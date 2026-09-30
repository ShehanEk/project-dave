class_name ControlsPanel
extends VBoxContainer
## Reusable "Controls" help panel (M7 follow-up; interface-and-accessibility.md
## / player-controls.md "Input icons follow current bindings"). A static
## three-column table (name, Kenney input-prompt icon(s), binding text) of
## every gameplay action's CURRENT binding, generated at runtime from
## InputMap (never hardcoded key names, so a future rebinding screen stays
## correct with no changes here), plus a few short spoiler-free tips. The
## binding TEXT is the always-correct, always-present column; the icon
## column is a visual accelerant beside it that simply goes emptier for a
## sub-binding this project has no icon file for (see input_icon_map.gd's
## KEY_ICON_FILES/MOUSE_ICON_FILES) — text never depends on icons existing. Embedded
## as a child VIEW inside both the Title screen and the Pause menu
## (CONVENTIONS.md "UI scenes" — "opener owns the action, this node owns
## its own buttons") rather than owning its own CanvasLayer/Panel: the host
## draws the panel chrome and swaps this in exactly like Journal/Settings.
##
## Text size (Settings.text_size) is applied by THIS node internally (collect
## bases + a Settings.changed listener), not by the host's own text-size
## sweep — a host that walks its own tree collecting Label/Button font-size
## bases must skip recursing into a ControlsPanel child (`if child is
## ControlsPanel: continue`) so the same Label is never scaled by two
## independent listeners at once.

signal back_pressed

## Player-facing rows, in the exact order interface-and-accessibility.md /
## player-controls.md ask for. `actions` lists every InputMap action name
## this row covers (used both to render its binding text and, for
## tests/test_help_controls.gd, to prove every non-ui_* InputMap action has
## exactly one row — nothing added later can silently go undocumented).
## `static_text` is shown as-is instead of an InputMap lookup for "Aim" (not
## a bindable action at all — always the mouse pointer, per player-controls.md
## "Aim with a pointer... within the gameplay plane").
const ROWS: Array[Dictionary] = [
	{"name": "Move", "actions": ["move_left", "move_right"], "static_text": ""},
	{"name": "Jump — hold for a higher jump", "actions": ["jump"], "static_text": ""},
	{"name": "Aim", "actions": [], "static_text": "Mouse pointer", "static_icon": "mouse_move.svg"},
	{"name": "Fire — hold to keep firing", "actions": ["fire"], "static_text": ""},
	{"name": "Interact / use", "actions": ["interact"], "static_text": ""},
	{"name": "Pause menu", "actions": ["pause"], "static_text": ""},
	{"name": "Journal", "actions": ["journal"], "static_text": ""},
	{"name": "Skip story scene", "actions": ["skip"], "static_text": ""},
	{"name": "Controls help", "actions": ["help"], "static_text": ""},
]

## Short, plain, spoiler-free reminders (no jargon/implementation terms) —
## interface-and-accessibility.md / the level design brief's own hazard and
## systems language, kept to a handful of lines so the panel never turns into
## a walkthrough.
const TIPS: Array[String] = [
	"Watch for the warning before an attack.",
	"Patrol Rovers stall against stone: shoot the battery on their back.",
	"Recovery stations heal you and save progress.",
	"You carry one weapon; the pistol never needs reloading.",
]

const NAME_COLOR := Color(0.2, 0.165, 0.125, 1)
const BINDING_COLOR := Color(0.212, 0.365, 0.384, 1)
const TIP_COLOR := Color(0.302, 0.243, 0.176, 1)

## M7 Kenney part B: the icon-file table and the layout-aware key-label logic
## used to live here directly; they now live in `input_icon_map.gd` (no
## `class_name` — see its own doc comment) so `tutorial_prompt.gd` can share
## the EXACT same mapping instead of duplicating it — reached through this
## plain preload() constant, never re-declared here.
const InputIconMap := preload("res://scripts/ui/input_icon_map.gd")
const ICON_DIR := InputIconMap.ICON_DIR

