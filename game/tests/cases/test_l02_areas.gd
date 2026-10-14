extends TestCase
## Level 2 "Alignment", the whole level (v2, C62: scenes/levels/l02/a01..a06, data/levels/l02.tres;
## blueprint prototype-plans/level-02-alignment/area-blueprints-v2.md). The level-wide view; each
## area's own layout, set pieces and fair fights are tests/cases/test_l02v2_*.gd:
##   - the LevelDef, the six areas' widths (40,800 px) and seams, the indoor look and the A01 sky
##     bridge's rain (outdoors to x 1,100), the sound;
##   - checkpoints CP00, CP00B, CP01-CP05 (+ the A03 workbench's UPG01) that are safe to stand on,
##     one recovery station per checkpoint id;
##   - the microchip economy (60 on the main route, the drill, armory and rack trays 10 + 5 + 5 and
##     the dock's 20-chip cache: chip_total 100), the evidence file, the encounters (the v2 groups
##     E01-E27 and the A03 launch rack, no slot left), the prompts;
##   - the A05 console's keycard and the A06 freight lift's hold-out (45 s, three waves: with the
##     card the level ends only once the override is over and Dave is in the gate);
##   - the A04 lockdown lanes (racks wait for their pad, never close on Dave, the upper ledge always
##     gets him through), and the RouteBot finishing the level start to finish (and the dock branch).
## Every sub-test starts by freeing whatever an earlier one left behind (a script error aborts a
## sub-test before its own clean-up, and a stray level's door or hero must never drive the next).

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const A04_SCENE := "res://scenes/levels/l02/a04_training_cells.tscn"
const A06_SCENE := "res://scenes/levels/l02/a06_demo_floor.tscn"
const RailRack := preload("res://scripts/objects/rail_rack.gd")
const LanePartition := preload("res://scripts/objects/lane_partition.gd")
const KeycardConsole := preload("res://scripts/objects/keycard_console.gd")
const ReleasePod := preload("res://scripts/objects/release_pod.gd")
const AmbienceMap := preload("res://scripts/audio/ambience_map.gd")
const SurfaceMap := preload("res://scripts/world/surface_map.gd")
const TerrainSkins := preload("res://scripts/world/terrain_skins.gd")
const NIGHT_GUARD_SCENE := "res://scenes/actors/night_guard.tscn"
const STAFFER_SCENE := "res://scenes/actors/staffer.tscn"
const SIDEARM_GUARD_SCENE := "res://scenes/actors/sidearm_guard.tscn"
const SECURITY_DRONE_SCENE := "res://scenes/actors/security_drone.tscn"
const HOUND_SCENE := "res://scenes/actors/hound.tscn"
const ROVER_SCENE := "res://scenes/actors/patrol_rover.tscn"
const TYPE_BY_SCENE := {
	NIGHT_GUARD_SCENE: "SE01", STAFFER_SCENE: "LK01", ROVER_SCENE: "M01",
	SIDEARM_GUARD_SCENE: "SE02", HOUND_SCENE: "K01", SECURITY_DRONE_SCENE: "M02",
}

const AREA_IDS: Array[String] = ["L02-A01", "L02-A02", "L02-A03", "L02-A04", "L02-A05", "L02-A06"]
const AREA_WIDTHS: Array[float] = [6200.0, 7800.0, 6400.0, 7000.0, 6000.0, 7400.0]
const LEVEL_WIDTH := 40800.0
## A01's sky bridge is outdoors up to here (the bridge door stands at x 1,120).
const WET_UNTIL := 1100.0
## Loose microchips per area (worth 1 each; a few wait inside breakables).
const CHIPS_PER_AREA: Array[int] = [9, 10, 10, 9, 10, 12]
const MAIN_CHIPS := 60
## The set-piece trays: id -> [area index, value, node].
const TRAYS := {
	"L02-A01-CACHE01": [0, 10, "Entities/DrillTray"],
	"L02-A02-CACHE01": [1, 5, "Entities/ArmoryTray"],
	"L02-A03-CACHE01": [2, 5, "Entities/RackCache"],
}
const TRAYS_VALUE := 20
const CACHE_ID := "L02-OPT01-CACHE01"
const CACHE_VALUE := 20
## The beat zones (22) plus the range's L02-A02-B04, reported through BeatHub by RangeLive.
const BEATS_TOTAL := 23
## Group id -> its area and what it fields (type codes: SE01 Night Guard, LK01 Staffer, M01
## Patrol Rover, SE02 Sidearm Guard, K01 Hound, M02 Security Drone).
const ENCOUNTERS := {
	"L02-E01": {"area": 0, "SE01": 2},
	"L02-E02": {"area": 0, "LK01": 2},
	"L02-E03": {"area": 0, "M01": 1},
	"L02-E04": {"area": 0, "SE01": 1},
	"L02-E05": {"area": 0, "SE01": 1, "LK01": 1},
	"L02-E06": {"area": 1, "LK01": 1, "SE01": 1},
	"L02-E07": {"area": 1, "SE02": 1},
	"L02-E08": {"area": 1, "SE02": 2},
	"L02-E08-D": {"area": 1, "SE01": 1},
	"L02-E09": {"area": 1, "SE01": 1, "K01": 1},
	"L02-E10": {"area": 1, "SE01": 1},
	"L02-E10-P1": {"area": 1, "K01": 1},
	"L02-E10-P2": {"area": 1, "K01": 1},
	"L02-E11": {"area": 2, "LK01": 1},
	"L02-E12": {"area": 2, "M02": 1},
	"L02-A03-RACK01": {"area": 2, "M02": 3},
	"L02-E13": {"area": 2, "LK01": 1},
	"L02-E14": {"area": 2, "SE02": 1, "M02": 1},
	"L02-E15": {"area": 3, "LK01": 2},
	"L02-E16": {"area": 3, "SE01": 1},
	"L02-E17P": {"area": 3, "LK01": 2},
	"L02-E17": {"area": 3, "LK01": 2, "M02": 1},
	"L02-E18": {"area": 3, "SE01": 1, "SE02": 1},
	"L02-E19": {"area": 4, "SE01": 2, "K01": 1},
	"L02-E20": {"area": 4, "SE02": 1, "M02": 1},
	"L02-E21": {"area": 4, "LK01": 2},
	"L02-E22": {"area": 4, "SE02": 2},
	"L02-E23": {"area": 5, "SE01": 1, "LK01": 1},
	"L02-E24-P1": {"area": 5, "M01": 1},
	"L02-E24-P2": {"area": 5, "M01": 1},
	"L02-E24": {"area": 5, "SE02": 1},
	"L02-E25": {"area": 5, "SE01": 1},
	"L02-E25-C1": {"area": 5, "M02": 1},
	"L02-E25-C2": {"area": 5, "M02": 1},
	"L02-E26-W1": {"area": 5, "SE01": 1, "K01": 1},
	"L02-E26-W2": {"area": 5, "SE01": 2},
	"L02-E26-W3": {"area": 5, "SE02": 1, "M02": 1},
	"L02-E27": {"area": 5, "M01": 1},
}
## 60 on the route and the dock's optional rover (E27).
const ENEMY_TOTAL := 61
## The Hounds on a Night Guard's lead: hound -> its handler (same group).
const HANDLED_HOUNDS := {
	"L02-E09-K01-01": "L02-E09-SE01-01", "L02-E19-K01-01": "L02-E19-SE01-02", "L02-E26-K01-01": "L02-E26-SE01-01",
}
## No enemy stands this close to a checkpoint (px, horizontally).
const SAFE_RADIUS := 500.0
## Interaction prompts stand at least 3 H apart.
const PROMPT_SPACING := 288.0
const H := 96.0
## The freight lift's override (S7).
const OVERRIDE_S := 45.0


