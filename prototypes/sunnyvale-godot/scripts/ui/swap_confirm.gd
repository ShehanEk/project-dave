class_name SwapConfirm
extends CanvasLayer
## Depot pad swap confirmation (weapon-swaps.md "atomic exchange"). Opened by
## WeaponPad.interact(); names both instances by their workshop tag (P01/
## P02). Confirm calls Session.swap_weapon(pad_id) exactly once; Decline/
## Escape leaves state unchanged. The caller disables hero input while this
## is open and re-enables it on `closed`. `closed(swapped)` tells the caller
## whether a swap actually happened (Confirm and it succeeded) or not
## (Decline/Escape, or a Confirm that Session refused) — ADV-04: WeaponPad
## only shows its "Weapon swapped" toast when `swapped` is true.

signal closed(swapped: bool)

var _pad_id: String = ""

@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _confirm_button: Button = $Panel/VBox/HBox/ConfirmButton
@onready var _decline_button: Button = $Panel/VBox/HBox/DeclineButton

var _pause_was_pressed: bool = false


func open(pad_id: String) -> void:
	_pad_id = pad_id
	if Session == null:
		return
	var held_tag := _tag(Session.equipped_weapon())
	var resting_tag := _tag(Session.weapon_on_pad(pad_id))
	_title_label.text = "Swap held %s for pad %s?" % [held_tag, resting_tag]


func _ready() -> void:
	layer = 20
	_confirm_button.pressed.connect(_on_confirm)
	_decline_button.pressed.connect(_on_decline)
	_confirm_button.grab_focus()


## Polled by hand in `_physics_process` rather than `_unhandled_input` or
## idle `_process` — see WorkbenchPanel's `_physics_process()` comment:
## `Input.action_press()` (RouteBot / tests) never dispatches a real input
## event, and idle `_process` can miss a press+release that both happen
## within one 60Hz physics tick under a fixed-fps test run.
func _physics_process(_delta: float) -> void:
	var pressed := Input.is_action_pressed("pause")
	if pressed and not _pause_was_pressed:
		_on_decline()
	_pause_was_pressed = pressed


func _on_confirm() -> void:
	_play_sfx(&"ui_confirm")
	var swapped := false
	if Session:
		swapped = Session.swap_weapon(_pad_id).ok
	_close(swapped)


func _on_decline() -> void:
	_play_sfx(&"ui_back")
	_close(false)


func _close(swapped: bool) -> void:
	closed.emit(swapped)
	queue_free()


func _play_sfx(cue: StringName) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue)


static func _tag(instance_id: String) -> String:
	if instance_id == "":
		return "—"
	var parts := instance_id.split("-")
	return parts[-1] if parts.size() > 0 else instance_id