## Icons render at this square size at Settings' Normal text size (~40px per
## the task brief) scaled by `Settings.scaled_font_size()` exactly like every
## row's text, EXCEPT this is capped tighter (see `_build_rows()`'s own note)
## so 9 icon rows plus the header/Back button still fit the shared host
## Panel's ~460px budget with no scrolling at Normal text size, matching the
## table's existing no-scroll contract (test_help_regress_table_clip.gd).
const ICON_SIZE := 28.0

@onready var _scroll: ScrollContainer = $Scroll
@onready var _header_label: Label = $TitleLabel
@onready var _table: GridContainer = $Scroll/Content/Table
@onready var _tips_parent: VBoxContainer = $Scroll/Content
@onready var _back_button: Button = $BackButton

## Below this, something has gone wrong measuring the table (e.g. queried
## before the first layout pass) — never shrink the Scroll to less than a
## couple of rows' worth rather than trust a bogus near-zero measurement.
const MIN_SCROLL_HEIGHT := 120.0

## Both hosts (title_screen.tscn/pause.tscn) embed this view in the SAME
## 640x500 C11 Panel, and both hide their own outer title/message row while
## this view is showing (TitleScreen._show_controls_view()/PauseMenu.
## _apply_view()) specifically to give it the Panel's whole usable ~460px of
## vertical room. This is that budget: at Settings' Normal text size the
## table (+ this panel's own header/Back button) comfortably fits inside it
## with no scrolling; at Large text size the table alone can need more than
## a 960x540-legible Panel has room for, and capping to this budget (rather
## than growing past it) keeps the WHOLE view inside the Panel's own drawn
## edges — Tips, and at Large text a few table rows too, stay reachable by
## scrolling instead of spilling past the Panel into the background (a real
## bug an earlier, uncapped version of this function had).
const HOST_BUDGET_HEIGHT := 460.0

## action name (String) -> its row's binding Label, built once in _ready().
## The one "Move" row maps BOTH move_left and move_right to the SAME Label.
var binding_labels: Dictionary = {}

## Row index -> its binding Label, parallel to ROWS (covers the static "Aim"
## row too, which has no InputMap action and so no entry in binding_labels).
var _row_labels: Array[Label] = []

## Row index -> its icon HBoxContainer, parallel to ROWS. The container itself
## is built once in _build_rows(); refresh() clears and repopulates its
## TextureRect children from the CURRENT InputMap, exactly like the binding
## Label's own text — so a future rebinding screen keeps both in sync with
## zero further changes here.
var _icon_boxes: Array[HBoxContainer] = []

var _text_size_bases: Dictionary = {}  # Control -> base font size (Settings text-size)


func _ready() -> void:
	_build_rows()
	_build_tips()
	_back_button.pressed.connect(func() -> void: back_pressed.emit())
	# Table.minimum_size_changed is Godot's own "the real, final layout number
	# is ready" signal (fires after every row Label's own min size settles,
	# including subsequent font-size/text changes) — driving off it instead
	# of a `call_deferred()` guess avoids a real bug found here: a
	# `call_deferred()` sized the Scroll off the Table's min size while the
	# GridContainer's columns hadn't been laid out against a real width yet,
	# which measured a spuriously huge value (autowrap re-flowing every
	# Label to a near-zero column width) and never got corrected. See
	# _resize_scroll_to_table's own doc comment for what this fixes.
	_table.minimum_size_changed.connect(_resize_scroll_to_table)
	refresh()
	_collect_text_size_bases(self)
	_apply_text_size()
	_resize_scroll_to_table()
	var settings := get_node_or_null("/root/Settings")
	if settings and not settings.changed.is_connected(_apply_text_size):
		settings.changed.connect(_apply_text_size)


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_apply_text_size):
		settings.changed.disconnect(_apply_text_size)


