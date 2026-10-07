class_name PracticeTarget
extends Node2D
## Inert shooting-practice target (blockout style). Reacts visibly to hits,
## awards nothing, and never "dies" — reused later in A01 and the depot.

## Revamp (C24) night look: an old Arcadia security-training silhouette
## board (level brief) on a slim stand — a pale board with a dark
## head-and-shoulders silhouette and score rings, rim-lit so it reads at
## night. A hit flashes it cold white and briefly swells it.
const OUTLINE := Color("#05070B")
const FILL := Color("#9DAEBF")
const SILHOUETTE := Color("#1C2A3A")
const RINGS := Color("#C9D6E2")
const STAND := Color("#2E3B4E")
const HIT_FLASH := Color("#EAF6FF")
const FLASH_TIME := 0.18

## The painted pixel-art look (objects2 sheet), drawn through PickupSkins; the
## code-drawn board below stays as the fallback. The origin is the board's
## centre (the hit zone's centre), as before; the stand is the painted pole
## repeated down to the floor line. A hit flashes the painted board cold white
## and swells its glow (the pixels never scale). All in art px from the piece's
## top-left corner: the piece's rows [0, 60) are the head and board, [60, 74)
## the pole and [74, 82) the base.
const PickupSkins := preload("res://scripts/world/pickup_skins.gd")
const PIECE := "practice_target"
const ORIGIN_ART := Vector2(15.0, 37.0)
const HEAD_BOX := Rect2(6.0, 0.0, 18.0, 16.0)
const BOARD_BOX := Rect2(0.0, 16.0, 30.0, 44.0)
const POLE_FROM := 60
const BASE_FROM := 74

@onready var hit_zone: HitZone = $HitZone

var _flash_timer: float = 0.0


func _ready() -> void:
	hit_zone.hit.connect(_on_hit)
	if painted_piece() != "":
		PickupSkins.make_crisp(self)


## The PickupSkins piece this target draws, or "" for the code-drawn look.
func painted_piece() -> String:
	return PIECE if PickupSkins.has_piece(PIECE) else ""


func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer = maxf(0.0, _flash_timer - delta)
		queue_redraw()


func _on_hit(_damage: int, _hit_position: Vector2, _direction: Vector2) -> void:
	_flash_timer = FLASH_TIME
	queue_redraw()


func _draw() -> void:
	var lit := _flash_timer > 0.0
	var k: float = 1.0 + 0.3 * (_flash_timer / FLASH_TIME) if lit else 1.0
	# the stand runs down to the area's floor line (this node sits in its
	# area's Entities, so -position.y is the height above that floor).
	var ground: float = maxf(-position.y, 0.0)
	if painted_piece() != "":
		_draw_painted(_flash_timer / FLASH_TIME, ground)
		return
	if ground > 28.0:
		draw_rect(Rect2(Vector2(-3.0, 26.0), Vector2(6.0, ground - 26.0)), STAND)
		draw_rect(Rect2(Vector2(-12.0, ground - 5.0), Vector2(24.0, 5.0)), STAND)
		draw_rect(Rect2(Vector2(-3.0, 26.0), Vector2(6.0, ground - 26.0)), OUTLINE, false, 1.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * k)
	var board := Rect2(Vector2(-24.0, -30.0), Vector2(48.0, 58.0))
	draw_rect(board.grow(4.0), Color(HIT_FLASH, 0.35 if lit else 0.08))
	draw_rect(board, HIT_FLASH if lit else FILL)
	draw_circle(Vector2(0.0, -14.0), 8.0, SILHOUETTE)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-17.0, 28.0), Vector2(-14.0, 2.0), Vector2(-5.0, -4.0), Vector2(5.0, -4.0),
		Vector2(14.0, 2.0), Vector2(17.0, 28.0),
	]), SILHOUETTE)
	draw_arc(Vector2(0.0, 10.0), 9.0, 0.0, TAU, 16, RINGS, 1.5)
	draw_arc(Vector2(0.0, 10.0), 4.0, 0.0, TAU, 12, RINGS, 1.5)
	draw_rect(board, OUTLINE, false, 3.0)
	draw_line(board.position + Vector2(2.0, 2.0), Vector2(board.end.x - 2.0, board.position.y + 2.0), Color(1.0, 1.0, 1.0, 0.5), 1.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## `flash` is 1 at a hit and fades to 0; `ground` is the height of the floor
## line below the origin.
func _draw_painted(flash: float, ground: float) -> void:
	var a := PickupSkins.ART
	var tl := -ORIGIN_ART * a
	var cols := BOARD_BOX.size.x
	var board_bottom := tl.y + float(POLE_FROM) * a
	var base_h := float(PickupSkins.texture(PIECE).get_height() - BASE_FROM) * a
	if ground >= board_bottom + base_h:
		# whole pole rows from the base up, tucked under the board
		var base_top := ground - base_h
		var rows := ceili((base_top - board_bottom) / a)
		var period := BASE_FROM - POLE_FROM
		var y := base_top - float(rows) * a
		while rows > 0:
			var n := mini(rows, period)
			PickupSkins.blit(self, PIECE, Rect2(0.0, POLE_FROM, cols, n), Vector2(tl.x, y), Color.WHITE)
			y += float(n) * a
			rows -= n
		PickupSkins.blit(self, PIECE, Rect2(0.0, BASE_FROM, cols, PickupSkins.texture(PIECE).get_height() - BASE_FROM),
				Vector2(tl.x, base_top), Color.WHITE)
	var board := Rect2(tl + BOARD_BOX.position * a, BOARD_BOX.size * a)
	var swell: float = 4.0 + 0.3 * flash * board.size.x * 0.5
	draw_rect(board.grow(swell), Color(HIT_FLASH, 0.35 if flash > 0.0 else 0.08))
	PickupSkins.blit(self, PIECE, Rect2(0.0, 0.0, cols, float(POLE_FROM)), tl, Color.WHITE)
	if flash > 0.0:
		var wash := Color(HIT_FLASH, 0.5 + 0.3 * flash)
		draw_rect(board, wash)
		draw_rect(Rect2(tl + HEAD_BOX.position * a, HEAD_BOX.size * a), wash)
