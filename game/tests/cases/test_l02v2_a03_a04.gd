extends TestCase
## Level 2 v2 (C62): A03 Flight cage and A04 Training cells rebuilt to the v2 blueprint
## (prototype-plans/level-02-alignment/area-blueprints-v2.md; level-design/l02-alignment.md).
##   - Layout, in the REAL level (LevelDirector, LevelDefs.get_def("L02")): seams at y 0 and the
##     widths, camera bounds, every room under a ceiling, every room seam on a floor, everything
##     standing on solid floor, every catwalk deck supported (Block.lab_structure()), every raised
##     floor and wall resting on something, every stair flight meeting a floor and a landing, a
##     lamp near every landing, a prop group every 400 px, chips (unique, L02- patterns), entity
##     ids, breakables, beats, every encounter with its ids and types, no enemy patrol on a stair
##     flight, the P23 budget (at most 2 shooters and 3 attackers in any 1,280 px window; a launch
##     rack counts as its max_live), checkpoints CP02/UPG01/CP03 safe (no enemy within 500 px),
##     A04's lockdown node and screens, L02-SW04 in l02.tres.
##   - The RouteBot crossing each area alone (tests/area_harness.gd, invulnerable), A04's upper
##     ledge alone, and both areas in the real level.
##   - A03: the three test-rig lifts (slow, flush lit stops, never crushing Dave under them,
##     carrying him up), the launch rack S4 wired (its drones, at most 2 live, the clamps, the
##     5-chip tray, the L02-SW04 latch across a rebuild), Secret 2 (the vent panel L02-A03-BR01,
##     the shelf reachable, the cartridge L02-A03-AM02 behind it).
##   - A04 (ported from test_l02_areas.gd): the lanes wait for their pad and never close on Dave,
##     a reload keeps used lanes open, the lockdown starts on L02-A04-B01 with Adam's line.
##   - FAIR FIGHTS: every mandatory encounter (E11, E12, the rack, E13, E14, E15, E16, E17, E18)
##     played in the real level like test_l02_encounters.gd: the base Scrapjack, a plausible
##     scripted player who answers the tells (jumps rounds, sidesteps dives, backs off swings) and
##     shoots in the punish windows; every enemy down, Dave alive, at most a third of his health
##     lost, the screen caps, the gun and tell gates, no airborne tells, no pit edge behind a gun
##     lane standing spot.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const CAMERA_SCENE := "res://scenes/actors/game_camera.tscn"
const A03_SCENE := "res://scenes/levels/l02/a03_flight_cage.tscn"
const A04_SCENE := "res://scenes/levels/l02/a04_training_cells.tscn"
const Arch := preload("res://scripts/world/lab_structure.gd")
const StairsScript := preload("res://scripts/world/stairs.gd")
const SeamScript := preload("res://scripts/world/room_seam.gd")
const BreakableScript := preload("res://scripts/objects/breakable.gd")
const VentScript := preload("res://scripts/objects/hazard_vent.gd")
const RackScript := preload("res://scripts/objects/launch_rack.gd")
const RailRack := preload("res://scripts/objects/rail_rack.gd")
const LanePartition := preload("res://scripts/objects/lane_partition.gd")
const LockdownScript := preload("res://scripts/objects/training_lockdown.gd")

const H := 96.0
const WINDOW := 1280.0
const SAFE_RADIUS := 500.0
const PROMPT_SPACING := 288.0
const PROP_BIN := 400.0

const AREAS := {
	"L02-A03": {"index": 2, "width": 6400.0, "camera": [-900.0, 120.0], "chips": 10, "breakables": 7, "seams": 4,
		"beats": ["L02-A03-B01", "L02-A03-B02", "L02-A03-B03"]},
	"L02-A04": {"index": 3, "width": 7000.0, "camera": [-520.0, 130.0], "chips": 9, "breakables": 11, "seams": 5,
		"beats": ["L02-A04-B01", "L02-A04-B02", "L02-A04-B03", "L02-A04-B04"]},
}
## Group id -> its area and what it fields (type codes).
const ENCOUNTERS := {
	"L02-E11": {"area": "L02-A03", "LK01": 1},
	"L02-E12": {"area": "L02-A03", "M02": 1},
	"L02-A03-RACK01": {"area": "L02-A03", "M02": 3, "trigger": true},
	"L02-E13": {"area": "L02-A03", "LK01": 1},
	"L02-E14": {"area": "L02-A03", "SE02": 1, "M02": 1},
	"L02-E15": {"area": "L02-A04", "LK01": 2},
	"L02-E16": {"area": "L02-A04", "SE01": 1},
	"L02-E17": {"area": "L02-A04", "LK01": 2, "M02": 1},
	"L02-E17P": {"area": "L02-A04", "LK01": 2},
	"L02-E18": {"area": "L02-A04", "SE01": 1, "SE02": 1},
}
const TYPE_BY_SCENE := {
	"res://scenes/actors/night_guard.tscn": "SE01", "res://scenes/actors/staffer.tscn": "LK01",
	"res://scenes/actors/sidearm_guard.tscn": "SE02", "res://scenes/actors/security_drone.tscn": "M02",
}
## The three test-rig lifts: [node, lower deck, upper deck].
const LIFTS := [["Lift1", "Deck1", "Deck2"], ["Lift2", "Deck2", "Deck3"], ["Lift3", "Deck3", "Deck4"]]

# --- the fair-fight player (as test_l02_encounters.gd) ---------------------------------------
const BUDGET_S := 40.0
const SHOOT_RANGE := 600.0
const JUMP_HOLD_TICKS := 27
const ROUND_REACT_S := 0.2
const HALF_W := 20.0
const DODGE_DRONE := 1.7 * H
const IDLE_FIRE_S := 4.0
const GUARD_TOO_CLOSE := 140.0
## Each fight: its area, group, the encounters already down (as a player arrives), switches
## already used, Dave's start (area-local, before the group wakes) and his fight floor
## [min x, max x, floor y] (area-local). `advance_x`: where he holds when nothing is near.
const FIGHTS := [
	{"label": "E11 the drone tech (A03)", "area": "L02-A03", "group": "EncounterGroup_E11",
		"start": Vector2(60, 0), "floor": [40.0, 1390.0, 0.0], "advance_x": 300.0, "standoff": 280.0},
	{"label": "E12 the Security Drone alone (A03)", "area": "L02-A03", "group": "EncounterGroup_E12",
		"down": ["L02-E11"], "start": Vector2(500, 0), "floor": [100.0, 1390.0, 0.0], "advance_x": 800.0, "standoff": 280.0},
	{"label": "S4 the launch rack's drones (A03)", "area": "L02-A03", "group": "EncounterGroup_RACK01",
		"down": ["L02-E11", "L02-E12"], "start": Vector2(2310, -280), "floor": [2305.0, 2745.0, -280.0],
		"advance_x": 2600.0, "standoff": 280.0, "budget": 70.0, "no_zone": true},
	{"label": "E13 the Staffer at her workstation (A03)", "area": "L02-A03", "group": "EncounterGroup_E13",
		"down": ["L02-E11", "L02-E12", "L02-A03-RACK01"], "start": Vector2(3700, -560), "floor": [3510.0, 4400.0, -560.0],
		"advance_x": 3800.0, "standoff": 280.0},
	{"label": "E14 Sidearm Guard on the gantry and a Security Drone (A03)", "area": "L02-A03", "group": "EncounterGroup_E14",
		"down": ["L02-E11", "L02-E12", "L02-A03-RACK01", "L02-E13"], "start": Vector2(4780, -560), "floor": [5340.0, 5670.0, -300.0],
		"advance_x": 5360.0, "standoff": 290.0},
	{"label": "E15 two Staffers from the open cell (A04)", "area": "L02-A04", "group": "EncounterGroup_E15",
		"start": Vector2(300, 0), "floor": [60.0, 1280.0, 0.0], "advance_x": 650.0, "standoff": 280.0},
	{"label": "E16 the guard in cell room A (A04)", "area": "L02-A04", "group": "EncounterGroup_E16",
		"down": ["L02-E15"], "switches": ["L02-SW01"], "start": Vector2(1500, 0), "floor": [1610.0, 2600.0, 0.0],
		"advance_x": 1800.0, "standoff": 280.0},
	{"label": "E17 two Staffers and a Security Drone in the server hall (A04)", "area": "L02-A04", "group": "EncounterGroup_E17",
		"down": ["L02-E15", "L02-E16"], "switches": ["L02-SW01", "L02-SW02", "L02-SW03"], "start": Vector2(4400, 0),
		"floor": [4510.0, 5560.0, 0.0], "advance_x": 4600.0, "standoff": 280.0},
	{"label": "E18 Sidearm Guard behind the control desk and a Night Guard (A04)", "area": "L02-A04", "group": "EncounterGroup_E18",
		"down": ["L02-E15", "L02-E16", "L02-E17"], "switches": ["L02-SW01", "L02-SW02", "L02-SW03"], "start": Vector2(5450, 0),
		"floor": [5300.0, 6600.0, 0.0], "advance_x": 5700.0, "standoff": 300.0},
]

