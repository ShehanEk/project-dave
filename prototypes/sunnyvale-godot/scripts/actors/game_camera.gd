class_name GameCamera
extends Camera2D
## Independent Camera2D (NOT a child of the hero) that follows an assigned
## target with light smoothing and a small look-ahead toward its facing
## direction. Zoom 1 at 1280x720 keeps the H=96 hero at 96/720 = 1/7.5
## screen height, close to the ~1/8 target (recorded in 09).

@export var target: Node2D
@export var look_ahead_distance: float = 90.0
@export var look_ahead_catchup: float = 4.0  ## higher = snappier look-ahead
@export var world_limits: Rect2 = Rect2(-1000000, -1000000, 2000000, 2000000):
	set(v):
		world_limits = v
		_apply_limits()

var _look_ahead: float = 0.0


func _ready() -> void:
	# Follow on physics ticks (not per render frame) so, with physics
	# interpolation on, the camera and the hero are smoothed identically and
	# never drift against each other on high-refresh displays.
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0
	zoom = Vector2.ONE
	_apply_limits()
	make_current()
	if target:
		global_position = target.global_position


func _apply_limits() -> void:
	limit_left = int(world_limits.position.x)
	limit_top = int(world_limits.position.y)
	limit_right = int(world_limits.position.x + world_limits.size.x)
	limit_bottom = int(world_limits.position.y + world_limits.size.y)


func set_world_limits(rect: Rect2) -> void:
	world_limits = rect


## Snaps straight to `target` with no smoothing and clears the look-ahead —
## use this right after `target` is teleported (checkpoint respawn, level
## boot) so the view doesn't visibly pan across the level to catch up.
func reset_position() -> void:
	_look_ahead = 0.0
	if target:
		global_position = target.global_position
	reset_smoothing()
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	if target == null:
		return
	# Look ahead in the direction of travel (the hero may face its aim while
	# backpedalling), falling back to facing when standing still, so hazards
	# ahead of a moving hero are always previewed.
	var dir: float = float(target.facing) if "facing" in target else 1.0
	if "velocity" in target and absf(target.velocity.x) > 20.0:
		dir = signf(target.velocity.x)
	_look_ahead = lerpf(_look_ahead, dir * look_ahead_distance,
			clampf(look_ahead_catchup * delta, 0.0, 1.0))
	global_position = target.global_position + Vector2(_look_ahead, 0.0)
