extends TestCase
## Level 2 v2 architecture kit: stairs and ramps (scripts/world/stairs.gd, the only sloped solid),
## the hero's floor settings that walk them (hero.gd _ready(): snap, constant speed, stop on slope),
## the RouteBot climbing a flight, the lab structure look (scripts/world/lab_structure.gd via
## Block) changing no collision anywhere in Level 2, and room seams (scripts/world/room_seam.gd)
## being visual unless `solid_lintel`.

const BlockScript := preload("res://scripts/world/block.gd")
const StairsScript := preload("res://scripts/world/stairs.gd")
const SeamScript := preload("res://scripts/world/room_seam.gd")
const AreaRootScript := preload("res://scripts/levels/area_root.gd")
const Arch := preload("res://scripts/world/lab_structure.gd")
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const STAIRS_SCENE := "res://scenes/world/stairs.tscn"
const L01_DEPOT := "res://scenes/levels/areas/a05_depot.tscn"
const L02_AREAS: Array[String] = [
	"res://scenes/levels/l02/a01_sky_bridge.tscn", "res://scenes/levels/l02/a02_range_kennel.tscn",
	"res://scenes/levels/l02/a03_flight_cage.tscn", "res://scenes/levels/l02/a04_training_cells.tscn",
	"res://scenes/levels/l02/a05_lattice.tscn", "res://scenes/levels/l02/a06_demo_floor.tscn",
]

## The test rig (global px): a floor at y 600, a flight rising right from x 200 (1.0 H over
## 1.5 H, the kit's stair), a landing from its high end at x 344.
const FLOOR_Y := 600.0
const STAIR_X := 200.0
const RISE := 96.0
const RUN := 144.0

var _rig: Array = []


func run() -> void:
	Session.new_run()
	_test_stairs_geometry()
	await _test_walk_up_and_down(false)
	await _test_walk_up_and_down(true)
	await _test_stand_still_on_flight()
	await _test_jump_from_flight()
	await _test_land_on_flight()
	await _test_route_bot_climbs_flight()
	await _test_structure_look_keeps_collision()
	await _test_level_1_keeps_its_look()
	await _test_room_seam()
	Session.new_run()


# --- rig ------------------------------------------------------------------------------------------

func _build_rig(style: int = 0) -> Node2D:
	_free_rig()
	var floor_b: Node2D = BlockScript.new()
	floor_b.position = Vector2(-600.0, FLOOR_Y)
	floor_b.size = Vector2(1800.0, 200.0)
	add_child(floor_b)
	var landing: Node2D = BlockScript.new()
	landing.position = Vector2(STAIR_X + RUN, FLOOR_Y - RISE)
	landing.size = Vector2(600.0, RISE)
	add_child(landing)
	var st: Node2D = load(STAIRS_SCENE).instantiate()
	st.position = Vector2(STAIR_X, FLOOR_Y)
	st.set("style", style)
	add_child(st)
	_rig = [floor_b, landing, st]
	return st


func _free_rig() -> void:
	for n in _rig:
		if is_instance_valid(n):
			n.queue_free()
	_rig = []


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load(HERO_SCENE).instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	hero.aim_override = pos + Vector2(400.0, 0.0)
	return hero


func _free(n: Node) -> void:
	if is_instance_valid(n):
		n.queue_free()
	await physics_frames(1)


# --- stairs -----------------------------------------------------------------------------------------

func _test_stairs_geometry() -> void:
	var st: Node2D = StairsScript.new()
	st.set("rise", 96.0)
	st.set("run", 144.0)
	check_eq(st.call("collision_polygon"), PackedVector2Array([Vector2(0, 0), Vector2(144, -96), Vector2(144, 0)]),
			"a flight rising right is solid over its footprint, high side vertical")
	check(absf(float(st.call("surface_y", 124.0)) + 96.0) < 0.01 and absf(float(st.call("surface_y", -20.0))) < 0.01,
			"the drawn walking line is the footprint's diagonal moved half the hero's width downhill")
	st.set("direction", -1)
	check_eq(st.call("collision_polygon"), PackedVector2Array([Vector2(0, -96), Vector2(144, 0), Vector2(0, 0)]),
			"a flight rising left mirrors it")
	check(absf(float(st.call("surface_y", 20.0)) + 96.0) < 0.01 and absf(float(st.call("surface_y", 164.0))) < 0.01,
			"and its walking line too")
	check_eq(st.call("step_count"), 8, "a 96 px flight has 8 treads (12 px steps)")
	st.free()
	var degs: float = rad_to_deg(atan2(RISE, RUN))
	check(degs < 45.0, "the kit's stair (1.0 H over 1.5 H, %.1f deg) is under the hero's floor_max_angle" % degs)


