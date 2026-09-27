class_name PauseMenu
extends CanvasLayer
## Pause menu (M5 part 2; interface-and-accessibility.md "Pause shows
## Continue, Settings, Journal, Restart from checkpoint, and Quit").
## Added once by LevelDirector, alongside the Hud it never recreates
## (`setup(hero)` right after instancing). `process_mode = PROCESS_MODE_ALWAYS`
## so this node keeps polling input while `get_tree().paused` is true — every
## OTHER node in the level (Hero, enemies, LevelDirector's own
## `_physics_process` that ticks `Session.tick_active_time`) uses the default
## pausable process mode, so simply setting `get_tree().paused = true` already
## stops gameplay/enemies/timers/active-time accrual with no extra plumbing
## (per `Session.tick_active_time()`'s own doc comment, this is exactly the
## "gate on hero.input_enabled, or just don't run while paused" it asks for).
##
## Opens only from actual gameplay (`hero.input_enabled == true` and the tree
## not already paused) — this is what keeps `pause` from fighting every OTHER
## thing that already treats `pause` as its own dismiss/skip action
## (BenchPanel/SwapConfirm/CompletionScreen's confirm-cancel, CoreConsole's
## SC01 skip): all of those already disable `hero.input_enabled` while open,
## so this menu simply never tries to open over them, and "pause IS available
## during SC01" already holds true unmodified (SC01's own skip-on-pause).
## `journal` (Tab) opens straight to the Journal view the same way.

signal restart_from_checkpoint_confirmed
signal quit_to_title_confirmed

enum View { CLOSED, MAIN, JOURNAL, RESTART_CONFIRM, QUIT_CONFIRM, SETTINGS }

## story-scenes.md/artifact-catalog.md A01 — a short (~45 word) journal entry
## written from the catalog's own description/location/meaning fields; no
## final written journal exists yet (catalog: "not yet the final written
## journal"), so this is this prototype's own first pass, kept in plain
## factual journal voice (dialogue-and-writing.md "essential information...
## plain factual language") rather than an invented Rook quip.
const A01_JOURNAL_TEXT := "Welcome Key — a palm-size cream ceramic house key, its head shaped like a smiling sun, teeth worn brass-bright from years of use. Found in a porch loft above Sunnyvale's front gardens: a resident's ordinary first day here. A keepsake, not the maintenance depot's own access credential."

## Minimum consecutive physics frames `hero.input_enabled` must have already
## been true before this menu will open. Without this, a same-tick modal
## close (BenchPanel/SwapConfirm's own "pause" poll re-enabling input the
## SAME frame RouteBot's dismiss_modal state presses "pause" to back out of
## them) can race this node's own "pause" edge detection into opening right
## on top of it — RouteBot then freezes forever (it stops processing while
## `get_tree().paused` is true, so `bot.running` never clears). Two frames
## (~33ms) is imperceptible to a player but never satisfied within one
## same-tick close, and doubles as "pause is unavailable during the few
## frames of a respawn transition" per the M5 part 2 brief, for free.
const OPEN_READY_FRAMES := 2

var _view: View = View.CLOSED
var _hero: Node = null
var _pause_was_pressed: bool = false
var _journal_was_pressed: bool = false
var _input_enabled_streak: int = 0
var _text_size_bases: Dictionary = {}  # Control -> base font size (M6 text-size setting)

@onready var _dim: ColorRect = $Dim
@onready var _panel: Panel = $Panel
@onready var _main_view: VBoxContainer = $Panel/VBox/MainView
@onready var _journal_view: VBoxContainer = $Panel/VBox/JournalView
@onready var _restart_view: VBoxContainer = $Panel/VBox/RestartConfirmView
@onready var _quit_view: VBoxContainer = $Panel/VBox/QuitConfirmView
@onready var _settings_view: VBoxContainer = $Panel/VBox/SettingsView

@onready var _resume_button: Button = $Panel/VBox/MainView/ResumeButton
@onready var _journal_button: Button = $Panel/VBox/MainView/JournalButton
@onready var _settings_button: Button = $Panel/VBox/MainView/SettingsButton
@onready var _restart_button: Button = $Panel/VBox/MainView/RestartButton
@onready var _quit_button: Button = $Panel/VBox/MainView/QuitButton

@onready var _objective_label: Label = $Panel/VBox/JournalView/ObjectiveLabel
@onready var _artifact_label: Label = $Panel/VBox/JournalView/ArtifactLabel
@onready var _journal_back_button: Button = $Panel/VBox/JournalView/BackButton

@onready var _restart_label: Label = $Panel/VBox/RestartConfirmView/WarningLabel
@onready var _restart_confirm_button: Button = $Panel/VBox/RestartConfirmView/ConfirmRow/ConfirmButton
@onready var _restart_cancel_button: Button = $Panel/VBox/RestartConfirmView/ConfirmRow/CancelButton

