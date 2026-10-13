extends Node2D
## Enemy lab for Level 2's three new types (M4): the SE02 Sidearm Guard (the Gunner
## template) behind a range bench, a second one on a raised step (the aimed shot at
## another floor), the M02 Security Drone (the Drone template) over a deck, and the K01
## Hound with its Night Guard handler in front of a kennel wall. Real scenes, the night
## lighting and overlay, Dave; it never saves (a throwaway folder, like enemy_lab.gd).
##
## Keys: A/D move, Space/W jump, mouse aim + click fire, plus
##   1 Sidearm Guard   2 Security Drone   3 Hound + handler   K kill all   C clear bodies
##   I Dave invulnerable   Z zoom   T slow motion   F1 help   Esc quit
## `-- --autoplay` runs a scripted tour of all of them (for captures); `-- --autoplay=drone`
## (or gunner, ledge, hound) runs only that part.

const HeroScene := preload("res://scenes/actors/hero.tscn")
const CameraScene := preload("res://scenes/actors/game_camera.tscn")
const SceneryScene := preload("res://scenes/objects/scenery.tscn")
const GunnerScene := preload("res://scenes/actors/sidearm_guard.tscn")
const DroneScene := preload("res://scenes/actors/security_drone.tscn")
const HoundScene := preload("res://scenes/actors/hound.tscn")
const GuardScene := preload("res://scenes/actors/night_guard.tscn")
const BlockScript := preload("res://scripts/world/block.gd")
const BackdropScript := preload("res://scripts/world/visuals/area_backdrop.gd")
const Blood := preload("res://scripts/effects/blood.gd")
const OVERLAY_SCENE := "res://scenes/world/night_overlay.tscn"
const LIGHTING_SCENE := "res://scenes/world/night_lighting.tscn"

const THROWAWAY := "user://enemy_lab_l02_throwaway"
const ARENA_X0 := -400.0
const ARENA_W := 4200.0
## A low range bench: 0.6 H, cover against a flat round.
const BENCH := Rect2(540.0, -58.0, 48.0, 58.0)
const GUNNER_X := 960.0
## The raised step (one jump up) and the gunner on it.
const STEP := Rect2(1420.0, -110.0, 320.0, 110.0)
const LEDGE_GUNNER_X := 1660.0
const DRONE_AT := Vector2(2300.0, -250.0)
const DRONE_SPAN := Vector2(2150.0, 2450.0)
const HOUND_X := 3150.0
const HANDLER_X := 3330.0
const KENNEL_WALL := Rect2(3440.0, -200.0, 50.0, 200.0)
const HELP := "ENEMY LAB L02: Sidearm Guard, Security Drone, Hound + handler\nA/D move · Space jump · mouse aim · click fire\n1 guard · 2 drone · 3 hound · K kill all · C clear\nI invulnerable · Z zoom · T slow-mo · F1 help · Esc quit"

var hero: Hero
var camera: Camera2D
var entities: Node2D
var hud_label: Label
var _autoplay: String = ""


func _enter_tree() -> void:
	var cps := get_node_or_null("/root/CheckpointService")
	if cps and cps.has_method("set_save_dir"):
		cps.set_save_dir(THROWAWAY + "/saves")
	var tel := get_node_or_null("/root/Telemetry")
	if tel and tel.has_method("set_playtest_dir"):
		tel.set_playtest_dir(THROWAWAY + "/playtests")


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "--autoplay":
			_autoplay = "all"
		elif a.begins_with("--autoplay="):
			_autoplay = a.trim_prefix("--autoplay=")
	RenderingServer.set_default_clear_color(Color("#0E1726"))
	if Session:
		Session.new_run()
	_build_world()
	_build_hero()
	if ResourceLoader.exists(LIGHTING_SCENE):
		add_child(load(LIGHTING_SCENE).instantiate())
	if ResourceLoader.exists(OVERLAY_SCENE):
		add_child(load(OVERLAY_SCENE).instantiate())
	_build_hud()
	_spawn_gunner(GUNNER_X, "L02-LAB-SE02-01")
	_spawn_gunner(LEDGE_GUNNER_X, "L02-LAB-SE02-02", STEP.position.y)
	_spawn_drone()
	_spawn_hound_pair()
	if _autoplay != "":
		_run_autoplay()