var _reports: Array = []


func run() -> void:
	# Debug aid: FIGHT_ONLY=<label part> runs only the matching fights.
	var only := OS.get_environment("FIGHT_ONLY")
	if only != "":
		for cfg in FIGHTS:
			if String(cfg.label).contains(only):
				await _fight(cfg)
		return
	await _test_layout_in_the_real_level()
	await _test_route_bot_alone()
	await _test_route_bot_in_the_real_level()
	await _test_lifts()
	await _test_launch_rack()
	await _test_secret_vent()
	await _test_a04_lanes_wait_and_never_close_on_dave()
	await _test_a04_reload_keeps_lanes_open()
	await _test_a04_lockdown_in_the_real_level()
	for cfg in FIGHTS:
		await _fight(cfg)
	print("[test_l02v2_a03_a04] ==== FIGHTS ====")
	for r in _reports:
		print("[test_l02v2_a03_a04]   %s" % r)
	release_all()
	CheckpointService.clear()
	Session.new_run()


# --- helpers ------------------------------------------------------------------------------

func _build_level() -> LevelDirector:
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	await physics_frames(3)
	return lvl


func _area(lvl: LevelDirector, id: String) -> AreaRoot:
	for a in lvl.areas:
		if a.area_id == id:
			return a
	return null


func _free(node: Node) -> void:
	if is_instance_valid(node):
		node.queue_free()
	await physics_frames(2)


func _collect(node: Node, out: Array, pred: Callable) -> void:
	if pred.call(node):
		out.append(node)
	for c in node.get_children():
		_collect(c, out, pred)


func _all(node: Node, pred: Callable) -> Array:
	var out: Array = []
	_collect(node, out, pred)
	return out


func _ray(node: Node2D, from: Vector2, to: Vector2) -> Dictionary:
	var q := PhysicsRayQueryParameters2D.create(from, to)
	q.collision_mask = 1
	return node.get_world_2d().direct_space_state.intersect_ray(q)


func _solid_between(node: Node2D, from: Vector2, to: Vector2) -> bool:
	return not _ray(node, from, to).is_empty()


## True when global point `p` (a foot) stands on something solid (within a few px).
func _on_solid(node: Node2D, p: Vector2) -> bool:
	return _solid_between(node, p + Vector2(0.0, -6.0), p + Vector2(0.0, 10.0))


func _type_code(e: Node) -> String:
	return String(TYPE_BY_SCENE.get(e.scene_file_path, "?"))


func _enemies(area: AreaRoot) -> Array:
	return _all(area.get_node("Encounters"), func(n): return n.is_in_group("enemy"))


func _spawn_alone(path: String, hero_at: Vector2) -> Array:
	var area: AreaRoot = load(path).instantiate()
	add_child(area)
	var hero: Hero = load(HERO_SCENE).instantiate()
	hero.debug_invulnerable = true
	add_child(hero)
	hero.respawn_at(hero_at)
	await physics_frames(3)
	return [area, hero]


# --- 1. layout in the real level --------------------------------------------------------------

func _test_layout_in_the_real_level() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var def := LevelDefs.get_def("L02")
	check(def.switches.has("L02-SW04") and def.switches["L02-SW04"] == false, "l02.tres lists the rack's latch L02-SW04 (off)")
	var lvl := await _build_level()
	var all_ids: PackedStringArray = []
	for id in AREAS:
		var want: Dictionary = AREAS[id]
		var a := _area(lvl, id)
		check(a != null, "%s is in the level" % id)
		if a == null:
			continue
		check_eq(lvl.areas.find(a), int(want.index), "%s is area %d" % [id, want.index])
		var i: int = lvl.areas.find(a)
		if i > 0:
			var prev: AreaRoot = lvl.areas[i - 1]
			check(is_equal_approx(a.global_position.x, prev.global_position.x + prev.width), "%s starts where %s ends" % [id, prev.area_id])
		check_eq(a.width, float(want.width), "%s is %d px wide" % [id, int(want.width)])
		check_eq([a.camera_top, a.camera_bottom], want.camera, "%s's camera bounds" % id)
		check(a.indoors and a.interior_look == "lab" and a.wet_until_x == 0.0, "%s is indoors in the lab look" % id)
		_check_seams(lvl, a)
		_check_rooms_and_structure(a)
		_check_standing(a)
		_check_lamps_and_props(a)
		all_ids.append_array(a.get_entity_ids())
		var chips := _all(a.get_node("Entities"), func(n): return n is Chip)
		check_eq(chips.size(), int(want.chips), "%s has %d microchips" % [id, want.chips])
		var re := RegEx.create_from_string("^%s-G\\d{3}$" % id)
		for c in chips:
			check(re.search((c as Chip).entity_id) != null and int(c.value) == 1, "chip %s matches %s-Gnnn" % [c.entity_id, id])
		var brk := _all(a.get_node("Entities"), func(n): return n.get_script() == BreakableScript)
		check_eq(brk.size(), int(want.breakables), "%s has %d breakables" % [id, want.breakables])
		var re_br := RegEx.create_from_string("^%s-BR\\d{2}$" % id)
		for b in brk:
			if String(b.entity_id) != "":
				check(re_br.search(b.entity_id) != null, "breakable id %s matches %s-BRnn" % [b.entity_id, id])
			for c in b.content_nodes():
				check(String(c.get("entity_id")) != "", "%s's contents %s have their own id" % [b.name, c.name])
		var beats := Array(a.get_beat_ids())
		for bid in want.beats:
			check(bid in beats, "%s keeps beat zone %s" % [id, bid])
		var seams := _all(a.get_node("Scenery"), func(n): return n.get_script() == SeamScript)
		check(seams.size() >= int(want.seams), "%s's rooms are joined by %d room seams (%d)" % [id, want.seams, seams.size()])
	var seen := {}
	var dupes: PackedStringArray = []
	for id in all_ids:
		if seen.has(id):
			dupes.append(id)
		seen[id] = true
		check(id.begins_with("L02-"), "entity id %s has the Level 2 prefix" % id)
	check(dupes.is_empty(), "no duplicate entity ids in A03 and A04 (%s)" % dupes)
	for required in ["L02-UPG01", "L02-EF02", "L02-A03-AM01", "L02-A03-AM02", "L02-A03-BR01", "L02-A03-CACHE01"]:
		check(required in all_ids, "entity %s is placed" % required)
	_check_encounters(lvl)
	_check_window_budget(lvl)
	await _check_checkpoints(lvl)
	var a04 := _area(lvl, "L02-A04")
	if a04:
		var lock := a04.get_node_or_null("Entities/Lockdown")
		check(lock != null and lock.get_script() == LockdownScript and lock.beat_id == "L02-A04-B01", "A04 keeps Entities/Lockdown on L02-A04-B01")
		if lock:
			check_eq(lock.screens.size(), 6, "the lockdown's six screens")
			check(is_equal_approx(lock.width, a04.width), "the emergency strips run the whole 7,000 px")
			var ev := a04.get_node_or_null("Entities/EvidencePickup_EF02") as Node2D
			var desk := a04.get_node_or_null("Scenery/DeskPod") as Node2D
			check(ev != null and desk != null and absf(ev.position.x - desk.position.x) <= 2.0, "EF02 sits on Dave's desk pod")
			if ev != null and lock.desk_screen >= 0:
				check(absf(lock.screens[lock.desk_screen].x - ev.position.x) <= 40.0, "the larger desk screen hangs over Dave's desk")
		var b01: Node2D = null
		for bz in _all(a04.get_node("Beats"), func(n): return n.is_in_group("beat_zone")):
			if bz.beat_id == "L02-A04-B01":
				b01 = bz
		check(b01 != null and b01.position.x - b01.size.x * 0.5 <= 200.0, "L02-A04-B01 covers the area's start")
	await _free(lvl)


## AreaRoot seam contract: flat, clear floor at y 0 for 4 H at the entry and the exit.
func _check_seams(lvl: LevelDirector, a: AreaRoot) -> void:
	for lx in [10.0, 100.0, 200.0, 300.0, 380.0, a.width - 380.0, a.width - 200.0, a.width - 100.0, a.width - 10.0]:
		check(a.has_floor_at(lx), "%s has floor at y 0, x %d" % [a.area_id, int(lx)])
		var g := a.to_global(Vector2(lx, 0.0))
		check(not _solid_between(lvl, g + Vector2(0.0, -H - 4.0), g + Vector2(0.0, -6.0)),
				"%s: nothing solid over the seam floor at x %d" % [a.area_id, int(lx)])
	check(a.get_marker("Spawn_CP00") != null, "%s has a Spawn_CP00 for the harness" % a.area_id)


