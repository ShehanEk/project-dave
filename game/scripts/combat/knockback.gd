extends Node
## A blast's push on an enemy body (M3, the Boom Broom): "knockback against small
## enemies, and stagger against larger ones" (w02-boom-broom.md). Added as a child of
## the enemy's CharacterBody2D by `push()`; every physics tick it moves the body
## sideways through `move_and_collide()` (walls stop it, floors let it slide) on top of
## whatever the enemy's own state machine does, and decays to nothing, then frees
## itself. No enemy script has to know about it, and it never touches the enemy's
## velocity, state or timers. A defeated enemy (collision layer 0: the body has become a
## ragdoll or a wreck, which take the killing shot's push themselves) is left alone.
## No class_name (preload it by path, like PixelFx).

const NODE_NAME := "BlastKnockback"

## Signed horizontal speed, px/s (+ right).
var speed: float = 0.0
## px/s^2 it slows by.
var decay: float = 1600.0
## px the body has been moved so far (tests).
var moved: float = 0.0


## Pushes `body` sideways at `velocity_x` px/s, decaying at `decay_rate`. A push while one
## is running keeps the stronger of the two in the new direction. Returns the node, or null
## when `body` is not a live CharacterBody2D.
static func push(body: Node, velocity_x: float, decay_rate: float) -> Node:
	if not (body is CharacterBody2D) or not is_instance_valid(body) or body.is_queued_for_deletion():
		return null
	if (body as CharacterBody2D).collision_layer == 0 or absf(velocity_x) < 1.0:
		return null
	var kb: Node = body.get_node_or_null(NODE_NAME)
	if kb == null:
		kb = new()
		kb.name = NODE_NAME
		body.add_child(kb)
	if signf(kb.speed) != signf(velocity_x) or absf(velocity_x) > absf(kb.speed):
		kb.speed = velocity_x
	kb.decay = maxf(decay_rate, 1.0)
	return kb


func _physics_process(delta: float) -> void:
	var body := get_parent() as CharacterBody2D
	if body == null or body.collision_layer == 0 or absf(speed) < 1.0:
		queue_free()
		return
	var step := Vector2(speed * delta, 0.0)
	var before := body.global_position.x
	var col := body.move_and_collide(step)
	if col != null:
		var n := col.get_normal()
		if absf(n.x) > 0.7:
			# A wall: the push ends there.
			speed = 0.0
		else:
			# A floor or a slope: slide along it.
			body.move_and_collide(col.get_remainder().slide(n))
	moved += absf(body.global_position.x - before)
	speed = move_toward(speed, 0.0, decay * delta)
