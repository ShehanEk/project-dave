extends Node2D
## Level 2's A04 lockdown (M5, C59 "Adam's lockdown event"): as Dave enters the
## training cells (the pacing beat `beat_id`), the lab lights drop to emergency
## white, every screen in the cells shows his personnel file stamped TERMINATED, the
## lockdown stinger plays, and Adam speaks (the LevelDef's `beat_lines` for the same
## beat). Drawn here: the cold-white emergency strips under the ceiling and the wall
## screens (`screens`, area px). The area's Background (the painted lab behind the
## cells) dims to `emergency_tint`.
##
## The `sandbox_lockdown` story flag records it: a level rebuilt or loaded past this
## point starts in lockdown, and a death before the next checkpoint rolls it back with
## everything else. Scripted and announced (C16): it never moves a lane (they wait for
## their pads) and never touches Dave. The change fades in over FADE_TIME, never a
## flash. Place it at the area's origin. No `class_name` (import-cache rule).

signal started

const PixelFont := preload("res://scripts/world/pixel_font.gd")
const FLAG := "sandbox_lockdown"
const EMERGENCY := Color("#E8F1FF")
const FIXTURE := Color("#3A4658")
const TEAL := Color("#3FE0D0")
const AMBER := Color("#FFB02E")
## The stamp is the lockdown's own red, like the sealed doors' readers.
const RED := Color("#FF3B4E")
const BEZEL := Color("#1C2A3A")
const SCREEN := Color("#061018")
const PORTRAIT := Color("#5A6678")
const TEXT := Color("#DDE6F2")
const OUTLINE := Color("#05070B")
const FADE_TIME := 1.2
const STAMP_ANGLE := -0.16

@export var beat_id: String = "L02-A04-B01"
## The Background's modulate in lockdown (the lab behind the cells, dimmed and cooled).
@export var emergency_tint: Color = Color(0.6, 0.64, 0.76)
## The ceiling's emergency strips: their y (the ceiling's underside), spacing and length,
## along `width`.
@export var strip_y: float = -458.0
@export var strip_spacing: float = 450.0
@export var strip_length: float = 110.0
@export var width: float = 5400.0
## The wall screens' centres (area px) and size; `desk_screen` (an index into
## `screens`) is the one over Dave's old desk, drawn larger.
@export var screens: PackedVector2Array = PackedVector2Array()
@export var screen_size: Vector2 = Vector2(100.0, 62.0)
@export var desk_screen: int = -1
@export var name_line: String = "HARLAN, D."
@export var team_line: String = "ALIGNMENT TEAM"
@export var stamp_text: String = "TERMINATED"

var on: bool = false
## How far the lockdown look has faded in (0 calm, 1 lockdown).
var amount: float = 0.0
var _font: Font


func _ready() -> void:
	z_index = -10
	_font = PixelFont.smooth_font()
	if _font == null:
		_font = ThemeDB.fallback_font
	if Session and Session.get_story(FLAG) == true:
		on = true
		amount = 1.0
	BeatHub.get_instance().beat_entered.connect(_on_beat_entered)
	_apply_tint()
	queue_redraw()


func _exit_tree() -> void:
	var hub := BeatHub.get_instance()
	if hub.beat_entered.is_connected(_on_beat_entered):
		hub.beat_entered.disconnect(_on_beat_entered)


func _on_beat_entered(id: String, _area_id: String) -> void:
	if id == beat_id and not on:
		start()


func start() -> void:
	if on:
		return
	on = true
	if Session:
		Session.set_story(FLAG, true)
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"lockdown")
	started.emit()


func _process(delta: float) -> void:
	var target := 1.0 if on else 0.0
	if amount != target:
		amount = move_toward(amount, target, delta / FADE_TIME)
		_apply_tint()
		queue_redraw()


func _apply_tint() -> void:
	var bg := _background()
	if bg:
		bg.modulate = Color.WHITE.lerp(emergency_tint, amount)


func _background() -> CanvasItem:
	var n := get_parent()
	while n:
		if n is AreaRoot:
			return n.get_node_or_null("Background") as CanvasItem
		n = n.get_parent()
	return null


## True once the screens show the personnel file (for tests).
func shows_terminated() -> bool:
	return amount >= 1.0


func _draw() -> void:
	_draw_strips()
	for i in screens.size():
		var sz := screen_size * (1.3 if i == desk_screen else 1.0)
		_draw_screen(screens[i], sz)


