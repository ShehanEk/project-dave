extends TestCase
## M2 T03/T04: Staffer (the Brawler template with the LK01 tuning: LUNGE
## strike, dormant until its encounter is active) body shots damage it, every
## lunge is preceded by a visible windup of at least 0.6s before AttackBox
## activates, one lunge costs at most 1 health, no damage from body overlap
## alone, defeated-once + not re-instanced, and a stage-0 bot can beat it
## without taking damage. (Ported from the old Staffer test: the Staffer's
## behaviour and timings carried over; its health is now tuning data and the
## body becomes a ragdoll at once instead of fading.)

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


## A Staffer starts DORMANT and wakes on its first physics tick (no
## EncounterGroup ancestor: "attacks freely", so its group counts as active);
## the second frame lets a hero already inside engage_range start the windup,
## which is what the first frame used to do before the Staffer had a dormant
## state.
func _make_staffer(pos: Vector2, entity_id: String = "") -> Brawler:
	var r: Brawler = load("res://scenes/actors/staffer.tscn").instantiate()
	r.entity_id = entity_id
	add_child(r)
	r.global_position = pos
	await physics_frames(2)
	return r


func run() -> void:
	await _test_body_shots_damage_and_defeat()
	await _test_no_damage_from_overlap_before_windup_ends()
	await _test_lunge_warning_and_cost()
	await _test_defeated_once_and_not_reinstanced()
	await _test_stage0_bot_beats_staffer()


func _test_body_shots_damage_and_defeat() -> void:
	var floor_b := _make_floor(0, 560, 2000)
	var staffer := await _make_staffer(Vector2(500, 560))
	var defeat_count := [0]
	staffer.defeated.connect(func(_id): defeat_count[0] += 1)
	var health: int = staffer.tuning.health
	var body_name := "Body_" + String(staffer.name)
	var had_rig: bool = staffer.rig != null

	check(staffer.hit_zone.bleeds, "the Staffer's whole-body HitZone bleeds (a person: no green hit spark)")
	# `health` body shots (any point on the whole-body HitZone) at 1 damage
	# each defeat the Staffer; the last one is the killing blow.
	for i in health:
		var outcome: StringName = staffer.hit_zone.take_hit(1, staffer.global_position, Vector2.LEFT)
		check(outcome == &"hit", "a body shot on the Staffer's whole-body HitZone is accepted (shot %d)" % (i + 1))
		if i < health - 1:
			check(is_instance_valid(staffer) and staffer.health == health - (i + 1),
					"shot %d takes exactly 1 health (health %d)" % [i + 1, staffer.health])
			await physics_frames(1)

	check(defeat_count[0] == 1, "Staffer emits defeated exactly once (got %d)" % defeat_count[0])
	# The old 0.35 s defeat fade is gone: the Staffer frees itself at once.
	await physics_frames(3)
	check(not is_instance_valid(staffer), "a defeated Staffer removes itself at once")
	# Its ragdoll stays behind under the Staffer's parent (no AreaRoot here);
	# only built when the rig loaded (a missing rig.json skips the visuals).
	if had_rig:
		check(get_node_or_null(body_name) != null, "a defeated Staffer leaves a %s ragdoll behind" % body_name)

	floor_b.queue_free()
	await physics_frames(1)


