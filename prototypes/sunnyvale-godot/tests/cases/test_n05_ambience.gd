extends TestCase
## N05: which ambience bed plays where the hero stands (scripts/audio/ambience_map.gd,
## driven by LevelDirector.update_ambience() and main.gd's title).
## Contracts under test:
##   1. The decision table: every area before and after the lockdown, the depot's
##      core room, the exit yard that keeps its own bed, and an unknown area.
##   2. The core room has an entry radius and a wider exit radius (no flicker).
##   3. Starting a level sets the bed for the saved checkpoint immediately (no fade
##      from another bed), before and after the lockdown, at every checkpoint area.
##   4. The hero crossing areas changes the bed on its own, the core room switches
##      it, and `awakening_done` going live swaps it for the lockdown bed (exit
##      yard excepted) and back again.
##   5. Main: the title is silent, New Game and Continue start on the right bed, and
##      quitting to the title silences it again.
##   6. An area scene on its own (no LevelDirector) does not touch the ambience.
##
## Main-flow checks run under a throwaway playtest directory and never write a save
## (a snapshot is adopted in memory); the runner already points CheckpointService at a
## throwaway save dir. Like the other audio cases it reads `Audio.current_ambience()`
## rather than waiting out the 2 s crossfade.

const AmbienceMap := preload("res://scripts/audio/ambience_map.gd")
const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const MAIN_SCENE := "res://scenes/main.tscn"

const NONE := &"none"
const CAMPUS := &"amb_campus_night"
const ROOF := &"amb_roof_night"
const PLAZA := &"amb_plaza_wet"
const DEPOT := &"amb_depot_hum"
const CORE := &"amb_server_core"
const LOCKDOWN := &"amb_lockdown_bed"
const YARD := &"amb_wicket_yard"

## Area id -> [bed before the lockdown, bed after it]. The depot's core room is
## checked on its own below.
const TABLE := {
	"L01-A01": [CAMPUS, LOCKDOWN],
	"L01-A02": [CAMPUS, LOCKDOWN],
	"L01-A03": [ROOF, LOCKDOWN],
	"L01-A04": [PLAZA, LOCKDOWN],
	"L01-A05": [DEPOT, LOCKDOWN],
	"L01-A06": [YARD, YARD],
}

## Checkpoint -> [bed before the lockdown, bed after it], by where the hero is placed.
## CP04 sits 70 px from the core node; UPG01 (the workbench) is far outside the room.
const CHECKPOINT_BEDS := {
	"CP00": [CAMPUS, LOCKDOWN],
	"CP01": [CAMPUS, LOCKDOWN],
	"CP02": [ROOF, LOCKDOWN],
	"CP03": [PLAZA, LOCKDOWN],
	"CP06": [PLAZA, LOCKDOWN],
	"CP04": [CORE, LOCKDOWN],
	"UPG01": [DEPOT, LOCKDOWN],
	"CP07": [YARD, YARD],
	"CP05": [YARD, YARD],
}

var _telemetry_dir: String = ""


func run() -> void:
	_test_decision_table()
	_test_core_room_hysteresis()
	_test_beds_are_real_loops()
	await _test_area_scene_alone_leaves_ambience_alone()
	await _test_level_start_sets_the_bed()
	await _test_walking_and_awakening()
	await _test_main_flow()
	Audio.set_ambience(NONE)


# --- 1. the decision table --------------------------------------------------------

