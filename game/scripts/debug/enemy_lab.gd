extends Node2D
## Enemy lab (C35): the three Level 1 enemies on a strip of the night campus,
## for judging the lit cutout art, the tells, the ragdolls and the blood
## without playing through the level. It uses the real scenes (the Night
## Guard, the Staffer in its annex door, the Patrol Rover and its backstop,
## Dave, the lamps, the moonlight and the night overlay) and never saves:
## saves and play logs go to a throwaway folder.
##
## Keys: A/D move, Space/W jump, mouse aim + left click fire, plus
##   1 Night Guard   2 Staffer (wakes when Dave comes near)   3 Patrol Rover
##   K kill every enemy (ragdolls)   C clear bodies and blood
##   N normal maps on/off   M moonlight on/off   B blood on/off
##   Z zoom 1x/2x   T slow motion   I Dave invulnerable   F1 help   Esc quit
## `-- --autoplay` runs a scripted tour of all three (used for captures).

const HeroScene := preload("res://scenes/actors/hero.tscn")
const CameraScene := preload("res://scenes/actors/game_camera.tscn")
const SceneryScene := preload("res://scenes/objects/scenery.tscn")
const GuardScene := preload("res://scenes/actors/night_guard.tscn")
const StafferScene := preload("res://scenes/actors/staffer.tscn")
const RoverScene := preload("res://scenes/actors/patrol_rover.tscn")
const BlockScript := preload("res://scripts/world/block.gd")
const BackdropScript := preload("res://scripts/world/visuals/area_backdrop.gd")
const Blood := preload("res://scripts/effects/blood.gd")
const OVERLAY_SCENE := "res://scenes/world/night_overlay.tscn"
const LIGHTING_SCENE := "res://scenes/world/night_lighting.tscn"

const THROWAWAY := "user://enemy_lab_throwaway"
const ARENA_X0 := -400.0
const ARENA_W := 2800.0
const GUARD_SPAWN := Vector2(860.0, 0.0)
const GUARD_PATROL := Vector2(640.0, 940.0)
const BACKSTOP_X := 1160.0
## Close enough to the stone that a charge always reaches it (a charge is
## capped at 4 hero-heights).
const ROVER_SPAWN := Vector2(1520.0, 0.0)
const ROVER_PATROL := Vector2(1450.0, 1560.0)
const ANNEX_X := 2180.0
const MAX_BODIES := 8
const HELP := "ENEMY LAB: Night Guard, Staffer, Patrol Rover\nA/D move · Space jump · mouse aim · click fire\n1 guard · 2 Staffer · 3 rover · K kill all · C clear bodies\nN normal maps · M moon · B blood · Z zoom · T slow-mo · I invulnerable · F1 help · Esc quit"

var hero: Hero
var camera: Camera2D
var entities: Node2D
var lighting: Node
var hud_label: Label
var status_label: Label
var _normals_on: bool = true
var _zoomed: bool = false
var _slow: bool = false
var _autoplay: bool = false


func _enter_tree() -> void:
	# Never touch the player's real save or play logs.
	var cps := get_node_or_null("/root/CheckpointService")
	if cps and cps.has_method("set_save_dir"):
		cps.set_save_dir(THROWAWAY + "/saves")
	var tel := get_node_or_null("/root/Telemetry")
	if tel and tel.has_method("set_playtest_dir"):
		tel.set_playtest_dir(THROWAWAY + "/playtests")


func _ready() -> void:
	_autoplay = OS.get_cmdline_user_args().has("--autoplay")
	RenderingServer.set_default_clear_color(Color("#0E1726"))
	if Session:
		Session.new_run()
	_build_world()
	_build_hero()
	if ResourceLoader.exists(LIGHTING_SCENE):
		lighting = load(LIGHTING_SCENE).instantiate()
		add_child(lighting)
	if ResourceLoader.exists(OVERLAY_SCENE):
		add_child(load(OVERLAY_SCENE).instantiate())
	_build_hud()
	_spawn_guard()
	_spawn_rover()
	_spawn_staffer()
	_update_status()
	if _autoplay:
		_run_autoplay()


