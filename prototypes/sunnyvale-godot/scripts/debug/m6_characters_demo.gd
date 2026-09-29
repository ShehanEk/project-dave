extends Node2D
## M6 art-pass evidence capture, revamped for the night look (tools/
## capture.sh res://scenes/debug/m6_characters_demo.tscn OUT_DIR frames fps).
## Everything sits on a flat navy night backdrop (#0E1726).
##
##   1. State board (~5 s): a row of Staffer bodies, one per state, then a
##      row of Clipper bodies, each labelled with its state and light. These
##      are bare Visual nodes lifted out of staffer.tscn/clipper.tscn and fed
##      fixed update_pose() values every tick; nothing else of either scene
##      runs, so the board shows the art alone.
##   2. The live Staffer, with real state-machine timing: dormant first (its
##      EncounterGroup held inactive: teal Link, ID-card routine), then
##      activated (amber) through approach/windup (red tell)/lunge/recovery
##      twice, three hits and the disabled collapse (Link dark).
##   3. The Hero's run/interact/jump showcase on the way to...
##   4. ...the live Clipper: patrol (amber lenses), windup and charge (red),
##      stall (motor exposed), three motor hits and the disabled settle
##      (lenses dark).
## No code under test is touched: this only presses named input actions
## like RouteBot, toggles the demo group's public `is_active`, and calls the
## SAME public HitZone.take_hit() API a Scrapjack bolt uses to land damage
## deterministically.
##
## M6_REDUCED_MOTION=1 captures the same sequence with Settings.reduced_motion
## on (visual-only toggle).

const StafferScene := preload("res://scenes/actors/staffer.tscn")
const ClipperScene := preload("res://scenes/actors/clipper.tscn")

@onready var hero: Hero = $Hero
@onready var camera: Camera2D = $Camera
@onready var staffer_group: EncounterGroup = $StafferGroup
@onready var staffer: Staffer = $StafferGroup/Staffer
@onready var clipper: Clipper = $Clipper

const STAFFER_FOCUS := Vector2(300.0, 460.0)
const CLIPPER_FOCUS := Vector2(1850.0, 460.0)
const BOARD_FLOOR_Y := 560.0
const STAFFER_BOARD_FOCUS := Vector2(-1540.0, 470.0)
const CLIPPER_BOARD_FOCUS := Vector2(-620.0, 480.0)
const LABEL_COLOR := Color("#c9d6e6")

## [label, facing, driver] per Staffer board slot.
const STAFFER_BOARD := [
	["dormant: teal", 1, &"dormant"],
	["dormant (left side)", -1, &"dormant"],
	["driven walk: amber", 1, &"walk"],
	["driven walk (left)", -1, &"walk"],
	["wind-up: red tell", 1, &"windup"],
	["lunge: amber", 1, &"lunge"],
	["stumble recovery", 1, &"recovery"],
	["hit: flicker", -1, &"hit"],
	["disabled: dark", 1, &"disabled"],
]
## [label, facing, driver] per Clipper board slot.
const CLIPPER_BOARD := [
	["hunting: amber", -1, &"hunting"],
	["wind-up: red", -1, &"windup"],
	["charge: red", -1, &"charge"],
	["stall: motor exposed", 1, &"stall"],
	["disabled: dark", -1, &"disabled"],
]

var _staffer_board: Array = []  # [visual, facing, driver]
var _clipper_board: Array = []
var _board_t: float = 0.0


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m6_characters_demo")
	if OS.get_environment("M6_REDUCED_MOTION") == "1":
		Settings.set_reduced_motion(true)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(200.0, 0.0)
	# Dormant until the demo activates the encounter (teal Link, ID routine).
	staffer_group.is_active = false
	_build_boards()
	camera.position = STAFFER_BOARD_FOCUS
	camera.zoom = Vector2(1.3, 1.3)
	_run()


func _run() -> void:
	await get_tree().physics_frame
	await _frames(170)
	camera.position = CLIPPER_BOARD_FOCUS
	await _frames(130)
	camera.zoom = Vector2(1.4, 1.4)
	camera.position = STAFFER_FOCUS
	await _staffer_sequence()
	await _hero_showcase_and_walk_to_clipper()
	await _clipper_sequence()
	await _frames(60)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


# --- state board ----------------------------------------------------------------------

func _build_boards() -> void:
	for i in STAFFER_BOARD.size():
		var slot: Array = STAFFER_BOARD[i]
		var pos := Vector2(-1980.0 + 110.0 * i, BOARD_FLOOR_Y)
		var v: Node2D = _lift_visual(StafferScene.instantiate(), pos)
		_staffer_board.append([v, slot[1], slot[2]])
		_add_label(slot[0], pos + Vector2(0.0, -118.0))
	for i in CLIPPER_BOARD.size():
		var slot: Array = CLIPPER_BOARD[i]
		var pos := Vector2(-940.0 + 165.0 * i, BOARD_FLOOR_Y)
		var v: Node2D = _lift_visual(ClipperScene.instantiate(), pos)
		_clipper_board.append([v, slot[1], slot[2]])
		_add_label(slot[0], pos + Vector2(0.0, -112.0))


## Takes the "Visual" subtree out of a never-entered actor instance (so the
## actor's own logic never runs) and places it on the board.
func _lift_visual(actor: Node, pos: Vector2) -> Node2D:
	var v: Node2D = actor.get_node("Visual")
	actor.remove_child(v)
	actor.free()
	v.position = pos
	v.z_index = 1
	add_child(v)
	return v


func _add_label(text: String, pos: Vector2) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", LABEL_COLOR)
	label.size = Vector2(112.0, 16.0)
	label.position = pos - Vector2(56.0, 0.0)
	add_child(label)


