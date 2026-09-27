extends TestCase
## M7 / 07-acceptance-and-playtesting.md T06 ("Mixed lane: at most two enemies
## active; only one windup/active attacker; usable retreat remains"), proven
## on the REAL level encounter groups L01-E07 (scenes/levels/areas/
## a04_square.tscn) and L01-E11 (scenes/levels/areas/a06_exit.tscn) with a
## dwelling RouteBot for a sustained multi-attack-cycle sample (CONVENTIONS.md's
## EncounterGroup contract: "At most one windup/active attacker per group").
##
## AUD-07 correction: L01-E09 (also in a04_square.tscn) also pairs a Resident
## with a Clipper, and L01-E08 pairs two Residents — E07/E11 are NOT the only
## multi-attacker groups in the shipped level, just the two this dwell-style
## test happens to sample. E08/E09 (and every other group) still get the
## brief whole-route one-attacker check from
## test_m3_regress_encounters.gd::_combat_run() as a RouteBot walks past them
## once; E08 specifically also gets test_m3_regress_encounters.gd's LAY-14
## exposure check. The "usable retreat remains" clause of T06 is evidenced
## separately by test_m3_regress_route.gd (every MAIN-route encounter
## activation asserts >=2H of flat retreat floor behind the hero), not by
## this file.
##
## This is deliberately NOT test_m2_mixed_lane.gd's own 20s fairness check
## (an isolated synthetic scene with hand-placed enemies/floor, unrelated to
## the shipped level's geometry/tuning) and NOT test_m3_regress_encounters.gd's
## `_combat_run()` (which asserts the same one-attacker invariant across the
## WHOLE level, but only for the few seconds a RouteBot takes to walk past
## each group once on its way through). Here a scripted hero (RouteBot, named
## input actions only, per CONVENTIONS.md) walks the group's own authored
## approach/backstop-hop lane (the exact terrain jump coordinates already
## placed by the area's own author — scenes/levels/areas/a04_square.tscn's
## RP02-RP07 / a06_exit.tscn's RP09-RP13) and DWELLS for several seconds at
## each real enemy's own (measured, not hand-guessed) position, long enough
## for several full attack cycles from each, sampling the one-attacker
## invariant continuously across the whole run. (An earlier draft tried a
## there-and-back loop over the same lane to get more samples per run, and
## found the reverse direction's jump over the backstop does not clear it the
## same way a forward jump does — a real player only ever crosses this lane
## one way in the shipped route, so this test does the same, single pass,
## with an explicit dwell instead of a repeated lap.)

const A04 := "res://scenes/levels/areas/a04_square.tscn"
const A06 := "res://scenes/levels/areas/a06_exit.tscn"
const DWELL_SECONDS := 8.0
const MAX_SECONDS := 60.0


func run() -> void:
	await _sample_group(A04, "Encounters/EncounterGroup_E07", "L01-E07",
			Vector2(460, 0), [
				{"pos": Vector2(1280, 0), "action": RoutePoint.Action.JUMP, "tol": 15.0, "hold": 0.1},
				{"pos": Vector2(1420, 0), "tol": 14.0},
				{"pos": Vector2(1530, 0), "tol": 16.0},
				{"pos": Vector2(1530, 0), "action": RoutePoint.Action.JUMP, "tol": 15.0, "hold": 0.25},
			], Vector2(1990, 0))
	await _sample_group(A06, "Encounters/EncounterGroup_E11", "L01-E11",
			Vector2(3900, 0), [
				{"pos": Vector2(4320, 0), "action": RoutePoint.Action.JUMP, "tol": 10.0, "hold": 0.25},
				{"pos": Vector2(5140, 0), "action": RoutePoint.Action.JUMP, "tol": 10.0, "hold": 0.45},
			], Vector2(5420, 0))


