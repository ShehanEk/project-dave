class_name PitHazard
extends Area2D
## The one marked exit-pit hazard (layer 8, mask 2 hero_body): on hero entry,
## costs `damage` health and resets the hero to the fixed child Marker2D
## "Reset" (per CONVENTIONS.md/03: "the one marked exit pit costs one
## health and returns to a fixed safe foothold").

const OUTLINE := Color("#332a20")
const STRIPE_A := Color("#c9663f")
const STRIPE_B := Color("#e8b65a")

@export var damage: int = 1
@export var size: Vector2 = Vector2(160.0, 40.0)

@onready var _reset_marker: Marker2D = get_node_or_null("Reset")


func _init() -> void:
	collision_layer = 1 << 7  # layer 8: hazard
	collision_mask = 1 << 1   # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("hero") or not body.has_method("fall_to"):
		return
	var reset_pos: Vector2 = _reset_marker.global_position if _reset_marker else global_position
	body.fall_to(reset_pos, damage)
	# M6/Audio cue table: "pit_fall" plays here, alongside hero.fall_to(...).
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"pit_fall", global_position)


func _draw() -> void:
	var rect := Rect2(-size * 0.5, size)
	draw_rect(rect, STRIPE_A)
	var stripe_w := 16.0
	var x := rect.position.x
	var flip := false
	while x < rect.position.x + rect.size.x:
		if flip:
			draw_rect(Rect2(Vector2(x, rect.position.y), Vector2(minf(stripe_w, rect.end.x - x), rect.size.y)), STRIPE_B)
		x += stripe_w
		flip = not flip
	draw_rect(rect, OUTLINE, false, 3.0)
	# A small warning-triangle mark, redundant with the diagonal stripe shape
	# itself (style guide: warnings must never rely on color alone).
	var tri_c := Vector2(0.0, rect.position.y - 12.0)
	var tri := PackedVector2Array([
		tri_c + Vector2(0.0, -9.0), tri_c + Vector2(9.0, 7.0), tri_c + Vector2(-9.0, 7.0),
	])
	draw_colored_polygon(tri, STRIPE_B)
	draw_polyline(tri, OUTLINE, 2.0, true)
	draw_line(tri_c + Vector2(0.0, -3.0), tri_c + Vector2(0.0, 2.0), OUTLINE, 2.0)
	draw_circle(tri_c + Vector2(0.0, 5.0), 1.4, OUTLINE)
