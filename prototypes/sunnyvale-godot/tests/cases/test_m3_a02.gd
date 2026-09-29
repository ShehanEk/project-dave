extends TestCase
## M3 L01-A02 "Front gardens" (02-area-blueprints.md): 2 Staffers + 2
## Clippers across B01/B02/B04/B05, a garden-wall jump trail at B03 with the
## OPT01 loft branch (Lockout Notice evidence), a med-patch shelf before E04,
## and CP01 on the final porch (B06). See CONVENTIONS.md "Areas and route
## bot" for the harness/RouteBot contract.

const AREA_SCENE := "res://scenes/levels/areas/a02_gardens.tscn"


func run() -> void:
	await _test_static_population_matches_blueprint()
	await _test_main_route_reaches_exit()
	await _test_opt01_branch_reaches_exit_and_collects_evidence()


# --- 1. static population/ids match 02-area-blueprints.md exactly ----------

func _test_static_population_matches_blueprint() -> void:
	var area: AreaRoot = load(AREA_SCENE).instantiate()
	add_child(area)
	await physics_frames(2)

	var beat_ids := area.get_beat_ids()
	check(beat_ids == PackedStringArray([
		"L01-A02-B01", "L01-A02-B02", "L01-A02-B03",
		"L01-A02-B04", "L01-A02-B05", "L01-A02-B06",
	]), "exactly the 6 beats B01-B06, in route order (got %s)" % [beat_ids])

	var enemy_ids := area.get_enemy_ids()
	check(enemy_ids == PackedStringArray([
		"L01-E01-CY01-01", "L01-E02-R01-01", "L01-E03-CY01-01", "L01-E04-R01-01",
	]), "exactly the 4 enemies (2 Staffer + 2 Clipper), in route order (got %s)" % [enemy_ids])

	var group_ids: PackedStringArray = []
	for group in _find_encounter_groups(area):
		group_ids.append(group.group_id)
	check(group_ids == PackedStringArray(["L01-E01", "L01-E02", "L01-E03", "L01-E04"]),
			"exactly 4 encounter groups E01-E04, in route order (got %s)" % [group_ids])

	var staffer_count := 0
	var clipper_count := 0
	for group in _find_encounter_groups(area):
		for child in group.get_children():
			if child is Staffer:
				staffer_count += 1
			elif child is Clipper:
				clipper_count += 1
	check(staffer_count == 2, "2 Staffer instances total (got %d)" % staffer_count)
	check(clipper_count == 2, "2 Clipper instances total (got %d)" % clipper_count)
	for group in _find_encounter_groups(area):
		var enemies_in_group := 0
		for child in group.get_children():
			if child is Staffer or child is Clipper:
				enemies_in_group += 1
		check(enemies_in_group == 1, "encounter group %s has exactly 1 enemy (got %d)" % [group.group_id, enemies_in_group])

	var entity_ids := area.get_entity_ids()
	var expected_chips := ["L01-A02-G001", "L01-A02-G002", "L01-A02-G003", "L01-A02-G004", "L01-A02-G005"]
	for id in expected_chips:
		check(entity_ids.has(id), "loose chip %s is present" % id)
	check(entity_ids.has("L01-A02-GC01"), "chip cluster L01-A02-GC01 is present")
	check(entity_ids.has("L01-HS01"), "med-patch L01-HS01 is present")
	check(entity_ids.has("L01-OPT01-A01"), "evidence pickup L01-OPT01-A01 is present")

	var wallet_value := 0
	for chip in _find_chips(area):
		wallet_value += chip.value
	check(wallet_value == 10, "total main-route chip value is exactly 10 (5 small + 1 cluster of 5, got %d)" % wallet_value)

	var station := _find_recovery_station(area)
	check(station != null and station.checkpoint_id == "CP01", "recovery station CP01 is present on the final porch")

	var evidence := area.get_node("Entities/EvidencePickup_A01") as EvidencePickup
	check(evidence.evidence_id == "EF01", "the OPT01 evidence records as EF01")

	check(area.has_floor_at(4.0), "entry seam has solid floor at local x~0")
	check(area.has_floor_at(area.width - 4.0), "exit seam has solid floor at local x~width")

	area.queue_free()
	await physics_frames(1)


