class_name GameCamera
extends Camera2D
## Independent Camera2D (NOT a child of the hero) that follows an assigned
## target with light smoothing and a small look-ahead toward its facing
## direction. Zoom 1.2 at 1280x720 shows the H=96 hero at about 1/6.25 of
## the screen height (playtest 2026-10-04: zoom 1, at 1/7.5, read too far
## out). It still shows 533 px each side of the hero, past the 520 px a guard
## or Staffer notices him from, and the look-ahead shows 90 px more ahead.

@export var target: Node2D
@export var look_ahead_distance: float = 90.0
@export var look_ahead_catchup: float = 4.0  ## higher = snappier look-ahead
@export var world_limits: Rect2 = Rect2(-1000000, -1000000, 2000000, 2000000):
	set(v):
		world_limits = v
		_apply_limits()

@export var zoom_level: float = 1.2
var _look_ahead: float = 0.0
## Shooting feel (C37, GameFeel): a kick that springs back and a decaying
## shake, applied as the camera's offset so the follow itself is untouched.
var _kick: Vector2 = Vector2.ZERO
var _shake: float = 0.0
var _shake_rng := RandomNumberGenerator.new()
const KICK_RETURN := 18.0
const SHAKE_DECAY := 14.0


func _ready() -> void:
	# Follow on physics ticks (not per render frame) so, with physics
	# interpolation on, the camera and the hero are smoothed identically and
	# never drift against each other on high-refresh displays.
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0
	zoom = Vector2(zoom_level, zoom_level)
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
	_kick = Vector2.ZERO
	_shake = 0.0
	offset = Vector2.ZERO
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
	_update_feel(delta)


## Kicks the view by `v` px; it springs back over a few frames.
func kick(v: Vector2) -> void:
	_kick += v
	_kick = _kick.limit_length(6.0)


## Shakes the view with a peak of `amount` px, decaying quickly.
func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _update_feel(delta: float) -> void:
	_kick = _kick.lerp(Vector2.ZERO, clampf(KICK_RETURN * delta, 0.0, 1.0))
	_shake = maxf(0.0, _shake - _shake * SHAKE_DECAY * delta - 0.5 * delta)
	var jitter := Vector2.ZERO
	if _shake > 0.05:
		jitter = Vector2(_shake_rng.randf_range(-1.0, 1.0), _shake_rng.randf_range(-1.0, 1.0)) * _shake
	offset = _kick + jitter
