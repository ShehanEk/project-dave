extends TestCase
## Batch 7: Level 2's hand-painted lab art (tools/art/import_hd_env.py --batch7,
## import_hd_ui.py --batch7; scripts/world/lab_skins.gd).
##   1. Every indoor Level 2 area wears the lab: its interior look is "lab" and its backdrop
##      layers are AreaBackdrop LAB (the atrium far layer behind the lab strip; a storey layer
##      draws the strip only); Level 1's depot keeps DEPOT and its blocks keep their skins.
##   2. The Lattice hologram in A05: additive, no collision, a teal light; animated, and static
##      under Reduced motion.
##   3. The lab props and doors are placed and their pieces exist: the range bench and the
##      backstop crates, the kennel pods, benches, pods, racks, crates, tanks and doors, the
##      lane control pads, the A04 partitions and rail lamps, the alignment console, the
##      freight lift door (closed, then open with the card) and the dummy practice targets.
##   4. The new effects resolve and are wired: the pistol's flash, round and impact, the
##      Broom's blast, pellets and casing, the drone's shock arc, the Hound's lunge dust.
##   5. The HUD icons exist and Level 2 names its own card and memo.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const L01_DEPOT := "res://scenes/levels/areas/a05_depot.tscn"
const LabSkins := preload("res://scripts/world/lab_skins.gd")
const PixelFx := preload("res://scripts/effects/pixel_fx.gd")
const PixelUi := preload("res://scripts/ui/pixel_ui.gd")
const HOLOGRAM := "res://scripts/world/visuals/lattice_hologram.gd"
const BlastTrails := preload("res://scripts/effects/blast_trails.gd")
const LAB_MODE := 3
const DEPOT_MODE := 2
## Effect -> frames.
const EFFECTS := {
	"pistol_flash": 4, "pistol_round": 1, "pistol_impact": 4, "shotgun_blast": 4,
	"shotgun_pellets": 1, "shell_casing": 3, "shock_arc": 4, "lunge_dust": 4,
}
## Area index -> {scenery node: lab piece}.
const PROPS := {
	0: {"BridgeDoor": "glass_door_open", "ExitBench": "lab_bench", "CoolantTank1": "coolant_tank"},
	1: {"KennelPod1": "kennel_pod", "KennelPod2": "kennel_pod", "KennelPod3": "kennel_pod",
		"LaneDivider1": "lane_divider", "ControlBench": "lab_bench"},
	2: {"Workstation": "lab_bench", "OpenDoor": "security_door_open", "GroundRack1": "server_rack"},
	3: {"DeskPod": "office_pod", "PodDoor": "security_door_open", "ChipRack1": "server_rack"},
	4: {"ArchiveRack1": "server_rack", "LandingBench": "lab_bench"},
	5: {"ProtoBench1": "proto_crate", "ProtoBench2": "proto_crate", "EntryTank": "coolant_tank"},
}


func run() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)
	_test_pieces_exist()
	Session.new_run("L02")
	var lvl := await _build_level()
	_test_backdrops(lvl)
	_test_hologram_in_level(lvl)
	_test_props_and_doors(lvl)
	await _test_freight_door_opens(lvl)
	await _free(lvl)
	await _test_level_1_unchanged()
	await _test_hologram_reduced_motion()
	await _test_effects()
	_test_hud_icons()
	Settings.set_reduced_motion(base_reduced)
	CheckpointService.clear()
	Session.new_run()


func _build_level() -> LevelDirector:
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	await physics_frames(3)
	return lvl


func _free(node) -> void:
	if is_instance_valid(node):
		node.queue_free()
	await physics_frames(2)


