extends StaticBody2D
## The glass partition at the far bank of one of Level 2's A04 lockdown lanes
## (M2, C59): solid while its lane's rack waits, it slides up out of the way
## the moment the rack docks (rail_rack.gd's `arrived`) and stays open. Like a
## Block, `position` is its TOP-LEFT corner and `size` its extent. It decides
## its own state in `_ready()` from Session: a level built with the lane's
## switch already on (the rack starts docked) has it open. Opening only ever
## removes collision, so it can never close on Dave. No `class_name`
## (import-cache rule).

signal opened

const FRAME := Color("#2E3B4E")
const OUTLINE := Color("#05070B")
const GLASS := Color(0.25, 0.88, 0.82, 0.24)
const GLASS_EDGE := Color(0.62, 0.95, 0.92, 0.55)
const AMBER := Color("#FFB02E")
const TEAL := Color("#3FE0D0")
## What is left showing of an open partition: its housing at the top.
const STUB := 18.0
## Batch 7: the painted sliding glass partition (scripts/world/lab_skins.gd "partition") fills
## the partition's height, centred on it and squeezed to PAINTED_WIDTH (a pane on its floor-rail
## shoe, turned a little toward the lane); open, it has slid up into the ledge and only its shoe
## shows under it. The lamps stay the state cue.
const LabSkins := preload("res://scripts/world/lab_skins.gd")
const PAINTED_WIDTH := 64.0
## Texel rows of the painted pane's foot (its rail shoe) still showing when it is open.
const SHOE_ROWS := 26.0

@export var size: Vector2 = Vector2(16, 184)
## The lane's RailRack, whose arrival opens this partition.
@export var rack_path: NodePath
## The lane's Session switch (an already-used lane starts open).
@export var switch_id: String = ""

var is_open: bool = false
var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 1  # world
	collision_mask = 0
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape.shape = rect
	_shape.position = size * 0.5
	add_child(_shape)  # generated, never saved
	var rack := get_node_or_null(rack_path)
	if rack and rack.has_signal("arrived"):
		rack.arrived.connect(open)
	if switch_id != "" and Session != null and Session.get_switch(switch_id):
		_set_open(true)
	queue_redraw()


## Slides the partition out of the way (once).
func open() -> void:
	if is_open:
		return
	_set_open(true)
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"door_unlock", global_position + size * 0.5)
	opened.emit()


func _set_open(value: bool) -> void:
	is_open = value
	_shape.set_deferred("disabled", value)
	queue_redraw()


func _draw() -> void:
	if LabSkins.has("partition"):
		_draw_painted()
		return
	if is_open:
		# Retracted into its housing at the top, its lamp teal.
		var housing := Rect2(Vector2(-6.0, 0.0), Vector2(size.x + 12.0, STUB))
		draw_rect(housing, FRAME)
		draw_rect(housing, OUTLINE, false, 2.0)
		draw_circle(Vector2(size.x * 0.5, STUB + 6.0), 7.0, Color(TEAL, 0.22))
		draw_circle(Vector2(size.x * 0.5, STUB + 6.0), 3.0, TEAL)
		return
	# A tall pane of tinted glass on a floor rail: a teal sheen with two
	# diagonal glints, steel jambs top and bottom, and an amber lamp at its foot.
	var pane := Rect2(Vector2(-6.0, 0.0), Vector2(size.x + 12.0, size.y))
	draw_rect(pane, GLASS)
	for k in 2:
		var y0 := size.y * (0.25 + 0.35 * k)
		draw_line(Vector2(pane.position.x + 2.0, y0 + 14.0), Vector2(pane.end.x - 2.0, y0), GLASS_EDGE, 1.5)
	draw_line(Vector2(pane.position.x + 1.0, STUB), Vector2(pane.position.x + 1.0, size.y - 8.0), GLASS_EDGE, 1.0)
	draw_line(Vector2(pane.end.x - 1.0, STUB), Vector2(pane.end.x - 1.0, size.y - 8.0), GLASS_EDGE, 1.0)
	draw_rect(Rect2(pane.position, Vector2(pane.size.x, STUB)), FRAME)
	draw_rect(Rect2(Vector2(pane.position.x, size.y - 8.0), Vector2(pane.size.x, 8.0)), FRAME)
	draw_rect(pane, OUTLINE, false, 2.0)
	# The amber rail lamp at its foot: this lane is still shut.
	draw_circle(Vector2(size.x * 0.5, size.y - 18.0), 8.0, Color(AMBER, 0.25))
	draw_circle(Vector2(size.x * 0.5, size.y - 18.0), 3.0, AMBER)


func _draw_painted() -> void:
	var e := LabSkins.entry("partition")
	var tw: float = float(e["size"][0])
	var th: float = float(e["size"][1])
	var sc: float = size.y / th
	var sx: float = minf(1.0, PAINTED_WIDTH / (tw * sc))
	var cx: float = size.x * 0.5
	if is_open:
		# Slid up into the ledge: its rail shoe hangs under it, the lamp teal.
		LabSkins.draw_rows(self, "partition", th - SHOE_ROWS, th, 0.0, sc, LabSkins.DIM, false, cx, sx)
		var lamp := Vector2(cx, SHOE_ROWS * sc + 6.0)
		draw_circle(lamp, 7.0, Color(TEAL, 0.22))
		draw_circle(lamp, 3.0, TEAL)
		return
	LabSkins.draw_rows(self, "partition", 0.0, th, 0.0, sc, LabSkins.DIM, false, cx, sx)
	# The amber rail lamp at its foot: this lane is still shut.
	draw_circle(Vector2(cx, size.y - 18.0), 8.0, Color(AMBER, 0.25))
	draw_circle(Vector2(cx, size.y - 18.0), 3.0, AMBER)
