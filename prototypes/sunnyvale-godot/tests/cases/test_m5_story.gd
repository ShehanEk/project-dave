extends TestCase
## M5 story/completion contracts (06-build-milestones.md M5 /
## 07-acceptance-and-playtesting.md T16-T18, T20). Every sub-test boots the
## full `level_01.tscn` (LevelDirector) so CoreNode, EnvironmentState, and
## the real completion flow are exercised exactly as in normal play, not in
## isolation.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const DEPOT_AREA_INDEX := 4
const EXIT_AREA_INDEX := 5

## Comfortably longer than CoreNode's own full watch-through (19.0s authored;
## up to ~20.4s with the N05 voice clips, which lengthen the 2nd and 3rd lines),
## so a "normal" run reaches full completion (including hero.input_enabled
## returning) before this test checks anything.
const FULL_WATCH_SECONDS := 22.0


func run() -> void:
	await _test_t16_sc01_normal_vs_skip()
	await _test_t17_resume_after_awakening()
	await _test_t18_zero_upgrade_finish()
	await _test_t20_completion_totals_and_replay()


# --- T16: SC01 normal vs skip produce IDENTICAL persistent state --------------

func _test_t16_sc01_normal_vs_skip() -> void:
	# --- normal: watch the whole scene, never press skip/pause -----------------
	Session.new_run()
	var level_a: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level_a)
	await physics_frames(3)

	var console_a: CoreNode = level_a.areas[DEPOT_AREA_INDEX].get_node("Entities/CoreNode")
	level_a.hero.global_position = console_a.global_position
	await physics_frames(2)
	check(not Session.get_story("awakening_done"), "setup: awakening not yet done")

	console_a.interact(level_a.hero)
	await physics_frames(2)
	check(not level_a.hero.input_enabled, "SC01 disables hero input while it plays")
	await seconds(FULL_WATCH_SECONDS)

	check(Session.get_story("awakening_done"), "normal watch-through sets awakening_done")
	check(Session.get_story("core_installed"), "normal watch-through sets core_installed")
	check(Session.get_story("hatch_open"), "normal watch-through opens the hatch")
	check(Session.get_objective() == Session.OBJECTIVE_POST_SC01,
			"normal watch-through sets the post-awakening objective")
	check(Session.state["checkpoint_id"] == "CP04", "normal watch-through commits CP04")
	check(level_a.hero.input_enabled, "control returns once the scene finishes")

	var normal_snapshot: Dictionary = Session.committed.duplicate(true)

	# Re-interacting afterward must not replay/duplicate the event.
	console_a.interact(level_a.hero)
	await physics_frames(3)
	check(Session.committed == normal_snapshot, "a repeated interact never changes the committed state")
	check(level_a.hero.input_enabled, "a repeated (status-only) interact never leaves input disabled")

	level_a.queue_free()
	await physics_frames(2)

	# --- skip: press skip almost immediately ------------------------------------
	Session.new_run()
	var level_b: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level_b)
	await physics_frames(3)

	var console_b: CoreNode = level_b.areas[DEPOT_AREA_INDEX].get_node("Entities/CoreNode")
	level_b.hero.global_position = console_b.global_position
	await physics_frames(2)

	console_b.interact(level_b.hero)
	await physics_frames(2)
	check(not level_b.hero.input_enabled, "SC01 also disables hero input on the skip path")
	await hold(&"skip", 1.0 / 60.0)
	await physics_frames(6)

	check(Session.get_story("awakening_done"), "skip sets awakening_done")
	check(Session.get_story("core_installed"), "skip sets core_installed")
	check(Session.get_story("hatch_open"), "skip opens the hatch")
	check(Session.get_objective() == Session.OBJECTIVE_POST_SC01, "skip sets the post-awakening objective")
	check(Session.state["checkpoint_id"] == "CP04", "skip commits CP04")
	check(level_b.hero.input_enabled, "control returns immediately once skipped")

	var skip_snapshot: Dictionary = Session.committed.duplicate(true)
	# ADV-09: `active_seconds` is a point-in-time mirror of this run's OWN
	# elapsed active time (Session.run_meta), which is genuinely different
	# between a ~21s full watch-through and an almost-immediate skip — it is
	# not part of the STORY state T16 is proving is identical either way, so
	# it is excluded from this specific comparison (every other field must
	# still match exactly).
	var normal_story := normal_snapshot.duplicate(true)
	var skip_story := skip_snapshot.duplicate(true)
	normal_story.erase("active_seconds")
	skip_story.erase("active_seconds")
	check(skip_story == normal_story,
			"normal and skipped SC01 produce an IDENTICAL committed snapshot (ignoring active_seconds)\n  normal: %s\n  skip:   %s"
			% [normal_snapshot, skip_snapshot])

	level_b.queue_free()
	await physics_frames(2)


# --- T17: resume after awakening (from CP04 and from UPG01) -------------------

