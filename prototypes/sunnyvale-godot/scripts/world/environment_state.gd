class_name EnvironmentState
extends Node2D
## Story-driven pre/post-awakening area look (SC01; 03-gameplay-systems.md
## "switch the environment state once"; 04-godot-architecture.md "A completed
## SC01 applies the settled lockdown arrangement before the hero appears").
## Revamp (C24): the post-awakening state is Adam's LOCKDOWN — lamps go
## amber (outdoor path lights) or alarm red (the depot), swivel toward the
## exit and pulse in a slow chase; the backdrop takes on a red emergency
## tint; lockdown-only props (rails, holograms, beacons) appear.
##
## Reacts LIVE to `Session.story_state_changed("awakening_done", true)` —
## which fires the instant SC01 completes or is skipped, while the hero is
## still in the depot (A05) — so the depot's lights go dark and come back
## red one bank at a time right there, and A06's one-shot "panels settle
## ahead" flourish plays entirely off-screen, away from the hero. On
## `_ready()` (level boot, or a rebuild after a death or a Continue load) the
## CURRENT flag value is applied directly with NO animation:
## `load_from_snapshot()` and `restore_committed()` never emit
## `story_state_changed` (only `_finish_awakening()`'s one live `set_story`
## call does), so a flourish can only ever play once, during the actual SC01
## moment, never on reload/Continue/death. Settings.reduced_motion also
## applies the settled look directly.
##
## The underlying Block/collision geometry never moves; this only shows/hides
## decorative Scenery groups, switches a shared set of always-present lit
## fixtures, retints/switches the area's own backdrop layers, and (only for
## the one instance with `controls_background = true`) sets the level's
## whole-screen clear color — a level-wide value (`project.godot`'s
## `environment/defaults/default_clear_color`), so exactly one
## EnvironmentState instance should own it.

@export var controls_background: bool = false
## Night navy (style guide token), then a lockdown night with a faint red
## cast. Only shows where no backdrop draws.
@export var pre_color: Color = Color("#0E1726")
@export var post_color: Color = Color("#170B12")
## Lamps and other lit fixtures (signs, terminals) that switch to the
## lockdown look — the SAME fixture, never a separate hidden/shown prop.
## Scenery handles its own look through `set_lamp_examination_mode()`; any
## other node gets a plain `modulate` retint.
@export var lamp_paths: Array[NodePath] = []
## Lockdown color for this area's `lamp_paths`: hazard amber for the outdoor
## path lights (the level brief's "slow amber lockdown pattern"), alarm red
## for the depot ("the lights turn red").
@export var lamp_lockdown_color: Color = Color("#FFB02E")
## Live flourish only: seconds between one lamp (left to right) switching
## and the next — "the depot lights dim one bank at a time".
@export var lamp_stagger: float = 0.3
## AD-12: background/interior layers (e.g. an area's own Parallax2D
## backdrops) switched per story state: `set_lockdown_mode()` when they have
## it (area_backdrop.gd's red emergency look), plus a `modulate` retint.
@export var backdrop_paths: Array[NodePath] = []
@export var backdrop_pre_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var backdrop_post_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
## Hidden once `awakening_done` (the calm pre-lockdown look).
@export var garden_visuals_path: NodePath = NodePath("")
## Hidden until `awakening_done`; fades in over `flourish_time` the first
## time the flag goes live (never on a direct `_ready()` application).
@export var lockdown_visuals_path: NodePath = NodePath("")
@export var flourish_time: float = 1.4

var _lamps: Array = []
var _backdrops: Array = []
var _garden: CanvasItem
var _lockdown: CanvasItem
var _tween: Tween
var _lamp_tween: Tween


func _ready() -> void:
	for p in lamp_paths:
		var n := get_node_or_null(p)
		if n:
			_lamps.append(n)
	# Left to right, so a staggered switch sweeps toward the exit.
	_lamps.sort_custom(func(a: Node, b: Node) -> bool: return _x_of(a) < _x_of(b))
	for p in backdrop_paths:
		var n2 := get_node_or_null(p)
		if n2:
			_backdrops.append(n2)
	if garden_visuals_path != NodePath(""):
		_garden = get_node_or_null(garden_visuals_path)
	if lockdown_visuals_path != NodePath(""):
		_lockdown = get_node_or_null(lockdown_visuals_path)
	if Session:
		Session.story_state_changed.connect(_on_story_changed)
	_apply(_is_active(), false)


func _exit_tree() -> void:
	if Session and Session.story_state_changed.is_connected(_on_story_changed):
		Session.story_state_changed.disconnect(_on_story_changed)


func _x_of(n: Node) -> float:
	return (n as Node2D).global_position.x if n is Node2D else 0.0


func _is_active() -> bool:
	return Session != null and Session.get_story("awakening_done") == true


func _on_story_changed(flag: String, value: Variant) -> void:
	if flag == "awakening_done" and value == true:
		_apply(true, true)


func _apply(active: bool, animate: bool) -> void:
	var settings := get_node_or_null("/root/Settings")
	var reduced_motion: bool = settings != null and settings.get_reduced_motion()
	var live: bool = animate and active and not reduced_motion
	if controls_background:
		RenderingServer.set_default_clear_color(post_color if active else pre_color)
	if _lamp_tween:
		_lamp_tween.kill()
		_lamp_tween = null
	if live and _lamps.size() > 1 and lamp_stagger > 0.0:
		_lamp_tween = create_tween()
		for lamp in _lamps:
			_lamp_tween.tween_callback(_set_lamp.bind(lamp, true, true))
			_lamp_tween.tween_interval(lamp_stagger)
	else:
		for lamp in _lamps:
			_set_lamp(lamp, active, live)
	for backdrop in _backdrops:
		if is_instance_valid(backdrop):
			backdrop.modulate = backdrop_post_tint if active else backdrop_pre_tint
			if backdrop.has_method("set_lockdown_mode"):
				backdrop.set_lockdown_mode(active, live)
	if _garden:
		_garden.visible = not active
	if _lockdown:
		if live:
			_lockdown.visible = true
			_lockdown.modulate.a = 0.0
			if _tween:
				_tween.kill()
			_tween = create_tween()
			_tween.tween_property(_lockdown, "modulate:a", 1.0, flourish_time)
		else:
			if _tween:
				_tween.kill()
			_lockdown.modulate.a = 1.0
			_lockdown.visible = active


func _set_lamp(lamp: Node, active: bool, animate: bool) -> void:
	if not is_instance_valid(lamp):
		return
	if lamp.has_method("set_lamp_examination_mode"):
		lamp.set_lamp_examination_mode(active, animate, lamp_lockdown_color)
	elif lamp is CanvasItem:
		(lamp as CanvasItem).modulate = lamp_lockdown_color.lerp(Color.WHITE, 0.4) if active else Color.WHITE
