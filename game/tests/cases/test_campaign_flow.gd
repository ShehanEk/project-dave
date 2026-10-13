extends TestCase
## M1 (C61) campaign framework. Levels are data (LevelDef, data/levels/*.tres,
## listed by LevelDefs) and Level 1 starts exactly as before; the Level 1 ->
## Level 2 handover carries the campaign state (held weapon type, upgrades,
## wallet, evidence, completed levels, carried story flags) and resets every
## per-level field from Level 2's LevelDef, through the real completion
## screen's Continue under Main; a save made inside Level 2 Continues into
## Level 2; `Main.start_level_direct()` (what the `--level` flag runs) starts
## any level with the default campaign state; and CheckpointService accepts
## each registered level's own ids while rejecting unknown or foreign ones.

const MAIN_SCENE := "res://scenes/main.tscn"

var _telemetry_dir := ""


func run() -> void:
	_telemetry_dir = "user://test_runs/campaign_flow_telemetry_%d" % Time.get_ticks_usec()
	Telemetry.set_playtest_dir(_telemetry_dir)
	_test_registry_and_level_1_unchanged()
	await _test_l02_first_area()
	_test_handover_state()
	_test_id_validation()
	await _test_completion_continue_into_l02()
	await _test_save_and_continue_inside_l02()
	await _test_level_flag()
	Telemetry.end_run()
	Telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
	CheckpointService.remove_dir_recursive(_telemetry_dir)
	CheckpointService.clear()
	Session.new_run()


func _round_trip(state: Dictionary) -> Dictionary:
	return JSON.parse_string(JSON.stringify(state))


func _valid(state: Dictionary) -> bool:
	return CheckpointService.validate_snapshot(_round_trip(state)).ok


# --- 1. the registry, and Level 1 as data --------------------------------------------

func _test_registry_and_level_1_unchanged() -> void:
	check_eq(Array(LevelDefs.ids()), ["L01", "L02"], "the registry lists L01 then L02")
	for i in LevelDefs.ids().size():
		var id: String = LevelDefs.ids()[i]
		var def := LevelDefs.get_def(id)
		check(def != null, "%s has a LevelDef" % id)
		if def == null:
			continue
		check_eq(def.id, id, "%s's LevelDef names itself" % id)
		check_eq(def.number, i + 1, "%s is level %d" % [id, i + 1])
		check(not def.area_scenes.is_empty(), "%s has area scenes" % id)
		for path in def.area_scenes:
			check(ResourceLoader.exists(path), "%s area scene exists: %s" % [id, path])
		for cp in def.checkpoint_markers:
			var entry: Array = def.checkpoint_markers[cp]
			check(int(entry[0]) >= 0 and int(entry[0]) < def.area_scenes.size(),
					"%s %s's marker is in one of its areas" % [id, cp])
		check(def.checkpoint_markers.has(def.first_checkpoint), "%s's first checkpoint has a marker" % id)
		check(def.checkpoint_markers.has(def.exit_checkpoint), "%s's exit checkpoint has a marker" % id)
		check(def.story_defaults.has("level_complete"), "%s saves level_complete" % id)
		check(_valid(Session.default_state(id)), "%s's fresh start validates" % id)
	check_eq(LevelDefs.get_def("L01").next_level, "L02", "Level 1 leads into Level 2")
	check_eq(LevelDefs.next_of("L01"), "L02", "next_of(L01) is L02")
	check_eq(LevelDefs.next_of("L02"), "", "Level 2 is the end of the campaign for now")
	check(LevelDefs.get_def("L09") == null and not LevelDefs.has_level("L09"), "an unknown level has no LevelDef")
	check_eq(LevelDefs.get_def("L02").display_name, "Alignment", "Level 2 is Alignment (C59)")

	# Level 1 starts exactly as before (the values that used to be constants).
	var l01 := LevelDefs.get_def("L01")
	check_eq(l01.area_scenes.size(), 6, "Level 1 has its six areas")
	check_eq(l01.area_scenes[0], "res://scenes/levels/areas/a01_gate.tscn", "Level 1 starts at the gate")
	check_eq(l01.objective_start, Session.OBJECTIVE_START, "l01.tres's first objective is Session's")
	check_eq(l01.objective_complete, Session.OBJECTIVE_COMPLETE, "l01.tres's final objective is Session's")
	check_eq(l01.intro_scene, "res://scripts/ui/intro_comic.gd", "Level 1's intro is the SC00 comic")
	var fresh := Session.default_state()
	check_eq(fresh, Session.default_state("L01"), "default_state() is Level 1's fresh start")
	check_eq(fresh["schema_version"], 4, "the save schema is 4 (M1)")
	check_eq(fresh["level"], "L01", "a new run is in Level 1")
	check_eq(fresh["checkpoint_id"], "CP00", "...at CP00")
	check_eq(fresh["health"], Session.MAX_HEALTH, "...at full health")
	check_eq(fresh["equipped_weapon"], "L01-W01-P01", "...holding L01-W01-P01")
	check_eq(fresh["world_weapons"], {"L01-W01-P02": "L01-A05-PAD01"}, "...with P02 on the depot pad")
	check_eq(fresh["switches"], {"L01-SW01": false}, "...with the A04 switch off")
	check_eq(fresh["story"], {"awakening_done": false, "core_installed": true, "hatch_open": false, "level_complete": false},
			"...with Level 1's four story flags")
	check_eq(fresh["upgrades"], {"W01": 0, "A01": 0}, "...with no upgrades")
	check_eq(fresh["completed_levels"], [], "...and nothing completed")
	check_eq(LevelDefs.wallet_cap("L01"), 65, "a Level 1 wallet is capped at its 65 chips")

	# An older save (schema 3) is rejected: Continue stays off until a new run.
	var old := Session.default_state()
	old["schema_version"] = 3
	old.erase("completed_levels")
	check(not _valid(old), "a schema 3 save is rejected")


