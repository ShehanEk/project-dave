extends TestCase
## The Staffer (LK01) as pixel art (2026-10-06), built from
## concept-art/lk01-staffer/lk01-staffer-parts-pixel-v1.webp by
## tools/art/import_parts_sheet.py exactly as the Night Guard was: pixel_art
## rig.json, art pixels enlarged 3x with nearest filtering, the exact electric
## blue #4D8DFF trim as the emissive mask, joints on whole art pixels, about
## the old rig's 97 world px tall. Extras of this rig: the Link port (its
## centre pixel is the dull amber light) and the ID lanyard are joints of
## their own, the tell glows on the grip hands at the rig's grip sockets, and
## a defeated Staffer's ragdoll still falls with the port riding on the head.

const STAFFER := "res://assets/characters/lit/staffer/"
const NEON := "4D8DFF"
const LENS := "C98A2B"
## The smooth Staffer's height (paint_staffer.py: crown 96.9 world px above the soles).
const OLD_HEIGHT := 96.9
const RigScript := preload("res://scripts/actors/lit/cutout_rig.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const Blood := preload("res://scripts/effects/blood.gd")
const FLOOR_Y := 560.0


func _rig_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


func run() -> void:
	var data := _rig_json(STAFFER + "rig.json")
	check_eq(data.get("pixel_art", false), true, "the Staffer's rig.json is flagged pixel_art")
	check_eq(float(data.get("pixel_world", 0.0)), 1.5, "one art pixel is 1.5 world px")
	check_eq(float(data["texture_scale"]), 2.0, "texture_scale 2: three atlas texels per art pixel")
	var up := int(round(float(data["texture_scale"]) * float(data["pixel_world"])))

	var albedo: Image = (load(STAFFER + "albedo.png") as Texture2D).get_image()
	var normal: Image = (load(STAFFER + "normal.png") as Texture2D).get_image()
	var spec: Image = (load(STAFFER + "spec.png") as Texture2D).get_image()
	check(albedo != null and normal != null and spec != null, "the albedo, normal and spec atlases load")
	check(albedo.get_size() == normal.get_size() and albedo.get_size() == spec.get_size(), "the three atlases share one layout")

	# Parts: the 13 of the sheet, the port and the lanyard among them.
	check_eq((data["parts"] as Dictionary).size(), 13, "the sheet's 13 parts are all in the atlas")
	for pname in ["head", "port", "torso", "pelvis", "upper_arm", "forearm", "forearm_bare", "hand_grip", "hand_open", "thigh", "shin", "foot", "lanyard"]:
		check(data["parts"].has(pname), "the atlas has the %s part" % pname)

	# Pixel grid, and the emissive mask: the exact blue trim glows, the amber port
	# lens (one art pixel) glows, and nothing else does.
	var bad_blocks := 0
	var bad_pivot := 0
	var neon_px := 0
	var neon_dark := 0
	var other_glow := 0
	var lens_px := 0
	var lens_texels_glowing := 0
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
						if (c.a > 0.5) != (c0.a > 0.5) or (c0.a > 0.5 and c != c0):
							bad_blocks += 1
				var html := c0.to_html(false).to_upper()
				var glows := spec.get_pixel(x0 + 1, y0 + 1).b > 0.9
				if c0.a > 0.5 and html == NEON:
					neon_px += 1
					if not glows:
						neon_dark += 1
				elif c0.a > 0.5 and html == LENS and pname == "port":
					lens_px += 1
					if glows:
						lens_texels_glowing += 1
				elif glows:
					other_glow += 1
	check_eq(bad_blocks, 0, "every part is made of whole art pixels (%dx%d texel blocks of one colour)" % [up, up])
	check_eq(bad_pivot, 0, "every pivot sits on a pixel corner")
	check(neon_px > 12, "the trim survives as exactly #%s (%d art pixels)" % [NEON, neon_px])
	check_eq(neon_dark, 0, "every exact-blue pixel is in the emissive mask")
	check_eq(lens_px, 1, "the port has one amber lens pixel")
	check_eq(lens_texels_glowing, 1, "the lens pixel is emissive")
	check_eq(other_glow, 0, "nothing but the blue trim and the port lens is emissive (the grips and the port stay unlit)")

	# The port and the lanyard are joints of their own; the port is on the head, the lanyard on the torso.
	var joints := {}
	for j in data["joints"]:
		joints[j["name"]] = j
	check_eq(joints.size(), 17, "17 joints: the 15 body joints, the port and the lanyard")
	for jname in ["pelvis", "torso", "head", "near_upper_arm", "near_forearm", "near_hand", "far_upper_arm", "far_forearm",
			"far_hand", "near_thigh", "near_shin", "near_foot", "far_thigh", "far_shin", "far_foot"]:
		check(joints.has(jname), "the old joint %s is still there" % jname)
	check(joints.has("port") and joints["port"]["parent"] == "head" and joints["port"]["part"] == "port", "the Link port hangs on the head")
	check(joints.has("lanyard") and joints["lanyard"]["parent"] == "torso" and joints["lanyard"]["part"] == "lanyard", "the lanyard hangs on the torso")
	check_eq(joints["near_forearm"]["part"], "forearm_bare", "the near forearm is the bare one")
	check_eq(joints["near_hand"]["part"], "hand_grip", "the near hand is the closed padded grip")
	check_eq(joints["far_hand"]["part"], "hand_open", "the far hand is the open padded grip")
	# Same hierarchy, limits and rest directions as before: the hand-keyed clips, the lunge and the ragdoll depend on them.
	for pair in [["torso", "pelvis", -90], ["head", "torso", -90], ["near_upper_arm", "torso", 90], ["near_forearm", "near_upper_arm", 90],
			["near_hand", "near_forearm", 90], ["near_thigh", "pelvis", 90], ["near_shin", "near_thigh", 90], ["near_foot", "near_shin", 0],
			["far_thigh", "pelvis", 90], ["far_foot", "far_shin", 0]]:
		check(joints[pair[0]]["parent"] == pair[1] and int(joints[pair[0]]["rest_dir"]) == pair[2], "%s keeps its parent and rest direction" % pair[0])
	check(joints["torso"]["limit"] == [-35.0, 75.0], "the torso keeps its ragdoll limit")
	check(joints["near_shin"]["limit"] == [0.0, 150.0], "the shin keeps its ragdoll limit")
	check_eq(float(joints["torso"]["mass"]), 22.0, "the torso keeps the old Staffer's mass")
	var every_collider := true
	for jname in joints:
		every_collider = every_collider and joints[jname].has("collider") and float(joints[jname]["mass"]) > 0.0
	check(every_collider, "every joint has a collider and a mass")

	# Sockets: the port's light and sparks on the lens pixel, the tell glow on each grip hand's palm.
	var sockets: Dictionary = data["sockets"]
	for sname in ["port_light", "spark_port", "grip_near", "grip_far"]:
		check(sockets.has(sname), "the %s socket exists" % sname)
	check_eq(sockets["port_light"]["joint"], "port", "the port light is on the port")
	check_eq(sockets["grip_near"]["joint"], "near_hand", "the near grip socket is on the near hand")
	check_eq(sockets["grip_far"]["joint"], "far_hand", "the far grip socket is on the far hand")
	var tex_scale := float(data["texture_scale"])
	for entry in [["port_light", "port"], ["spark_port", "port"], ["grip_near", "hand_grip"], ["grip_far", "hand_open"]]:
		var sock: Dictionary = sockets[entry[0]]
		var part: Dictionary = data["parts"][entry[1]]
		var tx := int(floor(float(part["rect"][0]) + float(part["pivot"][0]) + float(sock["pos"][0]) * tex_scale))
		var ty := int(floor(float(part["rect"][1]) + float(part["pivot"][1]) + float(sock["pos"][1]) * tex_scale))
		check(albedo.get_pixel(tx, ty).a > 0.5, "the %s socket sits on its part's art" % entry[0])
		if entry[0] == "port_light" or entry[0] == "spark_port":
			check(spec.get_pixel(tx, ty).b > 0.9 and albedo.get_pixel(tx, ty).to_html(false).to_upper() == LENS, "the %s socket is on the amber lens pixel" % entry[0])
		else:
			check(spec.get_pixel(tx, ty).b < 0.1, "the %s socket is on an unlit palm" % entry[0])

	# The rig in the engine.
	var rig: Node2D = RigScript.new()
	rig.rig_path = STAFFER + "rig.json"
	add_child(rig)
	check_eq(rig.pixel_art, true, "the engine reads pixel_art")
	check_eq(rig.order.size(), 17, "the engine builds 17 joints")
	var nearest := true
	var lit := true
	for jname in rig.order:
		nearest = nearest and (rig.sprites[jname] as Sprite2D).texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST
		var m := (rig.sprites[jname] as Sprite2D).material as ShaderMaterial
		lit = lit and m != null and m.get_shader_parameter("normal_atlas") != null and m.get_shader_parameter("spec_atlas") != null
	check(nearest, "every part draws with nearest filtering")
	check(lit, "every part is lit through its normal and spec maps")
	var off_grid := []
	for jname in rig.order:
		var pos := Vector2(rig.defs[jname]["pos"][0], rig.defs[jname]["pos"][1])
		for v in [pos.x, pos.y]:
			if absf(fposmod(v + 0.75, 1.5) - 0.75) > 0.011:
				off_grid.append("%s %s" % [jname, str(pos)])
				break
	check(off_grid.is_empty(), "every joint offset is whole art pixels: %s" % str(off_grid))

	# The height: within 5% of the smooth Staffer's, soles on the floor.
	rig.apply_pose({})
	var feet: float = rig._ground_error()
	var head_part: Dictionary = data["parts"]["head"]
	var head_top: float = (rig.joints["head"] as Node2D).position.y + (rig.joints["torso"] as Node2D).position.y \
			+ (rig.joints["pelvis"] as Node2D).position.y - float(head_part["pivot"][1]) / float(data["texture_scale"])
	var height := -head_top
	check(absf(height - OLD_HEIGHT) <= 0.05 * OLD_HEIGHT, "the Staffer stands within 5%% of the old 96.9 world px (%.1f)" % height)
	check(height < 102.0 - 1.0, "the Staffer is shorter than the Night Guard (%.1f vs 102)" % height)
	check(absf(feet) <= 0.75 + 0.05, "the soles stand within half an art pixel of the floor at rest (%.2f)" % feet)

	# The pelvis on whole pixels and joints turning in steps (a limb's tip moves one art pixel).
	rig.apply_pose({"near_forearm": 0.1234, "torso": 0.0711, "root": Vector2(1.1, 0.4)})
	for jname in ["near_forearm", "torso", "lanyard"]:
		var step: float = rig._rot_step[jname]
		check(rad_to_deg(step) >= 1.5 and rad_to_deg(step) <= 5.0, "%s's step is between 1.5 and 5 degrees" % jname)
	var pelvis_pos: Vector2 = (rig.joints["pelvis"] as Node2D).position
	check(absf(fposmod(pelvis_pos.x + 0.75, 1.5) - 0.75) < 0.011 and absf(fposmod(pelvis_pos.y + 0.75, 1.5) - 0.75) < 0.011,
			"the pelvis sits on whole art pixels (%s)" % str(pelvis_pos))

	# Draw order: the sleeve roll on the near upper arm's lower end covers the bare forearm's top; the lanyard
	# hangs over the torso but under the head and the near arm.
	var z := func(n: String) -> int: return (rig.sprites[n] as Sprite2D).z_index
	check(z.call("near_upper_arm") > z.call("near_forearm") and z.call("near_forearm") > z.call("torso"), "the near upper arm's roll covers the bare forearm's top")
	check(z.call("lanyard") > z.call("torso") and z.call("lanyard") <= z.call("head") and z.call("lanyard") < z.call("near_upper_arm"), "the lanyard hangs over the torso, under the near arm")
	check(z.call("port") > z.call("head"), "the port is drawn over the head")
	# The wound marks never pick the port or the lanyard.
	var struck: String = rig.nearest_joint(rig.joint_point("torso", Vector2(1.5, -12.0)))
	check(struck != "lanyard" and struck != "port", "a hit on the chest wounds the body, not the lanyard (%s)" % struck)
	rig.queue_free()

	# The tell: amber then red on the two grip hands, at the rig's grip sockets; the clips keep the lanyard hanging.
	var group := EncounterGroup.new()
	group.is_active = false
	add_child(group)
	var staffer: Brawler = load("res://scenes/actors/staffer.tscn").instantiate()
	staffer.position = Vector2(900.0, FLOOR_Y)
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(-200.0, FLOOR_Y)
	floor_b.size = Vector2(2400.0, 200.0)
	add_child(floor_b)
	group.add_child(staffer)
	await physics_frames(3)
	check(staffer.rig != null and staffer.rig.pixel_art, "the Staffer enemy builds the pixel rig")
	var grip: Vector2 = staffer.rig.sockets["grip_near"]["pos"]
	check(staffer.tuning.tell_offset.distance_to(grip) < 0.2, "the tell light sits on the near palm (%s vs %s)" % [str(staffer.tuning.tell_offset), str(grip)])
	check(staffer.tuning.tell_joint == "near_hand", "the tell is on the near hand")
	check_eq(staffer._hand_glows.size(), 2, "both hands carry a tell glow")
	if staffer._hand_glows.size() == 2:
		check(staffer._hand_glows[0].position.distance_to(staffer.rig.sockets["grip_near"]["pos"]) < 0.01, "the near hand's glow sits at the grip_near socket")
		check(staffer._hand_glows[1].position.distance_to(staffer.rig.sockets["grip_far"]["pos"]) < 0.01, "the far hand's glow sits at the grip_far socket")
	for clip in ["dormant", "shamble", "windup", "lunge", "stumble"]:
		var planted := true
		var hangs := true
		for k in 8:
			var pose: Dictionary = staffer.anim.sample(clip, float(k) * 0.08)
			staffer.rig.apply_pose(pose)
			planted = planted and absf(staffer.rig._ground_error()) < 0.5 * staffer.rig.pixel_world + 0.05
			# The lanyard's world lean stays within 25 degrees of upright in every clip.
			var lean := 0.0
			for n in ["pelvis", "torso", "lanyard"]:
				lean += (staffer.rig.joints[n] as Node2D).rotation
			hangs = hangs and absf(lean) < deg_to_rad(25.0)
		check(planted, "the %s clip keeps the pixel Staffer's feet on the floor" % clip)
		check(hangs, "the %s clip keeps the lanyard hanging (within 25 degrees of upright)" % clip)

	# A defeated Staffer: the ragdoll keeps every body part, the port rides on the head, the lanyard swings free.
	group.is_active = true
	await physics_frames(2)
	var at := staffer.global_position + Vector2(0.0, -60.0)
	var hits := 0
	while is_instance_valid(staffer) and hits < 6:
		staffer.hit_zone.take_hit(1, at, Vector2.RIGHT)
		hits += 1
		await physics_frames(1)
	check(not is_instance_valid(staffer), "the Staffer dies from his two hits (%d)" % hits)
	var found := find_children("Body_*", "", true, false)
	var ragdoll: Node = found[0] if not found.is_empty() else null
	check(ragdoll != null, "the dead Staffer leaves a ragdoll body")
	if ragdoll != null:
		var bodies := {}
		var pins := 0
		for c in ragdoll.get_children():
			if c is RigidBody2D:
				bodies[String(c.name)] = c
			elif c is PinJoint2D:
				pins += 1
		check_eq(bodies.size(), 11, "11 physics bodies (hands, feet, head and port ride on a forearm, shin or the torso)")
		check_eq(pins, 10, "every body but the pelvis is pinned at its joint")
		check(bodies.has("lanyard") and bodies.has("torso") and not bodies.has("port") and not bodies.has("head"), "the lanyard falls on its own; the head and the port ride on the torso")
		if bodies.has("torso"):
			var ports := 0
			for ch in (bodies["torso"] as Node).get_children():
				if ch is Sprite2D:
					ports += 1
			check_eq(ports, 3, "the torso body carries its own sprite plus the head's and the port's")
		await seconds(3.4)
		check(ragdoll.is_settled(), "the Staffer's ragdoll settles within a few seconds")
	Blood.clear()
	await physics_frames(2)
