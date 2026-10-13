extends TestCase
## REGRESSION (R1-04 / ENG-03): jump tapped (pressed+released) while falling,
## within the buffer window before landing. The button is already released at
## takeoff, so the buffered jump should be a short (cut) hop, like a grounded
## tap, not a full-height jump.

const BlockScript := preload("res://scripts/world/block.gd")


func run() -> void:
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(0, 560)
	floor_b.size = Vector2(2000, 200)
	add_child(floor_b)
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.use_aim_override = true
	hero.global_position = Vector2(300, 560)
	await physics_frames(3)

	# Reference: grounded 3-tick tap.
	var start_y := hero.global_position.y
	press("jump")
	await physics_frames(3)
	release("jump")
	var tap_h := 0.0
	for i in 60:
		await physics_frames(1)
		tap_h = maxf(tap_h, start_y - hero.global_position.y)
	await physics_frames(10)

	# Fall from high up; when ~66px above the floor, tap jump for 1 tick
	# (released while still airborne, ~3 ticks before landing).
	hero.global_position = Vector2(300, 360)
	hero.velocity = Vector2.ZERO
	for k in 120:
		await physics_frames(1)
		if start_y - hero.global_position.y < 70.0:
			break
	print("PROBE pressing at h=%.1f vy=%.1f coyote=%.3f" % [start_y - hero.global_position.y, hero.velocity.y, hero._coyote_timer])
	press("jump")
	for k in 1:
		await physics_frames(1)
		print("PROBE after 1-tick press: h=%.1f vy=%.1f on_floor=%s" % [start_y - hero.global_position.y, hero.velocity.y, hero.is_on_floor()])
	release("jump")
	var buf_h := 0.0
	for i in 90:
		await physics_frames(1)
		buf_h = maxf(buf_h, start_y - hero.global_position.y)
	print("PROBE tap_apex=%.1f buffered_tap_apex=%.1f" % [tap_h, buf_h])
	check(buf_h < tap_h * 1.5,
			"a released buffered tap gives a short hop like a grounded tap (grounded tap apex %.1f, buffered tap apex %.1f)" % [tap_h, buf_h])
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
