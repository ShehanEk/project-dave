class_name EmergencyHatch
extends StaticBody2D
## Solid door (layer 1: world) that opens (no collision, lit) once
## Session.get_story("hatch_open") is true. Listens for the flag changing
## rather than only checking it once, so a mid-run interact (SC01) opens it
## immediately without needing a scene reload.

## Revamp (C24) night look: closed, a heavy steel door with hazard
## chevrons and a small alarm-red LOCKED light (red = locked); open, the
## slab retracts into the header over a dark doorway, a signal-green exit
## light comes on above it (green = exit) and a teal frame marks it
## unlocked.
const OUTLINE := Color("#05070B")
const CLOSED_FILL := Color("#1F2B3B")
const PANEL := Color("#27364A")
const OPEN_FRAME := Color("#3FE0D0")
const FRAME := Color("#1C2A3A")
const LOCKED := Color("#FF3B4E")
const EXIT_GREEN := Color("#4DE38A")
const HAZARD := Color("#FFB02E")

@export var size: Vector2 = Vector2(64.0, 192.0)

var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 1  # world
	collision_mask = 0
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape.shape = rect
	_shape.position = Vector2(0.0, -size.y * 0.5)
	add_child(_shape)  # generated, not saved
	if Session:
		Session.story_state_changed.connect(_on_story_changed)
	_refresh()


func _exit_tree() -> void:
	if Session and Session.story_state_changed.is_connected(_on_story_changed):
		Session.story_state_changed.disconnect(_on_story_changed)


func _on_story_changed(flag: String, value: Variant) -> void:
	if flag != "hatch_open":
		return
	_refresh()
	# M6/Audio cue table: "hatch_open" plays here, on the LIVE flag flip only
	# (never on `_ready()`'s own initial sync — a reload/Continue/death
	# rebuild after the hatch is already open must not replay the sound).
	if value == true:
		var audio := get_node_or_null("/root/Audio")
		if audio:
			audio.play_sfx(&"hatch_open", global_position)


func is_open() -> bool:
	return Session != null and Session.get_story("hatch_open") == true


func _refresh() -> void:
	_shape.disabled = is_open()
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2(-size.x * 0.5, -size.y), size)
	var frame_w := 6.0
	if is_open():
		var doorway := Rect2(rect.position + Vector2(frame_w, 20.0), rect.size - Vector2(frame_w * 2.0, 20.0))
		draw_rect(doorway, Color("#03050A"))
		draw_rect(Rect2(doorway.position + Vector2(0.0, doorway.size.y * 0.75), Vector2(doorway.size.x, doorway.size.y * 0.25)),
				Color(EXIT_GREEN, 0.06))
		draw_rect(Rect2(rect.position, Vector2(size.x, 20.0)), CLOSED_FILL)
		draw_line(rect.position + Vector2(0.0, 16.0), rect.position + Vector2(size.x, 16.0), OUTLINE, 2.0)
		for side in [rect.position.x, rect.end.x - frame_w]:
			draw_rect(Rect2(Vector2(side, rect.position.y), Vector2(frame_w, size.y)), FRAME)
		draw_rect(rect, OPEN_FRAME, false, 2.0)
		draw_rect(rect.grow(1.5), OUTLINE, false, 1.5)
		var sign_r := Rect2(Vector2(-12.0, rect.position.y - 14.0), Vector2(24.0, 9.0))
		draw_rect(sign_r.grow(4.0), Color(EXIT_GREEN, 0.12))
		draw_rect(sign_r, EXIT_GREEN)
		draw_polyline(PackedVector2Array([
			sign_r.get_center() + Vector2(-3.0, -3.0), sign_r.get_center() + Vector2(2.0, 0.0),
			sign_r.get_center() + Vector2(-3.0, 3.0),
		]), OUTLINE, 2.0)
		draw_rect(sign_r, OUTLINE, false, 1.5)
	else:
		draw_rect(rect, CLOSED_FILL)
		var y := rect.position.y + 24.0
		while y < rect.end.y - 30.0:
			draw_rect(Rect2(Vector2(rect.position.x + 6.0, y), Vector2(size.x - 12.0, 5.0)), PANEL)
			y += 34.0
		draw_line(Vector2(0.0, -size.y), Vector2(0.0, 0.0), OUTLINE, 2.0)
		var hazard := Rect2(Vector2(rect.position.x, -16.0), Vector2(size.x, 16.0))
		draw_rect(hazard, OUTLINE)
		var hx := hazard.position.x + 4.0
		while hx < hazard.end.x - 6.0:
			draw_polyline(PackedVector2Array([
				Vector2(hx, hazard.position.y + 3.0), Vector2(hx + 6.0, hazard.get_center().y),
				Vector2(hx, hazard.end.y - 3.0),
			]), HAZARD, 2.5)
			hx += 12.0
		draw_line(rect.position + Vector2(2.0, 2.0), Vector2(rect.position.x + 2.0, rect.end.y), Color(0.36, 0.45, 0.56, 0.55), 1.5)
		draw_rect(rect, OUTLINE, false, 3.0)
		var lamp_c := Vector2(rect.end.x - 12.0, rect.position.y + 12.0)
		draw_circle(lamp_c, 7.0, Color(LOCKED, 0.2))
		draw_circle(lamp_c, 3.5, LOCKED)
		draw_rect(Rect2(lamp_c + Vector2(-16.0, -1.5), Vector2(8.0, 3.0)), LOCKED)
