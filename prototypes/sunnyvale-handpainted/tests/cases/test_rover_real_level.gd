extends TestCase
## Proves (or disproves) that each of the six real L01 Patrol Rovers can be
## killed fairly with the stage-0 pistol and ordinary movement, using the
## REAL area scenes (scenes/levels/areas/*.tscn) and the REAL authored Route
## points a player actually walks/jumps on the main route — not a synthetic
## hand-built rig like test_m2_rover.gd.
##
## For each rover: place the hero at an authored Route point strictly
## BEFORE that encounter's EncounterGroup.ApproachZone (so is_active flips on
## exactly like a real playthrough, never a teleport-past-the-trigger false
## negative), then walk/jump the exact chain of REAL Route points a player
## follows through that encounter (each point's own authored `action` and
## `hold_jump`, unchanged — MOVE or JUMP, read from the resource, never
## guessed by name), then try to destroy the rover with the base pistol from
## behind. The hero is `debug_invulnerable` (per CONVENTIONS.md/03:
## robustness, not a rules change), but every tick where the rover's
## AttackBox is active and overlaps the hero's approximate hurtbox is
## separately flagged as `would_take_damage` so an invulnerable pass is never
## silently read as "safe".
##
## This does NOT change the rover rule (front always blocks, the rear
## battery is only damageable while STALL) — it only proves whether the
## shipped level geometry/acquire timing actually produces a stall on a
## natural approach. Keep this test: it should read all-green only once
## every rover in the shipped level is fairly killable; a currently-failing
## rover is a real level-authoring bug for a follow-up pass, not a reason to
## loosen this test.

const A02 := "res://scenes/levels/areas/a02_gardens.tscn"
const A04 := "res://scenes/levels/areas/a04_square.tscn"
const A06 := "res://scenes/levels/areas/a06_exit.tscn"

const APPROACH_TOL := 8.0
const REAR_ALIGN_TOL := 18.0
const TOTAL_BUDGET_S := 26.0

## One report Dictionary per rover, printed as a single summary at the end.
var _reports: Array = []


func run() -> void:
	# Each encounter's route_names is the REAL, ordered Route chain from a
	# point strictly before that group's ApproachZone through to a point
	# safely past the rover. Every intermediate terrain jump the level
	# already authors (e.g. E07's CentralStep hop) is included so the hero
	# actually arrives, instead of a shortcut that walks into unclimbed
	# terrain.
	await _test_rover(A02, "Encounters/EncounterGroup_E02", "PatrolRover", "L01-E02-M01-01",
			["R03_Move", "R04_Move", "R05_JumpBackstop1", "R06_Move"],
			"L01-E02 (A02 Front Gardens, 1st rover)")
	await _test_rover(A02, "Encounters/EncounterGroup_E04", "PatrolRover", "L01-E04-M01-01",
			["R15_Move", "R16_Move", "R17_JumpBackstop2", "R18_Move"],
			"L01-E04 (A02 Front Gardens, 2nd rover)")
	await _test_rover(A04, "Encounters/EncounterGroup_E07", "PatrolRover_M01_01", "L01-E07-M01-01",
			["RP01_ToOverlookEdge", "RP02_PastGuard", "RP03_HopCentralStep",
					"RP04_AcrossStepTop", "RP05_ApproachBackstop", "RP06_HopBackstop", "RP07_PastRover"],
			"L01-E07 (A04 Square, 1st rover)")
	await _test_rover(A04, "Encounters/EncounterGroup_E09", "PatrolRover_M01_01", "L01-E09-M01-01",
			# Starts at RP20 (already past the SW01 walkway/channel, which is
			# an unrelated traversal gate, not part of this rover's own
			# mechanic) — still strictly before E09's ApproachZone (world
			# x=4830) so the natural acquire trigger is genuinely exercised.
			["RP20_PastChannel", "RP21_PastE09Guard", "RP22_ApproachE09Backstop",
					"RP23_HopE09Backstop", "RP24_PastE09Rover"],
			"L01-E09 (A04 Square, 2nd rover)")
	await _test_rover(A06, "Encounters/EncounterGroup_E10", "PatrolRover", "L01-E10-M01-01",
			["RP01_ApproachE10", "RP01b_JumpE10Stall", "RP02_JumpBackstopE10", "RP03_PastBackstopE10"],
			"L01-E10 (A06 Exit, 1st rover)")
	await _test_rover(A06, "Encounters/EncounterGroup_E11", "PatrolRover", "L01-E11-M01-01",
			["RP09_ApproachE11", "RP09b_JumpE11Stall", "RP10_PastStaffer", "RP11_PastRover"],
			"L01-E11 (A06 Exit, 2nd rover)")

	_print_summary()

	var all_killable := true
	for r in _reports:
		check(r.killable, "%s (%s): killable with the base pistol on the natural approach (%s)" % [r.label, r.id, r.notes])
		if not r.killable:
			all_killable = false
	check(all_killable, "every one of the six real Patrol Rovers is fairly killable on the shipped level's natural approach")


