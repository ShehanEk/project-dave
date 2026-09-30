extends TestCase
## M3 layout/fairness regression: recovery paths and traversal hazards in the
## assembled level_01, measured by actually driving the hero. Grew out of the
## M3 assembly review (LAY-01 A06 pit-hazard/reset-foothold overlap, LAY-04
## GapPlatform missed-cycle wait, LAY-05 roof-fall recovery, LAY-06 A03
## service-lane bypass, LAY-07 A04 flowerbed bottomless gaps, LAY-12 SW01
## channel stacked steps); keep passing after any future geometry change.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"

var level: LevelDirector


func run() -> void:
	await _probe_a03_street_bypass()
	await _probe_platform_cycle()
	await _probe_roof_fall_recovery()
	await _probe_sw01_channel()
	await _probe_a04_gaps()
	await _probe_a06_pit_edge()
	await _probe_a06_pit_reset_hold_right()
	await _probe_a03_midroof_street_bypass()


func _load() -> void:
	Session.new_run()
	level = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)


func _unload() -> void:
	release_all()
	level.queue_free()
	await physics_frames(3)


func _area(id: String) -> AreaRoot:
	for a in level.areas:
		if a.area_id == id:
			return a
	return null


func _place(area: AreaRoot, local: Vector2) -> void:
	level.hero.respawn_at(area.to_global(local))
	level.camera.reset_position()
	await physics_frames(2)


func _local(area: AreaRoot) -> Vector2:
	return area.to_local(level.hero.global_position)


## A throwaway AreaRoot carrying RoutePoints (area-local coords of `area`).
func _run_points(area: AreaRoot, spec: Array, timeout: float) -> Dictionary:
	var tmp := AreaRoot.new()
	tmp.area_id = area.area_id + "-probe"
	tmp.position = area.global_position
	var route := Node2D.new()
	route.name = "Route"
	tmp.add_child(route)
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
	bot.point_reached.connect(func(i, _p): print("[probe_lay_recovery]     pt%d start hero local=(%.0f,%.0f)" % [i, area.to_local(level.hero.global_position).x, area.to_local(level.hero.global_position).y]))
	bot.start(level.hero)
	var t := 0
	while bot.running and t < int(timeout * 60):
		await get_tree().physics_frame
		t += 1
	var rep := bot.get_report()
	if bot.running:
		rep.failure = "timeout"
		bot.running = false
	release_all()
	bot.queue_free()
	tmp.queue_free()
	await physics_frames(1)
	return rep


# (a) Can the whole rooftop area be skipped by walking the service lane?
func _probe_a03_street_bypass() -> void:
	await _load()
	var a3 := _area("L01-A03")
	await _place(a3, Vector2(96, -4))
	var jumps := 0
	press("move_right")
	var t := 0
	var reached := false
	while t < 60 * 30:
		await get_tree().physics_frame
		t += 1
		var lp := _local(a3)
		if lp.x >= a3.width - 64.0:
			reached = absf(lp.y) < 8.0
			break
	release_all()
	var lp := _local(a3)
	print("[probe_lay_recovery] A03 hold-right-only on street: reached_exit=%s in %.2fs, final local=(%.0f,%.0f), jumps=%d, beats hit? (B03/B04 zones cover y range)" % [reached, t / 60.0, lp.x, lp.y, jumps])
	print("[probe_lay_recovery]   Session checkpoint after bypass=%s chips=%s" % [Session.state.get("checkpoint_id"), str(Session.state.get("wallet"))])
	check(not reached, "A03 rooftop route (moving platform, E05, E06, CP02) cannot be bypassed by holding right on the street (reached exit in %.1fs)" % (t / 60.0))
	await _unload()


