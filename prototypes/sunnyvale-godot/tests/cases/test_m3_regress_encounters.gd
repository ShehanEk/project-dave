extends TestCase
## M3 layout/fairness regression: encounter lanes, approach zones, backstops,
## attack visibility, lane leashing, interactable spacing, depot exit gating,
## and seams, measured in the assembled level_01. Grew out of the M3 assembly
## review (LAY-10 rover leash compared in global space, LAY-11 rover
## backstops out of charge range, LAY-13/LAY-14 recovery-station/switch
## exposure to a neighbouring encounter); keep passing after any future
## geometry or tuning change. The level's enemies are Night Guards and
## Staffers (both Brawlers) and Patrol Rovers (the old Clippers).

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const H := 96.0

var level: LevelDirector


func run() -> void:
	await _station_and_switch_exposure()
	await _static_checks()
	await _idle_patrol_in_level()
	await _depot_exit()
	await _combat_run()


func _load() -> void:
	Session.new_run()
	level = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)


func _unload() -> void:
	release_all()
	level.queue_free()
	await physics_frames(3)


func _groups() -> Array:
	var out: Array = []
	_find(level, out)
	return out


func _find(n: Node, out: Array) -> void:
	for c in n.get_children():
		if c is EncounterGroup:
			out.append(c)
		_find(c, out)


func _lane_global(g: EncounterGroup) -> Rect2:
	var r := g.lane_rect
	return Rect2(g.to_global(r.position), r.size)


func _zone_global(g: EncounterGroup) -> Rect2:
	var z: Area2D = g.get_node_or_null("ApproachZone")
	if z == null:
		return Rect2()
	var cs: CollisionShape2D = z.get_node("CollisionShape2D")
	var s: Vector2 = cs.shape.size
	return Rect2(cs.global_position - s * 0.5, s)


func _area_of(x: float) -> AreaRoot:
	return level._area_for_x(x)


