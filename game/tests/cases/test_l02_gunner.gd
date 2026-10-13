extends TestCase
## M4: the SE02 Sidearm Guard (the Gunner template, the EG01 pistol) against the
## fairness rules (encounter-and-boss-fairness.md, P23):
##   - the tell: the muzzle lamp amber, then red for exactly the last red_time (0.25 s),
##     the aim locked at red; no round before the tell ends;
##   - on Dave's floor the round is flat at 0.5 H, a held jump clears it, a 0.6 H crate
##     stops it, it costs 1 health when it hits, and it reaches at most 6.5 H;
##   - never at an airborne Dave: no tell starts while he is in the air, and the aim
##     never follows him up;
##   - the readability gate: no tell, and no round, within 1 H of the camera's edge;
##   - from another floor the round flies at Dave's last grounded spot (+0.5 H), the aim
##     following at most 3 H/s through amber and locked at red;
##   - one round alive at a time; the reload roots him for 1.2 s, and the base Scrapjack
##     kills him (3 hits) inside that window;
##   - a death leaves a body and a dropped pistol, records the defeat, and a re-instance
##     with the same entity id removes itself.

const BlockScript := preload("res://scripts/world/block.gd")
const FLOOR_Y := 560.0
const H := 96.0


func _block(x: float, y: float, w: float, h: float) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	add_child(b)
	return b


func _hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.use_aim_override = true
	hero.aim_override = pos + Vector2(200.0, -40.0)
	return hero


func _gunner(pos: Vector2, entity_id: String = "", tuning: GunnerTuning = null) -> Gunner:
	var g: Gunner = load("res://scenes/actors/sidearm_guard.tscn").instantiate()
	g.entity_id = entity_id
	if tuning != null:
		g.tuning = tuning
	add_child(g)
	g.global_position = pos
	await physics_frames(2)
	return g


func _clear() -> void:
	release_all()
	for c in get_children():
		c.queue_free()
	await physics_frames(2)


## Waits until `cond` holds or `timeout` seconds pass; true if it held.
func _until(cond: Callable, timeout: float) -> bool:
	var frames := int(timeout * 60.0)
	for i in frames:
		if cond.call():
			return true
		await physics_frames(1)
	return cond.call()


func run() -> void:
	await _test_tell_timing_and_flat_round()
	await _test_jump_clears_the_flat_round()
	await _test_low_crate_stops_the_round()
	await _test_round_range()
	await _test_never_starts_at_an_airborne_dave()
	await _test_camera_gate()
	await _test_aimed_shot_from_another_floor()
	await _test_steps_up_to_the_edge()
	await _test_one_round_alive()
	await _test_reload_window_and_scrapjack_kill()
	await _test_death_and_defeat_record()


