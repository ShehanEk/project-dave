extends Node2D
## Level 2's set piece S5, the projector purge (level-design/l02-alignment.md): drives a row of
## hazard vents (hazard_vent.gd) as a WAVE. It fires them one after the other, `spacing` seconds
## apart, so the steam travels along the catwalk and Dave can ride in behind it; when the last
## vent has finished it rests `rest` seconds and sends the wave again.
##
## THE VENTS: `vents` lists NodePaths (relative to this node); an empty list means every child
## that is a vent, in tree order. Every vent it drives is put into "driven" mode
## (HazardVent.set_driven(): it never cycles by itself, it runs one WARN -> ACTIVE -> IDLE burst
## per `fire()`), so the sequencer is the only clock. `reverse` fires them last to first.
##
## TIMING: vent i is fired at `i * spacing` after the wave starts, so its steam starts
## `warn_duration()` later (the vents' own warning, 0.8 s, always plays first; the fire time is
## when the lamp lights, not when the steam arrives). A wave lasts `(n - 1) * spacing + warn +
## active`, the whole loop `period()` = that + `rest`. With the defaults (spacing 0.45, four
## vents) the steam front moves along the row at 1 vent per 0.45 s, and Dave, running at 384 px/s,
## covers a 150 px vent spacing in 0.4 s: he can keep up behind the front, never ahead of it.
##
## STARTING: by default the wave starts on its own when the sequencer is ready. With
## `start_on_approach` it waits for Dave: the first of
##   - the hero inside the Area2D at `approach_area` (a trigger placed by the level), or
##   - the hero's global x passing `approach_x` in direction `approach_dir` (+1: x >= approach_x,
##     -1: x <= approach_x; 0 disables this test)
## starts it. `loop` false sends one wave only. `start()` / `stop()` are public for beats.
##
## No `class_name`; reach it by path. Lives in the area's Entities (or Geometry) with its vents.

## A wave begins.
signal wave_started
## Vent `index` (position in firing order) was fired; `vent` is the HazardVent.
signal vent_fired(index: int, vent: Node)
## The last vent of a wave is back to idle.
signal wave_finished

const HazardVent := preload("res://scripts/objects/hazard_vent.gd")

enum Mode { WAITING, FIRING, DRAINING, RESTING, STOPPED }

@export var vents: Array[NodePath] = []
## Seconds between one vent's fire and the next one's.
@export var spacing: float = 0.45
## Seconds of quiet after a wave before the next.
@export var rest: float = 2.5
@export var reverse: bool = false
@export var loop: bool = true
## false: wait for `start()` (or the approach trigger below).
@export var autostart: bool = true
@export var start_on_approach: bool = false
@export var approach_area: NodePath = NodePath("")
@export var approach_x: float = 0.0
@export var approach_dir: int = 0

var mode: int = Mode.STOPPED
var _vents: Array = []
var _next: int = 0
var _timer: float = 0.0
var _bound: bool = false


func _ready() -> void:
	_bind.call_deferred()


## Collects the vents and takes them over. Deferred from _ready so vents later in the tree have
## run their own _ready (a self-cycling vent is stopped here, before any physics tick).
func _bind() -> void:
	_vents.clear()
	if vents.is_empty():
		for c in get_children():
			if c.has_method("set_driven") and c.has_method("fire"):
				_vents.append(c)
	else:
		for p in vents:
			var n := get_node_or_null(p)
			if n != null and n.has_method("set_driven") and n.has_method("fire"):
				_vents.append(n)
	for v in _vents:
		v.set_driven()
	_bound = true
	if autostart and not start_on_approach:
		start()
	elif start_on_approach:
		mode = Mode.WAITING


## The vents in firing order.
func ordered_vents() -> Array:
	var out := _vents.duplicate()
	if reverse:
		out.reverse()
	return out


## Seconds from the start of one wave to the start of the next.
func period() -> float:
	if _vents.is_empty():
		return rest
	var v = _vents[0]
	return maxf(float(_vents.size() - 1) * spacing, 0.0) + v.warn_duration() + v.get_active_time() + rest


## Begins a wave now (ignored before the vents are bound, or while one is under way).
func start() -> void:
	if not _bound or _vents.is_empty():
		return
	if mode == Mode.FIRING or mode == Mode.DRAINING:
		return
	_begin_wave()


## Stops sending waves and idles every vent at once.
func stop() -> void:
	mode = Mode.STOPPED
	for v in _vents:
		v.stop()


func _begin_wave() -> void:
	mode = Mode.FIRING
	_next = 0
	_timer = 0.0
	wave_started.emit()


func _physics_process(delta: float) -> void:
	match mode:
		Mode.WAITING:
			if _approached():
				_begin_wave()
				_step_firing(delta)
		Mode.FIRING:
			_step_firing(delta)
		Mode.DRAINING:
			if _all_idle():
				wave_finished.emit()
				if loop:
					mode = Mode.RESTING
					_timer = rest
				else:
					mode = Mode.STOPPED
		Mode.RESTING:
			_timer -= delta
			if _timer <= 0.0:
				_begin_wave()
				_step_firing(delta)


## Fires every vent whose time has come. The leftover time carries into the next spacing, so the
## gaps average exactly `spacing` whatever the frame step.
func _step_firing(delta: float) -> void:
	var order := ordered_vents()
	_timer -= delta
	while _next < order.size() and _timer <= 0.0:
		var v = order[_next]
		v.fire()
		vent_fired.emit(_next, v)
		_next += 1
		_timer += spacing
	if _next >= order.size():
		mode = Mode.DRAINING


func _all_idle() -> bool:
	for v in _vents:
		if v.state != HazardVent.State.IDLE:
			return false
	return true


func _approached() -> bool:
	var hero := get_tree().get_first_node_in_group("hero") as Node2D
	if hero == null:
		return false
	if approach_area != NodePath(""):
		var area := get_node_or_null(approach_area) as Area2D
		if area != null and area.overlaps_body(hero):
			return true
	if approach_dir > 0 and hero.global_position.x >= approach_x:
		return true
	if approach_dir < 0 and hero.global_position.x <= approach_x:
		return true
	return false