## Ceilings over every room, supported decks, raised floors and walls resting on something,
## stair flights meeting a floor and a landing.
func _check_rooms_and_structure(a: AreaRoot) -> void:
	var blocks := _all(a.get_node("Geometry"), func(n): return n is Block)
	var others: Array = []
	for b in blocks:
		others.append([b.get_rect_global(), int(b.kind)])
	# A ceiling over every stretch of the area.
	var x := 50.0
	var open: Array = []
	while x < a.width:
		var y: float = Arch.ceiling_above(others, a.to_global(Vector2(x, -1.0)), 1200.0)
		if is_nan(y):
			open.append(int(x))
		x += 100.0
	check(open.is_empty(), "%s: a ceiling closes every room (open at x %s)" % [a.area_id, str(open)])
	for b in blocks:
		var role: String = b.lab_structure()
		if b.kind != Block.Kind.SCENERY_SOLID and b.kind != Block.Kind.BACKSTOP:
			check(role != "", "%s/%s wears the lab structure look (kind %d)" % [a.area_id, b.name, b.kind])
		match role:
			"deck":
				var sup := Arch.deck_supports(b)
				check(int(sup["mode"]) != Arch.S_NONE and (sup["xs"] as Array).size() >= 1,
						"%s/%s: the deck hangs from a ceiling or stands on columns (mode %d)" % [a.area_id, b.name, sup["mode"]])
			"raised", "floor", "wall":
				var r: Rect2 = b.get_rect_global()
				var rests := _solid_between(b, Vector2(r.position.x + r.size.x * 0.5, r.end.y - 3.0), Vector2(r.position.x + r.size.x * 0.5, r.end.y + 8.0)) \
						or absf(r.end.y - a.global_position.y - 300.0) <= 1.0
				if role == "wall" and not rests:
					rests = _ray(b, Vector2(r.position.x + r.size.x * 0.5, r.position.y + 3.0), Vector2(r.position.x + r.size.x * 0.5, r.position.y - 8.0)).size() > 0
				check(rests, "%s/%s (%s) rests on something solid, no bare floating slab" % [a.area_id, b.name, role])
	for s in _all(a.get_node("Geometry"), func(n): return n.get_script() == StairsScript):
		var top_y: float = s.global_position.y - float(s.rise)
		var hx: float = s.high_end_x() + 12.0 * float(s.direction)
		var lx: float = s.low_end_x() - 12.0 * float(s.direction)
		var land := _ray(s, Vector2(hx, top_y - 10.0), Vector2(hx, top_y + 10.0))
		check(not land.is_empty() and absf(land.position.y - top_y) <= 2.0,
				"%s/%s: the flight's high end meets a landing at its height" % [a.area_id, s.name])
		var foot := _ray(s, Vector2(lx, s.global_position.y - 10.0), Vector2(lx, s.global_position.y + 10.0))
		check(not foot.is_empty() and absf(foot.position.y - s.global_position.y) <= 2.0,
				"%s/%s: its low end meets a floor" % [a.area_id, s.name])
		check(float(s.rise) <= float(s.run) + 0.5, "%s/%s is no steeper than 45 degrees" % [a.area_id, s.name])
	for seam in _all(a.get_node("Scenery"), func(n): return n.get_script() == SeamScript):
		check(_on_solid(seam, seam.global_position), "%s/%s stands on a floor line" % [a.area_id, seam.name])


## Enemies (not drones), interactables, cartridges, breakables (not the wall monitors) and the
## standing props all stand on solid floor.
func _check_standing(a: AreaRoot) -> void:
	var bad: Array = []
	for e in _enemies(a):
		if not (e is Drone) and not _on_solid(e, e.global_position):
			bad.append(e.entity_id)
	for n in _all(a.get_node("Entities"), func(n): return (n is Interactable and not (n is EvidencePickup)) or _is_cartridge(n) or n.get_script() == BreakableScript):
		if n.get_script() == BreakableScript and int(n.kind) == BreakableScript.Kind.MONITOR:
			continue   # on a bench top or a wall
		if not _on_solid(n, n.global_position):
			bad.append(String(n.name))
	for n in _all(a.get_node("Scenery"), func(n): return n is Scenery and int(n.kind) in [Scenery.Kind.LAB_PROP, Scenery.Kind.LAMP, Scenery.Kind.SUPPORT]):
		if not _on_solid(n, n.global_position):
			bad.append(String(n.name))
	check(bad.is_empty(), "%s: everything stands on solid floor (%s)" % [a.area_id, str(bad)])


func _is_cartridge(n: Node) -> bool:
	return n.scene_file_path == "res://scenes/objects/ammo_cartridge.tscn"


## A lamp near every landing (each deck, each stair's ends) and a prop group every 400 px.
func _check_lamps_and_props(a: AreaRoot) -> void:
	var lamps: Array = []
	var props: Array = []
	for n in _all(a.get_node("Scenery"), func(n): return n is Scenery):
		if int(n.kind) == Scenery.Kind.LAMP:
			lamps.append(a.to_local(n.global_position))
		if int(n.kind) in [Scenery.Kind.LAB_PROP, Scenery.Kind.PANEL, Scenery.Kind.SUPPORT, Scenery.Kind.SIGN]:
			props.append(a.to_local(n.global_position).x)
	for n in _all(a.get_node("Entities"), func(n): return n.get_script() == BreakableScript):
		props.append(n.position.x)
	var spots: Array = []
	for b in _all(a.get_node("Geometry"), func(n): return n is Block and n.lab_structure() == "deck" and n.size.x >= 200.0):
		spots.append([String(b.name), Vector2(b.position.x + b.size.x * 0.5, b.position.y), b.size.x * 0.5 + 200.0])
	for s in _all(a.get_node("Geometry"), func(n): return n.get_script() == StairsScript):
		spots.append([String(s.name) + " foot", a.to_local(Vector2(s.low_end_x(), s.global_position.y)), 320.0])
		spots.append([String(s.name) + " head", a.to_local(Vector2(s.high_end_x(), s.global_position.y - s.rise)), 320.0])
	for sp in spots:
		var near := lamps.any(func(l): return absf(l.x - sp[1].x) <= sp[2] and absf(l.y - sp[1].y) <= 160.0)
		check(near, "%s: a lamp near the landing %s" % [a.area_id, sp[0]])
	var empty: Array = []
	var x := 0.0
	while x < a.width:
		if not props.any(func(px): return px >= x and px < x + PROP_BIN):
			empty.append(int(x))
		x += PROP_BIN
	check(empty.is_empty(), "%s: a prop group in every 400 px (none at %s)" % [a.area_id, str(empty)])


func _check_encounters(lvl: LevelDirector) -> void:
	var groups := {}
	for id in AREAS:
		var a := _area(lvl, id)
		if a == null:
			continue
		for g in a.get_node("Encounters").get_children():
			if g is EncounterGroup:
				groups[g.group_id] = [id, g]
	check_eq(groups.size(), ENCOUNTERS.size(), "A03 and A04 hold %d encounter groups (%s)" % [ENCOUNTERS.size(), str(groups.keys())])
	var re := RegEx.create_from_string("^(L02-E\\d{2}P?|L02-A03-RACK01)-(SE01|LK01|SE02|M02)-\\d{2}$")
	var stairs: Array = []
	for id in AREAS:
		var a := _area(lvl, id)
		if a:
			for s in _all(a.get_node("Geometry"), func(n): return n.get_script() == StairsScript):
				stairs.append(Rect2(s.global_position + Vector2(0.0, -s.rise), Vector2(s.run, s.rise)))
	for gid in ENCOUNTERS:
		var want: Dictionary = ENCOUNTERS[gid]
		check(groups.has(gid), "encounter %s is placed" % gid)
		if not groups.has(gid):
			continue
		check_eq(groups[gid][0], want.area, "%s is in %s" % [gid, want.area])
		var g: EncounterGroup = groups[gid][1]
		check(g.max_attackers <= 2, "%s lets at most 2 attack at once (%d)" % [gid, g.max_attackers])
		var zone := g.get_node_or_null("ApproachZone") as Area2D
		if want.get("trigger", false):
			check(g.wait_for_trigger and zone == null, "%s waits for its rack's trigger" % gid)
		else:
			check(zone != null and zone.collision_mask == 2, "%s wakes on Dave's approach (ApproachZone)" % gid)
		var got := {}
		for e in g.get_children():
			if not e.is_in_group("enemy"):
				continue
			var code := _type_code(e)
			got[code] = int(got.get(code, 0)) + 1
			var m := re.search(e.entity_id)
			check(m != null and m.get_string(1) == gid and m.get_string(2) == code,
					"%s's id %s follows <group>-<type>-nn (%s)" % [gid, e.entity_id, code])
			if not (e is Drone):
				var lane: Rect2 = Rect2(g.to_global(g.lane_rect.position), g.lane_rect.size)
				for st in stairs:
					var touches_floor: bool = e.global_position.y >= st.position.y - 4.0 and e.global_position.y <= st.end.y + 4.0
					check(not (touches_floor and lane.position.x < st.end.x and lane.end.x > st.position.x),
							"%s's patrol lane stays off the stair flight at x %d" % [e.entity_id, int(st.position.x)])
		var want_types := {}
		for k in want:
			if k in ["SE01", "LK01", "SE02", "M02"]:
				want_types[k] = want[k]
		check_eq(got, want_types, "%s fields %s" % [gid, str(want_types)])


