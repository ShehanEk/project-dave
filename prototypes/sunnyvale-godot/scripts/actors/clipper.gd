class_name Clipper
extends CharacterBody2D
## R01 Clipper: grounded gardening-robot charger. States per
## 03-gameplay-systems.md: patrol -> acquire on-plane hero -> (token) charge
## windup (both eye stalks retract, shears open) -> straight grounded charge
## (cannot turn/jump; brakes at an unmarked ledge) -> wall/backstop contact
## stalls with the rear motor exposed, OR a missed charge brakes -> recovery
## -> patrol. Front shell always blocks shots (distinct feedback); the rear
## motor only accepts damage while stalled. AttackBox (contact damage) is
## active only during the charge.

signal defeated(entity_id: String)
signal hint_requested(text: String)

enum State { PATROL, WINDUP, CHARGE, STALL, RECOVERY, DEFEATED }

const H := 96.0
const WIDTH := 64.0
const HEIGHT := 48.0
const HALF_WIDTH := WIDTH * 0.5
const HIT_FLASH_TIME := 0.15
const DEFEAT_FADE_TIME := 0.35
const HINT_DISPLAY_TIME := 2.5
const HINT_TEXT := "Its motor is exposed when it stalls."

const OUTLINE := Color("#332a20")
const SHELL := Color("#6ead48")
const IVORY := Color("#efe5cf")
const RUBBER := Color("#303b39")
const EYE_COLOR := Color("#ffb547")
const MOTOR_COLOR := Color("#8a8078")
const MOTOR_EXPOSED := Color("#d97a4a")
const HIT_FLASH := Color("#f4d78a")
const WARN_COLOR := Color("#e8b65a")

@export var tuning: ClipperTuning
@export var entity_id: String = ""
## Optional patrol leash, independent of an EncounterGroup's lane_rect, so a
## standalone Clipper (isolated test/demo scenes, no EncounterGroup
## ancestor) doesn't wander arbitrarily far on open ground while idle.
## Authored in the owning AreaRoot's local space (same space as this node's
## own position when its EncounterGroup has no offset of its own, and the
## same space every other entity in the area is placed in) — NOT this
## node's immediate parent space when that parent (the EncounterGroup) is
## itself offset from the area's origin. Defaults to unbounded.
@export var patrol_min_x: float = -INF
@export var patrol_max_x: float = INF

var state: State = State.PATROL
var facing: int = -1
var _patrol_dir: int = -1
var _lock_dir: int = -1
var _state_timer: float = 0.0
var _traveled: float = 0.0
var _motor_health: int = 3
var _motor_hit_flash_timer: float = 0.0
var _shell_hit_flash_timer: float = 0.0
var _defeat_timer: float = -1.0
var _hint_timer: float = 0.0
var _frontal_hits: int = 0
var _hint_shown: bool = false
var _group: EncounterGroup = null
var _area_root: Node2D = null

@onready var front_hit_zone: ClipperFrontHitZone = $FrontHitZone
@onready var rear_hit_zone: HitZone = $RearHitZone
## Fills the centre strip between Front/RearHitZone (R1-03/ENG-02): without
## it, a shot straight down through the shell's middle (e.g. jumping over a
## charge and firing down) passes through to the floor with no feedback.
## Always blocks; carries no damage/hint logic of its own. Sized (and fixed
## at the body's centre, independent of facing) to butt against both zones
## with no gap, and never overlaps RearHitZone so a stalled motor shot still
## resolves on the motor, not the shell.
@onready var shell_hit_zone: HitZone = $ShellHitZone
@onready var attack_box: AttackBox = $AttackBox
@onready var hint_label: Label = $HintLabel
## Untyped on purpose (M6 art pass adds no class_name — see
## scripts/actors/visuals/clipper_visual.gd).
@onready var visual = $Visual


func _ready() -> void:
	add_to_group("enemy")
	if tuning == null:
		tuning = load("res://data/tuning/clipper.tres")
	if entity_id != "" and Session and Session.is_defeated(entity_id):
		queue_free()
		return
	collision_layer = 1 << 2  # layer 3: enemy_body
	collision_mask = 1        # layer 1: world only
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	_motor_health = tuning.motor_health
	attack_box.damage = tuning.damage
	rear_hit_zone.blocks = true  # only exposed while stalled
	_group = _find_group()
	_area_root = _find_area_root()
	front_hit_zone.blocked_hit.connect(_on_front_blocked_hit)
	rear_hit_zone.hit.connect(_on_rear_hit)
	if hint_label:
		hint_label.text = HINT_TEXT
		hint_label.visible = false
	_update_zone_positions()
	queue_redraw()


