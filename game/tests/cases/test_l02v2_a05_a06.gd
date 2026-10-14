extends TestCase
## Level 2 v2 (C62): A05 The Lattice and A06 Showroom and freight lift, rebuilt to
## prototype-plans/level-02-alignment/area-blueprints-v2.md.
##   1. Each area alone (tests/area_harness.gd, invulnerable RouteBot): A05 crosses the atrium, the
##      tiers (the glass lift), the projector ring and takes the keycard at the console; A06 crosses
##      the loading entry, the showroom, the balcony and the stage and finishes at the freight lift
##      after its 45 s hold-out; the dock branch (OPT01) opens the 20-chip cache.
##   2. Layout: widths, seams at y 0 with 4 H of flat floor, everything standing on solid floor,
##      every catwalk deck supported (Block.lab_structure()), no raised slab floating, every flight
##      meeting a floor and a landing, no enemy within 500 px of a checkpoint, ids, chips, the
##      console, the hologram over its slot, breakables, the plinths' chain and backstops, the vent
##      wave, the hold-out's doors, the dock cache.
##   3. The P23 budget in every 1,280 px window across both areas: at most 2 shooters and 3
##      attackers, counting every enemy where it stands and over its patrol span; enemies that can
##      never be alive together (a release prop's chain, the hold-out's waves) count as one phase.
##   4. The glass lift never crushes; the vent wave fires in order; the hold-out's waves open one
##      after the other through their doors.
##   5. The real level (LevelDirector + LevelDefs L02): the areas sit end to end and join at y 0.
##   6. Fair fights: each mandatory encounter played with the base Scrapjack by a scripted player
##      who reacts to tells (like test_l02_encounters.gd, plus the Patrol Rover's stall and the
##      waves): every enemy down, Dave alive, at most half his health lost, inside the budget, the
##      screen caps and the gun gates held throughout.
## Run: NOIMPORT=1 tools/test.sh l02v2_a05. Debug: L02V2_ONLY="<fight label prefix>" runs only those
## fights; L02V2_DEBUG=1 prints the fight state every 0.5 s.

const A05 := "res://scenes/levels/l02/a05_lattice.tscn"
const A06 := "res://scenes/levels/l02/a06_demo_floor.tscn"
const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const CAMERA_SCENE := "res://scenes/actors/game_camera.tscn"
const Arch := preload("res://scripts/world/lab_structure.gd")
const ReleasePod := preload("res://scripts/objects/release_pod.gd")
const StairsScript := preload("res://scripts/world/stairs.gd")
const HazardVentScript := preload("res://scripts/objects/hazard_vent.gd")

const H := 96.0
const WINDOW := 1280.0
const SAFE_RADIUS := 500.0
const PROMPT_SPACING := 288.0
const SHOOT_RANGE := 600.0
const JUMP_HOLD_TICKS := 27
const ROUND_REACT_S := 0.2
const HALF_W := 20.0
const DODGE_DRONE := 1.7 * H
const IDLE_FIRE_S := 4.0
const GUARD_TOO_CLOSE := 140.0
const ROVER_JUMP_DX := 190.0

const ENEMY_ID := "^L02-E(19|2[0-7])-(SE01|LK01|M01|SE02|K01|M02)-\\d\\d$"
const ENTITY_ID := "^L02(-[A-Z0-9]+)+$"

## Group node -> [guards, staffers, rovers, gunners, drones, hounds].
const GROUPS := {
	A05: {
		"EncounterGroup_E19": ["L02-E19", [2, 0, 0, 0, 0, 1]],
		"EncounterGroup_E20": ["L02-E20", [0, 0, 0, 1, 1, 0]],
		"EncounterGroup_E21": ["L02-E21", [0, 2, 0, 0, 0, 0]],
		"EncounterGroup_E22": ["L02-E22", [0, 0, 0, 2, 0, 0]],
	},
	A06: {
		"EncounterGroup_E23": ["L02-E23", [1, 1, 0, 0, 0, 0]],
		"EncounterGroup_E24P1": ["L02-E24-P1", [0, 0, 1, 0, 0, 0]],
		"EncounterGroup_E24P2": ["L02-E24-P2", [0, 0, 1, 0, 0, 0]],
		"EncounterGroup_E24": ["L02-E24", [0, 0, 0, 1, 0, 0]],
		"EncounterGroup_E25": ["L02-E25", [1, 0, 0, 0, 0, 0]],
		"EncounterGroup_E25C1": ["L02-E25-C1", [0, 0, 0, 0, 1, 0]],
		"EncounterGroup_E25C2": ["L02-E25-C2", [0, 0, 0, 0, 1, 0]],
		"EncounterGroup_E26W1": ["L02-E26-W1", [1, 0, 0, 0, 0, 1]],
		"EncounterGroup_E26W2": ["L02-E26-W2", [2, 0, 0, 0, 0, 0]],
		"EncounterGroup_E26W3": ["L02-E26-W3", [0, 0, 0, 1, 1, 0]],
		"EncounterGroup_E27": ["L02-E27", [0, 0, 1, 0, 0, 0]],
	},
}

const E23_IDS := ["L02-E23-SE01-01", "L02-E23-LK01-01"]
const S6_IDS := ["L02-E24-M01-01", "L02-E24-M01-02"]
const E24_IDS := ["L02-E24-SE02-01"]
const E25_IDS := ["L02-E25-SE01-01", "L02-E25-M02-01", "L02-E25-M02-02"]

## The fair fights (area-local numbers). `groups`: every enemy in them must go down. `start`: a
## Route point (or `start_at`) before the encounter's trigger; `route`: Route points walked onto
## the fight floor. `floor`: [min x, max x, floor y] Dave fights on. `rovers`: a Patrol Rover's
## entity id -> where Dave stands (in front of its backstop) to let it charge into it.
const FIGHTS := [
	{"label": "E19 Night Guard, handler and Hound on the atrium floor (A05)", "scene": A05,
		"groups": ["EncounterGroup_E19"], "start_at": [96.0, 0.0], "route": [],
		"floor": [20.0, 1270.0, 0.0], "advance_x": 380.0, "standoff": 200.0},
	{"label": "E20 Sidearm Guard on the step and Security Drone over tier 2, then E21's Staffers (A05)", "scene": A05,
		"groups": ["EncounterGroup_E20", "EncounterGroup_E21"], "start": "R07_OffLift", "route": [],
		"floor": [2040.0, 2690.0, -320.0], "advance_x": 2540.0, "drone_hold_x": 2220.0, "standoff": 260.0},
	{"label": "E22 two Sidearm Guards on the projector ring (A05)", "scene": A05,
		"groups": ["EncounterGroup_E22"], "start": "R12_ThroughPurge", "route": [],
		"floor": [3770.0, 4590.0, -480.0], "advance_x": 3910.0, "standoff": 150.0, "no_west_of": 3760.0},
	{"label": "E23 Night Guard and Staffer at the conveyors (A06)", "scene": A06,
		"groups": ["EncounterGroup_E23"], "start_at": [96.0, 0.0], "route": [],
		"floor": [20.0, 1240.0, 0.0], "advance_x": 300.0, "standoff": 260.0},
	{"label": "E24 S6 the exhibits wake: two Patrol Rovers off their plinths (A06)", "scene": A06,
		"groups": ["EncounterGroup_E24P1", "EncounterGroup_E24P2"], "pre": E23_IDS, "start": "R02_JumpDockGap",
		"route": ["R02_JumpDockGap"], "floor": [1470.0, 3080.0, 0.0], "advance_x": 2330.0, "standoff": 260.0,
		"rovers": {"L02-E24-M01-01": 2328.0, "L02-E24-M01-02": 2808.0}, "budget": 50.0},
	{"label": "E24 Sidearm Guard on the showroom balcony (A06)", "scene": A06,
		"groups": ["EncounterGroup_E24"], "pre": E23_IDS + S6_IDS, "start": "R05_ToPedestalC",
		"route": ["R06_JumpPedestalC", "R07_UpBalcony"], "floor": [3480.0, 4290.0, -240.0], "advance_x": 3600.0, "standoff": 300.0},
	{"label": "E25 two Security Drones from the demo cases and a Night Guard on the stage (A06)", "scene": A06,
		"groups": ["EncounterGroup_E25", "EncounterGroup_E25C1", "EncounterGroup_E25C2"],
		"pre": E23_IDS + S6_IDS + E24_IDS, "start": "R09_JumpBalconyCover", "route": ["R09_JumpBalconyCover", "R10_DownToStage"],
		"floor": [4330.0, 5090.0, -100.0], "advance_x": 4420.0, "standoff": 260.0, "budget": 50.0},
	{"label": "E26 S7 the freight-lift hold-out: three waves through the service doors (A06)", "scene": A06,
		"groups": ["EncounterGroup_E26W1", "EncounterGroup_E26W2", "EncounterGroup_E26W3"],
		"pre": E23_IDS + S6_IDS + E24_IDS + E25_IDS, "card": true, "start": "R11_ToCP05",
		"route": ["R13_ToCrateA", "R14_JumpCrateA", "R15_ToCrateB", "R16_JumpCrateB", "R17_ToFreightLift"],
		"floor": [5300.0, 7240.0, 0.0], "advance_x": 7000.0, "standoff": 280.0, "holdout": true, "budget": 90.0},
]

