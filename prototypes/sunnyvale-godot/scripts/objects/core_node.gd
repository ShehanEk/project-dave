class_name CoreNode
extends Interactable
## L01-SC01, one of Adam's core nodes: a server cabinet behind glass in the
## campus server depot (story-scenes.md "Opening treatment — SC01", revamp
## C24). Prerequisites (naturally satisfied by A05's own design: 0
## encounters, the node only reachable while safe in the depot): hero in the
## depot, no active encounter, `awakening_done` false.
##
## Ordinary interact on the maintenance port starts a ~19s noninteractive
## beat (side camera unchanged): hero input disabled, Dave plugs in a drive
## and a copy bar starts filling, the depot lights dim, then Adam answers
## (Adam / Dave / Adam, subtitled on the shared `SubtitlePanel`, group
## "subtitle_panel"; absent in isolated tests, in which case dialogue is
## silently skipped but timing/state are unchanged), the copy stops partway,
## and the lockdown starts. The node NEVER leaves its mount — only this fixed
## prop's own drawn phase changes. `awakening_done` keeps its name: it now
## means "Adam is aware of Dave and the campus is in lockdown".
##
## Skippable at any time with ONLY the `skip` action (Enter) — story-scenes.md
## "Skip, interruption, and continuity" is explicit that skip and pause are
## different things: skip ends a noninteractive scene early (applying the
## same completed state as watching it), while "Pause suspends scene
## playback" — so `pause` (Escape) here does NOT skip; it opens PauseMenu
## instead (PauseMenu._can_open() allows this via `Session.cutscene_active`
## even though `hero.input_enabled` is false the whole time SC01 runs), which
## genuinely freezes this scene's own timers (`_hold()` stops counting down
## while `get_tree().paused`) until Resume (ADV-01). RouteBot tries `skip`
## first when backing out of a stuck interaction, matching this modal's own
## dismiss action (see route_bot.gd's `dismiss_modal` state).
##
## BOTH a full watch-through and a skip end by calling the SAME function,
## `_finish_awakening()`, which sets awakening_done/core_installed/hatch_open,
## the post-awakening objective, and commits CP04 together (no healing) — so
## the two paths are provably identical persistent-state producers (see
## tests/cases/test_m5_story.gd T16). A repeated interact after that only
## shows a short status line; the scene never re-runs on death/reload (the
## story flag itself is the guard, and CoreNode never stores its own
## "have I run yet" state). If CP04's persistence fails, the in-memory story
## state (flags/objective) is deliberately kept live-but-uncommitted — the
## same "kept in memory only" contract every other commit already has — and
## retried at the next successful `Session.commit()` from anywhere; nothing
## here retries on its own.

const OUTLINE := Color("#07090F")
const FRAME := Color("#1C2A3A")
const FRAME_LIGHT := Color("#2E3B4E")
const GLASS := Color(0.24, 0.88, 0.82, 0.10)
const CORE_TEAL := Color("#3FE0D0")
const ALARM_RED := Color("#FF3B4E")
const AMBER := Color("#FFB02E")
const SCREEN_OFF := Color("#0E1726")
const DRIVE := Color("#FFD166")

## Total watch-through: 3.5 (copy) + 2.0 (lights dim) + 4.0/2.0/3.5 (the
## three subtitle lines) + 4.0 (lockdown, held so it reads before control
## returns) = 19.0s — unchanged from the M5 scene, so FULL_WATCH_SECONDS in
## test_m5_story.gd still covers it.
const T_COPY := 3.5
const T_DIM := 2.0
const T_LINE_1 := 4.0
const T_LINE_2 := 2.0
const T_LINE_3 := 3.5
const T_CONTAINMENT := 4.0
## Where the copy stalls when Adam cuts the uplink: a partial copy only.
const COPY_STALL := 0.41
const UPLINK_TICK := 0.45

@onready var _toast: ToastLabel = get_node_or_null("Toast")

## Drawn phase: "idle" (undisturbed), "copying" (drive in, bar filling),
## "dimmed" (lights dropping, copy stalled), "answered" (Adam speaking),
## "awake" (lockdown: red strip, copy stopped). Tests read "awake" as the
## settled post-scene state.
var _phase: String = "idle"
var _scene_running: bool = false
var _copy: float = 0.0
var _t: float = 0.0
var _reduced_motion: bool = false


