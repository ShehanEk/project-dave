@tool
class_name BlockedPanel
extends StaticBody2D
## Blockout stand-in for armored/backstop geometry: solid to the hero, and
## its HitZone always answers "blocked" — distinct feedback from a
## PracticeTarget's "hit". `position` is the rectangle's top-left corner,
## matching Block's convention.

## Revamp (C24) night look: dark armor plate with a lit top edge (it is
## solid and can be stood on), riveted seams and a diagonal armor rib.
const OUTLINE := Color("#05070B")
const FILL := Color("#26344A")
const PLATE := Color("#1C2A3A")
const RIVET := Color("#0B111A")
const TOP_EDGE := Color("#D8E6F0")
const TOP_BEVEL := Color("#5A718C")

@export var size: Vector2 = Vector2(48, 96):
	set(v):
		size = v
		_rebuild()

@onready var hit_zone: HitZone = $HitZone
var _body_shape: CollisionShape2D
var _hit_shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 1  # world: solid, like a backstop
	collision_mask = 0
	_rebuild()


func _rebuild() -> void:
	if not is_inside_tree():
		return
	if _body_shape == null:
		_body_shape = CollisionShape2D.new()
		add_child(_body_shape)  # generated, not saved
	var rect := RectangleShape2D.new()
	rect.size = size
	_body_shape.shape = rect
	_body_shape.position = size * 0.5

	if _hit_shape == null:
		_hit_shape = CollisionShape2D.new()
		hit_zone.add_child(_hit_shape)
	var hz_rect := RectangleShape2D.new()
	hz_rect.size = size
	_hit_shape.shape = hz_rect
	_hit_shape.position = size * 0.5
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), FILL)
	var inner := Rect2(Vector2(5.0, 8.0), size - Vector2(10.0, 13.0))
	if inner.size.x > 0.0 and inner.size.y > 0.0:
		draw_rect(inner, PLATE)
		draw_line(inner.position, inner.end, FILL, 4.0)
	for i in 3:
		draw_circle(Vector2(size.x * 0.5, size.y * (0.2 + 0.3 * i)), 3.5, RIVET)
	draw_rect(Rect2(Vector2.ZERO, size), OUTLINE, false, 3.0)
	draw_rect(Rect2(Vector2(0.0, 2.0), Vector2(size.x, minf(3.0, size.y - 2.0))), TOP_BEVEL)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, minf(2.0, size.y))), TOP_EDGE)
