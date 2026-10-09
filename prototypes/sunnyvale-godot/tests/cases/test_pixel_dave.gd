extends TestCase
## Dave Harlan (H01, the hero) as pixel art (2026-10-07), built from
## concept-art/h01-dave/h01-dave-parts-pixel-v1.webp by
## tools/art/import_parts_sheet.py dave as the Night Guard and the Staffer
## were: a pixel_art rig.json, art pixels enlarged 3x with nearest filtering,
## joints on whole art pixels, about the old Rook frames' height. Dave has no
## neon and nothing emissive (the badge's red band and the wrist light are
## dark paint). The revoked ID badge is painted out of the torso and hangs as
## its own `lanyard` part; the hoodie's hood is a `hood` part behind the neck.
##
## On the hero (scripts/actors/visuals/hero_rig_visual.gd, attached by
## hero.tscn): the hand-keyed clips (clips_dave.gd) follow the hero's state,
## the run cycle follows the stride, AimPivot sits on the rig's near shoulder,
## the near arm is posed every tick so the fist holds the Scrapjack's grip at
## any aim and either facing, the gun is at its own size (scale 1) with its
## muzzle on the aim line, a defeated Dave hides the gun and drops to a knee,
## a respawn stands him straight back up, and without the rig's art the Visual
## falls back to the Rook frames.

const DAVE := "res://assets/characters/lit/dave/"
const VISUAL_SCRIPT := "res://scripts/actors/visuals/hero_rig_visual.gd"
const LIT_SHADER_PATH := "res://assets/shaders/lit_part.gdshader"
const Clips := preload("res://scripts/actors/lit/clips_dave.gd")
const RigScript := preload("res://scripts/actors/lit/cutout_rig.gd")
const BlockScript := preload("res://scripts/world/block.gd")
## The brief's height (about 62 art px) and the Rook idle frame's.
const BRIEF_HEIGHT := 94.0
const ROOK_IDLE := "res://assets/characters/rook/rook_idle_1.png"
const SHEET_SKIN := Color8(0xD8, 0xA0, 0x78)
const BRIEF_SKIN := Color8(0xE1, 0xB5, 0x96)
const CARD_PALE := Color8(0xC0, 0xC8, 0xD0)
const BADGE_RED := Color8(0x99, 0x27, 0x2F)
const HUMAN_JOINTS := ["pelvis", "torso", "head", "far_upper_arm", "far_forearm", "far_hand", "far_thigh",
		"far_shin", "far_foot", "near_thigh", "near_shin", "near_foot", "near_upper_arm", "near_forearm", "near_hand"]
const STATES := ["idle", "run", "jump_rise", "jump_fall", "land", "hurt", "interact", "defeated"]
const FLOOR_Y := 560.0
## One art pixel: the fist may sit this far from the grip (its joints turn in rotation steps).
const GRIP_TOLERANCE := 1.5


func _rig_json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


func _joint_pos(data: Dictionary, jname: String) -> Vector2:
	var by_name := {}
	for j in data["joints"]:
		by_name[j["name"]] = j
	var p := Vector2.ZERO
	var cur: String = jname
	while cur != "":
		p += Vector2(by_name[cur]["pos"][0], by_name[cur]["pos"][1])
		cur = by_name[cur]["parent"]
	return p


func _near(a: Color, b: Color, tol: float) -> bool:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) <= tol


func run() -> void:
	_test_rig_file()
	_test_clips()
	await _test_on_the_hero()
	await _test_states()
	await _test_aim_holds_the_grip()
	await _test_backpedal_runs_the_cycle_backward()
	await _test_defeated_and_respawn()
	await _test_fallback()


