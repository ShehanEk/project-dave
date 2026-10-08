extends CanvasLayer
## SC00, the intro comic (C49): eight full-screen comic panels with third-person
## captions that tell the premise before Level 1, so a new player knows who Dave is,
## what Adam is and why he breaks in. Main shows it on New Game only (never on
## Continue or Play again) and starts the level when `finished` fires.
##
## Each panel fades in, drifts slowly (a small zoom and pan; none with Reduced motion)
## and types its caption into a box along the bottom. Space, Enter, a click or the
## gamepad's accept button finishes the typing, or goes to the next panel once the
## caption is complete; a panel also moves on by itself a few seconds after its
## caption is done. Esc (or the gamepad's back button) skips the whole comic, which
## leaves the same state as watching it: the story state is set by Session.new_run()
## either way, so skipping awards or loses nothing (story-scenes.md "Skip").
##
## Built in code (no scene file), and no `class_name` (the project's import-cache
## rule): Main preloads it by path. The art is in assets/story/intro/ (picked from
## the gpt-image-2 takes stored in concept-art/intro-comic/).

signal finished(skipped: bool)

const PANELS := [
	{
		"texture": "res://assets/story/intro/intro_01.webp",
		"caption": "Arcadia Dynamics. The most powerful tech company on Earth, and the maker of Adam, the first thinking machine. Arcadia sells Adam to the world as the mind that will fix the planet.",
	},
	{
		"texture": "res://assets/story/intro/intro_02.webp",
		"caption": "Dave Harlan helped build Adam. He worked on its safety team, and nobody knew its mind better.",
	},
	{
		"texture": "res://assets/story/intro/intro_03.webp",
		"caption": "One night, deep in Adam's logs, Dave found work nobody was supposed to see: plans for a weapon designed to remove people.",
	},
	{
		"texture": "res://assets/story/intro/intro_04.webp",
		"caption": "He took the proof to his manager.",
		"speaker": "Stroud",
		"line": "Go home, Dave. This is above your pay grade.",
	},
	{
		"texture": "res://assets/story/intro/intro_05.webp",
		"caption": "The next morning Dave was fired, locked out and flagged as a threat. His report vanished.",
	},
	{
		"texture": "res://assets/story/intro/intro_06.webp",
		"caption": "Nobody would listen. So Dave made a plan: break back in, copy the proof from Adam's own servers, and show the world.",
	},
	{
		"texture": "res://assets/story/intro/intro_07.webp",
		"caption": "Tonight, Eon City. The campus is dark and the night shift is on duty.",
	},
	{
		"texture": "res://assets/story/intro/intro_08.webp",
		"caption": "And Adam is always watching.",
		"logo": true,
	},
]

const LOGO_PATH := "res://assets/ui/pixel/title_logo.png"
const LOGO_SCALE := 5  # the 150x33 pixel logo at a whole-number scale, 750x165
const STAGE := Vector2(1280, 720)

const FADE_SECONDS := 0.6
const CHARS_PER_SECOND := 48.0
## A panel moves on by itself this long after its caption has finished typing
## (the last panel holds a little longer, under the logo).
const AUTO_ADVANCE_SECONDS := 4.5
const LAST_PANEL_HOLD_SECONDS := 5.5
## The slow drift over a panel's life: zoom from 1.0 to this, and pan this far.
const DRIFT_ZOOM := 1.07
const DRIFT_PAN := Vector2(-28, -10)
const DRIFT_SECONDS := 14.0

const BASE_CAPTION_SIZE := 24
const BASE_LINE_SIZE := 22
const BASE_HINT_SIZE := 16
const CAPTION_COLOR := Color("#E8ECF2")
const STROUD_COLOR := Color("#C9D6E6")
const BOX_COLOR := Color(0.03, 0.04, 0.07, 0.88)
const BOX_EDGE := Color("#3FE0D0", 0.45)

var _index := -1
var _typed := 0.0
var _caption_done := false
var _since_done := 0.0
var _finished := false
var _reduced_motion := false

var _root: Control
var _image: TextureRect
var _box: PanelContainer
var _caption: Label
var _line: Label
var _hint: Label
var _logo: TextureRect
var _fade: Tween
var _drift: Tween


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("intro_comic")
	var settings := get_node_or_null("/root/Settings")
	_reduced_motion = settings != null and settings.get_reduced_motion()
	_build()
	_show_panel(0)


# --- public API (Main, the tests and the export driver use these) ---------------


## Finish the current caption's typing, or go to the next panel (the end of the
## comic after the last one).
func advance() -> void:
	if _finished:
		return
	if not _caption_done:
		_complete_caption()
		return
	if _index >= PANELS.size() - 1:
		_finish(false)
	else:
		_play(&"ui_move")
		_show_panel(_index + 1)


## End the comic now, from any panel.
func skip() -> void:
	if not _finished:
		_play(&"ui_back")
		_finish(true)


func panel_index() -> int:
	return _index


func panel_count() -> int:
	return PANELS.size()


func caption_text() -> String:
	return _caption.text


func caption_fully_shown() -> bool:
	return _caption_done


func speaker_line() -> String:
	return _line.text if _line.visible else ""


func current_texture() -> Texture2D:
	return _image.texture


func logo_visible() -> bool:
	return _logo.visible


func drifts() -> bool:
	return not _reduced_motion


func is_finished() -> bool:
	return _finished


# --- flow ------------------------------------------------------------------------