var _reports: Array = []
var _debug: bool = OS.get_environment("L02V2_DEBUG") != ""
var _only: String = OS.get_environment("L02V2_ONLY")


func run() -> void:
	# The game's 16:9 view (the headless window is square, which would loosen every camera gate).
	var win := get_window()
	var old_size := win.size
	win.size = Vector2i(1280, 720)
	await physics_frames(2)
	await _run_all()
	win.size = old_size


func _run_all() -> void:
	if _only != "":
		for cfg in FIGHTS:
			if String(cfg.label).begins_with(_only):
				await _fight(cfg)
		for r in _reports:
			print("[test_l02v2_a05_a06]   %s" % r)
		return
	await _test_route_alone()
	await _test_layout(A05)
	await _test_layout(A06)
	await _test_budget()
	await _test_glass_lift()
	await _test_vent_wave()
	await _test_holdout_waves()
	await _test_real_level()
	for cfg in FIGHTS:
		await _fight(cfg)
	print("[test_l02v2_a05_a06] ==== FIGHTS ====")
	for r in _reports:
		print("[test_l02v2_a05_a06]   %s" % r)
	CheckpointService.clear()
	Session.new_run()


# --- helpers -------------------------------------------------------------------------------

func _area(path: String) -> AreaRoot:
	var a: AreaRoot = load(path).instantiate()
	add_child(a)
	await physics_frames(3)
	return a


func _free(n: Node) -> void:
	if is_instance_valid(n):
		n.queue_free()
	await physics_frames(2)


func _all(node: Node, pred: Callable, out: Array = []) -> Array:
	if pred.call(node):
		out.append(node)
	for c in node.get_children():
		_all(c, pred, out)
	return out


func _ray(n: Node2D, from: Vector2, to: Vector2, exclude: Array = []) -> Dictionary:
	var q := PhysicsRayQueryParameters2D.create(from, to)
	q.collision_mask = 1
	q.exclude = exclude
	return n.get_world_2d().direct_space_state.intersect_ray(q)


## Solid floor right under global `p` (within `below` px).
func _floor_under(n: Node2D, p: Vector2, below: float = 10.0) -> bool:
	return not _ray(n, p + Vector2(0, -6), p + Vector2(0, below)).is_empty()


func _enemies(n: Node) -> Array:
	return _all(n, func(c): return c.is_in_group("enemy"))


func _kind_index(e: Node) -> int:
	if e is Hound:
		return 5
	if e is Drone:
		return 4
	if e is Gunner:
		return 3
	if e is PatrolRover:
		return 2
	if e is Brawler:
		return 1 if String(e.entity_id).contains("-LK01-") else 0
	return -1


func _is_shooter(e: Node) -> bool:
	return e is Gunner or e is Drone


## [lo, hi] of where an enemy can be (global x): its spot and its patrol span.
func _span(e: Node2D, area: Node2D) -> Vector2:
	var lo: float = e.global_position.x
	var hi: float = lo
	for pair in [["patrol_min_x", "patrol_max_x"]]:
		var a = e.get(pair[0])
		var b = e.get(pair[1])
		if a != null and b != null and is_finite(float(a)) and is_finite(float(b)):
			lo = minf(lo, area.to_global(Vector2(float(a), 0)).x)
			hi = maxf(hi, area.to_global(Vector2(float(b), 0)).x)
	return Vector2(lo, hi)


# --- 1. the route bot, each area alone --------------------------------------------------------

func _test_route_alone() -> void:
	var harness = load("res://tests/area_harness.gd").new()
	CheckpointService.clear()
	Session.new_run("L02")
	var r: Dictionary = await harness.run_area(self, A05, [], 150.0)
	check(r.reached_exit, "A05 alone: the route bot crosses the Lattice to its exit seam (failure=%s, at %s, point %d/%d)" % [
			r.failure, str(r.hero_final_position), r.point_index_reached, r.points_total])
	check(Session.has_keycard("L02-KC01"), "A05 alone: the bot took the keycard at the alignment console")
	check_eq(Session.state.get("checkpoint_id", ""), "CP04", "A05 alone: CP04 committed at the console level")
	print("[test_l02v2_a05_a06] A05 route bot: %.1f s" % r.seconds)

	CheckpointService.clear()
	Session.new_run("L02")
	Session.take_keycard("L02-KC01", "L02-KC01-P")
	r = await harness.run_area(self, A06, [], 200.0)
	check(r.reached_exit, "A06 alone (card held): the route bot finishes at the freight lift after the hold-out (failure=%s, at %s, point %d/%d)" % [
			r.failure, str(r.hero_final_position), r.point_index_reached, r.points_total])
	check(r.seconds >= 45.0, "A06 alone: the run waited out the 45 s override (%.1f s)" % r.seconds)
	print("[test_l02v2_a05_a06] A06 route bot: %.1f s" % r.seconds)

	CheckpointService.clear()
	Session.new_run("L02")
	Session.take_keycard("L02-KC01", "L02-KC01-P")
	r = await harness.run_area(self, A06, ["OPT01"], 240.0)
	check(r.reached_exit, "A06 + OPT01: the bot visits the loading dock and still finishes (failure=%s, at %s)" % [
			r.failure, str(r.hero_final_position)])
	check(Session.is_collected("L02-OPT01-CACHE01"), "A06 + OPT01: the dock's 20-chip cache is opened")
	CheckpointService.clear()
	Session.new_run("L02")


# --- 2. layout --------------------------------------------------------------------------------

