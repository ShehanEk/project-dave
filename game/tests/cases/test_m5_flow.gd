extends TestCase
## M5 part 2 (game flow shell + local telemetry) contracts: Continue rebuilds
## the world from a saved snapshot, an invalid save is handled honestly
## (falls back to a valid backup, or offers New Game with no crash), the
## pause menu actually stops physics/enemies/the active-time clock and
## resumes cleanly (T21 partial), the New Game confirmation path, and
## Telemetry writing a parseable, correctly-ordered JSONL log (verified both
## directly and via tools/summarize_playtest.py on a synthetic fixture).

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
const A03_INDEX := 2

var _telemetry: Node = null
var _checkpoint_service: Node = null


func run() -> void:
	_telemetry = get_node_or_null("/root/Telemetry")
	_checkpoint_service = get_node_or_null("/root/CheckpointService")
	await _test_continue_from_cp02()
	await _test_invalid_save_backup_and_no_save()
	await _test_pause_stops_gameplay()
	await _test_new_game_confirmation()
	await _test_telemetry_log_sequence()
	_test_summarize_playtest_fixture()


# --- Continue from a saved CP02 snapshot ----------------------------------------

func _test_continue_from_cp02() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	# Collect a chip and defeat an enemy in A03, then commit CP02 (the real
	# A03 recovery station's own checkpoint id), exactly like reaching that
	# station mid-run would.
	check(Session.collect("L01-A03-G001", 1), "setup: collect a chip in A03")
	var guard: Brawler = level.areas[A03_INDEX].get_node("Encounters/EncounterGroup_E05/NightGuard_SE01_01")
	Session.mark_defeated(guard.entity_id)
	var committed := Session.commit("CP02")
	check(committed, "setup: CP02 commits successfully")

	level.queue_free()
	await physics_frames(2)

	# Simulate a fresh boot: clear live state, then load whatever is on disk.
	Session.new_run()
	var result: Dictionary = _checkpoint_service.load_latest()
	check(result.get("ok", false), "Continue: a valid CP02 save is found (error=%s)" % result.get("error", ""))
	Session.load_from_snapshot(result.snapshot)
	check(Session.state["checkpoint_id"] == "CP02", "Continue: loaded snapshot's checkpoint_id is CP02")

	var level2: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level2)
	await physics_frames(3)

	var respawn := level2.areas[A03_INDEX].get_marker("Respawn_CP02")
	check(level2.hero.global_position.distance_to(respawn.global_position) < 12.0,
			"Continue: hero rebuilds at CP02's own Respawn marker")
	var chip := level2.areas[A03_INDEX].get_node_or_null("Entities/Chip_G001")
	check(chip == null, "Continue: the already-collected chip is absent after rebuild")
	var fresh_guard := level2.areas[A03_INDEX].get_node_or_null("Encounters/EncounterGroup_E05/NightGuard_SE01_01")
	check(fresh_guard == null, "Continue: the already-defeated enemy is absent after rebuild")

	level2.queue_free()
	await physics_frames(2)


# --- Invalid save: backup offered transparently, or an honest dead-end-free message --

func _test_invalid_save_backup_and_no_save() -> void:
	Session.new_run()
	check(Session.commit("CP01"), "setup: commit CP01 (creates the primary)")
	check(Session.commit("CP02"), "setup: commit CP02 (CP01 becomes the backup)")

	var save_dir: String = _checkpoint_service.get_save_dir()
	var primary_path := save_dir.path_join("checkpoint.json")

	# Corrupt only the primary: load_latest() should transparently recover
	# the still-valid backup, and TitleScreen should say so honestly.
	var writer := FileAccess.open(primary_path, FileAccess.WRITE)
	writer.store_string("{ not valid json")
	writer.close()

	var title: TitleScreen = load(TITLE_SCENE).instantiate()
	add_child(title)
	await physics_frames(2)

	# Boxed in a single-element Array: GDScript lambdas capture an outer local
	# by VALUE (reassigning it inside the lambda never reaches the enclosing
	# function's own variable) — mutating a shared Array's element 0 does.
	var got_snapshot_box: Array = [{}]
	title.continue_confirmed.connect(func(snapshot: Dictionary): got_snapshot_box[0] = snapshot)
	title.attempt_continue()
	var got_snapshot: Dictionary = got_snapshot_box[0]
	check(not got_snapshot.is_empty(), "invalid primary: Continue still succeeds via the backup")
	check(String(got_snapshot.get("checkpoint_id", "")) == "CP01",
			"invalid primary: the recovered snapshot is the backup's own CP01 content")
	check(title.get_node("Panel/VBox/MessageLabel").text.findn("backup") != -1,
			"invalid primary: an honest 'restored from backup' message is shown")

	# Now also corrupt the backup: no valid save anywhere. No crash, and the
	# message points at New Game instead of leaving a dead end.
	var backup_path := save_dir.path_join("checkpoint.bak.json")
	var writer2 := FileAccess.open(backup_path, FileAccess.WRITE)
	writer2.store_string("{ also not valid json")
	writer2.close()

	got_snapshot_box[0] = {}
	title.attempt_continue()
	got_snapshot = got_snapshot_box[0]
	check(got_snapshot.is_empty(), "both invalid: Continue does not proceed")
	check(title.get_node("Panel/VBox/MessageLabel").text.findn("new game") != -1,
			"both invalid: the message points at New Game, not a dead end")

	title.queue_free()
	await physics_frames(2)
	_checkpoint_service.clear()


