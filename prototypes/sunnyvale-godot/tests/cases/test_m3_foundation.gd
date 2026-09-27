extends TestCase
## M3 foundation: AreaRoot + the shared entity scenes + the debug RouteBot/
## area_harness, proven against scenes/debug/sample_area.tscn (one AreaRoot
## exercising every M3 entity type, per CONVENTIONS.md "Areas and route
## bot"). Each of the six parallel area builders should write one test like
## this for their own area, e.g.:
##
##   extends TestCase
##   func run() -> void:
##       Session.new_run()
##       var harness := load("res://tests/area_harness.gd").new()
##       var result: Dictionary = await harness.run_area(
##               self, "res://scenes/levels/areas/a02_front_gardens.tscn",
##               ["OPT01"], 60.0)
##       check(result.reached_exit,
##               "A02 main route + OPT01 branch reach the exit (failure=%s)" % result.failure)
##
## `branches` is the list of optional RoutePoint.branch ids to enable (e.g.
## ["OPT01"]); pass [] to prove the main route alone.

const SAMPLE_AREA := "res://scenes/debug/sample_area.tscn"


func run() -> void:
	await _test_bot_completes_main_route_and_branch()
	await _test_gem_collects_once_and_respects_session()
	await _test_care_capsule_gating()
	await _test_recovery_station_heals_and_commits()
	await _test_walkway_extends_persists_never_retracts()
	await _test_pit_hazard_costs_health_and_resets()
	await _test_hatch_opens_from_story_flag()
	await _test_core_console_sets_flags_once()
	await _test_artifact_records_with_zero_gems()


# --- 1. full traversal: main route, then the OPT01 branch -------------------

func _test_bot_completes_main_route_and_branch() -> void:
	Session.new_run()
	var harness = load("res://tests/area_harness.gd").new()

	var r1: Dictionary = await harness.run_area(self, SAMPLE_AREA, [], 30.0)
	check(r1.reached_exit, "sample area: main route reaches the exit (failure=%s, pos=%s)" % [r1.failure, r1.hero_final_position])
	check(Session.is_collected("L01-TEST-G001"), "main route collects the loose gem")
	check(Session.is_collected("L01-TEST-GC01"), "main route collects the gem cluster")
	check(Session.get_switch("L01-SW01"), "main route pulls the route switch")
	check(Session.get_story("awakening_done"), "main route's console interaction sets awakening_done")
	check(Session.get_story("hatch_open"), "console interaction opens the hatch so the route can pass through it")
	check(not Session.is_collected("L01-TEST-CACHE01"), "the OPT01 cache is untouched when that branch is disabled")
	check(not Session.has_artifact("A01"), "the OPT01 artifact is untouched when that branch is disabled")
	check(r1.beat_times.has("L01-TEST-B01") and r1.beat_times.has("L01-TEST-B02"),
			"both beat zones report an elapsed time (got %s)" % [r1.beat_times])

	var wallet_after_main: int = Session.get_wallet()

	var r2: Dictionary = await harness.run_area(self, SAMPLE_AREA, ["OPT01"], 30.0)
	check(r2.reached_exit, "sample area: OPT01 branch route also reaches the exit (failure=%s, pos=%s)" % [r2.failure, r2.hero_final_position])
	check(Session.is_collected("L01-TEST-CACHE01"), "the OPT01 branch opens the optional cache")
	check(Session.has_artifact("A01"), "the OPT01 branch records the optional artifact")
	check(Session.get_wallet() == wallet_after_main + 20,
			"branch adds exactly the cache's 20 gems on top of the main route's total (before=%d after=%d)"
			% [wallet_after_main, Session.get_wallet()])


# --- 2. gems: one-time, Session-backed -------------------------------------

func _test_gem_collects_once_and_respects_session() -> void:
	Session.new_run()
	var id := "L01-TEST-GEM-DIRECT"
	check(not Session.is_collected(id), "sanity: gem not collected yet")

	var gem1: Gem = load("res://scenes/objects/gem.tscn").instantiate()
	gem1.entity_id = id
	gem1.value = 1
	add_child(gem1)
	await physics_frames(2)
	check(is_instance_valid(gem1) and not gem1.is_queued_for_deletion(), "an uncollected gem stays present")

	var fake_hero := Node2D.new()
	fake_hero.add_to_group("hero")
	gem1._on_body_entered(fake_hero)
	await physics_frames(2)
	check(Session.is_collected(id), "contact collects the gem via Session")
	check(Session.gems_found() == 1, "collecting once records exactly one gem")
	check(not is_instance_valid(gem1), "the collected gem removes itself")

	# Re-instancing the SAME id (simulating a reload) must come back absent.
	var gem2: Gem = load("res://scenes/objects/gem.tscn").instantiate()
	gem2.entity_id = id
	add_child(gem2)
	await physics_frames(2)
	check(not is_instance_valid(gem2), "re-instancing an already-collected gem frees it in _ready")

	check(not Session.collect(id, 1), "Session.collect refuses a repeat for the same id")
	check(Session.gems_found() == 1, "gems_found does not grow from the refused repeat")

	fake_hero.queue_free()