func _test_layout(path: String) -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var area := await _area(path)
	var tag := "A05" if path == A05 else "A06"
	var width := 6000.0 if path == A05 else 7400.0
	check_eq(area.width, width, "%s: width" % tag)
	check(area.indoors and area.interior_look == "lab", "%s: indoors, painted lab look" % tag)
	if path == A05:
		check(area.camera_top <= -1000.0, "A05: tall camera (top %.0f)" % area.camera_top)
	# Seams: 4 H of flat floor at y 0 at both ends.
	for x0 in [0.0, width - 384.0]:
		var ok := true
		var x: float = x0 + 8.0
		while x <= x0 + 376.0:
			if not area.has_floor_at(x) or not _ray(area, area.to_global(Vector2(x, -H + 4)), area.to_global(Vector2(x, -10))).is_empty():
				ok = false
			x += 16.0
		check(ok, "%s: 4 H of clear flat floor at y 0 at the %s seam (x %.0f..%.0f)" % [tag, "entry" if x0 == 0.0 else "exit", x0, x0 + 384.0])
	var spawn := area.get_marker("Spawn_CP00")
	check(spawn != null and absf(spawn.position.y) < 8.0, "%s: Spawn_CP00 on the entry floor" % tag)

	# Blocks: decks supported, nothing floating.
	var blocks := _all(area.get_node("Geometry"), func(n): return n is Block)
	var floating: Array = []
	var unsupported: Array = []
	var decks := 0
	for b in blocks:
		var role: String = b.lab_structure()
		if b.kind == Block.Kind.ROOF:
			continue
		if role == "deck":
			decks += 1
			if int(Arch.deck_supports(b)["mode"]) == Arch.S_NONE:
				unsupported.append(String(b.name))
			continue
		var bottom: float = b.position.y + b.size.y
		if bottom >= -0.5:
			continue
		# Rests on something: a solid right under its bottom edge (at a quarter and three quarters).
		var rests := false
		for f in [0.25, 0.5, 0.75]:
			var gx: float = b.global_position.x + b.size.x * f
			var gy: float = b.global_position.y + b.size.y
			if not _ray(b, Vector2(gx, gy - 2.0), Vector2(gx, gy + 6.0), [b.get_rid()]).is_empty():
				rests = true
		if not rests:
			floating.append(String(b.name))
	check(decks >= (3 if path == A05 else 2), "%s: catwalk decks in use (%d)" % [tag, decks])
	check(unsupported.is_empty(), "%s: every catwalk deck is hung from a ceiling or stands on columns (%s)" % [tag, unsupported])
	check(floating.is_empty(), "%s: no raised slab floats; every box rests on a floor or deck (%s)" % [tag, floating])
	# Stairs: the low end on a floor, the high end at a landing.
	var flights := _all(area.get_node("Geometry"), func(n): return n.get_script() == StairsScript)
	var bad_flights: Array = []
	for s in flights:
		var high_x: float = s.global_position.x + (-6.0 if s.direction < 0 else s.run + 6.0)
		var low_ok := _floor_under(s, Vector2(s.global_position.x + (s.run + 6.0 if s.direction < 0 else -6.0), s.global_position.y), 12.0)
		var high_ok := _floor_under(s, Vector2(high_x, s.global_position.y - s.rise), 10.0)
		if not low_ok or not high_ok:
			bad_flights.append("%s (low %s, high %s)" % [s.name, low_ok, high_ok])
	check(flights.size() >= 3, "%s: stair flights instead of floating steps (%d)" % [tag, flights.size()])
	check(bad_flights.is_empty(), "%s: every flight meets a floor at its foot and a landing at its head (%s)" % [tag, bad_flights])

	# Everything standing on solid floor.
	var not_standing: Array = []
	var stand_nodes: Array = []
	for e in _enemies(area.get_node("Encounters")):
		if e is Drone:
			continue
		stand_nodes.append(e)
	for n in area.get_node("Entities").get_children():
		if n.has_method("interact") or n is ExitWicket or n.get_script() == ReleasePod or n.has_method("break_now") \
				or String(n.name).begins_with("AmmoCartridge"):
			if n.has_meta("mount"):
				continue
			stand_nodes.append(n)
	for n in area.get_node("Scenery").get_children():
		if n is Scenery and (n.kind == Scenery.Kind.LAMP or n.kind == Scenery.Kind.LAB_PROP):
			stand_nodes.append(n)
	for n in stand_nodes:
		if n.has_meta("mount"):
			continue
		if not _floor_under(n, n.global_position, 12.0):
			not_standing.append("%s at %s" % [n.name, str(area.to_local(n.global_position).round())])
	check(not_standing.is_empty(), "%s: every enemy, station, console, prop, breakable, door and lamp stands on solid floor (%s)" % [tag, not_standing])
	# Drones hover low enough over the floor they are fought from to tell inside the camera.
	for e in _enemies(area.get_node("Encounters")):
		if e is Drone:
			var hit := _ray(e, e.global_position, e.global_position + Vector2(0, 400))
			var over: float = (hit.position.y - e.global_position.y) if not hit.is_empty() else INF
			check(over <= 190.0, "%s: %s hovers %.0f px over its floor (<= 190)" % [tag, e.entity_id, over])

	# Groups, enemies, ids.
	var exp: Dictionary = GROUPS[path]
	var enc := area.get_node("Encounters")
	var re_enemy := RegEx.create_from_string(ENEMY_ID)
	var seen_ids := {}
	for gname in exp:
		var g: EncounterGroup = enc.get_node_or_null(String(gname))
		check(g != null, "%s: %s exists" % [tag, gname])
		if g == null:
			continue
		check_eq(g.group_id, exp[gname][0], "%s: %s group id" % [tag, gname])
		var counts := [0, 0, 0, 0, 0, 0]
		for e in _enemies(g):
			var k := _kind_index(e)
			if k >= 0:
				counts[k] += 1
			check(re_enemy.search(e.entity_id) != null, "%s: enemy id %s follows L02-Exx-<type>-nn" % [tag, e.entity_id])
			check(not seen_ids.has(e.entity_id), "%s: enemy id %s is unique" % [tag, e.entity_id])
			seen_ids[e.entity_id] = true
			var num := String(e.entity_id).substr(4, 3)
			check(String(g.group_id).begins_with("L02-" + num), "%s: %s belongs to its encounter %s" % [tag, e.entity_id, g.group_id])
		check(counts == exp[gname][1], "%s: %s fields %s (guards, staffers, rovers, gunners, drones, hounds; got %s)" % [tag, gname, str(exp[gname][1]), str(counts)])
		check(g.max_attackers <= 2, "%s: %s lets at most 2 attack at once" % [tag, gname])
		var zone := g.get_node_or_null("ApproachZone")
		check(zone != null or g.wait_for_trigger, "%s: %s wakes on an ApproachZone or a trigger" % [tag, gname])
	check_eq(enc.get_child_count(), exp.size(), "%s: no other encounter groups" % tag)
	# Patrols off stair flights: no enemy spot or patrol span over a flight.
	for e in _enemies(enc):
		if e is Drone:
			continue
		var sp := _span(e, area)
		for s in flights:
			var fl: float = s.global_position.x
			var fh: float = fl + s.run
			var on_y := absf(e.global_position.y - s.global_position.y) < 4.0 or absf(e.global_position.y - (s.global_position.y - s.rise)) < 4.0
			if on_y and sp.y > fl + 4.0 and sp.x < fh - 4.0:
				check(false, "%s: %s's patrol (%.0f..%.0f) stays off the flight %s" % [tag, e.entity_id, sp.x, sp.y, s.name])

	# Entity ids, chips.
	var re_ent := RegEx.create_from_string(ENTITY_ID)
	var ids := area.get_entity_ids()
	var uniq := {}
	for id in ids:
		check(re_ent.search(id) != null, "%s: entity id %s matches the L02- pattern" % [tag, id])
		check(not uniq.has(id), "%s: entity id %s is unique" % [tag, id])
		uniq[id] = true
	var chips := _all(area.get_node("Entities"), func(n): return n is Chip)
	var re_chip := RegEx.create_from_string("^L02-%s-G\\d{3}$" % tag)
	var chip_ids := {}
	for c in chips:
		check(re_chip.search(c.entity_id) != null, "%s: chip id %s matches L02-%s-Gnnn" % [tag, c.entity_id, tag])
		chip_ids[c.entity_id] = true
	check_eq(chips.size(), 10 if path == A05 else 12, "%s: chips" % tag)
	check_eq(chip_ids.size(), chips.size(), "%s: chip ids unique" % tag)

	# Checkpoints: no enemy within 500 px; prompts 3 H apart.
	var cp_x: Array = []
	for m in area.get_node("Markers").get_children():
		if String(m.name).begins_with("Respawn_CP"):
			cp_x.append(m.global_position.x)
	for n in area.get_node("Entities").get_children():
		if n is RecoveryStation:
			cp_x.append(n.global_position.x)
	check(cp_x.size() >= 2, "%s: a recovery station and its respawn marker" % tag)
	for x in cp_x:
		for e in _enemies(enc):
			var sp := _span(e, area)
			var d: float = 0.0 if (x >= sp.x and x <= sp.y) else minf(absf(x - sp.x), absf(x - sp.y))
			check(d >= SAFE_RADIUS, "%s: %s is %.0f px from the checkpoint at x %.0f (>= 500)" % [tag, e.entity_id, d, area.to_local(Vector2(x, 0)).x])
	var prompts := _all(area.get_node("Entities"), func(n): return n is Interactable)
	for i in prompts.size():
		for j in range(i + 1, prompts.size()):
			var a: Node2D = prompts[i]
			var b: Node2D = prompts[j]
			if absf(a.global_position.y - b.global_position.y) < 200.0:
				check(absf(a.global_position.x - b.global_position.x) >= PROMPT_SPACING,
						"%s: prompts %s and %s stand 3 H apart" % [tag, a.name, b.name])

	# Lamps near every landing; prop density.
	var lamps := _all(area.get_node("Scenery"), func(n): return n is Scenery and n.kind == Scenery.Kind.LAMP)
	var props := _all(area.get_node("Scenery"), func(n): return n is Scenery and n.kind == Scenery.Kind.LAB_PROP)
	var gaps: Array = []
	var xs: Array = []
	for p in props:
		xs.append(area.to_local(p.global_position).x)
	for br in _all(area.get_node("Entities"), func(n): return n.has_method("break_now") or n.get_script() == ReleasePod \
			or n is Interactable or n is ExitWicket):
		xs.append(area.to_local(br.global_position).x)
	# A stair flight is a set piece of its own (its stringer, treads and handrail).
	for s in flights:
		for f in [0.0, 0.5, 1.0]:
			xs.append(area.to_local(s.global_position).x + s.run * f)
	xs.sort()
	for i in range(1, xs.size()):
		if xs[i] - xs[i - 1] > 420.0:
			gaps.append("%.0f..%.0f" % [xs[i - 1], xs[i]])
	check(gaps.is_empty(), "%s: a prop group every 300-400 px (gaps over 420: %s)" % [tag, gaps])
	check(lamps.size() >= 14, "%s: lamps throughout (%d)" % [tag, lamps.size()])
	for d in _all(area.get_node("Geometry"), func(n): return n is Block and n.lab_structure() == "deck"):
		var near := false
		for l in lamps:
			if absf(l.global_position.y - d.global_position.y) < 8.0 and l.global_position.x >= d.global_position.x - 40.0 \
					and l.global_position.x <= d.global_position.x + d.size.x + 40.0:
				near = true
		if d.size.x >= 200.0:
			check(near, "%s: a lamp on the landing %s" % [tag, d.name])
	var seams := _all(area.get_node("Scenery"), func(n): return n.has_method("frame_xs"))
	check(seams.size() >= 4, "%s: rooms joined by room seams (%d)" % [tag, seams.size()])
	var breakables := _all(area.get_node("Entities"), func(n): return n.has_method("break_now"))
	check(breakables.size() >= (7 if path == A05 else 9), "%s: breakables (%d)" % [tag, breakables.size()])
	for br in breakables:
		if br.entity_id != "":
			check(not br.contents.is_empty(), "%s: the recorded breakable %s holds a reward" % [tag, br.entity_id])
	print("[test_l02v2_a05_a06] %s: %d decks, %d flights, %d lamps, %d props, %d breakables, %d chips" % [
			tag, decks, flights.size(), lamps.size(), props.size(), breakables.size(), chips.size()])

	if path == A05:
		_layout_a05(area)
	else:
		_layout_a06(area)
	await _free(area)


