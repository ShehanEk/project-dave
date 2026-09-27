extends TestCase
## M2 T03/T05: Clipper frontal shots are blocked (with the one-time motor
## hint after enough ineffective hits), a charge stays grounded with
## monotonic x, a wall/backstop hit stalls it and exposes the rear motor for
## long enough to fit three stage-0 shots, and a scripted bot can dodge the
## charge (jump over it) and defeat it via the exposed motor without taking
## unavoidable damage.

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


func _make_clipper(pos: Vector2, entity_id: String = "") -> Clipper:
	var c: Clipper = load("res://scenes/actors/clipper.tscn").instantiate()
	c.entity_id = entity_id
	add_child(c)
	c.global_position = pos
	await physics_frames(1)
	return c


func run() -> void:
	await _test_frontal_shots_blocked_and_hint()
	await _test_charge_is_grounded_and_monotonic()
	await _test_wall_stall_exposes_motor_and_fits_three_shots()
	await _test_defeated_once_and_not_reinstanced()
	await _test_bot_dodges_charge_and_defeats_via_motor()


func _test_frontal_shots_blocked_and_hint() -> void:
	var clipper := await _make_clipper(Vector2(500, 560))
	var hint_count := [0]
	clipper.hint_requested.connect(func(_t): hint_count[0] += 1)

	for i in clipper.tuning.frontal_hint_threshold:
		var outcome: StringName = clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT)
		check(outcome == &"blocked", "the Clipper's front shell always answers 'blocked' (shot %d)" % (i + 1))

	check(hint_count[0] == 1,
			"the motor hint fires exactly once after %d ineffective frontal hits (got %d)" % [clipper.tuning.frontal_hint_threshold, hint_count[0]])
	check(clipper.hint_label.visible, "the one-time hint is shown on screen")

	# Further ineffective hits must not re-fire the hint.
	clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT)
	check(hint_count[0] == 1, "the hint does not re-fire on later ineffective hits (got %d)" % hint_count[0])

	clipper.queue_free()
	await physics_frames(1)


func _test_charge_is_grounded_and_monotonic() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(150, 560))
	var clipper := await _make_clipper(Vector2(600, 560))

	# Wait for acquire -> windup -> charge.
	var frame := 0
	while clipper.state != Clipper.State.CHARGE and frame < 180:
		await physics_frames(1)
		frame += 1
	check(clipper.state == Clipper.State.CHARGE, "Clipper reaches the CHARGE state after acquiring the hero")

	var start_y := clipper.global_position.y
	var last_x := clipper.global_position.x
	var monotonic := true
	var stayed_grounded := true
	var ticks := 0
	while clipper.state == Clipper.State.CHARGE and ticks < 120:
		await physics_frames(1)
		ticks += 1
		if absf(clipper.global_position.y - start_y) > 1.0:
			stayed_grounded = false
		if clipper.global_position.x > last_x + 0.01:  # charging left; x must not increase
			monotonic = false
		last_x = clipper.global_position.x

	check(ticks > 0, "the charge was observed for at least one tick")
	check(stayed_grounded, "the charge keeps a constant y (stays grounded, never jumps)")
	check(monotonic, "the charge's x moves monotonically in the locked charge direction")

	hero.queue_free()
	if is_instance_valid(clipper):
		clipper.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_wall_stall_exposes_motor_and_fits_three_shots() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	# The backstop sits BEYOND the hero (same side, same direction) so the
	# Clipper's line of sight to the hero is never blocked by it — matching
	# the real layout (02-area-blueprints A02): the hero triggers the charge
	# from the open side, and the wall is what stops the charge afterward,
	# not an obstruction between them.
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var clipper := await _make_clipper(Vector2(500, 560))

	var frame := 0
	while clipper.state != Clipper.State.STALL and frame < 240:
		await physics_frames(1)
		frame += 1

	check(clipper.state == Clipper.State.STALL, "the backstop stalls the Clipper within a reasonable time")
	check(not clipper.rear_hit_zone.blocks, "the rear motor accepts damage once stalled")
	var front_outcome: StringName = clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.RIGHT)
	check(front_outcome == &"blocked", "the front shell still blocks even while stalled")

	# Three stage-0-paced shots (0.32s apart) comfortably fit the 1.6s stall.
	var defeat_count := [0]
	clipper.defeated.connect(func(_id): defeat_count[0] += 1)
	var shot_interval_ticks := int(0.32 * 60.0)
	for i in 3:
		check(clipper.state == Clipper.State.STALL,
				"the Clipper is still stalled for shot %d (stall has %.2fs left)" % [i + 1, clipper.tuning.wall_stall_time - (i * 0.32)])
		var outcome: StringName = clipper.rear_hit_zone.take_hit(1, clipper.rear_hit_zone.global_position, Vector2.RIGHT)
		check(outcome == &"hit", "rear-motor shot %d is accepted while stalled" % (i + 1))
		await physics_frames(shot_interval_ticks)

	check(defeat_count[0] == 1, "three rear-motor hits defeat the Clipper")

	hero.queue_free()
	if is_instance_valid(clipper):
		clipper.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_defeated_once_and_not_reinstanced() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var entity_id := "L01-TEST-R01-01"
	var clipper := await _make_clipper(Vector2(500, 560), entity_id)
	clipper.rear_hit_zone.blocks = false  # force-expose for this direct test
	var defeat_count := [0]
	clipper.defeated.connect(func(_id): defeat_count[0] += 1)

	for i in clipper.tuning.motor_health:
		clipper.rear_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT)
	await physics_frames(int(Clipper.DEFEAT_FADE_TIME * 60.0) + 5)

	check(defeat_count[0] == 1, "Clipper defeated fires exactly once (got %d)" % defeat_count[0])
	check(Session.is_defeated(entity_id), "Session records the Clipper as defeated")
	check(not is_instance_valid(clipper), "the defeated Clipper node is gone")

	var respawned := await _make_clipper(Vector2(500, 560), entity_id)
	await physics_frames(2)
	check(not is_instance_valid(respawned),
			"re-instancing the same entity_id after Session marks it defeated removes it immediately")

	floor_b.queue_free()
	await physics_frames(1)


func _test_bot_dodges_charge_and_defeats_via_motor() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 900)
	var backstop := _make_backstop(100, 460, 48, 100)
	var hero := _make_hero(Vector2(220, 560))
	var clipper := await _make_clipper(Vector2(480, 560))

	var start_health := Session.get_health()
	var defeat_count := [0]
	clipper.defeated.connect(func(_id): defeat_count[0] += 1)

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
		elif is_instance_valid(clipper) and clipper.state == Clipper.State.CHARGE:
			# Reactive dodge: jump once the charge is closing in.
			var dx: float = absf(clipper.global_position.x - hero.global_position.x)
			if dx < 160.0 and hero.is_on_floor():
				jump_hold_left = 22

		if is_instance_valid(clipper) and clipper.state == Clipper.State.STALL:
			var rear_pos: Vector2 = clipper.rear_hit_zone.global_position
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

	check(defeat_count[0] == 1, "the bot defeats the Clipper via its exposed rear motor after dodging the charge")
	check(Session.get_health() == start_health,
			"the bot takes no unavoidable damage while dodging the charge and clearing the stall")

	hero.queue_free()
	if is_instance_valid(clipper):
		clipper.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