## Walks from the floor up the flight onto the landing and back down. On the way down he must
## never be airborne for more than one frame in a row (the snap keeps him on the floor), his
## feet stay on the drawn walking line, and he reaches the landing and the floor.
func _test_walk_up_and_down(ramp: bool) -> void:
	var label := "ramp" if ramp else "stairs"
	var st := _build_rig(StairsScript.Style.RAMP if ramp else StairsScript.Style.STAIRS)
	var hero := _make_hero(Vector2(40.0, FLOOR_Y))
	await physics_frames(4)
	check(hero.is_on_floor(), "%s: starts on the floor" % label)
	press(&"move_right")
	var air_up := 0
	var max_off := 0.0
	for i in 70:
		await physics_frames(1)
		if not hero.is_on_floor():
			air_up += 1
		var lx: float = hero.global_position.x - st.global_position.x
		if lx > -15.0 and lx < RUN - 25.0:
			max_off = maxf(max_off, absf((hero.global_position.y - st.global_position.y) - float(st.call("surface_y", lx))))
	release(&"move_right")
	check(hero.global_position.x > STAIR_X + RUN + 40.0 and absf(hero.global_position.y - (FLOOR_Y - RISE)) < 1.0,
			"%s: walking up reaches the landing (at %s)" % [label, hero.global_position])
	check_eq(air_up, 0, "%s: never airborne walking up (frames)" % label)
	check(max_off < 2.0, "%s: his feet stay on the drawn walking line going up (off by %.2f px)" % [label, max_off])
	await physics_frames(10)
	press(&"move_left")
	var run_air := 0
	var max_run_air := 0
	var squash := false
	var aim_limited := true
	for i in 80:
		await physics_frames(1)
		if hero.is_on_floor():
			run_air = 0
		else:
			run_air += 1
			max_run_air = maxi(max_run_air, run_air)
		var lx: float = hero.global_position.x - st.global_position.x
		if lx > -15.0 and lx < RUN - 25.0:
			# On the flight the ground aim limit holds (it reads is_on_floor()).
			var lim: Vector2 = hero.limit_ground_aim(Vector2(float(hero.facing) * 0.3, 1.0))
			aim_limited = aim_limited and atan2(lim.y, absf(lim.x)) <= deg_to_rad(45.0) + 0.001
			if hero.get("_land_squash_timer") > 0.0:
				squash = true
	release(&"move_left")
	check(hero.global_position.x < STAIR_X - 40.0 and absf(hero.global_position.y - FLOOR_Y) < 1.0,
			"%s: walking down reaches the floor (at %s)" % [label, hero.global_position])
	check(max_run_air <= 1, "%s: never airborne for more than a frame walking down (longest %d)" % [label, max_run_air])
	check(not squash, "%s: no landing squash while walking down" % label)
	check(aim_limited, "%s: the ground aim limit holds all the way down" % label)
	await _free(hero)
	_free_rig()
	await physics_frames(1)


func _test_stand_still_on_flight() -> void:
	var st := _build_rig()
	var hero := _make_hero(Vector2(40.0, FLOOR_Y))
	await physics_frames(4)
	press(&"move_right")
	while hero.global_position.x < STAIR_X + RUN * 0.5:
		await physics_frames(1)
	release(&"move_right")
	await physics_frames(20)
	var p0 := hero.global_position
	await seconds(1.5)
	check(hero.is_on_floor(), "standing on a flight he is on the floor")
	check(hero.global_position.distance_to(p0) < 0.5,
			"standing still on a flight he never slides (moved %.2f px)" % hero.global_position.distance_to(p0))
	check(absf((p0.y - st.global_position.y) - float(st.call("surface_y", p0.x - st.global_position.x))) < 2.0,
			"he stands on the drawn walking line")
	await _free(hero)
	_free_rig()
	await physics_frames(1)


func _test_jump_from_flight() -> void:
	_build_rig()
	var hero := _make_hero(Vector2(40.0, FLOOR_Y))
	await physics_frames(4)
	press(&"move_right")
	while hero.global_position.x < STAIR_X + RUN * 0.4:
		await physics_frames(1)
	release(&"move_right")
	await physics_frames(10)
	var y0 := hero.global_position.y
	press(&"jump")
	var min_y := y0
	var left := false
	var landed := false
	for i in 90:
		await physics_frames(1)
		min_y = minf(min_y, hero.global_position.y)
		if not hero.is_on_floor():
			left = true
		elif left:
			landed = true
			break
	release(&"jump")
	check(left, "a jump from a flight leaves the floor")
	check(y0 - min_y > 1.4 * Hero.H, "a held jump from a flight is a full jump (%.0f px)" % (y0 - min_y))
	check(landed, "and he lands again")
	await physics_frames(20)
	check(hero.is_on_floor() and absf(hero.velocity.x) < 1.0, "he comes to rest on the flight after the jump")
	await _free(hero)
	_free_rig()
	await physics_frames(1)


