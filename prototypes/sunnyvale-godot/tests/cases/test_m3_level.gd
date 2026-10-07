extends TestCase
## M3 level assembly: level_01.tscn (LevelDirector) end to end, across all
## six areas. Counts below are the M3 slice of prototype-spec.json (areas[],
## encounters[], economy, checkpoints) — kept as constants here since
## prototype-plans/ lives outside this Godot project's res:// root.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"

const EXPECTED_AREA_IDS: Array[String] = [
	"L01-A01", "L01-A02", "L01-A03", "L01-A04", "L01-A05", "L01-A06",
]
const BEATS_PER_AREA: Array[int] = [4, 6, 5, 7, 5, 5]  # -> 32 total
## Night Guards (SE01) and Staffers (LK01) are both Brawlers; the two are told
## apart by their scene. Rovers are the M01 Patrol Rover (the old Clipper).
const NIGHT_GUARD_SCENE := "res://scenes/actors/night_guard.tscn"
const STAFFER_SCENE := "res://scenes/actors/staffer.tscn"
## C41 (the fun pass): 15 EncounterGroups (E01..E16 minus E12, which does not
## exist) fielding 29 enemies — 12 Night Guards, 9 Staffers, 8 Patrol Rovers.
const EXPECTED_ENCOUNTERS := {
	"L01-E01": {"guards": 1, "staffers": 0, "rovers": 0},
	"L01-E02": {"guards": 0, "staffers": 0, "rovers": 1},
	"L01-E03": {"guards": 1, "staffers": 0, "rovers": 0},
	"L01-E04": {"guards": 0, "staffers": 0, "rovers": 1},
	"L01-E05": {"guards": 1, "staffers": 0, "rovers": 1},
	"L01-E06": {"guards": 2, "staffers": 0, "rovers": 0},
	"L01-E07": {"guards": 1, "staffers": 0, "rovers": 1},
	"L01-E08": {"guards": 2, "staffers": 0, "rovers": 1},
	"L01-E09": {"guards": 2, "staffers": 0, "rovers": 1},
	"L01-E10": {"guards": 0, "staffers": 2, "rovers": 1},
	"L01-E11": {"guards": 1, "staffers": 1, "rovers": 1},
	"L01-E13": {"guards": 0, "staffers": 2, "rovers": 0},
	"L01-E14": {"guards": 1, "staffers": 0, "rovers": 0},
	"L01-E15": {"guards": 0, "staffers": 2, "rovers": 0},
	"L01-E16": {"guards": 0, "staffers": 2, "rovers": 0},
}
const EXPECTED_GROUP_COUNT := 15
const EXPECTED_GUARDS_TOTAL := 12
const EXPECTED_STAFFERS_TOTAL := 9
const EXPECTED_ROVERS_TOTAL := 8
const EXPECTED_MAIN_CHIP_VALUE := 45
const EXPECTED_CACHE_VALUE := 20
## Spawn/respawn markers commonly sit a few px above their floor by design
## (e.g. A01's Spawn_CP00 is 4px above the floor); a few physics ticks of
## ordinary gravity settle the hero onto the floor before a check runs, so
## position checks against a marker allow this much drift rather than an
## exact match.
const SPAWN_POSITION_TOLERANCE_PX := 12.0


func run() -> void:
	await _test_instantiates_and_seams()
	await _test_population_counts()
	await _test_full_main_route()
	await _test_optional_branches()
	await _test_death_rebuild()
	await _test_extra_checkpoints()


# --- (a) instantiation + seams ------------------------------------------------

