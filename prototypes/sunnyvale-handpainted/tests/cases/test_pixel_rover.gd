extends TestCase
## The Patrol Rover (M01) as pixel art (2026-10-06), built from
## concept-art/m01-patrol-rover/m01-patrol-rover-parts-pixel-v1.webp by
## tools/art/import_parts_sheet.py (build_machine_pixel) as the Night Guard
## and the Staffer were: a pixel_art rig.json, art pixels enlarged 3x with
## nearest filtering, the exact neon colours as the emissive mask (the magenta
## flank strip #FF3DD5, the amber lens and lightbar #C98A2B, the teal battery
## gauge #3FE0D0), joints on whole art pixels, and about the smooth rover's 92
## world px long. What the old rover's code relies on is kept: its ten joints
## and roles, the sockets, the lid that hides the battery when shut and swings
## clear of it when stalled, and the wheels, which are round at every angle
## (they spin).

const ROVER := "res://assets/characters/lit/patrol_rover/"
const MAGENTA := "FF3DD5"
const AMBER_LENS := "C98A2B"
const TEAL := "3FE0D0"
## The smooth Patrol Rover's length (rear of the chassis to the front of the bumper).
const OLD_LENGTH := 92.0
const RigScript := preload("res://scripts/actors/lit/cutout_rig.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const FLOOR_Y := 560.0
const JOINTS := ["chassis", "wheel_far_rear", "wheel_far_front", "wheel_near_rear", "wheel_near_front",
		"lightbar", "battery", "hatch", "sensor", "bumper"]


func _rig_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


## A joint's pivot in rig space (the chassis's offset included).
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


func _html(c: Color) -> String:
	return c.to_html(false).to_upper()


func run() -> void:
	var data := _rig_json(ROVER + "rig.json")
	check_eq(data.get("pixel_art", false), true, "the Patrol Rover's rig.json is flagged pixel_art")
	check_eq(float(data.get("pixel_world", 0.0)), 1.5, "one art pixel is 1.5 world px")
	check_eq(float(data["texture_scale"]), 2.0, "texture_scale 2: three atlas texels per art pixel")
	check_eq(data["kind"], "machine", "the rover's rig is still a machine")
	check_eq(data["ground_lock"], false, "a machine has no ground lock")
	var up := int(round(float(data["texture_scale"]) * float(data["pixel_world"])))

	var albedo: Image = (load(ROVER + "albedo.png") as Texture2D).get_image()
	var normal: Image = (load(ROVER + "normal.png") as Texture2D).get_image()
	var spec: Image = (load(ROVER + "spec.png") as Texture2D).get_image()
	check(albedo != null and normal != null and spec != null, "the albedo, normal and spec atlases load")
	check(albedo.get_size() == normal.get_size() and albedo.get_size() == spec.get_size(), "the three atlases share one layout")
	for tex in ["albedo", "normal", "spec"]:
		check(load(ROVER + tex + ".png") is Texture2D, "the %s atlas is imported" % tex)

	# The ten joints, with the roles patrol_rover.gd drives them by.
	var names := []
	for j in data["joints"]:
		names.append(j["name"])
	check_eq(names, JOINTS, "the ten joints of the old rover, parents first")
	for part in ["chassis", "wheel", "bumper", "sensor", "lightbar", "hatch", "battery"]:
		check(data["parts"].has(part), "the atlas has the %s part" % part)
	check_eq((data["parts"] as Dictionary).size(), 7, "the sheet's seven parts, one wheel for all four wheels")
	for j in data["joints"]:
		if String(j["name"]).begins_with("wheel_"):
			check_eq(j["part"], "wheel", "%s draws the one wheel part" % j["name"])
			check_eq(j["far"], String(j["name"]).begins_with("wheel_far"), "%s is a far wheel only on the far side" % j["name"])
			check_eq(j["collider"]["type"], "circle", "%s has a circle collider" % j["name"])
			check(float(j["collider"]["r"]) > 9.0 and float(j["collider"]["r"]) < 11.0, "%s's collider fits the wheel" % j["name"])

	# Pixel grid and the emissive mask: every part is whole art pixels, its pivot a
	# pixel corner; the exact magenta, amber and teal glow, and nothing else does.
	var bad_blocks := 0
	var bad_pivot := 0
	var counts := {}        # part -> {colour: art pixels}
	var dark_neon := 0      # a glow colour that does not glow
	var other_glow := 0     # something glowing that is not one of the three
	var lens_strength := 0.0
	var bar_strength := 0.0
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
				if hex == MAGENTA or hex == AMBER_LENS or hex == TEAL:
					counts[pname][hex] = int(counts[pname].get(hex, 0)) + 1
					if not glows:
						dark_neon += 1
					if pname == "sensor" and hex == AMBER_LENS:
						lens_strength = spec.get_pixel(x0 + 1, y0 + 1).b
					if pname == "lightbar" and hex == AMBER_LENS:
						bar_strength = spec.get_pixel(x0 + 1, y0 + 1).b
				elif glows:
					other_glow += 1
	check_eq(bad_blocks, 0, "every part is made of whole art pixels (%dx%d texel blocks of one colour)" % [up, up])
	check_eq(bad_pivot, 0, "every pivot sits on a pixel corner")
	check(int(counts["chassis"].get(MAGENTA, 0)) > 20, "the flank strip survives as exactly #FF3DD5 (%d art pixels)" % int(counts["chassis"].get(MAGENTA, 0)))
	check(int(counts["lightbar"].get(AMBER_LENS, 0)) >= 6, "the lightbar keeps its six lenses as exactly #C98A2B (%d art pixels)" % int(counts["lightbar"].get(AMBER_LENS, 0)))
	check(int(counts["sensor"].get(AMBER_LENS, 0)) >= 1, "the sensor pod keeps its one amber lens")
	check(int(counts["battery"].get(TEAL, 0)) >= 4, "the battery keeps its gauge as exactly #3FE0D0 (%d art pixels)" % int(counts["battery"].get(TEAL, 0)))
	for pname in counts:
		for hex in counts[pname]:
			check(hex == MAGENTA and pname == "chassis" or hex == AMBER_LENS and (pname == "lightbar" or pname == "sensor") or hex == TEAL and pname == "battery",
					"%s is only used where it belongs (%s on %s)" % [hex, hex, pname])
	check_eq(dark_neon, 0, "every exact-neon pixel is in the emissive mask")
	check_eq(other_glow, 0, "nothing but the three neon colours is emissive")
	check(lens_strength > 0.2 and lens_strength < 0.5 and bar_strength > 0.9, "the sensor lens glows dimmer (%.2f) than the lightbar (%.2f)" % [lens_strength, bar_strength])

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

	# Size: the rover is as long as the smooth one (rear of the chassis to the front of
	# the bumper), as tall as before, and its wheels stand on the floor.
	var chassis := _joint_rect(data, "chassis")
	var bumper := _joint_rect(data, "bumper")
	var length := bumper.end.x - chassis.position.x
	check(absf(length - OLD_LENGTH) / OLD_LENGTH < 0.05, "the rover is within 5%% of the old %.0f world px long (%.1f)" % [OLD_LENGTH, length])
	var top := 0.0
	var bottom := -INF
	for jname in JOINTS:
		var rect := _joint_rect(data, jname)
		top = minf(top, rect.position.y)
		bottom = maxf(bottom, rect.end.y)
	check(absf(bottom) <= 0.76, "the lowest wheel point stands on the floor (%.2f)" % bottom)
	check(-top <= 48.0 and -top >= 36.0, "the rover is about as tall as the old one and fits its 48 px body box (%.1f)" % -top)
	check(chassis.position.x > -49.0 and bumper.end.x < 49.0, "the rig sits inside the body box's width (%.1f to %.1f)" % [chassis.position.x, bumper.end.x])

	# The wheel is round about its hub whatever its turn: its art is the same after a quarter
	# turn and a mirror (a spinning wheel must not wobble).
	var wr: Array = data["parts"]["wheel"]["rect"]
	var wpv: Array = data["parts"]["wheel"]["pivot"]
	var wn := int(wr[2]) / up
	check_eq(wn, int(wr[3]) / up, "the wheel is square")
	check(wn % 2 == 0 and absf(float(wpv[0]) / up - wn / 2.0) < 0.01 and absf(float(wpv[1]) / up - wn / 2.0) < 0.01, "the wheel's pivot is the centre corner of its art")
	var wheel_asym := 0
	for j in range(wn):
		for i in range(wn):
			var a := albedo.get_pixel(int(wr[0]) + i * up + 1, int(wr[1]) + j * up + 1)
			var b := albedo.get_pixel(int(wr[0]) + (wn - 1 - j) * up + 1, int(wr[1]) + i * up + 1)   # quarter turn
			var m := albedo.get_pixel(int(wr[0]) + (wn - 1 - i) * up + 1, int(wr[1]) + j * up + 1)  # mirror
			if a != b or a != m:
				wheel_asym += 1
	check_eq(wheel_asym, 0, "the wheel art is the same under a quarter turn and a mirror")

	# Sockets: the tell on the lightbar, the lens on the pod, the core in the battery.
	for sname in ["lens_light", "tell", "core", "spark_bumper", "spark_hatch", "spark_dome", "oil_drip"]:
		check(data["sockets"].has(sname), "the rig keeps its %s socket" % sname)
	var tell: Dictionary = data["sockets"]["tell"]
	var tell_at := _joint_pos(data, tell["joint"]) + Vector2(tell["pos"][0], tell["pos"][1])
	check_eq(tell["joint"], "lightbar", "the tell light is on the lightbar")
	check(_joint_rect(data, "lightbar").grow(0.1).has_point(tell_at), "the tell socket is inside the lightbar (%s)" % str(tell_at))
	var lens: Dictionary = data["sockets"]["lens_light"]
	check(_joint_rect(data, "sensor").grow(0.1).has_point(_joint_pos(data, lens["joint"]) + Vector2(lens["pos"][0], lens["pos"][1])), "the lens socket is inside the sensor pod")
	var core: Dictionary = data["sockets"]["core"]
	check(_joint_rect(data, "battery").grow(0.1).has_point(_joint_pos(data, core["joint"]) + Vector2(core["pos"][0], core["pos"][1])), "the core socket is inside the battery")
	var sp_b: Dictionary = data["sockets"]["spark_bumper"]
	var spark_front := _joint_pos(data, sp_b["joint"]).x + float(sp_b["pos"][0])
	check(absf(spark_front - bumper.end.x) < 3.0, "the bumper's spark point is its front face (%.1f vs %.1f)" % [spark_front, bumper.end.x])
	var drip: Dictionary = data["sockets"]["oil_drip"]
	check(float(drip["pos"][1]) > 0.0, "the oil drips from under the chassis")

	# The lid: shut, it hides the battery (to within an art pixel); stalled, it swings clear
	# of the gauge and the battery shows. (patrol_rover.gd opens it by HATCH_OPEN.)
	var lid := _joint_rect(data, "hatch")
	var batt := _joint_rect(data, "battery")
	check(lid.grow(1.6).encloses(batt), "the shut lid covers the battery (lid %s, battery %s)" % [str(lid), str(batt)])
	var br: Array = data["parts"]["battery"]["rect"]
	var gauge := Vector2.ZERO
	var gauge_n := 0
	for y in range(int(br[1]), int(br[1]) + int(br[3])):
		for x in range(int(br[0]), int(br[0]) + int(br[2])):
			var c := albedo.get_pixel(x, y)
			if c.a > 0.5 and _html(c) == TEAL:
				gauge += Vector2(x - int(br[0]), y - int(br[1]))
				gauge_n += 1
	var t := 1.0 / float(data["texture_scale"])
	var gauge_at := _joint_pos(data, "battery") - Vector2(data["parts"]["battery"]["pivot"][0], data["parts"]["battery"]["pivot"][1]) * t + gauge / float(gauge_n) * t
	var hinge := _joint_pos(data, "hatch")
	var corners := PackedVector2Array()
	for corner in [lid.position, Vector2(lid.end.x, lid.position.y), lid.end, Vector2(lid.position.x, lid.end.y)]:
		corners.append(hinge + (corner - hinge).rotated(PatrolRover.HATCH_OPEN))
	check(Geometry2D.is_point_in_polygon(gauge_at, PackedVector2Array([lid.position, Vector2(lid.end.x, lid.position.y), lid.end, Vector2(lid.position.x, lid.end.y)])),
			"the gauge is under the shut lid (%s)" % str(gauge_at))
	check(not Geometry2D.is_point_in_polygon(gauge_at, corners), "the open lid is clear of the gauge")

	# In the engine: the real rover builds the rig, nearest-filtered and lit, the tell
	# light on the lightbar's socket, the wheels turn in steps, the body bounces by whole
	# art pixels.
	var floor_b := BlockScript.new()
	floor_b.position = Vector2(0, FLOOR_Y)
	floor_b.size = Vector2(3000, 200)
	add_child(floor_b)
	var rover: PatrolRover = load("res://scenes/actors/patrol_rover.tscn").instantiate()
	rover.patrol_min_x = 699.0
	rover.patrol_max_x = 701.0
	rover.position = Vector2(700, FLOOR_Y)
	add_child(rover)
	await physics_frames(3)
	var rig = rover.rig
	check(rig != null and rig.pixel_art, "the Patrol Rover enemy builds the pixel rig")
	check_eq(rig.order.size(), 10, "the rover still has 10 joints")
	var nearest := true
	var lit := true
	for jname in rig.order:
		nearest = nearest and (rig.sprites[jname] as Sprite2D).texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST
		var m := (rig.sprites[jname] as Sprite2D).material as ShaderMaterial
		lit = lit and m != null and m.get_shader_parameter("normal_atlas") != null and m.get_shader_parameter("spec_atlas") != null
	check(nearest, "every part draws with nearest filtering")
	check(lit, "every part is still lit through its normal and spec maps")
	for role in ["chassis", "lightbar", "battery", "hatch", "dome", "bumper", "wheel_near_front", "wheel_near_rear", "wheel_far_front", "wheel_far_rear"]:
		check(rig.joint_for_role(role) != "", "the rover rig has a %s" % role)
	var tl: Node = rover._tell_light
	check(tl != null and tl.get_parent() == rig.joints["lightbar"] and tl.position.distance_to(rig.sockets["tell"]["pos"]) < 0.01, "the tell light sits on the lightbar's tell socket")
	for w in ["wheel_near_front", "wheel_near_rear", "wheel_far_front", "wheel_far_rear"]:
		var step: float = rig._rot_step[w]
		check(rad_to_deg(step) >= 1.5 and rad_to_deg(step) <= 5.0, "%s turns in steps of %.1f degrees (1.5 to 5)" % [w, rad_to_deg(step)])
	rig.apply_pose({"wheel_near_front": 1.2345})
	var turns: float = (rig.joints["wheel_near_front"] as Node2D).rotation / float(rig._rot_step["wheel_near_front"])
	check(absf(turns - round(turns)) < 0.001, "a wheel's spin is posed in whole steps")

	# Patrol: the chassis bounces by one art pixel at a time (a fraction of a pixel would
	# be rounded away), and rests on the floor.
	var ys := {}
	for i in 100:
		await physics_frames(1)
		var y: float = (rig.joints["chassis"] as Node2D).position.y
		ys[snappedf(y, 0.01)] = true
		check(absf(fposmod(y + 0.75, 1.5) - 0.75) < 0.011, "the chassis sits on whole art pixels (%.2f)" % y)
		if not rover.is_inside_tree():
			break
	check(ys.size() >= 2, "the patrolling rover still bounces (%s)" % str(ys.keys()))
	rover.queue_free()
	floor_b.queue_free()
	await physics_frames(2)

	# The old smooth art stays rebuildable.
	var importer := FileAccess.get_file_as_string("res://tools/art/import_parts_sheet.py")
	check(importer.contains("\"patrol_rover_smooth\": {") and importer.contains("m01-patrol-rover-parts-v1.webp") and importer.contains("m01-patrol-rover-parts-pixel-v1.webp"),
			"import_parts_sheet.py keeps the smooth rover as patrol_rover_smooth beside the pixel one")
	for sheet in ["m01-patrol-rover-parts-v1.webp", "m01-patrol-rover-parts-pixel-v1.webp"]:
		check(FileAccess.file_exists(ProjectSettings.globalize_path("res://").path_join("../../concept-art/m01-patrol-rover").path_join(sheet)), "the %s sheet is in concept-art" % sheet)
