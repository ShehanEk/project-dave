class_name MedPatch
extends Area2D
## Contact heal pickup (L01-HS01..03). Only collected while the hero is
## below max health; otherwise it remains in place (not marked collected)
## so it stays available for a later, hurt pass. Once actually collected it
## is gone for the rest of the run (per Session, across reloads).

const OUTLINE := Color("#07090F")
const SHELL := Color("#D8E2EC")
const CROSS := Color("#3FE0D0")
const GLOW := Color(0.25, 0.88, 0.82, 0.18)
## The painted pixel-art look (objects2 sheet), drawn through PickupSkins; the
## code-drawn patch below stays as the fallback. The glow grows to the painted
## patch's size (36 world px).
const PickupSkins := preload("res://scripts/world/pickup_skins.gd")
const PIECE := "med_patch"
const PAINTED_GLOW := 27.0

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
	if painted_piece() != "":
		PickupSkins.make_crisp(self)
	queue_redraw()


## The PickupSkins piece this patch draws, or "" for the code-drawn look.
func painted_piece() -> String:
	return PIECE if PickupSkins.has_piece(PIECE) else ""


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("hero"):
		return
	if Session == null or Session.is_full_health():
		return  # remains: not needed right now
	if Session.collect(entity_id, 0):
		Session.heal(heal)
		queue_free()


## A med-patch (revamp name for the care capsule): a pale adhesive patch
## with a teal plus. Deliberately not red — red is reserved for danger.
func _draw() -> void:
	if painted_piece() != "":
		draw_circle(Vector2.ZERO, PAINTED_GLOW, GLOW)
		PickupSkins.draw_centred(self, PIECE)
		return
	draw_circle(Vector2.ZERO, 22.0, GLOW)
	var patch := Rect2(Vector2(-15.0, -12.0), Vector2(30.0, 24.0))
	draw_rect(patch, SHELL)
	draw_rect(Rect2(Vector2(-3.0, -8.0), Vector2(6.0, 16.0)), CROSS)
	draw_rect(Rect2(Vector2(-8.0, -3.0), Vector2(16.0, 6.0)), CROSS)
	draw_rect(patch, OUTLINE, false, 2.5)