func _test_instantiates_and_seams() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	check(is_instance_valid(level), "level_01 instantiates without error")
	check(level.areas.size() == 6, "level has exactly 6 areas (got %d)" % level.areas.size())
	for i in level.areas.size():
		check(level.areas[i].area_id == EXPECTED_AREA_IDS[i],
				"area %d id is %s (got %s)" % [i, EXPECTED_AREA_IDS[i], level.areas[i].area_id])

	var expected_width := 0.0
	for area in level.areas:
		expected_width += area.width
	check(is_equal_approx(level.level_width, expected_width),
			"level_width is the sum of every area's width (got %.1f want %.1f)" % [level.level_width, expected_width])

	for i in level.areas.size() - 1:
		var a: AreaRoot = level.areas[i]
		var b: AreaRoot = level.areas[i + 1]
		check(a.has_floor_at(a.width - 10.0),
				"%s has solid floor at its own exit seam" % a.area_id)
		check(b.has_floor_at(10.0),
				"%s has solid floor at its own entry seam" % b.area_id)
		check(is_equal_approx(b.global_position.x, a.global_position.x + a.width),
				"%s starts exactly where %s ends (no gap/overlap)" % [b.area_id, a.area_id])

	check(is_instance_valid(level.hero), "level spawns a Hero")
	check(is_instance_valid(level.camera), "level spawns a GameCamera")
	var spawn := level.areas[0].get_marker("Spawn_CP00")
	check(spawn != null and level.hero.global_position.distance_to(spawn.global_position) < SPAWN_POSITION_TOLERANCE_PX,
			"hero starts at A01's Spawn_CP00 on a new run")

	level.queue_free()
	await physics_frames(2)


# --- (b) count checks ---------------------------------------------------------

