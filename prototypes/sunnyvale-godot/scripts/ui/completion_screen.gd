class_name CompletionScreen
extends CanvasLayer
## `scenes/ui/completion.tscn` — shown once by LevelDirector when the exit
## wicket is reached and CP05 is committed (03-gameplay-systems.md
## "Completion totals derive from unique collected IDs, so spending does not
## lower 'chips found.'"). Reads Session only; never mutates it directly
## except through `Session.new_run()` on a confirmed "Play again" (mirrors
## every other modal's "opener owns hero.input_enabled, this node owns its
## own buttons" split — LevelDirector disables input before this opens and
## decides what happens after `play_again_confirmed`/`quit_requested`).

signal play_again_confirmed
signal quit_requested

@onready var _stats_view: VBoxContainer = $Panel/VBox/StatsView
@onready var _confirm_view: VBoxContainer = $Panel/VBox/ConfirmView
@onready var _time_label: Label = $Panel/VBox/StatsView/TimeLabel
@onready var _chips_label: Label = $Panel/VBox/StatsView/ChipsLabel
@onready var _key_label: Label = $Panel/VBox/StatsView/KeyLabel
@onready var _quickcycle_label: Label = $Panel/VBox/StatsView/QuickcycleLabel
@onready var _play_again_button: Button = $Panel/VBox/StatsView/ButtonRow/PlayAgainButton
@onready var _quit_button: Button = $Panel/VBox/StatsView/ButtonRow/QuitButton
@onready var _confirm_button: Button = $Panel/VBox/ConfirmView/ConfirmRow/ConfirmButton
@onready var _cancel_button: Button = $Panel/VBox/ConfirmView/ConfirmRow/CancelButton

var _pause_was_pressed: bool = false


func _ready() -> void:
	layer = 25
	_play_again_button.pressed.connect(_on_play_again_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	_refresh_stats()
	_show_stats_view()
	_play_again_button.grab_focus()


## Polled by hand (see WorkbenchPanel/SwapConfirm's identical comment): only
## meaningful while the confirm sub-view is showing, where `pause` cancels
## back to the stats view exactly like a Decline button.
func _physics_process(_delta: float) -> void:
	var pressed := Input.is_action_pressed("pause")
	if pressed and not _pause_was_pressed and _confirm_view.visible:
		_on_cancel_pressed()
	_pause_was_pressed = pressed


func _refresh_stats() -> void:
	if Session == null:
		return
	var seconds := float(Session.run_meta.get("active_seconds", 0.0))
	_time_label.text = "Active play time: %s" % _format_time(seconds)
	_chips_label.text = "Microchips found: %d / 65" % Session.chips_found()
	_key_label.text = "Lockout Notice: %s" % ("Found" if Session.has_evidence("EF01") else "Not found")
	_quickcycle_label.text = "Quickcycle: %s" % ("Obtained" if Session.weapon_stage("W01") >= 1 else "Not obtained")


static func _format_time(seconds: float) -> String:
	var total := int(round(seconds))
	return "%d:%02d" % [total / 60, total % 60]


func _show_stats_view() -> void:
	_stats_view.visible = true
	_confirm_view.visible = false


func _show_confirm_view() -> void:
	_stats_view.visible = false
	_confirm_view.visible = true
	_cancel_button.grab_focus()


func _on_play_again_pressed() -> void:
	_play_sfx(&"ui_move")
	_show_confirm_view()


func _on_cancel_pressed() -> void:
	_play_sfx(&"ui_back")
	_show_stats_view()
	_play_again_button.grab_focus()


func _on_confirm_pressed() -> void:
	_play_sfx(&"ui_confirm")
	play_again_confirmed.emit()


func _on_quit_pressed() -> void:
	_play_sfx(&"ui_back")
	quit_requested.emit()


func _play_sfx(cue: StringName) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue)
