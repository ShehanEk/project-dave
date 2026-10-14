extends Node2D
## Capture demo (tools/capture.sh) for Level 2 v2's hazards: a steam vent (H1), a live cable (H2),
## a four-vent wave under a VentSequencer (S5, the projector purge) and a conveyor (H3) with
## Dave riding it, in a lit lab strip with the night lighting. Dave is invulnerable and parked
## at each station in turn (the camera snaps to him) so the frames show each hazard's whole
## cycle: the amber warning, the red last 0.25 s, the burst.
##   tools/capture.sh res://scenes/debug/hazards_demo.tscn /private/tmp/<dir> 520 30
## The environment variable HAZARD_STATION=N (1 steam, 2 cable, 3 wave, 4 conveyor) shows one
## station only (tools/capture.sh forwards no user args), e.g. for a short capture.
## Saves and logs go to a throwaway folder (nothing touches the real save).

const HeroScene := preload("res://scenes/actors/hero.tscn")
const CameraScene := preload("res://scenes/actors/game_camera.tscn")
const VentScene := preload("res://scenes/objects/hazard_vent.tscn")
const SequencerScene := preload("res://scenes/objects/vent_sequencer.tscn")
const ConveyorScene := preload("res://scenes/objects/conveyor.tscn")
const BlockScript := preload("res://scripts/world/block.gd")
const BackdropScript := preload("res://scripts/world/visuals/area_backdrop.gd")
const OVERLAY_SCENE := "res://scenes/world/night_overlay.tscn"
const LIGHTING_SCENE := "res://scenes/world/night_lighting.tscn"
const THROWAWAY := "user://debug_demo_throwaway/hazards"

const ARENA_X0 := -400.0
const ARENA_W := 3200.0
## Where Dave stands for each station and how long (seconds) he stays.
const STATIONS := [
	{"x": 120.0, "hold": 4.6},    # 1 steam vent at x 340
	{"x": 560.0, "hold": 4.6},    # 2 cable at x 800
	{"x": 1040.0, "hold": 7.0},   # 3 the wave, vents at 1300, 1450, 1600, 1750
	{"x": 2150.0, "hold": 5.4},   # 4 the conveyor, x 2100..2640: he is carried off its end
]

var hero: Hero
var camera: GameCamera
var wave: Node2D
var only: int = 0


func _enter_tree() -> void:
	CheckpointService.set_save_dir(THROWAWAY + "/saves")
	var tel := get_node_or_null("/root/Telemetry")
	if tel and tel.has_method("set_playtest_dir"):
		tel.set_playtest_dir(THROWAWAY + "/playtests")


func _ready() -> void:
	only = int(OS.get_environment("HAZARD_STATION"))
	RenderingServer.set_default_clear_color(Color("#0E1726"))
	Session.new_run()
	_build_world()
	hero = HeroScene.instantiate()
	hero.position = Vector2(STATIONS[0]["x"], -1.0)
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	add_child(hero)
	camera = CameraScene.instantiate()
	camera.set("target", hero)
	camera.set("world_limits", Rect2(ARENA_X0, -800.0, ARENA_W, 960.0))
	add_child(camera)
	if ResourceLoader.exists(LIGHTING_SCENE):
		add_child(load(LIGHTING_SCENE).instantiate())
	if ResourceLoader.exists(OVERLAY_SCENE):
		add_child(load(OVERLAY_SCENE).instantiate())
	_run.call_deferred()


func _block(r: Rect2, kind: int) -> void:
	var b := StaticBody2D.new()
	b.set_script(BlockScript)
	b.position = r.position
	b.set("size", r.size)
	b.set("kind", kind)
	$Geometry.add_child(b)


func _build_world() -> void:
	var bg := Node2D.new()
	bg.name = "Background"
	bg.position = Vector2(ARENA_X0, 0.0)
	add_child(bg)
	for mode in [0, 3]:   # SKY, LAB
		var layer := Parallax2D.new()
		layer.set_script(BackdropScript)
		layer.set("mode", mode)
		layer.set("tile_width", ARENA_W)
		layer.set("horizon_y", 0.0)
		bg.add_child(layer)
	var geo := Node2D.new()
	geo.name = "Geometry"
	add_child(geo)
	_block(Rect2(ARENA_X0, 0.0, 2500.0, 320.0), BlockScript.Kind.GROUND)
	_block(Rect2(2100.0, 40.0, 540.0, 280.0), BlockScript.Kind.GROUND)   # under the conveyor
	_block(Rect2(2640.0, 0.0, ARENA_X0 + ARENA_W - 2640.0, 320.0), BlockScript.Kind.GROUND)
	_block(Rect2(ARENA_X0, -300.0, 60.0, 300.0), BlockScript.Kind.WALL)
	var ents := Node2D.new()
	ents.name = "Entities"
	add_child(ents)
	# 1. a steam vent
	var steam: Area2D = VentScene.instantiate()
	steam.position = Vector2(340.0, 0.0)
	steam.idle_time = 1.0
	ents.add_child(steam)
	# 2. a live cable
	var cable: Area2D = VentScene.instantiate()
	cable.kind = 1
	cable.length = 240.0
	cable.position = Vector2(800.0, 0.0)
	cable.idle_time = 1.0
	ents.add_child(cable)
	# 3. the wave: four vents under a sequencer
	wave = SequencerScene.instantiate()
	wave.spacing = 0.6
	wave.rest = 1.2
	wave.autostart = false
	wave.position = Vector2(1300.0, 0.0)
	ents.add_child(wave)
	for i in 4:
		var v: Area2D = VentScene.instantiate()
		v.position = Vector2(150.0 * i, 0.0)
		v.name = "Vent%d" % i
		wave.add_child(v)
	# 4. the conveyor, carrying right, with crates
	var belt: StaticBody2D = ConveyorScene.instantiate()
	belt.position = Vector2(2100.0, 0.0)
	belt.size = Vector2(540.0, 40.0)
	belt.speed = 120.0
	belt.cargo = 3
	ents.add_child(belt)


func _wait(s: float) -> void:
	await get_tree().create_timer(s).timeout


func _station(i: int) -> void:
	var st: Dictionary = STATIONS[i]
	hero.respawn_at(Vector2(st["x"], -1.0))
	camera.reset_position()
	hero.aim_override = hero.global_position + Vector2(300.0, -20.0)
	print("[hazards_demo] station %d at x=%d" % [i + 1, int(st["x"])])
	if i == 2:
		wave.start()
	if i == 3:
		# ride the belt, standing still
		pass
	await _wait(float(st["hold"]))
	if i == 2:
		wave.stop()


func _run() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	hero.input_enabled = false
	for i in STATIONS.size():
		if only != 0 and only != i + 1:
			continue
		await _station(i)
	get_tree().quit()