func _build_rows() -> void:
	for row in ROWS:
		var name_label := Label.new()
		name_label.text = row["name"]
		name_label.custom_minimum_size = Vector2(230, 0)
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.add_theme_color_override("font_color", NAME_COLOR)
		name_label.add_theme_font_size_override("font_size", 20)
		_table.add_child(name_label)

		# Icons live in their own column (not inside the text Label) so the
		# text stays the single always-correct, always-present fallback per
		# the task brief ("kept beside... as fallback when no icon exists
		# for a key") — a binding with no matching icon file simply leaves
		# this box emptier for that one sub-binding, never touching the text.
		var icon_box := HBoxContainer.new()
		icon_box.add_theme_constant_override("separation", 4)
		icon_box.alignment = BoxContainer.ALIGNMENT_BEGIN
		_table.add_child(icon_box)
		_icon_boxes.append(icon_box)

		var binding_label := Label.new()
		binding_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		binding_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		binding_label.add_theme_color_override("font_color", BINDING_COLOR)
		binding_label.add_theme_font_size_override("font_size", 20)
		_table.add_child(binding_label)

		_row_labels.append(binding_label)
		var actions: Array = row["actions"]
		for action_name in actions:
			binding_labels[String(action_name)] = binding_label


func _build_tips() -> void:
	var separator := HSeparator.new()
	_tips_parent.add_child(separator)

	var header := Label.new()
	header.text = "Tips"
	header.add_theme_color_override("font_color", BINDING_COLOR)
	header.add_theme_font_size_override("font_size", 20)
	_tips_parent.add_child(header)

	for tip in TIPS:
		var label := Label.new()
		label.text = tip
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_color_override("font_color", TIP_COLOR)
		label.add_theme_font_size_override("font_size", 18)
		_tips_parent.add_child(label)


## Re-reads InputMap for every row's displayed binding. Safe to call anytime
## (e.g. every time the host opens this view) so a future rebinding screen's
## changes always show up correctly with zero changes here.
func refresh() -> void:
	for i in ROWS.size():
		var row: Dictionary = ROWS[i]
		var label: Label = _row_labels[i]
		var actions: Array = row["actions"]
		var static_text: String = row["static_text"]
		if static_text != "":
			label.text = static_text
		elif actions.size() == 2:
			label.text = _move_binding_text(StringName(actions[0]), StringName(actions[1]))
		else:
			label.text = get_binding_text(StringName(actions[0]))
		_refresh_row_icons(i, row)
	# A rebind can change a label's wrap (a longer/shorter binding string) —
	# _table.minimum_size_changed (connected in _ready()) re-measures the
	# Scroll automatically when that happens, no call needed here.


## Rebuilds row `i`'s icon column from the CURRENT InputMap (mirrors the
## binding Label text built just above it). Old icons are queue_free()'d —
## exactly the pattern used everywhere else in this project for "clear and
## rebuild a container's children" (e.g. Hud's toast area) — so a caller that
## needs to inspect the NEW icons right after refresh() should give freed
## nodes a frame to actually leave the tree first (tests do `await
## physics_frames(1)`).
func _refresh_row_icons(i: int, row: Dictionary) -> void:
	var box: HBoxContainer = _icon_boxes[i]
	for child in box.get_children():
		box.remove_child(child)
		child.queue_free()
	for path in _row_icon_paths(row):
		var rect := TextureRect.new()
		rect.texture = load(path)
		# The source SVGs are authored at 64x64 — EXPAND_IGNORE_SIZE is what
		# actually lets custom_minimum_size shrink them down to ICON_SIZE;
		# TextureRect's default expand mode (EXPAND_KEEP_SIZE) would otherwise
		# report the TEXTURE's own 64x64 as this control's minimum size no
		# matter what custom_minimum_size says, blowing every row's height
		# out to ~64px+ regardless of the size set here.
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.modulate = NAME_COLOR
		box.add_child(rect)