# (b) moving-platform missed-cycle wait
func _probe_platform_cycle() -> void:
	await _load()
	var a3 := _area("L01-A03")
	var plat: MovingPlatform = a3.get_node("Geometry/GapPlatform")
	var at_a_ticks: Array = []
	var was_at_a := false
	var leave_a := -1
	var waits: Array = []
	for t in 60 * 40:
		await get_tree().physics_frame
		var at_a: bool = plat.position.distance_to(plat.point_a) < 4.0
		if was_at_a and not at_a:
			leave_a = t
		if at_a and not was_at_a and leave_a >= 0:
			waits.append((t - leave_a) / 60.0)
		was_at_a = at_a
	var span := plat.point_a.distance_to(plat.point_b)
	print("[probe_lay_recovery] A03 GapPlatform span=%.0fpx speed=%.0f pause=%.1f -> analytic away-from-boarding-ledge time=%.2fs; measured leave->return waits=%s" % [
			span, plat.speed, plat.pause_time, 2.0 * span / plat.speed + plat.pause_time, str(waits)])
	var worst: float = waits.max() if not waits.is_empty() else 0.0
	check(worst <= 6.5, "A03 moving-platform missed-cycle wait %.2fs <= ~6s (01 pacing rule)" % worst)
	await _unload()


# (c) roof fall into the service lane below the gap-platform -> back up.
# LAY-05 regression: the original fix removed RecoveryStepA/RecoveryStepB
# (they sat inside the GapPlatform's own x-sweep, so the platform could
# shove the hero off them or block the climb) and tried to have the hero
# walk all the way back to redo the main route's own T1->T2->T3 chain from
# x=450. That does not actually work: Terrace1 (top -64, only 24px of
# clearance under it) and Terrace2 (top -136, its underside sits exactly at
# the hero's own head height) both fully block ground-level travel
# underneath them — by design, since a low "ordinary rise" step can never
# also be walkable under a full H-tall hero. A hero fallen near the
# GapPlatform (x~1950-2350) can never walk left past x~1310 at street
# level.
#
# The actual fix instead gives the hero a short LOCAL way back up, entirely
# to the right of Terrace1/2 (so it never needs that blocked walk) and
# clear of the GapPlatform's x-sweep (so it can never be shoved): a single
# new low step, RecoveryStepA (area-local x 1350..1470, top -68, matching
# the same ordinary-rise height as Terrace1's own step), lets the hero hop
# up from the street, then hop again from RecoveryStepA's top onto
# Terrace2's own top (-136, same rise, matching the main route's own
# T1->T2 hop) and continue the main route's proven Terrace2->Terrace3 jump
# (reusing RP05_JumpT3/RP06_T3Landed's own numbers) from there. MovingPlatform
# also yields to the hero (mask 1|2 in _is_blocked_ahead) instead of pushing
# through it, so this path is safe regardless of the platform's phase.
func _probe_roof_fall_recovery() -> void:
	for phase in [0.0, 1.5, 3.0, 4.5, 6.0, 7.5, 9.0]:
		await _load()
		var a3 := _area("L01-A03")
		await seconds(phase)
		await _place(a3, Vector2(2150, -4))
		var hp0: int = Session.state.get("health", 6)
		var spec := [
			{"pos": Vector2(1490, 0), "tol": 15.0},
			{"pos": Vector2(1490, 0), "action": RoutePoint.Action.JUMP, "hold": 0.25, "tol": 15.0},
			{"pos": Vector2(1400, -68), "tol": 12.0},
			{"pos": Vector2(1355, -68), "action": RoutePoint.Action.JUMP, "hold": 0.3, "tol": 12.0},
			{"pos": Vector2(1200, -136), "tol": 14.0},
			{"pos": Vector2(1290, -136), "action": RoutePoint.Action.JUMP, "hold": 0.24, "tol": 12.0},
			{"pos": Vector2(1700, -216), "tol": 12.0},
		]
		var rep := await _run_points(a3, spec, 25.0)
		var lp := _local(a3)
		var ok: bool = rep.success and lp.y < -200.0
		print("[probe_lay_recovery] A03 roof-fall recovery (platform phase +%.1fs): success=%s time=%.2fs final_local=(%.0f,%.0f) health %d->%d failure=%s" % [
				phase, ok, rep.seconds, lp.x, lp.y, hp0, Session.state.get("health", 6), rep.failure])
		check(ok, "A03 service-lane recovery back to Terrace3 succeeds (phase %.1fs): %s at local (%.0f,%.0f)" % [phase, rep.failure, lp.x, lp.y])
		await _unload()


