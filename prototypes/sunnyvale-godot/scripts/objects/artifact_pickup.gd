class_name ArtifactPickup
extends Interactable
## One-time story artifact (e.g. A01 / L01-OPT01-A01). Interact records the
## artifact via Session.record_artifact (adds 0 gems) and shows a short
## toast. `entity_id` is the pickup's own stable id; `artifact_id` is the
## whitelisted collectible id stored in the save.

const OUTLINE := Color("#332a20")
const FILL := Color("#c9a34a")
const RING := Color("#efe0be")
const SHINE := Color(1.0, 1.0, 1.0, 0.6)

@export var artifact_id: String = "A01"
@export var toast_text: String = "Welcome Key recorded"

var _collected: bool = false

@onready var _toast: ToastLabel = get_node_or_null("Toast")


func _ready() -> void:
	if Session and Session.has_artifact(artifact_id):
		_collected = true
	queue_redraw()


func can_interact(_hero: Node) -> bool:
	return not _collected


func get_prompt() -> String:
	return "Interact" if not _collected else ""


func interact(hero: Node) -> void:
	super(hero)
	if _collected:
		return
	if Session and Session.record_artifact(artifact_id, entity_id):
		_collected = true
		if _toast:
			_toast.show_message(toast_text)
		queue_redraw()


## The Welcome Key: a small drawn key silhouette (round bow, shaft, two
## teeth) inside a soft cream glow ring — reads as a distinct keepsake, not
## another gem, at gameplay size and in grayscale.
func _draw() -> void:
	if _collected:
		return
	draw_circle(Vector2.ZERO, 18.0, RING)
	draw_circle(Vector2.ZERO, 18.0, OUTLINE, false, 3.0)
	var bow_c := Vector2(-6.0, 0.0)
	draw_circle(bow_c, 7.0, FILL)
	draw_circle(bow_c, 3.2, RING)
	draw_circle(bow_c, 7.0, OUTLINE, false, 2.0)
	draw_circle(bow_c, 3.2, OUTLINE, false, 1.5)
	var shaft_x0: float = bow_c.x + 6.0
	var shaft_x1: float = 11.0
	draw_line(Vector2(shaft_x0, 0.0), Vector2(shaft_x1, 0.0), FILL, 4.0)
	draw_line(Vector2(shaft_x0, 0.0), Vector2(shaft_x1, 0.0), OUTLINE, 4.0 + 1.5)
	draw_line(Vector2(shaft_x0, 0.0), Vector2(shaft_x1, 0.0), FILL, 4.0)
	draw_rect(Rect2(Vector2(7.0, 0.0), Vector2(3.0, 5.0)), FILL)
	draw_rect(Rect2(Vector2(11.0, 0.0), Vector2(3.0, 3.5)), FILL)
	draw_rect(Rect2(Vector2(7.0, 0.0), Vector2(3.0, 5.0)), OUTLINE, false, 1.5)
	draw_rect(Rect2(Vector2(11.0, 0.0), Vector2(3.0, 3.5)), OUTLINE, false, 1.5)
	draw_line(bow_c + Vector2(-3.0, -4.0), bow_c + Vector2(-1.0, -5.5), SHINE, 2.0)
