extends TestCase
## Level 2 v2 (C62): A01 Sky bridge and coolant plant and A02 Firing range and K9 kennel, rebuilt to
## ../prototype-plans/level-02-alignment/area-blueprints-v2.md. Built inside the real level
## (LevelDirector with LevelDefs "L02"):
##   - the seams (y 0, 4 H of flat floor at each end), widths, camera bounds, the outdoor bridge;
##   - every enemy, chip, cartridge, cache and checkpoint standing on solid floor, no enemy within
##     500 px of a checkpoint, the P23 budget (at most 2 shooters and 3 attackers in any 1,280 px
##     window, counting only enemies that can be live together: a release prop's enemies replace
##     the ones it waits for), every catwalk deck supported (Block.lab_structure()), no floating
##     slab, no patrol lane over a stair flight;
##   - every encounter with its ids and types, the set pieces wired (the H1 vents, the drill and its
##     tray, the range going live, the side and maintenance doors, the kennel pods' groups and
##     chain, the secret armory), the breakables, chips and cartridges and their ids, the beats;
## then the RouteBot crossing each area alone (tests/area_harness.gd, invulnerable), and a FAIR
## FIGHT for every encounter: Dave with the base Scrapjack, played like test_l02_encounters.gd (a
## scripted player who walks the area's own route points, answers each tell and shoots in the
## punish windows), wins with at most half his health lost, inside the screen caps and gates.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const A01_SCENE := "res://scenes/levels/l02/a01_sky_bridge.tscn"
const A02_SCENE := "res://scenes/levels/l02/a02_range_kennel.tscn"
const BlockScript := preload("res://scripts/world/block.gd")
const StairsScript := preload("res://scripts/world/stairs.gd")
const Arch := preload("res://scripts/world/lab_structure.gd")
const Breakable := preload("res://scripts/objects/breakable.gd")
const ReleasePod := preload("res://scripts/objects/release_pod.gd")
const H := 96.0
const SAFE_RADIUS := 500.0
const WINDOW := 1280.0

## group_id -> [area, {entity_id: type}]
const ENCOUNTERS := {
	"L02-E01": [0, {"L02-E01-SE01-01": "guard", "L02-E01-SE01-02": "guard"}],
	"L02-E02": [0, {"L02-E02-LK01-01": "staffer", "L02-E02-LK01-02": "staffer"}],
	"L02-E03": [0, {"L02-E03-M01-01": "rover"}],
	"L02-E04": [0, {"L02-E04-SE01-01": "guard"}],
	"L02-E05": [0, {"L02-E05-SE01-01": "guard", "L02-E05-LK01-01": "staffer"}],
	"L02-E06": [1, {"L02-E06-LK01-01": "staffer", "L02-E06-SE01-01": "guard"}],
	"L02-E07": [1, {"L02-E07-SE02-01": "gunner"}],
	"L02-E08": [1, {"L02-E08-SE02-01": "gunner", "L02-E08-SE02-02": "gunner"}],
	"L02-E08-D": [1, {"L02-E08-SE01-01": "guard"}],
	"L02-E09": [1, {"L02-E09-SE01-01": "guard", "L02-E09-K01-01": "hound"}],
	"L02-E10": [1, {"L02-E10-SE01-01": "guard"}],
	"L02-E10-P1": [1, {"L02-E10-K01-01": "hound"}],
	"L02-E10-P2": [1, {"L02-E10-K01-02": "hound"}],
}
const BEATS := [["L02-A01-B01", "L02-A01-B02", "L02-A01-B03"], ["L02-A02-B01", "L02-A02-B02", "L02-A02-B03"]]

## The fair fights: each a fresh level build in which every other enemy of A01-A02 is recorded
## defeated (so only this encounter is live), Dave starting at the first route point (before the
## groups' ApproachZones) and walking the rest; `limits` (area, x0, x1) bound where he fights;
## `lure` (area-local x) is where he waits for a Patrol Rover's charge.
const FIGHTS := [
	{"label": "E01 two Night Guards in the airlock (A01)", "groups": ["L02-E01"],
		"route": [[0, "R01_CrossBridge"], [0, "R02_Airlock"]], "limits": [0, 1150.0, 1600.0]},
	{"label": "E02 two Staffers, catwalk and walkway, with the steam vents (A01)", "groups": ["L02-E02"],
		"route": [[0, "R02_Airlock"], [0, "R03_StairsPump"], [0, "R04_OnPlinth"], [0, "R05_JumpCatwalk"],
				[0, "R06_OnCatwalk"], [0, "R07_CatwalkEnd"], [0, "R08_PastSteam"]], "limits": [0, 1620.0, 2880.0]},
	{"label": "E03 the Patrol Rover, then E04 the guard from the maintenance door (A01)", "groups": ["L02-E03", "L02-E04"],
		"route": [[0, "R11_DrillYard"], [0, "R12_GalleryEntry"], [0, "R13_JumpValveBlock"], [0, "R14_PastValveBlock"]],
		"limits": [0, 4230.0, 5380.0], "lure": 4520.0},
	{"label": "E05 a Staffer on the landing and a Night Guard under it (A01)", "groups": ["L02-E05"],
		"route": [[0, "R14_PastValveBlock"], [0, "R15_StairFoot"], [0, "R16_StairTop"], [0, "R17_Landing"], [0, "R18_ToExit"]],
		"limits": [0, 5420.0, 6500.0]},
	{"label": "E06 the clerk and a Night Guard in the range lobby (A02)", "groups": ["L02-E06"],
		"route": [[0, "R18_ToExit"], [1, "R01_Lobby"], [1, "R02_JumpDesk"], [1, "R03_PastDesk"]], "limits": [1, -100.0, 1100.0]},
	{"label": "E07 the Sidearm Guard alone on lane 1 (A02)", "groups": ["L02-E07"],
		"route": [[1, "R03_PastDesk"], [1, "R04_LaneBench"], [1, "R05_JumpBench"], [1, "R06_PastBench"], [1, "R07_StairsBooth"]],
		"limits": [1, 1120.0, 3300.0]},
	{"label": "E08 two Sidearm Guards and the side-door guard, the range live (A02)", "groups": ["L02-E08", "L02-E08-D"],
		"route": [[1, "R10_OffBooth"], [1, "R11_LiveLanes"]], "limits": [1, 4020.0, 5600.0]},
	{"label": "E09 the Hound and its handler, then E10 the pods and the walkway handler (A02)",
		"groups": ["L02-E09", "L02-E10", "L02-E10-P1", "L02-E10-P2"],
		"route": [[1, "R11_LiveLanes"], [1, "R12_KennelWall"], [1, "R13_JumpKennelWall"], [1, "R14_Yard"], [1, "R15_StepFoot"],
				[1, "R16_JumpStep"], [1, "R17_OnStep"], [1, "R18_JumpWalkway"], [1, "R19_OnWalkway"]],
		"limits": [1, 5620.0, 7560.0]},
]
const Vent := preload("res://scripts/objects/hazard_vent.gd")
const BUDGET_S := 60.0
const SHOOT_RANGE := 600.0
const JUMP_HOLD_TICKS := 27
const ROUND_REACT_S := 0.2
const HALF_W := 20.0
const IDLE_FIRE_S := 4.0
const GUARD_TOO_CLOSE := 140.0
## An enemy on Dave's floor this close (px) with a clear line, or a gunner who can see him this
## close, holds him in the fight instead of walking on.
const ENGAGE_X := 650.0