# --- 3. care capsule: gated by hero health ----------------------------------

func _test_care_capsule_gating() -> void:
	Session.new_run()
	var id := "L01-TEST-HS-DIRECT"
	var capsule: CareCapsule = load("res://scenes/objects/care_capsule.tscn").instantiate()
	capsule.entity_id = id
	capsule.heal = 2
	add_child(capsule)
	await physics_frames(2)

	var fake_hero := Node2D.new()
	fake_hero.add_to_group("hero")
	check(Session.is_full_health(), "sanity: a fresh run starts at full health")
	capsule._on_body_entered(fake_hero)
	await physics_frames(2)
	check(not Session.is_collected(id), "capsule is NOT collected while the hero is at full health")
	check(is_instance_valid(capsule), "capsule remains present, available for later, when not needed now")

	Session.apply_damage(3)
	capsule._on_body_entered(fake_hero)
	await physics_frames(2)
	check(Session.is_collected(id), "capsule IS collected once the hero is hurt")
	check(Session.get_health() == Session.MAX_HEALTH - 3 + 2,
			"capsule heals exactly its `heal` amount (health=%d)" % Session.get_health())
	check(not is_instance_valid(capsule), "a collected capsule removes itself")

	fake_hero.queue_free()


# --- 4. recovery station: heals to full + commits ---------------------------

func _test_recovery_station_heals_and_commits() -> void:
	Session.new_run()
	Session.apply_damage(4)
	var station: RecoveryStation = load("res://scenes/objects/recovery_station.tscn").instantiate()
	station.checkpoint_id = "CP01"
	add_child(station)
	await physics_frames(2)

	var fake_hero := Node2D.new()
	station.interact(fake_hero)
	await physics_frames(1)
	check(Session.is_full_health(), "recovery station heals the run to full")
	check(Session.state["checkpoint_id"] == "CP01", "recovery station commits the given checkpoint id")
	check(Session.committed["health"] == Session.MAX_HEALTH, "the committed snapshot reflects the healed state")

	# Reusable: interacting again still heals/commits and does not error.
	Session.apply_damage(2)
	station.interact(fake_hero)
	await physics_frames(1)
	check(Session.is_full_health(), "reusing the station heals again")

	station.queue_free()
	fake_hero.queue_free()


# --- 5. service walkway: switch-gated, persists, never retracts ------------

func _test_walkway_extends_persists_never_retracts() -> void:
	Session.new_run()
	var switch_id := "L01-TEST-SW-DIRECT"
	var walkway: ServiceWalkway = load("res://scenes/objects/service_walkway.tscn").instantiate()
	walkway.switch_id = switch_id
	walkway.width = 100.0
	add_child(walkway)
	await physics_frames(2)
	check(not walkway.is_extended(), "walkway starts retracted before its switch is pulled")

	Session.set_switch(switch_id, true)
	await physics_frames(1)
	check(walkway.is_extended(), "walkway extends live the moment the switch changes")
	walkway.queue_free()
	await physics_frames(1)

	# Re-instancing (a reload) must come back extended immediately from Session.
	var walkway2: ServiceWalkway = load("res://scenes/objects/service_walkway.tscn").instantiate()
	walkway2.switch_id = switch_id
	add_child(walkway2)
	await physics_frames(2)
	check(walkway2.is_extended(), "a fresh walkway reads Session on _ready and is already extended")

	# Nothing in this project ever un-sets a switch; Session.set_switch is a
	# one-way latch here, so "never retracts" holds by construction.
	Session.set_switch(switch_id, true)  # idempotent
	check(walkway2.is_extended(), "re-affirming the same switch value keeps the walkway extended")
	check(Session.get_switch(switch_id), "the switch itself stays true")

	walkway2.queue_free()


# --- 6. pit hazard: costs 1 health, resets to its Reset marker --------------