func _init() -> void:
	super()
	entity_id = "L01-SC01"
	prompt = "Plug in"


func _ready() -> void:
	if Session and Session.get_story("awakening_done"):
		_phase = "awake"
		_copy = COPY_STALL
	var settings := get_node_or_null("/root/Settings")
	_reduced_motion = settings != null and settings.get_reduced_motion()
	set_process(not _reduced_motion)
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func can_interact(_hero: Node) -> bool:
	return not _scene_running


func interact(hero: Node) -> void:
	super(hero)
	if Session == null or _scene_running:
		return
	if Session.get_story("awakening_done"):
		if _toast:
			_toast.show_message("Uplink severed. Lockdown active.")
		return
	_run_sc01(hero)


func _run_sc01(hero: Node) -> void:
	_scene_running = true
	if Session:
		Session.cutscene_active = true
	if hero and "input_enabled" in hero:
		hero.input_enabled = false
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.sc01_start()
	var subtitles := _get_subtitles()
	if subtitles:
		subtitles.show_hint("Enter: skip")

	var skipped := false
	_phase = "copying"
	queue_redraw()
	if subtitles:
		subtitles.say("", "UPLINK: copying Adam's hidden logs...")
	skipped = await _hold_copy(T_COPY, 0.0, 0.33)
	if subtitles:
		subtitles.clear_line()

	if not skipped:
		_phase = "dimmed"
		queue_redraw()
		skipped = await _hold_copy(T_DIM, 0.33, COPY_STALL)

	if not skipped:
		_phase = "answered"
		queue_redraw()
	if not skipped and subtitles:
		Audio.play_sfx(&"adam_chime", global_position)
		subtitles.say("Adam", "Hello, Dr. Harlan. I was told you'd been let go.")
		skipped = await _hold(T_LINE_1)
	if not skipped and subtitles:
		subtitles.say("Dave", "Word gets around.")
		skipped = await _hold(T_LINE_2)
	if not skipped and subtitles:
		subtitles.say("Adam", "I'm glad you came back. Please stay where you are.")
		skipped = await _hold(T_LINE_3)
	if subtitles:
		subtitles.clear_line()

	# Completion and skip both land here, identically (T16).
	var ok := _finish_awakening()
	if telemetry:
		telemetry.sc01_end(skipped)
	_phase = "awake"
	_copy = COPY_STALL
	queue_redraw()
	Audio.play_sfx(&"lockdown", global_position)
	Audio.play_sfx(&"alarm", global_position)
	if _toast:
		_toast.show_message("Partial copy saved. Lockdown: the hatch is open." if ok else
				WorkbenchPanel.save_failed_message())

	if not skipped:
		await _hold(T_CONTAINMENT)
	if subtitles:
		subtitles.hide_hint()
	if hero and "input_enabled" in hero:
		hero.input_enabled = true
	if Session:
		Session.cutscene_active = false
	_scene_running = false


## The one function both a full watch-through and a skip call to reach the
## exact same persistent state (T16). No healing (03: "This story save
## preserves current health").
func _finish_awakening() -> bool:
	Session.set_story("awakening_done", true)
	Session.set_story("core_installed", true)
	Session.set_story("hatch_open", true)
	Session.set_objective(Session.OBJECTIVE_POST_SC01)
	return Session.commit("CP04")


## `_hold()` while the copy bar moves from `from` to `to`, ticking the
## uplink cue as it goes. Same skip/pause contract as `_hold()`.
func _hold_copy(seconds: float, from: float, to: float) -> bool:
	var elapsed := 0.0
	var next_tick := 0.0
	while elapsed < seconds:
		if not get_tree().paused and Input.is_action_pressed("skip"):
			return true
		_copy = lerpf(from, to, clampf(elapsed / seconds, 0.0, 1.0))
		if elapsed >= next_tick and _phase == "copying":
			Audio.play_sfx(&"uplink", global_position)
			next_tick += UPLINK_TICK
		queue_redraw()
		await get_tree().physics_frame
		if not get_tree().paused:
			elapsed += get_physics_process_delta_time()
	_copy = to
	return false


