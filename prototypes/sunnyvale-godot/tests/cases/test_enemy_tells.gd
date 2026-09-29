extends TestCase
## The Level 1 enemies' light cues (roster tell rule, C26/C35), proven on
## the values the lit rigs are driven by, never on pixels:
##   - Night Guard: the baton's tell light is off while it patrols and walks
##     in; amber through the windup, red for its last `red_time` and through
##     the swing; off again in the recovery.
##   - Staffer: a dim Link glow while its encounter sleeps, a steady one
##     once it walks out; its hands glow with the tell through the windup.
##   - Patrol Rover: a dim amber lightbar on patrol, amber then red through
##     the windup (red for its last RED_TIME), red through the charge; in the
##     stall the rear hatch swings open and the battery glows bright; a
##     wreck's lights are dark.
## Readability cues only: nothing here feeds back into gameplay, which the
## M2 cases prove on their own.

const BlockScript := preload("res://scripts/world/block.gd")
const FLOOR_Y := 560.0
const FRAME := 1.0 / 60.0


func _make_block(x: float, y: float, w: float, h: float, kind: int = 0) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	b.kind = kind
	add_child(b)
	return b


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.use_aim_override = true
	return hero


func _emissive(rig, jname: String) -> Array:
	var m: ShaderMaterial = rig.joint_material(jname)
	var c: Vector3 = m.get_shader_parameter("emissive_color")
	return [Color(c.x, c.y, c.z), float(m.get_shader_parameter("emissive_energy"))]


func run() -> void:
	await _test_night_guard_tell()
	await _test_staffer_link_and_hands()
	await _test_rover_lightbar_and_battery()


func _test_night_guard_tell() -> void:
	Session.new_run()
	var floor_b := _make_block(0, FLOOR_Y, 2000, 200)
	var guard: Brawler = load("res://scenes/actors/night_guard.tscn").instantiate()
	guard.position = Vector2(900, FLOOR_Y)
	add_child(guard)
	await physics_frames(2)
	check(guard.rig != null, "setup: the Night Guard has its lit rig")
	if guard.rig == null:
		return
	check(guard._tell_light.energy == 0.0, "the baton's tell light is off while the guard patrols")

	var hero := _make_hero(Vector2(620, FLOOR_Y))
	var light_off_walking := true
	var amber_early := true
	var red_late := true
	var red_swing := true
	var off_recovery := true
	var saw := {}
	var red_from := guard.tuning.windup_time - guard.tuning.red_time
	for i in 360:
		await physics_frames(1)
		if not is_instance_valid(guard):
			break
		var t: float = guard._state_timer
		var c: Color = guard._tell_light.color
		var e: float = guard._tell_light.energy
		saw[guard.state] = true
		match guard.state:
			Brawler.State.APPROACH, Brawler.State.PATROL:
				light_off_walking = light_off_walking and e == 0.0
			Brawler.State.WINDUP:
				if t < red_from - FRAME:
					amber_early = amber_early and c == Brawler.AMBER and e > 0.0
				elif t >= red_from:
					red_late = red_late and c == Brawler.ALARM and e > 0.0
			Brawler.State.STRIKE:
				red_swing = red_swing and c == Brawler.ALARM and e > 0.0
			Brawler.State.RECOVERY:
				off_recovery = off_recovery and e == 0.0
		if saw.has(Brawler.State.RECOVERY) and guard.state == Brawler.State.APPROACH:
			break
	check(saw.has(Brawler.State.WINDUP) and saw.has(Brawler.State.STRIKE) and saw.has(Brawler.State.RECOVERY),
			"setup: the guard walked in, wound up, swung and recovered (%s)" % str(saw.keys()))
	check(light_off_walking, "the tell light stays off while the guard walks in")
	check(amber_early, "the tell glows amber through the first part of the windup")
	check(red_late, "the tell turns red for the last %.2fs of the windup" % guard.tuning.red_time)
	check(red_swing, "the tell stays red through the swing")
	check(off_recovery, "the tell goes dark in the recovery (the punish window)")
	var baton := _emissive(guard.rig, guard.tuning.tell_joint)
	check(baton[1] == 0.0, "the baton tip's own glow is off outside the windup and swing")

	hero.queue_free()
	guard.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


