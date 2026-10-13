extends Control
## Revamp (C24): small clearance-card icon in the HUD top bar, shown once
## the level's keycard is held (interface-and-accessibility.md "keycard
## indicator"). Purely decorative — `Hud` decides visibility. Draws the pixel
## keycard (Sheet 12, `keycard`, 14 x 10 UI px at 3 canvas px each) through
## scripts/ui/pixel_ui.gd; without that PNG it keeps its code-drawn card,
## matching the world Keycard (scripts/objects/keycard.gd).

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")
const PIECE := "keycard"

## The piece drawn: the level's own card (LevelDef.keycard_icon, set by Hud; batch 7), else PIECE.
var piece: String = PIECE

const OUTLINE := Color("#07090F")
const BODY := Color("#1C2A3A")
const STRIPE := Color("#3FE0D0")
const CHIP := Color("#FFD166")


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tex := PixelUi.texture(piece)
	if tex:
		custom_minimum_size = tex.get_size() * float(PixelUi.SCALE)


## Shows the level's own card icon (a missing piece keeps the generic card).
func set_piece(new_piece: String) -> void:
	var p := new_piece if new_piece != "" and PixelUi.has_piece(new_piece) else PIECE
	if p == piece:
		return
	piece = p
	var tex := PixelUi.texture(piece)
	if tex:
		custom_minimum_size = tex.get_size() * float(PixelUi.SCALE)
	queue_redraw()


func has_art() -> bool:
	return PixelUi.has_piece(piece)


func _draw() -> void:
	var tex := PixelUi.texture(piece)
	if tex:
		var s: Vector2 = tex.get_size() * float(PixelUi.SCALE)
		draw_texture_rect(tex, Rect2(((size - s) * 0.5).floor(), s), false)
		return
	var r := Rect2(Vector2(2.0, (size.y - 16.0) * 0.5), Vector2(size.x - 4.0, 16.0))
	draw_rect(r, BODY)
	draw_rect(Rect2(r.position + Vector2(0.0, 3.0), Vector2(r.size.x, 3.5)), STRIPE)
	draw_rect(Rect2(r.position + Vector2(3.0, 9.0), Vector2(6.0, 4.5)), CHIP)
	draw_rect(r, OUTLINE, false, 1.6)