# --- world ---------------------------------------------------------------------

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
	_block(geo, Vector2(ARENA_X0, 0.0), Vector2(ARENA_W, 320.0), BlockScript.Kind.GROUND)
	_block(geo, Vector2(ARENA_X0, -160.0), Vector2(60.0, 160.0), BlockScript.Kind.BACKSTOP)
	_block(geo, Vector2(ARENA_X0 + ARENA_W - 60.0, -160.0), Vector2(60.0, 160.0), BlockScript.Kind.BACKSTOP)
	# The stone the rover is baited into: low enough for Dave to hop, high
	# enough to stop a charge (and to hide him from the rover behind it).
	_block(geo, Vector2(BACKSTOP_X, -72.0), Vector2(48.0, 72.0), BlockScript.Kind.BACKSTOP)
	var scenery := Node2D.new()
	scenery.name = "Scenery"
	add_child(scenery)
	_prop(scenery, 11, Vector2(-120.0, 0.0), Vector2(170.0, 64.0), "NIGHT SHIFT ENTRANCE")
	_prop(scenery, 0, Vector2(80.0, 0.0), Vector2(180.0, 150.0))
	_prop(scenery, 2, Vector2(330.0, 0.0), Vector2(64.0, 64.0))
	_prop(scenery, 7, Vector2(520.0, 0.0), Vector2(60.0, 50.0))
	_prop(scenery, 6, Vector2(720.0, 0.0), Vector2(30.0, 110.0))
	_prop(scenery, 1, Vector2(1000.0, 0.0), Vector2(120.0, 50.0))
	_prop(scenery, 6, Vector2(1480.0, 0.0), Vector2(30.0, 110.0))
	_prop(scenery, 2, Vector2(1820.0, 0.0), Vector2(64.0, 64.0))
	_prop(scenery, 13, Vector2(ANNEX_X, 0.0), Vector2(96.0, 150.0))
	_prop(scenery, 11, Vector2(ANNEX_X, -150.0), Vector2(120.0, 40.0), "STAFF ANNEX")
	_prop(scenery, 6, Vector2(2040.0, 0.0), Vector2(30.0, 110.0))
	entities = Node2D.new()
	entities.name = "Entities"
	add_child(entities)


func _block(parent: Node, pos: Vector2, size: Vector2, kind: int) -> void:
	var b := StaticBody2D.new()
	b.set_script(BlockScript)
	b.position = pos
	b.set("size", size)
	b.set("kind", kind)
	parent.add_child(b)


func _prop(parent: Node, kind: int, pos: Vector2, size: Vector2, text: String = "") -> Node2D:
	var s: Node2D = SceneryScene.instantiate()
	s.set("kind", kind)
	s.set("size", size)
	if text != "":
		s.set("text", text)
	s.position = pos
	parent.add_child(s)
	return s


func _build_hero() -> void:
	hero = HeroScene.instantiate()
	hero.position = Vector2(150.0, 0.0)
	entities.add_child(hero)
	camera = CameraScene.instantiate()
	camera.set("target", hero)
	camera.set("world_limits", Rect2(ARENA_X0, -700.0, ARENA_W, 900.0))
	add_child(camera)


# --- enemies -------------------------------------------------------------------

func _spawn_guard(at: Vector2 = GUARD_SPAWN, patrol: Vector2 = GUARD_PATROL) -> void:
	var g: Brawler = GuardScene.instantiate()
	g.patrol_min_x = patrol.x
	g.patrol_max_x = patrol.y
	g.position = at
	entities.add_child(g)
	_after_spawn(g)


func _spawn_rover() -> void:
	var r: PatrolRover = RoverScene.instantiate()
	r.patrol_min_x = ROVER_PATROL.x
	r.patrol_max_x = ROVER_PATROL.y
	r.position = ROVER_SPAWN
	entities.add_child(r)
	_after_spawn(r)


## The Staffer stands dormant in the annex door until Dave comes within
## ~450 px, like the two at Level 1's alarm exit.
func _spawn_staffer() -> void:
	var group := EncounterGroup.new()
	group.name = "AnnexGroup"
	var zone := Area2D.new()
	zone.name = "ApproachZone"
	zone.collision_layer = 0
	zone.collision_mask = 1 << 1  # hero body
	zone.position = Vector2(ANNEX_X - 450.0, -100.0)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40.0, 400.0)
	shape.shape = rect
	zone.add_child(shape)
	group.add_child(zone)
	var s: Brawler = StafferScene.instantiate()
	s.position = Vector2(ANNEX_X, 0.0)
	group.add_child(s)
	entities.add_child(group)
	_after_spawn(s)