# --- world ---------------------------------------------------------------------------

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
	_block(geo, Rect2(ARENA_X0, -200.0, 60.0, 200.0), BlockScript.Kind.WALL)
	_block(geo, Rect2(ARENA_X0 + ARENA_W - 60.0, -200.0, 60.0, 200.0), BlockScript.Kind.WALL)
	_block(geo, BENCH, BlockScript.Kind.BACKSTOP)
	_block(geo, STEP, BlockScript.Kind.PLATFORM)
	_block(geo, KENNEL_WALL, BlockScript.Kind.WALL)
	var scenery := Node2D.new()
	scenery.name = "Scenery"
	add_child(scenery)
	for x in [300.0, 800.0, 1250.0, 1700.0, 2150.0, 2600.0, 3000.0, 3300.0]:
		_prop(scenery, 6, Vector2(x, 0.0), Vector2(30.0, 110.0))
	_prop(scenery, 11, Vector2(760.0, -170.0), Vector2(150.0, 40.0), "RANGE 2")
	_prop(scenery, 11, Vector2(2300.0, -380.0), Vector2(150.0, 40.0), "FLIGHT CAGE")
	_prop(scenery, 11, Vector2(3300.0, -170.0), Vector2(120.0, 40.0), "K9 KENNEL")
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
	hero.position = Vector2(150.0, 0.0)
	entities.add_child(hero)
	camera = CameraScene.instantiate()
	camera.set("target", hero)
	camera.set("world_limits", Rect2(ARENA_X0, -800.0, ARENA_W, 960.0))
	add_child(camera)


# --- enemies ---------------------------------------------------------------------------

func _spawn_gunner(x: float, id: String, floor_y: float = 0.0) -> void:
	var g: Gunner = GunnerScene.instantiate()
	g.entity_id = id
	g.position = Vector2(x, floor_y)
	entities.add_child(g)
	g.defeated.connect(_on_defeated.unbind(1))


func _spawn_drone() -> void:
	var d: Drone = DroneScene.instantiate()
	d.entity_id = "L02-LAB-M02-01"
	d.patrol_min_x = DRONE_SPAN.x
	d.patrol_max_x = DRONE_SPAN.y
	d.position = DRONE_AT
	entities.add_child(d)
	d.defeated.connect(_on_defeated.unbind(1))


## The handler and his dog share one encounter (one attacker at a time).
func _spawn_hound_pair() -> void:
	var group := EncounterGroup.new()
	group.name = "KennelGroup"
	entities.add_child(group)
	var handler: Brawler = GuardScene.instantiate()
	handler.name = "Handler"
	handler.entity_id = "L02-LAB-SE01-01"
	handler.position = Vector2(HANDLER_X, 0.0)
	handler.patrol_min_x = HANDLER_X - 20.0
	handler.patrol_max_x = HANDLER_X + 20.0
	group.add_child(handler)
	var dog: Hound = HoundScene.instantiate()
	dog.name = "Hound"
	dog.entity_id = "L02-LAB-K01-01"
	dog.position = Vector2(HOUND_X, 0.0)
	dog.handler_path = NodePath("../Handler")
	group.add_child(dog)
	handler.defeated.connect(_on_defeated.unbind(1))
	dog.defeated.connect(_on_defeated.unbind(1))


func _on_defeated() -> void:
	pass


func _enemies() -> Array:
	return get_tree().get_nodes_in_group("enemy").filter(func(e): return is_instance_valid(e) and not e.is_queued_for_deletion())


func _kill_all() -> void:
	for e in _enemies():
		var dir := Vector2(signf(e.global_position.x - hero.global_position.x), -0.15).normalized()
		while is_instance_valid(e) and not e.is_queued_for_deletion() and e.health > 0:
			e.hit_zone.take_hit(1, e.global_position + Vector2(0.0, -40.0), dir)


