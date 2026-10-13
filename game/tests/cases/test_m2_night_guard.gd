extends TestCase
## M2 T04 for the SE01 Night Guard (the Brawler template with the baton
## SWING strike and a patrol): every swing is preceded by its full visible
## windup before the AttackBox goes live, the box is live only inside the
## swing's active window, one swing costs a stationary hero exactly 1 health,
## body overlap alone never hurts, and a hit never interrupts a windup or a
## swing (03-gameplay-systems.md). Its tell lights are test_enemy_tells.gd's;
## its rig, blood and ragdoll are test_lit_enemies.gd's.

const BlockScript := preload("res://scripts/world/block.gd")
const FLOOR_Y := 560.0
const FRAME := 1.0 / 60.0


func _make_floor() -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(0.0, FLOOR_Y)
	b.size = Vector2(2000.0, 200.0)
	add_child(b)
	return b


func _make_hero(x: float) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = Vector2(x, FLOOR_Y)
	hero.velocity = Vector2.ZERO
	hero.use_aim_override = true
	return hero


## No EncounterGroup ancestor: the guard attacks freely.
func _make_guard(x: float) -> Brawler:
	var g: Brawler = load("res://scenes/actors/night_guard.tscn").instantiate()
	add_child(g)
	g.global_position = Vector2(x, FLOOR_Y)
	await physics_frames(2)
	return g


func run() -> void:
	await _test_swing_warning_window_and_cost()
	await _test_no_damage_from_overlap_during_windup()
	await _test_hit_never_interrupts_windup_or_swing()
	await _test_flinch_while_walking_in()


func _test_swing_warning_window_and_cost() -> void:
	Session.new_run()
	var floor_b := _make_floor()
	var hero := _make_hero(300.0)
	var guard := await _make_guard(560.0)  # inside notice range: he walks in
	check(guard.tuning.strike == BrawlerTuning.Strike.SWING, "the Night Guard's strike is the baton swing")

	var start_health := Session.get_health()
	var windup_ticks := 0
	var box_went_live := false
	var box_only_in_swing := true
	var saw_recovery := false
	for i in 600:
		await physics_frames(1)
		if not is_instance_valid(guard):
			break
		var live: bool = guard.attack_box.active
		if live:
			box_went_live = true
			var t: float = guard._state_timer
			box_only_in_swing = box_only_in_swing and guard.state == Brawler.State.STRIKE \
					and t >= guard.tuning.swing_active_from - FRAME and t <= guard.tuning.swing_active_to + FRAME
		elif not box_went_live and guard.state == Brawler.State.WINDUP:
			windup_ticks += 1
		if box_went_live and guard.state == Brawler.State.RECOVERY:
			saw_recovery = true
			break
	check(box_went_live and saw_recovery, "setup: the guard walked in, wound up, swung and recovered")
	check(box_only_in_swing, "the AttackBox is live only inside the swing's active window")
	var warned_s := windup_ticks / 60.0
	check(warned_s >= guard.tuning.windup_time - FRAME,
			"the box goes live only after the full %.2fs windup (observed %.3fs)" % [guard.tuning.windup_time, warned_s])
	check(not guard.attack_box.active, "the box is off again in the recovery")

	# Let the one swing (and any re-hit inside the immunity window) resolve;
	# the 1.2 s recovery keeps a second swing out of this window.
	await physics_frames(40)
	var lost: int = start_health - Session.get_health()
	check(lost == 1, "one baton swing on a stationary hero costs exactly 1 health (lost %d)" % lost)

	hero.queue_free()
	if is_instance_valid(guard):
		guard.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


func _test_no_damage_from_overlap_during_windup() -> void:
	Session.new_run()
	var floor_b := _make_floor()
	var hero := _make_hero(400.0)
	var guard := await _make_guard(400.0)  # exact body overlap
	await physics_frames(2)
	check(guard.state == Brawler.State.WINDUP, "an overlapping guard starts his visible windup")
	var start_health := Session.get_health()
	var box_quiet := true
	for i in int(guard.tuning.windup_time * 60.0) - 6:
		await physics_frames(1)
		box_quiet = box_quiet and not guard.attack_box.active and not guard.is_attack_active()
	check(box_quiet, "the AttackBox stays off through the windup")
	check(Session.get_health() == start_health, "full body overlap during the windup deals no damage")

	hero.queue_free()
	guard.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


func _test_hit_never_interrupts_windup_or_swing() -> void:
	Session.new_run()
	var floor_b := _make_floor()
	var hero := _make_hero(400.0)
	hero.debug_invulnerable = true
	var guard := await _make_guard(460.0)  # inside engage range
	await physics_frames(2)
	check(guard.state == Brawler.State.WINDUP, "setup: the guard is winding up")
	var t_before: float = guard._state_timer
	guard.hit_zone.take_hit(1, guard.global_position + Vector2(0.0, -60.0), Vector2.RIGHT)
	await physics_frames(1)
	check(guard.state == Brawler.State.WINDUP and guard._state_timer > t_before,
			"a hit during the windup neither cancels nor restarts it")
	check(guard.anim.clip == guard.tuning.clip_windup, "and he doesn't flinch out of the windup pose")
	for i in 60:
		if guard.state == Brawler.State.STRIKE:
			break
		await physics_frames(1)
	check(guard.state == Brawler.State.STRIKE, "setup: the guard swings")
	guard.hit_zone.take_hit(1, guard.global_position + Vector2(0.0, -60.0), Vector2.RIGHT)
	await physics_frames(1)
	check(is_instance_valid(guard) and guard.state == Brawler.State.STRIKE, "a hit during the swing does not cancel it")

	hero.queue_free()
	if is_instance_valid(guard):
		guard.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


## A shot that lands while he walks in plays the hit flinch and stops
## him for a moment; a second shot inside the cooldown doesn't stop him again
## (rapid fire can't pin him), and he walks on and swings.
func _test_flinch_while_walking_in() -> void:
	Session.new_run()
	var floor_b := _make_floor()
	var hero := _make_hero(300.0)
	hero.debug_invulnerable = true
	var guard := await _make_guard(700.0)
	for i in 60:
		if guard.state == Brawler.State.APPROACH and absf(guard.velocity.x) > 1.0:
			break
		await physics_frames(1)
	check(guard.state == Brawler.State.APPROACH, "setup: he is walking in")
	var hit_at := guard.global_position + Vector2(0.0, -60.0)
	guard.hit_zone.take_hit(1, hit_at, Vector2.RIGHT)
	await physics_frames(1)
	check(guard.anim.clip == guard.tuning.clip_hit, "a shot while he walks in plays the hit flinch (clip %s)" % guard.anim.clip)
	var x0 := guard.global_position.x
	await physics_frames(int(guard.tuning.hit_stagger_time * 60.0) - 4)
	check(absf(guard.global_position.x - x0) < 1.0, "he stops for the flinch")
	guard.hit_zone.take_hit(1, hit_at, Vector2.RIGHT)
	await physics_frames(12)
	check(absf(guard.global_position.x - x0) > 4.0, "a second shot inside the cooldown doesn't stop him again")
	var swung := false
	for i in 240:
		await physics_frames(1)
		if not is_instance_valid(guard):
			break
		if guard.state == Brawler.State.WINDUP:
			swung = true
			break
	check(swung, "he walks on and winds up his swing")
	hero.queue_free()
	if is_instance_valid(guard):
		guard.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
