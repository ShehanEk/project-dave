extends TestCase
## M4b: Level 2's new enemies, fought where they stand. Each fight (E01 the Sidearm Guard
## on the range, E02 the Hound and its handler in the kennel, E03 the Security Drone in
## the flight cage, E05 the Sidearm Guard on the raised step with a Security Drone over
## the Lattice landing, twice: drone first out of the guard's reach, then straight in
## with both at once; E06 the Hound and its handler on the demo floor) is played in the
## REAL Level 2 (LevelDirector: its areas, camera and camera limits) with the base
## Scrapjack and a plausible scripted player, like test_rover_real_level.gd does for
## Level 1's rovers:
##   - Dave starts at an authored Route point before the encounter's ApproachZone and
##     walks/jumps the area's own Route points (their own action and hold) onto the
##     floor he fights on, so the group wakes exactly as in a playthrough;
##   - he reacts to what he can see: he jumps a round about to reach him (flat or aimed)
##     and each Hound lunge (on its red), sidesteps a Security Drone's locked dive (1.7 H
##     clear of the locked spot, on his own side of it, staying on his floor), backs off a Night Guard's swing, and keeps a
##     stand-off from the brawlers; he shoots a new type only in its punish window (the
##     Sidearm Guard's shot and reload, the drone's hang and climb, the Hound's recovery),
##     or after it has held back for IDLE_FIRE_S, and a Night Guard handler whenever he is
##     on screen once his Hound is down; so every fight plays its tells and dodges out;
##   - every fight must end with all its enemies down, Dave alive, at most half his
##     health lost, inside the time budget;
##   - and the fairness rules hold throughout (encounter-and-boss-fairness.md, P23): at
##     most 2 shooters and 3 attackers on screen, a gun fires only with its body 1 H
##     inside the camera and Dave on screen, no tell starts at an airborne Dave, and no
##     standing spot in a gun lane has a pit edge within 1.5 H behind it (checked as a
##     placement sweep of each gun's whole reach and at every tick a gun aims).
## Each fight is a fresh level build; input is released at the start of each.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const H := 96.0
const BUDGET_S := 40.0
## The Scrapjack's reach is 640 px; the player shoots a little inside it.
const SHOOT_RANGE := 600.0
## Held jump: the full 1.6 H jump (the apex comes at 0.42 s).
const JUMP_HOLD_TICKS := 27
## Jump when a round will reach Dave's near edge within this many seconds.
const ROUND_REACT_S := 0.2
## Dave's half width (the hurtbox is 40 px wide).
const HALF_W := 20.0
## A Security Drone's dive: sidestep this far from the locked spot.
const DODGE_DRONE := 1.7 * H
## A new type that has shown no tell for this long (it holds back) may be shot anyway.
const IDLE_FIRE_S := 4.0
## A Night Guard closer than this (px), and winding up or walking in, makes Dave back off.
const GUARD_TOO_CLOSE := 140.0

const FIGHTS := [
	{"label": "E01 Sidearm Guard on the range (A02)", "area": 1, "group": "EncounterGroup_E01",
		"route": ["R01_RangeLane", "R02_JumpBench", "R03_PastBench"],
		"floor": [1560.0, 2620.0, 0.0], "advance_x": 2150.0, "standoff": 300.0},
	{"label": "E02 Hound and handler in the kennel (A02)", "area": 1, "group": "EncounterGroup_E02",
		"route": ["R07_UseCP01"],
		"floor": [2950.0, 4870.0, 0.0], "advance_x": 4300.0, "standoff": 280.0},
	{"label": "E03 Security Drone in the flight cage (A03)", "area": 2, "group": "EncounterGroup_E03",
		"route": ["R05_AcrossDeck1", "R06_JumpStep2", "R07_OnStep2", "R08_JumpDeck2"],
		"floor": [1830.0, 2770.0, -240.0], "advance_x": 2050.0, "standoff": 280.0},
	{"label": "E05 Sidearm Guard and Security Drone on the Lattice landing (A05)", "area": 4, "group": "EncounterGroup_E05",
		"route": ["R05_OnCatwalk", "R06_JumpLanding"],
		"floor": [1530.0, 2380.0, -300.0], "advance_x": 2150.0, "drone_hold_x": 1760.0, "standoff": 280.0},
	{"label": "E05 again, both at once: straight into the guard's reach under the drone (A05)", "area": 4, "group": "EncounterGroup_E05",
		"route": ["R05_OnCatwalk", "R06_JumpLanding"],
		"floor": [1530.0, 2380.0, -300.0], "advance_x": 2150.0, "standoff": 280.0, "both_on_screen": true},
	{"label": "E06 Hound and handler on the demo floor (A06)", "area": 5, "group": "EncounterGroup_E06",
		"route": ["R02_UseCP05", "R03_JumpDockHole"],
		"floor": [1470.0, 2940.0, 0.0], "advance_x": 2350.0, "standoff": 280.0},
]

