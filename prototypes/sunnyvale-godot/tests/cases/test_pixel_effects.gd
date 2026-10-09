extends TestCase
## Sheet 9, the pixel-art effects: the user's six animation strips
## (assets/effects/pixel/, cut by tools/art/import_pixel_effects.py) replace
## the smooth muzzle flash, impact sparks, landing dust, machine break-up,
## checkpoint sparkle and chip glint.
##  1. The strips load, with their frame counts and sizes, one shared palette
##     and the black keyed out (clear, with no dark fringe).
##  2. PixelFx plays a strip once, frame by frame, and frees itself.
##  3. It flips and crops (a mirrored effect, the glancing half of an impact).
##  4. Reduced Motion plays fewer frames and dims the additive ones.
##  5. The old call sites keep their contract: one puff node per spawn, a cap,
##     the chained machine break-up, a cluster's three glints.
##  6. A shot's flash sits at the muzzle and turns and flips with the aim.
##  7. Impacts keep their two shapes and free themselves.
##  8. A missing strip keeps the old smooth effect (has_fx false).

const PixelFx := preload("res://scripts/effects/pixel_fx.gd")
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")
const BlockScript := preload("res://scripts/world/block.gd")

const FRAMES := {
	"muzzle_flash": 4, "bullet_impact": 5, "landing_dust": 5,
	"machine_break": 6, "checkpoint_sparkle": 6, "chip_glint": 4,
}
const ADDITIVE := ["muzzle_flash", "bullet_impact", "checkpoint_sparkle", "chip_glint"]


func run() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)
	_test_strips()
	await _test_plays_once_and_frees()
	await _test_flip_and_half()
	await _test_reduced_motion()
	await _test_puff_contract()
	await _test_muzzle_flash_follows_aim()
	await _test_impact_shapes()
	await _test_missing_strip_falls_back()
	Settings.set_reduced_motion(base_reduced)


func _make_host() -> Node2D:
	var host := Node2D.new()
	add_child(host)
	return host


func _fx_children(host: Node) -> Array:
	return host.get_children().filter(func(c): return c.get_script() == PixelFx)


# --- 1. the strips ----------------------------------------------------------

func _test_strips() -> void:
	var colors := {}
	for fx_name in FRAMES:
		check(PixelFx.has_fx(fx_name), "%s: its strip, frame data and settings exist" % fx_name)
		check_eq(PixelFx.frame_count(fx_name), FRAMES[fx_name], "%s: frame count" % fx_name)
		var tex: Texture2D = PixelFx.strip_texture(fx_name)
		var meta: Dictionary = PixelFx._load_meta()[fx_name]
		var size := Vector2i(int(meta["frame_size"][0]), int(meta["frame_size"][1]))
		check_eq(Vector2i(tex.get_width(), tex.get_height()), Vector2i(size.x * FRAMES[fx_name], size.y),
				"%s: the strip is its frames side by side" % fx_name)
		var img := tex.get_image()
		var clear := 0
		var dark := 0
		for y in img.get_height():
			for x in img.get_width():
				var c := img.get_pixel(x, y)
				if c.a < 0.5:
					clear += 1
				else:
					colors[c.to_html(false)] = true
					if maxf(c.r, maxf(c.g, c.b)) < 0.04:
						dark += 1
		check(clear > img.get_width() * img.get_height() / 2, "%s: the black is keyed out (clear: %d px)" % [fx_name, clear])
		check_eq(dark, 0, "%s: no opaque pixel is black (no fringe)" % fx_name)
		check(PixelFx.FX[fx_name]["add"] == ADDITIVE.has(fx_name), "%s: additive for bright sparks and flashes, plain alpha for dust and smoke" % fx_name)
	check(colors.size() <= 48, "one shared palette over every strip (%d colours)" % colors.size())
	# The dark smoke is kept (keyed by colour, not by luminance).
	var smoke := 0
	var img2: Image = PixelFx.strip_texture("machine_break").get_image()
	for y in img2.get_height():
		for x in img2.get_width():
			var c2 := img2.get_pixel(x, y)
			if c2.a > 0.5 and c2.get_luminance() < 0.25 and c2.b > c2.r:
				smoke += 1
	check(smoke > 40, "the machine break-up keeps its dark smoke puffs as opaque pixels (%d)" % smoke)
	check(not PixelFx.has_fx("no_such_effect"), "an unknown effect is not available")
	check(PixelFx.spawn("no_such_effect", Vector2.ZERO, self) == null, "and spawns nothing")


