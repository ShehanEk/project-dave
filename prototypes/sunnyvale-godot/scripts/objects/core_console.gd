class_name CoreConsole
extends Interactable
## L01-SC01, the depot's fixed power-core housing (story-scenes.md "Opening
## treatment — SC01"; 03-gameplay-systems.md "Story states and UI").
## Prerequisites (naturally satisfied by A05's own design: 0 encounters, the
## console only reachable while safe in the depot): hero in the depot, no
## active encounter, `awakening_done` false.
##
## Ordinary interact on the release latch starts a ~19s noninteractive beat
## (side camera unchanged — "hold the usual side camera" per the treatment,
## so no camera code lives here): hero input disabled, a ward-circuits
## warning, the safety interlock visibly locking the housing, a subtitled
## exchange (Rook / EDEN / Rook) on the shared `SubtitlePanel` (group
## "subtitle_panel"; absent in isolated tests, in which case dialogue is
## silently skipped but timing/state are unchanged), then EDEN's containment
## order. The core NEVER leaves its mount and never gains a face/limbs/
## personality — only this fixed prop's own drawn phase changes.
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
## story flag itself is the guard, and CoreConsole never stores its own
## "have I run yet" state). If CP04's persistence fails, the in-memory story
## state (flags/objective) is deliberately kept live-but-uncommitted — the
## same "kept in memory only" contract every other commit already has — and
## retried at the next successful `Session.commit()` from anywhere; nothing
## here retries on its own.

const OUTLINE := Color("#332a20")  # warm charcoal (C11 contour, M6)
const HOUSING := Color("#6b7b7d")
const HOUSING_TOP := Color("#9db0b2")
const CONSOLE_BODY := Color("#365d62")
const SCREEN_OFF := Color("#4a4a52")
const SCREEN_ON := Color("#8fe0c9")
const WARNING_COLOR := Color("#e0a83f")
const LOCK_COLOR := Color("#c9663f")

## Approximate total watch-through duration (story-scenes.md "approximately
## 20 seconds"): 3.0 (warning) + 2.5 (interlock locks) + 3.0/4.0/2.5 (the
## three subtitle lines) + 4.0 (containment/hatch, held so it reads before
## control returns) = 19.0s.
const T_WARNING := 3.0
const T_LOCKED := 2.5
const T_LINE_1 := 3.0
const T_LINE_2 := 4.0
const T_LINE_3 := 2.5
const T_CONTAINMENT := 4.0

@onready var _toast: ToastLabel = get_node_or_null("Toast")

## Drawn phase: "idle" (undisturbed), "warning" (ward circuits active),
## "locked" (interlock has sealed the housing), "awake" (post-awakening,
## matches the old M3 stub's screen-on look).
var _phase: String = "idle"
var _scene_running: bool = false


func _init() -> void:
	super()
	entity_id = "L01-SC01"
	prompt = "Interact"


func _ready() -> void:
	if Session and Session.get_story("awakening_done"):
		_phase = "awake"
	queue_redraw()


func can_interact(_hero: Node) -> bool:
	return not _scene_running


