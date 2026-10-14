extends Node2D
## Capture demo (tools/capture.sh) for the Level 2 v2 architecture kit: a small lab room with a
## floor, a stair up to a supported catwalk, a stair down to a raised floor, a step flight back to
## the floor, a ramp, a ceiling, a doorway and an airlock (scripts/world/stairs.gd,
## lab_structure.gd, room_seam.gd). Dave walks up and down it, stops on a flight, and jumps from
## one. Throwaway save.
##   tools/capture.sh res://scenes/debug/architecture_demo.tscn OUT 480 30

const HeroScene := preload("res://scenes/actors/hero.tscn")
const CameraScene := preload("res://scenes/actors/game_camera.tscn")
const SceneryScene := preload("res://scenes/objects/scenery.tscn")
const AreaRootScript := preload("res://scripts/levels/area_root.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const StairsScript := preload("res://scripts/world/stairs.gd")
const SeamScript := preload("res://scripts/world/room_seam.gd")
const BackdropScript := preload("res://scripts/world/visuals/area_backdrop.gd")
const Arch := preload("res://scripts/world/lab_structure.gd")
const OVERLAY_SCENE := "res://scenes/world/night_overlay.tscn"
const LIGHTING_SCENE := "res://scenes/world/night_lighting.tscn"

const X0 := 0.0
const W := 2900.0

var area: Node2D
var hero: Hero
var camera: Camera2D


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/architecture_demo")
	RenderingServer.set_default_clear_color(Color("#0E1726"))
	Session.new_run("L02")
	_build_area()
	if ResourceLoader.exists(LIGHTING_SCENE):
		add_child(load(LIGHTING_SCENE).instantiate())
	if ResourceLoader.exists(OVERLAY_SCENE):
		add_child(load(OVERLAY_SCENE).instantiate())
	hero = HeroScene.instantiate()
	hero.position = Vector2(100.0, 0.0)
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	area.get_node("Entities").add_child(hero)
	camera = CameraScene.instantiate()
	camera.set("target", hero)
	camera.set("world_limits", Rect2(X0, -440.0, W, 580.0))
	add_child(camera)
	await get_tree().physics_frame
	camera.reset_position()
	_tour()


func _build_area() -> void:
	area = Node2D.new()
	area.set_script(AreaRootScript)
	area.set("area_id", "L02-DEMO")
	area.set("width", W)
	area.set("indoors", true)
	area.set("interior_look", "lab")
	area.name = "ArchitectureDemo"
	add_child(area)
	var bg := Node2D.new()
	bg.name = "Background"
	bg.position.x = X0
	area.add_child(bg)
	var layer := Parallax2D.new()
	layer.set_script(BackdropScript)
	layer.set("mode", 3)
	layer.set("tile_width", W)
	layer.set("horizon_y", 0.0)
	bg.add_child(layer)
	var geo: Node2D = area.get_node("Geometry")
	_block(geo, Rect2(X0, 0.0, W, 300.0), BlockScript.Kind.GROUND, "Floor")
	_block(geo, Rect2(X0, -440.0, W, 40.0), BlockScript.Kind.ROOF, "Ceiling")
	_block(geo, Rect2(X0, -400.0, 40.0, 400.0), BlockScript.Kind.WALL, "WallLeft")
	# Stair 1 up (rising right) to the catwalk, which stands on columns.
	_stairs(geo, Vector2(300.0, 0.0), 192.0, 288.0, 1, "StairUp")
	var deck := _block(geo, Rect2(588.0, -192.0, 412.0, 16.0), BlockScript.Kind.PLATFORM, "Catwalk")
	deck.set("support", BlockScript.Support.COLUMNS)
	# Stair 2 down (rising left) from the catwalk to the raised floor (which runs under it).
	_block(geo, Rect2(1000.0, -96.0, 500.0, 396.0), BlockScript.Kind.GROUND, "RaisedFloor")
	_stairs(geo, Vector2(1000.0, -96.0), 96.0, 144.0, -1, "StairDown")
	# A hanging catwalk over the raised floor (hanger rods to the ceiling), out of reach: decor.
	var high := _block(geo, Rect2(1180.0, -300.0, 300.0, 16.0), BlockScript.Kind.PLATFORM, "HighDeck")
	high.set("railing", BlockScript.Railing.STEEL)
	# Step flight back to the floor, then a doorway and a ramp up to a box landing.
	_stairs(geo, Vector2(1500.0, 0.0), 96.0, 144.0, -1, "StepDown")
	_block(geo, Rect2(2350.0, -64.0, 400.0, 364.0), BlockScript.Kind.GROUND, "RampLanding")
	var ramp := _stairs(geo, Vector2(2110.0, 0.0), 64.0, 240.0, 1, "Ramp")
	ramp.set("style", StairsScript.Style.RAMP)
	var scen: Node2D = area.get_node("Scenery")
	var door: Node2D = Node2D.new()
	door.set_script(SeamScript)
	door.name = "Doorway"
	door.position = Vector2(1850.0, 0.0)
	door.set("icon", Arch.Icon.LATTICE)
	scen.add_child(door)
	var lock: Node2D = Node2D.new()
	lock.set_script(SeamScript)
	lock.name = "Airlock"
	lock.position = Vector2(2560.0, -64.0)
	lock.set("style", 1)
	lock.set("icon", Arch.Icon.LIFT)
	scen.add_child(lock)
	for x in [120.0, 760.0, 1300.0, 1700.0, 2200.0, 2500.0]:
		_prop(scen, 6, Vector2(x, 0.0 if x < 1000.0 or x > 1600.0 else -96.0), Vector2(30.0, 110.0))
	_lab_prop(scen, "server_rack", Vector2(820.0, 0.0))
	_lab_prop(scen, "lab_bench", Vector2(1250.0, -96.0))
	_lab_prop(scen, "coolant_tank", Vector2(2000.0, 0.0))


func _block(parent: Node, r: Rect2, kind: int, n: String) -> Node2D:
	var b := StaticBody2D.new()
	b.set_script(BlockScript)
	b.name = n
	b.position = r.position
	b.set("size", r.size)
	b.set("kind", kind)
	parent.add_child(b)
	return b


func _stairs(parent: Node, at: Vector2, rise: float, run: float, dir: int, n: String) -> Node2D:
	var s := StaticBody2D.new()
	s.set_script(StairsScript)
	s.name = n
	s.position = at
	s.set("rise", rise)
	s.set("run", run)
	s.set("direction", dir)
	parent.add_child(s)
	return s


func _prop(parent: Node, kind: int, pos: Vector2, size: Vector2) -> void:
	var s: Node2D = SceneryScene.instantiate()
	s.set("kind", kind)
	s.set("size", size)
	s.position = pos
	parent.add_child(s)


func _lab_prop(parent: Node, piece: String, pos: Vector2) -> void:
	var s: Node2D = SceneryScene.instantiate()
	s.set("kind", 22)
	s.set("lab_piece", piece)
	s.position = pos
	parent.add_child(s)


## Walk right over everything to the ramp's landing, back left to the start, then stop on the
## first flight and jump from it.
func _tour() -> void:
	await _walk_to(2500.0)
	await _wait(0.4)
	await _walk_to(100.0)
	await _wait(0.3)
	await _walk_to(440.0)
	await _wait(0.6)
	Input.action_press("jump")
	Input.action_press("move_right")
	await _wait(0.25)
	Input.action_release("jump")
	await _wait(0.6)
	Input.action_release("move_right")
	await _wait(1.0)
	get_tree().quit()


func _walk_to(x: float) -> void:
	var dir: String = "move_right" if x > hero.global_position.x else "move_left"
	hero.aim_override = hero.global_position + Vector2(400.0 if dir == "move_right" else -400.0, -20.0)
	Input.action_press(dir)
	var t := 0.0
	while absf(hero.global_position.x - x) > 10.0 and t < 12.0:
		hero.aim_override = hero.global_position + Vector2(400.0 if dir == "move_right" else -400.0, -20.0)
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	Input.action_release(dir)


func _wait(s: float) -> void:
	await get_tree().create_timer(s).timeout
