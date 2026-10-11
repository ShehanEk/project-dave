extends Node2D
## Death for a lit cutout rig (C35). A person: each rig part becomes a
## RigidBody2D at its current pose, the parts are pinned at their joints,
## the killing shot pushes the part it hit, and the body falls (C28). A
## machine (`pinned = false`): the parts fly apart as loose debris. Once it
## settles (or after SETTLE_TIME) the bodies are removed and the sprites
## stay behind, still, so a pile of bodies or wrecks costs no physics.
##
## Godot 4.7's PinJoint2D angular limits proved unstable in a probe (the
## pinned part spun instead of stopping), so joints only pin positions and
## the limits are enforced here, by turning a part back inside its range.
## The project's default 2D gravity is 0 (gameplay applies its own), so each
## part gets a constant downward force instead.
##
## Ragdoll parts live on physics layer 10 and collide only with the world
## (layer 1): never with the hero, enemies, shots or each other. No
## class_name (import-cache rule).

signal settled(corpse: Node2D, torso_position: Vector2)

const LAYER := 1 << 9
const GRAVITY := 1800.0
const SETTLE_TIME := 3.0
const REST_SPEED := 8.0
const REST_SPIN := 0.6
const REST_HOLD := 0.35
const DETACHED := ["baton"]
## Hands, feet and the head ride on the forearm, shin and torso at their
## pose at death: as separate bodies they twisted past any wrist, ankle or
## neck (a face-first fall folded the head back ~135°). Their collision
## shapes move onto the body they ride on, so they still hit the floor.
## How much harder than the default the limit spring pushes back on these
## joints once they are past their range (inside it they swing freely).
## The hips carry the body's weight in a fall: at 1x a thigh could rest bent
## ~45° past its limit after a sideways fall.
const STIFF_JOINTS := {"near_forearm": 3.0, "far_forearm": 3.0, "near_shin": 2.5, "far_shin": 2.5,
		"near_thigh": 3.0, "far_thigh": 3.0}
const LOCKED := ["near_hand", "far_hand", "near_foot", "far_foot", "head", "port"]
const PartScript := preload("res://scripts/actors/lit/ragdoll_part.gd")

var bodies: Dictionary = {}       # joint name -> RigidBody2D
var parent_of: Dictionary = {}    # child joint -> parent joint (pinned pairs only)
var limits: Dictionary = {}       # child joint -> Vector2(lo, hi), body-relative radians
var _rel: Dictionary = {}         # child joint -> body-relative angle at death
var _age: float = 0.0
var _still: float = 0.0
var _done: bool = false


