extends TestCase
## M3 layout/fairness regression: runs the RouteBot through the assembled
## level_01 and MEASURES, from the actual solid geometry the hero stands on,
## every airborne transition (gap, rise, obstacle clearance), every landing's
## distance to same-floor enemy starts, and the retreat floor behind the hero
## at each encounter activation. Design limits from 02-area-blueprints.md.
## Grew out of the M3 assembly review (LAY-03 Rover (then Clipper) windup on
## the landing, LAY-08 Night Guards and Staffers (then Staffers) too close to a
## landing, LAY-09 backstops above the ordinary-rise limit, LAY-16 E11 retreat
## floor); keep passing after any future geometry change. C41 (the fun pass)
## added enemies near the main route (E08's Rover, E14's Night Guard, the
## hold-out's staffers); the hold-out's two sleep until the exit wicket's
## override wakes them, so they are not landing hazards.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const H := 96.0
const MAIN_GAP_MAX := 2.0 * H      # 192
const MAIN_RISE_MAX := 0.9 * H     # 86.4
const OPT_GAP_MAX := 2.4 * H       # 230.4
const REACH_RISE_MAX := 144.0
const LANDING_ENEMY_MIN := 2.0 * H
const RETREAT_MIN := 2.0 * H

var level: LevelDirector


func run() -> void:
	await _run_route([], "MAIN")
	await _run_route(["OPT01"], "OPT01")
	await _run_route(["OPT02"], "OPT02")


func _solid_rect(obj: Node) -> Rect2:
	for c in obj.get_children():
		if c is CollisionShape2D and c.shape is RectangleShape2D and not c.disabled:
			var s: Vector2 = c.shape.size
			return Rect2(c.global_position - s * 0.5, s)
	return Rect2()


func _all_solids(root: Node, out: Array) -> void:
	for c in root.get_children():
		if c is CollisionObject2D and (c.collision_layer & 1) and not (c is CharacterBody2D):
			var r := _solid_rect(c)
			if r.size != Vector2.ZERO:
				out.append({"node": c, "rect": r})
		_all_solids(c, out)


func _area_of_x(x: float) -> AreaRoot:
	for a in level.areas:
		if x < a.global_position.x + a.width:
			return a
	return level.areas[-1]


func _floor_collider(hero: Hero) -> Object:
	for i in hero.get_slide_collision_count():
		var col := hero.get_slide_collision(i)
		if col.get_normal().y < -0.7:
			return col.get_collider()
	return null


## Flat floor length behind (to the left of) x at floor y, stopping at a
## drop >8px, a step up >8px, or a wall at body height.
func _floor_y_below(p: Vector2) -> float:
	var space := level.get_world_2d().direct_space_state
	var q := PhysicsRayQueryParameters2D.create(p + Vector2(0, -4), p + Vector2(0, 600))
	q.collision_mask = 1
	var hit := space.intersect_ray(q)
	return hit.position.y if not hit.is_empty() else p.y


func _retreat_left(x: float, y: float) -> float:
	var space := level.get_world_2d().direct_space_state
	var d := 0.0
	while d < 800.0:
		var px := x - d - 8.0
		var q := PhysicsRayQueryParameters2D.create(Vector2(px, y - 40.0), Vector2(px, y + 12.0))
		q.collision_mask = 1
		var hit := space.intersect_ray(q)
		if hit.is_empty() or absf(hit.position.y - y) > 8.0:
			break
		d += 8.0
	return d