func _test_decision_table() -> void:
	for area_id in TABLE:
		var beds: Array = TABLE[area_id]
		check_eq(AmbienceMap.bed_for(area_id, false), beds[0], "%s before the lockdown" % area_id)
		check_eq(AmbienceMap.bed_for(area_id, true), beds[1], "%s after the lockdown" % area_id)
		# Standing in the core room matters only in the depot, and only before the lockdown.
		var in_room_before: StringName = CORE if area_id == "L01-A05" else beds[0]
		check_eq(AmbienceMap.bed_for(area_id, false, true), in_room_before,
				"%s before the lockdown, hero in the core room" % area_id)
		check_eq(AmbienceMap.bed_for(area_id, true, true), beds[1],
				"%s after the lockdown, hero in the core room" % area_id)

	check_eq(AmbienceMap.bed_for("L01-A05", false, false), DEPOT, "depot outside the core room is the depot hum")
	check_eq(AmbienceMap.bed_for("L01-A05", false, true), CORE, "depot core room is the server core bed")
	check_eq(AmbienceMap.bed_for("L01-A05", true, true), LOCKDOWN, "the core room is the lockdown bed once the lockdown is on")
	check_eq(AmbienceMap.bed_for("L01-A06", false), YARD, "the exit yard keeps its bed even before the lockdown")
	check_eq(AmbienceMap.bed_for("", false), NONE, "no area id before the lockdown is silence")
	check_eq(AmbienceMap.bed_for("L99-A01", false), NONE, "an unknown area before the lockdown is silence")
	check_eq(AmbienceMap.bed_for("", true), LOCKDOWN, "no area id after the lockdown is the lockdown bed")
	# The bed that is the lockdown alarm bed is never used before the lockdown.
	for area_id in TABLE:
		check(AmbienceMap.bed_for(area_id, false, true) != LOCKDOWN and AmbienceMap.bed_for(area_id, false) != LOCKDOWN,
				"%s never plays the lockdown bed before the lockdown" % area_id)


# --- 2. the core room's edge ------------------------------------------------------

func _test_core_room_hysteresis() -> void:
	var core_x := AmbienceMap.CORE_NODE_X
	var enter := AmbienceMap.CORE_ROOM_ENTER
	var leave := AmbienceMap.CORE_ROOM_EXIT
	check(leave > enter, "the core room is left past a wider radius than it is entered by")
	check(AmbienceMap.in_core_room(core_x, core_x, false), "standing at the core node is in the room")
	check(AmbienceMap.in_core_room(core_x + enter - 1.0, core_x, false), "just inside the entry radius, from outside, is in")
	check(AmbienceMap.in_core_room(core_x - enter + 1.0, core_x, false), "just inside the entry radius on the left, from outside, is in")
	check(not AmbienceMap.in_core_room(core_x + enter + 1.0, core_x, false), "just past the entry radius, from outside, is out")
	check(not AmbienceMap.in_core_room(core_x - enter - 1.0, core_x, false), "just past the entry radius on the left, from outside, is out")
	check(AmbienceMap.in_core_room(core_x + enter + 1.0, core_x, true), "between the radii, from inside, stays in")
	check(AmbienceMap.in_core_room(core_x - enter - 1.0, core_x, true), "between the radii on the left, from inside, stays in")
	check(not AmbienceMap.in_core_room(core_x + leave + 1.0, core_x, true), "past the exit radius, from inside, is out")
	check(not AmbienceMap.in_core_room(core_x - leave - 1.0, core_x, true), "past the exit radius on the left, from inside, is out")
	# The fallback matches the scene, and the room fits inside the depot.
	var depot: AreaRoot = (load("res://scenes/levels/areas/a05_depot.tscn") as PackedScene).instantiate()
	var core := depot.get_node_or_null("Entities/CoreNode") as Node2D
	check(core != null, "the depot has an Entities/CoreNode the director can read")
	if core:
		check_eq(core.position.x, core_x, "the map's fallback x is where a05_depot.tscn puts the core node")
		check(core.position.x - leave > 0.0 and core.position.x + leave < depot.width,
				"the whole core room lies inside the depot")
	depot.free()


func _test_beds_are_real_loops() -> void:
	var used: Dictionary = {}
	for area_id in TABLE:
		for bed in TABLE[area_id]:
			used[bed] = true
	used[CORE] = true
	for bed in used:
		check(Audio.has_ambience(bed), "the table's bed has a loaded loop: %s" % String(bed))


# --- 6. an area on its own ---------------------------------------------------------

func _test_area_scene_alone_leaves_ambience_alone() -> void:
	Audio.set_ambience(&"amb_plaza_wet")
	var area = await spawn("res://scenes/levels/areas/a01_gate.tscn")
	await physics_frames(3)
	check_eq(Audio.current_ambience(), PLAZA, "an area scene instanced without a LevelDirector does not change the bed")
	area.queue_free()
	await physics_frames(2)
	Audio.set_ambience(NONE)


