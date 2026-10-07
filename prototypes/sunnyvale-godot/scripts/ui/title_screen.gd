class_name TitleScreen
extends Control
## Title screen (M5 part 2, scenes/main.tscn). Reads/calls only
## `CheckpointService` (never mutates `Session` itself — Main adopts the
## chosen snapshot/new run right before instancing the level, matching every
## other UI scene's "opener owns the action, this node owns its own buttons"
## split, per CONVENTIONS.md). Continue is enabled only when
## `CheckpointService.has_valid_save()`; pressing it always uses whatever
## `load_latest()` actually returns (transparently the backup when the
## primary is bad — "offer the backup" per the M5 part 2 brief IS this: a
## valid backup makes `has_valid_save()`/`load_latest().ok` true and Continue
## just works, with an honest "restored from backup" message). Only when
## BOTH the primary and backup are invalid/missing does Continue become
## unavailable, and Continue is disabled/hidden in that case anyway — the
## message area explains why and points at New Game, never a dead end.
##
## Look (2026-10-07): the pixel title art. A night-campus backdrop (1280x720,
## drawn covering whatever window shape there is, linear filtered) with the
## DEAD EDEN logo (a 150x33 pixel drawing, nearest filtered, shown at a whole
## number scale) over the calm sky at the top right and the menu panel under
## it. The logo and menu are laid out against a 1280x720 "stage" centred in
## the window (the project's base canvas), so a wider or taller window just
## shows more or less backdrop around the same composition. `TitleLabel` keeps
## the text "DEAD EDEN" (the logo's accessible name, and what the screen shows
## if the art is missing) but is hidden while the logo is on screen.

signal new_game_confirmed
signal continue_confirmed(snapshot: Dictionary)
signal quit_requested

enum View { MAIN, NEW_GAME_CONFIRM, CONTROLS }

const LOGO_PATH := "res://assets/ui/pixel/title_logo.png"
const BACKDROP_PATH := "res://assets/ui/pixel/title_backdrop.png"

## The composition is authored against the project's base canvas.
const STAGE_SIZE := Vector2(1280, 720)
## Biggest whole-number logo scale (150x33 -> 750x165 on the stage). It is
## capped so the logo stays right of the glowing tower in the backdrop, and
## lowered on a stage too small for it (never a fractional scale).
const LOGO_MAX_SCALE := 5
const LOGO_STAGE_FRACTION := 0.6  # the logo's width never exceeds this share of the stage
const LOGO_MARGIN := Vector2(28, 32)  # right and top margins on the stage
const TAGLINE_GAP := 8.0
const MENU_WIDTH := 400.0
const MENU_GAP := 8.0
const MENU_PADDING := 40.0  # the VBox's own top + bottom inset inside the Panel
## The menu panel lets the backdrop show through; the dense Controls table
## sits on a solid panel so its text stays readable.
const PANEL_ALPHA := 0.9
## The Controls table needs the shared 640x500 host Panel (ControlsPanel's
## HOST_BUDGET_HEIGHT); it replaces the logo while open, right of the tower.
const CONTROLS_RECT := Rect2(560, 110, 640, 500)

## The tower emblem's centre in the 1280x720 backdrop, and the size of the
## soft teal glow laid over it (scaled with the backdrop). The glow breathes
## slowly (and holds still under Settings' reduced motion).
const GLOW_CENTER := Vector2(409, 148)
const GLOW_SIZE := 170.0
const GLOW_LOW := 0.25
const GLOW_HIGH := 0.8
const GLOW_PERIOD := 5.0  # seconds for one full breath

@onready var _backdrop: TextureRect = $Backdrop
@onready var _glow: TextureRect = $Glow
@onready var _logo: TextureRect = $Logo
@onready var _tagline: Label = $Tagline
@onready var _panel: Panel = $Panel
@onready var _vbox: VBoxContainer = $Panel/VBox
@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _new_game_button: Button = $Panel/VBox/MainView/ButtonRow/NewGameButton
@onready var _continue_button: Button = $Panel/VBox/MainView/ButtonRow/ContinueButton
@onready var _controls_button: Button = $Panel/VBox/MainView/ButtonRow/ControlsButton
@onready var _quit_button: Button = $Panel/VBox/MainView/ButtonRow/QuitButton
@onready var _message_label: Label = $Panel/VBox/MessageLabel
@onready var _main_view: VBoxContainer = $Panel/VBox/MainView
@onready var _confirm_view: VBoxContainer = $Panel/VBox/ConfirmView
@onready var _confirm_button: Button = $Panel/VBox/ConfirmView/ConfirmRow/ConfirmButton
@onready var _cancel_button: Button = $Panel/VBox/ConfirmView/ConfirmRow/CancelButton
@onready var _controls_view: ControlsPanel = $Panel/VBox/ControlsView

