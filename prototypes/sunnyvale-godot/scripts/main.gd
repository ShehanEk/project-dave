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

var _level: Node = null
var _title: Control = null


func _ready() -> void:
	print("DEAD EDEN Sunnyvale prototype booted on Godot ", Engine.get_version_info().string)
	_maybe_redirect_m7_save_dir()
	_show_title()
	_maybe_start_m7_export_driver()


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
	_title.new_game_confirmed.connect(_on_new_game_confirmed)
	_title.continue_confirmed.connect(_on_continue_confirmed)
	_title.quit_requested.connect(_on_title_quit_requested)
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.set_music(&"none")


func _on_new_game_confirmed() -> void:
	Session.new_run()
	var checkpoint_service := get_node_or_null("/root/CheckpointService")
	if checkpoint_service:
		checkpoint_service.clear()
	_start_level()


func _on_continue_confirmed(snapshot: Dictionary) -> void:
	Session.load_from_snapshot(snapshot)
	_start_level()


func _start_level() -> void:
	if _title:
		_title.queue_free()
		_title = null
	# Music (M6): Session state is already adopted at this point (new_run()/
	# load_from_snapshot() ran in the caller just above) so this one check
	# covers every entry into the level — New Game (always pre-awakening ->
	# suburb) AND Continue, including "immediately on Continue after
	# awakening" (audio-direction.md / CONVENTIONS.md "Audio"): Continue's
	# load_from_snapshot() never re-emits story_state_changed, so Audio's own
	# live signal listener can't catch this case on its own.
	var audio := get_node_or_null("/root/Audio")
	if audio:
		var awakening: bool = Session.get_story("awakening_done") == true
		audio.set_music(&"quarantine" if awakening else &"suburb")
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
