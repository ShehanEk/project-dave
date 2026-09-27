extends Node2D
## Scripted autopilot over the M2 course (scenes/debug/m2_course.tscn) for
## tools/capture.sh evidence: walks up on the Resident and lets its
## warning->lunge play out while shooting it down, then approaches the
## Clipper's backstop lane, holds during its warning->charge (dodging the
## charge with a reactive jump once it closes in), and once it stalls at the
## backstop walks to the exposed rear motor and shoots it to defeat it.
## Driven reactively (probe-and-react), like m1_demo.gd, rather than
## hand-timed presses.

@onready var hero: Hero = $Course/Hero
@onready var resident: Resident = $Course/Resident
@onready var clipper: Clipper = $Course/Clipper

const RESIDENT_ENGAGE_X := 380.0
const RESIDENT_STAND_RANGE := 230.0
const CLIPPER_DODGE_RANGE := 170.0
## Comfortably more than hero half-width (22) + Clipper half-width (32) so
## the two silhouettes stay visibly separated at the rear-motor kill shot
## (R1-02), instead of the hero's leg merging into the Clipper's shell.
const MOTOR_STAND_RANGE := 64.0
const FINISH_X := 2150.0
## Just past the backstop's right face (course geometry: backstop at
## x=1150, width 48). Waiting here once the wall is cleared, rather than
## continuing to close the distance while the Clipper is still patrolling,
## keeps a safe dodge runway once it acquires and charges.
const CLIPPER_WAIT_X := 1238.0

## True while a jump-pulse coroutine owns "jump" input, so the per-tick
## reactive logic doesn't fight it (mirrors m1_demo.gd).
var _busy := false


func _ready() -> void:
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(200.0, 0.0)
	_run_autopilot()


func _run_autopilot() -> void:
	await get_tree().physics_frame
	while is_instance_valid(hero) and hero.global_position.x < FINISH_X:
		await get_tree().physics_frame
		_tick()
	Input.action_release("move_right")
	Input.action_release("move_left")
	Input.action_release("fire")
	Input.action_release("jump")


func _tick() -> void:
	if _busy:
		return

	if is_instance_valid(clipper):
		match clipper.state:
			Clipper.State.CHARGE:
				var dx: float = absf(clipper.global_position.x - hero.global_position.x)
				if dx < CLIPPER_DODGE_RANGE and hero.is_on_floor():
					_pulse_jump(22)
					return
				Input.action_release("move_right")
				Input.action_release("move_left")
				Input.action_release("fire")
				hero.aim_override = clipper.global_position
				return
			Clipper.State.WINDUP:
				Input.action_release("move_right")
				Input.action_release("move_left")
				Input.action_release("fire")
				hero.aim_override = clipper.global_position
				return
			Clipper.State.STALL:
				_approach_and_shoot(clipper.rear_hit_zone.global_position, MOTOR_STAND_RANGE)
				return
			Clipper.State.PATROL, Clipper.State.RECOVERY:
				if hero.global_position.x >= CLIPPER_WAIT_X:
					Input.action_release("move_right")
					Input.action_release("fire")
					hero.aim_override = clipper.global_position
					return

	if is_instance_valid(resident) and hero.global_position.x >= RESIDENT_ENGAGE_X:
		_approach_and_shoot(resident.global_position, RESIDENT_STAND_RANGE)
		return

	Input.action_release("fire")
	Input.action_press("move_right")
	Input.action_release("move_left")
	hero.aim_override = hero.global_position + Vector2(200.0, -20.0)
	if hero.is_on_floor() and (_gap_ahead() or _wall_ahead()):
		_pulse_jump(24)


func _approach_and_shoot(target: Vector2, stand_range: float) -> void:
	hero.aim_override = target
	var dx: float = target.x - hero.global_position.x
	if absf(dx) > stand_range:
		if dx > 0.0:
			Input.action_press("move_right")
			Input.action_release("move_left")
		else:
			Input.action_press("move_left")
			Input.action_release("move_right")
		Input.action_release("fire")
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")
		Input.action_press("fire")


func _gap_ahead() -> bool:
	var probe_x: float = hero.global_position.x + 34.0
	var y: float = hero.global_position.y
	var space_state := hero.get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(Vector2(probe_x, y - 4.0), Vector2(probe_x, y + 40.0))
	params.collision_mask = 1
	return space_state.intersect_ray(params).is_empty()


func _wall_ahead() -> bool:
	var y: float = hero.global_position.y - 40.0
	var from_x: float = hero.global_position.x + 15.0
	var to_x: float = hero.global_position.x + 32.0
	var space_state := hero.get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(Vector2(from_x, y), Vector2(to_x, y))
	params.collision_mask = 1
	return not space_state.intersect_ray(params).is_empty()


func _pulse_jump(ticks: int) -> void:
	_busy = true
	Input.action_press("jump")
	for i in ticks:
		await get_tree().physics_frame
	Input.action_release("jump")
	_busy = false
