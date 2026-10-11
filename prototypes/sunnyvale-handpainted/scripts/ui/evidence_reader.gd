extends CanvasLayer
## C53: an evidence file the player can read. Picking up EF01 (the Lockout Notice) used to show
## only a toast, so the one document in the level told the player nothing. EvidencePickup opens
## this over the game: a title, the memo's text and Close (Close, Esc or Interact closes it; the
## opener disables Dave's input while it is up and gets it back on `closed`). Built in code like
## the intro comic, in the shared pixel theme.

signal closed

const THEME := "res://assets/ui/c11_theme.tres"
const TEAL := Color(0.247, 0.878, 0.816, 1)
const PAPER_TEXT := Color(0.86, 0.89, 0.93, 1)

var _close_button: Button
var _title_label: Label
var _body_label: Label
## Interact and pause are polled as edges; a key already held when the reader opens (the
## Interact press that picked the file up) must be released before it can close it.
var _interact_was_pressed := true
var _pause_was_pressed := true


func _ready() -> void:
	layer = 20
	add_to_group("evidence_reader")
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := Panel.new()
	panel.theme = load(THEME)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -320.0
	panel.offset_right = 320.0
	panel.offset_top = -230.0
	panel.offset_bottom = 230.0
	add_child(panel)
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 28.0
	vb.offset_top = 22.0
	vb.offset_right = -28.0
	vb.offset_bottom = -22.0
	vb.add_theme_constant_override("separation", 12)
	panel.add_child(vb)
	var kicker := Label.new()
	kicker.text = "EVIDENCE FILE"
	kicker.add_theme_font_size_override("font_size", 16)
	kicker.add_theme_color_override("font_color", Color(0.55, 0.62, 0.7, 1))
	vb.add_child(kicker)
	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 26)
	_title_label.add_theme_color_override("font_color", TEAL)
	vb.add_child(_title_label)
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(0, 2)
	line.color = Color(TEAL, 0.5)
	vb.add_child(line)
	_body_label = Label.new()
	_body_label.add_theme_font_size_override("font_size", 19)
	_body_label.add_theme_color_override("font_color", PAPER_TEXT)
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(_body_label)
	_close_button = Button.new()
	_close_button.text = "Close"
	_close_button.add_theme_font_size_override("font_size", 22)
	_close_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_close_button.pressed.connect(close)
	vb.add_child(_close_button)
	_close_button.grab_focus()


func open(title: String, body: String) -> void:
	_title_label.text = title
	_body_label.text = body


func title_text() -> String:
	return _title_label.text


func body_text() -> String:
	return _body_label.text


func _physics_process(_delta: float) -> void:
	var interact := Input.is_action_pressed("interact")
	var pause := Input.is_action_pressed("pause")
	if (interact and not _interact_was_pressed) or (pause and not _pause_was_pressed):
		close()
		return
	_interact_was_pressed = interact
	_pause_was_pressed = pause


func close() -> void:
	if is_queued_for_deletion():
		return
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"ui_back")
	closed.emit()
	queue_free()
