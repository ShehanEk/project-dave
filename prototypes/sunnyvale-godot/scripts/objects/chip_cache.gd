class_name ChipCache
extends Interactable
## One-time Interactable chip cache (e.g. L01-OPT02-CACHE01): a dark steel
## component case with a teal latch light. Interact opens it and awards
## `value` chips through Session.collect; stays "opened" forever.

const OUTLINE := Color("#07090F")
const BODY := Color("#1C2A3A")
const LID_CLOSED := Color("#2E3B4E")
const LID_OPEN := Color("#0E1726")
const GOLD := Color("#FFD166")
const LATCH := Color("#3FE0D0")

## M6.5 Kenney integration pass: no class_name on the puff script (see its
## own doc comment) — reached through this plain preload + its static
## `spawn()`.
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")

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
		var host := get_tree().current_scene if get_tree().current_scene else get_tree().root
		KenneyPuff.spawn(&"chip_sparkle_cluster", global_position + Vector2(0.0, -48.0), host)


func _draw() -> void:
	# Bottom-anchored: local origin sits on the ground the cache rests on.
	var w := 56.0
	var h := 36.0
	var body := Rect2(Vector2(-w * 0.5, -h), Vector2(w, h))
	draw_rect(body, BODY)
	for x in [-16.0, 0.0, 16.0]:
		draw_line(Vector2(x, -h + 6.0), Vector2(x, -6.0), Color(LID_CLOSED, 0.8), 2.0)
	if _opened:
		draw_rect(Rect2(Vector2(-w * 0.5, -h * 1.45), Vector2(w, h * 0.35)), LID_OPEN)
		draw_rect(Rect2(Vector2(-w * 0.5, -h * 1.45), Vector2(w, h * 0.35)), OUTLINE, false, 2.0)
	else:
		var lid := Rect2(Vector2(-w * 0.5 - 2.0, -h - 8.0), Vector2(w + 4.0, 10.0))
		draw_rect(lid, LID_CLOSED)
		draw_rect(lid, OUTLINE, false, 2.0)
		draw_circle(Vector2(0.0, -h - 3.0), 7.0, Color(LATCH, 0.25))
		draw_circle(Vector2(0.0, -h - 3.0), 3.0, LATCH)
		draw_circle(Vector2(-14.0, -h * 0.5), 3.0, GOLD)
	draw_rect(body, OUTLINE, false, 3.0)