var _reports: Array = []


func run() -> void:
	await _test_screen_caps_at_rest()
	for cfg in FIGHTS:
		await _fight(cfg)
	print("[test_l02_encounters] ==== SUMMARY ====")
	for r in _reports:
		print("[test_l02_encounters]   %s" % r)
	CheckpointService.clear()
	Session.new_run()


# --- the screen caps, as placed ------------------------------------------------------------

## A screen-wide window (the camera's 1067 px at zoom 1.2) slid along the whole level: at
## most 2 shooters (Sidearm Guards and Security Drones) and 3 attackers (every enemy) in
## it at once, counting each enemy where it stands and across its patrol span.
func _test_screen_caps_at_rest() -> void:
	release_all()
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	await physics_frames(3)
	var view_w: float = lvl.get_viewport_rect().size.x / lvl.camera.zoom.x
	var spans: Array = []   # [min_x, max_x, is_shooter, id]
	for e in get_tree().get_nodes_in_group("enemy"):
		var lo: float = e.global_position.x
		var hi: float = e.global_position.x
		if e is Drone:
			var area: Node2D = e._area_root
			lo = minf(lo, area.to_global(Vector2(e._span.x, 0)).x)
			hi = maxf(hi, area.to_global(Vector2(e._span.y, 0)).x)
		spans.append([lo, hi, e is Gunner or e is Drone, e.entity_id])
	check_eq(spans.size(), 12, "setup: Level 2 places 12 enemies")
	var worst_s := 0
	var worst_a := 0
	var worst_at := 0.0
	var x := 0.0
	while x <= lvl.level_width:
		var shooters := 0
		var attackers := 0
		for sp in spans:
			if sp[1] >= x and sp[0] <= x + view_w:
				attackers += 1
				if sp[2]:
					shooters += 1
		if attackers > worst_a or shooters > worst_s:
			worst_at = x
		worst_s = maxi(worst_s, shooters)
		worst_a = maxi(worst_a, attackers)
		x += 32.0
	check(worst_s <= 2, "at most 2 shooters in any screen-wide stretch of Level 2 (max %d)" % worst_s)
	check(worst_a <= 3, "at most 3 attackers in any screen-wide stretch of Level 2 (max %d, near x %.0f)" % [worst_a, worst_at])
	print("[test_l02_encounters] screen caps at rest: max %d shooters, %d attackers per screen" % [worst_s, worst_a])
	lvl.queue_free()
	await physics_frames(2)


# --- one fight -------------------------------------------------------------------------

