extends Control
## Small microchip icon beside the HUD wallet count
## (interface-and-accessibility.md "microchip counter"). Purely decorative —
## `Hud` owns the number — colored to match the world Chip's own palette
## (scripts/objects/chip.gd) so the HUD icon and the pickups it represents
## read as the same thing.

const OUTLINE := Color("#07090F")
const BODY := Color("#1C2A3A")
const GOLD := Color("#FFD166")
const SHINE := Color("#FFF2C4")


func _draw() -> void:
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
