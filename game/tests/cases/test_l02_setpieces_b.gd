extends TestCase
## Level 2 v2 set pieces, part B: the release props (S3 kennel pods, S6 plinths, S7 doors),
## S4 the drone launch rack and S7's sequential hold-out waves on the exit wicket.
##   - pods open in turn: a trigger x, then `after` the first pod is cleared plus `delay`;
##     each warns (amber, then red for the last 0.25 s) for warn_time before it opens; the
##     enemies inside are inert (frozen, no physics body or hit zone, no token, never move)
##     until it opens, and opening activates the group; a plinth and a door hide theirs; a
##     door with no trigger opens only on release(); an Area2D trigger works;
##   - rebuild: a pod whose enemies are recorded defeated starts open (silently) and counts
##     as cleared; a rollback puts an undefeated dog back inside a closed pod;
##   - the rack: docked drones are frozen in their bays; Dave's approach activates it; a
##     warning then a launch along an arc to the drone's own home, launches `interval`
##     apart, never more than max_live alive, count in all; its group caps the attackers;
##   - the clamps: all four broken stop the launches (a warning is cancelled), reveal the
##     reward once; the switch latch survives a rebuild, a rollback restores the clamps; the
##     cache's own record guards a second collection;
##   - the hold-out's waves open only during the override, the first at its start, each next
##     one wave_delay after the one before is fully defeated, a door wave through its warning.

const ReleasePod := preload("res://scripts/objects/release_pod.gd")
const LaunchRack := preload("res://scripts/objects/launch_rack.gd")
const PodScene := preload("res://scenes/objects/release_pod.tscn")
const RackScene := preload("res://scenes/objects/launch_rack.tscn")
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
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	hero.aim_override = pos + Vector2(200.0, -30.0)
	return hero


func _move_hero(hero: Hero, x: float) -> void:
	hero.global_position = Vector2(x, FLOOR_Y)
	hero.velocity = Vector2.ZERO
	hero.reset_physics_interpolation()


func _group(gname: String, wait: bool = true, cap: int = 1, share: EncounterGroup = null) -> EncounterGroup:
	var g := EncounterGroup.new()
	g.name = gname
	g.group_id = gname
	g.wait_for_trigger = wait
	g.max_attackers = cap
	if share != null:
		g.share_tokens_with = share.get_path()
	add_child(g)
	return g


func _enemy(scene: String, g: Node, pos: Vector2, id: String) -> Node2D:
	var e: Node2D = load(scene).instantiate()
	e.set("entity_id", id)
	e.position = pos
	g.add_child(e)
	return e


func _pod(kind: int, pos: Vector2, g: Node, cfg: Dictionary = {}):
	var p = PodScene.instantiate()
	p.variant = kind
	p.position = pos
	p.group = g.get_path()
	for k in cfg:
		p.set(k, cfg[k])
	add_child(p)
	return p


func _clear() -> void:
	release_all()
	for c in get_children():
		c.queue_free()
	await physics_frames(3)


func _until(cond: Callable, timeout: float) -> bool:
	for i in int(timeout * 60.0):
		if cond.call():
			return true
		await physics_frames(1)
	return cond.call()


## True when a bolt-style query at the centre of `zone`'s shape finds it (layer 5).
func _zone_at(_at: Vector2, zone: Area2D) -> bool:
	var shape := zone.get_node_or_null("CollisionShape2D") as Node2D
	var q := PhysicsPointQueryParameters2D.new()
	q.position = shape.global_position if shape else zone.global_position
	q.collision_mask = 16
	q.collide_with_areas = true
	q.collide_with_bodies = false
	for r in get_viewport().world_2d.direct_space_state.intersect_point(q, 16):
		if r["collider"] == zone:
			return true
	return false


func _kill(e: Node) -> void:
	if is_instance_valid(e) and not e.is_queued_for_deletion():
		var zone: HitZone = e.hit_zone
		zone.take_hit(20, zone.global_position, Vector2.RIGHT)


func run() -> void:
	await _test_pods_in_turn()
	await _test_plinth_door_and_area_trigger()
	await _test_pod_rebuild_and_rollback()
	await _test_rack_launches()
	await _test_rack_clamps_and_reward()
	await _test_holdout_waves()


