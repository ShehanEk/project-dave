class_name AttackBox
extends Area2D
## Enemy attack sensor. Only while `active` does overlapping the hero's
## hurtbox (layer 4) deal damage. Body/sprite overlap alone never hurts.

@export var damage: int = 1
var active: bool = false:
	set(value):
		active = value
		set_deferred("monitoring", value)
		if value:
			_apply_to_overlaps.call_deferred()


func _init() -> void:
	collision_layer = 0
	collision_mask = 1 << 3  # layer 4: hero_hurtbox
	monitoring = false
	monitorable = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if active:
		_strike(area)


func _apply_to_overlaps() -> void:
	if not active or not monitoring:
		return
	for area in get_overlapping_areas():
		_strike(area)


func _strike(area: Area2D) -> void:
	var target := area.owner if area.owner else area.get_parent()
	if target and target.has_method("take_damage"):
		target.take_damage(damage, global_position)
