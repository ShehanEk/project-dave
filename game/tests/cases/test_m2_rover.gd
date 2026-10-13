extends TestCase
## M2 T03/T05: Patrol Rover frontal shots are blocked (with the one-time
## battery hint after enough ineffective hits), a charge stays grounded with
## monotonic x, a wall/backstop hit stalls it and exposes the rear battery
## for long enough to fit three stage-0 shots, and a scripted bot can dodge
## the charge (jump over it) and defeat it via the exposed battery without
## taking unavoidable damage. (Ported from the Clipper test: the Rover keeps
## the Clipper's behaviour and timings; only names and presentation changed.)

const BlockScript := preload("res://scripts/world/block.gd")


func _make_floor(x: float, y: float, w: float, h: float = 200.0) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	add_child(b)
	return b


func _make_backstop(x: float, y: float, w: float, h: float) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	b.kind = BlockScript.Kind.BACKSTOP
	add_child(b)
	return b


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.use_aim_override = true
	return hero


func _make_rover(pos: Vector2, entity_id: String = "") -> PatrolRover:
	var r: PatrolRover = load("res://scenes/actors/patrol_rover.tscn").instantiate()
	r.entity_id = entity_id
	add_child(r)
	r.global_position = pos
	await physics_frames(1)
	return r


func run() -> void:
	await _test_frontal_shots_blocked_and_hint()
	await _test_charge_is_grounded_and_monotonic()
	await _test_wall_stall_exposes_battery_and_fits_three_shots()
	await _test_defeated_once_and_not_reinstanced()
	await _test_bot_dodges_charge_and_defeats_via_battery()


func _test_frontal_shots_blocked_and_hint() -> void:
	var rover := await _make_rover(Vector2(500, 560))
	var hint_count := [0]
	rover.hint_requested.connect(func(_t): hint_count[0] += 1)

	for i in rover.tuning.frontal_hint_threshold:
		var outcome: StringName = rover.front_hit_zone.take_hit(1, rover.global_position, Vector2.LEFT)
		check(outcome == &"blocked", "the Rover's front armor always answers 'blocked' (shot %d)" % (i + 1))

	check(hint_count[0] == 1,
			"the battery hint fires exactly once after %d ineffective frontal hits (got %d)" % [rover.tuning.frontal_hint_threshold, hint_count[0]])
	check(rover.hint_label.visible, "the one-time hint is shown on screen")

	# Further ineffective hits must not re-fire the hint.
	rover.front_hit_zone.take_hit(1, rover.global_position, Vector2.LEFT)
	check(hint_count[0] == 1, "the hint does not re-fire on later ineffective hits (got %d)" % hint_count[0])

	rover.queue_free()
	await physics_frames(1)


