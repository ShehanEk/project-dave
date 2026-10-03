class_name GameFeel
extends RefCounted
## Shooting feel (C37, "punchy but clean"): a small camera kick on each shot,
## a brief hit-pause on a hit and a stronger shake on a kill. Reduced Motion
## halves the kick and the shake and drops the hit-pause. The camera does
## the moving (GameCamera.kick/shake); this only decides how much.

## Camera kick per shot, px, against the aim.
const SHOT_KICK := 1.6
## Shake on a kill, px of peak offset.
const KILL_SHAKE := 3.5
## The hit-pause: game time nearly stops for this long (real seconds).
const HIT_PAUSE := 0.03
const HIT_PAUSE_SCALE := 0.05

## Off in the headless test runner, so frame-counted timings stay exact.
static var hit_pause_enabled: bool = true

static var _pausing: bool = false
static var _pause_id: int = 0
static var _scale_before: float = 1.0


static func _reduced() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var settings: Node = tree.root.get_node_or_null("/root/Settings") if tree else null
	return settings != null and settings.get_reduced_motion()


static func _camera(from: Node) -> Node:
	if from == null or not from.is_inside_tree():
		return null
	var cam := from.get_viewport().get_camera_2d()
	return cam if cam != null and cam.has_method("kick") else null


## A shot fired toward `aim_dir`: the view kicks back a little.
static func shot(from: Node, aim_dir: Vector2) -> void:
	var cam := _camera(from)
	if cam:
		cam.kick(-aim_dir.normalized() * SHOT_KICK * (0.5 if _reduced() else 1.0))


## An enemy destroyed or killed: a short, stronger shake.
static func kill(from: Node) -> void:
	var cam := _camera(from)
	if cam:
		cam.shake(KILL_SHAKE * (0.5 if _reduced() else 1.0))


## A shot that hurt something: game time nearly stops for HIT_PAUSE (real
## seconds, timed unscaled). A hit during a pause extends it rather than
## stacking it.
static func hit_pause() -> void:
	if not hit_pause_enabled or _reduced():
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	if not _pausing:
		_pausing = true
		_scale_before = Engine.time_scale
		Engine.time_scale = _scale_before * HIT_PAUSE_SCALE
	_pause_id += 1
	var id := _pause_id
	tree.create_timer(HIT_PAUSE, true, false, true).timeout.connect(func(): _end_pause(id))


static func _end_pause(id: int) -> void:
	if id != _pause_id or not _pausing:
		return
	_pausing = false
	Engine.time_scale = _scale_before