func _test_no_damage_from_overlap_before_windup_ends() -> void:
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(300, 560))
	var staffer := await _make_staffer(Vector2(300, 560))  # exact body overlap
	check(staffer.state == Brawler.State.WINDUP,
			"a Staffer within engage range begins its visible windup as soon as it wakes")

	var start_health := Session.get_health()
	# A safe margin under windup_time (0.65s = 39 ticks): the windup is
	# already running (the transition tick itself, observed above), so this
	# still finishes comfortably before the windup ends.
	var windup_frames: int = int(staffer.tuning.windup_time * 60.0) - 6
	for i in windup_frames:
		await physics_frames(1)
		if is_instance_valid(staffer):
			check(not staffer.attack_box.active,
					"AttackBox stays inactive during the windup (frame %d)" % i)
			check(not staffer.is_attack_active(), "is_attack_active() is false during the windup (frame %d)" % i)

	check(Session.get_health() == start_health,
			"full body overlap during approach/windup deals no damage (start=%d, now=%d)" % [start_health, Session.get_health()])
	check(staffer.state == Brawler.State.WINDUP,
			"Staffer is still visibly winding up just before the windup ends")
	check(staffer.is_windup_active(), "is_windup_active() is true while winding up")

	hero.queue_free()
	staffer.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_lunge_warning_and_cost() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(300, 560))
	var staffer := await _make_staffer(Vector2(400, 560))  # inside engage_range (108px)

	check(staffer.tuning.windup_time >= 0.6,
			"the Staffer windup_time seed itself is >=0.6s (T04's minimum warning)")
	check(staffer.tuning.strike == BrawlerTuning.Strike.LUNGE, "the Staffer's strike is the low lunge")

	var start_health := Session.get_health()
	var saw_windup: bool = staffer.state == Brawler.State.WINDUP
	var warned_ticks := 0
	var attack_became_active := false
	for i in 200:
		await physics_frames(1)
		if not is_instance_valid(staffer):
			break
		if staffer.state == Brawler.State.WINDUP:
			saw_windup = true
			if not staffer.attack_box.active:
				warned_ticks += 1
		if saw_windup and staffer.attack_box.active:
			attack_became_active = true
			check(staffer.state == Brawler.State.STRIKE and staffer.is_attack_active(),
					"the AttackBox goes live only in the STRIKE state")
			break

	check(saw_windup, "Staffer entered a visible windup")
	check(attack_became_active, "Staffer's AttackBox eventually activates (the lunge)")
	var warned_s: float = warned_ticks / 60.0
	check(warned_s >= 0.6,
			"AttackBox activates only after >=0.6s of continuously-observed windup (got %.3fs)" % warned_s)

	# Let the lunge (and any single immunity-window re-hit) fully resolve.
	await physics_frames(90)
	var lost: int = start_health - Session.get_health()
	check(lost == 1, "one Staffer lunge in front of a stationary hero costs exactly 1 health (lost %d)" % lost)

	hero.queue_free()
	if is_instance_valid(staffer):
		staffer.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_defeated_once_and_not_reinstanced() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var entity_id := "L01-TEST-LK01-01"
	var staffer := await _make_staffer(Vector2(500, 560), entity_id)
	var defeat_count := [0]
	staffer.defeated.connect(func(_id): defeat_count[0] += 1)
	var had_rig: bool = staffer.rig != null

	for i in staffer.tuning.health:
		staffer.hit_zone.take_hit(1, staffer.global_position, Vector2.LEFT)
	# Further hits after death must not re-trigger defeat. The node is only
	# freed at the end of the frame, so the same frame is where a late hit
	# could still land on it.
	if is_instance_valid(staffer):
		staffer.hit_zone.take_hit(1, staffer.global_position, Vector2.LEFT)
	await physics_frames(3)

	check(defeat_count[0] == 1, "mark_defeated/defeated fires exactly once (got %d)" % defeat_count[0])
	check(Session.is_defeated(entity_id), "Session records the Staffer as defeated")
	check(not is_instance_valid(staffer), "the defeated Staffer node is gone")
	if had_rig:
		check(get_node_or_null("Body_" + entity_id) != null, "the defeated Staffer leaves a Body_<entity_id> ragdoll behind")

	var respawned := await _make_staffer(Vector2(500, 560), entity_id)
	await physics_frames(2)
	check(not is_instance_valid(respawned),
			"re-instancing the same entity_id after Session marks it defeated removes it immediately")

	floor_b.queue_free()
	await physics_frames(1)


func _test_stage0_bot_beats_staffer() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(100, 560))
	# Far outside engage_range (108px); at 0.8H/s approach speed the Staffer
	# cannot close that gap before its `health` stage-0 shots (interval
	# 0.32s) land.
	var staffer := await _make_staffer(Vector2(500, 560))
	hero.aim_override = staffer.global_position
	await physics_frames(3)

	var start_health := Session.get_health()
	press("fire")
	var frame := 0
	while is_instance_valid(staffer) and frame < 180:
		await physics_frames(1)
		frame += 1
		if is_instance_valid(hero) and is_instance_valid(staffer):
			hero.aim_override = staffer.global_position
	release("fire")

	check(not is_instance_valid(staffer), "a stage-0 pistol defeats a Staffer before it can close to engage range")
	check(Session.get_health() == start_health,
			"the hero takes no unavoidable damage while beating a Staffer from outside its engage range")

	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
