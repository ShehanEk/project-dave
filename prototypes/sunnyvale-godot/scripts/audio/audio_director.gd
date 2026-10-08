extends Node
## Audio (autoload, M6) — the ONLY way any other script touches sound.
## play_sfx(cue, position) fires a one-shot cue (positional 2D when a
## position is given); set_music(track) crossfades between the two level
## music loops (`&"campus"`, `&"lockdown"`) or silence. See CONVENTIONS.md
## "Audio" for the full cue list and exactly which script still needs to
## call which cue.
##
## Cues are pooled AudioStreamPlayer/AudioStreamPlayer2D nodes routed to the
## project's existing "SFX"/"Music" buses (data/audio/default_bus_layout.tres
## — Settings already applies the player's volume sliders to those buses, so
## this script never touches volume itself, only a small per-cue mix trim —
## see SFX_SOURCES below). An unknown/misspelled cue name never crashes a
## caller: it emits exactly one push_warning per distinct unknown name, then
## does nothing. Every AudioStreamPlayer[2D] call here is also safe under
## --headless (Godot's dummy audio driver) and inside tests: nodes still
## instance/play/stop without producing an error, just no audible output —
## this project's tests actually exercise every cue (see
## tests/cases/test_m6_audio.gd).
##
## Registered as an autoload by scripts/tools/configure_project.gd (rerun
## after any change there).

const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"
## The ElevenLabs set (N05): sound effects, ambience beds and voice lines made by
## tools/process_elevenlabs.py, with their mix trims in this generated manifest
## (preloaded by path, like the art skins: no `class_name`). A cue that has an
## entry whose files load plays those; a cue with none (or whose files are missing)
## plays its SFX_SOURCES source below, so the old Kenney / synthesized sounds stay
## as the fallback.
const Eleven := preload("res://scripts/audio/eleven_manifest.gd")

## Every cue this project knows about (05-content-and-assets.md /
## audio-direction.md). Keep this list, SFX_SOURCES below, and
## tools/gen_audio.py's SFX_GENERATORS in sync — a name here with no entry in
## SFX_SOURCES resolves to zero streams (play_sfx on it then warns "unknown
## cue" like any other typo). gen_audio.py reads this list and the
## `SFX_DIR + "x.wav"` sources below at generation time and fails the run if a
## cue or a wav here has no generator there.
const SFX_NAMES: Array[StringName] = [
	&"pistol_fire", &"pistol_fire_quick", &"bolt_hit", &"bolt_blocked",
	&"hero_hurt", &"hero_jump", &"hero_land",
	&"staffer_windup", &"staffer_lunge", &"staffer_defeat",
	# Level 1 roster (C33): the Night Guard's baton, hits and falls on people, the
	# Patrol Rover's roll, tell, ram, stall, armor and wreck, and metal debris.
	&"guard_windup", &"guard_swing", &"hit_flesh", &"body_fall",
	&"rover_patrol", &"rover_windup", &"rover_charge", &"rover_stall", &"rover_armor", &"rover_destroyed",
	&"debris_clatter",
	&"chip", &"chip_cluster", &"cache_open", &"evidence", &"med_patch",
	&"interact", &"checkpoint", &"purchase", &"swap", &"latch",
	&"adam_chime", &"alarm", &"hatch_open", &"pit_fall", &"exit",
	&"ui_move", &"ui_confirm", &"ui_back", &"save_failed",
	# Night-campus additions: the clearance keycard and its wicket, the SC01
	# copy bar, the lockdown stinger, and the Link implant chirp.
	&"keycard", &"keycard_denied", &"door_unlock", &"uplink", &"lockdown", &"link_chirp",
]

## Cues that only exist as ElevenLabs sounds (they have no synthesized or Kenney
## source, so they are not in SFX_NAMES, which tools/gen_audio.py cross-checks):
## the hero's footsteps by surface, and three interface and weapon ticks.
const ELEVEN_ONLY_CUES: Array[StringName] = [
	&"footstep_paving", &"footstep_metal", &"footstep_roof",
	&"ui_pause", &"toast_save", &"ready_click",
	# The guards' and Staffers' spoken barks (played positionally at the speaker; the
	# text each says is in data/tuning/*.tres and scripts/audio/bark_map.gd maps it to
	# its cue), and the level-complete and checkpoint music stings.
	&"bark_guard_ground", &"bark_guard_security", &"bark_guard_there_he_is",
	&"bark_guard_dont_make_me", &"bark_guard_last_warning", &"bark_guard_hes_shooting",
	&"bark_guard_shots_fired",
	&"bark_staffer_stay", &"bark_staffer_workstation", &"bark_staffer_hold_still",
	&"bark_staffer_dave",
	&"sting_complete", &"sting_checkpoint",
]

## A small pitch nudge applied only to cues heard often enough (gunfire,
## footsteps, pickups, UI ticks) that hearing the exact same waveform every
## time would get noticeable/fatiguing. Rare or dramatic beats (attack
## telegraphs, story stingers, alarms, one-off pickups) are left at their
## authored pitch so they stay a precise, repeatable read.
const PITCH_VARIANCE_FREQUENT := 0.04

## Base playback pitch for the hero and pistol cues (all Kenney sources):
## about a semitone down, so the dark night-campus mix does not sit
## on bright, toy-like effects. Applied as the cue's "pitch" in SFX_SOURCES
## and multiplied with any pitch variance.
const DARKEN := 0.94