var _level: LevelDirector
var _reports: Array = []


func run() -> void:
	release_all()
	CheckpointService.clear()
	Session.new_run("L02")
	_level = load(LEVEL_SCENE).instantiate()
	_level.level_def = LevelDefs.get_def("L02")
	add_child(_level)
	await physics_frames(3)
	var a01: AreaRoot = _level.areas[0]
	var a02: AreaRoot = _level.areas[1]
	_test_areas(a01, a02)
	_test_standing_and_checkpoints([a01, a02])
	_test_window_budget([a01, a02])
	_test_structure([a01, a02])
	_test_encounters([a01, a02])
	_test_set_pieces(a01, a02)
	_test_pickups_and_breakables(a01, a02)
	_level.queue_free()
	await physics_frames(2)
	if OS.get_environment("L02V2_SKIPBOT") == "":
		await _test_route_bot(A01_SCENE, "A01")
		await _test_route_bot(A02_SCENE, "A02")
	var only := OS.get_environment("L02V2_FIGHT")
	for i in FIGHTS.size():
		if only != "" and int(only) != i:
			continue
		await _fight(FIGHTS[i])
	print("[test_l02v2_a01_a02] ==== FIGHTS ====")
	for r in _reports:
		print("[test_l02v2_a01_a02]   %s" % r)
	CheckpointService.clear()
	Session.new_run()


# --- helpers --------------------------------------------------------------------------------

func _all(node: Node, pred: Callable, out: Array = []) -> Array:
	if pred.call(node):
		out.append(node)
	for c in node.get_children():
		_all(c, pred, out)
	return out


func _ray(from: Vector2, to: Vector2) -> Dictionary:
	var q := PhysicsRayQueryParameters2D.create(from, to)
	q.collision_mask = 1
	return _level.get_world_2d().direct_space_state.intersect_ray(q)


## Solid floor under global point `p` within `depth` px (a stair's slope, a deck, a block).
func _floor_under(p: Vector2, depth: float = 30.0) -> bool:
	return not _ray(p + Vector2(0.0, -6.0), p + Vector2(0.0, depth)).is_empty()


func _local(area: AreaRoot, n: Node2D) -> Vector2:
	return area.to_local(n.global_position)


func _enemies(area: AreaRoot) -> Array:
	return _all(area.get_node("Encounters"), func(n): return n.is_in_group("enemy"))


func _type_of(e: Node) -> String:
	if e is Gunner:
		return "gunner"
	if e is Drone:
		return "drone"
	if e is PatrolRover:
		return "rover"
	if e is Hound:
		return "hound"
	if e is Brawler:
		return "staffer" if String(e.scene_file_path).ends_with("staffer.tscn") else "guard"
	return "?"


# --- 1. the areas ------------------------------------------------------------------------------

func _test_areas(a01: AreaRoot, a02: AreaRoot) -> void:
	check_eq(a01.area_id, "L02-A01", "area 0 is L02-A01")
	check_eq(a02.area_id, "L02-A02", "area 1 is L02-A02")
	check_eq(a01.width, 6200.0, "A01 is 6,200 px wide (v2)")
	check_eq(a02.width, 7800.0, "A02 is 7,800 px wide (v2)")
	check(absf(a02.global_position.x - (a01.global_position.x + a01.width)) < 0.5, "A02 starts where A01 ends")
	for a in [a01, a02]:
		check(absf(a.global_position.y) < 0.5, "%s sits at y 0" % a.area_id)
		var bad: Array = []
		for lx in range(0, 385, 32) + range(int(a.width) - 384, int(a.width) + 1, 32):
			var x := clampf(float(lx), 2.0, a.width - 2.0)
			if not a.has_floor_at(x):
				bad.append(int(x))
			# Flat at y 0: nothing solid in the 1 H above the floor line at the seams.
			if not _ray(a.to_global(Vector2(x, -H)), a.to_global(Vector2(x, -10.0))).is_empty():
				bad.append("obstacle at %d" % int(x))
		check(bad.is_empty(), "%s: 4 H of flat floor at y 0 at both seams (%s)" % [a.area_id, str(bad)])
		check(a.indoors and a.interior_look == "lab", "%s is indoors and wears the lab" % a.area_id)
	check_eq(a01.wet_until_x, 1100.0, "A01's bridge is outdoors to x 1,100")
	check_eq([a01.camera_top, a01.camera_bottom], [-560.0, 120.0], "A01 camera bounds -560..120")
	check_eq([a02.camera_top, a02.camera_bottom], [-500.0, 120.0], "A02 camera bounds -500..120")
	var door: Node2D = a01.get_node_or_null("Entities/BridgeDoor")
	check(door != null and absf(_local(a01, door).x - 1120.0) < 0.5, "A01 Entities/BridgeDoor at x 1,120")
	var pad: Node = a01.get_node_or_null("Entities/WeaponPad")
	check(pad != null and pad.pad_id == "L02-A01-PAD01", "A01 Entities/WeaponPad is L02-A01-PAD01")
	check(a01.get_marker("Spawn_CP00") != null and a01.get_marker("Respawn_CP00B") != null, "A01 has Spawn_CP00 and Respawn_CP00B")
	check(a02.get_marker("Respawn_CP01") != null, "A02 has Respawn_CP01")
	for i in 2:
		var a: AreaRoot = [a01, a02][i]
		check_eq(Array(a.get_beat_ids()), BEATS[i], "%s beat zones" % a.area_id)
	var rl: Node = a02.get_node_or_null("Entities/RangeLive")
	check(rl != null and rl.beat_id == "L02-A02-B04", "the range line's beat L02-A02-B04 comes from RangeLive")
	check(LevelDefs.get_def("L02").beat_lines.has("L02-A02-B04"), "L02-A02-B04 has Adam's range line")


# --- 2. standing, checkpoints -----------------------------------------------------------------

