extends Control
## A frame piece of the pixel UI (a nine-slice: plain edges and middle, corners
## `margin` UI px) stretched over this control's rect at `px` canvas px per UI
## pixel. Used behind the HUD objective (the banner strip, `show_behind_parent`
## so the Label's text draws over it). Draws nothing when the PNG is missing.

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")

@export var piece: String = "banner":
	set(value):
		piece = value
		queue_redraw()
@export var margin: int = 4
@export var px: int = PixelUi.SCALE


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func has_art() -> bool:
	return PixelUi.has_piece(piece)


func _draw() -> void:
	PixelUi.draw_frame(self, piece, Rect2(Vector2.ZERO, size), margin, float(px))
