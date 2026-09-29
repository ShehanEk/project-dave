extends TestCase
## M3 A04 "Neighborhood square" (per 02-area-blueprints.md L01-A04 and
## CONVENTIONS.md "Areas and route bot"). No optional branch in this area —
## all A04 treasure sits on the main route (02: "Reward positions remain
## reachable if enemies are bypassed"). Proves the main route reaches the
## exit seam, every beat/entity/enemy id matches 02 exactly, and reports the
## bot's per-beat timing (NOT pacing evidence, just for the record).

const AREA := "res://scenes/levels/areas/a04_square.tscn"

const EXPECTED_BEATS := [
	"L01-A04-B01", "L01-A04-B02", "L01-A04-B03", "L01-A04-B04",
	"L01-A04-B05", "L01-A04-B06", "L01-A04-B07",
]
const EXPECTED_GROUP_IDS := ["L01-E07", "L01-E08", "L01-E09"]
const EXPECTED_ENEMY_IDS := [
	"L01-E07-SE01-01", "L01-E07-M01-01",
	"L01-E08-SE01-01", "L01-E08-SE01-02",
	"L01-E09-SE01-01", "L01-E09-M01-01",
]
const EXPECTED_CHIP_IDS := [
	"L01-A04-G001", "L01-A04-G002", "L01-A04-G003", "L01-A04-G004",
	"L01-A04-G005", "L01-A04-G006", "L01-A04-G007", "L01-A04-G008",
	"L01-A04-GC01", "L01-A04-G009", "L01-A04-G010", "L01-A04-GC02",
]
const EXPECTED_CHIP_TOTAL_VALUE := 20  # 10 small (1 each) + 2 clusters (5 each)


func run() -> void:
	await _test_main_route_reaches_exit_and_ids_match()
	await _test_switch_and_recovery_station_persist()


func _test_main_route_reaches_exit_and_ids_match() -> void:
	Session.new_run()
	var harness = load("res://tests/area_harness.gd").new()

	var area_scene: PackedScene = load(AREA)
	var probe: AreaRoot = area_scene.instantiate()
	add_child(probe)
	await physics_frames(2)

	var beat_ids := probe.get_beat_ids()
	check(beat_ids.size() == EXPECTED_BEATS.size(),
			"A04 has exactly %d beats (got %d: %s)" % [EXPECTED_BEATS.size(), beat_ids.size(), beat_ids])
	for i in EXPECTED_BEATS.size():
		if i < beat_ids.size():
			check(beat_ids[i] == EXPECTED_BEATS[i],
					"beat %d id is %s (got %s)" % [i, EXPECTED_BEATS[i], beat_ids[i]])

	var enemy_ids := probe.get_enemy_ids()
	check(enemy_ids.size() == EXPECTED_ENEMY_IDS.size(),
			"A04 has exactly %d enemies (got %d: %s)" % [EXPECTED_ENEMY_IDS.size(), enemy_ids.size(), enemy_ids])
	for id in EXPECTED_ENEMY_IDS:
		check(enemy_ids.has(id), "enemy id %s present" % id)
	var guard_count := 0
	var rover_count := 0
	for id in enemy_ids:
		if id.contains("-SE01-"):
			guard_count += 1
		elif id.contains("-M01-"):
			rover_count += 1
	check(guard_count == 4, "A04 population: 4 Night Guards (got %d)" % guard_count)
	check(rover_count == 2, "A04 population: 2 Patrol Rovers (got %d)" % rover_count)

	var group_ids: Array = []
	var encounters := probe.get_node("Encounters")
	for child in encounters.get_children():
		if "group_id" in child:
			group_ids.append(child.group_id)
	check(group_ids.size() == EXPECTED_GROUP_IDS.size() and group_ids.has("L01-E07")
			and group_ids.has("L01-E08") and group_ids.has("L01-E09"),
			"encounter groups are exactly L01-E07/E08/E09 (got %s)" % [group_ids])

	var entity_ids := probe.get_entity_ids()
	for id in EXPECTED_CHIP_IDS:
		check(entity_ids.has(id), "chip/cluster id %s present" % id)
	check(entity_ids.has("L01-HS02"), "med-patch L01-HS02 present")

	check(probe.has_floor_at(50.0), "seam contract: solid floor near local x=50 (entry seam)")
	check(probe.has_floor_at(probe.width - 50.0), "seam contract: solid floor near local x=width-50 (exit seam)")

	probe.queue_free()
	await physics_frames(2)

	var result: Dictionary = await harness.run_area(self, AREA, [], 90.0)
	check(result.reached_exit, "A04 main route reaches the exit seam (failure=%s, pos=%s)" % [result.failure, result.hero_final_position])

	for id in EXPECTED_CHIP_IDS:
		check(Session.is_collected(id), "main route collects %s" % id)
	check(Session.get_wallet() == EXPECTED_CHIP_TOTAL_VALUE,
			"main route collects exactly %d chip value (got %d)" % [EXPECTED_CHIP_TOTAL_VALUE, Session.get_wallet()])
	check(Session.get_switch("L01-SW01"), "main route pulls SW01 and extends the service walkway")
	check(Session.state.get("checkpoint_id", "") == "CP03", "main route commits CP03 at the recovery station")

	print("[test_m3_a04] main route seconds=%.2f" % result.seconds)
	print("[test_m3_a04] beat_times=%s" % [result.beat_times])
	for beat_id in EXPECTED_BEATS:
		check(result.beat_times.has(beat_id), "beat %s reported an elapsed time" % beat_id)


func _test_switch_and_recovery_station_persist() -> void:
	# Re-affirms CONVENTIONS.md contracts using a fresh instance (independent
	# of the harness run above): the walkway never retracts once extended.
	Session.new_run()
	Session.set_switch("L01-SW01", true)
	var area_scene: PackedScene = load(AREA)
	var probe: AreaRoot = area_scene.instantiate()
	add_child(probe)
	await physics_frames(2)
	var walkway := probe.get_node("Geometry/Walkway")
	check(walkway.is_extended(), "a fresh A04 instance reads the SW01 switch on _ready and starts extended")
	probe.queue_free()
	await physics_frames(2)