func _test_rig_file() -> void:
	var data := _rig_json(DAVE + "rig.json")
	check_eq(data.get("pixel_art", false), true, "Dave's rig.json is flagged pixel_art")
	check_eq(float(data.get("pixel_world", 0.0)), 1.5, "one art pixel is 1.5 world px")
	check_eq(float(data["texture_scale"]), 2.0, "texture_scale 2: three atlas texels per art pixel")
	check_eq(data["kind"], "human", "a human rig")
	check_eq(data["ground_lock"], true, "his soles are kept on the floor")
	check(String(data["source"]).ends_with("h01-dave-parts-pixel-v1.webp"), "its source is Dave's pixel parts sheet")
	var up := int(round(float(data["texture_scale"]) * float(data["pixel_world"])))

	var albedo: Image = (load(DAVE + "albedo.png") as Texture2D).get_image()
	var normal: Image = (load(DAVE + "normal.png") as Texture2D).get_image()
	var spec: Image = (load(DAVE + "spec.png") as Texture2D).get_image()
	check(albedo != null and normal != null and spec != null, "the albedo, normal and spec atlases load")
	check(albedo.get_size() == normal.get_size() and albedo.get_size() == spec.get_size(), "the three atlases share one layout")
	for pname in ["head", "hood", "torso", "pelvis", "upper_arm", "forearm", "hand_grip", "hand_open", "thigh", "shin", "foot", "lanyard"]:
		check(data["parts"].has(pname), "the atlas has the sheet's %s" % pname)
	check_eq((data["parts"] as Dictionary).size(), 12, "the sheet's 12 parts")

	# The pixel grid; and nothing glows (no neon, the badge band and the wrist light are paint).
	var bad_blocks := 0
	var bad_pivot := 0
	var glowing := 0
	var colours := {}     # part -> Array of opaque art-pixel colours
	for pname in data["parts"]:
		var p: Dictionary = data["parts"][pname]
		var r: Array = p["rect"]
		if int(r[2]) % up != 0 or int(r[3]) % up != 0:
			bad_blocks += 1
			continue
		if fposmod(float(p["pivot"][0]), up) != 0.0 or fposmod(float(p["pivot"][1]), up) != 0.0:
			bad_pivot += 1
		colours[pname] = []
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
				colours[pname].append(c0)
				if spec.get_pixel(x0 + 1, y0 + 1).b > 0.05:
					glowing += 1
	check_eq(bad_blocks, 0, "every part is made of whole art pixels (%dx%d texel blocks of one colour)" % [up, up])
	check_eq(bad_pivot, 0, "every pivot sits on a pixel corner")
	check_eq(glowing, 0, "nothing on Dave is emissive (no neon; the badge band and the wrist light stay dark)")

	# Joint offsets on whole art pixels.
	var off_grid := []
	for j in data["joints"]:
		for v in [float(j["pos"][0]), float(j["pos"][1])]:
			if absf(fposmod(v + 0.75, 1.5) - 0.75) > 0.011:
				off_grid.append("%s %s" % [j["name"], str(j["pos"])])
				break
	check(off_grid.is_empty(), "every joint offset is whole art pixels: %s" % str(off_grid))

	# The joints: the human rig's 15 plus the hood and the lanyard, both on the torso; no baton.
	var names := {}
	var parent := {}
	for j in data["joints"]:
		names[j["name"]] = j["part"]
		parent[j["name"]] = j["parent"]
	for jname in HUMAN_JOINTS:
		check(names.has(jname), "the rig has the %s joint" % jname)
	check(names.has("hood") and parent.get("hood", "") == "torso", "the hood hangs on the torso")
	check(names.has("lanyard") and parent.get("lanyard", "") == "torso", "the lanyard hangs on the torso")
	check(not names.has("baton"), "no baton")
	check_eq(names.get("near_hand", ""), "hand_grip", "the gun hand is the gripping hand")
	check_eq(names.get("far_hand", ""), "hand_open", "the free hand is the open hand")
	check_eq((data["joints"] as Array).size(), 17, "17 joints")

	# Height: crown to soles, at rest, within 5% of the brief's 94 world px and of the Rook idle frame.
	var head_part: Dictionary = data["parts"]["head"]
	var crown := _joint_pos(data, "head").y - float(head_part["pivot"][1]) / float(data["texture_scale"])
	var sole := -INF
	for sp in data["sole_points"]:
		sole = maxf(sole, _joint_pos(data, "near_foot").y + float(sp[1]))
	var height := sole - crown
	var rook: Image = (load(ROOK_IDLE) as Texture2D).get_image()
	var top := rook.get_height()
	var bottom := 0
	for y in rook.get_height():
		for x in range(0, rook.get_width(), 2):
			if rook.get_pixel(x, y).a > 0.5:
				top = mini(top, y)
				bottom = maxi(bottom, y)
	var rook_height := float(bottom - top + 1) * 0.5
	check(absf(height - BRIEF_HEIGHT) <= BRIEF_HEIGHT * 0.05, "Dave stands %.1f world px (%.1f art px), within 5%% of the brief's %.0f" % [height, height / 1.5, BRIEF_HEIGHT])
	check(absf(height - rook_height) <= rook_height * 0.05, "and within 5%% of the Rook idle frame's %.1f" % rook_height)
	check(absf(sole) <= 0.76, "his lowest sole is on the floor at rest (within half an art pixel: %.2f)" % sole)

	# Skin: retinted from the sheet's tan toward the brief's fair #E1B596; the head's most common
	# warm, light colour is the skin.
	var count := {}
	for c in colours["head"]:
		if c.r > c.b + 0.12 and c.v > 0.5:
			count[c] = int(count.get(c, 0)) + 1
	var skin := Color.BLACK
	var best := 0
	for c in count:
		if count[c] > best:
			best = count[c]
			skin = c
	check(_near(skin, BRIEF_SKIN, 0.12), "the face is about the brief's fair skin #E1B596 (%s)" % skin.to_html(false))
	check(skin.g > SHEET_SKIN.g and skin.b > SHEET_SKIN.b, "lighter than the sheet's tan #D8A078 (%s)" % skin.to_html(false))
	var orange := 0
	for c in colours["torso"]:
		if c.r > 0.55 and c.g < 0.4 and c.b < 0.25:
			orange += 1
	check(orange > 80, "the jacket stays burnt orange (%d art pixels)" % orange)

	# The badge: painted out of the torso (no pale card, no red band on its chest), hanging on the
	# lanyard instead.
	var torso_card := 0
	var torso_red := 0
	for c in colours["torso"]:
		if _near(c, CARD_PALE, 0.06):
			torso_card += 1
		if _near(c, BADGE_RED, 0.06):
			torso_red += 1
	check(torso_card <= 2, "no ID card is painted on the torso (%d pale art pixels: the lanyard cord at the neck at most)" % torso_card)
	check_eq(torso_red, 0, "and no red REVOKED band")
	var card := 0
	var red := 0
	for c in colours["lanyard"]:
		if _near(c, CARD_PALE, 0.06):
			card += 1
		if _near(c, BADGE_RED, 0.06):
			red += 1
	check(card >= 2 and red >= 1, "the badge hangs on the lanyard: a pale card (%d) with a red band (%d)" % [card, red])

	# Sockets: the fist's grip, the wrist light, and the five places a hit bleeds from.
	var sockets: Dictionary = data["sockets"]
	check(sockets.has("grip") and sockets["grip"]["joint"] == "near_hand", "the grip socket is on the near (gun) hand")
	check(sockets.has("wrist_light") and sockets["wrist_light"]["joint"] == "near_forearm", "the wrist light socket is on the near forearm's cuff")
	var want := {"blood_head": "head", "blood_chest": "torso", "blood_belly": "torso", "blood_arm": "near_upper_arm", "blood_thigh": "near_thigh"}
	for sname in want:
		check(sockets.has(sname) and sockets[sname]["joint"] == want[sname], "%s is on the %s" % [sname, want[sname]])
	if sockets.has("blood_chest") and sockets.has("blood_belly"):
		check(float(sockets["blood_chest"]["pos"][1]) < float(sockets["blood_belly"]["pos"][1]), "the chest is above the belly")


