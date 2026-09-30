extends TestCase
## M1 T03: hero damage/immunity/death and fall_to contract.

const BlockScript := preload("res://scripts/world/block.gd")


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.input_enabled = false
	return hero


func run() -> void:
	await _test_immunity_blocks_second_hit()
	await _test_died_emitted_once()
	await _test_fall_to()


func _test_immunity_blocks_second_hit() -> void:
	Session.new_run()
	var floor_b := BlockScript.new()
	floor_b.position = Vector2(0, 560)
	floor_b.size = Vector2(2000, 200)
	add_child(floor_b)
	var hero := _make_hero(Vector2(100, 560))
	await physics_frames(3)

	var start_health := Session.get_health()
	var first_ok := hero.take_damage(1, Vector2(0, 560))
	await physics_frames(1)
	var second_ok := hero.take_damage(1, Vector2(0, 560))  # still within 1.0s immunity
	await physics_frames(1)

	check(first_ok, "first take_damage call while not immune succeeds")
	check(not second_ok, "a second take_damage call within immunity is refused")
	check(Session.get_health() == start_health - 1,
			"two take_damage calls within immunity cost exactly 1 health (start=%d, now=%d)" % [start_health, Session.get_health()])

	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_died_emitted_once() -> void:
	Session.new_run()
	var hero := _make_hero(Vector2(100, 200))
	await physics_frames(3)

	Session.state["health"] = 1  # about to die on the next hit
	# NOTE: a GDScript lambda snapshots captured scalars by value; use a
	# 1-element Array (captured by reference) so the count is actually shared.
	var died_count := [0]
	hero.died.connect(func(): died_count[0] += 1)

	var ok := hero.take_damage(5, Vector2(0, 200))
	check(ok, "the lethal hit itself is accepted")
	check(Session.get_health() == 0, "health clamps to 0, never negative")
	check(died_count[0] == 1, "died is emitted exactly once when health reaches 0 (got %d)" % died_count[0])

	# Further hits (even after immunity would normally expire) must not
	# re-emit died or go below 0 health.
	await seconds(1.2)
	var ok2 := hero.take_damage(1, Vector2(0, 200))
	check(not ok2, "take_damage while already dead (0 health) is refused")
	check(died_count[0] == 1, "died is still only emitted once after further hits (got %d)" % died_count[0])
	check(Session.get_health() == 0, "health stays at 0")

	hero.queue_free()
	await physics_frames(1)


func _test_fall_to() -> void:
	Session.new_run()
	var hero := _make_hero(Vector2(500, 500))
	await physics_frames(3)

	var start_health := Session.get_health()
	var safe_pos := Vector2(50, 100)
	hero.fall_to(safe_pos, 1)
	await physics_frames(1)

	check(Session.get_health() == start_health - 1,
			"fall_to costs exactly 1 health (start=%d, now=%d)" % [start_health, Session.get_health()])
	check(hero.global_position.distance_to(safe_pos) < 0.5,
			"fall_to teleports the hero to the safe position (got %s, want %s)" % [hero.global_position, safe_pos])

	hero.queue_free()
	await physics_frames(1)
