class_name BenchPanel
extends CanvasLayer
## L01-UPG01 modal bench UI (03-gameplay-systems.md "Bench flow"). Opened by
## MaintenanceBench.interact(); reads/writes only through Session, never
## edits state directly. Gameplay input is disabled by the caller
## (`hero.input_enabled = false`) while this is open; this node re-enables
## it via `closed` regardless of what the player chose.

signal closed

const WEAPON_TYPE := "W01"
const TARGET_STAGE := 1
const PRICE := 40
const BASE_INTERVAL := 0.32
const QUICKCYCLE_INTERVAL := 0.24

@onready var _service_button: Button = $Panel/VBox/ServiceRow/ServiceButton
@onready var _confirm_button: Button = $Panel/VBox/UpgradeRow/ConfirmButton
@onready var _decline_button: Button = $Panel/VBox/UpgradeRow/DeclineButton
@onready var _status_label: Label = $Panel/VBox/StatusLabel
@onready var _price_label: Label = $Panel/VBox/PriceLabel
@onready var _cadence_label: Label = $Panel/VBox/CadenceLabel
@onready var _wallet_label: Label = $Panel/VBox/WalletLabel

var _pause_was_pressed: bool = false


func _ready() -> void:
	layer = 20
	_service_button.pressed.connect(_on_service_pressed)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_decline_button.pressed.connect(_on_decline_pressed)
	if Session:
		Session.wallet_changed.connect(_on_state_changed)
		Session.upgrade_purchased.connect(_on_upgrade_purchased)
	_refresh("")
	_confirm_button.grab_focus()


func _exit_tree() -> void:
	if Session:
		if Session.wallet_changed.is_connected(_on_state_changed):
			Session.wallet_changed.disconnect(_on_state_changed)
		if Session.upgrade_purchased.is_connected(_on_upgrade_purchased):
			Session.upgrade_purchased.disconnect(_on_upgrade_purchased)


## Polled by hand in `_physics_process` (like hero.gd's jump/interact edges)
## rather than through `_unhandled_input` or idle `_process`: `Input.
## action_press()` — how RouteBot and this project's own tests drive input —
## deliberately never dispatches a real input event, only the polling state
## `is_action_pressed` reads; and a fixed-fps test run (tools/test.sh's
## FPS=30) can retarget/release an action within a single 60Hz physics tick,
## which idle `_process` (throttled to the fixed-fps rate) can miss entirely.
func _physics_process(_delta: float) -> void:
	var pressed := Input.is_action_pressed("pause")
	if pressed and not _pause_was_pressed:
		_close()
	_pause_was_pressed = pressed


func _on_service_pressed() -> void:
	_play_sfx(&"ui_confirm")
	if Session == null:
		return
	Session.heal_full()
	var ok := Session.commit("UPG01")
	_refresh("Progress saved" if ok else BenchPanel.save_failed_message())


func _on_confirm_pressed() -> void:
	if Session == null:
		_play_sfx(&"ui_confirm")
		return
	var result: Dictionary = Session.purchase_upgrade(WEAPON_TYPE, TARGET_STAGE, PRICE)
	if result.get("ok", false):
		_play_sfx(&"ui_confirm")
		_refresh("Quickcycle installed")
		return
	# AD-14 (partial): audio-direction.md calls for a distinct failed-purchase
	# cue; this used to play the same "ui_confirm" success chime on a refusal
	# (insufficient funds/locked/etc.), with nothing else to tell the two
	# apart by ear. Reuse the existing negative-feedback cue (ui_back, already
	# used for Decline) instead of adding a new synthesized asset.
	_play_sfx(&"ui_back")
	var message: String
	match String(result.get("reason", "")):
		"save_failed":
			message = BenchPanel.save_failed_message()
		"insufficient_funds":
			message = "Not enough gems"
		"already_owned":
			message = "Quickcycle already installed"
		"locked":
			message = "Bench offline"
		_:
			message = "Purchase unavailable"
	_refresh(message)


func _on_decline_pressed() -> void:
	_play_sfx(&"ui_back")
	_close()


func _play_sfx(cue: StringName) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue)


func _on_state_changed(_value) -> void:
	_refresh(_status_label.text)


func _on_upgrade_purchased(_type: String, _stage: int) -> void:
	_refresh(_status_label.text)


func _refresh(status: String) -> void:
	if Session == null:
		return
	var stage := Session.weapon_stage(WEAPON_TYPE)
	var wallet := Session.get_wallet()
	_wallet_label.text = "Gems: %d" % wallet
	if stage >= TARGET_STAGE:
		_cadence_label.text = "Quickcycle installed — cadence %.2fs" % QUICKCYCLE_INTERVAL
		_price_label.text = "Owned"
		_confirm_button.visible = false
		_confirm_button.disabled = true
		_decline_button.text = "Close"
	else:
		_cadence_label.text = "Quickcycle: %.2fs -> %.2fs cadence" % [BASE_INTERVAL, QUICKCYCLE_INTERVAL]
		# AD-11 fix: used to always show "wallet X -> Y" including when Y went
		# negative (an impossible purchase result) whenever funds were short.
		# Show what's actually missing instead; the successful case (enough
		# gems) still shows the real before -> after projection.
		if wallet < PRICE:
			_price_label.text = "Need %d gems (you have %d)" % [PRICE, wallet]
		else:
			_price_label.text = "%d gems (wallet %d -> %d)" % [PRICE, wallet, wallet - PRICE]
		_confirm_button.visible = true
		_confirm_button.disabled = wallet < PRICE
		_decline_button.text = "Decline"
	_status_label.text = status


func _close() -> void:
	closed.emit()
	queue_free()


static func save_failed_message() -> String:
	return "Save failed — progress since the last checkpoint is kept in memory only"