func _layout_a05(area: AreaRoot) -> void:
	var console := area.get_node_or_null("Entities/AlignmentConsole")
	check(console != null, "A05: Entities/AlignmentConsole")
	if console:
		check_eq(console.keycard_id, "L02-KC01", "A05: the console issues L02-KC01")
		check_eq(console.entity_id, "L02-KC01-P", "A05: the console's pickup id")
		check(absf(console.position.y + 480.0) < 1.0, "A05: the console is on the console level (y -480)")
		var used := false
		for p in area.get_route_points():
			if p.action == RoutePoint.Action.INTERACT and absf(p.global_position.x - console.global_position.x) <= 16.0:
				used = true
		check(used, "A05: the route bot interacts with the console")
	var holo: Node2D = area.get_node_or_null("Scenery/Hologram")
	var slot: Node2D = area.get_node_or_null("Entities/Slot_Hologram")
	check(holo != null and slot != null, "A05: the hologram and its slot")
	if holo and slot:
		check_eq(holo.position.x, slot.position.x, "A05: the hologram stands at its slot's x")
		check(absf(holo.position.y - float(holo.height) * 0.5 + 500.0) < 2.0, "A05: the hologram is centred at y -500")
	var cp := area.get_marker("Respawn_CP04")
	var st := area.get_node_or_null("Entities/RecoveryStation_CP04")
	check(cp != null and st != null and st.checkpoint_id == "CP04", "A05: Respawn_CP04 and the CP04 station")
	if cp and console:
		check(absf(cp.position.y + 484.0) < 2.0, "A05: CP04 on the console level")
	var lift: MovingPlatform = area.get_node_or_null("Geometry/GlassLift")
	check(lift != null and absf(lift.point_a.y - lift.point_b.y) >= 150.0, "A05: the glass lift travels between two tiers")
	var door := area.get_node_or_null("Entities/StaffDoor_E21")
	check(door != null and door.variant == ReleasePod.Kind.DOOR and door.get_node_or_null(door.after) == area.get_node("Encounters/EncounterGroup_E20"),
			"A05: E21's staff door opens after E20")
	var seq := area.get_node_or_null("Entities/ProjectorPurge")
	check(seq != null, "A05: the projector purge's sequencer")
	if seq:
		var vents: Array = seq.ordered_vents()
		check_eq(vents.size(), 6, "A05: six vents in the wave")
		for v in vents:
			check(v.kind == HazardVentScript.Kind.STEAM and is_equal_approx(v.active_time, 0.9), "A05: %s is steam, active 0.9 s" % v.name)
			check(absf(v.position.y + 480.0) < 1.0, "A05: %s is on the ring" % v.name)
			for m in [area.get_marker("Respawn_CP04")]:
				check(absf(m.global_position.x - v.global_position.x) > 300.0, "A05: %s is far from a checkpoint" % v.name)


func _layout_a06(area: AreaRoot) -> void:
	var enc := area.get_node("Encounters")
	var ents := area.get_node("Entities")
	# S6: plinth A after E23, plinth B after plinth A; each rover's charge reaches its backstop.
	var pa := ents.get_node_or_null("PlinthA")
	var pb := ents.get_node_or_null("PlinthB")
	check(pa != null and pb != null and pa.variant == ReleasePod.Kind.PLINTH and pb.variant == ReleasePod.Kind.PLINTH,
			"A06: the two S6 plinths")
	if pa and pb:
		check(pa.get_node_or_null(pa.after) == enc.get_node("EncounterGroup_E23"), "A06: plinth A wakes after E23")
		check(pb.get_node_or_null(pb.after) == pa, "A06: plinth B wakes after plinth A's rover is down")
		check(pa.get_node_or_null(pa.group) == enc.get_node("EncounterGroup_E24P1") and pb.get_node_or_null(pb.group) == enc.get_node("EncounterGroup_E24P2"),
				"A06: each plinth holds its rover's group")
		for spec in [["EncounterGroup_E24P1", "PedestalB"], ["EncounterGroup_E24P2", "PedestalC"]]:
			var r: PatrolRover = _enemies(enc.get_node(spec[0]))[0]
			var ped: Block = area.get_node("Geometry/" + spec[1])
			var run: float = ped.global_position.x - (r.global_position.x + PatrolRover.HALF_WIDTH)
			check(run > 0.0 and run <= r.tuning.charge_max_distance() - 24.0,
					"A06: %s's charge reaches %s (%.0f of %.0f px)" % [r.entity_id, spec[1], run, r.tuning.charge_max_distance()])
			check(ped.kind == Block.Kind.BACKSTOP and ped.size.y >= 72.0, "A06: %s is a backstop" % spec[1])
	# E25's cases open after E24.
	for n in ["DemoCaseA", "DemoCaseB"]:
		var c := ents.get_node_or_null(n)
		check(c != null and c.get_node_or_null(c.after) == enc.get_node("EncounterGroup_E24"), "A06: %s opens after E24" % n)
	# The hold-out.
	var lift: ExitWicket = ents.get_node_or_null("FreightLift")
	check(lift != null, "A06: Entities/FreightLift")
	if lift:
		check_eq(lift.required_keycard, "L02-KC01", "A06: the freight lift wants L02-KC01")
		check_eq(lift.override_time, 45.0, "A06: the lift takes 45 s (the hold-out)")
		check_eq(lift.wave_groups.size(), 3, "A06: three waves")
		var want := ["EncounterGroup_E26W1", "EncounterGroup_E26W2", "EncounterGroup_E26W3"]
		for i in lift.wave_groups.size():
			var d := lift.get_node_or_null(lift.wave_groups[i])
			check(d != null and d.get_script() == ReleasePod and d.variant == ReleasePod.Kind.DOOR,
					"A06: wave %d comes through a service door" % (i + 1))
			if d:
				check(d.get_node_or_null(d.group) == enc.get_node(want[i]), "A06: wave %d's door holds %s" % [i + 1, want[i]])
				check(d.trigger_x == INF and d.after.is_empty(), "A06: wave %d's door opens only on the lift's call" % (i + 1))
		check(lift.position.x >= area.width - 384.0, "A06: the lift stands on the exit seam's floor")
	# The dock cache.
	var cache := ents.get_node_or_null("ChipCache_OPT01")
	check(cache != null and cache.entity_id == "L02-OPT01-CACHE01" and cache.value == 20, "A06: the dock's 20-chip cache")
	if cache:
		check(absf(cache.position.y - 240.0) < 1.0, "A06: the cache is down in the dock")
	var conv := _all(area.get_node("Geometry"), func(n): return n.has_method("belt_velocity"))
	check(conv.size() >= 2, "A06: H3 conveyors in the loading entry")
	for c in conv:
		check(c.speed >= 90.0 and c.speed <= 120.0, "A06: %s runs at %.0f px/s (90-120)" % [c.name, c.speed])
	var cp := area.get_marker("Respawn_CP05")
	check(cp != null and area.get_node_or_null("Entities/RecoveryStation_CP05") != null, "A06: Respawn_CP05 and its station")


# --- 3. the P23 budget ------------------------------------------------------------------------

func _test_budget() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var root := Node2D.new()
	add_child(root)
	var a5: AreaRoot = load(A05).instantiate()
	var a6: AreaRoot = load(A06).instantiate()
	root.add_child(a5)
	a6.position.x = a5.width
	root.add_child(a6)
	await physics_frames(3)
	# Phases: group -> [chain key, step]. A release prop's group follows its `after`; the
	# hold-out's waves follow each other.
	var phase := {}
	for area in [a5, a6]:
		for g in area.get_node("Encounters").get_children():
			phase[g] = [g, 0]
		var props := _all(area.get_node("Entities"), func(n): return n.get_script() == ReleasePod)
		for _pass in 4:
			for p in props:
				var g = p.get_node_or_null(p.group)
				var after = p.get_node_or_null(p.after) if not p.after.is_empty() else null
				if after != null and after.get_script() == ReleasePod:
					after = after.get_node_or_null(after.group)
				if g != null and after != null and phase.has(after):
					phase[g] = [phase[after][0], int(phase[after][1]) + 1]
		for w in _all(area.get_node("Entities"), func(n): return n is ExitWicket):
			for i in w.wave_groups.size():
				var d = w.get_node_or_null(w.wave_groups[i])
				var g = d.get_node_or_null(d.group) if d and d.get_script() == ReleasePod else d
				if g:
					phase[g] = [w, i]
	var spans: Array = []   # [lo, hi, shooter, chain, step, id]
	for area in [a5, a6]:
		for g in area.get_node("Encounters").get_children():
			for e in _enemies(g):
				var sp := _span(e, area)
				spans.append([sp.x, sp.y, _is_shooter(e), phase[g][0], phase[g][1], e.entity_id])
	check_eq(spans.size(), 9 + 14 + 1, "budget: A05 places 9 enemies, A06 14 + the dock's optional rover")
	var worst_s := 0
	var worst_a := 0
	var at_s := 0.0
	var at_a := 0.0
	var x := -WINDOW
	var end: float = a5.width + a6.width
	while x <= end:
		var by_chain := {}   # chain -> {step: [attackers, shooters]}
		for sp in spans:
			if sp[1] >= x and sp[0] <= x + WINDOW:
				var steps: Dictionary = by_chain.get(sp[3], {})
				var c: Array = steps.get(sp[4], [0, 0])
				c[0] += 1
				if sp[2]:
					c[1] += 1
				steps[sp[4]] = c
				by_chain[sp[3]] = steps
		var att := 0
		var sho := 0
		for ch in by_chain:
			var ma := 0
			var ms := 0
			for st in by_chain[ch]:
				ma = maxi(ma, by_chain[ch][st][0])
				ms = maxi(ms, by_chain[ch][st][1])
			att += ma
			sho += ms
		if att > worst_a:
			worst_a = att
			at_a = x
		if sho > worst_s:
			worst_s = sho
			at_s = x
		x += 16.0
	check(worst_s <= 2, "budget: at most 2 shooters in any 1,280 px window across A05-A06 (max %d near x %.0f)" % [worst_s, at_s])
	check(worst_a <= 3, "budget: at most 3 attackers in any 1,280 px window across A05-A06 (max %d near x %.0f)" % [worst_a, at_a])
	print("[test_l02v2_a05_a06] budget: max %d shooters, %d attackers per 1,280 px window" % [worst_s, worst_a])
	await _free(root)


