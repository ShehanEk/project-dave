extends TestCase
## REGRESSION (M7 controls-help-menu adversarial review, "clip-normal-text"):
## the Controls table's ScrollContainer had a hardcoded
## `custom_minimum_size.y = 340`, guessed without ever measuring the real
## rendered table — at Settings' Normal text size (the default every player
## starts with) that guess was too small by about 15-20px, silently clipping
## the descenders off the LAST row ("Controls help" / "F1") behind the
## ScrollContainer's own clip boundary. A player had to notice the thin
## scrollbar and scroll to read the one row that explains how to reopen this
## screen, despite the panel being sized specifically to avoid that.
##
## Fixed by controls_panel.gd's `_resize_scroll_to_table()`: the Scroll is
## now sized off the Table's OWN measured `get_combined_minimum_size()`
## (re-run off `_table.minimum_size_changed`, never a fixed guess). This case
## locks in the actual contract: at Normal text, every row's binding Label
## sits ENTIRELY above the Scroll's own bottom edge — nothing needs to be
## scrolled to read the whole table — using a SubViewport of a fixed size
## (the same technique test_m7_pause_and_resize.gd uses) so the measurement
## is a real, deterministic layout pass rather than root's own unreliable
## headless viewport size.

const CONTROLS_PANEL_SCENE := "res://scenes/ui/controls_panel.tscn"

## The real shared host Panel (title_screen.tscn/pause.tscn) gives this view
## a 592x460 rect once its own title/message row is hidden for Controls (see
## controls_panel.gd's own HOST_BUDGET_HEIGHT doc comment) — reproduced here
## so this is testing the same layout budget the real UI actually gives it.
const HOST_WIDTH := 592.0
const HOST_HEIGHT := 460.0


func run() -> void:
	var settings := get_node("/root/Settings")
	var original_size: String = settings.get_text_size()
	settings.set_text_size(Settings.TEXT_SIZE_NORMAL)

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.disable_3d = true
	add_child(vp)

	var panel: ControlsPanel = load(CONTROLS_PANEL_SCENE).instantiate()
	vp.add_child(panel)
	panel.size = Vector2(HOST_WIDTH, HOST_HEIGHT)
	await physics_frames(3)

	var scroll: ScrollContainer = panel.get_node("Scroll")
	var scroll_bottom: float = scroll.global_position.y + scroll.size.y

	check(panel._row_labels.size() == 9, "setup: the table has all 9 documented rows")
	for i in panel._row_labels.size():
		var label: Label = panel._row_labels[i]
		var label_bottom: float = label.global_position.y + label.size.y
		check(label_bottom <= scroll_bottom + 1.0,
				"row %d ('%s') is fully visible above the Scroll's bottom edge with no clipping (label bottom %.1f, scroll bottom %.1f)"
						% [i, label.text, label_bottom, scroll_bottom])

	panel.queue_free()
	vp.queue_free()
	settings.set_text_size(original_size)
	await physics_frames(2)