# --- 2. Level 2's first area (M2 replaced M1's one-area stub; test_l02_areas.gd has the rest) --

func _test_l02_first_area() -> void:
	var def := LevelDefs.get_def("L02")
	check_eq(def.area_scenes.size(), 6, "Level 2 has its six areas (M2)")
	var area: AreaRoot = (load(def.area_scenes[0]) as PackedScene).instantiate()
	add_child(area)
	await physics_frames(2)
	check_eq(area.area_id, "L02-A01", "the first area uses the L02- prefix")
	check(area.indoors and area.wet_until_x > 0.0, "A01 is the rainy sky bridge into the indoor plant")
	check(area.get_marker("Spawn_CP00") != null, "A01 has the CP00 start marker")
	check(area.has_floor_at(200.0) and area.has_floor_at(area.width - 200.0), "A01's floor runs to its exit seam")
	area.queue_free()
	await physics_frames(1)


# --- 3. the handover state ------------------------------------------------------------------

func _finished_level_1() -> Dictionary:
	var from := Session.default_state()
	from["checkpoint_id"] = "CP05"
	from["health"] = 2
	from["wallet"] = 37
	from["collected"] = {"L01-A02-G001": 1, "L01-OPT01-A01": 0, "L01-KC01-P": 0}
	from["evidence"] = ["EF01"]
	from["keycards"] = ["L01-KC01"]
	from["upgrades"] = {"W01": 1, "A01": 1}
	# Swapped at the pad: the other W01 copy is in hand. Its TYPE carries over.
	from["equipped_weapon"] = "L01-W01-P02"
	from["world_weapons"] = {"L01-W01-P01": "L01-A05-PAD01"}
	from["defeated"] = {"L01-E01-SE01-01": true}
	from["switches"] = {"L01-SW01": true}
	from["story"] = {"awakening_done": true, "core_installed": true, "hatch_open": true, "level_complete": true}
	from["objective"] = Session.OBJECTIVE_COMPLETE
	from["active_seconds"] = 300.0
	return from


