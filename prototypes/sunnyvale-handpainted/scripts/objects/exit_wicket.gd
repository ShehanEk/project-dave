class_name ExitWicket
extends Area2D
## Level-end trigger. Always a member of group "exit_wicket" so a harness/
## level director can find it; emits `wicket_reached` once when the hero
## first enters WHILE holding the level's clearance keycard. This node only
## detects and announces the moment — CP05, `Session.level_completed`, and
## the completion screen are all owned by `LevelDirector._on_wicket_reached()`
## (04-godot-architecture.md's table assigns "completion" to LevelDirector),
## which permanently disables `hero.input_enabled` right after, ending the
## run for good (no re-enable, unlike a dismissible modal).
##
## Revamp (C24, level-design L01 / P19): the wicket's card reader stays amber
## and locked until `Session.has_keycard(required_keycard)`. Entering without
## the card shows a short "clearance card required" toast (rate-limited) and
## never ends the level — the card sits on the main route in A04, so this is
## a belt-and-braces message, not a puzzle.
##
## The hold-out (C41, the finale): with `override_time` above zero, the gate
## stays shut (a solid bar) after the card is read while the reader overrides
## the lockdown, showing its progress; the moment it starts it wakes
## `override_groups`, and `reinforcement_delay` later `reinforcement_groups`
## (EncounterGroups with `wait_for_trigger`). When it finishes the bar drops
## and the level ends as soon as Dave is in the gate. A death resets it (the
## area is rebuilt), so the hold-out always starts over from the card swipe.

signal wicket_reached
signal wicket_denied
signal override_started
signal override_finished

const LOCKED := Color("#FFB02E")  # amber: a warning, not danger (red stays reserved for attack tells)
const UNLOCKED := Color("#3FE0D0")
const FRAME := Color("#2E3B4E")
const OUTLINE := Color("#07090F")
const DENY_COOLDOWN := 1.6
## The override's progress bar over the gate (C41 hold-out).
const BAR_W := 64.0
const BAR_H := 8.0
## The painted pixel-art look (objects sheet): the gate with an amber reader
## (locked), with a teal reader and no bars (open), and shut by the striped
## steel bar; drawn through ObjectSkins, the code-drawn look below stays as the
## fallback. The reader's lens centre, per piece, is in art px from the
## piece's top-left corner; the shut gate's lens rect (art px) turns teal once
## the card starts the override.
const ObjectSkins := preload("res://scripts/world/object_skins.gd")
const LOCKED_PIECE := "gate_locked"
const OPEN_PIECE := "gate_open"
const SHUT_PIECE := "gate_shut"
const LENS_ART := {
	"gate_locked": Vector2(66.0, 45.0), "gate_open": Vector2(63.0, 43.0), "gate_shut": Vector2(64.0, 44.0),
}
const SHUT_LENS := Rect2(60.0, 40.0, 8.0, 8.0)

@export var required_keycard: String = "L01-KC01"
@export var denied_text: String = "Clearance card required"
## Seconds the reader takes to override the lockdown; 0 opens at once.
@export var override_time: float = 0.0
@export var override_groups: Array[NodePath] = []
@export var reinforcement_groups: Array[NodePath] = []
@export var reinforcement_delay: float = 8.0
@export var override_text: String = "Overriding the lockdown. Hold on!"
@export var open_text: String = "Override complete"

var _reached: bool = false
var _deny_cooldown: float = 0.0
## -1 = not started; then seconds into the override.
var _override_t: float = -1.0
var _open: bool = false
var _reinforced: bool = false
var _gate: StaticBody2D

@onready var _toast: ToastLabel = get_node_or_null("Toast")


func _init() -> void:
	collision_layer = 0
	collision_mask = 1 << 1  # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	add_to_group("exit_wicket")
	if painted_piece() != "":
		ObjectSkins.make_crisp(self)
	body_entered.connect(_on_body_entered)
	_open = override_time <= 0.0
	if not _open:
		# The shut gate: a bar just past the reader, on the world layer.
		_gate = StaticBody2D.new()
		_gate.name = "Gate"
		_gate.collision_layer = 1
		_gate.collision_mask = 0
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(16.0, 240.0)
		shape.shape = rect
		shape.position = Vector2(36.0, -120.0)
		_gate.add_child(shape)
		add_child(_gate)
	if Session:
		Session.keycard_taken.connect(_on_keycard_taken)
		Session.snapshot_restored.connect(_on_snapshot_restored)
	queue_redraw()


func _exit_tree() -> void:
	if Session:
		if Session.keycard_taken.is_connected(_on_keycard_taken):
			Session.keycard_taken.disconnect(_on_keycard_taken)
		if Session.snapshot_restored.is_connected(_on_snapshot_restored):
			Session.snapshot_restored.disconnect(_on_snapshot_restored)


func _physics_process(delta: float) -> void:
	if _deny_cooldown > 0.0:
		_deny_cooldown -= delta
	if _override_t < 0.0 or _open:
		return
	_override_t += delta
	if not _reinforced and _override_t >= reinforcement_delay:
		_reinforced = true
		_wake(reinforcement_groups)
	if _override_t >= override_time:
		_finish_override()
	queue_redraw()


func is_overriding() -> bool:
	return _override_t >= 0.0 and not _open


func is_open() -> bool:
	return _open


## 0..1 progress of the override (1 once open).
func override_progress() -> float:
	if _open:
		return 1.0
	return clampf(_override_t / override_time, 0.0, 1.0) if _override_t >= 0.0 else 0.0


