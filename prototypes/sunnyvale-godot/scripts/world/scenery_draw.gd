class_name SceneryDraw
extends RefCounted
## Tiny shared drawing helpers so paired objects (e.g. route_switch and
## service_walkway) can draw the exact same matching symbol without one
## depending on the other's script. Call from inside the caller's own
## _draw() with `self` as `node`.

const OUTLINE := Color("#332a20")
const ON_COLOR := Color("#87b45e")
const OFF_COLOR := Color("#c9663f")


static func draw_switch_symbol(node: CanvasItem, pos: Vector2, on: bool) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(-7.0, 6.0), pos + Vector2(7.0, 6.0), pos + Vector2(0.0, -7.0),
	])
	node.draw_colored_polygon(pts, ON_COLOR if on else OFF_COLOR)
	node.draw_polyline(pts, OUTLINE, 2.0, true)
	node.draw_line(pts[2], pts[0], OUTLINE, 2.0)