# --- 4. the glass lift, the vent wave, the hold-out's waves -----------------------------------

func _world(path: String, at: Vector2, invulnerable: bool = true) -> Dictionary:
	var area := await _area(path)
	var hero: Hero = load(HERO_SCENE).instantiate()
	hero.global_position = area.to_global(at)
	hero.debug_invulnerable = invulnerable
	add_child(hero)
	var cam: GameCamera = load(CAMERA_SCENE).instantiate()
	cam.target = hero
	add_child(cam)
	cam.world_limits = area.get_camera_limits()
	await physics_frames(3)
	cam.reset_position()
	await physics_frames(2)
	return {"area": area, "hero": hero, "camera": cam}


func _free_world(w: Dictionary) -> void:
	release_all()
	for k in ["camera", "hero", "area"]:
		if is_instance_valid(w[k]):
			w[k].queue_free()
	await physics_frames(3)


func _test_glass_lift() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var w := await _world(A05, Vector2(1860, -164))
	var area: AreaRoot = w.area
	var hero: Hero = w.hero
	var lift: MovingPlatform = area.get_node("Geometry/GlassLift")
	var half_t: float = lift.thickness * 0.5
	var low_bottom: float = maxf(lift.point_a.y, lift.point_b.y) + half_t
	var high_top: float = minf(lift.point_a.y, lift.point_b.y) - half_t
	check(-low_bottom >= H + 24.0, "lift: at its lowest the underside is %.0f px over the atrium floor (Dave stands under it)" % -low_bottom)
	var x0: float = lift.point_a.x - lift.width * 0.5 + 4.0
	var clear_above := _ray(area, area.to_global(Vector2(lift.point_a.x, high_top - 2.0)), area.to_global(Vector2(lift.point_a.x, high_top - 2.0 * H)))
	check(clear_above.is_empty(), "lift: 2 H of headroom over its top stop")
	var shaft_blocks := _ray(area, area.to_global(Vector2(x0, high_top + 2.0)), area.to_global(Vector2(x0, low_bottom - 2.0)))
	check(shaft_blocks.is_empty() or shaft_blocks.collider == lift, "lift: nothing solid inside its shaft")
	# Ride it: wait at tier 1, step on, ride up and down twice; Dave stays on top, never inside a solid.
	var lift_top := func(): return lift.global_position.y - half_t
	var t := 0
	while absf(lift.global_position.y - area.to_global(lift.point_a).y) > 2.0 and t < 600:
		await physics_frames(1)
		t += 1
	press("move_right")
	while hero.global_position.x < area.to_global(Vector2(lift.point_a.x, 0)).x and t < 900:
		await physics_frames(1)
		t += 1
	release("move_right")
	var max_off := 0.0
	var ticks := 0
	var below_ok := true
	while ticks < 60 * 14:
		await physics_frames(1)
		ticks += 1
		if hero.is_on_floor():
			max_off = maxf(max_off, absf(hero.global_position.y - lift_top.call()))
		var head := _ray(area, hero.global_position + Vector2(0, -H + 6), hero.global_position + Vector2(0, -8), [lift.get_rid()])
		if not head.is_empty():
			below_ok = false
	check(max_off <= 3.0, "lift: Dave rides it, standing on its deck (max %.1f px off)" % max_off)
	check(below_ok, "lift: Dave is never inside a solid while riding (never crushed)")
	# Standing under it on the atrium floor while it cycles: never touched.
	hero.respawn_at(area.to_global(Vector2(lift.point_a.x, -4)))
	var touched := false
	for i in 60 * 8:
		await physics_frames(1)
		if hero.global_position.y < area.to_global(Vector2(0, -2)).y and not hero.is_on_floor():
			touched = true
		if lift.global_position.y + half_t > hero.global_position.y - H - 2.0:
			touched = true
	check(not touched, "lift: Dave standing under it on the atrium floor is never touched")
	await _free_world(w)


func _test_vent_wave() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var w := await _world(A05, Vector2(3000, -420))
	var seq: Node = w.area.get_node("Entities/ProjectorPurge")
	var order: Array = []
	var cb := func(i: int, v: Node): order.append([i, v.name, Engine.get_physics_frames()])
	seq.vent_fired.connect(cb)
	var damaging_overlap := 0
	for i in 60 * 12:
		await physics_frames(1)
		var live := 0
		for v in seq.ordered_vents():
			if v.is_damaging():
				live += 1
		damaging_overlap = maxi(damaging_overlap, live)
	check(order.size() >= 12, "vent wave: the purge loops (%d vents fired in 12 s)" % order.size())
	# From the first full wave seen: vent 0 to 5 in turn, west to east.
	while not order.is_empty() and order[0][0] != 0:
		order.pop_front()
	var in_order := order.size() >= 7
	for k in range(1, mini(order.size(), 6)):
		if order[k][0] != order[k - 1][0] + 1 or order[k][2] < order[k - 1][2]:
			in_order = false
	var xs_ok := true
	var vs: Array = seq.ordered_vents()
	for k in range(1, vs.size()):
		if vs[k].global_position.x <= vs[k - 1].global_position.x:
			xs_ok = false
	check(in_order and xs_ok, "vent wave: the vents fire one after the other, west to east")
	check(damaging_overlap <= 4, "vent wave: a wave, not a wall (at most %d of 6 steaming at once)" % damaging_overlap)
	var gap := 0.0
	if order.size() >= 7:
		gap = float(order[6][2] - order[5][2]) / 60.0
	check(gap >= 3.0, "vent wave: a rest between waves for Dave to cross (%.1f s between the last and the next first)" % gap)
	await _free_world(w)


## Kills one enemy by hits, like a shot would.
func _kill(e: Node) -> void:
	for i in 12:
		if not is_instance_valid(e) or ReleasePod.enemy_down(e):
			return
		if e is PatrolRover:
			e.call("_on_rear_hit", 1, e.global_position + Vector2(0, -20), Vector2.RIGHT)
		else:
			var z: HitZone = e.get("hit_zone")
			if z:
				z.take_hit(1, z.global_position, Vector2.RIGHT)
		await physics_frames(10)


func _test_holdout_waves() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	Session.take_keycard("L02-KC01", "L02-KC01-P")
	var w := await _world(A06, Vector2(6700, -4))
	var area: AreaRoot = w.area
	var lift: ExitWicket = area.get_node("Entities/FreightLift")
	var doors: Array = []
	for p in lift.wave_groups:
		doors.append(lift.get_node(p))
	var opened := []
	lift.wave_opened.connect(func(i): opened.append([i, Engine.get_physics_frames()]))
	for d in doors:
		check(d.state == ReleasePod.State.CLOSED, "hold-out: %s is shut before the lift is called" % d.name)
	w.hero.respawn_at(lift.global_position + Vector2(0, -4))
	await physics_frames(6)
	check(lift.is_overriding(), "hold-out: the card at the lift starts the 45 s call")
	var cleared_at := []
	for i in doors.size():
		var d = doors[i]
		var t := 0
		while d.state != ReleasePod.State.OPEN and t < 600:
			await physics_frames(1)
			t += 1
		check(d.state == ReleasePod.State.OPEN, "hold-out: wave %d's door opens" % (i + 1))
		for j in range(i + 1, doors.size()):
			check(doors[j].state == ReleasePod.State.CLOSED, "hold-out: wave %d waits while wave %d is up" % [j + 1, i + 1])
		await physics_frames(30)
		for e in ReleasePod.group_enemies(d.get_node(d.group)):
			await _kill(e)
		cleared_at.append(Engine.get_physics_frames())
	check_eq(opened.size(), 3, "hold-out: three waves opened")
	for i in range(1, opened.size()):
		check(opened[i][0] == i and opened[i][1] > cleared_at[i - 1], "hold-out: wave %d opened only after wave %d was down" % [i + 1, i])
	await _free_world(w)


# --- 5. the real level ------------------------------------------------------------------------

func _test_real_level() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	await physics_frames(3)
	var a5: AreaRoot = null
	var a6: AreaRoot = null
	for a in lvl.areas:
		if a.area_id == "L02-A05":
			a5 = a
		elif a.area_id == "L02-A06":
			a6 = a
	check(a5 != null and a6 != null, "real level: L02 builds A05 and A06")
	if a5 and a6:
		check(is_equal_approx(a6.global_position.x, a5.global_position.x + a5.width), "real level: A06 follows A05 seam to seam")
		check(absf(a5.global_position.y - a6.global_position.y) < 0.5, "real level: both areas' floors at the same y")
		for spec in [[a5, 8.0], [a5, a5.width - 8.0], [a6, 8.0], [a6, a6.width - 8.0]]:
			check(spec[0].has_floor_at(spec[1]), "real level: %s has floor at y 0 at x %.0f" % [spec[0].area_id, spec[1]])
		var idx: int = lvl.areas.find(a5)
		if idx > 0:
			var prev: AreaRoot = lvl.areas[idx - 1]
			check(prev.has_floor_at(prev.width - 8.0), "real level: the area before A05 ends on floor at y 0")
		var markers: Dictionary = lvl.checkpoint_markers()
		check(markers.get("CP04", [])[0] == idx and markers.get("CP04", [])[1] == "Respawn_CP04", "real level: CP04 -> A05 Respawn_CP04")
		check(markers.get("CP05", [])[0] == idx + 1 and markers.get("CP05", [])[1] == "Respawn_CP05", "real level: CP05 -> A06 Respawn_CP05")
	lvl.queue_free()
	await physics_frames(3)


