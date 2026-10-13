class_name WorkbenchPanel
extends CanvasLayer
## L01-UPG01 modal workbench UI (03-gameplay-systems.md "Workbench flow"). Opened by
## Workbench.interact(); reads/writes only through Session, never
## edits state directly. Gameplay input is disabled by the caller
## (`hero.input_enabled = false`) while this is open; this node re-enables
## it via `closed` regardless of what the player chose.
##
## C52/C53 layout: numbered sections, one per thing the bench does. 1. REPAIR AND SAVE (free:
## heal fully, save here) and 2. UPGRADES: the Quickcycle (fire rate as two bars) and Scrap
## Plating (+1 max health), each with its state and its own Buy button. The line under them
## says what the chips can buy (C53: the main route pays about 45 chips, the two cost 65
## together, so a player who skipped the 20-chip cache picks one). The chip count sits in the
## header, and the line at the bottom says what just happened.

signal closed

const WEAPON_TYPE := "W01"
const TARGET_STAGE := 1
const PRICE := 40
const PLATING_TYPE := "A01"
const PLATING_PRICE := 25
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
@onready var _state_label: Label = $Panel/VBox/QuickcycleCard/Info/NameRow/StateLabel
@onready var _now_name: Label = $Panel/VBox/QuickcycleCard/Info/RateGrid/NowName
@onready var _now_fill: ColorRect = $Panel/VBox/QuickcycleCard/Info/RateGrid/NowBar/Fill
@onready var _now_value: Label = $Panel/VBox/QuickcycleCard/Info/RateGrid/NowValue
@onready var _quick_name: Label = $Panel/VBox/QuickcycleCard/Info/RateGrid/QuickName
@onready var _quick_value: Label = $Panel/VBox/QuickcycleCard/Info/RateGrid/QuickValue
@onready var _plating_state: Label = $Panel/VBox/PlatingCard/Info/NameRow/StateLabel
@onready var _plating_effect: Label = $Panel/VBox/PlatingCard/Info/EffectLabel
@onready var _balance_label: Label = $Panel/VBox/BalanceLabel
@onready var _confirm_button: Button = $Panel/VBox/UpgradeRowButtons/ConfirmButton
@onready var _plating_button: Button = $Panel/VBox/UpgradeRowButtons/PlatingButton
@onready var _decline_button: Button = $Panel/VBox/UpgradeRowButtons/DeclineButton
@onready var _status_label: Label = $Panel/VBox/StatusLabel

var _pause_was_pressed: bool = false
## True once a Quickcycle was bought in this visit; the bench reads it on `closed` so the
## HUD can announce it after the panel is gone.
var bought: bool = false
## True once Scrap Plating was bought in this visit.
var bought_plating: bool = false
var _tuning: WeaponTuning = null


func _ready() -> void:
	layer = 20
	_tuning = load(TUNING_PATH)
	_service_button.pressed.connect(_on_service_pressed)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_plating_button.pressed.connect(_on_plating_pressed)
	_decline_button.pressed.connect(_on_decline_pressed)
	if Session:
		Session.wallet_changed.connect(_on_state_changed)
		Session.health_changed.connect(_on_health_changed)
		Session.upgrade_purchased.connect(_on_upgrade_purchased)
	_refresh("")
	# Land on the useful button: a Buy that can be pressed, else Close.
	if _confirm_button.visible and not _confirm_button.disabled:
		_confirm_button.grab_focus()
	elif _plating_button.visible and not _plating_button.disabled:
		_plating_button.grab_focus()
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
	if _buy(WEAPON_TYPE, PRICE):
		bought = true
		_refresh("Quickcycle installed. It fires %.1f shots a second now." % _rate(TARGET_STAGE))


func _on_plating_pressed() -> void:
	if _buy(PLATING_TYPE, PLATING_PRICE):
		bought_plating = true
		_refresh("Scrap Plating fitted. %d health segments now." % Session.max_health())