func run() -> void:
	_test_level_def()
	await _test_seams_floors_and_presentation()
	await _test_population()
	await _test_checkpoints()
	await _test_keycard_and_freight_lift()
	await _test_a04_lanes_wait_and_never_close_on_dave()
	await _test_a04_upper_ledge_recovery()
	await _test_a04_reload_keeps_lanes_open()
	await _test_route_bot_finishes_level_2()
	await _test_dock_branch_cache()
	await _clear_leftovers()
	CheckpointService.clear()
	Session.new_run()


func _build_level() -> LevelDirector:
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	await physics_frames(3)
	return lvl


func _free(node: Node) -> void:
	if is_instance_valid(node):
		node.queue_free()
	await physics_frames(2)


## Frees whatever an earlier sub-test left under this case (a level, a lone area, a hero, a
## bot): a script error aborts a sub-test before its own _free(), and a leaked level's door,
## floors and hero would otherwise drive or block the next one. Also lets go of every input.
func _clear_leftovers() -> void:
	release_all()
	var left := get_children()
	for c in left:
		c.queue_free()
	if not left.is_empty():
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


func _solid_between(lvl: Node, from: Vector2, to: Vector2) -> bool:
	var params := PhysicsRayQueryParameters2D.create(from, to)
	params.collision_mask = 1
	return not lvl.get_world_2d().direct_space_state.intersect_ray(params).is_empty()


## The encounter id an enemy's entity id is filed under: its group id without a phase suffix
## (-D side door, -P1/-P2 pods or plinths, -C1/-C2 cases, -W1..-W3 hold-out waves).
func _base_group_id(gid: String) -> String:
	var re := RegEx.create_from_string("-(D|P\\d|C\\d|W\\d)$")
	return re.sub(gid, "")


# --- 1. the LevelDef ------------------------------------------------------------------------

func _test_level_def() -> void:
	var def := LevelDefs.get_def("L02")
	check_eq(def.area_scenes.size(), 6, "Level 2 has six areas")
	for path in def.area_scenes:
		check(path.begins_with("res://scenes/levels/l02/") and ResourceLoader.exists(path), "area scene exists: %s" % path)
	check(not ResourceLoader.exists("res://scenes/levels/l02/a01_placeholder.tscn"), "the M1 placeholder area is gone")
	var want_markers := {
		"CP00": [0, "Spawn_CP00"], "CP00B": [0, "Respawn_CP00B"], "CP01": [1, "Respawn_CP01"],
		"CP02": [2, "Respawn_CP02"], "CP03": [3, "Respawn_CP03"], "CP04": [4, "Respawn_CP04"],
		"CP05": [5, "Respawn_CP05"], "UPG01": [2, "Respawn_UPG01"],
	}
	check_eq(def.checkpoint_markers, want_markers, "checkpoints CP00, A01's CP00B, CP01-CP05 and the workbench's UPG01")
	check_eq(def.first_checkpoint, "CP00", "Level 2 starts at CP00")
	check_eq(def.exit_checkpoint, "CP05", "...and ends by committing CP05")
	check_eq(def.switches, {"L02-SW01": false, "L02-SW02": false, "L02-SW03": false, "L02-SW04": false},
			"the three A04 lane switches and the A03 launch rack's L02-SW04 start off")
	check_eq(def.keycard_id, "L02-KC01", "the level's clearance keycard")
	check_eq(def.evidence_id, "EF02", "the level's evidence file")
	check_eq(def.evidence_name, "Reassignment Memo", "...the Reassignment Memo")
	check_eq(def.chip_total, MAIN_CHIPS + TRAYS_VALUE + CACHE_VALUE,
			"100 microchips: 60 on the route, the three set-piece trays (10 + 5 + 5) and the dock's 20-chip cache")
	check_eq(def.world_weapons, {"L02-W02-P01": "L02-A01-PAD01"}, "M3: the Boom Broom L02-W02-P01 rests on the A01 pad L02-A01-PAD01")
	check(def.beat_lines.has("L02-A02-B04"), "the range's beat L02-A02-B04 carries Adam's line")
	check(CheckpointService.validate_snapshot(JSON.parse_string(JSON.stringify(Session.default_state("L02")))).ok,
			"a fresh Level 2 state validates")


