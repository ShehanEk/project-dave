extends RigidBody2D
## One ragdoll part (see ragdoll.gd). Past its joint's range, a stiff,
## damped spring torque turns it back (with the equal and opposite torque on
## its parent), so the physics solver settles limbs naturally instead of
## fighting a snapped rotation, which could push a limb through the floor.
## Godot 4.7's own PinJoint2D angular limits did not constrain anything in
## probes, so they are left off. No class_name.

## Spring strength and damping, per unit of the part's rotational inertia.
const STIFFNESS := 500.0
const DAMPING := 40.0
## Cap on the spring's angular acceleration (rad/s²), for stability.
const MAX_ACCEL := 400.0
## Far past the range, also stop any spin that pushes further out.
const HARD_MARGIN := deg_to_rad(20.0)

var parent_part: RigidBody2D = null
## Hinges (elbows, knees) and the neck resist harder than the rest.
var stiffness_scale: float = 1.0
var limit := Vector2(-INF, INF)
## Continuous rotation relative to the parent (no wrap at ±180°).
var rel: float = 0.0
var _prev_self: float = 0.0
var _prev_parent: float = 0.0


func start(p_parent: RigidBody2D, p_limit: Vector2, p_rel: float, p_stiffness_scale: float = 1.0) -> void:
	parent_part = p_parent
	stiffness_scale = p_stiffness_scale
	limit = p_limit
	rel = p_rel
	_prev_self = rotation
	_prev_parent = p_parent.rotation if p_parent else 0.0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if parent_part == null or not is_instance_valid(parent_part):
		return
	var self_rot := state.transform.get_rotation()
	var parent_rot := parent_part.rotation
	rel += wrapf((self_rot - _prev_self) - (parent_rot - _prev_parent), -PI, PI)
	_prev_self = self_rot
	_prev_parent = parent_rot
	var err := 0.0
	if rel < limit.x:
		err = rel - limit.x
	elif rel > limit.y:
		err = rel - limit.y
	if err == 0.0:
		return
	var parent_w := parent_part.angular_velocity
	var wrel := state.angular_velocity - parent_w
	if absf(err) > HARD_MARGIN and signf(wrel) == signf(err):
		state.angular_velocity = parent_w
		wrel = 0.0
	# The inertia is not known until the body has been simulated once.
	if state.inverse_inertia <= 0.0 or not is_finite(state.inverse_inertia):
		return
	var inertia := 1.0 / state.inverse_inertia
	var accel := clampf((-err * STIFFNESS - wrel * DAMPING) * stiffness_scale, -MAX_ACCEL * stiffness_scale, MAX_ACCEL * stiffness_scale)
	var torque := accel * inertia
	state.apply_torque(torque)
	parent_part.apply_torque(-torque * 0.5)
