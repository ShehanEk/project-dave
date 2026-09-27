extends TestCase
## M7 / 07-acceptance-and-playtesting.md T07 ("Roof fall: recovery lane
## reaches the route by normal jumps; no damage, trap, or forced fight"),
## in the assembled level_01.
##
## test_m3_regress_recovery.gd's own `_probe_roof_fall_recovery()` already
## proves the "reaches the route by normal jumps" half (RouteBot success +
## final height) across 7 moving-platform phases, and prints (but never
## asserts) the health before/after — so a regression that made the fall
## recovery cost health would print a changed number without ever failing
## the suite. This case adds the missing explicit "no damage" assertion (the
## other stated half of T07's own pass condition), and also turns the
## printed recovery time into a real evidence number for the functional
## matrix. The hero is NOT debug_invulnerable here — a real vulnerable hero
## is required for "zero damage" to mean anything.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"


func run() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	var a3: AreaRoot = null
	for a in level.areas:
		if a.area_id == "L01-A03":
			a3 = a
	check(a3 != null, "L01-A03 present in the assembled level")
	if a3 == null:
		level.queue_free()
		return

	# Land the hero exactly where a missed GapPlatform jump drops it: the
	# service lane below the roof route (same spot test_m3_regress_recovery.gd
	# uses for its own roof-fall probe).
	level.hero.respawn_at(a3.to_global(Vector2(2150, -4)))
	level.camera.reset_position()
	await physics_frames(2)
	check(not level.hero.debug_invulnerable, "setup: hero is genuinely vulnerable for this probe (not debug_invulnerable)")
	var hp0: int = Session.state.get("health", 6)
	check(hp0 == 6, "setup: hero starts at full health before the fall-recovery climb")

	# The authored recovery path back up to the main roof route (identical to
	# test_m3_regress_recovery.gd's LAY-05 fix: street -> RecoveryStepA -> the
	# main route's own Terrace2->Terrace3 jump), driven by named-action input
	# only (RouteBot), never a teleport.
	var tmp := AreaRoot.new()
	tmp.area_id = "L01-A03-t07-probe"
	tmp.position = a3.global_position
	var route := Node2D.new()
	route.name = "Route"
	tmp.add_child(route)
	var spec := [
		{"pos": Vector2(1490, 0), "tol": 15.0},
		{"pos": Vector2(1490, 0), "action": RoutePoint.Action.JUMP, "hold": 0.25, "tol": 15.0},
		{"pos": Vector2(1400, -68), "tol": 12.0},
		{"pos": Vector2(1355, -68), "action": RoutePoint.Action.JUMP, "hold": 0.3, "tol": 12.0},
		{"pos": Vector2(1200, -136), "tol": 14.0},
		{"pos": Vector2(1290, -136), "action": RoutePoint.Action.JUMP, "hold": 0.24, "tol": 12.0},
		{"pos": Vector2(1700, -216), "tol": 12.0},
	]
	for s in spec:
		var p := RoutePoint.new()
		p.position = s.pos
		p.action = s.get("action", RoutePoint.Action.MOVE)
		p.tolerance = s.get("tol", 12.0)
		p.hold_jump = s.get("hold", 0.12)
		route.add_child(p)
	level.add_child(tmp)

	var bot := RouteBot.new()
	bot.stuck_timeout = 4.0
	add_child(bot)
	bot.build_points(tmp, [])
	bot.start(level.hero)
	var t := 0
	var max_ticks := int(25.0 * Engine.physics_ticks_per_second)
	while bot.running and t < max_ticks:
		await get_tree().physics_frame
		t += 1
	if bot.running:
		bot.failure_message = "test timeout after 25s"
		bot.running = false
	var rep := bot.get_report()
	var final_local: Vector2 = a3.to_local(level.hero.global_position)
	var hp1: int = Session.state.get("health", 6)

	print("[test_m7_roof_fall_zero_damage] A03 roof-fall recovery: success=%s recovery_time=%.2fs final_local=(%.0f,%.0f) health %d->%d failure=%s" % [
			rep.success, rep.seconds, final_local.x, final_local.y, hp0, hp1, rep.failure])
	check(rep.success and final_local.y < -200.0,
			"the recovery lane reaches back up to the main roof route by normal jumps (failure=%s, final local=(%.0f,%.0f))" % [rep.failure, final_local.x, final_local.y])
	check(hp1 == hp0, "the roof-fall recovery costs zero health (started %d, ended %d)" % [hp0, hp1])
	check(level.hero.input_enabled, "the hero is never trapped/soft-locked mid-recovery (input still enabled)")
	check(not Session.get_story("level_complete"), "recovering from the fall does not force any fight or skip content (run still in progress)")

	bot.queue_free()
	tmp.queue_free()
	level.queue_free()
	await physics_frames(2)