func _test_clips() -> void:
	var data := _rig_json(DAVE + "rig.json")
	var joints := {"root": true}
	for j in data["joints"]:
		joints[j["name"]] = true
	for state in STATES:
		check(Clips.CLIPS.has(state), "clips_dave.gd keys a %s clip" % state)
	var unknown := []
	for cname in Clips.CLIPS:
		for key in Clips.CLIPS[cname]["keys"]:
			for jname in key[1]:
				if not joints.has(jname) and not unknown.has(jname):
					unknown.append(jname)
	check(unknown.is_empty(), "every keyed joint is one of the rig's: %s" % str(unknown))
	check(Clips.CLIPS["idle"]["loop"] and Clips.CLIPS["run"]["loop"], "idle and run loop")
	check(is_equal_approx(float(Clips.CLIPS["idle"]["keys"][1][0]), 0.7), "idle's second breathing beat comes after 0.7 s (the Rook frames' IDLE_BREATH_TIME)")
	check_eq((Clips.CLIPS["run"]["keys"] as Array).size(), 7, "the run cycle has six keys (and the first again to close the loop)")
	check(is_equal_approx(float(Clips.CLIPS["land"]["length"]), 0.12), "the landing squash lasts LAND_SQUASH_TIME")
	check(is_equal_approx(float(Clips.CLIPS["hurt"]["length"]), 0.2), "the flinch lasts HIT_POSE_TIME")
	check(is_equal_approx(float(Clips.CLIPS["interact"]["length"]), 0.35), "the reach lasts INTERACT_POSE_TIME")