# --- 2. seams, floors, indoor look, rain and sound ---------------------------------------------

func _test_seams_floors_and_presentation() -> void:
	await _clear_leftovers()
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)
	Session.new_run("L02")
	var lvl := await _build_level()
	check_eq(lvl.areas.size(), 6, "Level 2 builds six areas")
	var x := 0.0
	for i in lvl.areas.size():
		var a: AreaRoot = lvl.areas[i]
		check_eq(a.area_id, AREA_IDS[i], "area %d is %s" % [i, AREA_IDS[i]])
		check_eq(a.width, AREA_WIDTHS[i], "%s is %d px wide" % [a.area_id, AREA_WIDTHS[i]])
		check(is_equal_approx(a.global_position.x, x), "%s starts where the area before it ends" % a.area_id)
		x += a.width
		check(a.indoors and a.interior_look == "lab", "%s is indoors and wears the lab" % a.area_id)
		check(a.camera_bottom - a.camera_top >= 600.0, "%s's camera band is at least a screen tall" % a.area_id)
		# AreaRoot contract: flat, clear floor at y 0 for 4 H at the entry and the exit seam.
		for lx in [10.0, 100.0, 200.0, 300.0, 380.0, a.width - 380.0, a.width - 200.0, a.width - 100.0, a.width - 10.0]:
			check(a.has_floor_at(lx), "%s has floor at y 0, x %d" % [a.area_id, int(lx)])
			var g := a.to_global(Vector2(lx, 0.0))
			check(not _solid_between(lvl, g + Vector2(0.0, -H - 4.0), g + Vector2(0.0, -6.0)),
					"%s: nothing solid over the seam floor at x %d" % [a.area_id, int(lx)])
		var spawn := a.get_marker("Spawn_CP00")
		check(spawn != null, "%s has a Spawn_CP00 for the area harness" % a.area_id)
	check(is_equal_approx(lvl.level_width, LEVEL_WIDTH), "Level 2 is 40,800 px across (got %.0f)" % lvl.level_width)
	check_eq(lvl.areas[0].wet_until_x, WET_UNTIL, "A01's sky bridge (x 0-1,100) is outdoors")
	for i in range(1, 6):
		check_eq(lvl.areas[i].wet_until_x, 0.0, "%s is indoors all through" % lvl.areas[i].area_id)
	var door: Node2D = lvl.areas[0].get_node_or_null("Entities/BridgeDoor")
	check(door != null and door.position.x >= WET_UNTIL and door.position.x - WET_UNTIL <= 40.0,
			"the bridge door stands just under the roof's edge (x %.0f)" % (door.position.x if door else -1.0))

	# Rain: only over the sky bridge; the indoors areas merge into one dry span.
	var atmos: Node = lvl.get_node_or_null("Atmosphere")
	check(atmos != null, "Level 2 has the rain and glow")
	if atmos:
		var a01x: float = lvl.areas[0].global_position.x
		check_eq(atmos._dry.size(), 1, "one merged dry span from the bridge door to the end (%s)" % str(atmos._dry))
		if atmos._dry.size() == 1:
			check(is_equal_approx(atmos._dry[0].x, a01x + WET_UNTIL) and is_equal_approx(atmos._dry[0].y, lvl.level_width),
					"the dry span runs from x 1,100 to the level's end (%s)" % str(atmos._dry[0]))
		check(atmos.is_wet(a01x + 400.0), "rain falls on the sky bridge")
		check(atmos.is_wet(a01x + WET_UNTIL - 60.0), "...right up to the bridge door")
		check(not atmos.is_wet(a01x + 1300.0), "no rain in the airlock")
		check(not atmos.is_wet(a01x + 2200.0), "no rain in the coolant plant")
		check(not atmos.is_wet(lvl.areas[3].global_position.x + 3000.0), "no rain in the training cells")
		check(not atmos.is_wet(lvl.level_width - 200.0), "no rain at the freight lift")
		var span: Vector4 = atmos._far_mat.get_shader_parameter("dry_a")
		check(is_equal_approx(span.x, a01x + WET_UNTIL), "the rain shader is told where the roof starts (%s)" % str(span))

	# The interior (lab) look follows the roof: the bridge keeps the walkway.
	var bridge: Block = lvl.areas[0].get_node("Geometry/FloorBridge")
	var airlock: Block = lvl.areas[0].get_node("Geometry/FloorAirlock")
	check(not bridge._in_interior() and airlock._in_interior(), "the bridge floor is outdoors, the airlock floor indoors")
	if TerrainSkins.has_skin("depot_floor"):
		check_eq(airlock.skin_name(), "depot_floor", "the airlock floor is the lab's steel floor")
		check(bridge.skin_name() != "depot_floor", "the bridge keeps the outdoor walkway")
	if TerrainSkins.has_skin("ac_unit"):
		var wall: Block = lvl.areas[1].get_node("Geometry/KennelWall")
		check_eq(wall.skin_name(), "ac_unit", "a lab backstop is a machine housing, not a stone planter (C57)")
	var lamp: Scenery = lvl.areas[0].get_node("Scenery/AirlockLamp")
	check_eq(lamp.painted_piece(), "", "props under the roof keep the interior look")
	var bridge_lamp: Scenery = lvl.areas[0].get_node("Scenery/BridgeLamp1")
	check(bridge_lamp.painted_piece() != "", "...and the bridge's lamps the outdoor one")
	var outdoor_blocks: Array = []
	for i in range(0, 6):
		for b in _all(lvl.areas[i].get_node("Geometry"), func(n): return n is Block):
			if not (b as Block)._in_interior():
				outdoor_blocks.append("%s/%s" % [lvl.areas[i].area_id, b.name])
	check_eq(outdoor_blocks, ["L02-A01/FloorBridge"], "every block but the bridge's floor has the interior look")

	# Sound: the lab hums like the depot until Adam's lockdown (A04); the Lattice has
	# the server core's tone; footsteps ring on metal everywhere.
	var beds := [AmbienceMap.DEPOT, AmbienceMap.DEPOT, AmbienceMap.DEPOT, AmbienceMap.LOCKDOWN, AmbienceMap.CORE, AmbienceMap.LOCKDOWN]
	for i in 6:
		check_eq(AmbienceMap.bed_for(AREA_IDS[i], true), beds[i], "%s's ambience bed" % AREA_IDS[i])
		check_eq(SurfaceMap.for_area(AREA_IDS[i]), SurfaceMap.METAL, "%s's floors ring as metal" % AREA_IDS[i])
	check_eq(AmbienceMap.music_for("L02-A01", true), AmbienceMap.MUSIC_DEPOT, "the lab plays the depot track")
	check_eq(AmbienceMap.music_for("L02-A04", true), AmbienceMap.MUSIC_LOCKDOWN, "...and the lockdown track from A04")
	check_eq(lvl.ambience_bed(), AmbienceMap.DEPOT, "Dave starts in Level 2 to the lab's hum (not the lockdown bed)")
	check_eq(AmbienceMap.bed_for("L01-A02", true), AmbienceMap.LOCKDOWN, "Level 1's beds are unchanged")
	Settings.set_reduced_motion(base_reduced)
	await _free(lvl)


