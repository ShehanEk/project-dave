extends TestCase
## REGRESSION (ADV-08 + ADV-09): (1) save_snapshot() used to copy whatever
## the primary file held over the last-known-good backup unconditionally, so
## one corrupt primary followed by one more save destroyed the only good
## backup too — fixed to rotate the primary to backup only when the primary
## itself is a valid, loadable snapshot. (2) Session.run_meta["active_seconds"]
## was never persisted, so a completed save's Continue always showed "Active
## play time: 0:00" on the completion screen — fixed by mirroring it into a
## new `active_seconds` schema field on every commit.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"


func run() -> void:
	var cs: Node = get_node("/root/CheckpointService")
	Session.new_run()
	check(Session.commit("CP01"), "CP01 saved")
	check(Session.commit("CP02"), "CP02 saved (CP01 -> backup)")
	var primary: String = cs.get_save_dir().path_join("checkpoint.json")
	var f := FileAccess.open(primary, FileAccess.WRITE)
	f.store_string("{\"schema_version\": 1, \"trunc")
	f.close()
	var r: Dictionary = cs.load_latest()
	check(r.ok and r.source == "backup", "setup: Continue falls back to the good backup")
	Session.load_from_snapshot(r.snapshot)
	check(Session.commit("CP03"), "next save succeeds")
	var backup_check: Dictionary = cs._try_load(cs.get_save_dir().path_join("checkpoint.bak.json"))
	check(backup_check.ok, "after a save, backup should still be a last-KNOWN-GOOD file (got error: %s)" % backup_check.error)

	# Completed save -> Continue: the completion screen's active time.
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	Session.tick_active_time(754.0)
	level._on_wicket_reached()
	# The completion screen opens after the Security PA line (C28).
	await physics_frames(int(LevelDirector.PA_BEAT * 60.0) + 2)
	var before: String = level._completion_screen._time_label.text
	level.queue_free()
	await physics_frames(3)
	Session.load_from_snapshot(cs.load_latest().snapshot)
	var level2: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level2)
	await physics_frames(3)
	var after: String = level2._completion_screen._time_label.text if level2._completion_screen else "(none)"
	check_eq(after, before, "completed-save Continue shows the same active play time")
	level2.queue_free()
	await physics_frames(2)
