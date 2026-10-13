extends TestCase
## The hand-painted HD characters (C56): Dave, the Scrapjack and the Night Guard's three looks,
## imported from the painted parts sheets by tools/art/import_parts_sheet.py (dave_hd,
## scrapjack_hd, night_guard_hd_a/b/c). They replace the pixel-art rigs of the pixel prototype
## (whose test_pixel_dave, test_pixel_chars and test_pixel_scrapjack this case stands in for).
## Contracts under test:
##   1. Each rig.json is smooth (no pixel_art), from its HD sheet, with the joints the clips
##      pose and the sockets the game reads.
##   2. Dave's Visual builds the rig with smooth filtering; he stands about 96 px tall; at every
##      aim step, facing either way, his fist holds the Scrapjack's grip; he stands about 96 px tall; his head bleeds high and
##      his thigh low.
##   3. The three guard looks share one skeleton (the same joints and parts), each guard picks
##      one by its entity id (the same id the same look), every look is used, the tell light rides
##      on the drawn baton tip and the baton tip glows (spec emissive).
##   5. Batch 2: the Staffer's three looks and the Patrol Rover's two liveries share one skeleton
##      each, every look is used, and they keep the joints and sockets their scripts read (the
##      Staffer's port and grips, the Rover's wheels, lightbar tell, battery and hatch).
##   4. The Scrapjack's muzzle is about 30 px ahead of the grip, as the pixel gun's (point-blank
##      shots on a stalled rover depend on where the muzzle and the shoulder are).

const HERO := "res://scenes/actors/hero.tscn"
const GUARD := "res://scenes/actors/night_guard.tscn"
const BlockScript := preload("res://scripts/world/block.gd")
const LIT := "res://assets/characters/lit/"
const LOOKS := ["night_guard_hd_a", "night_guard_hd_b", "night_guard_hd_c"]


func _rig(name: String) -> Dictionary:
	var d = JSON.parse_string(FileAccess.get_file_as_string(LIT + name + "/rig.json"))
	return d if typeof(d) == TYPE_DICTIONARY else {}


func run() -> void:
	_rig_files()
	await _dave()
	await _guards()
	await _staffers_and_rovers()


func _rig_files() -> void:
	var dave := _rig("dave")
	check(not dave.is_empty(), "Dave's rig.json loads")
	check(not dave.get("pixel_art", false), "Dave's rig is smooth (hand-painted), not pixel art")
	check(String(dave.get("source", "")).ends_with("h01-dave-parts-hd-v3.webp"), "from his HD parts sheet (v3, C58)")
	var names := []
	for j in dave.get("joints", []):
		names.append(j["name"])
	for jn in ["pelvis", "torso", "head", "near_upper_arm", "near_forearm", "near_hand", "far_upper_arm",
			"near_thigh", "near_shin", "near_foot", "hood", "lanyard"]:
		check(jn in names, "Dave has the %s joint" % jn)
	for sn in ["grip", "wrist_light", "blood_head", "blood_chest", "blood_belly", "blood_arm", "blood_thigh"]:
		check(dave.get("sockets", {}).has(sn), "Dave's rig marks the %s socket" % sn)
	var gun := _rig("scrapjack")
	check(not gun.get("pixel_art", false) and String(gun.get("source", "")).ends_with("w01-scrapjack-parts-hd-v1.webp"),
			"the Scrapjack is the smooth HD rig")
	var j := {}
	for jj in gun.get("joints", []):
		j[jj["name"]] = jj
	check(j.has("barrel") and j.has("battery") and j.has("upper"), "the gun has the parts scrapjack.gd moves and lights")
	var muzzle: Vector2 = Vector2(j["barrel"]["pos"][0], j["barrel"]["pos"][1]) + Vector2(gun["sockets"]["muzzle"]["pos"][0], gun["sockets"]["muzzle"]["pos"][1])
	check(muzzle.length() > 27.0 and muzzle.length() < 33.0, "the muzzle is about 30 px ahead of the grip, as the pixel gun's (%.1f)" % muzzle.length())
	var first := _rig(LOOKS[0])
	for look in LOOKS:
		var d := _rig(look)
		check(not d.is_empty() and not d.get("pixel_art", false), "%s: a smooth rig" % look)
		var a := []
		var b := []
		for jj in d.get("joints", []):
			a.append([jj["name"], jj["part"], jj["parent"]])
		for jj in first.get("joints", []):
			b.append([jj["name"], jj["part"], jj["parent"]])
		check(a == b, "%s: the same skeleton as the first look" % look)
		check(d.get("sockets", {}).has("tell"), "%s: the baton's tell socket" % look)
		var spec: Image = load(LIT + look + "/spec.png").get_image()
		var rect: Array = d["parts"]["baton"]["rect"]
		var lit := 0
		for y in range(int(rect[1]), int(rect[1]) + int(rect[3]), 2):
			for x in range(int(rect[0]), int(rect[0]) + int(rect[2]), 2):
				if spec.get_pixel(x, y).b > 0.8:
					lit += 1
		check(lit > 4, "%s: the baton's tip glows (emissive texels %d)" % [look, lit])


