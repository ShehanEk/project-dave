extends TestCase
## M1 T02: variable jump, run speed, coyote grace, jump buffer, ceiling bonk.

const BlockScript := preload("res://scripts/world/block.gd")


func _make_floor(x: float, y: float, w: float, h: float = 200.0) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	add_child(b)
	return b


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	return hero


func run() -> void:
	await _test_full_hold_apex()
	await _test_short_tap_apex()
	await _test_run_speed()
	await _test_coyote()
	await _test_jump_buffer()
	await _test_jump_buffer_expires()
	await _test_ceiling_bonk()


func _test_full_hold_apex() -> void:
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(100, 560))
	await physics_frames(3)
	hero.global_position = Vector2(100, 560)
	hero.velocity = Vector2.ZERO
	await physics_frames(1)

	var start_y := hero.global_position.y
	var max_h := 0.0
	press("jump")
	# Hold through and past the analytic apex time (0.42s) before releasing,
	# so the jump-cut never engages: this measures the FULL-HOLD arc.
	for i in 30:
		await physics_frames(1)
		max_h = maxf(max_h, start_y - hero.global_position.y)
	release("jump")
	await physics_frames(20)
	max_h = maxf(max_h, start_y - hero.global_position.y)

	var expected := hero.tuning.jump_apex_h * hero.tuning.height_px  # 153.6
	check(max_h > expected * 0.9 and max_h < expected * 1.1,
			"full-hold apex ~%.1f within 10%% of %.1f (got %.1f)" % [expected, expected, max_h])
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_short_tap_apex() -> void:
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(100, 560))
	await physics_frames(3)
	hero.global_position = Vector2(100, 560)
	hero.velocity = Vector2.ZERO
	await physics_frames(1)

	var start_y := hero.global_position.y
	var max_h := 0.0
	press("jump")
	await physics_frames(1)
	release("jump")
	for i in 40:
		await physics_frames(1)
		max_h = maxf(max_h, start_y - hero.global_position.y)

	var full_hold_expected := hero.tuning.jump_apex_h * hero.tuning.height_px
	check(max_h < full_hold_expected * 0.5,
			"short-tap apex (%.1f) is clearly lower than full-hold apex (%.1f)" % [max_h, full_hold_expected])
	check(max_h > 4.0, "short tap still leaves the ground at all (%.1f)" % max_h)
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_run_speed() -> void:
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(100, 560))
	await physics_frames(3)
	hero.global_position = Vector2(100, 560)
	hero.velocity = Vector2.ZERO
	await physics_frames(1)

	press("move_right")
	await seconds(1.0)
	var vx := hero.velocity.x
	release("move_right")
	check(vx > hero.tuning.run_speed * 0.95 and vx < hero.tuning.run_speed * 1.05,
			"run speed reaches ~%.0f px/s (got %.1f)" % [hero.tuning.run_speed, vx])
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_coyote() -> void:
	var ledge := _make_floor(0, 560, 300)
	var hero := _make_hero(Vector2(250, 560))
	await physics_frames(3)
	hero.global_position = Vector2(250, 560)
	hero.velocity = Vector2.ZERO
	await physics_frames(1)

	press("move_right")
	var left_floor := false
	for i in 60:
		await physics_frames(1)
		if not left_floor and not hero.is_on_floor():
			left_floor = true
			break
	release("move_right")
	check(left_floor, "hero actually walks off the ledge")

	# Case A: jump 3 ticks (0.05s) after leaving — within the 0.10s grace.
	for i in 3:
		await physics_frames(1)
	press("jump")
	await physics_frames(1)
	var succeeded_a := hero.velocity.y < -100.0
	release("jump")
	check(succeeded_a, "coyote jump succeeds shortly (0.05s) after leaving a ledge")

	hero.queue_free()
	ledge.queue_free()
	await physics_frames(2)

	# Case B: jump ~0.25s after leaving — beyond the 0.10s grace, must fail.
	var ledge2 := _make_floor(0, 560, 300)
	var hero2 := _make_hero(Vector2(250, 560))
	await physics_frames(3)
	hero2.global_position = Vector2(250, 560)
	hero2.velocity = Vector2.ZERO
	await physics_frames(1)
	press("move_right")
	left_floor = false
	for i in 60:
		await physics_frames(1)
		if not left_floor and not hero2.is_on_floor():
			left_floor = true
			break
	release("move_right")
	for i in 15:  # 0.25s
		await physics_frames(1)
	press("jump")
	await physics_frames(1)
	var succeeded_b := hero2.velocity.y < -100.0
	release("jump")
	check(not succeeded_b, "jump ~0.25s after leaving a ledge (beyond coyote) does not take off")
	hero2.queue_free()
	ledge2.queue_free()
	await physics_frames(1)