## --- per-rover scripted natural-approach + kill attempt -------------------

func _test_rover(area_path: String, group_path: String, rover_path: String, entity_id: String,
		route_names: PackedStringArray, label: String) -> void:
	Session.new_run()
	var area: AreaRoot = load(area_path).instantiate()
	add_child(area)
	await physics_frames(3)

	var group: EncounterGroup = area.get_node_or_null(group_path)
	check(group != null, "%s: EncounterGroup exists at %s" % [label, group_path])
	var rover: PatrolRover = group.get_node_or_null(rover_path) if group != null else null
	check(rover != null, "%s: PatrolRover node exists at %s/%s" % [label, group_path, rover_path])
	if group == null or rover == null:
		_reports.append(_blank_report(entity_id, label,
				"scene wiring missing (%s / %s) — see checks above" % [group_path, rover_path]))
		area.queue_free()
		await physics_frames(1)
		return
	check(rover.entity_id == entity_id, "%s: rover entity_id is %s (got %s)" % [label, entity_id, rover.entity_id])

	var points: Array = []
	for n in route_names:
		var p: RoutePoint = area.get_node_or_null("Route/%s" % n)
		check(p != null, "%s: authored Route point %s exists" % [label, n])
		points.append(p)
	if points.has(null):
		_reports.append(_blank_report(entity_id, label, "missing Route point(s) — see checks above"))
		area.queue_free()
		await physics_frames(1)
		return

	var approach_zone: Area2D = group.get_node_or_null("ApproachZone")
	if approach_zone:
		check(points[0].global_position.x <= approach_zone.global_position.x,
				"%s: chosen start point (x=%.0f) is genuinely at/before the ApproachZone (x=%.0f), not teleported past it" % [
						label, points[0].global_position.x, approach_zone.global_position.x])

	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	hero.global_position = Vector2(points[0].global_position.x, rover.global_position.y)
	await physics_frames(3)

	# A destroyed rover frees itself (its wreck is a separate ragdoll), so
	# read its tuning up front for the report.
	var tuning: ChargerTuning = rover.tuning
	var ctx := {
		"tick": 0,
		"prev_state": rover.state,
		"charge_index": 0,
		"charge_start_pos": Vector2.ZERO,
		"charge_log": [],  # [{index, start_x, outcome, traveled}]
		"stall_enter_tick": -1,
		"engage_tick": -1,  # first tick hero is grounded+near rear zone during a STALL
		"would_take_damage": false,
		"rear_hits": 0,
		"blocked_hits": 0,
		"hint_shown": false,
		"defeated": false,
	}
	rover.defeated.connect(func(_id): ctx.defeated = true)
	rover.rear_hit_zone.hit.connect(func(_d, _p, _dir): ctx.rear_hits += 1)
	rover.hint_requested.connect(func(_t): ctx.hint_shown = true)
	if rover.front_hit_zone.has_signal("blocked_hit"):
		rover.front_hit_zone.blocked_hit.connect(func(_p): ctx.blocked_hits += 1)

	# --- One reactive loop: normally follows the real authored Route chain
	# (each point's own action/hold_jump, unchanged — MOVE just walks, JUMP
	# holds jump for that point's own hold_jump while steering toward the
	# NEXT point so the jump actually carries past the obstacle, exactly like
	# RouteBot's own jump-air steering), but at ANY tick where the rover is
	# actually STALLed, a plausible alert player reacts immediately — turns
	# to aim at the exposed rear battery and fires — interrupting whatever
	# scripted footwork was in progress, rather than robotically finishing a
	# pre-planned path while a stall window ticks away unused. The hero is
	# placed AT points[0] already, so navigation starts at index 1.
	var idx := 1
	var last_x: float = points[points.size() - 1].global_position.x
	var jumping := false
	var jump_hold_ticks := 0
	var jump_elapsed := 0
	var jump_left_ground := false

	var max_ticks := int(TOTAL_BUDGET_S * 60.0)
	var t := 0
	while t < max_ticks and not ctx.defeated and is_instance_valid(rover):
		_track(rover, hero, ctx)
		if rover.state == PatrolRover.State.STALL:
			if ctx.stall_enter_tick < 0:
				ctx.stall_enter_tick = ctx.tick
			if jumping:
				release("jump")
				jumping = false
			var rear: Vector2 = rover.rear_hit_zone.global_position
			hero.aim_override = rear
			var aligned: bool = _steer(hero, rear.x, REAR_ALIGN_TOL)
			if ctx.engage_tick < 0 and aligned and hero.is_on_floor():
				ctx.engage_tick = ctx.tick
			press("fire")
		elif rover.state == PatrolRover.State.CHARGE and not jumping and hero.is_on_floor() \
				and absf(rover.global_position.x - hero.global_position.x) < 150.0:
			# Reactive dodge: a charge is closing in faster than a scripted
			# waypoint jump would react — jump now regardless of route index.
			release("fire")
			press("jump")
			jumping = true
			jump_hold_ticks = 16
			jump_elapsed = 0
			jump_left_ground = false
		elif jumping:
			release("fire")
			if jump_elapsed < jump_hold_ticks:
				press("jump")
			else:
				release("jump")
			var next_x: float = points[idx + 1].global_position.x if idx + 1 < points.size() else points[idx].global_position.x
			_steer(hero, next_x, 4.0)
			jump_elapsed += 1
			if not hero.is_on_floor():
				jump_left_ground = true
			elif jump_left_ground:
				jumping = false
				release("jump")
				idx += 1
		elif idx < points.size():
			release("fire")
			var point: RoutePoint = points[idx]
			if _steer(hero, point.global_position.x, APPROACH_TOL):
				if point.action == RoutePoint.Action.JUMP:
					press("jump")
					jumping = true
					jump_hold_ticks = int(maxf(point.hold_jump, 0.1) * 60.0)
					jump_elapsed = 0
					jump_left_ground = false
				else:
					idx += 1
		else:
			release("fire")
			_steer(hero, last_x, APPROACH_TOL)
		await physics_frames(1)
		ctx.tick += 1
		t += 1
	release("fire"); release("move_left"); release("move_right"); release("jump")

	# --- build the report ---
	var first_outcome := "no charge observed"
	var first_traveled := 0.0
	if not ctx.charge_log.is_empty():
		first_outcome = ctx.charge_log[0].outcome
		first_traveled = ctx.charge_log[0].traveled
	var stalls_natural: bool = not ctx.charge_log.is_empty() and ctx.charge_log[0].outcome == "STALL"

	var stall_window := 0.0
	if ctx.stall_enter_tick >= 0:
		var engage_tick: int = ctx.engage_tick if ctx.engage_tick >= 0 else ctx.stall_enter_tick
		var elapsed_into_stall: float = maxf(0.0, float(engage_tick - ctx.stall_enter_tick) / 60.0)
		stall_window = maxf(0.0, tuning.wall_stall_time - elapsed_into_stall)

	var notes: PackedStringArray = []
	notes.append("charge #1: %s after %.0fpx (backstop cap 4H=%.0fpx)" % [first_outcome, first_traveled, tuning.charge_max_distance()])
	if ctx.charge_log.size() > 1:
		var later: PackedStringArray = []
		for i in range(1, ctx.charge_log.size()):
			later.append("#%d %s/%.0fpx" % [i + 1, ctx.charge_log[i].outcome, ctx.charge_log[i].traveled])
		notes.append("later charges: " + ", ".join(later))
	notes.append("blocked frontal hits observed=%d, hint_shown=%s" % [ctx.blocked_hits, ctx.hint_shown])
	notes.append("rear hits landed=%d" % ctx.rear_hits)
	notes.append("would_take_damage=%s" % ctx.would_take_damage)
	if ctx.defeated:
		notes.append("DEFEATED")
	else:
		notes.append("NOT defeated within %.0fs total budget" % TOTAL_BUDGET_S)

	var report := {
		"id": entity_id,
		"label": label,
		"stalls_on_natural_approach": stalls_natural,
		"stall_window_s": stall_window,
		"shots_needed": ctx.rear_hits,
		"killable": ctx.defeated,
		"would_take_damage": ctx.would_take_damage,
		"notes": "; ".join(notes),
	}
	_reports.append(report)
	print("[test_rover_real_level] %s (%s): %s" % [label, entity_id, report.notes])

	hero.queue_free()
	area.queue_free()
	await physics_frames(2)