func _make_hero(x: float = 600.0) -> Hero:
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(-1000, FLOOR_Y)
	floor_b.size = Vector2(4000, 200)
	add_child(floor_b)
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = Vector2(x, FLOOR_Y - 1.0)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(400, -60)
	hero.set_meta("floor", floor_b)
	return hero


func _free(hero: Hero) -> void:
	var floor_b: Node = hero.get_meta("floor")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


func _test_on_the_hero() -> void:
	Session.new_run()
	var hero := _make_hero()
	await seconds(0.4)      # past the landing squash of the spawn drop
	var visual = hero.visual
	check_eq(String(visual.get_script().resource_path), VISUAL_SCRIPT, "hero.tscn's Visual is the rig visual")
	check(visual.rig != null and visual.rig.pixel_art, "the Visual builds Dave's pixel-art rig")
	if visual.rig == null:
		await _free(hero)
		return
	var rig: Node2D = visual.rig
	var nearest := true
	var lit := true
	var masks := true
	for jname in rig.order:
		var s: Sprite2D = rig.sprites[jname]
		nearest = nearest and s.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST
		var m := s.material as ShaderMaterial
		lit = lit and m != null and m.shader.resource_path == LIT_SHADER_PATH
		masks = masks and s.light_mask == 3
	check(nearest, "every part sprite uses nearest filtering")
	check(lit, "every part uses the shared lit-part shader")
	check(masks, "every part is on light masks 1 | 2 (world lights and the moon rim)")
	var mat: ShaderMaterial = rig.body_material
	var ambient: Vector3 = mat.get_shader_parameter("ambient")
	check(ambient.x > 0.35 and ambient.x < 0.55, "the characters' night ambient (about 0.45)")
	check(float(mat.get_shader_parameter("wrap")) > 0.0, "his light wraps a little round an edge")
	check(mat.get_shader_parameter("spec_atlas") != null and mat.get_shader_parameter("normal_atlas") != null, "a normal and a spec map")
	check(hero.get_node_or_null("AimPivot/Arm") == null, "no separate Rook arm sprite: the rig's own arm holds the gun")

	# The gun keeps its own pixel size, its grip in the fist and its muzzle on the aim line.
	var gun: Scrapjack = hero.get_node("AimPivot/Scrapjack")
	check(gun.scale.is_equal_approx(Vector2.ONE), "the Scrapjack is at scale 1, so its art pixels stay 1.5 world px (%s)" % str(gun.scale))
	check(gun.rig != null and gun.rig.scale.is_equal_approx(Vector2.ONE), "and its rig too")
	var shoulder: Vector2 = hero.aim_pivot.global_position
	var fwd: Vector2 = hero.aim_pivot.global_transform.x.normalized()
	var muzzle: Vector2 = gun.get_muzzle_global_position()
	var off_line := absf((muzzle - shoulder).cross(fwd))
	check(off_line <= 2.0, "the muzzle is within 2 px of the aim line through the shoulder (%.2f)" % off_line)
	check((muzzle - shoulder).dot(fwd) > (visual.grip_global() - shoulder).dot(fwd) + 20.0, "and well ahead of the fist")
	check(visual.grip_error() <= GRIP_TOLERANCE, "the fist holds the grip (%.2f px off)" % visual.grip_error())

	# Draw order: the gun between the near upper arm and the near forearm and fist, all of Dave
	# below the combat effects (z 20).
	var z := {}
	for jname in rig.order:
		z[jname] = (rig.sprites[jname] as Sprite2D).z_index
	var gun_lo := 99
	var gun_hi := -99
	for jname in gun.rig.order:
		var gz: int = gun.rig.z_index + (gun.rig.sprites[jname] as Sprite2D).z_index
		gun_lo = mini(gun_lo, gz)
		gun_hi = maxi(gun_hi, gz)
	check(gun_lo > int(z["near_upper_arm"]) and gun_lo > int(z["torso"]) and gun_lo > int(z["head"]), "the gun is drawn over the body and the upper arm (gun %d..%d)" % [gun_lo, gun_hi])
	check(gun_hi < int(z["near_hand"]) and gun_hi < int(z["near_forearm"]), "and under the forearm and the fist that wraps its grip")
	var top := -99
	for jname in z:
		top = maxi(top, int(z[jname]))
	check(top < 20 and gun_hi < 20, "Dave and his gun stay under the combat effects (z 20)")
	check(visual.process_physics_priority > hero.process_physics_priority, "the arm is posed after hero.gd has turned the aim pivot")

	# AimPivot sits on the rig's near shoulder, standing and running; the wrist light rides on the cuff.
	check(hero.aim_pivot.position.distance_to(visual.shoulder_offset()) < 0.01, "AimPivot sits on the rig's near shoulder")
	var s_rig: Vector2 = rig._to_rig(rig.joints["torso"]) * (rig.joints["near_upper_arm"] as Node2D).position
	check(absf(s_rig.y + 72.0) < 6.0, "the shoulder is about where the Rook frames' was (%.1f px up, Rook 75.4)" % -s_rig.y)
	press(&"move_right")
	var attached := true
	var gripped := true
	var worst := 0.0
	for i in 40:
		await physics_frames(1)
		hero.aim_override = hero.global_position + Vector2(400, -60)
		if hero.aim_pivot.position.distance_to(visual.shoulder_offset()) > 0.5:
			attached = false
		worst = maxf(worst, visual.grip_error())
	release(&"move_right")
	gripped = worst <= GRIP_TOLERANCE
	check(attached, "AimPivot stays on the shoulder through the run cycle")
	check(gripped, "the fist stays on the grip through the run cycle (worst %.2f px)" % worst)
	var wl: Node2D = hero.get_node("AimPivot/WristLight")
	var ws: Dictionary = rig.sockets["wrist_light"]
	check(wl.global_position.distance_to(rig.joint_point(ws["joint"], ws["pos"])) < 0.01, "the wrist light rides on the forearm's cuff")
	check_eq((wl as PointLight2D).texture, SceneryDraw.smooth_disc_texture(), "with the world lights' smooth falloff")

	# Blood: a hit bleeds from the rig's nearest blood socket.
	var head_sock: Dictionary = rig.sockets["blood_head"]
	var thigh_sock: Dictionary = rig.sockets["blood_thigh"]
	var head_pt: Vector2 = rig.joint_point(head_sock["joint"], head_sock["pos"])
	var thigh_pt: Vector2 = rig.joint_point(thigh_sock["joint"], thigh_sock["pos"])
	check(visual.blood_point(head_pt + Vector2(30, -20)).is_equal_approx(head_pt), "a shot at his head bleeds from the head")
	check(visual.blood_point(thigh_pt + Vector2(30, 4)).is_equal_approx(thigh_pt), "a shot at his legs bleeds from the thigh")
	check(head_pt.y < hero.global_position.y - 75.0 and thigh_pt.y > hero.global_position.y - 45.0, "the head socket is high on him, the thigh's low")
	await _free(hero)