func _test_pieces_exist() -> void:
	for piece in ["lab_backdrop", "atrium_far", "lattice", "lab_bench", "office_pod", "server_rack", "partition",
			"rail_lamps", "control_pad", "test_dummy", "range_bench", "lane_divider", "kennel_pod",
			"alignment_console", "proto_crate", "coolant_tank", "freight_door_closed", "freight_door_open",
			"glass_door_closed", "glass_door_open", "security_door_closed", "security_door_open"]:
		check(LabSkins.has(piece), "the lab piece %s is imported" % piece)
	# Real-world sizes at Level 1's scale (H = 96 px): the prompt's sizes in person heights.
	check(absf(LabSkins.world_size("server_rack").y - 1.1 * 96.0) < 1.0, "the server rack is 1.1 H tall")
	check(absf(LabSkins.world_size("freight_door_closed").y - 2.2 * 96.0) < 1.0, "the freight lift door is 2.2 H tall")
	check(absf(LabSkins.world_size("test_dummy").y - 96.0) < 1.0, "the test dummy is a person tall")
	check_eq(LabSkins.world_size("freight_door_open"), LabSkins.world_size("freight_door_closed"),
			"the lift door's two states line up")
	var lamps: Array = LabSkins.value("rail_lamps", "lamps", [])
	check_eq(lamps.size(), 3, "the rail segment's three lamps are recorded")


func _test_backdrops(lvl: LevelDirector) -> void:
	var main_layers := {0: "Background/Plant/Interior", 1: "Background/Interior", 2: "Background/Interior",
			3: "Background/Interior", 4: "Background/Interior", 5: "Background/Interior"}
	for i in 6:
		var a: AreaRoot = lvl.areas[i]
		check_eq(a.interior_look, "lab", "%s wears the lab look" % a.area_id)
		var layer: Node = a.get_node_or_null(main_layers[i])
		check(layer != null and int(layer.mode) == LAB_MODE, "%s's interior backdrop is the LAB mode" % a.area_id)
		if layer:
			check(layer.lab_far, "%s's main layer draws the atrium far layer" % a.area_id)
			check(layer.is_lab_painted(), "%s draws the painted lab, not the depot fallback" % a.area_id)
		for n in a.get_node("Background").find_children("*", "Parallax2D", true, false):
			if n.get("mode") != null and n != layer and String(n.get_parent().name) != "Background":
				check(int(n.mode) == LAB_MODE and not n.lab_far, "%s's storey layer %s draws the lab strip only" % [a.area_id, n.get_parent().name])
	# The bridge (outdoors) keeps the campus sky.
	check_eq(int(lvl.areas[0].get_node("Background/Sky").mode), 0, "the sky bridge keeps its sky")


func _test_hologram_in_level(lvl: LevelDirector) -> void:
	var a05: AreaRoot = lvl.areas[4]
	var holo: Node2D = a05.get_node_or_null("Scenery/Hologram")
	check(holo != null and holo.get_script() != null and holo.get_script().resource_path == HOLOGRAM,
			"A05's Lattice hologram stands at its slot")
	if holo == null:
		return
	var slot: Node2D = a05.get_node_or_null("Entities/Slot_Hologram")
	if slot:
		check(absf(holo.position.x - slot.position.x) < 1.0, "the hologram is at Slot_Hologram's x")
	check(holo.has_art(), "the hologram draws the painted lattice")
	var mat := holo.material as CanvasItemMaterial
	check(mat != null and mat.blend_mode == CanvasItemMaterial.BLEND_MODE_ADD, "the hologram is drawn additively")
	check(holo.find_children("*", "CollisionObject2D", true, false).is_empty(), "the hologram has no collision")
	check(holo.find_children("*", "CollisionShape2D", true, false).is_empty(), "...and no shape")
	var lights := holo.find_children("*", "PointLight2D", true, false)
	check(lights.size() == 1 and (lights[0] as PointLight2D).color.is_equal_approx(Color("#3FE0D0")),
			"a teal light stands by it")
	check(holo.is_animated(), "it animates (slow pulse and turn) with motion on")
	check(holo.z_index < 0, "it stands behind the actors")