# --- 3. microchips, entities, encounters and prompts ----------------------------------------

func _test_population() -> void:
	await _clear_leftovers()
	Session.new_run("L02")
	var lvl := await _build_level()
	var all_ids: PackedStringArray = []
	var main_value := 0
	var tray_value := 0
	var cache_value := 0
	var caches_found := {}
	for i in lvl.areas.size():
		var a: AreaRoot = lvl.areas[i]
		all_ids.append_array(a.get_entity_ids())
		var chips := _all(a.get_node("Entities"), func(n): return n is Chip)
		check_eq(chips.size(), CHIPS_PER_AREA[i], "%s has %d microchips" % [a.area_id, CHIPS_PER_AREA[i]])
		for c in chips:
			check((c as Chip).entity_id.begins_with(a.area_id + "-G"), "chip id %s is under its area" % c.entity_id)
			check_eq(int(c.value), 1, "%s is worth 1" % c.entity_id)
			main_value += int(c.value)
		for c in _all(a.get_node("Entities"), func(n): return n is ChipCache):
			var cid: String = (c as ChipCache).entity_id
			caches_found[cid] = [i, int(c.value)]
			if cid == CACHE_ID:
				cache_value += int(c.value)
			else:
				tray_value += int(c.value)
	check_eq(main_value, MAIN_CHIPS, "60 microchips on the route")
	var want_caches := {CACHE_ID: [5, CACHE_VALUE]}
	for id in TRAYS:
		want_caches[id] = [TRAYS[id][0], TRAYS[id][1]]
		var tray := lvl.areas[int(TRAYS[id][0])].get_node_or_null(String(TRAYS[id][2])) as ChipCache
		check(tray != null and tray.entity_id == id and int(tray.value) == int(TRAYS[id][1]),
				"%s is %s, worth %d" % [TRAYS[id][2], id, TRAYS[id][1]])
	check_eq(caches_found, want_caches, "the caches: the drill, armory and rack trays and the dock's cache")
	check_eq(tray_value, TRAYS_VALUE, "the set-piece trays hold 10 + 5 + 5")
	check_eq(cache_value, CACHE_VALUE, "one 20-chip cache behind the optional rover")
	check_eq(main_value + tray_value + cache_value, lvl.level_def.chip_total, "the LevelDef's chip total matches the level")
	var seen := {}
	var dupes: PackedStringArray = []
	for id in all_ids:
		if seen.has(id):
			dupes.append(id)
		seen[id] = true
		check(id.begins_with("L02-"), "entity id %s has the Level 2 prefix" % id)
	check(dupes.is_empty(), "no duplicate entity ids (%s)" % dupes)
	for required in ["L02-KC01-P", "L02-EF02", "L02-UPG01", CACHE_ID, "L02-A01-DRILL01"]:
		check(required in all_ids, "entity %s is placed" % required)

	var evidence := lvl.areas[3].get_node_or_null("Entities/EvidencePickup_EF02") as EvidencePickup
	check(evidence != null and evidence.evidence_id == "EF02" and evidence.reader_title == "Reassignment Memo",
			"the Reassignment Memo sits on Dave's old desk in A04")
	var desk: Node2D = lvl.areas[3].get_node_or_null("Scenery/DeskPod")
	check(evidence != null and desk != null and absf(evidence.position.x - desk.position.x) < 1.0,
			"...over the desk pod at x %.0f" % (desk.position.x if desk else -1.0))
	var console := lvl.areas[4].get_node_or_null("Entities/AlignmentConsole")
	check(console != null and console.get_script() == KeycardConsole and console.keycard_id == "L02-KC01",
			"the A05 alignment console issues L02-KC01")
	var bench := lvl.areas[2].get_node_or_null("Entities/Workbench") as Workbench
	check(bench != null and bench.can_interact(lvl.hero), "the A03 workbench is there and usable (Dave is past the awakening)")
	var stations := {}
	for st in _all(lvl, func(n): return n is RecoveryStation):
		stations[(st as RecoveryStation).checkpoint_id] = int(stations.get(st.checkpoint_id, 0)) + 1
	check_eq(stations, {"CP00B": 1, "CP01": 1, "CP02": 1, "CP03": 1, "CP04": 1, "CP05": 1}, "one recovery station per checkpoint id")
	var pads := _all(lvl.areas[3], func(n): return n is RouteSwitch)
	check_eq(pads.size(), 3, "three lane control pads in A04")
	check_eq(_all(lvl, func(n): return n is RouteSwitch).size(), 3, "...and no other control pad in the level")
	var racks := _all(lvl.areas[3], func(n): return n.get_script() == RailRack)
	var parts := _all(lvl.areas[3], func(n): return n.get_script() == LanePartition)
	check_eq(racks.size(), 3, "three sliding racks")
	check_eq(parts.size(), 3, "three far-bank partitions")
	for i in 3:
		var sw := "L02-SW%02d" % (i + 1)
		check(pads.any(func(p): return p.switch_id == sw and p.get_prompt() == "Use control pad"), "a control pad sets %s" % sw)
		check(racks.any(func(r): return r.switch_id == sw), "a rack waits for %s" % sw)
		check(parts.any(func(p): return p.switch_id == sw), "a partition opens for %s" % sw)
	var rack_switches := _all(lvl.areas[2], func(n): return n.get("switch_id") == "L02-SW04")
	check(rack_switches.size() == 1 and String(rack_switches[0].name).begins_with("LaunchRack"), "the A03 launch rack latches L02-SW04")
	var wickets := _all(lvl, func(n): return n is ExitWicket)
	check_eq(wickets.size(), 1, "one exit: the A06 freight lift")
	if wickets.size() == 1:
		var lift := wickets[0] as ExitWicket
		check_eq(lift.required_keycard, "L02-KC01", "the freight lift needs L02-KC01")
		check(lvl.areas[5].is_ancestor_of(lift), "the freight lift is in A06")
		check_eq(lift.override_time, OVERRIDE_S, "...and takes 45 s to come up (the hold-out)")
		check_eq(lift.wave_groups.size(), 3, "...through three waves")
	var pad := lvl.areas[0].get_node_or_null("Entities/WeaponPad") as WeaponPad
	check(pad != null and pad.position.x == 2960.0 and pad.pad_id == "L02-A01-PAD01"
			and Session.weapon_on_pad(pad.pad_id) == "L02-W02-P01",
			"A01's WeaponPad L02-A01-PAD01 at x 2,960 rests the Boom Broom L02-W02-P01 (M3)")
	check(_all(lvl, func(n): return n is WeaponPad).size() == 1 and lvl.has_swap_pad(), "the level has its one weapon pad (M3)")

	# Encounters: the v2 groups, each with its ids and types; no slot is left.
	var groups := {}
	for i in lvl.areas.size():
		for g in _all(lvl.areas[i].get_node("Encounters"), func(n): return n is EncounterGroup):
			groups[g.group_id] = [i, g]
	check_eq(groups.size(), ENCOUNTERS.size(), "%d encounter groups (%s)" % [ENCOUNTERS.size(), str(groups.keys())])
	var id_re := RegEx.create_from_string("^(.+)-(SE01|LK01|M01|SE02|K01|M02)-(\\d\\d)$")
	var by_type := {}
	var hounds: Array = []
	var staffers_by_group := {}
	for gid in ENCOUNTERS:
		var want: Dictionary = ENCOUNTERS[gid]
		check(groups.has(gid), "encounter %s is placed" % gid)
		if not groups.has(gid):
			continue
		check_eq(groups[gid][0], want.area, "%s is in %s" % [gid, AREA_IDS[want.area]])
		var g: EncounterGroup = groups[gid][1]
		var zone := g.get_node_or_null("ApproachZone") as Area2D
		check((zone != null and zone.collision_mask == 2) or (zone == null and g.wait_for_trigger),
				"%s wakes on Dave's approach (ApproachZone) or waits for its trigger" % gid)
		var got := {}
		for c in g.get_children():
			check(not (c is Marker2D and String(c.name).begins_with("Slot_")), "%s has no M4 slot left (%s)" % [gid, c.name])
			if not c.is_in_group("enemy"):
				continue
			var code: String = TYPE_BY_SCENE.get(c.scene_file_path, "?")
			got[code] = int(got.get(code, 0)) + 1
			by_type[code] = int(by_type.get(code, 0)) + 1
			var m := id_re.search(c.entity_id)
			check(m != null and m.get_string(1) == _base_group_id(gid) and m.get_string(2) == code,
					"%s's id %s is <encounter>-<type>-nn (%s)" % [gid, c.entity_id, code])
			if c is Hound:
				hounds.append(c)
			elif code == "LK01":
				check(c.rig_path_for_look().contains("/staffer_hd_"), "%s wears a painted look (%s)" % [c.entity_id, c.rig_path_for_look()])
				var looks: Array = staffers_by_group.get(gid, [])
				looks.append(c.rig_path_for_look())
				staffers_by_group[gid] = looks
		var want_types := want.duplicate()
		want_types.erase("area")
		check_eq(got, want_types, "%s fields %s" % [gid, str(want_types)])
	for gid in staffers_by_group:
		var looks: Array = staffers_by_group[gid]
		if looks.size() == 2:
			check(looks[0] != looks[1], "%s's two Staffers wear different faces (%s)" % [gid, str(looks)])
	check_eq(by_type, {"SE01": 17, "LK01": 15, "M01": 4, "SE02": 10, "K01": 5, "M02": 10},
			"the level fields 17 Night Guards, 15 Staffers, 4 rovers, 10 Sidearm Guards, 5 Hounds, 10 drones")
	# The Hounds on a lead: the handler is a Night Guard in the same group, linked (its spine lime).
	for h in hounds:
		if not HANDLED_HOUNDS.has(h.entity_id):
			continue
		var handler := h.get_node_or_null(h.handler_path) as Brawler
		check(handler != null and handler.scene_file_path == NIGHT_GUARD_SCENE and handler.get_parent() == h.get_parent()
				and handler.entity_id == HANDLED_HOUNDS[h.entity_id],
				"%s's handler is the Night Guard %s in its group (handler_path %s)" % [h.entity_id, HANDLED_HOUNDS[h.entity_id], h.handler_path])
		check(h.has_handler(), "...and is linked to him (its spine strip lime)")
	var loose: Array = []
	for h in hounds:
		if not HANDLED_HOUNDS.has(h.entity_id):
			loose.append(h.entity_id)
	print("[test_l02_areas] Hounds without a handler_path (Adam's, magenta): %s" % str(loose))
	var enemy_ids: PackedStringArray = []
	for a in lvl.areas:
		enemy_ids.append_array(a.get_enemy_ids())
	check_eq(enemy_ids.size(), ENEMY_TOTAL, "61 enemies placed: 60 on the route and the dock's optional rover")

	# The optional rover (E27): its tuned eye height, and backstops at both ends of its beat.
	check_eq(PatrolRover.EYE_HEIGHT, 24.0, "the rover keeps its tuned eye height")
	var a06: AreaRoot = lvl.areas[5]
	var rover: PatrolRover = null
	if groups.has("L02-E27"):
		for c in (groups["L02-E27"][1] as Node).get_children():
			if c is PatrolRover:
				rover = c
	check(rover != null, "the dock's optional rover is E27's")
	if rover:
		var left: Block = a06.get_node("Geometry/DockBackstopL")
		var right: Block = a06.get_node("Geometry/DockBackstopR")
		check(left.kind == Block.Kind.BACKSTOP and right.kind == Block.Kind.BACKSTOP, "the dock lane has backstop crates")
		check(left.position.x + left.size.x <= rover.patrol_min_x - PatrolRover.HALF_WIDTH
				and right.position.x >= rover.patrol_max_x + PatrolRover.HALF_WIDTH, "the rover's beat runs between its backstops")
		var dock_top: float = (a06.get_node("Geometry/DockFloor") as Block).position.y
		check(is_equal_approx(left.position.y + left.size.y, dock_top) and is_equal_approx(right.position.y + right.size.y, dock_top)
				and absf(a06.to_local(rover.global_position).y - dock_top) <= 2.0,
				"both backstops and the rover stand on the dock floor (rover at %s)" % str(a06.to_local(rover.global_position)))
		var cache := a06.get_node("Entities/ChipCache_OPT01") as Node2D
		check(cache.position.x > right.position.x, "the cache waits past the rover's far backstop")

	# Prompts at least 3 H apart (or 2 H apart in height).
	for a in lvl.areas:
		var spots: Array = []
		for n in _all(a.get_node("Entities"), func(n): return n is Interactable):
			spots.append([String(n.name), a.to_local((n as Node2D).global_position)])
		for p in spots.size():
			for q in range(p + 1, spots.size()):
				var d: Vector2 = spots[p][1] - spots[q][1]
				check(absf(d.x) >= PROMPT_SPACING or absf(d.y) >= 2.0 * H,
						"%s: %s and %s are 3 H apart (dx %d, dy %d)" % [a.area_id, spots[p][0], spots[q][0], int(d.x), int(d.y)])
	await _free(lvl)