# --- release props --------------------------------------------------------------------------

func _test_pods_in_turn() -> void:
	Session.new_run("L02")
	_block(-400, FLOOR_Y, 3200, 200)
	var hero := _hero(Vector2(640, FLOOR_Y))
	var ga := _group("PodA", true, 1)
	var gb := _group("PodB", true, 1, ga)
	var dog_a: Hound = _enemy("res://scenes/actors/hound.tscn", ga, Vector2(800, FLOOR_Y), "L02-E90-K01-01")
	var dog_b: Hound = _enemy("res://scenes/actors/hound.tscn", gb, Vector2(1060, FLOOR_Y), "L02-E90-K01-02")
	var pod_a = _pod(ReleasePod.Kind.POD, Vector2(800, FLOOR_Y), ga, {"trigger_x": 700.0})
	var pod_b = _pod(ReleasePod.Kind.POD, Vector2(1060, FLOOR_Y), gb, {"after": pod_a.get_path(), "delay": 1.0})
	var warned := [0, 0]
	pod_a.warning_started.connect(func(): warned[0] += 1)
	pod_b.warning_started.connect(func(): warned[1] += 1)
	await physics_frames(2)
	var start_a := dog_a.global_position
	var start_state := dog_a.state
	check(ga.process_mode == Node.PROCESS_MODE_DISABLED and gb.process_mode == Node.PROCESS_MODE_DISABLED,
			"the dogs' groups are frozen while their pods are closed")
	check(dog_a.z_index + ga.z_index == -2 and pod_a.z_index == -3 and pod_a.get_node("Front").z_index + pod_a.z_index == -1,
			"a waiting dog draws between the pod's back (-3) and its glass (-1), behind Dave")
	check(ga.visible and dog_a.is_visible_in_tree(), "a pod shows its dog behind the glass")
	# Dave is 160 px from dog A (inside its engage range) but short of the trigger.
	var moved := false
	var acted := false
	var zone_seen := false
	for i in 90:
		await physics_frames(1)
		moved = moved or dog_a.global_position.distance_to(start_a) > 0.5
		acted = acted or dog_a.state != start_state or dog_a.attack_box.active or dog_b.attack_box.active
		zone_seen = zone_seen or _zone_at(dog_a.hit_zone.global_position, dog_a.hit_zone)
	check(not moved and not acted, "a dog inside its closed pod never moves, notices or attacks Dave")
	check(not zone_seen, "a dog inside its closed pod has no hit zone in the world (a shot passes the pod)")
	check(ga.attacker_count() == 0, "no dog inside a pod holds an attack token")
	check(pod_a.state == ReleasePod.State.CLOSED and pod_b.state == ReleasePod.State.CLOSED and not ga.is_active,
			"both pods stay closed until Dave passes the trigger")
	check(pod_a.lamp_color() == ReleasePod.TEAL, "a waiting pod's ring light is teal")
	# Dave passes x 700: pod A warns, then opens.
	_move_hero(hero, 720.0)
	var log: Array = []
	var ok := await _until(func():
		log.append([pod_a.state, pod_a.lamp_color()])
		return pod_a.state == ReleasePod.State.OPEN, 2.0)
	check(ok, "pod A opens after Dave passes its trigger")
	var warn := log.filter(func(e): return e[0] == ReleasePod.State.WARNING)
	var red := warn.filter(func(e): return e[1] == ReleasePod.ALARM).size()
	var amber_after_red := false
	var seen_red := false
	for e in warn:
		seen_red = seen_red or e[1] == ReleasePod.ALARM
		amber_after_red = amber_after_red or (seen_red and e[1] == ReleasePod.AMBER)
	check(absf(warn.size() / 60.0 - pod_a.warn_time) <= 2.0 / 60.0, "pod A warns for warn_time before it opens (%.3f s)" % (warn.size() / 60.0))
	check(not warn.is_empty() and warn[0][1] == ReleasePod.AMBER and not amber_after_red and absf(red / 60.0 - 0.25) <= 1.5 / 60.0,
			"the warning is amber, then red for the last 0.25 s (red %.3f s)" % (red / 60.0))
	check(warned[0] == 1, "pod A's warning starts once")
	check(ga.is_active and ga.process_mode == Node.PROCESS_MODE_INHERIT and dog_a.z_index + ga.z_index == 1,
			"opening activates the group and lets the dog out (unfrozen, back at its own z)")
	await physics_frames(2)
	check(_zone_at(dog_a.hit_zone.global_position, dog_a.hit_zone), "a released dog can be shot")
	var engaged := await _until(func(): return dog_a.state == Brawler.State.WINDUP or dog_a.state == Brawler.State.APPROACH, 2.0)
	check(engaged, "the released dog goes for Dave")
	# Pod B waits while dog A lives.
	var cap_ok := true
	for i in 120:
		await physics_frames(1)
		cap_ok = cap_ok and ga.attacker_count() <= ga.attacker_cap()
	check(pod_b.state == ReleasePod.State.CLOSED and not gb.is_active, "pod B stays closed while pod A's dog lives")
	check(cap_ok, "the pod row shares one token pool (at most %d attacker)" % ga.attacker_cap())
	# Dog A down: pod B warns `delay` (1 s) later, then opens.
	_kill(dog_a)
	var frames := 0
	while pod_b.state == ReleasePod.State.CLOSED and frames < 240:
		await physics_frames(1)
		frames += 1
	check(pod_a.is_cleared(), "pod A counts as cleared once its dog is down")
	check(absf(frames / 60.0 - 1.0) <= 3.0 / 60.0, "pod B starts warning `delay` after pod A is cleared (%.3f s)" % (frames / 60.0))
	check(pod_b.state == ReleasePod.State.WARNING and gb.process_mode == Node.PROCESS_MODE_DISABLED,
			"dog B stays frozen through pod B's warning")
	ok = await _until(func(): return pod_b.state == ReleasePod.State.OPEN, 1.5)
	check(ok and gb.is_active and gb.process_mode == Node.PROCESS_MODE_INHERIT, "pod B opens and releases its dog")
	check(warned[1] == 1, "pod B warns once")
	await _clear()