func _test_props_and_doors(lvl: LevelDirector) -> void:
	for i in PROPS:
		var a: AreaRoot = lvl.areas[i]
		for node_name in PROPS[i]:
			var s: Scenery = a.get_node_or_null("Scenery/" + node_name)
			check(s != null and s.kind == Scenery.Kind.LAB_PROP and s.lab_piece == PROPS[i][node_name],
					"%s: %s is the painted %s" % [a.area_id, node_name, PROPS[i][node_name]])
	check(lvl.areas[5].get_node_or_null("Scenery/LiftDoor") == null, "A06's stand-in lift door is gone (the wicket is the door)")
	var bench: Block = lvl.areas[1].get_node("Geometry/RangeBench")
	check_eq(bench.lab_skin(), "range_bench", "the range bench (cover block) wears the painted bench")
	check_eq(lvl.areas[1].get_node("Geometry/KennelWall").lab_skin(), "proto_crate", "the kennel backstop is a crate stack")
	for n in ["DockBackstopL", "DockBackstopR", "CrateStack"]:
		check_eq(lvl.areas[5].get_node("Geometry/" + n).lab_skin(), "proto_crate", "A06's %s is backstop crates" % n)
	check_eq(lvl.areas[1].get_node("Geometry/FloorRange").lab_skin(), "", "a floor keeps its terrain skin")
	for p in ["ControlPad_SW01", "ControlPad_SW02", "ControlPad_SW03"]:
		check_eq(lvl.areas[3].get_node("Entities/" + p).lab_piece(), "control_pad", "A04's %s is the lane control pad" % p)
	for t in ["PracticeTarget_1", "PracticeTarget_2", "PracticeTarget_3"]:
		check_eq(lvl.areas[0].get_node("Entities/" + t).lab_piece(), "test_dummy", "A01's %s is the test dummy" % t)
	# The A04 lanes: the painted partition and the rail lamps along the trench.
	var rack = lvl.areas[3].get_node("Geometry/RailRack_1")
	var x0: float = rack.point_a.x - rack.width * 0.5 + 12.0
	var x1: float = rack.point_b.x + rack.width * 0.5 - 12.0
	var lamps: Array = rack.rail_lamps(x0, x1, 26.0)
	check(lamps.size() >= 4, "the painted rail has a lamp every bay (%d)" % lamps.size())
	var inside := true
	for l in lamps:
		inside = inside and (l as Vector2).x >= x0 - 30.0 and (l as Vector2).x <= x1 + 30.0
	check(inside, "the rail lamps run from bank to bank under the deck")
	check(LabSkins.has("partition"), "the lane partitions draw the painted glass panel")


func _test_freight_door_opens(lvl: LevelDirector) -> void:
	var lift = lvl.areas[5].get_node("Entities/FreightLift")
	check_eq(lift.lab_piece(), "freight_door_closed", "the freight lift is shut without the card")
	var console = lvl.areas[4].get_node("Entities/AlignmentConsole")
	check(console != null, "the alignment console is in A05")
	Session.take_keycard("L02-KC01", "L02-KC01-P")
	await physics_frames(1)
	check_eq(lift.lab_piece(), "freight_door_open", "the lift door opens once the card is held")


func _test_level_1_unchanged() -> void:
	var depot: Node = load(L01_DEPOT).instantiate()
	add_child(depot)
	await physics_frames(2)
	check_eq(str(depot.interior_look), "depot", "Level 1's depot keeps the depot look")
	var interior: Node = depot.get_node_or_null("Background/Interior")
	check(interior != null and int(interior.mode) == DEPOT_MODE, "Level 1's depot backdrop stays DEPOT")
	var lab_blocks := 0
	for b in depot.find_children("*", "StaticBody2D", true, false):
		if b is Block and (b as Block).lab_skin() != "":
			lab_blocks += 1
	check_eq(lab_blocks, 0, "no Level 1 block wears a lab skin")
	await _free(depot)


func _test_hologram_reduced_motion() -> void:
	Settings.set_reduced_motion(true)
	var holo: Node2D = load(HOLOGRAM).new()
	add_child(holo)
	await physics_frames(2)
	check(not holo.is_animated(), "under Reduced motion the hologram is static")
	check(not holo.is_processing(), "...and does not process")
	await _free(holo)
	Settings.set_reduced_motion(false)