func _test_land_on_flight() -> void:
	var st := _build_rig()
	var hero := _make_hero(Vector2(STAIR_X + RUN * 0.5, FLOOR_Y - 300.0))
	for i in 60:
		await physics_frames(1)
	var p0 := hero.global_position
	await seconds(1.0)
	check(hero.is_on_floor(), "dropped onto a flight he lands on it")
	check(hero.global_position.distance_to(p0) < 0.5, "and stays put")
	check(absf((p0.y - st.global_position.y) - float(st.call("surface_y", p0.x - st.global_position.x))) < 2.0,
			"on the drawn walking line")
	await _free(hero)
	_free_rig()
	await physics_frames(1)


## A small area with a flight up to a landing and a flight down again; the RouteBot walks it with
## plain MOVE points.
func _test_route_bot_climbs_flight() -> void:
	var area: Node2D = Node2D.new()
	area.set_script(AreaRootScript)
	area.set("area_id", "L02-TEST")
	area.set("width", 1600.0)
	area.position = Vector2(0.0, FLOOR_Y)
	add_child(area)
	var geo: Node = area.get_node("Geometry")
	var f: Node2D = BlockScript.new()
	f.position = Vector2(0.0, 0.0)
	f.size = Vector2(1600.0, 200.0)
	geo.add_child(f)
	var landing: Node2D = BlockScript.new()
	landing.position = Vector2(544.0, -RISE)
	landing.size = Vector2(400.0, RISE)
	geo.add_child(landing)
	for d in [[400.0, 1], [944.0, -1]]:
		var st: Node2D = StairsScript.new()
		st.position = Vector2(d[0], 0.0)
		st.set("direction", d[1])
		geo.add_child(st)
	var route: Node = area.get_node("Route")
	for x in [700.0, 1300.0]:
		var p := RoutePoint.new()
		p.position = Vector2(x, 0.0)
		route.add_child(p)
	var hero := _make_hero(area.global_position + Vector2(100.0, 0.0))
	await physics_frames(4)
	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(area)
	bot.start(hero)
	var peak := hero.global_position.y
	var t := 0.0
	while bot.running and t < 10.0:
		await physics_frames(1)
		t += 1.0 / Engine.physics_ticks_per_second
		peak = minf(peak, hero.global_position.y)
	var rep: Dictionary = bot.get_report()
	check(bool(rep["success"]), "the RouteBot walks up a flight and down another (%s)" % rep["failure"])
	check(absf(peak - (FLOOR_Y - RISE)) < 2.0, "it climbed onto the landing on the way")
	check(absf(hero.global_position.y - FLOOR_Y) < 1.0, "and came down to the floor")
	bot.queue_free()
	await _free(hero)
	area.queue_free()
	await physics_frames(2)


# --- the structure look ---------------------------------------------------------------------------

