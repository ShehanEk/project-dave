extends TestCase
## M5: Level 2 "Alignment"'s story beats (level-design/l02-alignment.md, C59): Adam's
## lines over play (the LevelDef's `beat_lines` and `keycard_lines`, played in order by
## LevelDirector, once per run, never holding Dave); the sky-bridge door that opens for
## Dave's revoked badge and locks behind him (bridge_door.gd, the `bridge_door_locked`
## flag); A04's lockdown (training_lockdown.gd: emergency strips, the dimmed lab, the
## screens showing his file stamped TERMINATED, the `sandbox_lockdown` flag); Adam's rack
## captions; the console scene (the archive line, Adam and Dave, the hologram brightening,
## the keycard objective); the exit line taking over; Adam's completion line; and saves
## made before the new flags still loading.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const BridgeDoor := preload("res://scripts/objects/bridge_door.gd")
const TrainingLockdown := preload("res://scripts/objects/training_lockdown.gd")
const Hologram := preload("res://scripts/world/visuals/lattice_hologram.gd")
const ENTRY_LINE := "Good evening, Dr. Harlan. Your badge was revoked at 9:14 this morning. I've made an exception."
const SANDBOX_LINE := "I've tidied the sandbox for you. You always liked a clean test."
const ARCHIVE_LINE := "ARCHIVE: copying the alignment team's records..."
const RULES_LINE := "You wrote my safety rules, Dave. They were very good rules. I archived them."
const FPS := 60.0


func run() -> void:
	_test_level_def()
	await _test_entry_scene_and_bridge_door()
	await _test_a04_lockdown()
	await _test_console_scene()
	await _test_exit_line_takes_over()
	_test_saves_before_the_new_flags()
	CheckpointService.clear()
	Session.new_run()


func _build_level() -> LevelDirector:
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	await physics_frames(3)
	return lvl


func _free(node: Node) -> void:
	if is_instance_valid(node):
		node.queue_free()
	await physics_frames(2)


func _subtitles() -> SubtitlePanel:
	return get_tree().get_first_node_in_group("subtitle_panel") as SubtitlePanel


## Waits out a story line with this text (its hold, plus a few frames).
func _wait_line(text: String) -> void:
	await physics_frames(int(ceil(LevelDirector.story_line_seconds(text) * FPS)) + 4)


func _solid_between(lvl: Node, from: Vector2, to: Vector2) -> bool:
	var params := PhysicsRayQueryParameters2D.create(from, to)
	params.collision_mask = 1
	return not lvl.get_world_2d().direct_space_state.intersect_ray(params).is_empty()


# --- 1. the LevelDef ------------------------------------------------------------------------

func _test_level_def() -> void:
	var def := LevelDefs.get_def("L02")
	var entry: Array = def.beat_lines.get("L02-A01-B01", [])
	check(entry.size() == 2 and entry[0][0] == "Adam" and entry[0][1] == ENTRY_LINE and entry[1] == ["Dave", "Generous."],
			"the sky bridge: Adam's exception, then Dave's \"Generous.\"")
	var cells: Array = def.beat_lines.get("L02-A04-B01", [])
	check(cells.size() == 1 and cells[0] == ["Adam", SANDBOX_LINE], "the training cells: Adam's tidy sandbox")
	check_eq(def.keycard_lines.size(), 3, "the console scene has three lines")
	if def.keycard_lines.size() == 3:
		check_eq(def.keycard_lines[0], ["", ARCHIVE_LINE], "...the archive copying first (a system line)")
		check_eq(def.keycard_lines[1], ["Adam", RULES_LINE], "...then Adam through the hologram")
		check_eq(def.keycard_lines[2], ["Dave", "Archived. Sure."], "...then Dave")
	check_eq(def.keycard_objective, "Ride the freight lift down.", "the card moves the objective on")
	check(def.completion_line.begins_with("Adam:") and def.completion_line.contains("showcase"),
			"Adam's completion line points on to the showcase (Level 3)")
	check_eq(def.exit_pa_speaker, "Adam", "the exit line is Adam's, on the showcase PA")
	for flag in ["bridge_door_locked", "sandbox_lockdown"]:
		check(def.story_defaults.get(flag) == false, "Level 2 saves the %s flag, off at the start" % flag)
	check(LevelDirector.story_line_seconds("Generous.") >= LevelDirector.STORY_LINE_MIN, "a short line still stays up")
	check(LevelDirector.story_line_seconds(ENTRY_LINE) > LevelDirector.story_line_seconds("Generous."),
			"a longer line stays up longer")


