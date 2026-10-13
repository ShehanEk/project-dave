extends TestCase
## C37, the Scrapjack's shooting look and feel: an ivory tracer (never a
## tell or pickup color), one muzzle glow held through rapid fire, a camera
## kick against the aim on each shot, a short shake on a kill, a brief
## hit-pause on a hit (none under Reduced Motion), and impacts whose HIT and
## BLOCKED bursts differ by shape.

const BlockScript := preload("res://scripts/world/block.gd")


func run() -> void:
	_test_tracer_colors()
	await _test_rapid_fire_holds_one_glow()
	await _test_camera_kick_and_kill_shake()
	await _test_hit_pause()
	await _test_impact_shapes()
	await _test_painted_gun()


func _hero_with_camera() -> Array:
	Session.new_run()
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(0, 0)
	floor_b.size = Vector2(3000, 200)
	add_child(floor_b)
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = Vector2(400, -1)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(500, -40)
	var cam: GameCamera = load("res://scenes/actors/game_camera.tscn").instantiate()
	cam.target = hero
	add_child(cam)
	await physics_frames(3)
	return [hero, cam, floor_b]


func _test_tracer_colors() -> void:
	check(ScrapBolt.TRACER.is_equal_approx(Color("#F2EBD3")), "the shot is tracer ivory (#F2EBD3)")
	for c in [ScrapBolt.TRACER, ScrapBolt.CORE, ScrapBolt.HIT_COLOR, ScrapBolt.BLOCK_COLOR, Scrapjack.FLASH_IVORY]:
		check(c.s < 0.2 and c.v > 0.75, "shot and impact colors are near-white, never amber, gold or green (%s)" % c.to_html(false))


func _test_rapid_fire_holds_one_glow() -> void:
	var made := await _hero_with_camera()
	var hero: Hero = made[0]
	var gun: Scrapjack = hero.get_node("AimPivot/Scrapjack")
	press(&"fire")
	var lowest := INF
	var count := [0]
	gun.fired.connect(func(): count[0] += 1)
	for i in 72:
		await physics_frames(1)
		if count[0] >= 1 and gun._muzzle_light != null:
			lowest = minf(lowest, gun._muzzle_light.energy)
	release(&"fire")
	check(count[0] >= 4, "setup: holding fire shoots repeatedly (%d shots)" % count[0])
	check(lowest >= Scrapjack.HOLD_ENERGY - 0.01, "rapid fire holds one glow, never dropping dark between shots (lowest %.2f)" % lowest)
	await seconds(0.3)
	check(gun._muzzle_light.energy < 0.01, "the glow fades once the trigger is let go")
	for n in made:
		n.queue_free()
	await physics_frames(2)


func _test_camera_kick_and_kill_shake() -> void:
	var made := await _hero_with_camera()
	var hero: Hero = made[0]
	var cam: GameCamera = made[1]
	var gun: Scrapjack = hero.get_node("AimPivot/Scrapjack")
	var aim: Vector2 = (hero.aim_override - gun.global_position).normalized()
	gun._try_fire()
	await physics_frames(1)
	check(cam.offset.length() > 0.5, "a shot kicks the camera (offset %s)" % str(cam.offset))
	check(cam.offset.dot(aim) < 0.0, "the kick is against the aim")
	await seconds(0.5)
	check(cam.offset.length() < 0.1, "the kick springs back")
	GameFeel.kill(hero)
	check(cam._shake >= GameFeel.KILL_SHAKE - 0.01, "a kill shakes the camera")
	await physics_frames(2)
	var shaken := cam.offset.length() > 0.2
	await seconds(1.0)
	check(shaken and cam.offset.length() < 0.1, "the shake is short")
	Settings.set_reduced_motion(true)
	gun._cooldown = 0.0
	gun._try_fire()
	await physics_frames(1)
	var soft := cam.offset.length()
	Settings.set_reduced_motion(false)
	check(soft > 0.0 and soft < GameFeel.SHOT_KICK * 0.6, "Reduced Motion halves the kick (%.2f)" % soft)
	for n in made:
		n.queue_free()
	await physics_frames(2)


