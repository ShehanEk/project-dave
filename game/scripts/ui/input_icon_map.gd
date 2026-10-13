extends RefCounted
## Shared input-binding -> pixel key-cap icon / display-text mapping (M7
## Kenney part B; pixel UI pass, Sheet 12). `controls_panel.gd` (the
## Controls-help table) and `tutorial_prompt.gd` (world-space one-shot
## prompts) both name a CURRENT InputMap binding and show an icon for it, text
## fallback when there is none — this is the ONE place that mapping (and the
## layout-aware key-label logic it depends on) lives. No `class_name` (every
## M6/M6.5/M7-era helper script in this project follows the same "no
## class_name churn" rule) — reached through a plain preload() constant and its
## static functions, exactly like kenney_puff.gd.
##
## Icons are the pixel UI's key caps (scripts/ui/pixel_ui.gd `key_cap()`): the
## CURRENT layout-aware key label (`key_label()`) drawn in the pixel font in
## dark ink on the sheet's blank cap (widened for a multi-letter label such as
## ESC, TAB, ENTER or SPACE on the wide cap), the sheet's arrow glyphs on a cap
## for the arrow keys, and the sheet's mice with the left or right button lit.
## A binding with no cap (a label the pixel font cannot draw, longer than
## `PixelUi.MAX_CAP_CHARS`, the middle mouse button, or any missing PNG) has no
## icon, and every caller shows its text instead — never a crash or a missing
## row. The icons are 1 texel per UI pixel; each caller scales them by a whole
## number (`ICON_SCALE` in its own script).

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")

## The pixel mouse pieces per bindable mouse button.
const MOUSE_PIECES := {
	MOUSE_BUTTON_LEFT: "mouse_left",
	MOUSE_BUTTON_RIGHT: "mouse_right",
}
## Icons for bindings that are not InputMap actions (Aim is always the raw
## pointer), by name. "mouse_move.svg" is the Kenney file name the A01 "Aim +
## Fire" prompt (a01_gate.tscn `static_icon_before`) and older callers use; it
## maps to the pixel "aim with the mouse" icon too.
const STATIC_PIECES := {
	"mouse_aim": "mouse_aim",
	"mouse_move.svg": "mouse_aim",
}
const MOUSE_AIM_ICON := "mouse_aim"


## The icon for one InputEvent, or null if there is none for it.
static func icon_for_event(event: InputEvent) -> Texture2D:
	if event is InputEventKey:
		var label := label_for_event(event)
		return PixelUi.key_cap(label) if label != "" else null
	elif event is InputEventMouseButton:
		var piece: String = MOUSE_PIECES.get((event as InputEventMouseButton).button_index, "")
		return PixelUi.texture(piece) if piece != "" else null
	return null


## The icon for a static (non-InputMap) name such as "mouse_aim", or null.
static func static_icon(icon_name: String) -> Texture2D:
	var piece: String = STATIC_PIECES.get(icon_name, "")
	return PixelUi.texture(piece) if piece != "" else null


## Every icon (in binding order, de-duplicated) for `action`'s CURRENT events.
static func icons_for_action(action: StringName) -> Array[Texture2D]:
	var icons: Array[Texture2D] = []
	for event in InputMap.action_get_events(action):
		var icon := icon_for_event(event)
		if icon != null and not icons.has(icon):
			icons.append(icon)
	return icons


## One token per bound event for `action`, in binding order, de-duplicated:
## `{"icon": Texture2D}` when there is an icon for that binding, else
## `{"text": display_label}` — the SAME label `label_for_action()` would show
## for it — so a caller (tutorial_prompt.gd) always documents the CURRENT
## binding even for a key with no cap ("text fallback if no icon exists" per
## the task brief). Empty for an unbound action.
static func tokens_for_action(action: StringName) -> Array[Dictionary]:
	var tokens: Array[Dictionary] = []
	var seen: Array = []
	for event in InputMap.action_get_events(action):
		var label := label_for_event(event)
		if label == "":
			continue
		var icon := icon_for_event(event)
		var dedup_key: Variant = icon if icon != null else "text:" + label
		if seen.has(dedup_key):
			continue
		seen.append(dedup_key)
		tokens.append({"icon": icon} if icon != null else {"text": label})
	return tokens


## Display text for one InputEvent — parallels controls_panel.gd's original
## `_event_label()`.
static func label_for_event(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var code: int = key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode
		return key_label(code)
	elif event is InputEventMouseButton:
		return mouse_label((event as InputEventMouseButton).button_index)
	return ""


## Joined display text for every CURRENT event bound to `action` — parallels
## controls_panel.gd's original `get_binding_text()`.
static func label_for_action(action: StringName) -> String:
	var labels: PackedStringArray = []
	for event in InputMap.action_get_events(action):
		var text := label_for_event(event)
		if text != "" and not labels.has(text):
			labels.append(text)
	return " / ".join(labels) if labels.size() > 0 else "(unbound)"


## Layout-aware key label: arrows/space/enter/escape/tab/function keys get a
## short, stable name; every other (letter/number/symbol) key asks
## DisplayServer for the CURRENT keyboard layout's own label (falling back to
## OS.get_keycode_string when no layout answer is available, e.g. some
## headless runs) rather than assuming a US QWERTY layout. Moved here
## verbatim from controls_panel.gd's original `_key_label()` (see that
## function's own removal note) so both callers share one implementation.
static func key_label(keycode: int) -> String:
	match keycode:
		KEY_LEFT:
			return "←"
		KEY_RIGHT:
			return "→"
		KEY_UP:
			return "↑"
		KEY_DOWN:
			return "↓"
		KEY_SPACE:
			return "Space"
		KEY_ENTER, KEY_KP_ENTER:
			return "Enter"
		KEY_ESCAPE:
			return "Esc"
		KEY_TAB:
			return "Tab"
		KEY_F1:
			return "F1"
	var mapped: Key = KEY_NONE
	if DisplayServer.get_name() != "headless":
		mapped = DisplayServer.keyboard_get_label_from_physical(keycode) as Key
	if mapped == KEY_NONE:
		mapped = keycode as Key
	return OS.get_keycode_string(mapped)


static func mouse_label(button_index: int) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT:
			return "Left mouse button"
		MOUSE_BUTTON_RIGHT:
			return "Right mouse button"
		MOUSE_BUTTON_MIDDLE:
			return "Middle mouse button"
	return "Mouse button %d" % button_index
