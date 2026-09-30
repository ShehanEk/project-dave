class_name Hero
extends CharacterBody2D
## The solo hero. Movement/physics only lives here; no story logic (per
## CONVENTIONS.md). Health is authoritative in Session; the hero only owns
## immunity timing, knockback, and the visible tint while immune.

signal died

const H := 96.0

@export var tuning: HeroTuning
@export var input_enabled: bool = true
## Debug-only: take_damage() and fall_to() do nothing while true (area
## traversal tests/route-bot runs; never set true in normal play).
@export var debug_invulnerable: bool = false

## Overridable aim for tests/demos in place of the live mouse cursor.
@export var use_aim_override: bool = false
@export var aim_override: Vector2 = Vector2.ZERO

var facing: int = 1  # +1 right, -1 left
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _was_on_floor: bool = false
var _jump_held: bool = false

var _immune_timer: float = 0.0
var _knockback: Vector2 = Vector2.ZERO
var _died_emitted: bool = false
var _is_firing: bool = false
var _jumped_this_frame: bool = false

## M6.5 Kenney integration pass: seconds spent with `_was_on_floor` false,
## used only to gate the landing-dust puff below to a "real fall" (a jump or
## an off-ledge drop) rather than firing on a bare floor-state flicker (e.g.
## the tick right after `respawn_at()` teleports the hero, which does not
## reset `_was_on_floor` — ADV-note pattern elsewhere in this file). Purely
## cosmetic; never read by movement/physics.
var _air_time: float = 0.0
const REAL_FALL_AIR_TIME := 0.12
## No class_name on the puff script (see its own doc comment) — reached
## through this plain preload + its static `spawn()`.
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")

# --- presentation-only state (M6): read by Visual, never by physics/logic ---
const LAND_SQUASH_TIME := 0.12
## Horizontal distance (px) from the hero within which the aim no longer
## flips the facing (cursor straight above/below).
const FACING_DEADZONE := 8.0
const HIT_POSE_TIME := 0.2
const INTERACT_POSE_TIME := 0.35
var _stride_phase: float = 0.0
var _land_squash_timer: float = 0.0
var _hit_pose_timer: float = 0.0
var _interact_pose_timer: float = 0.0

## Edge detection for "jump"/"interact" is done by hand from the level state
## sampled once per physics tick, not via is_action_just_pressed/released.
## Those engine helpers stamp separate idle/physics frame counters, which can
## fall a tick behind when input is driven headlessly at a variable frame
## rate (tools/test.sh without --fixed-fps) — this keeps behavior identical
## under FPS=30 and uncapped runs alike.
var _jump_was_pressed: bool = false
var _interact_was_pressed: bool = false

@onready var hurtbox: Area2D = $Hurtbox
@onready var interact_sensor: Area2D = $InteractSensor
@onready var prompt_label: Label = $PromptLabel
@onready var aim_pivot: Node2D = $AimPivot
## Untyped on purpose (M6 art pass adds no class_name — see hero_visual.gd):
## calling its update_pose()/setup() below is a dynamic dispatch that needs
## no static type resolved through the (unrefreshed during this pass) import
## cache.
@onready var visual = $Visual


func _ready() -> void:
	add_to_group("hero")
	if tuning == null:
		tuning = load("res://data/tuning/hero.tres")
	collision_layer = 1 << 1  # layer 2: hero_body
	collision_mask = 1        # layer 1: world
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_DO_NOTHING
	if Session:
		Session.health_changed.connect(_on_health_changed)
	prompt_label.visible = false
	if visual:
		visual.setup(aim_pivot)


func _exit_tree() -> void:
	if Session and Session.health_changed.is_connected(_on_health_changed):
		Session.health_changed.disconnect(_on_health_changed)