## Every icon file (res:// path, in display order) for row `row`'s CURRENT
## binding(s) — parallels get_binding_text()/_move_binding_text() but
## resolves to an icon path instead of a display string. A sub-binding with
## no matching entry in input_icon_map.gd's KEY_ICON_FILES/MOUSE_ICON_FILES
## (e.g. a future rebind onto a key this pack has no icon for) is simply omitted here — the row's
## text label (always built regardless) is what keeps that binding
## documented either way.
func _row_icon_paths(row: Dictionary) -> Array[String]:
	var static_icon: String = row.get("static_icon", "")
	if static_icon != "":
		return [ICON_DIR + static_icon]
	var actions: Array = row["actions"]
	if actions.size() == 2:
		return _move_icon_paths(StringName(actions[0]), StringName(actions[1]))
	elif actions.size() == 1:
		return _action_icon_paths(StringName(actions[0]))
	return []


func _action_icon_paths(action: StringName) -> Array[String]:
	var paths: Array[String] = []
	for event in InputMap.action_get_events(action):
		var path := _event_icon_path(event)
		if path != "" and not paths.has(path):
			paths.append(path)
	return paths


## Move's icon column mirrors _move_binding_text()'s own pairing (index 0
## with index 0, ...) so the icons read left-to-right in the same order as
## the text beside them ("A D" then "← →" rather than an unrelated order).
func _move_icon_paths(left_action: StringName, right_action: StringName) -> Array[String]:
	var left_events := InputMap.action_get_events(left_action)
	var right_events := InputMap.action_get_events(right_action)
	var paths: Array[String] = []
	var count: int = maxi(left_events.size(), right_events.size())
	for i in count:
		if i < left_events.size():
			var l := _event_icon_path(left_events[i])
			if l != "" and not paths.has(l):
				paths.append(l)
		if i < right_events.size():
			var r := _event_icon_path(right_events[i])
			if r != "" and not paths.has(r):
				paths.append(r)
	return paths


## Delegates to input_icon_map.gd (see this script's own top-of-file note) —
## kept as a thin wrapper so every call site above reads exactly as before.
func _event_icon_path(event: InputEvent) -> String:
	return InputIconMap.icon_path_for_event(event)


## Every InputMap action name this panel documents (used by
## tests/cases/test_help_controls.gd to prove no gameplay action is missing a
## row) — flattened straight from ROWS, so it can never drift from what's
## actually rendered.
func get_covered_actions() -> PackedStringArray:
	var result: PackedStringArray = []
	for row in ROWS:
		var actions: Array = row["actions"]
		for action_name in actions:
			result.append(String(action_name))
	return result


func grab_back_focus() -> void:
	_back_button.grab_focus()


# --- InputMap -> display text --------------------------------------------------

func get_binding_text(action: StringName) -> String:
	var labels: PackedStringArray = []
	for event in InputMap.action_get_events(action):
		var text := _event_label(event)
		if text != "" and not labels.has(text):
			labels.append(text)
	return " / ".join(labels) if labels.size() > 0 else "(unbound)"


## Move gets its own combined format ("A / D  or  ← / →"): the two actions'
## events are paired up positionally (index 0 with index 0, ...) rather than
## each rendered as its own row, per the task's explicit example.
func _move_binding_text(left_action: StringName, right_action: StringName) -> String:
	var left_events := InputMap.action_get_events(left_action)
	var right_events := InputMap.action_get_events(right_action)
	var pairs: PackedStringArray = []
	var count: int = maxi(left_events.size(), right_events.size())
	for i in count:
		var left_text := _event_label(left_events[i]) if i < left_events.size() else ""
		var right_text := _event_label(right_events[i]) if i < right_events.size() else ""
		if left_text == "" and right_text == "":
			continue
		var pair := "%s / %s" % [left_text, right_text]
		if not pairs.has(pair):
			pairs.append(pair)
	return "  or  ".join(pairs) if pairs.size() > 0 else "(unbound)"