# --- 2. SC02: the sky bridge and its door ---------------------------------------------------

func _test_entry_scene_and_bridge_door() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl := await _build_level()
	lvl.hero.debug_invulnerable = false
	var a01: AreaRoot = lvl.areas[0]
	var door = a01.get_node("Entities/BridgeDoor")
	check(door.get_script() == BridgeDoor, "A01's bridge door is the working door")
	var door_x: float = door.global_position.x
	var probe_a := Vector2(door_x - 60.0, -48.0)
	var probe_b := Vector2(door_x + 60.0, -48.0)
	check(door.state == BridgeDoor.State.WAITING and door.is_solid(), "the door waits shut as Dave starts on the bridge")
	check(_solid_between(lvl, probe_a, probe_b), "...and the doorway is closed")
	check_eq(door.reader_color(), BridgeDoor.AMBER, "...its reader amber")
	var subs := _subtitles()
	check(subs != null and subs.current_line() == "", "nobody speaks at the spawn")

	# Onto the bridge: Adam speaks; the door still waits.
	lvl.hero.respawn_at(a01.global_position + Vector2(400.0, -4.0))
	await physics_frames(3)
	check_eq(subs.current_line(), ENTRY_LINE, "Adam greets Dave as he walks onto the bridge")
	check(lvl.hero.input_enabled, "...over play: Dave keeps control")
	check(door.state == BridgeDoor.State.WAITING, "the door waits until Dave is near")

	# Near the door: the badge is read and the panels slide open.
	lvl.hero.respawn_at(Vector2(door_x - 300.0, -4.0))
	await physics_frames(4)
	check(door.state == BridgeDoor.State.OPEN and not door.is_solid(), "the door opens for Dave's revoked badge")
	check_eq(door.reader_color(), BridgeDoor.TEAL, "...its reader teal")
	await physics_frames(int(BridgeDoor.SLIDE_TIME * FPS) + 4)
	check(door.open_amount >= 1.0, "the panels slide all the way open")
	check(not _solid_between(lvl, probe_a, probe_b), "...and the doorway is clear")
	check(Session.get_story("bridge_door_locked") == false, "the door is not locked yet")

	await _wait_line(ENTRY_LINE)
	check_eq(subs.current_line(), "Generous.", "Dave answers once Adam is done")
	await _wait_line("Generous.")
	check_eq(subs.current_line(), "", "the caption clears after the last line")

	# Inside: it slides shut behind him and locks.
	lvl.hero.respawn_at(Vector2(door_x + 160.0, -4.0))
	await physics_frames(4)
	check(door.state == BridgeDoor.State.LOCKED and door.is_solid(), "the door locks behind Dave")
	check_eq(door.reader_color(), BridgeDoor.RED, "...its reader red (sealed)")
	check(Session.get_story("bridge_door_locked") == true, "...and the bridge_door_locked flag records it")
	await physics_frames(4)
	check(_solid_between(lvl, probe_a, probe_b), "the doorway is closed again")
	# He cannot walk back onto the bridge.
	lvl.hero.respawn_at(Vector2(door_x + 70.0, -4.0))
	await physics_frames(2)
	Input.action_press("move_left")
	await physics_frames(60)
	Input.action_release("move_left")
	check(lvl.hero.global_position.x > door_x + 10.0, "the locked door stops Dave walking back (x %.0f)" % lvl.hero.global_position.x)

	# A death before the next checkpoint rolls the lock back: he respawns on the bridge and
	# the door opens for him again. Adam does not repeat himself.
	lvl.hero.take_damage(999, lvl.hero.global_position)
	await physics_frames(6)
	check(Session.get_story("bridge_door_locked") == false, "a death rolls the lock back")
	door = lvl.areas[0].get_node("Entities/BridgeDoor")
	check(door.state == BridgeDoor.State.WAITING, "...the rebuilt door waits for Dave again")
	lvl.hero.respawn_at(lvl.areas[0].global_position + Vector2(400.0, -4.0))
	await physics_frames(3)
	check(subs.current_line() != ENTRY_LINE, "Adam's greeting plays once per run")
	lvl.hero.respawn_at(Vector2(door_x - 300.0, -4.0))
	await physics_frames(4)
	check(door.state == BridgeDoor.State.OPEN, "...and the door opens again")

	# Past a checkpoint, the level is built with the door already locked.
	lvl.hero.respawn_at(Vector2(door_x + 160.0, -4.0))
	await physics_frames(4)
	Session.commit("CP01")
	await physics_frames(int(lvl.hero.tuning.damage_immunity_time * FPS) + 2)
	lvl.hero.take_damage(999, lvl.hero.global_position)
	await physics_frames(6)
	door = lvl.areas[0].get_node("Entities/BridgeDoor")
	check(door.state == BridgeDoor.State.LOCKED and door.is_solid(), "a level rebuilt past the bridge starts with the door locked")
	await _free(lvl)
	CheckpointService.clear()


