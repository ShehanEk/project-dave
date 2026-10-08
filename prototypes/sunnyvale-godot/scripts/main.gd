extends Node
## Main — game flow shell (M5 part 2): Title screen <-> the L01 level.
## Owns exactly the transition between them; Session/CheckpointService state
## changes (new_run/load_from_snapshot/clear) happen here, right before
## instancing LevelDirector, so its own `_ready()` (which reads
## `Session.state["checkpoint_id"]` to place the hero) always sees the
## correct state already adopted — the same "adopt state, then rebuild"
## ordering LevelDirector's own `_on_play_again_confirmed()` already uses.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
## SC00 (C49): the intro comic that tells the premise before a New Game.
const IntroComic := preload("res://scripts/ui/intro_comic.gd")

## Crosshair cursor (M7 Kenney UI pass; assets/kenney/README.md section 3 —
## Crosshair Pack, Outline style, `crosshair-000`). Shown as the OS mouse
## cursor only during actual gameplay: not on the Title screen (`_level ==
## null`), not while `get_tree().paused` (Pause menu, and its own Restart/
## Quit confirm sub-views), and not while the level's own Hero has
## `input_enabled == false` — which already covers WorkbenchPanel, SwapConfirm,
## the completion screen, and CoreNode's SC01 coroutine (CONVENTIONS.md
## "UI scenes"/"core_node.tscn" — every one of those already disables
## `hero.input_enabled` while it's open), so this needs no per-screen hook
## into any of them. Everywhere else falls back to the OS's normal arrow.
enum CursorMode { ARROW, CROSSHAIR }

const CROSSHAIR_1X := preload("res://assets/kenney/crosshair-pack/crosshair_1x.png")
const CROSSHAIR_2X := preload("res://assets/kenney/crosshair-pack/crosshair_2x.png")

## Above this actual OS window size (either axis), the 2x crosshair asset is
## used so the reticle doesn't read as undersized once the window is scaled
## well past project.godot's own 1280x720 base (canvas_items/expand stretch)
## — checked alongside the display's own DPI scale (`DisplayServer.
## screen_get_scale`) so a genuine Retina/HiDPI screen gets the larger asset
## even at the base window size, per the task brief ("2x variant on
## high-DPI/large windows").
const LARGE_WINDOW_SIZE := Vector2i(1920, 1080)
## The window title players see. project.godot's config/name stays "DEAD EDEN -
## Sunnyvale Prototype" because it names the user:// folder that holds saves and
## playtest logs; the city was renamed Eon City (C48), so the window says that.
const WINDOW_TITLE := "DEAD EDEN - Eon City Prototype"

var _level: Node = null
var _title: Control = null
var _intro: CanvasLayer = null
## New Game from the title plays the intro comic first. Tests and debug demos that
## call `_on_new_game_confirmed()` directly start the level at once either way.
var play_intro := true
var _cursor_mode: CursorMode = CursorMode.ARROW


func _ready() -> void:
	print("DEAD EDEN Eon City prototype booted on Godot ", Engine.get_version_info().string)
	get_window().title = WINDOW_TITLE
	# So the cursor's own _process (below) keeps running, and correctly snaps
	# back to the arrow, the instant `get_tree().paused` becomes true — the
	# same reasoning PauseMenu's own PROCESS_MODE_ALWAYS doc comment gives.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_maybe_redirect_m7_save_dir()
	_show_title()
	_maybe_start_m7_export_driver()


func _process(_delta: float) -> void:
	_update_cursor()


func _update_cursor() -> void:
	var mode := _compute_cursor_mode()
	if mode == _cursor_mode:
		return
	_cursor_mode = mode
	_apply_cursor(mode)


func _compute_cursor_mode() -> CursorMode:
	if get_tree().paused:
		return CursorMode.ARROW
	if _level == null:
		return CursorMode.ARROW
	var hero := get_tree().get_first_node_in_group("hero")
	if hero == null or not hero.input_enabled:
		return CursorMode.ARROW
	return CursorMode.CROSSHAIR


