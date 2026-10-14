extends Area2D
## S1 "the drill" (level-design/l02-alignment.md, A01's Broom bay and drill yard): a lit floor
## pad that runs a timed shooting drill. Standing on it starts a run of `duration` seconds (15)
## in which its linked pop-up targets (scripts/objects/popup_target.gd, `targets`) are called on
## their own schedule: each one's tell starts `tell_time` before its `appear_at` and it is up at
## `appear_at`. All of them down before the time runs out: success, once. The `reward` (a hidden
## chip tray: a ChipCache, a Chip, or a node holding several) is revealed and stays revealed, a HUD
## toast says so, and the pad stays done. Time out: whatever is still up goes back into its
## hatch, the pad rearms after `rearm_time` and Dave can start it again, as often as he likes (no
## failure penalty, no failure state).
##
## Persistence: with an `entity_id` the success is recorded as `Session.collect(entity_id, 0)`, so
## a rebuilt level (a death, Continue) shows the drill done and the tray open, and a rollback to a
## checkpoint from before the success puts the drill back. The reward's own pickups keep their
## own ids, so revealing it again never pays twice (a tray already looted stays empty; a chip
## already taken is not rebuilt). Without an id the success lasts as long as the node.
##
## Readout: the HUD toast (`Hud.toast_message`) says "Drill 0/8" at the start and "Drill n/8" on
## each target down; the pad's console draws one pip per target (lit when down) and a time bar
## that drains, teal, amber for the last `warn_time` and red for the last RED_TIME. The pad's
## ring lamp is teal when it is ready, dim while it rearms and status green once done. No
## flashing; reduced motion has nothing to change (nothing here moves but the bar).
##
## Origin: the floor line at the pad's centre. Mask 2 (hero_body), layer 0. Stand-in art until
## art Batch 8 (`piece`: a painted pad, code-drawn while ""). Only existing cues: `latch` (start),
## `keycard_denied` (time out), `door_unlock` (success). No `class_name` (import-cache rule):
## preload it by path; group "drill_pad".

signal run_started
signal target_down(count: int, total: int)
signal run_succeeded
signal run_timed_out(count: int, total: int)

enum State { READY, RUNNING, REARM, DONE }

const Lights := preload("res://scripts/actors/lit/lights.gd")
const TEAL := Color("#3FE0D0")
const AMBER := Color("#FFB02E")
const RED := Color("#FF3B4E")
const STATUS := Color("#4DE38A")
const OUTLINE := Color("#05070B")
const STEEL := Color("#1C2A3A")
const SLATE := Color("#2E3B4E")
const EDGE := Color("#D8E6F0")
const PIP_OFF := Color("#26364B")
const RED_TIME := 0.25
const PAD_HEIGHT := 10.0

@export var entity_id: String = ""
@export var duration: float = 15.0
## The PopupTargets this pad runs (each carries its own `appear_at`).
@export var targets: Array[NodePath] = []
## What success reveals, once: a ChipCache, a Chip, or a node holding several.
@export var reward: NodePath
## Seconds of a tell before each target's `appear_at` (passed to the targets).
@export var tell_time: float = 0.6
## After a time-out the pad waits this long before a new run can start.
@export var rearm_time: float = 1.5
## The time bar turns amber this long before the end (red for the last RED_TIME).
@export var warn_time: float = 3.0
@export var pad_width: float = 112.0
## Painted pad (art Batch 8); code-drawn while "".
@export var piece: String = ""

var state: State = State.READY
var elapsed: float = 0.0
var _rearm_left: float = 0.0
var _targets: Array = []
var _called: Dictionary = {}    # target -> true once its tell has started this run
var _reward: Node = null
var _light: PointLight2D


