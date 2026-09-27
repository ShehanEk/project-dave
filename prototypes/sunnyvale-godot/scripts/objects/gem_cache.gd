class_name GemCache
extends Interactable
## One-time Interactable cache (e.g. L01-OPT02-CACHE01). Interact opens it
## and awards `value` gems through Session.collect; stays "opened" forever.

const OUTLINE := Color("#332a20")
const BODY := Color("#8a6a45")
const LID_CLOSED := Color("#a9834f")
const LID_OPEN := Color("#5a4530")
const GOLD := Color("#f4d35e")

@export var value: int = 20

var _opened: bool = false


func _ready() -> void:
	if entity_id != "" and Session and Session.is_collected(entity_id):
		_opened = true
	prompt = "Open" if not _opened else "Empty"
	queue_redraw()


func can_interact(_hero: Node) -> bool:
	return not _opened


func get_prompt() -> String:
	return "Open" if not _opened else "Empty"


func interact(hero: Node) -> void:
	super(hero)
	if _opened:
		return
	if entity_id != "" and Session and Session.collect(entity_id, value):
		_opened = true
		queue_redraw()


func _draw() -> void:
	# Bottom-anchored: local origin sits on the ground the cache rests on.
	var w := 56.0
	var h := 40.0
	var body := Rect2(Vector2(-w * 0.5, -h), Vector2(w, h))
	draw_rect(body, BODY)
	if _opened:
		draw_rect(Rect2(Vector2(-w * 0.5, -h * 1.35), Vector2(w, h * 0.35)), LID_OPEN)
		draw_circle(Vector2(0.0, -h * 1.05), 6.0, GOLD)
	else:
		draw_rect(Rect2(Vector2(-w * 0.5, -h * 1.15), Vector2(w, h * 0.35)), LID_CLOSED)
	draw_rect(body, OUTLINE, false, 3.0)