func _test_population_counts() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	# 32 beat ids, in exact order.
	var expected_beats: PackedStringArray = []
	for i in EXPECTED_AREA_IDS.size():
		for b in range(1, BEATS_PER_AREA[i] + 1):
			expected_beats.append("%s-B%02d" % [EXPECTED_AREA_IDS[i], b])
	check(expected_beats.size() == 32, "sanity: expected beat list itself totals 32")

	var actual_beats: PackedStringArray = []
	for area in level.areas:
		actual_beats.append_array(area.get_beat_ids())
	check(actual_beats.size() == 32, "level has exactly 32 BeatZones (got %d)" % actual_beats.size())
	check(actual_beats == expected_beats,
			"beat ids match exactly, in area/route order\n  got:  %s\n  want: %s" % [actual_beats, expected_beats])

	# 15 EncounterGroups with exact Night Guard/Staffer/Rover counts.
	var groups := {}
	for area in level.areas:
		_collect_encounter_groups(area.get_node_or_null("Encounters"), groups)
	check(groups.size() == EXPECTED_GROUP_COUNT,
			"level has exactly %d EncounterGroups (got %d: %s)" % [EXPECTED_GROUP_COUNT, groups.size(), groups.keys()])
	var guards_total := 0
	var staffers_total := 0
	var rovers_total := 0
	for group_id in EXPECTED_ENCOUNTERS:
		check(groups.has(group_id), "encounter %s is present" % group_id)
		if groups.has(group_id):
			var got: Dictionary = groups[group_id]
			var want: Dictionary = EXPECTED_ENCOUNTERS[group_id]
			check(got.guards == want.guards and got.staffers == want.staffers and got.rovers == want.rovers,
					"%s has %d guard(s)/%d staffer(s)/%d rover(s) (got %d/%d/%d)"
					% [group_id, want.guards, want.staffers, want.rovers, got.guards, got.staffers, got.rovers])
			guards_total += got.guards
			staffers_total += got.staffers
			rovers_total += got.rovers
	check(guards_total == EXPECTED_GUARDS_TOTAL,
			"total Night Guards across the level is %d (got %d)" % [EXPECTED_GUARDS_TOTAL, guards_total])
	check(staffers_total == EXPECTED_STAFFERS_TOTAL,
			"total Staffers across the level is %d (got %d)" % [EXPECTED_STAFFERS_TOTAL, staffers_total])
	check(rovers_total == EXPECTED_ROVERS_TOTAL,
			"total Patrol Rovers across the level is %d (got %d)" % [EXPECTED_ROVERS_TOTAL, rovers_total])

	# Chip economy: 45 main-route + 20 cache = 65.
	var values := {"main": 0, "cache": 0}
	for area in level.areas:
		_collect_chip_values(area.get_node_or_null("Entities"), values)
	check(int(values["main"]) == EXPECTED_MAIN_CHIP_VALUE,
			"main-route chip value totals %d (got %d)" % [EXPECTED_MAIN_CHIP_VALUE, int(values["main"])])
	check(int(values["cache"]) == EXPECTED_CACHE_VALUE,
			"optional cache value totals %d (got %d)" % [EXPECTED_CACHE_VALUE, int(values["cache"])])
	check(int(values["main"]) + int(values["cache"]) == 65,
			"total chip value across the level is 65 (got %d)" % [int(values["main"]) + int(values["cache"])])

	# Entity ids: no duplicates anywhere, and every named singleton is present.
	var all_ids: PackedStringArray = []
	for area in level.areas:
		all_ids.append_array(area.get_entity_ids())
	var seen := {}
	var duplicates: PackedStringArray = []
	for id in all_ids:
		if seen.has(id):
			duplicates.append(id)
		seen[id] = true
	check(duplicates.is_empty(), "no duplicate entity ids anywhere in the level (dupes: %s)" % [duplicates])

	for required in ["L01-OPT01-A01", "L01-HS01", "L01-HS02", "L01-HS03", "L01-SC01", "L01-UPG01"]:
		check(required in all_ids, "entity id %s is present exactly once" % required)

	var all_enemy_ids: PackedStringArray = []
	for area in level.areas:
		all_enemy_ids.append_array(area.get_enemy_ids())
	var enemy_seen := {}
	var enemy_dupes: PackedStringArray = []
	for id in all_enemy_ids:
		if enemy_seen.has(id):
			enemy_dupes.append(id)
		enemy_seen[id] = true
	check(enemy_dupes.is_empty(), "no duplicate enemy ids anywhere in the level (dupes: %s)" % [enemy_dupes])
	var expected_enemy_total := EXPECTED_GUARDS_TOTAL + EXPECTED_STAFFERS_TOTAL + EXPECTED_ROVERS_TOTAL
	check(all_enemy_ids.size() == expected_enemy_total,
			"enemy id count matches the Night Guard+Staffer+Rover total (got %d, want %d)"
			% [all_enemy_ids.size(), expected_enemy_total])

	# Stations / console / workbench / pad / switch+walkway / wicket (by node
	# type, since several of these deliberately leave entity_id empty).
	var stations := {}
	var pads := {}
	var switches := {}
	var walkways := {}
	var wickets := 0
	for area in level.areas:
		_collect_typed(area, stations, pads, switches, walkways)
		wickets += _count_in_group(area, "exit_wicket")
	check(stations.size() == 5 and stations.has("CP01") and stations.has("CP02") and stations.has("CP03")
			and stations.has("CP06") and stations.has("CP07"),
			"recovery stations CP01, CP02, CP03, CP06, CP07 are each present exactly once (got %s)" % [stations.keys()])
	check(pads.has("L01-A05-PAD01"), "weapon pad L01-A05-PAD01 is present")
	check(Session.weapon_on_pad("L01-A05-PAD01") == "L01-W01-P02",
			"L01-A05-PAD01 holds the resting weapon L01-W01-P02 (Session)")
	check(switches.has("L01-SW01"), "route switch L01-SW01 is present")
	check(walkways.has("L01-SW01"), "a service walkway matching switch L01-SW01 is present")
	check(wickets == 1, "exactly one exit wicket in the level (got %d)" % wickets)

	level.queue_free()
	await physics_frames(2)


func _collect_encounter_groups(node: Node, groups: Dictionary) -> void:
	if node == null:
		return
	for child in node.get_children():
		if child is EncounterGroup:
			var group := child as EncounterGroup
			var guards := 0
			var staffers := 0
			var rovers := 0
			for enemy in group.get_children():
				if enemy is Brawler:
					if enemy.scene_file_path == NIGHT_GUARD_SCENE:
						guards += 1
					elif enemy.scene_file_path == STAFFER_SCENE:
						staffers += 1
				elif enemy is PatrolRover:
					rovers += 1
			groups[group.group_id] = {"guards": guards, "staffers": staffers, "rovers": rovers}
		_collect_encounter_groups(child, groups)


func _collect_chip_values(node: Node, values: Dictionary) -> void:
	if node == null:
		return
	for child in node.get_children():
		if ("value" in child) and ("entity_id" in child) and String(child.get("entity_id")) != "":
			var v := int(child.get("value"))
			var id := String(child.get("entity_id"))
			var key := "cache" if id.begins_with("L01-OPT") else "main"
			values[key] = int(values.get(key, 0)) + v
		_collect_chip_values(child, values)


