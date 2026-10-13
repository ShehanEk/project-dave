extends Control
## Revamp (C24): small clearance-card icon in the HUD top bar, shown once
## the level's keycard is held (interface-and-accessibility.md "keycard
## indicator"). Purely decorative — `Hud` decides visibility. Draws the pixel
## keycard (Sheet 12, `keycard`, 14 x 10 UI px at 3 canvas px each) through
## scripts/ui/pixel_ui.gd; without that PNG it keeps its code-drawn card,
## matching the world Keycard (scripts/objects/keycard.gd).

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")
const PIECE := "keycard"

const OUTLINE := Color("#07090F")
const BODY := Color("#1C2A3A")
const STRIPE := Color("#3FE0D0")
const CHIP := Color("#FFD166")


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tex := PixelUi.texture(PIECE)
	if tex:
		custom_minimum_size = tex.get_size() * float(PixelUi.SCALE)


func has_art() -> bool:
	return PixelUi.has_piece(PIECE)


func _draw() -> void:
	var tex := PixelUi.texture(PIECE)
	if tex:
		var s: Vector2 = tex.get_size() * float(PixelUi.SCALE)
		draw_texture_rect(tex, Rect2(((size - s) * 0.5).floor(), s), false)
		return
	var r := Rect2(Vector2(2.0, (size.y - 16.0) * 0.5), Vector2(size.x - 4.0, 16.0))
	draw_rect(r, BODY)
	draw_rect(Rect2(r.position + Vector2(0.0, 3.0), Vector2(r.size.x, 3.5)), STRIPE)
	draw_rect(Rect2(r.position + Vector2(3.0, 9.0), Vector2(6.0, 4.5)), CHIP)
	draw_rect(r, OUTLINE, false, 1.6)
