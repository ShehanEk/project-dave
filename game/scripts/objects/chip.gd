class_name Chip
extends Area2D
## Contact pickup (layer 7 pickup, mask 2 hero_body). A microchip (revamp
## C19: microchips replace gems): `value` 1 = one loose chip; 5 = a small
## stack of three, drawn larger. Gold contacts and a soft glint so it reads
## against the dark night campus (style guide: gold = pickups). Absent if
## Session already recorded `entity_id` as collected.

const OUTLINE := Color("#07090F")
const BODY := Color("#1C2A3A")
const GOLD := Color("#FFD166")
const GOLD_CLUSTER := Color("#FFC24A")
const SHINE := Color("#FFF2C4")
const GLINT := Color(1.0, 0.82, 0.4, 0.22)
const CLUSTER_VALUE := 5

## M6.5 Kenney integration pass (assets/kenney/README.md section 5): no
## class_name on the puff script (see its own doc comment) — reached through
## this plain preload + its static `spawn()`.
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")

## The painted pixel-art look (objects2 sheet), drawn through PickupSkins; the
## code-drawn chip below stays as the fallback. The glint grows to the painted
## chip's size (30 world px; the five-chip cluster is 66).
const PickupSkins := preload("res://scripts/world/pickup_skins.gd")
const PAINTED_GLINT := 18.0
const PAINTED_GLINT_CLUSTER := 36.0

@export var entity_id: String = ""
@export var value: int = 1


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


## The PickupSkins piece this chip draws, or "" for the code-drawn look.
func painted_piece() -> String:
	var piece := "chip_cluster" if _is_cluster() else "chip"
	return piece if PickupSkins.has_piece(piece) else ""


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("hero"):
		return
	if Session and Session.collect(entity_id, value):
		var host := get_tree().current_scene if get_tree().current_scene else get_tree().root
		KenneyPuff.spawn(&"chip_sparkle_cluster" if _is_cluster() else &"chip_sparkle", global_position, host)
		queue_free()


func _is_cluster() -> bool:
	return value >= CLUSTER_VALUE


func _draw() -> void:
	var piece := painted_piece()
	if piece != "":
		draw_circle(Vector2.ZERO, PAINTED_GLINT_CLUSTER if _is_cluster() else PAINTED_GLINT, GLINT)
		PickupSkins.draw_centred(self, piece)
		return
	draw_circle(Vector2.ZERO, 22.0 if _is_cluster() else 16.0, GLINT)
	if _is_cluster():
		_draw_chip(Vector2(-8.0, 3.0), 10.0)
		_draw_chip(Vector2(8.0, 5.0), 9.0)
		_draw_chip(Vector2(0.0, -9.0), 11.0)
	else:
		_draw_chip(Vector2.ZERO, 10.0)


## One chip: a dark square package with gold pins on every side and a gold
## die in the middle — no facets, so it can never be mistaken for the old gem.
func _draw_chip(center: Vector2, half: float) -> void:
	var gold := GOLD_CLUSTER if _is_cluster() else GOLD
	var pin := half * 0.45
	for i in 3:
		var o := (-0.55 + i * 0.55) * half
		draw_line(center + Vector2(-half - pin, o), center + Vector2(-half, o), gold, 2.0)
		draw_line(center + Vector2(half, o), center + Vector2(half + pin, o), gold, 2.0)
		draw_line(center + Vector2(o, -half - pin), center + Vector2(o, -half), gold, 2.0)
		draw_line(center + Vector2(o, half), center + Vector2(o, half + pin), gold, 2.0)
	var body := Rect2(center - Vector2(half, half), Vector2(half, half) * 2.0)
	draw_rect(body, BODY)
	draw_rect(Rect2(center - Vector2(half, half) * 0.45, Vector2(half, half) * 0.9), gold)
	draw_rect(body, OUTLINE, false, 2.0)
	draw_line(center + Vector2(-half * 0.7, -half * 0.7), center + Vector2(-half * 0.2, -half * 0.7), SHINE, 1.5)