func _test_pit_hazard_costs_health_and_resets() -> void:
	Session.new_run()
	var pit: PitHazard = load("res://scenes/objects/pit_hazard.tscn").instantiate()
	pit.damage = 1
	add_child(pit)
	await physics_frames(2)
	var reset_marker: Marker2D = pit.get_node("Reset")

	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	# Position BEFORE add_child (not after): a Hero entering the tree at its
	# default (0,0) — which overlaps this pit, itself also at (0,0) — can
	# have that transient overlap detected and its body_entered signal
	# delivered a few physics frames later (after the hero has already been
	# moved far away here), landing right on top of this test's own manual
	# _on_body_entered call and costing an extra, untracked health. Setting
	# `position` first means the Hero only ever enters the tree far from
	# the pit, so no such overlap is ever possible.
	hero.position = Vector2(9999.0, 9999.0)
	hero.input_enabled = false
	add_child(hero)
	await physics_frames(3)

	var start_health: int = Session.get_health()
	pit._on_body_entered(hero)
	await physics_frames(1)
	check(Session.get_health() == start_health - 1, "pit hazard costs exactly 1 health (default damage)")
	check(hero.global_position.distance_to(reset_marker.global_position) < 0.5,
			"pit hazard resets the hero to its fixed Reset marker (got %s, want %s)"
			% [hero.global_position, reset_marker.global_position])

	hero.queue_free()
	pit.queue_free()


# --- 7. emergency hatch: opens from the story flag --------------------------

func _test_hatch_opens_from_story_flag() -> void:
	Session.new_run()
	var hatch: EmergencyHatch = load("res://scenes/objects/emergency_hatch.tscn").instantiate()
	add_child(hatch)
	await physics_frames(2)
	check(not hatch.is_open(), "hatch starts closed/solid before the story flag is set")

	Session.set_story("hatch_open", true)
	await physics_frames(1)
	check(hatch.is_open(), "hatch opens live the moment the story flag changes")
	hatch.queue_free()
	await physics_frames(1)

	# A fresh instance (reload/re-enter) with the flag already true must open
	# immediately, without needing to witness the change.
	Session.new_run()
	Session.set_story("hatch_open", true)
	var hatch2: EmergencyHatch = load("res://scenes/objects/emergency_hatch.tscn").instantiate()
	add_child(hatch2)
	await physics_frames(2)
	check(hatch2.is_open(), "a fresh hatch reads the story flag on _ready too")
	hatch2.queue_free()


# --- 8. core console: the real SC01 event sets the awakening flags once ----
# (M5 replaced the M3 stub's instant flag-flip with the ~19s watch-through/
# skippable scene in story-scenes.md; the skip path — proven identical to a
# full watch-through by tests/cases/test_m5_story.gd T16 — is exercised here
# so this M3-era foundation test still proves CoreConsole's per-entity-type
# contract quickly.)

func _test_core_console_sets_flags_once() -> void:
	Session.new_run()
	var console: CoreConsole = load("res://scenes/objects/core_console.tscn").instantiate()
	add_child(console)
	await physics_frames(2)
	var fake_hero := Node2D.new()

	check(not Session.get_story("awakening_done"), "sanity: awakening not yet done on a fresh run")
	console.interact(fake_hero)
	await physics_frames(2)
	await hold(&"skip", 1.0 / 60.0)
	await physics_frames(6)
	check(Session.get_story("awakening_done"), "first console interaction sets awakening_done")
	check(Session.get_story("core_installed"), "first console interaction sets core_installed")
	check(Session.get_story("hatch_open"), "first console interaction opens the hatch")
	check(Session.get_objective() == "Reach the garden wicket.", "first interaction sets the post-awakening objective")
	check(Session.state["checkpoint_id"] == "CP04", "first interaction commits CP04")

	var story_signals := [0]
	Session.story_state_changed.connect(func(_f, _v): story_signals[0] += 1)
	console.interact(fake_hero)  # repeat: status-only per 03-gameplay-systems.md
	await physics_frames(1)
	check(story_signals[0] == 0, "a repeated interaction does not re-fire any story flag (got %d signal(s))" % story_signals[0])

	console.queue_free()
	fake_hero.queue_free()


# --- 9. artifact: records once, adds zero gems ------------------------------

func _test_artifact_records_with_zero_gems() -> void:
	Session.new_run()
	var pickup: ArtifactPickup = load("res://scenes/objects/artifact_pickup.tscn").instantiate()
	add_child(pickup)
	await physics_frames(2)
	var fake_hero := Node2D.new()

	var wallet_before: int = Session.get_wallet()
	check(not Session.has_artifact("A01"), "sanity: artifact not yet recorded on a fresh run")
	pickup.interact(fake_hero)
	await physics_frames(1)
	check(Session.has_artifact("A01"), "interacting records the artifact")
	check(Session.get_wallet() == wallet_before, "recording the artifact adds zero gems (wallet unchanged)")
	check(Session.is_collected(pickup.entity_id), "the pickup's own entity_id is marked collected (zero value)")
	check(not Session.record_artifact("A01", pickup.entity_id), "recording the same artifact twice is refused")

	pickup.queue_free()
	fake_hero.queue_free()
