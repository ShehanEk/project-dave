extends Node
## M7 export-verification driver ONLY — see reports/export-report.md.
##
## Never reachable in the shipped release export: `scripts/main.gd` only
## ever loads/starts this script when BOTH `OS.is_debug_build()` is true
## (false for every `--export-release` build, regardless of any argument)
## AND the exact `--m7-phase=<newgame|continue>` user cmdline argument is
## present (`OS.get_cmdline_user_args()` — the same mechanism
## `tests/run_tests.gd` already uses for its own `--filter`). Launching the
## shipped release .exe/.app with this same flag does nothing but start an
## ordinary game — verified in reports/export-report.md.
##
## Drives the REAL game exactly as a player would: the title screen's own
## `NewGameButton`/`ContinueButton`/confirm-dialog `pressed` signals (the
## same call a mouse click makes) and the existing debug `RouteBot`, which
## itself only ever calls `Input.action_press`/`action_release` on the
## project's own named actions (move/jump/interact) — see
## `scripts/debug/route_bot.gd`. This script never calls `Session.commit`,
## `CheckpointService`, or any world-object method directly; it only reads
## `Session`/`LevelDirector` state to know when a real, player-triggered
## save/complete has happened, and to log it.
##
## Save location: `scripts/main.gd`'s own `_maybe_redirect_m7_save_dir()`
## (same debug-build + exact-argument gate) redirects `CheckpointService`/
## `Telemetry` to a throwaway folder BEFORE the title screen even reads
## `has_valid_save()`, when an extra `--m7-save-dir=user://<path>` argument is
## passed alongside `--m7-phase=...` — the exported app's real default save
## location is untouched whenever that argument is used.

const HERO_TIMEOUT := 10.0
const CHECKPOINT_TIMEOUT := 180.0
const COMPLETION_TIMEOUT := 240.0

var _phase: String = ""


func start(phase: String) -> void:
	_phase = phase
	print("[M7DRIVER] starting phase=", phase)
	call_deferred("_run")


func _run() -> void:
	match _phase:
		"newgame":
			await _run_newgame()
		"continue":
			await _run_continue()
		_:
			print("[M7DRIVER] FAIL unknown phase '", _phase, "'")
			get_tree().quit(1)


# --- shared helpers -----------------------------------------------------

func _find_title(timeout: float = HERO_TIMEOUT) -> Control:
	var elapsed := 0.0
	while elapsed < timeout:
		var t := get_tree().root.find_child("TitleScreen", true, false)
		if t:
			return t
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	return null


func _find_level(timeout: float = HERO_TIMEOUT) -> Node:
	var elapsed := 0.0
	while elapsed < timeout:
		var lvl := get_tree().root.find_child("Level01", true, false)
		if lvl:
			return lvl
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	return null


func _log_session_state(tag: String) -> void:
	print("[M7DRIVER] ", tag,
			" checkpoint_id=", Session.state.get("checkpoint_id", "?"),
			" objective=", Session.state.get("objective", "?"),
			" health=", Session.state.get("health", "?"),
			" wallet=", Session.state.get("wallet", "?"),
			" chips_found=", Session.chips_found())


func _fail(message: String) -> void:
	print("[M7DRIVER] FAIL ", message)
	get_tree().quit(1)


# --- phase: newgame -------------------------------------------------------
# Real click on New Game (through any pre-existing-save confirm dialog),
# then drive the real route via RouteBot until the FIRST real
# Session.checkpoint_committed fires (the first recovery station's own
# `interact()` -> `Session.commit()` -> CheckpointService.save_snapshot()),
# proving a genuine gameplay checkpoint save reaches the exported app's
# real user:// location. Quits immediately after, with exit code 0.

func _run_newgame() -> void:
	var title := await _find_title()
	if title == null:
		_fail("title screen never appeared")
		return
	print("[M7DRIVER] title screen found — clicking New Game")
	var new_game_button: Button = title.get_node("Panel/VBox/MainView/ButtonRow/NewGameButton")
	new_game_button.pressed.emit()
	await get_tree().process_frame
	# A fresh save-less run transitions straight to the level in the same
	# frame (Main frees the title screen instance) — only a pre-existing
	# save routes through the confirm dialog, so the title node may already
	# be gone here; that is success, not a failure.
	if not is_instance_valid(title):
		var level_now := await _find_level()
		if level_now == null:
			_fail("level never loaded after New Game")
			return
		await _drive_newgame_route(level_now)
		return
	var confirm_view: Control = title.get_node_or_null("Panel/VBox/ConfirmView")
	if confirm_view and confirm_view.visible:
		print("[M7DRIVER] pre-existing save detected — confirming New Game overwrite")
		title.get_node("Panel/VBox/ConfirmView/ConfirmRow/ConfirmButton").pressed.emit()
		await get_tree().process_frame

	var level := await _find_level()
	if level == null:
		_fail("level never loaded after New Game")
		return
	await _drive_newgame_route(level)


