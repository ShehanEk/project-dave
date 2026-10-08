class_name WorkbenchPanel
extends CanvasLayer
## L01-UPG01 modal workbench UI (03-gameplay-systems.md "Workbench flow"). Opened by
## Workbench.interact(); reads/writes only through Session, never
## edits state directly. Gameplay input is disabled by the caller
## (`hero.input_enabled = false`) while this is open; this node re-enables
## it via `closed` regardless of what the player chose.
##
## C52 layout: two numbered sections, one per thing the bench does. 1. REPAIR AND SAVE
## (free: heal fully, save here) and 2. WEAPON UPGRADE (the Quickcycle: what it does as
## shots per second on two bars, what it costs, what is left after, one Buy button). The
## chip count sits in the header. Each button says what it does ("Repair and save",
## "Buy Quickcycle (40 chips)", "Close"), and the line at the bottom says what just happened.

signal closed

const WEAPON_TYPE := "W01"
const TARGET_STAGE := 1
const PRICE := 40
## The numbers shown come from the same tuning the Scrapjack fires by.
const TUNING_PATH := "res://data/tuning/w01_scrapjack.tres"
const ICON_FILL_NOW := Color(0.66, 0.73, 0.8, 1)
const ICON_FILL_QUICK := Color(0.247, 0.878, 0.816, 1)
const DIM_TEXT := Color(0.46, 0.52, 0.6, 1)
const BRIGHT_TEXT := Color(0.92, 0.95, 0.98, 1)
const TEAL := Color(0.247, 0.878, 0.816, 1)
const WARN := Color(1, 0.45, 0.35, 1)
const AMBER := Color(1, 0.69, 0.18, 1)

@onready var _wallet_label: Label = $Panel/VBox/HeaderRow/WalletLabel
@onready var _service_button: Button = $Panel/VBox/ServiceRow/ServiceButton
@onready var _service_info: Label = $Panel/VBox/ServiceRow/ServiceInfo
@onready var _state_label: Label = $Panel/VBox/UpgradeRow/Info/NameRow/StateLabel
@onready var _now_name: Label = $Panel/VBox/UpgradeRow/Info/RateGrid/NowName
@onready var _now_fill: ColorRect = $Panel/VBox/UpgradeRow/Info/RateGrid/NowBar/Fill
@onready var _now_value: Label = $Panel/VBox/UpgradeRow/Info/RateGrid/NowValue
@onready var _quick_name: Label = $Panel/VBox/UpgradeRow/Info/RateGrid/QuickName
@onready var _quick_value: Label = $Panel/VBox/UpgradeRow/Info/RateGrid/QuickValue
@onready var _cost_row: Control = $Panel/VBox/CostRow
@onready var _cost_label: Label = $Panel/VBox/CostRow/CostLabel
@onready var _balance_label: Label = $Panel/VBox/CostRow/BalanceLabel
@onready var _confirm_button: Button = $Panel/VBox/UpgradeRowButtons/ConfirmButton
@onready var _decline_button: Button = $Panel/VBox/UpgradeRowButtons/DeclineButton
@onready var _status_label: Label = $Panel/VBox/StatusLabel

var _pause_was_pressed: bool = false
## True once a Quickcycle was bought in this visit; the bench reads it on `closed` so the
## HUD can announce it after the panel is gone.
var bought: bool = false
var _tuning: WeaponTuning = null


func _ready() -> void:
	layer = 20
	_tuning = load(TUNING_PATH)
	_service_button.pressed.connect(_on_service_pressed)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_decline_button.pressed.connect(_on_decline_pressed)
	if Session:
		Session.wallet_changed.connect(_on_state_changed)
		Session.health_changed.connect(_on_health_changed)
		Session.upgrade_purchased.connect(_on_upgrade_purchased)
	_refresh("")
	# Land on the useful button: Buy when it can be pressed, else Close.
	if _confirm_button.visible and not _confirm_button.disabled:
		_confirm_button.grab_focus()
	else:
		_decline_button.grab_focus()


