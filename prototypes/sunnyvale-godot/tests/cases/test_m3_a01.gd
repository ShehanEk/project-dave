extends TestCase
## M3 area: L01-A01 Perimeter gate (scenes/levels/areas/a01_gate.tscn).
## No enemies; proves the main route (arrival apron -> two low steps -> short
## gap with a walkable catch floor -> inert practice target -> gem trail ->
## open exit seam) is completable by the debug RouteBot, and that the exact
## population from 02-area-blueprints.md is present: 5 small gems
## (L01-A01-G001..G005), 0 Residents, 0 Clippers, 4 beats.

const AREA := "res://scenes/levels/areas/a01_gate.tscn"

const EXPECTED_BEATS := ["L01-A01-B01", "L01-A01-B02", "L01-A01-B03", "L01-A01-B04"]
const EXPECTED_GEMS := ["L01-A01-G001", "L01-A01-G002", "L01-A01-G003", "L01-A01-G004", "L01-A01-G005"]


func run() -> void:
	await _test_main_route_reaches_exit()
	await _test_static_population_matches_blueprint()
	await _test_seam_contract()


# --- 1. main route reaches the exit seam -------------------------------------

func _test_main_route_reaches_exit() -> void:
	Session.new_run()
	var harness = load("res://tests/area_harness.gd").new()
	var result: Dictionary = await harness.run_area(self, AREA, [], 45.0)
	check(result.reached_exit,
			"A01 main route reaches the exit seam (failure=%s, pos=%s)"
			% [result.failure, result.hero_final_position])

	for id in EXPECTED_GEMS:
		check(Session.is_collected(id), "main route collects gem %s" % id)
	check(Session.gems_found() == EXPECTED_GEMS.size(),
			"exactly %d gems are collected on the main route (got %d)"
			% [EXPECTED_GEMS.size(), Session.gems_found()])
	check(Session.get_wallet() == EXPECTED_GEMS.size(),
			"5 small gems (value 1 each) add up to a wallet of 5 (got %d)" % Session.get_wallet())

	print("[test_m3_a01] main route seconds=%.2f" % result.seconds)
	for beat_id in EXPECTED_BEATS:
		var t: float = result.beat_times.get(beat_id, -1.0)
		print("[test_m3_a01] beat %s reached at t=%.2fs" % [beat_id, t])
	check(result.beat_times.has("L01-A01-B01") and result.beat_times.has("L01-A01-B02")
			and result.beat_times.has("L01-A01-B03") and result.beat_times.has("L01-A01-B04"),
			"all four beats report an elapsed time (got %s)" % [result.beat_times])

	# Beats are hit in route order (B01 before B02 before B03 before B04) —
	# bot timing itself is NOT pacing evidence, just reported above. Use a
	# high default so a missing beat_times entry fails the ordering check
	# instead of crashing the test with an invalid dictionary access.
	var t01: float = result.beat_times.get("L01-A01-B01", 9999.0)
	var t02: float = result.beat_times.get("L01-A01-B02", 9999.0)
	var t03: float = result.beat_times.get("L01-A01-B03", 9999.0)
	var t04: float = result.beat_times.get("L01-A01-B04", 9999.0)
	check(t01 <= t02, "B01 is reached before B02")
	check(t02 <= t03, "B02 is reached before B03")
	check(t03 <= t04, "B03 is reached before B04")


# --- 2. static population matches 02-area-blueprints.md exactly -------------

func _test_static_population_matches_blueprint() -> void:
	var area: AreaRoot = load(AREA).instantiate()
	add_child(area)

	check(area.area_id == "L01-A01", "area_id is L01-A01")

	var beat_ids: PackedStringArray = area.get_beat_ids()
	check(beat_ids.size() == 4, "exactly 4 beats are placed (got %d: %s)" % [beat_ids.size(), beat_ids])
	for i in EXPECTED_BEATS.size():
		check(beat_ids[i] == EXPECTED_BEATS[i],
				"beat %d is %s in route order (got %s)" % [i, EXPECTED_BEATS[i], beat_ids[i]])

	var entity_ids: PackedStringArray = area.get_entity_ids()
	check(entity_ids.size() == EXPECTED_GEMS.size(),
			"exactly %d entities carry an entity_id — the 5 gems, no other tracked entity (got %d: %s)"
			% [EXPECTED_GEMS.size(), entity_ids.size(), entity_ids])
	for id in EXPECTED_GEMS:
		check(entity_ids.has(id), "entity_ids includes gem %s" % id)

	var enemy_ids: PackedStringArray = area.get_enemy_ids()
	check(enemy_ids.is_empty(), "A01 has zero enemies (0 Residents, 0 Clippers) per 02-area-blueprints.md (got %s)" % [enemy_ids])

	var encounters := area.get_node_or_null("Encounters")
	check(encounters == null or encounters.get_child_count() == 0,
			"no EncounterGroup is present in A01 (hostile-free area)")

	var practice_target := _find_node_of_type(area, "PracticeTarget")
	check(practice_target != null, "an inert PracticeTarget is placed beyond the shooting lane")

	var route_points: Array = area.get_route_points([])
	check(route_points.size() >= 6,
			"the main route has enough points to cover apron, two steps, gap, and gem trail (got %d)"
			% route_points.size())
	var jump_count := 0
	for p in route_points:
		if p.action == RoutePoint.Action.JUMP:
			jump_count += 1
	check(jump_count == 3,
			"the main route authors exactly 3 jumps: two low steps + one short gap (got %d)" % jump_count)

	area.queue_free()
	await physics_frames(1)


# --- 3. seam contract: >=384px flat floor at y=0 on both ends ---------------

func _test_seam_contract() -> void:
	var area: AreaRoot = load(AREA).instantiate()
	add_child(area)
	await physics_frames(1)

	check(area.width >= 3000.0 and area.width <= 4000.0,
			"area width %.0f is within the suggested 3000-4000px range" % area.width)

	# Entry seam: >=384px (4H) of flat floor at local y=0 starting at x=0.
	for x in [4.0, 100.0, 384.0]:
		check(area.has_floor_at(x), "entry seam has solid floor at local x=%.0f, y=0" % x)
	# Exit seam: >=384px (4H) of flat floor at local y=0 ending at x=width.
	for x in [area.width - 384.0, area.width - 100.0, area.width - 4.0]:
		check(area.has_floor_at(x), "exit seam has solid floor at local x=%.0f, y=0" % x)

	area.queue_free()
	await physics_frames(1)


func _find_node_of_type(root: Node, type_name: String) -> Node:
	for child in root.get_children():
		var script: Script = child.get_script()
		if script != null and script.get_global_name() == type_name:
			return child
		var found := _find_node_of_type(child, type_name)
		if found:
			return found
	return null