func _clear_bodies() -> void:
	for n in get_tree().get_nodes_in_group("enemy_round"):
		n.queue_free()
	for n in entities.get_children() + get_children():
		var nm := String(n.name)
		if nm.begins_with("Body_") or nm.begins_with("Wreck_") or nm.begins_with("Gun_"):
			n.queue_free()
	Blood.clear()


# --- input -----------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if _autoplay != "" or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_1:
			_spawn_gunner(hero.global_position.x + 420.0, "")
		KEY_2:
			var d: Drone = DroneScene.instantiate()
			d.position = hero.global_position + Vector2(260.0, -250.0)
			entities.add_child(d)
		KEY_3:
			_spawn_hound_pair()
		KEY_K:
			_kill_all()
		KEY_C:
			_clear_bodies()
		KEY_I:
			hero.debug_invulnerable = not hero.debug_invulnerable
		KEY_Z:
			camera.zoom = Vector2.ONE * (2.0 if camera.zoom.x < 1.5 else 1.2)
		KEY_T:
			Engine.time_scale = 0.3 if Engine.time_scale > 0.5 else 1.0
		KEY_F1:
			hud_label.visible = not hud_label.visible
		KEY_ESCAPE:
			Engine.time_scale = 1.0
			get_tree().quit()
		_:
			return
	get_viewport().set_input_as_handled()


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	hud_label = Label.new()
	hud_label.text = HELP
	hud_label.position = Vector2(16.0, 12.0)
	hud_label.add_theme_font_size_override("font_size", 14)
	hud_label.add_theme_color_override("font_color", Color("#D8E6F0"))
	hud_label.add_theme_color_override("font_outline_color", Color("#05070B"))
	hud_label.add_theme_constant_override("outline_size", 5)
	layer.add_child(hud_label)
	hud_label.visible = _autoplay == ""


func _process(_delta: float) -> void:
	if Session and Session.get_health() <= 1 and not hero.debug_invulnerable:
		Session.heal_full()


# --- scripted tour for captures ----------------------------------------------------------
# Each step waits on what the enemies do (a tell, a lock, a dive, a recovery), not on fixed
# times, so the tour survives tuning changes. Dave is invulnerable: a mistimed dodge only
# costs nothing.

func _run_autoplay() -> void:
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(300.0, -40.0)
	if _autoplay in ["all", "gunner"]:
		await _tour_gunner()
	if _autoplay in ["all", "ledge"]:
		await _tour_ledge()
	if _autoplay in ["all", "drone"]:
		await _tour_drone()
	if _autoplay in ["all", "hound"]:
		await _tour_hound()
	await _wait(1.0)
	get_tree().quit()


func _gunner_at(x: float) -> Gunner:
	for e in _enemies():
		if e is Gunner and absf(e.global_position.x - x) < 200.0:
			return e
	return null


## The bench: Dave behind it takes the flat round on the bench; then out in the open he
## jumps the next one, and shoots the guard three times while he racks the slide.
func _tour_gunner() -> void:
	await _teleport(Vector2(470.0, 0.0))
	var g := _gunner_at(GUNNER_X)
	hero.aim_override = Vector2(GUNNER_X, -60.0)
	await _until(func(): return g == null or not is_instance_valid(g) or g.state == Gunner.State.RELOAD, 8.0)
	await _wait(0.6)
	# Over the bench into the open.
	Input.action_press(&"move_right")
	Input.action_press(&"jump")
	await _wait(0.25)
	Input.action_release(&"jump")
	await _until(func(): return hero.global_position.x >= 660.0, 3.0)
	Input.action_release(&"move_right")
	await _until(func(): return hero.is_on_floor(), 2.0)
	await _until(func(): return not is_instance_valid(g) or g.is_tell_red(), 8.0)
	await _wait(0.12)
	Input.action_press(&"jump")
	await _wait(0.45)
	Input.action_release(&"jump")
	await _until(func(): return not is_instance_valid(g) or g.state == Gunner.State.RELOAD, 4.0)
	for i in 3:
		if is_instance_valid(g):
			hero.aim_override = g.global_position + Vector2(0.0, -60.0)
		await _tap(&"fire")
		await _wait(0.34)
	await _wait(2.5)


