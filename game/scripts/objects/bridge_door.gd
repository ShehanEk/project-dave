extends StaticBody2D
## Level 2's sky-bridge door (M5, SC02: "The bridge door locks behind him"): the glass
## door at the end of the A01 sky bridge, in the doorway under the coolant plant's
## lintel. It waits shut with an amber reader; as Dave comes along the bridge his
## revoked badge is read anyway (Adam's "I've made an exception", the LevelDef's
## `beat_lines`), the reader turns teal and the panels slide open. Once he is
## `lock_after` px inside, they slide shut behind him and the door locks (a red
## reader: a sealed door), and the `bridge_door_locked` story flag records it, so a
## level rebuilt or loaded past this point starts with it locked; a death before the
## next checkpoint rolls the flag back with everything else, and the door opens for
## him again.
##
## Solid only while shut, and it never shuts on Dave: it opens before he can reach it
## (`open_range`) and locks only once he is past it. Should he ever stand behind the
## locked door (a respawn on the bridge), it opens. No `class_name` (import-cache
## rule): tests preload it by path.

signal opened
signal locked

enum State { WAITING, OPEN, LOCKED }

## The painted glass door (batch 7): the open frame is drawn whole and the closed
## door's two glass panels slide over it from the frame posts. PANEL_LEFT and
## PANEL_RIGHT are the panels in the closed piece's texels.
const LabSkins := preload("res://scripts/world/lab_skins.gd")
const CLOSED_PIECE := "glass_door_closed"
const OPEN_PIECE := "glass_door_open"
const PANEL_LEFT := Rect2(26.0, 40.0, 88.0, 280.0)
const PANEL_RIGHT := Rect2(114.0, 40.0, 88.0, 280.0)
const FLAG := "bridge_door_locked"

const AMBER := Color("#FFB02E")
const TEAL := Color("#3FE0D0")
const RED := Color("#FF3B4E")
const FRAME := Color("#2E3B4E")
const GLASS := Color(0.55, 0.85, 0.95, 0.3)
const OUTLINE := Color("#07090F")
## Seconds the panels take to slide.
const SLIDE_TIME := 0.45

## Dave this close before the door (px, his centre) opens it.
@export var open_range: float = 360.0
## Dave this far past the door locks it behind him.
@export var lock_after: float = 100.0
## The doorway's solid span while shut, from the floor up to the lintel.
@export var height: float = 260.0
@export var thickness: float = 40.0

var state: int = State.WAITING
## How far open the panels are drawn (0 shut, 1 open); the collision follows `state`.
var open_amount: float = 0.0
var _shape: CollisionShape2D


func _init() -> void:
	collision_layer = 1  # world
	collision_mask = 0


func _ready() -> void:
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	var rect := RectangleShape2D.new()
	rect.size = Vector2(thickness, height)
	_shape.shape = rect
	_shape.position = Vector2(0.0, -height * 0.5)
	add_child(_shape)  # generated, not saved
	z_index = -10
	if Session and Session.get_story(FLAG) == true:
		state = State.LOCKED
	queue_redraw()


func is_solid() -> bool:
	return state != State.OPEN


func _physics_process(delta: float) -> void:
	var hero := _hero()
	if hero:
		var dx := hero.global_position.x - global_position.x
		match state:
			State.WAITING:
				if dx > -open_range:
					_open_door()
			State.OPEN:
				if dx > lock_after:
					_lock_door()
			State.LOCKED:
				if dx < -thickness:
					_open_door()
	var target := 1.0 if state == State.OPEN else 0.0
	if open_amount != target:
		open_amount = move_toward(open_amount, target, delta / SLIDE_TIME)
		queue_redraw()


## The hero of the level this door is in (its LevelDirector's), else the first in the group: a
## test that leaves another hero in the tree must not drive this door.
func _hero() -> Node2D:
	var n := get_parent()
	while n:
		if n is LevelDirector:
			return n.hero
		n = n.get_parent()
	return get_tree().get_first_node_in_group("hero") as Node2D


func _open_door() -> void:
	var was_locked := state == State.LOCKED
	state = State.OPEN
	_shape.set_deferred("disabled", true)
	if was_locked and Session:
		Session.set_story(FLAG, false)
	_cue(&"door_unlock")
	opened.emit()
	queue_redraw()


func _lock_door() -> void:
	state = State.LOCKED
	_shape.set_deferred("disabled", false)
	if Session:
		Session.set_story(FLAG, true)
	_cue(&"latch")
	locked.emit()
	queue_redraw()


func _cue(cue: StringName) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue, global_position)


func reader_color() -> Color:
	match state:
		State.OPEN:
			return TEAL
		State.LOCKED:
			return RED
	return AMBER


func painted() -> bool:
	return LabSkins.in_lab(self) and LabSkins.has(CLOSED_PIECE) and LabSkins.has(OPEN_PIECE)


func _draw() -> void:
	var lit := reader_color()
	if painted():
		_draw_painted(lit)
		return
	# Code-drawn fallback: a steel frame, two glass panels and the reader.
	var w := 96.0
	var h := 150.0
	draw_rect(Rect2(Vector2(-w * 0.5, -h), Vector2(w, h)), FRAME, false, 6.0)
	var pw := (w * 0.5 - 6.0) * (1.0 - open_amount)
	if pw > 0.5:
		draw_rect(Rect2(Vector2(-w * 0.5 + 3.0, -h + 3.0), Vector2(pw, h - 6.0)), GLASS)
		draw_rect(Rect2(Vector2(w * 0.5 - 3.0 - pw, -h + 3.0), Vector2(pw, h - 6.0)), GLASS)
	var reader := Vector2(w * 0.5 + 12.0, -70.0)
	draw_rect(Rect2(reader - Vector2(5.0, 9.0), Vector2(10.0, 18.0)), OUTLINE)
	draw_circle(reader, 4.0, lit)


func _draw_painted(lit: Color) -> void:
	LabSkins.draw(self, OPEN_PIECE)
	var shut := 1.0 - open_amount
	if shut > 0.01:
		var s := LabSkins.scale(CLOSED_PIECE)
		var e := LabSkins.entry(CLOSED_PIECE)
		var origin := Vector2(-float(e["anchor_x"]), -float(e["size"][1])) * s
		var tex := LabSkins.texture(CLOSED_PIECE)
		# Each panel slides into its frame post, squeezed toward it.
		var left := Rect2(origin + PANEL_LEFT.position * s, Vector2(PANEL_LEFT.size.x * shut, PANEL_LEFT.size.y) * s)
		draw_texture_rect_region(tex, left, PANEL_LEFT, LabSkins.DIM)
		var rw := PANEL_RIGHT.size.x * shut * s
		var right := Rect2(origin + Vector2(PANEL_RIGHT.end.x * s - rw, PANEL_RIGHT.position.y * s),
				Vector2(rw, PANEL_RIGHT.size.y * s))
		draw_texture_rect_region(tex, right, PANEL_RIGHT, LabSkins.DIM)
	var reader := LabSkins.point(OPEN_PIECE, "reader")
	draw_circle(reader, 9.0, Color(lit, 0.22))
	draw_circle(reader, 3.5, lit)
