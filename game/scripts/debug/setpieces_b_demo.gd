extends Node2D
## Capture demo (tools/capture.sh, 300 frames at 30 fps): Level 2 v2's set pieces, part B.
## A kennel pod row: Dave walks past the trigger, pod A's ring light goes amber then red, the
## glass slides up and its Hound comes for him; he shoots it, and pod B (`after` pod A, 0.8 s)
## releases the second Hound. Then (from 6 s) the drone launch rack on the cage wall: Dave's
## approach activates it and it launches two docked Security Drones along their arcs (the
## interval is shortened to 2 s so the capture shows two launches; the level uses 6 s).
## `-- --part=rack` starts at the rack, lets it launch twice, then shoots its four clamps:
## the rack goes dark and its hidden chip tray appears. `-- --part=props` shows a showroom
## plinth (a covered Patrol Rover) and a service door (a Night Guard) released in turn, for
## judging those stand-in looks. Dave is invulnerable. Throwaway save.

const HeroScene := preload("res://scenes/actors/hero.tscn")
const CameraScene := preload("res://scenes/actors/game_camera.tscn")
const SceneryScene := preload("res://scenes/objects/scenery.tscn")
const HoundScene := preload("res://scenes/actors/hound.tscn")
const DroneScene := preload("res://scenes/actors/security_drone.tscn")
const PodScene := preload("res://scenes/objects/release_pod.tscn")
const RackScene := preload("res://scenes/objects/launch_rack.tscn")
const CacheScene := preload("res://scenes/objects/chip_cache.tscn")
const ReleasePod := preload("res://scripts/objects/release_pod.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const BackdropScript := preload("res://scripts/world/visuals/area_backdrop.gd")
const OVERLAY_SCENE := "res://scenes/world/night_overlay.tscn"
const LIGHTING_SCENE := "res://scenes/world/night_lighting.tscn"
const THROWAWAY := "user://debug_demo_throwaway/setpieces_b_demo"

const ARENA_X0 := -400.0
const ARENA_W := 3600.0
const POD_A_X := 760.0
const POD_B_X := 960.0
const POD_TRIGGER_X := 450.0
const RACK_AT := Vector2(2250.0, -150.0)
const RACK_TRIGGER_X := 1950.0
const DRONE_HOMES := [Vector2(2430.0, -175.0), Vector2(2580.0, -180.0), Vector2(2720.0, -175.0)]

var hero: Hero
var camera: Camera2D
var entities: Node2D
var encounters: Node2D
var dogs: Array = []
var pods: Array = []
var rack: Node2D
var _part: String = ""


func _enter_tree() -> void:
	CheckpointService.set_save_dir(THROWAWAY + "/saves")
	var tel := get_node_or_null("/root/Telemetry")
	if tel and tel.has_method("set_playtest_dir"):
		tel.set_playtest_dir(THROWAWAY + "/playtests")


func _ready() -> void:
	CheckpointService.set_save_dir(THROWAWAY + "/saves")
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--part="):
			_part = a.trim_prefix("--part=")
	RenderingServer.set_default_clear_color(Color("#0E1726"))
	Session.new_run("L02")
	_build_world()
	encounters = Node2D.new()
	encounters.name = "Encounters"
	add_child(encounters)
	_build_hero()
	if _part == "props":
		_build_props()
	else:
		_build_pods()
		_build_rack()
	if ResourceLoader.exists(LIGHTING_SCENE):
		add_child(load(LIGHTING_SCENE).instantiate())
	if ResourceLoader.exists(OVERLAY_SCENE):
		add_child(load(OVERLAY_SCENE).instantiate())
	_run()


# --- world -------------------------------------------------------------------------------

func _build_world() -> void:
	var bg := Node2D.new()
	bg.name = "Background"
	bg.position = Vector2(ARENA_X0, 0.0)
	add_child(bg)
	for mode in [0, 1]:
		var layer := Parallax2D.new()
		layer.set_script(BackdropScript)
		layer.set("mode", mode)
		layer.set("tile_width", ARENA_W)
		layer.set("horizon_y", 0.0)
		bg.add_child(layer)
	var geo := Node2D.new()
	geo.name = "Geometry"
	add_child(geo)
	_block(geo, Rect2(ARENA_X0, 0.0, ARENA_W, 320.0), BlockScript.Kind.GROUND)
	_block(geo, Rect2(ARENA_X0, -260.0, 60.0, 260.0), BlockScript.Kind.WALL)
	_block(geo, Rect2(ARENA_X0 + ARENA_W - 60.0, -260.0, 60.0, 260.0), BlockScript.Kind.WALL)
	var scenery := Node2D.new()
	scenery.name = "Scenery"
	add_child(scenery)
	for x in [250.0, 1200.0, 1700.0, 2950.0]:
		_prop(scenery, 6, Vector2(x, 0.0), Vector2(30.0, 110.0))
	_prop(scenery, 11, Vector2(860.0, -230.0), Vector2(150.0, 40.0), "K9 KENNEL")
	_prop(scenery, 11, Vector2(2250.0, -330.0), Vector2(150.0, 40.0), "FLIGHT CAGE")
	entities = Node2D.new()
	entities.name = "Entities"
	add_child(entities)


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


func _build_hero() -> void:
	hero = HeroScene.instantiate()
	hero.position = Vector2(300.0 if _part != "rack" else 1850.0, 0.0)
	entities.add_child(hero)
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	hero.aim_override = hero.position + Vector2(300.0, -40.0)
	camera = CameraScene.instantiate()
	camera.set("target", hero)
	camera.set("world_limits", Rect2(ARENA_X0, -800.0, ARENA_W, 960.0))
	add_child(camera)


func _group(gname: String, cap: int = 1, share: Node = null) -> EncounterGroup:
	var g := EncounterGroup.new()
	g.name = gname
	g.group_id = gname
	g.wait_for_trigger = true
	g.max_attackers = cap
	if share != null:
		g.share_tokens_with = NodePath("../" + String(share.name))
	encounters.add_child(g)
	return g


## Two kennel pods, each holding a Hound; pod B shares pod A's token pool and opens 0.8 s
## after pod A's dog is down.
func _build_pods() -> void:
	var ga := _group("E10_PodA")
	var gb := _group("E10_PodB", 1, ga)
	var i := 0
	for spec in [[ga, POD_A_X], [gb, POD_B_X]]:
		var dog: Node2D = HoundScene.instantiate()
		dog.set("entity_id", "L02-E10-K01-0%d" % (i + 1))
		dog.position = Vector2(spec[1] + 12.0, 0.0)
		spec[0].add_child(dog)
		dogs.append(dog)
		i += 1
	var pa = PodScene.instantiate()
	pa.name = "PodA"
	pa.variant = ReleasePod.Kind.POD
	pa.position = Vector2(POD_A_X, 0.0)
	pa.group = ga.get_path()
	pa.trigger_x = POD_TRIGGER_X
	entities.add_child(pa)
	var pb = PodScene.instantiate()
	pb.name = "PodB"
	pb.variant = ReleasePod.Kind.POD
	pb.position = Vector2(POD_B_X, 0.0)
	pb.group = gb.get_path()
	pb.after = pa.get_path()
	pb.delay = 0.8
	entities.add_child(pb)
	pods = [pa, pb]


func _build_rack() -> void:
	var g := _group("E12_Rack", 1)
	var paths: Array[NodePath] = []
	for k in DRONE_HOMES.size():
		var d: Node2D = DroneScene.instantiate()
		d.set("entity_id", "L02-E12-M02-0%d" % (k + 1))
		d.position = DRONE_HOMES[k]
		d.set("patrol_min_x", DRONE_HOMES[k].x - 80.0)
		d.set("patrol_max_x", DRONE_HOMES[k].x + 80.0)
		g.add_child(d)
		paths.append(d.get_path())
	var cache = CacheScene.instantiate()
	cache.entity_id = "L02-A03-CACHE01"
	cache.value = 5
	cache.position = Vector2(RACK_AT.x - 120.0, 0.0)
	entities.add_child(cache)
	rack = RackScene.instantiate()
	rack.position = RACK_AT
	rack.drones = paths
	rack.group = g.get_path()
	rack.reward = cache.get_path()
	rack.trigger_x = RACK_TRIGGER_X
	rack.interval = 2.0
	rack.first_delay = 0.3
	entities.add_child(rack)


# --- the scripted run --------------------------------------------------------------------

func _wait(t: float) -> void:
	await get_tree().create_timer(t, false, true).timeout


func _alive(e) -> bool:
	return is_instance_valid(e) and not e.is_queued_for_deletion() and not ReleasePod.enemy_down(e)


## Walks Dave to x, then stops.
func _walk_to(x: float) -> void:
	var dir := "move_right" if x > hero.global_position.x else "move_left"
	Input.action_press(dir)
	for i in 600:
		await get_tree().physics_frame
		if (dir == "move_right" and hero.global_position.x >= x) or (dir == "move_left" and hero.global_position.x <= x):
			break
	Input.action_release(dir)


## Holds fire at the dog once it is out and close, until it is down.
func _shoot_dog(dog) -> void:
	for i in 600:
		await get_tree().physics_frame
		if not _alive(dog):
			break
		hero.aim_override = dog.global_position + Vector2(0.0, -30.0)
		if absf(dog.global_position.x - hero.global_position.x) < 230.0:
			Input.action_press("fire")
	Input.action_release("fire")


## A plinth with a covered Patrol Rover and a service door holding a Night Guard.
func _build_props() -> void:
	var gp := _group("E24_Plinth")
	var rover: Node2D = load("res://scenes/actors/patrol_rover.tscn").instantiate()
	rover.set("entity_id", "L02-E24-M01-01")
	rover.position = Vector2(760.0, 0.0)
	gp.add_child(rover)
	var pl = PodScene.instantiate()
	pl.variant = ReleasePod.Kind.PLINTH
	pl.position = Vector2(760.0, 0.0)
	pl.group = gp.get_path()
	pl.trigger_x = POD_TRIGGER_X
	entities.add_child(pl)
	var gd := _group("E26_Door")
	var guard: Node2D = load("res://scenes/actors/night_guard.tscn").instantiate()
	guard.set("entity_id", "L02-E26-SE01-01")
	guard.position = Vector2(1000.0, 0.0)
	gd.add_child(guard)
	var door = PodScene.instantiate()
	door.variant = ReleasePod.Kind.DOOR
	door.position = Vector2(1000.0, 0.0)
	door.group = gd.get_path()
	door.after = pl.get_path()
	door.delay = 0.5
	entities.add_child(door)
	dogs = [rover, guard]


func _run() -> void:
	await get_tree().physics_frame
	if _part == "props":
		await _walk_to(470.0)
		# Let each exhibit come out and show itself, then put it down (a scripted kill).
		for e in dogs:
			for i in 600:
				await get_tree().physics_frame
				if e.is_visible_in_tree() and e.can_process():
					break
			await _wait(1.4)
			while _alive(e):
				# The rover's battery only takes hits in its stall (the punish window), so the
				# scripted kill calls its handler; the guard just takes the hit.
				if e.has_method("_on_rear_hit"):
					e.call("_on_rear_hit", 1, e.global_position + Vector2(0.0, -30.0), Vector2.RIGHT)
				else:
					var zone: HitZone = e.get("hit_zone")
					zone.take_hit(1, zone.global_position, Vector2.RIGHT)
				await _wait(0.15)
		await _wait(3.0)
		return
	if _part != "rack":
		await _walk_to(490.0)
		hero.aim_override = hero.global_position + Vector2(300.0, -40.0)
		await _shoot_dog(dogs[0])
		await _shoot_dog(dogs[1])
		await _wait(0.6)
		hero.global_position = Vector2(1800.0, 0.0)
		hero.reset_physics_interpolation()
		camera.call("reset_position")
	await _walk_to(2000.0)
	hero.aim_override = hero.global_position + Vector2(300.0, -200.0)
	if _part == "rack":
		await _wait(5.0)
		for i in 4:
			var z: HitZone = rack.clamp_zone(i)
			hero.aim_override = z.global_position
			await _wait(0.4)
			for k in rack.clamp_health:
				Input.action_press("fire")
				await _wait(0.12)
				Input.action_release("fire")
				if z.monitorable:
					z.take_hit(1, z.global_position, Vector2.RIGHT)
				await _wait(0.25)
		await _wait(3.0)