func _physics_process(delta: float) -> void:
	_jumped_this_frame = false
	if not _was_on_floor:
		_air_time += delta
	else:
		_air_time = 0.0
	_is_firing = input_enabled and Input.is_action_pressed("fire")
	if input_enabled:
		_handle_jump_input()
	_update_interact_prompt()
	_apply_gravity(delta)
	_handle_jump_takeoff()
	_handle_horizontal(delta)
	_apply_knockback_decay(delta)

	var was_on_floor := is_on_floor()
	move_and_slide()

	if is_on_ceiling() and velocity.y < 0.0:
		velocity.y = 0.0

	var landed_this_tick := is_on_floor() and not _was_on_floor
	if landed_this_tick:
		Audio.play_sfx(&"hero_land", global_position)
		_land_squash_timer = LAND_SQUASH_TIME
		if _air_time > REAL_FALL_AIR_TIME:
			var host := get_tree().current_scene if get_tree().current_scene else get_tree().root
			KenneyPuff.spawn(&"landing_dust", global_position, host)

	if is_on_floor():
		_coyote_timer = tuning.coyote_time
	elif was_on_floor and not _jumped_this_frame:
		# Left the floor by walking off (not by jumping): start coyote grace.
		_coyote_timer = tuning.coyote_time
	else:
		_coyote_timer = maxf(0.0, _coyote_timer - delta)

	_jump_buffer_timer = maxf(0.0, _jump_buffer_timer - delta)
	_was_on_floor = is_on_floor()

	_update_facing()
	_update_immunity(delta)
	# Visual first: it picks this tick's sprite frame, and AimPivot then
	# snaps to that frame's shoulder (no one-tick lag between arm and body).
	_update_visual_pose(delta)
	_update_aim_pivot()


## Presentation-only bookkeeping (M6): stride phase for the procedural walk
## cycle and the land-squash/hit-pose/interact-pose timers, then hands the
## whole pose to Visual. Reads state other code already computed; never
## writes anything physics/logic reads back.
func _update_visual_pose(delta: float) -> void:
	_land_squash_timer = maxf(0.0, _land_squash_timer - delta)
	_hit_pose_timer = maxf(0.0, _hit_pose_timer - delta)
	_interact_pose_timer = maxf(0.0, _interact_pose_timer - delta)

	var moving := is_on_floor() and absf(velocity.x) > 4.0
	if moving:
		# Signed: moving toward the facing side advances the run cycle,
		# moving away from it (backpedalling toward the aim) runs it backward.
		_stride_phase += velocity.x * float(facing) * delta * 0.045
	if visual:
		visual.update_pose(facing, moving, is_on_floor(), velocity.y, _stride_phase,
				_is_firing, is_immune(), _died_emitted, _land_squash_timer,
				_hit_pose_timer, _interact_pose_timer)


# --- movement ---------------------------------------------------------------

func _handle_jump_input() -> void:
	var pressed := Input.is_action_pressed("jump")
	if pressed and not _jump_was_pressed:
		_jump_buffer_timer = tuning.jump_buffer_time
		_jump_held = true
	elif not pressed and _jump_was_pressed:
		_jump_held = false
		if velocity.y < 0.0:
			velocity.y *= tuning.jump_cut_multiplier
	_jump_was_pressed = pressed


func _handle_jump_takeoff() -> void:
	if _jump_buffer_timer > 0.0 and (is_on_floor() or _coyote_timer > 0.0):
		velocity.y = -tuning.jump_velocity()
		# A buffered jump can take off on a later tick than the press: if
		# "jump" was already released before this takeoff happens (tapped
		# while still airborne, inside the buffer window), apply the same
		# early-release cut here that a grounded tap gets immediately, so a
		# released buffered tap is a short hop too, not a full-height jump.
		if not _jump_held:
			velocity.y *= tuning.jump_cut_multiplier
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_jumped_this_frame = true
		Audio.play_sfx(&"hero_jump", global_position)


func _apply_gravity(delta: float) -> void:
	var g: float = tuning.fall_gravity() if velocity.y > 0.0 else tuning.gravity()
	if not is_on_floor():
		velocity.y += g * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0