func _test_handover_state() -> void:
	var from := _finished_level_1()
	check(_valid(from), "setup: the finished Level 1 state validates")
	var l02 := LevelDefs.get_def("L02")
	var next := Session.next_level_state(from, "L02")
	# Carried.
	check_eq(next["level"], "L02", "handover: the run is in Level 2")
	check_eq(next["wallet"], 37, "handover: the wallet carries over")
	check_eq(next["upgrades"], {"W01": 1, "A01": 1}, "handover: every upgrade stage carries over")
	check_eq(next["evidence"], ["EF01"], "handover: the evidence files carry over")
	check_eq(next["completed_levels"], ["L01"], "handover: Level 1 is recorded as completed")
	check_eq(next["equipped_weapon"], "L02-W01-P01", "handover: the held weapon TYPE (W01) carries over as Level 2's hand instance")
	check_eq(next["story"]["awakening_done"], true, "handover: awakening_done (a carried story flag) carries over")
	# Fresh from Level 2's LevelDef.
	check_eq(next["checkpoint_id"], "CP00", "handover: Level 2 starts at its first checkpoint")
	check_eq(next["health"], Session.MAX_HEALTH + 1, "handover: full health, with Scrap Plating's segment")
	check_eq(next["collected"], {}, "handover: no Level 2 pickups collected")
	check_eq(next["defeated"], {}, "handover: no Level 2 enemies defeated")
	check_eq(next["keycards"], [], "handover: Level 1's keycard does not carry over")
	check_eq(next["switches"], l02.switches, "handover: Level 2's switches start at their defaults")
	check_eq(next["world_weapons"], l02.world_weapons, "handover: Level 2's world weapons start where its LevelDef puts them")
	check_eq(next["story"], {"awakening_done": true, "bridge_door_locked": false, "level_complete": false, "sandbox_lockdown": false},
			"handover: Level 2's own story flags, level_complete off")
	check_eq(next["objective"], l02.objective_start, "handover: Level 2's first objective")
	check_eq(next["active_seconds"], 0.0, "handover: Level 2's play time starts at 0")
	check(_valid(next), "handover: the Level 2 start state validates")
	check_eq(from["level"], "L01", "handover: next_level_state() never touches its input")
	check(Session.next_level_state(from, "L09").is_empty(), "handover: an unknown level gives no state")
	check_eq(l02.hand_instance("W02"), "L02-W02-P02", "a carried-in W02 would be Level 2's hand instance L02-W02-P02 (M3: P01 rests on the A01 pad)")

	# Live: Session.advance_to_level() adopts it and saves Level 2's CP00.
	CheckpointService.clear()
	Session.load_from_snapshot(_round_trip(from))
	Session.run_meta["active_seconds"] = 123.0
	var saved := Session.advance_to_level("L02")
	check(saved, "advance_to_level saves the next level's first checkpoint")
	check_eq(Session.current_level_id(), "L02", "advance_to_level: the run is in Level 2")
	check_eq(Session.state, Session.committed, "advance_to_level: Level 2's start is the rollback boundary")
	check_eq(float(Session.run_meta["active_seconds"]), 0.0, "advance_to_level: the play-time counter restarts")
	check_eq(Session.get_wallet(), 37, "advance_to_level: the wallet is carried")
	var loaded := CheckpointService.load_latest()
	check(loaded.ok and loaded.snapshot.get("level") == "L02" and loaded.snapshot.get("checkpoint_id") == "CP00",
			"advance_to_level: the save on disk is Level 2 at CP00 (%s)" % str(loaded.get("error", "")))
	var before := Session.state.duplicate(true)
	check(not Session.advance_to_level("L09"), "advance_to_level refuses an unknown level")
	check_eq(Session.state, before, "...and changes nothing")
	CheckpointService.clear()
	Session.new_run()


# --- 4. id validation across levels -------------------------------------------------------