# (e) SW01 channel: fall in before the switch, climb back out.
# LAY-12 fix: ChannelStep1 (area-local x 4340..4480, top 232) and
# ChannelStep2 (x 4200..4340, top 164) are now offset horizontally instead
# of stacked at the same x, so the climb out of the pit (floor top 300) is
# three ordinary 68px hops — pit->Step1, Step1->Step2, Step2->B04Floor
# (top 96, whose own right edge sits flush against Step2's left edge) —
# each approached from outside the next block's own footprint, the same
# way every other jump in this level works, instead of one near-max-reach
# 136px leap stacked at a single x.
func _probe_sw01_channel() -> void:
	await _load()
	var a4 := _area("L01-A04")
	await _place(a4, Vector2(4500, 296))
	await seconds(0.5)
	var spec := [
		{"pos": Vector2(4500, 300), "tol": 10.0},
		{"pos": Vector2(4500, 300), "action": RoutePoint.Action.JUMP, "hold": 0.22, "tol": 10.0},
		{"pos": Vector2(4360, 232), "tol": 10.0},
		{"pos": Vector2(4360, 232), "action": RoutePoint.Action.JUMP, "hold": 0.25, "tol": 10.0},
		{"pos": Vector2(4220, 164), "tol": 10.0},
		{"pos": Vector2(4220, 164), "action": RoutePoint.Action.JUMP, "hold": 0.25, "tol": 10.0},
		{"pos": Vector2(4100, 96), "tol": 12.0},
	]
	var rep := await _run_points(a4, spec, 20.0)
	var lp := _local(a4)
	print("[probe_lay_recovery] A04 SW01 channel escape (three ordinary hops): success=%s final_local=(%.0f,%.0f) failure=%s time=%.2f" % [rep.success, lp.x, lp.y, rep.failure, rep.seconds])
	# geometry facts
	var s1: Block = a4.get_node("Geometry/ChannelStep1")
	var s2: Block = a4.get_node("Geometry/ChannelStep2")
	var pit: Block = a4.get_node("Geometry/PitFloor")
	var rise1: float = pit.position.y - s1.position.y
	var rise2: float = s1.position.y - s2.position.y
	print("[probe_lay_recovery] A04 channel: PitFloor top=%.0f  Step1 rect=%s (rise %.0f)  Step2 rect=%s (rise %.0f) -> offset (not stacked): %s" % [
			pit.position.y, str(Rect2(s1.position, s1.size)), rise1, str(Rect2(s2.position, s2.size)), rise2,
			str(s1.position.x != s2.position.x)])
	check(rep.success and lp.y < 100.0, "hero who falls into the SW01 channel can climb back out to B04Floor")
	check(s1.position.x != s2.position.x, "SW01 channel steps are horizontally offset, not stacked at the same x")
	check(rise1 <= 86.4, "SW01 channel pit->Step1 rise %.0f px <= 0.9H" % rise1)
	check(rise2 <= 86.4, "SW01 channel Step1->Step2 rise %.0f px <= 0.9H" % rise2)
	await _unload()