## update_pose() switches the clip on the same inputs (and in the same priority) the Rook
## frames did; the run cycle is set by the stride phase.
func _test_states() -> void:
	Session.new_run()
	var hero := _make_hero()
	await physics_frames(3)
	var visual = hero.visual
	hero.set_physics_process(false)      # only these update_pose calls drive the visual
	var cases := [
		["idle", [1, false, true, 0.0, 0.0, false, false, false, 0.0, 0.0, 0.0]],
		["run", [1, true, true, 0.0, 1.0, false, false, false, 0.0, 0.0, 0.0]],
		["jump_rise", [1, false, false, -300.0, 0.0, false, false, false, 0.0, 0.0, 0.0]],
		["jump_fall", [1, false, false, 120.0, 0.0, false, false, false, 0.0, 0.0, 0.0]],
		["jump_fall", [1, true, false, -10.0, 0.0, false, false, false, 0.0, 0.0, 0.0]],
		["land", [1, false, true, 0.0, 0.0, false, false, false, 0.1, 0.0, 0.0]],
		["land", [1, true, true, 0.0, 0.0, false, false, false, 0.1, 0.0, 0.0]],
		["hurt", [1, true, false, -200.0, 0.0, false, true, false, 0.1, 0.15, 0.0]],
		["interact", [1, false, true, 0.0, 0.0, false, false, false, 0.0, 0.0, 0.3]],
		["hurt", [1, false, true, 0.0, 0.0, false, true, false, 0.0, 0.15, 0.3]],
		["defeated", [1, false, true, 0.0, 0.0, false, true, true, 0.1, 0.15, 0.3]],
		["idle", [-1, false, true, 0.0, 0.0, false, false, false, 0.0, 0.0, 0.0]],
	]
	for c in cases:
		var a: Array = c[1]
		visual.update_pose(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10])
		check_eq(String(visual.current_frame()), c[0], "update_pose%s plays %s" % [str(a), c[0]])
		check_eq(visual.anim.clip, c[0], "and the animator plays the %s clip" % c[0])
	check(visual.rig.facing == -1 and visual.rig.scale.x < 0.0, "facing left mirrors the rig")
	var sx_left: float = visual.shoulder_offset().x
	visual.update_pose(1, false, true, 0.0, 0.0, false, false, false, 0.0, 0.0, 0.0)
	check(absf(visual.shoulder_offset().x + sx_left) < 0.01, "and mirrors the shoulder (%.2f vs %.2f)" % [sx_left, visual.shoulder_offset().x])
	# The run clip's time is the stride phase's share of a cycle.
	for k in 6:
		var phase := TAU * (float(k) + 0.25) / 6.0
		visual.update_pose(1, true, true, 0.0, phase, false, false, false, 0.0, 0.0, 0.0)
		check(absf(visual.anim.time - (float(k) + 0.25) / 6.0) < 0.001, "stride phase %.2f sets the run cycle to %.3f" % [phase, visual.anim.time])
	# Each state shows a different pose (the legs and the free arm), not just a clip name.
	var poses := {}
	for c in [["idle", [1, false, true, 0.0, 0.0, false, false, false, 0.0, 0.0, 0.0]],
			["jump_rise", [1, false, false, -300.0, 0.0, false, false, false, 0.0, 0.0, 0.0]],
			["land", [1, false, true, 0.0, 0.0, false, false, false, 0.1, 0.0, 0.0]],
			["interact", [1, false, true, 0.0, 0.0, false, false, false, 0.0, 0.0, 0.3]]]:
		var a: Array = c[1]
		for i in 30:
			visual.update_pose(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10])
		var sig := ""
		for jname in ["near_thigh", "near_shin", "far_upper_arm", "torso"]:
			sig += "%.2f," % (visual.rig.joints[jname] as Node2D).rotation
		poses[sig] = c[0]
	check_eq(poses.size(), 4, "idle, rising, landing and reaching are four different poses")
	hero.set_physics_process(true)
	await _free(hero)


