class_name PitHazard
extends Area2D
## A marked pit hazard (layer 8, mask 2 hero_body): on hero entry,
## costs `damage` health and resets the hero to the fixed child Marker2D
## "Reset" (per CONVENTIONS.md/03: "the one marked exit pit costs one
## health and returns to a fixed safe foothold").

## Revamp (C24) night look: hazard-amber diagonal stripes on near-black with
## a faint amber glow line along the pit's lip, so the drop reads in the
## dark; the warning triangle stays as a shape cue.
const OUTLINE := Color("#05070B")
const STRIPE_A := Color("#0B0F16")
const STRIPE_B := Color("#FFB02E")

## M6.5 Kenney integration pass: no class_name on the puff script (see its
## own doc comment) — reached through this plain preload + its static
## `spawn()`.
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")

## The painted pixel-art look (objects2 sheet), drawn through PickupSkins: the
## amber and black striped cover between steel rails, stretched to `size`
## without scaling a pixel (stripes repeat sideways and, in a taller pit,
## downward). Its top rail sits on the pit's top; a pit shorter than the
## piece (54 px) is drawn as tall as the piece, so the stripes stay readable.
## The lip glow and warning triangle stay on top of it; the code-drawn
## stripes stay as the fallback.
const PickupSkins := preload("res://scripts/world/pickup_skins.gd")
const PIECE := "pit_cover"

@export var damage: int = 1
@export var size: Vector2 = Vector2(160.0, 40.0)

@onready var _reset_marker: Marker2D = get_node_or_null("Reset")


func _init() -> void:
	collision_layer = 1 << 7  # layer 8: hazard
	collision_mask = 1 << 1   # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Each pit's trigger matches its own drawn `size` (the scene's shape is
	# shared, so it is copied first): the roof gaps (C41) are long strips.
	var cs := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs and cs.shape is RectangleShape2D and (cs.shape as RectangleShape2D).size != size:
		cs.shape = cs.shape.duplicate()
		(cs.shape as RectangleShape2D).size = size
	if painted_piece() != "":
		PickupSkins.make_crisp(self)
	queue_redraw()


## The PickupSkins piece this pit draws, or "" for the code-drawn look.
func painted_piece() -> String:
	return PIECE if PickupSkins.has_piece(PIECE) else ""


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("hero") or not body.has_method("fall_to"):
		return
	var reset_pos: Vector2 = _reset_marker.global_position if _reset_marker else global_position
	body.fall_to(reset_pos, damage)
	# M6/Audio cue table: "pit_fall" plays here, alongside hero.fall_to(...).
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"pit_fall", global_position)
	var host := get_tree().current_scene if get_tree().current_scene else get_tree().root
	KenneyPuff.spawn(&"pit_dust", global_position, host)


func _draw() -> void:
	var rect := Rect2(-size * 0.5, size)
	if painted_piece() != "":
		PickupSkins.draw_sized(self, PIECE, rect.position, Vector2(rect.size.x, maxf(rect.size.y, PickupSkins.piece_size(PIECE).y)))
	else:
		draw_rect(rect, STRIPE_A)
		var rect_poly := PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end,
				Vector2(rect.position.x, rect.end.y)])
		var stripe_w := 14.0
		var x := rect.position.x - rect.size.y
		while x < rect.end.x:
			var band := PackedVector2Array([
				Vector2(x + rect.size.y, rect.position.y), Vector2(x + rect.size.y + stripe_w, rect.position.y),
				Vector2(x + stripe_w, rect.end.y), Vector2(x, rect.end.y),
			])
			for piece in Geometry2D.intersect_polygons(band, rect_poly):
				if piece.size() >= 3:
					draw_colored_polygon(piece, STRIPE_B)
			x += stripe_w * 2.0
		draw_rect(rect, OUTLINE, false, 3.0)
	draw_line(rect.position + Vector2(0.0, -2.0), Vector2(rect.end.x, rect.position.y - 2.0), Color(STRIPE_B, 0.35), 2.0)
	# A small warning-triangle mark, redundant with the diagonal stripe shape
	# itself (style guide: warnings must never rely on color alone).
	var tri_c := Vector2(0.0, rect.position.y - 14.0)
	var tri := PackedVector2Array([
		tri_c + Vector2(0.0, -9.0), tri_c + Vector2(9.0, 7.0), tri_c + Vector2(-9.0, 7.0),
	])
	draw_circle(tri_c, 14.0, Color(STRIPE_B, 0.1))
	draw_colored_polygon(tri, STRIPE_B)
	draw_polyline(tri, OUTLINE, 2.0, true)
	draw_line(tri[2], tri[0], OUTLINE, 2.0)
	draw_line(tri_c + Vector2(0.0, -3.0), tri_c + Vector2(0.0, 2.0), OUTLINE, 2.0)
	draw_circle(tri_c + Vector2(0.0, 5.0), 1.4, OUTLINE)