# --- 2. one shot ------------------------------------------------------------

func _test_plays_once_and_frees() -> void:
	var host := _make_host()
	var fx: Sprite2D = PixelFx.spawn("bullet_impact", Vector2(120.0, 80.0), host)
	check(fx != null and fx.get_script() == PixelFx, "spawn returns the one-shot node")
	check_eq(host.get_child_count(), 1, "exactly one node is added")
	check(fx.global_position.is_equal_approx(Vector2(120.0, 80.0)), "it sits on the spawn point")
	check_eq(fx.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "drawn crisp, pixel for pixel")
	check(fx.region_enabled and not fx.centered, "a frame of the strip, its anchor on the origin")
	check_eq(fx.current_frame(), 0, "it starts on the first frame")
	var seen := {}
	var end: float = PixelFx.duration("bullet_impact")
	check(absf(fx.total_time() - end) < 0.001, "its play time is its frame count times the frame time")
	var t := 0.0
	while is_instance_valid(fx) and t < end + 0.5:
		seen[fx.current_frame()] = true
		await physics_frames(1)
		t += 1.0 / Engine.physics_ticks_per_second
	check_eq(seen.size(), 5, "every frame of the strip showed in turn")
	check(not is_instance_valid(fx), "it frees itself after the last frame")
	check(t < end + 0.2, "and about on time (%.2f s for %.2f s)" % [t, end])
	check_eq(host.get_child_count(), 0, "nothing is left behind")
	# A delayed layer waits invisible, then plays.
	var late: Sprite2D = PixelFx.spawn("chip_glint", Vector2.ZERO, host, {"delay": 0.2})
	check(not late.visible, "a delayed effect is hidden until its time")
	await seconds(0.3)
	check(is_instance_valid(late) and late.visible, "and shows once the delay has passed")
	await seconds(0.4)
	check(not is_instance_valid(late), "then frees itself too")
	# A frame list plays only those frames.
	var part: Sprite2D = PixelFx.spawn("machine_break", Vector2.ZERO, host, {"frames": [3, 4, 5]})
	check_eq(part.current_frame(), 3, "a frame list starts on its first frame")
	check(absf(part.total_time() - 3.0 * float(PixelFx.FX["machine_break"]["frame_time"])) < 0.001, "and lasts as long as its frames")
	part.queue_free()
	host.queue_free()
	await physics_frames(2)


# --- 3. flipping and cropping -----------------------------------------------

func _test_flip_and_half() -> void:
	var host := _make_host()
	var right: Sprite2D = PixelFx.spawn("muzzle_flash", Vector2.ZERO, host)
	var left: Sprite2D = PixelFx.spawn("muzzle_flash", Vector2.ZERO, host, {"flip": true})
	check(not right.flip_h and left.flip_h, "the flip option mirrors the effect")
	check(right.get_rect().position.x > -0.01, "the muzzle flash points right, growing out of its anchor")
	check(left.get_rect().end.x < 0.01, "mirrored, it points left from the same anchor")
	check(is_equal_approx(right.get_rect().size.x, left.get_rect().size.x), "both are the same size")
	right.queue_free()
	left.queue_free()
	# A burst cropped to one half keeps only that side of its anchor.
	var full: Sprite2D = PixelFx.spawn("bullet_impact", Vector2.ZERO, host)
	var back: Sprite2D = PixelFx.spawn("bullet_impact", Vector2.ZERO, host, {"half": Vector2i(-1, 0)})
	var up: Sprite2D = PixelFx.spawn("bullet_impact", Vector2.ZERO, host, {"half": Vector2i(0, -1)})
	check(full.get_rect().position.x < -1.0 and full.get_rect().end.x > 1.0, "a burst spreads both ways")
	check(back.get_rect().end.x < 0.01 and back.get_rect().size.x > 1.0, "its back half is only the left of the anchor")
	check(up.get_rect().end.y < 0.01 and up.get_rect().size.x > full.get_rect().size.x - 0.01, "and its upper half only above it")
	host.queue_free()
	await physics_frames(2)


# --- 4. reduced motion ------------------------------------------------------

