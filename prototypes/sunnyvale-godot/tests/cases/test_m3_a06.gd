extends TestCase
## M3 area L01-A06 "Alarm exit" (02-area-blueprints.md): the debug RouteBot
## must complete the main route from the A05->A06 entry seam to the service
## wicket / exit seam, and the area's structure (beats, encounter groups,
## enemy roster, entities, seam floors, the B03 pit hazard's safe foothold)
## must match the design doc exactly. No optional branches in this area.
## Run: cd prototypes/sunnyvale-godot && NOIMPORT=1 tools/test.sh m3_a06

const AREA_SCENE := "res://scenes/levels/areas/a06_exit.tscn"

const EXPECTED_BEATS: PackedStringArray = [
	"L01-A06-B01", "L01-A06-B02", "L01-A06-B03", "L01-A06-B04", "L01-A06-B05",
]
## Tree order: Encounters/EncounterGroup_E10 (Patrol Rover, Staffer), then
## EncounterGroup_E11 (Staffer, Patrol Rover) — matches the encounter
## registry row-by-row (L01-E10: 1 Rover + 1 Staffer; L01-E11: 1 Staffer +
## 1 Rover). Both Staffers are Linked workers who walk out of an annex door
## after the lockdown (C33).
const EXPECTED_ENEMIES: PackedStringArray = [
	"L01-E10-M01-01", "L01-E10-LK01-01", "L01-E11-LK01-01", "L01-E11-M01-01",
]
## 0 chips on the main route; the only Entities-container id is the HS03
## capsule (no cache/evidence/switch/station/workbench/pad in this area).
const EXPECTED_ENTITIES: PackedStringArray = [
	"L01-HS03",
]


func run() -> void:
	await _test_main_route_reaches_exit()
	await _test_structure_and_ids()


# --- 1. RouteBot: main route reaches the exit seam --------------------------

func _test_main_route_reaches_exit() -> void:
	Session.new_run()
	var harness = load("res://tests/area_harness.gd").new()
	var result: Dictionary = await harness.run_area(self, AREA_SCENE, [], 60.0)
	check(result.reached_exit,
			"A06 main route reaches the exit seam (failure=%s, pos=%s)"
			% [result.failure, result.hero_final_position])

	print("[test_m3_a06] main route total seconds=%.2f" % result.seconds)
	for beat_id in EXPECTED_BEATS:
		var t = result.beat_times.get(beat_id, null)
		print("[test_m3_a06] beat %s reached at t=%s" % [beat_id, ("%.2f" % t) if t != null else "NEVER"])
		check(result.beat_times.has(beat_id), "beat %s is reported by the route bot" % beat_id)
	check(result.beat_times.size() == EXPECTED_BEATS.size(),
			"exactly %d beats are reported, no extras (got %d: %s)"
			% [EXPECTED_BEATS.size(), result.beat_times.size(), result.beat_times])

	# No chips anywhere on the main route (02: "Main-route treasure: 0 chips").
	check(Session.get_wallet() == 0, "the main route collects zero chips (wallet=%d)" % Session.get_wallet())
	check(Session.chips_found() == 0, "the main route records zero chips found")


# --- 2. structure: beats, encounter groups, enemy roster, entities, seams ---

