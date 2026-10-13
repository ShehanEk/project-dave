extends TestCase
## M2 T06: one EncounterGroup with a Brawler (a Staffer, then a Night Guard)
## and a Patrol Rover contesting the same hero. Over >=20s of simulated
## combat, never more than one enemy is in windup/active-attack at once, and
## both enemies actually get a turn (the token isn't monopolized). Also
## covers EncounterGroup's approach-zone activation gate.
## (Ported from the Staffer + Clipper version: the Staffer + Rover run is the
## direct successor; the Night Guard + Rover run covers the shipped E07/E09
## pairing, whose Brawler has the SWING strike instead of the lunge.)

const BlockScript := preload("res://scripts/world/block.gd")
const STAFFER := "res://scenes/actors/staffer.tscn"
const NIGHT_GUARD := "res://scenes/actors/night_guard.tscn"
const ROVER := "res://scenes/actors/patrol_rover.tscn"


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
	await _test_fairness_over_20_seconds("Staffer", STAFFER, "Rover", ROVER)
	await _test_fairness_over_20_seconds("Night Guard", NIGHT_GUARD, "Rover", ROVER)


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


## True while `e` is in its windup or its committed attack (the states that
## hold the group's attack token).
func _is_attacking(e: Node) -> bool:
	if e is PatrolRover:
		return e.state == PatrolRover.State.WINDUP or e.state == PatrolRover.State.CHARGE
	return e.state == Brawler.State.WINDUP or e.state == Brawler.State.STRIKE


func _test_fairness_over_20_seconds(label_a: String, scene_a: String, label_b: String, scene_b: String) -> void:
	var label := "%s + %s" % [label_a, label_b]
	Session.new_run()
	Session.state["health"] = 1000  # survive sustained contact for this token-sharing test
	var floor_b := _make_floor(0, 560, 1400)

	var group := EncounterGroup.new()
	group.lane_rect = Rect2(-500, -500, 2000, 1000)
	add_child(group)

	var enemy_a: Node2D = load(scene_a).instantiate()
	group.add_child(enemy_a)
	var enemy_b: Node2D = load(scene_b).instantiate()
	group.add_child(enemy_b)
	await physics_frames(1)
	enemy_a.global_position = Vector2(760, 560)
	enemy_b.global_position = Vector2(640, 560)

	var hero := _make_hero(Vector2(700, 560))
	await physics_frames(3)

	var enemies: Array = [enemy_a, enemy_b]
	var attacks := [0, 0]
	var was_active := [false, false]
	var max_concurrent := 0
	var violation_frame := -1

	var ticks := int(20.5 * 60.0)  # a bit over 20 simulated seconds
	for i in ticks:
		await physics_frames(1)
		var concurrent := 0
		for k in 2:
			var active: bool = is_instance_valid(enemies[k]) and _is_attacking(enemies[k])
			if active and not was_active[k]:
				attacks[k] += 1
			was_active[k] = active
			concurrent += int(active)
		max_concurrent = maxi(max_concurrent, concurrent)
		if concurrent > 1 and violation_frame < 0:
			violation_frame = i

	check(violation_frame < 0,
			"%s: never more than one enemy is windup/active-attacking at once (first violation at tick %d)" % [label, violation_frame])
	check(max_concurrent <= 1, "%s: max concurrent windup/active attackers over 20s is <=1 (got %d)" % [label, max_concurrent])
	check(attacks[0] >= 1, "%s: the %s got at least one attack turn over 20s (got %d)" % [label, label_a, attacks[0]])
	check(attacks[1] >= 1, "%s: the %s got at least one attack turn over 20s (got %d)" % [label, label_b, attacks[1]])
	print("[test_m2_mixed_lane] %s: %s attacks=%d, %s attacks=%d" % [label, label_a, attacks[0], label_b, attacks[1]])

	hero.queue_free()
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	group.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