# --- 3. starting a level -----------------------------------------------------------

func _test_level_start_sets_the_bed() -> void:
	for checkpoint in CHECKPOINT_BEDS:
		for awake in [false, true]:
			Session.new_run()
			Session.state["checkpoint_id"] = checkpoint
			Session.set_story("awakening_done", awake)
			Audio.set_ambience(NONE)  # the title is silent when a level starts
			var level: LevelDirector = load(LEVEL_01).instantiate()
			add_child(level)
			# Set by _ready() itself, with no frame needed (so nothing fades in from another bed).
			var expected: StringName = CHECKPOINT_BEDS[checkpoint][1 if awake else 0]
			check_eq(Audio.current_ambience(), expected,
					"level started at %s %s the lockdown: bed set before the first frame" % [checkpoint, "after" if awake else "before"])
			await physics_frames(2)
			check_eq(Audio.current_ambience(), expected,
					"level started at %s %s the lockdown: bed unchanged a frame later" % [checkpoint, "after" if awake else "before"])
			level.queue_free()
			await physics_frames(2)
	Session.new_run()
	Audio.set_ambience(NONE)


# --- 4. walking, the core room and the awakening ----------------------------------

func _test_walking_and_awakening() -> void:
	Session.new_run()
	Audio.set_ambience(NONE)
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	level.hero.debug_invulnerable = true
	check_eq(Audio.current_ambience(), CAMPUS, "a new run starts on the campus night bed")

	# Each area's start (a few px in), before the lockdown.
	for i in level.areas.size():
		var area: AreaRoot = level.areas[i]
		await _put_hero(level, area.global_position.x + 40.0)
		var beds: Array = TABLE[area.area_id]
		check_eq(Audio.current_ambience(), beds[0], "walking into %s before the lockdown plays %s" % [area.area_id, String(beds[0])])
		check_eq(level.ambience_bed(), beds[0], "the director's own bed for %s before the lockdown" % area.area_id)

	# The depot's core room, and the hysteresis at its edge.
	var depot: AreaRoot = level.areas[4]
	var core_x: float = (depot.get_node("Entities/CoreNode") as Node2D).position.x
	await _put_hero(level, depot.global_position.x + core_x)
	check_eq(Audio.current_ambience(), CORE, "next to the core node plays the server core bed")
	await _put_hero(level, depot.global_position.x + core_x + AmbienceMap.CORE_ROOM_ENTER + 40.0)
	check_eq(Audio.current_ambience(), CORE, "just past the entry radius, having come from inside, still plays the server core bed")
	await _put_hero(level, depot.global_position.x + core_x + AmbienceMap.CORE_ROOM_EXIT + 40.0)
	check_eq(Audio.current_ambience(), DEPOT, "past the exit radius the depot hum is back")
	await _put_hero(level, depot.global_position.x + core_x + AmbienceMap.CORE_ROOM_ENTER + 40.0)
	check_eq(Audio.current_ambience(), DEPOT, "just past the entry radius, having come from outside, stays on the depot hum")
	await _put_hero(level, depot.global_position.x + core_x - AmbienceMap.CORE_ROOM_ENTER + 40.0)
	check_eq(Audio.current_ambience(), CORE, "walking in from the left plays the server core bed")

	# The awakening happens in the core room: the lockdown bed takes over there.
	Session.set_story("awakening_done", true)
	await physics_frames(2)
	check_eq(Audio.current_ambience(), LOCKDOWN, "the awakening in the core room switches to the lockdown bed")
	check_eq(Audio.current_music(), &"lockdown", "the music goes to lockdown at the same moment")

	# Afterwards: every area but the yard plays the lockdown bed.
	for i in level.areas.size():
		var area: AreaRoot = level.areas[i]
		await _put_hero(level, area.global_position.x + 40.0)
		var beds: Array = TABLE[area.area_id]
		check_eq(Audio.current_ambience(), beds[1], "walking into %s after the lockdown plays %s" % [area.area_id, String(beds[1])])

	# A rollback to before the awakening (death or Restart from checkpoint) goes back.
	await _put_hero(level, level.areas[1].global_position.x + 40.0)
	check_eq(Audio.current_ambience(), LOCKDOWN, "setup: in the gardens after the lockdown")
	Session.set_story("awakening_done", false)
	await physics_frames(2)
	check_eq(Audio.current_ambience(), CAMPUS, "with the flag cleared again the gardens play the campus bed")

	level.queue_free()
	await physics_frames(2)
	Session.new_run()
	Audio.set_ambience(NONE)