func _test_standing_and_checkpoints(areas: Array) -> void:
	var def := LevelDefs.get_def("L02")
	var cps: Array = []   # [label, global position]
	for id in def.checkpoint_markers:
		var spec: Array = def.checkpoint_markers[id]
		if int(spec[0]) > 1:
			continue
		var m: Marker2D = (areas[int(spec[0])] as AreaRoot).get_marker(String(spec[1]))
		check(m != null, "checkpoint %s's marker %s exists" % [id, spec[1]])
		if m != null:
			cps.append([id, m.global_position])
			check(_floor_under(m.global_position), "checkpoint %s's marker stands on solid floor" % id)
	for a in areas:
		for st in _all(a, func(n): return n is RecoveryStation):
			cps.append([st.checkpoint_id + " station", st.global_position])
			check(_floor_under(st.global_position), "%s's station stands on solid floor" % st.checkpoint_id)
			var m: Marker2D = null
			for id in def.checkpoint_markers:
				if id == st.checkpoint_id:
					m = (areas[int(def.checkpoint_markers[id][0])] as AreaRoot).get_marker(String(def.checkpoint_markers[id][1]))
			check(m != null and m.global_position.distance_to(st.global_position) < 24.0,
					"station %s stands at its respawn marker" % st.checkpoint_id)
	var cp_ids := []
	for st in _all(areas[0], func(n): return n is RecoveryStation):
		cp_ids.append(st.checkpoint_id)
	check_eq(cp_ids, ["CP00B"], "A01's recovery station is CP00B")
	cp_ids = []
	for st in _all(areas[1], func(n): return n is RecoveryStation):
		cp_ids.append(st.checkpoint_id)
	check_eq(cp_ids, ["CP01"], "A02's recovery station is CP01")
	var close: Array = []
	var floating: Array = []
	for a in areas:
		for e in _enemies(a):
			if not (e is Drone) and not _floor_under(e.global_position, 24.0):
				floating.append(e.entity_id)
			for cp in cps:
				if absf(e.global_position.x - (cp[1] as Vector2).x) < SAFE_RADIUS:
					close.append("%s near %s" % [e.entity_id, cp[0]])
	check(floating.is_empty(), "every enemy stands on solid floor (%s)" % str(floating))
	check(close.is_empty(), "no enemy within %d px of a checkpoint (%s)" % [int(SAFE_RADIUS), str(close)])
	var loose: Array = []
	for a in areas:
		for n in _all(a.get_node("Entities"), func(n): return n is Chip or n is ChipCache or n.has_method("get") and String(n.scene_file_path).ends_with("ammo_cartridge.tscn")):
			if not _floor_under(n.global_position, 40.0):
				loose.append("%s at %s" % [n.get("entity_id"), str(_local(a, n).round())])
	check(loose.is_empty(), "every chip, cache and cartridge rests over solid floor (%s)" % str(loose))


# --- 3. the P23 window budget --------------------------------------------------------------

## The sets of enemies that can be live together: those no release prop holds, and for each
## release prop its own enemies plus everyone else except the ones it waits for (its `after`
## chain), since those are down before it opens.
func _live_sets(areas: Array) -> Array:
	var held := {}       # enemy -> pod
	var pods: Array = []
	for a in areas:
		for p in _all(a, func(n): return n.has_method("held_enemies")):
			pods.append(p)
			for e in p.held_enemies():
				held[e] = p
	var all: Array = []
	for a in areas:
		all.append_array(_enemies(a))
	var base := all.filter(func(e): return not held.has(e))
	var sets: Array = [base]
	for p in pods:
		var gone := {}
		var n: Node = p.get_node_or_null(p.after) if not p.after.is_empty() else null
		while n != null:
			if n.has_method("held_enemies"):
				for e in n.held_enemies():
					gone[e] = true
				n = n.get_node_or_null(n.after) if not n.after.is_empty() else null
			else:
				for e in ReleasePod.group_enemies(n):
					gone[e] = true
				n = null
		var s := base.filter(func(e): return not gone.has(e))
		s.append_array(p.held_enemies())
		sets.append(s)
	return sets


func _test_window_budget(areas: Array) -> void:
	var worst_s := 0
	var worst_a := 0
	var where := ""
	var x0: float = (areas[0] as AreaRoot).global_position.x
	var x1: float = (areas[1] as AreaRoot).global_position.x + (areas[1] as AreaRoot).width
	for s in _live_sets(areas):
		var x := x0 - WINDOW
		while x <= x1:
			var shooters := 0
			var attackers := 0
			var ids: Array = []
			for e in s:
				var lo: float = e.global_position.x
				var hi: float = e.global_position.x
				if e is Drone:
					lo = e._area_root.to_global(Vector2(e._span.x, 0)).x
					hi = e._area_root.to_global(Vector2(e._span.y, 0)).x
				if hi >= x and lo <= x + WINDOW:
					attackers += 1
					ids.append(e.entity_id)
					if e is Gunner or e is Drone:
						shooters += 1
			if attackers > worst_a:
				where = "%s from x %.0f" % [str(ids), x]
			worst_s = maxi(worst_s, shooters)
			worst_a = maxi(worst_a, attackers)
			x += 32.0
	check(worst_s <= 2, "at most 2 shooters in any 1,280 px window of A01-A02 (max %d)" % worst_s)
	check(worst_a <= 3, "at most 3 attackers in any 1,280 px window of A01-A02 (max %d: %s)" % [worst_a, where])
	print("[test_l02v2_a01_a02] window budget: max %d shooters, %d attackers (%s)" % [worst_s, worst_a, where])


# --- 4. structure: supported decks, no floating slabs, patrols off the flights --------------

func _test_structure(areas: Array) -> void:
	for a in areas:
		var blocks := _all(a.get_node("Geometry"), func(n): return n.get_script() == BlockScript)
		var flights := _all(a.get_node("Geometry"), func(n): return n.get_script() == StairsScript)
		var decks := 0
		var unsupported: Array = []
		var floating: Array = []
		for b in blocks:
			var role: String = b.lab_structure()
			var lr := Rect2(_local(a, b), b.size)
			if role == "deck":
				decks += 1
				var sup: Dictionary = Arch.deck_supports(b)
				if int(sup["mode"]) == Arch.S_NONE or (sup["xs"] as Array).size() < 2:
					unsupported.append(String(b.name))
			elif b.kind == BlockScript.Kind.PLATFORM or (b.kind == BlockScript.Kind.GROUND and lr.end.y < -0.5):
				# A raised box must stand on something: its bottom on a floor top.
				if not _floor_under(b.global_position + Vector2(b.size.x * 0.5, b.size.y), 8.0):
					floating.append(String(b.name))
			if b.kind in [BlockScript.Kind.BACKSTOP, BlockScript.Kind.SCENERY_SOLID] and lr.end.y < -0.5:
				floating.append(String(b.name))
		check(decks >= (4 if a.area_id == "L02-A01" else 2), "%s has its catwalk decks (%d)" % [a.area_id, decks])
		check(unsupported.is_empty(), "%s: every deck is supported (hangers or columns) (%s)" % [a.area_id, str(unsupported)])
		check(floating.is_empty(), "%s: no floating slab (%s)" % [a.area_id, str(floating)])
		# Every flight's high end meets a landing at its height.
		for st in flights:
			var top := Vector2(st.high_end_x() + float(st.direction) * 12.0, st.top_y())
			check(_floor_under(top + Vector2(0.0, -2.0), 12.0), "%s: %s's high end meets a landing" % [a.area_id, st.name])
		# Every room under a ceiling: a ROOF over each 200 px of the roofed part.
		var open: Array = []
		var x: float = a.wet_until_x + 60.0
		while x < a.width - 20.0:
			var hit := _ray(a.to_global(Vector2(x, -H - 10.0)), a.to_global(Vector2(x, -700.0)))
			if hit.is_empty():
				open.append(int(x))
			x += 200.0
		check(open.is_empty(), "%s: every room has a ceiling over it (open at %s)" % [a.area_id, str(open)])
		# Patrols and lanes off the stair flights.
		var on_flight: Array = []
		for g in _all(a.get_node("Encounters"), func(n): return n is EncounterGroup):
			var lane: Rect2 = g.lane_rect
			for st in flights:
				var fx0: float = _local(a, st).x
				var fx1: float = fx0 + st.run
				if lane.position.x < fx1 - 1.0 and lane.end.x > fx0 + 1.0 and lane.size.x < 50000.0:
					on_flight.append("%s over %s" % [g.group_id, st.name])
			for e in _all(g, func(n): return n.is_in_group("enemy")):
				var pmin: float = e.get("patrol_min_x")
				var pmax: float = e.get("patrol_max_x")
				for st in flights:
					var fx0: float = _local(a, st).x
					if is_finite(pmin) and is_finite(pmax) and pmin < fx0 + st.run and pmax > fx0:
						on_flight.append("%s patrols over %s" % [e.entity_id, st.name])
		check(on_flight.is_empty(), "%s: no lane or patrol over a stair flight (%s)" % [a.area_id, str(on_flight)])


