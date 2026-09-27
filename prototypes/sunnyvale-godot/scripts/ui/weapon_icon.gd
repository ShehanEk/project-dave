extends Control
## Small always-visible Scrapjack silhouette for the HUD's "one carried
## weapon" slot (interface-and-accessibility.md "Carried weapon: One icon,
## weapon name on change, stage 0-3 pips"). Pure presentation — `Hud` tells
## it whether the Quickcycle stage is owned; it never reads Session/Settings
## itself. Mirrors scrapjack.gd's own C11 palette (w01-scrapjack-pistol.md)
## at icon scale, so the HUD tag and the held weapon read as the same gun.

const OUTLINE := Color("#332a20")
const UPPER_FILL := Color("#b96b4c")
const LOWER_FILL := Color("#dcceaf")
const STEEL_FILL := Color("#424a4d")
const GRIP_FILL := Color("#438f88")
const QUICKCYCLE_FILL := Color("#a9714a")

var _quickcycle_owned: bool = false


func set_quickcycle_owned(owned: bool) -> void:
	if _quickcycle_owned == owned:
		return
	_quickcycle_owned = owned
	queue_redraw()


func _draw() -> void:
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