## The near arm holds the gun at any aim, facing either way, even aimed behind him
## (the old arm and gun turned independently of the body).
func _test_aim_holds_the_grip() -> void:
	Session.new_run()
	var hero := _make_hero()
	await physics_frames(3)
	var visual = hero.visual
	var gun: Node2D = hero.get_node("AimPivot/Scrapjack")
	hero.set_physics_process(false)
	var worst := 0.0
	var worst_case := ""
	var aligned := true
	for face in [1, -1]:
		for k in 8:
			var a := deg_to_rad(45.0 * k)
			for flip in [1.0, -1.0]:
				visual.update_pose(face, false, true, 0.0, 0.0, false, false, false, 0.0, 0.0, 0.0)
				hero.aim_pivot.position = visual.shoulder_offset()
				hero.aim_pivot.rotation = a
				hero.aim_pivot.scale.y = flip
				visual.aim_arm()
				var err: float = visual.grip_error()
				if err > worst:
					worst = err
					worst_case = "facing %d, aim %d deg, gun %s" % [face, 45 * k, "upright" if flip > 0 else "flipped"]
				var hand: Node2D = visual.rig.joints["near_hand"]
				if hand.global_transform.y.normalized().dot(gun.global_transform.x.normalized()) < 0.95:
					aligned = false
	check(worst <= GRIP_TOLERANCE, "the fist stays within an art pixel of the grip in 8 directions, both facings, the gun either way up (worst %.2f px: %s)" % [worst, worst_case])
	check(aligned, "and the hand lines up with the gun (its fingers along the barrel)")
	# The arm is posed in the rig's rotation steps (a pixel rig).
	var stepped := true
	for jname in ["near_upper_arm", "near_forearm", "near_hand"]:
		var r: float = (visual.rig.joints[jname] as Node2D).rotation
		stepped = stepped and is_equal_approx(r, visual.rig.snap_rotation(jname, r))
	check(stepped, "the aiming arm turns in the rig's rotation steps")
	hero.set_physics_process(true)
	hero.aim_pivot.scale.y = 1.0

	# Live: the hero turns the pivot to the aim, the gun follows continuously, the fist follows the gun.
	var live_worst := 0.0
	for k in 8:
		var a := deg_to_rad(45.0 * k + 10.0)
		hero.aim_override = hero.aim_pivot.global_position + Vector2(cos(a), sin(a)) * 300.0
		await physics_frames(4)
		live_worst = maxf(live_worst, visual.grip_error())
	check(live_worst <= GRIP_TOLERANCE, "aiming round a full turn in play, the fist holds the grip (worst %.2f px)" % live_worst)
	# Firing: the gun kicks back and the fist goes with it.
	hero.aim_override = hero.global_position + Vector2(400, -60)
	await physics_frames(4)
	(gun as Scrapjack)._try_fire()
	var kick_worst := 0.0
	for i in 6:
		await physics_frames(1)
		kick_worst = maxf(kick_worst, visual.grip_error())
	check(kick_worst <= GRIP_TOLERANCE, "through the recoil the fist stays on the grip (worst %.2f px)" % kick_worst)
	await _free(hero)