## P23 at rest: at most 2 shooters (Sidearm Guards, drones) and 3 attackers in any 1,280 px
## window over A03 and A04, each enemy counted where it stands and across its patrol span; a
## launch rack's drones count as at most its max_live.
func _check_window_budget(lvl: LevelDirector) -> void:
	var spans: Array = []   # [lo, hi, shooter, rack or null]
	var lo_x := INF
	var hi_x := -INF
	for id in AREAS:
		var a := _area(lvl, id)
		if a == null:
			continue
		lo_x = minf(lo_x, a.global_position.x)
		hi_x = maxf(hi_x, a.global_position.x + a.width)
		var racks := _all(a.get_node("Entities"), func(n): return n.get_script() == RackScript)
		for e in _enemies(a):
			var lo: float = e.global_position.x
			var hi: float = lo
			if e is Drone:
				lo = minf(lo, a.to_global(Vector2(e.patrol_min_x, 0)).x)
				hi = maxf(hi, a.to_global(Vector2(e.patrol_max_x, 0)).x)
			var rack: Node = null
			for r in racks:
				for p in r.drones:
					if r.get_node_or_null(p) == e:
						rack = r
			spans.append([lo, hi, e is Gunner or e is Drone, rack])
	var worst_s := 0
	var worst_a := 0
	var worst_at := 0.0
	var x := lo_x - WINDOW
	while x <= hi_x:
		var shooters := 0
		var attackers := 0
		var per_rack := {}
		for sp in spans:
			if sp[1] >= x and sp[0] <= x + WINDOW:
				if sp[3] != null:
					var k: int = sp[3].get_instance_id()
					per_rack[k] = int(per_rack.get(k, 0)) + 1
					if int(per_rack[k]) > int(sp[3].max_live):
						continue
				attackers += 1
				if sp[2]:
					shooters += 1
		if shooters > worst_s or attackers > worst_a:
			worst_at = x
		worst_s = maxi(worst_s, shooters)
		worst_a = maxi(worst_a, attackers)
		x += 16.0
	check(worst_s <= 2, "P23: at most 2 shooters in any 1,280 px window of A03-A04 (max %d near x %.0f)" % [worst_s, worst_at])
	check(worst_a <= 3, "P23: at most 3 attackers in any 1,280 px window of A03-A04 (max %d near x %.0f)" % [worst_a, worst_at])
	print("[test_l02v2_a03_a04] window budget: max %d shooters, %d attackers per 1,280 px" % [worst_s, worst_a])


func _check_checkpoints(lvl: LevelDirector) -> void:
	var def := lvl.level_def
	for cp in ["CP02", "UPG01", "CP03"]:
		var entry: Array = def.checkpoint_markers[cp]
		var area: AreaRoot = lvl.areas[entry[0]]
		var marker := area.get_marker(entry[1])
		check(marker != null, "%s's marker %s is in %s" % [cp, entry[1], area.area_id])
		if marker == null:
			continue
		var m := marker.global_position
		check(_solid_between(lvl, m + Vector2(0, -2), m + Vector2(0, 24)), "%s's marker stands on a floor" % cp)
		check(not _solid_between(lvl, m + Vector2(0, -H), m + Vector2(0, -8)), "%s's marker has headroom" % cp)
		for e in _enemies(area):
			var t: Vector2 = e.global_position
			check(absf(t.x - m.x) >= SAFE_RADIUS or absf(t.y - m.y) >= 3.0 * H,
					"%s is 500 px clear of %s (at %s)" % [cp, e.entity_id, str(area.to_local(t))])
		if cp.begins_with("CP"):
			var st := area.get_node_or_null("Entities/RecoveryStation_" + cp) as RecoveryStation
			check(st != null and st.global_position.distance_to(m) <= 24.0, "%s's recovery station is at its marker" % cp)
		else:
			var bench := area.get_node_or_null("Entities/Workbench") as Node2D
			check(bench != null and bench.global_position.distance_to(m) <= 24.0, "UPG01 respawns at the workbench")
		lvl._place_hero_at_checkpoint(cp)
		await physics_frames(20)
		check(lvl.hero.is_on_floor() and lvl.hero.global_position.distance_to(m) <= 12.0,
				"Dave stands safely at %s (at %s)" % [cp, str(area.to_local(lvl.hero.global_position))])
	# Prompts 3 H apart in both areas.
	for id in AREAS:
		var a := _area(lvl, id)
		if a == null:
			continue
		var spots: Array = []
		for n in _all(a.get_node("Entities"), func(n): return n is Interactable and (n as Node2D).visible):
			spots.append([String(n.name), (n as Node2D).position])
		for p in spots.size():
			for q in range(p + 1, spots.size()):
				var d: Vector2 = spots[p][1] - spots[q][1]
				check(absf(d.x) >= PROMPT_SPACING or absf(d.y) >= 2.0 * H,
						"%s: %s and %s are 3 H apart (dx %d)" % [id, spots[p][0], spots[q][0], int(d.x)])


# --- 2. the RouteBot -------------------------------------------------------------------------

func _test_route_bot_alone() -> void:
	for path in [A03_SCENE, A04_SCENE]:
		Session.new_run("L02")
		var harness = load("res://tests/area_harness.gd").new()
		var result: Dictionary = await harness.run_area(self, path, [], 120.0)
		print("[test_l02v2_a03_a04] route bot alone %s: %.1f s %s" % [path.get_file(), result.seconds, str(result.beat_times.keys())])
		check(result.reached_exit, "the RouteBot crosses %s alone on the main route (%s at %s)" % [path.get_file(), result.failure, str(result.hero_final_position)])
		if path == A03_SCENE:
			check(Session.state["checkpoint_id"] == "CP02", "the A03 route uses the CP02 station")
			check(Session.chips_found() >= 8, "the A03 route picks up the deck and lift chips (%d)" % Session.chips_found())
		else:
			for sw in ["L02-SW01", "L02-SW02", "L02-SW03"]:
				check(Session.get_switch(sw), "the A04 route uses %s's lane" % sw)
			check(Session.state["checkpoint_id"] == "CP03", "the A04 route uses the CP03 station")
			check(not Session.has_evidence("EF02"), "the evidence file stays optional")
	# The upper ledge alone: no lane used, A04 crossed.
	Session.new_run("L02")
	var spawned := await _spawn_alone(A04_SCENE, Vector2(96, -4))
	var area: AreaRoot = spawned[0]
	var hero: Hero = spawned[1]
	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(area, ["LEDGE"])
	var pts: Array = []
	var owners: Array = []
	for i in bot.points.size():
		if bot.points[i].branch == "LEDGE":
			pts.append(bot.points[i])
			owners.append(bot._point_areas[i])
	bot.points = pts
	bot._point_areas = owners
	check(pts.size() >= 4, "setup: the LEDGE route is authored (%d points)" % pts.size())
	bot.start(hero)
	var ticks := 0
	while bot.running and ticks < 60 * 60:
		await get_tree().physics_frame
		ticks += 1
	check(bot.success, "the upper ledge gets Dave through A04 with no lane used (%s)" % bot.failure_message)
	check(hero.global_position.x >= area.width - 64.0 and absf(hero.global_position.y) <= 8.0, "...to the exit seam (at %s)" % str(hero.global_position))
	for sw in ["L02-SW01", "L02-SW02", "L02-SW03"]:
		check(not Session.get_switch(sw), "%s was never used" % sw)
	await _free(bot)
	await _free(hero)
	await _free(area)


## Both areas' main routes in the real level (their real offsets and camera), from A03's entry.
func _test_route_bot_in_the_real_level() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl := await _build_level()
	var a03 := _area(lvl, "L02-A03")
	var a04 := _area(lvl, "L02-A04")
	if a03 == null or a04 == null:
		check(false, "setup: A03 and A04 in the level")
		await _free(lvl)
		return
	lvl.hero.debug_invulnerable = true
	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(lvl, [])
	var pts: Array = []
	var owners: Array = []
	for i in bot.points.size():
		if bot._point_areas[i] == a03 or bot._point_areas[i] == a04:
			pts.append(bot.points[i])
			owners.append(bot._point_areas[i])
	bot.points = pts
	bot._point_areas = owners
	lvl.hero.respawn_at(a03.to_global(Vector2(60, -4)))
	await physics_frames(3)
	lvl.camera.reset_position()
	bot.start(lvl.hero)
	var ticks := 0
	while bot.running and ticks < 60 * 150:
		await get_tree().physics_frame
		ticks += 1
	var report := bot.get_report()
	print("[test_l02v2_a03_a04] route bot in the level: %.1f s, areas %s" % [report.seconds, str(report.area_times)])
	check(bot.success, "the RouteBot crosses A03 and A04 in the real level (%s)" % report.failure)
	check(lvl.hero.global_position.x >= a04.global_position.x + a04.width - 64.0, "...to A04's exit seam (at %s)" % str(lvl.hero.global_position))
	for bid in AREAS["L02-A03"].beats + AREAS["L02-A04"].beats:
		check(report.beat_times.has(bid), "the route crosses beat %s" % bid)
	await _free(bot)
	await _free(lvl)
	CheckpointService.clear()


