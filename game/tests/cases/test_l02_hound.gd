extends TestCase
## M4: the K01 Hound (a four-legged Brawler with a double lunge) and its handler:
##   - the chain: crouch (jaw amber, then red for the last 0.25 s) -> lunge 2 H -> a
##     0.5 s re-crouch with its own amber-then-red blip -> lunge -> the rigid recovery;
##     at least 0.9 s from lunge to lunge; the attack box is live only in a lunge; the
##     re-crouch turns to face Dave;
##   - a held jump clears each lunge;
##   - the base Scrapjack kills it (2 hits) inside its recovery;
##   - with a Night Guard handler: the handler's tell starts no sooner than 1.5 s after
##     the chain ends (and about then when he is in reach), and the two never attack
##     together; the spine strip is lime with a living handler, magenta without;
##   - it bleeds; its hit zone is 0.8 H tall; on death its legs twitch for about 1 s,
##     then the body settles; the defeat is recorded and a re-instance removes itself.

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
	hero.aim_override = pos + Vector2(200.0, -30.0)
	return hero


func _hound(pos: Vector2, entity_id: String = "", parent: Node = null) -> Hound:
	var d: Hound = load("res://scenes/actors/hound.tscn").instantiate()
	d.entity_id = entity_id
	d.position = pos
	(parent if parent != null else self).add_child(d)
	await physics_frames(2)
	return d


func _clear() -> void:
	release_all()
	for c in get_children():
		c.queue_free()
	await physics_frames(2)


func _until(cond: Callable, timeout: float) -> bool:
	for i in int(timeout * 60.0):
		if cond.call():
			return true
		await physics_frames(1)
	return cond.call()


func run() -> void:
	await _test_double_lunge_chain()
	await _test_jumps_clear_both_lunges()
	await _test_scrapjack_kills_it_in_recovery()
	await _test_handler_waits_for_the_chain()
	await _test_death_twitch_and_record()


func _test_double_lunge_chain() -> void:
	Session.new_run()
	_block(-400, FLOOR_Y, 2800, 200)
	var hero := _hero(Vector2(520, FLOOR_Y))
	hero.debug_invulnerable = true
	var dog := await _hound(Vector2(740, FLOOR_Y))
	check(dog.rig != null, "the Hound builds its four-legged lit rig")
	if dog.rig != null:
		check(dog.rig.order.size() == 17, "17 parts: torso, neck, head, jaw, tail and 4 x 3 leg parts (%d)" % dog.rig.order.size())
		var planted := true
		for clip in ["idle", "trot", "crouch", "recover"]:
			for k in 5:
				dog.rig.apply_pose(dog.anim.sample(clip, float(k) * 0.1))
				planted = planted and absf(dog.rig._ground_error()) < 0.05
		check(planted, "the ground lock keeps a paw on the floor in every standing clip")
	var shape: RectangleShape2D = dog.hit_zone.get_node("CollisionShape2D").shape
	check(absf(shape.size.y - 0.8 * H) <= 1.0, "its hit zone is 0.8 H tall (%.1f)" % shape.size.y)
	check(dog.hit_zone.bleeds, "a dog bleeds")
	check(dog.tuning.lunge_count == 2, "Act 1: two lunges")
	# Record the chain frame by frame.
	var log: Array = []   # [state, timer, tell colour, attack active, facing, x]
	var moved := [false]
	var started := await _until(func(): return dog.state == Brawler.State.WINDUP, 3.0)
	check(started, "the Hound crouches into its tell near Dave")
	while is_instance_valid(dog) and dog.state != Brawler.State.APPROACH and log.size() < 600:
		log.append([dog.state, dog._state_timer, dog._tell_light.color if dog._tell_light.energy > 0.0 else Color(0, 0, 0, 0),
				dog.attack_box.active, dog.facing, dog.global_position.x])
		# Halfway through the re-crouch, Dave is behind it: the second lunge turns.
		if dog.state == Brawler.State.WINDUP and dog._recrouch and dog._state_timer >= 0.08 and not moved[0]:
			moved[0] = true
			hero.global_position = Vector2(dog.global_position.x + 160.0 * -dog.facing, FLOOR_Y)
			hero.reset_physics_interpolation()
		await physics_frames(1)
	# Split it into phases.
	var phases: Array = []   # [state, frames, first index]
	for i in log.size():
		if phases.is_empty() or phases[-1][0] != log[i][0]:
			phases.append([log[i][0], 0, i])
		phases[-1][1] += 1
	var names := phases.map(func(p): return Brawler.State.keys()[p[0]])
	check(names == ["WINDUP", "STRIKE", "WINDUP", "STRIKE", "RECOVERY"], "crouch, lunge, crouch, lunge, recovery (%s)" % str(names))
	if names.size() == 5:
		var w1: float = phases[0][1] / 60.0
		var s1: float = phases[1][1] / 60.0
		var w2: float = phases[2][1] / 60.0
		var rec: float = phases[4][1] / 60.0
		check(absf(w1 - dog.tuning.windup_time) <= 2.0 / 60.0, "the first crouch lasts windup_time (%.3f s)" % w1)
		check(absf(w2 - 0.5) <= 2.0 / 60.0, "the re-crouch lasts 0.5 s (%.3f s)" % w2)
		check(s1 + w2 >= 0.9 - 1.0 / 60.0, "at least 0.9 s from lunge to lunge (%.3f s)" % (s1 + w2))
		check(absf(rec - dog.tuning.recovery_time) <= 2.0 / 60.0, "the rigid recovery lasts recovery_time (%.2f s)" % rec)
		for pi in [0, 2]:
			var first: int = phases[pi][2]
			var n: int = phases[pi][1]
			var red := 0
			var amber_after_red := false
			for k in range(first, first + n):
				var c: Color = log[k][2]
				if c == Brawler.ALARM:
					red += 1
				elif c == Brawler.AMBER and red > 0:
					amber_after_red = true
			check(not amber_after_red and absf(red / 60.0 - 0.25) <= 1.5 / 60.0,
					"crouch %d: amber, then red for the last 0.25 s (red %.3f s)" % [pi / 2 + 1, red / 60.0])
		var active_outside := false
		for e in log:
			if e[3] and e[0] != Brawler.State.STRIKE:
				active_outside = true
		check(not active_outside, "the attack box is live only in a lunge")
		var l1: float = absf(log[phases[1][2] + phases[1][1] - 1][5] - log[phases[1][2]][5])
		check(l1 <= 2.0 * H + 8.0 and l1 >= 1.6 * H, "a lunge covers about 2 H (%.0f px)" % l1)
		var f1: int = log[phases[1][2]][4]
		var f2: int = log[phases[3][2]][4]
		check(f2 == -f1, "the re-crouch turned it to face Dave behind it")
	await _clear()


