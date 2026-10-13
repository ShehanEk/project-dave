extends TestCase
## M4: the M02 Security Drone (the Drone template):
##   - the tell: the lightbar amber, then red for exactly the last 0.25 s, the nose up;
##     the aim follows Dave's grounded spot at head height at most 3 H/s and locks at red;
##   - the dive goes straight at the locked spot (committed: Dave's later moves never bend
##     it); a Dave who stays is hit once, a Dave who sidesteps 1.5 H is not;
##   - it hangs at head height for hang_time (the punish window, its attack box off), and
##     the base Scrapjack kills it there (2 hits); left alone it climbs back to its height;
##   - never at an airborne Dave, and no tell within 1 H of the camera's edge;
##   - destroyed it leaves a wreck (never blood), records the defeat, and a re-instance
##     with the same entity id removes itself.

const BlockScript := preload("res://scripts/world/block.gd")
const FLOOR_Y := 560.0
const H := 96.0
const HOVER_Y := FLOOR_Y - 250.0


func _block(x: float, y: float, w: float, h: float) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	add_child(b)
	return b


func _hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.use_aim_override = true
	hero.aim_override = pos + Vector2(200.0, -100.0)
	return hero


func _drone(pos: Vector2, entity_id: String = "") -> Drone:
	var d: Drone = load("res://scenes/actors/security_drone.tscn").instantiate()
	d.entity_id = entity_id
	d.position = pos
	add_child(d)
	await physics_frames(2)
	return d


func _clear() -> void:
	release_all()
	for c in get_children():
		c.queue_free()
	await physics_frames(2)


func _until(cond: Callable, timeout: float) -> bool:
	for i in int(timeout * 60.0):
		if cond.call():
			return true
		await physics_frames(1)
	return cond.call()


func run() -> void:
	await _test_tell_and_lock()
	await _test_dive_hits_a_dave_who_stays()
	await _test_sidestep_and_committed_dive()
	await _test_hang_window_and_climb()
	await _test_scrapjack_kills_it_in_the_hang()
	await _test_never_at_an_airborne_dave_and_camera_gate()
	await _test_wreck_and_defeat_record()


func _test_tell_and_lock() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(560, FLOOR_Y))
	hero.debug_invulnerable = true
	var d := await _drone(Vector2(700, HOVER_Y))
	check(d.rig != null, "the drone builds its lit rig")
	check(d.tuning.health == 2, "a Security Drone takes 2 hits")
	var started := await _until(func(): return d.state == Drone.State.TELL, 2.0)
	check(started, "the drone starts its tell over a grounded Dave")
	var amber := 0
	var red := 0
	var order_ok := true
	var lock_ok := true
	var nose_up := false
	var attack_off := true
	# Dave walks right through the amber part: the aim follows at most 3 H/s.
	press("move_right")
	var prev: Vector2 = d.locked_point()
	var max_step := 0.0
	while d.state == Drone.State.TELL:
		var c: Color = d.tell_color()
		if c == Drone.ALARM:
			red += 1
		elif c == Drone.AMBER:
			amber += 1
			if red > 0:
				order_ok = false
		if d.is_lock_set() != d.is_tell_red():
			lock_ok = false
		if d._pitch < -0.1:
			nose_up = true
		if d.attack_box.active:
			attack_off = false
		var p: Vector2 = d.locked_point()
		max_step = maxf(max_step, p.distance_to(prev))
		prev = p
		await physics_frames(1)
	release("move_right")
	check(order_ok, "the lightbar is amber, then red")
	check(absf(red / 60.0 - 0.25) <= 1.5 / 60.0, "red lasts the last 0.25 s (%.3f s)" % (red / 60.0))
	check(absf((amber + red) / 60.0 - d.tuning.windup_time) <= 2.0 / 60.0, "the tell lasts windup_time")
	check(lock_ok, "the dive's spot locks exactly when the lightbar turns red")
	check(nose_up, "it noses up in the tell")
	check(attack_off, "no attack box during the tell")
	check(max_step <= 3.0 * H / 60.0 + 0.05, "the aim follows at most 3 H/s (%.2f px/frame)" % max_step)
	await _clear()