func _test_hit_pause() -> void:
	GameFeel.hit_pause_enabled = true
	var before := Engine.time_scale
	GameFeel.hit_pause()
	check(Engine.time_scale < 0.1 * before, "a hit nearly stops game time (scale %.2f)" % Engine.time_scale)
	for i in 10:
		await get_tree().process_frame
	check(is_equal_approx(Engine.time_scale, before), "and time runs again a moment later (scale %.2f)" % Engine.time_scale)
	Settings.set_reduced_motion(true)
	GameFeel.hit_pause()
	check(is_equal_approx(Engine.time_scale, before), "Reduced Motion drops the hit-pause")
	Settings.set_reduced_motion(false)
	GameFeel.hit_pause_enabled = false


func _test_impact_shapes() -> void:
	var dir := Vector2.RIGHT
	var blocked := ImpactSpark.new()
	blocked.shape = ImpactSpark.Shape.BLOCKED
	blocked.dir = dir
	blocked.global_position = Vector2(300, 200)
	add_child(blocked)
	var hit := ImpactSpark.new()
	hit.shape = ImpactSpark.Shape.HIT
	hit.dir = dir
	hit.global_position = Vector2(500, 200)
	add_child(hit)
	var back := blocked._sparks.all(func(s): return (s[1] as Vector2).dot(dir) < 0.0)
	check(back, "a blocked shot's sparks glance back toward the shooter")
	var fwd := hit._sparks.any(func(s): return (s[1] as Vector2).dot(dir) > 0.0)
	var bwd := hit._sparks.any(func(s): return (s[1] as Vector2).dot(dir) < 0.0)
	check(fwd and bwd, "a hit's sparks burst every way")
	check(not blocked._chips.is_empty() and not hit._chips.is_empty(), "both throw scrap chips")
	await seconds(0.6)
	check(not is_instance_valid(blocked) and not is_instance_valid(hit), "impacts free themselves within about half a second")


## The painted Scrapjack (the user's parts sheet as a lit rig): it builds on
## the hero, the muzzle sits at the barrel's tip, a shot heats the copper
## coils and they cool again, and the upper housing and the barrel slide
## back together, so no gap opens between them.
func _test_painted_gun() -> void:
	var made := await _hero_with_camera()
	var hero: Hero = made[0]
	var gun: Scrapjack = hero.get_node("AimPivot/Scrapjack")
	check(gun.rig != null, "the Scrapjack wears its painted rig")
	if gun.rig == null:
		for n in made:
			n.queue_free()
		return
	for part in ["frame", "upper", "barrel", "battery"]:
		check(gun.rig.joints.has(part), "the gun rig has its %s" % part)
	var barrel: Node2D = gun.rig.joints["barrel"]
	var muzzle_x: float = gun.to_local(gun.get_muzzle_global_position()).x
	var barrel_x: float = gun.to_local(barrel.global_position).x
	check(muzzle_x > barrel_x + 4.0, "the muzzle sits at the front of the barrel")
	var mat: ShaderMaterial = gun.rig.joint_material("barrel")
	var idle: float = mat.get_shader_parameter("emissive_energy")
	gun._try_fire()
	await physics_frames(1)
	var hot: float = mat.get_shader_parameter("emissive_energy")
	var gap0: float = gun.rig.joints["barrel"].position.x - gun.rig.joints["upper"].position.x
	var slid: float = gun.rig.joints["upper"].position.x - gun._slide_rest["upper"].x
	check(hot > idle + 0.5, "a shot heats the coils (glow %.2f -> %.2f)" % [idle, hot])
	check(slid < -0.3, "the upper housing snaps back on a shot (%.2f px)" % slid)
	var rest_gap: float = gun._slide_rest["barrel"].x - gun._slide_rest["upper"].x
	check(absf(gap0 - rest_gap) < 0.01, "the barrel slides with the housing, so no gap opens")
	await seconds(0.5)
	check(absf(mat.get_shader_parameter("emissive_energy") - idle) < 0.05, "and the coils cool again")
	for n in made:
		n.queue_free()
	await physics_frames(2)
