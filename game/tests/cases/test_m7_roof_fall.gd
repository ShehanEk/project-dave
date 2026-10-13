extends TestCase
## M7 / 07-acceptance-and-playtesting.md T07, as changed by the fun pass
## (C41: "Roof fall: the first roofs drop onto the street lane, which climbs
## back by normal jumps at no cost; past them the roofs have real gaps, and
## a fall costs one health and returns Dave to the roof he jumped from"), in
## the assembled level_01.
##
## Part 1, the free street lane under the first roofs: the authored recovery
## path (street -> RecoveryStepA -> Terrace2 -> Terrace3), driven by
## named-action input only (RouteBot), costs nothing. Part 2, the roof gaps:
## dropping Dave into the gap under the moving platform and into the gap
## between the long roof and Terrace5 each costs exactly one health and puts
## him back on the roof he left, never trapped. The hero is NOT
## debug_invulnerable here — a real vulnerable hero is required for the
## health numbers to mean anything.

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

	# Land the hero on the street lane under Terrace3 (where a missed jump
	# among the first roofs drops it).
	level.hero.respawn_at(a3.to_global(Vector2(1700, -4)))
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

	print("[test_m7_roof_fall] A03 street-lane recovery: success=%s recovery_time=%.2fs final_local=(%.0f,%.0f) health %d->%d failure=%s" % [
			rep.success, rep.seconds, final_local.x, final_local.y, hp0, hp1, rep.failure])
	check(rep.success and final_local.y < -200.0,
			"the recovery lane reaches back up to the main roof route by normal jumps (failure=%s, final local=(%.0f,%.0f))" % [rep.failure, final_local.x, final_local.y])
	check(hp1 == hp0, "the roof-fall recovery costs zero health (started %d, ended %d)" % [hp0, hp1])
	check(level.hero.input_enabled, "the hero is never trapped/soft-locked mid-recovery (input still enabled)")
	check(not Session.get_story("level_complete"), "recovering from the fall does not force any fight or skip content (run still in progress)")
	bot.queue_free()
	tmp.queue_free()
	await physics_frames(2)

	# Part 2: the roof gaps (C41).
	await _gap_fall(level, a3, Vector2(2150, -300), Vector2(1830, -216), "the gap under the moving platform")
	await _gap_fall(level, a3, Vector2(3545, -300), Vector2(3440, -216), "the gap after the long roof")
	check(level.hero.input_enabled, "the hero is never trapped after a gap fall (input still enabled)")

	level.queue_free()
	await physics_frames(2)


## Drops a vulnerable, full-health hero above a roof gap and checks the fall
## costs exactly one health and lands him on the roof he jumped from.
func _gap_fall(level: LevelDirector, a3: AreaRoot, drop_local: Vector2, roof_local: Vector2, label: String) -> void:
	Session.heal_full()
	# A pit costs health only outside the hero's post-hit immunity window
	# (hero.fall_to), so let the previous fall's window run out first.
	var wait := 0
	while level.hero.is_immune() and wait < 3 * Engine.physics_ticks_per_second:
		await get_tree().physics_frame
		wait += 1
	level.hero.respawn_at(a3.to_global(drop_local))
	level.camera.reset_position()
	var hp0: int = Session.state.get("health", 6)
	var t := 0
	while t < int(3.0 * Engine.physics_ticks_per_second):
		await get_tree().physics_frame
		t += 1
		if Session.state.get("health", 6) < hp0 and level.hero.is_on_floor():
			break
	await physics_frames(10)
	var hp1: int = Session.state.get("health", 6)
	var at: Vector2 = a3.to_local(level.hero.global_position)
	print("[test_m7_roof_fall] %s: health %d->%d, now at local (%.0f,%.0f)" % [label, hp0, hp1, at.x, at.y])
	check(hp1 == hp0 - 1, "a fall into %s costs one health (%d -> %d)" % [label, hp0, hp1])
	check(absf(at.x - roof_local.x) < 40.0 and absf(at.y - roof_local.y) < 12.0,
			"and puts Dave back on the roof he jumped from (now local (%.0f,%.0f), want ~(%.0f,%.0f))" % [at.x, at.y, roof_local.x, roof_local.y])