func _find_encounter_groups(area: AreaRoot) -> Array:
	var found: Array = []
	var encounters := area.get_node_or_null("Encounters")
	if encounters:
		for child in encounters.get_children():
			if child is EncounterGroup:
				found.append(child)
	return found


func _find_chips(area: AreaRoot) -> Array:
	var found: Array = []
	var entities := area.get_node_or_null("Entities")
	if entities:
		for child in entities.get_children():
			if child is Chip:
				found.append(child)
	return found


func _find_recovery_station(area: AreaRoot) -> RecoveryStation:
	var entities := area.get_node_or_null("Entities")
	if entities:
		for child in entities.get_children():
			if child is RecoveryStation:
				return child
	return null


# --- 2. main route reaches the exit, collects the main-route treasure ------

func _test_main_route_reaches_exit() -> void:
	Session.new_run()
	var harness = load("res://tests/area_harness.gd").new()
	var result: Dictionary = await harness.run_area(self, AREA_SCENE, [], 60.0)
	check(result.reached_exit,
			"A02 main route reaches the exit seam (failure=%s, pos=%s)" % [result.failure, result.hero_final_position])

	for id in ["L01-A02-G001", "L01-A02-G002", "L01-A02-G003", "L01-A02-G004", "L01-A02-G005", "L01-A02-GC01"]:
		check(Session.is_collected(id), "main route collects %s by ordinary movement" % id)
	check(Session.get_wallet() == 10, "main route collects exactly 10 chip value (got %d)" % Session.get_wallet())
	check(Session.state.get("checkpoint_id", "") == "CP01", "main route interacts with CP01 and commits it")
	check(not Session.has_evidence("EF01"), "the OPT01 evidence is untouched when that branch is disabled")
	check(not Session.is_collected("L01-HS01"), "HS01 stays uncollected on a full-health main run (off the main line)")

	for beat_id in ["L01-A02-B01", "L01-A02-B02", "L01-A02-B03", "L01-A02-B04", "L01-A02-B05", "L01-A02-B06"]:
		check(result.beat_times.has(beat_id), "beat %s reports an elapsed time (got %s)" % [beat_id, result.beat_times])

	print("[test_m3_a02] main route: %.2fs total" % result.seconds)
	var ordered_beats := ["L01-A02-B01", "L01-A02-B02", "L01-A02-B03", "L01-A02-B04", "L01-A02-B05", "L01-A02-B06"]
	var prev_t := 0.0
	for beat_id in ordered_beats:
		var t: float = result.beat_times.get(beat_id, -1.0)
		print("[test_m3_a02]   %s reached at %.2fs (+%.2fs)" % [beat_id, t, t - prev_t])
		prev_t = t
	print("[test_m3_a02]   exit reached at %.2fs (+%.2fs)" % [result.seconds, result.seconds - prev_t])


# --- 3. OPT01 branch also reaches the exit and records the Lockout Notice -----

func _test_opt01_branch_reaches_exit_and_collects_evidence() -> void:
	Session.new_run()
	var harness = load("res://tests/area_harness.gd").new()
	var result: Dictionary = await harness.run_area(self, AREA_SCENE, ["OPT01"], 60.0)
	check(result.reached_exit,
			"A02 main route + OPT01 branch reach the exit seam (failure=%s, pos=%s)" % [result.failure, result.hero_final_position])
	check(Session.has_evidence("EF01"), "the OPT01 branch records the Lockout Notice evidence")
	check(Session.is_collected("L01-OPT01-A01"), "the evidence pickup's own entity_id is marked collected")
	check(Session.get_wallet() == 10, "the evidence adds zero chips on top of the main route's 10 (got %d)" % Session.get_wallet())

	print("[test_m3_a02] OPT01 branch: %.2fs total (main route: %.2fs above)" % [result.seconds, result.seconds])
