class_name BeatZone
extends Area2D
## Debug/telemetry marker (mask 2 hero_body) for one pacing beat (e.g.
## L01-A02-B03). On hero entry it reports through BeatHub — an
## autoload-free static signal hub — rather than a group broadcast, so a
## later Telemetry system (or the RouteBot) can log it without this object
## needing to know who's listening. Draws nothing in normal play.

@export var beat_id: String = ""
@export var size: Vector2 = Vector2(200.0, 400.0)

## Debug-only: draws the zone's outline when true (project-wide toggle).
static var show_debug_outline: bool = false

const OUTLINE := Color("#365d62", 0.6)

var _shape: CollisionShape2D


func _init() -> void:
	collision_layer = 0
	collision_mask = 1 << 1  # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	add_to_group("beat_zone")
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape.shape = rect
	add_child(_shape)  # generated, not saved
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("hero"):
		return
	BeatHub.get_instance().beat_entered.emit(beat_id, _find_area_id())


func _find_area_id() -> String:
	var p := get_parent()
	while p:
		if p is AreaRoot:
			return p.area_id
		p = p.get_parent()
	return ""


func _draw() -> void:
	if show_debug_outline:
		draw_rect(Rect2(-size * 0.5, size), OUTLINE, false, 2.0)