## Per-cue source pools + mix trim. Two source kinds: Kenney's CC0 interface/
## impact/ui-audio/sci-fi packs (see assets/kenney/README.md section 1) for
## the hero, pistol and generic UI/world cues, and the sounds that define the
## dark night-campus identity, synthesized by tools/gen_audio.py (the Night
## Guard's baton, hits and falls on people, the Staffer cues, the Patrol Rover
## and machine debris, microchips, evidence, med patch, Adam's PA chime, the
## alarm and lockdown stinger, the keycard family, uplink, Link chirp, the
## exit sting). `files` is one or more `res://` paths (multiple = a
## variety pool: play_sfx picks one at random each call, the same
## round-robin-ish spirit as the AudioStreamPlayer pools below, just applied
## to source material too); `volume_db` is a fixed trim applied to the pooled
## player before each play; `pitch_variance` is 0.0 or PITCH_VARIANCE_FREQUENT;
## `pitch` (optional, default 1.0) is the base pitch scale. The synthesized
## cues' trims come from a measured pass (each cue recorded as played through
## the Master bus; A-weighted RMS over the loudest 200 ms, dBFS): story beats
## -12 to -14 (Adam's chime, exit, evidence), the enemy tells and strikes and
## the keycard family -15 to -17 (the Staffer, Night Guard and Patrol Rover
## windups all sit at about -15.5, so no tell is louder than another), chips
## and med patch -16 to -20, the Staffer's collapse, the rover's wall crash and
## wreck -19, its armor clang -21, and the soft or repeated ones lower (denied
## buzz and Link chirp -22, a hit on a person -25 like Dave's own hurt cue,
## debris -25, uplink tick and the rover's idle roll -26 like the old Clipper's
## scrape, and a body landing -31, since a thud is mostly low end that the
## weighting discounts). The lockdown stinger (-17.5) and the alarm (-20.5) sit
## lower than their rank because core_node.gd plays them at the same instant:
## at their earlier levels their peaks summed to full scale with the master and
## SFX sliders at 100%. Kenney cues keep their original trims.
const SFX_SOURCES: Dictionary = {
	&"pistol_fire": {
		"files": [
			"res://assets/kenney/sci-fi-sounds/laserRetro_000.ogg",
			"res://assets/kenney/sci-fi-sounds/laserRetro_001.ogg",
			"res://assets/kenney/sci-fi-sounds/laserRetro_002.ogg",
		],
		"volume_db": -3.0, "pitch": DARKEN, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"pistol_fire_quick": {
		"files": [
			"res://assets/kenney/sci-fi-sounds/laserSmall_000.ogg",
			"res://assets/kenney/sci-fi-sounds/laserSmall_001.ogg",
		],
		"volume_db": -4.0, "pitch": DARKEN, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"bolt_hit": {
		"files": [
			"res://assets/kenney/impact-sounds/impactGeneric_light_000.ogg",
			"res://assets/kenney/impact-sounds/impactGeneric_light_001.ogg",
			"res://assets/kenney/impact-sounds/impactGeneric_light_002.ogg",
		],
		"volume_db": -4.0, "pitch": DARKEN, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	# The clang of a shot turned away (scrapjack.gd / scrap_bolt.gd play this on
	# a blocked shot; rover_armor below is the Patrol Rover's own) — trimmed
	# less than bolt_hit so it stays clearly, unmistakably audible over
	# pistol_fire without getting harsh.
	&"bolt_blocked": {
		"files": [
			"res://assets/kenney/impact-sounds/impactMetal_medium_000.ogg",
			"res://assets/kenney/impact-sounds/impactMetal_medium_001.ogg",
			"res://assets/kenney/impact-sounds/impactMetal_medium_002.ogg",
		],
		"volume_db": -2.0, "pitch": DARKEN, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"hero_hurt": {
		"files": ["res://assets/kenney/impact-sounds/impactPunch_medium_001.ogg"],
		"volume_db": -2.0, "pitch": DARKEN, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"hero_jump": {
		"files": ["res://assets/kenney/interface-sounds/pluck_001.ogg"],
		"volume_db": -5.0, "pitch": DARKEN, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"hero_land": {
		"files": [
			"res://assets/kenney/impact-sounds/footstep_concrete_000.ogg",
			"res://assets/kenney/impact-sounds/footstep_concrete_001.ogg",
			"res://assets/kenney/impact-sounds/footstep_concrete_002.ogg",
		],
		"volume_db": -6.0, "pitch": DARKEN, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	# Staffer cues (a Linked office worker: no groans, no servos). The port's
	# rising chirp is the tell, the lunge is a fast grab of air and cloth, and
	# the collapse is a spit of sparks, the light going out and a body landing.
	# None of the curated packs has an implant chirp, so these are synthesized.
	# Attack telegraphs keep a fixed pitch.
	&"staffer_windup": {
		"files": [SFX_DIR + "staffer_windup.wav"], "volume_db": -2.0, "pitch_variance": 0.0,
	},
	&"staffer_lunge": {
		"files": [SFX_DIR + "staffer_lunge.wav"], "volume_db": -3.0, "pitch_variance": 0.0,
	},
	&"staffer_defeat": {
		"files": [SFX_DIR + "staffer_defeat.wav"], "volume_db": -1.5, "pitch_variance": 0.0,
	},
	# Night Guard (SE01): the stun baton charging is the tell and the swing is the
	# commit, so both keep a fixed pitch. The hit on a person and the dull thud
	# of a body landing are restrained and low (never a splatter) and are heard
	# often enough to get the frequent nudge. Synthesized: the curated packs'
	# impacts are all bright, hollow or mechanical next to a person.
	&"guard_windup": {
		"files": [SFX_DIR + "guard_windup.wav"], "volume_db": -2.5, "pitch_variance": 0.0,
	},
	&"guard_swing": {
		"files": [SFX_DIR + "guard_swing.wav"], "volume_db": -5.0, "pitch_variance": 0.0,
	},
	&"hit_flesh": {
		"files": [SFX_DIR + "hit_flesh.wav"], "volume_db": -2.0, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"body_fall": {
		"files": [SFX_DIR + "body_fall.wav"], "volume_db": -5.5, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	# Patrol Rover (M01, the charger): a quiet electric roll while it patrols
	# (played again and again, so it gets the nudge), then the attack chain, all
	# at a fixed pitch like every telegraph: siren whoop with wheel-spin revs
	# (the tell), the motor surge (the ram), the crash and electrical fizz of the
	# wall stall. rover_armor is the clang of its armored front turning a shot,
	# rover_destroyed the burst and clatter of the wreck, debris_clatter a few
	# metal parts landing.
	&"rover_patrol": {
		"files": [SFX_DIR + "rover_patrol.wav"], "volume_db": -12.0, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"rover_windup": {
		"files": [SFX_DIR + "rover_windup.wav"], "volume_db": -5.5, "pitch_variance": 0.0,
	},
	&"rover_charge": {
		"files": [SFX_DIR + "rover_charge.wav"], "volume_db": -3.0, "pitch_variance": 0.0,
	},
	&"rover_stall": {
		"files": [SFX_DIR + "rover_stall.wav"], "volume_db": -2.0, "pitch_variance": 0.0,
	},
	&"rover_armor": {
		"files": [SFX_DIR + "rover_armor.wav"], "volume_db": -5.0, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"rover_destroyed": {
		"files": [SFX_DIR + "rover_destroyed.wav"], "volume_db": -4.0, "pitch_variance": 0.0,
	},
	&"debris_clatter": {
		"files": [SFX_DIR + "debris_clatter.wav"], "volume_db": -11.5, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	# Microchips: crisp digital blips (the cluster is brighter and multi-note).
	&"chip": {
		"files": [SFX_DIR + "chip.wav"], "volume_db": -4.0, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"chip_cluster": {
		"files": [SFX_DIR + "chip_cluster.wav"], "volume_db": -4.5, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"cache_open": {
		"files": ["res://assets/kenney/interface-sounds/open_001.ogg"],
		"volume_db": -4.0, "pitch_variance": 0.0,
	},
	# Evidence file: a data-save chirp. Med patch: soft hiss plus a beep.
	&"evidence": {
		"files": [SFX_DIR + "evidence.wav"], "volume_db": -3.5, "pitch_variance": 0.0,
	},
	&"med_patch": {
		"files": [SFX_DIR + "med_patch.wav"], "volume_db": -10.0, "pitch_variance": 0.0,
	},
	&"interact": {
		"files": ["res://assets/kenney/interface-sounds/select_001.ogg"],
		"volume_db": -8.0, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"checkpoint": {
		"files": ["res://assets/kenney/interface-sounds/bong_001.ogg"],
		"volume_db": -4.0, "pitch_variance": 0.0,
	},
	&"purchase": {
		"files": ["res://assets/kenney/interface-sounds/select_005.ogg"],
		"volume_db": -4.0, "pitch_variance": 0.0,
	},
	&"swap": {
		"files": ["res://assets/kenney/ui-audio/switch1.ogg"],
		"volume_db": -6.0, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"latch": {
		"files": ["res://assets/kenney/sci-fi-sounds/doorClose_000.ogg"],
		"volume_db": -3.0, "pitch_variance": 0.0,
	},
	# Adam's PA chime (SC01, "Hello, Dr. Harlan"): two soft, reverberant notes
	# that are pleasant and slightly wrong. Bespoke; nothing in the packs is
	# warm and eerie at once.
	&"adam_chime": {
		"files": [SFX_DIR + "adam_chime.wav"], "volume_db": -2.0, "pitch_variance": 0.0,
	},
	# Low emergency tone (never piercing), and the stinger the lockdown starts
	# with. core_node.gd plays both at the same instant; they share a key.
	&"alarm": {
		"files": [SFX_DIR + "alarm.wav"], "volume_db": -6.5, "pitch_variance": 0.0,
	},
	&"lockdown": {
		"files": [SFX_DIR + "lockdown.wav"], "volume_db": -4.0, "pitch_variance": 0.0,
	},
	&"hatch_open": {
		"files": ["res://assets/kenney/sci-fi-sounds/doorOpen_000.ogg"],
		"volume_db": -3.0, "pitch_variance": 0.0,
	},
	&"pit_fall": {
		"files": ["res://assets/kenney/impact-sounds/impactSoft_heavy_000.ogg"],
		"volume_db": -2.0, "pitch_variance": 0.0,
	},
	# Level-completion sting — none of these one-shot UI/impact/sci-fi packs
	# contain a finale/musical phrase; synthesized (an open-fifth ladder in D,
	# the same key as the unlock beep that plays with it).
	&"exit": {
		"files": [SFX_DIR + "exit.wav"], "volume_db": -0.5, "pitch_variance": 0.0,
	},
	&"ui_move": {
		"files": [
			"res://assets/kenney/ui-audio/rollover2.ogg",
			"res://assets/kenney/ui-audio/rollover3.ogg",
			"res://assets/kenney/ui-audio/rollover4.ogg",
		],
		"volume_db": -12.0, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"ui_confirm": {
		"files": [
			"res://assets/kenney/ui-audio/click1.ogg",
			"res://assets/kenney/ui-audio/click2.ogg",
		],
		"volume_db": -9.0, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"ui_back": {
		"files": [
			"res://assets/kenney/interface-sounds/back_001.ogg",
			"res://assets/kenney/interface-sounds/back_002.ogg",
		],
		"volume_db": -9.0, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"save_failed": {
		"files": ["res://assets/kenney/interface-sounds/error_001.ogg"],
		"volume_db": -6.0, "pitch_variance": 0.0,
	},
	# The clearance keycard: pickup chirp (a rising two-note access tone),
	# a short low reader buzz when the wicket refuses, and the wicket's
	# mechanical clunk plus a teal confirmation beep. Fixed pitch: each one
	# is a precise, repeatable read.
	&"keycard": {
		"files": [SFX_DIR + "keycard.wav"], "volume_db": -6.0, "pitch_variance": 0.0,
	},
	&"keycard_denied": {
		"files": [SFX_DIR + "keycard_denied.wav"], "volume_db": -3.5, "pitch_variance": 0.0,
	},
	&"door_unlock": {
		"files": [SFX_DIR + "door_unlock.wav"], "volume_db": -5.5, "pitch_variance": 0.0,
	},
	# SC01's copy bar ticks this every ~0.45 s, so it is short, soft and gets
	# the frequent pitch nudge; the Link chirp (brawler.gd plays it once as a
	# dormant Staffer wakes and Adam takes the body over) is tiny but must
	# still read over the music bed.
	&"uplink": {
		"files": [SFX_DIR + "uplink.wav"], "volume_db": -6.5, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	&"link_chirp": {
		"files": [SFX_DIR + "link_chirp.wav"], "volume_db": -6.5, "pitch_variance": PITCH_VARIANCE_FREQUENT,
	},
	# ElevenLabs-only cues (ELEVEN_ONLY_CUES): no old source, so "files" is empty and
	# the trim here only matters if the manifest is ever missing. Steps are heard
	# constantly, so they take the pitch nudge; the interface ticks do too.
	&"footstep_paving": {"files": [], "volume_db": -20.0, "pitch_variance": PITCH_VARIANCE_FREQUENT},
	&"footstep_metal": {"files": [], "volume_db": -20.0, "pitch_variance": PITCH_VARIANCE_FREQUENT},
	&"footstep_roof": {"files": [], "volume_db": -22.0, "pitch_variance": PITCH_VARIANCE_FREQUENT},
	&"ui_pause": {"files": [], "volume_db": -13.0, "pitch_variance": 0.0},
	&"toast_save": {"files": [], "volume_db": -14.0, "pitch_variance": 0.0},
	&"ready_click": {"files": [], "volume_db": -14.0, "pitch_variance": PITCH_VARIANCE_FREQUENT},
	# Spoken barks and the two stings: fixed pitch (a voice nudged in pitch sounds wrong).
	&"bark_guard_ground": {"files": [], "volume_db": -6.0, "pitch_variance": 0.0},
	&"bark_guard_security": {"files": [], "volume_db": -6.0, "pitch_variance": 0.0},
	&"bark_guard_there_he_is": {"files": [], "volume_db": -6.0, "pitch_variance": 0.0},
	&"bark_guard_dont_make_me": {"files": [], "volume_db": -6.0, "pitch_variance": 0.0},
	&"bark_guard_last_warning": {"files": [], "volume_db": -6.0, "pitch_variance": 0.0},
	&"bark_guard_hes_shooting": {"files": [], "volume_db": -6.0, "pitch_variance": 0.0},
	&"bark_guard_shots_fired": {"files": [], "volume_db": -6.0, "pitch_variance": 0.0},
	&"bark_staffer_stay": {"files": [], "volume_db": -9.0, "pitch_variance": 0.0},
	&"bark_staffer_workstation": {"files": [], "volume_db": -9.0, "pitch_variance": 0.0},
	&"bark_staffer_hold_still": {"files": [], "volume_db": -9.0, "pitch_variance": 0.0},
	&"bark_staffer_dave": {"files": [], "volume_db": -9.0, "pitch_variance": 0.0},
	&"sting_complete": {"files": [], "volume_db": -4.0, "pitch_variance": 0.0},
	&"sting_checkpoint": {"files": [], "volume_db": -8.0, "pitch_variance": 0.0},
}

## Music track key (as passed to set_music) -> file basename under MUSIC_DIR.
const MUSIC_FILES := {
	&"campus": "campus_loop",
	&"lockdown": "lockdown_loop",
}

## Ambience beds (set_ambience) fade over this long; a spoken line (play_voice) uses
## one player of its own so a new line cuts the old one.
const AMBIENCE_CROSSFADE_SECONDS := 2.0
const AMBIENCE_NONE := &"none"

const SFX_POOL_SIZE := 10
const SFX2D_POOL_SIZE := 16

## When every pooled player is busy a new sound takes one over: the OLDEST player
## whose sound is not more important than the new one. Spoken barks, the music
## stings and the story beats are important (priority 2) and are only ever cut by
## another important sound, never by footsteps, hits or the like. (A Rover that
## turned every frame once filled the whole pool and cut every bark.)
const PRIORITY_CUE_PREFIXES: Array[String] = ["bark_", "sting_"]
const PRIORITY_CUES: Array[StringName] = [&"adam_chime", &"lockdown", &"alarm", &"exit"]

## The least time between two plays of the same cue, in seconds of game time, for
## the cues that can be asked for every frame. The Rover's turn roll is requested on
## each physics frame while it is blocked and flipping.
const CUE_MIN_GAP_SECONDS := {
	&"rover_patrol": 1.2,
}

## A positional sound farther than this from the camera is silent anyway (the 2D
## players' default max_distance is 2000 px), so it takes no player at all.
const AUDIBLE_RANGE := 2100.0
const MUSIC_CROSSFADE_SECONDS := 1.2
## How fast set_music_duck() lowers or restores the music.
const MUSIC_DUCK_SECONDS := 0.6
const MUSIC_FADE_DB := -80.0

## StringName -> {"streams": Array[AudioStream], "volume_db": float, "pitch": float,
## "pitch_variance": float}.
## Built once in _load_streams() from SFX_SOURCES; a cue whose configured
## files all failed to load (missing on disk) ends up with an empty
## "streams" array and behaves exactly like an unknown cue (play_sfx warns
## once and no-ops) rather than erroring.
var _sfx_pools: Dictionary = {}
var _music_streams: Dictionary = {}  # StringName -> AudioStreamWAV
var _music_trims: Dictionary = {}    # StringName -> float (the track's own level, dB)
var _music_sources: Dictionary = {}  # StringName -> &"eleven" | &"legacy"
## The synthesized loops stay loaded (and looped) even where an ElevenLabs loop has
## replaced them: they are the fallback, and holding them keeps the shared resource
## (with its loop points) alive for anything else that loads the same file.
var _legacy_music_streams: Dictionary = {}
var _ambience_streams: Dictionary = {}  # StringName -> {"stream": AudioStreamWAV, "volume_db": float}
var _voice_lines: Dictionary = {}       # StringName -> {"streams": Array, "volume_db": float}
var _warned_cues: Dictionary = {}    # StringName -> true (warn once each)

var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx2d_pool: Array[AudioStreamPlayer2D] = []
var _cue_last_frame: Dictionary = {}  # StringName -> physics frame of the last play
var _play_serial: int = 0              # counts plays, so "oldest" is exact even within one frame

var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _music_active: AudioStreamPlayer = null
var _music_tween: Tween = null
var _music_duck: AudioEffectAmplify = null
var _music_duck_tween: Tween = null
var _music_duck_target := 0.0

var _ambience_a: AudioStreamPlayer
var _ambience_b: AudioStreamPlayer
var _ambience_active: AudioStreamPlayer = null
var _ambience_tween: Tween = null
var _ambience_current: StringName = &"__unset__"

var _voice_player: AudioStreamPlayer
var _voice_current: StringName = &""
## Sentinel (not a real track key) so the very first set_music() call — even
## set_music(&"none") from the title screen — always actually applies.
var _music_current: StringName = &"__unset__"

var _re_cluster := RegEx.new()
var _re_chip := RegEx.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_re_cluster.compile("-GC\\d+$")
	_re_chip.compile("-G\\d+$")
	_load_streams()
	_build_pools()
	_music_a = _make_music_player()
	_music_b = _make_music_player()
	_ambience_a = _make_ambience_player()
	_ambience_b = _make_ambience_player()
	_voice_player = AudioStreamPlayer.new()
	_voice_player.bus = _safe_bus("SFX")
	add_child(_voice_player)
	_connect_session()


func _make_music_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = _safe_bus("Music")
	p.volume_db = MUSIC_FADE_DB
	add_child(p)
	return p


func _make_ambience_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = _safe_bus("SFX")
	p.volume_db = MUSIC_FADE_DB
	add_child(p)
	return p


func _safe_bus(bus_name: String) -> String:
	return bus_name if AudioServer.get_bus_index(bus_name) >= 0 else "Master"


func _load_streams() -> void:
	var cues: Array[StringName] = []
	cues.append_array(SFX_NAMES)
	cues.append_array(ELEVEN_ONLY_CUES)
	for cue in cues:
		var source: Dictionary = SFX_SOURCES.get(cue, {})
		var pitch_variance := float(source.get("pitch_variance", 0.0))
		var eleven_streams := _load_all(Eleven.SFX.get(cue, {}).get("files", []))
		if not eleven_streams.is_empty():
			# The ElevenLabs takes: levelled by the tool, so the manifest's trim is the
			# cue's mix and the Kenney "darker" base pitch no longer applies.
			_sfx_pools[cue] = {
				"streams": eleven_streams,
				"volume_db": float(Eleven.SFX[cue].get("volume_db", 0.0)),
				"pitch": 1.0,
				"pitch_variance": pitch_variance,
				"source": &"eleven",
			}
			continue
		_sfx_pools[cue] = {
			"streams": _load_all(source.get("files", [])),
			"volume_db": float(source.get("volume_db", 0.0)),
			"pitch": float(source.get("pitch", 1.0)),
			"pitch_variance": pitch_variance,
			"source": &"legacy",
		}
	for bed in Eleven.AMBIENCE:
		var entry: Dictionary = Eleven.AMBIENCE[bed]
		var path: String = entry.get("file", "")
		if not ResourceLoader.exists(path):
			continue
		var stream: AudioStreamWAV = load(path)
		if stream:
			_make_seamless(stream)
			_ambience_streams[bed] = {"stream": stream, "volume_db": float(entry.get("volume_db", 0.0))}
	for line in Eleven.VOICE:
		var entry: Dictionary = Eleven.VOICE[line]
		var streams := _load_all(entry.get("files", []))
		if not streams.is_empty():
			_voice_lines[line] = {"streams": streams, "volume_db": float(entry.get("volume_db", 0.0))}
	for key in MUSIC_FILES:
		var path := MUSIC_DIR + String(MUSIC_FILES[key]) + ".wav"
		if not ResourceLoader.exists(path):
			continue
		var stream: AudioStreamWAV = load(path)
		if stream:
			_make_seamless(stream)
			_legacy_music_streams[key] = stream
			_music_streams[key] = stream
			_music_trims[key] = 0.0
			_music_sources[key] = &"legacy"
	# The ElevenLabs loops (stereo, levelled to the synthesized ones): a track with a
	# loadable file here replaces the synthesized loop of the same key, and the
	# depot and title tracks exist only here.
	for key in Eleven.MUSIC:
		var entry: Dictionary = Eleven.MUSIC[key]
		var path: String = entry.get("file", "")
		if not ResourceLoader.exists(path):
			continue
		var stream: AudioStreamWAV = load(path)
		if stream:
			_make_seamless(stream)
			_music_streams[key] = stream
			_music_trims[key] = float(entry.get("volume_db", 0.0))
			_music_sources[key] = &"eleven"


func _load_all(paths: Array) -> Array[AudioStream]:
	var streams: Array[AudioStream] = []
	for path in paths:
		if not ResourceLoader.exists(path):
			continue
		var stream: AudioStream = load(path)
		if stream:
			streams.append(stream)
	return streams


## Sets the WAV's own loop points to its full length so AudioStreamPlayer
## repeats it with no engine-level restart gap (loop content itself is
## authored to be seamless at that point — see tools/gen_audio.py's
## loop_locked_freq() comment). The frame count comes from get_length(), not
## from the byte size of `data`: an imported WAV may be QOA- or ADPCM-
## compressed (the importer's default is QOA), where `data` holds far fewer
## bytes than frames and a byte-based count would loop only the first fifth
## of the track.
func _make_seamless(stream: AudioStreamWAV) -> void:
	var frames := int(round(stream.get_length() * float(stream.mix_rate)))
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = frames


func _build_pools() -> void:
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = _safe_bus("SFX")
		add_child(p)
		_sfx_pool.append(p)
	for i in SFX2D_POOL_SIZE:
		var p := AudioStreamPlayer2D.new()
		p.bus = _safe_bus("SFX")
		add_child(p)
		_sfx2d_pool.append(p)


func _connect_session() -> void:
	var session := get_node_or_null("/root/Session")
	if session == null:
		return
	session.pickup_collected.connect(_on_pickup_collected)
	session.evidence_recorded.connect(_on_evidence_recorded)
	session.checkpoint_committed.connect(_on_checkpoint_committed)
	session.upgrade_purchased.connect(_on_upgrade_purchased)
	session.weapon_swapped.connect(_on_weapon_swapped)
	session.save_failed.connect(_on_save_failed)
	session.story_state_changed.connect(_on_story_state_changed)
	session.level_completed.connect(_on_level_completed)


# --- public API ----------------------------------------------------------------

## Plays a one-shot cue. `position` (Vector2) plays it positionally through a
## small AudioStreamPlayer2D pool; omitted/null plays it as a flat 2D-less
## cue (UI, HUD, global world events) through a small AudioStreamPlayer pool.
## Returns the pooled player it used (so a caller can stop its own sound with
## stop_player_if_playing), or null for an unknown cue. An unknown cue name — or
## one whose configured source file(s) failed to
## load — never errors: it push_warnings once and returns. When a cue has
## more than one pooled source file, one is picked at random each call; the
## cue's base "pitch" (see SFX_SOURCES) is applied, and a small pitch_variance
## adds a further +-N% pitch nudge on top of that for cues heard often enough
## that exact repetition would be noticeable.
func play_sfx(cue: StringName, position: Variant = null) -> Node:
	var pool: Dictionary = _sfx_pools.get(cue, {})
	var streams: Array = pool.get("streams", [])
	if streams.is_empty():
		if not _warned_cues.has(cue):
			_warned_cues[cue] = true
			push_warning("Audio.play_sfx: unknown cue %s" % String(cue))
		return null
	var gap_seconds: float = CUE_MIN_GAP_SECONDS.get(cue, 0.0)
	if gap_seconds > 0.0:
		var frame := Engine.get_physics_frames()
		var min_frames := int(ceil(gap_seconds * float(Engine.physics_ticks_per_second)))
		if frame - int(_cue_last_frame.get(cue, -1000000)) < min_frames:
			return null
		_cue_last_frame[cue] = frame
	if position != null and not _audible_from_camera(position):
		return null
	var stream: AudioStream = streams[randi() % streams.size()]
	var volume_db: float = pool.get("volume_db", 0.0)
	var pitch_variance: float = pool.get("pitch_variance", 0.0)
	var pitch_scale: float = pool.get("pitch", 1.0)
	if pitch_variance > 0.0:
		pitch_scale *= 1.0 + randf_range(-pitch_variance, pitch_variance)
	var priority := _cue_priority(cue)
	if position != null:
		var player2d: AudioStreamPlayer2D = _acquire_2d(priority)
		_play_serial += 1
		player2d.set_meta(&"priority", priority)
		player2d.set_meta(&"serial", _play_serial)
		player2d.global_position = position
		player2d.stream = stream
		player2d.volume_db = volume_db
		player2d.pitch_scale = pitch_scale
		player2d.play()
		return player2d
	var player: AudioStreamPlayer = _acquire_flat(priority)
	_play_serial += 1
	player.set_meta(&"priority", priority)
	player.set_meta(&"serial", _play_serial)
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
	return player


## Stops every pooled player that is playing one of `cue`'s sounds right now (a
## long sting that the next screen must not overlap). Pooled players are reused, so
## this matches on the stream, never on the player: it never cuts another cue.
func stop_sfx(cue: StringName) -> void:
	var streams: Array = _sfx_pools.get(cue, {}).get("streams", [])
	if streams.is_empty():
		return
	for p in _sfx_pool:
		if p.playing and streams.has(p.stream):
			p.stop()
	for p in _sfx2d_pool:
		if p.playing and streams.has(p.stream):
			p.stop()


## Stops `player` if it is STILL playing `stream`: the handle `play_sfx` returned
## may have been reused by another cue since, and that one must not be cut. For
## a speaker who must not talk over himself or keep talking after he dies.
func stop_player_if_playing(player: Node, stream: AudioStream) -> void:
	if is_instance_valid(player) and player.playing and player.stream == stream:
		player.stop()


## Switches the level music. `track` is `&"campus"`, `&"lockdown"`, `&"depot"`,
## `&"title"` or `&"none"` (depot and title exist only as ElevenLabs loops; a track
## with no loaded stream is silence, never an error). Crossfades over MUSIC_CROSSFADE_SECONDS; calling it again with
## the CURRENT track is a no-op (never restarts a loop that's already
## playing). The logical "current track" updates immediately (readable via
## current_music()) even though the audible fade takes a moment — callers
## and tests never need to wait out the fade to know which track is active.
func set_music(track: StringName) -> void:
	if track == _music_current:
		return
	_music_current = track

	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = null

	var outgoing := _music_active
	var target_stream: AudioStreamWAV = _music_streams.get(track, null)

	# Nothing audible to change (e.g. the very first set_music(&"none") at
	# boot, before anything ever played) — a Tween started with zero
	# Tweeners is itself an engine error, so skip making one.
	if target_stream == null and not (outgoing and outgoing.playing):
		_music_active = null
		return

	_music_tween = create_tween()
	_music_tween.set_parallel(true)

	if target_stream:
		var incoming := _music_b if outgoing == _music_a else _music_a
		incoming.stream = target_stream
		incoming.volume_db = MUSIC_FADE_DB
		incoming.play()
		_music_tween.tween_property(incoming, "volume_db", float(_music_trims.get(track, 0.0)), MUSIC_CROSSFADE_SECONDS)
		_music_active = incoming
	else:
		_music_active = null

	if outgoing and outgoing != _music_active and outgoing.playing:
		_music_tween.tween_property(outgoing, "volume_db", MUSIC_FADE_DB, MUSIC_CROSSFADE_SECONDS)
		_music_tween.chain().tween_callback(outgoing.stop)


## Lowers all music by `db` (0.0 restores it) over MUSIC_DUCK_SECONDS, under a voice
## that must be heard over it: the SC00 intro comic ducks the title theme under its
## narration. It works on an Amplify effect on the Music bus, so the player's Music
## slider (the bus volume) and set_music()'s own fades are untouched.
func set_music_duck(db: float) -> void:
	_music_duck_target = db
	var bus := AudioServer.get_bus_index("Music")
	if bus < 0:
		return
	if _music_duck == null:
		_music_duck = AudioEffectAmplify.new()
		_music_duck.volume_db = 0.0
		AudioServer.add_bus_effect(bus, _music_duck)
	if _music_duck_tween and _music_duck_tween.is_valid():
		_music_duck_tween.kill()
	_music_duck_tween = create_tween()
	_music_duck_tween.tween_property(_music_duck, "volume_db", db, MUSIC_DUCK_SECONDS)


## The duck set_music_duck() is heading for (0.0 when the music is not ducked).
func music_duck() -> float:
	return _music_duck_target


## Switches the ambience bed under the music: `bed` is a key of the manifest's
## AMBIENCE (`&"amb_campus_night"`, `&"amb_roof_night"`, `&"amb_plaza_wet"`,
## `&"amb_depot_hum"`, `&"amb_lockdown_bed"`, `&"amb_alarm_far"`, `&"amb_wicket_yard"`,
## `&"amb_server_core"`) or `&"none"`. Crossfades over AMBIENCE_CROSSFADE_SECONDS;
## asking for the bed already playing is a no-op, and a bed whose file is missing is
## silence rather than an error. The beds are seamless loops on the SFX bus, so the
## player's SFX slider sets their volume.
func set_ambience(bed: StringName) -> void:
	if bed == _ambience_current:
		return
	_ambience_current = bed
	if _ambience_tween and _ambience_tween.is_valid():
		_ambience_tween.kill()
	_ambience_tween = null
	var outgoing := _ambience_active
	var entry: Dictionary = _ambience_streams.get(bed, {})
	if entry.is_empty() and not (outgoing and outgoing.playing):
		_ambience_active = null
		return
	_ambience_tween = create_tween()
	_ambience_tween.set_parallel(true)
	if not entry.is_empty():
		var incoming := _ambience_b if outgoing == _ambience_a else _ambience_a
		incoming.stream = entry["stream"]
		incoming.volume_db = MUSIC_FADE_DB
		incoming.play()
		_ambience_tween.tween_property(incoming, "volume_db", float(entry["volume_db"]), AMBIENCE_CROSSFADE_SECONDS)
		_ambience_active = incoming
	else:
		_ambience_active = null
	if outgoing and outgoing != _ambience_active and outgoing.playing:
		_ambience_tween.tween_property(outgoing, "volume_db", MUSIC_FADE_DB, AMBIENCE_CROSSFADE_SECONDS)
		_ambience_tween.chain().tween_callback(outgoing.stop)


## The bed asked for last (`&"none"`, a manifest key, or the unset sentinel before
## the first set_ambience() call). For tests and readers.
func current_ambience() -> StringName:
	return _ambience_current


## True while `bed` has a loaded loop. For tests.
func has_ambience(bed: StringName) -> bool:
	return _ambience_streams.has(bed)


## Plays a spoken line (`&"adam_hello"`, `&"adam_stay"`, `&"dave_word_gets_around"`,
## `&"pa_lethal"`, `&"pa_remain_calm"`) and returns its length in seconds, so the
## caller can hold the subtitle for as long as the voice runs. One line speaks at a
## time: a new line cuts the old one, and stop_voice() ends it (the dialogue skip).
## Alternate takes are picked at random. An unknown line, or one with no loaded file,
## plays nothing and returns 0.0.
func play_voice(line: StringName) -> float:
	var entry: Dictionary = _voice_lines.get(line, {})
	var streams: Array = entry.get("streams", [])
	if streams.is_empty():
		return 0.0
	var stream: AudioStream = streams[randi() % streams.size()]
	_voice_player.stream = stream
	_voice_player.volume_db = float(entry.get("volume_db", 0.0))
	_voice_player.play()
	_voice_current = line
	return stream.get_length()


func stop_voice() -> void:
	if _voice_player and _voice_player.playing:
		_voice_player.stop()
	_voice_current = &""


## The line speaking now, or &"" when none is. For tests.
func current_voice() -> StringName:
	return _voice_current if _voice_player and _voice_player.playing else &""


## True while `line` has at least one loaded take. For tests.
func has_voice(line: StringName) -> bool:
	return _voice_lines.has(line)


## The length of `line`'s first take in seconds (0.0 for an unknown line), so a
## caller can plan around it before playing.
func voice_length(line: StringName) -> float:
	var streams: Array = _voice_lines.get(line, {}).get("streams", [])
	return (streams[0] as AudioStream).get_length() if not streams.is_empty() else 0.0


## True while `track` has a loaded music loop. For tests and callers that pick a
## track only when it exists.
func has_music(track: StringName) -> bool:
	return _music_streams.has(track)


## Where `track` plays from: &"eleven" (the ElevenLabs loop), &"legacy" (the
## synthesized one) or &"" (no such track). For tests.
func music_source(track: StringName) -> StringName:
	return _music_sources.get(track, &"")


## The logical current track key (&"campus" / &"lockdown" / &"none" /
## the unset sentinel before the first set_music() call). For tests and any
## reader that wants to know what's playing without inspecting player nodes.
func current_music() -> StringName:
	return _music_current


## True while `cue` has at least one loaded stream (.wav or .ogg) behind it
## (i.e. play_sfx(cue) will actually play something rather than
## push_warning and no-op). For tests.
func has_cue(cue: StringName) -> bool:
	return not (_sfx_pools.get(cue, {}).get("streams", []) as Array).is_empty()


## Where `cue` plays from: &"eleven" (the ElevenLabs takes), &"legacy" (its old
## Kenney or synthesized source) or &"" for an unknown cue. For tests.
func cue_source(cue: StringName) -> StringName:
	return _sfx_pools.get(cue, {}).get("source", &"")


## The number of loaded source-file variants behind `cue` (0 for an unknown
## cue or one whose files all failed to load). For tests.
func cue_variant_count(cue: StringName) -> int:
	return (_sfx_pools.get(cue, {}).get("streams", []) as Array).size()


# --- pool helpers ----------------------------------------------------------------

func _acquire_flat(priority: int = 1) -> AudioStreamPlayer:
	for p in _sfx_pool:
		if not p.playing:
			return p
	return _oldest_not_above(_sfx_pool, priority) as AudioStreamPlayer


func _acquire_2d(priority: int = 1) -> AudioStreamPlayer2D:
	for p in _sfx2d_pool:
		if not p.playing:
			return p
	return _oldest_not_above(_sfx2d_pool, priority) as AudioStreamPlayer2D


## The player to take over when the pool is full: the oldest one whose sound is no
## more important than `priority`; if every player holds something more important,
## the oldest of all.
func _oldest_not_above(pool: Array, priority: int) -> Node:
	var best: Node = null
	var best_time := 0
	for p in pool:
		if int(p.get_meta(&"priority", 1)) > priority:
			continue
		var t := int(p.get_meta(&"serial", 0))
		if best == null or t < best_time:
			best = p
			best_time = t
	if best != null:
		return best
	for p in pool:
		var t := int(p.get_meta(&"serial", 0))
		if best == null or t < best_time:
			best = p
			best_time = t
	return best


func _cue_priority(cue: StringName) -> int:
	if PRIORITY_CUES.has(cue):
		return 2
	var name := String(cue)
	for prefix in PRIORITY_CUE_PREFIXES:
		if name.begins_with(prefix):
			return 2
	return 1


## False for a positional sound the camera is too far from to hear. With no camera
## (isolated test scenes, the title) everything counts as audible.
func _audible_from_camera(position: Vector2) -> bool:
	var viewport := get_viewport()
	var camera := viewport.get_camera_2d() if viewport else null
	if camera == null:
		return true
	return camera.get_screen_center_position().distance_to(position) <= AUDIBLE_RANGE


# --- Session signal wiring (ADV: audio calls only, never gameplay) ---------------

func _on_pickup_collected(entity_id: String) -> void:
	var cue := _cue_for_pickup(entity_id)
	if cue != &"":
		play_sfx(cue)


## Cues driven purely by entity_id shape (CONVENTIONS.md "IDs"): caches
## (`...-CACHE##`), med patches (`L01-HS##`), chip clusters (`...-GC##`),
## plain chips (`...-G###`). Anything else intentionally returns "" here:
## an evidence file's own pickup id (`L01-OPT01-A01`) — record_evidence()
## already fires its own evidence_recorded signal (handled below) — and the
## keycard's (`L01-KC01-P`), which keycard.gd cues itself as &"keycard".
## Neither may also play a chip-family sound over it.
func _cue_for_pickup(entity_id: String) -> StringName:
	if entity_id.findn("CACHE") != -1:
		return &"cache_open"
	if entity_id.begins_with("L01-HS"):
		return &"med_patch"
	if _re_cluster.search(entity_id):
		return &"chip_cluster"
	if _re_chip.search(entity_id):
		return &"chip"
	return &""


func _on_evidence_recorded(_evidence_id: String) -> void:
	play_sfx(&"evidence")


func _on_checkpoint_committed(_checkpoint_id: String) -> void:
	play_sfx(&"checkpoint")


func _on_upgrade_purchased(_weapon_type: String, _stage: int) -> void:
	play_sfx(&"purchase")


func _on_weapon_swapped(_old_id: String, _new_id: String) -> void:
	play_sfx(&"swap")


func _on_save_failed(_reason: String, _attempted_checkpoint_id: String) -> void:
	play_sfx(&"save_failed")


## Live awakening moment (SC01 finishing, or an art/UI-script hand-off — this
## fires on Session.set_story("awakening_done", true) however it's reached).
## Continue-after-awakening (load_from_snapshot never re-emits this signal)
## is handled explicitly by scripts/main.gd instead — see CONVENTIONS.md.
func _on_story_state_changed(flag: String, value: Variant) -> void:
	if flag == "awakening_done" and value == true:
		set_music(&"lockdown")


func _on_level_completed() -> void:
	play_sfx(&"exit")
