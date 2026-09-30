extends TestCase
## Rook sprite rig (scripts/actors/visuals/hero_visual.gd + the processed
## sprite pack in assets/characters/rook/): the body frame follows the hero's
## state, AimPivot stays on the current frame's shoulder (so the arm and the
## Scrapjack stay attached), and the arm + gun hide when Rook is defeated.
## Lit like the enemies (C35): the body and arm use the shared lit-part shader
## with each frame's normal map (a frame without one falls back to flat
## normals). Presentation only — movement/collision are covered by the M1
## tests.

const Frames := preload("res://scripts/actors/visuals/rook_frames.gd")
const LIT_SHADER_PATH := "res://assets/shaders/lit_part.gdshader"
const NORMAL_DIR := "res://assets/characters/rook/normals/"


func run() -> void:
	_test_textures_load()
	_test_smoothing_settings()
	await _test_states()
	await _test_faces_aim_and_backpedals()
	await _test_lit_with_normal_maps()


func _test_textures_load() -> void:
	var names := ["idle_1", "idle_2", "run_1", "run_2", "run_3", "run_4", "run_5", "run_6",
			"jump_rise", "jump_fall", "land", "hurt", "defeated", "interact", "arm"]
	for n in names:
		var tex: Texture2D = load("res://assets/characters/rook/rook_%s.png" % n)
		check(tex != null, "texture rook_%s loads" % n)
		if tex and n != "arm":
			check_eq(tex.get_size(), Vector2(256, 256), "rook_%s is on the shared 256x256 canvas" % n)
		if n != "arm":
			check(Frames.SHOULDER.has(StringName(n)), "rook_%s has a shoulder pivot" % n)


func _make_level() -> Hero:
	var floor_block := Block.new()
	floor_block.size = Vector2(4000, 64)
	floor_block.position = Vector2(-2000, 0)
	add_child(floor_block)
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	hero.position = Vector2(0, -1)
	add_child(hero)
	return hero


func _test_states() -> void:
	var hero := _make_level()
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(500, -80)
	await seconds(0.5)
	var visual = hero.visual
	var frame: StringName = visual.current_frame()
	check(frame == &"idle_1" or frame == &"idle_2", "standing still shows an idle frame (got %s)" % frame)
	check(hero.aim_pivot.position.distance_to(visual.shoulder_offset()) < 0.01,
			"AimPivot sits on the idle frame's shoulder")
	var gun: CanvasItem = hero.get_node("AimPivot/Scrapjack")
	var arm: CanvasItem = hero.get_node("AimPivot/Arm")
	check(arm != null and arm.visible and gun.visible, "arm and pistol are shown while alive")

	# Running cycles through the run frames, and the pivot follows each one.
	press(&"move_right")
	var seen := {}
	var attached := true
	for i in 60:
		await physics_frames(1)
		seen[visual.current_frame()] = true
		if hero.aim_pivot.position.distance_to(visual.shoulder_offset()) > 0.5:
			attached = false
	release(&"move_right")
	var run_frames := 0
	for k in seen:
		if String(k).begins_with("run_"):
			run_frames += 1
	check(run_frames >= 4, "running shows several run frames (saw %s)" % str(seen.keys()))
	check(attached, "AimPivot stays on every running frame's shoulder")

	# Jumping: rising frame on the way up.
	await seconds(0.4)
	press(&"jump")
	await physics_frames(6)
	check_eq(visual.current_frame(), &"jump_rise", "rising shows jump_rise")
	release(&"jump")
	await seconds(0.9)
	check(visual.current_frame() != &"jump_rise", "back down it no longer shows jump_rise")

	# Hurt, then defeated: arm and gun hide when down.
	await seconds(1.2)
	hero.take_damage(1, hero.global_position + Vector2(40, 0))
	await physics_frames(2)
	check_eq(visual.current_frame(), &"hurt", "taking a hit shows the hurt frame")
	await seconds(1.2)
	Session.apply_damage(Session.get_health())
	await physics_frames(3)
	check_eq(visual.current_frame(), &"defeated", "zero health shows the defeated frame")
	check(not arm.visible and not gun.visible, "arm and pistol are hidden when defeated")

	# Facing left mirrors the body and the shoulder.
	var body: Sprite2D = visual.get_node("Body")
	visual.update_pose(-1, false, true, 0.0, 0.0, false, false, false, 0.0, 0.0, 0.0)
	check(body.flip_h, "facing left flips the body sprite")
	check(visual.shoulder_offset().x == -Frames.SHOULDER[visual.current_frame()].x,
			"facing left mirrors the shoulder pivot")


## Playtest 2026-09-28 ("running fast looks blurry" on a 120 Hz display):
## physics-moved objects are drawn interpolated between 60 Hz ticks, and the
## camera follows on physics ticks so it is smoothed the same way.
func _test_smoothing_settings() -> void:
	check(ProjectSettings.get_setting("physics/common/physics_interpolation") == true,
			"physics interpolation is enabled")
	var cam: Camera2D = load("res://scenes/actors/game_camera.tscn").instantiate()
	add_child(cam)
	check_eq(cam.process_callback, Camera2D.CAMERA2D_PROCESS_PHYSICS, "camera follows on physics ticks")
	cam.queue_free()