func _test_structure_and_ids() -> void:
	var area: AreaRoot = load(AREA_SCENE).instantiate()
	add_child(area)
	await physics_frames(2)

	var beat_ids := area.get_beat_ids()
	check(beat_ids == EXPECTED_BEATS, "beat ids match 02-area-blueprints.md exactly (got %s)" % [beat_ids])

	var enemy_ids := area.get_enemy_ids()
	check(enemy_ids == EXPECTED_ENEMIES, "enemy ids match the encounter registry exactly (got %s)" % [enemy_ids])

	var entity_ids := area.get_entity_ids()
	check(entity_ids == EXPECTED_ENTITIES,
			"entity ids match: 0 chips/caches/evidence/switches, 1 med-patch (got %s)" % [entity_ids])

	# Encounter groups: exact group_id and per-group enemy composition
	# (E10: 1 Rover + 1 Staffer; E11: 1 Staffer + 1 Rover, one-attacker rule).
	var encounters := area.get_node("Encounters")
	var group_e10: EncounterGroup = encounters.get_node("EncounterGroup_E10")
	var group_e11: EncounterGroup = encounters.get_node("EncounterGroup_E11")
	check(group_e10.group_id == "L01-E10", "E10 group_id is exactly L01-E10")
	check(group_e11.group_id == "L01-E11", "E11 group_id is exactly L01-E11")

	var e10_types := _enemy_types(group_e10)
	check(e10_types.size() == 2 and e10_types.count("Rover") == 1 and e10_types.count("Staffer") == 1,
			"E10 has exactly 1 Rover + 1 Staffer (got %s)" % [e10_types])

	var e11_types := _enemy_types(group_e11)
	check(e11_types.size() == 2 and e11_types.count("Staffer") == 1 and e11_types.count("Rover") == 1,
			"E11 has exactly 1 Staffer + 1 Rover (got %s)" % [e11_types])

	# Each Staffer is dormant in its own annex door until its group's
	# ApproachZone fires: it stands at the door's x, asleep (DORMANT).
	for pair in [[group_e10, "AnnexDoor_E10"], [group_e11, "AnnexDoor_E11"]]:
		var group: EncounterGroup = pair[0]
		var door: Node2D = area.get_node("Scenery/AnnexDoors/" + pair[1])
		var staffer: Brawler = null
		for child in group.get_children():
			if child is Brawler:
				staffer = child
		check(staffer != null, "%s has a Staffer to walk out of %s" % [group.group_id, pair[1]])
		if staffer != null:
			check(absf(area.to_local(staffer.global_position).x - area.to_local(door.global_position).x) < 1.0,
					"%s's Staffer stands in %s (x %.0f vs door x %.0f)" % [group.group_id, pair[1],
							area.to_local(staffer.global_position).x, area.to_local(door.global_position).x])
			check(staffer.tuning.dormant_until_active and staffer.state == Brawler.State.DORMANT,
					"%s's Staffer is dormant while its encounter is inactive (state %d)" % [group.group_id, staffer.state])

	# Both groups have an ApproachZone (visible-approach activation, per
	# CONVENTIONS.md: "no enemy attack begins ... from an unpreviewed region").
	check(group_e10.has_node("ApproachZone") and not group_e10.is_active,
			"E10 starts inactive behind its ApproachZone")
	check(group_e11.has_node("ApproachZone") and not group_e11.is_active,
			"E11 starts inactive behind its ApproachZone")

	# Rover backstops: a solid BACKSTOP block sits in each Rover's lane.
	var backstop_e10 := area.get_node("Geometry/BackstopE10")
	var backstop_e11 := area.get_node("Geometry/BackstopE11")
	check(backstop_e10.kind == 4, "BackstopE10 uses the BACKSTOP block kind")
	check(backstop_e11.kind == 4, "BackstopE11 uses the BACKSTOP block kind")
	var backstop_e10_center: Vector2 = area.to_local(backstop_e10.global_position) + backstop_e10.size * 0.5
	var backstop_e11_center: Vector2 = area.to_local(backstop_e11.global_position) + backstop_e11.size * 0.5
	check(group_e10.lane_rect.has_point(backstop_e10_center), "E10's backstop sits inside its own lane_rect")
	check(group_e11.lane_rect.has_point(backstop_e11_center), "E11's backstop sits inside its own lane_rect")

	# B03 pit hazard: its Reset foothold sits exactly on PlatformA's surface
	# (fixed, safe, no enemies anywhere near B03) rather than in mid-air or
	# buried in solid geometry.
	var platform_a := area.get_node("Geometry/PlatformA")
	var pit := area.get_node("Entities/PitHazard_B03")
	var reset_marker: Marker2D = pit.get_node("Reset")
	var reset_local: Vector2 = area.to_local(reset_marker.global_position)
	check(is_equal_approx(reset_local.y, platform_a.position.y),
			"pit hazard Reset foothold sits exactly on PlatformA's surface (y=%.1f, want %.1f)"
			% [reset_local.y, platform_a.position.y])
	check(reset_local.x >= platform_a.position.x and reset_local.x <= platform_a.position.x + platform_a.size.x,
			"pit hazard Reset foothold x (%.1f) is within PlatformA's span [%.1f, %.1f]"
			% [reset_local.x, platform_a.position.x, platform_a.position.x + platform_a.size.x])

	# Seam contract: >=384px flat floor at y=0 at both the entry and exit seams.
	check(area.has_floor_at(50.0) and area.has_floor_at(380.0),
			"entry seam has solid floor at y=0 across its required 384px span")
	check(area.has_floor_at(area.width - 50.0) and area.has_floor_at(area.width - 380.0),
			"exit seam has solid floor at y=0 across its required 384px span")

	# The service wicket exists and sits near width-300, per 02.
	var wicket := area.get_node("Entities/ExitWicket")
	check(absf(area.to_local(wicket.global_position).x - (area.width - 300.0)) < 1.0,
			"exit wicket sits at x ~= width-300 (got %.1f)" % area.to_local(wicket.global_position).x)

	# AD-12/AD-17 regression (m7-tscn-comment-swallows-next-node): a `##`
	# doc-comment placed on the line right after a `[node ...]` header
	# silently ate the FIRST following sibling's entire node declaration on
	# load (Godot's text-scene parser, not a script bug) — Lamps was
	# missing Lamp1, GardenVisuals was missing Fence1, and LockdownVisuals
	# was missing Rail1, all silently (no load error). Fixed by moving/
	# removing those comments; this guards against it coming back.
	check(area.get_node("Scenery/Lamps").get_child_count() == 3,
			"Scenery/Lamps keeps all 3 lamps (Lamp1/LampPlatformB/LampWicket)")
	check(area.get_node("Scenery/GardenVisuals").get_child_count() == 3,
			"Scenery/GardenVisuals keeps all 3 pre-awakening fences")
	check(area.get_node("Scenery/LockdownVisuals").get_child_count() == 9,
			"Scenery/LockdownVisuals keeps all 9 post-awakening props")
	check(area.get_node("Scenery/Lamps").has_node("Lamp1"), "Lamp1 specifically exists (was the swallowed node)")
	check(area.get_node("Scenery/GardenVisuals").has_node("Fence1"), "Fence1 specifically exists (was the swallowed node)")
	check(area.get_node("Scenery/LockdownVisuals").has_node("Rail1"), "Rail1 specifically exists (was the swallowed node)")

	area.queue_free()
	await physics_frames(2)


## "Rover", "Staffer" or "Night Guard" for every enemy directly under `group`
## (the Staffer and the Night Guard are both Brawlers; the scene tells them
## apart).
func _enemy_types(group: Node) -> Array:
	var types: Array = []
	for child in group.get_children():
		if child is PatrolRover:
			types.append("Rover")
		elif child is Brawler:
			types.append("Staffer" if child.scene_file_path == "res://scenes/actors/staffer.tscn" else "Night Guard")
	return types