func _collect_typed(node: Node, stations: Dictionary, pads: Dictionary, switches: Dictionary, walkways: Dictionary) -> void:
	if node is RecoveryStation:
		stations[(node as RecoveryStation).checkpoint_id] = true
	elif node is WeaponPad:
		pads[(node as WeaponPad).pad_id] = true
	elif node is RouteSwitch:
		switches[(node as RouteSwitch).switch_id] = true
	elif node is ServiceWalkway:
		walkways[(node as ServiceWalkway).switch_id] = true
	for child in node.get_children():
		_collect_typed(child, stations, pads, switches, walkways)


func _count_in_group(node: Node, group: StringName) -> int:
	var total := 0
	if node.is_in_group(group):
		total += 1
	for child in node.get_children():
		total += _count_in_group(child, group)
	return total


# --- (c) full main route -------------------------------------------------------

func _test_full_main_route() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	# The RouteBot never dodges; keep combat from killing it mid-route (the
	# per-area harness does the same) so a real hit can't tear down the
	# level's Areas out from under the bot's own area/point references.
	level.hero.debug_invulnerable = true

	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(level, [])
	bot.start(level.hero)

	var timeout_s := 150.0
	var max_ticks := int(timeout_s * Engine.physics_ticks_per_second)
	var ticks := 0
	while bot.running and ticks < max_ticks:
		await get_tree().physics_frame
		ticks += 1
	if bot.running:
		bot.failure_message = "test timeout after %.1fs" % timeout_s
		bot.running = false

	var report := bot.get_report()
	print("[test_m3_level] MAIN ROUTE bot seconds total=%.2f (bot traversal time, not pacing evidence)" % report["seconds"])
	for area_id in EXPECTED_AREA_IDS:
		if report["area_times"].has(area_id):
			print("[test_m3_level]   %s bot seconds=%.2f" % [area_id, report["area_times"][area_id]])
	for beat_id in report["beat_times"]:
		print("[test_m3_level]   beat %s reached at t=%.2fs" % [beat_id, report["beat_times"][beat_id]])

	check(bot.success, "RouteBot completes the full main route across all 6 areas (failure=%s)" % report["failure"])
	check(level.level_ended_flag, "the exit wicket signalled level_ended by the end of the main route")
	check(report["beat_times"].size() == 32, "all 32 beats were reached during the main route (got %d)" % report["beat_times"].size())

	bot.queue_free()
	level.queue_free()
	await physics_frames(2)


# --- (d) optional branches rejoin ----------------------------------------------

func _test_optional_branches() -> void:
	await _run_branch_to_completion("OPT01")
	await _run_branch_to_completion("OPT02")


func _run_branch_to_completion(branch_id: String) -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	level.hero.debug_invulnerable = true

	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(level, [branch_id])
	bot.start(level.hero)

	var timeout_s := 160.0
	var max_ticks := int(timeout_s * Engine.physics_ticks_per_second)
	var ticks := 0
	while bot.running and ticks < max_ticks:
		await get_tree().physics_frame
		ticks += 1
	if bot.running:
		bot.failure_message = "test timeout after %.1fs" % timeout_s
		bot.running = false

	var report := bot.get_report()
	print("[test_m3_level] %s branch bot seconds total=%.2f (bot traversal time, not pacing evidence)" % [branch_id, report["seconds"]])
	check(bot.success, "%s branch completes and rejoins the main route to the exit (failure=%s)" % [branch_id, report["failure"]])
	check(level.level_ended_flag, "%s branch run still reaches the exit wicket" % branch_id)

	bot.queue_free()
	level.queue_free()
	await physics_frames(2)


# --- (e) death rebuild: rollback + respawn at the right checkpoint -------------