# --- 5. encounters -------------------------------------------------------------------------

func _test_encounters(areas: Array) -> void:
	var found := {}
	for i in areas.size():
		var a: AreaRoot = areas[i]
		var groups: Dictionary = a.get_encounter_groups()
		for gid in groups:
			found[gid] = [i, groups[gid]]
	check_eq(found.keys().size(), ENCOUNTERS.size(), "A01-A02 have the v2 encounter groups (%s)" % str(found.keys()))
	var n_enemies := 0
	for gid in ENCOUNTERS:
		var want: Array = ENCOUNTERS[gid]
		check(found.has(gid), "encounter %s exists" % gid)
		if not found.has(gid):
			continue
		check_eq(found[gid][0], want[0], "%s is in area %d" % [gid, want[0]])
		var ids: Array = Array(found[gid][1])
		ids.sort()
		var want_ids: Array = (want[1] as Dictionary).keys()
		want_ids.sort()
		check_eq(ids, want_ids, "%s fields %s" % [gid, str(want_ids)])
		n_enemies += want_ids.size()
	check_eq(n_enemies, 19, "A01 and A02 field 19 enemies (8 + 11)")
	for a in areas:
		for e in _enemies(a):
			var want_t := ""
			for gid in ENCOUNTERS:
				want_t = (ENCOUNTERS[gid][1] as Dictionary).get(e.entity_id, want_t)
			check_eq(_type_of(e), want_t, "%s is a %s" % [e.entity_id, want_t])
			var g: EncounterGroup = e.get("_group")
			check(g != null and (g.get_node_or_null("ApproachZone") != null or g.wait_for_trigger),
					"%s's group wakes on an ApproachZone or a release prop" % e.entity_id)
			check(g != null and g.attacker_cap() <= 2, "%s's group lets at most 2 attack at once" % e.entity_id)
	# The introductions: the Sidearm Guard alone at E07, the Hound alone with its handler at E09.
	var e07: Array = found.get("L02-E07", [0, []])[1]
	check_eq(Array(e07), ["L02-E07-SE02-01"], "E07 is the Sidearm Guard alone")
	var hound: Hound = areas[1].get_node("Encounters/EncounterGroup_E09/Hound")
	check(hound.has_handler() and hound._handler.entity_id == "L02-E09-SE01-01", "E09's Hound is on its handler's lead")
	# The first gun: no other shooter anywhere within a 1,280 px window of E07's guard.
	var g07: Node2D = areas[1].get_node("Encounters/EncounterGroup_E07/SidearmGuard")
	var others: Array = []
	for a in areas:
		for e in _enemies(a):
			if e != g07 and absf(e.global_position.x - g07.global_position.x) < WINDOW:
				others.append(e.entity_id)
	check(others.is_empty(), "E07's Sidearm Guard is alone within a screen and more (%s)" % str(others))


# --- 6. set pieces ---------------------------------------------------------------------------

func _test_set_pieces(a01: AreaRoot, a02: AreaRoot) -> void:
	# H1: three steam vents with the level's 0.9 s steam, out of step, never under a landing.
	var vents := _all(a01.get_node("Entities"), func(n): return n.is_in_group("hazard_vent") or String(n.scene_file_path).ends_with("hazard_vent.tscn"))
	check_eq(vents.size(), 3, "A01 has the three H1 steam vents")
	var phases: Array = []
	for v in vents:
		check(v.kind == 0 and absf(v.get_active_time() - 0.9) < 0.001, "%s vents steam for 0.9 s" % v.name)
		phases.append(v.phase)
		var lx: float = _local(a01, v).x
		check(lx > 1950.0 and lx < 2700.0, "%s is in the pump hall's floor path (x %.0f)" % [v.name, lx])
	check_eq(phases, [0.0, 0.7, 1.4], "the vents run 0, 0.7 and 1.4 s out of step")
	for v in vents:
		var vx: float = v.global_position.x
		for edge_name in ["PumpPlinth", "PumpCatwalk"]:
			var b: Node2D = a01.get_node("Geometry/" + edge_name)
			var land_x: float = b.global_position.x + b.size.x
			check(absf(vx - land_x) > 36.0 + 60.0, "%s is not under the landing off %s" % [v.name, edge_name])
		var cp: Node2D = a01.get_node("Entities/RecoveryStation_CP00B")
		check(absf(vx - cp.global_position.x) > 200.0, "%s is clear of the CP00B station" % v.name)
	# S1: the drill.
	var pad: Node = a01.get_node_or_null("Entities/DrillPad")
	check(pad != null, "A01 has the drill pad")
	if pad:
		check_eq(pad.entity_id, "L02-A01-DRILL01", "the drill is L02-A01-DRILL01")
		check_eq(pad.duration, 15.0, "a 15 s drill")
		check_eq(pad.targets.size(), 8, "eight pop-up dummies")
		var mounts := {0: 0, 1: 0}
		for p in pad.targets:
			var t: Node = pad.get_node_or_null(p)
			check(t != null and t.is_in_group("popup_target"), "drill target %s is a pop-up dummy" % str(p))
			if t:
				mounts[int(t.mount)] += 1
		check(mounts[0] >= 4 and mounts[1] >= 2, "dummies rise from hatches and drop from rails (%s)" % str(mounts))
		var tray: Node = pad.get_node_or_null(pad.reward)
		check(tray is ChipCache and tray.entity_id == "L02-A01-CACHE01" and tray.value == 10, "the drill's reward is the 10-chip tray L02-A01-CACHE01")
	# E04's maintenance door waits for the rover.
	var mdoor: Node = a01.get_node_or_null("Entities/MaintenanceDoor")
	check(mdoor != null and mdoor.get_node(mdoor.group).group_id == "L02-E04" and mdoor.get_node(mdoor.after).group_id == "L02-E03",
			"E04's guard steps out of the maintenance door once E03's rover is down")
	# S2: the range goes live.
	var rl: Node = a02.get_node("Entities/RangeLive")
	check_eq(rl.plates.size(), 3, "the range has three cover plates")
	for p in rl.plates:
		var plate: Node = rl.get_node_or_null(p)
		check(plate != null and plate.is_in_group("cover_plate"), "range plate %s is a cover plate" % str(p))
	var rl_x: float = _local(a02, rl).x
	check(rl_x > 4300.0 and rl_x < 4500.0, "the range trigger is at the live-fire lanes' door (x %.0f)" % rl_x)
	var sdoor: Node = a02.get_node("Entities/SideDoor")
	var sg: EncounterGroup = sdoor.get_node(sdoor.group)
	check(sg.group_id == "L02-E08-D" and sg.wait_for_trigger and sg.get_node_or_null(sg.share_tokens_with).group_id == "L02-E08",
			"E08's side-door guard shares E08's attack tokens")
	# S3: the kennel pods.
	var pa: Node = a02.get_node("Entities/KennelPodA")
	var pb: Node = a02.get_node("Entities/KennelPodB")
	check(pa.get_node(pa.group).group_id == "L02-E10-P1" and pb.get_node(pb.group).group_id == "L02-E10-P2", "the pods hold E10's two Hounds")
	check(pa.get_node(pa.after).group_id == "L02-E09", "pod A opens after E09 is down")
	check(pb.get_node(pb.after) == pa, "pod B opens after pod A")
	check(pa.trigger_x == pb.trigger_x, "both pods share the trigger")
	for p in [pa, pb]:
		var g: EncounterGroup = p.get_node(p.group)
		check(g.wait_for_trigger and g.get_node_or_null(g.share_tokens_with) != null and g.get_node(g.share_tokens_with).group_id == "L02-E10",
				"%s's group waits and shares E10's tokens" % p.name)
	# Secret 1: the armory.
	var wall: Node = a02.get_node("Entities/ArmoryGlass")
	check(wall.entity_id == "L02-A02-BR01" and wall.solid and wall.kind == Breakable.Kind.GLASS_PANEL, "the armory's cracked glass wall is the solid L02-A02-BR01")
	var inside: Array = []
	for p in wall.contents:
		var n: Node = wall.get_node_or_null(p)
		if n:
			inside.append(n.get("entity_id"))
	inside.sort()
	check_eq(inside, ["L02-A02-AM02", "L02-A02-CACHE01"], "behind it: a cartridge and the 5-chip tray")
	check_eq(a02.get_node("Entities/ArmoryTray").value, 5, "the armory tray holds 5 chips")