func _static_checks() -> void:
	await _load()
	var groups := _groups()
	for g in groups:
		var lane := _lane_global(g)
		var zone := _zone_global(g)
		var a := _area_of(zone.get_center().x)
		print("[probe_lay_enc] %s lane local x %.0f..%.0f  approach zone local x %.0f..%.0f" % [
				g.group_id, lane.position.x - a.global_position.x, lane.end.x - a.global_position.x,
				zone.position.x - a.global_position.x, zone.end.x - a.global_position.x])
		for h in groups:
			if h == g:
				continue
			var hz := _zone_global(h)
			var retreat := Rect2(lane.position.x - 2.0 * H, lane.position.y, lane.size.x + 4.0 * H, lane.size.y)
			check(not retreat.intersects(hz), "%s lane(+2H retreat) does not contain %s approach zone" % [g.group_id, h.group_id])
			check(not lane.intersects(_lane_global(h)), "%s lane does not overlap %s lane" % [g.group_id, h.group_id])
		# Rover backstops within one charge (4H) on each side, same floor
		for e in g.get_children():
			if e is PatrolRover:
				var space := level.get_world_2d().direct_space_state
				var res := {}
				for dir in [-1, 1]:
					var from: Vector2 = e.global_position + Vector2(dir * 34.0, -24.0)
					var to: Vector2 = from + Vector2(dir * 4.0 * H, 0.0)
					var q := PhysicsRayQueryParameters2D.create(from, to)
					q.collision_mask = 1
					var hit := space.intersect_ray(q)
					res[dir] = ("%s at %.0fpx" % [hit.collider.name, absf(hit.position.x - from.x)]) if not hit.is_empty() else "NONE"
				print("[probe_lay_enc]   Rover %s start local x=%.0f: wall within 4H left=%s right=%s" % [
						e.entity_id, e.global_position.x - a.global_position.x, res[-1], res[1]])
				# LAY-11 regression: every Rover must have SOME indestructible
				# backstop within one charge (4H) of its start, so a charge in
				# whichever direction it actually fires can stall and expose
				# the battery (03: "Indestructible backstops make a stall
				# possible in every lane"). A backstop on only one side (as
				# with E02/E04's existing right-side Backstop1/2) is not
				# itself a defect — a Rover can acquire and charge toward
				# the hero from either side depending on where it is when it
				# acquires — so this does not require a LEFT-specific one.
				check(res[-1] != "NONE" or res[1] != "NONE", "Rover %s has a backstop within one charge (4H) of its start" % e.entity_id)
	# depot interactables
	var a5: AreaRoot = level.areas[4]
	var names := ["CoreNode", "Workbench", "WeaponPad"]
	var rects := {}
	for n in names:
		var node: Area2D = a5.get_node("Entities/" + n)
		for c in node.get_children():
			if c is CollisionShape2D and c.shape is RectangleShape2D:
				var s: Vector2 = c.shape.size
				rects[n] = Rect2(c.global_position - s * 0.5, s)
	for i in names.size():
		for j in range(i + 1, names.size()):
			var r1: Rect2 = rects[names[i]]
			var r2: Rect2 = rects[names[j]]
			var gapx: float = maxf(r2.position.x - r1.end.x, r1.position.x - r2.end.x)
			print("[probe_lay_enc] A05 %s <-> %s horizontal gap %.0f px (hero sensor diameter 144)" % [names[i], names[j], gapx])
			check(gapx > 144.0, "A05 %s and %s interaction areas cannot both be in the hero's 72px sensor (gap %.0f)" % [names[i], names[j], gapx])
	# seams
	for i in level.areas.size():
		var ar: AreaRoot = level.areas[i]
		var bad: Array = []
		for x in range(8, 384, 16):
			if not ar.has_floor_at(float(x)):
				bad.append(x)
			if not ar.has_floor_at(ar.width - float(x)):
				bad.append(-x)
		check(bad.is_empty(), "%s seams have 4H flat y=0 floor both ends (missing at %s)" % [ar.area_id, str(bad)])
	# population / forbidden
	# Kinds by the scene each enemy was instanced from (a Night Guard and a
	# Staffer are the same Brawler script).
	var kinds := {}
	for e in get_tree().get_nodes_in_group("enemy"):
		if level.is_ancestor_of(e):
			var k: String = e.scene_file_path.get_file().get_basename()
			kinds[k] = kinds.get(k, 0) + 1
	print("[probe_lay_enc] enemy kinds in level: %s" % str(kinds))
	check(kinds.keys().size() == 3 and kinds.get("night_guard", 0) == 8 and kinds.get("staffer", 0) == 2 and kinds.get("patrol_rover", 0) == 6,
			"only Night Guard x8 + Staffer x2 + Patrol Rover x6 (got %s)" % str(kinds))
	await _unload()


## The enemies that idle by patrolling (every Rover; the Night Guards) must
## not jitter (LAY-10: a leash compared in the wrong space flipped facing
## every frame) and must stay in their lane; the dormant Staffers must stand
## perfectly still until their encounter wakes them.
func _idle_patrol_in_level() -> void:
	await _load()
	# hero stays at A01 start, far away; watch every patroller's idle beat
	var patrollers: Array = []
	var sleepers: Array = []
	for e in get_tree().get_nodes_in_group("enemy"):
		if not level.is_ancestor_of(e):
			continue
		if e is PatrolRover or (e is Brawler and e.tuning.patrol_speed() > 0.0):
			patrollers.append(e)
		elif e is Brawler and e.tuning.dormant_until_active:
			sleepers.append(e)
	check(patrollers.size() == 14, "8 Night Guards + 6 Rovers idle by patrolling (got %d)" % patrollers.size())
	check(sleepers.size() == 2, "the 2 Staffers idle dormant (got %d)" % sleepers.size())
	var flips := {}
	var last := {}
	var x0 := {}
	var max_out := {}
	for c in patrollers + sleepers:
		flips[c] = 0
		last[c] = c.facing
		x0[c] = c.global_position.x
		max_out[c] = 0.0
	for t in 120:
		await get_tree().physics_frame
		for c in patrollers + sleepers:
			if c.facing != last[c]:
				flips[c] += 1
				last[c] = c.facing
			if c._group != null:
				var lane := _lane_global(c._group)
				max_out[c] = maxf(max_out[c], maxf(lane.position.x - c.global_position.x, c.global_position.x - lane.end.x))
	for c in patrollers:
		print("[probe_lay_enc] %s %s idle 2s in assembled level: facing flips=%d, moved %.0f px, patrol_min/max_x=%s/%s vs global x=%.0f" % [
				c.scene_file_path.get_file().get_basename(), c.entity_id, flips[c], c.global_position.x - x0[c], str(c.patrol_min_x), str(c.patrol_max_x), c.global_position.x])
		check(flips[c] <= 4, "%s does not jitter (facing flipped %d times in 2 s idle)" % [c.entity_id, flips[c]])
		check(max_out[c] <= 0.0, "%s stays inside its lane while idle (out by %.1f px)" % [c.entity_id, max_out[c]])
	for c in sleepers:
		check(c.state == Brawler.State.DORMANT and absf(c.global_position.x - x0[c]) < 1.0 and flips[c] == 0,
				"%s stands still, dormant, while its encounter sleeps (state %d, moved %.1f px)" % [c.entity_id, c.state, c.global_position.x - x0[c]])
	await _unload()