func _test_t17_resume_after_awakening() -> void:
	# --- resume from CP04 -------------------------------------------------------
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	var console: CoreNode = level.areas[DEPOT_AREA_INDEX].get_node("Entities/CoreNode")
	level.hero.global_position = console.global_position
	await physics_frames(2)
	console.interact(level.hero)
	await hold(&"skip", 1.0 / 60.0)
	await physics_frames(6)
	check(Session.state["checkpoint_id"] == "CP04", "setup: CP04 committed")
	var health_before_death := Session.get_health()

	var lockdown_a06 := level.areas[EXIT_AREA_INDEX].get_node("Scenery/LockdownVisuals")
	var garden_a06 := level.areas[EXIT_AREA_INDEX].get_node("Scenery/GardenVisuals")
	check(lockdown_a06.visible, "A06's lockdown visuals are already settled off-screen after SC01")
	check(not garden_a06.visible, "A06's pre-awakening garden visuals are hidden after SC01")

	level.hero.take_damage(999, level.hero.global_position)
	await physics_frames(4)

	check(Session.get_story("awakening_done"), "death after CP04 keeps awakening_done true")
	check(Session.get_story("hatch_open"), "death after CP04 never relocks the hatch")
	check(Session.get_health() == health_before_death, "respawn deals no extra damage (health unchanged)")

	var fresh_console: CoreNode = level.areas[DEPOT_AREA_INDEX].get_node("Entities/CoreNode")
	check(fresh_console._phase == "awake", "the rebuilt console shows the settled state directly, no replay")
	var fresh_lockdown := level.areas[EXIT_AREA_INDEX].get_node("Scenery/LockdownVisuals")
	var fresh_garden := level.areas[EXIT_AREA_INDEX].get_node("Scenery/GardenVisuals")
	check(fresh_lockdown.visible and fresh_lockdown.modulate.a == 1.0,
			"a rebuilt A06 applies the settled lockdown look directly, with no fade-in evidence")
	check(not fresh_garden.visible, "a rebuilt A06 never shows the pre-awakening garden look once awake")

	var respawn_marker := level.areas[DEPOT_AREA_INDEX].get_marker("Respawn_CP04")
	check(level.hero.global_position.distance_to(respawn_marker.global_position) < 12.0,
			"respawn lands exactly at CP04's own marker")

	level.queue_free()
	await physics_frames(2)

	# --- resume from UPG01 -------------------------------------------------------
	Session.new_run()
	var level2: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level2)
	await physics_frames(3)

	var console2: CoreNode = level2.areas[DEPOT_AREA_INDEX].get_node("Entities/CoreNode")
	level2.hero.global_position = console2.global_position
	await physics_frames(2)
	console2.interact(level2.hero)
	await hold(&"skip", 1.0 / 60.0)
	await physics_frames(6)
	check(Session.get_story("awakening_done"), "setup: awakened before visiting the workbench")

	Session.state["wallet"] = 40
	var purchase: Dictionary = Session.purchase_upgrade("W01", 1, 40)
	check(purchase.get("ok", false), "setup: the workbench purchase itself succeeds")
	check(Session.state["checkpoint_id"] == "UPG01", "setup: the purchase commits UPG01")
	var health_before_death2 := Session.get_health()

	level2.hero.take_damage(999, level2.hero.global_position)
	await physics_frames(4)

	check(Session.state["checkpoint_id"] == "UPG01", "rollback restores checkpoint_id UPG01")
	check(Session.get_story("hatch_open"), "resuming from UPG01 still has the hatch open")
	check(Session.get_health() == health_before_death2, "resuming from UPG01 deals no extra damage")
	var respawn_marker2 := level2.areas[DEPOT_AREA_INDEX].get_marker("Respawn_UPG01")
	check(level2.hero.global_position.distance_to(respawn_marker2.global_position) < 12.0,
			"respawn lands exactly at UPG01's own marker")
	var fresh_console2: CoreNode = level2.areas[DEPOT_AREA_INDEX].get_node("Entities/CoreNode")
	check(fresh_console2._phase == "awake", "the rebuilt console (post-purchase resume) is settled, no replay")

	level2.queue_free()
	await physics_frames(2)


# --- T18: zero-upgrade finish ---------------------------------------------------

func _test_t18_zero_upgrade_finish() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	# The RouteBot never dodges or purchases; keep combat from killing it mid
	# route (same precedent as test_m3_level.gd's own full-route test).
	level.hero.debug_invulnerable = true

	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(level, [])  # main route only: no OPT01/OPT02 branches
	bot.start(level.hero)
	while bot.running:
		await get_tree().physics_frame
	var report := bot.get_report()

	check(report.success, "the base-pistol RouteBot completes A01->A06 through the real SC01 to the exit (failure=%s)" % report.failure)
	check(level.level_ended_flag, "the run reaches real completion (level_ended_flag)")
	check(Session.get_story("level_complete"), "completion sets level_complete")
	check(Session.state["checkpoint_id"] == "CP05", "completion commits CP05")
	check(Session.get_objective() == Session.OBJECTIVE_COMPLETE, "completion sets the final objective")
	check(Session.weapon_stage("W01") == 0, "zero-upgrade finish: Quickcycle was never purchased (stage 0)")
	check(not Session.has_evidence("EF01"), "zero-upgrade finish: no evidence collected (main route only)")
	check(Session.chips_found() == 45, "zero-upgrade finish: only the main-route 45 chip value, no cache")

	level.queue_free()
	bot.queue_free()
	await physics_frames(2)