func _blank_report(entity_id: String, label: String, notes: String) -> Dictionary:
	return {"id": entity_id, "label": label, "killable": false,
			"stalls_on_natural_approach": false, "stall_window_s": 0.0,
			"shots_needed": 0, "would_take_damage": false, "notes": notes}


## Tracks rover state transitions (charge start/outcome) and a rough
## "would this frontal-invulnerable pass actually have been hit" flag, once
## per tick, from every phase.
func _track(rover: PatrolRover, hero: Hero, ctx: Dictionary) -> void:
	if not is_instance_valid(rover):
		return
	if rover.attack_box.active:
		var dx: float = absf(hero.global_position.x - rover.global_position.x)
		var dy: float = absf(hero.global_position.y - rover.global_position.y)
		if dx < 50.0 and dy < 70.0:
			ctx.would_take_damage = true

	if rover.state == ctx.prev_state:
		return
	if rover.state == PatrolRover.State.CHARGE:
		ctx.charge_index += 1
		ctx.charge_start_pos = rover.global_position
	if ctx.prev_state == PatrolRover.State.CHARGE:
		var traveled: float = absf(rover.global_position.x - ctx.charge_start_pos.x)
		var outcome := "STALL" if rover.state == PatrolRover.State.STALL else \
				("RECOVERY(brake, no stall)" if rover.state == PatrolRover.State.RECOVERY else \
				str(PatrolRover.State.find_key(rover.state)))
		ctx.charge_log.append({"index": ctx.charge_index, "start_x": ctx.charge_start_pos.x,
				"outcome": outcome, "traveled": traveled})
	ctx.prev_state = rover.state


func _steer(hero: Hero, target_x: float, tol: float) -> bool:
	var dx := target_x - hero.global_position.x
	if absf(dx) <= tol:
		release("move_left"); release("move_right")
		return true
	if dx > 0.0:
		release("move_left"); press("move_right")
	else:
		release("move_right"); press("move_left")
	return false


func _print_summary() -> void:
	print("[test_rover_real_level] ==== SIX-ROVER SUMMARY ====")
	for r in _reports:
		print("[test_rover_real_level]   %s: killable=%s stalls_on_natural_approach=%s stall_window=%.2fs shots=%d would_take_damage=%s" % [
				r.id, r.killable, r.stalls_on_natural_approach, r.stall_window_s, r.shots_needed, r.would_take_damage])
