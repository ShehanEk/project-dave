class_name RouteSwitch
extends Interactable
## Visible hand lever (L01-SW01). Interact sets Session's switch true;
## idempotent (Session.set_switch no-ops and emits nothing if already set).
## Draws the matching symbol that service_walkway also draws, so the player
## can tell which walkway a given lever controls.

## Revamp (C24) night look: a steel post with a small control box and
## indicator LED; the lever reads amber while off (waiting) and teal once
## pulled, by position as well as color.
const OUTLINE := Color("#05070B")
const POST := Color("#2E3B4E")
const BOX := Color("#1C2A3A")
const RIM := Color(0.36, 0.45, 0.56, 0.55)
const LEVER_OFF := Color("#FFB02E")
const LEVER_ON := Color("#3FE0D0")
## The painted pixel-art look (objects sheet): the lever up while off, down
## once pulled, drawn through ObjectSkins; the code-drawn post and lever below
## stay as the fallback. The matching symbol floats above either.
const ObjectSkins := preload("res://scripts/world/object_skins.gd")
const UP_PIECE := "lever_up"
const DOWN_PIECE := "lever_down"

@export var switch_id: String = "L01-SW01"


func _init() -> void:
	super()
	prompt = "Pull lever"


func _ready() -> void:
	if painted_piece() != "":
		ObjectSkins.make_crisp(self)


## The ObjectSkins piece this lever draws now (up or down), or "" for the
## code-drawn look.
func painted_piece() -> String:
	if not ObjectSkins.has_pieces([UP_PIECE, DOWN_PIECE]):
		return ""
	return DOWN_PIECE if _is_on() else UP_PIECE


func interact(hero: Node) -> void:
	super(hero)
	var was_on := _is_on()
	if Session:
		Session.set_switch(switch_id, true)
	# M6/Audio cue table: "latch" plays here. Only on the actual actuation
	# (never on a repeat interact with the switch already on) — the latch is
	# a one-way action per CONVENTIONS.md, so its sound only fires once too.
	if not was_on:
		var audio := get_node_or_null("/root/Audio")
		if audio:
			audio.play_sfx(&"latch", global_position)
	queue_redraw()


func _is_on() -> bool:
	return Session != null and Session.get_switch(switch_id)


func _draw() -> void:
	var on := _is_on()
	var painted := painted_piece()
	if painted != "":
		ObjectSkins.draw(self, painted)
		SceneryDraw.draw_switch_symbol(self, Vector2(0.0, -84.0), on)
		return
	var lever_col: Color = LEVER_ON if on else LEVER_OFF
	draw_rect(Rect2(Vector2(-9.0, -5.0), Vector2(18.0, 5.0)), BOX)
	draw_rect(Rect2(Vector2(-9.0, -5.0), Vector2(18.0, 5.0)), OUTLINE, false, 1.5)
	draw_rect(Rect2(Vector2(-5.0, -46.0), Vector2(10.0, 41.0)), POST)
	draw_line(Vector2(-3.5, -44.0), Vector2(-3.5, -6.0), RIM, 1.0)
	draw_rect(Rect2(Vector2(-5.0, -46.0), Vector2(10.0, 41.0)), OUTLINE, false, 2.0)
	var box := Rect2(Vector2(-9.0, -56.0), Vector2(18.0, 12.0))
	draw_rect(box, BOX)
	draw_circle(box.get_center() + Vector2(4.0, 0.0), 4.5, Color(lever_col, 0.2))
	draw_circle(box.get_center() + Vector2(4.0, 0.0), 2.0, lever_col)
	draw_rect(box, OUTLINE, false, 1.5)
	var lever_end := Vector2(18.0, -66.0) if on else Vector2(-18.0, -66.0)
	draw_line(Vector2(0.0, -52.0), lever_end, OUTLINE, 8.0)
	draw_line(Vector2(0.0, -52.0), lever_end, lever_col, 5.0)
	draw_circle(lever_end, 5.0, POST)
	draw_circle(lever_end, 5.0, OUTLINE, false, 2.0)
	# Matching symbol (a small triangle), shared with service_walkway.
	SceneryDraw.draw_switch_symbol(self, Vector2(0.0, -84.0), on)
