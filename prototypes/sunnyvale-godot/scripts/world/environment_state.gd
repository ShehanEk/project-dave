class_name EnvironmentState
extends Node2D
## Story-driven pre/post-awakening area look (SC01; 03-gameplay-systems.md
## "switch the environment state once"; 04-godot-architecture.md "A completed
## SC01 applies the settled quarantine arrangement before the hero appears").
##
## Reacts LIVE to `Session.story_state_changed("awakening_done", true)` —
## which fires the instant SC01 completes or is skipped, while the hero is
## still in the depot (A05) — so A06's one-shot "panels settle ahead"
## flourish plays entirely off-screen, away from the hero. On `_ready()`
## (level boot, or a rebuild after a death or a Continue load) the CURRENT
## flag value is applied directly with NO animation: `load_from_snapshot()`
## and `restore_committed()` never emit `story_state_changed` (only
## `_finish_awakening()`'s one live `set_story` call does), so a flourish can
## only ever play once, during the actual SC01 moment, never on reload/
## Continue/death.
##
## The underlying Block/collision geometry never moves; this only shows/hides
## decorative Scenery groups, retints a shared set of always-present lamp
## props, and (only for the one instance with `controls_background = true`)
## nudges the level's whole-screen clear color — a level-wide value
## (`project.godot`'s `environment/defaults/default_clear_color`), so exactly
## one EnvironmentState instance should own it.

@export var controls_background: bool = false
@export var pre_color: Color = Color(0.62352943, 0.84705883, 0.9098039)
@export var post_color: Color = Color("#3a4650")
## Scenery nodes (e.g. LAMP-kind props) whose `modulate` reflects the story
## state — the SAME fixture "swivelled into an examination light", not a
## separate hidden/shown prop.
@export var lamp_paths: Array[NodePath] = []
## AD-12: background/interior layers (e.g. an area's own DEPOT-mode
## Parallax2D) whose `modulate` is retinted per story state — the SAME
## approach as `lamp_paths`, just applied to the whole backdrop instead of
## one fixture, so an interior area's ambience reads as calm before and
## clearly alarmed after even where no lamp is directly in view.
@export var backdrop_paths: Array[NodePath] = []
@export var backdrop_pre_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var backdrop_post_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
## Hidden once `awakening_done` (the "happy garden" default look).
@export var garden_visuals_path: NodePath = NodePath("")
## Hidden until `awakening_done`; fades in over `flourish_time` the first
## time the flag goes live (never on a direct `_ready()` application).
@export var quarantine_visuals_path: NodePath = NodePath("")
@export var flourish_time: float = 1.4

const LAMP_POST_TINT := Color("#8fe0c9")
const LAMP_PRE_TINT := Color(1.0, 1.0, 1.0, 1.0)

var _lamps: Array = []
var _backdrops: Array = []
var _garden: CanvasItem
var _quarantine: CanvasItem
var _tween: Tween


func _ready() -> void:
	for p in lamp_paths:
		var n := get_node_or_null(p)
		if n:
			_lamps.append(n)
	for p in backdrop_paths:
		var n2 := get_node_or_null(p)
		if n2:
			_backdrops.append(n2)
	if garden_visuals_path != NodePath(""):
		_garden = get_node_or_null(garden_visuals_path)
	if quarantine_visuals_path != NodePath(""):
		_quarantine = get_node_or_null(quarantine_visuals_path)
	if Session:
		Session.story_state_changed.connect(_on_story_changed)
	_apply(_is_active(), false)


func _exit_tree() -> void:
	if Session and Session.story_state_changed.is_connected(_on_story_changed):
		Session.story_state_changed.disconnect(_on_story_changed)


func _is_active() -> bool:
	return Session != null and Session.get_story("awakening_done") == true


func _on_story_changed(flag: String, value: Variant) -> void:
	if flag == "awakening_done" and value == true:
		_apply(true, true)


func _apply(active: bool, animate: bool) -> void:
	if controls_background:
		RenderingServer.set_default_clear_color(post_color if active else pre_color)
	for lamp in _lamps:
		if is_instance_valid(lamp):
			lamp.modulate = LAMP_POST_TINT if active else LAMP_PRE_TINT
	for backdrop in _backdrops:
		if is_instance_valid(backdrop):
			backdrop.modulate = backdrop_post_tint if active else backdrop_pre_tint
	if _garden:
		_garden.visible = not active
	if _quarantine:
		var settings := get_node_or_null("/root/Settings")
		var reduced_motion: bool = settings != null and settings.get_reduced_motion()
		if animate and not reduced_motion:
			_quarantine.visible = true
			_quarantine.modulate.a = 0.0
			if _tween:
				_tween.kill()
			_tween = create_tween()
			_tween.tween_property(_quarantine, "modulate:a", 1.0, flourish_time)
		else:
			if _tween:
				_tween.kill()
			_quarantine.modulate.a = 1.0
			_quarantine.visible = active