func _physics_process(delta: float) -> void:
	_board_t += delta
	var t := _board_t
	for entry in _staffer_board:
		_drive_staffer_board(entry[0], entry[1], entry[2], t)
	for entry in _clipper_board:
		_drive_clipper_board(entry[0], entry[1], entry[2], t)


func _drive_staffer_board(v: Node2D, facing: int, driver: StringName, t: float) -> void:
	match driver:
		&"dormant":
			v.update_pose(facing, false, 0.0, 0.0, false, 0.0, -1.0)
			v.update_drive(false, -1.0)
		&"walk":
			# Walking in place at the real approach speed's phase rate.
			v.update_pose(facing, true, t * 76.8 * 0.06, 0.0, false, 0.0, -1.0)
			v.update_drive(true, -1.0)
		&"windup":
			var lean: float = fmod(t, 1.1) / 0.65
			if lean < 1.0:
				v.update_pose(facing, false, 0.0, lean, true, 0.0, -1.0)
			else:
				v.update_pose(facing, false, 0.0, 0.0, false, 0.0, -1.0)
			v.update_drive(true, -1.0)
		&"lunge":
			v.update_pose(facing, false, 0.0, 1.0, true, 0.0, -1.0)
			v.update_drive(true, -1.0)
		&"recovery":
			v.update_pose(facing, false, 0.0, 0.0, false, 0.0, -1.0)
			v.update_drive(true, minf(fmod(t, 1.4) / 0.8, 1.0))
		&"hit":
			var h: float = maxf(0.0, 0.15 - fmod(t, 0.9))
			v.update_pose(facing, false, 0.0, 0.0, false, h, -1.0)
			v.update_drive(true, -1.0)
		&"disabled":
			# Slowed down (the real collapse lasts 0.35 s) and held mid-fold.
			v.update_pose(facing, false, 0.0, 0.0, false, 0.0, minf(fmod(t, 1.6) / 1.2, 0.6))
			v.update_drive(false, -1.0)


func _drive_clipper_board(v: Node2D, facing: int, driver: StringName, t: float) -> void:
	match driver:
		&"hunting":
			v.update_pose(facing, 0.35, 0.0, 0.0, false, false, false, -1.0)
		&"windup":
			var k: float = minf(fmod(t, 1.2) / 0.8, 1.0)
			v.update_pose(facing, k, k, k, false, false, false, -1.0)
		&"charge":
			v.update_pose(facing, 1.0, 1.0, 1.0, false, false, false, -1.0)
		&"stall":
			v.update_pose(facing, 0.0, 0.0, 0.0, true, false, false, -1.0, 1.0 - fmod(t, 1.6) / 1.6)
		&"disabled":
			v.update_pose(facing, 0.0, 0.0, 0.0, false, false, false, minf(fmod(t, 1.6) / 1.2, 0.55))


# --- live sequences -------------------------------------------------------------------

func _staffer_sequence() -> void:
	# Dormant (teal, ID-card routine) until the encounter activates.
	await _frames(150)
	staffer_group.is_active = true
	# Approach + at least two windup/lunge cycles happen on their own.
	var lunges := 0
	var was_lunge := false
	var guard := 0
	while lunges < 2 and guard < 900:
		await get_tree().physics_frame
		guard += 1
		var is_lunge: bool = staffer.state == Staffer.State.LUNGE
		if is_lunge and not was_lunge:
			lunges += 1
		was_lunge = is_lunge
	await _frames(15)
	# Land 3 hits (Staffer.health = 3) the same way a bolt would, spaced out
	# to see the hit reaction each time, then hold for the disabled collapse.
	for hit in range(3):
		staffer.hit_zone.take_hit(1, staffer.global_position + Vector2(0.0, -40.0), Vector2(1.0, 0.0))
		await _frames(12)
	await _frames(20)


## Walks the Hero across to the Clipper section (run-cycle showcase),
## interacting with the lever on the way (interact pose) and jumping the
## Backstop wall just ahead of it (jump rise/apex/fall/land squash showcase
## — and the only way past: the Backstop is solid on layer 1 like any other
## world geometry, so the Hero must clear it the same way it would clear
## any low obstacle, exactly like the wall the Clipper itself charges into
## moments later).
func _hero_showcase_and_walk_to_clipper() -> void:
	camera.position = (STAFFER_FOCUS + CLIPPER_FOCUS) * 0.5
	Input.action_press("move_right")
	var guard := 0
	while hero.global_position.x < 900.0 and guard < 900:
		await get_tree().physics_frame
		guard += 1
	Input.action_press("interact")
	await _frames(6)
	Input.action_release("interact")
	guard = 0
	while hero.global_position.x < 1480.0 and guard < 900:
		await get_tree().physics_frame
		guard += 1
	Input.action_press("jump")
	# Hold well past the tuned time-to-apex (0.42s = 25 ticks at 60Hz) so the
	# jump isn't cut short — a quick tap would (correctly) only produce a
	# short hop, per hero.gd's own jump-cut behavior, too low to clear the
	# Backstop's 100px height.
	await _frames(30)
	Input.action_release("jump")
	guard = 0
	while hero.global_position.x < 1780.0 and guard < 900:
		await get_tree().physics_frame
		guard += 1
	Input.action_release("move_right")


func _clipper_sequence() -> void:
	camera.position = CLIPPER_FOCUS
	var guard := 0
	while not clipper.is_stalled() and guard < 900:
		await get_tree().physics_frame
		guard += 1
	await _frames(20)
	# Land 3 hits (Clipper.motor_health = 3) on the now-exposed rear motor.
	for hit in range(3):
		clipper.rear_hit_zone.take_hit(1, clipper.global_position, Vector2(1.0, 0.0))
		await _frames(12)