func _test_reduced_motion() -> void:
	var host := _make_host()
	Settings.set_reduced_motion(false)
	var normal: Sprite2D = PixelFx.spawn("checkpoint_sparkle", Vector2.ZERO, host)
	var normal_glow: Sprite2D = PixelFx.spawn("muzzle_flash", Vector2.ZERO, host)
	Settings.set_reduced_motion(true)
	var calm: Sprite2D = PixelFx.spawn("checkpoint_sparkle", Vector2.ZERO, host)
	var calm_glow: Sprite2D = PixelFx.spawn("muzzle_flash", Vector2.ZERO, host)
	check(calm.total_time() < normal.total_time(), "Reduced Motion plays fewer frames, a shorter play (%.2f vs %.2f s)" % [calm.total_time(), normal.total_time()])
	check(calm.total_time() > 0.0 and calm.visible, "but never hides the cue")
	check(calm_glow.modulate.a < normal_glow.modulate.a, "and dims an additive flash")
	check(PixelFx.frames_for("machine_break", [0, 1, 2], true).size() < 3, "a split strip is thinned too")
	check(not PixelFx.frames_for("machine_break", [3, 4, 5], true).is_empty(), "and each part keeps a frame")
	for n in PixelFx.FX:
		check(not PixelFx.frames_for(n, [], true).is_empty(), "%s keeps frames under Reduced Motion" % n)
	Settings.set_reduced_motion(false)
	await seconds(0.8)
	check(not is_instance_valid(calm) and not is_instance_valid(normal), "both free themselves")
	host.queue_free()
	await physics_frames(2)


# --- 5. the old call sites ---------------------------------------------------

func _test_puff_contract() -> void:
	var host := _make_host()
	for kind in KenneyPuff.PIXEL:
		KenneyPuff.spawn(kind, Vector2(50.0, 60.0), host)
	check_eq(host.get_child_count(), KenneyPuff.PIXEL.size(), "one puff node per spawn, as before")
	for puff in host.get_children():
		var layers: Array = KenneyPuff.PIXEL[puff.effect_kind]
		check_eq(_fx_children(puff).size(), layers.size(), "%s plays its %d pixel layer(s)" % [puff.effect_kind, layers.size()])
		check(not (puff.get_node("Particles") as CPUParticles2D).emitting, "%s: the smooth particles stay silent" % puff.effect_kind)
	# a cluster glints in three places, one after the other
	var cluster: Node = host.get_children().filter(func(c): return c.effect_kind == &"chip_sparkle_cluster")[0]
	var spots := {}
	for f in _fx_children(cluster):
		spots[f.position] = true
	check_eq(spots.size(), 3, "a chip cluster glints in three different places")
	# the machine break-up: sparks first, then the smoke, no gap and no overlap
	var spark: Node = _fx_children(host.get_children().filter(func(c): return c.effect_kind == &"machine_spark")[0])[0]
	var smoke: Node = _fx_children(host.get_children().filter(func(c): return c.effect_kind == &"machine_smoke")[0])[0]
	check(spark.visible and not smoke.visible, "the sparks play first, the smoke waits")
	check(absf(smoke._delay - spark.total_time()) < 0.001, "and the smoke starts as the sparks end")
	# each puff frees itself within its old lifetime
	await seconds(1.0)
	check_eq(host.get_child_count(), 0, "every puff freed itself, none left behind")
	# the cap still holds
	for i in 8:
		KenneyPuff.spawn(&"armor_spark", Vector2(i * 10.0, 0.0), host)
	check(host.get_child_count() <= 3, "armor_spark stays capped at 3 live (%d)" % host.get_child_count())
	await seconds(0.8)
	check_eq(host.get_child_count(), 0, "and they free themselves")
	host.queue_free()
	await physics_frames(2)


# --- 6. the muzzle flash -----------------------------------------------------

