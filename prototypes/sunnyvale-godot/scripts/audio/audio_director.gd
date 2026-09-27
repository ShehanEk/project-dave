extends Node
## Audio (autoload, M6) — the ONLY way any other script touches sound.
## play_sfx(cue, position) fires a one-shot cue (positional 2D when a
## position is given); set_music(track) crossfades between the two level
## music loops (or silence). See CONVENTIONS.md "Audio" for the full cue
## list and exactly which script still needs to call which cue.
##
## Cues are pooled AudioStreamPlayer/AudioStreamPlayer2D nodes routed to the
## project's existing "SFX"/"Music" buses (data/audio/default_bus_layout.tres
## — Settings already applies the player's volume sliders to those buses, so
## this script never touches volume itself). An unknown/misspelled cue name
## never crashes a caller: it emits exactly one push_warning per distinct
## unknown name, then does nothing. Every AudioStreamPlayer[2D] call here is
## also safe under --headless (Godot's dummy audio driver) and inside tests:
## nodes still instance/play/stop without producing an error, just no
## audible output — this project's tests actually exercise every cue (see
## tests/cases/test_m6_audio.gd).
##
## Registered as an autoload by scripts/tools/configure_project.gd (rerun
## after any change there).

const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"

## Every cue this project knows about (05-content-and-assets.md /
## audio-direction.md). Keep this list and tools/gen_audio.py's
## SFX_GENERATORS in sync — a name here with no matching .wav is simply
## never loaded (play_sfx on it then warns "unknown cue" like any other
## typo), and gen_audio.py asserts the reverse at generation time.
const SFX_NAMES: Array[StringName] = [
	&"pistol_fire", &"pistol_fire_quick", &"bolt_hit", &"bolt_blocked",
	&"hero_hurt", &"hero_jump", &"hero_land",
	&"resident_windup", &"resident_lunge", &"resident_defeat",
	&"clipper_scrape", &"clipper_windup", &"clipper_charge", &"clipper_stall", &"clipper_defeat",
	&"gem", &"gem_cluster", &"cache_open", &"artifact", &"capsule",
	&"interact", &"checkpoint", &"purchase", &"swap", &"latch",
	&"eden_chime", &"alarm", &"hatch_open", &"pit_fall", &"exit",
	&"ui_move", &"ui_confirm", &"ui_back", &"save_failed",
]

## Music track key (as passed to set_music) -> file basename under MUSIC_DIR.
const MUSIC_FILES := {
	&"suburb": "suburb_loop",
	&"quarantine": "quarantine_loop",
}

const SFX_POOL_SIZE := 6
const SFX2D_POOL_SIZE := 8
const MUSIC_CROSSFADE_SECONDS := 1.2
const MUSIC_FADE_DB := -80.0

var _sfx_streams: Dictionary = {}    # StringName -> AudioStreamWAV
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
var _re_gem := RegEx.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_re_cluster.compile("-GC\\d+$")
	_re_gem.compile("-G\\d+$")
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
		var path := SFX_DIR + String(cue) + ".wav"
		if ResourceLoader.exists(path):
			_sfx_streams[cue] = load(path)
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
## loop_locked_freq() comment).
func _make_seamless(stream: AudioStreamWAV) -> void:
	var bytes_per_sample := 1 if stream.format == AudioStreamWAV.FORMAT_8_BITS else 2
	var channels := 2 if stream.stereo else 1
	var frames := int(stream.data.size() / float(bytes_per_sample * channels))
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
	session.artifact_recorded.connect(_on_artifact_recorded)
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
## An unknown cue name never errors — it push_warnings once and returns.
func play_sfx(cue: StringName, position: Variant = null) -> void:
	if not _sfx_streams.has(cue):
		if not _warned_cues.has(cue):
			_warned_cues[cue] = true
			push_warning("Audio.play_sfx: unknown cue %s" % String(cue))
		return
	var stream: AudioStreamWAV = _sfx_streams[cue]
	if position != null:
		var player2d: AudioStreamPlayer2D = _acquire_2d()
		player2d.global_position = position
		player2d.stream = stream
		player2d.play()
	else:
		var player: AudioStreamPlayer = _acquire_flat()
		player.stream = stream
		player.play()


## Switches the level music. `track` is `&"suburb"`, `&"quarantine"` or
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


## The logical current track key (&"suburb" / &"quarantine" / &"none" /
## the unset sentinel before the first set_music() call). For tests and any
## reader that wants to know what's playing without inspecting player nodes.
func current_music() -> StringName:
	return _music_current


## True while `cue` has a loaded .wav behind it (i.e. play_sfx(cue) will
## actually play something rather than push_warning and no-op). For tests.
func has_cue(cue: StringName) -> bool:
	return _sfx_streams.has(cue)


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
## (`...-CACHE##`), care capsules (`L01-HS##`), gem clusters (`...-GC##`),
## plain gems (`...-G###`). Anything else (e.g. an artifact's own pickup id,
## `L01-OPT01-A01`) intentionally returns "" here — record_artifact() already
## fires its own artifact_recorded signal (handled below) for that case, and
## this must not also play a gem-family sound over it.
func _cue_for_pickup(entity_id: String) -> StringName:
	if entity_id.findn("CACHE") != -1:
		return &"cache_open"
	if entity_id.begins_with("L01-HS"):
		return &"capsule"
	if _re_cluster.search(entity_id):
		return &"gem_cluster"
	if _re_gem.search(entity_id):
		return &"gem"
	return &""


func _on_artifact_recorded(_artifact_id: String) -> void:
	play_sfx(&"artifact")


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
		set_music(&"quarantine")


func _on_level_completed() -> void:
	play_sfx(&"exit")