func _test_death_rebuild() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	var a02 := level.areas[1]
	var chip: Chip = a02.get_node("Entities/Chip_G001")
	var chip_id: String = chip.entity_id
	level.hero.global_position = chip.global_position
	await physics_frames(3)
	check(Session.is_collected(chip_id),
			"setup: hero walked onto a post-CP00 chip in A02 and collected it")

	level.hero.take_damage(999, level.hero.global_position)
	await physics_frames(4)

	check(Session.state["checkpoint_id"] == "CP00",
			"death before any station restores checkpoint_id to CP00 (got %s)" % Session.state["checkpoint_id"])
	check(not Session.is_collected(chip_id),
			"death before any station rolls back the post-CP00 chip pickup")
	var spawn00 := level.areas[0].get_marker("Spawn_CP00")
	check(level.hero.global_position.distance_to(spawn00.global_position) < SPAWN_POSITION_TOLERANCE_PX,
			"hero respawns at A01's Spawn_CP00 (got %s want %s)" % [level.hero.global_position, spawn00.global_position])
	check(level.hero.input_enabled, "hero input is re-enabled after the rebuild")
	check(is_instance_valid(level.areas[1].get_node("Entities/Chip_G001")),
			"the rebuilt A02 has a fresh, uncollected Chip_G001 (world state actually rebuilt, not just Session)")

	# Use CP01, then die again: should now return to CP01's Respawn. Wait out
	# the first hit's damage-immunity window first, or this second
	# take_damage call is simply refused (hero.gd: immune for
	# tuning.damage_immunity_time, 1.0s, after any hit).
	await seconds(1.2)
	var station: RecoveryStation = level.areas[1].get_node("Entities/RecoveryStation_CP01")
	station.interact(level.hero)
	await physics_frames(2)
	check(Session.state["checkpoint_id"] == "CP01", "setup: CP01 station committed")

	check(not level.hero.is_immune(), "sanity: immunity from the first hit has worn off before the second")
	level.hero.take_damage(999, level.hero.global_position)
	await physics_frames(4)

	check(Session.state["checkpoint_id"] == "CP01",
			"death after using CP01 keeps checkpoint_id at CP01 (got %s)" % Session.state["checkpoint_id"])
	var respawn01 := level.areas[1].get_marker("Respawn_CP01")
	check(level.hero.global_position.distance_to(respawn01.global_position) < SPAWN_POSITION_TOLERANCE_PX,
			"second death respawns the hero at A02's Respawn_CP01 (got %s want %s)" % [level.hero.global_position, respawn01.global_position])
	check(level.hero.input_enabled, "hero input is re-enabled after the second rebuild")

	level.queue_free()
	await physics_frames(2)


# --- (f) C41's extra stations: CP06 (A04) and CP07 (A06) ------------------------

func _test_extra_checkpoints() -> void:
	for pair in [["CP06", 3], ["CP07", 5]]:
		var cp: String = pair[0]
		Session.new_run()
		var level: LevelDirector = load(LEVEL_01).instantiate()
		add_child(level)
		await physics_frames(3)
		var area: AreaRoot = level.areas[pair[1]]
		var station: RecoveryStation = area.get_node("Entities/RecoveryStation_" + cp)
		station.interact(level.hero)
		await physics_frames(2)
		check(Session.state["checkpoint_id"] == cp, "using the %s station commits %s (got %s)" % [cp, cp, Session.state["checkpoint_id"]])
		check(CheckpointService.validate_snapshot(Session.state.duplicate(true)).ok,
				"a save at %s passes the checkpoint whitelist" % cp)

		level.hero.take_damage(999, level.hero.global_position)
		await physics_frames(4)
		check(Session.state["checkpoint_id"] == cp, "death after using %s keeps checkpoint_id at %s (got %s)" % [cp, cp, Session.state["checkpoint_id"]])
		# The death rebuilds every area, so look the area up again.
		area = level.areas[pair[1]]
		var respawn := area.get_marker("Respawn_" + cp)
		check(respawn != null and level.hero.global_position.distance_to(respawn.global_position) < SPAWN_POSITION_TOLERANCE_PX,
				"death after %s respawns the hero at %s's Respawn_%s (got %s want %s)" % [cp, area.area_id, cp,
						level.hero.global_position, respawn.global_position if respawn else Vector2.ZERO])
		check(level.hero.input_enabled, "hero input is re-enabled after the %s rebuild" % cp)
		level.queue_free()
		await physics_frames(2)
