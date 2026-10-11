extends TestCase
## M7 Kenney UI integration pass — two contracts owned by this workflow slice
## (scripts/ui/controls_panel.gd + scenes/ui/controls_panel.tscn, and Main's
## own cursor-only addition to scripts/main.gd):
##   1. ControlsPanel: every documented row shows at least one input-prompt
##      icon (the pixel key caps and mice since the pixel UI pass, Sheet 12;
##      Kenney's before) for its CURRENT
##      binding, generated from InputMap exactly like the existing binding
##      text is — and a binding rebound onto a key that has no key cap
##      falls back to text-only for that one row, proving the
##      binding Label (built regardless of icons) is the real accessible
##      fallback the task asked for, not a decorative extra.
##   2. Main: the OS mouse cursor is the curated crosshair (assets/kenney/
##      README.md section 3) only during real gameplay (a Hero in the tree,
##      its input_enabled true, the tree not paused) and the plain arrow on
##      the Title screen, while paused, and during a "modal" moment
##      (WorkbenchPanel/SwapConfirm/the completion screen/CoreNode's SC01 all
##      already disable hero.input_enabled while open — CONVENTIONS.md "UI
##      scenes"/"core_node.tscn" — so this is simulated directly rather
##      than opening one of those screens for real) — read through
##      Main.get_cursor_mode(), the seam the task asked for since the
##      headless test display server has no real OS cursor to inspect and
##      Movie Maker capture may not render one either.
##
## This is one of the few cases that instances scenes/main.tscn to reach a
## real, fully-booted level (same reasoning/pattern as test_m6_audio.gd and
## test_m5_regress_title_newgame_honesty.gd) — it redirects Telemetry to a
## throwaway playtest dir first; CheckpointService itself is already
## redirected to a fresh throwaway user:// dir for the whole suite run by
## tests/run_tests.gd (CONVENTIONS.md), so no separate save-dir redirect is
## needed here.

const CONTROLS_PANEL_SCENE := "res://scenes/ui/controls_panel.tscn"
const InputIconMapScript := preload("res://scripts/ui/input_icon_map.gd")
const MAIN_SCENE := "res://scenes/main.tscn"


func run() -> void:
	await _test_rows_show_icons_for_current_bindings()
	await _test_row_falls_back_to_text_when_no_icon()
	await _test_cursor_mode_gameplay_vs_paused_vs_modal()


# --- 1. every row's CURRENT binding(s) show at least one matching icon -----------

func _test_rows_show_icons_for_current_bindings() -> void:
	var panel: ControlsPanel = await spawn(CONTROLS_PANEL_SCENE)

	check_eq(panel._icon_boxes.size(), panel._row_labels.size(),
			"setup: one icon box built per documented row")

	for i in panel._icon_boxes.size():
		var box: HBoxContainer = panel._icon_boxes[i]
		var row_name: String = String(ControlsPanel.ROWS[i]["name"])
		check(box.get_child_count() > 0,
				"row '%s' shows at least one input-prompt icon for its current binding" % row_name)
		for child in box.get_children():
			check(child is TextureRect, "row '%s' icon child is a TextureRect" % row_name)
			check((child as TextureRect).texture != null,
					"row '%s' icon is a real loaded texture, not an empty placeholder" % row_name)

	panel.queue_free()
	await physics_frames(2)


# --- 2. a binding with no matching icon file falls back to text only ------------

func _test_row_falls_back_to_text_when_no_icon() -> void:
	var panel: ControlsPanel = await spawn(CONTROLS_PANEL_SCENE)

	var original_events := InputMap.action_get_events(&"interact").duplicate()
	InputMap.action_erase_events(&"interact")
	var new_event := InputEventKey.new()
	# No key cap for this one: the pixel font cannot letter ";" (a real
	# layout) and "Semicolon" (headless) is longer than a cap holds. Since the
	# pixel UI pass, Q has a cap like every other letter.
	new_event.physical_keycode = KEY_SEMICOLON
	InputMap.action_add_event(&"interact", new_event)
	panel.refresh()
	await physics_frames(1)

	var interact_row_index := -1
	for i in ControlsPanel.ROWS.size():
		var actions: Array = ControlsPanel.ROWS[i]["actions"]
		if actions.has("interact"):
			interact_row_index = i
			break
	check(interact_row_index >= 0, "setup: found the Interact row")

	if interact_row_index >= 0:
		var box: HBoxContainer = panel._icon_boxes[interact_row_index]
		check_eq(box.get_child_count(), 0,
				"a binding with no matching icon file shows no icon for that row")

	var label: Label = panel.binding_labels.get("interact")
	check_eq(label.text if label else "", InputIconMapScript.key_label(KEY_SEMICOLON),
			"...but the row's binding TEXT still names the current key, as the accessible fallback")

	# Restore the real project binding so no later test/real player inherits
	# a rebound "interact" action, same cleanup pattern as
	# test_help_controls.gd's own rebinding case.
	InputMap.action_erase_events(&"interact")
	for event in original_events:
		InputMap.action_add_event(&"interact", event)
	panel.refresh()
	await physics_frames(1)
	check_eq(panel.binding_labels.get("interact").text, "E", "cleanup: interact's real binding is restored")
	check(panel._icon_boxes[interact_row_index].get_child_count() > 0,
			"cleanup: the Interact row's icon is back once its real (iconed) binding is restored")

	panel.queue_free()
	await physics_frames(2)


# --- 3. Main's gameplay cursor: crosshair in gameplay, arrow paused/modal -------

func _test_cursor_mode_gameplay_vs_paused_vs_modal() -> void:
	var test_playtest_dir := "user://test_runs/kenney_ui_cursor_%d" % Time.get_ticks_usec()
	Telemetry.set_playtest_dir(test_playtest_dir)

	var main: Node = load(MAIN_SCENE).instantiate()
	add_child(main)
	await physics_frames(3)
	check_eq(main.get_cursor_mode(), "arrow", "Title screen: cursor is the plain arrow")

	main._on_new_game_confirmed()
	await physics_frames(6)

	var hero: Node = get_tree().get_first_node_in_group("hero")
	check(hero != null, "setup: New Game reached gameplay with a real Hero in the tree")
	if hero == null:
		main.queue_free()
		await physics_frames(2)
		Telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
		return

	check(hero.input_enabled, "setup: hero input is enabled at level start")
	check(not get_tree().paused, "setup: the tree is not paused at level start")
	check_eq(main.get_cursor_mode(), "crosshair",
			"gameplay (hero present, input enabled, not paused): cursor is the crosshair")

	get_tree().paused = true
	await physics_frames(2)
	check_eq(main.get_cursor_mode(), "arrow", "paused: cursor returns to the plain arrow")

	get_tree().paused = false
	await physics_frames(2)
	check_eq(main.get_cursor_mode(), "crosshair", "unpaused again: cursor returns to the crosshair")

	# A "modal" moment (WorkbenchPanel/SwapConfirm/the completion screen/SC01)
	# disables hero.input_enabled without pausing the tree — Main's own
	# cursor check already keys off that same flag, so simulating it
	# directly here proves the contract without opening a real modal scene.
	hero.input_enabled = false
	await physics_frames(2)
	check_eq(main.get_cursor_mode(), "arrow",
			"a modal moment (hero.input_enabled = false, tree unpaused) shows the plain arrow")

	hero.input_enabled = true
	await physics_frames(2)
	check_eq(main.get_cursor_mode(), "crosshair", "closing the modal restores the crosshair")

	main.queue_free()
	await physics_frames(2)
	Telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
