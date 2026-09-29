extends TestCase
## REGRESSION (R1-01 / R1-02): Staffer lunge AttackBox geometry (must only
## ever be on the facing/lunge side of the body, never reach a hero standing
## behind it) and lane leash (a lunge must not push the Staffer out of its
## EncounterGroup lane, and if it ever ends up outside, it must be able to
## walk back in rather than getting stuck).

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
	hero.use_aim_override = true
	return hero


func run() -> void:
	await _probe_front_lunge_damages()
	await _probe_lunge_hits_hero_behind()
	await _probe_lunge_leaves_lane_and_sticks()


func _probe_front_lunge_damages() -> void:
	Session.new_run()
	var f := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(300, 560))
	var r: Staffer = load("res://scenes/actors/staffer.tscn").instantiate()
	add_child(r)
	r.global_position = Vector2(400, 560)
	await physics_frames(90)
	var lost := 6 - Session.get_health()
	print("PROBE front_lunge lost=%d" % lost)
	check(lost == 1, "control: a frontal lunge on a stationary hero at 100px deals 1 damage (lost %d)" % lost)
	hero.queue_free(); r.queue_free(); f.queue_free()
	await physics_frames(2)


func _probe_lunge_hits_hero_behind() -> void:
	Session.new_run()
	var f := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(300, 560))
	var r: Staffer = load("res://scenes/actors/staffer.tscn").instantiate()
	add_child(r)
	r.global_position = Vector2(400, 560)
	await physics_frames(3)
	check(r.state == Staffer.State.WINDUP, "staffer winds up facing LEFT toward hero")
	var lunge_dir := r._lunge_dir
	# During the windup the hero relocates BEHIND the staffer (e.g. after
	# jumping over it), 40px behind its centre.
	hero.global_position = Vector2(440, 560)
	await physics_frames(90)
	var lost := 6 - Session.get_health()
	print("PROBE behind_lunge lunge_dir=%d hero_dx=+40 lost=%d" % [lunge_dir, lost])
	check(lost == 0, "a lunge committed to the LEFT must not damage a hero standing 40px BEHIND (right of) the Staffer (lost %d)" % lost)
	hero.queue_free(); r.queue_free(); f.queue_free()
	await physics_frames(2)


func _probe_lunge_leaves_lane_and_sticks() -> void:
	Session.new_run()
	Session.state["health"] = 100
	var f := _make_floor(-400, 560, 2000)
	var group := EncounterGroup.new()
	group.lane_rect = Rect2(380, -500, 750, 1200)
	add_child(group)
	var r: Staffer = load("res://scenes/actors/staffer.tscn").instantiate()
	group.add_child(r)
	await physics_frames(1)
	r.global_position = Vector2(400, 560)
	var hero := _make_hero(Vector2(310, 560))  # just outside the lane, within engage range
	await physics_frames(60)  # windup (0.65s) + lunge
	await physics_frames(60)  # recovery
	var after_lunge_x := r.global_position.x
	var in_lane_after := group.is_in_lane(r.global_position)
	# Hero now walks back deep into the lane; Staffer should rejoin/pursue.
	hero.global_position = Vector2(900, 560)
	await physics_frames(300)  # 5s at 76.8px/s would cover ~380px
	print("PROBE lane: after_lunge_x=%.1f in_lane=%s  x_after_5s=%.1f in_lane=%s" % [after_lunge_x, str(in_lane_after), r.global_position.x, str(group.is_in_lane(r.global_position))])
	check(in_lane_after, "the Staffer's lunge keeps it inside its lane_rect (x=%.1f, lane starts 380)" % after_lunge_x)
	check(r.global_position.x > after_lunge_x + 50.0, "the Staffer can walk back toward a hero inside its lane (x %.1f -> %.1f)" % [after_lunge_x, r.global_position.x])
	hero.queue_free(); group.queue_free(); f.queue_free()
	await physics_frames(2)