# --- 4. checkpoints are safe to stand on, save and respawn ------------------------------------

func _test_checkpoints() -> void:
	await _clear_leftovers()
	Session.new_run("L02")
	var lvl := await _build_level()
	var def := lvl.level_def
	var threats: Array = []   # global positions of enemies
	for a in lvl.areas:
		for n in _all(a.get_node("Encounters"), func(n): return n.is_in_group("enemy")):
			threats.append((n as Node2D).global_position)
	for cp in def.checkpoint_markers:
		var entry: Array = def.checkpoint_markers[cp]
		var area: AreaRoot = lvl.areas[entry[0]]
		var marker := area.get_marker(entry[1])
		check(marker != null, "%s's marker %s is in %s" % [cp, entry[1], area.area_id])
		if marker == null:
			continue
		var m := marker.global_position
		check(_solid_between(lvl, m + Vector2(0, -2), m + Vector2(0, 24)), "%s's marker stands on a floor" % cp)
		check(not _solid_between(lvl, m + Vector2(0, -H), m + Vector2(0, -8)), "%s's marker has headroom" % cp)
		for t in threats:
			check(absf(t.x - m.x) >= SAFE_RADIUS or absf(t.y - m.y) >= 3.0 * H,
					"%s is clear of enemies (one at %s)" % [cp, str(area.to_local(t))])
		if cp.begins_with("CP") and cp != "CP00":
			var station := area.get_node_or_null("Entities/RecoveryStation_" + cp) as RecoveryStation
			check(station != null and station.global_position.distance_to(m) <= 24.0, "%s's recovery station is at its marker" % cp)
		if cp == "UPG01":
			var bench := area.get_node("Entities/Workbench") as Node2D
			check(bench.global_position.distance_to(m) <= 24.0, "UPG01 respawns at the workbench")
		lvl._place_hero_at_checkpoint(cp)
		await physics_frames(20)
		check(lvl.hero.is_on_floor() and lvl.hero.global_position.distance_to(m) <= 12.0,
				"Dave stands safely at %s (at %s)" % [cp, str(area.to_local(lvl.hero.global_position))])
		var snap: Dictionary = Session.state.duplicate(true)
		snap["checkpoint_id"] = cp
		check(CheckpointService.validate_snapshot(JSON.parse_string(JSON.stringify(snap))).ok, "a Level 2 save at %s validates" % cp)

	# Commit at the A04 station after using the lanes; a death comes back there with
	# the racks docked and the partitions open.
	for sw in ["L02-SW01", "L02-SW02", "L02-SW03"]:
		Session.set_switch(sw, true)
	var st := lvl.areas[3].get_node("Entities/RecoveryStation_CP03") as RecoveryStation
	lvl.hero.global_position = st.global_position + Vector2(0, -4)
	await physics_frames(3)
	st.interact(lvl.hero)
	await physics_frames(2)
	check_eq(Session.state["checkpoint_id"], "CP03", "the CP03 station commits CP03")
	var died := lvl.hero.take_damage(999, lvl.hero.global_position)
	await physics_frames(4)
	var respawn := lvl.areas[3].get_marker("Respawn_CP03")
	check(died and lvl.hero.global_position.distance_to(respawn.global_position) <= 12.0,
			"a death after CP03 respawns at Respawn_CP03 (died %s, at %s, health %d, cp %s)" % [died,
			str(lvl.areas[3].to_local(lvl.hero.global_position)), Session.get_health(), Session.state["checkpoint_id"]])
	for i in 3:
		var rack: Node = lvl.areas[3].get_node("Geometry/RailRack_%d" % (i + 1))
		var part: Node = lvl.areas[3].get_node("Geometry/Partition_%d" % (i + 1))
		check(rack.is_docked() and rack.position.distance_to(rack.point_b) < 0.5, "after the rebuild lane %d's rack is docked" % (i + 1))
		check(part.is_open, "...and its partition is open")
	await _free(lvl)