func _test_dive_hits_a_dave_who_stays() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(560, FLOOR_Y))
	var d := await _drone(Vector2(700, HOVER_Y))
	var health := Session.get_health()
	await _until(func(): return d.is_tell_red(), 3.0)
	var lock: Vector2 = d.locked_point()
	check(absf(lock.x - 560.0) <= 1.0 and absf(lock.y - (FLOOR_Y - 0.85 * H)) <= 0.6,
			"it locks Dave's grounded spot at head height (%s)" % str(lock))
	var dived := await _until(func(): return d.is_diving(), 1.0)
	check(dived, "it dives")
	await _until(func(): return not d.is_diving(), 2.0)
	check(Session.get_health() == health - 1, "a Dave who stays in the dive's spot loses 1 health (lost %d)" % (health - Session.get_health()))
	await _clear()


func _test_sidestep_and_committed_dive() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(560, FLOOR_Y))
	var d := await _drone(Vector2(700, HOVER_Y))
	var health := Session.get_health()
	await _until(func(): return d.is_lock_set(), 3.0)
	var lock: Vector2 = d.locked_point()
	# Sidestep away from the drone, 1.5 H, after the lock.
	press("move_left")
	await _until(func(): return hero.global_position.x <= 560.0 - 1.5 * H, 1.0)
	release("move_left")
	var hang := await _until(func(): return d.is_hanging(), 2.0)
	check(hang, "the dive ends in the hang")
	check(d.global_position.distance_to(lock) <= 2.0,
			"the dive ends at the locked spot, not where Dave went (%.1f px off)" % d.global_position.distance_to(lock))
	check(Session.get_health() == health, "a sidestep of 1.5 H avoids the dive")
	await _clear()


func _test_hang_window_and_climb() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(560, FLOOR_Y))
	hero.debug_invulnerable = true
	var d := await _drone(Vector2(700, HOVER_Y))
	await _until(func(): return d.is_hanging(), 4.0)
	var frames := 0
	var attack_off := true
	var still := true
	var y0 := d.global_position.y
	while d.is_hanging() and frames < 300:
		if d.attack_box.active:
			attack_off = false
		if absf(d.global_position.y - y0) > 0.5:
			still = false
		await physics_frames(1)
		frames += 1
	check(absf(y0 - (FLOOR_Y - 0.85 * H)) <= 2.0, "it hangs at head height (%.1f above the floor)" % (FLOOR_Y - y0))
	check(absf(frames / 60.0 - d.tuning.hang_time) <= 2.0 / 60.0, "the hang lasts hang_time (%.2f s)" % (frames / 60.0))
	check(attack_off and still, "it hangs still with its attack box off (the punish window)")
	check(d.state == Drone.State.CLIMB, "then it climbs")
	var back := await _until(func(): return d.state == Drone.State.PATROL, 3.0)
	check(back, "it climbs back and patrols again")
	check(absf(d.global_position.y - d.home_y()) <= 6.0, "at its hover height (%.1f px off)" % absf(d.global_position.y - d.home_y()))
	# It rests before the next tell.
	var rested := 0
	while d.state == Drone.State.PATROL and rested < 300:
		await physics_frames(1)
		rested += 1
	check(d.state == Drone.State.TELL, "then it tells again")
	check(rested / 60.0 >= d.tuning.rest_time - 1.5 / 60.0, "it rests at least rest_time before the next tell (%.2f s)" % (rested / 60.0))
	await _clear()