func _test_plinth_door_and_area_trigger() -> void:
	Session.new_run("L02")
	_block(-400, FLOOR_Y, 3200, 200)
	var hero := _hero(Vector2(200, FLOOR_Y))
	var gp := _group("Plinth")
	var rover: PatrolRover = _enemy("res://scenes/actors/patrol_rover.tscn", gp, Vector2(700, FLOOR_Y), "L02-E91-M01-01")
	var zone := Area2D.new()
	zone.collision_layer = 0
	zone.collision_mask = 2
	zone.position = Vector2(500, FLOOR_Y - 60)
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(60, 120)
	cs.shape = rect
	zone.add_child(cs)
	add_child(zone)
	var plinth = _pod(ReleasePod.Kind.PLINTH, Vector2(700, FLOOR_Y), gp, {"trigger_area": zone.get_path()})
	var gd := _group("Door")
	var guard: Brawler = _enemy("res://scenes/actors/night_guard.tscn", gd, Vector2(300, FLOOR_Y), "L02-E91-SE01-01")
	var door = _pod(ReleasePod.Kind.DOOR, Vector2(300, FLOOR_Y), gd)
	await physics_frames(2)
	check(not gp.visible and not gd.visible, "a plinth's cover and a door hide the enemies they hold")
	var rx := rover.global_position.x
	await seconds(1.5)
	check(absf(rover.global_position.x - rx) < 0.5 and rover.state == PatrolRover.State.PATROL, "the covered rover never drives")
	check(door.state == ReleasePod.State.CLOSED and guard.state != Brawler.State.WINDUP,
			"a door with no trigger stays shut with Dave beside it (it opens only on release())")
	check(plinth.state == ReleasePod.State.CLOSED, "the plinth waits for its trigger area")
	_move_hero(hero, 500.0)
	var ok := await _until(func(): return plinth.state == ReleasePod.State.WARNING, 0.5)
	check(ok, "Dave entering the trigger area starts the plinth's warning")
	ok = await _until(func(): return plinth.state == ReleasePod.State.OPEN, 1.2)
	check(ok and gp.visible and gp.is_active, "the plinth's cover drops and its rover is shown and woken")
	_move_hero(hero, 120.0)
	door.release()
	check(door.state == ReleasePod.State.WARNING and not gd.visible, "release() starts a door's warning; its guard is still hidden")
	ok = await _until(func(): return door.state == ReleasePod.State.OPEN, 1.2)
	check(ok and gd.visible and gd.is_active, "the door opens and its guard steps out")
	await _clear()


