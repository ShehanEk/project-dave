class_name EncounterGroup
extends Node2D
## Coordinates a lane of enemies (per CONVENTIONS.md): leashes them to a lane,
## activates on visible approach, and hands out at most `max_attackers` attack
## tokens at a time, so at most that many enemies are ever mid-windup/active-
## attack (one by default; the lockdown fights in A06 allow two, C41). An
## enemy with no EncounterGroup ancestor may attack freely (isolated test
## scenes only).
##
## Optional child "ApproachZone" (Area2D, mask 2 = hero_body) flips
## `is_active` true the first time the hero enters it. A group with
## `wait_for_trigger` set instead stays inactive until something calls
## `activate()` (the exit wicket's hold-out, C41). With neither, the group
## starts active (useful for demo/test scenes that skip the approach beat).

## Emitted exactly once, the moment `is_active` flips true from an
## ApproachZone entry (never for a group that starts already active — there
## is no "moment" to mark there). M7 readability: lets a scene-specific
## one-shot cue (e.g. TutorialPrompt's `trigger_node`) key off the same
## "encounter activated" moment the fight itself uses, with no polling.
signal activated

@export var group_id: String = ""
## Lane bounds in this node's parent space; enemies should stay leashed
## inside this rect (checked by the enemy itself via is_in_lane()).
@export var lane_rect: Rect2 = Rect2(-100000, -100000, 200000, 200000)
## Short grace period before the enemy that just released the token may take
## it back, IF another enemy is currently waiting for it — this is what
## keeps one enemy from monopolizing the token (03: "release the token
## fairly; do not let one enemy monopolize it").
@export var reactivate_cooldown: float = 0.35
## How many enemies may hold an attack token at once (C41: 1 everywhere but
## the lockdown fights in A06, which use 2).
@export_range(1, 4) var max_attackers: int = 1
## Starts inactive and waits for `activate()` (no ApproachZone needed).
@export var wait_for_trigger: bool = false
## Another group whose attack tokens this one uses instead of its own, so
## two groups that wake at different times in the same yard (the hold-out's
## first staffers and its reinforcements, C41) never field more attackers
## together than that group's `max_attackers`.
@export var share_tokens_with: NodePath

var is_active: bool = true

var _holders: Array = []
var _last_holder: Node = null
## Counts down (simulated physics time, not wall clock) after a release;
## reactivate_cooldown applies only while this is still positive. Using
## `delta` here keeps it correct under pause and under a forced fixed frame
## rate (tools/test.sh FPS=30), unlike Time.get_ticks_msec().
var _reactivate_timer: float = 0.0
var _waiting: Array = []
var _voice_free_frame: int = 0
var _voice: Node = null

@onready var _approach_zone: Area2D = get_node_or_null("ApproachZone")
@onready var _token_owner: EncounterGroup = get_node_or_null(share_tokens_with) as EncounterGroup if not share_tokens_with.is_empty() else null


func _ready() -> void:
	if _approach_zone or wait_for_trigger:
		is_active = false
	if _approach_zone:
		_approach_zone.body_entered.connect(_on_approach_body_entered)


func _physics_process(delta: float) -> void:
	if _reactivate_timer > 0.0:
		_reactivate_timer = maxf(0.0, _reactivate_timer - delta)
	# Drop anyone from the waiting list who died or left the tree since they
	# asked for the token, so a stale entry can't keep delaying the last
	# holder's reactivation forever (request_attack_token's `not
	# _waiting.is_empty()` check would otherwise never clear).
	_waiting = _waiting.filter(func(e): return is_instance_valid(e))
	_holders = _holders.filter(func(e): return is_instance_valid(e))


func _on_approach_body_entered(body: Node) -> void:
	if body.is_in_group("hero"):
		activate()


## Wakes the group (once): its enemies notice Dave and join the fight.
func activate() -> void:
	if is_active:
		return
	is_active = true
	activated.emit()


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


## True while `enemy` currently holds an attack token.
func holds_token(enemy: Node) -> bool:
	if _token_owner:
		return _token_owner.holds_token(enemy)
	return enemy in _holders


## How many enemies hold an attack token right now.
func attacker_count() -> int:
	if _token_owner:
		return _token_owner.attacker_count()
	return _holders.size()


## The most enemies that may attack at once from this group's token pool.
func attacker_cap() -> int:
	return _token_owner.attacker_cap() if _token_owner else max_attackers


## Requests permission to begin a windup/attack. At most `max_attackers`
## enemies in the group hold a token at a time.
func request_attack_token(enemy: Node) -> bool:
	if _token_owner:
		return _token_owner.request_attack_token(enemy)
	if enemy in _holders:
		return true
	if _holders.size() >= max_attackers:
		_mark_waiting(enemy)
		return false
	# Fairness: don't let the enemy that just released a token snatch it
	# straight back while another enemy is still waiting its turn.
	if enemy == _last_holder and not _waiting.is_empty() and _reactivate_timer > 0.0:
		_mark_waiting(enemy)
		return false
	_holders.append(enemy)
	_waiting.erase(enemy)
	return true


## One voice at a time: a group's enemies that notice Dave together (the
## lockdown fights wake two or more at once, C41) speak one line at a time,
## so their barks never pile on top of each other. True if `speaker` may
## speak now (the one already speaking always may); it then holds the voice
## for `seconds` of physics time.
func claim_voice(speaker: Node, seconds: float) -> bool:
	if _token_owner:
		return _token_owner.claim_voice(speaker, seconds)
	var f := Engine.get_physics_frames()
	if f < _voice_free_frame and is_instance_valid(_voice) and _voice != speaker:
		return false
	_voice = speaker
	_voice_free_frame = f + int(seconds * Engine.physics_ticks_per_second)
	return true


func release_attack_token(enemy: Node) -> void:
	if _token_owner:
		_token_owner.release_attack_token(enemy)
		return
	if enemy not in _holders:
		return
	_holders.erase(enemy)
	_last_holder = enemy
	_reactivate_timer = reactivate_cooldown


func _mark_waiting(enemy: Node) -> void:
	if enemy not in _waiting:
		_waiting.append(enemy)
