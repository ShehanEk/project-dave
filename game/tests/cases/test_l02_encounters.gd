extends TestCase
## Level 2 "Alignment" v2 (C62): the encounters, level-wide. Built in the REAL level (LevelDirector
## with LevelDefs "L02": its six areas side by side, 40,800 px), so windows straddle the area seams:
##   - the screen budget at rest (encounter-and-boss-fairness.md, P23): at most 2 shooters (Sidearm
##     Guards, Security Drones) and 3 attackers in any 1,280 px window, each enemy counted where it
##     stands and across a drone's patrol span; counting only enemies that can be live together, as
##     the three per-area tests do: a release prop's group follows the one it waits for (`after`),
##     so a chain counts as its biggest phase; the freight lift's hold-out waves are phases of one
##     chain; a launch rack's drones count as at most its `max_live`;
##   - the enemy count by type, per area and for the level (17 Night Guards, 15 Staffers, 4 Patrol
##     Rovers with the dock's optional one, 10 Sidearm Guards, 5 Hounds, 10 Security Drones);
##   - the new types' introductions in route order: the Sidearm Guard alone (E07), the Hound alone
##     with its handler (E09), the Security Drone alone (E12);
##   - the groups' wiring: every group wakes on Dave's approach (an ApproachZone on the hero layer)
##     or waits for exactly one trigger (a release prop, the launch rack, a hold-out wave), lets at
##     most 2 attack at once, shares tokens only with a group in its own area; every release prop's
##     `after` resolves and it holds only its own group's enemies; every enemy's id is
##     `<encounter>-<type>-nn` and unique.
## The fair fights themselves (Dave with the base Scrapjack against every encounter, its tells, the
## caps on screen, the gun gates and the gun-lane pit sweeps) are test_l02v2_a01_a02.gd,
## test_l02v2_a03_a04.gd and test_l02v2_a05_a06.gd.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const ReleasePod := preload("res://scripts/objects/release_pod.gd")
const LaunchRack := preload("res://scripts/objects/launch_rack.gd")
const WINDOW := 1280.0
const TYPE_BY_SCENE := {
	"res://scenes/actors/night_guard.tscn": "SE01", "res://scenes/actors/staffer.tscn": "LK01",
	"res://scenes/actors/patrol_rover.tscn": "M01", "res://scenes/actors/sidearm_guard.tscn": "SE02",
	"res://scenes/actors/hound.tscn": "K01", "res://scenes/actors/security_drone.tscn": "M02",
}
## Area index -> enemies by type code.
const BY_AREA := [
	{"SE01": 4, "LK01": 3, "M01": 1},
	{"SE01": 4, "LK01": 1, "SE02": 3, "K01": 3},
	{"LK01": 2, "SE02": 1, "M02": 5},
	{"SE01": 2, "LK01": 6, "SE02": 1, "M02": 1},
	{"SE01": 2, "LK01": 2, "SE02": 3, "K01": 1, "M02": 1},
	{"SE01": 5, "LK01": 1, "M01": 3, "SE02": 2, "K01": 1, "M02": 3},
]
const LEVEL_TOTALS := {"SE01": 17, "LK01": 15, "M01": 4, "SE02": 10, "K01": 5, "M02": 10}
const GROUP_COUNT := 38

var _level: LevelDirector


func run() -> void:
	release_all()
	CheckpointService.clear()
	Session.new_run("L02")
	_level = load(LEVEL_SCENE).instantiate()
	_level.level_def = LevelDefs.get_def("L02")
	add_child(_level)
	await physics_frames(3)
	check_eq(_level.areas.size(), 6, "setup: Level 2 builds its six areas")
	_test_counts()
	_test_introductions()
	_test_wiring()
	_test_window_budget()
	# Freed here even if a check above aborted on a script error (this is the case's only level).
	for c in get_children():
		c.queue_free()
	await physics_frames(2)
	CheckpointService.clear()
	Session.new_run()


# --- helpers ---------------------------------------------------------------------------------

func _all(node: Node, pred: Callable, out: Array = []) -> Array:
	if pred.call(node):
		out.append(node)
	for c in node.get_children():
		_all(c, pred, out)
	return out


func _enemies(n: Node) -> Array:
	return _all(n, func(c): return c.is_in_group("enemy"))


func _groups(n: Node) -> Array:
	return _all(n, func(c): return c is EncounterGroup)


func _code(e: Node) -> String:
	return TYPE_BY_SCENE.get(e.scene_file_path, "?")


