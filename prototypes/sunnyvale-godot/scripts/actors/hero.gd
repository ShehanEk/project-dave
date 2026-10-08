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
var _move_dir: int = 0
var _aim_face_timer: float = 0.0
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
## The pixel UI helper (no class_name): backs PromptLabel with the pixel
## prompt tag (`dress_prompt_label()`), keeping the plain label without the art.
const PixelUi := preload("res://scripts/ui/pixel_ui.gd")
## What he is standing on -> the footstep cue (no class_name, like PixelUi).
const SurfaceMap := preload("res://scripts/world/surface_map.gd")

# --- presentation-only state (M6): read by Visual, never by physics/logic ---
const LAND_SQUASH_TIME := 0.12
## Horizontal distance (px) from the hero within which the aim no longer
## flips the facing (cursor straight above/below).
const FACING_DEADZONE := 8.0
## Seconds the body keeps facing the aim after the last shot, so tapping fire
## while running away doesn't spin him round between shots.
const FIRE_FACING_HOLD := 0.4
## The gun's rest angle (rad, below level) while he runs away from the aim.
const ARM_REST_DROP := 0.35
const HIT_POSE_TIME := 0.2
const INTERACT_POSE_TIME := 0.35
## Horizontal speed (px/s) above which he counts as moving on the ground: the
## run cycle plays, and footsteps are counted.
const MOVING_SPEED := 4.0
## Radians the run cycle's stride phase advances per px run (one cycle = TAU).
const STRIDE_PHASE_PER_PX := 0.045
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
## Untyped on purpose (M6 art pass adds no class_name — see hero_visual.gd;
## hero.tscn attaches hero_rig_visual.gd, which extends it):
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
	PixelUi.dress_prompt_label(prompt_label)
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

	_update_facing(delta)
	_update_immunity(delta)
	# Visual first: it picks this tick's sprite frame, and AimPivot then
	# snaps to that frame's shoulder (no one-tick lag between arm and body).
	_update_visual_pose(delta)
	_update_footsteps(delta)
	_update_aim_pivot()


## Presentation-only bookkeeping (M6): stride phase for the procedural walk
## cycle and the land-squash/hit-pose/interact-pose timers, then hands the
## whole pose to Visual. Reads state other code already computed; never
## writes anything physics/logic reads back.
func _update_visual_pose(delta: float) -> void:
	_land_squash_timer = maxf(0.0, _land_squash_timer - delta)
	_hit_pose_timer = maxf(0.0, _hit_pose_timer - delta)
	_interact_pose_timer = maxf(0.0, _interact_pose_timer - delta)

	var moving := is_on_floor() and absf(velocity.x) > MOVING_SPEED
	if moving:
		# Signed: moving toward the facing side advances the run cycle,
		# moving away from it (backpedalling toward the aim) runs it backward.
		_stride_phase += velocity.x * float(facing) * delta * STRIDE_PHASE_PER_PX
	if visual:
		visual.update_pose(facing, moving, is_on_floor(), velocity.y, _stride_phase,
				_is_firing, is_immune(), _died_emitted, _land_squash_timer,
				_hit_pose_timer, _interact_pose_timer)


# --- footsteps (presentation-only, like the stride above) -----------------------

## Ground distance (px) between two footfalls: one foot contact of the run
## cycle (the cycle is TAU of stride phase and plants a foot every half of it),
## so the sound lands on the foot the rig plants. About 70 px, which is 5.5
## steps a second at the 384 px/s run speed, the same cadence as the legs.
const FOOTSTEP_STRIDE := PI / STRIDE_PHASE_PER_PX
## Distance (px) after starting to move (or after a landing squash) to the
## first step, so a walk sounds at once instead of a full stride later.
const FIRST_FOOTSTEP_DISTANCE := 14.0
## The floor probe: a ray from this far above his feet to this far below them,
## on the world layer, run only when a step sounds.
const FLOOR_PROBE_UP := 8.0
const FLOOR_PROBE_DOWN := 16.0

## Steps sounded so far and the cue of the latest one (tests read these).
var footsteps_played: int = 0
var last_footstep_cue: StringName = &""
var _step_distance: float = FOOTSTEP_STRIDE - FIRST_FOOTSTEP_DISTANCE
var _floor_probe: PhysicsRayQueryParameters2D = null


## One footstep per FOOTSTEP_STRIDE of ground run under his own power. None
## while standing, airborne, pushed against a wall, dead, with input off (a
## modal or cutscene), or in the hurt, interact or landing poses, which are the
## moments the rig is not showing the run cycle. Standing or airborne primes the
## distance so the first step of the next run follows FIRST_FOOTSTEP_DISTANCE.
func _update_footsteps(delta: float) -> void:
	var running := (is_on_floor() and _move_dir != 0 and absf(velocity.x) > MOVING_SPEED
			and not _died_emitted and _hit_pose_timer <= 0.0 and _interact_pose_timer <= 0.0
			and _land_squash_timer <= 0.0)
	if not running:
		_step_distance = FOOTSTEP_STRIDE - FIRST_FOOTSTEP_DISTANCE
		return
	_step_distance += absf(velocity.x) * delta
	if _step_distance >= FOOTSTEP_STRIDE:
		_step_distance -= FOOTSTEP_STRIDE
		_play_footstep()


func _play_footstep() -> void:
	var cue := _surface_cue()
	footsteps_played += 1
	last_footstep_cue = cue
	Audio.play_sfx(cue, global_position)


## The footstep cue for the floor under his feet (SurfaceMap): a short ray
## down finds the block or platform, so the roofs' paving run-in and landing
## differ from their slabs. DEFAULT (paving) when nothing is found, such as in
## an isolated test scene with no AreaRoot.
func _surface_cue() -> StringName:
	if _floor_probe == null:
		_floor_probe = PhysicsRayQueryParameters2D.new()
		_floor_probe.collision_mask = 1  # layer 1: world
	_floor_probe.from = global_position + Vector2(0.0, -FLOOR_PROBE_UP)
	_floor_probe.to = global_position + Vector2(0.0, FLOOR_PROBE_DOWN)
	var hit := get_world_2d().direct_space_state.intersect_ray(_floor_probe)
	return SurfaceMap.for_collider(hit.get("collider", null))


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
	_move_dir = int(dir)

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


## Running faces the way he runs; standing still, or shooting (and for
## FIRE_FACING_HOLD after the last shot), faces the aim, so shooting while
## backing off backpedals (the run cycle plays in reverse — see
## _update_visual_pose). While he runs away from the aim the gun rests
## pointing ahead (_update_aim_pivot), never backwards across his body.
## Playtest 2026-09-30 ("going backward, he should face that way"); this is
## G02's rule plus the rest pose that fixes the 2026-09-28 "hand points
## backwards" report. Within FACING_DEADZONE of straight up/down the aim
## holds the facing.
func _update_facing(delta: float) -> void:
	_aim_face_timer = FIRE_FACING_HOLD if _is_firing else maxf(0.0, _aim_face_timer - delta)
	if _move_dir != 0 and _aim_face_timer <= 0.0:
		facing = _move_dir
		return
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
	if to_aim.x * facing < -FACING_DEADZONE:
		# Aim behind him while he runs the other way: the gun rests ahead.
		aim_pivot.rotation = ARM_REST_DROP if facing > 0 else PI - ARM_REST_DROP
		aim_pivot.scale.y = float(facing)
	elif to_aim.length() > 0.5:
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

# --- visual: scripts/actors/visuals/hero_rig_visual.gd (child node "Visual"; ----
# --- Dave's pixel rig, falling back to hero_visual.gd's Rook frames) ---------