func _handle_horizontal(delta: float) -> void:
	var dir := 0.0
	if input_enabled:
		if Input.is_action_pressed("move_left"):
			dir -= 1.0
		if Input.is_action_pressed("move_right"):
			dir += 1.0

	var target_speed := dir * tuning.run_speed
	var accel: float
	if is_on_floor():
		accel = tuning.ground_acceleration if dir != 0.0 else tuning.ground_deceleration
	else:
		accel = tuning.air_acceleration if dir != 0.0 else tuning.air_deceleration

	# Steering only ever controls the "control" part of velocity.x; the
	# knockback impulse rides on top and decays on its own (see
	# _apply_knockback_decay), so braking input can't cancel a knockback pop.
	var control_velocity := velocity.x - _knockback.x
	control_velocity = move_toward(control_velocity, target_speed, accel * delta)
	velocity.x = control_velocity + _knockback.x


func _apply_knockback_decay(delta: float) -> void:
	_knockback = _knockback.move_toward(Vector2.ZERO, 900.0 * delta)


## The body always faces the side the aim is on, so the gun arm never twists
## back across the body; moving away from the aim backpedals (the run cycle
## plays in reverse — see _update_visual_pose). Playtest change 2026-09-28:
## G02 proposed "facing follows aim while firing and movement otherwise",
## which left the arm pointing backwards whenever the mouse was behind a
## moving hero. Within FACING_DEADZONE of straight up/down the facing holds.
func _update_facing() -> void:
	var dx := get_current_aim().x - global_position.x
	if absf(dx) > FACING_DEADZONE:
		facing = 1 if dx > 0.0 else -1


## World-space aim target: the overridable value in tests/demos, otherwise
## the live mouse cursor projected into world space.
func get_current_aim() -> Vector2:
	if use_aim_override:
		return aim_override
	var vp := get_viewport()
	return vp.get_camera_2d().get_global_mouse_position() if vp and vp.get_camera_2d() else get_global_mouse_position()


func set_firing(firing: bool) -> void:
	_is_firing = firing


## Rotates the weapon pivot toward the current aim; flips it vertically
## (rather than upside-down) when aiming left, a standard 2D top-down/side
## aim trick that keeps the held weapon's silhouette right-side up.
func _update_aim_pivot() -> void:
	if aim_pivot == null:
		return
	# The pivot is the near shoulder of the current sprite frame (the arm
	# rotates around it and holds the Scrapjack), so it follows the pose —
	# lower while running, crouching or kneeling.
	if visual and visual.has_method("shoulder_offset"):
		aim_pivot.position = visual.shoulder_offset()
	var to_aim := get_current_aim() - aim_pivot.global_position
	if to_aim.length() > 0.5:
		aim_pivot.rotation = to_aim.angle()
		aim_pivot.scale.y = 1.0 if to_aim.x >= 0.0 else -1.0


# --- damage / health ---------------------------------------------------------

func take_damage(amount: int, source_position: Vector2) -> bool:
	if debug_invulnerable:
		return false
	# Gated on `_died_emitted` (THIS hero instance already died and hasn't
	# been respawned yet — see respawn_at()), never on a bare
	# `Session.get_health() <= 0` read (ADV-07): those two used to be treated
	# as equivalent, but they aren't — a snapshot loaded straight from disk
	# can start a BRAND NEW hero instance already at 0 health (e.g. a
	# tampered/corrupt save; CheckpointService.validate_snapshot() now
	# refuses to persist health 0 in the first place, but this is the hero's
	# own defense in depth) with `_died_emitted` still false, and that hero
	# must still be damageable, not permanently stuck. A hero that genuinely
	# died THIS run (`_died_emitted` true) correctly keeps refusing further
	# hits until `respawn_at()` resets the flag, matching test_m1_damage's
	# "take_damage while already dead is refused" contract.
	if _immune_timer > 0.0 or _died_emitted:
		return false
	Session.apply_damage(amount)
	_immune_timer = tuning.damage_immunity_time
	_hit_pose_timer = HIT_POSE_TIME
	Audio.play_sfx(&"hero_hurt", global_position)
	var away := (global_position - source_position)
	away.y = 0.0
	away = away.normalized() if away.length() > 0.001 else Vector2(-facing, 0.0)
	_knockback = away * tuning.knockback_speed
	velocity.y = -tuning.knockback_up_speed
	return true


