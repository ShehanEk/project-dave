extends Node
## Telemetry (autoload) — local-only playtest logging (07-acceptance-and-
## playtesting.md "Timing protocol"; 01-player-journey-and-pacing.md). NEVER
## uploads anything: writes one JSONL file per run under
## `user://sunnyvale/playtests/` (default; tests redirect this the same way
## `CheckpointService.set_save_dir` redirects saves). One JSON object per
## line, each carrying `event`, `t_active` (seconds — mirrors
## `Session.run_meta["active_seconds"]`, so it excludes every modal/pause
## exactly like the completion screen's own stat) and `t_wall` (real seconds
## since `run_start()`), plus event-specific fields.
##
## A run only gets logged once something actually calls `run_start()`
## (Main._start_level(), M5 part 2) — every OTHER test in this project builds
## a level/LevelDirector directly without going through Main, so none of them
## ever produce a playtest file, matching CONVENTIONS.md's "tests never touch
## the player's real save" spirit for this file too. Session/BeatHub signals
## this connects to in `_ready()` are therefore harmless no-ops (guarded by
## `_file == null`) for every one of those tests. ONE exception (M7 finding):
## `LevelDirector._on_play_again_confirmed()` ALSO calls `run_start()`
## directly (a real player's "Play again" is exactly as real a new run as
## their first New Game) — any test that drives a directly-built
## `LevelDirector` through THAT path (not just Main's New Game/Continue) must
## redirect `set_playtest_dir()` first too, same as
## `tests/cases/test_m5_regress_play_again_hud.gd` does.
##
## `tools/summarize_playtest.py` (python3 stdlib only) turns one log into
## 07's report template fields.

const DEFAULT_PLAYTEST_DIR := "user://sunnyvale/playtests"

var _playtest_dir: String = DEFAULT_PLAYTEST_DIR
var _file: FileAccess = null
var _run_start_wall_msec: int = 0
var _reported_groups: Dictionary = {}
## group_id -> PackedStringArray of its enemy entity_ids, built by
## `register_encounter_groups()` (LevelDirector, once per build/rebuild).
var _encounter_groups: Dictionary = {}


func _ready() -> void:
	if Session:
		Session.checkpoint_committed.connect(_on_checkpoint_committed)
		Session.upgrade_purchased.connect(_on_upgrade_purchased)
		Session.weapon_swapped.connect(_on_weapon_swapped)
		Session.enemy_defeated.connect(_on_enemy_defeated)
	BeatHub.get_instance().beat_entered.connect(_on_beat_entered)


# --- test hook -----------------------------------------------------------------

func set_playtest_dir(path: String) -> void:
	_playtest_dir = path


func get_playtest_dir() -> String:
	return _playtest_dir


func current_log_path() -> String:
	return _file.get_path_absolute() if _file else ""


## Closes the current run's log file (if any) without starting a new one.
## Not called anywhere in normal play (a run's file just stays open until the
## NEXT `run_start()`, same as `CheckpointService` never needing an explicit
## "close"); exposed for a test that needs to read back the exact bytes
## written before cleaning up its own throwaway directory.
func end_run() -> void:
	_close_file()


# --- run lifecycle ---------------------------------------------------------------

## Starts a fresh JSONL file for one run (New Game or Continue, from the
## title screen — Main._start_level()). Closes any file already open (a
## previous run that was quit-to-title without finishing).
func run_start() -> void:
	_close_file()
	_reported_groups = {}
	if not DirAccess.dir_exists_absolute(_playtest_dir):
		DirAccess.make_dir_recursive_absolute(_playtest_dir)
	var stamp := Time.get_datetime_string_from_system(true).replace(":", "-")
	var path := _playtest_dir.path_join("run_%s_%d.jsonl" % [stamp, Time.get_ticks_usec()])
	_file = FileAccess.open(path, FileAccess.WRITE)
	if _file == null:
		push_error("Telemetry.run_start: could not open %s for writing" % path)
		return
	_run_start_wall_msec = Time.get_ticks_msec()
	var window := DisplayServer.window_get_size()
	_write("run_start", {
		"build": Session.BUILD if Session else "",
		"engine": Engine.get_version_info().string,
		"window_w": window.x,
		"window_h": window.y,
	})