# --- 5. the console's keycard and the freight lift's hold-out ----------------------------------

func _test_keycard_and_freight_lift() -> void:
	await _clear_leftovers()
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl := await _build_level()
	var lift: ExitWicket = lvl.areas[5].get_node("Entities/FreightLift")
	check(not lift.is_unlocked(), "the freight lift is locked without the card")
	lvl.hero.respawn_at(lift.global_position + Vector2(-80, -4))
	await physics_frames(3)
	lvl.hero.respawn_at(lift.global_position + Vector2(0, -4))
	await physics_frames(4)
	check(not lvl.level_ended_flag, "walking into the locked lift does not end the level")
	check(not lift.is_overriding() and not lift.is_open(), "...nor calls it without the card")
	lvl.hero.respawn_at(lift.global_position + Vector2(-200, -4))
	await physics_frames(3)

	var console: Node = lvl.areas[4].get_node("Entities/AlignmentConsole")
	check(console.can_interact(lvl.hero) and console.get_prompt() == "Use console", "the console offers the card")
	var granted: Array = []
	console.keycard_granted.connect(func(id): granted.append(id))
	console.interact(lvl.hero)
	check(Session.has_keycard("L02-KC01") and Session.is_collected("L02-KC01-P"), "using the console takes L02-KC01")
	check_eq(granted, ["L02-KC01"], "the console's keycard_granted hook fires once (M5's console scene)")
	check(not console.can_interact(lvl.hero), "the console has nothing more to give")
	await physics_frames(2)
	check(lvl.hud.get_node("TopBar/KeycardIcon").visible, "the HUD shows the card")
	check(lift.is_unlocked(), "the card unlocks the freight lift's reader")
	check(not lift.is_overriding() and not lift.is_open(), "...but the lift only comes up once Dave calls it at the gate")

	# A death before CP04 puts the card back on the console.
	lvl.hero.take_damage(999, lvl.hero.global_position)
	await physics_frames(5)
	check(not Session.has_keycard("L02-KC01"), "a death before a checkpoint rolls the card back")
	console = lvl.areas[4].get_node("Entities/AlignmentConsole")
	check(console.can_interact(lvl.hero), "...and the rebuilt console offers it again")
	console.interact(lvl.hero)
	check(Session.has_keycard("L02-KC01"), "setup: the card is taken again")

	# The hold-out: the card at the gate calls the lift; the level does not end until the
	# 45 s override is over, and then only with Dave in the gate.
	lvl.hero.debug_invulnerable = true
	lift = lvl.areas[5].get_node("Entities/FreightLift")
	lvl.hero.respawn_at(lift.global_position + Vector2(0, -4))
	await physics_frames(4)
	check(lift.is_overriding(), "the card at the gate starts the 45 s override")
	check(not lvl.level_ended_flag, "...and the level does not end yet")
	check_eq(lift.current_wave(), 0, "...the first wave opens with it")
	var away := lift.global_position + Vector2(-1000, -4)
	lvl.hero.respawn_at(away)
	var frames := 0
	var ended_early := false
	while not lift.is_open() and frames < int((OVERRIDE_S + 5.0) * 60.0):
		await get_tree().physics_frame
		frames += 1
		ended_early = ended_early or lvl.level_ended_flag
	check(lift.is_open(), "the override finishes (after %.1f s)" % (frames / 60.0))
	check(frames >= int((OVERRIDE_S - 1.0) * 60.0), "...only after its 45 s (%.1f s)" % (frames / 60.0))
	check(not ended_early, "the level never ends during the hold-out")
	check(not lvl.level_ended_flag, "Dave away from the gate: the open lift waits for him")
	lvl.hero.respawn_at(lift.global_position + Vector2(0, -4))
	await physics_frames(4)
	check(lvl.level_ended_flag, "with the card and the override done, stepping into the lift ends the level")
	check_eq(Session.state["checkpoint_id"], "CP05", "the level's end commits CP05")
	check(Session.get_story("level_complete") == true, "Level 2 is complete")
	await _free(lvl)
	CheckpointService.clear()


