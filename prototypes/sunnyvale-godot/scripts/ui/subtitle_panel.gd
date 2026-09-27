class_name SubtitlePanel
extends CanvasLayer
## Shared, always-in-tree noninteractive-scene subtitle overlay (03-gameplay-
## systems.md "UI minimum: ... subtitle panel"). Added once by LevelDirector,
## alongside the HUD; found by whoever needs it (CoreConsole's SC01 today)
## via group "subtitle_panel" rather than a direct reference, so isolated
## area/object tests that never instance LevelDirector simply find none and
## skip dialogue — timing/state are unaffected either way (see
## core_console.gd). Pure display: it never polls input or decides when a
## scene skips; the caller owns that.

const BASE_TEXT_SIZE := 22
const BASE_SPEAKER_SIZE := 20
const BASE_HINT_SIZE := 18

@onready var _panel: PanelContainer = $Panel
@onready var _speaker_label: Label = $Panel/VBox/SpeakerLabel
@onready var _text_label: Label = $Panel/VBox/TextLabel
@onready var _hint_label: Label = $HintLabel


func _ready() -> void:
	layer = 18
	add_to_group("subtitle_panel")
	_panel.visible = false
	_hint_label.visible = false
	_apply_text_size()
	var settings := get_node_or_null("/root/Settings")
	if settings and not settings.changed.is_connected(_apply_text_size):
		settings.changed.connect(_apply_text_size)


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_apply_text_size):
		settings.changed.disconnect(_apply_text_size)


## Settings "text size" (interface-and-accessibility.md "Adjustable subtitle
## size" — minimal now, M6 extends): scales this panel's own labels only.
func _apply_text_size() -> void:
	var settings := get_node_or_null("/root/Settings")
	var scale_fn := (func(base: int) -> int: return settings.scaled_font_size(base) if settings else base)
	_text_label.add_theme_font_size_override("font_size", scale_fn.call(BASE_TEXT_SIZE))
	_speaker_label.add_theme_font_size_override("font_size", scale_fn.call(BASE_SPEAKER_SIZE))
	_hint_label.add_theme_font_size_override("font_size", scale_fn.call(BASE_HINT_SIZE))


func show_hint(text: String = "Enter: skip") -> void:
	_hint_label.text = text
	_hint_label.visible = true


func hide_hint() -> void:
	_hint_label.visible = false


## Empty `speaker` shows the line without a speaker tag (e.g. a system line).
## Settings "subtitles" toggle (minimal now, M6 extends): while disabled, this
## silently shows nothing — exactly like this panel being absent in an
## isolated test (per this script's own doc comment) — never affecting SC01's
## own timing/state, which never reads this panel's visibility.
func say(speaker: String, text: String) -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and not settings.get_subtitles_enabled():
		return
	_panel.visible = true
	_speaker_label.visible = speaker != ""
	_speaker_label.text = speaker
	_text_label.text = text


func clear_line() -> void:
	_panel.visible = false
	_speaker_label.text = ""
	_text_label.text = ""