func _apply_cursor(mode: CursorMode) -> void:
	# The headless test display server backs no real OS cursor at all (same
	# reasoning as ControlsPanel._key_label()'s own DisplayServer guard) —
	# `_cursor_mode`/`get_cursor_mode()` below is still the real, always-
	# correct seam a headless test reads; this only skips the one call that
	# would otherwise push a harmless engine warning under `tools/test.sh`.
	if DisplayServer.get_name() == "headless":
		return
	if mode == CursorMode.CROSSHAIR:
		var texture := _crosshair_texture()
		Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, texture.get_size() / 2.0)
	else:
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)


func _crosshair_texture() -> Texture2D:
	var window := get_window()
	var use_2x := false
	if window:
		use_2x = (window.size.x >= LARGE_WINDOW_SIZE.x or window.size.y >= LARGE_WINDOW_SIZE.y
				or DisplayServer.screen_get_scale(window.current_screen) >= 1.5)
	return CROSSHAIR_2X if use_2x else CROSSHAIR_1X


## Test seam (M7 Kenney UI pass): the CURRENT cursor mode as a plain string,
## so a headless test can assert the gameplay/paused switch without a real OS
## cursor to inspect (the headless display server has none, and Movie Maker
## capture may not render one either — see tests/cases/test_kenney_ui.gd).
func get_cursor_mode() -> String:
	return "crosshair" if _cursor_mode == CursorMode.CROSSHAIR else "arrow"


## M7 export verification only (reports/export-report.md) — NEVER active in a
## release export, same `OS.is_debug_build()` + exact-argument gate as
## `_maybe_start_m7_export_driver()` below. Runs BEFORE `_show_title()` (whose
## own `_ready()` already calls `CheckpointService.has_valid_save()`) so a
## throwaway `--m7-save-dir=user://<path>` redirect is in effect for every
## read/write this process makes, including the very first one — the exported
## app's own default save location (and real playtest log directory) is never
## touched when this argument is passed. Mirrors the existing debug-demo
## redirect pattern (CONVENTIONS.md "debug-demos-touch-real-save") rather than
## inventing a new one.
##
## AUD-06: this used to return early (no redirect at all) whenever
## `--m7-save-dir` was left off, while `_maybe_start_m7_export_driver()`
## below still started the driver on `--m7-phase=newgame` alone — the driver
## then pressed New Game against the REAL default save dir. Whenever
## `--m7-phase` is present at all, this now redirects to the explicit
## `--m7-save-dir` if given, or otherwise a throwaway
## `user://m7_throwaway/<ticks>` — the driver can never run un-redirected.
func _maybe_redirect_m7_save_dir() -> void:
	if not OS.is_debug_build():
		return
	var save_dir := ""
	var phase_requested := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--m7-save-dir="):
			save_dir = arg.substr(len("--m7-save-dir="))
		elif arg.begins_with("--m7-phase="):
			phase_requested = true
	if save_dir.is_empty():
		if not phase_requested:
			return
		# --m7-phase was given with no explicit --m7-save-dir: never fall
		# through to the real default save dir (AUD-06).
		save_dir = "user://m7_throwaway/%d" % Time.get_ticks_usec()
	var checkpoint_service := get_node_or_null("/root/CheckpointService")
	if checkpoint_service:
		checkpoint_service.set_save_dir(save_dir)
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.set_playtest_dir(save_dir.path_join("playtests"))


## M7 export verification only (reports/export-report.md) — NEVER active in
## a release export: `OS.is_debug_build()` is false there unconditionally
## (it reflects the export type chosen at export time, not any runtime
## argument), so this whole method is a no-op on the shipped
## `--export-release` Windows/macOS builds regardless of command line.
## Even on a debug export, nothing happens unless the exact
## `--m7-phase=<newgame|continue>` user argument is present — an ordinary
## double-click launch is a completely normal, non-automated title screen.
## See scripts/debug/m7_export_driver.gd for what the driver actually does.
func _maybe_start_m7_export_driver() -> void:
	if not OS.is_debug_build():
		return
	var phase := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--m7-phase="):
			phase = arg.substr(len("--m7-phase="))
	if phase.is_empty():
		return
	# AUD-06 defense-in-depth: `_maybe_redirect_m7_save_dir()` above always
	# redirects away from DEFAULT_SAVE_DIR whenever `--m7-phase` is present,
	# but never start the driver against the real save dir even if that
	# invariant is ever broken by a future edit.
	var checkpoint_service := get_node_or_null("/root/CheckpointService")
	if checkpoint_service and checkpoint_service.get_save_dir() == checkpoint_service.DEFAULT_SAVE_DIR:
		push_error("m7_export_driver: refusing to start — CheckpointService is not redirected away from the real save dir")
		return
	var driver: Node = load("res://scripts/debug/m7_export_driver.gd").new()
	add_child(driver)
	driver.start(phase)