func _test_id_validation() -> void:
	var base := Session.default_state("L02")
	check(_valid(base), "a fresh Level 2 state validates")

	var s := base.duplicate(true)
	s["collected"] = {"L02-A01-G001": 1, "L02-A04-OPT01-A01": 0}
	s["defeated"] = {"L02-E01-SE02-01": true}
	s["keycards"] = ["L02-KC01"]
	s["switches"] = {"L02-SW01": true}
	s["evidence"] = ["EF01", "EF02"]
	s["checkpoint_id"] = "CP05"
	check(_valid(s), "Level 2 ids (chips, enemies, keycard, switch, CP05) are accepted in a Level 2 save")

	for field in ["collected", "defeated"]:
		s = base.duplicate(true)
		s[field] = {"L09-A01-G001": (1 if field == "collected" else true)}
		check(not _valid(s), "an unknown level prefix (L09) is rejected in %s" % field)
		s = base.duplicate(true)
		s[field] = {"L01-A02-G001": (1 if field == "collected" else true)}
		check(not _valid(s), "a Level 1 id is rejected in a Level 2 save's %s (per-level state starts fresh)" % field)
	s = Session.default_state()
	s["collected"] = {"L02-A01-G001": 1}
	check(not _valid(s), "a Level 2 id is rejected in a Level 1 save")
	s = base.duplicate(true)
	s["keycards"] = ["L01-KC01"]
	check(not _valid(s), "Level 1's keycard is rejected in a Level 2 save")
	s = base.duplicate(true)
	s["switches"] = {"L09-SW01": true}
	check(not _valid(s), "an unknown level's switch is rejected")
	s = base.duplicate(true)
	s["level"] = "L09"
	check(not _valid(s), "an unregistered level is rejected")
	s = base.duplicate(true)
	s["level"] = "l02"
	check(not _valid(s), "a malformed level id is rejected")
	s = base.duplicate(true)
	s["checkpoint_id"] = "CP06"
	check(not _valid(s), "a checkpoint Level 2 does not have (CP06) is rejected")
	s = Session.default_state()
	s["checkpoint_id"] = "CP06"
	check(_valid(s), "...while Level 1 still accepts CP06")
	s = base.duplicate(true)
	s["equipped_weapon"] = "L01-W01-P01"
	check(not _valid(s), "a Level 1 weapon instance is rejected in a Level 2 save")
	s = base.duplicate(true)
	s["world_weapons"] = {"L02-W01-P02": "L02-A01-PAD01"}
	check(not _valid(s), "a weapon instance Level 2's LevelDef does not place is rejected")
	s = base.duplicate(true)
	s["story"] = Session.default_state()["story"]
	check(not _valid(s), "Level 1's story flags are rejected in a Level 2 save")
	s = base.duplicate(true)
	s["wallet"] = LevelDefs.wallet_cap("L02")
	check(_valid(s), "a Level 2 wallet may hold every chip found so far (%d)" % LevelDefs.wallet_cap("L02"))
	s["wallet"] = LevelDefs.wallet_cap("L02") + 1
	check(not _valid(s), "...but not one more")
	s = base.duplicate(true)
	s["completed_levels"] = ["L02"]
	check(not _valid(s), "a level cannot list itself as completed")
	s["completed_levels"] = ["L01", "L01"]
	check(not _valid(s), "a completed level is listed once")
	s["completed_levels"] = ["L09"]
	check(not _valid(s), "an unknown completed level is rejected")
	s = base.duplicate(true)
	s.erase("completed_levels")
	check(not _valid(s), "completed_levels is required")


# --- 5. the real flow: Level 1's completion screen -> Continue -> Level 2 ------------------