@onready var _quit_confirm_button: Button = $Panel/VBox/QuitConfirmView/ConfirmRow/ConfirmButton
@onready var _quit_cancel_button: Button = $Panel/VBox/QuitConfirmView/ConfirmRow/CancelButton

@onready var _subtitles_check: CheckButton = $Panel/VBox/SettingsView/SubtitlesRow/SubtitlesCheck
@onready var _text_size_option: OptionButton = $Panel/VBox/SettingsView/TextSizeRow/TextSizeOption
@onready var _reduced_motion_check: CheckButton = $Panel/VBox/SettingsView/ReducedMotionRow/ReducedMotionCheck
@onready var _master_slider: HSlider = $Panel/VBox/SettingsView/MasterRow/MasterSlider
@onready var _music_slider: HSlider = $Panel/VBox/SettingsView/MusicRow/MusicSlider
@onready var _sfx_slider: HSlider = $Panel/VBox/SettingsView/SfxRow/SfxSlider
@onready var _settings_back_button: Button = $Panel/VBox/SettingsView/BackButton


func setup(hero: Node) -> void:
	_hero = hero


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 22

	_resume_button.pressed.connect(_on_resume_pressed)
	_journal_button.pressed.connect(_on_journal_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_restart_button.pressed.connect(_on_restart_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

	_journal_back_button.pressed.connect(_back_to_main)
	_restart_confirm_button.pressed.connect(_on_restart_confirm)
	_restart_cancel_button.pressed.connect(_back_to_main)
	_quit_confirm_button.pressed.connect(_on_quit_confirm)
	_quit_cancel_button.pressed.connect(_back_to_main)
	_settings_back_button.pressed.connect(_back_to_main)

	_text_size_option.clear()
	_text_size_option.add_item("Normal", 0)
	_text_size_option.add_item("Large", 1)
	_subtitles_check.toggled.connect(_on_subtitles_toggled)
	_text_size_option.item_selected.connect(_on_text_size_selected)
	_reduced_motion_check.toggled.connect(_on_reduced_motion_toggled)
	_master_slider.value_changed.connect(_on_master_changed)
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)

	_apply_view()
	_collect_text_size_bases(_panel)
	_apply_text_size()
	var settings := get_node_or_null("/root/Settings")
	if settings and not settings.changed.is_connected(_apply_text_size):
		settings.changed.connect(_apply_text_size)


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_apply_text_size):
		settings.changed.disconnect(_apply_text_size)


## Settings "text size" (M6): captures every Label/Button/OptionButton's own
## authored font size once as its baseline so it can be scaled consistently
## without hardcoding each node's base size a second time here.
func _collect_text_size_bases(root: Node) -> void:
	for child in root.get_children():
		if child is Label or child is Button or child is OptionButton:
			_text_size_bases[child] = child.get_theme_font_size("font_size")
		_collect_text_size_bases(child)


func _apply_text_size() -> void:
	var settings := get_node_or_null("/root/Settings")
	for node in _text_size_bases:
		if is_instance_valid(node):
			var base: int = _text_size_bases[node]
			node.add_theme_font_size_override("font_size",
					settings.scaled_font_size(base) if settings else base)


func _play_sfx(cue: StringName) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue)


## Polled by hand (see BenchPanel/SwapConfirm's identical comment): `Input.
## action_press()` (RouteBot/tests) never dispatches a real input event, and
## idle `_process` can miss a same-tick press+release under a fixed-fps test
## run — and this node must keep polling while `get_tree().paused` is true,
## which idle `_process` would not do at all without PROCESS_MODE_ALWAYS.
func _physics_process(_delta: float) -> void:
	if _hero != null and is_instance_valid(_hero) and _hero.input_enabled:
		_input_enabled_streak = mini(_input_enabled_streak + 1, OPEN_READY_FRAMES)
	else:
		_input_enabled_streak = 0

	var pause_pressed := Input.is_action_pressed("pause")
	var pause_edge := pause_pressed and not _pause_was_pressed
	_pause_was_pressed = pause_pressed

	var journal_pressed := Input.is_action_pressed("journal")
	var journal_edge := journal_pressed and not _journal_was_pressed
	_journal_was_pressed = journal_pressed

	if _view == View.CLOSED:
		if pause_edge and _can_open():
			_open(View.MAIN)
		elif journal_edge and _can_open():
			_open(View.JOURNAL)
		return

	if pause_edge:
		if _view == View.MAIN:
			_resume()
		else:
			_back_to_main()


## Normally gates on the `hero.input_enabled` streak (see class doc) so this
## menu never fights a modal that already owns `pause` as its own dismiss
## action. SC01 is the one deliberate exception (ADV-01): it disables
## `hero.input_enabled` for its ENTIRE ~19s run and does not itself treat
## `pause` as a dismiss action any more (only `skip` ends it) — Session.
## `cutscene_active` (set only around that one coroutine) is what lets `pause`
## open this menu and genuinely suspend the scene instead, honoring
## story-scenes.md's "Pause suspends scene playback" for the project's one
## noninteractive scene.
func _can_open() -> bool:
	if get_tree().paused:
		return false
	if _input_enabled_streak >= OPEN_READY_FRAMES:
		return true
	return Session != null and Session.cutscene_active