# --- Pause stops gameplay / active time, resumes cleanly (T21 partial) ---------

func _test_pause_stops_gameplay() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	# Enough frames for PauseMenu's own open-readiness streak (2 frames) to
	# be satisfied before we try to open it.
	await physics_frames(4)

	check(not get_tree().paused, "setup: the tree starts unpaused")

	press(&"pause")
	await physics_frames(1)
	release(&"pause")
	await physics_frames(1)
	check(get_tree().paused, "pause: pressing pause opens the menu and pauses the tree")

	var pos_before: Vector2 = level.hero.global_position
	var active_before: float = float(Session.run_meta.get("active_seconds", 0.0))
	press(&"move_right")
	await physics_frames(10)
	release(&"move_right")
	check(level.hero.global_position.distance_to(pos_before) < 0.5,
			"pause: gameplay input has no effect while paused (hero does not move)")
	check(is_equal_approx(float(Session.run_meta.get("active_seconds", 0.0)), active_before),
			"pause: the active-time clock does not advance while paused")

	press(&"pause")
	await physics_frames(1)
	release(&"pause")
	await physics_frames(1)
	check(not get_tree().paused, "pause: pressing pause again resumes and unpauses the tree")

	press(&"move_right")
	await physics_frames(10)
	release(&"move_right")
	check(level.hero.global_position.x > pos_before.x + 1.0,
			"pause: gameplay resumes normally after unpausing (hero moves again)")
	check(float(Session.run_meta.get("active_seconds", 0.0)) > active_before,
			"pause: the active-time clock resumes advancing after unpausing")

	level.queue_free()
	await physics_frames(2)
	get_tree().paused = false


# --- New Game confirmation path -------------------------------------------------

func _test_new_game_confirmation() -> void:
	Session.new_run()
	check(Session.commit("CP01"), "setup: a save exists")

	var title: TitleScreen = load(TITLE_SCENE).instantiate()
	add_child(title)
	await physics_frames(2)

	# Boxed (see the identical comment in _test_invalid_save_backup_and_no_save):
	# a lambda captures an outer local by value, so a plain int the lambda
	# reassigns never changes outside it — a shared Array's element does.
	var confirmed_box: Array = [0]
	title.new_game_confirmed.connect(func(): confirmed_box[0] += 1)

	title._on_new_game_pressed()
	check(title._view == TitleScreen.View.NEW_GAME_CONFIRM,
			"New Game with an existing save shows a confirmation view first")
	check(confirmed_box[0] == 0, "New Game confirmation: nothing is confirmed yet")

	title._on_new_game_cancel()
	check(title._view == TitleScreen.View.MAIN, "New Game: Cancel returns to the main view")
	check(confirmed_box[0] == 0, "New Game: Cancel never confirms")

	title._on_new_game_pressed()
	title._on_new_game_confirm()
	check(confirmed_box[0] == 1, "New Game: Confirm emits new_game_confirmed exactly once")

	title.queue_free()
	await physics_frames(2)

	# No existing save: New Game proceeds immediately, no confirmation step.
	_checkpoint_service.clear()
	var title2: TitleScreen = load(TITLE_SCENE).instantiate()
	add_child(title2)
	await physics_frames(2)
	var confirmed2_box: Array = [0]
	title2.new_game_confirmed.connect(func(): confirmed2_box[0] += 1)
	title2._on_new_game_pressed()
	check(confirmed2_box[0] == 1, "New Game with no existing save skips the confirmation view")
	check(title2._view == TitleScreen.View.MAIN, "New Game with no existing save never shows the confirm view")

	title2.queue_free()
	await physics_frames(2)


