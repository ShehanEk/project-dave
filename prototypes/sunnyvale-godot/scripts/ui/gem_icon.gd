extends Control
## Small gem-diamond icon beside the HUD wallet count
## (interface-and-accessibility.md "Gems: small increment on collection").
## Purely decorative — `Hud` owns the number — colored to match the world
## Gem's own palette (scripts/objects/gem.gd) so the HUD icon and the
## pickups it represents read as the same thing.

const OUTLINE := Color("#332a20")
const FILL := Color("#f4d35e")
const SHINE := Color("#fff6d9")


func _draw() -> void:
	var c := size * 0.5
	var pts := PackedVector2Array([
		c + Vector2(0, -9), c + Vector2(7, -1), c + Vector2(0, 9), c + Vector2(-7, -1),
	])
	draw_colored_polygon(pts, FILL)
	draw_polyline(pts + PackedVector2Array([pts[0]]), OUTLINE, 1.6)
	draw_line(c + Vector2(0, -9), c + Vector2(0, 9), OUTLINE, 1.0)
	draw_line(c + Vector2(-7, -1), c + Vector2(7, -1), OUTLINE, 1.0)
	draw_circle(c + Vector2(-2, -3), 1.5, SHINE)