func _build_pod_pair(ids: Array) -> Array:
	var ga := _group("PodA")
	var gb := _group("PodB", true, 1, ga)
	var dog_a: Node = _enemy("res://scenes/actors/hound.tscn", ga, Vector2(800, FLOOR_Y), ids[0])
	var dog_b: Node = _enemy("res://scenes/actors/hound.tscn", gb, Vector2(1060, FLOOR_Y), ids[1])
	var pod_a = _pod(ReleasePod.Kind.POD, Vector2(800, FLOOR_Y), ga, {"trigger_x": 700.0})
	# The recommended chain for a rebuild: B also waits for Dave, then for A.
	var pod_b = _pod(ReleasePod.Kind.POD, Vector2(1060, FLOOR_Y), gb, {"trigger_x": 700.0, "after": pod_a.get_path(), "delay": 0.5})
	return [ga, gb, dog_a, dog_b, pod_a, pod_b]


func _test_pod_rebuild_and_rollback() -> void:
	var ids := ["L02-E92-K01-01", "L02-E92-K01-02"]
	Session.new_run("L02")
	check(Session.commit("CP01"), "baseline checkpoint")
	_block(-400, FLOOR_Y, 3200, 200)
	var hero := _hero(Vector2(200, FLOOR_Y))
	var b := _build_pod_pair(ids)
	await physics_frames(2)
	_move_hero(hero, 720.0)
	var ok := await _until(func(): return b[4].is_open(), 2.0)
	check(ok, "pod A opens")
	_kill(b[2])
	ok = await _until(func(): return b[5].is_open(), 3.0)
	check(ok, "pod B opens after A")
	check(Session.commit("CP02"), "a checkpoint with dog A defeated and dog B alive")
	# A death: roll back to CP02 and rebuild.
	Session.restore_committed()
	await _clear()
	_block(-400, FLOOR_Y, 3200, 200)
	hero = _hero(Vector2(200, FLOOR_Y))
	var warned := [0]
	b = _build_pod_pair(ids)
	b[4].warning_started.connect(func(): warned[0] += 1)
	check(b[4].state == ReleasePod.State.OPEN and b[4]._anim >= 1.0, "rebuilt with its dog recorded defeated, pod A starts open (no slide)")
	check(b[0].is_active, "the open pod's (empty) group is active")
	await physics_frames(2)
	check(b[4].is_cleared() and warned[0] == 0, "it counts as cleared and never warns again")
	check(b[5].state == ReleasePod.State.CLOSED and b[1].process_mode == Node.PROCESS_MODE_DISABLED,
			"dog B (alive at CP02) is back inside its closed pod")
	await seconds(1.0)
	check(b[5].state == ReleasePod.State.CLOSED, "pod B (trigger + after) still waits for Dave")
	_move_hero(hero, 720.0)
	ok = await _until(func(): return b[5].state == ReleasePod.State.WARNING, 1.0)
	check(ok, "with A already cleared, pod B warns `delay` after Dave passes its trigger")
	await _clear()


# --- the launch rack ------------------------------------------------------------------------