func _test_muzzle_flash_follows_aim() -> void:
	Session.new_run()
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(0, 0)
	floor_b.size = Vector2(3000, 200)
	add_child(floor_b)
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = Vector2(800, -1)
	hero.use_aim_override = true
	var gun: Scrapjack = hero.get_node("AimPivot/Scrapjack")
	for dir in [Vector2(1.0, -0.15), Vector2(-1.0, -0.15)]:
		hero.aim_override = hero.global_position + dir * 400.0
		await physics_frames(3)
		var before := gun._muzzle.get_children().filter(func(c): return c.get_script() == PixelFx).size()
		gun._try_fire()
		var flashes: Array = gun._muzzle.get_children().filter(func(c): return c.get_script() == PixelFx)
		check_eq(flashes.size(), before + 1, "a shot plays one muzzle flash at the muzzle (aiming %s)" % str(dir))
		var fx: Sprite2D = flashes[-1]
		var rect_centre: Vector2 = fx.to_global(fx.get_rect().get_center())
		var along: float = (rect_centre - gun._muzzle.global_position).dot(dir.normalized())
		check(along > 4.0, "the flash lies ahead of the muzzle along the shot (%.1f px)" % along)
		var xs: Vector2 = fx.global_transform.x.normalized()
		check(xs.dot(dir.normalized()) > 0.97, "and points the way the gun does")
		# upright when aiming left: the flash's up stays up
		check(fx.global_transform.y.normalized().y < 0.0 or absf(dir.y) < 0.5 and fx.global_transform.y.normalized().y > -1.0, "it is not turned upside down")
		check(absf(fx.global_transform.get_scale().x - PixelFx.FX["muzzle_flash"]["px"]) < 0.01,
				"it keeps its size in the world (%.2f world px per art px)" % fx.global_transform.get_scale().x)
		await seconds(0.3)
		check(not is_instance_valid(fx), "it frees itself")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 7. impacts --------------------------------------------------------------

func _test_impact_shapes() -> void:
	var dir := Vector2.RIGHT
	var hit := ImpactSpark.new()
	hit.shape = ImpactSpark.Shape.HIT
	hit.dir = dir
	hit.global_position = Vector2(500, 200)
	add_child(hit)
	var blocked := ImpactSpark.new()
	blocked.shape = ImpactSpark.Shape.BLOCKED
	blocked.dir = dir
	blocked.color = ScrapBolt.BLOCK_COLOR
	blocked.global_position = Vector2(300, 200)
	add_child(blocked)
	check(hit._pixel != null and blocked._pixel != null, "both impacts play the pixel burst")
	var hit_rect: Rect2 = hit._pixel.get_rect()
	var blocked_rect: Rect2 = blocked._pixel.get_rect()
	check(hit_rect.position.x < -1.0 and hit_rect.end.x > 1.0, "a hit is the whole radial burst")
	check(blocked_rect.end.x < 0.01, "a blocked shot is only the half that glances back toward the shooter")
	check(blocked._pixel.modulate.is_equal_approx(Color(ScrapBolt.BLOCK_COLOR, 1.0)), "it is tinted by the impact's colour")
	check(not hit._sparks.is_empty() and not blocked._chips.is_empty(), "the spark data is still worked out")
	await seconds(0.6)
	check(not is_instance_valid(hit) and not is_instance_valid(blocked), "impacts free themselves within about half a second")


# --- 8. a missing strip ------------------------------------------------------

func _test_missing_strip_falls_back() -> void:
	for n in ["bullet_impact", "landing_dust", "chip_glint", "machine_break", "muzzle_flash"]:
		PixelFx._textures[n] = null   # as if the PNG were not there
	check(not PixelFx.has_fx("bullet_impact"), "a missing strip is not available")
	var host := _make_host()
	check(PixelFx.spawn("bullet_impact", Vector2.ZERO, host) == null, "and spawns nothing")
	KenneyPuff.spawn(&"landing_dust", Vector2.ZERO, host)
	var puff: Node = host.get_child(0)
	check(_fx_children(puff).is_empty(), "the puff plays no pixel layer")
	check((puff.get_node("Particles") as CPUParticles2D).emitting, "and the smooth particles do it, as before")
	# a kind with two layers, one of them missing, falls back whole
	KenneyPuff.spawn(&"machine_spark", Vector2.ZERO, host)
	check((host.get_child(1).get_node("Particles") as CPUParticles2D).emitting, "a split effect falls back whole")
	var spark := ImpactSpark.new()
	spark.global_position = Vector2(100, 100)
	add_child(spark)
	check(spark._pixel == null, "an impact draws its old sparks")
	check(spark.life > 0.4, "with its old life (%.2f s)" % spark.life)
	await seconds(0.8)
	check(not is_instance_valid(spark), "and frees itself")
	check_eq(host.get_child_count(), 0, "the puffs free themselves too")
	for n in ["bullet_impact", "landing_dust", "chip_glint", "machine_break", "muzzle_flash"]:
		PixelFx._textures.erase(n)
	check(PixelFx.has_fx("bullet_impact"), "the strips load again once they are there")
	host.queue_free()
	await physics_frames(2)
