extends Control
## Small microchip icon beside the HUD wallet count
## (interface-and-accessibility.md "microchip counter"). Purely decorative —
## `Hud` owns the number. Draws the pixel chip (Sheet 12, `chip`, 12 x 12 UI
## px at 3 canvas px each) through scripts/ui/pixel_ui.gd; without that PNG it
## keeps its code-drawn chip, coloured like the world Chip
## (scripts/objects/chip.gd) so the icon and the pickups read as one thing.

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")
const PIECE := "chip"

const OUTLINE := Color("#07090F")
const BODY := Color("#1C2A3A")
const GOLD := Color("#FFD166")
const SHINE := Color("#FFF2C4")


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
	var c := size * 0.5
	var body := Rect2(c - Vector2(6.0, 6.0), Vector2(12.0, 12.0))
	for i in 3:
		var o := -4.0 + i * 4.0
		draw_line(c + Vector2(-9.0, o), c + Vector2(-6.0, o), GOLD, 1.6)
		draw_line(c + Vector2(6.0, o), c + Vector2(9.0, o), GOLD, 1.6)
		draw_line(c + Vector2(o, -9.0), c + Vector2(o, -6.0), GOLD, 1.6)
		draw_line(c + Vector2(o, 6.0), c + Vector2(o, 9.0), GOLD, 1.6)
	draw_rect(body, BODY)
	draw_rect(Rect2(c - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), GOLD)
	draw_rect(body, OUTLINE, false, 1.4)
	draw_circle(c + Vector2(-1.5, -1.5), 1.1, SHINE)