## A rack on the wall at (600, FLOOR_Y - 230) with three docked drones whose homes are over the
## floor to its right, a hidden cache under it.
func _build_rack(cfg: Dictionary = {}) -> Dictionary:
	var g := _group("RackDrones", true, 1)
	var homes := [Vector2(900, FLOOR_Y - 180), Vector2(1100, FLOOR_Y - 170), Vector2(1300, FLOOR_Y - 180)]
	var ds: Array = []
	for i in 3:
		var d: Drone = load("res://scenes/actors/security_drone.tscn").instantiate()
		d.entity_id = "L02-E93-M02-0%d" % (i + 1)
		d.position = homes[i]
		d.patrol_min_x = homes[i].x - 100.0
		d.patrol_max_x = homes[i].x + 100.0
		g.add_child(d)
		ds.append(d)
	var cache = load("res://scenes/objects/chip_cache.tscn").instantiate()
	cache.entity_id = "L02-A03-CACHE93"
	cache.value = 5
	cache.position = Vector2(600, FLOOR_Y)
	add_child(cache)
	var rack = RackScene.instantiate()
	rack.position = Vector2(600, FLOOR_Y - 230)
	var paths: Array[NodePath] = [ds[0].get_path(), ds[1].get_path(), ds[2].get_path()]
	rack.drones = paths
	rack.group = g.get_path()
	rack.reward = cache.get_path()
	rack.trigger_x = 450.0
	for k in cfg:
		rack.set(k, cfg[k])
	add_child(rack)
	return {"group": g, "drones": ds, "homes": homes, "cache": cache, "rack": rack}


func _test_rack_launches() -> void:
	Session.new_run("L02")
	_block(-400, FLOOR_Y, 3200, 200)
	var hero := _hero(Vector2(200, FLOOR_Y))
	var r := _build_rack()
	var rack = r["rack"]
	var g: EncounterGroup = r["group"]
	var ds: Array = r["drones"]
	var launches: Array = []   # [frame, index]
	var warnings: Array = []
	var frame := [0]
	rack.launched.connect(func(_d, i): launches.append([frame[0], i]))
	rack.launch_warning.connect(func(i): warnings.append([frame[0], i]))
	await physics_frames(2)
	var docked := true
	for i in 3:
		var d: Drone = ds[i]
		docked = docked and d.process_mode == Node.PROCESS_MODE_DISABLED \
				and d.global_position.distance_to(rack.to_global(rack.bay_position(i))) < 0.5 and rack.is_docked(d)
		check(not _zone_at(d.hit_zone.global_position, d.hit_zone), "docked drone %d has no hit zone in the world" % i)
	check(docked, "the three drones are docked, frozen, in their bays")
	check(ds[0]._home_y == r["homes"][0].y, "a docked drone keeps its authored home height")
	await seconds(1.0)
	check(rack.state == LaunchRack.State.IDLE and launches.is_empty() and not g.is_active, "nothing launches before Dave approaches")
	_move_hero(hero, 480.0)
	await physics_frames(1)
	check(rack.state == LaunchRack.State.ACTIVE and g.is_active, "Dave's approach activates the rack and its drones' group")
	# The first launch: warning at first_delay, launch warn_time later, along an arc.
	var d0: Drone = ds[0]
	var from := d0.global_position
	var min_y := from.y
	var cap_ok := true
	while launches.is_empty() and frame[0] < 300:
		await physics_frames(1)
		frame[0] += 1
	check(not warnings.is_empty() and absf(warnings[0][0] / 60.0 - rack.first_delay) <= 2.0 / 60.0,
			"the first warning comes first_delay after activation")
	check(not launches.is_empty() and absf((launches[0][0] - warnings[0][0]) / 60.0 - rack.warn_time) <= 2.0 / 60.0,
			"the launch follows its warning by warn_time")
	var arrived := false
	for i in 90:
		await physics_frames(1)
		frame[0] += 1
		min_y = minf(min_y, d0.global_position.y)
		if d0.process_mode == Node.PROCESS_MODE_INHERIT:
			arrived = true
			break
	check(arrived and d0.global_position.distance_to(r["homes"][0]) < 1.0, "the drone flies to its own home, then wakes")
	check(min_y < minf(from.y, r["homes"][0].y) - 12.0, "it leaves the rack along an arc (rises %.0f px over its ends)" % (minf(from.y, r["homes"][0].y) - min_y))
	await seconds(1.6)
	frame[0] += 96
	check(d0.global_position.distance_to(r["homes"][0]) > 2.0, "launched, it flies its patrol (or dives)")
	# The second launch, interval later; then the third waits for a free slot (max_live 2).
	while launches.size() < 2 and frame[0] < 900:
		await physics_frames(1)
		frame[0] += 1
		cap_ok = cap_ok and g.attacker_count() <= 1
	check(launches.size() == 2 and absf((launches[1][0] - launches[0][0]) / 60.0 - rack.interval) <= 2.0 / 60.0,
			"launches are interval (%.1f s) apart" % rack.interval)
	for i in 600:
		await physics_frames(1)
		frame[0] += 1
		cap_ok = cap_ok and g.attacker_count() <= 1 and rack.live_count() <= rack.max_live
	check(launches.size() == 2 and warnings.size() == 2, "with max_live (2) drones alive the third waits, without a warning")
	check(rack.is_docked(ds[2]) and ds[2].process_mode == Node.PROCESS_MODE_DISABLED, "the third drone is still docked")
	_kill(ds[0])
	var killed_at: int = frame[0]
	while launches.size() < 3 and frame[0] < killed_at + 120:
		await physics_frames(1)
		frame[0] += 1
	check(launches.size() == 3 and absf((launches[2][0] - killed_at) / 60.0 - rack.warn_time) <= 3.0 / 60.0,
			"a free slot: the third warns at once and launches warn_time later")
	_kill(ds[1])
	for i in 480:
		await physics_frames(1)
		cap_ok = cap_ok and g.attacker_count() <= 1
	check(launches.size() == 3 and rack.launched_count() == 3 and rack.state == LaunchRack.State.SPENT,
			"count (3) drones in all: the rack is spent")
	check(cap_ok, "the drones' group never fields more than one attacker, and never more than 2 live")
	await _clear()
	# Rebuild with a drone recorded defeated: it counts as launched.
	Session.new_run("L02")
	Session.mark_defeated("L02-E93-M02-01")
	_block(-400, FLOOR_Y, 3200, 200)
	hero = _hero(Vector2(200, FLOOR_Y))
	r = _build_rack({"interval": 2.0})
	rack = r["rack"]
	var n := [0]
	rack.launched.connect(func(_d, _i): n[0] += 1)
	await physics_frames(2)
	check(rack.launched_count() == 1, "a drone already defeated at load counts as launched")
	_move_hero(hero, 480.0)
	await seconds(8.0)
	check(n[0] == 2 and rack.state == LaunchRack.State.SPENT, "the rack launches only the two remaining drones")
	await _clear()