func _find_group() -> EncounterGroup:
	var p := get_parent()
	while p:
		if p is EncounterGroup:
			return p
		p = p.get_parent()
	return null


## Every area scene authors patrol_min_x/max_x as AREA-local values (matching
## the Clipper's own position and every other entity in that area), even
## when the Clipper's immediate parent is an EncounterGroup offset from the
## area's own origin (e.g. A04's E07/E09). Converting through the owning
## AreaRoot (rather than just `get_parent()`) keeps the leash correct in
## both an isolated per-area test (AreaRoot at the origin) and the
## assembled level (AreaRoot offset by every preceding area's width).
func _find_area_root() -> Node2D:
	var p := get_parent()
	while p:
		if p is AreaRoot:
			return p
		p = p.get_parent()
	return null


func _physics_process(delta: float) -> void:
	if _hint_timer > 0.0:
		_hint_timer -= delta
		if _hint_timer <= 0.0 and hint_label:
			hint_label.visible = false

	if state == State.DEFEATED:
		if _defeat_timer > 0.0:
			_defeat_timer -= delta
			if _defeat_timer <= 0.0:
				queue_free()
		queue_redraw()
		_update_visual_pose(delta)
		return

	if _motor_hit_flash_timer > 0.0:
		_motor_hit_flash_timer = maxf(0.0, _motor_hit_flash_timer - delta)
	if _shell_hit_flash_timer > 0.0:
		_shell_hit_flash_timer = maxf(0.0, _shell_hit_flash_timer - delta)

	_apply_gravity(delta)
	match state:
		State.PATROL:
			_tick_patrol(delta)
		State.WINDUP:
			_tick_windup(delta)
		State.CHARGE:
			_tick_charge_pre(delta)
		State.STALL:
			_tick_stall(delta)
		State.RECOVERY:
			_tick_recovery(delta)
	_update_zone_positions()
	move_and_slide()
	if state == State.CHARGE:
		_tick_charge_post()
	queue_redraw()
	_update_visual_pose(delta)


## Presentation-only (M6): hands the current pose to Visual. Reads state
## other code already computed; writes nothing physics/logic reads back.
func _update_visual_pose(_delta: float) -> void:
	if visual == null:
		return
	if state == State.DEFEATED:
		var k: float = 1.0 - clampf(_defeat_timer / DEFEAT_FADE_TIME, 0.0, 1.0) if _defeat_timer > 0.0 else 1.0
		visual.update_pose(facing, 0.0, 0.0, 0.0, false, false, false, k)
		return

	var eye_retract := 0.0
	var shear_open := 0.0
	var lean_amount := 0.0
	if state == State.WINDUP:
		var t: float = clampf(_state_timer / maxf(0.001, tuning.windup_time), 0.0, 1.0)
		eye_retract = t
		shear_open = t
		lean_amount = t
	elif state == State.CHARGE:
		eye_retract = 1.0
		shear_open = 1.0
		lean_amount = 1.0
	elif state == State.PATROL and not is_zero_approx(velocity.x):
		lean_amount = 0.35
	visual.update_pose(facing, lean_amount, eye_retract, shear_open, is_stalled(),
			_shell_hit_flash_timer > 0.0, _motor_hit_flash_timer > 0.0, -1.0)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += tuning.gravity * delta
	else:
		velocity.y = 0.0


func _get_hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero")


func _has_line_of_sight(hero: Node2D) -> bool:
	# Aim both ends at mid-body height, not the ground plane at the feet —
	# a ray ending exactly on the floor's top surface (where global_position
	# sits for both grounded actors) can register the floor itself as the
	# "obstruction" right at the target.
	var eye: Vector2 = global_position + Vector2(0.0, -HEIGHT * 0.75)
	var target: Vector2 = hero.global_position + Vector2(0.0, -Hero.H * 0.5)
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(eye, target)
	params.collision_mask = 1  # world only
	return space_state.intersect_ray(params).is_empty()