# --- 7. pickups and breakables ---------------------------------------------------------------

func _test_pickups_and_breakables(a01: AreaRoot, a02: AreaRoot) -> void:
	var ids := {}
	var re := RegEx.create_from_string("^L02-A0([12])-G\\d{3}$")
	for i in 2:
		var a: AreaRoot = [a01, a02][i]
		var chips := _all(a.get_node("Entities"), func(n): return n is Chip)
		var want := 9 if i == 0 else 10
		check_eq(chips.size(), want, "%s has %d chips" % [a.area_id, want])
		var total := 0
		for c in chips:
			var m := re.search(c.entity_id)
			check(m != null and int(m.get_string(1)) == i + 1, "chip id %s matches L02-A0%d-Gnnn" % [c.entity_id, i + 1])
			check(not ids.has(c.entity_id), "chip id %s is unique" % c.entity_id)
			ids[c.entity_id] = true
			total += c.value
		check_eq(total, want, "%s's chips are worth %d" % [a.area_id, want])
		var br := _all(a.get_node("Entities"), func(n): return n.is_in_group("breakable"))
		check(br.size() >= 7, "%s has about 7 breakables (%d)" % [a.area_id, br.size()])
		var rewarding := 0
		for b in br:
			if not b.contents.is_empty():
				rewarding += 1
				check(String(b.entity_id).begins_with("%s-BR" % a.area_id), "%s holds a reward and has a BR id (%s)" % [b.name, b.entity_id])
		check(rewarding >= 2, "%s: a few breakables hold chips or a cartridge (%d)" % [a.area_id, rewarding])
		var carts := _all(a.get_node("Entities"), func(n): return String(n.scene_file_path).ends_with("ammo_cartridge.tscn"))
		check(carts.size() >= 1, "%s has a feed cartridge" % a.area_id)
		for c in carts:
			check(String(c.entity_id).begins_with("%s-AM" % a.area_id), "cartridge id %s" % c.entity_id)
	check(a01.get_node_or_null("Entities/AmmoCartridge_AM01") != null and a01.get_node("Entities/AmmoCartridge_AM01").entity_id == "L02-A01-AM01",
			"A01's cartridge L02-A01-AM01 is in the service landing's crate")


# --- 8. the route bot ---------------------------------------------------------------------

func _test_route_bot(path: String, label: String) -> void:
	release_all()
	CheckpointService.clear()
	Session.new_run("L02")
	var harness = load("res://tests/area_harness.gd").new()
	var result: Dictionary = await harness.run_area(self, path, [], 120.0)
	check(result.reached_exit, "%s: the RouteBot crosses the area alone on the main route (failure=%s, at %s, %.1f s)" % [
			label, result.failure, str(result.hero_final_position.round()), result.seconds])
	print("[test_l02v2_a01_a02] route bot %s: %s in %.1f s (%d/%d points)" % [label,
			"done" if result.reached_exit else "FAILED", result.seconds, result.point_index_reached, result.points_total])
	release_all()


# --- 9. the fair fights ---------------------------------------------------------------------

func _group_by_id(lvl: LevelDirector, gid: String) -> EncounterGroup:
	for a in [lvl.areas[0], lvl.areas[1]]:
		for g in a.get_node("Encounters").get_children():
			if g is EncounterGroup and g.group_id == gid:
				return g
	return null