func _break_clamp(rack, i: int) -> void:
	var z: HitZone = rack.clamp_zone(i)
	for k in rack.clamp_health:
		z.take_hit(1, z.global_position, Vector2.RIGHT)
	await physics_frames(1)


func _test_rack_clamps_and_reward() -> void:
	Session.new_run("L02")
	check(Session.commit("CP02"), "baseline checkpoint")
	_block(-400, FLOOR_Y, 3200, 200)
	var hero := _hero(Vector2(200, FLOOR_Y))
	var r := _build_rack({"switch_id": "L02-SW09"})
	var rack = r["rack"]
	var cache = r["cache"]
	var counts := {"launch": 0, "disabled": 0, "revealed": 0}
	rack.launched.connect(func(_d, _i): counts["launch"] += 1)
	rack.disabled.connect(func(): counts["disabled"] += 1)
	rack.reward_revealed.connect(func(): counts["revealed"] += 1)
	await physics_frames(2)
	check(not cache.visible and cache.process_mode == Node.PROCESS_MODE_DISABLED, "the reward tray is hidden until the rack breaks")
	check(rack.clamps_left() == 4, "four clamps")
	check(_zone_at(rack.clamp_zone(0).global_position, rack.clamp_zone(0)), "a clamp is a hit zone a shot can strike")
	_move_hero(hero, 480.0)
	for i in 3:
		await _break_clamp(rack, i)
	check(rack.clamps_left() == 1 and rack.state == LaunchRack.State.ACTIVE, "three clamps broken: still running")
	var ok := await _until(func(): return counts["launch"] == 1, 3.0)
	check(ok, "with one clamp left it still launches")
	check(not _zone_at(rack.clamp_zone(0).global_position, rack.clamp_zone(0)), "a broken clamp leaves the world")
	ok = await _until(func(): return rack.is_warning(), 8.0)
	check(ok, "the next launch's warning starts")
	await _break_clamp(rack, 3)
	check(rack.state == LaunchRack.State.DISABLED and not rack.is_warning(), "the fourth clamp stops it, cancelling the warning")
	check(counts["disabled"] == 1 and counts["revealed"] == 1, "it reports broken and reveals the reward once")
	check(cache.visible and cache.process_mode == Node.PROCESS_MODE_INHERIT and cache.can_interact(hero), "the cache is shown and can be opened")
	check(Session.get_switch("L02-SW09"), "the broken rack is latched in Session")
	rack.clamp_zone(3).take_hit(1, rack.clamp_zone(3).global_position, Vector2.RIGHT)
	await seconds(8.0)
	check(counts["launch"] == 1 and counts["revealed"] == 1 and counts["disabled"] == 1, "no more launches, no second reveal")
	var w0: int = Session.get_wallet()
	cache.interact(hero)
	check(Session.get_wallet() == w0 + 5, "the tray pays its 5 chips")
	check(Session.commit("CP02"), "checkpoint with the rack broken and the tray collected")
	# A rebuild after that checkpoint: still broken, drones docked, the tray opened.
	Session.restore_committed()
	await _clear()
	_block(-400, FLOOR_Y, 3200, 200)
	hero = _hero(Vector2(480, FLOOR_Y))
	r = _build_rack({"switch_id": "L02-SW09"})
	rack = r["rack"]
	cache = r["cache"]
	var relaunch := [0]
	rack.launched.connect(func(_d, _i): relaunch[0] += 1)
	await physics_frames(2)
	check(rack.state == LaunchRack.State.DISABLED and rack.clamps_left() == 0 and rack.is_revealed(),
			"rebuilt with the latch, the rack starts broken and its tray shown")
	check(cache.visible and not cache.can_interact(hero), "the rebuilt tray is the opened one")
	cache.interact(hero)
	check(Session.get_wallet() == w0 + 5, "no second collection")
	await seconds(3.0)
	check(relaunch[0] == 0 and r["drones"][1].process_mode == Node.PROCESS_MODE_DISABLED, "a broken rack never launches its docked drones")
	await _clear()
	# A rollback to before the break: clamps back, tray hidden.
	Session.new_run("L02")
	check(Session.commit("CP02"), "baseline")
	_block(-400, FLOOR_Y, 3200, 200)
	hero = _hero(Vector2(200, FLOOR_Y))
	r = _build_rack({"switch_id": "L02-SW09"})
	await physics_frames(2)
	for i in 4:
		await _break_clamp(r["rack"], i)
	check(r["rack"].state == LaunchRack.State.DISABLED, "broken")
	Session.restore_committed()
	await _clear()
	_block(-400, FLOOR_Y, 3200, 200)
	hero = _hero(Vector2(200, FLOOR_Y))
	r = _build_rack({"switch_id": "L02-SW09"})
	await physics_frames(2)
	check(r["rack"].state == LaunchRack.State.IDLE and r["rack"].clamps_left() == 4 and not r["cache"].visible,
			"rolled back to before the break, the rack is whole and its tray hidden")
	await _clear()


