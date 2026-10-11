extends TestCase
## REGRESSION (M7 controls-help-menu adversarial review, "clip-large-text",
## plus a second bug found fixing it): at Settings' Large text size the
## table's real measured height (all row fonts scaled 1.25x, per
## Settings.scaled_font_size()) is bigger than the shared host Panel
## (title_screen.tscn/pause.tscn, 640x500) has room for even after hiding
## its own title/message row for Controls. An early fix sized the Scroll to
## the Table's full measured height unconditionally, which "fixed" the
## clipping by instead pushing the WHOLE ControlsPanel (its Tips section and
## Back button) past the host Panel's own drawn bottom edge — Back rendered
## floating on the plain background below the panel box, outside it, at
## Large text.
##
## Fixed by controls_panel.gd's `_resize_scroll_to_table()` capping the
## Scroll to HOST_BUDGET_HEIGHT minus the header/Back button's own (also
## text-size-scaled) room, so the WHOLE view — including Back — always stays
## inside the shared host Panel, and the table itself (not the rest of the
## view) is what stays scrollable when Large text genuinely doesn't fit.
## This case locks in that no-overflow contract directly (never a screenshot
## diff): Back's bottom edge never sits below the host rect's own bottom
## edge, at both text sizes.

const CONTROLS_PANEL_SCENE := "res://scenes/ui/controls_panel.tscn"
const HOST_WIDTH := 592.0
const HOST_HEIGHT := 460.0


func _check_no_overflow(settings: Node, text_size: String) -> void:
	settings.set_text_size(text_size)

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.disable_3d = true
	add_child(vp)

	var panel: ControlsPanel = load(CONTROLS_PANEL_SCENE).instantiate()
	vp.add_child(panel)
	panel.size = Vector2(HOST_WIDTH, HOST_HEIGHT)
	await physics_frames(3)

	var host_bottom: float = panel.global_position.y + HOST_HEIGHT
	var back: Button = panel.get_node("BackButton")
	var back_bottom: float = back.global_position.y + back.size.y
	check(back_bottom <= host_bottom + 1.0,
			"text_size=%s: the Back button stays inside the host Panel's own bottom edge, never floating past it (back bottom %.1f, host bottom %.1f)"
					% [text_size, back_bottom, host_bottom])
	check(panel.size.y <= HOST_HEIGHT + 1.0,
			"text_size=%s: the whole ControlsPanel never grows past the host's given rect (panel height %.1f, host height %.1f)"
					% [text_size, panel.size.y, HOST_HEIGHT])

	panel.queue_free()
	vp.queue_free()
	await physics_frames(2)


func run() -> void:
	var settings := get_node("/root/Settings")
	var original_size: String = settings.get_text_size()

	await _check_no_overflow(settings, Settings.TEXT_SIZE_NORMAL)
	await _check_no_overflow(settings, Settings.TEXT_SIZE_LARGE)

	settings.set_text_size(original_size)
	await physics_frames(1)