## hero.gd's backpedal (firing at an aim behind him while running away): he faces the aim and
## the run cycle plays backward.
func _test_backpedal_runs_the_cycle_backward() -> void:
	Session.new_run()
	var hero := _make_hero(900.0)
	await physics_frames(3)
	var visual = hero.visual
	press(&"move_right")
	press(&"fire")
	var times: Array[float] = []
	for i in 40:
		hero.aim_override = hero.global_position + Vector2(-300, -60)
		await physics_frames(1)
		if String(visual.current_frame()) == "run":
			times.append(visual.anim.time)
	release(&"fire")
	release(&"move_right")
	check(hero.facing == -1, "firing behind him turns him to the aim")
	var back := 0
	var fwd := 0
	for i in range(1, times.size()):
		var d := wrapf(times[i] - times[i - 1], -0.5, 0.5)
		if d < -0.001:
			back += 1
		elif d > 0.001:
			fwd += 1
	check(back > fwd and back >= 10, "backpedalling runs the cycle backward (%d back, %d forward)" % [back, fwd])
	await _free(hero)


func _test_defeated_and_respawn() -> void:
	Session.new_run()
	var hero := _make_hero()
	await physics_frames(4)
	var visual = hero.visual
	var gun: CanvasItem = hero.get_node("AimPivot/Scrapjack")
	check(gun.visible, "the gun shows while he is alive")
	Session.apply_damage(Session.get_health())
	await physics_frames(3)
	check_eq(String(visual.current_frame()), "defeated", "zero health plays the defeated clip")
	check(not gun.visible, "the gun is hidden when he is down")
	await seconds(0.8)
	var upper: float = (visual.rig.joints["near_upper_arm"] as Node2D).rotation
	var want: float = visual.rig.snap_rotation("near_upper_arm", deg_to_rad(float(Clips.KNEEL["near_upper_arm"])))
	check(absf(upper - want) < 0.001, "the gun arm hangs with the clip, no longer aimed (%.1f vs %.1f deg)" % [rad_to_deg(upper), rad_to_deg(want)])
	var head_y: float = visual.rig.joint_point("head", Vector2.ZERO).y
	check(head_y > hero.global_position.y - 60.0, "he is down on one knee (head %.0f px up)" % (hero.global_position.y - head_y))
	# A respawn stands him straight up: no blend out of the kneel, the gun back in his fist.
	Session.restore_committed()
	hero.respawn_at(Vector2(700, FLOOR_Y - 1.0))
	await physics_frames(2)
	check_eq(String(visual.current_frame()), "idle", "after a respawn he is back on his feet")
	check(gun.visible, "and holding the gun again")
	check(visual.rig.joint_point("head", Vector2.ZERO).y < hero.global_position.y - 70.0, "standing at once (no kneel to blend out of)")
	await physics_frames(2)
	check(visual.grip_error() <= GRIP_TOLERANCE, "the fist is back on the grip (%.2f px)" % visual.grip_error())
	await _free(hero)