## Moves the hero to global x (just above the floor line) and lets the director's
## _process() see it.
func _put_hero(level: LevelDirector, global_x: float) -> void:
	level.hero.global_position = Vector2(global_x, -60.0)
	level.hero.velocity = Vector2.ZERO
	await physics_frames(3)


# --- 5. Main: title, New Game, Continue, quit to title ------------------------------

func _test_main_flow() -> void:
	_telemetry_dir = "user://test_runs/n05_ambience_telemetry_%d" % Time.get_ticks_usec()
	Telemetry.set_playtest_dir(_telemetry_dir)
	Session.new_run()
	Audio.set_ambience(CAMPUS)  # something left playing from before

	var main: Node = load(MAIN_SCENE).instantiate()
	add_child(main)
	await physics_frames(2)
	check_eq(Audio.current_ambience(), NONE, "Main boot: the title screen is silent")

	main._on_new_game_confirmed()
	await physics_frames(3)
	check_eq(Audio.current_ambience(), CAMPUS, "New Game: the first area plays the campus night bed")
	check_eq(Audio.current_music(), &"campus", "New Game: the music is still campus")

	main._on_quit_to_title()
	await physics_frames(2)
	check_eq(Audio.current_ambience(), NONE, "Quit to title: the ambience goes quiet")
	check_eq(Audio.current_music(), &"title", "Quit to title: the music goes to the title theme")

	# Continue after the awakening (the flag is in the snapshot; no signal fires for it).
	var awake_snapshot := _snapshot_at("CP04", true)
	main._on_continue_confirmed(awake_snapshot)
	await physics_frames(3)
	check_eq(Audio.current_ambience(), LOCKDOWN, "Continue after the awakening: the lockdown bed from the start")
	main._on_quit_to_title()
	await physics_frames(2)
	check_eq(Audio.current_ambience(), NONE, "Quit to title after a Continue: silent again")

	# Continue at the exit yard after the lockdown keeps the yard bed.
	main._on_continue_confirmed(_snapshot_at("CP07", true))
	await physics_frames(3)
	check_eq(Audio.current_ambience(), YARD, "Continue in the exit yard: the yard bed")
	main._on_quit_to_title()
	await physics_frames(2)

	# Continue at the core node before the awakening.
	main._on_continue_confirmed(_snapshot_at("CP04", false))
	await physics_frames(3)
	check_eq(Audio.current_ambience(), CORE, "Continue next to the core node before the awakening: the server core bed")
	check_eq(Audio.current_music(), &"depot", "...with the depot music (the core node stands in the depot)")
	main._on_quit_to_title()
	await physics_frames(2)
	check_eq(Audio.current_ambience(), NONE, "Quit to title again: silent")

	# New Game after all of that starts fresh on the campus bed.
	main._on_new_game_confirmed()
	await physics_frames(3)
	check_eq(Audio.current_ambience(), CAMPUS, "New Game again: the campus night bed")
	main._on_quit_to_title()
	await physics_frames(2)
	check_eq(Audio.current_ambience(), NONE, "Quit to title: silent")

	main.queue_free()
	await physics_frames(2)

	Telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
	CheckpointService.remove_dir_recursive(_telemetry_dir)
	CheckpointService.clear()
	Session.new_run()


## A snapshot of a fresh run placed at `checkpoint`, with the awakening flag as given,
## adopted by Main's Continue path in memory (nothing is written to disk).
func _snapshot_at(checkpoint: String, awakened: bool) -> Dictionary:
	Session.new_run()
	Session.state["checkpoint_id"] = checkpoint
	Session.set_story("awakening_done", awakened)
	return Session.state.duplicate(true)
