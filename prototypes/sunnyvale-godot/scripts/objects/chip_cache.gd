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

## The painted pixel-art look (objects2 sheet), drawn through PickupSkins; the
## code-drawn case below stays as the fallback. The closed cache is the
## painted piece with a soft amber glow on its padlock. Opened, it is dimmed,
## the padlock is painted over with plate and the lid stands ajar over a dark
## gap. All in art px from the piece's top-left corner.
const PickupSkins := preload("res://scripts/world/pickup_skins.gd")
const PIECE := "chip_cache"
const PLATE := Color("#212E42")
const OPENED_PAINT := Color(0.55, 0.58, 0.66)
const LOCK_GLOW := Color(1.0, 0.69, 0.18, 0.15)
const LOCK_CENTER := Vector2(24.0, 19.0)
const LOCK_BOX := Rect2(16.0, 11.0, 15.0, 16.0)
const LID_BOX := Rect2(8.0, 0.0, 32.0, 12.0)
const LID_LIFT := 5.0

@export var value: int = 20

var _opened: bool = false


func _ready() -> void:
	if entity_id != "" and Session and Session.is_collected(entity_id):
		_opened = true
	prompt = "Open" if not _opened else "Empty"
	if painted_piece() != "":
		PickupSkins.make_crisp(self)
	queue_redraw()


## The PickupSkins piece this cache draws, or "" for the code-drawn look.
func painted_piece() -> String:
	return PIECE if PickupSkins.has_piece(PIECE) else ""


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
	if painted_piece() != "":
		_draw_painted()
		return
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


func _draw_painted() -> void:
	if not _opened:
		PickupSkins.draw_standing(self, PIECE)
		var lock := PickupSkins.standing_at(PIECE, LOCK_CENTER)
		draw_circle(lock, 13.0, LOCK_GLOW)
		return
	var tint := OPENED_PAINT
	PickupSkins.draw_standing(self, PIECE, Vector2.ZERO, tint)
	var a := PickupSkins.ART
	# The padlock is gone: its plate patch, then the lid lifted off a dark gap.
	draw_rect(Rect2(PickupSkins.standing_at(PIECE, LOCK_BOX.position), LOCK_BOX.size * a), PLATE * tint)
	var lid := PickupSkins.standing_at(PIECE, LID_BOX.position)
	draw_rect(Rect2(lid, LID_BOX.size * a), LID_OPEN)
	PickupSkins.blit(self, PIECE, LID_BOX, lid - Vector2(0.0, LID_LIFT * a), tint)