## Without the rig's art (an export without assets/characters/lit/dave), the Visual falls back to
## the Rook frames: the body sprite, the separate arm on AimPivot, the gun in that arm's fist.
func _test_fallback() -> void:
	Session.new_run()
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(-1000, FLOOR_Y)
	floor_b.size = Vector2(4000, 200)
	add_child(floor_b)
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	hero.get_node("Visual").rig_path = DAVE + "__missing__.json"
	add_child(hero)
	hero.global_position = Vector2(600, FLOOR_Y - 1.0)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(400, -60)
	await seconds(0.4)
	var visual = hero.visual
	check(visual.rig == null, "with no rig.json the Visual builds no rig")
	check(visual.get_node_or_null("Body") is Sprite2D, "it draws the Rook body frame")
	check(hero.get_node_or_null("AimPivot/Arm") is Sprite2D, "and the Rook arm on AimPivot")
	var frame := String(visual.current_frame())
	check(frame == "idle_1" or frame == "idle_2", "standing still shows a Rook idle frame (%s)" % frame)
	check(hero.aim_pivot.position.distance_to(visual.shoulder_offset()) < 0.01, "AimPivot sits on the frame's shoulder")
	var gun: Node2D = hero.get_node("AimPivot/Scrapjack")
	check(gun.position.is_equal_approx(visual.FALLBACK_GUN_POSITION), "the gun's grip is placed in the Rook arm's fist")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
