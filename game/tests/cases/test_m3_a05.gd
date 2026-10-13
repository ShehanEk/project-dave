extends TestCase
## M3 L01-A05 Maintenance depot: compact safe interior workshop with the
## level's single core_node (L01-SC01, CP04/awakening trigger), the
## workbench (L01-UPG01) M3 stub (the weapon pad L01-A05-PAD01 was removed, C51), a
## PracticeTarget for trials, and the emergency_hatch to A06. No enemies, no
## chips (per 02-area-blueprints.md). No optional branch — OPT01/OPT02 belong
## to L01-A02/A03, not this area.

const AREA := "res://scenes/levels/areas/a05_depot.tscn"

const EXPECTED_BEATS: PackedStringArray = [
	"L01-A05-B01", "L01-A05-B02", "L01-A05-B03", "L01-A05-B04", "L01-A05-B05",
]


func run() -> void:
	await _test_main_route_reaches_exit_and_sets_story()
	await _test_area_population_matches_blueprint()


func _test_main_route_reaches_exit_and_sets_story() -> void:
	Session.new_run()
	var harness = load("res://tests/area_harness.gd").new()
	var result: Dictionary = await harness.run_area(self, AREA, [], 60.0)

	check(result.reached_exit,
			"A05 main route reaches the exit seam (failure=%s, pos=%s)" % [result.failure, result.hero_final_position])

	# Story/save contract (CoreNode L01-SC01, the level's only console).
	check(Session.get_story("awakening_done"), "main route's console interaction sets awakening_done")
	check(Session.get_story("core_installed"), "main route's console interaction sets core_installed")
	check(Session.get_story("hatch_open"), "main route's console interaction opens the hatch so the route can pass through it")
	check(Session.get_objective() == Session.OBJECTIVE_POST_SC01, "console interaction sets the post-awakening objective")
	check(Session.state["checkpoint_id"] == "CP04", "console interaction commits CP04")

	# No chips anywhere in this area.
	check(Session.chips_found() == 0, "L01-A05 awards zero chips (got %d)" % Session.chips_found())

	# Every beat fired, in route order, each with a plausible elapsed time.
	for beat_id in EXPECTED_BEATS:
		check(result.beat_times.has(beat_id), "beat %s fires along the main route" % beat_id)
	var order_ok := true
	var prev_t := -1.0
	var seconds_report := ""
	for beat_id in EXPECTED_BEATS:
		var t: float = result.beat_times.get(beat_id, -1.0)
		seconds_report += "%s=%.2fs " % [beat_id, t]
		if t < prev_t:
			order_ok = false
		prev_t = t
	check(order_ok, "beats fire in route order (%s)" % seconds_report)
	print("[test_m3_a05] bot per-beat seconds (not pacing evidence): %s total=%.2fs" % [seconds_report, result.seconds])

	# Area-time report sanity (single area run).
	check(result.area_times.has("L01-A05"), "harness reports time spent in L01-A05")


func _test_area_population_matches_blueprint() -> void:
	Session.new_run()
	var area_scene: PackedScene = load(AREA)
	var area: AreaRoot = area_scene.instantiate()
	add_child(area)
	# Let AreaRoot._ready() and every child's _ready() run once.
	await physics_frames(2)

	check(area.get_enemy_ids().is_empty(), "L01-A05 has zero enemies (Night Guards/Staffers/Rovers) per 02-area-blueprints.md")

	var entity_ids := area.get_entity_ids()
	check(entity_ids.has("L01-SC01"), "the core node L01-SC01 is present")
	check(entity_ids.has("L01-UPG01"), "the workbench L01-UPG01 is present")
	# C51 (2026-10-08): the swap pad was taken out of Level 1 (it traded the Scrapjack for an
	# identical copy); it returns in Level 2 (level-design/swap-pad-for-level-2.md).
	check(area.find_child("WeaponPad", true, false) == null, "Level 1's depot has no weapon swap pad (C51)")

	# No chip/cache/capsule/evidence ids anywhere (main-route treasure = 0).
	for id in entity_ids:
		check(not id.begins_with("L01-A05-G") and not id.contains("CACHE") and not id.contains("HS"),
				"no chip/cache/capsule id leaks into L01-A05 (found %s)" % id)

	check(area.get_beat_ids() == EXPECTED_BEATS, "beat ids match 02-area-blueprints.md exactly (got %s)" % [area.get_beat_ids()])

	area.queue_free()
