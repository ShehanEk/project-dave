extends TestCase
## M2 T06: one EncounterGroup with a Staffer and a Clipper contesting the
## same hero. Over >=20s of simulated combat, never more than one enemy is
## in windup/active-attack at once, and both enemies actually get a turn
## (the token isn't monopolized). Also covers EncounterGroup's
## approach-zone activation gate.

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
	await _test_group_activation_gate()
	await _test_fairness_over_20_seconds()


func _test_group_activation_gate() -> void:
	# Kept well away from world origin (0,0): a node's spawn transform is
	# (0,0) for the single frame between add_child() and an explicit
	# reposition, so placing test geometry away from the origin avoids a
	# spurious body_entered against that transient default position.
	const ORIGIN := Vector2(-6000, -6000)
	var group := EncounterGroup.new()
	group.position = ORIGIN
	var zone := Area2D.new()
	zone.name = "ApproachZone"
	zone.collision_layer = 0
	zone.collision_mask = 2  # hero_body
	zone.monitoring = true
	zone.monitorable = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(200, 400)
	shape.shape = rect
	zone.add_child(shape)
	group.add_child(zone)
	add_child(group)
	await physics_frames(1)

	check(not group.is_active, "a group with an ApproachZone starts inactive")

	var hero := _make_hero(ORIGIN + Vector2(-1000, 0))
	await physics_frames(2)
	check(not group.is_active, "the group stays inactive while the hero is outside the approach zone")

	hero.global_position = ORIGIN
	await physics_frames(3)
	check(group.is_active, "the group activates once the hero enters the approach zone")

	hero.queue_free()
	group.queue_free()
	await physics_frames(1)


func _test_fairness_over_20_seconds() -> void:
	Session.new_run()
	Session.state["health"] = 1000  # survive sustained contact for this token-sharing test
	var floor_b := _make_floor(0, 560, 1400)

	var group := EncounterGroup.new()
	group.lane_rect = Rect2(-500, -500, 2000, 1000)
	add_child(group)

	var staffer: Staffer = load("res://scenes/actors/staffer.tscn").instantiate()
	group.add_child(staffer)
	var clipper: Clipper = load("res://scenes/actors/clipper.tscn").instantiate()
	group.add_child(clipper)
	await physics_frames(1)
	staffer.global_position = Vector2(760, 560)
	clipper.global_position = Vector2(640, 560)

	var hero := _make_hero(Vector2(700, 560))
	await physics_frames(3)

	var staffer_attacks := 0
	var clipper_attacks := 0
	var staffer_was_active := false
	var clipper_was_active := false
	var max_concurrent := 0
	var violation_frame := -1

	var ticks := int(20.5 * 60.0)  # a bit over 20 simulated seconds
	for i in ticks:
		await physics_frames(1)
		var r_active: bool = is_instance_valid(staffer) and staffer.state in [Staffer.State.WINDUP, Staffer.State.LUNGE]
		var c_active: bool = is_instance_valid(clipper) and clipper.state in [Clipper.State.WINDUP, Clipper.State.CHARGE]

		if r_active and not staffer_was_active:
			staffer_attacks += 1
		if c_active and not clipper_was_active:
			clipper_attacks += 1
		staffer_was_active = r_active
		clipper_was_active = c_active

		var concurrent := int(r_active) + int(c_active)
		max_concurrent = maxi(max_concurrent, concurrent)
		if concurrent > 1 and violation_frame < 0:
			violation_frame = i

	check(violation_frame < 0,
			"never more than one enemy is windup/active-attacking at once (first violation at tick %d)" % violation_frame)
	check(max_concurrent <= 1, "max concurrent windup/active attackers over 20s is <=1 (got %d)" % max_concurrent)
	check(staffer_attacks >= 1, "the Staffer got at least one attack turn over 20s (got %d)" % staffer_attacks)
	check(clipper_attacks >= 1, "the Clipper got at least one attack turn over 20s (got %d)" % clipper_attacks)

	hero.queue_free()
	if is_instance_valid(staffer):
		staffer.queue_free()
	if is_instance_valid(clipper):
		clipper.queue_free()
	group.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
