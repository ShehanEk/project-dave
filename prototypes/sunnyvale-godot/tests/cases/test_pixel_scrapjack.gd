extends TestCase
## The Scrapjack (W01, Dave's gun) as pixel art (2026-10-07), built from
## concept-art/w01-scrapjack/w01-scrapjack-parts-pixel-v1.webp by
## tools/art/import_parts_sheet.py (build_prop_pixel) as the Night Guard, the
## Staffer and the Patrol Rover were: a pixel_art rig.json, art pixels
## enlarged 3x with nearest filtering, the exact copper #D9884A (the coils,
## which glow per shot) and teal #3FE0D0 (the charge light, a steady glow) as
## the emissive masks, joints on whole art pixels. What the hero and
## scrapjack.gd rely on is kept: the four joints, the frame as the root with
## its origin on the grip (where Dave's fist is), the muzzle socket on the
## barrel at the front of the gun, and a gun that turns smoothly with the aim
## and recoils in whole art pixels.
##
## The sheet draws the pistol about 123 generated pixels long (the prompt asked
## for 26), so at the smooth gun's 26 world px the art would be 17 pixels long
## and illegible (the teal light and a coil drop out): it is 24 art pixels, 36
## world px, long, and the test says so (an upper bound of 1.5x as well as the
## lower one).

const GUN := "res://assets/characters/lit/scrapjack/"
const COPPER := "D9884A"
const TEAL := "3FE0D0"
const OLD_LENGTH := 26.0          # the smooth gun, back of the grip to the muzzle
const OLD_MUZZLE := Vector2(22.38, -2.95)   # the smooth gun's muzzle from its grip
const JOINTS := ["frame", "barrel", "upper", "battery"]
const RigScript := preload("res://scripts/actors/lit/cutout_rig.gd")
const BlockScript := preload("res://scripts/world/block.gd")


func _rig_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


func _html(c: Color) -> String:
	return c.to_html(false).to_upper()


## A joint's pivot in rig space.
func _joint_pos(data: Dictionary, jname: String) -> Vector2:
	var p := Vector2.ZERO
	var by_name := {}
	for j in data["joints"]:
		by_name[j["name"]] = j
	var cur: String = jname
	while cur != "":
		var j: Dictionary = by_name[cur]
		p += Vector2(j["pos"][0], j["pos"][1])
		cur = j["parent"]
	return p


## The part a joint draws, as a rectangle in rig space (world px) at rest.
func _joint_rect(data: Dictionary, jname: String) -> Rect2:
	var t := 1.0 / float(data["texture_scale"])
	var part_name := ""
	for j in data["joints"]:
		if j["name"] == jname:
			part_name = j["part"]
	var part: Dictionary = data["parts"][part_name]
	var r: Array = part["rect"]
	var origin := _joint_pos(data, jname) - Vector2(part["pivot"][0], part["pivot"][1]) * t
	return Rect2(origin, Vector2(r[2], r[3]) * t)