func _test_tell_timing_and_flat_round() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(300, FLOOR_Y))
	var g := await _gunner(Vector2(700, FLOOR_Y))
	var rounds: Array = []
	g.fired.connect(func(r): rounds.append(r))
	check(g.tuning.red_time == 0.25, "the tell's red part is 0.25 s (P23)")
	check(g.tuning.round_range_h <= 6.5, "the pistol reaches at most 6.5 H")
	var started := await _until(func(): return g.state == Gunner.State.AIM, 2.0)
	check(started, "a Sidearm Guard within range of a grounded Dave starts the tell")
	var amber_frames := 0
	var red_frames := 0
	var order_ok := true
	var lock_matches_red := true
	var seen_red := false
	var health := Session.get_health()
	while g.state == Gunner.State.AIM:
		check(rounds.is_empty(), "no round leaves during the tell")
		var c: Color = g.tell_color()
		if c == Gunner.ALARM:
			red_frames += 1
			seen_red = true
		elif c == Gunner.AMBER:
			amber_frames += 1
			if seen_red:
				order_ok = false
		if g.is_aim_locked() != g.is_tell_red():
			lock_matches_red = false
		await physics_frames(1)
	var amber_s := amber_frames / 60.0
	var red_s := red_frames / 60.0
	check(order_ok, "the lamp is amber first, then red, never back")
	check(absf(red_s - 0.25) <= 1.5 / 60.0, "red lasts the last 0.25 s of the tell (%.3f s)" % red_s)
	check(absf(amber_s + red_s - g.tuning.windup_time) <= 2.0 / 60.0,
			"the whole tell lasts windup_time (%.3f s)" % (amber_s + red_s))
	check(lock_matches_red, "the aim locks exactly when the lamp turns red (the lock click)")
	check(rounds.size() == 1, "exactly one round per tell (%d)" % rounds.size())
	if rounds.size() == 1:
		var r: EnemyRound = rounds[0]
		check(r.direction.is_equal_approx(Vector2.LEFT), "on Dave's floor the round flies flat, toward him (%s)" % str(r.direction))
		check(absf(r.global_position.y - (FLOOR_Y - 0.5 * H)) <= 0.6, "the round flies at 0.5 H (y %.1f)" % r.global_position.y)
		check(absf(r.speed - 9.0 * H) < 0.5, "the round flies at 9 H/s")
	await _until(func(): return rounds.is_empty() or not is_instance_valid(rounds[0]), 1.0)
	check(Session.get_health() == health - 1, "the round costs a standing Dave exactly 1 health (lost %d)" % (health - Session.get_health()))
	check(hero._knockback.length() <= hero.tuning.knockback_speed * 0.5 + 1.0, "a round's hit uses half knockback")
	await _clear()


func _test_jump_clears_the_flat_round() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(420, FLOOR_Y))
	var g := await _gunner(Vector2(760, FLOOR_Y))
	var health := Session.get_health()
	await _until(func(): return g.is_tell_red(), 3.0)
	await seconds(0.12)
	press("jump")
	var rounds: Array = []
	g.fired.connect(func(r): rounds.append(r))
	var cleared := false
	for i in 50:
		await physics_frames(1)
		if not rounds.is_empty() and is_instance_valid(rounds[0]) and rounds[0].global_position.x < hero.global_position.x - 30.0:
			cleared = true
	release("jump")
	await seconds(0.8)
	check(not rounds.is_empty(), "the guard fired")
	check(cleared, "the flat round passed under a held jump")
	check(Session.get_health() == health, "a held jump clears the flat round (no damage)")
	await _clear()


func _test_low_crate_stops_the_round() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var crate := _block(420, FLOOR_Y - 0.6 * H, 48, 0.6 * H)
	var hero := _hero(Vector2(340, FLOOR_Y))
	hero.aim_override = Vector2(800, FLOOR_Y - 60.0)
	var g := await _gunner(Vector2(800, FLOOR_Y))
	var outcomes: Array = []
	g.fired.connect(func(r): r.resolved.connect(func(o, at): outcomes.append([o, at])))
	var health := Session.get_health()
	var fired := await _until(func(): return not outcomes.is_empty(), 4.0)
	check(fired, "the guard fires at Dave behind a low crate (he sees him over it)")
	if not outcomes.is_empty():
		check(outcomes[0][0] == &"blocked", "the flat round hits the crate (%s)" % str(outcomes[0][0]))
		var at: Vector2 = outcomes[0][1]
		check(absf(at.x - (crate.position.x + 48.0)) <= 12.0, "it stops at the crate's face (x %.1f)" % at.x)
	check(Session.get_health() == health, "a 0.6 H crate keeps Dave safe")
	await _clear()


func _test_round_range() -> void:
	_block(-200, FLOOR_Y, 2400, 200)
	var r: EnemyRound = load("res://scenes/weapons/pistol_round.tscn").instantiate()
	add_child(r)
	var start := Vector2(1600, FLOOR_Y - 48.0)
	r.setup(start, Vector2.LEFT, 9.0 * H, 6.5 * H)
	var outcome := [&"", Vector2.ZERO]
	r.resolved.connect(func(o, at): outcome[0] = o; outcome[1] = at)
	await seconds(1.0)
	check(outcome[0] == &"expired", "a round with nothing in its way expires (%s)" % str(outcome[0]))
	check(absf(start.x - outcome[1].x) <= 6.5 * H + 15.0, "it travels at most 6.5 H (%.0f px)" % absf(start.x - outcome[1].x))
	await _clear()