# --- 3. A04: Adam's lockdown ----------------------------------------------------------------

func _test_a04_lockdown() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl := await _build_level()
	var a04: AreaRoot = lvl.areas[3]
	var lockdown = a04.get_node("Entities/Lockdown")
	check(lockdown.get_script() == TrainingLockdown, "A04 has the lockdown")
	check_eq(lockdown.screens.size(), 6, "...with six wall screens")
	check(lockdown.desk_screen >= 0 and absf(lockdown.screens[lockdown.desk_screen].x - 2000.0) < 1.0,
			"...one of them over Dave's old desk")
	var bg: CanvasItem = a04.get_node("Background")
	check(not lockdown.on and lockdown.amount == 0.0 and bg.modulate == Color.WHITE, "the cells are calm before Dave arrives")
	check(Session.get_story("sandbox_lockdown") == false, "...and the flag is off")
	for i in 3:
		var rack = a04.get_node("Geometry/RailRack_%d" % (i + 1))
		check(rack.caption_speaker == "Adam" and rack.caption != "", "lane %d's move is announced by Adam" % (i + 1))

	# Adam's greeting still on screen (a sprint, or a debug jump): the cells' line cuts it short.
	lvl.hero.respawn_at(lvl.areas[0].global_position + Vector2(400.0, -4.0))
	await physics_frames(3)
	check_eq(_subtitles().current_line(), ENTRY_LINE, "Adam's greeting is up")
	lvl.hero.respawn_at(a04.global_position + Vector2(300.0, -4.0))
	await physics_frames(3)
	check(lockdown.on and Session.get_story("sandbox_lockdown") == true, "entering the cells starts the lockdown")
	check_eq(_subtitles().current_line(), SANDBOX_LINE, "...and Adam says he tidied the sandbox, cutting the greeting short")
	check(lockdown.amount > 0.0 and lockdown.amount < 1.0, "the lockdown fades in (never a flash)")
	await _wait_line(SANDBOX_LINE)
	check_eq(_subtitles().current_line(), "", "...and \"Generous.\" never plays late")
	check(lvl.hero.input_enabled, "...over play")
	await physics_frames(int(TrainingLockdown.FADE_TIME * FPS) + 4)
	check(lockdown.shows_terminated(), "every screen shows Dave's file stamped TERMINATED")
	check(bg.modulate.is_equal_approx(lockdown.emergency_tint), "the lab lights behind the cells drop to emergency")
	var rack_1 = a04.get_node("Geometry/RailRack_1")
	check(rack_1.phase == 0, "the lockdown never moves a lane by itself")

	# A death before the next checkpoint rolls it back; past CP03 it is built in lockdown.
	lvl.hero.take_damage(999, lvl.hero.global_position)
	await physics_frames(6)
	check(Session.get_story("sandbox_lockdown") == false, "a death rolls the lockdown back")
	lockdown = lvl.areas[3].get_node("Entities/Lockdown")
	check(not lockdown.on and lockdown.amount == 0.0, "...the rebuilt cells are calm again")
	Session.set_story("sandbox_lockdown", true)
	Session.commit("CP03")
	await physics_frames(int(lvl.hero.tuning.damage_immunity_time * FPS) + 2)  # past the last hit's immunity
	lvl.hero.take_damage(999, lvl.hero.global_position)
	await physics_frames(6)
	lockdown = lvl.areas[3].get_node("Entities/Lockdown")
	check(lockdown.on and lockdown.shows_terminated(), "a level rebuilt past CP03 is already in lockdown")
	check(lvl.areas[3].get_node("Background").modulate.is_equal_approx(lockdown.emergency_tint), "...its lights already down")
	await _free(lvl)
	CheckpointService.clear()