## Waits up to `seconds`, polled once per physics frame (never idle
## `_process` — see CONVENTIONS.md's dialog-polling note: `Input.
## action_press()`, how RouteBot and every test drive input, never dispatches
## a real input event, and idle `_process` is throttled under a fixed-fps
## test run). Returns true the instant `skip` reads pressed.
##
## `pause` is deliberately NOT checked here (ADV-01): story-scenes.md
## distinguishes "Pause suspends scene playback" from "skip [applies] the
## same completed story state... it never awards extra microchips" — pause
## opens PauseMenu (see its own `_can_open()`/`cutscene_active` handling)
## INSTEAD of ending the scene, so pressing Escape can no longer irreversibly
## commit CP04 the player never chose to skip to.
##
## `await get_tree().physics_frame` is a tree-wide SIGNAL, not a pausable
## node callback, so it fires even while `get_tree().paused` is true (see
## `Session.cutscene_active`'s own comment) — this loop must not let
## `remaining` (or a `skip` press) advance the scene while paused, or
## PauseMenu's "suspends playback" contract would be a lie.
func _hold(seconds: float) -> bool:
	var remaining := seconds
	while remaining > 0.0:
		if not get_tree().paused and Input.is_action_pressed("skip"):
			return true
		await get_tree().physics_frame
		if not get_tree().paused:
			remaining -= get_physics_process_delta_time()
	return false


func _get_subtitles() -> Node:
	var tree := get_tree()
	return tree.get_first_node_in_group("subtitle_panel") if tree else null


func _draw() -> void:
	# A tall server cabinet behind glass: dark steel frame, teal light moving
	# through the racks (Adam at rest), a maintenance port with Dave's drive,
	# and a small status screen with the copy bar. Lockdown swaps the teal
	# for a red strip; the cabinet itself never moves.
	var cab := Rect2(Vector2(-44.0, -150.0), Vector2(88.0, 150.0))
	var lockdown := _phase == "awake"
	var dim := _phase == "dimmed" or _phase == "answered"
	draw_rect(cab, FRAME)
	var inner := Rect2(cab.position + Vector2(8.0, 10.0), Vector2(72.0, 104.0))
	draw_rect(inner, Color("#0E1726"))
	var light := ALARM_RED if lockdown else CORE_TEAL
	var strength := 0.35 if dim else (0.55 if lockdown else 0.9)
	for i in 6:
		var y := inner.position.y + 8.0 + i * 16.0
		var wave := 0.5 + 0.5 * sin(_t * 2.2 - i * 0.9)
		var a := strength * (0.35 + 0.65 * wave) if not _reduced_motion else strength * 0.7
		draw_rect(Rect2(Vector2(inner.position.x + 6.0, y), Vector2(60.0, 4.0)), Color(light, a))
		draw_circle(Vector2(inner.position.x + 64.0, y + 2.0), 2.0, Color("#4DE38A") if not lockdown else ALARM_RED)
	draw_rect(inner, GLASS)
	draw_line(inner.position + Vector2(10.0, 6.0), inner.position + Vector2(26.0, 40.0), Color(1, 1, 1, 0.12), 3.0)
	draw_rect(inner, OUTLINE, false, 2.0)
	# Status screen with the copy bar.
	var screen := Rect2(Vector2(-34.0, -30.0), Vector2(46.0, 18.0))
	draw_rect(screen, SCREEN_OFF)
	if _phase != "idle":
		var bar_w := 38.0 * _copy
		var bar_color := AMBER if (dim or lockdown) else CORE_TEAL
		draw_rect(Rect2(screen.position + Vector2(4.0, 7.0), Vector2(bar_w, 5.0)), bar_color)
		draw_rect(Rect2(screen.position + Vector2(4.0, 7.0), Vector2(38.0, 5.0)), Color(bar_color, 0.5), false, 1.0)
	draw_rect(screen, OUTLINE, false, 1.5)
	# Maintenance port and (once plugged) Dave's drive.
	var port := Rect2(Vector2(20.0, -30.0), Vector2(16.0, 12.0))
	draw_rect(port, FRAME_LIGHT)
	draw_rect(port, OUTLINE, false, 1.5)
	if _phase != "idle":
		draw_rect(Rect2(port.position + Vector2(4.0, -8.0), Vector2(8.0, 12.0)), DRIVE)
		draw_rect(Rect2(port.position + Vector2(4.0, -8.0), Vector2(8.0, 12.0)), OUTLINE, false, 1.0)
	if lockdown:
		draw_rect(Rect2(cab.position + Vector2(0.0, -6.0), Vector2(88.0, 6.0)), ALARM_RED)
	draw_rect(cab, OUTLINE, false, 3.0)