func _open(view: View) -> void:
	get_tree().paused = true
	_view = view
	_refresh_journal()
	_refresh_settings_controls()
	_apply_view()
	_play_sfx(&"ui_move")
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.pause_start()


func _resume() -> void:
	_view = View.CLOSED
	_apply_view()
	get_tree().paused = false
	_play_sfx(&"ui_back")
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.pause_end()


func _back_to_main() -> void:
	_view = View.MAIN
	_apply_view()
	_play_sfx(&"ui_back")


func _apply_view() -> void:
	visible = _view != View.CLOSED
	_main_view.visible = _view == View.MAIN
	_journal_view.visible = _view == View.JOURNAL
	_restart_view.visible = _view == View.RESTART_CONFIRM
	_quit_view.visible = _view == View.QUIT_CONFIRM
	_settings_view.visible = _view == View.SETTINGS
	match _view:
		View.MAIN:
			_resume_button.grab_focus()
		View.JOURNAL:
			_journal_back_button.grab_focus()
		View.RESTART_CONFIRM:
			_restart_cancel_button.grab_focus()
		View.QUIT_CONFIRM:
			_quit_cancel_button.grab_focus()
		View.SETTINGS:
			_settings_back_button.grab_focus()


# --- main view ---------------------------------------------------------------

func _on_resume_pressed() -> void:
	_resume()


func _on_journal_pressed() -> void:
	_refresh_journal()
	_view = View.JOURNAL
	_apply_view()
	_play_sfx(&"ui_move")


func _on_settings_pressed() -> void:
	_refresh_settings_controls()
	_view = View.SETTINGS
	_apply_view()
	_play_sfx(&"ui_move")


func _on_restart_pressed() -> void:
	if Session:
		_restart_label.text = ("Restart from checkpoint %s? Progress since then will be lost." %
				String(Session.state.get("checkpoint_id", "CP00")))
	_view = View.RESTART_CONFIRM
	_apply_view()
	_play_sfx(&"ui_move")


func _on_quit_pressed() -> void:
	_view = View.QUIT_CONFIRM
	_apply_view()
	_play_sfx(&"ui_move")


# --- journal -------------------------------------------------------------------

func _refresh_journal() -> void:
	if Session == null:
		return
	_objective_label.text = "Objective: %s" % Session.get_objective()
	if Session.has_artifact("A01"):
		_artifact_label.text = A01_JOURNAL_TEXT
	else:
		_artifact_label.text = "Artifacts: 1 undiscovered."


# --- restart / quit confirms ---------------------------------------------------

func _on_restart_confirm() -> void:
	_view = View.CLOSED
	_apply_view()
	get_tree().paused = false
	_play_sfx(&"ui_confirm")
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.pause_end()
	restart_from_checkpoint_confirmed.emit()


func _on_quit_confirm() -> void:
	_view = View.CLOSED
	_apply_view()
	get_tree().paused = false
	_play_sfx(&"ui_confirm")
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.pause_end()
	quit_to_title_confirmed.emit()


# --- settings --------------------------------------------------------------------

func _refresh_settings_controls() -> void:
	var s := get_node_or_null("/root/Settings")
	if s == null:
		return
	_subtitles_check.button_pressed = s.get_subtitles_enabled()
	_text_size_option.selected = 1 if s.get_text_size() == s.TEXT_SIZE_LARGE else 0
	_reduced_motion_check.button_pressed = s.get_reduced_motion()
	_master_slider.value = s.get_master_volume()
	_music_slider.value = s.get_music_volume()
	_sfx_slider.value = s.get_sfx_volume()


func _on_subtitles_toggled(pressed: bool) -> void:
	var s := get_node_or_null("/root/Settings")
	if s:
		s.set_subtitles_enabled(pressed)
	_play_sfx(&"ui_move")


func _on_text_size_selected(index: int) -> void:
	var s := get_node_or_null("/root/Settings")
	if s:
		s.set_text_size(s.TEXT_SIZE_LARGE if index == 1 else s.TEXT_SIZE_NORMAL)
	_play_sfx(&"ui_move")


func _on_reduced_motion_toggled(pressed: bool) -> void:
	var s := get_node_or_null("/root/Settings")
	if s:
		s.set_reduced_motion(pressed)
	_play_sfx(&"ui_move")


func _on_master_changed(value: float) -> void:
	var s := get_node_or_null("/root/Settings")
	if s:
		s.set_master_volume(value)


func _on_music_changed(value: float) -> void:
	var s := get_node_or_null("/root/Settings")
	if s:
		s.set_music_volume(value)


func _on_sfx_changed(value: float) -> void:
	var s := get_node_or_null("/root/Settings")
	if s:
		s.set_sfx_volume(value)