func _is_shooter(e: Node) -> bool:
	return e is Gunner or e is Drone


func _area_of(n: Node) -> AreaRoot:
	var p := n.get_parent()
	while p != null and not (p is AreaRoot):
		p = p.get_parent()
	return p as AreaRoot


## The encounter id an enemy's entity id is filed under: its group id without a phase suffix
## (-D side door, -P1/-P2 pods or plinths, -C1/-C2 cases, -W1..-W3 hold-out waves).
func _base_group_id(gid: String) -> String:
	return RegEx.create_from_string("-(D|P\\d|C\\d|W\\d)$").sub(gid, "")


## [lo, hi] (global x) of where an enemy can be: its spot, and a drone's patrol span.
func _span(e: Node2D) -> Vector2:
	var lo: float = e.global_position.x
	var hi: float = lo
	if e is Drone:
		var area: Node2D = e._area_root
		lo = minf(lo, area.to_global(Vector2(e._span.x, 0)).x)
		hi = maxf(hi, area.to_global(Vector2(e._span.y, 0)).x)
		for pair in [[e.get("patrol_min_x"), e.get("patrol_max_x")]]:
			if pair[0] != null and pair[1] != null and is_finite(float(pair[0])) and is_finite(float(pair[1])):
				lo = minf(lo, area.to_global(Vector2(float(pair[0]), 0)).x)
				hi = maxf(hi, area.to_global(Vector2(float(pair[1]), 0)).x)
	return Vector2(lo, hi)


# --- 1. counts by type ---------------------------------------------------------------------------

func _test_counts() -> void:
	var totals := {}
	var ids := {}
	var dupes: Array = []
	for i in _level.areas.size():
		var a: AreaRoot = _level.areas[i]
		var got := {}
		for e in _enemies(a.get_node("Encounters")):
			var code := _code(e)
			got[code] = int(got.get(code, 0)) + 1
			totals[code] = int(totals.get(code, 0)) + 1
			if ids.has(e.entity_id):
				dupes.append(e.entity_id)
			ids[e.entity_id] = true
		check_eq(got, BY_AREA[i], "%s fields %s" % [a.area_id, str(BY_AREA[i])])
		check(_enemies(a.get_node("Entities")).is_empty(), "%s: every enemy stands in an encounter group" % a.area_id)
	check_eq(totals, LEVEL_TOTALS, "Level 2 fields 17 Night Guards, 15 Staffers, 4 rovers, 10 Sidearm Guards, 5 Hounds, 10 drones")
	check_eq(ids.size(), 61, "61 enemies in all (60 on the route and the dock's optional rover)")
	check(dupes.is_empty(), "no enemy id is used twice (%s)" % str(dupes))
	check_eq(get_tree().get_nodes_in_group("enemy").size(), 61, "...and no enemy outside the level's areas")


# --- 2. the new types' introductions ----------------------------------------------------------

func _test_introductions() -> void:
	# The first group (in route order) that fields each new type.
	var first := {}
	var groups: Array = []
	for a in _level.areas:
		groups.append_array(_groups(a.get_node("Encounters")))
	groups.sort_custom(func(p, q):
		var pe := _enemies(p)
		var qe := _enemies(q)
		var px: float = pe[0].global_position.x if not pe.is_empty() else INF
		var qx: float = qe[0].global_position.x if not qe.is_empty() else INF
		return px < qx)
	for g in groups:
		for e in _enemies(g):
			var code := _code(e)
			if not first.has(code):
				first[code] = g
	check(first.has("SE02") and first["SE02"].group_id == "L02-E07", "the Sidearm Guard is introduced at E07")
	if first.has("SE02"):
		check_eq(_enemies(first["SE02"]).size(), 1, "...alone")
	check(first.has("K01") and first["K01"].group_id == "L02-E09", "the Hound is introduced at E09")
	if first.has("K01"):
		var codes: Array = _enemies(first["K01"]).map(func(e): return _code(e))
		codes.sort()
		check_eq(codes, ["K01", "SE01"], "...alone with its Night Guard handler")
		for e in _enemies(first["K01"]):
			if e is Hound:
				check(e.has_handler(), "...on his lead")
	check(first.has("M02") and first["M02"].group_id == "L02-E12", "the Security Drone is introduced at E12")
	if first.has("M02"):
		check_eq(_enemies(first["M02"]).size(), 1, "...alone")
	# The level's other types are Level 1's: they come before any new one.
	for code in ["SE01", "LK01", "M01"]:
		check(first.has(code) and _level.areas[0].is_ancestor_of(first[code]), "Level 1's %s returns in A01" % code)