## One purchase through Session; on a refusal says why. True when it went through.
func _buy(upgrade_type: String, price: int) -> bool:
	if Session == null:
		_play_sfx(&"ui_confirm")
		return false
	var result: Dictionary = Session.purchase_upgrade(upgrade_type, TARGET_STAGE, price)
	if result.get("ok", false):
		_play_sfx(&"ui_confirm")
		return true
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
			message = "Already installed"
		"locked":
			message = "Workbench offline"
		_:
			message = "Purchase unavailable"
	_refresh(message)
	return false


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
	var owned := Session.weapon_stage(WEAPON_TYPE) >= TARGET_STAGE
	var plated := Session.weapon_stage(PLATING_TYPE) >= TARGET_STAGE
	var wallet := Session.get_wallet()
	_wallet_label.text = "%d" % wallet

	# 1. Repair and save.
	_service_info.text = "Free. Heals you fully (health %d of %d now) and saves your progress here." \
			% [Session.get_health(), Session.max_health()]

	# 2a. The Quickcycle: what it does, as two bars on one scale (the fast one is full).
	var base_rate := _rate(0)
	var quick_rate := _rate(TARGET_STAGE)
	_now_fill.anchor_right = base_rate / quick_rate
	_now_value.text = "%.1f shots/s" % base_rate
	_quick_value.text = "%.1f shots/s  (+%d%%)" % [quick_rate, roundi((quick_rate / base_rate - 1.0) * 100.0)]
	_set_state(_state_label, owned)
	# The row you have now reads white, the offer teal; once bought the old row dims.
	for l in [_now_name, _now_value]:
		l.add_theme_color_override("font_color", DIM_TEXT if owned else BRIGHT_TEXT)
	for l in [_quick_name, _quick_value]:
		l.add_theme_color_override("font_color", BRIGHT_TEXT if owned else TEAL)
	_now_fill.color = ICON_FILL_NOW.darkened(0.45) if owned else ICON_FILL_NOW

	# 2b. Scrap Plating.
	_set_state(_plating_state, plated)
	_plating_effect.text = ("Max health %d. One more hit before you go down." % Session.max_health()) if plated \
			else ("Max health %d -> %d: one more hit before you go down." % [Session.MAX_HEALTH, Session.MAX_HEALTH + 1])

	# What the chips buy, and one Buy button per upgrade still to buy.
	_balance_label.remove_theme_color_override("font_color")
	if owned and plated:
		_balance_label.text = "Everything here is fitted."
	elif owned or plated:
		var left_price := PLATING_PRICE if owned else PRICE
		if wallet >= left_price:
			_balance_label.text = "You have %d chips: %d left after buying." % [wallet, wallet - left_price]
		else:
			_balance_label.text = "You have %d chips. Find %d more for the other upgrade." % [wallet, left_price - wallet]
	elif wallet >= PRICE + PLATING_PRICE:
		_balance_label.text = "You have %d chips: enough for both." % wallet
	elif wallet >= PRICE:
		_balance_label.text = "You have %d chips: enough for one of them. Choose." % wallet
		_balance_label.add_theme_color_override("font_color", AMBER)
	elif wallet >= PLATING_PRICE:
		_balance_label.text = "You have %d chips: enough for the Plating. %d more for the Quickcycle." % [wallet, PRICE - wallet]
	else:
		_balance_label.text = "You have %d chips. Find %d more for the Plating." % [wallet, PLATING_PRICE - wallet]
		_balance_label.add_theme_color_override("font_color", WARN)
	_confirm_button.visible = not owned
	_confirm_button.disabled = owned or wallet < PRICE
	_confirm_button.text = "Buy Quickcycle (%d)" % PRICE
	_plating_button.visible = not plated
	_plating_button.disabled = plated or wallet < PLATING_PRICE
	_plating_button.text = "Buy Plating (%d)" % PLATING_PRICE
	_decline_button.text = "Close"
	# A button just hidden or disabled hands focus on to the next one that works.
	var focused: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	if focused != null and (not focused.visible or (focused is Button and focused.disabled)):
		for b in [_confirm_button, _plating_button, _decline_button]:
			if b.visible and not b.disabled:
				b.grab_focus()
				break
	_status_label.text = status


func _set_state(label: Label, installed: bool) -> void:
	label.text = "INSTALLED" if installed else "NOT INSTALLED"
	label.add_theme_color_override("font_color", TEAL if installed else DIM_TEXT)


func _close() -> void:
	closed.emit()
	queue_free()


static func save_failed_message() -> String:
	return "Save failed — progress since the last checkpoint is kept in memory only"
