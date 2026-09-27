extends Node2D
## Scripted autopilot over the M1 course (scenes/debug/m1_course.tscn) for
## tools/capture.sh evidence: runs, hops the low steps and the point-blank
## wall/panel, clears the four gaps, walks the low-ceiling corridor, rides
## the moving platform, and pauses to fire at the wall/target/panel.
## Driven reactively (probe-ahead-and-jump) plus a few known x-range "shoot
## here" windows, rather than hand-timed presses, so it tolerates the
## acceleration curve without frame-perfect scripting.

@onready var hero: Hero = $Course/Hero

const SHOOT_WALL_X := Vector2(150.0, 210.0)
## Kept comfortably short of PracticeTarget (x=900, radius 26): stopping here
## (dx >= ~56, versus hero half-width 22) keeps the hero's silhouette visibly
## separate from the target instead of overlapping it (R1-02).
const SHOOT_TARGET_X := Vector2(820.0, 844.0)
const SHOOT_PANEL_X := Vector2(1370.0, 1430.0)
const PLATFORM_ZONE_X := Vector2(3340.0, 3900.0)
const LEDGE_EDGE_X := 3440.0   # last solid ground before the platform gap
const LEDGE_B_START := 3850.0  # far ledge's near edge

@onready var _platform: Node = $Course/MovingPlatform

var _shot_wall := false
var _shot_target := false
var _shot_panel := false
## True while a fire-in-place or jump-pulse coroutine owns the inputs, so the
## per-tick reactive logic below doesn't fight it (e.g. releasing "fire"
## the instant the pause-and-fire coroutine pressed it).
var _busy := false


func _ready() -> void:
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(200.0, 0.0)
	_run_autopilot()


func _run_autopilot() -> void:
	await get_tree().physics_frame
	while is_instance_valid(hero) and hero.global_position.x < 4150.0:
		await get_tree().physics_frame
		_tick()
	# Done: release every held input so the hero settles on FloorFinish
	# instead of running off the end of the authored geometry forever.
	Input.action_release("move_right")
	Input.action_release("move_left")
	Input.action_release("fire")
	Input.action_release("jump")


func _tick() -> void:
	if _busy:
		return
	var x := hero.global_position.x

	if not _shot_wall and x >= SHOOT_WALL_X.x and x <= SHOOT_WALL_X.y:
		_shot_wall = true
		_pause_and_fire(hero.global_position + Vector2(70.0, -70.0), 0.5)
		return
	if not _shot_target and x >= SHOOT_TARGET_X.x and x <= SHOOT_TARGET_X.y:
		_shot_target = true
		_pause_and_fire(Vector2(900.0, 430.0), 0.5)
		return
	if not _shot_panel and x >= SHOOT_PANEL_X.x and x <= SHOOT_PANEL_X.y:
		_shot_panel = true
		_pause_and_fire(Vector2(1466.0, 530.0), 0.5)
		return

	if x >= PLATFORM_ZONE_X.x and x <= PLATFORM_ZONE_X.y:
		_drive_platform_zone(x)
		return

	Input.action_release("fire")
	Input.action_press("move_right")
	hero.aim_override = hero.global_position + Vector2(200.0, -20.0)

	if hero.is_on_floor() and (_gap_ahead() or _wall_ahead()):
		_pulse_jump()


func _drive_platform_zone(x: float) -> void:
	# The platform cycles on its own clock, independent of when the hero
	# arrives. Walk up to the last solid ground, then WAIT there (frozen
	# position is safe — it's still solid floor) until the platform's own
	# position confirms it has actually docked alongside the edge, rather
	# than assuming timing and stepping into the gap.
	if x < LEDGE_EDGE_X:
		Input.action_press("move_right")
		return

	var plat_left: float = _platform.position.x - _platform.width * 0.5
	var plat_right: float = _platform.position.x + _platform.width * 0.5
	var platform_docked_here: bool = plat_left <= LEDGE_EDGE_X + 30.0

	if x < LEDGE_EDGE_X + 20.0 and not platform_docked_here:
		Input.action_release("move_right")  # wait right at the brink
		return

	if plat_right >= LEDGE_B_START - 60.0:
		# Platform's leading edge is close enough to the far ledge: just
		# walk the rest of the way across like ordinary ground.
		Input.action_press("move_right")
		return

	# Aboard and mid-transit: don't outrun the platform (384 px/s would
	# carry the hero off its leading edge into the gap) — stay glued near
	# the front so we're ready to step off the instant it gets close.
	var lead_point: float = _platform.position.x + 40.0
	if x < lead_point:
		Input.action_press("move_right")
	else:
		Input.action_release("move_right")


func _gap_ahead() -> bool:
	var probe_x := hero.global_position.x + 34.0
	var y := hero.global_position.y
	var space_state := hero.get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(Vector2(probe_x, y - 4.0), Vector2(probe_x, y + 40.0))
	params.collision_mask = 1
	return space_state.intersect_ray(params).is_empty()


func _wall_ahead() -> bool:
	var y := hero.global_position.y - 40.0
	var from_x := hero.global_position.x + 15.0
	var to_x := hero.global_position.x + 32.0
	var space_state := hero.get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(Vector2(from_x, y), Vector2(to_x, y))
	params.collision_mask = 1
	return not space_state.intersect_ray(params).is_empty()


## Held close to the full time-to-apex so the arc clears the tallest
## obstacle on the course (the 100px point-blank wall, apex 1.6H=153.6px).
## A short tap here would cut the jump far too low (see the M1 jump-cut
## tests) to clear anything but the lowest steps.
const JUMP_HOLD_TICKS := 24

func _pulse_jump() -> void:
	_busy = true
	Input.action_press("jump")
	for i in JUMP_HOLD_TICKS:
		await get_tree().physics_frame
	Input.action_release("jump")
	_busy = false


func _pause_and_fire(aim_at: Vector2, duration: float) -> void:
	_busy = true
	Input.action_release("move_right")
	hero.aim_override = aim_at
	Input.action_press("fire")
	var t := 0.0
	var dt := 1.0 / float(Engine.physics_ticks_per_second)
	while t < duration:
		await get_tree().physics_frame
		t += dt
	Input.action_release("fire")
	_busy = false
