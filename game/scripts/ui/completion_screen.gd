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
##
## Per level (M1, C61): the title, chip total, evidence file, rank times, Adam's
## line and the "Next" line come from `level_def` (set by LevelDirector, else
## Session's current level). When the level has a registered next level, a
## Continue button (focused first) emits `next_level_confirmed`; LevelDirector
## passes it on to Main, which saves the next level's first checkpoint and
## loads it. The best-run record is kept per level.

signal play_again_confirmed
signal next_level_confirmed
signal quit_requested

## The finished level. Set before add_child(); null = Session's current level.
var level_def: LevelDef = null

@onready var _stats_view: VBoxContainer = $Panel/VBox/StatsView
@onready var _confirm_view: VBoxContainer = $Panel/VBox/ConfirmView
@onready var _time_label: Label = $Panel/VBox/StatsView/TimeLabel
@onready var _chips_label: Label = $Panel/VBox/StatsView/ChipsLabel
@onready var _key_label: Label = $Panel/VBox/StatsView/KeyLabel
@onready var _quickcycle_label: Label = $Panel/VBox/StatsView/QuickcycleLabel
@onready var _rank_label: Label = $Panel/VBox/StatsView/RankLabel
@onready var _best_label: Label = $Panel/VBox/StatsView/BestLabel
@onready var _adam_label: Label = $Panel/VBox/StatsView/AdamLabel
@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _next_label: Label = $Panel/VBox/StatsView/NextLabel

## C53 debrief: a rank from time, chips and the evidence file (points, 5 at most), the best run
## kept beside the save, and a line from Adam (the LevelDef's `completion_line`) that points on
## to the next level. Ranks by points:
const RANKS := {5: "S", 4: "A", 3: "B", 2: "C"}
## Level 1's rank times (l01.tres `rank_fast_seconds`/`rank_ok_seconds`), the defaults.
const RANK_FAST_SECONDS := 240.0
const RANK_OK_SECONDS := 360.0
## Level 1's microchip total (l01.tres `chip_total`), the default; 50 of 65 earns one point.
const CHIP_TOTAL := 65

## The rank shown and whether this run beat the stored best (tests read these).
var rank := ""
var new_best := false
@onready var _next_button: Button = $Panel/VBox/StatsView/ButtonRow/NextButton
@onready var _play_again_button: Button = $Panel/VBox/StatsView/ButtonRow/PlayAgainButton
@onready var _quit_button: Button = $Panel/VBox/StatsView/ButtonRow/QuitButton
@onready var _confirm_button: Button = $Panel/VBox/ConfirmView/ConfirmRow/ConfirmButton
@onready var _cancel_button: Button = $Panel/VBox/ConfirmView/ConfirmRow/CancelButton

var _pause_was_pressed: bool = false


func _ready() -> void:
	layer = 25
	if level_def == null and Session:
		level_def = Session.current_level_def()
	_next_button.pressed.connect(_on_next_pressed)
	_play_again_button.pressed.connect(_on_play_again_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	_refresh_stats()
	_refresh_next()
	_show_stats_view()
	_default_button().grab_focus()


## The level after this one, or null when the campaign ends here for now.
func next_level_def() -> LevelDef:
	if level_def == null:
		return null
	var next_id := LevelDefs.next_of(level_def.id)
	return LevelDefs.get_def(next_id) if next_id != "" else null


## "Next: Level 2, Alignment" and the Continue button, only when there is a next level.
func _refresh_next() -> void:
	var next := next_level_def()
	_next_button.visible = next != null
	_next_label.visible = next != null
	if next:
		_next_label.text = "Next: Level %d, %s" % [next.number, next.display_name]


## Continue when there is a next level, else Play again.
func _default_button() -> Button:
	return _next_button if _next_button.visible else _play_again_button


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
	var def := level_def if level_def else Session.current_level_def()
	var seconds := float(Session.run_meta.get("active_seconds", 0.0))
	if def.objective_complete != "":
		_title_label.text = def.objective_complete
	_time_label.text = "Active play time: %s" % _format_time(seconds)
	_chips_label.visible = def.chip_total > 0
	_chips_label.text = "Microchips found: %d / %d" % [Session.chips_found(), def.chip_total]
	var has_file := def.evidence_id != "" and Session.has_evidence(def.evidence_id)
	_key_label.visible = def.evidence_id != ""
	_key_label.text = "%s: %s" % [def.evidence_name, "Found" if has_file else "Not found"]
	var fitted: Array[String] = []
	if Session.weapon_stage("W01") >= 1:
		fitted.append("Quickcycle")
	if Session.weapon_stage(Session.PLATING_TYPE) >= 1:
		fitted.append("Scrap Plating")
	_quickcycle_label.text = "Upgrades: %s" % (", ".join(fitted) if not fitted.is_empty() else "none")
	var points := rank_points(seconds, Session.chips_found(), has_file,
			def.chip_total, def.rank_fast_seconds, def.rank_ok_seconds)
	rank = rank_for(points)
	_rank_label.text = "Rank: %s" % rank
	_best_label.text = _update_best(points, seconds, def)
	_adam_label.visible = def.completion_line != ""
	_adam_label.text = def.completion_line


## Time (up to 2), chips (up to 2) and the evidence file (1). The defaults are
## Level 1's; a level without chips gives no chip points.
static func rank_points(seconds: float, chips: int, evidence: bool, chip_total: int = CHIP_TOTAL,
		fast_seconds: float = RANK_FAST_SECONDS, ok_seconds: float = RANK_OK_SECONDS) -> int:
	var p := 0
	if seconds > 0.0 and seconds <= fast_seconds:
		p += 2
	elif seconds > 0.0 and seconds <= ok_seconds:
		p += 1
	if chip_total > 0:
		if chips >= chip_total:
			p += 2
		elif chips >= int(ceil(chip_total * 50.0 / 65.0)):
			p += 1
	if evidence:
		p += 1
	return p


static func rank_for(points: int) -> String:
	return RANKS.get(clampi(points, 0, 5), "D")


## Compares with the level's stored best (more points, then less time) and keeps the better one.
func _update_best(points: int, seconds: float, def: LevelDef) -> String:
	var cs := get_node_or_null("/root/CheckpointService")
	if cs == null:
		return ""
	var best: Dictionary = cs.load_records(def.id)
	var better := best.is_empty() or points > int(best.get("points", -1)) \
			or (points == int(best.get("points", -1)) and seconds < float(best.get("seconds", INF)))
	if better and seconds > 0.0:
		new_best = not best.is_empty()
		cs.save_records({"points": points, "seconds": seconds, "rank": rank_for(points)}, def.id)
		return "New best!" if new_best else "First clear. Beat it: S needs every chip, the file and under %s." % _format_time(def.rank_fast_seconds)
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


func _on_next_pressed() -> void:
	_play_sfx(&"ui_confirm")
	next_level_confirmed.emit()


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