# --- 6. A04: the lanes wait for their pad and never close on Dave ----------------------------

func _spawn_a04() -> Array:
	var area: AreaRoot = load(A04_SCENE).instantiate()
	add_child(area)
	var hero: Hero = load(HERO_SCENE).instantiate()
	hero.debug_invulnerable = true
	add_child(hero)
	hero.respawn_at(Vector2(96, -4))
	await physics_frames(3)
	return [area, hero]


func _test_a04_lanes_wait_and_never_close_on_dave() -> void:
	await _clear_leftovers()
	Session.new_run("L02")
	var spawned := await _spawn_a04()
	var area: AreaRoot = spawned[0]
	var hero: Hero = spawned[1]
	var racks: Array = []
	var parts: Array = []
	for i in 3:
		racks.append(area.get_node("Geometry/RailRack_%d" % (i + 1)))
		parts.append(area.get_node("Geometry/Partition_%d" % (i + 1)))
	await seconds(2.0)
	for i in 3:
		check(racks[i].phase == RailRack.Phase.WAITING and racks[i].position.distance_to(racks[i].point_a) < 0.5,
				"lane %d's rack waits at the near bank until its pad is used" % (i + 1))
		check(not parts[i].is_open and not parts[i]._shape.disabled, "lane %d's partition is shut" % (i + 1))

	# Dave in trench 1 at the far bank, right where the rack is headed (the lanes are at
	# x 1,300-1,600, 2,700-3,000 and 4,200-4,500 in v2).
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
			"the move is announced first (chime/caption hook), then starts (%s)" % str(events))

	# Dave steps clear: the rack finishes its crossing and the partition slides open.
	hero.respawn_at(Vector2(1000, -4))
	await seconds(3.0)
	check(racks[0].is_docked() and racks[0].position.distance_to(racks[0].point_b) < 0.5, "once clear the rack docks at the far bank")
	check(parts[0].is_open and parts[0]._shape.disabled, "and the far-bank partition opens")
	check(events.size() == 3 and events[2][0] == "arrived", "warned, started, arrived, once each (%s)" % str(events))
	check(not racks[1].is_docked() and not racks[2].is_docked(), "the other lanes still wait for their own pads")

	# Lane 2: ride the rack across, then walk out past the opened partition.
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