func _test_completion_continue_into_l02() -> void:
	CheckpointService.clear()
	Session.new_run()
	var main: Node = load(MAIN_SCENE).instantiate()
	add_child(main)
	await physics_frames(2)
	main._on_new_game_confirmed()
	await physics_frames(3)
	var l1: LevelDirector = main._level
	check(l1 != null and l1.level_def.id == "L01" and l1.name == "Level01", "New Game builds Level 1 (node Level01)")
	if l1 == null:
		main.queue_free()
		return

	# Earn campaign state in Level 1 the way play would.
	Session.set_story("awakening_done", true)
	check(Session.collect("L01-A05-G001", 45), "setup: collect chips")
	check(Session.purchase_upgrade("W01", 1, 40).get("ok", false), "setup: buy Quickcycle")
	check(Session.record_evidence("EF01", "L01-OPT01-A01"), "setup: find the Lockout Notice")
	check(Session.take_keycard("L01-KC01", "L01-KC01-P"), "setup: take Level 1's keycard")
	Session.set_switch("L01-SW01", true)
	Session.mark_defeated("L01-E01-SE01-01")
	l1._on_wicket_reached()
	await seconds(LevelDirector.PA_BEAT + 0.3)
	var screen: CompletionScreen = l1._completion_screen
	check(screen != null, "Level 1's completion screen opens after the PA line")
	if screen == null:
		main.queue_free()
		return
	var next_button: Button = screen.get_node("Panel/VBox/StatsView/ButtonRow/NextButton")
	check(next_button.visible, "Level 1's completion screen offers Continue (a next level exists)")
	check(next_button.has_focus(), "Continue has the focus")
	check(screen.get_node("Panel/VBox/StatsView/ButtonRow/PlayAgainButton").visible, "Play again is still there")
	check_eq(screen.get_node("Panel/VBox/TitleLabel").text, "Eon City complete.", "the title is unchanged")
	check_eq(screen.get_node("Panel/VBox/StatsView/NextLabel").text, "Next: Level 2, Alignment", "the next level is named from its LevelDef")
	check(screen.get_node("Panel/VBox/StatsView/AdamLabel").text.begins_with("Adam:"), "Adam's line is unchanged")
	check(screen.get_node("Panel/VBox/StatsView/ChipsLabel").text.ends_with("/ 65"), "the chip total is Level 1's 65")

	next_button.pressed.emit()
	await physics_frames(3)
	var l2: LevelDirector = main._level
	check(l2 != null and l2 != l1 and l2.level_def.id == "L02", "Continue loads Level 2")
	check(not is_instance_valid(l1) or not l1.is_inside_tree(), "Level 1 is gone")
	if l2 == null:
		main.queue_free()
		return
	check_eq(String(l2.name), "Level02", "the level node is named Level02")
	check_eq(get_tree().get_nodes_in_group("hero").size(), 1, "exactly one hero after the handover")
	check_eq(get_tree().get_nodes_in_group("subtitle_panel").size(), 1, "exactly one subtitle panel after the handover")
	check_eq(Session.current_level_id(), "L02", "Session is in Level 2")
	check_eq(Session.get_wallet(), 5, "the wallet carried (45 - 40)")
	check_eq(Session.weapon_stage("W01"), 1, "Quickcycle carried")
	check(Session.has_evidence("EF01"), "the evidence file carried")
	check_eq(Session.equipped_weapon(), "L02-W01-P01", "the W01 carried in as Level 2's hand instance")
	check(not Session.has_keycard("L01-KC01") and Session.state["keycards"].is_empty(), "keycards reset")
	check(Session.state["collected"].is_empty() and Session.state["defeated"].is_empty(), "pickups and enemies reset")
	check_eq(Session.state["switches"], LevelDefs.get_def("L02").switches, "switches reset to Level 2's (its lanes, all off)")
	check_eq(Session.get_story("level_complete"), false, "Level 2 is not complete")
	check_eq(Session.get_objective(), LevelDefs.get_def("L02").objective_start, "Level 2's objective")
	var loaded := CheckpointService.load_latest()
	check(loaded.ok and loaded.snapshot["level"] == "L02" and loaded.snapshot["checkpoint_id"] == "CP00",
			"the save on disk is Level 2's CP00")
	var spawn := l2.areas[0].get_marker("Spawn_CP00")
	check(spawn != null and l2.hero.global_position.distance_to(spawn.global_position) < 12.0, "Dave starts at Level 2's CP00")
	check(l2.hero.input_enabled, "Dave can move in Level 2")
	check(not l2.hud.get_node("TopBar/KeycardIcon").visible, "no keycard icon in Level 2 yet")

	# Level 2's end: its own exit checkpoint and a completion screen with no Continue.
	l2._on_wicket_reached()
	await seconds(LevelDirector.PA_BEAT + 0.3)
	var screen2: CompletionScreen = l2._completion_screen
	check(screen2 != null, "Level 2's completion screen opens")
	if screen2:
		check(not screen2.get_node("Panel/VBox/StatsView/ButtonRow/NextButton").visible, "no Continue after the last level")
		check_eq(screen2.get_node("Panel/VBox/TitleLabel").text, "Alignment complete.", "Level 2's own title")
	check_eq(Session.state["checkpoint_id"], "CP05", "Level 2's end commits its exit checkpoint")
	check(CheckpointService.load_latest().ok, "the completed Level 2 save is valid")

	# Continue from the title on that save reopens Level 2's completion.
	main._on_quit_to_title()
	await physics_frames(2)
	Session.new_run()
	main._title.attempt_continue()
	await physics_frames(3)
	var l2b: LevelDirector = main._level
	check(l2b != null and l2b.level_def.id == "L02" and l2b._completion_screen != null,
			"Continue on a completed Level 2 save shows Level 2's completion screen")
	if l2b and l2b._completion_screen:
		# Play again there is a brand-new run from Level 1 (Main swaps the level).
		l2b._completion_screen.play_again_confirmed.emit()
		await physics_frames(3)
		var fresh_level: LevelDirector = main._level
		check(fresh_level != null and fresh_level.level_def.id == "L01", "Play again after Level 2 starts Level 1")
		check_eq(Session.state, Session.default_state(), "...as a brand-new run")
		check(not CheckpointService.has_valid_save(), "...with the old save deleted")
		check_eq(get_tree().get_nodes_in_group("hero").size(), 1, "...and one hero")
	main._on_quit_to_title()
	await physics_frames(2)
	main.queue_free()
	await physics_frames(2)
	CheckpointService.clear()