func _test_jumps_clear_both_lunges() -> void:
	Session.new_run()
	_block(-400, FLOOR_Y, 2800, 200)
	var hero := _hero(Vector2(520, FLOOR_Y))
	var dog := await _hound(Vector2(720, FLOOR_Y))
	var health := Session.get_health()
	for lunge in 2:
		var red := await _until(func(): return dog.state == Brawler.State.WINDUP and dog._state_timer >= dog._windup_len - dog.tuning.red_time, 3.0)
		check(red, "setup: crouch %d turns red" % (lunge + 1))
		press("jump")
		await seconds(0.45)
		release("jump")
		await _until(func(): return hero.is_on_floor(), 1.5)
	await _until(func(): return dog.state == Brawler.State.RECOVERY, 2.0)
	check(dog.state == Brawler.State.RECOVERY, "setup: the chain ended")
	check(Session.get_health() == health, "jumping each lunge as it turns red avoids both (lost %d)" % (health - Session.get_health()))
	await _clear()


func _test_scrapjack_kills_it_in_recovery() -> void:
	Session.new_run()
	_block(-400, FLOOR_Y, 2800, 200)
	var hero := _hero(Vector2(300, FLOOR_Y))
	hero.debug_invulnerable = true
	var dog := await _hound(Vector2(720, FLOOR_Y), "L02-TEST-K01-01")
	check(dog.tuning.health == 2, "a Hound takes 2 hits")
	await _until(func(): return dog.state == Brawler.State.RECOVERY, 6.0)
	check(dog.state == Brawler.State.RECOVERY, "setup: the Hound stands rigid after its chain")
	# Dave backs off to 3 H, aims a little down, and fires.
	hero.global_position = Vector2(dog.global_position.x + 3.0 * H * -dog.facing, FLOOR_Y)
	hero.reset_physics_interpolation()
	await physics_frames(1)
	var t0 := dog._state_timer
	hero.aim_override = dog.global_position + Vector2(0.0, -26.0)
	press("fire")
	var t := 0
	while is_instance_valid(dog) and dog.state != Brawler.State.DEFEATED and t < 120:
		await physics_frames(1)
		t += 1
	release("fire")
	check(not is_instance_valid(dog) or dog.state == Brawler.State.DEFEATED, "the base Scrapjack kills it")
	check(t0 + t / 60.0 <= 1.2, "inside its 1.2 s recovery (%.2f s)" % (t0 + t / 60.0))
	await _clear()