func run() -> void:
	var data := _rig_json(GUN + "rig.json")
	check_eq(data.get("pixel_art", false), true, "the Scrapjack's rig.json is flagged pixel_art")
	check_eq(float(data.get("pixel_world", 0.0)), 1.5, "one art pixel is 1.5 world px")
	check_eq(float(data["texture_scale"]), 2.0, "texture_scale 2: three atlas texels per art pixel")
	check_eq(data["kind"], "prop", "the gun's rig is still a prop (no skeleton, aimed by scrapjack.gd)")
	check_eq(data["ground_lock"], false, "a prop has no ground lock")
	check(String(data["source"]).ends_with("w01-scrapjack-parts-pixel-v1.webp"), "its source is the pixel parts sheet")
	var up := int(round(float(data["texture_scale"]) * float(data["pixel_world"])))

	var albedo: Image = (load(GUN + "albedo.png") as Texture2D).get_image()
	var normal: Image = (load(GUN + "normal.png") as Texture2D).get_image()
	var spec: Image = (load(GUN + "spec.png") as Texture2D).get_image()
	check(albedo != null and normal != null and spec != null, "the albedo, normal and spec atlases load")
	check(albedo.get_size() == normal.get_size() and albedo.get_size() == spec.get_size(), "the three atlases share one layout")
	for tex in ["albedo", "normal", "spec"]:
		check(load(GUN + tex + ".png") is Texture2D, "the %s atlas is imported" % tex)

	# The four joints scrapjack.gd and the hero rely on; the frame is the root.
	var names := []
	for j in data["joints"]:
		names.append(j["name"])
		check_eq(j["part"], j["name"], "%s draws its own part" % j["name"])
		check_eq(j["parent"], "" if j["name"] == "frame" else "frame", "%s hangs off the frame" % j["name"] if j["name"] != "frame" else "the frame is the root")
	check_eq(names, JOINTS, "the old gun's four joints, the frame first")
	check_eq((data["parts"] as Dictionary).size(), 4, "the sheet's four parts: frame, upper housing, barrel, battery cell")

	# The grip: the frame's joint is the rig's origin, as for the smooth gun (hero.tscn and
	# scrapjack.gd put the fist at GRIP_LOCAL on that origin).
	var frame_joint: Dictionary = data["joints"][0]
	check_eq(Vector2(frame_joint["pos"][0], frame_joint["pos"][1]), Vector2.ZERO, "the frame's pivot, the grip, is the rig's origin")
	check(_joint_rect(data, "frame").has_point(Vector2(0.01, 0.01)), "the grip point lies on the frame's art (the taped grip)")

	# Pixel grid and the emissive mask: every part is whole art pixels, its pivot a pixel
	# corner; the exact copper and teal glow (only on the barrel and the battery), nothing else does.
	var bad_blocks := 0
	var bad_pivot := 0
	var counts := {}        # part -> {colour: art pixels}
	var dark_neon := 0      # a glow colour that does not glow
	var other_glow := 0     # something glowing that is not copper or teal
	for pname in data["parts"]:
		var p: Dictionary = data["parts"][pname]
		var r: Array = p["rect"]
		if int(r[2]) % up != 0 or int(r[3]) % up != 0:
			bad_blocks += 1
			continue
		if fposmod(float(p["pivot"][0]), up) != 0.0 or fposmod(float(p["pivot"][1]), up) != 0.0:
			bad_pivot += 1
		counts[pname] = {}
		for by in range(int(r[3]) / up):
			for bx in range(int(r[2]) / up):
				var x0 := int(r[0]) + bx * up
				var y0 := int(r[1]) + by * up
				var c0 := albedo.get_pixel(x0, y0)
				for dy in up:
					for dx in up:
						var c := albedo.get_pixel(x0 + dx, y0 + dy)
						if (c.a > 0.5) != (c0.a > 0.5) or (c0.a > 0.5 and c != c0):
							bad_blocks += 1
				if c0.a < 0.5:
					continue
				var hex := _html(c0)
				var glows := spec.get_pixel(x0 + 1, y0 + 1).b > 0.2
				if hex == COPPER or hex == TEAL:
					counts[pname][hex] = int(counts[pname].get(hex, 0)) + 1
					if not glows:
						dark_neon += 1
				elif glows:
					other_glow += 1
	check_eq(bad_blocks, 0, "every part is made of whole art pixels (%dx%d texel blocks of one colour)" % [up, up])
	check_eq(bad_pivot, 0, "every pivot sits on a pixel corner")
	check(int(counts["barrel"].get(COPPER, 0)) >= 6, "the barrel's two coils are exactly #D9884A (%d art pixels)" % int(counts["barrel"].get(COPPER, 0)))
	check(int(counts["battery"].get(TEAL, 0)) >= 1, "the battery's charge light is exactly #3FE0D0 (%d art pixels)" % int(counts["battery"].get(TEAL, 0)))
	for pname in counts:
		for hex in counts[pname]:
			check(hex == COPPER and pname == "barrel" or hex == TEAL and pname == "battery",
					"%s is only used where it belongs (%s on %s)" % [hex, hex, pname])
	check_eq(dark_neon, 0, "every exact copper and teal pixel is in the emissive mask")
	check_eq(other_glow, 0, "nothing but the coils and the charge light is emissive (no rust fleck, no scrap glows)")

	# Normals are smooth across the pixel steps.
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

	# Joint offsets are whole art pixels.
	var off_grid := []
	for j in data["joints"]:
		for v in [float(j["pos"][0]), float(j["pos"][1])]:
			if absf(fposmod(v + 0.75, 1.5) - 0.75) > 0.011:
				off_grid.append("%s %s" % [j["name"], str(j["pos"])])
				break
	check(off_grid.is_empty(), "every joint offset is whole art pixels: %s" % str(off_grid))

	# Sockets: the muzzle is on the barrel at the front of the whole gun; the charge light is on
	# the battery's teal pixel.
	var muzzle_sock: Dictionary = data["sockets"]["muzzle"]
	check_eq(muzzle_sock["joint"], "barrel", "the muzzle socket is on the barrel")
	var muzzle := _joint_pos(data, "barrel") + Vector2(muzzle_sock["pos"][0], muzzle_sock["pos"][1])
	var front := -INF
	var back := INF
	for jname in JOINTS:
		var rect := _joint_rect(data, jname)
		front = maxf(front, rect.end.x)
		back = minf(back, rect.position.x)
	check(absf(muzzle.x - front) < 0.01, "the muzzle is the front-most point of the gun (%.2f vs %.2f)" % [muzzle.x, front])
	var barrel_rect := _joint_rect(data, "barrel")
	check(muzzle.y > barrel_rect.position.y and muzzle.y < barrel_rect.end.y, "and halfway up the barrel (y %.2f in %.2f..%.2f)" % [muzzle.y, barrel_rect.position.y, barrel_rect.end.y])
	check(absf(muzzle.y - OLD_MUZZLE.y) < 1.6, "its height above the grip is near the smooth gun's (%.2f vs %.2f), so a shot still starts close to the aim line" % [muzzle.y, OLD_MUZZLE.y])
	var length := muzzle.x - back
	check(length >= OLD_LENGTH and length <= OLD_LENGTH * 1.5, "the gun is %.1f world px long: longer than the smooth gun's %.0f (the sheet is too fine to bin to it) but under 1.5x" % [length, OLD_LENGTH])
	check(absf(fposmod(length, 1.5) - 0.0) < 0.011 or absf(fposmod(length, 1.5) - 1.5) < 0.011, "and a whole number of art pixels long (%.1f art px)" % (length / 1.5))
	var light_sock: Dictionary = data["sockets"]["charge_light"]
	check_eq(light_sock["joint"], "battery", "the charge light socket is on the battery")
	var bp: Dictionary = data["parts"]["battery"]
	var lx := int(floor((float(light_sock["pos"][0]) * 2.0 + float(bp["pivot"][0]))))
	var ly := int(floor((float(light_sock["pos"][1]) * 2.0 + float(bp["pivot"][1]))))
	var lc := albedo.get_pixel(int(bp["rect"][0]) + lx, int(bp["rect"][1]) + ly)
	check_eq(_html(lc), TEAL, "the charge light socket sits on the teal pixel")

	# The engine: the rig draws with nearest filtering and is not stepped by a pose.
	var rig: Node2D = RigScript.new()
	rig.rig_path = GUN + "rig.json"
	add_child(rig)
	check(rig.pixel_art, "cutout_rig builds it as a pixel-art rig")
	var smooth := true
	for jname in rig.order:
		smooth = smooth and (rig.sprites[jname] as Sprite2D).texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST
	check(not smooth, "every part sprite uses nearest filtering")
	check(rig.sockets.has("muzzle") and rig.sockets.has("charge_light"), "the rig keeps its two sockets")
	rig.queue_free()
	await physics_frames(1)

	await _test_on_the_hero()