# --- 6. save and Continue inside Level 2 --------------------------------------------------

func _test_save_and_continue_inside_l02() -> void:
	CheckpointService.clear()
	Session.new_run()
	var main: Node = load(MAIN_SCENE).instantiate()
	add_child(main)
	await physics_frames(2)
	check(main.start_level_direct("L02"), "setup: start Level 2")
	await physics_frames(3)
	check(Session.collect("L02-A01-G001", 1), "setup: collect a Level 2 chip")
	check(Session.commit("CP05"), "a Level 2 checkpoint saves")
	main._on_quit_to_title()
	await physics_frames(2)

	Session.new_run()  # a fresh boot
	check(CheckpointService.has_valid_save(), "the title offers Continue for the Level 2 save")
	main._title.attempt_continue()
	await physics_frames(3)
	var level: LevelDirector = main._level
	check(level != null and level.level_def.id == "L02", "Continue loads Level 2")
	if level:
		var marker := level.areas[5].get_marker("Respawn_CP05")
		check(level.hero.global_position.distance_to(marker.global_position) < 12.0, "Dave is back at Level 2's CP05")
	check_eq(Session.current_level_id(), "L02", "Session is in Level 2 again")
	check(Session.is_collected("L02-A01-G001"), "the Level 2 chip is still collected")
	check_eq(Session.get_wallet(), 1, "the wallet is restored")
	main._on_quit_to_title()
	await physics_frames(2)
	main.queue_free()
	await physics_frames(2)
	CheckpointService.clear()


# --- 7. the --level debug flag's function -------------------------------------------------

func _test_level_flag() -> void:
	var main_script: Script = load("res://scripts/main.gd")
	check_eq(main_script.level_flag(PackedStringArray(["--filter=x", "--level=L02"])), "L02", "--level=L02 is read")
	check_eq(main_script.level_flag(PackedStringArray(["--filter=x"])), "", "no --level, no level")

	Session.new_run()
	var main: Node = load(MAIN_SCENE).instantiate()
	add_child(main)
	await physics_frames(2)
	check(not main.start_level_direct("L09"), "an unknown level is refused")
	check(main._title != null and main._level == null, "...and the title stays")

	check(main.start_level_direct("L02"), "--level=L02 starts Level 2")
	await physics_frames(3)
	check(main._title == null, "no title")
	var level: LevelDirector = main._level
	check(level != null and level.level_def.id == "L02", "Level 2 is built")
	check_eq(Session.state, Session.default_state("L02"), "with the default campaign state")
	check_eq(Session.state["completed_levels"], ["L01"], "the levels before it count as completed")
	if level:
		var spawn := level.areas[0].get_marker("Spawn_CP00")
		check(level.hero.global_position.distance_to(spawn.global_position) < 12.0, "Dave is at Level 2's CP00")

	check(main.start_level_direct("L01"), "--level=L01 starts Level 1")
	await physics_frames(3)
	level = main._level
	check(level != null and level.level_def.id == "L01" and level.areas.size() == 6, "Level 1 is built with its six areas")
	check_eq(Session.state, Session.default_state("L01"), "with a fresh Level 1 run")
	check_eq(get_tree().get_nodes_in_group("hero").size(), 1, "one hero after switching levels")
	main._on_quit_to_title()
	await physics_frames(2)
	main.queue_free()
	await physics_frames(2)
