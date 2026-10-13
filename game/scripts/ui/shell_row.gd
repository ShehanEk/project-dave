extends Control
## The Boom Broom's tube in the HUD (batch 7): one shell icon per shell the tube holds, lit
## (`shell_lit`, the red shell) for each loaded one and dark (`shell_unlit`) for each spent one,
## beside the weapon slot; the reserve stays a number after it (Hud's AmmoLabel). Pure
## presentation: Hud sets `capacity` and `loaded`. Without the icons `has_art()` is false and Hud
## keeps the "4/24" text. No class_name (Hud preloads it).

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")
const LIT := "shell_lit"
const DARK := "shell_unlit"
## UI px between two shells.
const GAP := 1

var capacity: int = 0
var loaded: int = 0


func has_art() -> bool:
	return PixelUi.has_piece(LIT) and PixelUi.has_piece(DARK)


func set_shells(new_loaded: int, new_capacity: int) -> void:
	loaded = clampi(new_loaded, 0, maxi(new_capacity, 0))
	capacity = maxi(new_capacity, 0)
	var tex := PixelUi.texture(LIT)
	if tex:
		var s := float(PixelUi.SCALE)
		custom_minimum_size = Vector2((tex.get_size().x * capacity + GAP * maxi(capacity - 1, 0)) * s, tex.get_size().y * s)
	queue_redraw()


func _draw() -> void:
	var lit := PixelUi.texture(LIT)
	var dark := PixelUi.texture(DARK)
	if lit == null or dark == null:
		return
	var s := float(PixelUi.SCALE)
	var sz: Vector2 = lit.get_size() * s
	var y: float = floorf((size.y - sz.y) * 0.5)
	for i in capacity:
		var x: float = float(i) * (sz.x + GAP * s)
		draw_texture_rect(lit if i < loaded else dark, Rect2(Vector2(x, y), sz), false)