func _test_handler_waits_for_the_chain() -> void:
	Session.new_run()
	_block(-400, FLOOR_Y, 2800, 200)
	var hero := _hero(Vector2(600, FLOOR_Y))
	hero.debug_invulnerable = true
	var group := EncounterGroup.new()
	add_child(group)
	var handler: Brawler = load("res://scenes/actors/night_guard.tscn").instantiate()
	handler.name = "Handler"
	handler.position = Vector2(670, FLOOR_Y)
	group.add_child(handler)
	var dog: Hound = load("res://scenes/actors/hound.tscn").instantiate()
	dog.position = Vector2(780, FLOOR_Y)
	dog.handler_path = NodePath("../Handler")
	group.add_child(dog)
	await physics_frames(2)
	check(dog.has_handler(), "the Hound knows its handler")
	check(dog.neon_color() == Hound.LIME, "lime spine strip with a handler (Arcadia Security)")
	var together := false
	var chain_end := -1.0
	var handler_tell := -1.0
	var t := 0.0
	while t < 8.0:
		await physics_frames(1)
		t += 1.0 / 60.0
		if not is_instance_valid(dog) or not is_instance_valid(handler):
			break
		if dog.is_in_chain() and handler.is_in_chain():
			together = true
		if chain_end < 0.0 and dog.state == Brawler.State.RECOVERY:
			chain_end = t
		if chain_end >= 0.0 and handler_tell < 0.0 and handler.state == Brawler.State.WINDUP:
			handler_tell = t
		if handler_tell >= 0.0 and t > handler_tell + 1.0:
			break
	check(chain_end >= 0.0, "setup: the Hound ran its chain")
	check(handler_tell >= 0.0, "the handler takes his turn after the chain")
	if chain_end >= 0.0 and handler_tell >= 0.0:
		var gap := handler_tell - chain_end
		check(gap >= 1.5 - 1.0 / 60.0, "the handler's tell starts no sooner than 1.5 s after the chain (%.2f s)" % gap)
		check(gap <= 1.6, "and about then when he is in reach (%.2f s)" % gap)
	check(not together, "dog and handler never attack together")
	# Without its handler the dog is Adam's: magenta.
	for i in handler.tuning.health:
		if is_instance_valid(handler):
			handler.hit_zone.take_hit(1, handler.global_position + Vector2(0, -60), Vector2.RIGHT)
	await physics_frames(2)
	check(not dog.has_handler(), "a dead handler handles no one")
	check(dog.neon_color() == Hound.MAGENTA, "magenta without a handler")
	await _clear()


func _test_death_twitch_and_record() -> void:
	Session.new_run()
	_block(-400, FLOOR_Y, 2800, 200)
	var id := "L02-TEST-K01-02"
	var dog := await _hound(Vector2(700, FLOOR_Y), id)
	var defeats := [0]
	dog.defeated.connect(func(_id): defeats[0] += 1)
	var host_before := get_child_count()
	for i in dog.tuning.health:
		dog.hit_zone.take_hit(1, dog.global_position + Vector2(10, -30), Vector2.RIGHT)
	if is_instance_valid(dog):
		dog.hit_zone.take_hit(1, dog.global_position + Vector2(10, -30), Vector2.RIGHT)
	await physics_frames(2)
	check(defeats[0] == 1, "defeated fires once")
	check(Session.is_defeated(id), "Session records the defeat")
	check(get_child_count() > host_before, "a hit sprays blood and the body stays behind")
	var body = get_node_or_null("Body_" + id)
	check(body != null, "it leaves a Body_<id> ragdoll")
	if body != null:
		check(body.is_twitching(), "its legs twitch after death")
		await seconds(0.7)
		check(body.is_twitching(), "still twitching at 0.7 s")
		await seconds(0.45)
		check(not body.is_twitching(), "the twitch stops after about 1 s")
		await _until(func(): return body.is_settled(), 3.5)
		check(body.is_settled(), "then the body settles as a corpse")
		var lowest := -INF
		var highest := INF
		for part in body.get_node("Corpse").get_children():
			lowest = maxf(lowest, (part as Node2D).global_position.y)
			highest = minf(highest, (part as Node2D).global_position.y)
		check(lowest <= FLOOR_Y + 2.0, "the corpse rests on the floor, not through it")
	var again := await _hound(Vector2(700, FLOOR_Y), id)
	await physics_frames(1)
	check(not is_instance_valid(again), "a re-instance with the same entity id removes itself")
	await _clear()