# --- 3. the groups' wiring -----------------------------------------------------------------------

func _test_wiring() -> void:
	var groups: Array = []
	for a in _level.areas:
		groups.append_array(_groups(a.get_node("Encounters")))
	check_eq(groups.size(), GROUP_COUNT, "Level 2 has %d encounter groups" % GROUP_COUNT)
	# Who opens each waiting group.
	var owners := {}   # group -> [owner names]
	var props := _all(_level, func(n): return n.get_script() == ReleasePod)
	var racks := _all(_level, func(n): return n.get_script() == LaunchRack)
	var wickets := _all(_level, func(n): return n is ExitWicket)
	for p in props:
		var g: Node = p.get_node_or_null(p.group)
		check(g is EncounterGroup, "%s holds an encounter group" % p.name)
		if g is EncounterGroup:
			var o: Array = owners.get(g, [])
			o.append(String(p.name))
			owners[g] = o
			var held: Array = p.held_enemies()
			var in_group: Array = ReleasePod.group_enemies(g)
			check(held.size() == in_group.size() and held.all(func(e): return e in in_group) and not held.is_empty(),
					"%s holds exactly its group %s's enemies" % [p.name, g.group_id])
			check(_area_of(p) == _area_of(g), "%s and its group are in the same area" % p.name)
		if not p.after.is_empty():
			var after: Node = p.get_node_or_null(p.after)
			check(after != null and (after is EncounterGroup or after.get_script() == ReleasePod) and _area_of(after) == _area_of(p),
					"%s waits for a group or prop of its own area (%s)" % [p.name, str(p.after)])
	for r in racks:
		var g: Node = r.get_node_or_null(r.group)
		check(g is EncounterGroup and g.wait_for_trigger, "%s launches a waiting group" % r.name)
		if g is EncounterGroup:
			var o: Array = owners.get(g, [])
			o.append(String(r.name))
			owners[g] = o
			check_eq(r.drones.size(), _enemies(g).size(), "%s docks every drone of %s" % [r.name, g.group_id])
			for d in r.drones:
				var drone: Node = r.get_node_or_null(d)
				check(drone is Drone and drone.get_parent() == g, "%s's drone %s is in its group" % [r.name, str(d)])
			check(r.max_live <= 2, "%s keeps at most 2 drones up (%d)" % [r.name, r.max_live])
	check_eq(wickets.size(), 1, "one exit wicket: the freight lift")
	for w in wickets:
		var lists: Array = [w.wave_groups, w.override_groups, w.reinforcement_groups]
		for paths in lists:
			for p in paths:
				var n: Node = w.get_node_or_null(p)
				check(n != null, "%s's %s resolves" % [w.name, str(p)])
				if n != null and n is EncounterGroup:
					var o: Array = owners.get(n, [])
					o.append(String(w.name))
					owners[n] = o
		for p in w.wave_groups:
			var n: Node = w.get_node_or_null(p)
			if n != null and n.get_script() == ReleasePod:
				check(not is_finite(n.trigger_x) and n.trigger_area.is_empty() and n.after.is_empty(),
						"hold-out door %s opens only when the lift releases its wave" % n.name)
	for g in groups:
		var zone := g.get_node_or_null("ApproachZone") as Area2D
		var o: Array = owners.get(g, [])
		if g.wait_for_trigger:
			check(zone == null, "%s waits for its trigger, no ApproachZone" % g.group_id)
			check_eq(o.size(), 1, "%s is opened by exactly one trigger %s" % [g.group_id, str(o)])
		else:
			check(zone != null and zone.collision_mask == 2, "%s wakes on Dave's approach (ApproachZone on the hero layer)" % g.group_id)
			check(o.is_empty(), "%s is not also held by a trigger %s" % [g.group_id, str(o)])
		check(g.max_attackers <= 2, "%s lets at most 2 attack at once (%d)" % [g.group_id, g.max_attackers])
		if not g.share_tokens_with.is_empty():
			var other: Node = g.get_node_or_null(g.share_tokens_with)
			check(other is EncounterGroup and other != g and _area_of(other) == _area_of(g),
					"%s shares its tokens with a group of its own area (%s)" % [g.group_id, str(g.share_tokens_with)])
		var re := RegEx.create_from_string("^(.+)-(SE01|LK01|M01|SE02|K01|M02)-(\\d\\d)$")
		for e in _enemies(g):
			var m := re.search(e.entity_id)
			check(m != null and m.get_string(1) == _base_group_id(g.group_id) and m.get_string(2) == _code(e),
					"%s's id %s is <encounter>-<type>-nn" % [g.group_id, e.entity_id])
			check(e.get_parent() == g, "%s stands directly in its group %s" % [e.entity_id, g.group_id])