func register_encounter_groups(areas: Array) -> void:
	_encounter_groups = {}
	for area in areas:
		if area and area.has_method("get_encounter_groups"):
			var groups: Dictionary = area.get_encounter_groups()
			for group_id in groups:
				_encounter_groups[group_id] = groups[group_id]


# --- event API (called directly by LevelDirector/CoreNode/PauseMenu) --------

func area_enter(area_id: String) -> void:
	_write("area_enter", {"area_id": area_id})


func area_exit(area_id: String) -> void:
	_write("area_exit", {"area_id": area_id})


func branch_enter(branch_id: String) -> void:
	_write("branch_enter", {"branch_id": branch_id})


func branch_exit(branch_id: String) -> void:
	_write("branch_exit", {"branch_id": branch_id})


func death(position: Vector2, area_id: String, cause: String) -> void:
	_write("death", {"x": position.x, "y": position.y, "area_id": area_id, "cause": cause})


func restart_from_checkpoint(checkpoint_id: String) -> void:
	_write("restart_from_checkpoint", {"checkpoint_id": checkpoint_id})


func pause_start() -> void:
	_write("pause_start", {})


func pause_end() -> void:
	_write("pause_end", {})


func sc01_start() -> void:
	_write("sc01_start", {})


func sc01_end(skipped: bool) -> void:
	_write("sc01_end", {"skipped": skipped})


func completion(active_seconds: float, chips_found: int, evidence_found: bool, upgrade_stage: int) -> void:
	_write("completion", {
		"active_seconds": active_seconds,
		"chips_found": chips_found,
		"evidence_found": evidence_found,
		"upgrade_stage": upgrade_stage,
	})


# --- Session/BeatHub-driven events (self-connected; no call site needed) -------

func _on_checkpoint_committed(checkpoint_id: String) -> void:
	_write("checkpoint_commit", {"checkpoint_id": checkpoint_id})


func _on_upgrade_purchased(weapon_type: String, stage: int) -> void:
	_write("upgrade_purchase", {"weapon_type": weapon_type, "stage": stage})


func _on_weapon_swapped(old_id: String, new_id: String) -> void:
	_write("weapon_swap", {"old_id": old_id, "new_id": new_id})


func _on_beat_entered(beat_id: String, area_id: String) -> void:
	_write("beat_enter", {"beat_id": beat_id, "area_id": area_id})


func _on_enemy_defeated(entity_id: String) -> void:
	if _file == null:
		return
	for group_id in _encounter_groups:
		if _reported_groups.has(group_id):
			continue
		var ids: PackedStringArray = _encounter_groups[group_id]
		if not ids.has(entity_id):
			continue
		var all_defeated := true
		for id in ids:
			if not Session.is_defeated(id):
				all_defeated = false
				break
		if all_defeated:
			_reported_groups[group_id] = true
			_write("encounter_complete", {"group_id": group_id})


# --- internals ---------------------------------------------------------------

func _write(event: String, fields: Dictionary) -> void:
	if _file == null:
		return
	var line: Dictionary = {
		"event": event,
		"t_active": float(Session.run_meta.get("active_seconds", 0.0)) if Session else 0.0,
		"t_wall": (Time.get_ticks_msec() - _run_start_wall_msec) / 1000.0,
	}
	for key in fields:
		line[key] = fields[key]
	_file.store_line(JSON.stringify(line))
	_file.flush()


func _close_file() -> void:
	if _file:
		_file.close()
		_file = null


func _exit_tree() -> void:
	_close_file()
