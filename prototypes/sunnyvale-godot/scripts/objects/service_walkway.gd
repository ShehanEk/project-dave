class_name ServiceWalkway
extends StaticBody2D
## Retractable plank gated by Session's switch (L01-SW01 etc.): no collision
## and drawn stowed while retracted, solid and drawn extended once the
## switch is true — including immediately after a reload (`_ready` re-reads
## Session). NEVER retracts again once extended (nothing in this project
## ever sets a switch back to false).

## Revamp (C24) night look: extended, a steel grating plank under the same
## cold-white lit edge as every walkable Block; stowed, a dim folded stub
## with no lit edge (nothing to stand on yet). The matching switch symbol
## is teal when on, amber when off.
const OUTLINE := Color("#05070B")
const FILL := Color("#253449")
const FACE := Color("#19242F")
const TOP_EDGE := Color("#D8E6F0")
const TOP_BEVEL := Color("#5A718C")
const STOWED := Color("#141D2A")
## The painted pixel-art look (objects2 sheet), drawn through PickupSkins: the
## grating strip stretched to the plank (its rim is the lit walkable edge, its
## repeating middle stays in phase with the world x). Stowed, the same piece
## dimmed and cut to the stub, so no lit edge shows. The code-drawn plank
## stays as the fallback.
const PickupSkins := preload("res://scripts/world/pickup_skins.gd")
const PIECE := "service_walkway"
const STOWED_PAINT := Color(0.42, 0.46, 0.56)

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
	if painted_piece() != "":
		PickupSkins.make_crisp(self)
	_refresh()


## The PickupSkins piece this plank draws, or "" for the code-drawn look.
func painted_piece() -> String:
	return PIECE if PickupSkins.has_piece(PIECE) else ""


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
		if painted_piece() != "":
			PickupSkins.draw_sized(self, PIECE, Vector2.ZERO, rect.size, global_position.x)
		else:
			draw_rect(rect, FACE)
			draw_rect(Rect2(rect.position, Vector2(width, minf(9.0, thickness))), FILL)
			var slot := FILL.darkened(0.4)
			var x: float = 8.0
			while x < width - 6.0:
				draw_line(Vector2(x, 5.0), Vector2(x, minf(9.0, thickness - 1.0)), slot, 2.0)
				x += 9.0
			draw_rect(rect, OUTLINE, false, 3.0)
			draw_rect(Rect2(Vector2(0.0, 2.0), Vector2(width, minf(3.0, thickness - 2.0))), TOP_BEVEL)
			draw_rect(Rect2(rect.position, Vector2(width, minf(2.0, thickness))), TOP_EDGE)
		SceneryDraw.draw_switch_symbol(self, Vector2(width * 0.5, -14.0), true)
	else:
		# Stowed against the near edge: a thin folded plank, no walkable span.
		var rect := Rect2(Vector2.ZERO, Vector2(minf(28.0, width), thickness))
		if painted_piece() != "":
			PickupSkins.draw_sized(self, PIECE, Vector2.ZERO, rect.size, NAN, STOWED_PAINT)
		else:
			draw_rect(rect, STOWED)
			draw_line(Vector2(4.0, thickness * 0.5), Vector2(rect.size.x - 4.0, thickness * 0.5), OUTLINE, 1.5)
			draw_rect(rect, OUTLINE, false, 2.0)
		SceneryDraw.draw_switch_symbol(self, Vector2(14.0, -14.0), false)
