extends TestCase
## Help/controls menu (new "help" InputMap action bound to F1;
## scenes/ui/controls_panel.tscn, scripts/ui/controls_panel.gd) contracts:
##   1. ControlsPanel has exactly one row per non-ui_* InputMap action (a
##      future action added anywhere in the project without a matching row
##      here fails loudly instead of silently going undocumented).
##   2. Every row shows the EXACT current binding (this project's own default
##      InputMap, as scripts/tools/configure_project.gd writes it).
##   3. refresh() re-reads InputMap live: rebinding an action and calling
##      refresh() again changes the displayed text (restored afterwards).
##   4. Title screen: the Controls button opens the Controls view; Back
##      (button) and Escape both close it, restoring focus to the Controls
##      button itself (not New Game).
##   5. Pause menu: Controls opens both from the pause menu's own "Controls"
##      button AND directly from gameplay via the "help" action (F1) — the
##      same `_can_open()` gating Tab/Journal already uses — pauses the tree,
##      Escape/back returns to the pause main view (not Resume), and Resume
##      from there actually unpauses.
##   6. Settings "text size" enlarges the panel's own labels (title, a row
##      binding label, and the Back button), same live-Settings.changed
##      pattern as every other UI screen (CONVENTIONS.md).
##
## Never touches a real save: redirects CheckpointService to a throwaway
## user:// dir for the whole run, same pattern as test_m6_ui.gd.

const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
const PAUSE_SCENE := "res://scenes/ui/pause.tscn"
const CONTROLS_PANEL_SCENE := "res://scenes/ui/controls_panel.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"


func run() -> void:
	var base_dir: String = CheckpointService.get_save_dir()
	var test_dir := "user://test_runs/help_controls_%d" % Time.get_ticks_usec()
	CheckpointService.set_save_dir(test_dir)

	await _test_rows_cover_every_action()
	await _test_rows_show_exact_current_bindings()
	await _test_refresh_reflects_rebinding()
	await _test_title_controls_open_and_back()
	await _test_pause_controls_open_and_back()
	await _test_text_size_applies()

	CheckpointService.remove_dir_recursive(test_dir)
	CheckpointService.set_save_dir(base_dir)


# --- 1. every non-ui_* InputMap action has exactly one row -----------------------

func _test_rows_cover_every_action() -> void:
	var panel: ControlsPanel = await spawn(CONTROLS_PANEL_SCENE)
	var covered := panel.get_covered_actions()

	var gameplay_actions: PackedStringArray = []
	for action in InputMap.get_actions():
		var name := String(action)
		if name.begins_with("ui_"):
			continue
		gameplay_actions.append(name)

	for name in gameplay_actions:
		check(covered.has(name), "ControlsPanel has a row for InputMap action '%s'" % name)

	check_eq(covered.size(), gameplay_actions.size(),
			"ControlsPanel documents exactly the gameplay actions in InputMap, no more/fewer (got %s, want %s)"
					% [str(covered), str(gameplay_actions)])

	panel.queue_free()
	await physics_frames(2)


# --- 2. exact current bindings (this project's own default InputMap) -------------

func _test_rows_show_exact_current_bindings() -> void:
	var panel: ControlsPanel = await spawn(CONTROLS_PANEL_SCENE)

	check_eq(panel.get_covered_actions().has("move_left"), true, "setup: move row covers move_left")
	check_eq(_row_text_for(panel, "move_left"), "A / D  or  ← / →",
			"Move row combines move_left/move_right into the documented format")
	check_eq(_row_text_for(panel, "jump"), "Space / W / ↑", "Jump row shows its exact current bindings")
	check_eq(_row_text_for(panel, "fire"), "Left mouse button", "Fire row names the mouse button, not a raw index")
	check_eq(_row_text_for(panel, "interact"), "E", "Interact row shows its exact current binding")
	check_eq(_row_text_for(panel, "pause"), "Esc", "Pause row shows its exact current binding")
	check_eq(_row_text_for(panel, "journal"), "Tab", "Journal row shows its exact current binding")
	check_eq(_row_text_for(panel, "skip"), "Enter", "Skip row collapses Enter/Numpad Enter into one label")
	check_eq(_row_text_for(panel, "help"), "F1", "Controls-help row shows its exact current binding")

	panel.queue_free()
	await physics_frames(2)


func _row_text_for(panel: ControlsPanel, action: String) -> String:
	var label: Label = panel.binding_labels.get(action)
	return label.text if label else ""


# --- 3. refresh() re-reads InputMap live (rebinding), restored afterwards --------

func _test_refresh_reflects_rebinding() -> void:
	var panel: ControlsPanel = await spawn(CONTROLS_PANEL_SCENE)

	var before := _row_text_for(panel, "interact")
	check_eq(before, "E", "setup: interact starts bound to E")

	var original_events := InputMap.action_get_events(&"interact").duplicate()
	InputMap.action_erase_events(&"interact")
	var new_event := InputEventKey.new()
	new_event.physical_keycode = KEY_F
	InputMap.action_add_event(&"interact", new_event)

	panel.refresh()
	check_eq(_row_text_for(panel, "interact"), "F",
			"refresh() re-reads InputMap: a rebound action's displayed text changes")

	# Restore the real project binding so no later test case (or a real
	# player, if this ever ran outside a throwaway process) inherits a
	# rebound "interact" action.
	InputMap.action_erase_events(&"interact")
	for event in original_events:
		InputMap.action_add_event(&"interact", event)
	panel.refresh()
	check_eq(_row_text_for(panel, "interact"), "E", "cleanup: interact's real binding is restored")

	panel.queue_free()
	await physics_frames(2)