# --- 6. fair fights ---------------------------------------------------------------------------

func _fight(cfg: Dictionary) -> void:
	release_all()
	await physics_frames(2)
	CheckpointService.clear()
	Session.new_run("L02")
	for id in cfg.get("pre", []):
		Session.mark_defeated(id)
	if cfg.get("card", false):
		Session.take_keycard("L02-KC01", "L02-KC01-P")
	var label: String = cfg.label
	var start_local := Vector2.ZERO
	var area_probe: AreaRoot = load(cfg.scene).instantiate()
	if cfg.has("start_at"):
		start_local = Vector2(cfg.start_at[0], cfg.start_at[1])
	else:
		start_local = (area_probe.get_node("Route/" + String(cfg.start)) as Node2D).position
	area_probe.free()
	var w := await _world(cfg.scene, start_local + Vector2(0, -4), false)
	var area: AreaRoot = w.area
	var hero: Hero = w.hero
	var cam: GameCamera = w.camera
	var enemies: Array = []
	var groups: Array = []
	for gname in cfg.groups:
		var g: EncounterGroup = area.get_node("Encounters/" + String(gname))
		groups.append(g)
		for e in _enemies(g):
			enemies.append(e)
	check(hero.aim_pivot.get_node_or_null("Scrapjack") != null, "%s: Dave holds the base Scrapjack" % label)
	check(not groups[0].is_active, "%s: the encounter sleeps until Dave's approach" % label)
	var points: Array = []
	for n in cfg.route:
		points.append(area.get_node("Route/" + String(n)))
	var fmin: float = area.to_global(Vector2(cfg.floor[0], 0)).x
	var fmax: float = area.to_global(Vector2(cfg.floor[1], 0)).x
	var floor_y: float = area.to_global(Vector2(0, cfg.floor[2])).y
	for e in enemies:
		if e is Gunner:
			_sweep_gun_lane(e, fmin, fmax, floor_y, label)
	var new_types: Array = []
	for e in enemies:
		if e is Gunner or e is Drone or e is Hound:
			new_types.append(e.entity_id)
	var lift: ExitWicket = area.get_node_or_null("Entities/FreightLift")
	var reached := [false]
	if cfg.get("holdout", false) and lift:
		lift.wicket_reached.connect(func(): reached[0] = true)
	var rovers: Dictionary = cfg.get("rovers", {})
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(300, -40)
	var ctx := {
		"t": 0, "health0": Session.get_health(), "min_health": Session.get_health(), "died": false,
		"tells": 0, "tells_by": {}, "tells_by_enemy": {}, "shots": 0, "dives": 0, "lunges": 0, "swings": 0,
		"charges": 0, "stalls": 0, "max_shooters": 0, "max_attackers": 0, "fire_gate_bad": [], "airborne_tells": 0,
		"tell_gate_bad": [], "pit_bad": [], "jumps": 0, "dodges": 0, "prev": {}, "last_attack": {}, "active_at": -1,
		"hit_by": [], "seen_at": {},
	}
	hero.died.connect(func(): ctx.died = true)
	var on_health := _on_health.bind(ctx)
	Session.health_changed.connect(on_health)
	for e in enemies:
		if e is Gunner:
			e.fired.connect(_on_gunner_fired.bind(e, hero, cam, ctx))
	var idx := 0
	var in_fight := points.is_empty()
	var jump_left := 0
	var route_jump := false
	var route_left_ground := false
	var dodge_x := NAN
	var dodging: Node = null
	var budget: float = cfg.get("budget", 40.0)
	var max_ticks := int(budget * 60.0)
	while ctx.t < max_ticks:
		var alive := enemies.filter(func(e): return _alive(e))
		if ctx.died:
			break
		if cfg.get("holdout", false):
			if reached[0]:
				break
		elif alive.is_empty():
			break
		var view := _view(cam)
		var out := alive.filter(func(e): return _engaged(e))
		if groups.any(func(g): return g.is_active) and int(ctx.active_at) < 0:
			ctx.active_at = int(ctx.t)
		_audit(hero, out, view, ctx)
		for e in out:
			if not ctx.seen_at.has(e) and view.grow(-H).has_point(_aim_point(e)):
				ctx.seen_at[e] = int(ctx.t)
		var feet := hero.global_position
		var want_jump := false
		var jump_ticks := JUMP_HOLD_TICKS
		var target_x := NAN
		var tol := 10.0
		# Threats.
		for r in get_tree().get_nodes_in_group("enemy_round"):
			if _round_arrival(r, hero) <= ROUND_REACT_S:
				want_jump = true
		var guard_close: Node = null
		for e in out:
			if e is Gunner and e.state == Gunner.State.AIM and e._state_timer >= e.tuning.windup_time - 0.1 \
					and hero.is_on_floor() and signf(feet.x - e.global_position.x) == float(e.facing):
				# The red lamp is about to fire: he hops the round (a flat one, or an aimed one at him).
				want_jump = true
			if e is Hound:
				if _hound_red_at(e, hero):
					want_jump = true
			elif e is PatrolRover:
				if e.state == PatrolRover.State.CHARGE:
					var dx: float = feet.x - e.global_position.x
					if signf(dx) == float(e.facing) and absf(dx) <= ROVER_JUMP_DX and absf(feet.y - e.global_position.y) < 40.0:
						want_jump = true
			elif e is Brawler:
				var dx2: float = e.global_position.x - feet.x
				if absf(e.global_position.y - feet.y) <= 64.0 and absf(dx2) <= GUARD_TOO_CLOSE \
						and e.state in [Brawler.State.WINDUP, Brawler.State.STRIKE, Brawler.State.APPROACH]:
					guard_close = e
			elif e is Drone:
				if e.state == Drone.State.TELL and e.is_lock_set() and dodging == null and hero.is_on_floor():
					var lock: Vector2 = e.locked_point()
					if absf(lock.x - feet.x) < DODGE_DRONE:
						dodging = e
						dodge_x = _pick_dodge(lock.x, feet.x, e.global_position.x, fmin, fmax)
						ctx.dodges = int(ctx.dodges) + 1
		if dodging != null and (not _alive(dodging) or not (dodging.state in [Drone.State.TELL, Drone.State.DIVE])):
			dodging = null
			dodge_x = NAN
		# Where to go.
		if not in_fight:
			if route_jump:
				target_x = points[idx + 1].global_position.x if idx + 1 < points.size() else (fmin + fmax) * 0.5
				tol = 4.0
				if not hero.is_on_floor():
					route_left_ground = true
				elif route_left_ground and jump_left <= 0:
					route_jump = false
					idx += 1
			elif idx < points.size():
				var p: RoutePoint = points[idx]
				target_x = p.global_position.x
				tol = maxf(p.tolerance * 0.5, 4.0)
				if absf(feet.x - target_x) <= tol and hero.is_on_floor():
					if p.action == RoutePoint.Action.JUMP:
						if jump_left <= 0:
							want_jump = true
							jump_ticks = maxi(int(p.hold_jump * 60.0), 6)
							route_jump = true
							route_left_ground = false
					else:
						idx += 1
			if idx >= points.size() and not route_jump and hero.is_on_floor() \
					and absf(feet.y - floor_y) <= 6.0 and feet.x >= fmin and feet.x <= fmax:
				in_fight = true
		var rover_target: Node = null
		if in_fight:
			for e in out:
				if e is PatrolRover:
					rover_target = e
			if rover_target != null:
				var r: PatrolRover = rover_target
				if r.state == PatrolRover.State.STALL:
					target_x = r.global_position.x - float(r.facing) * 110.0
				else:
					target_x = area.to_global(Vector2(float(rovers.get(r.entity_id, cfg.advance_x)), 0)).x
				tol = 6.0
			elif not rovers.is_empty() and _next_rover_stand(rovers, enemies) != INF:
				target_x = area.to_global(Vector2(_next_rover_stand(rovers, enemies), 0)).x
				tol = 6.0
			elif dodging != null:
				target_x = dodge_x
				tol = 6.0
			elif guard_close != null:
				var away: float = -signf(guard_close.global_position.x - feet.x)
				target_x = clampf(feet.x + away * 220.0, fmin + 30.0, fmax - 30.0)
			elif cfg.get("holdout", false) and lift.is_open() and out.is_empty():
				target_x = lift.global_position.x + 10.0
				tol = 4.0
			else:
				target_x = _fight_spot(cfg, area, out, hero, fmin, fmax, floor_y)
			if cfg.has("no_west_of") and not is_nan(target_x):
				target_x = maxf(target_x, area.to_global(Vector2(cfg.no_west_of, 0)).x)
		# Shooting.
		var target: Node = _pick_target(out.filter(func(e): return _open_to_fire(e, out, ctx, hero)), hero, view)
		if target != null:
			hero.aim_override = _aim_point(target)
			press("fire")
		else:
			release("fire")
			if not is_nan(target_x) and absf(target_x - feet.x) > tol:
				hero.aim_override = feet + Vector2(signf(target_x - feet.x) * 300.0, -40.0)
			else:
				# Standing: he watches the nearest threat (and the camera leads that way).
				var watch: Node2D = null
				for e in out:
					if watch == null or feet.distance_to(e.global_position) < feet.distance_to(watch.global_position):
						watch = e
				if watch != null:
					hero.aim_override = _aim_point(watch)
		# Apply.
		if is_nan(target_x) or absf(target_x - feet.x) <= tol:
			release("move_left"); release("move_right")
		elif target_x > feet.x:
			release("move_left"); press("move_right")
		else:
			release("move_right"); press("move_left")
		if in_fight and hero.is_on_floor() and hero.is_on_wall() and not is_nan(target_x) and absf(target_x - feet.x) > tol:
			want_jump = true
			jump_ticks = 20
		if jump_left > 0:
			jump_left -= 1
			if jump_left == 0:
				release("jump")
		elif want_jump and hero.is_on_floor():
			press("jump")
			jump_left = jump_ticks
			ctx.jumps = int(ctx.jumps) + 1
		if _debug and int(ctx.t) % 30 == 0:
			var st := []
			for e in enemies:
				if is_instance_valid(e):
					st.append("%s:%s@%s%s%s" % [String(e.entity_id).right(8), e.state, str(area.to_local(e.global_position).round()), "" if _engaged(e) else "(held)",
							(" cam=%s" % e.is_on_camera()) if e is Gunner else ""])
			st.append("view=%s" % str(_view(cam)))
			print("[dbg %s t=%.1f] dave %s floor=%s target %s in_fight=%s idx=%d | %s" % [String(cfg.label).left(8), ctx.t / 60.0,
					str(area.to_local(hero.global_position).round()), hero.is_on_floor(), str(area.to_local(Vector2(target_x if not is_nan(target_x) else 0.0, 0)).x), in_fight, idx, " ".join(st)])
		await physics_frames(1)
		ctx.t = int(ctx.t) + 1
	release_all()
	var down := enemies.filter(func(e): return not _alive(e)).size()
	if cfg.get("holdout", false) and lift:
		check_eq(lift.current_wave(), 2, "%s: all three waves came while the lift was on its way" % label)
	var lost: int = int(ctx.health0) - int(ctx.min_health)
	var secs: float = ctx.t / 60.0
	var half: int = Session.max_health() / 2
	check(down == enemies.size(), "%s: every enemy is down (%d of %d) in %.1f s" % [label, down, enemies.size(), secs])
	check(not ctx.died, "%s: Dave survives" % label)
	check(lost <= half, "%s: Dave loses at most half his health (%d of %d; hits %s)" % [label, lost, Session.max_health(), str(ctx.hit_by)])
	check(secs < budget, "%s: inside the %.0f s budget (%.1f s)" % [label, budget, secs])
	if not new_types.is_empty():
		check(int(ctx.tells) >= 1, "%s: the encounter showed its tells (%d)" % [label, ctx.tells])
	for id in new_types:
		check(int(ctx.tells_by_enemy.get(id, 0)) >= 1, "%s: %s showed its tell before it went down" % [label, id])
	if not rovers.is_empty():
		check(int(ctx.stalls) >= rovers.size(), "%s: each rover stalled against its backstop (%d stalls)" % [label, ctx.stalls])
	if cfg.get("holdout", false):
		check(reached[0], "%s: the lift arrived and Dave stepped in" % label)
	check(int(ctx.max_shooters) <= 2, "%s: at most 2 shooters on screen (max %d)" % [label, ctx.max_shooters])
	check(int(ctx.max_attackers) <= 3, "%s: at most 3 attackers on screen (max %d)" % [label, ctx.max_attackers])
	check((ctx.fire_gate_bad as Array).is_empty(), "%s: every round left with its gunner 1 H inside the camera and Dave on screen (%s)" % [label, ctx.fire_gate_bad])
	check((ctx.tell_gate_bad as Array).is_empty(), "%s: every drone tell started 1 H inside the camera (%s)" % [label, ctx.tell_gate_bad])
	check(int(ctx.airborne_tells) == 0, "%s: no shooter's tell started at an airborne Dave (%d)" % [label, ctx.airborne_tells])
	check((ctx.pit_bad as Array).is_empty(), "%s: no pit edge within 1.5 H behind Dave while a gun aimed at him (%s)" % [label, ctx.pit_bad])
	var report := "%s: %s in %.1f s, damage %d/%d %s, tells %s, rounds %d, dives %d, lunges %d, swings %d, charges %d, stalls %d, jumps %d, dodges %d, max on screen %d shooters / %d attackers" % [
			label, "WON" if down == enemies.size() and not ctx.died else "LOST", secs, lost, Session.max_health(), str(ctx.hit_by),
			str(ctx.tells_by), ctx.shots, ctx.dives, ctx.lunges, ctx.swings, ctx.charges, ctx.stalls, ctx.jumps, ctx.dodges,
			ctx.max_shooters, ctx.max_attackers]
	_reports.append(report)
	print("[test_l02v2_a05_a06] " + report)
	if Session.health_changed.is_connected(on_health):
		Session.health_changed.disconnect(on_health)
	await _free_world(w)
	CheckpointService.clear()