# --- 3. A03: the lifts, the rack, the secret --------------------------------------------------

func _test_lifts() -> void:
	Session.new_run("L02")
	var spawned := await _spawn_alone(A03_SCENE, Vector2(96, -4))
	var area: AreaRoot = spawned[0]
	var hero: Hero = spawned[1]
	var lamps: Array = []
	for n in _all(area.get_node("Scenery"), func(n): return n is Scenery and int(n.kind) == Scenery.Kind.LAMP):
		lamps.append(n.position)
	for spec in LIFTS:
		var lift: MovingPlatform = area.get_node("Geometry/" + spec[0])
		var low: Block = area.get_node("Geometry/" + spec[1])
		var high: Block = area.get_node("Geometry/" + spec[2])
		var top_a: float = lift.point_a.y - lift.thickness * 0.5
		var top_b: float = lift.point_b.y - lift.thickness * 0.5
		check(absf(top_a - low.position.y) <= 1.0 and absf(top_b - high.position.y) <= 1.0,
				"%s's stops are flush with %s and %s" % [spec[0], spec[1], spec[2]])
		check(lift.speed <= 60.0 and lift.pause_time >= 1.0, "%s is slow (%.0f px/s) and pauses %.1f s at each stop" % [spec[0], lift.speed, lift.pause_time])
		var gap_lo: float = (lift.point_a.x - lift.width * 0.5) - (low.position.x + low.size.x)
		var gap_hi: float = high.position.x - (lift.point_b.x + lift.width * 0.5)
		check(gap_lo >= 0.0 and gap_lo <= 8.0 and gap_hi >= 0.0 and gap_hi <= 8.0,
				"%s fills its shaft (gaps %.0f / %.0f px), clear of both decks" % [spec[0], gap_lo, gap_hi])
		var lit_a := lamps.any(func(l): return absf(l.x - (low.position.x + low.size.x)) <= 60.0 and absf(l.y - low.position.y) <= 2.0)
		var lit_b := lamps.any(func(l): return absf(l.x - high.position.x) <= 60.0 and absf(l.y - high.position.y) <= 2.0)
		check(lit_a and lit_b, "%s has a lit stop at both ends" % spec[0])
		# Never crushing: Dave on the catch floor under the shaft for a whole cycle.
		var under := Vector2(lift.point_a.x, -4.0)
		hero.respawn_at(under)
		await physics_frames(10)
		var stand := hero.global_position
		var cycle: float = 2.0 * (absf(lift.point_b.y - lift.point_a.y) / lift.speed + lift.pause_time) + 0.5
		var moved := 0.0
		for i in int(cycle * 60.0):
			await get_tree().physics_frame
			moved = maxf(moved, hero.global_position.distance_to(stand))
		check(moved < 2.0 and hero.is_on_floor(), "%s never closes on Dave standing under it (moved %.1f px)" % [spec[0], moved])
		# Riding: Dave put on it at its lower stop is carried up to the upper deck's height.
		var t := 0
		while lift.position.distance_to(lift.point_a) > 1.0 and t < 60 * 12:
			await get_tree().physics_frame
			t += 1
		hero.respawn_at(Vector2(lift.position.x, top_a - 2.0))
		var best_y := INF
		for i in int(cycle * 60.0):
			await get_tree().physics_frame
			best_y = minf(best_y, hero.global_position.y)
		check(absf(best_y - high.position.y) <= 3.0, "%s carries Dave up to %s (reached y %.0f, deck %.0f)" % [spec[0], spec[2], best_y, high.position.y])
	await _free(hero)
	await _free(area)


func _test_launch_rack() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var spawned := await _spawn_alone(A03_SCENE, Vector2(2310, -284))
	var area: AreaRoot = spawned[0]
	var hero: Hero = spawned[1]
	var rack: Node2D = area.get_node("Entities/LaunchRack_RACK01")
	var group: EncounterGroup = area.get_node("Encounters/EncounterGroup_RACK01")
	var cache := area.get_node("Entities/RackCache") as ChipCache
	check(rack.get_script() == RackScript, "the rack is the S4 launch rack")
	check_eq(rack.drones.size(), 3, "the rack holds three drones")
	var drones: Array = []
	for p in rack.drones:
		var d := rack.get_node_or_null(p)
		check(d is Drone and d.get_parent() == group, "rack drone %s is a Security Drone in the rack's group" % str(p))
		drones.append(d)
	check(rack.get_node_or_null(rack.group) == group and group.wait_for_trigger, "the rack's group waits for its trigger")
	check(rack.count == 3 and rack.max_live == 2 and is_equal_approx(rack.interval, 6.0), "3 drones, 1 every 6 s, at most 2 live")
	check_eq(rack.switch_id, "L02-SW04", "the rack latches L02-SW04")
	check(cache != null and rack.get_node_or_null(rack.reward) == cache and cache.value == 5 and cache.entity_id == "L02-A03-CACHE01",
			"the reward is the 5-chip tray L02-A03-CACHE01")
	var d3: Block = area.get_node("Geometry/Deck3")
	check(cache != null and cache.position.x >= d3.position.x and cache.position.x <= d3.position.x + d3.size.x and is_equal_approx(cache.position.y, d3.position.y),
			"...on Deck 3")
	check(cache != null and not cache.visible, "the tray is hidden until the clamps break")
	check(rack.state == RackScript.State.IDLE, "the rack waits for Dave")
	# Dave walks onto Deck 2: the rack wakes and launches, never more than two alive.
	press("move_right")
	await seconds(0.4)
	release("move_right")
	var max_live := 0
	for i in 60 * 16:
		await get_tree().physics_frame
		max_live = maxi(max_live, rack.live_count())
	check(rack.state != RackScript.State.IDLE, "Dave's approach activates the rack")
	check_eq(rack.launched_count(), 2, "two drones launched while two live")
	check(max_live <= 2, "never more than two live (%d)" % max_live)
	var out: Array = drones.filter(func(d): return is_instance_valid(d) and not rack.is_docked(d))
	if not out.is_empty():
		var d: Drone = out[0]
		d.hit_zone.take_hit(5, d.global_position, Vector2.RIGHT)
	await seconds(8.0)
	check_eq(rack.launched_count(), 3, "with one down the third launches")
	# Shoot the four clamps: the rack stops, the tray opens, the latch is set.
	for i in 4:
		var z: HitZone = rack.clamp_zone(i)
		for k in rack.clamp_health:
			z.take_hit(1, z.global_position, Vector2.UP)
			await physics_frames(2)
	await physics_frames(10)
	check(rack.state == RackScript.State.DISABLED and rack.clamps_left() == 0, "all four clamps broken disable the rack")
	check(cache.visible and cache.can_interact(hero), "the 5-chip tray is revealed")
	check(Session.get_switch("L02-SW04"), "L02-SW04 latches the broken rack")
	await _free(hero)
	await _free(area)
	# A rebuild after a checkpoint keeps it broken and the tray shown.
	spawned = await _spawn_alone(A03_SCENE, Vector2(2310, -284))
	area = spawned[0]
	hero = spawned[1]
	rack = area.get_node("Entities/LaunchRack_RACK01")
	await physics_frames(4)
	check(rack.state == RackScript.State.DISABLED and (area.get_node("Entities/RackCache") as CanvasItem).visible,
			"a rebuilt A03 keeps the rack broken and its tray shown")
	await _free(hero)
	await _free(area)