# --- 4. Title screen: Controls opens/closes, focus restored to Controls button ---

func _test_title_controls_open_and_back() -> void:
	var title: TitleScreen = await spawn(TITLE_SCENE)

	check_eq(title._view, TitleScreen.View.MAIN, "setup: title starts on the main view")
	title._on_controls_pressed()
	check_eq(title._view, TitleScreen.View.CONTROLS, "Controls button opens the Controls view")
	check(title._controls_view.visible, "the ControlsView is actually visible")
	check(not title._main_view.visible, "the main view is hidden while Controls is open")

	press(&"pause")
	await physics_frames(1)
	release(&"pause")
	await physics_frames(1)
	check_eq(title._view, TitleScreen.View.MAIN, "Escape closes the Controls view, returning to main")
	check(title._main_view.visible, "the main view is visible again")
	check(title._controls_button.has_focus(),
			"focus is restored to the Controls button specifically (not New Game)")

	# The Back button itself does the same thing.
	title._on_controls_pressed()
	check_eq(title._view, TitleScreen.View.CONTROLS, "setup: Controls open again")
	title._controls_view.back_pressed.emit()
	check_eq(title._view, TitleScreen.View.MAIN, "the panel's own Back button also closes the view")
	check(title._controls_button.has_focus(), "...and also restores focus to the Controls button")

	# F1 (help) opens Controls straight from the main view, same as the button.
	press(&"help")
	await physics_frames(1)
	release(&"help")
	await physics_frames(1)
	check_eq(title._view, TitleScreen.View.CONTROLS, "F1 opens the Controls view from the title screen")

	title.queue_free()
	await physics_frames(2)


# --- 5. Pause menu: Controls opens from the button AND from gameplay via help ----

func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load(HERO_SCENE).instantiate()
	add_child(hero)
	hero.debug_invulnerable = true
	hero.global_position = pos
	return hero


func _test_pause_controls_open_and_back() -> void:
	Session.new_run()
	var hero := _make_hero(Vector2(0, 96))
	var pause_menu: PauseMenu = load(PAUSE_SCENE).instantiate()
	add_child(pause_menu)
	pause_menu.setup(hero)
	# Enough frames for PauseMenu's own open-readiness streak (2 frames).
	await physics_frames(4)

	check(not get_tree().paused, "setup: the tree starts unpaused")

	# From gameplay, F1 opens the pause menu directly on the Controls view —
	# exactly like Tab opens the Journal — and pauses the game.
	press(&"help")
	await physics_frames(1)
	release(&"help")
	await physics_frames(1)
	check(get_tree().paused, "help: opens the pause menu and pauses the tree")
	check_eq(pause_menu._view, PauseMenu.View.CONTROLS, "help: opens directly on the Controls view")
	check(pause_menu._controls_view.visible, "help: the ControlsView is visible")

	# Escape/back returns to the pause MAIN view (not Resume) — same as every
	# other pause sub-view (Journal/Settings).
	press(&"pause")
	await physics_frames(1)
	release(&"pause")
	await physics_frames(1)
	check_eq(pause_menu._view, PauseMenu.View.MAIN, "escape from Controls returns to the pause main view")
	check(get_tree().paused, "...and the game remains paused (Escape from a sub-view is not Resume)")

	# The pause menu's own "Controls" button reaches the same view.
	pause_menu._on_controls_pressed()
	check_eq(pause_menu._view, PauseMenu.View.CONTROLS, "the pause menu's Controls button opens the Controls view")
	check(pause_menu._controls_view.visible, "...ControlsView visible")

	press(&"pause")
	await physics_frames(1)
	release(&"pause")
	await physics_frames(1)
	check_eq(pause_menu._view, PauseMenu.View.MAIN, "escape returns to the main view again")

	# Resume (from the main view) actually unpauses.
	press(&"pause")
	await physics_frames(1)
	release(&"pause")
	await physics_frames(1)
	check(not get_tree().paused, "Resume from the main view unpauses the tree")
	check_eq(pause_menu._view, PauseMenu.View.CLOSED, "...and closes the menu")

	pause_menu.queue_free()
	hero.queue_free()
	get_tree().paused = false
	await physics_frames(2)


# --- 6. Settings text size enlarges the panel's own labels ------------------------

func _test_text_size_applies() -> void:
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	var panel: ControlsPanel = await spawn(CONTROLS_PANEL_SCENE)

	var title_label: Label = panel.get_node("TitleLabel")
	var jump_label: Label = panel.binding_labels["jump"]
	var back_button: Button = panel.get_node("BackButton")

	var base_title: int = title_label.get_theme_font_size("font_size")
	var base_jump: int = jump_label.get_theme_font_size("font_size")
	var base_back: int = back_button.get_theme_font_size("font_size")

	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	await physics_frames(1)
	check_eq(title_label.get_theme_font_size("font_size"), Settings.scaled_font_size(base_title),
			"ControlsPanel title label scales up live on Settings.changed (large text)")
	check_eq(jump_label.get_theme_font_size("font_size"), Settings.scaled_font_size(base_jump),
			"ControlsPanel row binding label scales up live on Settings.changed (large text)")
	check_eq(back_button.get_theme_font_size("font_size"), Settings.scaled_font_size(base_back),
			"ControlsPanel Back button scales up live on Settings.changed (large text)")

	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	await physics_frames(1)
	check_eq(title_label.get_theme_font_size("font_size"), base_title,
			"ControlsPanel title label scales back down when text size returns to normal")

	panel.queue_free()
	await physics_frames(2)
