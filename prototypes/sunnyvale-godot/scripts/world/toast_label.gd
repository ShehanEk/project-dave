class_name ToastLabel
extends Label
## Small reusable "X happened" toast: shows text, holds, fades, hides.
## Attached to a child Label named "Toast" in interactable scenes so they
## don't each reimplement the same tween.

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")

const HOLD_TIME := 1.1
const FADE_TIME := 0.6
## Backing plate (sc01-double-toast/weapon-pad-toast-overlap): a dark backing
## so plain white toast text stays legible over ANY world background. Pixel UI
## (Sheet 11): the backing is the pixel banner strip, nine-sliced to the
## label at 3 px per UI pixel (canvas px on the HUD, world px over an object),
## the same frame as every other panel. Without that PNG it keeps the flat
## plate below, the same bg/border pair as SubtitlePanel's fallback.
const BACKING := Color(0.027, 0.035, 0.059, 0.88)
const OUTLINE := Color(0.11, 0.165, 0.227, 1.0)
## Gap between an icon (`show_message(..., icon)`) and the text, px.
const ICON_GAP := 9.0

var _icon: TextureRect = null
var _base_margin_left := 0.0
var _base_margin_top := 0.0
var _base_margin_bottom := 0.0


func _ready() -> void:
	visible = false
	modulate.a = 1.0
	var style: StyleBox = PixelUi.toast_style()
	if style == null:
		var flat := StyleBoxFlat.new()
		flat.bg_color = BACKING
		flat.border_color = OUTLINE
		flat.border_width_left = 2
		flat.border_width_top = 2
		flat.border_width_right = 2
		flat.border_width_bottom = 2
		flat.corner_radius_top_left = 4
		flat.corner_radius_top_right = 4
		flat.corner_radius_bottom_right = 4
		flat.corner_radius_bottom_left = 4
		flat.content_margin_left = 6.0
		flat.content_margin_right = 6.0
		flat.content_margin_top = 3.0
		flat.content_margin_bottom = 3.0
		style = flat
	_base_margin_left = style.content_margin_left
	_base_margin_top = style.content_margin_top
	_base_margin_bottom = style.content_margin_bottom
	add_theme_stylebox_override("normal", style)
	resized.connect(_place_icon)


## `icon` (a pixel UI piece name: "save", "warning", "evidence") is drawn just
## left of the text at 3 px per UI pixel; "" or a missing PNG shows text only.
func show_message(message: String, hold: float = HOLD_TIME, fade: float = FADE_TIME, icon: String = "") -> void:
	text = message
	_set_icon(icon)
	modulate = Color(1, 1, 1, 1)
	visible = true
	var tween := create_tween()
	tween.tween_interval(hold)
	tween.tween_property(self, "modulate:a", 0.0, fade)
	tween.tween_callback(func(): visible = false)


## The icon piece shown with the current message ("" when none).
func icon_piece() -> String:
	return String(_icon.get_meta(&"piece", "")) if _icon and _icon.visible else ""


func _set_icon(piece: String) -> void:
	var tex: Texture2D = PixelUi.texture(piece) if piece != "" else null
	var style := get_theme_stylebox("normal")
	if tex == null:
		if _icon:
			_icon.visible = false
		if style:
			style.content_margin_left = _base_margin_left
			style.content_margin_top = _base_margin_top
			style.content_margin_bottom = _base_margin_bottom
		return
	if _icon == null:
		_icon = TextureRect.new()
		_icon.name = "Icon"
		_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_icon.stretch_mode = TextureRect.STRETCH_SCALE
		_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_icon)
	_icon.texture = tex
	_icon.set_meta(&"piece", piece)
	_icon.size = tex.get_size() * float(PixelUi.SCALE)
	_icon.visible = true
	# Tall enough that the icon sits inside the frame's border with one dark
	# UI pixel above and below it.
	if style:
		var line: float = get_line_height()
		var need: float = (_icon.size.y + 2.0 * (PixelUi.FRAME_BORDER + 1) * PixelUi.SCALE - line) * 0.5
		style.content_margin_top = maxf(_base_margin_top, ceilf(need))
		style.content_margin_bottom = maxf(_base_margin_bottom, ceilf(need))
	_place_icon()


## Puts the icon just left of the (centred) text; when text and icon would not
## fit on one line side by side, the text's left margin makes room for the icon
## instead, so a wrapped message never runs under it.
func _place_icon() -> void:
	if _icon == null or not _icon.visible:
		return
	var style := get_theme_stylebox("normal")
	if style == null:
		return
	var f := get_theme_font("font")
	var fs := get_theme_font_size("font_size")
	var text_w: float = f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x if f else 0.0
	var iw: float = _icon.size.x
	var mr: float = style.content_margin_right
	style.content_margin_left = _base_margin_left
	var inner: float = size.x - _base_margin_left - mr
	var x: float
	if text_w + iw + ICON_GAP > inner:
		style.content_margin_left = _base_margin_left + iw + ICON_GAP
		x = _base_margin_left
	else:
		x = _base_margin_left + (inner - text_w) * 0.5 - ICON_GAP - iw
	_icon.position = Vector2(roundf(x), roundf((size.y - _icon.size.y) * 0.5))
