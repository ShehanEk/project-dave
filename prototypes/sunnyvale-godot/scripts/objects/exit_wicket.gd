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

signal wicket_reached
signal wicket_denied

const LOCKED := Color("#FFB02E")  # amber: a warning, not danger (red stays reserved for attack tells)
const UNLOCKED := Color("#3FE0D0")
const FRAME := Color("#2E3B4E")
const OUTLINE := Color("#07090F")
const DENY_COOLDOWN := 1.6

@export var required_keycard: String = "L01-KC01"
@export var denied_text: String = "Clearance card required"

var _reached: bool = false
var _deny_cooldown: float = 0.0

@onready var _toast: ToastLabel = get_node_or_null("Toast")


func _init() -> void:
	collision_layer = 0
	collision_mask = 1 << 1  # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	add_to_group("exit_wicket")
	body_entered.connect(_on_body_entered)
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
	_reached = true
	Audio.play_sfx(&"door_unlock", global_position)
	queue_redraw()
	wicket_reached.emit()


func _draw() -> void:
	# A narrow service gate frame with a card reader on its post. The reader
	# light is the only state cue: amber = locked, teal = unlocked.
	draw_rect(Rect2(Vector2(-6.0, -110.0), Vector2(6.0, 110.0)), FRAME)
	draw_rect(Rect2(Vector2(-6.0, -110.0), Vector2(6.0, 110.0)), OUTLINE, false, 2.0)
	var reader := Rect2(Vector2(-22.0, -70.0), Vector2(14.0, 22.0))
	draw_rect(reader, FRAME)
	draw_rect(reader, OUTLINE, false, 2.0)
	var light := UNLOCKED if (is_unlocked() or _reached) else LOCKED
	draw_circle(reader.position + Vector2(7.0, 6.0), 8.0, Color(light, 0.22))
	draw_circle(reader.position + Vector2(7.0, 6.0), 3.5, light)
	draw_line(reader.position + Vector2(3.0, 14.0), reader.position + Vector2(11.0, 14.0), Color(light, 0.7), 2.0)