## Where Dave waits for the next rover still to come (the first in `rovers` not yet down).
func _next_rover_stand(rovers: Dictionary, enemies: Array) -> float:
	for id in rovers:
		for e in enemies:
			if is_instance_valid(e) and e is PatrolRover and e.entity_id == id and _alive(e):
				return float(rovers[id])
	return INF


func _on_health(current: int, _max: int, ctx: Dictionary) -> void:
	if current < int(ctx.min_health):
		var by: Array = []
		for e in get_tree().get_nodes_in_group("enemy"):
			if e is Drone and e.state == Drone.State.DIVE:
				by.append("drone dive")
			elif e is PatrolRover and e.state == PatrolRover.State.CHARGE:
				by.append("rover charge")
			elif e is Brawler and e.is_attack_active():
				by.append("hound lunge" if e is Hound else ("staffer lunge" if String(e.entity_id).contains("LK01") else "guard swing"))
		for r in get_tree().get_nodes_in_group("enemy_round"):
			if r is EnemyRound and r.is_spent():
				by.append("round")
		(ctx.hit_by as Array).append("/".join(by) if not by.is_empty() else "?")
	ctx.min_health = mini(int(ctx.min_health), current)


func _on_gunner_fired(_round: Node, g: Gunner, hero: Hero, cam: GameCamera, ctx: Dictionary) -> void:
	ctx.shots = int(ctx.shots) + 1
	var view := _view(cam)
	var dave_on: bool = view.has_point(hero.global_position + Vector2(0.0, -H * 0.5))
	if not g.is_on_camera() or not view.grow(-H).has_point(g.global_position + Vector2(0.0, -Gunner.HEIGHT * 0.5)) or not dave_on:
		(ctx.fire_gate_bad as Array).append("%s at %s" % [g.entity_id, str(g.global_position.round())])


## Out of its prop and thinking (a closed prop's enemies are frozen and hidden).
func _engaged(e: Node) -> bool:
	return e.is_visible_in_tree() and e.can_process()


func _box_blocked(hero: Hero, x: float, y: float) -> bool:
	var q := PhysicsShapeQueryParameters2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(2.0 * HALF_W + 4.0, 10.0)
	q.shape = r
	q.transform = Transform2D(0.0, Vector2(x, y))
	q.collision_mask = 1
	q.exclude = [hero.get_rid()]
	return not hero.get_world_2d().direct_space_state.intersect_shape(q, 1).is_empty()


func _fight_spot(cfg: Dictionary, area: AreaRoot, alive: Array, hero: Hero, fmin: float, fmax: float, floor_y: float) -> float:
	var feet := hero.global_position
	var nearest: Node2D = null
	for e in alive:
		if e is Drone:
			continue
		if absf(e.global_position.y - floor_y) > 64.0:
			continue
		if nearest == null or absf(e.global_position.x - feet.x) < absf(nearest.global_position.x - feet.x):
			nearest = e
	var spot: float = area.to_global(Vector2(cfg.advance_x, 0)).x
	if cfg.has("drone_hold_x") and alive.any(func(e): return e is Drone):
		spot = area.to_global(Vector2(cfg.drone_hold_x, 0)).x
	if nearest != null:
		var dx: float = nearest.global_position.x - feet.x
		var standoff: float = cfg.standoff
		if absf(dx) <= standoff:
			spot = feet.x
		else:
			spot = nearest.global_position.x - signf(dx) * standoff
	spot = clampf(spot, fmin + 30.0, fmax - 30.0)
	# Never inside a solid: behind low cover (a crate he shoots over), past high cover (a pillar
	# that would hide the enemy from him).
	var away: float = -signf(nearest.global_position.x - feet.x) if nearest != null else -1.0
	if away == 0.0:
		away = -1.0
	var y := floor_y - 30.0
	if _box_blocked(hero, spot, y):
		var high := _box_blocked(hero, spot, floor_y - 80.0) or _box_blocked(hero, spot + away * 60.0, floor_y - 80.0) \
				or _box_blocked(hero, spot - away * 60.0, floor_y - 80.0)
		var step: float = (-away if high else away) * 8.0
		for i in 40:
			if not _box_blocked(hero, spot, y):
				break
			spot += step
	return clampf(spot, fmin + 30.0, fmax - 30.0)