func _after_spawn(enemy: Node) -> void:
	if enemy.get("rig") != null and not _normals_on:
		enemy.rig.set_normals_enabled(false)
	enemy.defeated.connect(_on_enemy_defeated.unbind(1))


func _enemies() -> Array:
	return get_tree().get_nodes_in_group("enemy").filter(func(e): return is_instance_valid(e) and not e.is_queued_for_deletion())


func _on_enemy_defeated() -> void:
	# Bodies and wrecks live under this scene; keep only the newest few.
	var bodies := get_children().filter(func(n): return String(n.name).begins_with("Body_") or String(n.name).begins_with("Wreck_"))
	while bodies.size() > MAX_BODIES:
		bodies.pop_front().queue_free()
	_update_status.call_deferred()


func _kill_all() -> void:
	for e in _enemies():
		var from := signf(e.global_position.x - hero.global_position.x)
		var dir := Vector2(from if from != 0.0 else 1.0, -0.15).normalized()
		if e is Brawler:
			var at: Vector2 = e.global_position + Vector2(0.0, -70.0)
			while is_instance_valid(e) and e.state != Brawler.State.DEFEATED:
				e.hit_zone.take_hit(1, at, dir)
		elif e is PatrolRover:
			e.rear_hit_zone.blocks = false
			while is_instance_valid(e) and e.state != PatrolRover.State.DEFEATED:
				e.rear_hit_zone.take_hit(1, e.rear_hit_zone.global_position, dir)


func _clear_bodies() -> void:
	for n in get_children():
		if String(n.name).begins_with("Body_") or String(n.name).begins_with("Wreck_"):
			n.queue_free()
	Blood.clear()


func _set_normals(on: bool) -> void:
	_normals_on = on
	for e in _enemies():
		if e.get("rig") != null:
			e.rig.set_normals_enabled(on)
	var v := _find_with_method(hero, "set_normals_enabled")
	if v:
		v.set_normals_enabled(on)


func _find_with_method(n: Node, method: String) -> Node:
	for c in n.get_children():
		if c.has_method(method):
			return c
		var deep := _find_with_method(c, method)
		if deep:
			return deep
	return null


# --- input ---------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if _autoplay or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_1:
			_spawn_guard()
		KEY_2:
			_spawn_staffer()
		KEY_3:
			_spawn_rover()
		KEY_K:
			_kill_all()
		KEY_C:
			_clear_bodies()
		KEY_N:
			_set_normals(not _normals_on)
		KEY_M:
			if lighting and lighting.has_method("set_enabled"):
				lighting.moon.enabled = not lighting.moon.enabled
		KEY_B:
			Blood.enabled = not Blood.enabled
		KEY_Z:
			_zoomed = not _zoomed
			camera.zoom = Vector2.ONE * (2.0 if _zoomed else 1.0)
		KEY_T:
			_slow = not _slow
			Engine.time_scale = 0.3 if _slow else 1.0
		KEY_I:
			hero.debug_invulnerable = not hero.debug_invulnerable
		KEY_F1:
			hud_label.visible = not hud_label.visible
		KEY_ESCAPE:
			Engine.time_scale = 1.0
			get_tree().quit()
		_:
			return
	_update_status()
	get_viewport().set_input_as_handled()


# --- HUD -----------------------------------------------------------------------

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
	status_label = Label.new()
	status_label.position = Vector2(16.0, 680.0)
	status_label.add_theme_font_size_override("font_size", 13)
	status_label.add_theme_color_override("font_color", Color("#9DB0C4"))
	status_label.add_theme_color_override("font_outline_color", Color("#05070B"))
	status_label.add_theme_constant_override("outline_size", 4)
	layer.add_child(status_label)
	if _autoplay:
		hud_label.visible = false