## Replaces `rig` (a cutout_rig.gd node) with physics bodies under this
## node. `impulse` is a velocity kick (px/s) for the part nearest
## `hit_position`; `base_velocity` is the body's own motion at death.
## `spread` (debris only) throws every part outward from the wreck's
## centre at up to that speed (px/s).
func build(rig: Node2D, impulse: Vector2, hit_position: Vector2, base_velocity: Vector2 = Vector2.ZERO,
		pinned: bool = true, spread: float = 0.0) -> void:
	var hit_joint: String = rig.nearest_joint(hit_position)
	var flipped: bool = rig.facing < 0
	var locked_sprites: Array = []
	var centre: Vector2 = rig.global_position + Vector2(0.0, -24.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(absf(rig.global_position.x) * 13.0)
	for jname in rig.order:
		var joint: Node2D = rig.joints[jname]
		var def: Dictionary = rig.defs[jname]
		if pinned and LOCKED.has(jname):
			locked_sprites.append([rig.sprites[jname], def["parent"], def["collider"], joint.global_transform])
			continue
		var gt: Transform2D = joint.global_transform
		var yaxis := gt.y.normalized()
		var body: RigidBody2D = PartScript.new()
		body.name = jname
		body.collision_layer = LAYER
		body.collision_mask = 1
		body.gravity_scale = 0.0
		body.mass = float(def["mass"])
		body.linear_damp = 0.05
		body.angular_damp = 2.0
		body.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
		body.can_sleep = false
		var mat := PhysicsMaterial.new()
		mat.friction = 0.9
		mat.bounce = 0.05
		body.physics_material_override = mat
		body.add_child(_collider(def["collider"], flipped))
		add_child(body)
		body.global_position = gt.origin
		body.rotation = atan2(-yaxis.x, yaxis.y)
		body.constant_force = Vector2(0.0, GRAVITY * body.mass)
		var sprite: Sprite2D = rig.sprites[jname]
		sprite.get_parent().remove_child(sprite)
		body.add_child(sprite)
		sprite.position = Vector2.ZERO
		sprite.rotation = 0.0
		sprite.scale = Vector2(-rig.texture_scale if flipped else rig.texture_scale, rig.texture_scale)
		body.linear_velocity = base_velocity
		if not pinned:
			mat.bounce = 0.25
			var out := (gt.origin - centre)
			out = out.normalized() if out.length() > 0.5 else Vector2(rng.randf_range(-1.0, 1.0), -1.0).normalized()
			body.linear_velocity += (out + Vector2(0.0, -0.6)).normalized() * spread * rng.randf_range(0.5, 1.0)
			body.angular_velocity = rng.randf_range(-9.0, 9.0)
		bodies[jname] = body
		var parent_name: String = def["parent"]
		if pinned and parent_name != "" and not DETACHED.has(jname):
			parent_of[jname] = parent_name
			_rel[jname] = (-joint.rotation) if flipped else joint.rotation
			if def["limit"] != null:
				var lo := deg_to_rad(float(def["limit"][0]))
				var hi := deg_to_rad(float(def["limit"][1]))
				limits[jname] = Vector2(-hi, -lo) if flipped else Vector2(lo, hi)
	for entry in locked_sprites:
		var sprite: Sprite2D = entry[0]
		# (A part locked onto a locked part, the Staffer's port on its head, rides on whatever
		# the chain ends at: the torso.)
		var holder_name: String = entry[1]
		while not bodies.has(holder_name) and rig.defs.has(holder_name) and String(rig.defs[holder_name]["parent"]) != "":
			holder_name = rig.defs[holder_name]["parent"]
		var holder: RigidBody2D = bodies[holder_name]
		var gt: Transform2D = sprite.global_transform
		sprite.get_parent().remove_child(sprite)
		holder.add_child(sprite)
		sprite.global_transform = gt
		# The locked part's collider, placed in the holder's space.
		var cs := _collider(entry[2], flipped)
		var joint_gt: Transform2D = entry[3]
		var yaxis := joint_gt.y.normalized()
		var part_body_xf := Transform2D(atan2(-yaxis.x, yaxis.y), joint_gt.origin)
		var local := holder.global_transform.affine_inverse() * part_body_xf
		cs.position = local * cs.position
		cs.rotation += local.get_rotation()
		holder.add_child(cs)
	for jname in parent_of:
		var pin := PinJoint2D.new()
		pin.name = "pin_" + jname
		add_child(pin)
		pin.global_position = bodies[jname].global_position
		pin.disable_collision = true
		pin.softness = 0.0
		pin.node_a = pin.get_path_to(bodies[parent_of[jname]])
		pin.node_b = pin.get_path_to(bodies[jname])
	for jname in bodies:
		bodies[jname].reset_physics_interpolation()
		if parent_of.has(jname):
			var lim: Vector2 = limits.get(jname, Vector2(-INF, INF))
			bodies[jname].start(bodies[parent_of[jname]], lim, _rel[jname], STIFF_JOINTS.get(jname, 1.0))
	# The killing shot: most of the push on the part it hit, some on the torso.
	if LOCKED.has(hit_joint):
		hit_joint = rig.defs[hit_joint]["parent"]
	if bodies.has(hit_joint):
		bodies[hit_joint].linear_velocity += impulse
	if bodies.has("torso") and hit_joint != "torso":
		bodies["torso"].linear_velocity += impulse * 0.45
	if bodies.has("baton"):
		bodies["baton"].linear_velocity += impulse * 0.3 + Vector2(0.0, -60.0)
		bodies["baton"].angular_velocity = 3.0 * signf(impulse.x if impulse.x != 0.0 else 1.0)
	rig.queue_free()


func _collider(col: Dictionary, flipped: bool) -> CollisionShape2D:
	var cs := CollisionShape2D.new()
	var mx := -1.0 if flipped else 1.0
	if col["type"] == "circle":
		var c := CircleShape2D.new()
		c.radius = float(col["r"])
		cs.shape = c
		cs.position = Vector2(float(col["c"][0]) * mx, float(col["c"][1]))
	else:
		var a := Vector2(float(col["a"][0]) * mx, float(col["a"][1]))
		var b := Vector2(float(col["b"][0]) * mx, float(col["b"][1]))
		var r := float(col["r"])
		var cap := CapsuleShape2D.new()
		cap.radius = r
		cap.height = a.distance_to(b) + 2.0 * r
		cs.shape = cap
		cs.position = (a + b) * 0.5
		# CapsuleShape2D runs along +y; turn it onto the segment.
		cs.rotation = (b - a).angle() - PI * 0.5
	return cs


func _physics_process(delta: float) -> void:
	if _done:
		return
	_age += delta
	var moving := false
	for jname in bodies:
		var body: RigidBody2D = bodies[jname]
		if body.linear_velocity.length() > REST_SPEED or absf(body.angular_velocity) > REST_SPIN:
			moving = true
			break
	_still = 0.0 if moving else _still + delta
	if (_still >= REST_HOLD and _age > 0.6) or _age >= SETTLE_TIME:
		_freeze()


## Swaps the bodies for plain sprites at their last pose.
func _freeze() -> void:
	_done = true
	var corpse := Node2D.new()
	corpse.name = "Corpse"
	add_child(corpse)
	var torso_pos := Vector2.ZERO
	if bodies.has("torso"):
		torso_pos = bodies["torso"].global_position
	elif not bodies.is_empty():
		for jname in bodies:
			torso_pos += bodies[jname].global_position
		torso_pos /= float(bodies.size())
	for jname in bodies:
		var body: RigidBody2D = bodies[jname]
		var holder := Node2D.new()
		holder.name = jname
		corpse.add_child(holder)
		holder.global_transform = body.global_transform
		for child in body.get_children():
			if child is Sprite2D:
				body.remove_child(child)
				holder.add_child(child)
		holder.reset_physics_interpolation()
	for child in get_children():
		if child != corpse:
			child.queue_free()
	bodies.clear()
	settled.emit(corpse, torso_pos)


## A part's rotation relative to its parent, continuous (for tests).
func relative_angle(jname: String) -> float:
	return bodies[jname].rel if bodies.has(jname) else 0.0


func is_settled() -> bool:
	return _done
