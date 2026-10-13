class_name RouteBot
extends Node
## Drives a Hero through a chain of RoutePoints ONLY via
## Input.action_press/release of named actions (plus an aim override, so the
## headless run never depends on a live mouse cursor). Points are collected,
## in tree order, from every AreaRoot found under `scan_root`'s subtree
## (RoutePoint.branch == "" always included; other branches only when passed
## to build_points()). Deterministic: input is reset between every point and
## a jump press never survives past its own JUMP point.
##
## Usage:
##   var bot := RouteBot.new()
##   add_child(bot)
##   bot.build_points(area_root_or_scan_root, ["OPT01"])
##   bot.start(hero)
##   while bot.running: await get_tree().physics_frame
##   var report := bot.get_report()

signal point_reached(index: int, point: RoutePoint)
signal failed(message: String, index: int, hero_position: Vector2)
signal finished(success: bool)

const MOVE_DEADZONE := 2.0
const INTERACT_TAP_TIME := 1.0 / 60.0
## How long a dismiss attempts a plain `skip` tap alone before also trying
## `pause` (ADV-01): SC01 is the ONLY modal that ends on `skip` (a Story
## design decision — "pause suspends scene playback", it never skips), so
## trying skip alone first and giving it a moment to react avoids ever
## pressing `pause` while SC01 is still genuinely running (which would race
## PauseMenu's own cutscene-aware open check into pausing the game instead of
## skipping, stalling this bot). Every OTHER modal (workbench/pad/completion
## confirms) ignores `skip` entirely and closes on `pause`, so it falls
## through to the `pause` tap unaffected, just delayed by this long.
const DISMISS_PAUSE_DELAY := 0.25
const DISMISS_TIMEOUT := 1.0

@export var stuck_timeout: float = 3.0

var running: bool = false
var success: bool = false
var failure_message: String = ""

var points: Array = []
var _point_areas: Array = []  # parallel to `points`: owning AreaRoot or null

var hero: Hero = null
var _index: int = -1
var _state: String = "idle"  # approach, jump_air, wait_platform, interact, wait_seconds

var _jump_hold_timer: float = 0.0
var _jump_pressed: bool = false
var _left_ground: bool = false
var _interact_timer: float = 0.0
var _interact_released: bool = false
var _wait_timer: float = 0.0
var _dismiss_timer: float = 0.0
var _dismiss_skip_released: bool = false
var _dismiss_pause_pressed: bool = false
var _dismiss_pause_released: bool = false

var _elapsed: float = 0.0
var _stuck_timer: float = 0.0
var _last_x: float = 0.0

var _current_area: AreaRoot = null
var _area_start_time: float = 0.0
var area_times: Dictionary = {}      # area_id -> seconds spent in that area
var beat_times: Dictionary = {}      # beat_id -> seconds elapsed at entry
var point_index_reached: int = -1

var _beat_hub: BeatHub = null


func build_points(scan_root: Node, enabled_branches: Array = []) -> void:
	points = []
	_point_areas = []
	for area in _find_area_roots(scan_root):
		for p in area.get_route_points(enabled_branches):
			points.append(p)
			_point_areas.append(area)


func _find_area_roots(node: Node) -> Array:
	var found: Array = []
	if node is AreaRoot:
		found.append(node)
	for child in node.get_children():
		found.append_array(_find_area_roots(child))
	return found


func start(target_hero: Hero) -> void:
	hero = target_hero
	# Neutral aim override: keep the aim pivot from chasing a live/absent
	# mouse cursor during a headless run (the bot never fires).
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(float(hero.facing) * 100.0, 0.0)
	_release_all()
	_beat_hub = BeatHub.get_instance()
	if not _beat_hub.beat_entered.is_connected(_on_beat_entered):
		_beat_hub.beat_entered.connect(_on_beat_entered)
	_elapsed = 0.0
	_stuck_timer = 0.0
	_last_x = hero.global_position.x
	_index = -1
	running = true
	success = false
	failure_message = ""
	if points.is_empty():
		_finish(true)
		return
	_advance()


func _exit_tree() -> void:
	if _beat_hub and _beat_hub.beat_entered.is_connected(_on_beat_entered):
		_beat_hub.beat_entered.disconnect(_on_beat_entered)


func get_report() -> Dictionary:
	return {
		"success": success,
		"failure": failure_message,
		"seconds": _elapsed,
		"point_index_reached": point_index_reached,
		"points_total": points.size(),
		"area_times": area_times.duplicate(),
		"beat_times": beat_times.duplicate(),
		"hero_final_position": hero.global_position if hero else Vector2.ZERO,
	}