func _test_secret_vent() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var spawned := await _spawn_alone(A03_SCENE, Vector2(4850, -564))
	var area: AreaRoot = spawned[0]
	var hero: Hero = spawned[1]
	var vent: Node2D = area.get_node("Entities/Breakable_SecretVent")
	var cart: Node2D = area.get_node("Entities/AmmoCartridge_AM02")
	check(vent.entity_id == "L02-A03-BR01" and int(vent.kind) == BreakableScript.Kind.VENT_PANEL and vent.solid, "Secret 2 is the solid vent panel L02-A03-BR01")
	check(not cart.visible and cart.process_mode == Node.PROCESS_MODE_DISABLED, "the cartridge waits hidden behind it")
	var shelf: Block = area.get_node("Geometry/DuctShelf")
	var obs: Block = area.get_node("Geometry/ObservationFloor")
	check(shelf.position.y - obs.position.y >= -120.0, "the shelf is one 120 px step up from the observation floor")
	check(_solid_between(area, vent.global_position + Vector2(-30, -50), vent.global_position + Vector2(30, -50)), "the intact vent blocks the duct")
	# Dave jumps up onto the shelf from the observation floor's end.
	press("move_right")
	press("jump")
	await seconds(0.45)
	release("jump")
	await seconds(0.5)
	release("move_right")
	await seconds(0.3)
	check(hero.is_on_floor() and absf(hero.global_position.y - shelf.position.y) <= 2.0, "Dave reaches the shelf (at %s)" % str(hero.global_position))
	check(hero.global_position.x < vent.global_position.x, "...and stops at the vent")
	# Shoot it open with the Scrapjack.
	hero.use_aim_override = true
	for i in 120:
		hero.aim_override = vent.global_position + Vector2(0, -50)
		press("fire")
		await get_tree().physics_frame
		if vent.is_broken():
			break
	release("fire")
	check(vent.is_broken(), "the Scrapjack breaks the vent panel")
	check(Session.is_collected("L02-A03-BR01"), "the break is recorded")
	await physics_frames(20)
	check(cart.visible, "the cartridge shows")
	# A cartridge feeds the Boom Broom only: Dave carries it with room in its reserve.
	Session.swap_weapon("L02-A01-PAD01")
	Session.set_weapon_ammo(Session.equipped_weapon(), 4, 0)
	await physics_frames(3)
	press("move_right")
	await seconds(0.6)
	release("move_right")
	await physics_frames(5)
	check(Session.is_collected("L02-A03-AM02"), "Dave takes the cartridge L02-A03-AM02 in the duct")
	await _free(hero)
	await _free(area)


# --- 4. A04: the lanes and the lockdown (ported from test_l02_areas.gd) -----------------------

func _test_a04_lanes_wait_and_never_close_on_dave() -> void:
	Session.new_run("L02")
	var spawned := await _spawn_alone(A04_SCENE, Vector2(96, -4))
	var area: AreaRoot = spawned[0]
	var hero: Hero = spawned[1]
	var racks: Array = []
	var parts: Array = []
	for i in 3:
		racks.append(area.get_node("Geometry/RailRack_%d" % (i + 1)))
		parts.append(area.get_node("Geometry/Partition_%d" % (i + 1)))
		check(racks[i].get_script() == RailRack and parts[i].get_script() == LanePartition, "lane %d keeps its rack and partition" % (i + 1))
		var pad: RouteSwitch = area.get_node("Entities/ControlPad_SW%02d" % (i + 1))
		check(pad.switch_id == "L02-SW%02d" % (i + 1) and racks[i].switch_id == pad.switch_id and parts[i].switch_id == pad.switch_id,
				"lane %d's pad, rack and partition share L02-SW%02d" % [i + 1, i + 1])
	# No enemy ever on a moving lane: every lane rect keeps clear of the racks' tracks.
	for g in area.get_node("Encounters").get_children():
		if not (g is EncounterGroup):
			continue
		for r in racks:
			var lo: float = minf(r.point_a.x, r.point_b.x) - r.width * 0.5
			var hi: float = maxf(r.point_a.x, r.point_b.x) + r.width * 0.5
			var lane: Rect2 = g.lane_rect
			check(lane.end.x <= lo or lane.position.x >= hi or lane.end.y < -40.0,
					"%s's lane keeps off %s's track (%d-%d)" % [g.group_id, r.name, int(lo), int(hi)])
	await seconds(2.0)
	for i in 3:
		check(racks[i].phase == RailRack.Phase.WAITING and racks[i].position.distance_to(racks[i].point_a) < 0.5,
				"lane %d's rack waits at the near bank until its pad is used" % (i + 1))
		check(not parts[i].is_open and not parts[i]._shape.disabled, "lane %d's partition is shut" % (i + 1))
	var events: Array = []
	racks[0].move_warned.connect(func(c): events.append(["warned", c]))
	racks[0].move_started.connect(func(): events.append(["started"]))
	racks[0].arrived.connect(func(): events.append(["arrived"]))
	hero.respawn_at(Vector2(1578, 44))
	await physics_frames(20)
	var standing := hero.global_position
	check(standing.y > 40.0 and hero.is_on_floor(), "setup: Dave stands in trench 1 at its far end (%s)" % str(standing))
	var pad1: RouteSwitch = area.get_node("Entities/ControlPad_SW01")
	pad1.interact(hero)
	check(Session.get_switch("L02-SW01"), "the control pad sets L02-SW01")
	await seconds(4.0)
	check(racks[0].phase == RailRack.Phase.MOVING and racks[0].blocked, "the rack holds still while Dave is in its way")
	var rack_front: float = racks[0].position.x + racks[0].width * 0.5
	check(rack_front <= hero.global_position.x - 20.0 + 1.0, "the rack never closes on Dave (front %.0f, Dave's back %.0f)" % [rack_front, hero.global_position.x - 20.0])
	check(hero.global_position.distance_to(standing) < 2.0, "Dave is not pushed (moved %.1f px)" % hero.global_position.distance_to(standing))
	check(not parts[0].is_open, "the partition stays shut until the rack arrives")
	check(events.size() >= 2 and events[0][0] == "warned" and String(events[0][1]) != "" and events[1][0] == "started",
			"the move is announced first, then starts (%s)" % str(events))
	hero.respawn_at(Vector2(1000, -4))
	await seconds(3.0)
	check(racks[0].is_docked() and racks[0].position.distance_to(racks[0].point_b) < 0.5, "once clear the rack docks at the far bank")
	check(parts[0].is_open and parts[0]._shape.disabled, "and the far-bank partition opens")
	check(events.size() == 3 and events[2][0] == "arrived", "warned, started, arrived, once each (%s)" % str(events))
	check(not racks[1].is_docked() and not racks[2].is_docked(), "the other lanes still wait for their own pads")
	hero.respawn_at(Vector2(2800, -4))
	await physics_frames(10)
	check(hero.is_on_floor(), "setup: Dave stands on lane 2's rack at the near bank")
	var pad2: RouteSwitch = area.get_node("Entities/ControlPad_SW02")
	pad2.interact(hero)
	await seconds(4.0)
	check(racks[1].is_docked(), "lane 2's rack crosses with Dave on it")
	check(hero.global_position.x >= 2890.0 and hero.is_on_floor(), "Dave rides it across (x %.0f)" % hero.global_position.x)
	press("move_right")
	await seconds(1.0)
	release("move_right")
	check(hero.global_position.x > 3060.0 and hero.global_position.y < 2.0, "Dave walks out past the open partition (at %s)" % str(hero.global_position))
	await _free(hero)
	await _free(area)


func _test_a04_reload_keeps_lanes_open() -> void:
	Session.new_run("L02")
	for sw in ["L02-SW01", "L02-SW02", "L02-SW03"]:
		Session.set_switch(sw, true)
	var area: AreaRoot = load(A04_SCENE).instantiate()
	add_child(area)
	await physics_frames(2)
	for i in 3:
		var rack: Node = area.get_node("Geometry/RailRack_%d" % (i + 1))
		var part: Node = area.get_node("Geometry/Partition_%d" % (i + 1))
		check(rack.is_docked() and rack.position.distance_to(rack.point_b) < 0.5, "a used lane %d loads with its rack docked" % (i + 1))
		check(part.is_open, "...and its partition open")
	await _free(area)


func _test_a04_lockdown_in_the_real_level() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl := await _build_level()
	var a04 := _area(lvl, "L02-A04")
	if a04 == null:
		check(false, "setup: A04 in the level")
		await _free(lvl)
		return
	var lock = a04.get_node("Entities/Lockdown")
	check(not lock.on and Session.get_story("sandbox_lockdown") == false, "the sandbox is calm before Dave arrives")
	lvl.hero.respawn_at(a04.to_global(Vector2(-150, -4)))
	await physics_frames(5)
	press("move_right")
	await seconds(1.0)
	release("move_right")
	await physics_frames(5)
	check(lock.on and Session.get_story("sandbox_lockdown") == true, "walking into A04 starts Adam's lockdown (L02-A04-B01)")
	check(lvl.story_lines_active(), "...and Adam's line plays")
	await seconds(lock.FADE_TIME + 0.5)
	check(lock.shows_terminated(), "the six screens show Dave's file stamped TERMINATED")
	await _free(lvl)
	CheckpointService.clear()


# --- 5. fair fights ----------------------------------------------------------------------------