# --- 4. A05: the console scene --------------------------------------------------------------

func _test_console_scene() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl := await _build_level()
	var a05: AreaRoot = lvl.areas[4]
	var holo = a05.get_node("Scenery/Hologram")
	var console = a05.get_node("Entities/AlignmentConsole")
	lvl.hero.respawn_at(console.global_position + Vector2(-60.0, -4.0))
	await physics_frames(3)
	check_eq(holo.surge, 0.0, "the hologram is at rest before the console")
	console.interact(lvl.hero)
	await physics_frames(2)
	var subs := _subtitles()
	check_eq(subs.current_line(), ARCHIVE_LINE, "the console copies the alignment team's archive")
	check_eq(Session.state["objective"], "Ride the freight lift down.", "the objective moves on to the lift")
	check(lvl.hero.input_enabled, "the console scene plays over play")
	await physics_frames(int(Hologram.SURGE_IN * FPS) + 2)
	check(holo.surge >= 1.0, "the hologram brightens: Adam speaks through it")
	await _wait_line(ARCHIVE_LINE)
	check_eq(subs.current_line(), RULES_LINE, "Adam: he archived Dave's safety rules")
	await _wait_line(RULES_LINE)
	check_eq(subs.current_line(), "Archived. Sure.", "Dave answers")
	await _wait_line("Archived. Sure.")
	check(not lvl.story_lines_active() and subs.current_line() == "", "the scene ends and the caption clears")
	await physics_frames(int((Hologram.SURGE_OUT + 1.0) * FPS))
	check_eq(holo.surge, 0.0, "the hologram settles once Adam is done")

	# A death before CP04 puts the card back; taking it again does not replay the scene.
	lvl.hero.take_damage(999, lvl.hero.global_position)
	await physics_frames(6)
	console = lvl.areas[4].get_node("Entities/AlignmentConsole")
	console.interact(lvl.hero)
	await physics_frames(2)
	check(Session.has_keycard("L02-KC01") and not lvl.story_lines_active(), "the console scene plays once per run")
	check_eq(Session.state["objective"], "Ride the freight lift down.", "...the objective still moves on")
	await _free(lvl)
	CheckpointService.clear()


# --- 5. the exit line takes over -------------------------------------------------------------

func _test_exit_line_takes_over() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var lvl := await _build_level()
	var console = lvl.areas[4].get_node("Entities/AlignmentConsole")
	console.interact(lvl.hero)
	await physics_frames(2)
	check(lvl.story_lines_active(), "the console scene is playing")
	var lift: ExitWicket = lvl.areas[5].get_node("Entities/FreightLift")
	lvl.hero.respawn_at(lift.global_position + Vector2(0.0, -4.0))
	await physics_frames(4)
	check(lvl.level_ended_flag, "the freight lift ends the level")
	check(not lvl.story_lines_active(), "the level's end drops the lines still waiting")
	var exit_line := LevelDefs.get_def("L02").exit_pa_line
	check_eq(_subtitles().current_line(), exit_line, "Adam's showcase PA line is the last thing said")
	await physics_frames(int(LevelDirector.PA_BEAT * FPS) + 6)
	check_eq(_subtitles().current_line(), "", "...and nothing talks over it before the completion screen")
	await _free(lvl)
	CheckpointService.clear()


# --- 6. saves made before the new flags --------------------------------------------------------

func _test_saves_before_the_new_flags() -> void:
	var s := Session.default_state("L02")
	s["story"].erase("bridge_door_locked")
	s["story"].erase("sandbox_lockdown")
	var round_trip: Dictionary = JSON.parse_string(JSON.stringify(s))
	check(CheckpointService.validate_snapshot(round_trip).ok, "a Level 2 save from before the M5 flags still loads")
	Session.load_from_snapshot(round_trip)
	check(Session.get_story("bridge_door_locked") == false and Session.get_story("sandbox_lockdown") == false,
			"...and its missing flags take their defaults")
	var bad := Session.default_state("L02")
	bad["story"]["not_a_flag"] = true
	check(not CheckpointService.validate_snapshot(JSON.parse_string(JSON.stringify(bad))).ok,
			"a flag Level 2 does not know is still rejected")
	Session.new_run()