func _dave() -> void:
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.size = Vector2(3000, 64)
	floor_b.position = Vector2(-500, 0)
	add_child(floor_b)
	var hero: Hero = load(HERO).instantiate()
	add_child(hero)
	hero.global_position = Vector2(800, -1)
	hero.use_aim_override = true
	await physics_frames(4)
	var visual = hero.get_node("Visual")
	check(visual.rig != null and not visual.rig.pixel_art, "the Visual builds Dave's hand-painted rig")
	if visual.rig == null:
		hero.queue_free()
		floor_b.queue_free()
		return
	var smooth := true
	for s in visual.rig.sprites.values():
		smooth = smooth and (s as Sprite2D).texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST
	check(smooth, "every part draws smooth")
	# Standing height in the rest pose (the clips bend him a little): the crown above the soles.
	var data := _rig("dave")
	var jy := {}
	for jj in data["joints"]:
		jy[jj["name"]] = float(jj["pos"][1])
	var head_part: Dictionary = data["parts"]["head"]
	var crown: float = jy["pelvis"] + jy["torso"] + jy["head"] - float(head_part["pivot"][1]) / float(data["texture_scale"])
	check(-crown > 90.0 and -crown < 102.0, "he stands about 96 px tall, the pixel Dave's height (his shoulder is the aim pivot) (%.1f)" % -crown)
	for facing in [1, -1]:
		for step in range(-4, 5):
			var a := float(step) * Hero.AIM_STEP
			var dir := Vector2(cos(a) * facing, sin(a))
			if absf(dir.x) < 0.01:
				dir.x = 0.01 * facing
			hero.aim_override = hero.aim_pivot.global_position + Vector2(400.0 * facing, 0.0)
			await physics_frames(2)
			hero.aim_override = hero.aim_pivot.global_position + dir * 400.0
			await physics_frames(3)
			check(visual.grip_error() <= 2.5, "facing %d, step %d: the fist holds the grip (%.2f px)" % [facing, step, visual.grip_error()])
	var head_pt: Vector2 = visual.rig.joint_point("head", Vector2(visual.rig.sockets["blood_head"]["pos"][0], visual.rig.sockets["blood_head"]["pos"][1]))
	var thigh_pt: Vector2 = visual.rig.joint_point("near_thigh", Vector2(visual.rig.sockets["blood_thigh"]["pos"][0], visual.rig.sockets["blood_thigh"]["pos"][1]))
	check(head_pt.y < hero.global_position.y - 75.0 and thigh_pt.y > hero.global_position.y - 55.0,
			"the head bleeds high, the thigh low (%.0f, %.0f)" % [head_pt.y - hero.global_position.y, thigh_pt.y - hero.global_position.y])
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _guards() -> void:
	var seen := {}
	var guards := []
	for n in 12:
		var g: Brawler = load(GUARD).instantiate()
		g.entity_id = "HDTEST_%d" % n
		add_child(g)
		g.global_position = Vector2(-4000 - n * 300, -1)
		guards.append(g)
	await physics_frames(2)
	for g in guards:
		var path: String = g.rig_path_for_look()
		seen[path] = true
		check(g.rig != null and g.rig.rig_path == path, "%s draws the look its id picks" % g.entity_id)
		check_eq(g.rig_path_for_look(), path, "%s: the same id, the same look" % g.entity_id)
		if g.rig != null:
			var tip: Vector2 = g.rig.sockets["tell"]["pos"]
			check(g._tell_light.position.is_equal_approx(tip), "%s: the tell light is on the drawn baton tip" % g.entity_id)
	check_eq(seen.size(), 3, "all three guard looks are used")
	for g in guards:
		g.queue_free()


func _same_skeleton(looks: Array) -> bool:
	var first := []
	for jj in _rig(looks[0]).get("joints", []):
		first.append([jj["name"], jj["part"], jj["parent"]])
	for look in looks:
		var a := []
		for jj in _rig(look).get("joints", []):
			a.append([jj["name"], jj["part"], jj["parent"]])
		if a != first:
			return false
	return true


func _staffers_and_rovers() -> void:
	var staffers := ["staffer_hd_a", "staffer_hd_b", "staffer_hd_c"]
	var rovers := ["patrol_rover_hd_a", "patrol_rover_hd_b"]
	check(_same_skeleton(staffers), "the three Staffer looks share one skeleton")
	check(_same_skeleton(rovers), "the two Rover liveries share one skeleton")
	for look in staffers:
		var d := _rig(look)
		check(not d.get("pixel_art", false), "%s: a smooth rig" % look)
		for sn in ["port_light", "spark_port", "grip_near", "grip_far"]:
			check(d.get("sockets", {}).has(sn), "%s: the %s socket" % [look, sn])
	for look in rovers:
		var d := _rig(look)
		var names := []
		for jj in d.get("joints", []):
			names.append(jj["name"])
		for jn in ["chassis", "wheel_near_front", "wheel_near_rear", "lightbar", "battery", "hatch", "sensor", "bumper"]:
			check(jn in names, "%s: the %s joint" % [look, jn])
		for sn in ["tell", "lens_light", "core", "spark_bumper", "oil_drip"]:
			check(d.get("sockets", {}).has(sn), "%s: the %s socket" % [look, sn])
	var seen := {}
	var made := []
	for n in 9:
		var st: Brawler = load("res://scenes/actors/staffer.tscn").instantiate()
		st.entity_id = "HDSTAFF_%d" % n
		add_child(st)
		st.global_position = Vector2(-9000 - n * 300, -1)
		made.append(st)
	for n in 6:
		var rv: PatrolRover = load("res://scenes/actors/patrol_rover.tscn").instantiate()
		rv.entity_id = "HDROVER_%d" % n
		add_child(rv)
		rv.global_position = Vector2(-14000 - n * 400, -1)
		made.append(rv)
	await physics_frames(2)
	for e in made:
		seen[e.rig_path_for_look()] = true
		check(e.rig != null and e.rig.rig_path == e.rig_path_for_look(), "%s draws the look its id picks" % e.entity_id)
	check_eq(seen.size(), 5, "all three Staffer looks and both Rover liveries are used")
	for e in made:
		e.queue_free()