# --- 4. the P23 window budget, level-wide ------------------------------------------------------

func _test_window_budget() -> void:
	# Phases: group -> [chain key, step]. A release prop's group follows its `after`; the
	# hold-out's waves follow each other; everything else is its own chain.
	var phase := {}
	var groups: Array = []
	for a in _level.areas:
		groups.append_array(_groups(a.get_node("Encounters")))
	for g in groups:
		phase[g] = [g, 0]
	var props := _all(_level, func(n): return n.get_script() == ReleasePod)
	for _pass in 6:
		for p in props:
			var g = p.get_node_or_null(p.group)
			var after = p.get_node_or_null(p.after) if not p.after.is_empty() else null
			if after != null and after.get_script() == ReleasePod:
				after = after.get_node_or_null(after.group)
			if g != null and after != null and phase.has(after):
				phase[g] = [phase[after][0], int(phase[after][1]) + 1]
	for w in _all(_level, func(n): return n is ExitWicket):
		for i in w.wave_groups.size():
			var d = w.get_node_or_null(w.wave_groups[i])
			var g = d.get_node_or_null(d.group) if d and d.get_script() == ReleasePod else d
			if g:
				phase[g] = [w, i]
	# A launch rack's group: at most max_live of its drones are up at once.
	var cap := {}
	for r in _all(_level, func(n): return n.get_script() == LaunchRack):
		var g = r.get_node_or_null(r.group)
		if g:
			cap[g] = int(r.max_live)
	var spans: Array = []   # [lo, hi, shooter, chain, step, group, id]
	for g in groups:
		for e in _enemies(g):
			var sp := _span(e)
			spans.append([sp.x, sp.y, _is_shooter(e), phase[g][0], phase[g][1], g, e.entity_id])
	check_eq(spans.size(), 61, "setup: every enemy of the level is counted")
	var worst_s := 0
	var worst_a := 0
	var at_s := ""
	var at_a := ""
	var x := -WINDOW
	while x <= _level.level_width:
		var by_chain := {}   # chain -> {step: [attackers, shooters, ids]}
		var per_group := {}  # rack group -> [attackers, shooters] (capped below)
		for sp in spans:
			if sp[1] >= x and sp[0] <= x + WINDOW:
				var steps: Dictionary = by_chain.get(sp[3], {})
				var c: Array = steps.get(sp[4], [0, 0, []])
				if cap.has(sp[5]):
					var n: int = int(per_group.get(sp[5], 0))
					per_group[sp[5]] = n + 1
					if n >= int(cap[sp[5]]):
						continue
				c[0] += 1
				if sp[2]:
					c[1] += 1
				(c[2] as Array).append(sp[6])
				steps[sp[4]] = c
				by_chain[sp[3]] = steps
		var att := 0
		var sho := 0
		var ids: Array = []
		for ch in by_chain:
			var ma := 0
			var ms := 0
			var mids: Array = []
			for st in by_chain[ch]:
				if by_chain[ch][st][0] > ma:
					mids = by_chain[ch][st][2]
				ma = maxi(ma, by_chain[ch][st][0])
				ms = maxi(ms, by_chain[ch][st][1])
			att += ma
			sho += ms
			ids.append_array(mids)
		if att > worst_a:
			worst_a = att
			at_a = "x %.0f: %s" % [x, str(ids)]
		if sho > worst_s:
			worst_s = sho
			at_s = "x %.0f: %s" % [x, str(ids)]
		x += 16.0
	check(worst_s <= 2, "P23: at most 2 shooters in any 1,280 px window of Level 2 (max %d, %s)" % [worst_s, at_s])
	check(worst_a <= 3, "P23: at most 3 attackers in any 1,280 px window of Level 2 (max %d, %s)" % [worst_a, at_a])
	print("[test_l02_encounters] window budget at rest: max %d shooters (%s), %d attackers (%s) per 1,280 px" % [worst_s, at_s, worst_a, at_a])
