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
}

## Music track key (as passed to set_music) -> file basename under MUSIC_DIR.
const MUSIC_FILES := {
	&"campus": "campus_loop",
	&"lockdown": "lockdown_loop",
}

const SFX_POOL_SIZE := 6
const SFX2D_POOL_SIZE := 8
const MUSIC_CROSSFADE_SECONDS := 1.2
const MUSIC_FADE_DB := -80.0

## StringName -> {"streams": Array[AudioStream], "volume_db": float, "pitch": float,
## "pitch_variance": float}.
## Built once in _load_streams() from SFX_SOURCES; a cue whose configured
## files all failed to load (missing on disk) ends up with an empty
## "streams" array and behaves exactly like an unknown cue (play_sfx warns
## once and no-ops) rather than erroring.
var _sfx_pools: Dictionary = {}
var _music_streams: Dictionary = {}  # StringName -> AudioStreamWAV
var _warned_cues: Dictionary = {}    # StringName -> true (warn once each)

var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_next: int = 0
var _sfx2d_pool: Array[AudioStreamPlayer2D] = []
var _sfx2d_pool_next: int = 0

var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _music_active: AudioStreamPlayer = null
var _music_tween: Tween = null
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
	_connect_session()


func _make_music_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = _safe_bus("Music")
	p.volume_db = MUSIC_FADE_DB
	add_child(p)
	return p


func _safe_bus(bus_name: String) -> String:
	return bus_name if AudioServer.get_bus_index(bus_name) >= 0 else "Master"


func _load_streams() -> void:
	for cue in SFX_NAMES:
		var source: Dictionary = SFX_SOURCES.get(cue, {})
		var streams: Array[AudioStream] = []
		for path in source.get("files", []):
			if not ResourceLoader.exists(path):
				continue
			var stream: AudioStream = load(path)
			if stream:
				streams.append(stream)
		_sfx_pools[cue] = {
			"streams": streams,
			"volume_db": float(source.get("volume_db", 0.0)),
			"pitch": float(source.get("pitch", 1.0)),
			"pitch_variance": float(source.get("pitch_variance", 0.0)),
		}
	for key in MUSIC_FILES:
		var path := MUSIC_DIR + String(MUSIC_FILES[key]) + ".wav"
		if not ResourceLoader.exists(path):
			continue
		var stream: AudioStreamWAV = load(path)
		if stream:
			_make_seamless(stream)
			_music_streams[key] = stream


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
## An unknown cue name — or one whose configured source file(s) failed to
## load — never errors: it push_warnings once and returns. When a cue has
## more than one pooled source file, one is picked at random each call; the
## cue's base "pitch" (see SFX_SOURCES) is applied, and a small pitch_variance
## adds a further +-N% pitch nudge on top of that for cues heard often enough
## that exact repetition would be noticeable.
func play_sfx(cue: StringName, position: Variant = null) -> void:
	var pool: Dictionary = _sfx_pools.get(cue, {})
	var streams: Array = pool.get("streams", [])
	if streams.is_empty():
		if not _warned_cues.has(cue):
			_warned_cues[cue] = true
			push_warning("Audio.play_sfx: unknown cue %s" % String(cue))
		return
	var stream: AudioStream = streams[randi() % streams.size()]
	var volume_db: float = pool.get("volume_db", 0.0)
	var pitch_variance: float = pool.get("pitch_variance", 0.0)
	var pitch_scale: float = pool.get("pitch", 1.0)
	if pitch_variance > 0.0:
		pitch_scale *= 1.0 + randf_range(-pitch_variance, pitch_variance)
	if position != null:
		var player2d: AudioStreamPlayer2D = _acquire_2d()
		player2d.global_position = position
		player2d.stream = stream
		player2d.volume_db = volume_db
		player2d.pitch_scale = pitch_scale
		player2d.play()
	else:
		var player: AudioStreamPlayer = _acquire_flat()
		player.stream = stream
		player.volume_db = volume_db
		player.pitch_scale = pitch_scale
		player.play()


## Switches the level music. `track` is `&"campus"`, `&"lockdown"` or
## `&"none"`. Crossfades over MUSIC_CROSSFADE_SECONDS; calling it again with
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
		_music_tween.tween_property(incoming, "volume_db", 0.0, MUSIC_CROSSFADE_SECONDS)
		_music_active = incoming
	else:
		_music_active = null

	if outgoing and outgoing != _music_active and outgoing.playing:
		_music_tween.tween_property(outgoing, "volume_db", MUSIC_FADE_DB, MUSIC_CROSSFADE_SECONDS)
		_music_tween.chain().tween_callback(outgoing.stop)


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


## The number of loaded source-file variants behind `cue` (0 for an unknown
## cue or one whose files all failed to load). For tests.
func cue_variant_count(cue: StringName) -> int:
	return (_sfx_pools.get(cue, {}).get("streams", []) as Array).size()


# --- pool helpers ----------------------------------------------------------------

func _acquire_flat() -> AudioStreamPlayer:
	for p in _sfx_pool:
		if not p.playing:
			return p
	var p: AudioStreamPlayer = _sfx_pool[_sfx_pool_next]
	_sfx_pool_next = (_sfx_pool_next + 1) % _sfx_pool.size()
	return p


func _acquire_2d() -> AudioStreamPlayer2D:
	for p in _sfx2d_pool:
		if not p.playing:
			return p
	var p: AudioStreamPlayer2D = _sfx2d_pool[_sfx2d_pool_next]
	_sfx2d_pool_next = (_sfx2d_pool_next + 1) % _sfx2d_pool.size()
	return p


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