func _fight(cfg: Dictionary) -> void:
	release_all()
	await physics_frames(2)
	CheckpointService.clear()
	Session.new_run("L02")
	for sw in cfg.get("switches", []):
		Session.set_switch(sw, true)
	var lvl := await _build_level()
	var label: String = cfg.label
	var area := _area(lvl, cfg.area)
	if area == null:
		check(false, "%s: setup: the area is in the level" % label)
		await _free(lvl)
		return
	# The encounters a player has already cleared on the way are down.
	for gid in cfg.get("down", []):
		for g in area.get_node("Encounters").get_children():
			if g is EncounterGroup and g.group_id == gid:
				for e in g.get_children():
					if e.is_in_group("enemy"):
						Session.mark_defeated(e.entity_id)
	lvl._rebuild_areas()
	await physics_frames(3)
	area = _area(lvl, cfg.area)
	var group: EncounterGroup = area.get_node("Encounters/" + String(cfg.group))
	var enemies: Array = group.get_children().filter(func(c): return c.is_in_group("enemy"))
	var new_type_ids: Array = []
	for e in enemies:
		if e is Gunner or e is Drone:
			new_type_ids.append(e.entity_id)
	var hero: Hero = lvl.hero
	check(hero.aim_pivot.get_node_or_null("Scrapjack") != null and Session.weapon_stage("W01") == 0,
			"%s: Dave holds the base Scrapjack" % label)
	var start_g: Vector2 = area.to_global(Vector2(cfg.start.x, cfg.start.y - 4.0))
	if not cfg.get("no_zone", false):
		var zone: Area2D = group.get_node("ApproachZone")
		var zs := (zone.get_node("CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D
		check(start_g.x < zone.global_position.x - zs.size.x * 0.5, "%s: Dave starts before the ApproachZone" % label)
	await _teleport(lvl, area, start_g)
	check(not group.is_active, "%s: the group sleeps until Dave's approach" % label)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(300.0, -40.0)
	var fmin: float = area.to_global(Vector2(cfg.floor[0], 0)).x
	var fmax: float = area.to_global(Vector2(cfg.floor[1], 0)).x
	var floor_y: float = area.to_global(Vector2(0, cfg.floor[2])).y
	for e in enemies:
		if e is Gunner:
			_sweep_gun_lane(e, fmin, fmax, floor_y, label)
	var ctx := {
		"t": 0, "health0": Session.get_health(), "min_health": Session.get_health(), "hits": 0,
		"tells": 0, "tells_by": {}, "shots": 0, "dives": 0, "lunges": 0, "swings": 0,
		"max_shooters": 0, "max_attackers": 0, "fire_gate_bad": [], "airborne_tells": 0,
		"tell_gate_bad": [], "pit_bad": [], "died": false, "jumps": 0, "dodges": 0,
		"prev": {}, "last_attack": {}, "active_at": -1, "hit_by": [], "tells_by_enemy": {},
	}
	hero.died.connect(func(): ctx.died = true)
	var on_health := _on_health.bind(ctx)
	Session.health_changed.connect(on_health)
	for e in enemies:
		if e is Gunner:
			e.fired.connect(_on_gunner_fired.bind(e, lvl, ctx))
	var in_fight := false
	var jump_left := 0
	var dodge_x := NAN
	var dodging_drone: Node = null
	var budget: float = cfg.get("budget", BUDGET_S)
	var max_ticks := int(budget * 60.0)
	while ctx.t < max_ticks:
		var alive := enemies.filter(func(e): return _alive(e))
		if alive.is_empty() or ctx.died:
			break
		var view := _view(lvl)
		if group.is_active and int(ctx.active_at) < 0:
			ctx.active_at = int(ctx.t)
		_audit(lvl, hero, alive, view, ctx)
		var feet := hero.global_position
		var want_jump := false
		var jump_ticks := JUMP_HOLD_TICKS
		var target_x := NAN
		var tol := 10.0
		for r in get_tree().get_nodes_in_group("enemy_round"):
			if _round_arrival(r, hero) <= ROUND_REACT_S:
				want_jump = true
		var guard_close: Node = null
		for e in alive:
			if e is Brawler:
				var dx: float = e.global_position.x - feet.x
				if absf(e.global_position.y - feet.y) <= 64.0 and absf(dx) <= GUARD_TOO_CLOSE \
						and e.state in [Brawler.State.WINDUP, Brawler.State.STRIKE, Brawler.State.APPROACH]:
					guard_close = e
			elif e is Drone:
				if e.state == Drone.State.TELL and e.is_lock_set() and dodging_drone == null and hero.is_on_floor():
					var lock: Vector2 = e.locked_point()
					if absf(lock.x - feet.x) < DODGE_DRONE:
						dodging_drone = e
						dodge_x = _pick_dodge(lock.x, feet.x, e.global_position.x, fmin, fmax)
						ctx.dodges = int(ctx.dodges) + 1
		if dodging_drone != null and (not _alive(dodging_drone) or not (dodging_drone.state in [Drone.State.TELL, Drone.State.DIVE])):
			dodging_drone = null
			dodge_x = NAN
		if not in_fight:
			target_x = (fmin + fmax) * 0.5 if not cfg.has("advance_x") else area.to_global(Vector2(cfg.advance_x, 0)).x
			if hero.is_on_floor() and absf(feet.y - floor_y) <= 4.0 and feet.x >= fmin and feet.x <= fmax:
				in_fight = true
		if in_fight:
			if dodging_drone != null:
				target_x = dodge_x
				tol = 6.0
			elif guard_close != null:
				var away: float = -signf(guard_close.global_position.x - feet.x)
				target_x = clampf(feet.x + away * 220.0, fmin + 30.0, fmax - 30.0)
			else:
				target_x = _fight_spot(cfg, area, alive, hero, fmin, fmax) if group.is_active \
						else area.to_global(Vector2(cfg.advance_x, 0)).x
		var target: Node = _pick_target(alive.filter(func(e): return _open_to_fire(e, alive, ctx)), hero, view)
		if target != null:
			hero.aim_override = _aim_point(target, hero.global_position + Vector2(0.0, -60.0))
			press("fire")
		else:
			release("fire")
			if not is_nan(target_x) and absf(target_x - feet.x) > 8.0:
				hero.aim_override = feet + Vector2(signf(target_x - feet.x) * 300.0, -40.0)
		if is_nan(target_x) or absf(target_x - feet.x) <= tol:
			release("move_left"); release("move_right")
		elif target_x > feet.x:
			release("move_left"); press("move_right")
		else:
			release("move_right"); press("move_left")
		if hero.is_on_floor() and hero.is_on_wall() and not is_nan(target_x) and absf(target_x - feet.x) > tol:
			want_jump = true
			jump_ticks = 16
		if jump_left > 0:
			jump_left -= 1
			if jump_left == 0:
				release("jump")
		elif want_jump and hero.is_on_floor():
			press("jump")
			jump_left = jump_ticks
			ctx.jumps = int(ctx.jumps) + 1
		await physics_frames(1)
		ctx.t = int(ctx.t) + 1
		if OS.get_environment("FIGHT_DEBUG") != "" and int(ctx.t) % 60 == 0:
			print("[fight debug] t=%d dave=%s infight=%s active=%s %s" % [ctx.t, str(area.to_local(hero.global_position).round()), in_fight, group.is_active,
					str(alive.map(func(e): return [e.entity_id, e.state, str(area.to_local(e.global_position).round())]))])
	release_all()
	var down := enemies.filter(func(e): return not _alive(e)).size()
	var lost: int = int(ctx.health0) - int(ctx.min_health)
	var secs: float = ctx.t / 60.0
	var third: int = maxi(1, Session.max_health() / 3)
	check(down == enemies.size(), "%s: every enemy is down (%d of %d) in %.1f s" % [label, down, enemies.size(), secs])
	check(not ctx.died, "%s: Dave survives" % label)
	check(lost <= third, "%s: Dave loses at most a third of his health (%d of %d: %s)" % [label, lost, Session.max_health(), str(ctx.hit_by)])
	check(secs < budget, "%s: inside the %.0f s budget (%.1f s)" % [label, budget, secs])
	if not new_type_ids.is_empty():
		check(int(ctx.tells) >= 1, "%s: the encounter showed its tells (%d)" % [label, ctx.tells])
	for id in new_type_ids:
		check(int(ctx.tells_by_enemy.get(id, 0)) >= 1, "%s: %s showed its tell before it went down" % [label, id])
	check(int(ctx.max_shooters) <= 2, "%s: at most 2 shooters on screen (max %d)" % [label, ctx.max_shooters])
	check(int(ctx.max_attackers) <= 3, "%s: at most 3 attackers on screen (max %d)" % [label, ctx.max_attackers])
	check((ctx.fire_gate_bad as Array).is_empty(), "%s: every round left with its gunner 1 H inside the camera and Dave on screen (%s)" % [label, ctx.fire_gate_bad])
	check((ctx.tell_gate_bad as Array).is_empty(), "%s: every drone tell started 1 H inside the camera (%s)" % [label, ctx.tell_gate_bad])
	check(int(ctx.airborne_tells) == 0, "%s: no tell started at an airborne Dave (%d)" % [label, ctx.airborne_tells])
	check((ctx.pit_bad as Array).is_empty(), "%s: no pit edge within 1.5 H behind Dave while a gun aimed at him (%s)" % [label, ctx.pit_bad])
	var report := "%s: %s in %.1f s, damage taken %d/%d %s, tells %s, rounds %d, dives %d, lunges %d, swings %d, jumps %d, dodges %d, max on screen %d shooters / %d attackers" % [
			label, "WON" if down == enemies.size() and not ctx.died else "LOST", secs, lost, Session.max_health(), str(ctx.hit_by),
			str(ctx.tells_by), ctx.shots, ctx.dives, ctx.lunges, ctx.swings, ctx.jumps, ctx.dodges, ctx.max_shooters, ctx.max_attackers]
	_reports.append(report)
	print("[test_l02v2_a03_a04] " + report)
	if Session.health_changed.is_connected(on_health):
		Session.health_changed.disconnect(on_health)
	await _free(lvl)
	CheckpointService.clear()


func _on_health(current: int, _max: int, ctx: Dictionary) -> void:
	if current < int(ctx.min_health):
		ctx.hits = int(ctx.hits) + 1
		var by: Array = []
		for e in get_tree().get_nodes_in_group("enemy"):
			if e is Drone and e.state == Drone.State.DIVE:
				by.append("drone dive")
			elif e is Brawler and e.is_attack_active():
				by.append("staffer lunge" if e.scene_file_path.contains("staffer") else "guard swing")
		for r in get_tree().get_nodes_in_group("enemy_round"):
			if r is EnemyRound and r.is_spent():
				by.append("round (%s)" % ("flat" if absf(r.direction.y) < 0.05 else "aimed"))
		(ctx.hit_by as Array).append("/".join(by) if not by.is_empty() else "? (hazard?)")
	ctx.min_health = mini(int(ctx.min_health), current)


func _on_gunner_fired(_round: Node, g: Gunner, lvl: LevelDirector, ctx: Dictionary) -> void:
	ctx.shots = int(ctx.shots) + 1
	var view := _view(lvl)
	var dave_on: bool = view.has_point(lvl.hero.global_position + Vector2(0.0, -H * 0.5))
	if not g.is_on_camera() or not view.grow(-H).has_point(g.global_position + Vector2(0.0, -Gunner.HEIGHT * 0.5)) or not dave_on:
		(ctx.fire_gate_bad as Array).append("%s at %s, Dave at %s" % [g.entity_id, str(g.global_position.round()), str(lvl.hero.global_position.round())])


func _fight_spot(cfg: Dictionary, area: AreaRoot, alive: Array, hero: Hero, fmin: float, fmax: float) -> float:
	var feet := hero.global_position
	var nearest: Node2D = null
	for e in alive:
		if e is Drone:
			continue
		if absf(e.global_position.y - feet.y) > 64.0:
			continue
		if nearest == null or absf(e.global_position.x - feet.x) < absf(nearest.global_position.x - feet.x):
			nearest = e
	var spot: float = area.to_global(Vector2(cfg.advance_x, 0)).x
	if nearest != null:
		var dx: float = nearest.global_position.x - feet.x
		var standoff: float = cfg.standoff
		var from := feet + Vector2(0.0, -60.0)
		if _solid_between(hero, from, _aim_point(nearest, from)):
			standoff = 120.0   # low cover between them: close in (and hop onto it)
		if absf(dx) <= standoff:
			spot = feet.x
		else:
			spot = nearest.global_position.x - signf(dx) * standoff
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


func _open_to_fire(e: Node, alive: Array, ctx: Dictionary) -> bool:
	if int(ctx.active_at) < 0:
		return false
	var since: int = maxi(int(ctx.last_attack.get(e, 0)), maxi(int(ctx.active_at), 0))
	var idle: bool = int(ctx.t) - since >= int(IDLE_FIRE_S * 60.0)
	if e is Gunner:
		return e.state in [Gunner.State.FIRE, Gunner.State.RELOAD] or (idle and e.state != Gunner.State.AIM)
	if e is Drone:
		return e.state in [Drone.State.HANG, Drone.State.CLIMB] or (idle and e.state == Drone.State.PATROL)
	# A Staffer or a Night Guard: after its swing or lunge (its recovery), or once it has held
	# back for IDLE_FIRE_S; never into a windup (he backs off it instead).
	if e is Brawler:
		return e.state == Brawler.State.RECOVERY or (idle and e.state in [Brawler.State.PATROL, Brawler.State.APPROACH])
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


func _pick_target(alive: Array, hero: Hero, view: Rect2) -> Node:
	var best: Node = null
	var best_d := INF
	var from := hero.global_position + Vector2(0.0, -60.0)
	for e in alive:
		var c := _aim_point(e, from)
		if not view.grow(-16.0).has_point(c):
			continue
		var d := from.distance_to(c)
		if d > SHOOT_RANGE:
			continue
		if _solid_between(hero, from, c):
			continue
		if d < best_d:
			best_d = d
			best = e
	return best


## Where the player aims at `e`: its hit zone's middle, or its upper body over low cover.
func _aim_point(e: Node2D, from: Vector2) -> Vector2:
	var c := _center(e)
	if e is Drone or not _solid_between(e, from, c):
		return c
	return c + Vector2(0.0, -30.0)


func _audit(lvl: LevelDirector, hero: Hero, alive: Array, view: Rect2, ctx: Dictionary) -> void:
	var shooters := 0
	var attackers := 0
	for e in get_tree().get_nodes_in_group("enemy"):
		if not _alive(e) or not view.has_point(_center(e)):
			continue
		if e is Drone and e.process_mode == Node.PROCESS_MODE_DISABLED:
			continue   # docked in its rack: not flying, cannot attack
		attackers += 1
		if e is Gunner or e is Drone:
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
		elif e is Brawler and s == Brawler.State.WINDUP:
			tell = was != Brawler.State.STRIKE
		elif e is Brawler and s == Brawler.State.STRIKE:
			if e.scene_file_path.contains("staffer"):
				ctx.lunges = int(ctx.lunges) + 1
			else:
				ctx.swings = int(ctx.swings) + 1
		if tell:
			ctx.tells = int(ctx.tells) + 1
			ctx.last_attack[e] = int(ctx.t)
			ctx.tells_by_enemy[e.entity_id] = int(ctx.tells_by_enemy.get(e.entity_id, 0)) + 1
			var kind := "gunner" if e is Gunner else ("drone" if e is Drone else ("staffer" if e.scene_file_path.contains("staffer") else "guard"))
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
		# Floor at his feet' height, or a stair flight rising behind him (no more than 45 degrees).
		if not _solid_between(node, Vector2(x, feet.y - 8.0), Vector2(x, feet.y + 24.0)) \
				and not _solid_between(node, Vector2(x, feet.y - absf(x - feet.x) - 8.0), Vector2(x, feet.y - 8.0)):
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
			var on_floor := _solid_between(g, spot + Vector2(0.0, -8.0), spot + Vector2(0.0, 24.0))
			if on_floor and not _solid_between(g, spot + Vector2(0.0, -H + 4.0), spot + Vector2(0.0, -12.0)):
				reach += 1
				var b := _pit_behind(g, spot, signf(spot.x - g.global_position.x))
				if b != "":
					bad.append(b)
		x += 16.0
	check(reach > 0, "%s: %s's gun reaches part of the fight floor (%d spots)" % [label, g.entity_id, reach])
	check(bad.is_empty(), "%s: no standing spot in %s's lane has a pit edge within 1.5 H behind it (%s)" % [label, g.entity_id, str(bad.slice(0, 3))])


func _alive(e) -> bool:
	if not is_instance_valid(e) or e.is_queued_for_deletion():
		return false
	if e is Gunner:
		return e.state != Gunner.State.DEFEATED
	if e is Drone:
		return e.state != Drone.State.DEFEATED
	if e is Brawler:
		return e.state != Brawler.State.DEFEATED
	return true


func _center(e: Node2D) -> Vector2:
	if e is Drone:
		return e.global_position
	var hz: Node = e.get("hit_zone")
	if hz != null:
		for c in hz.get_children():
			if c is CollisionShape2D:
				return (c as CollisionShape2D).global_position
	return e.global_position + Vector2(0.0, -H * 0.5)


func _view(lvl: LevelDirector) -> Rect2:
	var cam: Camera2D = lvl.camera
	var size: Vector2 = lvl.get_viewport_rect().size / cam.zoom
	return Rect2(cam.get_screen_center_position() - size * 0.5, size)


func _teleport(lvl: LevelDirector, area: AreaRoot, pos: Vector2) -> void:
	lvl.hero.respawn_at(pos)
	var r: Rect2 = lvl._camera_target_rect_for_area(area)
	lvl._camera_top = r.position.y
	lvl._camera_bottom = r.position.y + r.size.y
	lvl.camera.world_limits = Rect2(0.0, r.position.y, lvl.level_width, r.size.y)
	await physics_frames(2)
	lvl.camera.reset_position()
	await physics_frames(8)