## Every Level 2 area: each Block keeps the position, size and kind its scene stores, its one
## generated shape is the rectangle over exactly that, on the world layer, after the lab look has
## drawn; the roles are as designed and every catwalk deck finds a support.
func _test_structure_look_keeps_collision() -> void:
	var roles := {}
	var decks := 0
	var unsupported: Array = []
	for path in L02_AREAS:
		var packed: PackedScene = load(path)
		var stored := _stored_blocks(packed)
		var area: Node2D = packed.instantiate()
		add_child(area)
		await physics_frames(2)
		for b in area.get_node("Geometry").get_children():
			if not (b is Block):
				continue
			b.queue_redraw()
		await physics_frames(2)
		for b in area.get_node("Geometry").get_children():
			if not (b is Block):
				continue
			var key := "%s/%s" % [path.get_file(), b.name]
			var want: Dictionary = stored.get(String(b.name), {})
			check(not want.is_empty(), "%s is stored in its scene" % key)
			if want.is_empty():
				continue
			check(b.position == want["position"] and b.size == want["size"] and int(b.kind) == want["kind"],
					"%s keeps its stored position/size/kind" % key)
			var shapes: Array = b.get_children().filter(func(n): return n is CollisionShape2D or n is CollisionPolygon2D)
			check_eq(shapes.size(), 1, "%s has exactly one collision shape" % key)
			var cs := shapes[0] as CollisionShape2D
			var rect := cs.shape as RectangleShape2D if cs else null
			check(rect != null and rect.size == b.size and cs.position == b.size * 0.5 and b.collision_layer == 1,
					"%s's collision is the rectangle over its size on the world layer" % key)
			var role: String = b.lab_structure()
			roles[role] = int(roles.get(role, 0)) + 1
			if role == "deck":
				decks += 1
				if int(Arch.deck_supports(b)["mode"]) == Arch.S_NONE:
					unsupported.append(key)
		area.queue_free()
		await physics_frames(2)
	check(int(roles.get("raised", 0)) >= 8, "raised floors and boxes get the panelled fascia (%d)" % int(roles.get("raised", 0)))
	check(int(roles.get("floor", 0)) >= 10, "the area floors get the sub-floor look (%d)" % int(roles.get("floor", 0)))
	check(int(roles.get("ceiling", 0)) >= 5, "ceilings get beams and light troughs (%d)" % int(roles.get("ceiling", 0)))
	check(decks >= 10, "thin platforms are catwalk decks (%d)" % decks)
	check(unsupported.is_empty(), "every catwalk deck finds a ceiling or a floor to hang from or stand on (%s)" % str(unsupported))
	check(int(roles.get("", 0)) >= 3, "benches and crates keep their painted lab skins (%d)" % int(roles.get("", 0)))


## name -> {position, size, kind} for each Block node stored in `packed` (defaults filled in).
func _stored_blocks(packed: PackedScene) -> Dictionary:
	var out := {}
	var st := packed.get_state()
	for i in st.get_node_count():
		var props := {}
		var is_block := false
		for j in st.get_node_property_count(i):
			var pname := st.get_node_property_name(i, j)
			var v = st.get_node_property_value(i, j)
			if pname == "script" and v is Script and (v as Script).resource_path.ends_with("world/block.gd"):
				is_block = true
			props[pname] = v
		if is_block:
			out[String(st.get_node_name(i))] = {
				"position": props.get("position", Vector2.ZERO),
				"size": props.get("size", Vector2(192, 48)),
				"kind": int(props.get("kind", 0)),
			}
	return out


## Level 1's depot is indoors but not the lab: none of its blocks take a structure role.
func _test_level_1_keeps_its_look() -> void:
	var area: Node2D = load(L01_DEPOT).instantiate()
	add_child(area)
	await physics_frames(2)
	var n := 0
	var roles: Array = []
	for b in area.get_node("Geometry").get_children():
		if b is Block:
			n += 1
			if b.lab_structure() != "":
				roles.append(b.name)
	check(n > 0 and roles.is_empty(), "no Level 1 depot block takes a lab structure role (%s)" % str(roles))
	area.queue_free()
	await physics_frames(2)


func _test_room_seam() -> void:
	var roof: Node2D = BlockScript.new()
	roof.position = Vector2(-200.0, FLOOR_Y - 480.0)
	roof.size = Vector2(400.0, 40.0)
	roof.kind = BlockScript.Kind.ROOF
	add_child(roof)
	var seam: Node2D = SeamScript.new()
	seam.position = Vector2(0.0, FLOOR_Y)
	add_child(seam)
	await physics_frames(2)
	check(absf(float(seam.call("resolved_height")) - 440.0) < 0.5, "a seam reaches up to the ceiling above it")
	check(seam.get_children().filter(func(n): return n is CollisionObject2D).is_empty(), "a seam is visual by default")
	seam.set("solid_lintel", true)
	await physics_frames(2)
	var q := PhysicsPointQueryParameters2D.new()
	q.collision_mask = 1
	q.position = Vector2(0.0, FLOOR_Y - 300.0)
	check(not roof.get_world_2d().direct_space_state.intersect_point(q).is_empty(), "solid_lintel makes the pier above the opening solid")
	q.position = Vector2(0.0, FLOOR_Y - 100.0)
	check(roof.get_world_2d().direct_space_state.intersect_point(q).is_empty(), "the opening itself stays open")
	seam.set("style", SeamScript.Style.AIRLOCK)
	seam.set("solid_lintel", false)
	await physics_frames(2)
	check(seam.get_children().filter(func(n): return n is CollisionObject2D and not n.is_queued_for_deletion()).is_empty(),
			"turning solid_lintel off removes the solid")
	seam.queue_free()
	roof.queue_free()
	await physics_frames(2)