# --- the hold-out's waves -------------------------------------------------------------------

func _wicket(x: float, time: float, waves: Array) -> ExitWicket:
	var w: ExitWicket = load("res://scenes/objects/exit_wicket.tscn").instantiate()
	w.required_keycard = ""
	w.override_time = time
	w.position = Vector2(x, FLOOR_Y)
	var paths: Array[NodePath] = []
	for n in waves:
		paths.append(n.get_path())
	w.wave_groups = paths
	w.wave_delay = 1.0
	add_child(w)
	return w


func _test_holdout_waves() -> void:
	Session.new_run("L02")
	_block(-400, FLOOR_Y, 3600, 200)
	var hero := _hero(Vector2(300, FLOOR_Y))
	var g1 := _group("Wave1", true, 2)
	var w1: Brawler = _enemy("res://scenes/actors/night_guard.tscn", g1, Vector2(1600, FLOOR_Y), "L02-E94-SE01-01")
	var door1 = _pod(ReleasePod.Kind.DOOR, Vector2(1600, FLOOR_Y), g1)
	var g2 := _group("Wave2", true, 2)
	var w2a: Brawler = _enemy("res://scenes/actors/night_guard.tscn", g2, Vector2(1750, FLOOR_Y), "L02-E94-SE01-02")
	var w2b: Brawler = _enemy("res://scenes/actors/night_guard.tscn", g2, Vector2(1850, FLOOR_Y), "L02-E94-SE01-03")
	var g3 := _group("Wave3", true, 2)
	var w3: Brawler = _enemy("res://scenes/actors/night_guard.tscn", g3, Vector2(800, FLOOR_Y), "L02-E94-SE01-04")
	var door3 = _pod(ReleasePod.Kind.DOOR, Vector2(800, FLOOR_Y), g3)
	var wicket := _wicket(1200.0, 40.0, [door1, g2, door3])
	var opened: Array = []   # [frame, index]
	var frame := [0]
	wicket.wave_opened.connect(func(i): opened.append([frame[0], i]))
	await seconds(1.0)
	check(wicket.current_wave() == -1 and door1.state == ReleasePod.State.CLOSED and not g2.is_active,
			"no wave opens before the override starts")
	_move_hero(hero, 1190.0)
	var ok := await _until(func(): return wicket.is_overriding(), 0.5)
	check(ok, "the card (none needed here) starts the override")
	check(wicket.current_wave() == 0 and door1.state == ReleasePod.State.WARNING, "the first wave's door starts its warning with the override")
	ok = await _until(func(): return door1.is_open(), 1.5)
	check(ok and g1.is_active, "the first wave's door opens and its guard steps out")
	await seconds(3.0)
	check(not g2.is_active and wicket.current_wave() == 0, "the second wave waits while the first is alive")
	_kill(w1)
	while opened.size() < 2 and frame[0] < 240:
		await physics_frames(1)
		frame[0] += 1
	check(opened.size() == 2 and opened[1][1] == 1 and absf(opened[1][0] / 60.0 - wicket.wave_delay) <= 3.0 / 60.0,
			"the second wave opens wave_delay (%.1f s) after the first is down" % wicket.wave_delay)
	check(g2.is_active, "a bare group wave is activated")
	var one_live := true
	for i in 120:
		await physics_frames(1)
		one_live = one_live and not (g2.is_active and door3.is_open())
	check(door3.state == ReleasePod.State.CLOSED and one_live, "the third wave waits for the whole second wave")
	_kill(w2a)
	await seconds(2.0)
	check(door3.state == ReleasePod.State.CLOSED, "one of two down is not the whole wave")
	_kill(w2b)
	ok = await _until(func(): return door3.state == ReleasePod.State.WARNING, 1.5)
	check(ok and wicket.current_wave() == 2, "the third wave's door warns once the second wave is down")
	ok = await _until(func(): return door3.is_open() and g3.is_active, 1.5)
	check(ok, "the third wave's door opens")
	check(wicket.is_overriding() and not wicket.is_open(), "the override keeps running through the waves")
	_kill(w3)
	await _clear()
	# The override finishing stops the waves; the C41 timing is unchanged.
	Session.new_run("L02")
	_block(-400, FLOOR_Y, 3600, 200)
	hero = _hero(Vector2(300, FLOOR_Y))
	g1 = _group("Wave1", true, 2)
	w1 = _enemy("res://scenes/actors/night_guard.tscn", g1, Vector2(1600, FLOOR_Y), "L02-E95-SE01-01")
	g2 = _group("Wave2", true, 2)
	_enemy("res://scenes/actors/night_guard.tscn", g2, Vector2(1750, FLOOR_Y), "L02-E95-SE01-02")
	wicket = _wicket(1200.0, 3.0, [g1, g2])
	var finished := [false]
	wicket.override_finished.connect(func(): finished[0] = true)
	await physics_frames(2)
	_move_hero(hero, 1190.0)
	ok = await _until(func(): return wicket.is_overriding(), 0.5)
	check(ok and g1.is_active, "a bare first wave wakes with the override")
	ok = await _until(func(): return finished[0], 3.5)
	check(ok and wicket.is_open(), "the override still finishes at override_time with a wave alive")
	_kill(w1)
	await seconds(2.0)
	check(not g2.is_active and wicket.current_wave() == 0, "no new wave opens once the override has finished")
	await _clear()