var _view: View = View.MAIN
var _pause_was_pressed: bool = false
var _help_was_pressed: bool = false
var _text_size_bases: Dictionary = {}  # Control -> base font size (M6 text-size setting)

## Overridable before add_child() (a test points them at a missing file to
## prove the screen still works without its art).
var logo_path: String = LOGO_PATH
var backdrop_path: String = BACKDROP_PATH
var logo_scale: int = 1  # the whole-number scale the logo is drawn at
var _has_logo: bool = false
var _has_backdrop: bool = false
var _glow_tween: Tween = null


func _ready() -> void:
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_controls_button.pressed.connect(_on_controls_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_confirm_button.pressed.connect(_on_new_game_confirm)
	_cancel_button.pressed.connect(_on_new_game_cancel)
	_controls_view.back_pressed.connect(_on_controls_back)
	_set_message("")
	_load_art()
	refresh()
	_show_main_view()
	_collect_text_size_bases($Panel)
	_text_size_bases[_tagline] = _tagline.get_theme_font_size("font_size")
	_apply_text_size()
	var settings := get_node_or_null("/root/Settings")
	if settings:
		if not settings.changed.is_connected(_apply_text_size):
			settings.changed.connect(_apply_text_size)
		if not settings.changed.is_connected(_update_glow_motion):
			settings.changed.connect(_update_glow_motion)
	resized.connect(_layout)
	_vbox.minimum_size_changed.connect(_fit_panel)
	_layout()
	_update_glow_motion()


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_apply_text_size):
		settings.changed.disconnect(_apply_text_size)
	if settings and settings.changed.is_connected(_update_glow_motion):
		settings.changed.disconnect(_update_glow_motion)


## Loads the two pictures. Either may be missing (a fresh checkout before the
## art is imported, a test pointing at nothing): the plain dark Background then
## shows and the TitleLabel text stands in for the logo — every button still
## works.
func _load_art() -> void:
	var backdrop_tex: Texture2D = _load_texture(backdrop_path)
	_has_backdrop = backdrop_tex != null
	_backdrop.texture = backdrop_tex
	_backdrop.visible = _has_backdrop
	_glow.visible = _has_backdrop
	var logo_tex: Texture2D = _load_texture(logo_path)
	_has_logo = logo_tex != null
	_logo.texture = logo_tex


func _load_texture(path: String) -> Texture2D:
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


## Places the logo, tagline, menu panel and emblem glow for the current window
## size (called on every resize, view change and when the menu's content size
## changes). The logo is the anchor: top-right of the stage, at the biggest
## whole-number scale that fits; the tagline sits under it and the menu panel
## under that, both centred on it.
func _layout() -> void:
	var stage := Vector2(minf(size.x, STAGE_SIZE.x), minf(size.y, STAGE_SIZE.y))
	var origin := (size - stage) * 0.5

	# Backdrop emblem glow: follows the covered (cropped) backdrop exactly.
	var cover := maxf(size.x / STAGE_SIZE.x, size.y / STAGE_SIZE.y)
	var backdrop_origin := (size - STAGE_SIZE * cover) * 0.5
	var glow_size := GLOW_SIZE * cover
	_glow.size = Vector2(glow_size, glow_size)
	_glow.position = backdrop_origin + GLOW_CENTER * cover - _glow.size * 0.5

	var logo_native := _logo.texture.get_size() if _has_logo else Vector2(150, 33)
	logo_scale = clampi(int(floor(stage.x * LOGO_STAGE_FRACTION / logo_native.x)), 1, LOGO_MAX_SCALE)
	var logo_size := logo_native * float(logo_scale)
	_logo.size = logo_size
	_logo.position = origin + Vector2(stage.x - LOGO_MARGIN.x - logo_size.x, LOGO_MARGIN.y)
	var cx := _logo.position.x + logo_size.x * 0.5

	# The tagline wraps to a second line at Large text rather than running off
	# the window edge: set the width first, then read the wrapped height.
	var tagline_width := minf(700.0, stage.x - 2.0 * LOGO_MARGIN.x)
	_tagline.size = Vector2(tagline_width, 0.0)
	_tagline.size = Vector2(tagline_width, _tagline.get_combined_minimum_size().y)
	_tagline.position = Vector2(cx - tagline_width * 0.5, _logo.position.y + logo_size.y + TAGLINE_GAP)
	_tagline.position.x = clampf(_tagline.position.x, origin.x, origin.x + stage.x - tagline_width)

	_fit_panel()