func _tick_patrol(_delta: float) -> void:
	var hero := _get_hero()
	if hero != null and (_group == null or _group.is_active):
		var dx: float = hero.global_position.x - global_position.x
		var dy: float = hero.global_position.y - global_position.y
		var same_floor: bool = absf(dy) <= tuning.floor_band
		if same_floor and absf(dx) <= tuning.acquire_range and _has_line_of_sight(hero):
			var dir: int = 1 if dx >= 0.0 else -1
			var can_attack: bool = _group == null or _group.request_attack_token(self)
			if can_attack:
				_enter_windup(dir)
			else:
				facing = dir
				velocity.x = 0.0
			return

	velocity.x = _patrol_dir * tuning.patrol_speed
	var next_x: float = global_position.x + _patrol_dir * 24.0
	var blocked_by_lane: bool = _group != null and not _group.is_in_lane(Vector2(next_x, global_position.y))
	# patrol_min_x/max_x are authored as AREA-local values (matching this
	# Clipper's own position and every other entity in the area), but the
	# assembled level offsets every area by its cumulative x, so comparing
	# against global_position.x directly reads as "out of leash" on every
	# step and flips facing every frame. Convert through the owning AreaRoot
	# (falling back to the immediate parent for an isolated test/demo scene
	# with no AreaRoot ancestor) before comparing.
	var leash_space: Node2D = _area_root if _area_root else (get_parent() as Node2D)
	# No AreaRoot ancestor AND a non-Node2D parent (e.g. a plain Node the
	# test attaches the Clipper directly under): there is no meaningful
	# "local" space to convert through, so compare in global space as
	# before — patrol_min_x/max_x default to unbounded, so this only
	# matters for a test that sets them without also giving the Clipper a
	# Node2D parent.
	var next_local_x: float = leash_space.to_local(Vector2(next_x, global_position.y)).x if leash_space else next_x
	var blocked_by_leash: bool = next_local_x < patrol_min_x or next_local_x > patrol_max_x
	if not _floor_ahead(_patrol_dir) or _wall_ahead(_patrol_dir) or blocked_by_lane or blocked_by_leash:
		_patrol_dir = -_patrol_dir
		velocity.x = 0.0
		Audio.play_sfx(&"clipper_scrape", global_position)
	facing = _patrol_dir


func _enter_windup(dir: int) -> void:
	state = State.WINDUP
	_state_timer = 0.0
	_lock_dir = dir
	facing = dir
	velocity.x = 0.0
	Audio.play_sfx(&"clipper_windup", global_position)


func _tick_windup(delta: float) -> void:
	velocity.x = 0.0
	_state_timer += delta
	if _state_timer >= tuning.windup_time:
		_enter_charge()


func _enter_charge() -> void:
	state = State.CHARGE
	_state_timer = 0.0
	_traveled = 0.0
	attack_box.active = true
	Audio.play_sfx(&"clipper_charge", global_position)


func _tick_charge_pre(delta: float) -> void:
	if not _floor_ahead(_lock_dir):
		_enter_brake_recovery()
		return
	velocity.x = _lock_dir * tuning.charge_speed()
	_state_timer += delta
	_traveled += tuning.charge_speed() * delta


func _tick_charge_post() -> void:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var n := col.get_normal()
		if n.x * float(_lock_dir) < -0.3:
			_enter_stall()
			return
	if _traveled >= tuning.charge_max_distance():
		_enter_brake_recovery()


func _enter_stall() -> void:
	state = State.STALL
	attack_box.active = false
	velocity = Vector2.ZERO
	_state_timer = 0.0
	rear_hit_zone.blocks = false
	Audio.play_sfx(&"clipper_stall", global_position)
	# The token is held only through windup/active-attack (03: combat
	# fairness); release it now so another enemy can take its turn while
	# this one sits stalled/recovering.
	if _group != null:
		_group.release_attack_token(self)


func _tick_stall(delta: float) -> void:
	velocity.x = 0.0
	_state_timer += delta
	if _state_timer >= tuning.wall_stall_time:
		rear_hit_zone.blocks = true
		state = State.RECOVERY
		_state_timer = 0.0


func _enter_brake_recovery() -> void:
	attack_box.active = false
	velocity.x = 0.0
	state = State.RECOVERY
	_state_timer = 0.0
	if _group != null:
		_group.release_attack_token(self)


func _tick_recovery(delta: float) -> void:
	velocity.x = 0.0
	_state_timer += delta
	if _state_timer >= tuning.missed_charge_recovery_time:
		state = State.PATROL


func _floor_ahead(dir: int) -> bool:
	var probe_x: float = global_position.x + dir * (HALF_WIDTH + 6.0)
	var from := Vector2(probe_x, global_position.y - 4.0)
	var to := Vector2(probe_x, global_position.y + 40.0)
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(from, to)
	params.collision_mask = 1
	return not space_state.intersect_ray(params).is_empty()