func _depot_exit() -> void:
	await _load()
	var a5: AreaRoot = level.areas[4]
	var hatch: EmergencyHatch = a5.get_node("Geometry/Hatch")
	check(not hatch.is_open(), "hatch starts closed")
	level.hero.respawn_at(a5.to_global(Vector2(600, -4)))
	await physics_frames(3)
	await hold("interact", 0.1)
	await physics_frames(3)
	# M5: the real SC01 event is a skippable ~19s scene, not the old M3
	# stub's instant flag-flip — skip it so this M3-era depot-exit test still
	# proves the hatch/geometry contract quickly (the skip path is proven
	# identical to a full watch-through by test_m5_story.gd's own T16).
	await hold(&"skip", 1.0 / 60.0)
	await physics_frames(6)
	print("[probe_lay_enc] A05 after console only (wallet=%s, evidence=%s, defeated=%s): hatch open=%s" % [
			str(Session.state.get("wallet")), str(Session.state.get("evidence")), str(Session.state.get("defeated")), hatch.is_open()])
	check(hatch.is_open(), "depot hatch opens from the console alone (no kills/chips/evidence)")
	press("move_right")
	await seconds(6.0)
	release_all()
	var lp := a5.to_local(level.hero.global_position)
	check(lp.x > a5.width, "hero walks out through the hatch into A06 (local x=%.0f)" % lp.x)
	await _unload()


func _combat_run() -> void:
	await _load()
	var hero := level.hero
	hero.debug_invulnerable = true
	var enemies: Array = []
	for e in get_tree().get_nodes_in_group("enemy"):
		if level.is_ancestor_of(e):
			enemies.append(e)
	var groups := _groups()
	var prev_state := {}
	var max_out := {}
	for e in enemies:
		prev_state[e] = e.state
		max_out[e] = 0.0
	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(level, [])
	bot.start(hero)
	var vp := Vector2(1280, 720)
	var t := 0
	while bot.running and t < 60 * 300:
		await get_tree().physics_frame
		t += 1
		var cam_c: Vector2 = level.camera.get_screen_center_position()
		var view := Rect2(cam_c - vp * 0.5, vp)
		for g in groups:
			var n := 0
			for e in g.get_children():
				if is_instance_valid(e) and e.is_in_group("enemy") and _attacking(e):
					n += 1
			if n > 1:
				check(false, "%s has at most one windup/active attacker (got %d)" % [g.group_id, n])
		for e in enemies:
			if not is_instance_valid(e):
				continue
			var st = e.state
			var g: EncounterGroup = e._group
			if g != null:
				var lane := _lane_global(g)
				var out := 0.0
				if e.global_position.x < lane.position.x:
					out = lane.position.x - e.global_position.x
				elif e.global_position.x > lane.end.x:
					out = e.global_position.x - lane.end.x
				max_out[e] = maxf(max_out[e], out)
			if st != prev_state[e] and _is_windup(e):
				var a := _area_of(e.global_position.x)
				var in_view := view.has_point(e.global_position + Vector2(0, -24))
				var hero_in_lane: bool = g == null or _lane_global(g).has_point(hero.global_position)
				var dist: float = absf(e.global_position.x - hero.global_position.x)
				print("[probe_lay_enc] WINDUP %s at local x=%.0f, hero local x=%.0f (dx=%.0f), enemy on-screen=%s, hero inside its lane=%s" % [
						e.entity_id, e.global_position.x - a.global_position.x, hero.global_position.x - a.global_position.x, dist, in_view, hero_in_lane])
				check(in_view, "%s never begins an attack from off-screen (dx=%.0f)" % [e.entity_id, dist])
			prev_state[e] = st
	check(bot.success, "combat bot run completes")
	for e in enemies:
		if is_instance_valid(e) and max_out[e] > 0.0:
			print("[probe_lay_enc] %s left its lane by up to %.0f px" % [e.entity_id, max_out[e]])
	bot.queue_free()
	await _unload()