func _test_never_starts_at_an_airborne_dave() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(400, FLOOR_Y))
	var g := await _gunner(Vector2(800, FLOOR_Y))
	await physics_frames(1)
	# Dave goes up into the air before the guard is ready.
	hero.global_position = Vector2(400, FLOOR_Y - 420.0)
	hero.velocity = Vector2.ZERO
	var aimed_airborne := false
	var landed := false
	var was: int = g.state
	for i in 120:
		await physics_frames(1)
		if g.state == Gunner.State.AIM and was != Gunner.State.AIM and not hero.is_on_floor():
			aimed_airborne = true
		was = g.state
		if hero.is_on_floor():
			landed = true
			break
	check(landed, "setup: Dave lands")
	check(not aimed_airborne, "no tell starts while Dave is in the air")
	var started := await _until(func(): return g.state == Gunner.State.AIM, 1.0)
	check(started, "the tell starts once Dave stands on the floor")
	# He jumps during the amber part: the aim stays on his grounded spot.
	press("jump")
	await seconds(0.2)
	release("jump")
	check(not hero.is_on_floor(), "setup: Dave is in the air during the tell")
	var p: Vector2 = g.locked_aim_point()
	check(absf(p.y - (FLOOR_Y - 0.5 * H)) <= 0.6, "the aim stays at his grounded spot + 0.5 H, never on him in the air (y %.1f)" % p.y)
	await _clear()


func _test_camera_gate() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 3000, 200)
	var hero := _hero(Vector2(400, FLOOR_Y))
	var cam := Camera2D.new()
	add_child(cam)
	cam.make_current()
	var half: Vector2 = get_viewport().get_visible_rect().size * 0.5 / cam.zoom
	var gx := 800.0
	# The guard 0.5 H inside the right edge: too close.
	cam.global_position = Vector2(gx - half.x + 0.5 * H, FLOOR_Y - 100.0)
	await physics_frames(2)
	var g := await _gunner(Vector2(gx, FLOOR_Y))
	check(not g.is_on_camera(), "setup: within 1 H of the camera's edge the gate is shut")
	var aimed := await _until(func(): return g.state == Gunner.State.AIM, 1.5)
	check(not aimed, "no tell starts within 1 H of the camera's edge")
	cam.global_position = Vector2(gx - half.x + 2.5 * H, FLOOR_Y - 100.0)
	await physics_frames(2)
	check(g.is_on_camera(), "setup: 2.5 H inside the edge the gate is open")
	aimed = await _until(func(): return g.state == Gunner.State.AIM, 1.5)
	check(aimed, "well inside the view he starts the tell")
	var rounds: Array = []
	g.fired.connect(func(r): rounds.append(r))
	# The view slides off him before the tell ends: he holds his fire.
	cam.global_position = Vector2(gx - half.x + 0.3 * H, FLOOR_Y - 100.0)
	await _until(func(): return g.state != Gunner.State.AIM, 2.0)
	await physics_frames(3)
	check(rounds.is_empty(), "no round leaves while he is within 1 H of the edge")
	check(g.state != Gunner.State.RELOAD, "a held shot is not a reload")
	cam.queue_free()
	await _clear()


