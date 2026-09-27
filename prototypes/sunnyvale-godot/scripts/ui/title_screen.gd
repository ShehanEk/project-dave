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

signal new_game_confirmed
signal continue_confirmed(snapshot: Dictionary)
signal quit_requested

enum View { MAIN, NEW_GAME_CONFIRM }

@onready var _new_game_button: Button = $Panel/VBox/MainView/ButtonRow/NewGameButton
@onready var _continue_button: Button = $Panel/VBox/MainView/ButtonRow/ContinueButton
@onready var _quit_button: Button = $Panel/VBox/MainView/ButtonRow/QuitButton
@onready var _message_label: Label = $Panel/VBox/MessageLabel
@onready var _main_view: VBoxContainer = $Panel/VBox/MainView
@onready var _confirm_view: VBoxContainer = $Panel/VBox/ConfirmView
@onready var _confirm_button: Button = $Panel/VBox/ConfirmView/ConfirmRow/ConfirmButton
@onready var _cancel_button: Button = $Panel/VBox/ConfirmView/ConfirmRow/CancelButton

var _view: View = View.MAIN
var _pause_was_pressed: bool = false
var _text_size_bases: Dictionary = {}  # Control -> base font size (M6 text-size setting)


func _ready() -> void:
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_confirm_button.pressed.connect(_on_new_game_confirm)
	_cancel_button.pressed.connect(_on_new_game_cancel)
	_message_label.text = ""
	refresh()
	_show_main_view()
	_collect_text_size_bases($Panel)
	_apply_text_size()
	var settings := get_node_or_null("/root/Settings")
	if settings and not settings.changed.is_connected(_apply_text_size):
		settings.changed.connect(_apply_text_size)


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_apply_text_size):
		settings.changed.disconnect(_apply_text_size)


## Settings "text size" (M6): captures every Label/Button's own authored font
## size once as its baseline so it can be scaled consistently without
## hardcoding each node's base size a second time here.
func _collect_text_size_bases(root: Node) -> void:
	for child in root.get_children():
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


## Polled by hand (see BenchPanel/SwapConfirm's identical comment): `pause`
## also backs the New Game confirmation out, matching every other dialog's
## Decline-wired-to-pause convention.
func _physics_process(_delta: float) -> void:
	var pressed := Input.is_action_pressed("pause")
	if pressed and not _pause_was_pressed and _view == View.NEW_GAME_CONFIRM:
		_on_new_game_cancel()
	_pause_was_pressed = pressed


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


func _show_main_view() -> void:
	_view = View.MAIN
	_main_view.visible = true
	_confirm_view.visible = false
	_new_game_button.grab_focus()


func _show_confirm_view() -> void:
	_view = View.NEW_GAME_CONFIRM
	_main_view.visible = false
	_confirm_view.visible = true
	_cancel_button.grab_focus()


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
		_message_label.text = "Save system unavailable."
		return
	var result: Dictionary = service.load_latest()
	if result.get("ok", false):
		_message_label.text = ("Primary save was unreadable — restored from backup."
				if String(result.get("source", "")) == "backup" else "")
		_play_sfx(&"ui_confirm")
		continue_confirmed.emit(result.snapshot)
	else:
		_message_label.text = "No valid save found (%s). Start a New Game instead." % result.get("error", "")
		refresh()


func _on_continue_pressed() -> void:
	attempt_continue()


func _on_quit_pressed() -> void:
	_play_sfx(&"ui_back")
	quit_requested.emit()
