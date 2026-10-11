class_name TutorialPrompt
extends Node2D
## Non-blocking one-shot hint: shows `text` (optionally preceded by input
## icons) near a spot until `action` is performed once, then fades. Never
## pauses or gates gameplay.
##
## M7 readability additions (both optional, default off so every EXISTING
## instance — a01_gate.tscn, sample_area.tscn — keeps its original
## "visible from _ready(), fades on first `action`" behavior unchanged):
## `trigger_node` defers showing until that node's `activated` signal fires
## (e.g. an EncounterGroup, so a contextual prompt appears exactly when the
## fight itself activates, not the instant the area loads); `once_per_run_key`
## gates showing at all behind `Session.get_runtime_flag()`/
## `set_runtime_flag()` (live-only, never persisted — see session.gd) so a
## death/respawn rebuild mid-run never re-shows it, but a genuinely new run/
## Continue does.
##
## M7 Kenney part B readability pass: `text` now sits inside a C11 cream
## backing panel (matches subtitle_panel.gd/toast_label.gd's own material) at
## a larger, Settings-text-size-scaled font, in warm charcoal rather than the
## old small pale outlined text. `icon_actions` (and the singular
## `static_icon_before`, for the one un-bindable "Aim" case) render the
## CURRENT InputMap binding's Kenney icon(s) before the text — generated
## through `input_icon_map.gd`, the SAME mapping controls_panel.gd's Controls
## menu uses, never a second hardcoded table — falling back to a small
## bracketed text token (e.g. "[Q]") for any sub-binding this project has no
## icon file for, so the prompt always documents the CURRENT binding either
## way. A prompt that doesn't literally name an input (e.g. the E02 Patrol
## Rover prompt) simply leaves `icon_actions` empty and reads as plain styled text.
##
## Pixel UI pass (Sheets 11 and 12): the icons are the pixel key caps and mice
## (input_icon_map.gd / scripts/ui/pixel_ui.gd) and the panel is the pixel tag
## frame, nine-sliced, all at 3 world px per UI pixel (the world's own object
## and building pixel); the text stays in the UI font. Without the PNGs the
## panel keeps its flat style (tutorial_prompt.tscn) and the keys their text.
## The panel stays centred on its authored centre when its content is wider
## than its authored width.

const InputIconMap := preload("res://scripts/ui/input_icon_map.gd")
const PixelUi := preload("res://scripts/ui/pixel_ui.gd")

## World px per UI pixel for the key caps at Settings' Normal text size; Large
## rounds Settings.scaled_font_size()'s ratio to a whole 4.
const ICON_SCALE := 3
const BASE_TEXT_SIZE := 24  ## >= 22px at Normal text size per the task brief.
## The widest the text asks to be before it wraps, world px.
const MAX_TEXT_WIDTH := 300.0

const TEXT_COLOR := Color("#D8E2EC")  # light text on the dark night panel

@export var text: String = ""
@export var action: StringName = &"jump"
## If set, wait for this node's `activated` signal before showing at all
## (instead of showing immediately in `_ready()`).
@export var trigger_node: NodePath
## If non-empty, shown at most once per run (Session.runtime_flags).
@export var once_per_run_key: String = ""
## If > 0, also fades after this many seconds even if `action` is never
## pressed (0 = only `action` fades it, the original behavior).
@export var auto_fade_time: float = 0.0
## InputMap action names to show an icon (or text-fallback token) for, in
## order, before `text` — e.g. `["move_left", "move_right"]` renders "[A][D]"
## (as real icons, when this project has them) ahead of the "Move" text.
## Empty (the default) renders `text` alone, unchanged from before this pass.
@export var icon_actions: Array[StringName] = []
## A static icon name (input_icon_map.gd `STATIC_PIECES`: "mouse_aim", or the
## older Kenney file name "mouse_move.svg", which maps to the same pixel icon)
## shown before `icon_actions`' own icons, for the one binding that isn't an
## InputMap action at all — Aim, always the raw mouse pointer. Mirrors
## controls_panel.gd's own "Aim" row (`static_icon: "mouse_aim"`).
@export var static_icon_before: String = ""

var _shown_once: bool = false
var _visible_elapsed: float = 0.0
var _center_x: float = 0.0

@onready var _panel: PanelContainer = $Panel
@onready var _icons_box: HBoxContainer = $Panel/Row/Icons
@onready var _text_label: Label = $Panel/Row/TextLabel


func _ready() -> void:
	add_to_group(&"tutorial_prompt")
	_text_label.text = text
	_center_x = (_panel.offset_left + _panel.offset_right) * 0.5
	var frame := PixelUi.frame_style("tag", 4)
	if frame:
		frame.content_margin_left = 5.0 * PixelUi.SCALE
		frame.content_margin_right = 5.0 * PixelUi.SCALE
		frame.content_margin_top = 4.0 * PixelUi.SCALE
		frame.content_margin_bottom = 4.0 * PixelUi.SCALE
		_panel.add_theme_stylebox_override("panel", frame)
	_panel.resized.connect(_recenter)
	_build_icons()
	_panel.modulate = Color(1, 1, 1, 1)
	_apply_text_size()
	var settings := get_node_or_null("/root/Settings")
	if settings and not settings.changed.is_connected(_apply_text_size):
		settings.changed.connect(_apply_text_size)

	if once_per_run_key != "" and Session and Session.get_runtime_flag(once_per_run_key):
		_shown_once = true
		_panel.visible = false
		return
	if not trigger_node.is_empty():
		_panel.visible = false
		var node := get_node_or_null(trigger_node)
		if node and node.has_signal("activated"):
			node.activated.connect(_on_triggered)
			return
		# Trigger node missing/wrong type: fail open (show immediately)
		# rather than silently never showing a hint the level author placed.
	_show_now()


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_apply_text_size):
		settings.changed.disconnect(_apply_text_size)


