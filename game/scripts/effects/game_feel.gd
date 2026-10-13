class_name GameFeel
extends RefCounted
## Shooting feel (C37, "punchy but clean"): a small camera kick on each shot,
## a brief hit-pause on a hit and a stronger shake on a kill. Reduced Motion
## halves the kick and the shake and drops the hit-pause. The camera does
## the moving (GameCamera.kick/shake); this only decides how much.

## Camera kick per shot, px, against the aim. (C53 fun pass: 1.6 -> 2.2, the
## kill shake 3.5 -> 5 and the hit-pause 0.03 -> 0.05 s; the hits read soft.)
const SHOT_KICK := 2.2
## Shake on a kill, px of peak offset.
const KILL_SHAKE := 5.0
## The hit-pause: game time nearly stops for this long (real seconds).
const HIT_PAUSE := 0.05
## C53: Dave being hit lands harder than his own shots (it used to land softer):
## a bigger shake and a longer pause. His death gets the biggest of both.
const HURT_SHAKE := 6.0
const HURT_PAUSE := 0.08
const DEATH_SHAKE := 10.0
const DEATH_PAUSE := 0.16
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


## Dave was hurt: a shake and a pause, so the hit is felt.
static func hurt(from: Node) -> void:
	var cam := _camera(from)
	if cam:
		cam.shake(HURT_SHAKE * (0.5 if _reduced() else 1.0))
	hit_pause(HURT_PAUSE)


## Dave died: the biggest shake and pause in the game.
static func death(from: Node) -> void:
	var cam := _camera(from)
	if cam:
		cam.shake(DEATH_SHAKE * (0.5 if _reduced() else 1.0))
	hit_pause(DEATH_PAUSE)


## A shot that hurt something: game time nearly stops for `duration` (real
## seconds, timed unscaled). A hit during a pause extends it rather than
## stacking it.
static func hit_pause(duration: float = HIT_PAUSE) -> void:
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
	tree.create_timer(duration, true, false, true).timeout.connect(func(): _end_pause(id))


static func _end_pause(id: int) -> void:
	if id != _pause_id or not _pausing:
		return
	_pausing = false
	Engine.time_scale = _scale_before
