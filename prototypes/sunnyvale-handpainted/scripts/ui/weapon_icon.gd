extends Control
## The HUD's "one carried weapon" slot (interface-and-accessibility.md
## "Carried weapon: One icon, weapon name on change, stage 0-3 pips"). Pure
## presentation — `Hud` tells it whether the Quickcycle stage is owned; it
## never reads Session/Settings itself.
##
## Pixel art (Sheets 11 and 12): the weapon-slot frame (`weapon_slot`, its
## plain edges stretched to fit) over a dark fill, holding the pixel Scrapjack
## (`weapon_scrapjack`, built by tools/art/import_pixel_ui.py from the in-game
## rig's rest pose, so the HUD and the held gun are the same art), all at 3
## canvas px per UI pixel; an owned Quickcycle lights the amber pip in the
## slot's lower right corner. Without those PNGs it keeps its code-drawn
## silhouette in scrapjack.gd's C11 palette.

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")
const SLOT := "weapon_slot"
const GUN := "weapon_scrapjack"
const PIP := "pip_lit"
## The slot frame's corner (outline, two border pixels and the highlight), UI px.
const SLOT_MARGIN := 4
## The frame's border (outline + two teal pixels), UI px.
const SLOT_BORDER := 3
## Dark pixels between the gun and the border, UI px.
const PAD := 1
const SLOT_FILL := Color("#0E1726")

const OUTLINE := Color("#332a20")
const UPPER_FILL := Color("#b96b4c")
const LOWER_FILL := Color("#dcceaf")
const STEEL_FILL := Color("#424a4d")
const GRIP_FILL := Color("#438f88")
const QUICKCYCLE_FILL := Color("#a9714a")

var _quickcycle_owned: bool = false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if has_art():
		custom_minimum_size = slot_size() * float(PixelUi.SCALE)


func set_quickcycle_owned(owned: bool) -> void:
	if _quickcycle_owned == owned:
		return
	_quickcycle_owned = owned
	queue_redraw()


func is_quickcycle_shown() -> bool:
	return _quickcycle_owned


func has_art() -> bool:
	return PixelUi.has_piece(SLOT) and PixelUi.has_piece(GUN)


## The slot's size in UI px: the gun, its padding and the frame's border.
func slot_size() -> Vector2:
	var gun := PixelUi.texture(GUN)
	if gun == null:
		return Vector2.ZERO
	return gun.get_size() + Vector2.ONE * float(2 * (SLOT_BORDER + PAD))


func _draw() -> void:
	if has_art():
		_draw_pixel()
	else:
		_draw_fallback()


func _draw_pixel() -> void:
	var s := float(PixelUi.SCALE)
	var slot_px: Vector2 = slot_size() * s
	var r := Rect2(((size - slot_px) * 0.5).floor(), slot_px)
	draw_rect(r.grow(-s), SLOT_FILL)
	PixelUi.draw_frame(self, SLOT, r, SLOT_MARGIN, s)
	var gun := PixelUi.texture(GUN)
	draw_texture_rect(gun, Rect2(r.position + Vector2.ONE * float(SLOT_BORDER + PAD) * s, gun.get_size() * s), false)
	if _quickcycle_owned:
		var pip := PixelUi.texture(PIP)
		if pip:
			var ps: Vector2 = pip.get_size() * s
			draw_texture_rect(pip, Rect2(r.end - ps - Vector2.ONE * float(SLOT_BORDER - 1) * s, ps), false)


func _draw_fallback() -> void:
	var o := Vector2(8.0, size.y * 0.5)
	draw_rect(Rect2(o + Vector2(-6, 0), Vector2(24, 7)), LOWER_FILL)
	draw_rect(Rect2(o + Vector2(-6, -7), Vector2(24, 7)), UPPER_FILL)
	draw_rect(Rect2(o + Vector2(-9, -1), Vector2(5, 6)), GRIP_FILL)
	draw_circle(o + Vector2(19, 0), 5.0, STEEL_FILL)
	draw_circle(o + Vector2(19, 0), 2.2, OUTLINE)
	draw_rect(Rect2(o + Vector2(-6, -7), Vector2(24, 14)), OUTLINE, false, 1.6)
	draw_rect(Rect2(o + Vector2(-9, -1), Vector2(5, 6)), OUTLINE, false, 1.2)
	draw_circle(o + Vector2(19, 0), 5.0, OUTLINE, false, 1.6)
	if _quickcycle_owned:
		draw_circle(o + Vector2(-3, 4.5), 3.0, QUICKCYCLE_FILL)
		draw_circle(o + Vector2(-3, 4.5), 3.0, OUTLINE, false, 1.0)
