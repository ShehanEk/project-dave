extends TestCase
## Pixel-art characters (2026-10-06). The Night Guard is the first character
## drawn as pixel art: its rig.json says so (`pixel_art`), its textures are
## art pixels enlarged 3x with nearest filtering (crisp), the neon trim is
## the exact emissive colour, it stands about 102 world px, its joints and
## pelvis sit on whole art pixels (1.5 world px), and its parts are posed in
## small rotation steps. The Staffer is the second (test_pixel_staffer.gd) and
## the Patrol Rover the third (test_pixel_rover.gd). The Scrapjack, Dave's
## gun, became pixel art on 2026-10-07 (test_pixel_scrapjack.gd); nothing
## drawn as a cutout rig is smooth any more (Dave's own frames are).

const GUARD := "res://assets/characters/lit/night_guard/"
const NEON := Color8(0xC6, 0xFF, 0x3D)
const RigScript := preload("res://scripts/actors/lit/cutout_rig.gd")


func _rig_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


func _build(rig_path: String) -> Node2D:
	var rig: Node2D = RigScript.new()
	rig.rig_path = rig_path
	add_child(rig)
	return rig


func run() -> void:
	var data := _rig_json(GUARD + "rig.json")
	check_eq(data.get("pixel_art", false), true, "the Night Guard's rig.json is flagged pixel_art")
	check_eq(float(data.get("pixel_world", 0.0)), 1.5, "one art pixel is 1.5 world px")
	check_eq(float(data["texture_scale"]), 2.0, "texture_scale 2: three atlas texels per art pixel")
	var up := int(round(float(data["texture_scale"]) * float(data["pixel_world"])))

	var albedo: Image = (load(GUARD + "albedo.png") as Texture2D).get_image()
	var normal: Image = (load(GUARD + "normal.png") as Texture2D).get_image()
	var spec: Image = (load(GUARD + "spec.png") as Texture2D).get_image()
	check(albedo != null and normal != null and spec != null, "the albedo, normal and spec atlases load")
	check(albedo.get_size() == normal.get_size() and albedo.get_size() == spec.get_size(), "the three atlases share one layout")
	for tex in ["albedo", "normal", "spec"]:
		check(load(GUARD + tex + ".png") is Texture2D, "the %s atlas is imported" % tex)

	# Pixel grid: every part is made of whole art pixels (up x up blocks of one
	# colour), and its pivot is on a pixel corner.
	var bad_blocks := 0
	var bad_pivot := 0
	var neon_texels := 0
	var neon_without_glow := 0
	var emissive_other := 0
	for pname in data["parts"]:
		var p: Dictionary = data["parts"][pname]
		var r: Array = p["rect"]
		if int(r[2]) % up != 0 or int(r[3]) % up != 0:
			bad_blocks += 1
			continue
		if fposmod(float(p["pivot"][0]), up) != 0.0 or fposmod(float(p["pivot"][1]), up) != 0.0:
			bad_pivot += 1
		for by in range(int(r[3]) / up):
			for bx in range(int(r[2]) / up):
				var x0 := int(r[0]) + bx * up
				var y0 := int(r[1]) + by * up
				var c0 := albedo.get_pixel(x0, y0)
				for dy in up:
					for dx in up:
						var c := albedo.get_pixel(x0 + dx, y0 + dy)
						# (the importer bleeds colour into a transparent texel's rgb)
						if (c.a > 0.5) != (c0.a > 0.5) or (c0.a > 0.5 and c != c0):
							bad_blocks += 1
				var is_neon := c0.a > 0.5 and c0.to_html(false).to_upper() == "C6FF3D"
				var glows := spec.get_pixel(x0 + 1, y0 + 1).b > 0.9
				if is_neon:
					neon_texels += 1
					if not glows:
						neon_without_glow += 1
				elif glows and pname != "baton":
					emissive_other += 1
	check_eq(bad_blocks, 0, "every part is made of whole art pixels (%dx%d texel blocks of one colour)" % [up, up])
	check_eq(bad_pivot, 0, "every pivot sits on a pixel corner")
	check(neon_texels > 30, "the neon trim survives as exactly #C6FF3D (%d art pixels)" % neon_texels)
	check_eq(neon_without_glow, 0, "every exact-neon pixel is in the emissive mask")
	check_eq(emissive_other, 0, "nothing but the neon (and the baton's tell cap) is emissive")
	var baton_glow := 0
	var br: Array = data["parts"]["baton"]["rect"]
	for y in range(int(br[1]), int(br[1]) + int(br[3])):
		for x in range(int(br[0]), int(br[0]) + int(br[2])):
			if spec.get_pixel(x, y).b > 0.9 and spec.get_pixel(x, y).a > 0.5:
				baton_glow += 1
	check(baton_glow > 0, "the baton has an emissive tip for its amber and red tell")

	# Normals are smooth across the pixel steps: away from a part's rim (the
	# rounded silhouette edge) neighbouring texels turn the light by little.
	var worst := 0.0
	for pname in data["parts"]:
		var r: Array = data["parts"][pname]["rect"]
		for y in range(int(r[1]) + 3, int(r[1]) + int(r[3]) - 3):
			for x in range(int(r[0]) + 3, int(r[0]) + int(r[2]) - 3):
				var inner := true
				for o in [Vector2i(3, 0), Vector2i(-3, 0), Vector2i(0, 3), Vector2i(0, -3)]:
					inner = inner and albedo.get_pixel(x + o.x, y + o.y).a > 0.5
				if not inner:
					continue
				var n := normal.get_pixel(x, y)
				worst = maxf(worst, maxf(absf(n.r - normal.get_pixel(x + 1, y).r), absf(n.g - normal.get_pixel(x, y + 1).g)))
	check(worst < 0.25, "the normal map is smooth across pixel steps (worst neighbour step %.3f)" % worst)

	# The rig in the engine.
	var rig := _build(GUARD + "rig.json")
	check_eq(rig.pixel_art, true, "the engine reads pixel_art")
	check_eq(rig.order.size(), 16, "the Night Guard still has 16 joints")
	var nearest: bool = true
	for jname in rig.order:
		nearest = nearest and (rig.sprites[jname] as Sprite2D).texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST
	check(nearest, "every part draws with nearest filtering")
	var lit: bool = true
	for jname in rig.order:
		var m := (rig.sprites[jname] as Sprite2D).material as ShaderMaterial
		lit = lit and m != null and m.get_shader_parameter("normal_atlas") != null and m.get_shader_parameter("spec_atlas") != null
	check(lit, "every part is still lit through its normal and spec maps")

	# Whole art pixels: every joint offset (pelvis included) is a multiple of 1.5.
	var off_grid := []
	for jname in rig.order:
		var pos := Vector2(rig.defs[jname]["pos"][0], rig.defs[jname]["pos"][1])
		for v in [pos.x, pos.y]:
			if absf(fposmod(v + 0.75, 1.5) - 0.75) > 0.011:
				off_grid.append("%s %s" % [jname, str(pos)])
				break
	check(off_grid.is_empty(), "every joint offset is whole art pixels: %s" % str(off_grid))

	# About 102 world px from the soles to the crown.
	rig.apply_pose({})
	var feet: float = rig._ground_error()
	var head_part: Dictionary = data["parts"]["head"]
	var head_top: float = (rig.joints["head"] as Node2D).position.y + (rig.joints["torso"] as Node2D).position.y \
			+ (rig.joints["pelvis"] as Node2D).position.y - float(head_part["pivot"][1]) / float(data["texture_scale"])
	var height := -head_top
	check(height > 97.0 and height < 107.0, "the Night Guard stands about 102 world px (%.1f)" % height)
	check(absf(feet) <= 0.75 + 0.05, "the soles stand within half an art pixel of the floor at rest (%.2f)" % feet)

	# Poses: joints turn in steps (a limb's tip moves about one art pixel), the
	# pelvis sits on whole art pixels, the soles stay near the floor.
	rig.apply_pose({"near_forearm": 0.1234, "torso": 0.0711, "root": Vector2(1.1, 0.4)})
	for jname in ["near_forearm", "torso"]:
		var step: float = rig._rot_step[jname]
		var turns := (rig.joints[jname] as Node2D).rotation / step
		check(absf(turns - round(turns)) < 0.001, "%s turns in whole steps (%.2f deg)" % [jname, rad_to_deg(step)])
		check(rad_to_deg(step) >= 1.5 and rad_to_deg(step) <= 5.0, "%s's step is between 1.5 and 5 degrees" % jname)
	var pelvis_pos: Vector2 = (rig.joints["pelvis"] as Node2D).position
	check(absf(fposmod(pelvis_pos.x + 0.75, 1.5) - 0.75) < 0.011 and absf(fposmod(pelvis_pos.y + 0.75, 1.5) - 0.75) < 0.011,
			"the pelvis sits on whole art pixels (%s)" % str(pelvis_pos))
	check(absf(rig._ground_error()) <= 0.75 + 0.05, "a posed guard's soles stay within half an art pixel of the floor")
	rig.queue_free()

	# The real enemy: the same rig under its tuning, with the tell on the baton tip.
	var guard: Brawler = load("res://scenes/actors/night_guard.tscn").instantiate()
	add_child(guard)
	await physics_frames(3)
	check(guard.rig != null and guard.rig.pixel_art, "the Night Guard enemy builds the pixel rig")
	var tip: Vector2 = guard.rig.sockets["tell"]["pos"]
	check(guard.tuning.tell_offset.distance_to(tip) < 1.0, "the tell light sits on the baton tip (%s vs %s)" % [str(guard.tuning.tell_offset), str(tip)])
	guard.queue_free()
	await physics_frames(2)

	# Every cutout rig is pixel art now: the Staffer and the Patrol Rover became pixel art on
	# 2026-10-06 and the Scrapjack on 2026-10-07 (test_pixel_staffer.gd, test_pixel_rover.gd and
	# test_pixel_scrapjack.gd cover them).
	await physics_frames(1)
