extends Node2D
## Capture demo (tools/capture.sh): Level 2 v2's set pieces S1 and S2 on a lab-look test strip.
## Part 1, the drill: Dave, holding the Boom Broom, steps onto the drill pad; four test dummies rise
## from floor hatches and drop from a ceiling rail on the pad's schedule (amber then red hatch
## lamps), he blasts each down (the HUD's "Drill n/4" toasts, the pad's pips and time bar) and
## the hidden chip tray opens. Part 2, the range goes live: Dave walks into the live-fire lane, the
## lane lamps go amber then red, the carriers start, and a Sidearm Guard's rounds stop on the
## armoured plates sliding between them. Throwaway save (never the real one).
##   tools/capture.sh res://scenes/debug/setpieces_a_demo.tscn OUT 240 30
## `-- --part=range` starts at part 2.

const HeroScene := preload("res://scenes/actors/hero.tscn")
const CameraScene := preload("res://scenes/actors/game_camera.tscn")
const HudScene := preload("res://scenes/ui/hud.tscn")
const SceneryScene := preload("res://scenes/objects/scenery.tscn")
const GunnerScene := preload("res://scenes/actors/sidearm_guard.tscn")
const PadScene := preload("res://scenes/objects/drill_pad.tscn")
const TargetScene := preload("res://scenes/objects/popup_target.tscn")
const PlateScene := preload("res://scenes/objects/cover_plate.tscn")
const CacheScene := preload("res://scenes/objects/chip_cache.tscn")
const RangeLive := preload("res://scripts/objects/range_live.gd")
const AreaRootScript := preload("res://scripts/levels/area_root.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const BackdropScript := preload("res://scripts/world/visuals/area_backdrop.gd")
const OVERLAY_SCENE := "res://scenes/world/night_overlay.tscn"
const LIGHTING_SCENE := "res://scenes/world/night_lighting.tscn"
const PAD_ID := "L02-A01-PAD01"

const WIDTH := 3400.0
const CEILING_Y := -440.0
const RAIL_Y := -250.0
const PAD_X := 360.0
## The drill's dummies: [x, mount, appear_at, chest height].
const DRILL := [
	[690.0, 0, 0.8, 70.0],
	[740.0, 1, 1.5, 150.0],
	[470.0, 0, 2.2, 100.0],
	[640.0, 1, 2.9, 116.0],
]
## Where Dave stands to shoot once the run has started.
const SHOOT_X := 560.0
const RANGE_X := 1900.0

var hero: Hero
var camera: Camera2D
var hud: Node
var area: Node2D
var entities: Node2D
var pad: Area2D
var range_ctl: Node2D
var guard: Gunner


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/setpieces_a_demo")
	var tel := get_node_or_null("/root/Telemetry")
	if tel and tel.has_method("set_playtest_dir"):
		tel.set_playtest_dir("user://debug_demo_throwaway/setpieces_a_demo/playtests")
	RenderingServer.set_default_clear_color(Color("#0E1726"))
	Session.new_run("L02")
	Session.swap_weapon(PAD_ID)
	_build_area()
	_build_drill()
	_build_range()
	_build_hero()
	if ResourceLoader.exists(LIGHTING_SCENE):
		add_child(load(LIGHTING_SCENE).instantiate())
	if ResourceLoader.exists(OVERLAY_SCENE):
		add_child(load(OVERLAY_SCENE).instantiate())
	hud = HudScene.instantiate()
	add_child(hud)
	await get_tree().physics_frame
	hud.setup(hero)
	var part := "all"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--part="):
			part = a.trim_prefix("--part=")
	if part == "range":
		_run_range()
	else:
		_run()


# --- the strip --------------------------------------------------------------------------------

func _build_area() -> void:
	area = Node2D.new()
	area.set_script(AreaRootScript)
	area.name = "DemoArea"
	area.set("area_id", "L02-A01")
	area.set("width", WIDTH)
	area.set("indoors", true)
	area.set("interior_look", "lab")
	area.set("camera_top", -440.0)
	area.set("camera_bottom", 120.0)
	add_child(area)
	var bg := Node2D.new()
	bg.name = "Background"
	area.add_child(bg)
	var layer := Parallax2D.new()
	layer.set_script(BackdropScript)
	layer.set("mode", 3)
	layer.set("tile_width", WIDTH)
	layer.set("horizon_y", 0.0)
	bg.add_child(layer)
	var geo: Node2D = area.get_node_or_null("Geometry")
	if geo == null:
		geo = Node2D.new()
		geo.name = "Geometry"
		area.add_child(geo)
	_block(geo, Rect2(0.0, 0.0, WIDTH, 300.0), BlockScript.Kind.GROUND)
	_block(geo, Rect2(0.0, CEILING_Y - 40.0, WIDTH, 40.0), BlockScript.Kind.ROOF)
	_block(geo, Rect2(0.0, -300.0, 40.0, 300.0), BlockScript.Kind.WALL)
	_block(geo, Rect2(WIDTH - 40.0, -300.0, 40.0, 300.0), BlockScript.Kind.WALL)
	var scenery: Node2D = area.get_node_or_null("Scenery")
	if scenery == null:
		scenery = Node2D.new()
		scenery.name = "Scenery"
		area.add_child(scenery)
	# The drill yard: a sign, a bench, lamps over the pad and the hatches.
	_prop(scenery, 11, Vector2(560.0, -330.0), Vector2(150.0, 44.0), "DRILL YARD")
	_lab(scenery, "lab_bench", Vector2(150.0, 0.0))
	_lab(scenery, "server_rack", Vector2(980.0, 0.0))
	for x in [300.0, 760.0]:
		_prop(scenery, 6, Vector2(x, 0.0), Vector2(24.0, 190.0))
	# The live-fire lanes: a sign, lane dividers, the guard's bench.
	_prop(scenery, 11, Vector2(RANGE_X + 260.0, -330.0), Vector2(170.0, 44.0), "LIVE FIRE")
	for x in [RANGE_X - 60.0, RANGE_X + 520.0]:
		_lab(scenery, "lane_divider", Vector2(x, 0.0))
	entities = area.get_node_or_null("Entities")
	if entities == null:
		entities = Node2D.new()
		entities.name = "Entities"
		area.add_child(entities)


func _block(parent: Node, r: Rect2, kind: int) -> void:
	var b := StaticBody2D.new()
	b.set_script(BlockScript)
	b.position = r.position
	b.set("size", r.size)
	b.set("kind", kind)
	parent.add_child(b)


func _prop(parent: Node, kind: int, pos: Vector2, size: Vector2, text: String = "") -> void:
	var s: Node2D = SceneryScene.instantiate()
	s.set("kind", kind)
	s.set("size", size)
	if text != "":
		s.set("text", text)
	s.position = pos
	parent.add_child(s)


func _lab(parent: Node, piece: String, pos: Vector2) -> void:
	var s: Node2D = SceneryScene.instantiate()
	s.set("kind", 22)
	s.set("lab_piece", piece)
	s.position = pos
	parent.add_child(s)


func _build_drill() -> void:
	var paths: Array[NodePath] = []
	for i in DRILL.size():
		var d: Array = DRILL[i]
		var t: Node2D = TargetScene.instantiate()
		t.name = "Dummy%d" % (i + 1)
		t.mount = d[1]
		t.appear_at = d[2]
		t.chest_height = d[3]
		t.position = Vector2(d[0], 0.0 if int(d[1]) == 0 else RAIL_Y)
		t.stem_height = RAIL_Y - CEILING_Y - 22.0
		entities.add_child(t)
		paths.append(NodePath("../Dummy%d" % (i + 1)))
	# The ceiling rail the drop dummies hang from.
	var tray: Area2D = CacheScene.instantiate()
	tray.name = "Tray"
	tray.entity_id = "L02-A01-CACHE01"
	tray.value = 10
	tray.position = Vector2(200.0, 0.0)
	entities.add_child(tray)
	pad = PadScene.instantiate()
	pad.name = "DrillPad"
	pad.entity_id = "L02-A01-DRILL01"
	pad.duration = 15.0
	pad.targets = paths
	pad.reward = NodePath("../Tray")
	pad.position = Vector2(PAD_X, 0.0)
	entities.add_child(pad)


func _build_range() -> void:
	var p1: Node2D = PlateScene.instantiate()
	p1.name = "Plate1"
	p1.point_a = Vector2(RANGE_X + 150.0, 0.0)
	p1.point_b = Vector2(RANGE_X + 330.0, 0.0)
	p1.rail_height = 300.0
	p1.bracket_height = -CEILING_Y - 304.0   # up to the ceiling
	p1.speed = 70.0
	entities.add_child(p1)
	var p2: Node2D = PlateScene.instantiate()
	p2.name = "Plate2"
	p2.point_a = Vector2(RANGE_X + 640.0, 0.0)
	p2.point_b = Vector2(RANGE_X + 820.0, 0.0)
	p2.rail_height = 300.0
	p2.bracket_height = -CEILING_Y - 304.0   # up to the ceiling
	p2.speed = 70.0
	p2.start_progress = 1.0
	p2.start_dir = -1
	entities.add_child(p2)
	range_ctl = Node2D.new()
	range_ctl.set_script(RangeLive)
	range_ctl.name = "RangeLive"
	range_ctl.position = Vector2(RANGE_X, 0.0)
	range_ctl.set("plates", Array([NodePath("../Plate1"), NodePath("../Plate2")], TYPE_NODE_PATH, &"", null))
	range_ctl.set("lamp_points", PackedVector2Array([Vector2(120.0, -330.0), Vector2(420.0, -330.0), Vector2(720.0, -330.0)]))
	range_ctl.set("trigger_offset", Vector2(0.0, -200.0))
	entities.add_child(range_ctl)
	guard = GunnerScene.instantiate()
	guard.entity_id = "L02-DEMO-SE02-01"
	guard.position = Vector2(RANGE_X + 560.0, 0.0)
	guard.start_facing = -1
	entities.add_child(guard)


func _build_hero() -> void:
	hero = HeroScene.instantiate()
	hero.position = Vector2(140.0, 0.0)
	entities.add_child(hero)
	hero.debug_invulnerable = true
	camera = CameraScene.instantiate()
	camera.set("target", hero)
	camera.set("world_limits", Rect2(0.0, CEILING_Y - 40.0, WIDTH, 600.0))
	add_child(camera)


# --- the tour ---------------------------------------------------------------------------------

func _wait(t: float) -> void:
	await get_tree().create_timer(t).timeout


func _run() -> void:
	hero.input_enabled = false
	await _wait(0.4)
	# Step onto the pad.
	hero.input_enabled = true
	Input.action_press(&"move_right")
	while not pad.is_running():
		await get_tree().physics_frame
	# Off the pad to the shooting spot (the run keeps going).
	while hero.global_position.x < SHOOT_X:
		await get_tree().physics_frame
	Input.action_release(&"move_right")
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(400.0, -40.0)
	var gun = hero.held_weapon()
	var dummies := entities.get_children().filter(func(n): return n.is_in_group("popup_target"))
	dummies.sort_custom(func(a, b): return a.appear_at < b.appear_at)
	for t in dummies:
		while t.raise < 1.0:
			await get_tree().physics_frame
		hero.aim_override = t.to_global(t.chest_local())
		await _wait(0.1)
		var tries := 0
		while not t.is_down() and tries < 3:
			while not gun.is_ready():
				await get_tree().physics_frame
			hero.aim_override = t.to_global(t.chest_local())
			await get_tree().physics_frame
			await get_tree().physics_frame
			gun.try_blast()
			tries += 1
			await _wait(0.1)
	await _wait(0.8)
	_run_range()


func _run_range() -> void:
	hero.use_aim_override = false
	hero.input_enabled = false
	hero.respawn_at(Vector2(RANGE_X - 160.0, -4.0))
	camera.call("reset_position")
	await _wait(0.3)
	hero.input_enabled = true
	Input.action_press(&"move_right")
	while hero.global_position.x < RANGE_X + 40.0:
		await get_tree().physics_frame
	Input.action_release(&"move_right")
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(400.0, -30.0)
	await _wait(6.0)
	get_tree().quit()