func _exit_tree() -> void:
	if Session:
		if Session.wallet_changed.is_connected(_on_state_changed):
			Session.wallet_changed.disconnect(_on_state_changed)
		if Session.health_changed.is_connected(_on_health_changed):
			Session.health_changed.disconnect(_on_health_changed)
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
	_refresh("Repaired. Progress saved." if ok else WorkbenchPanel.save_failed_message())


func _on_confirm_pressed() -> void:
	if Session == null:
		_play_sfx(&"ui_confirm")
		return
	var result: Dictionary = Session.purchase_upgrade(WEAPON_TYPE, TARGET_STAGE, PRICE)
	if result.get("ok", false):
		_play_sfx(&"ui_confirm")
		bought = true
		_refresh("Quickcycle installed. It fires %.1f shots a second now." % _rate(TARGET_STAGE))
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
			message = WorkbenchPanel.save_failed_message()
		"insufficient_funds":
			message = "Not enough chips"
		"already_owned":
			message = "Quickcycle already installed"
		"locked":
			message = "Workbench offline"
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


func _on_health_changed(_hp, _max_hp) -> void:
	_refresh(_status_label.text)


func _on_upgrade_purchased(_type: String, _stage: int) -> void:
	_refresh(_status_label.text)


## Shots per second at `stage`, from the tuning the gun uses.
func _rate(stage: int) -> float:
	return _tuning.shots_per_second(stage) if _tuning else (1.0 / 0.32 if stage < 1 else 1.0 / 0.18)


func _refresh(status: String) -> void:
	if Session == null:
		return
	var stage := Session.weapon_stage(WEAPON_TYPE)
	var owned := stage >= TARGET_STAGE
	var wallet := Session.get_wallet()
	_wallet_label.text = "%d" % wallet

	# 1. Repair and save.
	_service_info.text = "Free. Heals you fully (health %d of %d now) and saves your progress here." \
			% [Session.get_health(), Session.MAX_HEALTH]

	# 2. The Quickcycle: what it does, as two bars on one scale (the fast one is full).
	var base_rate := _rate(0)
	var quick_rate := _rate(TARGET_STAGE)
	_now_fill.anchor_right = base_rate / quick_rate
	_now_value.text = "%.1f shots/s" % base_rate
	_quick_value.text = "%.1f shots/s  (+%d%%)" % [quick_rate, roundi((quick_rate / base_rate - 1.0) * 100.0)]
	_state_label.text = "INSTALLED" if owned else "NOT INSTALLED"
	_state_label.add_theme_color_override("font_color", TEAL if owned else DIM_TEXT)
	# The row you have now reads white, the offer teal; once bought the old row dims.
	for l in [_now_name, _now_value]:
		l.add_theme_color_override("font_color", DIM_TEXT if owned else BRIGHT_TEXT)
	for l in [_quick_name, _quick_value]:
		l.add_theme_color_override("font_color", BRIGHT_TEXT if owned else TEAL)
	_now_fill.color = ICON_FILL_NOW.darkened(0.45) if owned else ICON_FILL_NOW

	# Price, what is left, and the one Buy button.
	_cost_row.visible = not owned
	if owned:
		_confirm_button.visible = false
		_confirm_button.disabled = true
		_decline_button.text = "Close"
		_decline_button.grab_focus()
	else:
		_cost_label.text = "Price: %d chips" % PRICE
		_cost_label.add_theme_color_override("font_color", AMBER)
		if wallet < PRICE:
			_balance_label.text = "You have %d. Find %d more chips." % [wallet, PRICE - wallet]
			_balance_label.add_theme_color_override("font_color", WARN)
		else:
			_balance_label.text = "You have %d. %d left after buying." % [wallet, wallet - PRICE]
			_balance_label.remove_theme_color_override("font_color")
		_confirm_button.visible = true
		_confirm_button.disabled = wallet < PRICE
		_confirm_button.text = "Buy Quickcycle (%d chips)" % PRICE
		_decline_button.text = "Close"
	_status_label.text = status


func _close() -> void:
	closed.emit()
	queue_free()


static func save_failed_message() -> String:
	return "Save failed — progress since the last checkpoint is kept in memory only"
