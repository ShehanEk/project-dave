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
@onready var _rank_label: Label = $Panel/VBox/StatsView/RankLabel
@onready var _best_label: Label = $Panel/VBox/StatsView/BestLabel
@onready var _adam_label: Label = $Panel/VBox/StatsView/AdamLabel

## C53 debrief: a rank from time, chips and the evidence file (points, 5 at most), the best run
## kept beside the save, and a line from Adam that points on to Level 2. Ranks by points:
const RANKS := {5: "S", 4: "A", 3: "B", 2: "C"}
const RANK_FAST_SECONDS := 240.0
const RANK_OK_SECONDS := 360.0
const ADAM_LINE := "Adam: \u201CYou got out of the depot, Dave. Eon City is bigger than one building, and every gate in it answers to me.\u201D"

## The rank shown and whether this run beat the stored best (tests read these).
var rank := ""
var new_best := false
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
	var fitted: Array[String] = []
	if Session.weapon_stage("W01") >= 1:
		fitted.append("Quickcycle")
	if Session.weapon_stage(Session.PLATING_TYPE) >= 1:
		fitted.append("Scrap Plating")
	_quickcycle_label.text = "Upgrades: %s" % (", ".join(fitted) if not fitted.is_empty() else "none")
	var points := rank_points(seconds, Session.chips_found(), Session.has_evidence("EF01"))
	rank = rank_for(points)
	_rank_label.text = "Rank: %s" % rank
	_best_label.text = _update_best(points, seconds)
	_adam_label.text = ADAM_LINE


## Time (up to 2), chips (up to 2) and the evidence file (1).
static func rank_points(seconds: float, chips: int, evidence: bool) -> int:
	var p := 0
	if seconds > 0.0 and seconds <= RANK_FAST_SECONDS:
		p += 2
	elif seconds > 0.0 and seconds <= RANK_OK_SECONDS:
		p += 1
	if chips >= 65:
		p += 2
	elif chips >= 50:
		p += 1
	if evidence:
		p += 1
	return p


static func rank_for(points: int) -> String:
	return RANKS.get(clampi(points, 0, 5), "D")


## Compares with the stored best (more points, then less time) and keeps the better one.
func _update_best(points: int, seconds: float) -> String:
	var cs := get_node_or_null("/root/CheckpointService")
	if cs == null:
		return ""
	var best: Dictionary = cs.load_records()
	var better := best.is_empty() or points > int(best.get("points", -1)) \
			or (points == int(best.get("points", -1)) and seconds < float(best.get("seconds", INF)))
	if better and seconds > 0.0:
		new_best = not best.is_empty()
		cs.save_records({"points": points, "seconds": seconds, "rank": rank_for(points)})
		return "New best!" if new_best else "First clear. Beat it: S needs every chip, the file and under %s." % _format_time(RANK_FAST_SECONDS)
	return "Best: %s in %s" % [String(best.get("rank", "?")), _format_time(float(best.get("seconds", 0.0)))]


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