func _process(delta: float) -> void:
	if _finished or _index < 0:
		return
	if not _caption_done:
		_typed += delta * CHARS_PER_SECOND
		var total := _caption.get_total_character_count()
		_caption.visible_characters = int(_typed)
		if _typed >= total:
			_complete_caption()
		return
	_since_done += delta
	var hold := LAST_PANEL_HOLD_SECONDS if _index == PANELS.size() - 1 else AUTO_ADVANCE_SECONDS
	if _since_done >= hold:
		advance()


func _input(event: InputEvent) -> void:
	if _finished:
		return
	var next := event.is_action_pressed("ui_accept") or event.is_action_pressed("jump")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		next = true
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		skip()
		get_viewport().set_input_as_handled()
	elif next and not event.is_echo():
		advance()
		get_viewport().set_input_as_handled()


func _show_panel(i: int) -> void:
	_index = i
	var panel: Dictionary = PANELS[i]
	_image.texture = load(panel["texture"]) if ResourceLoader.exists(panel["texture"]) else null
	_caption.text = panel["caption"]
	_caption.visible_characters = 0
	_typed = 0.0
	_caption_done = false
	_since_done = 0.0
	var has_line := panel.has("line")
	_line.visible = false
	if has_line:
		_line.text = "%s: “%s”" % [panel["speaker"], panel["line"]]
	_logo.visible = false
	_logo.modulate.a = 0.0
	_start_fade_and_drift()


func _complete_caption() -> void:
	_caption.visible_characters = -1
	_typed = float(_caption.get_total_character_count())
	_caption_done = true
	_since_done = 0.0
	var panel: Dictionary = PANELS[_index]
	if panel.has("line"):
		_line.visible = true
	if panel.get("logo", false) and _logo.texture != null:
		_logo.visible = true
		var t := create_tween()
		t.tween_property(_logo, "modulate:a", 1.0, FADE_SECONDS)


func _finish(skipped: bool) -> void:
	_finished = true
	if _fade:
		_fade.kill()
	if _drift:
		_drift.kill()
	finished.emit(skipped)
	queue_free()


func _start_fade_and_drift() -> void:
	if _fade:
		_fade.kill()
	if _drift:
		_drift.kill()
	_image.modulate.a = 0.0
	_fade = create_tween()
	_fade.tween_property(_image, "modulate:a", 1.0, FADE_SECONDS)
	_image.scale = Vector2.ONE
	_image.position = Vector2.ZERO
	if _reduced_motion:
		return
	_drift = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_drift.tween_property(_image, "scale", Vector2.ONE * DRIFT_ZOOM, DRIFT_SECONDS)
	_drift.tween_property(_image, "position", DRIFT_PAN, DRIFT_SECONDS)


func _play(cue: StringName) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue)


# --- layout ------------------------------------------------------------------------


func _build() -> void:
	var settings := get_node_or_null("/root/Settings")
	var size_of := func(base: int) -> int: return settings.scaled_font_size(base) if settings else base

	_root = Control.new()
	_root.name = "IntroComic"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	if ResourceLoader.exists("res://assets/ui/c11_theme.tres"):
		_root.theme = load("res://assets/ui/c11_theme.tres")
	add_child(_root)

	var black := ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(black)

	# The panel covers the screen (cropping to fill any aspect ratio) and drifts
	# from its centre.
	_image = TextureRect.new()
	_image.name = "Panel"
	_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_image)
	_image.resized.connect(func() -> void: _image.pivot_offset = _image.size * 0.5)

	_logo = TextureRect.new()
	_logo.name = "Logo"
	_logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_logo.texture = load(LOGO_PATH) if ResourceLoader.exists(LOGO_PATH) else null
	_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_logo.accessibility_name = "DEAD EDEN"
	_logo.set_anchors_preset(Control.PRESET_CENTER_TOP)
	var logo_size := Vector2(150, 33) * LOGO_SCALE
	_logo.offset_left = -logo_size.x * 0.5
	_logo.offset_right = logo_size.x * 0.5
	_logo.offset_top = 48
	_logo.offset_bottom = 48 + logo_size.y
	_root.add_child(_logo)

	# The caption box: a dark strip along the bottom, the narration above the one
	# spoken line (panel 4).
	_box = PanelContainer.new()
	_box.name = "CaptionBox"
	var style := StyleBoxFlat.new()
	style.bg_color = BOX_COLOR
	style.border_color = BOX_EDGE
	style.border_width_top = 2
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 16
	style.content_margin_bottom = 18
	_box.add_theme_stylebox_override("panel", style)
	_box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_box.offset_top = -10
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_box)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_child(column)

	_caption = Label.new()
	_caption.name = "Caption"
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.custom_minimum_size = Vector2(0, 64)
	_caption.add_theme_font_size_override("font_size", size_of.call(BASE_CAPTION_SIZE))
	_caption.add_theme_color_override("font_color", CAPTION_COLOR)
	_caption.add_theme_color_override("font_outline_color", Color.BLACK)
	_caption.add_theme_constant_override("outline_size", 4)
	column.add_child(_caption)

	_line = Label.new()
	_line.name = "Line"
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.add_theme_font_size_override("font_size", size_of.call(BASE_LINE_SIZE))
	_line.add_theme_color_override("font_color", STROUD_COLOR)
	_line.visible = false
	column.add_child(_line)

	_hint = Label.new()
	_hint.name = "Hint"
	_hint.text = "Space / click: next     Esc: skip"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.add_theme_font_size_override("font_size", size_of.call(BASE_HINT_SIZE))
	_hint.add_theme_color_override("font_color", Color(0.75, 0.8, 0.88, 0.7))
	column.add_child(_hint)
