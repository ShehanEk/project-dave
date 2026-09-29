class_name Keycard
extends Area2D
## Revamp (C24): the level's clearance keycard (level-design L01, P19 "each
## level's exit door needs that level's clearance card"). A contact pickup on
## the main route, like a Chip, but it records `keycard_id` through
## `Session.take_keycard()` instead of adding to the wallet. The exit wicket
## (scripts/objects/exit_wicket.gd) stays locked until it is held.
## Absent if Session already recorded `entity_id` as collected, so a death
## rollback to a checkpoint from before the pickup puts it back.

const OUTLINE := Color("#07090F")
const BODY := Color("#1C2A3A")
const STRIPE := Color("#3FE0D0")
const CHIP := Color("#FFD166")
const HALO := Color(0.25, 0.88, 0.82, 0.18)
const BOB_HEIGHT := 3.0
const BOB_SPEED := 2.4

@export var entity_id: String = "L01-KC01-P"
@export var keycard_id: String = "L01-KC01"
@export var toast_text: String = "Clearance card taken"

var _t: float = 0.0
var _reduced_motion: bool = false

@onready var _toast: ToastLabel = get_node_or_null("Toast")


func _init() -> void:
	collision_layer = 1 << 6  # layer 7: pickup
	collision_mask = 1 << 1   # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	add_to_group("keycard")
	if Session and (Session.is_collected(entity_id) or Session.has_keycard(keycard_id)):
		queue_free()
		return
	var settings := get_node_or_null("/root/Settings")
	_reduced_motion = settings != null and settings.get_reduced_motion()
	body_entered.connect(_on_body_entered)
	set_process(not _reduced_motion)
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("hero"):
		return
	if Session and Session.take_keycard(keycard_id, entity_id):
		Audio.play_sfx(&"keycard", global_position)
		if _toast:
			# The toast outlives this pickup: reparent it to the area so it can
			# finish fading after the card itself is gone.
			var parent := get_parent()
			var at := _toast.global_position
			remove_child(_toast)
			parent.add_child(_toast)
			_toast.global_position = at
			_toast.show_message(toast_text)
		queue_free()


func _draw() -> void:
	var bob := 0.0 if _reduced_motion else sin(_t * BOB_SPEED) * BOB_HEIGHT
	var o := Vector2(0.0, bob)
	draw_circle(o, 24.0, HALO)
	var card := Rect2(o + Vector2(-16.0, -11.0), Vector2(32.0, 22.0))
	draw_rect(card, BODY)
	draw_rect(Rect2(card.position + Vector2(0.0, 4.0), Vector2(32.0, 5.0)), STRIPE)
	draw_rect(Rect2(card.position + Vector2(4.0, 12.0), Vector2(8.0, 6.0)), CHIP)
	draw_line(card.position + Vector2(16.0, 14.0), card.position + Vector2(28.0, 14.0), Color(STRIPE, 0.6), 1.5)
	draw_line(card.position + Vector2(16.0, 17.0), card.position + Vector2(24.0, 17.0), Color(STRIPE, 0.6), 1.5)
	draw_rect(card, OUTLINE, false, 2.0)
