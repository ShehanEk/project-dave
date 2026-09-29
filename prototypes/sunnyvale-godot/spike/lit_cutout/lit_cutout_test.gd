extends Node2D
## Lit-cutout test scene (C35): one Night Guard (SE01) and Dave on a strip
## of the Level 1 night campus, under a real Level 1 path lamp, to judge
## the new enemy art direction — painted parts lit smoothly through normal
## maps, a ragdoll death and visible blood — before Level 1 is rebuilt
## (C33). Self-contained: it adds no autoloads, edits no existing scene or
## script, and never saves (saves and play logs are redirected to a
## throwaway folder).
##
## Keys: A/D move, Space/W jump, mouse aim + left click fire, plus
##   R respawn a guard      K kill the guard (ragdoll test)
##   N normal maps on/off   L lighting: smooth / old stepped lamps
##   M moonlight on/off     B blood on/off
##   Z zoom 1x/2x           T slow motion
##   I Dave invulnerable    P guard passive/aggressive
##   F1 this help           Esc quit
## `-- --autoplay` runs a scripted demo (used for captures).

const HeroScene := preload("res://scenes/actors/hero.tscn")
const CameraScene := preload("res://scenes/actors/game_camera.tscn")
const SceneryScene := preload("res://scenes/objects/scenery.tscn")
const OverlayScene := preload("res://scenes/world/night_overlay.tscn")
const BlockScript := preload("res://scripts/world/block.gd")
const BackdropScript := preload("res://scripts/world/visuals/area_backdrop.gd")
const GuardScript := preload("res://spike/lit_cutout/scripts/night_guard.gd")
const HeroAdapter := preload("res://spike/lit_cutout/scripts/lit_hero_adapter.gd")
const Blood := preload("res://spike/lit_cutout/scripts/blood.gd")
const CONE := preload("res://spike/lit_cutout/art/light_cone_smooth.png")
const DISC := preload("res://spike/lit_cutout/art/light_disc_smooth.png")
const RECT := preload("res://spike/lit_cutout/art/light_soft_rect.png")

const THROWAWAY := "user://lit_cutout_test_throwaway"
const ARENA_X0 := -400.0
const ARENA_W := 2600.0
const LAMP_XS := [720.0, 1480.0]
const GUARD_PATROL := Vector2(640.0, 940.0)
const MAX_CORPSES := 6
const HELP := "LIT CUTOUT TEST — Night Guard (SE01)\nA/D move · Space jump · mouse aim · click fire\nR respawn guard · K kill · N normal maps · L lamp style · M moon\nB blood · Z zoom · T slow-mo · I invulnerable · P passive guard · F1 help · Esc quit"

var hero: Node2D
var camera: Camera2D
var adapter: Node
var entities: Node2D
var guard: Node2D
var moon: DirectionalLight2D
var hud_label: Label
var status_label: Label
var _lamps: Array = []
var _smooth_lights: Array = []
var _corpses: Array = []
var _normals_on: bool = true
var _smooth_on: bool = true
var _zoomed: bool = false
var _slow: bool = false
var _passive: bool = false
var _autoplay: bool = false
var _auto_t: float = 0.0


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
	_build_world()
	_build_hero()
	_build_lights()
	_spawn_guard()
	_build_hud()
	add_child(OverlayScene.instantiate())
	_update_status()


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
	_block(geo, Vector2(ARENA_X0, 0.0), Vector2(ARENA_W, 320.0), 0)
	_block(geo, Vector2(ARENA_X0, -160.0), Vector2(60.0, 160.0), 4)
	_block(geo, Vector2(ARENA_X0 + ARENA_W - 60.0, -160.0), Vector2(60.0, 160.0), 4)
	_block(geo, Vector2(1180.0, -100.0), Vector2(170.0, 22.0), 1)
	var scenery := Node2D.new()
	scenery.name = "Scenery"
	add_child(scenery)
	_prop(scenery, 11, Vector2(-120.0, 0.0), Vector2(170.0, 64.0), "NIGHT SHIFT ENTRANCE")
	_prop(scenery, 0, Vector2(80.0, 0.0), Vector2(180.0, 150.0))
	_prop(scenery, 2, Vector2(330.0, 0.0), Vector2(64.0, 64.0))
	_prop(scenery, 7, Vector2(520.0, 0.0), Vector2(60.0, 50.0))
	_prop(scenery, 1, Vector2(1040.0, 0.0), Vector2(160.0, 50.0))
	_prop(scenery, 2, Vector2(1650.0, 0.0), Vector2(64.0, 64.0))
	_prop(scenery, 7, Vector2(1880.0, 0.0), Vector2(60.0, 50.0))
	for x in LAMP_XS:
		_lamps.append(_prop(scenery, 6, Vector2(x, 0.0), Vector2(30.0, 110.0)))
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
	adapter = HeroAdapter.new()
	adapter.name = "LitHeroAdapter"
	add_child(adapter)
	adapter.setup(hero)
	if Session and Session.has_method("heal_full"):
		Session.heal_full()


