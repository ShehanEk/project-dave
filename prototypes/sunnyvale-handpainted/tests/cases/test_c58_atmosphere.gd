extends TestCase
## C58 (corporate cyberpunk): rain and the neon glow, `scripts/world/atmosphere.gd`.
## The level instances it next to the night overlay. Two rain layers (a far one
## in the world just in front of the campus backdrop, a near one on its own
## CanvasLayer above the foreground row), splashes where the rain meets the top
## of a solid, and an additive glow pass drawn last on that layer, below the
## night overlay and the HUD. No rain inside an `indoors` area (the depot), and
## Reduced motion turns the rain and splashes off while the glow stays.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const Atmos := preload("res://scripts/world/atmosphere.gd")
const FG := preload("res://scripts/world/visuals/foreground_layer.gd")
const NightOverlay := preload("res://scripts/world/night_overlay.gd")
const DEPOT_ID := "L01-A05"


func run() -> void:
	_layers()
	await _in_level()


func _layers() -> void:
	check(FG.LAYER < Atmos.LAYER and Atmos.LAYER < NightOverlay.LAYER and NightOverlay.LAYER < 15,
			"the rain and glow layer sits above the foreground row, below the night overlay and the HUD")
	check(Atmos.FAR_Z > -60 and Atmos.FAR_Z < -10,
			"the far rain is in front of the campus backdrop (-60) and behind the scenery (-10)")
	check(Atmos.PARALLAX_FAR < 1.0 and Atmos.PARALLAX_NEAR > 1.0,
			"the far rain slides slower than the camera, the near rain faster")
	check(Atmos.NEAR_RAIN.alpha <= 0.3 and Atmos.FAR_RAIN.alpha <= 0.3,
			"both rain layers stay faint enough not to hide the play")


func _in_level() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)
	var lvl: Node = await spawn(LEVEL_01)
	var a: Node = lvl.get_node_or_null("Atmosphere")
	check(a != null, "the level instances the atmosphere")
	if a == null:
		Settings.set_reduced_motion(base_reduced)
		lvl.queue_free()
		return

	check_eq(a.screen.layer, Atmos.LAYER, "the screen layer is on its layer")
	check(a.glow.get_index() > a.near_rain.get_index(), "the glow is drawn after the near rain")
	var glow_code: String = (a.glow.material as ShaderMaterial).shader.code
	check(glow_code.contains("blend_add"), "the glow adds light, never darkens")
	check(glow_code.contains("178.0") and glow_code.contains("38.0"),
			"the glow keys teal-cyan and warm amber (the C58 scenery neon)")
	for r in [a.near_rain, a.glow, a.far_rain]:
		check_eq((r as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE, "%s never takes the mouse" % r.name)

	# Indoors: only the depot, and the rain shaders know its span.
	var depot: AreaRoot = null
	for ar in lvl.areas:
		if ar.area_id == DEPOT_ID:
			depot = ar
		else:
			check(not ar.indoors, "%s is outdoors" % ar.area_id)
	check(depot != null and depot.indoors, "the depot is indoors")
	if depot != null:
		var mid := depot.global_position.x + depot.width * 0.5
		check(not a.is_wet(mid), "no rain falls in the depot")
		check(a.is_wet(lvl.areas[0].global_position.x + 400.0), "rain falls at the gate")
		for m in [a._far_mat, a._near_mat]:
			var span: Vector4 = m.get_shader_parameter("dry_a")
			check(is_equal_approx(span.x, depot.global_position.x)
					and is_equal_approx(span.y, depot.global_position.x + depot.width),
					"each rain layer is told the depot's span (%s)" % str(span))

	# Splashes land on the top of a solid.
	await seconds(1.0)
	check(a._splash.size() > 0, "rain splashes on the ground (%d live)" % a._splash.size())
	var space: PhysicsDirectSpaceState2D = a.get_world_2d().direct_space_state
	var on_top := 0
	for s in a._splash:
		var below := PhysicsPointQueryParameters2D.new()
		below.position = Vector2(s[0], s[1] + 2.0)
		below.collision_mask = Atmos.WORLD_MASK
		var above := PhysicsPointQueryParameters2D.new()
		above.position = Vector2(s[0], s[1] - 2.0)
		above.collision_mask = Atmos.WORLD_MASK
		if not space.intersect_point(below).is_empty() and space.intersect_point(above).is_empty():
			on_top += 1
	check(on_top == a._splash.size(), "every splash sits on a solid's top (%d of %d)" % [on_top, a._splash.size()])

	# Reduced motion: no rain, no splashes; the glow stays.
	Settings.set_reduced_motion(true)
	await physics_frames(2)
	check_eq(float(a._far_mat.get_shader_parameter("amount")), 0.0, "reduced motion stops the far rain")
	check_eq(float(a._near_mat.get_shader_parameter("amount")), 0.0, "and the near rain")
	await seconds(0.5)
	check(a._splash.is_empty(), "and no splashes appear")
	check(a.glow.visible, "the glow stays (it does not move)")
	Settings.set_reduced_motion(false)
	await physics_frames(2)
	check_eq(float(a._far_mat.get_shader_parameter("amount")), 1.0, "the rain comes back when it is switched off")

	Settings.set_reduced_motion(base_reduced)
	lvl.queue_free()
	await physics_frames(2)