func _test_a04_upper_ledge_recovery() -> void:
	# No pad used at all: the upper ledge still takes Dave from the entry to the exit.
	await _clear_leftovers()
	Session.new_run("L02")
	var spawned := await _spawn_a04()
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
	check(hero.global_position.x >= area.width - 64.0 and absf(hero.global_position.y) <= 8.0,
			"...to the exit seam (at %s)" % str(hero.global_position))
	for sw in ["L02-SW01", "L02-SW02", "L02-SW03"]:
		check(not Session.get_switch(sw), "%s was never used" % sw)
	await _free(bot)
	await _free(hero)
	await _free(area)


func _test_a04_reload_keeps_lanes_open() -> void:
	await _clear_leftovers()
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


# --- 7. the RouteBot plays Level 2 start to finish -----------------------------------------

func _test_route_bot_finishes_level_2() -> void:
	await _clear_leftovers()
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl := await _build_level()
	lvl.hero.debug_invulnerable = true
	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(lvl, [])
	var waits := 0
	for p in bot.points:
		if p.action == RoutePoint.Action.WAIT_SECONDS and p.seconds >= OVERRIDE_S:
			waits += 1
	check_eq(waits, 1, "setup: the main route waits out the hold-out once (a WAIT_SECONDS of 45 s or more)")
	bot.start(lvl.hero)
	var ticks := 0
	# Six areas (about 4 to 5 minutes of play) and the 45 s hold-out; generous headroom.
	while bot.running and ticks < 60 * 900:
		await get_tree().physics_frame
		ticks += 1
	if bot.running:
		bot.failure_message = "test timeout"
		bot.running = false
	var report := bot.get_report()
	print("[test_l02_areas] main route bot seconds=%.1f chips=%d areas=%s" % [report.seconds, Session.chips_found(), str(report.area_times)])
	check(bot.success, "the RouteBot finishes Level 2's main route (%s)" % report.failure)
	check(lvl.level_ended_flag, "...through the freight lift")
	for id in AREA_IDS:
		check(report.area_times.has(id), "the route crosses %s" % id)
	check(float(report.area_times.get("L02-A06", 0.0)) >= OVERRIDE_S, "...waiting out the lift's 45 s hold-out in A06 (%.1f s there)"
			% float(report.area_times.get("L02-A06", 0.0)))
	check_eq(report.beat_times.size(), BEATS_TOTAL, "every beat is reached on the way (%s)" % str(report.beat_times.keys()))
	check(Session.has_keycard("L02-KC01"), "the route takes the keycard at the console")
	for sw in ["L02-SW01", "L02-SW02", "L02-SW03"]:
		check(Session.get_switch(sw), "the route uses %s's lane" % sw)
	check_eq(Session.state["checkpoint_id"], "CP05", "the run ends committed at CP05")
	check(Session.chips_found() >= 42 and not Session.is_collected(CACHE_ID),
			"the main route picks up most chips and leaves the optional cache (%d)" % Session.chips_found())
	check(not Session.has_evidence("EF02"), "the evidence file is optional")
	await _free(bot)
	await _free(lvl)
	CheckpointService.clear()


func _test_dock_branch_cache() -> void:
	await _clear_leftovers()
	CheckpointService.clear()
	Session.new_run("L02")
	# A06 alone ends at the freight lift after its hold-out, so the card is held.
	Session.take_keycard("L02-KC01", "L02-KC01-P")
	var harness = load("res://tests/area_harness.gd").new()
	var result: Dictionary = await harness.run_area(self, A06_SCENE, ["OPT01"], 240.0)
	check(result.reached_exit, "the dock branch rejoins and reaches A06's exit (%s at %s)" % [result.failure, str(result.hero_final_position)])
	check(Session.is_collected(CACHE_ID), "the dock branch opens the cache behind the rover")
	var loose := 0
	for i in range(1, 13):
		if Session.is_collected("L02-A06-G%03d" % i):
			loose += 1
	check(loose >= 6, "...on a run that picks up A06's loose chips on the way (%d)" % loose)
	check_eq(Session.chips_found(), loose + CACHE_VALUE, "A06's chips plus the cache's 20, counted once")
	CheckpointService.clear()