func _draw_strips() -> void:
	var x := strip_spacing * 0.5
	while x < width:
		var r := Rect2(Vector2(x - strip_length * 0.5, strip_y), Vector2(strip_length, 6.0))
		draw_rect(r.grow(2.0), OUTLINE)
		draw_rect(r, FIXTURE)
		if amount > 0.0:
			draw_rect(r, Color(EMERGENCY, amount))
			draw_rect(r.grow_individual(10.0, 3.0, 10.0, 8.0), Color(EMERGENCY, 0.12 * amount))
			# A faint cold wash under the strip.
			var cone := PackedVector2Array([
				r.position + Vector2(0.0, 6.0), r.position + Vector2(strip_length, 6.0),
				r.position + Vector2(strip_length + 60.0, 150.0), r.position + Vector2(-60.0, 150.0),
			])
			var top := Color(EMERGENCY, 0.07 * amount)
			var bottom := Color(EMERGENCY, 0.0)
			draw_polygon(cone, PackedColorArray([top, top, bottom, bottom]))
		x += strip_spacing


func _draw_screen(c: Vector2, sz: Vector2) -> void:
	var outer := Rect2(c - sz * 0.5, sz)
	draw_rect(outer.grow(2.0), OUTLINE)
	draw_rect(outer, BEZEL)
	var inner := outer.grow(-4.0)
	draw_rect(inner, SCREEN)
	if amount < 1.0:
		_draw_idle(inner, 1.0 - amount)
	if amount > 0.0:
		_draw_file(inner, amount)


## The calm screen: abstract teal readouts (no readable text).
func _draw_idle(r: Rect2, a: float) -> void:
	var teal := Color(TEAL, 0.7 * a)
	for i in 3:
		var y := r.position.y + r.size.y * (0.25 + 0.17 * i)
		draw_line(Vector2(r.position.x + 6.0, y), Vector2(r.position.x + r.size.x * (0.55 - 0.1 * i), y), teal, 2.0)
	for i in 4:
		var h := r.size.y * (0.18 + 0.12 * float((i * 7) % 4))
		var bx := r.position.x + r.size.x * 0.66 + i * 7.0
		draw_rect(Rect2(Vector2(bx, r.end.y - 5.0 - h), Vector2(4.0, h)), Color(TEAL, 0.45 * a))


## Dave's personnel file: an amber header, his ID photo, his name and team, and the stamp.
func _draw_file(r: Rect2, a: float) -> void:
	draw_rect(Rect2(r.position, Vector2(r.size.x, 5.0)), Color(AMBER, 0.85 * a))
	var photo := Rect2(r.position + Vector2(5.0, 10.0), Vector2(r.size.y * 0.42, r.size.y * 0.55))
	draw_rect(photo, Color(PORTRAIT, 0.6 * a))
	draw_circle(photo.position + Vector2(photo.size.x * 0.5, photo.size.y * 0.38), photo.size.x * 0.24, Color(TEXT, 0.55 * a))
	draw_rect(Rect2(photo.position + Vector2(photo.size.x * 0.18, photo.size.y * 0.66),
			Vector2(photo.size.x * 0.64, photo.size.y * 0.34)), Color(TEXT, 0.45 * a))
	var fs := int(round(r.size.y * 0.2))
	var tx := photo.end.x + 5.0
	draw_string(_font, Vector2(tx, r.position.y + 10.0 + fs), name_line, HORIZONTAL_ALIGNMENT_LEFT,
			r.end.x - tx - 3.0, fs, Color(TEXT, a))
	draw_string(_font, Vector2(tx, r.position.y + 12.0 + fs * 2), team_line, HORIZONTAL_ALIGNMENT_LEFT,
			r.end.x - tx - 3.0, int(fs * 0.7), Color(TEXT, 0.6 * a))
	# The stamp, tilted across the lower half.
	var sfs := int(round(r.size.y * 0.24))
	var centre := r.position + Vector2(r.size.x * 0.55, r.size.y * 0.74)
	var tw := _font.get_string_size(stamp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, sfs).x
	draw_set_transform(centre, STAMP_ANGLE)
	var box := Rect2(Vector2(-tw * 0.5 - 4.0, -sfs * 0.62), Vector2(tw + 8.0, sfs * 1.05))
	draw_rect(box, Color(RED, 0.9 * a), false, 2.0)
	draw_string(_font, Vector2(-tw * 0.5, sfs * 0.32), stamp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, sfs, Color(RED, a))
	draw_set_transform(Vector2.ZERO)