# (f) A04 main-route gaps: where does a missed jump put the hero?
func _probe_a04_gaps() -> void:
	for x in [2075.0, 2420.0, 2735.0, 3060.0, 6330.0, 6725.0]:
		await _load()
		var a4 := _area("L01-A04")
		await _place(a4, Vector2(x, 60))
		await seconds(3.0)
		var lp := _local(a4)
		var ar := level._area_for_x(level.hero.global_position.x)
		print("[probe_lay_recovery] A04 missed jump at local x=%.0f -> hero ends at %s local (%.0f,%.0f) [global %.0f]" % [
				x, ar.area_id, ar.to_local(level.hero.global_position).x, ar.to_local(level.hero.global_position).y, level.hero.global_position.x])
		check(absf(lp.x - x) < 400.0, "A04 missed main-route jump at x=%.0f recovers nearby (ended at local x=%.0f, %.0f px back)" % [x, lp.x, x - lp.x])
		await _unload()


# (g) A06 marked pit: hazard area vs solid platform tops
func _probe_a06_pit_edge() -> void:
	for x in [3160.0, 3180.0, 3190.0, 3198.0, 3382.0, 3378.0]:
		await _load()
		var a6 := _area("L01-A06")
		var pit: PitHazard = a6.get_node("Entities/PitHazard_B03")
		var reset: Marker2D = pit.get_node("Reset")
		var hp0: int = Session.state.get("health", 6)
		await _place(a6, Vector2(x, -68))
		await seconds(0.6)
		var hp1: int = Session.state.get("health", 6)
		var lp := _local(a6)
		var on_solid: bool = (x + 20.0 <= 3220.0) or (x - 20.0 >= 3360.0)
		print("[probe_lay_recovery] A06 standing still at local x=%.0f (body %.0f..%.0f, fully on solid=%s): health %d->%d, now at (%.0f,%.0f); reset marker local=%s hazard rect local=%s" % [
				x, x - 20.0, x + 20.0, on_solid, hp0, hp1, lp.x, lp.y,
				str(a6.to_local(reset.global_position)), str(Rect2(a6.to_local(pit.global_position) - pit.size * 0.5, pit.size))])
		if on_solid:
			check(hp1 == hp0, "A06 hero standing on solid platform at x=%.0f is not hit by the pit hazard (health %d->%d)" % [x, hp0, hp1])
		await _unload()


# (h) after a pit reset, the natural "keep holding right" input
func _probe_a06_pit_reset_hold_right() -> void:
	await _load()
	var a6 := _area("L01-A06")
	var reset: Marker2D = a6.get_node("Entities/PitHazard_B03/Reset")
	level.hero.respawn_at(reset.global_position)
	await physics_frames(2)
	var hp0: int = Session.get_health()
	var hits := 0
	var last: int = hp0
	press("move_right")
	for t in 90:
		await get_tree().physics_frame
		if Session.get_health() < last:
			hits += 1
		last = Session.get_health()
	release_all()
	print("[probe_lay_recovery] A06 from pit Reset foothold, hold move_right 1.5s: health %d->%d (%d separate pit hits), checkpoint=%s" % [hp0, Session.get_health(), hits, Session.state.get("checkpoint_id")])
	check(hits <= 1, "A06 pit reset foothold: walking right from the reset point costs at most 1 health per 1.5s (took %d hits)" % hits)
	await _unload()


# (i) fall off the roof after the first terrace -> walk the street to the exit?
func _probe_a03_midroof_street_bypass() -> void:
	await _load()
	var a3 := _area("L01-A03")
	await _place(a3, Vector2(2150, -4))
	press("move_right")
	var t := 0
	var reached := false
	while t < 60 * 30:
		await get_tree().physics_frame
		t += 1
		var lp := _local(a3)
		if lp.x >= a3.width - 64.0:
			reached = absf(lp.y) < 8.0
			break
	release_all()
	var lp := _local(a3)
	print("[probe_lay_recovery] A03 fall to street at x=2150 then hold right only: reached A03 exit=%s in %.2fs final local=(%.0f,%.0f)" % [reached, t / 60.0, lp.x, lp.y])
	check(not reached, "A03 service lane below the roofs does not let the hero skip B03-B05 (E05, E06, CP02) by walking right (%.1fs)" % (t / 60.0))
	await _unload()
