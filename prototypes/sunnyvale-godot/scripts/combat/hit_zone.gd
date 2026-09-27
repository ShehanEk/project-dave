class_name HitZone
extends Area2D
## Something a player bolt can strike (collision layer 5 "hittable").
## Bolts call take_hit(); the zone answers "hit" (damage accepted) or
## "blocked" (armored shell, inert target that shrugs, etc.) so the bolt can
## show distinct feedback. The owner listens to `hit` for damage.

signal hit(damage: int, hit_position: Vector2, direction: Vector2)

## When true every strike is refused with "blocked" feedback.
@export var blocks: bool = false


func _init() -> void:
	collision_layer = 1 << 4  # layer 5: hittable
	collision_mask = 0
	monitoring = false
	monitorable = true


func take_hit(damage: int, hit_position: Vector2, direction: Vector2) -> StringName:
	if blocks or not monitorable:
		return &"blocked"
	hit.emit(damage, hit_position, direction)
	return &"hit"