func _fight(cfg: Dictionary) -> void:
	release_all()
	await physics_frames(2)
	CheckpointService.clear()
	Session.new_run("L02")
	for gid in ENCOUNTERS:
		if not (gid in cfg.groups):
			for id in (ENCOUNTERS[gid][1] as Dictionary):
				Session.mark_defeated(id)
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	_level = lvl
	await physics_frames(3)
	var label: String = cfg.label
	var enemies: Array = []
	var groups: Array = []
	for gid in cfg.groups:
		var g := _group_by_id(lvl, gid)
		check(g != null, "%s: group %s exists" % [label, gid])
		if g == null:
			lvl.queue_free()
			await physics_frames(2)
			return
		groups.append(g)
		enemies.append_array(_all(g, func(n): return n.is_in_group("enemy")))
	var new_type_ids: Array = []
	for e in enemies:
		if e is Gunner or e is Hound or e is PatrolRover:
			new_type_ids.append(e.entity_id)
	var pods: Array = []
	for a in [lvl.areas[0], lvl.areas[1]]:
		for p in _all(a, func(n): return n.has_method("held_enemies")):
			if p.get_node_or_null(p.group) in groups:
				pods.append(p)
	var vents: Array = _all(lvl.areas[0], func(n): return n.get_script() == Vent)
	var points: Array = []
	for rp in cfg.route:
		points.append((lvl.areas[int(rp[0])] as AreaRoot).get_node("Route/" + String(rp[1])))
	var lim_area: AreaRoot = lvl.areas[int(cfg.limits[0])]
	var xmin: float = lim_area.to_global(Vector2(cfg.limits[1], 0)).x
	var xmax: float = lim_area.to_global(Vector2(cfg.limits[2], 0)).x
	var lure_x: float = lim_area.to_global(Vector2(cfg.lure, 0)).x if cfg.has("lure") else NAN
	var hero: Hero = lvl.hero
	check(hero.aim_pivot.get_node_or_null("Scrapjack") != null and Session.weapon_stage("W01") == 0,
			"%s: Dave holds the base Scrapjack" % label)
	var start: Node2D = points[0]
	for g in groups:
		var zone: Area2D = g.get_node_or_null("ApproachZone")
		if zone:
			var zs := (zone.get_node("CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D
			check(start.global_position.x < zone.global_position.x - zs.size.x * 0.5,
					"%s: Dave starts at %s, before %s's ApproachZone" % [label, start.name, g.group_id])
	await _teleport(lvl, start.global_position + Vector2(0.0, -4.0))
	for g in groups:
		check(not g.is_active, "%s: %s sleeps until Dave's approach" % [label, g.group_id])
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(300.0, -40.0)
	# The static sweep: no pit edge within 1.5 H behind any spot a gun in this fight reaches.
	for e in enemies:
		if e is Gunner:
			_sweep_gun_lane(e, xmin, xmax, e.global_position.y, label)

	var ctx := {
		"t": 0, "health0": Session.get_health(), "min_health": Session.get_health(), "hits": 0,
		"tells": 0, "tells_by": {}, "shots": 0, "lunges": 0, "swings": 0, "charges": 0,
		"max_shooters": 0, "max_attackers": 0, "fire_gate_bad": [], "airborne_tells": 0,
		"pit_bad": [], "died": false, "jumps": 0, "vent_hits": 0, "prev": {}, "last_attack": {},
		"active_at": {}, "hit_by": [], "tells_by_enemy": {},
	}
	hero.died.connect(func(): ctx.died = true)
	var on_health := _on_health.bind(ctx, vents)
	Session.health_changed.connect(on_health)
	for e in enemies:
		if e is Gunner:
			e.fired.connect(_on_gunner_fired.bind(e, lvl, ctx))

	var idx := 1
	var jump_left := 0
	var route_jump := false
	var route_jump_left_ground := false
	var max_ticks := int(BUDGET_S * 60.0)
	while int(ctx.t) < max_ticks:
		var alive := enemies.filter(func(e): return _alive(e))
		if alive.is_empty() or ctx.died:
			break
		var view := _view(lvl)
		for e in alive:
			if _is_live(e) and not (ctx.active_at as Dictionary).has(e.entity_id):
				ctx.active_at[e.entity_id] = int(ctx.t)
		_audit(hero, alive, view, ctx)
		var feet := hero.global_position
		var want_jump := false
		var jump_ticks := JUMP_HOLD_TICKS
		var target_x := NAN
		var tol := 10.0
		var steer_over := NAN   # a jump over a charging rover steers this way

		# 1. Threats.
		for r in get_tree().get_nodes_in_group("enemy_round"):
			if _round_arrival(r, hero) <= ROUND_REACT_S:
				want_jump = true
		var guard_close: Node = null
		var rover_stalled: PatrolRover = null
		var rover_alive: PatrolRover = null
		for e in alive:
			if not _is_live(e):
				continue
			var dx: float = e.global_position.x - feet.x
			var same: bool = absf(e.global_position.y - feet.y) <= 64.0
			if e is Hound:
				if _hound_red_at(e, hero):
					want_jump = true
			elif e is PatrolRover:
				rover_alive = e
				if e.state == PatrolRover.State.STALL:
					rover_stalled = e
				elif e.state == PatrolRover.State.CHARGE and same and absf(dx) < 170.0 \
						and signf(-dx) == float(e.facing) and _clear(feet + Vector2(0, -30), e.global_position + Vector2(0, -30)):
					want_jump = true
					steer_over = e.global_position.x + float(e.facing) * -200.0
			elif e is Brawler:
				if same and absf(dx) <= GUARD_TOO_CLOSE and e.state in [Brawler.State.WINDUP, Brawler.State.STRIKE, Brawler.State.APPROACH]:
					guard_close = e
		var vent_x := NAN
		for v in vents:
			if v.state == Vent.State.IDLE:
				continue
			var r: Rect2 = v.damage_rect()
			r.position += v.global_position
			r = r.grow_individual(HALF_W + 14.0, 0.0, HALF_W + 14.0, 0.0)
			if feet.x > r.position.x and feet.x < r.end.x and feet.y > r.position.y and feet.y <= r.end.y + 4.0:
				var left: float = r.position.x - 6.0
				var right: float = r.end.x + 6.0
				vent_x = left if absf(feet.x - left) < absf(feet.x - right) else right
				if not _floor_under(Vector2(vent_x, feet.y), 30.0):
					vent_x = right if vent_x == left else left

		# 2. Fight or walk on.
		var engaged := alive.filter(func(e): return _engages(e, hero))
		# A pod row that is armed (Dave passed its trigger) is watched: he waits for it to open.
		var paused := pods.any(func(p): return p.state == ReleasePod.State.WARNING or (p.state == ReleasePod.State.CLOSED and p._armed and is_finite(p.trigger_x)))
		var fighting := not engaged.is_empty() and not route_jump
		if route_jump:
			target_x = points[idx + 1].global_position.x if idx + 1 < points.size() else feet.x
			tol = 4.0
			if not hero.is_on_floor():
				route_jump_left_ground = true
			elif route_jump_left_ground and jump_left <= 0:
				route_jump = false
				idx += 1
		elif fighting:
			if not is_nan(steer_over):
				target_x = steer_over
			elif rover_stalled != null:
				var rear: Vector2 = rover_stalled.rear_hit_zone.global_position
				target_x = rear.x - float(rover_stalled.facing) * 70.0
				tol = 14.0
			elif rover_alive != null and not is_nan(lure_x):
				target_x = lure_x
			elif not is_nan(vent_x):
				target_x = vent_x
				tol = 4.0
			elif guard_close != null:
				var away: float = -signf(guard_close.global_position.x - feet.x)
				target_x = feet.x + away * 220.0
			else:
				target_x = _stand_off(engaged, hero)
			if is_nan(steer_over) and rover_stalled == null:
				target_x = _clamp_to_floor(hero, clampf(target_x, xmin + 30.0, xmax - 30.0))
		elif not is_nan(vent_x):
			target_x = vent_x
			tol = 4.0
		elif paused:
			target_x = feet.x
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
		else:
			# The route is walked: go to the nearest live enemy left (dropping off a deck if need be).
			var best: Node2D = null
			for e in alive:
				if _is_live(e) and (best == null or absf(e.global_position.x - feet.x) < absf(best.global_position.x - feet.x)):
					best = e
			if best != null:
				target_x = clampf(best.global_position.x - signf(best.global_position.x - feet.x) * 200.0, xmin + 30.0, xmax - 30.0)

		# 3. Shooting, in the punish windows.
		var target: Node = _pick_target(alive.filter(func(e): return _open_to_fire(e, alive, ctx)), hero, view)
		if target != null:
			hero.aim_override = _center(target)
			press("fire")
		else:
			release("fire")
			if not is_nan(target_x) and absf(target_x - feet.x) > 8.0:
				hero.aim_override = feet + Vector2(signf(target_x - feet.x) * 300.0, -40.0)

		# 4. Steer and jump.
		if is_nan(target_x) or absf(target_x - feet.x) <= tol:
			release("move_left"); release("move_right")
		elif target_x > feet.x:
			release("move_left"); press("move_right")
		else:
			release("move_right"); press("move_left")
		if fighting and hero.is_on_floor() and hero.is_on_wall() and not is_nan(target_x) and absf(target_x - feet.x) > tol:
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
		if OS.get_environment("L02V2_DEBUG") != "" and int(ctx.t) % 30 == 0:
			var st: Array = []
			for e in alive:
				st.append("%s:%d@%.0f,%.0f live=%s" % [e.entity_id.right(9), e.state, e.global_position.x, e.global_position.y, _is_live(e)])
			print("[dbg] t=%.1f dave %.0f,%.0f idx=%d fight=%s tgt=%.0f %s" % [ctx.t / 60.0, feet.x, feet.y, idx, fighting, target_x, str(st)])
		await physics_frames(1)
		ctx.t = int(ctx.t) + 1
	release_all()

	var down := enemies.filter(func(e): return not _alive(e)).size()
	var lost: int = int(ctx.health0) - int(ctx.min_health)
	var secs: float = float(ctx.t) / 60.0
	var half: int = Session.max_health() / 2
	check(down == enemies.size(), "%s: every enemy is down (%d of %d) in %.1f s" % [label, down, enemies.size(), secs])
	check(not ctx.died, "%s: Dave survives" % label)
	check(lost <= half, "%s: Dave loses at most half his health (%d of %d: %s)" % [label, lost, Session.max_health(), str(ctx.hit_by)])
	check(secs < BUDGET_S, "%s: inside the %.0f s budget (%.1f s)" % [label, BUDGET_S, secs])
	if not new_type_ids.is_empty():
		check(int(ctx.tells) >= 1, "%s: the encounter showed its tells (%d)" % [label, ctx.tells])
	for id in new_type_ids:
		check(int(ctx.tells_by_enemy.get(id, 0)) >= 1, "%s: %s showed its tell before it went down" % [label, id])
	check(int(ctx.max_shooters) <= 2, "%s: at most 2 shooters on screen (max %d)" % [label, ctx.max_shooters])
	check(int(ctx.max_attackers) <= 3, "%s: at most 3 attackers on screen (max %d)" % [label, ctx.max_attackers])
	check((ctx.fire_gate_bad as Array).is_empty(), "%s: every round left with its gunner 1 H inside the camera and Dave on screen (%s)" % [label, ctx.fire_gate_bad])
	check(int(ctx.airborne_tells) == 0, "%s: no gun tell started at an airborne Dave (%d)" % [label, ctx.airborne_tells])
	check((ctx.pit_bad as Array).is_empty(), "%s: no pit edge within 1.5 H behind Dave while a gun aimed at him (%s)" % [label, ctx.pit_bad])
	var report := "%s: %s in %.1f s, damage %d/%d %s (steam %d), tells %s, rounds %d, lunges %d, swings %d, charges %d, jumps %d, max on screen %d shooters / %d attackers" % [
			label, "WON" if down == enemies.size() and not ctx.died else "LOST", secs, lost, Session.max_health(), str(ctx.hit_by),
			ctx.vent_hits, str(ctx.tells_by), ctx.shots, ctx.lunges, ctx.swings, ctx.charges, ctx.jumps, ctx.max_shooters, ctx.max_attackers]
	_reports.append(report)
	print("[test_l02v2_a01_a02] " + report)
	if Session.health_changed.is_connected(on_health):
		Session.health_changed.disconnect(on_health)
	lvl.queue_free()
	await physics_frames(2)
	CheckpointService.clear()


## Live: thinking (not held in a closed release prop) and its group awake.
func _is_live(e: Node) -> bool:
	if not _alive(e) or not e.can_process():
		return false
	var g: Node = e.get("_group")
	return g == null or g.is_active


func _clear(from: Vector2, to: Vector2) -> bool:
	return _ray(from, to).is_empty()


## Does `e` hold Dave in the fight? A gunner who can see him within ENGAGE_X; anyone else live on
## his floor within ENGAGE_X with a clear line between them.
func _engages(e: Node, hero: Hero) -> bool:
	if not _is_live(e):
		return false
	var d: Vector2 = e.global_position - hero.global_position
	if absf(d.x) > ENGAGE_X:
		return false
	if e is Gunner:
		return e.can_see(hero)
	if absf(d.y) > 64.0:
		return false
	return _clear(hero.global_position + Vector2(0, -50), e.global_position + Vector2(0, -30))


## A stand-off from the nearest engaged enemy on Dave's floor (300 px from a gunner, 280 from the
## rest), or where he stands.
func _stand_off(engaged: Array, hero: Hero) -> float:
	var feet := hero.global_position
	var nearest: Node2D = null
	for e in engaged:
		if absf(e.global_position.y - feet.y) > 64.0 and not (e is Gunner):
			continue
		if nearest == null or absf(e.global_position.x - feet.x) < absf(nearest.global_position.x - feet.x):
			nearest = e
	if nearest == null:
		return feet.x
	var dx: float = nearest.global_position.x - feet.x
	var standoff: float = 300.0 if nearest is Gunner else 280.0
	if absf(dx) <= standoff:
		return feet.x
	return nearest.global_position.x - signf(dx) * standoff


## `x` cut back to the floor Dave stands on (he never walks off a ledge while fighting).
func _clamp_to_floor(hero: Hero, x: float) -> float:
	var feet := hero.global_position
	if not hero.is_on_floor():
		return x
	var dir: float = signf(x - feet.x)
	var cx: float = feet.x
	while absf(x - cx) > 8.0:
		var nx: float = cx + dir * 8.0
		if not _floor_under(Vector2(nx + dir * HALF_W, feet.y), 26.0):
			return cx
		cx = nx
	return x


func _teleport(lvl: LevelDirector, pos: Vector2) -> void:
	lvl.hero.respawn_at(pos)
	var r: Rect2 = lvl._camera_target_rect_for_area(lvl._area_for_x(pos.x))
	lvl._camera_top = r.position.y
	lvl._camera_bottom = r.position.y + r.size.y
	lvl.camera.world_limits = Rect2(0.0, r.position.y, lvl.level_width, r.size.y)
	await physics_frames(2)
	lvl.camera.reset_position()
	await physics_frames(8)


func _alive(e) -> bool:
	if not is_instance_valid(e) or e.is_queued_for_deletion():
		return false
	if e is Gunner:
		return e.state != Gunner.State.DEFEATED
	if e is Drone:
		return e.state != Drone.State.DEFEATED
	if e is Brawler:
		return e.state != Brawler.State.DEFEATED
	if e is PatrolRover:
		return e.state != PatrolRover.State.DEFEATED
	return true


func _center(e: Node2D) -> Vector2:
	if e is Drone:
		return e.global_position
	if e is PatrolRover:
		return (e as PatrolRover).rear_hit_zone.global_position
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


func _on_health(current: int, _max: int, ctx: Dictionary, vents: Array) -> void:
	if current < int(ctx.min_health):
		ctx.hits = int(ctx.hits) + 1
		var by: Array = []
		for v in vents:
			var vr: Rect2 = v.damage_rect()
			vr.position += v.global_position
			if v.is_damaging() and vr.grow(HALF_W + 4.0).has_point(_level.hero.global_position + Vector2(0, -20)):
				by.append("steam")
				ctx.vent_hits = int(ctx.vent_hits) + 1
		for e in get_tree().get_nodes_in_group("enemy"):
			if e is Brawler and e.is_attack_active():
				by.append("hound lunge" if e is Hound else "swing")
			elif e is PatrolRover and e.state == PatrolRover.State.CHARGE:
				by.append("rover charge")
		for r in get_tree().get_nodes_in_group("enemy_round"):
			if r is EnemyRound and r.is_spent():
				by.append("round")
		(ctx.hit_by as Array).append("/".join(by) if not by.is_empty() else "?")
	ctx.min_health = mini(int(ctx.min_health), current)


func _on_gunner_fired(_round: Node, g: Gunner, lvl: LevelDirector, ctx: Dictionary) -> void:
	ctx.shots = int(ctx.shots) + 1
	var view := _view(lvl)
	var dave_on: bool = view.has_point(lvl.hero.global_position + Vector2(0.0, -H * 0.5))
	if not g.is_on_camera() or not view.grow(-H).has_point(g.global_position + Vector2(0.0, -Gunner.HEIGHT * 0.5)) or not dave_on:
		(ctx.fire_gate_bad as Array).append("%s at %s" % [g.entity_id, str(g.global_position.round())])


## The player's discipline: a gunner in his shot or reload, a Hound in its recovery, a rover only
## while it stalls (its battery), a guard or Staffer any time (a handler once his dog is down); a
## new type that holds back for IDLE_FIRE_S may be shot anyway.
func _open_to_fire(e: Node, alive: Array, ctx: Dictionary) -> bool:
	if not _is_live(e):
		return false
	var since: int = maxi(int(ctx.last_attack.get(e.entity_id, 0)), int(ctx.active_at.get(e.entity_id, int(ctx.t))))
	var idle: bool = int(ctx.t) - since >= int(IDLE_FIRE_S * 60.0)
	if e is Gunner:
		return e.state in [Gunner.State.FIRE, Gunner.State.RELOAD] or (idle and e.state != Gunner.State.AIM)
	if e is PatrolRover:
		return e.state == PatrolRover.State.STALL
	if e is Hound:
		return e.state == Brawler.State.RECOVERY or (idle and not e.is_in_chain())
	var k9: Node = e.get("_k9")
	return not (k9 != null and _alive(k9))


func _round_arrival(r: Node, hero: Hero) -> float:
	if not (r is EnemyRound) or r.is_spent():
		return INF
	var dir: Vector2 = r.direction
	var feet := hero.global_position
	var dx: float = feet.x - r.global_position.x
	if dir.x * dx <= 0.0 or absf(dir.x) < 0.05:
		return INF
	var gap: float = maxf(absf(dx) - HALF_W, 0.0)
	var t: float = gap / (r.speed * absf(dir.x))
	var y_at: float = r.global_position.y + dir.y / absf(dir.x) * absf(dx)
	if y_at < feet.y - H - 8.0 or y_at > feet.y + 4.0:
		return INF
	return t


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


func _pick_target(cands: Array, hero: Hero, view: Rect2) -> Node:
	var best: Node = null
	var best_d := INF
	var from := hero.global_position + Vector2(0.0, -60.0)
	for e in cands:
		var c := _center(e)
		if not view.grow(-16.0).has_point(c):
			continue
		var d := from.distance_to(c)
		if d > SHOOT_RANGE:
			continue
		if not _clear(from, c):
			continue
		if d < best_d:
			best_d = d
			best = e
	return best


func _audit(hero: Hero, alive: Array, view: Rect2, ctx: Dictionary) -> void:
	var shooters := 0
	var attackers := 0
	for e in get_tree().get_nodes_in_group("enemy"):
		if not _alive(e) or not e.can_process() or not view.has_point(_center(e)):
			continue
		attackers += 1
		if e is Gunner or e is Drone:
			shooters += 1
	ctx.max_shooters = maxi(int(ctx.max_shooters), shooters)
	ctx.max_attackers = maxi(int(ctx.max_attackers), attackers)
	var prev: Dictionary = ctx.prev
	for e in alive:
		var st: int = e.state
		var was: int = prev.get(e.entity_id, -1)
		prev[e.entity_id] = st
		if st == was:
			continue
		var tell := false
		if e is Gunner and st == Gunner.State.AIM:
			tell = true
		elif e is PatrolRover and st == PatrolRover.State.WINDUP:
			tell = true
		elif e is PatrolRover and st == PatrolRover.State.CHARGE:
			ctx.charges = int(ctx.charges) + 1
		elif e is Brawler and st == Brawler.State.WINDUP:
			tell = was != Brawler.State.STRIKE
		elif e is Brawler and st == Brawler.State.STRIKE:
			if e is Hound:
				ctx.lunges = int(ctx.lunges) + 1
			else:
				ctx.swings = int(ctx.swings) + 1
		if tell:
			ctx.tells = int(ctx.tells) + 1
			ctx.last_attack[e.entity_id] = int(ctx.t)
			ctx.tells_by_enemy[e.entity_id] = int(ctx.tells_by_enemy.get(e.entity_id, 0)) + 1
			var kind := _type_of(e)
			ctx.tells_by[kind] = int(ctx.tells_by.get(kind, 0)) + 1
			if e is Gunner and not hero.is_on_floor():
				ctx.airborne_tells = int(ctx.airborne_tells) + 1
	if hero.is_on_floor():
		for e in alive:
			if e is Gunner and e.state == Gunner.State.AIM:
				var bad := _pit_behind(hero.global_position, signf(hero.global_position.x - e.global_position.x))
				if bad != "" and (ctx.pit_bad as Array).size() < 4:
					(ctx.pit_bad as Array).append(bad)


func _pit_behind(feet: Vector2, away: float) -> String:
	for k in 10:
		var x: float = feet.x + away * (HALF_W + 1.5 * H * float(k) / 9.0)
		if _ray(Vector2(x, feet.y - 8.0), Vector2(x, feet.y + 24.0)).is_empty():
			return "standing at x %.0f, the floor ends by x %.0f" % [feet.x, x]
	return ""


## Every spot on the fight's floors a gunner's gun reaches has 1.5 H of floor behind it.
func _sweep_gun_lane(g: Gunner, fmin: float, fmax: float, floor_y: float, label: String) -> void:
	var reach := 0
	var bad: Array = []
	var x := fmin
	while x <= fmax:
		var spot := Vector2(x, floor_y)
		var target := spot + Vector2(0.0, -g.tuning.round_height())
		var ahead: float = (target.x - g.global_position.x) * float(g.facing)
		if ahead >= 8.0 and absf(target.x - g.flat_origin().x) <= g.tuning.engage_range():
			var on_floor := not _ray(spot + Vector2(0.0, -8.0), spot + Vector2(0.0, 24.0)).is_empty()
			var clear := _ray(spot + Vector2(0.0, -H + 4.0), spot + Vector2(0.0, -12.0)).is_empty()
			if on_floor and clear:
				reach += 1
				var b := _pit_behind(spot, signf(spot.x - g.global_position.x))
				if b != "":
					bad.append(b)
		x += 16.0
	check(reach > 0, "%s: %s's gun reaches part of the fight floor (%d spots)" % [label, g.entity_id, reach])
	check(bad.is_empty(), "%s: no standing spot in %s's lane has a pit edge within 1.5 H behind it (%s)" % [label, g.entity_id, str(bad.slice(0, 3))])