## Builds the Icons row from the CURRENT InputMap once at `_ready()` (this
## node's exports never change afterward, so unlike controls_panel.gd's own
## `refresh()` there is nothing to rebuild later).
func _build_icons() -> void:
	for child in _icons_box.get_children():
		_icons_box.remove_child(child)
		child.queue_free()
	if static_icon_before != "":
		var aim := InputIconMap.static_icon(static_icon_before)
		if aim:
			_add_icon(aim)
	# Several actions' bindings are interleaved by binding index, so Move's
	# left/right pair reads "A D ← →" (the Controls table's own pairing),
	# not "A ← D →".
	var per_action: Array = []
	var longest := 0
	for action_name in icon_actions:
		var tokens := InputIconMap.tokens_for_action(action_name)
		per_action.append(tokens)
		longest = maxi(longest, tokens.size())
	for i in longest:
		for tokens in per_action:
			if i >= tokens.size():
				continue
			var token: Dictionary = tokens[i]
			if token.has("icon"):
				_add_icon(token["icon"])
			else:
				_add_text_token(token["text"])


func _add_icon(icon: Texture2D) -> void:
	var rect := TextureRect.new()
	rect.texture = icon
	# EXPAND_IGNORE_SIZE lets custom_minimum_size (the icon's UI pixels times a
	# whole scale) set the size — see controls_panel.gd's own note.
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.custom_minimum_size = icon.get_size() * float(_icon_scale())
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_icons_box.add_child(rect)


## Keeps the panel centred on its authored centre when its content makes it
## wider than authored (a row of key caps).
func _recenter() -> void:
	var x := roundf(_center_x - _panel.size.x * 0.5)
	if not is_equal_approx(_panel.position.x, x):
		_panel.position.x = x


func _icon_scale() -> int:
	var settings := get_node_or_null("/root/Settings")
	if settings == null:
		return ICON_SCALE
	return maxi(1, roundi(ICON_SCALE * settings.scaled_font_size(100) / 100.0))


## Text fallback for a bound key/button this project has no icon file for
## ("text fallback if no icon exists" per the task brief) — bracketed so it
## visually reads as a key, matching the project's old hardcoded prompt text
## style (e.g. the original "Jump: Space").
func _add_text_token(label_text: String) -> void:
	var lbl := Label.new()
	lbl.text = "[%s]" % label_text
	lbl.add_theme_color_override("font_color", TEXT_COLOR)
	_icons_box.add_child(lbl)


func _on_triggered() -> void:
	if _shown_once or not is_inside_tree():
		return
	_show_now()


func _show_now() -> void:
	if once_per_run_key != "" and Session:
		if Session.get_runtime_flag(once_per_run_key):
			return
		Session.set_runtime_flag(once_per_run_key)
	_panel.visible = true
	_visible_elapsed = 0.0


func _process(delta: float) -> void:
	if _shown_once or not _panel.visible:
		return
	_visible_elapsed += delta
	# An empty `action` makes a purely informational prompt that only fades on
	# its timer (or via dismiss()) — e.g. the E02 Patrol Rover prompt, which must
	# not vanish on the very first shot the player fires at the Rover.
	var acted := action != &"" and InputMap.has_action(action) and Input.is_action_just_pressed(action)
	if acted or (auto_fade_time > 0.0 and _visible_elapsed >= auto_fade_time):
		_fade_out()


## Fades out a prompt that is currently showing (no-op otherwise), exactly as
## performing its action would. Called through the "tutorial_prompt" group by
## anything that replaces it with a more specific message — e.g. the Patrol
## Rover's "Armored!" hint supersedes the E02 prompt instead of overlapping it.
func dismiss() -> void:
	if _shown_once or not _panel.visible:
		return
	_fade_out()


func _fade_out() -> void:
	_shown_once = true
	var tween := create_tween()
	tween.tween_property(_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): _panel.visible = false)


## Settings' "text size" scales both the text and the icons by the same
## ratio (task brief: "larger font... scaling with the text-size setting...
## icons... generated from InputMap"), the same idiom
## controls_panel.gd's own `_apply_text_size()` already follows.
func _apply_text_size() -> void:
	var settings := get_node_or_null("/root/Settings")
	var text_size: int = settings.scaled_font_size(BASE_TEXT_SIZE) if settings else BASE_TEXT_SIZE
	_text_label.add_theme_font_size_override("font_size", text_size)
	# An autowrapping Label asks for almost no width, so a short text ("Jump")
	# beside a row of key caps was squeezed out of the panel: ask for the
	# text's own width, up to MAX_TEXT_WIDTH (longer text still wraps).
	var f := _text_label.get_theme_font("font")
	if f:
		var w: float = f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x
		_text_label.custom_minimum_size.x = ceilf(minf(w + 2.0, MAX_TEXT_WIDTH))
	var scale := _icon_scale()
	for child in _icons_box.get_children():
		if child is TextureRect and child.texture:
			child.custom_minimum_size = child.texture.get_size() * float(scale)
		elif child is Label:
			child.add_theme_font_size_override("font_size", text_size)