func _init() -> void:
	collision_layer = 0
	collision_mask = 1 << 1   # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	add_to_group("drill_pad")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(pad_width, 40.0)
	shape.shape = rect
	shape.position = Vector2(0.0, -20.0)
	add_child(shape)  # generated, not saved
	_light = PointLight2D.new()
	_light.texture = Lights.soft_disc()
	_light.texture_scale = 2.2
	_light.energy = 0.45
	_light.height = 30.0
	_light.position = Vector2(0.0, -12.0)
	_light.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(_light)
	for p in targets:
		var t := get_node_or_null(p)
		if t != null and t.has_signal("knocked_down"):
			_targets.append(t)
			t.tell_time = tell_time
			t.knocked_down.connect(_on_target_down)
	_reward = get_node_or_null(reward) if not reward.is_empty() else null
	if entity_id != "" and Session and Session.is_collected(entity_id):
		_finish_done(false)
	else:
		_set_reward_shown(false)
	_update_light()
	queue_redraw()


func is_done() -> bool:
	return state == State.DONE


func is_running() -> bool:
	return state == State.RUNNING


func total() -> int:
	return _targets.size()


func down_count() -> int:
	var n := 0
	for t in _targets:
		if t.is_down():
			n += 1
	return n


func time_left() -> float:
	return maxf(0.0, duration - elapsed) if state == State.RUNNING else duration


## Starts a run now when the pad is ready (Dave standing on it does this). Returns true if it did.
func start_run() -> bool:
	if state != State.READY or _targets.is_empty():
		return false
	state = State.RUNNING
	elapsed = 0.0
	_called.clear()
	for t in _targets:
		t.reset_target()
	_play(&"latch")
	_toast("Drill 0/%d" % total())
	run_started.emit()
	_tick_schedule()
	_update_light()
	queue_redraw()
	return true


func _physics_process(delta: float) -> void:
	match state:
		State.READY:
			if _hero_on_pad():
				start_run()
		State.RUNNING:
			elapsed += delta
			_tick_schedule()
			if state == State.RUNNING and elapsed >= duration:
				_time_out()
			queue_redraw()
		State.REARM:
			_rearm_left -= delta
			if _rearm_left <= 0.0:
				state = State.READY
				_update_light()
				queue_redraw()


func _hero_on_pad() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group("hero"):
			return true
	return false


## Calls every target whose tell is due (and raises any whose time has come).
func _tick_schedule() -> void:
	for t in _targets:
		var at: float = float(t.appear_at)
		if not _called.has(t) and elapsed >= at - float(t.tell_time):
			_called[t] = true
			t.begin_tell()
		if elapsed >= at:
			t.raise_target()


func _on_target_down() -> void:
	if state != State.RUNNING:
		return
	var n := down_count()
	target_down.emit(n, total())
	if n >= total():
		_succeed()
	else:
		_toast("Drill %d/%d" % [n, total()])
	queue_redraw()


func _succeed() -> void:
	if entity_id != "" and Session:
		Session.collect(entity_id, 0)
	_finish_done(true)
	_play(&"door_unlock")
	_toast("Drill complete: %d/%d. Chip tray open" % [total(), total()])
	run_succeeded.emit()


## The drill is done for good: targets stay down, the reward is shown (once).
func _finish_done(live: bool) -> void:
	state = State.DONE
	if not live:
		for t in _targets:
			t.set_done()
	_set_reward_shown(true)
	_update_light()
	queue_redraw()


func _time_out() -> void:
	var n := down_count()
	for t in _targets:
		if t.is_down():
			continue
		t.retract()
	state = State.REARM
	_rearm_left = rearm_time
	_play(&"keycard_denied")
	_toast("Time. Drill %d/%d: step on the pad to go again" % [n, total()])
	run_timed_out.emit(n, total())
	# The ones already down come back up for the next run when it starts (reset_target).
	_update_light()
	queue_redraw()


## Hides (or shows) the reward: invisible, its shapes off, so it can be neither seen nor taken.
func _set_reward_shown(on: bool) -> void:
	if _reward == null or not is_instance_valid(_reward):
		return
	if _reward is CanvasItem:
		(_reward as CanvasItem).visible = on
	_set_shapes(_reward, not on)