func _drive_newgame_route(level: Node) -> void:
	_log_session_state("post-new-game")

	# Boxed (see the closure-value note on `completed_box` in
	# `_drive_to_completion()` below) so the outer `if not checkpoint_reached`
	# check after the polling loop reads the SAME flag this callback sets —
	# harmless today only because the success path calls `get_tree().quit()`
	# straight from the callback, before the outer loop can ever observe a
	# stale copy, but boxed now so nothing here depends on that ordering.
	var checkpoint_reached_box: Array = [false]
	Session.checkpoint_committed.connect(func(cp_id: String) -> void:
		if checkpoint_reached_box[0]:
			return
		checkpoint_reached_box[0] = true
		print("[M7DRIVER] checkpoint_committed id=", cp_id, " — real save written")
		_log_session_state("post-checkpoint")
		get_tree().quit(0)
	)

	print("[M7DRIVER] starting RouteBot toward the first checkpoint")
	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(level, [])
	bot.start(level.hero)
	bot.failed.connect(func(msg: String, _idx: int, _pos: Vector2) -> void:
		_fail("RouteBot failed before any checkpoint: %s" % msg)
	)

	var elapsed := 0.0
	while elapsed < CHECKPOINT_TIMEOUT:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	if not checkpoint_reached_box[0]:
		_fail("no checkpoint_committed within %.0fs" % CHECKPOINT_TIMEOUT)


# --- phase: continue -------------------------------------------------------
# Real click on Continue (loads whatever the "newgame" phase actually wrote
# to disk), then drives the REST of the route from wherever that checkpoint
# resumed the hero, all the way to the real ending (Session.level_completed
# + the completion screen actually showing), proving Continue restores the
# exported app's own save and that the run can finish outside the editor.

func _run_continue() -> void:
	var title := await _find_title()
	if title == null:
		_fail("title screen never appeared")
		return
	var continue_button: Button = title.get_node("Panel/VBox/MainView/ButtonRow/ContinueButton")
	if continue_button.disabled:
		_fail("Continue button disabled — no valid save found by CheckpointService")
		return
	print("[M7DRIVER] title screen found — clicking Continue")
	continue_button.pressed.emit()
	await get_tree().process_frame

	var level := await _find_level()
	if level == null:
		_fail("level never loaded after Continue")
		return
	_log_session_state("post-continue")
	var resumed_checkpoint: String = String(Session.state.get("checkpoint_id", "CP00"))
	var start_area_index: int = 0
	if LevelDirector.CHECKPOINT_MARKERS.has(resumed_checkpoint):
		start_area_index = LevelDirector.CHECKPOINT_MARKERS[resumed_checkpoint][0]
	print("[M7DRIVER] resumed at ", resumed_checkpoint, " (area index ", start_area_index, ") — driving to the end")

	# BOXED (see the identical gotcha documented in
	# tests/cases/test_m5_flow.gd/_test_invalid_save_backup_and_no_save()): a
	# GDScript lambda captures an outer local BY VALUE, so `completed = true`
	# inside the connect() callback below was reassigning only the lambda's
	# own copy — the outer `while` loop's `completed` never actually changed,
	# so this driver deterministically fell through to the timeout FAIL below
	# on every real completion, even though the log line right above it
	# ("Session.level_completed fired") proves the signal genuinely fired. A
	# one-element Array's element IS shared with the closure, so mutating
	# `completed_box[0]` here is visible to the polling loop below.
	var completed_box: Array = [false]
	Session.level_completed.connect(func() -> void:
		completed_box[0] = true
		print("[M7DRIVER] Session.level_completed fired")
	)

	var bot := RouteBot.new()
	add_child(bot)
	bot.points = []
	bot._point_areas = []
	for i in range(start_area_index, level.areas.size()):
		var area: AreaRoot = level.areas[i]
		for p in area.get_route_points([]):
			bot.points.append(p)
			bot._point_areas.append(area)
	# A checkpoint/workbench respawn marker sits partway through its own area (not
	# necessarily at that area's very first route point) — Continue resumes
	# the hero there, so any authored point still BEHIND the hero's actual
	# resume x would send RouteBot walking backward into geometry meant only
	# to be crossed forward once (a real bug this driver hit and failed on:
	# resuming at CP01 inside A02 tried to walk back to A02's own R01_Move at
	# local x=300 from the CP01 respawn at local x=5850, and got stuck).
	# Drop every leading point strictly behind the hero's resume position so
	# the bot starts from wherever the route actually continues from here.
	var resume_x: float = level.hero.global_position.x
	while bot.points.size() > 0 and (bot.points[0] as RoutePoint).global_position.x < resume_x - 4.0:
		bot.points.pop_front()
		bot._point_areas.pop_front()
	bot.start(level.hero)
	bot.failed.connect(func(msg: String, _idx: int, _pos: Vector2) -> void:
		_fail("RouteBot failed en route to completion: %s" % msg)
	)

	var elapsed := 0.0
	while elapsed < COMPLETION_TIMEOUT:
		if completed_box[0]:
			await _finish_completion()
			return
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	# One more check: `completed_box[0]` can flip true during that very last
	# `await` right as `elapsed` crosses the timeout, so recheck once before
	# giving up rather than reporting a same-frame finish as a timeout.
	if completed_box[0]:
		await _finish_completion()
		return
	_fail("level_completed never fired within %.0fs" % COMPLETION_TIMEOUT)


## The Security PA line plays at the wicket first; the completion screen
## opens LevelDirector.PA_BEAT later. Wait for it, then prove it is showing.
func _finish_completion() -> void:
	await get_tree().create_timer(LevelDirector.PA_BEAT + 0.5).timeout
	await get_tree().process_frame
	var screen := get_tree().root.find_child("CompletionScreen", true, false)
	print("[M7DRIVER] completion screen present=", screen != null)
	_log_session_state("post-completion")
	if screen == null:
		_fail("the completion screen never opened after the PA line")
		return
	print("[M7DRIVER] DONE ok")
	get_tree().quit(0)