func _test_jump_buffer() -> void:
	# Hero falling toward a floor from just above it, timed so landing
	# happens within the 0.12s buffer window after the press.
	var floor_b := _make_floor(0, 700, 300)
	var hero := _make_hero(Vector2(100, 690))
	await physics_frames(3)
	hero.global_position = Vector2(100, 690)
	hero.velocity = Vector2(0, 20.0)  # falling the last ~10px
	await physics_frames(1)

	press("jump")
	var landed_with_jump := false
	for i in 60:
		await physics_frames(1)
		if hero.is_on_floor():
			# One extra tick for takeoff to apply.
			await physics_frames(1)
			landed_with_jump = hero.velocity.y < -100.0
			break
	release("jump")
	check(landed_with_jump, "a buffered jump pressed while falling fires on landing")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


## R1-05(c): the existing buffer test only holds jump straight through
## landing, never a released tap, and never a press old enough for the
## buffer to expire. This covers the expired-buffer half.
func _test_jump_buffer_expires() -> void:
	var floor_b := _make_floor(0, 700, 300)
	var hero := _make_hero(Vector2(100, 500))
	await physics_frames(3)
	hero.global_position = Vector2(100, 500)
	hero.velocity = Vector2.ZERO
	await physics_frames(1)

	# Tap jump right away, well outside the 0.12s buffer window before the
	# ~0.4s fall to the floor actually lands.
	press("jump")
	await physics_frames(1)
	release("jump")
	var landed_with_jump := false
	for i in 120:
		await physics_frames(1)
		if hero.is_on_floor():
			# One extra tick for takeoff to apply, same as _test_jump_buffer.
			await physics_frames(1)
			landed_with_jump = hero.velocity.y < -100.0
			break
	check(not landed_with_jump,
			"a jump tapped well before landing, once its 0.12s buffer has expired, does not fire on landing")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_ceiling_bonk() -> void:
	var floor_b := _make_floor(0, 560, 400)
	# Ceiling bottom 1.2H above the floor: lower than the full-hold apex, so
	# a full jump must be stopped by it, not pass through.
	var ceiling_bottom := 560.0 - 1.2 * 96.0
	var ceiling := _make_floor(0, -400.0, 400, 400.0 + ceiling_bottom)
	var hero := _make_hero(Vector2(100, 560))
	await physics_frames(3)
	hero.global_position = Vector2(100, 560)
	hero.velocity = Vector2.ZERO
	await physics_frames(1)

	press("jump")
	var min_y := hero.global_position.y
	for i in 90:
		await physics_frames(1)
		min_y = minf(min_y, hero.global_position.y)
	release("jump")
	await physics_frames(20)

	var hero_top_at_min := min_y - hero.tuning.height_px
	check(hero_top_at_min >= ceiling_bottom - 2.0,
			"hero's head never passes above the ceiling (min feet y=%.1f, ceiling bottom=%.1f)" % [min_y, ceiling_bottom])
	# It should bonk almost exactly at ceiling_bottom + H, well short of the
	# ~153.6px full-jump apex (feet would reach 560-153.6=406.4 unobstructed).
	var expected_stop := ceiling_bottom + hero.tuning.height_px
	check(absf(min_y - expected_stop) < 6.0,
			"jump is capped right at the ceiling (expected feet y~%.1f, got %.1f)" % [expected_stop, min_y])
	hero.queue_free()
	floor_b.queue_free()
	ceiling.queue_free()
	await physics_frames(1)