func _run_route(branches: Array, label: String) -> void:
	Session.new_run()
	level = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	var hero: Hero = level.hero
	hero.debug_invulnerable = true

	var enemies: Array = []
	for e in get_tree().get_nodes_in_group("enemy"):
		# The hold-out's staffers (C41) sleep until the exit wicket's override
		# wakes them, so a landing near one is never a landing into a fight.
		if level.is_ancestor_of(e) and not (e._group != null and e._group.wait_for_trigger):
			enemies.append({"id": e.entity_id, "pos": e.global_position, "cls": e.get_class_name() if e.has_method("get_class_name") else e.get_script().get_global_name()})
	var groups: Array = []
	_find_groups(level, groups)
	var group_active := {}
	for g in groups:
		group_active[g] = g.is_active

	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(level, branches)
	bot.start(hero)

	var was_floor := true
	var takeoff := {}
	var events: Array = []
	var ticks := 0
	var last_floor: Object = null
	var min_x := INF
	var max_x := -INF
	while bot.running and ticks < 60 * 400:
		await get_tree().physics_frame
		ticks += 1
		var on_floor := hero.is_on_floor()
		var fc := _floor_collider(hero) if on_floor else null
		if on_floor and fc != null:
			last_floor = fc
		if was_floor and not on_floor:
			takeoff = {"x": hero.global_position.x, "y": hero.global_position.y, "floor": last_floor,
					"rect": _solid_rect(last_floor) if last_floor else Rect2(), "tick": ticks,
					"pt": bot.point_index_reached}
			min_x = hero.global_position.x
			max_x = hero.global_position.x
		if not on_floor:
			min_x = minf(min_x, hero.global_position.x)
			max_x = maxf(max_x, hero.global_position.x)
		if not was_floor and on_floor and fc != null and not takeoff.is_empty():
			events.append({"to": takeoff, "land_x": hero.global_position.x, "land_y": hero.global_position.y,
					"floor": fc, "rect": _solid_rect(fc), "air": (ticks - takeoff.tick) / 60.0,
					"minx": min_x, "maxx": max_x, "pt": takeoff.pt})
		was_floor = on_floor
		# encounter activation -> retreat floor behind hero
		for g in groups:
			if is_instance_valid(g) and g.is_active and not group_active[g]:
				group_active[g] = true
				var fy := _floor_y_below(hero.global_position)
				var r := _retreat_left(hero.global_position.x, fy)
				print("[probe_lay_route][%s] ACTIVATE %s at hero=(%.0f,%.0f) area=%s retreat_floor_behind=%.0fpx" % [
						label, g.group_id, hero.global_position.x, hero.global_position.y,
						_area_of_x(hero.global_position.x).area_id, r])
				if label == "MAIN":
					check(r >= RETREAT_MIN, "%s activation: flat retreat floor behind hero %.0f px >= 2H (192)" % [g.group_id, r])
	var report := bot.get_report()
	check(bot.success, "[%s] bot completes (%s)" % [label, report.failure])

	var solids: Array = []
	_all_solids(level, solids)
	var pts: Array = bot.points
	for ev in events:
		var t: Dictionary = ev.to
		var tr: Rect2 = t.rect
		var lr: Rect2 = ev.rect
		var rise: float = tr.position.y - lr.position.y   # +ve = landing higher
		var gap := 0.0
		if ev.land_x > t.x:
			gap = lr.position.x - tr.end.x
		else:
			gap = tr.position.x - lr.end.x
		var same: bool = ev.floor == t.floor
		# obstacle clearance: highest solid (not takeoff/landing) the hero passed over
		var clear := 0.0
		var clear_name := ""
		for s in solids:
			if s.node == t.floor or s.node == ev.floor:
				continue
			var r: Rect2 = s.rect
			if r.end.x <= ev.minx - 20.0 or r.position.x >= ev.maxx + 20.0:
				continue
			if r.position.y >= tr.position.y:
				continue
			# only things the hero actually went over (below its path), not ceilings
			if r.position.y < tr.position.y - 170.0:
				continue
			var c: float = tr.position.y - r.position.y
			if c > clear:
				clear = c
				clear_name = s.node.name
		var area := _area_of_x(t.x)
		var pt_name: String = pts[ev.pt].name if ev.pt >= 0 and ev.pt < pts.size() else "?"
		var branch_pt: String = pts[ev.pt].branch if ev.pt >= 0 and ev.pt < pts.size() else ""
		if label == "MAIN" and ev.air > 0.12:
			for e in enemies:
				if absf(e.pos.y - ev.land_y) < 64.0:
					var d: float = absf(e.pos.x - ev.land_x)
					if d < 400.0:
						print("[probe_lay_route][MAIN]   landing %s local x=%.0f (from %s) -> enemy %s start %.0f px away" % [area.area_id, ev.land_x - area.global_position.x, t.floor.name if t.floor else "?", e.id, d])
					check(d >= LANDING_ENEMY_MIN, "enemy %s starts %.0f px from main-route landing at %s local x=%.0f (>= 192)" % [e.id, d, area.area_id, ev.land_x - area.global_position.x])
		var meaningful: bool = ev.air > 0.12 and (gap > 0.5 or rise > 4.0 or clear > 4.0)
		if not meaningful:
			continue
		print("[probe_lay_route][%s] %s pt=%s%s from %s(top %.0f) -> %s(top %.0f) gap=%.0f rise=%.0f clear=%.0f%s air=%.2fs land_x_local=%.0f" % [
				label, area.area_id, pt_name, ("[" + branch_pt + "]") if branch_pt != "" else "",
				t.floor.name if t.floor else "?", tr.position.y, ev.floor.name, lr.position.y,
				gap, rise, clear, (" over " + clear_name) if clear_name != "" else "", ev.air,
				ev.land_x - area.global_position.x])
		var is_opt := branch_pt != ""
		if label == "MAIN" or is_opt:
			var gmax := OPT_GAP_MAX if is_opt else MAIN_GAP_MAX
			var rmax := REACH_RISE_MAX if is_opt else MAIN_RISE_MAX
			check(gap <= gmax, "[%s] %s %s gap %.0f px <= %.0f" % [label, area.area_id, pt_name, gap, gmax])
			check(rise <= rmax, "[%s] %s %s rise %.0f px <= %.1f" % [label, area.area_id, pt_name, rise, rmax])
			check(clear <= rmax, "[%s] %s %s required obstacle clearance %.0f px (over %s) <= %.1f" % [label, area.area_id, pt_name, clear, clear_name, rmax])
	print("[probe_lay_route][%s] bot seconds=%.1f area_times=%s" % [label, report.seconds, str(report.area_times)])
	if label == "MAIN":
		var order: Array = report.beat_times.keys()
		order.sort_custom(func(a, b): return report.beat_times[a] < report.beat_times[b])
		var expected: Array = []
		for a in level.areas:
			for b in a.get_beat_ids():
				expected.append(b)
		print("[probe_lay_route] beat order hit: %s" % str(order))
		check(order == expected, "beat entry order during main route equals authored order")
	bot.queue_free()
	level.queue_free()
	await physics_frames(3)


func _find_groups(node: Node, out: Array) -> void:
	for c in node.get_children():
		if c is EncounterGroup:
			out.append(c)
		_find_groups(c, out)
