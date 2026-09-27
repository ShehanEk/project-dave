extends TestCase
## M2 T03/T04: Resident body shots damage it, every lunge is preceded by a
## visible windup of at least 0.6s before AttackBox activates, one lunge
## costs at most 1 health, no damage from body overlap alone, defeated-once
## + not re-instanced, and a stage-0 bot can beat it without taking damage.

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


func _make_resident(pos: Vector2, entity_id: String = "") -> Resident:
	var r: Resident = load("res://scenes/actors/resident.tscn").instantiate()
	r.entity_id = entity_id
	add_child(r)
	r.global_position = pos
	await physics_frames(1)
	return r


func run() -> void:
	await _test_body_shots_damage_and_defeat()
	await _test_no_damage_from_overlap_before_windup_ends()
	await _test_lunge_warning_and_cost()
	await _test_defeated_once_and_not_reinstanced()
	await _test_stage0_bot_beats_resident()


func _test_body_shots_damage_and_defeat() -> void:
	var floor_b := _make_floor(0, 560, 2000)
	var resident := await _make_resident(Vector2(500, 560))
	var defeat_count := [0]
	resident.defeated.connect(func(_id): defeat_count[0] += 1)

	# Three body shots (any point on the whole-body HitZone) at 1 damage each
	# defeat a 3-health Resident.
	for i in 3:
		var outcome: StringName = resident.hit_zone.take_hit(1, resident.global_position, Vector2.LEFT)
		check(outcome == &"hit", "a body shot on the Resident's whole-body HitZone is accepted (shot %d)" % (i + 1))
		await physics_frames(1)

	check(defeat_count[0] == 1, "Resident emits defeated exactly once (got %d)" % defeat_count[0])
	await physics_frames(int(Resident.DEFEAT_FADE_TIME * 60.0) + 5)
	check(not is_instance_valid(resident), "a defeated Resident removes itself")

	floor_b.queue_free()
	await physics_frames(1)


func _test_no_damage_from_overlap_before_windup_ends() -> void:
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(300, 560))
	var resident := await _make_resident(Vector2(300, 560))  # exact body overlap
	check(resident.state == Resident.State.WINDUP,
			"a Resident within engage range immediately begins its visible windup")

	var start_health := Session.get_health()
	# A safe margin under windup_time (0.65s = 39 ticks): count is 1 tick
	# short already (the transition tick itself, observed above) so this
	# still finishes comfortably before the windup ends.
	var windup_frames: int = int(resident.tuning.windup_time * 60.0) - 6
	for i in windup_frames:
		await physics_frames(1)
		if is_instance_valid(resident):
			check(not resident.attack_box.active,
					"AttackBox stays inactive during the windup (frame %d)" % i)

	check(Session.get_health() == start_health,
			"full body overlap during approach/windup deals no damage (start=%d, now=%d)" % [start_health, Session.get_health()])
	check(resident.state == Resident.State.WINDUP,
			"Resident is still visibly winding up just before the windup ends")

	hero.queue_free()
	resident.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_lunge_warning_and_cost() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(300, 560))
	var resident := await _make_resident(Vector2(400, 560))  # inside engage_range (108px)

	check(resident.tuning.windup_time >= 0.6,
			"the Resident windup_time seed itself is >=0.6s (T04's minimum warning)")

	var start_health := Session.get_health()
	var saw_windup: bool = resident.state == Resident.State.WINDUP
	var warned_ticks := 0
	var attack_became_active := false
	for i in 200:
		await physics_frames(1)
		if not is_instance_valid(resident):
			break
		if resident.state == Resident.State.WINDUP:
			saw_windup = true
			if not resident.attack_box.active:
				warned_ticks += 1
		if saw_windup and resident.attack_box.active:
			attack_became_active = true
			break

	check(saw_windup, "Resident entered a visible windup")
	check(attack_became_active, "Resident's AttackBox eventually activates (the lunge)")
	var warned_s: float = warned_ticks / 60.0
	check(warned_s >= 0.6,
			"AttackBox activates only after >=0.6s of continuously-observed windup (got %.3fs)" % warned_s)

	# Let the lunge (and any single immunity-window re-hit) fully resolve.
	await physics_frames(90)
	var lost: int = start_health - Session.get_health()
	check(lost == 1, "one Resident lunge in front of a stationary hero costs exactly 1 health (lost %d)" % lost)

	hero.queue_free()
	if is_instance_valid(resident):
		resident.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_defeated_once_and_not_reinstanced() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var entity_id := "L01-TEST-Z01-01"
	var resident := await _make_resident(Vector2(500, 560), entity_id)
	var defeat_count := [0]
	resident.defeated.connect(func(_id): defeat_count[0] += 1)

	for i in 3:
		resident.hit_zone.take_hit(1, resident.global_position, Vector2.LEFT)
		await physics_frames(1)
	# Further hits after death must not re-trigger defeat.
	resident.hit_zone.take_hit(1, resident.global_position, Vector2.LEFT)
	await physics_frames(int(Resident.DEFEAT_FADE_TIME * 60.0) + 5)

	check(defeat_count[0] == 1, "mark_defeated/defeated fires exactly once (got %d)" % defeat_count[0])
	check(Session.is_defeated(entity_id), "Session records the Resident as defeated")
	check(not is_instance_valid(resident), "the defeated Resident node is gone")

	var respawned := await _make_resident(Vector2(500, 560), entity_id)
	await physics_frames(2)
	check(not is_instance_valid(respawned),
			"re-instancing the same entity_id after Session marks it defeated removes it immediately")

	floor_b.queue_free()
	await physics_frames(1)


func _test_stage0_bot_beats_resident() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(100, 560))
	# Far outside engage_range (108px); at 0.8H/s approach speed the Resident
	# cannot close that gap before three stage-0 shots (interval 0.32s) land.
	var resident := await _make_resident(Vector2(500, 560))
	hero.aim_override = resident.global_position
	await physics_frames(3)

	var start_health := Session.get_health()
	press("fire")
	var frame := 0
	while is_instance_valid(resident) and frame < 180:
		await physics_frames(1)
		frame += 1
		if is_instance_valid(hero) and is_instance_valid(resident):
			hero.aim_override = resident.global_position
	release("fire")

	check(not is_instance_valid(resident), "a stage-0 pistol defeats a Resident before it can close to engage range")
	check(Session.get_health() == start_health,
			"the hero takes no unavoidable damage while beating a Resident from outside its engage range")

	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