## The menu is a column centred under the logo, as tall as its content (so the
## backdrop shows under it); the Controls view instead takes its fixed
## 640x500 rect. Never past the window's own edges.
func _fit_panel() -> void:
	if not is_node_ready():
		return
	var stage := Vector2(minf(size.x, STAGE_SIZE.x), minf(size.y, STAGE_SIZE.y))
	var origin := (size - stage) * 0.5
	var rect: Rect2
	if _view == View.CONTROLS:
		rect = Rect2(origin + CONTROLS_RECT.position, CONTROLS_RECT.size)
	else:
		var cx := _logo.position.x + _logo.size.x * 0.5
		var top := _tagline.position.y + _tagline.size.y + MENU_GAP
		var height := _vbox.get_combined_minimum_size().y + MENU_PADDING
		rect = Rect2(cx - MENU_WIDTH * 0.5, top, MENU_WIDTH, height)
	rect.position.x = clampf(rect.position.x, 0.0, maxf(0.0, size.x - rect.size.x))
	rect.position.y = clampf(rect.position.y, 0.0, maxf(0.0, size.y - rect.size.y))
	_panel.position = rect.position
	_panel.size = rect.size
	_panel.self_modulate.a = 1.0 if _view == View.CONTROLS else PANEL_ALPHA


## The emblem glow breathes slowly; held still under reduced motion.
func _update_glow_motion() -> void:
	if _glow_tween:
		_glow_tween.kill()
		_glow_tween = null
	var settings := get_node_or_null("/root/Settings")
	var reduced: bool = settings != null and settings.get_reduced_motion()
	_glow.modulate.a = (GLOW_LOW + GLOW_HIGH) * 0.5
	if reduced or not _glow.visible:
		return
	_glow.modulate.a = GLOW_LOW
	_glow_tween = create_tween().set_loops()
	_glow_tween.tween_property(_glow, "modulate:a", GLOW_HIGH, GLOW_PERIOD * 0.5) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_glow_tween.tween_property(_glow, "modulate:a", GLOW_LOW, GLOW_PERIOD * 0.5) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Settings "text size" (M6): captures every Label/Button's own authored font
## size once as its baseline so it can be scaled consistently without
## hardcoding each node's base size a second time here.
func _collect_text_size_bases(root: Node) -> void:
	for child in root.get_children():
		if child is ControlsPanel:
			continue  # manages its own text-size bases/listener (see its own doc comment)
		if child is Label or child is Button:
			_text_size_bases[child] = child.get_theme_font_size("font_size")
		_collect_text_size_bases(child)


func _apply_text_size() -> void:
	var settings := get_node_or_null("/root/Settings")
	for node in _text_size_bases:
		if is_instance_valid(node):
			var base: int = _text_size_bases[node]
			node.add_theme_font_size_override("font_size",
					settings.scaled_font_size(base) if settings else base)
	_layout()  # the tagline (and so the menu under it) may have changed size


## Polled by hand (see WorkbenchPanel/SwapConfirm's identical comment): `pause`
## also backs the New Game confirmation AND the Controls view out, matching
## every other dialog's Decline-wired-to-pause convention. `help` (F1) opens
## the Controls view straight from the main view — the title screen's own
## discoverability hint (also spelled out on the Controls button's own label).
func _physics_process(_delta: float) -> void:
	var pressed := Input.is_action_pressed("pause")
	var pause_edge := pressed and not _pause_was_pressed
	_pause_was_pressed = pressed
	if pause_edge:
		if _view == View.NEW_GAME_CONFIRM:
			_on_new_game_cancel()
		elif _view == View.CONTROLS:
			_on_controls_back()

	var help_pressed := Input.is_action_pressed("help")
	var help_edge := help_pressed and not _help_was_pressed
	_help_was_pressed = help_pressed
	if help_edge and _view == View.MAIN:
		_on_controls_pressed()


