class_name ServiceWalkway
extends StaticBody2D
## Retractable plank gated by Session's switch (L01-SW01 etc.): no collision
## and drawn stowed while retracted, solid and drawn extended once the
## switch is true — including immediately after a reload (`_ready` re-reads
## Session). NEVER retracts again once extended (nothing in this project
## ever sets a switch back to false).

const OUTLINE := Color("#332a20")
const FILL := Color("#8a7f6a")
const TOP_EDGE := Color("#e9dfc9")
const STOWED := Color("#5b5548")

@export var switch_id: String = "L01-SW01"
@export var width: float = 192.0
@export var thickness: float = 20.0

var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 1  # world
	collision_mask = 0
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	var rect := RectangleShape2D.new()
	rect.size = Vector2(width, thickness)
	_shape.shape = rect
	_shape.position = Vector2(width * 0.5, thickness * 0.5)
	add_child(_shape)  # generated, not saved
	if Session:
		Session.switch_changed.connect(_on_switch_changed)
	_refresh()


func _exit_tree() -> void:
	if Session and Session.switch_changed.is_connected(_on_switch_changed):
		Session.switch_changed.disconnect(_on_switch_changed)


func _on_switch_changed(changed_switch_id: String, _value: bool) -> void:
	if changed_switch_id == switch_id:
		_refresh()


func is_extended() -> bool:
	return Session != null and Session.get_switch(switch_id)


func _refresh() -> void:
	_shape.disabled = not is_extended()
	queue_redraw()


func _draw() -> void:
	if is_extended():
		var rect := Rect2(Vector2.ZERO, Vector2(width, thickness))
		draw_rect(rect, FILL)
		draw_rect(Rect2(rect.position, Vector2(width, minf(5.0, thickness))), TOP_EDGE)
		draw_rect(rect, OUTLINE, false, 3.0)
		SceneryDraw.draw_switch_symbol(self, Vector2(width * 0.5, -14.0), true)
	else:
		# Stowed against the near edge: a thin folded plank, no walkable span.
		var rect := Rect2(Vector2.ZERO, Vector2(minf(28.0, width), thickness))
		draw_rect(rect, STOWED)
		draw_rect(rect, OUTLINE, false, 2.0)
		SceneryDraw.draw_switch_symbol(self, Vector2(14.0, -14.0), false)