func _test_aimed_shot_from_another_floor() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	# A raised step 1.5 H up, the guard on it, Dave on the floor below.
	var step := _block(700, FLOOR_Y - 1.5 * H, 400, 1.5 * H)
	var hero := _hero(Vector2(380, FLOOR_Y))
	var g := await _gunner(Vector2(900, step.position.y))
	var rounds: Array = []
	g.fired.connect(func(r): rounds.append(r))
	var started := await _until(func(): return g.state == Gunner.State.AIM, 3.0)
	check(started, "the guard on the step aims at Dave below")
	# Dave walks left through the amber part: the aim follows at most 3 H/s.
	press("move_left")
	var max_step := 0.0
	var prev: Vector2 = g.locked_aim_point()
	while g.state == Gunner.State.AIM and not g.is_aim_locked():
		await physics_frames(1)
		var p: Vector2 = g.locked_aim_point()
		max_step = maxf(max_step, p.distance_to(prev))
		prev = p
	release("move_left")
	check(max_step <= 3.0 * H / 60.0 + 0.05, "the aim point follows at most 3 H/s (%.2f px/frame)" % max_step)
	check(g.is_aim_locked(), "the aim locks at red")
	var locked: Vector2 = g.locked_aim_point()
	check(not g._flat, "a shot at another floor is not the flat line")
	check(absf(locked.y - (FLOOR_Y - 0.5 * H)) <= 0.6, "it aims at his grounded height + 0.5 H")
	# After the lock Dave runs right: the round still goes at the locked spot.
	press("move_right")
	await _until(func(): return not rounds.is_empty(), 1.0)
	release("move_right")
	check(rounds.size() == 1, "one round")
	if rounds.size() == 1:
		var r: EnemyRound = rounds[0]
		var to_lock := (locked - r.global_position)
		var off := absf(to_lock.cross(r.direction))
		check(off <= 1.0, "the round flies through the locked spot, not at where Dave went (%.2f px off)" % off)
		check(r.direction.y > 0.05, "it flies down toward the floor")
	await _clear()


## Far back on a step, the line from his muzzle down to Dave clips the step's edge: he
## walks to the edge (never off it) and only then aims.
func _test_steps_up_to_the_edge() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var step := _block(600, FLOOR_Y - 1.5 * H, 600, 1.5 * H)
	var hero := _hero(Vector2(380, FLOOR_Y))
	hero.debug_invulnerable = true
	var g := await _gunner(Vector2(1000, step.position.y))
	check(not g._shot_clear(g._ground_target(hero.global_position)), "setup: from far back the step's edge is in the way")
	var aimed := await _until(func(): return g.state == Gunner.State.AIM, 4.0)
	check(aimed, "he aims once he has a clear line")
	check(g.global_position.x < 800.0, "he walked up toward the edge until the line was clear (x %.0f)" % g.global_position.x)
	check(g.global_position.x > 600.0 and absf(g.global_position.y - step.position.y) < 1.0, "and stayed on the step")
	var outcome := [&""]
	g.fired.connect(func(r): r.resolved.connect(func(o, _at): outcome[0] = o))
	await _until(func(): return outcome[0] != &"", 2.0)
	check(outcome[0] == &"hit", "his round reaches Dave below, not the step's edge (%s)" % str(outcome[0]))
	await _clear()


func _test_one_round_alive() -> void:
	Session.new_run()
	_block(-400, FLOOR_Y, 3000, 200)
	var t: GunnerTuning = load("res://data/tuning/sidearm_guard.tres").duplicate()
	t.reload_time = 0.05
	t.rest_time = 0.0
	t.round_speed_h_per_s = 2.0
	var hero := _hero(Vector2(250, FLOOR_Y))
	hero.debug_invulnerable = true
	var g := await _gunner(Vector2(800, FLOOR_Y), "", t)
	var most := 0
	var aimed_with_live := false
	for i in 240:
		await physics_frames(1)
		var n: int = get_tree().get_nodes_in_group("enemy_round").size()
		most = maxi(most, n)
		if g.state == Gunner.State.AIM and g._state_timer <= 1.0 / 60.0 + 0.0001 and g.live_round_count() > 0:
			aimed_with_live = true
	check(most == 1, "one of his rounds alive at a time (most %d)" % most)
	check(not aimed_with_live, "no new tell while his round is alive")
	await _clear()