func _set_shapes(n: Node, disabled: bool) -> void:
	if n is CollisionShape2D or n is CollisionPolygon2D:
		if Engine.is_in_physics_frame():
			n.set_deferred("disabled", disabled)
		else:
			n.set("disabled", disabled)
	for c in n.get_children():
		_set_shapes(c, disabled)


func reward_shown() -> bool:
	return _reward != null and is_instance_valid(_reward) and (not (_reward is CanvasItem) or (_reward as CanvasItem).visible)


func _toast(text: String) -> void:
	if not is_inside_tree():
		return
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("toast_message"):
		hud.toast_message(text)


func _play(cue: StringName) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue, global_position)


## The ring lamp's colour for the current state.
func ring_color() -> Color:
	match state:
		State.READY:
			return TEAL
		State.RUNNING:
			return bar_color()
		State.DONE:
			return STATUS
	return Color(TEAL, 0.25)


## The time bar's colour: teal, amber for the last `warn_time`, red for the last RED_TIME.
func bar_color() -> Color:
	var left := time_left()
	if left <= RED_TIME:
		return RED
	if left <= warn_time:
		return AMBER
	return TEAL


func _update_light() -> void:
	if _light == null:
		return
	var c := ring_color()
	_light.color = Color(c, 1.0)
	_light.energy = 0.45 * c.a if state != State.DONE else 0.2


func _draw() -> void:
	if state == State.RUNNING:
		_update_light()
	var w := pad_width
	var plate := Rect2(-w * 0.5, -PAD_HEIGHT, w, PAD_HEIGHT)
	var ring := ring_color()
	# The pad: a raised steel plate with a lit ring inset and a lit top edge (walkable cue).
	draw_rect(Rect2(plate.position - Vector2(4.0, 0.0), plate.size + Vector2(8.0, 0.0)), OUTLINE)
	draw_rect(plate, STEEL)
	draw_rect(Rect2(plate.position + Vector2(10.0, 3.0), Vector2(w - 20.0, 3.0)), Color(ring, 0.9 * ring.a))
	draw_rect(Rect2(plate.position + Vector2(6.0, -6.0), Vector2(w - 12.0, 6.0)), Color(ring, 0.12 * ring.a))
	draw_line(plate.position, Vector2(plate.end.x, plate.position.y), EDGE, 1.5)
	draw_rect(plate, OUTLINE, false, 1.5)
	# The console post at the pad's back edge: pips and the time bar.
	var n := maxi(total(), 1)
	var post := Rect2(-w * 0.5 - 22.0, -64.0, 16.0, 64.0 - PAD_HEIGHT)
	draw_rect(post, SLATE)
	draw_rect(post, OUTLINE, false, 1.5)
	var panel := Rect2(-w * 0.5 - 40.0, -96.0, 52.0, 34.0)
	draw_rect(panel, STEEL)
	draw_rect(panel, OUTLINE, false, 2.0)
	var pip_w := (panel.size.x - 8.0) / float(n)
	for i in total():
		var down: bool = _targets[i].is_down()
		var r := Rect2(panel.position + Vector2(4.0 + pip_w * float(i) + 1.0, 5.0), Vector2(pip_w - 2.0, 7.0))
		draw_rect(r, STATUS if down else PIP_OFF)
	var bar_bg := Rect2(panel.position + Vector2(4.0, 18.0), Vector2(panel.size.x - 8.0, 9.0))
	draw_rect(bar_bg, OUTLINE)
	var frac := 1.0 if state != State.RUNNING else time_left() / maxf(duration, 0.01)
	var bar_c := bar_color() if state == State.RUNNING else ring
	if state == State.DONE:
		bar_c = STATUS
	draw_rect(Rect2(bar_bg.position + Vector2(1.0, 1.0), Vector2((bar_bg.size.x - 2.0) * frac, bar_bg.size.y - 2.0)), bar_c)