## The step: the guard up there aims at Dave's grounded spot below; Dave keeps walking
## once the aim locks, so the round strikes the floor where he stood.
func _tour_ledge() -> void:
	await _teleport(Vector2(1180.0, 0.0))
	# Zoomed out a little so the guard on the step stays well inside the view (the
	# readability gate) while Dave steps aside.
	camera.zoom = Vector2.ONE
	var g := _gunner_at(LEDGE_GUNNER_X)
	hero.aim_override = Vector2(LEDGE_GUNNER_X, -170.0)
	await _until(func(): return not is_instance_valid(g) or g.is_aim_locked(), 8.0)
	Input.action_press(&"move_left")
	await _wait(0.3)
	Input.action_release(&"move_left")
	await _until(func(): return not is_instance_valid(g) or g.state == Gunner.State.RELOAD, 3.0)
	for i in 3:
		if is_instance_valid(g):
			hero.aim_override = g.global_position + Vector2(0.0, -60.0)
		await _tap(&"fire")
		await _wait(0.34)
	await _wait(2.5)
	camera.zoom = Vector2.ONE * 1.2


## The drone: Dave waits under it, steps aside once the aim locks, and shoots it twice
## while it hangs at head height.
func _tour_drone() -> void:
	await _teleport(Vector2(2120.0, 0.0))
	var d: Drone = null
	for e in _enemies():
		if e is Drone:
			d = e
	hero.aim_override = DRONE_AT
	await _until(func(): return d == null or not is_instance_valid(d) or d.is_lock_set(), 10.0)
	var away := &"move_left" if is_instance_valid(d) and d.global_position.x > hero.global_position.x else &"move_right"
	Input.action_press(away)
	await _wait(0.42)
	Input.action_release(away)
	await _until(func(): return not is_instance_valid(d) or d.is_hanging(), 3.0)
	await _wait(0.2)
	for i in 2:
		if is_instance_valid(d):
			hero.aim_override = d.global_position
		await _tap(&"fire")
		await _wait(0.34)
	await _wait(3.0)


## The kennel: the dog's double lunge (Dave jumps each one), two shots in its rigid
## recovery, then its handler's turn, 1.5 s after the chain.
func _tour_hound() -> void:
	await _teleport(Vector2(2700.0, 0.0))
	var dog: Hound = null
	for e in _enemies():
		if e is Hound:
			dog = e
	hero.aim_override = hero.global_position + Vector2(300.0, -10.0)
	for lunge in 2:
		await _until(func(): return not is_instance_valid(dog) or (dog.state == Brawler.State.WINDUP and dog._state_timer >= dog._windup_len - dog.tuning.red_time), 10.0)
		await _until(func(): return not is_instance_valid(dog) or dog.state == Brawler.State.STRIKE or absf(dog.global_position.x - hero.global_position.x) < 150.0, 1.0)
		Input.action_press(&"jump")
		await _wait(0.4)
		Input.action_release(&"jump")
		await _until(func(): return hero.is_on_floor(), 2.0)
	await _until(func(): return not is_instance_valid(dog) or dog.state == Brawler.State.RECOVERY, 3.0)
	for i in 2:
		if is_instance_valid(dog):
			hero.aim_override = dog.global_position + Vector2(0.0, -26.0)
		await _tap(&"fire")
		await _wait(0.34)
	await _wait(3.0)


func _teleport(at: Vector2) -> void:
	hero.global_position = at
	hero.velocity = Vector2.ZERO
	hero.reset_physics_interpolation()
	if camera.has_method("reset_position"):
		camera.reset_position()
	await get_tree().physics_frame


func _wait(secs: float) -> void:
	await get_tree().create_timer(secs, false, true).timeout


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while not cond.call() and t < timeout:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


func _tap(action: StringName) -> void:
	Input.action_press(action)
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(action)