func _wall_ahead(dir: int) -> bool:
	var y: float = global_position.y - HEIGHT * 0.5
	var from_x: float = global_position.x + dir * (HALF_WIDTH - 2.0)
	var to_x: float = global_position.x + dir * (HALF_WIDTH + 10.0)
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(Vector2(from_x, y), Vector2(to_x, y))
	params.collision_mask = 1
	return not space_state.intersect_ray(params).is_empty()


func _update_zone_positions() -> void:
	var f := float(facing)
	front_hit_zone.position = Vector2(f * (HALF_WIDTH - 6.0), -HEIGHT * 0.55)
	rear_hit_zone.position = Vector2(-f * (HALF_WIDTH - 8.0), -HEIGHT * 0.55)
	# Fixed at the body's centre: Front/Rear already mirror around x=0 as
	# facing flips, so the gap between them is always this same central
	# strip regardless of facing — no f-dependence needed here.
	shell_hit_zone.position = Vector2(0.0, -HEIGHT * 0.55)
	attack_box.position = Vector2(f * (HALF_WIDTH + 6.0), -HEIGHT * 0.5)


func _on_front_blocked_hit() -> void:
	if state == State.DEFEATED:
		return
	_shell_hit_flash_timer = HIT_FLASH_TIME
	_frontal_hits += 1
	if _frontal_hits >= tuning.frontal_hint_threshold and not _hint_shown:
		_hint_shown = true
		hint_requested.emit(HINT_TEXT)
		if hint_label:
			hint_label.visible = true
		_hint_timer = HINT_DISPLAY_TIME


func _on_rear_hit(damage: int, _hit_position: Vector2, _direction: Vector2) -> void:
	if state == State.DEFEATED:
		return
	_motor_health -= damage
	_motor_hit_flash_timer = HIT_FLASH_TIME
	if _motor_health <= 0:
		_defeat()


func _defeat() -> void:
	if state == State.DEFEATED:
		return
	state = State.DEFEATED
	attack_box.active = false
	front_hit_zone.monitorable = false
	rear_hit_zone.monitorable = false
	shell_hit_zone.monitorable = false
	velocity = Vector2.ZERO
	if _group != null:
		_group.release_attack_token(self)
	if entity_id != "" and Session:
		Session.mark_defeated(entity_id)
	Audio.play_sfx(&"clipper_defeat", global_position)
	defeated.emit(entity_id)
	_defeat_timer = DEFEAT_FADE_TIME
	queue_redraw()


func is_stalled() -> bool:
	return state == State.STALL


func is_windup_active() -> bool:
	return state == State.WINDUP


func is_charging() -> bool:
	return state == State.CHARGE


# --- warning overlay ----------------------------------------------------------
# The character body itself is rendered by the "Visual" child node
# (scripts/actors/visuals/clipper_visual.gd); this root still draws the
# windup warning triangle directly since it's anchored to gameplay timing,
# not to the character art.

func _draw() -> void:
	if state == State.WINDUP:
		_draw_warning()


func _draw_warning() -> void:
	# Interface-and-accessibility.md / M6: reduced-motion keeps the (shape-
	# based) warning fully visible but drops the pulsing animation.
	var settings := get_node_or_null("/root/Settings")
	var reduced_motion: bool = settings != null and settings.get_reduced_motion()
	# AD-05 fix: never dips below 0.8 alpha now (was 0.2), plus an outline
	# stroke, matching resident.gd's own warning-triangle fix — measured
	# contrast against sky/lawn/wall backdrops was under 2:1 at the old low
	# point. Also raised further above the ~80px-tall body sprite (was
	# -HEIGHT-30 = -78, inside the sprite's own bounds and paintable-over by
	# the child Visual node's eye-stalk overlay) so it always clears it.
	var pulse: float = 0.95 if reduced_motion else 0.9 + 0.1 * sin(_state_timer * TAU * 3.0)
	var c := WARN_COLOR
	c.a = pulse
	var top := Vector2(0.0, -HEIGHT - 48.0)
	var pts := PackedVector2Array([
		top + Vector2(-8.0, 14.0), top + Vector2(8.0, 14.0), top + Vector2(0.0, -6.0),
	])
	draw_colored_polygon(pts, c)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), OUTLINE, 2.0, true)
	draw_rect(Rect2(top + Vector2(-1.5, -2.0), Vector2(3.0, 8.0)), OUTLINE)
	draw_circle(top + Vector2(0.0, 10.0), 1.6, OUTLINE)