func _test_charge_is_grounded_and_monotonic() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(150, 560))
	var rover := await _make_rover(Vector2(600, 560))

	# Wait for acquire -> windup -> charge.
	var frame := 0
	while rover.state != PatrolRover.State.CHARGE and frame < 180:
		await physics_frames(1)
		frame += 1
	check(rover.state == PatrolRover.State.CHARGE, "Rover reaches the CHARGE state after acquiring the hero")

	var start_y := rover.global_position.y
	var last_x := rover.global_position.x
	var monotonic := true
	var stayed_grounded := true
	var ticks := 0
	while rover.state == PatrolRover.State.CHARGE and ticks < 120:
		await physics_frames(1)
		ticks += 1
		if absf(rover.global_position.y - start_y) > 1.0:
			stayed_grounded = false
		if rover.global_position.x > last_x + 0.01:  # charging left; x must not increase
			monotonic = false
		last_x = rover.global_position.x

	check(ticks > 0, "the charge was observed for at least one tick")
	check(stayed_grounded, "the charge keeps a constant y (stays grounded, never jumps)")
	check(monotonic, "the charge's x moves monotonically in the locked charge direction")

	hero.queue_free()
	if is_instance_valid(rover):
		rover.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_wall_stall_exposes_battery_and_fits_three_shots() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	# The backstop sits BEYOND the hero (same side, same direction) so the
	# Rover's line of sight to the hero is never blocked by it — matching
	# the real layout (02-area-blueprints A02): the hero triggers the charge
	# from the open side, and the wall is what stops the charge afterward,
	# not an obstruction between them.
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var rover := await _make_rover(Vector2(500, 560))

	var frame := 0
	while rover.state != PatrolRover.State.STALL and frame < 240:
		await physics_frames(1)
		frame += 1

	check(rover.state == PatrolRover.State.STALL, "the backstop stalls the Rover within a reasonable time")
	check(rover.is_stalled(), "is_stalled() agrees with the STALL state")
	check(not rover.rear_hit_zone.blocks, "the rear battery accepts damage once stalled")
	var front_outcome: StringName = rover.front_hit_zone.take_hit(1, rover.global_position, Vector2.RIGHT)
	check(front_outcome == &"blocked", "the front armor still blocks even while stalled")

	# Three stage-0-paced shots (0.32s apart) comfortably fit the 1.6s stall.
	var defeat_count := [0]
	rover.defeated.connect(func(_id): defeat_count[0] += 1)
	var shot_interval_ticks := int(0.32 * 60.0)
	for i in 3:
		check(rover.state == PatrolRover.State.STALL,
				"the Rover is still stalled for shot %d (stall has %.2fs left)" % [i + 1, rover.tuning.wall_stall_time - (i * 0.32)])
		var outcome: StringName = rover.rear_hit_zone.take_hit(1, rover.rear_hit_zone.global_position, Vector2.RIGHT)
		check(outcome == &"hit", "rear-battery shot %d is accepted while stalled" % (i + 1))
		await physics_frames(shot_interval_ticks)

	check(defeat_count[0] == 1, "three rear-battery hits defeat the Rover")

	hero.queue_free()
	if is_instance_valid(rover):
		rover.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_defeated_once_and_not_reinstanced() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var entity_id := "L01-TEST-M01-01"
	var rover := await _make_rover(Vector2(500, 560), entity_id)
	rover.rear_hit_zone.blocks = false  # force-expose for this direct test
	var had_rig: bool = rover.rig != null
	var defeat_count := [0]
	rover.defeated.connect(func(_id): defeat_count[0] += 1)

	for i in rover.tuning.motor_health:
		rover.rear_hit_zone.take_hit(1, rover.global_position, Vector2.LEFT)
	# A further hit in the same frame as the killing blow (the node is only
	# freed at the end of the frame) must not re-trigger defeat.
	if is_instance_valid(rover):
		rover.rear_hit_zone.take_hit(1, rover.global_position, Vector2.LEFT)
	# The old 0.35 s defeat fade is gone: the Rover frees itself at once.
	await physics_frames(3)

	check(defeat_count[0] == 1, "Rover defeated fires exactly once (got %d)" % defeat_count[0])
	check(Session.is_defeated(entity_id), "Session records the Rover as defeated")
	check(not is_instance_valid(rover), "the defeated Rover node is gone at once (no fade timer any more)")
	# Its wreck stays behind under the Rover's parent (no AreaRoot here) until
	# the area is rebuilt; only built when the rig loaded (a missing rig.json
	# skips the visuals).
	if had_rig:
		check(get_node_or_null("Wreck_" + entity_id) != null, "the defeated Rover leaves a Wreck_<entity_id> node behind")

	var respawned := await _make_rover(Vector2(500, 560), entity_id)
	await physics_frames(2)
	check(not is_instance_valid(respawned),
			"re-instancing the same entity_id after Session marks it defeated removes it immediately")

	floor_b.queue_free()
	await physics_frames(1)


func _test_bot_dodges_charge_and_defeats_via_battery() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 900)
	var backstop := _make_backstop(100, 460, 48, 100)
	var hero := _make_hero(Vector2(220, 560))
	var rover := await _make_rover(Vector2(480, 560))

	var start_health := Session.get_health()
	var defeat_count := [0]
	rover.defeated.connect(func(_id): defeat_count[0] += 1)

	var frame := 0
	# Holding "jump" for a fixed number of ticks once triggered (rather than
	# tying the hold to is_on_floor()) avoids an early release clipping the
	# jump short via the hero's jump-cut-on-release rule the instant it
	# leaves the ground.
	var jump_hold_left := 0
	while defeat_count[0] == 0 and frame < 600:  # up to 10s
		await physics_frames(1)
		frame += 1
		if not is_instance_valid(hero):
			break

		if jump_hold_left > 0:
			press("jump")
			jump_hold_left -= 1
			if jump_hold_left == 0:
				release("jump")
		elif is_instance_valid(rover) and rover.state == PatrolRover.State.CHARGE:
			# Reactive dodge: jump once the charge is closing in.
			var dx: float = absf(rover.global_position.x - hero.global_position.x)
			if dx < 160.0 and hero.is_on_floor():
				jump_hold_left = 22

		if is_instance_valid(rover) and rover.state == PatrolRover.State.STALL:
			var rear_pos: Vector2 = rover.rear_hit_zone.global_position
			hero.aim_override = rear_pos
			var to_target: float = rear_pos.x - hero.global_position.x
			if absf(to_target) > 36.0:
				if to_target > 0.0:
					press("move_right"); release("move_left")
				else:
					press("move_left"); release("move_right")
				release("fire")
			else:
				release("move_left"); release("move_right")
				press("fire")
		else:
			release("fire")

	release("jump")
	release("fire")
	release("move_left")
	release("move_right")

	check(defeat_count[0] == 1, "the bot defeats the Rover via its exposed rear battery after dodging the charge")
	check(Session.get_health() == start_health,
			"the bot takes no unavoidable damage while dodging the charge and clearing the stall")

	hero.queue_free()
	if is_instance_valid(rover):
		rover.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
