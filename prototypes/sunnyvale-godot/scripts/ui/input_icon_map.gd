extends RefCounted
## Shared input-binding -> Kenney icon / display-text mapping (M7 Kenney part
## B). `controls_panel.gd` (the Controls-help table) and `tutorial_prompt.gd`
## (world-space one-shot prompts) both name a CURRENT InputMap binding and
## show a Kenney icon for it, text fallback when no icon file exists — this
## is the ONE place that mapping (and the layout-aware key-label logic it
## depends on) lives, so nothing duplicates `controls_panel.gd`'s original
## KEY_ICON_FILES/MOUSE_ICON_FILES table or its `_key_label()`/`_mouse_label()`
## logic. No `class_name` (every M6/M6.5/M7-era helper script in this project
## follows the same "no class_name churn" rule mid a concurrent workflow
## phase — see kenney_puff.gd's own doc comment) — reached through a plain
## preload() constant and its static functions, exactly like kenney_puff.gd.

const ICON_DIR := "res://assets/kenney/input-prompts/"

## Kenney "Keyboard & Mouse -> Vector -> Outline" input-prompt icons
## (assets/kenney/README.md section 2). Keyed by the same physical keycode /
## mouse button index `label_for_event()` below already switches on, so a
## binding this project doesn't currently use (and so has no icon file
## copied in) simply has no entry here — every caller falls back to text for
## that one sub-binding, never a crash or a missing row.
## Kenney part B fix (space-icon-illegible-at-render-size, this pass):
## `keyboard_space_outline.svg` deliberately has NO entry here. Unlike the
## single-glyph keys below (A/D/W/E/...), Kenney bakes the word "SPACE" as
## vector text into that icon's own artwork; at this project's icon render
## size (26-28px — `tutorial_prompt.gd`'s `ICON_SIZE`/`controls_panel.gd`'s
## own `ICON_SIZE`) the 5-character word shrinks into an illegible smudge
## (confirmed by zoomed capture — see reports/asset-inventory.md 7.6), unlike
## every other key/mouse icon here which stays crisp at the same size. Every
## caller already falls back to the plain bracketed-text token
## ("[Space]"/"Space" in the binding-text column) for any binding with no
## icon file — the exact mechanism this leans on, per input_icon_map.gd's own
## "no crash, no missing row" contract above — so Jump's row keeps its W/↑
## icons plus a readable "Space" text label instead of a blurry icon.
const KEY_ICON_FILES := {
	KEY_A: "keyboard_a_outline.svg",
	KEY_D: "keyboard_d_outline.svg",
	KEY_W: "keyboard_w_outline.svg",
	KEY_LEFT: "keyboard_arrow_left_outline.svg",
	KEY_RIGHT: "keyboard_arrow_right_outline.svg",
	KEY_UP: "keyboard_arrow_up_outline.svg",
	KEY_E: "keyboard_e_outline.svg",
	KEY_ESCAPE: "keyboard_escape_outline.svg",
	KEY_TAB: "keyboard_tab_outline.svg",
	KEY_ENTER: "keyboard_enter_outline.svg",
	KEY_KP_ENTER: "keyboard_enter_outline.svg",
	KEY_F1: "keyboard_f1_outline.svg",
}
const MOUSE_ICON_FILES := {
	MOUSE_BUTTON_LEFT: "mouse_left_outline.svg",
}
## `mouse_move.svg` has no bindable InputMap action (aim is always the raw
## pointer) — callers that want it use this filename directly as a
## `static_icon`/`static_icon_before`, mirroring controls_panel.gd's own
## "Aim" row (`static_icon: "mouse_move.svg"`).
const MOUSE_MOVE_ICON := "mouse_move.svg"


## Icon res:// path for one InputEvent, or "" if this project has no icon
## file for it.
static func icon_path_for_event(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var code: int = key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode
		var filename: String = KEY_ICON_FILES.get(code, "")
		return ICON_DIR + filename if filename != "" else ""
	elif event is InputEventMouseButton:
		var filename: String = MOUSE_ICON_FILES.get((event as InputEventMouseButton).button_index, "")
		return ICON_DIR + filename if filename != "" else ""
	return ""


## Every icon path (res://, in binding order, de-duplicated) for `action`'s
## CURRENT events — parallels controls_panel.gd's original `_action_icon_paths`.
static func icon_paths_for_action(action: StringName) -> Array[String]:
	var paths: Array[String] = []
	for event in InputMap.action_get_events(action):
		var path := icon_path_for_event(event)
		if path != "" and not paths.has(path):
			paths.append(path)
	return paths


## One token per bound event for `action`, in binding order, de-duplicated:
## `{"icon": res_path}` when this project has an icon file for that binding,
## else `{"text": display_label}` — the SAME label `label_for_action()` would
## show for it — so a caller (tutorial_prompt.gd) always documents the
## CURRENT binding even for a key this pack has no icon for ("text fallback
## if no icon exists" per the task brief). Empty for an unbound action.
static func tokens_for_action(action: StringName) -> Array[Dictionary]:
	var tokens: Array[Dictionary] = []
	var seen: Array[String] = []
	for event in InputMap.action_get_events(action):
		var label := label_for_event(event)
		if label == "":
			continue
		var icon := icon_path_for_event(event)
		var dedup_key: String = icon if icon != "" else "text:" + label
		if seen.has(dedup_key):
			continue
		seen.append(dedup_key)
		tokens.append({"icon": icon} if icon != "" else {"text": label})
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