func _fight(cfg: Dictionary) -> void:
	release_all()
	await physics_frames(2)
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	await physics_frames(3)
	var label: String = cfg.label
	var area: AreaRoot = lvl.areas[cfg.area]
	var group: EncounterGroup = area.get_node("Encounters/" + String(cfg.group))
	var enemies: Array = []
	for c in group.get_children():
		if c.is_in_group("enemy"):
			enemies.append(c)
	var new_type_ids: Array = []
	for e in enemies:
		if e is Gunner or e is Drone or e is Hound:
			new_type_ids.append(e.entity_id)
	var points: Array = []
	for n in cfg.route:
		points.append(area.get_node("Route/" + String(n)))
	var hero: Hero = lvl.hero
	check(hero.aim_pivot.get_node_or_null("Scrapjack") != null, "%s: Dave holds the base Scrapjack" % label)
	check(Session.equipped_weapon().begins_with("L02-W01") and Session.weapon_stage("W01") == 0,
			"%s: at base stage (%s, stage %d)" % [label, Session.equipped_weapon(), Session.weapon_stage("W01")])

	# The start: an authored Route point before the ApproachZone.
	var zone: Area2D = group.get_node("ApproachZone")
	var zone_shape := (zone.get_node("CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D
	var zone_left: float = zone.global_position.x - zone_shape.size.x * 0.5
	var start: Node2D = points[0]
	check(start.global_position.x < zone_left, "%s: Dave starts at %s (x %.0f), before the ApproachZone (x %.0f)" % [
			label, start.name, area.to_local(start.global_position).x, area.to_local(Vector2(zone_left, 0)).x])
	await _teleport(lvl, area, start.global_position + Vector2(0.0, -4.0))
	check(not group.is_active, "%s: the group sleeps until Dave's approach" % label)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(300.0, -40.0)

	# The static placement sweep: no pit edge within 1.5 H behind any spot a gun reaches.
	var fmin: float = area.to_global(Vector2(cfg.floor[0], 0)).x
	var fmax: float = area.to_global(Vector2(cfg.floor[1], 0)).x
	var floor_y: float = area.to_global(Vector2(0, cfg.floor[2])).y
	for e in enemies:
		if e is Gunner:
			_sweep_gun_lane(lvl, e, fmin, fmax, floor_y, label)

	var ctx := {
		"t": 0, "health0": Session.get_health(), "min_health": Session.get_health(), "hits": 0,
		"tells": 0, "tells_by": {}, "shots": 0, "dives": 0, "lunges": 0, "swings": 0,
		"max_shooters": 0, "max_attackers": 0, "fire_gate_bad": [], "airborne_tells": 0,
		"tell_gate_bad": [], "pit_bad": [], "died": false, "jumps": 0, "dodges": 0,
		"prev": {}, "last_attack": {}, "active_at": -1, "hit_by": [], "tells_by_enemy": {},
	}
	hero.died.connect(func(): ctx.died = true)
	var on_health := _on_health.bind(ctx)
	Session.health_changed.connect(on_health)
	for e in enemies:
		if e is Gunner:
			e.fired.connect(_on_gunner_fired.bind(e, lvl, ctx))

	var idx := 1
	var in_fight := false
	var jump_left := 0         # ticks the jump action stays held
	var route_jump := false    # a route point's jump is under way
	var route_jump_left_ground := false
	var dodge_x := NAN
	var dodging_drone: Node = null
	var max_ticks := int(BUDGET_S * 60.0)
	while ctx.t < max_ticks:
		var alive := enemies.filter(func(e): return _alive(e))
		if alive.is_empty() or ctx.died:
			break
		var view := _view(lvl)
		if group.is_active and int(ctx.active_at) < 0:
			ctx.active_at = int(ctx.t)
		_audit(lvl, hero, alive, view, fmin, fmax, ctx)
		var feet := hero.global_position
		var want_jump := false
		var jump_ticks := JUMP_HOLD_TICKS
		var target_x := NAN
		var tol := 10.0

		# 1. Threats: rounds about to reach him, a Hound's red, a drone's locked dive,
		#    a Night Guard winding up (or walking in) close by.
		for r in get_tree().get_nodes_in_group("enemy_round"):
			if _round_arrival(r, hero) <= ROUND_REACT_S:
				want_jump = true
		var guard_close: Node = null
		for e in alive:
			if e is Hound:
				if _hound_red_at(e, hero):
					want_jump = true
			elif e is Brawler:
				var dx: float = e.global_position.x - feet.x
				if absf(e.global_position.y - feet.y) <= 64.0 and absf(dx) <= GUARD_TOO_CLOSE \
						and e.state in [Brawler.State.WINDUP, Brawler.State.STRIKE, Brawler.State.APPROACH]:
					guard_close = e
			elif e is Drone:
				if e.state == Drone.State.TELL and e.is_lock_set() and dodging_drone == null and hero.is_on_floor():
					var lock: Vector2 = e.locked_point()
					if absf(lock.x - feet.x) < DODGE_DRONE:
						dodging_drone = e
						dodge_x = _pick_dodge(lock.x, feet.x, e.global_position.x, fmin, fmax)
						ctx.dodges = int(ctx.dodges) + 1
		if dodging_drone != null and (not _alive(dodging_drone) or not (dodging_drone.state in [Drone.State.TELL, Drone.State.DIVE])):
			dodging_drone = null
			dodge_x = NAN

		# 2. Where to go: the area's own Route points onto the fight floor, then the fight.
		if not in_fight:
			if route_jump:
				target_x = points[idx + 1].global_position.x if idx + 1 < points.size() else (fmin + fmax) * 0.5
				tol = 4.0
				if not hero.is_on_floor():
					route_jump_left_ground = true
				elif route_jump_left_ground and jump_left <= 0:
					route_jump = false
					idx += 1
			elif idx < points.size():
				var p: RoutePoint = points[idx]
				target_x = p.global_position.x
				tol = maxf(p.tolerance * 0.5, 4.0)
				if absf(feet.x - target_x) <= tol and hero.is_on_floor():
					if p.action == RoutePoint.Action.JUMP:
						if jump_left <= 0:
							want_jump = true
							jump_ticks = maxi(int(p.hold_jump * 60.0), 6)
							route_jump = true
							route_jump_left_ground = false
					else:
						idx += 1
			if idx >= points.size() and not route_jump and hero.is_on_floor() \
					and absf(feet.y - floor_y) <= 4.0 and feet.x >= fmin and feet.x <= fmax:
				in_fight = true
		if in_fight:
			if dodging_drone != null:
				target_x = dodge_x
				tol = 6.0
			elif guard_close != null:
				var away: float = -signf(guard_close.global_position.x - feet.x)
				target_x = clampf(feet.x + away * 220.0, fmin + 30.0, fmax - 30.0)
			else:
				target_x = _fight_spot(cfg, area, alive, hero, fmin, fmax)

		# 3. Shooting: a new type only in its punish window (the gunner's shot and reload,
		#    the drone's hang and climb, the Hound's recovery), or once it has shown no
		#    tell for IDLE_FIRE_S (it holds back); a Night Guard handler whenever he is on
		#    screen once his Hound is down. Also while backing off or dodging.
		var target: Node = _pick_target(alive.filter(func(e): return _open_to_fire(e, alive, ctx)), hero, view)
		if target != null:
			hero.aim_override = _center(target)
			press("fire")
		else:
			release("fire")
			if not is_nan(target_x) and absf(target_x - feet.x) > 8.0:
				hero.aim_override = feet + Vector2(signf(target_x - feet.x) * 300.0, -40.0)

		# 4. Apply: steer (hopping a low obstacle he runs into) and jump.
		if is_nan(target_x) or absf(target_x - feet.x) <= tol:
			release("move_left"); release("move_right")
		elif target_x > feet.x:
			release("move_left"); press("move_right")
		else:
			release("move_right"); press("move_left")
		if in_fight and hero.is_on_floor() and hero.is_on_wall() and not is_nan(target_x) and absf(target_x - feet.x) > tol:
			want_jump = true
			jump_ticks = 16
		if jump_left > 0:
			jump_left -= 1
			if jump_left == 0:
				release("jump")
		elif want_jump and hero.is_on_floor():
			press("jump")
			jump_left = jump_ticks
			ctx.jumps = int(ctx.jumps) + 1
		await physics_frames(1)
		ctx.t = int(ctx.t) + 1
	release_all()

	# --- the verdict ---
	var down := enemies.filter(func(e): return not _alive(e)).size()
	var lost: int = int(ctx.health0) - int(ctx.min_health)
	var secs: float = ctx.t / 60.0
	var half: int = Session.max_health() / 2
	check(down == enemies.size(), "%s: every enemy is down (%d of %d) in %.1f s" % [label, down, enemies.size(), secs])
	check(not ctx.died, "%s: Dave survives" % label)
	check(lost <= half, "%s: Dave loses at most half his health (%d of %d)" % [label, lost, Session.max_health()])
	check(secs < BUDGET_S, "%s: inside the %.0f s budget (%.1f s)" % [label, BUDGET_S, secs])
	check(int(ctx.tells) >= 1, "%s: the encounter showed its tells (%d) and the player answered them" % [label, ctx.tells])
	for id in new_type_ids:
		check(int(ctx.tells_by_enemy.get(id, 0)) >= 1,
				"%s: %s showed its tell before it went down (the player waited for its opening)" % [label, id])
	if cfg.get("both_on_screen", false):
		check(int(ctx.max_shooters) == 2, "%s: the guard and the drone were on screen together (max %d shooters)" % [label, ctx.max_shooters])
	check(int(ctx.max_shooters) <= 2, "%s: at most 2 shooters on screen (max %d)" % [label, ctx.max_shooters])
	check(int(ctx.max_attackers) <= 3, "%s: at most 3 attackers on screen (max %d)" % [label, ctx.max_attackers])
	check((ctx.fire_gate_bad as Array).is_empty(), "%s: every round left with its gunner 1 H inside the camera and Dave on screen (%s)" % [label, ctx.fire_gate_bad])
	check((ctx.tell_gate_bad as Array).is_empty(), "%s: every drone tell started 1 H inside the camera (%s)" % [label, ctx.tell_gate_bad])
	check(int(ctx.airborne_tells) == 0, "%s: no tell started at an airborne Dave (%d)" % [label, ctx.airborne_tells])
	check((ctx.pit_bad as Array).is_empty(), "%s: no pit edge within 1.5 H behind Dave while a gun aimed at him (%s)" % [label, ctx.pit_bad])
	var report := "%s: %s in %.1f s, damage taken %d/%d %s, tells %s, rounds %d, dives %d, lunges %d, swings %d, jumps %d, dodges %d, max on screen %d shooters / %d attackers" % [
			label, "WON" if down == enemies.size() and not ctx.died else "LOST", secs, lost, Session.max_health(), str(ctx.hit_by),
			str(ctx.tells_by), ctx.shots, ctx.dives, ctx.lunges, ctx.swings, ctx.jumps, ctx.dodges, ctx.max_shooters, ctx.max_attackers]
	_reports.append(report)
	print("[test_l02_encounters] " + report)
	if Session.health_changed.is_connected(on_health):
		Session.health_changed.disconnect(on_health)
	lvl.queue_free()
	await physics_frames(2)
	CheckpointService.clear()


func _on_health(current: int, _max: int, ctx: Dictionary) -> void:
	if current < int(ctx.min_health):
		ctx.hits = int(ctx.hits) + 1
		# What landed it (for the report).
		var by: Array = []
		for e in get_tree().get_nodes_in_group("enemy"):
			if e is Drone and e.state == Drone.State.DIVE:
				by.append("drone dive")
			elif e is Brawler and e.is_attack_active():
				by.append("hound lunge" if e is Hound else "guard swing")
		for r in get_tree().get_nodes_in_group("enemy_round"):
			if r is EnemyRound and r.is_spent():
				by.append("round (%s)" % ("flat" if absf(r.direction.y) < 0.05 else "aimed"))
		(ctx.hit_by as Array).append("/".join(by) if not by.is_empty() else "?")
	ctx.min_health = mini(int(ctx.min_health), current)


func _on_gunner_fired(_round: Node, g: Gunner, lvl: LevelDirector, ctx: Dictionary) -> void:
	ctx.shots = int(ctx.shots) + 1
	var view := _view(lvl)
	var dave_on: bool = view.has_point(lvl.hero.global_position + Vector2(0.0, -H * 0.5))
	if not g.is_on_camera() or not view.grow(-H).has_point(g.global_position + Vector2(0.0, -Gunner.HEIGHT * 0.5)) or not dave_on:
		(ctx.fire_gate_bad as Array).append("%s at %s, Dave at %s" % [g.entity_id, str(g.global_position.round()), str(lvl.hero.global_position.round())])


# --- the player's choices ----------------------------------------------------------------

## Where Dave stands while no threat moves him: a stand-off from the nearest brawler or
## gunner on his floor, else the fight's spot (out of the guard's reach while a drone
## still flies in E05).
func _fight_spot(cfg: Dictionary, area: AreaRoot, alive: Array, hero: Hero, fmin: float, fmax: float) -> float:
	var feet := hero.global_position
	var nearest: Node2D = null
	for e in alive:
		if e is Drone:
			continue
		if absf(e.global_position.y - feet.y) > 64.0:
			continue
		if nearest == null or absf(e.global_position.x - feet.x) < absf(nearest.global_position.x - feet.x):
			nearest = e
	var spot: float = area.to_global(Vector2(cfg.advance_x, 0)).x
	if cfg.has("drone_hold_x") and alive.any(func(e): return e is Drone):
		spot = area.to_global(Vector2(cfg.drone_hold_x, 0)).x
	if nearest != null:
		var dx: float = nearest.global_position.x - feet.x
		var standoff: float = cfg.standoff
		if absf(dx) <= standoff:
			spot = feet.x
		else:
			spot = nearest.global_position.x - signf(dx) * standoff
	return clampf(spot, fmin + 30.0, fmax - 30.0)


## A Security Drone's locked dive: on to the side of the locked spot Dave is already on
## (never back across it), or away from the drone when he stands on it; the other side
## only when his floor runs out.
func _pick_dodge(lock_x: float, feet_x: float, drone_x: float, fmin: float, fmax: float) -> float:
	var side: float = signf(feet_x - lock_x)
	if absf(feet_x - lock_x) < 4.0:
		side = -1.0 if drone_x >= lock_x else 1.0
	for sd in [side, -side]:
		var x: float = lock_x + sd * DODGE_DRONE
		if x >= fmin + 30.0 and x <= fmax - 30.0:
			return x
	return clampf(lock_x + side * DODGE_DRONE, fmin + 30.0, fmax - 30.0)


## The player's discipline: may he shoot `e` now?
func _open_to_fire(e: Node, alive: Array, ctx: Dictionary) -> bool:
	if int(ctx.active_at) < 0:
		return false
	var since: int = maxi(int(ctx.last_attack.get(e, 0)), int(ctx.active_at))
	var idle: bool = int(ctx.t) - since >= int(IDLE_FIRE_S * 60.0)
	if e is Gunner:
		return e.state in [Gunner.State.FIRE, Gunner.State.RELOAD] or (idle and e.state != Gunner.State.AIM)
	if e is Drone:
		return e.state in [Drone.State.HANG, Drone.State.CLIMB] or (idle and e.state == Drone.State.PATROL)
	if e is Hound:
		return e.state == Brawler.State.RECOVERY or (idle and not e.is_in_chain())
	# A handler once his dog is down (the dog is the first problem, and stands in the
	# line of fire in front of him).
	return not alive.any(func(o): return o is Hound)


## Seconds until `r` reaches Dave's near edge, or INF when it will not (spent, flying
## away, or passing clear above or below him).
func _round_arrival(r: Node, hero: Hero) -> float:
	if not (r is EnemyRound) or r.is_spent():
		return INF
	var dir: Vector2 = r.direction
	var feet := hero.global_position
	var dx: float = feet.x - r.global_position.x
	if dir.x * dx <= 0.0 or absf(dir.x) < 0.05:
		return INF
	var gap: float = absf(dx) - HALF_W
	if gap < 0.0:
		gap = 0.0
	var t: float = gap / (r.speed * absf(dir.x))
	# Where it crosses Dave's x: only a round that would meet his standing body counts.
	var y_at: float = r.global_position.y + dir.y / absf(dir.x) * absf(dx)
	if y_at < feet.y - H - 8.0 or y_at > feet.y + 4.0:
		return INF
	return t


## A Hound on Dave's floor, red (the last part of a crouch or re-crouch), facing him and
## within a lunge's reach.
func _hound_red_at(h: Hound, hero: Hero) -> bool:
	if h.state != Brawler.State.WINDUP:
		return false
	if h._state_timer < h._windup_len - h.tuning.red_time:
		return false
	var dx: float = hero.global_position.x - h.global_position.x
	if absf(hero.global_position.y - h.global_position.y) > 64.0:
		return false
	if signf(dx) != float(h.facing) and absf(dx) > 8.0:
		return false
	return absf(dx) <= h.tuning.lunge_distance() + h.tuning.attack_box_offset.x + h.tuning.attack_box_size.x + HALF_W + 24.0


## The visible enemy to shoot: on screen, in reach, with a clear line; the nearest.
func _pick_target(alive: Array, hero: Hero, view: Rect2) -> Node:
	var best: Node = null
	var best_d := INF
	var from := hero.global_position + Vector2(0.0, -60.0)
	for e in alive:
		var c := _center(e)
		if not view.grow(-16.0).has_point(c):
			continue
		var d := from.distance_to(c)
		if d > SHOOT_RANGE:
			continue
		var q := PhysicsRayQueryParameters2D.create(from, c)
		q.collision_mask = 1
		if not hero.get_world_2d().direct_space_state.intersect_ray(q).is_empty():
			continue
		if d < best_d:
			best_d = d
			best = e
	return best


# --- fairness audit ----------------------------------------------------------------------

func _audit(lvl: LevelDirector, hero: Hero, alive: Array, view: Rect2, fmin: float, fmax: float, ctx: Dictionary) -> void:
	# Screen caps: every living enemy in the level that is on screen.
	var shooters := 0
	var attackers := 0
	for e in get_tree().get_nodes_in_group("enemy"):
		if not _alive(e) or not view.has_point(_center(e)):
			continue
		attackers += 1
		if e is Gunner or e is Drone:
			shooters += 1
	ctx.max_shooters = maxi(int(ctx.max_shooters), shooters)
	ctx.max_attackers = maxi(int(ctx.max_attackers), attackers)
	var prev: Dictionary = ctx.prev
	for e in alive:
		var s: int = e.state
		var was: int = prev.get(e, -1)
		prev[e] = s
		if s == was:
			continue
		var tell := false
		if e is Gunner and s == Gunner.State.AIM:
			tell = true
		elif e is Drone and s == Drone.State.TELL:
			tell = true
			if not e.is_on_camera() or not view.grow(-H).has_point(e.global_position):
				(ctx.tell_gate_bad as Array).append("%s at %s" % [e.entity_id, str(e.global_position.round())])
		elif e is Drone and s == Drone.State.DIVE:
			ctx.dives = int(ctx.dives) + 1
		elif e is Brawler and s == Brawler.State.WINDUP:
			tell = was != Brawler.State.STRIKE   # a re-crouch is part of the same chain
		elif e is Brawler and s == Brawler.State.STRIKE:
			if e is Hound:
				ctx.lunges = int(ctx.lunges) + 1
			else:
				ctx.swings = int(ctx.swings) + 1
		if tell:
			ctx.tells = int(ctx.tells) + 1
			ctx.last_attack[e] = int(ctx.t)
			ctx.tells_by_enemy[e.entity_id] = int(ctx.tells_by_enemy.get(e.entity_id, 0)) + 1
			var kind := "gunner" if e is Gunner else ("drone" if e is Drone else ("hound" if e is Hound else "guard"))
			ctx.tells_by[kind] = int(ctx.tells_by.get(kind, 0)) + 1
			if (e is Gunner or e is Drone) and not hero.is_on_floor():
				ctx.airborne_tells = int(ctx.airborne_tells) + 1
	# Pit edges: while a gun aims at Dave on a floor, 1.5 H behind him is floor.
	if hero.is_on_floor():
		for e in alive:
			if e is Gunner and e.state == Gunner.State.AIM:
				var bad := _pit_behind(hero, hero.global_position, signf(hero.global_position.x - e.global_position.x))
				if bad != "" and (ctx.pit_bad as Array).size() < 4:
					(ctx.pit_bad as Array).append(bad)


## "" when there is floor all along 1.5 H behind `feet` (on the side `away` points to),
## else where the floor ends.
func _pit_behind(node: Node2D, feet: Vector2, away: float) -> String:
	var space := node.get_world_2d().direct_space_state
	for k in 10:
		var x: float = feet.x + away * (HALF_W + 1.5 * H * float(k) / 9.0)
		var q := PhysicsRayQueryParameters2D.create(Vector2(x, feet.y - 8.0), Vector2(x, feet.y + 24.0))
		q.collision_mask = 1
		if space.intersect_ray(q).is_empty():
			return "standing at x %.0f, the floor ends by x %.0f" % [feet.x, x]
	return ""


## The placement sweep: every spot on Dave's fight floor that the gunner could aim at
## (the gunner's own gates: range, a clear line, his aim limits) has 1.5 H of floor
## behind it, away from the gun.
func _sweep_gun_lane(lvl: LevelDirector, g: Gunner, fmin: float, fmax: float, floor_y: float, label: String) -> void:
	var space := g.get_world_2d().direct_space_state
	var reach := 0
	var bad: Array = []
	var x := fmin
	while x <= fmax:
		var spot := Vector2(x, floor_y)
		var target := spot + Vector2(0.0, -g.tuning.round_height())
		var ahead: float = (target.x - g.global_position.x) * float(g.facing)
		var in_reach := false
		if ahead >= 8.0:
			if g.is_same_floor(spot):
				in_reach = absf(target.x - g.flat_origin().x) <= g.tuning.engage_range()
			else:
				in_reach = g.shot_origin(target).distance_to(target) <= g.tuning.engage_range()
		if in_reach:
			# Something solid at the spot itself (a bench, a step) is not a standing spot.
			var q := PhysicsRayQueryParameters2D.create(spot + Vector2(0.0, -8.0), spot + Vector2(0.0, 24.0))
			q.collision_mask = 1
			var on_floor := not space.intersect_ray(q).is_empty()
			var q2 := PhysicsRayQueryParameters2D.create(spot + Vector2(0.0, -H + 4.0), spot + Vector2(0.0, -12.0))
			q2.collision_mask = 1
			if on_floor and space.intersect_ray(q2).is_empty():
				reach += 1
				var b := _pit_behind(g, spot, signf(spot.x - g.global_position.x))
				if b != "":
					bad.append(b)
		x += 16.0
	check(reach > 0, "%s: %s's gun reaches part of the fight floor (%d spots)" % [label, g.entity_id, reach])
	check(bad.is_empty(), "%s: no standing spot in %s's lane has a pit edge within 1.5 H behind it (%s)" % [label, g.entity_id, str(bad.slice(0, 3))])


# --- helpers -------------------------------------------------------------------------------

func _alive(e) -> bool:
	if not is_instance_valid(e) or e.is_queued_for_deletion():
		return false
	if e is Gunner:
		return e.state != Gunner.State.DEFEATED
	if e is Drone:
		return e.state != Drone.State.DEFEATED
	if e is Brawler:
		return e.state != Brawler.State.DEFEATED
	return true


## The middle of an enemy's hit zone (the drone's hull).
func _center(e: Node2D) -> Vector2:
	if e is Drone:
		return e.global_position
	var hz: Node = e.get("hit_zone")
	if hz != null:
		for c in hz.get_children():
			if c is CollisionShape2D:
				return (c as CollisionShape2D).global_position
	return e.global_position + Vector2(0.0, -H * 0.5)


func _view(lvl: LevelDirector) -> Rect2:
	var cam: Camera2D = lvl.camera
	var size: Vector2 = lvl.get_viewport_rect().size / cam.zoom
	return Rect2(cam.get_screen_center_position() - size * 0.5, size)


## Puts Dave at `pos` with the camera (and its limits) where a playthrough would have it.
func _teleport(lvl: LevelDirector, area: AreaRoot, pos: Vector2) -> void:
	lvl.hero.respawn_at(pos)
	var r: Rect2 = lvl._camera_target_rect_for_area(area)
	lvl._camera_top = r.position.y
	lvl._camera_bottom = r.position.y + r.size.y
	lvl.camera.world_limits = Rect2(0.0, r.position.y, lvl.level_width, r.size.y)
	await physics_frames(2)
	lvl.camera.reset_position()
	await physics_frames(8)