func _test_effects() -> void:
	for fx_name in EFFECTS:
		check(PixelFx.has_fx(fx_name), "%s: its painted strip resolves" % fx_name)
		check_eq(PixelFx.frame_count(fx_name), EFFECTS[fx_name], "%s: frame count" % fx_name)
		var node: Sprite2D = PixelFx.spawn(fx_name, Vector2(200.0, 200.0), self)
		check(node != null, "%s spawns" % fx_name)
		if node:
			node.queue_free()
	# The Sidearm Guard's round: the painted slug instead of the drawn streak.
	var round: Node2D = load("res://scenes/weapons/pistol_round.tscn").instantiate()
	add_child(round)
	round.setup(Vector2(100.0, 100.0), Vector2.LEFT, 0.0, 600.0)
	var slugs := round.get_children().filter(func(c): return c.get_script() == PixelFx and c.effect == "pistol_round")
	check_eq(slugs.size(), 1, "the pistol round carries the painted slug")
	if not slugs.is_empty():
		check(absf(absf((slugs[0] as Node2D).rotation) - PI) < 0.01, "...turned along its flight")
	round.queue_free()
	# A blocked round's impact plays the painted pistol impact.
	var spark := ImpactSpark.new()
	spark.effect = "pistol_impact"
	spark.dir = Vector2.RIGHT
	spark.shape = ImpactSpark.Shape.BLOCKED
	add_child(spark)
	var fx := spark.get_children().filter(func(c): return c.get_script() == PixelFx)
	check(fx.size() == 1 and fx[0].effect == "pistol_impact", "the round's impact is the pistol impact")
	if fx.size() == 1:
		# Fanned back toward the shooter (its up turned to -dir).
		var up: Vector2 = Vector2.UP.rotated((fx[0] as Node2D).rotation)
		check(up.dot(Vector2.LEFT) > 0.99, "the impact's sparks fan back against the shot")
	# The Broom's pellet spray rides in its blast trails.
	var trails: Node2D = BlastTrails.spawn(self, Vector2(50.0, 50.0), Vector2.RIGHT, [], 0.09, false)
	var spray := trails.get_children().filter(func(c): return c.get_script() == PixelFx and c.effect == "shotgun_pellets")
	check_eq(spray.size(), 1, "the blast trails burst the painted pellet spray")
	# The drone's fork crackles with the shock arc through its dive.
	var drone = load("res://scenes/actors/security_drone.tscn").instantiate()
	add_child(drone)
	drone.global_position = Vector2(400.0, -2000.0)
	await physics_frames(2)
	if drone.has_method("_spawn_arc"):
		check(drone._spawn_arc() != null, "the drone's fork tip plays the shock arc")
	# The Hound kicks up lunge dust.
	var floor_block := Block.new()
	floor_block.size = Vector2(800.0, 40.0)
	floor_block.position = Vector2(-400.0, 3000.0)
	add_child(floor_block)
	var hound = load("res://scenes/actors/hound.tscn").instantiate()
	add_child(hound)
	hound.global_position = Vector2(0.0, 2990.0)
	await physics_frames(20)
	check(hound.is_on_floor(), "the test Hound stands on the floor")
	check(hound._kick_dust() != null, "the Hound's lunge kicks up the painted dust")
	await _free(drone)
	await _free(hound)
	await _free(floor_block)
	await _free(trails)
	await _free(spark)


func _test_hud_icons() -> void:
	for piece in ["weapon_boom_broom", "shell_lit", "shell_unlit", "keycard_l2", "evidence_memo"]:
		check(PixelUi.has_piece(piece), "the HUD icon %s is imported" % piece)
	var def := LevelDefs.get_def("L02")
	check_eq(def.keycard_icon, "keycard_l2", "Level 2's card has its own HUD icon")
	check_eq(def.evidence_icon, "evidence_memo", "Level 2's evidence toast shows the memo")
	check_eq(LevelDefs.get_def("L01").keycard_icon, "keycard", "Level 1 keeps its card icon")
