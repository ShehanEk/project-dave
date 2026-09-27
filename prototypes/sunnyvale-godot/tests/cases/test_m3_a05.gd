extends TestCase
## M3 L01-A05 Maintenance depot: compact safe interior workshop with the
## level's single core_console (L01-SC01, CP04/awakening trigger), the
## maintenance bench (L01-UPG01) and weapon pad (L01-A05-PAD01) M3 stubs, a
## PracticeTarget for trials, and the emergency_hatch to A06. No enemies, no
## gems (per 02-area-blueprints.md). No optional branch — OPT01/OPT02 belong
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

	# Story/save contract (CoreConsole L01-SC01, the level's only console).
	check(Session.get_story("awakening_done"), "main route's console interaction sets awakening_done")
	check(Session.get_story("core_installed"), "main route's console interaction sets core_installed")
	check(Session.get_story("hatch_open"), "main route's console interaction opens the hatch so the route can pass through it")
	check(Session.get_objective() == "Reach the garden wicket.", "console interaction sets the post-awakening objective")
	check(Session.state["checkpoint_id"] == "CP04", "console interaction commits CP04")

	# No gems anywhere in this area.
	check(Session.gems_found() == 0, "L01-A05 awards zero gems (got %d)" % Session.gems_found())

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

	check(area.get_enemy_ids().is_empty(), "L01-A05 has zero enemies (Residents/Clippers) per 02-area-blueprints.md")

	var entity_ids := area.get_entity_ids()
	check(entity_ids.has("L01-SC01"), "the core console L01-SC01 is present")
	check(entity_ids.has("L01-UPG01"), "the maintenance bench L01-UPG01 is present")
	# WeaponPad is keyed by pad_id, not the shared entity_id export; check the
	# node directly instead of get_entity_ids().
	var pad := area.find_child("WeaponPad", true, false)
	check(pad != null and "pad_id" in pad and pad.pad_id == "L01-A05-PAD01",
			"the weapon pad L01-A05-PAD01 is present at its own stable spot")

	# No gem/cache/capsule/artifact ids anywhere (main-route treasure = 0).
	for id in entity_ids:
		check(not id.begins_with("L01-A05-G") and not id.contains("CACHE") and not id.contains("HS"),
				"no gem/cache/capsule id leaks into L01-A05 (found %s)" % id)

	check(area.get_beat_ids() == EXPECTED_BEATS, "beat ids match 02-area-blueprints.md exactly (got %s)" % [area.get_beat_ids()])

	# Spatial separation: pad kept >= 3H (288px) from the bench's and
	# console's interaction spots, per the area brief.
	var console := area.find_child("CoreConsole", true, false)
	var bench := area.find_child("MaintenanceBench", true, false)
	check(absf(pad.position.x - bench.position.x) >= 288.0,
			"weapon pad is >=3H from the bench (dx=%.1f)" % absf(pad.position.x - bench.position.x))
	check(absf(pad.position.x - console.position.x) >= 288.0,
			"weapon pad is >=3H from the console (dx=%.1f)" % absf(pad.position.x - console.position.x))

	area.queue_free()
