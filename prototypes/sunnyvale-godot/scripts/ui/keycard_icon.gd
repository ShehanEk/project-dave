extends Control
## Revamp (C24): small clearance-card icon in the HUD top bar, shown once
## the level's keycard is held (interface-and-accessibility.md "keycard
## indicator"). Purely decorative — `Hud` decides visibility — and drawn to
## match the world Keycard (scripts/objects/keycard.gd).

const OUTLINE := Color("#07090F")
const BODY := Color("#1C2A3A")
const STRIPE := Color("#3FE0D0")
const CHIP := Color("#FFD166")


func _draw() -> void:
	var r := Rect2(Vector2(2.0, (size.y - 16.0) * 0.5), Vector2(size.x - 4.0, 16.0))
	draw_rect(r, BODY)
	draw_rect(Rect2(r.position + Vector2(0.0, 3.0), Vector2(r.size.x, 3.5)), STRIPE)
	draw_rect(Rect2(r.position + Vector2(3.0, 9.0), Vector2(6.0, 4.5)), CHIP)
	draw_rect(r, OUTLINE, false, 1.6)
