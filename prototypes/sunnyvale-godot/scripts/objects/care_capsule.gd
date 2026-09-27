class_name CareCapsule
extends Area2D
## Contact heal pickup (L01-HS01..03). Only collected while the hero is
## below max health; otherwise it remains in place (not marked collected)
## so it stays available for a later, hurt pass. Once actually collected it
## is gone for the rest of the run (per Session, across reloads).

const OUTLINE := Color("#332a20")
const SHELL := Color("#f2efe6")
const CROSS := Color("#ffffff")
const CENTER := Color("#e88a9a")

@export var entity_id: String = ""
@export var heal: int = 2


func _init() -> void:
	collision_layer = 1 << 6  # layer 7: pickup
	collision_mask = 1 << 1   # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	if entity_id != "" and Session and Session.is_collected(entity_id):
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("hero"):
		return
	if Session == null or Session.is_full_health():
		return  # remains: not needed right now
	if Session.collect(entity_id, 0):
		Session.heal(heal)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 20.0, SHELL)
	draw_circle(Vector2.ZERO, 20.0, OUTLINE, false, 3.0)
	draw_circle(Vector2.ZERO, 7.0, CENTER)
	draw_rect(Rect2(Vector2(-3.0, -12.0), Vector2(6.0, 24.0)), CROSS)
	draw_rect(Rect2(Vector2(-12.0, -3.0), Vector2(24.0, 6.0)), CROSS)