## `start`/`finish` and `mid_terrain` (any jumps that sit BETWEEN the
## Resident and the Clipper on the real route, unchanged authored terrain
## coordinates) bracket two dynamic dwell points measured at each enemy's own
## actual settled position, so this stays correct even if area geometry is
## retuned later.
func _sample_group(area_path: String, group_path: String, label: String,
		start: Vector2, mid_terrain: Array, finish: Vector2) -> void:
	Session.new_run()
	var area: AreaRoot = load(area_path).instantiate()
	add_child(area)
	await physics_frames(3)

	var group: EncounterGroup = area.get_node_or_null(group_path)
	check(group != null, "%s: EncounterGroup exists at %s" % [label, group_path])
	if group == null:
		area.queue_free()
		return

	var enemies: Array = []
	for c in group.get_children():
		if c.is_in_group("enemy"):
			enemies.append(c)
	check(enemies.size() == 2, "%s has exactly 2 enemies (a Resident + a Clipper) (got %d)" % [label, enemies.size()])
	if enemies.size() != 2:
		area.queue_free()
		return
	var resident: Node2D = enemies[0] if enemies[0] is Resident else enemies[1]
	var clipper: Node2D = enemies[0] if enemies[0] is Clipper else enemies[1]
	check(resident is Resident and clipper is Clipper,
			"%s: group has exactly one Resident and one Clipper" % label)

	# Build: start -> [dwell at the real Resident / authored mid-lane terrain
	# (backstop hop(s)) / dwell at the real Clipper, merged in x-order since
	# the terrain can sit before, between, or after either enemy depending on
	# the area] -> finish.
	var items: Array = [
		{"x": resident.global_position.x, "points": [
			{"pos": Vector2(resident.global_position.x, 0.0), "tol": 24.0},
			{"pos": Vector2(resident.global_position.x, 0.0), "tol": 24.0, "action": RoutePoint.Action.WAIT_SECONDS, "seconds": DWELL_SECONDS},
		]},
		{"x": clipper.global_position.x, "points": [
			{"pos": Vector2(clipper.global_position.x, 0.0), "tol": 24.0},
			{"pos": Vector2(clipper.global_position.x, 0.0), "tol": 24.0, "action": RoutePoint.Action.WAIT_SECONDS, "seconds": DWELL_SECONDS},
		]},
	]
	for m in mid_terrain:
		items.append({"x": m.pos.x, "points": [m]})
	items.sort_custom(func(a, b): return a.x < b.x)

	var spec: Array = [{"pos": start, "tol": 16.0}]
	for it in items:
		for p in it.points:
			spec.append(p)
	spec.append({"pos": finish, "tol": 16.0})

	var tmp := AreaRoot.new()
	tmp.area_id = area.area_id + "-fairness-probe"
	var route := Node2D.new()
	route.name = "Route"
	tmp.add_child(route)
	for s in spec:
		var p := RoutePoint.new()
		p.position = s.pos
		p.action = s.get("action", RoutePoint.Action.MOVE)
		p.tolerance = s.get("tol", 12.0)
		p.hold_jump = s.get("hold", 0.12)
		p.seconds = s.get("seconds", 0.0)
		route.add_child(p)
	add_child(tmp)

	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.debug_invulnerable = true
	hero.global_position = area.to_global(start)
	await physics_frames(3)

	var bot := RouteBot.new()
	bot.stuck_timeout = 6.0
	add_child(bot)
	bot.build_points(tmp, [])
	bot.start(hero)

	var attacks := {resident: 0, clipper: 0}
	var was_active := {resident: false, clipper: false}
	var max_concurrent := 0
	var violation_tick := -1
	var t := 0
	var max_ticks := int(MAX_SECONDS * Engine.physics_ticks_per_second)
	while bot.running and t < max_ticks:
		await get_tree().physics_frame
		t += 1
		var concurrent := 0
		for e in [resident, clipper]:
			if not is_instance_valid(e):
				continue
			var active: bool = _is_attacking(e)
			if active and not was_active[e]:
				attacks[e] += 1
			was_active[e] = active
			if active:
				concurrent += 1
		max_concurrent = maxi(max_concurrent, concurrent)
		if concurrent > 1 and violation_tick < 0:
			violation_tick = t
	if bot.running:
		bot.failure_message = "test timeout after %.1fs" % MAX_SECONDS
		bot.running = false

	var rep := bot.get_report()
	print("[test_m7_encounter_fairness] %s: %.1fs run (success=%s, failure=%s), max_concurrent=%d, resident_attacks=%d clipper_attacks=%d" % [
			label, t / 60.0, rep.success, rep.failure, max_concurrent, attacks[resident], attacks[clipper]])
	check(rep.success, "%s: scripted hero completes the real lane past both enemies (failure=%s)" % [label, rep.failure])
	check(violation_tick < 0,
			"%s: never more than one windup/active attacker at once (first violation at tick %d)" % [label, violation_tick])
	check(max_concurrent <= 1, "%s: max concurrent windup/active attackers is <=1 (got %d)" % [label, max_concurrent])
	check(attacks[resident] >= 1,
			"%s: %s actually got at least one attack turn (got %d) — proves the invariant was really exercised, not vacuously true" % [
					label, resident.entity_id, attacks[resident]])
	check(attacks[clipper] >= 1,
			"%s: %s actually got at least one attack turn (got %d) — proves the invariant was really exercised, not vacuously true" % [
					label, clipper.entity_id, attacks[clipper]])
	check(hero.input_enabled, "%s: hero input remains enabled throughout (never trapped/soft-locked by the encounter)" % label)

	bot.queue_free()
	hero.queue_free()
	tmp.queue_free()
	area.queue_free()
	await physics_frames(2)


func _is_attacking(e: Node) -> bool:
	if e is Clipper:
		return e.state == Clipper.State.WINDUP or e.state == Clipper.State.CHARGE
	return e.state == Resident.State.WINDUP or e.state == Resident.State.LUNGE