func _physics_process(delta: float) -> void:
	if not running or hero == null:
		return
	_elapsed += delta
	_check_stuck(delta)
	match _state:
		"approach":
			_tick_approach()
		"jump_air":
			_tick_jump_air(delta)
		"wait_platform":
			_tick_wait_platform()
		"interact":
			_tick_interact(delta)
		"dismiss_modal":
			_tick_dismiss_modal(delta)
		"wait_seconds":
			_tick_wait_seconds(delta)


# --- per-point state machine -------------------------------------------------

func _current_point() -> RoutePoint:
	return points[_index]


func _advance() -> void:
	var prev_area: AreaRoot = _current_area
	_index += 1
	if _index >= points.size():
		_finish(true)
		return
	point_index_reached = _index
	point_reached.emit(_index, _current_point())
	var area: AreaRoot = _point_areas[_index]
	if area != prev_area:
		if prev_area != null:
			area_times[prev_area.area_id] = _elapsed - _area_start_time
		_current_area = area
		_area_start_time = _elapsed
	_release_all()
	_state = "approach"
	_reset_stuck()


func _finish(reached_end: bool) -> void:
	if _current_area != null and not area_times.has(_current_area.area_id):
		area_times[_current_area.area_id] = _elapsed - _area_start_time
	running = false
	success = reached_end
	_release_all()
	finished.emit(success)


func _fail(message: String) -> void:
	failure_message = "point %d (%s): %s" % [_index, _current_point().name if _index >= 0 and _index < points.size() else "?", message]
	running = false
	success = false
	_release_all()
	failed.emit(failure_message, _index, hero.global_position)
	finished.emit(false)


# --- approach (shared by every action's "walk to point.x" phase) ------------

func _tick_approach() -> void:
	var point := _current_point()
	# A one-way level-ending trigger reachable only by WALKING into it (M5's
	# exit wicket: LevelDirector permanently sets hero.input_enabled = false
	# the instant the hero's body overlaps it, well before a route point
	# authored past it — e.g. deep in the same solid floor, to guarantee the
	# walk actually crosses the trigger — can ever be reached) is the run's
	# own successful completion, not a stuck failure, PROVIDED there is
	# nothing left afterward for the bot to do (this is the route's last
	# point). This is deliberately narrower than M4's `dismiss_modal` (a
	# dismissible modal re-enables input on its own and always has more
	# route left to drive) — an input_enabled drop with route left to go is
	# still a real failure, caught by the unchanged stuck-timeout below.
	if hero and not hero.input_enabled and _index == points.size() - 1:
		_release_move()
		_finish(true)
		return
	if _steer_toward(point.global_position.x, point.tolerance):
		_release_move()
		match point.action:
			RoutePoint.Action.MOVE:
				_advance()
			RoutePoint.Action.JUMP:
				_begin_jump()
			RoutePoint.Action.WAIT_PLATFORM:
				_state = "wait_platform"
				_reset_stuck()
			RoutePoint.Action.INTERACT:
				_state = "interact"
				_interact_timer = 0.0
				_interact_released = false
				Input.action_press("interact")
				_reset_stuck()
			RoutePoint.Action.WAIT_SECONDS:
				_state = "wait_seconds"
				_wait_timer = point.seconds
				_reset_stuck()


## Returns true once hero.x is within `tolerance` of `target_x` (and steers
## toward it via move_left/move_right in the meantime).
func _steer_toward(target_x: float, tolerance: float) -> bool:
	var dx := target_x - hero.global_position.x
	if absf(dx) <= tolerance:
		_release_move()
		return true
	if dx > 0.0:
		_set_move(1)
	else:
		_set_move(-1)
	return false


func _set_move(dir: int) -> void:
	if dir > 0:
		Input.action_release("move_left")
		Input.action_press("move_right")
	elif dir < 0:
		Input.action_release("move_right")
		Input.action_press("move_left")
	else:
		_release_move()


func _release_move() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")


# --- JUMP ---------------------------------------------------------------------

func _begin_jump() -> void:
	Input.action_press("jump")
	_jump_pressed = true
	_jump_hold_timer = 0.0
	_left_ground = false
	_state = "jump_air"
	_reset_stuck()


func _tick_jump_air(delta: float) -> void:
	if _jump_pressed:
		_jump_hold_timer += delta
		var point := _current_point()
		if _jump_hold_timer >= point.hold_jump:
			Input.action_release("jump")
			_jump_pressed = false

	# Steer toward the NEXT point while airborne so the jump lands close to
	# where the route actually continues; fall back to this point's x if it
	# is the last one.
	var steer_x: float = _current_point().global_position.x
	if _index + 1 < points.size():
		steer_x = points[_index + 1].global_position.x
	_steer_toward(steer_x, 4.0)

	if not hero.is_on_floor():
		_left_ground = true
	elif _left_ground:
		_release_move()
		if _jump_pressed:
			Input.action_release("jump")
			_jump_pressed = false
		_advance()