func _pick_dodge(lock_x: float, feet_x: float, drone_x: float, fmin: float, fmax: float) -> float:
	var side: float = signf(feet_x - lock_x)
	if absf(feet_x - lock_x) < 4.0:
		side = -1.0 if drone_x >= lock_x else 1.0
	for sd in [side, -side]:
		var x: float = lock_x + sd * DODGE_DRONE
		if x >= fmin + 30.0 and x <= fmax - 30.0:
			return x
	return clampf(lock_x + side * DODGE_DRONE, fmin + 30.0, fmax - 30.0)


func _open_to_fire(e: Node, alive: Array, ctx: Dictionary, hero: Hero) -> bool:
	if int(ctx.active_at) < 0:
		return false
	var since: int = maxi(maxi(int(ctx.last_attack.get(e, 0)), int(ctx.active_at)), int(ctx.seen_at.get(e, 1 << 30)))
	var idle: bool = int(ctx.t) - since >= int(IDLE_FIRE_S * 60.0)
	if e is Gunner:
		return e.state in [Gunner.State.FIRE, Gunner.State.RELOAD] or (idle and e.state != Gunner.State.AIM)
	if e is Drone:
		return e.state in [Drone.State.HANG, Drone.State.CLIMB] or (idle and e.state == Drone.State.PATROL)
	if e is PatrolRover:
		return e.state == PatrolRover.State.STALL and signf(hero.global_position.x - e.global_position.x) == -float(e.facing)
	if e is Hound:
		return e.state == Brawler.State.RECOVERY or (idle and not e.is_in_chain())
	# A handler once his dog is down (the dog is the first problem, in front of him).
	for o in alive:
		if o is Hound and o.get_node_or_null(o.handler_path) == e:
			return false
	return true


func _round_arrival(r: Node, hero: Hero) -> float:
	if not (r is EnemyRound) or r.is_spent():
		return INF
	var dir: Vector2 = r.direction
	var feet := hero.global_position
	var dx: float = feet.x - r.global_position.x
	if dir.x * dx <= 0.0 or absf(dir.x) < 0.05:
		return INF
	var gap: float = maxf(absf(dx) - HALF_W, 0.0)
	var t: float = gap / (r.speed * absf(dir.x))
	var y_at: float = r.global_position.y + dir.y / absf(dir.x) * absf(dx)
	if y_at < feet.y - H - 8.0 or y_at > feet.y + 4.0:
		return INF
	return t


func _hound_red_at(h: Hound, hero: Hero) -> bool:
	if h.state != Brawler.State.WINDUP:
		return false
	if h._state_timer < h._windup_len - h.tuning.red_time:
		return false
	var dx: float = hero.global_position.x - h.global_position.x
	if absf(hero.global_position.y - h.global_position.y) > 64.0:
		return false
	if signf(dx) != float(h.facing) and absf(dx) > 8.0:
		return false
	return absf(dx) <= h.tuning.lunge_distance() + h.tuning.attack_box_offset.x + h.tuning.attack_box_size.x + HALF_W + 24.0


func _pick_target(alive: Array, hero: Hero, view: Rect2) -> Node:
	var best: Node = null
	var best_d := INF
	var from: Vector2 = hero.aim_pivot.global_position
	for e in alive:
		var c := _aim_point(e)
		if not view.grow(-16.0).has_point(c):
			continue
		var d := from.distance_to(c)
		if d > SHOOT_RANGE:
			continue
		if not _ray(hero, from, c).is_empty():
			continue
		if d < best_d:
			best_d = d
			best = e
	return best


func _aim_point(e: Node2D) -> Vector2:
	if e is Drone:
		return e.global_position
	if e is PatrolRover:
		return (e.rear_hit_zone as Node2D).global_position
	var hz: Node = e.get("hit_zone")
	if hz != null:
		for c in hz.get_children():
			if c is CollisionShape2D:
				return (c as CollisionShape2D).global_position
	return e.global_position + Vector2(0.0, -H * 0.5)


func _alive(e) -> bool:
	return is_instance_valid(e) and not ReleasePod.enemy_down(e)


func _view(cam: Camera2D) -> Rect2:
	var size: Vector2 = cam.get_viewport_rect().size / cam.zoom
	return Rect2(cam.get_screen_center_position() - size * 0.5, size)


func _audit(hero: Hero, alive: Array, view: Rect2, ctx: Dictionary) -> void:
	var shooters := 0
	var attackers := 0
	for e in get_tree().get_nodes_in_group("enemy"):
		if not _alive(e) or not _engaged(e) or not view.has_point(_aim_point(e)):
			continue
		attackers += 1
		if _is_shooter(e):
			shooters += 1
	ctx.max_shooters = maxi(int(ctx.max_shooters), shooters)
	ctx.max_attackers = maxi(int(ctx.max_attackers), attackers)
	var prev: Dictionary = ctx.prev
	for e in alive:
		var s: int = e.state
		var was: int = prev.get(e, -1)
		prev[e] = s
		if s == was:
			continue
		var tell := false
		if e is Gunner and s == Gunner.State.AIM:
			tell = true
		elif e is Drone and s == Drone.State.TELL:
			tell = true
			if not e.is_on_camera() or not view.grow(-H).has_point(e.global_position):
				(ctx.tell_gate_bad as Array).append("%s at %s" % [e.entity_id, str(e.global_position.round())])
		elif e is Drone and s == Drone.State.DIVE:
			ctx.dives = int(ctx.dives) + 1
		elif e is PatrolRover and s == PatrolRover.State.WINDUP:
			tell = true
		elif e is PatrolRover and s == PatrolRover.State.CHARGE:
			ctx.charges = int(ctx.charges) + 1
		elif e is PatrolRover and s == PatrolRover.State.STALL:
			ctx.stalls = int(ctx.stalls) + 1
		elif e is Brawler and s == Brawler.State.WINDUP:
			tell = was != Brawler.State.STRIKE
		elif e is Brawler and s == Brawler.State.STRIKE:
			if e is Hound:
				ctx.lunges = int(ctx.lunges) + 1
			else:
				ctx.swings = int(ctx.swings) + 1
		if tell:
			ctx.tells = int(ctx.tells) + 1
			ctx.last_attack[e] = int(ctx.t)
			ctx.tells_by_enemy[e.entity_id] = int(ctx.tells_by_enemy.get(e.entity_id, 0)) + 1
			var kind := "gunner" if e is Gunner else ("drone" if e is Drone else ("rover" if e is PatrolRover else ("hound" if e is Hound else "brawler")))
			ctx.tells_by[kind] = int(ctx.tells_by.get(kind, 0)) + 1
			if (e is Gunner or e is Drone) and not hero.is_on_floor():
				ctx.airborne_tells = int(ctx.airborne_tells) + 1
	if hero.is_on_floor():
		for e in alive:
			if e is Gunner and e.state == Gunner.State.AIM:
				var bad := _pit_behind(hero, hero.global_position, signf(hero.global_position.x - e.global_position.x))
				if bad != "" and (ctx.pit_bad as Array).size() < 4:
					(ctx.pit_bad as Array).append(bad)


func _pit_behind(node: Node2D, feet: Vector2, away: float) -> String:
	for k in 10:
		var x: float = feet.x + away * (HALF_W + 1.5 * H * float(k) / 9.0)
		if _ray(node, Vector2(x, feet.y - 8.0), Vector2(x, feet.y + 24.0)).is_empty():
			return "standing at x %.0f, the floor ends by x %.0f" % [feet.x, x]
	return ""


func _sweep_gun_lane(g: Gunner, fmin: float, fmax: float, floor_y: float, label: String) -> void:
	var reach := 0
	var bad: Array = []
	var x := fmin
	while x <= fmax:
		var spot := Vector2(x, floor_y)
		var target := spot + Vector2(0.0, -g.tuning.round_height())
		var ahead: float = (target.x - g.global_position.x) * float(g.facing)
		var in_reach := false
		if ahead >= 8.0:
			if g.is_same_floor(spot):
				in_reach = absf(target.x - g.flat_origin().x) <= g.tuning.engage_range()
			else:
				in_reach = g.shot_origin(target).distance_to(target) <= g.tuning.engage_range()
		if in_reach:
			var on_floor := not _ray(g, spot + Vector2(0.0, -8.0), spot + Vector2(0.0, 24.0)).is_empty()
			var clear := _ray(g, spot + Vector2(0.0, -H + 4.0), spot + Vector2(0.0, -12.0)).is_empty()
			if on_floor and clear:
				reach += 1
				var b := _pit_behind(g, spot, signf(spot.x - g.global_position.x))
				if b != "":
					bad.append(b)
		x += 16.0
	check(reach > 0, "%s: %s's gun reaches part of the fight floor (%d spots)" % [label, g.entity_id, reach])
	check(bad.is_empty(), "%s: no standing spot in %s's lane has a pit edge within 1.5 H behind it (%s)" % [label, g.entity_id, str(bad.slice(0, 3))])