# --- T20: completion totals / fresh replay --------------------------------------

func _test_t20_completion_totals_and_replay() -> void:
	# M7 finding (see telemetry.gd's own doc comment and
	# test_m5_regress_play_again_hud.gd): confirming "Play again" through the
	# real completion screen below calls the REAL
	# `LevelDirector._on_play_again_confirmed()`, which itself calls the REAL
	# `Telemetry.run_start()` — redirect first so this test cannot leave a
	# playtest log in the actual player's default save directory.
	var telemetry: Node = get_node_or_null("/root/Telemetry")
	var test_dir := "user://test_runs/t20_replay_%d" % Time.get_ticks_usec()
	if telemetry:
		telemetry.set_playtest_dir(test_dir)

	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	# One properly-whitelisted-shaped fake chip id worth the full main-route
	# total, so a real CheckpointService.save_snapshot() (called by the real
	# purchase transaction below) still validates.
	check(Session.collect("L01-A02-G001", 45), "setup: collect 45 chips worth of value")
	Session.set_story("awakening_done", true)

	var spend: Dictionary = Session.purchase_upgrade("W01", 1, 40)
	check(spend.get("ok", false), "setup: the 40-chip Quickcycle purchase succeeds")
	check(Session.get_wallet() == 5, "setup: wallet reflects the spend (45-40=5)")
	check(Session.chips_found() == 45, "chips found stays 45 after spending 40 at the workbench (wallet != chips found)")

	# Take some damage, defeat an enemy, flip the depot swap, so "Play again"
	# has real progress across every field to reset, not just chips/wallet.
	Session.apply_damage(2)
	var a02: AreaRoot = level.areas[1]
	var guard: Brawler = a02.get_node("Encounters/EncounterGroup_E01/NightGuard")
	Session.mark_defeated(guard.entity_id)
	Session.set_switch("L01-SW01", true)
	var swap := Session.swap_weapon("L01-A05-PAD01")
	check(swap.get("ok", false), "setup: the depot weapon swap succeeds")

	# Reach the real exit wicket and confirm "Play again" through the actual
	# completion screen (not by calling Session.new_run() ourselves).
	var wicket := level.areas[EXIT_AREA_INDEX].get_node("Entities/ExitWicket")
	# Revamp (C24): the wicket needs the A04 clearance keycard, which a real
	# run always picks up on the plaza porch (main route).
	Session.take_keycard("L01-KC01", "L01-KC01-P")
	# C41: the wicket's override is a 16 s hold-out against the lockdown
	# staffers; the level ends when it finishes with Dave in the gate. This
	# test is about the completion flow, so Dave rides the fight out unhurt.
	level.hero.debug_invulnerable = true
	level.hero.global_position = wicket.global_position
	await physics_frames(3)
	check(not level.level_ended_flag, "the exit wicket holds the level open while its override runs (C41)")
	await seconds(wicket.override_time + 1.0)
	check(level.level_ended_flag, "setup: the exit wicket triggers completion")
	# C28: the Security PA line plays first; the completion screen opens
	# PA_BEAT later (level_ended_flag and level_ended are set at once).
	check(not is_instance_valid(level._completion_screen), "the completion screen waits for the Security PA line")
	await physics_frames(int(LevelDirector.PA_BEAT * 60.0) + 2)
	check(is_instance_valid(level._completion_screen), "the completion screen opens after the PA line")
	check(Session.chips_found() == 45, "chips found is still 45 on the completion screen (independent of the earlier spend)")

	level._completion_screen.play_again_confirmed.emit()
	await physics_frames(4)

	var fresh := Session.default_state()
	check(Session.state["health"] == fresh["health"], "Play again resets health")
	check(Session.state["wallet"] == fresh["wallet"], "Play again resets wallet")
	check(Session.state["upgrades"] == fresh["upgrades"], "Play again resets upgrades")
	check(Session.state["collected"].is_empty(), "Play again resets collected chips")
	check(Session.state["defeated"].is_empty(), "Play again resets defeated enemies")
	check(Session.state["switches"] == fresh["switches"], "Play again resets switches")
	check(Session.state["story"] == fresh["story"], "Play again resets story flags")
	check(Session.state["equipped_weapon"] == fresh["equipped_weapon"], "Play again resets the equipped weapon")
	check(Session.state["world_weapons"] == fresh["world_weapons"], "Play again resets world weapon placement")
	check(Session.state["objective"] == fresh["objective"], "Play again resets the objective")
	check(not level.level_ended_flag, "Play again clears level_ended_flag for a real new playthrough")
	check(level.hero.input_enabled, "Play again re-enables hero input")

	var checkpoint_service := get_node_or_null("/root/CheckpointService")
	if checkpoint_service:
		check(not checkpoint_service.has_valid_save(), "Play again clears the on-disk save too")

	level.queue_free()
	await physics_frames(2)
	if telemetry:
		telemetry.end_run()
		telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
		get_node("/root/CheckpointService").remove_dir_recursive(test_dir)