func _test_staffer_link_and_hands() -> void:
	Session.new_run()
	var floor_b := _make_block(0, FLOOR_Y, 2000, 200)
	var group := EncounterGroup.new()
	group.is_active = false
	group.lane_rect = Rect2(0, 200, 2000, 600)
	add_child(group)
	var staffer: Brawler = load("res://scenes/actors/staffer.tscn").instantiate()
	staffer.position = Vector2(900, FLOOR_Y)
	group.add_child(staffer)
	await physics_frames(2)
	check(staffer.rig != null, "setup: the Staffer has its lit rig")
	if staffer.rig == null:
		return
	var link_energy := func() -> float: return float(staffer.rig.body_material.get_shader_parameter("emissive_energy"))
	check(staffer.state == Brawler.State.DORMANT, "setup: the Staffer starts dormant")
	check(is_equal_approx(link_energy.call(), 0.45), "a dormant Staffer's Link glows dim (got %.2f)" % link_energy.call())
	check(staffer._hand_glows.size() == 2 and not staffer._hand_glows[0].visible, "its hands carry a tell glow, off while dormant")

	var hero := _make_hero(Vector2(640, FLOOR_Y))
	group.is_active = true
	var steady := true
	var hands_in_windup := true
	var hands_off_walking := true
	var saw_windup := false
	for i in 360:
		await physics_frames(1)
		if not is_instance_valid(staffer):
			break
		steady = steady and is_equal_approx(link_energy.call(), 1.3)
		if staffer.state == Brawler.State.WINDUP:
			saw_windup = true
			hands_in_windup = hands_in_windup and staffer._hand_glows[0].visible and staffer._hand_glows[1].visible
		elif staffer.state == Brawler.State.APPROACH:
			hands_off_walking = hands_off_walking and not staffer._hand_glows[0].visible
		if saw_windup and staffer.state == Brawler.State.RECOVERY:
			break
	check(saw_windup, "setup: the Staffer walked out and wound up its grab")
	check(steady, "once it walks out, the Staffer's Link glows steady")
	check(hands_in_windup, "both hands glow through the windup")
	check(hands_off_walking, "the hands stay dark while it walks")

	hero.queue_free()
	group.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


func _test_rover_lightbar_and_battery() -> void:
	Session.new_run()
	var floor_b := _make_block(0, FLOOR_Y, 2000, 200)
	# A backstop beyond the hero (the real A02 layout): it stops the charge.
	var backstop := _make_block(250, FLOOR_Y - 100, 48, 100, BlockScript.Kind.BACKSTOP)
	var host := Node2D.new()
	add_child(host)
	var rover: PatrolRover = load("res://scenes/actors/patrol_rover.tscn").instantiate()
	rover.name = "Rover"
	rover.position = Vector2(700, FLOOR_Y)
	host.add_child(rover)
	await physics_frames(2)
	var rig = rover.rig
	check(rig != null, "setup: the rover has its lit rig")
	if rig == null:
		return
	var bar: String = rig.joint_for_role("lightbar")
	var battery: String = rig.joint_for_role("battery")
	var hatch: String = rig.joint_for_role("hatch")
	var patrol_bar := _emissive(rig, bar)
	check(patrol_bar[0] == PatrolRover.AMBER and patrol_bar[1] < 1.0, "a patrolling rover's lightbar is a dim amber")
	check(rover._tell_light.energy == 0.0, "its tell light is off on patrol")
	check(is_zero_approx(rig.joints[hatch].rotation), "the battery hatch is shut on patrol")

	var hero := _make_hero(Vector2(450, FLOOR_Y))
	var amber_early := true
	var red_late := true
	var red_charge := true
	var hatch_open := false
	var battery_bright := false
	var saw := {}
	var red_from := rover.tuning.windup_time - PatrolRover.RED_TIME
	for i in 420:
		await physics_frames(1)
		if not is_instance_valid(rover):
			break
		saw[rover.state] = true
		var e := _emissive(rig, bar)
		match rover.state:
			PatrolRover.State.WINDUP:
				if rover._state_timer < red_from - FRAME:
					amber_early = amber_early and e[0] == PatrolRover.AMBER and rover._tell_light.energy > 0.0
				elif rover._state_timer >= red_from:
					red_late = red_late and e[0] == PatrolRover.ALARM and rover._tell_light.energy > 0.0
			PatrolRover.State.CHARGE:
				red_charge = red_charge and e[0] == PatrolRover.ALARM and rover._tell_light.energy > 0.0
			PatrolRover.State.STALL:
				if rover._state_timer > 0.3:
					hatch_open = hatch_open or absf(rig.joints[hatch].rotation) > 0.8
					battery_bright = battery_bright or _emissive(rig, battery)[1] >= 1.5
		if saw.has(PatrolRover.State.STALL) and rover.state == PatrolRover.State.RECOVERY:
			break
	check(saw.has(PatrolRover.State.WINDUP) and saw.has(PatrolRover.State.CHARGE) and saw.has(PatrolRover.State.STALL),
			"setup: the rover wound up, charged and stalled on the backstop (%s)" % str(saw.keys()))
	check(amber_early, "the lightbar and tell light are amber through the first part of the windup")
	check(red_late, "they turn red for the last %.2fs of the windup" % PatrolRover.RED_TIME)
	check(red_charge, "they stay red through the charge")
	check(hatch_open, "in the stall the rear hatch swings open")
	check(battery_bright, "in the stall the exposed battery glows bright")

	# A destroyed rover's lights go dark on the wreck.
	if is_instance_valid(rover):
		rover.rear_hit_zone.blocks = false
		var wreck_bar: Sprite2D = rig.sprites[bar]
		for i in rover.tuning.motor_health:
			rover.rear_hit_zone.take_hit(1, rover.rear_hit_zone.global_position, Vector2.RIGHT)
		await physics_frames(1)
		var m: ShaderMaterial = wreck_bar.material
		check(float(m.get_shader_parameter("emissive_energy")) == 0.0, "a wreck's lightbar is dark")

	hero.queue_free()
	host.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
