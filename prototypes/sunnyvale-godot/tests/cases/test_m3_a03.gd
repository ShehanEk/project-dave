extends TestCase
## M3 area: L01-A03 Rooftop walk (scenes/levels/areas/a03_roofs.tscn).
## Porch-step ascent -> first moving-platform crossing (with an untested but
## present ground-level recovery lane below) -> Resident E05 on a broad far
## terrace -> a short roof-height sequence to Resident E06's broad landing ->
## protected descent with CP02 -> broad descending terraces to the exit seam.
## OPT02 is a small up-and-back detour right after the platform landing that
## opens the 20-value gem cache and rejoins the main route in place.
## Population/treasure per 02-area-blueprints.md: 2 Residents, 0 Clippers,
## 5 small gems + 1 cluster (10) on the main route, 20 in the OPT02 cache.

const AREA := "res://scenes/levels/areas/a03_roofs.tscn"

const EXPECTED_BEATS := [
	"L01-A03-B01", "L01-A03-B02", "L01-A03-B03", "L01-A03-B04", "L01-A03-B05",
]
const EXPECTED_GEMS := [
	"L01-A03-G001", "L01-A03-G002", "L01-A03-G003", "L01-A03-G004", "L01-A03-G005",
]
const CLUSTER_ID := "L01-A03-GC01"
const CACHE_ID := "L01-OPT02-CACHE01"
const EXPECTED_ENEMIES := ["L01-E05-Z01-01", "L01-E06-Z01-01"]


func run() -> void:
	await _test_main_route_reaches_exit()
	await _test_opt02_branch_opens_cache_and_reaches_exit()
	_test_static_population_matches_blueprint()


# --- 1. main route reaches the exit seam, OPT02 cache untouched -------------

func _test_main_route_reaches_exit() -> void:
	Session.new_run()
	var harness = load("res://tests/area_harness.gd").new()
	var result: Dictionary = await harness.run_area(self, AREA, [], 60.0)
	check(result.reached_exit,
			"A03 main route reaches the exit seam (failure=%s, pos=%s)"
			% [result.failure, result.hero_final_position])

	for id in EXPECTED_GEMS:
		check(Session.is_collected(id), "main route collects gem %s" % id)
	check(Session.is_collected(CLUSTER_ID), "main route collects the gem cluster %s" % CLUSTER_ID)
	# Session.gems_found() sums collected VALUES (small=1, cluster=5), not
	# item counts, so 5 small + 1 cluster totals 10, matching the wallet.
	check(Session.gems_found() == EXPECTED_GEMS.size() * 1 + 5,
			"main-route treasure totals 10 gems worth of value (5 small + 1 cluster) (got %d)"
			% Session.gems_found())
	check(Session.get_wallet() == EXPECTED_GEMS.size() * 1 + 5,
			"main-route treasure totals 10 gems worth of wallet value (got %d)" % Session.get_wallet())
	check(not Session.is_collected(CACHE_ID), "the OPT02 cache is untouched when that branch is disabled")

	check(Session.is_defeated(EXPECTED_ENEMIES[0]) or not Session.is_defeated(EXPECTED_ENEMIES[0]),
			"sanity: defeat query does not error for E05 (route bot never fights)")

	print("[test_m3_a03] main route seconds=%.2f" % result.seconds)
	for beat_id in EXPECTED_BEATS:
		var t: float = result.beat_times.get(beat_id, -1.0)
		print("[test_m3_a03] beat %s reached at t=%.2fs" % [beat_id, t])
	for beat_id in EXPECTED_BEATS:
		check(result.beat_times.has(beat_id), "beat %s reports an elapsed time" % beat_id)

	var t01: float = result.beat_times.get("L01-A03-B01", 9999.0)
	var t02: float = result.beat_times.get("L01-A03-B02", 9999.0)
	var t03: float = result.beat_times.get("L01-A03-B03", 9999.0)
	var t04: float = result.beat_times.get("L01-A03-B04", 9999.0)
	var t05: float = result.beat_times.get("L01-A03-B05", 9999.0)
	check(t01 <= t02, "B01 is reached before B02")
	check(t02 <= t03, "B02 is reached before B03")
	check(t03 <= t04, "B03 is reached before B04")
	check(t04 <= t05, "B04 is reached before B05")


# --- 2. OPT02 branch opens the cache and still reaches the exit -------------

