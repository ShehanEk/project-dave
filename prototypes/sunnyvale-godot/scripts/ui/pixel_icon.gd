extends Control
## One piece of the pixel UI (assets/ui/pixel/, scripts/ui/pixel_ui.gd) drawn
## whole at `px` canvas px per UI pixel, centred in this control; the control's
## minimum size becomes the piece's size at that scale. The HUD's health
## segments, Quickcycle pip and fire-readiness light use it (`set_piece()`
## swaps lit/dark, full/empty). When the piece's PNG is missing it draws
## `fallback_color` as a plain rectangle (edged with `fallback_outline`) at its
## authored minimum size instead, so the HUD still reads without the art.

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")

@export var piece: String = "":
	set(value):
		piece = value
		_refresh()
@export var px: int = PixelUi.SCALE:
	set(value):
		px = value
		_refresh()
@export var fallback_color: Color = Color(0, 0, 0, 0):
	set(value):
		fallback_color = value
		queue_redraw()
@export var fallback_outline: Color = Color(0, 0, 0, 0)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh()


## Shows `new_piece`, with `fallback` as its no-art colour.
func set_piece(new_piece: String, fallback: Color = fallback_color) -> void:
	fallback_color = fallback
	if new_piece != piece:
		piece = new_piece
	else:
		queue_redraw()


## True when the current piece's PNG exists (it draws pixel art, not the fallback).
func has_art() -> bool:
	return piece != "" and PixelUi.has_piece(piece)


func _refresh() -> void:
	var tex := PixelUi.texture(piece) if piece != "" else null
	if tex:
		custom_minimum_size = tex.get_size() * float(px)
	queue_redraw()


func _draw() -> void:
	var tex := PixelUi.texture(piece) if piece != "" else null
	if tex:
		var s: Vector2 = tex.get_size() * float(px)
		draw_texture_rect(tex, Rect2(((size - s) * 0.5).floor(), s), false)
	elif fallback_color.a > 0.0:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, fallback_color)
		if fallback_outline.a > 0.0:
			draw_rect(r.grow(-1.0), fallback_outline, false, 2.0)