func _test_scrapjack_kills_it_in_the_hang() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(560, FLOOR_Y))
	var d := await _drone(Vector2(760, HOVER_Y))
	await _until(func(): return d.is_lock_set(), 4.0)
	# Sidestep, turn, and shoot it level while it hangs.
	press("move_left")
	await _until(func(): return hero.global_position.x <= 560.0 - 2.0 * H, 1.0)
	release("move_left")
	await _until(func(): return d.is_hanging(), 2.0)
	var health := Session.get_health()
	hero.aim_override = d.global_position
	press("fire")
	var t := 0
	while is_instance_valid(d) and d.state != Drone.State.DEFEATED and t < 120:
		await physics_frames(1)
		t += 1
	release("fire")
	check(not is_instance_valid(d) or d.state == Drone.State.DEFEATED, "the base Scrapjack downs it while it hangs")
	check(t / 60.0 <= 1.6, "inside the hang (%.2f s)" % (t / 60.0))
	check(Session.get_health() == health, "without taking a hit")
	await _clear()


func _test_never_at_an_airborne_dave_and_camera_gate() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(600, FLOOR_Y - 380.0))
	hero.debug_invulnerable = true
	var d := await _drone(Vector2(700, HOVER_Y))
	var told_airborne := false
	var was: int = d.state
	for i in 90:
		await physics_frames(1)
		if d.state == Drone.State.TELL and was != Drone.State.TELL and not hero.is_on_floor():
			told_airborne = true
		was = d.state
		if hero.is_on_floor():
			break
	check(hero.is_on_floor(), "setup: Dave lands")
	check(not told_airborne, "no tell starts while Dave is in the air")
	await _clear()
	# The camera gate.
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	hero = _hero(Vector2(560, FLOOR_Y))
	hero.debug_invulnerable = true
	var cam := Camera2D.new()
	add_child(cam)
	cam.make_current()
	var half: Vector2 = get_viewport().get_visible_rect().size * 0.5 / cam.zoom
	cam.global_position = Vector2(700 - half.x + 0.5 * H, HOVER_Y + 60.0)
	await physics_frames(2)
	d = await _drone(Vector2(700, HOVER_Y))
	d.patrol_min_x = 690
	d.patrol_max_x = 710
	d._span = d._patrol_span()
	var told := await _until(func(): return d.state == Drone.State.TELL, 1.5)
	check(not told, "no tell within 1 H of the camera's edge")
	cam.global_position = Vector2(700, HOVER_Y + 60.0)
	told = await _until(func(): return d.state == Drone.State.TELL, 1.5)
	check(told, "well inside the view it starts the tell")
	cam.queue_free()
	await _clear()


func _test_wreck_and_defeat_record() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var id := "L02-TEST-M02-01"
	var d := await _drone(Vector2(700, HOVER_Y), id)
	check(not d.hit_zone.bleeds, "a machine never bleeds")
	var defeats := [0]
	d.defeated.connect(func(_id): defeats[0] += 1)
	for i in d.tuning.health:
		d.hit_zone.take_hit(1, d.global_position, Vector2.RIGHT)
	if is_instance_valid(d):
		d.hit_zone.take_hit(1, d.global_position, Vector2.RIGHT)
	await physics_frames(3)
	check(defeats[0] == 1, "defeated fires once")
	check(Session.is_defeated(id), "Session records the defeat")
	check(not is_instance_valid(d), "the drone node is gone")
	var wreck := get_node_or_null("Wreck_" + id)
	check(wreck != null, "it leaves a Wreck_<id> that falls")
	if wreck != null:
		await _until(func(): return wreck.is_settled(), 4.0)
		check(wreck.is_settled(), "the wreck settles")
		var lowest := -INF
		for part in wreck.get_node("Corpse").get_children():
			lowest = maxf(lowest, (part as Node2D).global_position.y)
		check(lowest > HOVER_Y + 150.0, "its parts fell to the floor (lowest at %.0f)" % lowest)
	var again := await _drone(Vector2(700, HOVER_Y), id)
	await physics_frames(1)
	check(not is_instance_valid(again), "a re-instance with the same entity id removes itself")
	await _clear()