func _test_reload_window_and_scrapjack_kill() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var hero := _hero(Vector2(450, FLOOR_Y))
	hero.debug_invulnerable = true
	var g := await _gunner(Vector2(800, FLOOR_Y), "")
	hero.aim_override = g.global_position + Vector2(0.0, -60.0)
	await _until(func(): return g.state == Gunner.State.RELOAD, 3.0)
	check(g.is_reloading(), "after the shot he racks the slide")
	var x := g.global_position.x
	var frames := 0
	var rooted := true
	while is_instance_valid(g) and g.state == Gunner.State.RELOAD and frames < 200:
		if absf(g.global_position.x - x) > 0.01 or absf(g.velocity.x) > 0.0:
			rooted = false
		await physics_frames(1)
		frames += 1
	check(rooted, "the reload roots him")
	check(absf(frames / 60.0 - g.tuning.reload_time) <= 2.0 / 60.0 if is_instance_valid(g) else false,
			"the reload lasts 1.2 s (%.3f s)" % (frames / 60.0))
	await _clear()
	# The punish: fire from 3.6 H away as the rack starts; three base hits kill him in the window.
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	hero = _hero(Vector2(450, FLOOR_Y))
	hero.debug_invulnerable = true
	var id := "L02-TEST-SE02-01"
	g = await _gunner(Vector2(800, FLOOR_Y), id)
	check(g.tuning.health == 3, "a Sidearm Guard takes 3 hits")
	hero.aim_override = g.global_position + Vector2(0.0, -60.0)
	await _until(func(): return g.state == Gunner.State.RELOAD, 3.0)
	press("fire")
	var t := 0
	while is_instance_valid(g) and g.state != Gunner.State.DEFEATED and t < 120:
		await physics_frames(1)
		t += 1
	release("fire")
	check(not is_instance_valid(g) or g.state == Gunner.State.DEFEATED, "the base Scrapjack kills him")
	check(t / 60.0 <= 1.2, "inside the 1.2 s reload (%.2f s)" % (t / 60.0))
	await _clear()


func _test_death_and_defeat_record() -> void:
	Session.new_run()
	_block(-200, FLOOR_Y, 2400, 200)
	var id := "L02-TEST-SE02-02"
	var g := await _gunner(Vector2(800, FLOOR_Y), id)
	var had_rig: bool = g.rig != null
	var had_gun: bool = g.gun != null
	check(had_rig, "the Sidearm Guard builds its lit rig (the Night Guard look for now)")
	check(had_gun, "the pistol prop hangs on his hand")
	if had_rig:
		check(not g.rig.joints.has("baton"), "the borrowed rig has no baton")
	check(g.hit_zone.bleeds, "he bleeds")
	var defeats := [0]
	g.defeated.connect(func(_id): defeats[0] += 1)
	for i in g.tuning.health:
		g.hit_zone.take_hit(1, g.global_position + Vector2(0, -60), Vector2.LEFT)
	if is_instance_valid(g):
		g.hit_zone.take_hit(1, g.global_position + Vector2(0, -60), Vector2.LEFT)
	await physics_frames(3)
	check(defeats[0] == 1, "defeated fires once (%d)" % defeats[0])
	check(Session.is_defeated(id), "Session records the defeat")
	check(not is_instance_valid(g), "the gunner node is gone")
	if had_rig:
		check(get_node_or_null("Body_" + id) != null, "he leaves a Body_<id> ragdoll")
	if had_gun:
		var drop := get_node_or_null("Gun_" + id)
		check(drop != null, "the pistol drops as a prop (Gun_<id>)")
		check(get_tree().get_nodes_in_group("pickup").is_empty(), "the dropped pistol is never a pickup")
	await seconds(3.5)
	var again := await _gunner(Vector2(800, FLOOR_Y), id)
	await physics_frames(1)
	check(not is_instance_valid(again), "a re-instance with the same entity id removes itself")
	await _clear()