func interact(hero: Node) -> void:
	super(hero)
	if Session == null or _scene_running:
		return
	if Session.get_story("awakening_done"):
		if _toast:
			_toast.show_message("Core housing: sealed and installed.")
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
	_phase = "warning"
	queue_redraw()
	if subtitles:
		# story-scenes.md SC01 "a warning labels the core's ward circuits as
		# active" — a system line (empty speaker), distinct from the Rook/
		# EDEN exchange that follows once the interlock has already locked.
		subtitles.say("", "WARNING: Ward circuits active.")
	Audio.play_sfx(&"alarm", global_position)
	skipped = await _hold(T_WARNING)
	if subtitles:
		subtitles.clear_line()

	if not skipped:
		_phase = "locked"
		queue_redraw()
		skipped = await _hold(T_LOCKED)

	if not skipped and subtitles:
		subtitles.say("Rook", "Worth a fortune.")
		skipped = await _hold(T_LINE_1)
	if not skipped and subtitles:
		subtitles.say("EDEN", "Unregistered resident. Care has been scheduled.")
		Audio.play_sfx(&"eden_chime", global_position)
		skipped = await _hold(T_LINE_2)
	if not skipped and subtitles:
		subtitles.say("Rook", "That sounds expensive.")
		skipped = await _hold(T_LINE_3)
	if subtitles:
		subtitles.clear_line()

	# Completion and skip both land here, identically (T16).
	var ok := _finish_awakening()
	if telemetry:
		telemetry.sc01_end(skipped)
	_phase = "awake"
	queue_redraw()
	if _toast:
		_toast.show_message("EDEN awakens. The hatch is open." if ok else
				BenchPanel.save_failed_message())

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


## Waits up to `seconds`, polled once per physics frame (never idle
## `_process` — see CONVENTIONS.md's dialog-polling note: `Input.
## action_press()`, how RouteBot and every test drive input, never dispatches
## a real input event, and idle `_process` is throttled under a fixed-fps
## test run). Returns true the instant `skip` reads pressed.
##
## `pause` is deliberately NOT checked here (ADV-01): story-scenes.md
## distinguishes "Pause suspends scene playback" from "skip [applies] the
## same completed story state... it never awards extra gems" — pause now
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
	# Floor-mounted core housing: no face/limbs, a bolted domed block. The
	# core itself never moves or changes shape — only the tint/overlay below
	# (and the console screen) reflects the current phase.
	draw_rect(Rect2(Vector2(-40.0, -46.0), Vector2(80.0, 46.0)), HOUSING)
	draw_rect(Rect2(Vector2(-40.0, -52.0), Vector2(80.0, 10.0)), HOUSING_TOP)
	match _phase:
		"warning":
			draw_rect(Rect2(Vector2(-40.0, -46.0), Vector2(80.0, 46.0)), Color(WARNING_COLOR, 0.35))
		"locked", "awake":
			draw_rect(Rect2(Vector2(-40.0, -46.0), Vector2(80.0, 46.0)), Color(LOCK_COLOR, 0.20))
	draw_rect(Rect2(Vector2(-40.0, -46.0), Vector2(80.0, 46.0)), OUTLINE, false, 3.0)
	for bx in [-32.0, 32.0]:
		draw_circle(Vector2(bx, -8.0), 3.0, OUTLINE)
	if _phase == "warning":
		# Small pulsing-style warning triangle above the housing.
		var tri := PackedVector2Array([Vector2(0.0, -70.0), Vector2(-9.0, -56.0), Vector2(9.0, -56.0)])
		draw_colored_polygon(tri, WARNING_COLOR)
		draw_polyline(tri, OUTLINE, 2.0, true)
	elif _phase == "locked" or _phase == "awake":
		# A small visible padlock on the housing front, per the treatment's
		# "safety interlock locks the housing (visible lock)".
		draw_rect(Rect2(Vector2(-7.0, -34.0), Vector2(14.0, 12.0)), LOCK_COLOR)
		draw_arc(Vector2(0.0, -34.0), 6.0, PI, TAU, 10, LOCK_COLOR, 2.5)
		draw_rect(Rect2(Vector2(-7.0, -34.0), Vector2(14.0, 12.0)), OUTLINE, false, 1.5)
	# Console beside it.
	draw_rect(Rect2(Vector2(48.0, -34.0), Vector2(30.0, 34.0)), CONSOLE_BODY)
	draw_rect(Rect2(Vector2(52.0, -28.0), Vector2(22.0, 12.0)), SCREEN_ON if _phase == "awake" else SCREEN_OFF)
	draw_rect(Rect2(Vector2(48.0, -34.0), Vector2(30.0, 34.0)), OUTLINE, false, 2.0)
