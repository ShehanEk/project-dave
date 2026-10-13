extends TestCase
## REGRESSION (ADV-02): tools/summarize_playtest.py's main-route
## successful-progress time used to count every rolled-back death attempt
## (t_active is never rolled back on death) and silently drop the very first
## segment (run start -> CP01, since the real game never emits a "CP00"
## checkpoint_commit for the boundary before it). 07's own definition:
## "Successful-progress main-route time includes only the main-route
## intervals retained through successful checkpoint progression. Exclude
## intervals later rolled back by death/restart". Drive a real LevelDirector
## + Telemetry log: 30s A01 -> CP01, then a 20s attempt that dies (rolled
## back), then a 40s attempt that reaches CP02.
## Expected successful-progress ~= 30 + 40 = 70s. Raw active ~= 90s.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"


func run() -> void:
	var telemetry: Node = get_node("/root/Telemetry")
	var test_dir := "user://test_runs/probe_adv_telemetry_%d" % Time.get_ticks_usec()
	telemetry.set_playtest_dir(test_dir)

	Session.new_run()
	telemetry.run_start()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	level.hero.debug_invulnerable = false
	var t0: float = Session.run_meta["active_seconds"]

	Session.tick_active_time(30.0)
	check(Session.commit("CP01"), "CP01 commits")
	var t_cp01: float = Session.run_meta["active_seconds"]

	Session.tick_active_time(20.0)
	level.hero.take_damage(999, level.hero.global_position)
	await physics_frames(6)
	var t_after_death: float = Session.run_meta["active_seconds"]

	Session.tick_active_time(40.0)
	check(Session.commit("CP02"), "CP02 commits")
	var t_cp02: float = Session.run_meta["active_seconds"]

	var log_path: String = telemetry.current_log_path()
	telemetry.end_run()
	telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)

	var expected := (t_cp01 - t0) + (t_cp02 - t_after_death)
	var script := ProjectSettings.globalize_path("res://tools/summarize_playtest.py")
	var output: Array = []
	var code := OS.execute("python3", PackedStringArray([script, log_path]), output, true)
	check(code == 0, "summarizer ran")
	var text := "\n".join(output)
	var reported := -1.0
	for line in text.split("\n"):
		if line.begins_with("Main-route successful-progress time:"):
			reported = float(line.get_slice(":", 1).strip_edges().trim_suffix("s"))
	check(absf(reported - expected) < 1.0,
			"successful-progress time should be ~%.1fs (A01 interval + surviving attempt), summarizer reported %.1fs\n%s"
			% [expected, reported, text])

	level.queue_free()
	await physics_frames(2)
	CheckpointService.remove_dir_recursive(test_dir)
