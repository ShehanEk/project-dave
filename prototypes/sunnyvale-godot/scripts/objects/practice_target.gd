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

@onready var hit_zone: HitZone = $HitZone

var _flash_timer: float = 0.0


func _ready() -> void:
	hit_zone.hit.connect(_on_hit)


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