## The gun on Dave: the rig is the gun's, the muzzle marker sits on the socket, the flash and
## the shot start there, the gun turns smoothly with the aim, recoils in whole art pixels, and
## glows copper per shot while the teal light steadies.
func _test_on_the_hero() -> void:
	Session.new_run()
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(0, 0)
	floor_b.size = Vector2(3000, 200)
	add_child(floor_b)
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = Vector2(800, -1)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(500, -60)
	await physics_frames(4)
	var gun: Scrapjack = hero.get_node("AimPivot/Scrapjack")
	check(gun.rig != null and gun.rig.pixel_art, "Dave's Scrapjack wears the pixel-art rig")
	if gun.rig == null:
		hero.queue_free()
		floor_b.queue_free()
		return
	var rig: Node2D = gun.rig
	check(rig.position.is_equal_approx(Scrapjack.GRIP_LOCAL), "at rest the rig's origin, the grip, sits where the fist is (%s)" % str(rig.position))

	# The muzzle marker is the socket's place in the gun's space; the gun's front edge is there.
	var sock: Dictionary = rig.sockets["muzzle"]
	var s := 1.0 / maxf(absf(gun.scale.x), 0.001)
	var want: Vector2 = rig.position + ((rig.joints[sock["joint"]] as Node2D).position + (sock["pos"] as Vector2)) * s
	check(gun._muzzle.position.distance_to(want) < 0.01, "the muzzle marker sits on the barrel's muzzle socket")
	var front := -INF
	for jname in rig.order:
		var spr: Sprite2D = rig.sprites[jname]
		var right: float = (rig.joints[jname] as Node2D).position.x + spr.offset.x * spr.scale.x + spr.region_rect.size.x * spr.scale.x
		front = maxf(front, right)
	check(absf((gun._muzzle.position.x - rig.position.x) / s - front) < 0.01, "the muzzle is at the front edge of the drawn gun")

	# The gun turns with the aim and is not stepped: its global rotation is the aim pivot's own, to
	# the last digit (a pixel-art rig stepping its turn would be off by up to half a step), and the
	# pivot follows the aim.
	var distinct := {}
	for deg in [3.0, 17.0, -41.0, 63.0, 17.3, 17.9]:
		var a := deg_to_rad(deg)
		hero.aim_override = hero.aim_pivot.global_position + Vector2(cos(a), sin(a)) * 400.0
		await physics_frames(3)
		var turn: float = wrapf(rig.global_rotation - hero.aim_pivot.global_rotation, -PI, PI)
		check(absf(turn) < 0.0005, "the gun turns exactly with the aim pivot at %.1f degrees, with no rotation step (%.4f deg off)" % [deg, rad_to_deg(turn)])
		var to_aim: float = (hero.aim_override - hero.aim_pivot.global_position).angle()
		check(absf(wrapf(hero.aim_pivot.global_rotation - to_aim, -PI, PI)) < deg_to_rad(2.5), "and the pivot follows the aim (%.1f vs %.1f degrees)" % [rad_to_deg(hero.aim_pivot.global_rotation), rad_to_deg(to_aim)])
		distinct[snappedf(rig.global_rotation, 0.0001)] = true
	check_eq(distinct.size(), 6, "six different aims give six different gun angles, even 0.3 and 0.6 degrees apart")
	# Aiming left turns the gun over (hero.gd flips the pivot) rather than upside down.
	hero.aim_override = hero.aim_pivot.global_position + Vector2(-400.0, -50.0)
	await physics_frames(3)
	check(rig.global_transform.y.y > 0.0, "aimed left the gun is still the right way up")
	hero.aim_override = hero.global_position + Vector2(500, -60)
	await physics_frames(3)

	# Recoil: the slide and the arm's kick move in whole art pixels, and the coils glow per shot.
	var upper_rest: Vector2 = gun._slide_rest["upper"]
	var mat: ShaderMaterial = rig.joint_material("barrel")
	var idle: float = mat.get_shader_parameter("emissive_energy")
	gun._try_fire()
	var seen_kicks := {}
	var all_whole := true
	for i in 8:
		await physics_frames(1)
		var slide: float = absf((rig.joints["upper"] as Node2D).position.x - upper_rest.x)
		var kick: float = absf(rig.position.x - Scrapjack.GRIP_LOCAL.x) * absf(gun.scale.x)    # world px
		for v in [slide, kick]:
			if absf(fposmod(v + 0.75, 1.5) - 0.75) > 0.011:
				all_whole = false
		seen_kicks[snappedf(kick, 0.01)] = true
	check(all_whole, "the slide and the kick are whole art pixels (1.5 world px) on every frame")
	check(seen_kicks.size() >= 2, "the kick steps down as the recoil settles (%s)" % str(seen_kicks.keys()))
	check(float(mat.get_shader_parameter("emissive_energy")) < 0.5 + idle, "the coils cool again after a shot")
	gun._try_fire()
	await physics_frames(1)
	check(float(mat.get_shader_parameter("emissive_energy")) > idle + 0.5, "a shot heats the copper coils")
	# The charge light is one steady teal glow.
	var bmat: ShaderMaterial = rig.joint_material("battery")
	check(float(bmat.get_shader_parameter("emissive_energy")) > 0.5, "the teal charge light glows")

	# The shot and its flash start at the muzzle.
	await seconds(0.4)
	for b in get_tree().root.find_children("*", "ScrapBolt", true, false):
		b.queue_free()
	await physics_frames(1)
	gun._try_fire()
	var bolts := get_tree().root.find_children("*", "ScrapBolt", true, false)
	check_eq(bolts.size(), 1, "a shot spawns one bolt")
	if bolts.size() == 1:
		check((bolts[0] as Node2D).global_position.distance_to(gun.get_muzzle_global_position()) < 0.5, "the bolt starts at the muzzle")
	var flashes := gun._muzzle.get_children().filter(func(c): return c.get_script() != null and String(c.get_script().resource_path).ends_with("pixel_fx.gd"))
	check(not flashes.is_empty(), "the shot's flash is a child of the muzzle marker (%d)" % flashes.size())
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