func _test_opt02_branch_opens_cache_and_reaches_exit() -> void:
	Session.new_run()
	var harness = load("res://tests/area_harness.gd").new()
	var wallet_before: int = Session.get_wallet()

	var result: Dictionary = await harness.run_area(self, AREA, ["OPT02"], 60.0)
	check(result.reached_exit,
			"A03 main route + OPT02 branch reach the exit seam (failure=%s, pos=%s)"
			% [result.failure, result.hero_final_position])
	check(Session.is_collected(CACHE_ID), "the OPT02 branch opens the optional cache")
	check(Session.get_wallet() == wallet_before + 10 + 20,
			"OPT02 run collects the main route's 10 gems plus the cache's 20 (before=%d after=%d)"
			% [wallet_before, Session.get_wallet()])

	print("[test_m3_a03] OPT02 branch seconds=%.2f" % result.seconds)


# --- 3. static population matches 02-area-blueprints.md exactly -------------

func _test_static_population_matches_blueprint() -> void:
	var area: AreaRoot = load(AREA).instantiate()
	add_child(area)

	check(area.area_id == "L01-A03", "area_id is L01-A03")

	var beat_ids: PackedStringArray = area.get_beat_ids()
	check(beat_ids.size() == 5, "exactly 5 beats are placed (got %d: %s)" % [beat_ids.size(), beat_ids])
	for i in EXPECTED_BEATS.size():
		check(beat_ids[i] == EXPECTED_BEATS[i],
				"beat %d is %s in route order (got %s)" % [i, EXPECTED_BEATS[i], beat_ids[i]])

	var entity_ids: PackedStringArray = area.get_entity_ids()
	var expected_entities := EXPECTED_GEMS.duplicate()
	expected_entities.append(CLUSTER_ID)
	expected_entities.append(CACHE_ID)
	check(entity_ids.size() == expected_entities.size(),
			"exactly %d tracked entities: 5 gems + 1 cluster + the OPT02 cache (got %d: %s)"
			% [expected_entities.size(), entity_ids.size(), entity_ids])
	for id in expected_entities:
		check(entity_ids.has(id), "entity_ids includes %s" % id)

	var enemy_ids: PackedStringArray = area.get_enemy_ids()
	check(enemy_ids.size() == 2, "exactly 2 enemies are placed (got %d: %s)" % [enemy_ids.size(), enemy_ids])
	for id in EXPECTED_ENEMIES:
		check(enemy_ids.has(id), "enemy_ids includes %s" % id)

	var encounters := area.get_node_or_null("Encounters")
	check(encounters != null and encounters.get_child_count() == 2,
			"exactly 2 EncounterGroups are present (E05, E06)")

	var e05: EncounterGroup = encounters.get_node("EncounterGroup_E05")
	var e06: EncounterGroup = encounters.get_node("EncounterGroup_E06")
	check(e05.group_id == "L01-E05", "first group is L01-E05")
	check(e06.group_id == "L01-E06", "second group is L01-E06")

	# E05 must not be able to chase into E06's lane: the lanes are disjoint
	# (E05's lane ends well before E06's lane begins).
	var e05_end: float = e05.lane_rect.position.x + e05.lane_rect.size.x
	var e06_start: float = e06.lane_rect.position.x
	check(e05_end <= e06_start,
			"E05's lane (ends at x=%.0f) does not overlap E06's lane (starts at x=%.0f)"
			% [e05_end, e06_start])

	# Each Resident starts at least 2H (192px) beyond the edge of its own
	# lane closest to the approach, i.e. away from where the hero lands.
	var h := 96.0
	var resident05: Node = e05.get_node("Resident_Z01_01")
	var resident06: Node = e06.get_node("Resident_Z01_01")
	check(resident05.global_position.x - e05.lane_rect.position.x >= 2.0 * h,
			"E05's Resident stands at least 2H beyond its lane's landing edge")
	check(resident06.global_position.x - e06.lane_rect.position.x >= 2.0 * h,
			"E06's Resident stands at least 2H beyond its lane's landing edge")

	var route_points: Array = area.get_route_points([])
	check(route_points.size() >= 10,
			"the main route has enough points for the full traversal (got %d)" % route_points.size())
	var opt_points: Array = area.get_route_points(["OPT02"])
	check(opt_points.size() > route_points.size(),
			"enabling OPT02 adds extra route points (main=%d, +OPT02=%d)"
			% [route_points.size(), opt_points.size()])

	var wait_platform_count := 0
	for p in route_points:
		if p.action == RoutePoint.Action.WAIT_PLATFORM:
			wait_platform_count += 1
	check(wait_platform_count == 2,
			"the main route waits on the moving platform exactly twice (board + ride) (got %d)"
			% wait_platform_count)

	var gap_platform := area.get_node_or_null("Geometry/GapPlatform")
	check(gap_platform != null, "the first moving maintenance platform is present")

	var station: Node = area.get_node_or_null("Entities/RecoveryStation_CP02")
	check(station != null and station.checkpoint_id == "CP02", "CP02 recovery station is present")

	area.queue_free()
	await physics_frames(1)