## Delegates to input_icon_map.gd (see this script's own top-of-file note).
## `_key_label()`/`_mouse_label()` (the layout-aware key-label logic) moved
## there verbatim as `InputIconMap.key_label()`/`mouse_label()` so
## tutorial_prompt.gd gets the exact same labels this panel shows.
func _event_label(event: InputEvent) -> String:
	return InputIconMap.label_for_event(event)


# --- Settings text size ----------------------------------------------------------

func _collect_text_size_bases(root: Node) -> void:
	for child in root.get_children():
		if child is Label or child is Button or child is OptionButton:
			_text_size_bases[child] = child.get_theme_font_size("font_size")
		_collect_text_size_bases(child)


func _apply_text_size() -> void:
	var settings := get_node_or_null("/root/Settings")
	for node in _text_size_bases:
		if is_instance_valid(node):
			var base: int = _text_size_bases[node]
			node.add_theme_font_size_override("font_size",
					settings.scaled_font_size(base) if settings else base)
	# Icons scale with the SAME Settings.scaled_font_size() ratio as every
	# row's text (task brief: "icons... scale with the text-size setting"),
	# reusing the exact helper the fonts above use rather than a second,
	# independently-tunable ratio.
	var icon_size: int = settings.scaled_font_size(int(ICON_SIZE)) if settings else int(ICON_SIZE)
	for box in _icon_boxes:
		for child in box.get_children():
			if child is TextureRect:
				child.custom_minimum_size = Vector2(icon_size, icon_size)
	# Settings' "text size" grows every row's font (and can turn a one-line
	# row into two) — _table.minimum_size_changed (connected in _ready())
	# re-measures the Scroll automatically once that settles.


# --- Scroll sizing -----------------------------------------------------------

## Sizes the Scroll to the Table's OWN actual measured height (never a
## hardcoded pixel guess — CONVENTIONS.md/the M7 controls-menu review found a
## fixed guess silently clipped the last row, and clipped three whole rows at
## Settings' Large text size, both invisibly to a row-count sanity check).
## This keeps every documented action visible with no scrolling needed for
## the table itself at both supported resolutions and both text sizes;
## `Content`'s separator/"Tips" block sits right after the table and stays
## reachable by scrolling — those are spoiler-free bonus lines, not one of
## the InputMap actions this panel is contractually documenting per-row. At
## Settings' Large text size the table itself can exceed HOST_BUDGET_HEIGHT
## once the header/Back button's own (also-scaled) room is set aside — the
## table then keeps scrolling rather than growing this whole view past the
## Panel's own edges (see HOST_BUDGET_HEIGHT's doc comment).
func _resize_scroll_to_table() -> void:
	if not is_instance_valid(_scroll) or not is_instance_valid(_table) \
			or not is_instance_valid(_header_label) or not is_instance_valid(_back_button):
		return
	var needed: float = _table.get_combined_minimum_size().y
	var separation: float = get_theme_constant("separation")
	var overhead: float = (_header_label.get_combined_minimum_size().y
			+ _back_button.get_combined_minimum_size().y + separation * 2)
	var max_height: float = maxf(HOST_BUDGET_HEIGHT - overhead, MIN_SCROLL_HEIGHT)
	var target: float = clampf(needed, MIN_SCROLL_HEIGHT, max_height)
	# Only write on an actual change: the Scroll showing/hiding its own
	# vertical scrollbar changes Content's available WIDTH by the scrollbar's
	# thickness, which can change how a row wraps and re-fire
	# `minimum_size_changed` right back at this same handler — writing the
	# SAME target height again on every such call would keep re-triggering
	# that notification for no reason, so this is a plain no-op guard against
	# that, not a fix for an observed hang (a headless hang WAS hit writing
	# these regression tests, but that one traced to a test-script compile
	# error, not this function).
	if not is_equal_approx(_scroll.custom_minimum_size.y, target):
		_scroll.custom_minimum_size.y = target
