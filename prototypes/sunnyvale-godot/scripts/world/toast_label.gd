class_name ToastLabel
extends Label
## Small reusable "X happened" toast: shows text, holds, fades, hides.
## Attached to a child Label named "Toast" in interactable scenes so they
## don't each reimplement the same tween.

const HOLD_TIME := 1.1
const FADE_TIME := 0.6
## Backing plate (sc01-double-toast/weapon-pad-toast-overlap): matches
## SubtitlePanel's own dark backing so plain white toast text stays legible
## over ANY world background (a bright sky, light gardens) rather than
## depending on whatever happens to be behind this particular instance.
## AD-17: this used to be a separate purplish tone instead of the actual C11
## warm-charcoal token (#332a20-family) SubtitlePanel itself uses
## (scenes/ui/subtitle_panel.tscn's own StyleBoxFlat) — now it's the exact
## same bg/border pair so every toast and the subtitle panel read as one
## consistent UI material.
const BACKING := Color(0.027, 0.035, 0.059, 0.88)
const OUTLINE := Color(0.11, 0.165, 0.227, 1.0)


func _ready() -> void:
	visible = false
	modulate.a = 1.0
	var style := StyleBoxFlat.new()
	style.bg_color = BACKING
	style.border_color = OUTLINE
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	add_theme_stylebox_override("normal", style)


func show_message(message: String, hold: float = HOLD_TIME, fade: float = FADE_TIME) -> void:
	text = message
	modulate = Color(1, 1, 1, 1)
	visible = true
	var tween := create_tween()
	tween.tween_interval(hold)
	tween.tween_property(self, "modulate:a", 0.0, fade)
	tween.tween_callback(func(): visible = false)
