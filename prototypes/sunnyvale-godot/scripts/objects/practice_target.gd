class_name PracticeTarget
extends Node2D
## Inert shooting-practice target (blockout style). Reacts visibly to hits,
## awards nothing, and never "dies" — reused later in A01 and the depot.

const OUTLINE := Color("#332a20")  # warm charcoal (C11 contour)
const FILL := Color("#c9663f")
const HIT_FLASH := Color("#f4d78a")
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
	var r: float = 26.0 * (1.0 + 0.5 * (_flash_timer / FLASH_TIME)) if lit else 26.0
	draw_circle(Vector2.ZERO, r, HIT_FLASH if lit else FILL)
	draw_circle(Vector2.ZERO, r, OUTLINE, false, 3.0)
	draw_circle(Vector2.ZERO, 9.0, OUTLINE)