# --- lights --------------------------------------------------------------------

func _build_lights() -> void:
	# Each Level 1 path lamp keeps its drawn head and glow; its stepped cone
	# light is swapped for a smooth one sitting AT the lamp head, so normal-
	# mapped parts are lit from where the lamp actually is.
	for lamp in _lamps:
		var old := _find_light(lamp)
		var head := Vector2(lamp.global_position.x, lamp.global_position.y - 110.0 * 0.9 + 4.0)
		var l := PointLight2D.new()
		l.texture = CONE
		l.texture_scale = 240.0 / 256.0
		l.color = Color(0.86, 0.91, 0.95)
		l.energy = 1.8
		l.height = 70.0
		l.blend_mode = Light2D.BLEND_MODE_ADD
		add_child(l)
		l.global_position = head
		_smooth_lights.append({"smooth": l, "old": old})
	# Teal wash from the entrance sign.
	var teal := PointLight2D.new()
	teal.texture = RECT
	teal.texture_scale = 1.6
	teal.color = Color("#3FE0D0")
	teal.energy = 0.55
	teal.height = 24.0
	teal.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(teal)
	teal.global_position = Vector2(-60.0, -60.0)
	_smooth_lights.append({"smooth": teal, "old": null})
	# Faint cold moonlight, on characters only (light mask bit 2), from the
	# upper left: a rim that keeps them readable in the dark.
	moon = DirectionalLight2D.new()
	moon.color = Color("#7E93C9")
	moon.energy = 0.4
	moon.height = 0.4
	moon.rotation_degrees = -35.0
	moon.range_item_cull_mask = 2
	moon.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(moon)
	_apply_light_style()


func _find_light(n: Node) -> PointLight2D:
	for c in n.get_children():
		if c is PointLight2D:
			return c
		var deep := _find_light(c)
		if deep:
			return deep
	return null


func _apply_light_style() -> void:
	for e in _smooth_lights:
		(e["smooth"] as PointLight2D).enabled = _smooth_on
		if e["old"]:
			(e["old"] as PointLight2D).enabled = not _smooth_on


# --- guard ---------------------------------------------------------------------

func _spawn_guard() -> void:
	if guard and is_instance_valid(guard):
		guard.queue_free()
	guard = CharacterBody2D.new()
	guard.set_script(GuardScript)
	guard.name = "NightGuard"
	guard.set("patrol_min_x", GUARD_PATROL.x)
	guard.set("patrol_max_x", GUARD_PATROL.y)
	guard.set("start_facing", -1)
	guard.set("aggressive", not _passive)
	guard.z_index = 1
	guard.position = Vector2(860.0, 0.0)
	entities.add_child(guard)
	guard.died.connect(_on_guard_died)
	if not _normals_on:
		guard.rig.set_normals_enabled(false)


func _on_guard_died(_g: Node, ragdoll: Node) -> void:
	_corpses.append(ragdoll)
	while _corpses.size() > MAX_CORPSES:
		var old = _corpses.pop_front()
		if is_instance_valid(old):
			old.queue_free()
	guard = null
	_update_status()


