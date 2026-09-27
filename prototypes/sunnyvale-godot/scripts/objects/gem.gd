class_name Gem
extends Area2D
## Contact pickup (layer 7 pickup, mask 2 hero_body). `value` 1 = a small
## loose gem; 5 = a cluster, drawn visibly larger/as a small cluster of
## facets. Absent if Session already recorded `entity_id` as collected.

const OUTLINE := Color("#332a20")
const FILL := Color("#f4d35e")
const FILL_CLUSTER := Color("#e0a72e")
const SHINE := Color("#fff6d9")
const CLUSTER_VALUE := 5

@export var entity_id: String = ""
@export var value: int = 1


func _init() -> void:
	collision_layer = 1 << 6  # layer 7: pickup
	collision_mask = 1 << 1   # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	if entity_id != "" and Session and Session.is_collected(entity_id):
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("hero"):
		return
	if Session and Session.collect(entity_id, value):
		queue_free()


func _is_cluster() -> bool:
	return value >= CLUSTER_VALUE


func _draw() -> void:
	if _is_cluster():
		_draw_gem(Vector2(-8.0, 2.0), 15.0)
		_draw_gem(Vector2(9.0, 4.0), 13.0)
		_draw_gem(Vector2(0.0, -10.0), 17.0)
	else:
		_draw_gem(Vector2.ZERO, 15.0)


func _draw_gem(center: Vector2, r: float) -> void:
	var fill := FILL_CLUSTER if _is_cluster() else FILL
	var pts := PackedVector2Array([
		center + Vector2(0.0, -r),
		center + Vector2(r * 0.75, -r * 0.15),
		center + Vector2(r * 0.4, r * 0.85),
		center + Vector2(-r * 0.4, r * 0.85),
		center + Vector2(-r * 0.75, -r * 0.15),
	])
	draw_colored_polygon(pts, fill)
	draw_polyline(pts, OUTLINE, 2.5, true)
	draw_line(center + Vector2(-r * 0.3, -r * 0.4), center + Vector2(r * 0.15, -r * 0.55), SHINE, 2.0)