func _update_status() -> void:
	if status_label == null or hero == null:
		return
	var moon_on: bool = lighting != null and lighting.moon.enabled
	status_label.text = "enemies %d · normals %s · moon %s · blood %s · zoom %s · slow-mo %s · invulnerable %s" % [
		_enemies().size(), _on(_normals_on), _on(moon_on), _on(Blood.enabled),
		"2x" if _zoomed else "1x", _on(_slow), _on(hero.debug_invulnerable)]


func _on(v: bool) -> String:
	return "on" if v else "off"


func _process(_delta: float) -> void:
	if Session and Session.get_health() <= 1 and not hero.debug_invulnerable:
		# A test bench, not a fight: top Dave back up rather than dying.
		Session.heal_full()


# --- scripted tour for captures ----------------------------------------------------
# Each step waits on what the enemies actually do (a windup, a charge, a
# stall), not on fixed times, so the tour survives tuning changes.

func _run_autoplay() -> void:
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(300.0, -40.0)
	camera.zoom = Vector2(2.0, 2.0)
	_zoomed = true
	var guard: Brawler = _first(Brawler, GUARD_PATROL.y + 200.0)
	var rover: PatrolRover = _first(PatrolRover, INF)
	# 1. The guard notices Dave under the lamp, walks in, winds up and swings;
	# three shots put him down: a ragdoll, then a pool.
	hero.global_position = Vector2(560.0, 0.0)
	hero.reset_physics_interpolation()
	await _wait(0.4)
	await _until(func(): return not is_instance_valid(guard) or guard.state == Brawler.State.RECOVERY, 8.0)
	for i in 3:
		if is_instance_valid(guard):
			hero.aim_override = guard.global_position + Vector2(0.0, -64.0)
		await _tap(&"fire")
		await _wait(0.45)
	await _wait(3.0)
	# 2. The rover: Dave hops the stone, waits in front of it, jumps the
	# charge, and shoots the battery while the rover sits stalled against it.
	await _walk_to(BACKSTOP_X - 70.0)
	Input.action_press(&"move_right")
	Input.action_press(&"jump")
	await _wait(0.3)
	Input.action_release(&"jump")
	await _until(func(): return hero.global_position.x >= BACKSTOP_X + 150.0, 3.0)
	Input.action_release(&"move_right")
	await _until(func(): return hero.is_on_floor(), 2.0)
	hero.aim_override = hero.global_position + Vector2(300.0, -30.0)
	await _until(func(): return not is_instance_valid(rover) or rover.is_charging(), 10.0)
	await _until(func(): return not is_instance_valid(rover) or absf(rover.global_position.x - hero.global_position.x) < 150.0, 3.0)
	Input.action_press(&"jump")
	await _wait(0.3)
	Input.action_release(&"jump")
	await _until(func(): return not is_instance_valid(rover) or rover.is_stalled(), 3.0)
	await _wait(0.35)
	for i in 3:
		if is_instance_valid(rover):
			hero.aim_override = rover.rear_hit_zone.global_position
		await _tap(&"fire")
		await _wait(0.3)
	await _wait(3.0)
	# 3. The Staffer walks out of the annex door when Dave comes near,
	# lunges, and takes two shots.
	await _walk_to(ANNEX_X - 420.0)
	var staffer: Brawler = _first(Brawler, INF)
	await _until(func(): return not is_instance_valid(staffer) or staffer.state == Brawler.State.RECOVERY, 10.0)
	for i in 2:
		if is_instance_valid(staffer):
			hero.aim_override = staffer.global_position + Vector2(0.0, -60.0)
		await _tap(&"fire")
		await _wait(0.45)
	await _wait(3.0)
	# 4. A fresh guard, flat normals for comparison, then back.
	var x := hero.global_position.x + 260.0
	_spawn_guard(Vector2(x, 0.0), Vector2(x - 60.0, x + 60.0))
	_set_normals(false)
	await _wait(1.6)
	_set_normals(true)
	await _wait(1.6)
	get_tree().quit()


func _first(type, max_x: float) -> Node:
	for e in _enemies():
		if is_instance_of(e, type) and e.global_position.x <= max_x:
			return e
	return null


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
	_update_status()


func _walk_to(x: float) -> void:
	var action := &"move_right" if x > hero.global_position.x else &"move_left"
	Input.action_press(action)
	await _until(func(): return absf(hero.global_position.x - x) < 12.0, 8.0)
	Input.action_release(action)