# --- input ---------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_R:
			_spawn_guard()
		KEY_K:
			_kill_guard()
		KEY_N:
			_normals_on = not _normals_on
			if guard and is_instance_valid(guard):
				guard.rig.set_normals_enabled(_normals_on)
			adapter.set_normals_enabled(_normals_on)
		KEY_L:
			_smooth_on = not _smooth_on
			_apply_light_style()
		KEY_M:
			moon.enabled = not moon.enabled
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
		KEY_P:
			_passive = not _passive
			if guard and is_instance_valid(guard):
				guard.aggressive = not _passive
		KEY_F1:
			hud_label.visible = not hud_label.visible
		KEY_ESCAPE:
			Engine.time_scale = 1.0
			get_tree().quit()
		_:
			return
	_update_status()
	get_viewport().set_input_as_handled()


func _kill_guard() -> void:
	if guard == null or not is_instance_valid(guard):
		return
	var hz: HitZone = guard.hit_zone
	var from_hero := (guard.global_position - hero.global_position).normalized()
	var at: Vector2 = guard.global_position + Vector2(0.0, -70.0)
	while guard and is_instance_valid(guard) and guard.state != GuardScript.State.DEAD:
		hz.take_hit(1, at, Vector2(signf(from_hero.x), -0.15).normalized())


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
	if status_label == null:
		return
	status_label.text = "normals %s · lamps %s · moon %s · blood %s · zoom %s · slow-mo %s · invulnerable %s · guard %s" % [
		_on(_normals_on), "smooth" if _smooth_on else "old stepped", _on(moon.enabled), _on(Blood.enabled),
		"2x" if _zoomed else "1x", _on(_slow), _on(hero.debug_invulnerable),
		"passive" if _passive else "aggressive"]


func _on(v: bool) -> String:
	return "on" if v else "off"


func _process(delta: float) -> void:
	if Session and Session.get_health() <= 1 and not hero.debug_invulnerable:
		# A test bench, not a fight: top Dave back up rather than dying.
		Session.heal_full()
	if _autoplay:
		_run_autoplay(delta)


# --- scripted demo for captures ----------------------------------------------------

func _run_autoplay(delta: float) -> void:
	var prev := _auto_t
	_auto_t += delta
	var t := _auto_t
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	var aim_target := hero.global_position + Vector2(300.0, -40.0)
	if guard and is_instance_valid(guard):
		aim_target = guard.global_position + Vector2(0.0, -64.0)
	hero.aim_override = aim_target
	Input.action_release("move_right")
	Input.action_release("move_left")
	Input.action_release("fire")
	if prev == 0.0:
		hero.global_position = Vector2(610.0, 0.0)
		hero.reset_physics_interpolation()
		camera.zoom = Vector2(2.0, 2.0)
		_zoomed = true
	# 0-4 s: the guard notices Dave, walks in under the lamp, winds up and
	# swings (Dave is invulnerable for the demo).
	# 4-6.5 s: three shots, a beat apart, then the ragdoll and the pool.
	for shot_t in [4.2, 5.0, 5.8]:
		if prev < shot_t and t >= shot_t:
			Input.action_press("fire")
	# 9.5 s: a new guard; 11-13 s flat normals for comparison; 13+ kill.
	if prev < 9.5 and t >= 9.5:
		_spawn_guard()
	if prev < 11.0 and t >= 11.0:
		_normals_on = false
		if guard and is_instance_valid(guard):
			guard.rig.set_normals_enabled(false)
		adapter.set_normals_enabled(false)
	if prev < 12.6 and t >= 12.6:
		_normals_on = true
		if guard and is_instance_valid(guard):
			guard.rig.set_normals_enabled(true)
		adapter.set_normals_enabled(true)
	for shot_t in [14.0, 14.4, 14.8]:
		if prev < shot_t and t >= shot_t:
			Input.action_press("fire")
	_update_status()