func _start_override() -> void:
	_override_t = 0.0
	Audio.play_sfx(&"keycard", global_position)
	Audio.play_sfx(&"alarm", global_position)
	if _toast:
		_toast.show_message(override_text)
	_wake(override_groups)
	override_started.emit()
	queue_redraw()


func _finish_override() -> void:
	_open = true
	if _gate:
		_gate.queue_free()
		_gate = null
	Audio.play_sfx(&"door_unlock", global_position)
	if _toast:
		_toast.show_message(open_text)
	override_finished.emit()
	queue_redraw()
	for body in get_overlapping_bodies():
		if body.is_in_group("hero"):
			_reach()
			return


func _wake(paths: Array[NodePath]) -> void:
	for p in paths:
		var g := get_node_or_null(p)
		if g and g.has_method("activate"):
			g.activate()


## The ObjectSkins piece this gate draws now, or "" for the code-drawn look:
## shut by the striped bar until the override finishes (the hold-out), then the
## open frame with a teal reader once the card is held, else the barred gate
## with an amber reader.
func painted_piece() -> String:
	if not ObjectSkins.has_pieces([LOCKED_PIECE, OPEN_PIECE, SHUT_PIECE]):
		return ""
	if not _open:
		return SHUT_PIECE
	return OPEN_PIECE if (is_unlocked() or _reached) else LOCKED_PIECE


func is_unlocked() -> bool:
	return required_keycard == "" or (Session != null and Session.has_keycard(required_keycard))


func _on_keycard_taken(_id: String) -> void:
	queue_redraw()


func _on_snapshot_restored(_checkpoint_id: String) -> void:
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _reached or not body.is_in_group("hero"):
		return
	if not is_unlocked():
		if _deny_cooldown <= 0.0:
			_deny_cooldown = DENY_COOLDOWN
			Audio.play_sfx(&"keycard_denied", global_position)
			if _toast:
				_toast.show_message(denied_text)
			wicket_denied.emit()
		return
	if not _open:
		if _override_t < 0.0:
			_start_override()
		return
	_reach()


func _reach() -> void:
	if _reached:
		return
	_reached = true
	if override_time <= 0.0:
		Audio.play_sfx(&"door_unlock", global_position)
	queue_redraw()
	wicket_reached.emit()


## The override's progress, over the gate: fills teal as it runs.
func _draw_override_bar() -> void:
	if _override_t < 0.0 or _open:
		return
	var frame := Rect2(Vector2(-BAR_W * 0.5 + 8.0, -122.0), Vector2(BAR_W, BAR_H))
	draw_rect(frame.grow(2.0), OUTLINE)
	draw_rect(frame, Color(LOCKED, 0.25))
	draw_rect(Rect2(frame.position, Vector2(BAR_W * override_progress(), BAR_H)), UNLOCKED)


func _draw_painted(piece: String) -> void:
	ObjectSkins.draw(self, piece)
	var light := LOCKED
	if piece == OPEN_PIECE:
		light = UNLOCKED
	elif piece == SHUT_PIECE and _override_t >= 0.0:
		# The card is read and the reader is overriding the lockdown.
		light = UNLOCKED
		draw_rect(Rect2(ObjectSkins.at(piece, SHUT_LENS.position), SHUT_LENS.size * ObjectSkins.ART), UNLOCKED)
	# The glow stays smooth over the crisp reader.
	draw_circle(ObjectSkins.at(piece, LENS_ART[piece]), 8.0, Color(light, 0.22))
	_draw_override_bar()


func _draw() -> void:
	var painted := painted_piece()
	if painted != "":
		_draw_painted(painted)
		return
	# A narrow service gate frame with a card reader on its post. The reader
	# light is the only state cue: amber = locked, teal = unlocked.
	draw_rect(Rect2(Vector2(-6.0, -110.0), Vector2(6.0, 110.0)), FRAME)
	draw_rect(Rect2(Vector2(-6.0, -110.0), Vector2(6.0, 110.0)), OUTLINE, false, 2.0)
	var reader := Rect2(Vector2(-22.0, -70.0), Vector2(14.0, 22.0))
	draw_rect(reader, FRAME)
	draw_rect(reader, OUTLINE, false, 2.0)
	var light := UNLOCKED if (is_unlocked() or _reached) else LOCKED
	if not _open and _override_t < 0.0 and override_time > 0.0:
		light = LOCKED   # card or not, the lockdown holds the gate shut
	draw_circle(reader.position + Vector2(7.0, 6.0), 8.0, Color(light, 0.22))
	draw_circle(reader.position + Vector2(7.0, 6.0), 3.5, light)
	draw_line(reader.position + Vector2(3.0, 14.0), reader.position + Vector2(11.0, 14.0), Color(light, 0.7), 2.0)
	if override_time <= 0.0:
		return
	if not _open:
		# The shut gate: a steel bar with hazard stripes, past the reader.
		var bar := Rect2(Vector2(28.0, -150.0), Vector2(16.0, 150.0))
		draw_rect(bar, FRAME)
		var y := bar.position.y + 6.0
		while y < bar.end.y - 8.0:
			draw_rect(Rect2(Vector2(bar.position.x + 2.0, y), Vector2(12.0, 8.0)), Color(LOCKED, 0.75))
			y += 22.0
		draw_rect(bar, OUTLINE, false, 2.0)
	_draw_override_bar()
