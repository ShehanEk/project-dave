class_name EncounterGroup
extends Node2D
## Coordinates a lane of enemies (per CONVENTIONS.md): leashes them to a lane,
## activates on visible approach, and hands out at most one attack token at a
## time so only one enemy is ever mid-windup/active-attack. An enemy with no
## EncounterGroup ancestor may attack freely (isolated test scenes only).
##
## Optional child "ApproachZone" (Area2D, mask 2 = hero_body) flips
## `is_active` true the first time the hero enters it. If absent, the group
## starts active (useful for demo/test scenes that skip the approach beat).

@export var group_id: String = ""
## Lane bounds in this node's parent space; enemies should stay leashed
## inside this rect (checked by the enemy itself via is_in_lane()).
@export var lane_rect: Rect2 = Rect2(-100000, -100000, 200000, 200000)
## Short grace period before the enemy that just released the token may take
## it back, IF another enemy is currently waiting for it — this is what
## keeps one enemy from monopolizing the token (03: "release the token
## fairly; do not let one enemy monopolize it").
@export var reactivate_cooldown: float = 0.35

var is_active: bool = true

var _token_holder: Node = null
var _last_holder: Node = null
## Counts down (simulated physics time, not wall clock) after a release;
## reactivate_cooldown applies only while this is still positive. Using
## `delta` here keeps it correct under pause and under a forced fixed frame
## rate (tools/test.sh FPS=30), unlike Time.get_ticks_msec().
var _reactivate_timer: float = 0.0
var _waiting: Array = []

@onready var _approach_zone: Area2D = get_node_or_null("ApproachZone")


func _ready() -> void:
	if _approach_zone:
		is_active = false
		_approach_zone.body_entered.connect(_on_approach_body_entered)


func _physics_process(delta: float) -> void:
	if _reactivate_timer > 0.0:
		_reactivate_timer = maxf(0.0, _reactivate_timer - delta)
	# Drop anyone from the waiting list who died or left the tree since they
	# asked for the token, so a stale entry can't keep delaying the last
	# holder's reactivation forever (request_attack_token's `not
	# _waiting.is_empty()` check would otherwise never clear).
	_waiting = _waiting.filter(func(e): return is_instance_valid(e))


func _on_approach_body_entered(body: Node) -> void:
	if body.is_in_group("hero"):
		is_active = true


func is_in_lane(global_pos: Vector2) -> bool:
	return lane_rect.has_point(to_local(global_pos))


## True if moving one step in `dir` from `global_pos` keeps the actor inside
## the lane, OR — when it is already outside — the step moves it back toward
## the lane. Without this, an enemy nudged just outside its lane (e.g. by a
## lunge that briefly overshoots) can never take a single step back in, since
## every candidate step also lands outside: it would be leashed in place
## forever instead of rejoining its lane.
func allows_step(global_pos: Vector2, dir: int, step: float = 4.0) -> bool:
	if dir == 0:
		return false
	var next_pos := global_pos + Vector2(dir * step, 0.0)
	if is_in_lane(next_pos):
		return true
	if is_in_lane(global_pos):
		return false
	var local_x: float = to_local(global_pos).x
	if local_x < lane_rect.position.x:
		return dir > 0
	if local_x > lane_rect.position.x + lane_rect.size.x:
		return dir < 0
	return false


## True while `enemy` currently holds the single attack token.
func holds_token(enemy: Node) -> bool:
	return _token_holder == enemy


## Requests permission to begin a windup/attack. At most one enemy in the
## group holds the token at a time.
func request_attack_token(enemy: Node) -> bool:
	if _token_holder == enemy:
		return true
	if _token_holder != null:
		_mark_waiting(enemy)
		return false
	# Fairness: don't let the enemy that just released the token snatch it
	# straight back while another enemy is still waiting its turn.
	if enemy == _last_holder and not _waiting.is_empty() and _reactivate_timer > 0.0:
		_mark_waiting(enemy)
		return false
	_token_holder = enemy
	_waiting.erase(enemy)
	return true


func release_attack_token(enemy: Node) -> void:
	if _token_holder != enemy:
		return
	_token_holder = null
	_last_holder = enemy
	_reactivate_timer = reactivate_cooldown


func _mark_waiting(enemy: Node) -> void:
	if enemy not in _waiting:
		_waiting.append(enemy)