# --- Telemetry: parseable log, correct event sequence (death + restart) --------

func _test_telemetry_log_sequence() -> void:
	if _telemetry == null:
		check(false, "Telemetry autoload is present")
		return

	var test_dir := "user://test_runs/telemetry_%d" % Time.get_ticks_usec()
	_telemetry.set_playtest_dir(test_dir)

	Session.new_run()
	_telemetry.run_start()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	check(Session.commit("CP01"), "telemetry setup: CP01 commits")

	level.hero.take_damage(999, level.hero.global_position)
	await physics_frames(4)

	level._on_restart_from_checkpoint_confirmed()
	await physics_frames(4)

	var log_path: String = _telemetry.current_log_path()
	check(log_path != "", "telemetry: a log file is open")
	_telemetry.end_run()

	var events := _read_jsonl(log_path)
	check(events.size() >= 4, "telemetry: the log has at least the expected events (got %d)" % events.size())
	var names: Array = []
	for e in events:
		names.append(e.get("event", "?"))
	check(names[0] == "run_start", "telemetry: run_start is the first event (%s)" % [names])
	check(names.has("area_enter"), "telemetry: area_enter was logged (%s)" % [names])
	check(names.has("checkpoint_commit"), "telemetry: checkpoint_commit was logged (%s)" % [names])
	check(names.has("death"), "telemetry: death was logged (%s)" % [names])
	check(names.has("restart_from_checkpoint"), "telemetry: restart_from_checkpoint was logged (%s)" % [names])
	var death_idx: int = names.find("death")
	var restart_idx: int = names.find("restart_from_checkpoint")
	check(death_idx != -1 and restart_idx != -1 and death_idx < restart_idx,
			"telemetry: death is logged before restart_from_checkpoint (%s)" % [names])
	for e in events:
		check(e.has("t_active") and e.has("t_wall"), "telemetry: every event carries t_active/t_wall (%s)" % e)

	level.queue_free()
	await physics_frames(2)
	_telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
	CheckpointService.remove_dir_recursive(test_dir)


func _read_jsonl(path: String) -> Array:
	var out: Array = []
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return out
	while not f.eof_reached():
		var line := f.get_line()
		if line.strip_edges() == "":
			continue
		var parsed = JSON.parse_string(line)
		if typeof(parsed) == TYPE_DICTIONARY:
			out.append(parsed)
	f.close()
	return out


# --- summarize_playtest.py on the committed synthetic fixture -------------------

func _test_summarize_playtest_fixture() -> void:
	var fixture := ProjectSettings.globalize_path("res://tests/fixtures/telemetry_sample.jsonl")
	var script := ProjectSettings.globalize_path("res://tools/summarize_playtest.py")
	var output: Array = []
	var exit_code := OS.execute("python3", PackedStringArray([script, fixture]), output, true)
	check(exit_code == 0, "summarize_playtest.py runs cleanly against the fixture (exit=%d)" % exit_code)
	var text := "\n".join(output)
	# Hand-computed from the fixture per 07's own definition (ADV-02): the
	# fixture has no "CP00" checkpoint_commit (the real game never emits one
	# either) — the boundary before the first real commit is `run_start`
	# itself (t_active=0.0). The first segment (run_start -> CP01 at t=90)
	# contains a death at t=50, so only the SURVIVING attempt after it counts
	# (90-50=40), discarding the rolled-back 0-50 attempt entirely. Then
	# CP01->CP02 (90->150 = 60s) and CP02->CP05 (150->200 = 50s, UPG01
	# excluded) add normally. 40+60+50 = 150s, minus the one OPT01 branch
	# interval (100->115 = 15s) = 135.0s.
	check(text.find("Main-route successful-progress time: 135.0s") != -1,
			"summarize_playtest.py computes the correct successful-progress time on the fixture:\n%s" % text)
	check(text.find("Raw active first-completion time: 200.0s") != -1,
			"summarize_playtest.py reports the fixture's own raw active first-completion time")