func _show_title() -> void:
	get_tree().paused = false
	_title = load(TITLE_SCENE).instantiate()
	add_child(_title)
	_title.new_game_confirmed.connect(_on_new_game_requested)
	_title.continue_confirmed.connect(_on_continue_confirmed)
	_title.quit_requested.connect(_on_title_quit_requested)
	var audio := get_node_or_null("/root/Audio")
	if audio:
		# N05: the title screen has its own theme (silence if that track is missing), at
		# boot and after Quit to title. Starting the level crossfades from it to the
		# level music (a Play again stays in the level, so it never passes through here).
		audio.set_music(&"title")
		# The ambience bed goes quiet under the title. The level's own director picks
		# the bed for where the hero stands the moment it is instanced
		# (LevelDirector.update_ambience(), from _ready()), so New Game and Continue
		# fade in from silence straight into the right bed.
		audio.set_ambience(&"none")


## The title's New Game (after any overwrite confirm): the intro comic, then the
## level. The run is reset and the old save deleted right away, as the confirm text
## promises, so the comic only delays the level. The title music keeps playing under
## the comic; the level's director takes over the music when the level starts.
func _on_new_game_requested() -> void:
	if not play_intro:
		_on_new_game_confirmed()
		return
	_reset_for_new_game()
	if _title:
		_title.queue_free()
		_title = null
	_intro = IntroComic.new()
	add_child(_intro)
	_intro.finished.connect(_on_intro_finished)


func _on_intro_finished(_skipped: bool) -> void:
	_intro = null
	_start_level()


func _on_new_game_confirmed() -> void:
	_reset_for_new_game()
	_start_level()


func _reset_for_new_game() -> void:
	Session.new_run()
	var checkpoint_service := get_node_or_null("/root/CheckpointService")
	if checkpoint_service:
		checkpoint_service.clear()


func _on_continue_confirmed(snapshot: Dictionary) -> void:
	Session.load_from_snapshot(snapshot)
	_start_level()


func _start_level() -> void:
	if _title:
		_title.queue_free()
		_title = null
	# Music (M6, N05): not set here. Session state is already adopted at this point
	# (new_run()/load_from_snapshot() ran in the caller just above), and the level's
	# own director picks the track for where the hero stands, and the lockdown, the
	# moment it is instanced below (LevelDirector.update_music(), from _ready(), then
	# every frame). Choosing the track in two places (campus/lockdown here, depot
	# there) would make a Continue at a depot checkpoint start one track and
	# immediately cross to another. That covers New Game (pre-awakening, campus),
	# Continue at any checkpoint, and "immediately on Continue after awakening":
	# load_from_snapshot() never re-emits story_state_changed, so Audio's own live
	# signal listener could not catch that case on its own.
	# Open the telemetry log BEFORE instancing the level: LevelDirector's own
	# `_ready()` (which runs synchronously the instant it's added below) fires
	# the very first area_enter/register_encounter_groups calls, which are
	# silent no-ops until a run is actually open.
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.run_start()
	_level = load(LEVEL_01).instantiate()
	add_child(_level)
	_level.quit_to_title_requested.connect(_on_quit_to_title)


func _on_quit_to_title() -> void:
	if _level:
		_level.queue_free()
		_level = null
	get_tree().paused = false
	_show_title()


func _on_title_quit_requested() -> void:
	get_tree().quit()