## Re-reads `CheckpointService.has_valid_save()` to gate the Continue button.
## Deliberately never touches `_message_label` itself (a caller — e.g.
## `attempt_continue()`'s failure branch — sets that message and THEN calls
## this to update the button; clearing the message here would immediately
## wipe out whatever it just explained). Exposed (not just internal) so a
## test can force a refresh after writing/corrupting save files under it.
func refresh() -> void:
	var has_save: bool = _checkpoint_service() != null and _checkpoint_service().has_valid_save()
	_continue_button.disabled = not has_save


func _checkpoint_service() -> Node:
	return get_node_or_null("/root/CheckpointService")


## `focus` lets a caller restore focus somewhere other than New Game — used by
## `_on_controls_back()` so Back/Escape from Controls returns focus to the
## Controls button itself, per the task's own spec, rather than New Game.
func _show_main_view(focus: Control = null) -> void:
	_view = View.MAIN
	_main_view.visible = true
	_confirm_view.visible = false
	_controls_view.visible = false
	_show_heading(true)
	_set_message(_message_label.text)
	(focus if focus else _new_game_button).grab_focus()
	_fit_panel()


func _show_confirm_view() -> void:
	_view = View.NEW_GAME_CONFIRM
	_main_view.visible = false
	_confirm_view.visible = true
	_controls_view.visible = false
	_show_heading(true)
	_set_message(_message_label.text)
	_cancel_button.grab_focus()
	_fit_panel()


func _show_controls_view() -> void:
	_view = View.CONTROLS
	_main_view.visible = false
	_confirm_view.visible = false
	_controls_view.visible = true
	# Reclaim the (otherwise empty, save-status-only) message line's vertical
	# space, AND the redundant "DEAD EDEN" heading (the Controls
	# view already has its own "Controls" title) for the Controls table —
	# both restored by _show_main_view()/_show_confirm_view(). This is what
	# gets every row visible with no scrolling at Settings' Normal text size;
	# at Large text size the table itself still needs scrolling to reach the
	# last few rows (ControlsPanel.HOST_BUDGET_HEIGHT's own doc comment) —
	# the shared Panel has no more room to give at a 960x540-legible size.
	_message_label.visible = false
	_show_heading(false)
	_controls_view.refresh()
	_controls_view.grab_back_focus()
	_fit_panel()


## The heading is the logo when the art loaded, else the TitleLabel text; the
## tagline goes with it. All three are hidden for the Controls view (which has
## its own title and needs the room).
func _show_heading(on: bool) -> void:
	_logo.visible = on and _has_logo
	_title_label.visible = on and not _has_logo
	_tagline.visible = on


## The save-status line sits under the buttons and only takes room when it has
## something to say.
func _set_message(text: String) -> void:
	_message_label.text = text
	_message_label.visible = text != "" and _view != View.CONTROLS


func _on_controls_pressed() -> void:
	_play_sfx(&"ui_move")
	_show_controls_view()


func _on_controls_back() -> void:
	_play_sfx(&"ui_back")
	_show_main_view(_controls_button)


func _on_new_game_pressed() -> void:
	var service := _checkpoint_service()
	if service and service.has_valid_save():
		_play_sfx(&"ui_move")
		_show_confirm_view()
	else:
		_play_sfx(&"ui_confirm")
		new_game_confirmed.emit()


func _on_new_game_confirm() -> void:
	_play_sfx(&"ui_confirm")
	new_game_confirmed.emit()


func _on_new_game_cancel() -> void:
	_play_sfx(&"ui_back")
	_show_main_view()


func _play_sfx(cue: StringName) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue)


## Also usable directly by a test (bypasses the disabled-button UI state to
## exercise the same logic the button would run).
func attempt_continue() -> void:
	var service := _checkpoint_service()
	if service == null:
		_set_message("Save system unavailable.")
		return
	var result: Dictionary = service.load_latest()
	if result.get("ok", false):
		_set_message("Primary save was unreadable — restored from backup."
				if String(result.get("source", "")) == "backup" else "")
		_play_sfx(&"ui_confirm")
		continue_confirmed.emit(result.snapshot)
	else:
		_set_message("No valid save found (%s). Start a New Game instead." % result.get("error", ""))
		refresh()


func _on_continue_pressed() -> void:
	attempt_continue()


func _on_quit_pressed() -> void:
	_play_sfx(&"ui_back")
	quit_requested.emit()