## Playtest 2026-09-28 ("body facing forward but hand backwards"): the body
## faces the aim side, so the gun arm always points in front of the body;
## moving away from the aim backpedals with the run cycle reversed.
func _test_faces_aim_and_backpedals() -> void:
	Session.new_run()
	var hero := _make_level()
	hero.position = Vector2(600, -1)
	hero.use_aim_override = true
	await physics_frames(2)
	var visual = hero.visual
	# Aim behind (left) while running right.
	press(&"move_right")
	var ok_facing := true
	var ok_arm := true
	var order: Array[int] = []
	for i in 50:
		hero.aim_override = hero.global_position + Vector2(-300, -60)
		await physics_frames(1)
		if hero.facing != -1:
			ok_facing = false
		if signf(cos(hero.aim_pivot.rotation)) != float(hero.facing):
			ok_arm = false
		var f := String(visual.current_frame())
		if f.begins_with("run_"):
			var n := int(f.substr(4))
			if order.is_empty() or order[-1] != n:
				order.append(n)
	release(&"move_right")
	check(ok_facing, "aiming behind a hero running right turns the body to face the aim")
	check(ok_arm, "the gun arm always points to the side the body faces")
	# Backpedalling: consecutive run frames step downward (6 -> 5 -> ...).
	var down := 0
	var up := 0
	for i in range(1, order.size()):
		var step := (order[i] - order[i - 1] + 6) % 6
		if step == 5:
			down += 1
		elif step == 1:
			up += 1
	check(down > up and down >= 3, "backpedalling plays the run frames in reverse (sequence %s)" % str(order))


## The frame's normal map, or null when that file is not there (yet).
func _normal_for(frame: StringName) -> Texture2D:
	var path := "%srook_%s_n.png" % [NORMAL_DIR, frame]
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


## Body and Arm are lit through the shared shader on light masks 1 | 2, and the
## normal map follows the frame that is showing (set when the frame changes).
func _test_lit_with_normal_maps() -> void:
	Session.new_run()
	var hero := _make_level()
	hero.position = Vector2(200, -1)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(400, -60)
	await seconds(0.3)
	var visual = hero.visual
	var body: Sprite2D = visual.get_node("Body")
	var arm: Sprite2D = hero.get_node("AimPivot/Arm")
	for sprite in [body, arm]:
		var mat := sprite.material as ShaderMaterial
		check(mat != null and mat.shader != null and mat.shader.resource_path == LIT_SHADER_PATH,
				"%s uses the lit-part shader" % sprite.name)
		check_eq(sprite.light_mask, 3, "%s is on light masks 1 | 2 (world lights and the moon rim)" % sprite.name)
		var ambient: Vector3 = mat.get_shader_parameter("ambient")
		check(ambient.x > 0.35 and ambient.x < 0.55, "%s has the characters' night ambient (about 0.45)" % sprite.name)
		check(float(mat.get_shader_parameter("wrap")) > 0.0, "%s wraps its light a little" % sprite.name)
		check(mat.get_shader_parameter("spec_atlas") != null, "%s always has a spec map (never a bare sampler)" % sprite.name)
	check(body.material != arm.material, "the body and the arm have their own materials (their own normal maps)")

	# The Body's normal map follows the frame, standing and running.
	var body_mat := body.material as ShaderMaterial
	var arm_mat := arm.material as ShaderMaterial
	var seen := {}
	var in_sync := true
	press(&"move_right")
	for i in 40:
		await physics_frames(1)
		var frame: StringName = visual.current_frame()
		var expected := _normal_for(frame)
		seen[frame] = true
		var got: Texture2D = body_mat.get_shader_parameter("normal_atlas")
		var on: float = body_mat.get_shader_parameter("normals_on")
		if got != expected or on != (1.0 if expected != null else 0.0):
			in_sync = false
	release(&"move_right")
	check(seen.size() >= 3, "the check saw several frames (%s)" % str(seen.keys()))
	check(in_sync, "the body's normal map (or flat fallback) matches the frame showing, every tick")
	var arm_expected := _normal_for(&"arm")
	check_eq(arm_mat.get_shader_parameter("normal_atlas"), arm_expected, "the arm carries the arm normal map (null: flat, none made yet)")
	check_eq(float(arm_mat.get_shader_parameter("normals_on")), 1.0 if arm_expected != null else 0.0, "the arm falls back to flat normals only when it has none")

	# A texture with no normal map gets flat normals, not an empty sampler.
	visual._apply_normal(body_mat, "rook_no_such_frame")
	check(body_mat.get_shader_parameter("normal_atlas") == null and float(body_mat.get_shader_parameter("normals_on")) == 0.0,
			"a missing normal map falls back to flat normals")
	# The A/B switch: flat normals on request, normal maps back on.
	visual.set_normals_enabled(false)
	check(float(body_mat.get_shader_parameter("normals_on")) == 0.0 and float(arm_mat.get_shader_parameter("normals_on")) == 0.0,
			"normals can be switched off for an A/B look")
	visual.set_normals_enabled(true)
	var frame_now: StringName = visual.current_frame()
	check_eq(float(body_mat.get_shader_parameter("normals_on")), 1.0 if _normal_for(frame_now) != null else 0.0,
			"and back on (where a normal map exists)")

	# The small wrist light shares the world lights' smooth falloff and has a height.
	var wrist: PointLight2D = hero.get_node("AimPivot/WristLight")
	check_eq(wrist.texture, SceneryDraw.smooth_disc_texture(), "the wrist light uses the shared smooth disc")
	check(wrist.height > 0.0, "the wrist light has a height for the normal-mapped body")
	hero.queue_free()
	await physics_frames(2)