# --- WAIT_PLATFORM --------------------------------------------------------------

func _tick_wait_platform() -> void:
	var point := _current_point()
	var platform := point.get_platform_node()
	if platform == null:
		_fail("WAIT_PLATFORM has no valid `platform` NodePath")
		return
	# `platform_target` is authored AreaRoot-local (per RoutePoint), so it
	# reads correctly whether the area is tested alone at the origin or
	# placed at a nonzero x offset inside the full level (LevelDirector).
	var area: AreaRoot = _point_areas[_index]
	var target_global: Vector2 = area.to_global(point.platform_target) if area else point.platform_target
	if (platform.global_position as Vector2).distance_to(target_global) <= point.tolerance:
		_reset_stuck()
		_advance()
	# else: keep waiting; stuck detection is suspended for this state (see
	# _check_stuck), a genuinely broken platform times out the whole run.


# --- INTERACT -------------------------------------------------------------------

func _tick_interact(delta: float) -> void:
	_interact_timer += delta
	if not _interact_released and _interact_timer >= INTERACT_TAP_TIME:
		Input.action_release("interact")
		_interact_released = true
	if _interact_timer >= 0.3:
		if hero and not hero.input_enabled:
			# The interact opened a modal (workbench/pad confirm, SC01, ...) that
			# disabled gameplay input. RouteBot makes no gameplay CHOICES on
			# the player's behalf (never confirms a purchase/swap) — it just
			# backs out exactly like a player who wants to keep moving, same
			# as CONVENTIONS.md's manual-edge input handling elsewhere in
			# this project. Tries "skip" (SC01's ONLY dismiss action) first,
			# then falls back to "pause" (every other modal's Decline/Cancel)
			# — see DISMISS_PAUSE_DELAY's comment for why this order matters.
			_state = "dismiss_modal"
			_dismiss_timer = 0.0
			_dismiss_skip_released = false
			_dismiss_pause_pressed = false
			_dismiss_pause_released = false
			Input.action_press("skip")
			return
		_advance()


func _tick_dismiss_modal(delta: float) -> void:
	_dismiss_timer += delta
	if not _dismiss_skip_released and _dismiss_timer >= INTERACT_TAP_TIME:
		Input.action_release("skip")
		_dismiss_skip_released = true
	if hero.input_enabled:
		_advance()
		return
	if not _dismiss_pause_pressed and _dismiss_timer >= DISMISS_PAUSE_DELAY:
		Input.action_press("pause")
		_dismiss_pause_pressed = true
	elif _dismiss_pause_pressed and not _dismiss_pause_released and _dismiss_timer >= DISMISS_PAUSE_DELAY + INTERACT_TAP_TIME:
		Input.action_release("pause")
		_dismiss_pause_released = true
	if hero.input_enabled:
		_advance()
	elif _dismiss_timer >= DISMISS_TIMEOUT:
		_fail("modal stayed open after skip/pause (never re-enabled hero.input_enabled)")


# --- WAIT_SECONDS ---------------------------------------------------------------

func _tick_wait_seconds(delta: float) -> void:
	_wait_timer -= delta
	if _wait_timer <= 0.0:
		_advance()


# --- stuck detection ----------------------------------------------------------

func _reset_stuck() -> void:
	_stuck_timer = 0.0
	_last_x = hero.global_position.x if hero else 0.0


func _check_stuck(delta: float) -> void:
	# Only x-progress is expected during approach/jump; waiting states are
	# legitimately stationary and exempt (their own logic times out via the
	# harness-level timeout instead).
	if _state != "approach" and _state != "jump_air":
		return
	if absf(hero.global_position.x - _last_x) > MOVE_DEADZONE:
		_last_x = hero.global_position.x
		_stuck_timer = 0.0
		return
	_stuck_timer += delta
	if _stuck_timer >= stuck_timeout:
		_fail("stuck: no x progress for %.1fs at x=%.1f" % [stuck_timeout, hero.global_position.x])


func _release_all() -> void:
	_release_move()
	if Input.is_action_pressed("jump"):
		Input.action_release("jump")
	if Input.is_action_pressed("interact"):
		Input.action_release("interact")
	if Input.is_action_pressed("pause"):
		Input.action_release("pause")
	if Input.is_action_pressed("skip"):
		Input.action_release("skip")
	_jump_pressed = false


func _on_beat_entered(beat_id: String, _area_id: String) -> void:
	if not beat_times.has(beat_id):
		beat_times[beat_id] = _elapsed