func _is_windup(e: Node) -> bool:
	if e is PatrolRover:
		return e.state == PatrolRover.State.WINDUP
	return e.state == Brawler.State.WINDUP


func _attacking(e: Node) -> bool:
	if e is PatrolRover:
		return e.state == PatrolRover.State.WINDUP or e.state == PatrolRover.State.CHARGE
	return e.state == Brawler.State.WINDUP or e.state == Brawler.State.STRIKE


## Hero idles at a CP/switch interaction spot while the neighbouring group is
## active and its enemy is placed at its lane edge nearest that spot.
func _exposure(area_idx: int, group_path: String, enemy_name: String, enemy_local_x: float, hero_local: Vector2, label: String) -> void:
	await _load()
	var ar: AreaRoot = level.areas[area_idx]
	var g: EncounterGroup = ar.get_node(group_path)
	for c in g.get_children():
		if c.is_in_group("enemy") and c.name != enemy_name:
			c.queue_free()
	var e: Node2D = g.get_node(enemy_name)
	e.global_position = ar.to_global(Vector2(enemy_local_x, hero_local.y))
	level.hero.respawn_at(ar.to_global(hero_local + Vector2(0, -4)))
	await physics_frames(2)
	g.is_active = true
	var hp0 := Session.get_health()
	var min_x := INF
	var max_y := -INF
	for t in 60 * 6:
		await get_tree().physics_frame
		var lp := ar.to_local(level.hero.global_position)
		min_x = minf(min_x, lp.x)
		max_y = maxf(max_y, lp.y)
	var lp2 := ar.to_local(level.hero.global_position)
	print("[probe_lay_enc] %s: hero idle at local %s with %s at lane-edge local x=%.0f for 6s -> health %d->%d, hero final local (%.0f,%.0f), max y=%.0f" % [
			label, str(hero_local), e.get("entity_id"), enemy_local_x, hp0, Session.get_health(), lp2.x, lp2.y, max_y])
	check(Session.get_health() == hp0, "%s: idling at the interaction spot takes no damage from the neighbouring group (health %d->%d)" % [label, hp0, Session.get_health()])
	await _unload()


func _station_and_switch_exposure() -> void:
	# LAY-13 fix: E06's lane_rect was shrunk to end at local 5100 (was 5310)
	# so its Night Guard can never reach anywhere near CP02 (station at local
	# 5420). Worst case is the guard sitting right at that new lane edge.
	await _exposure(2, "Encounters/EncounterGroup_E06", "NightGuard_SE01_01", 5100.0, Vector2(5360, -540), "A03 CP02 station vs E06")
	# LAY-14 fix: E08's lane_rect ends at local 3900 (SW01 lever at 4130,
	# outside it). Worst case is the Night Guard at that lane edge.
	await _exposure(3, "Encounters/EncounterGroup_E08", "NightGuard_SE01_02", 3900.0, Vector2(4130, 96), "A04 SW01 lever vs E08")