func fall_to(safe_position: Vector2, damage: int) -> void:
	# Same immunity window a normal hit gets (tuning.damage_immunity_time),
	# and — unlike a plain re-trigger of take_damage() — checked here too:
	# without gating on `_immune_timer`, a hazard whose trigger area is even
	# slightly reachable from its own reset foothold re-fires body_entered
	# (and therefore another fall_to() call, with its own fresh damage) on
	# every full walk cycle back into it, so one pit could still cost more
	# than one health in quick succession even with the timer set. Still
	# always repositions the hero (a hazard trigger area is never a place to
	# leave them standing), just without stacking extra damage while immune.
	if not debug_invulnerable and _immune_timer <= 0.0:
		Session.apply_damage(damage)
		_immune_timer = tuning.damage_immunity_time
	respawn_at(safe_position)


func respawn_at(position: Vector2) -> void:
	global_position = position
	# A teleport, not motion: don't let physics interpolation draw a slide
	# from the old position (checkpoint respawns, pit resets).
	reset_physics_interpolation()
	velocity = Vector2.ZERO
	_knockback = Vector2.ZERO
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	# This life's death (if any) has been handled and the hero repositioned;
	# allow `died` to fire again on a future death (LevelDirector calls this
	# once per respawn, so without the reset a second death would never
	# re-emit `died` and the level would never rebuild again).
	_died_emitted = false


func _on_health_changed(current: int, _maximum: int) -> void:
	if current <= 0 and not _died_emitted:
		_died_emitted = true
		died.emit()


## Gentle warm tint while immune (was 1.0/0.55/0.55, sized for the old flat
## blockout hero; on the detailed Rook sprite that read as sunburnt). The
## hurt pose is the main cue; this only marks the ~1 s immunity window.
const IMMUNE_TINT := Color(1.0, 0.86, 0.8)
const NORMAL_TINT := Color(1.0, 1.0, 1.0)


func _update_immunity(delta: float) -> void:
	if _immune_timer > 0.0:
		_immune_timer = maxf(0.0, _immune_timer - delta)
	# A steady tint while immune, no rapid flashing (per CONVENTIONS.md).
	modulate = IMMUNE_TINT if _immune_timer > 0.0 else NORMAL_TINT


func is_immune() -> bool:
	return _immune_timer > 0.0


# --- interaction --------------------------------------------------------------

var _highlighted: Interactable = null


func _update_interact_prompt() -> void:
	var best: Interactable = null
	var best_dist := INF
	for area in interact_sensor.get_overlapping_areas():
		if area is Interactable and area.can_interact(self):
			var d := area.global_position.distance_squared_to(global_position)
			if d < best_dist:
				best_dist = d
				best = area
	if best != _highlighted:
		if _highlighted:
			_highlighted.set_highlighted(false)
		_highlighted = best
		if _highlighted:
			_highlighted.set_highlighted(true)
	# PromptLabel keeps its authored hero-relative offset (hero.tscn), clear
	# above the hero's own head. It used to be re-placed 64 px above the
	# interactable's origin, which for floor-level objects the hero stands
	# beside (console, workbench, pad) landed it on the hero's torso.
	if _highlighted and not _highlighted.is_showing_toast():
		prompt_label.text = _highlighted.get_prompt()
		prompt_label.visible = true
	else:
		prompt_label.visible = false

	var interact_pressed := Input.is_action_pressed("interact")
	if input_enabled and _highlighted and interact_pressed and not _interact_was_pressed:
		Audio.play_sfx(&"interact", global_position)
		_highlighted.interact(self)
		_interact_pose_timer = INTERACT_POSE_TIME
	_interact_was_pressed = interact_pressed

# --- visual: scripts/actors/visuals/hero_visual.gd (child node "Visual") ----
