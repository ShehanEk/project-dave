class_name Resident
extends CharacterBody2D
## Z01 Resident: slow shambler. States per 03-gameplay-systems.md:
## idle/patrol -> slow approach -> (token) lunge windup -> short committed
## lunge -> recovery -> approach. Whole body is the damaging-capable HitZone
## (it can be shot anywhere); the hero is only ever hurt through AttackBox,
## active solely during LUNGE, never from body overlap (layer 3 masks only
## layer 1 world — enemies and the hero never body-block each other).

signal defeated(entity_id: String)

enum State { APPROACH, WINDUP, LUNGE, RECOVERY, DEFEATED }

const H := 96.0
const WIDTH := 48.0
const HEIGHT := 84.0
const HALF_WIDTH := WIDTH * 0.5
const HIT_FLASH_TIME := 0.15
const DEFEAT_FADE_TIME := 0.35

const OUTLINE := Color("#332a20")
const SKIN := Color("#9aaa88")
const CARDIGAN := Color("#c98979")
const SHIRT := Color("#dcd1b9")
const TROUSERS := Color("#658f8a")
const HIT_FLASH := Color("#f4d78a")
const WARN_COLOR := Color("#e8b65a")

## Lunge AttackBox size (must match the RectangleShape2D in resident.tscn).
const ATTACK_BOX_SIZE := Vector2(56.0, 60.0)
## How far the AttackBox's near edge reaches back into the body, so it tiles
## flush against the body with no gap on the facing side.
const ATTACK_BOX_OVERLAP := 14.0

@export var tuning: ResidentTuning
@export var entity_id: String = ""

var state: State = State.APPROACH
var facing: int = -1
var _state_timer: float = 0.0
var _lunge_dir: int = -1
var _lunge_traveled: float = 0.0
var _health: int = 3
var _hit_flash_timer: float = 0.0
var _defeat_timer: float = -1.0
var _group: EncounterGroup = null

@onready var hit_zone: HitZone = $HitZone
@onready var attack_box: AttackBox = $AttackBox
## Untyped on purpose (M6 art pass adds no class_name — see
## scripts/actors/visuals/resident_visual.gd).
@onready var visual = $Visual
var _walk_phase: float = 0.0


func _ready() -> void:
	add_to_group("enemy")
	if tuning == null:
		tuning = load("res://data/tuning/resident.tres")
	if entity_id != "" and Session and Session.is_defeated(entity_id):
		queue_free()
		return
	collision_layer = 1 << 2  # layer 3: enemy_body
	collision_mask = 1        # layer 1: world only (never body-blocks the hero)
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	_health = tuning.health
	attack_box.damage = tuning.damage
	_group = _find_group()
	hit_zone.hit.connect(_on_hit)
	queue_redraw()


func _find_group() -> EncounterGroup:
	var p := get_parent()
	while p:
		if p is EncounterGroup:
			return p
		p = p.get_parent()
	return null


func _physics_process(delta: float) -> void:
	if state == State.DEFEATED:
		if _defeat_timer > 0.0:
			_defeat_timer -= delta
			if _defeat_timer <= 0.0:
				queue_free()
		queue_redraw()
		_update_visual_pose(delta)
		return

	if _hit_flash_timer > 0.0:
		_hit_flash_timer = maxf(0.0, _hit_flash_timer - delta)

	_apply_gravity(delta)
	match state:
		State.APPROACH:
			_tick_approach(delta)
		State.WINDUP:
			_tick_windup(delta)
		State.LUNGE:
			_tick_lunge(delta)
		State.RECOVERY:
			_tick_recovery(delta)
	_update_attack_box_position()
	move_and_slide()
	queue_redraw()
	_update_visual_pose(delta)


## Presentation-only (M6): hands the current pose to Visual. Reads state
## other code already computed; writes nothing physics/logic reads back.
func _update_visual_pose(delta: float) -> void:
	if visual == null:
		return
	if state == State.DEFEATED:
		var k: float = 1.0 - clampf(_defeat_timer / DEFEAT_FADE_TIME, 0.0, 1.0) if _defeat_timer > 0.0 else 1.0
		visual.update_pose(facing, false, _walk_phase, 0.0, false, 0.0, k)
		return

	var moving: bool = state == State.APPROACH and not is_zero_approx(velocity.x)
	if moving:
		_walk_phase += absf(velocity.x) * delta * 0.06
	var lean: float = 0.0
	if state == State.WINDUP:
		lean = clampf(_state_timer / maxf(0.001, tuning.windup_time), 0.0, 1.0)
	elif state == State.LUNGE:
		lean = 1.0
	var use_procedural: bool = state == State.WINDUP or state == State.LUNGE
	visual.update_pose(facing, moving, _walk_phase, lean, use_procedural, _hit_flash_timer, -1.0)


## Keeps the lunge AttackBox on the facing/lunge side of the body only, so it
## can never reach a hero standing behind the Resident (03 combat fairness:
## damage only from explicit attack hitboxes the warning points toward).
func _update_attack_box_position() -> void:
	var dir: int = _lunge_dir if state == State.LUNGE else facing
	var f: float = float(dir)
	var box_half_width: float = ATTACK_BOX_SIZE.x * 0.5
	attack_box.position = Vector2(f * (HALF_WIDTH + box_half_width - ATTACK_BOX_OVERLAP), -46.0)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += tuning.gravity * delta
	else:
		velocity.y = 0.0


func _get_hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero")


func _tick_approach(_delta: float) -> void:
	velocity.x = 0.0
	var hero := _get_hero()
	if hero == null:
		return
	if _group != null and not _group.is_active:
		return  # not yet activated: idle in place

	var dx: float = hero.global_position.x - global_position.x
	var dy: float = hero.global_position.y - global_position.y
	var same_floor: bool = absf(dy) <= tuning.floor_band

	if same_floor and absf(dx) <= tuning.engage_range:
		facing = 1 if dx >= 0.0 else -1
		var can_attack: bool = _group == null or _group.request_attack_token(self)
		if can_attack:
			_enter_windup(facing)
		return

	var dir: int = 1 if dx > 0.0 else -1
	if _group != null and not _group.allows_step(global_position, dir):
		dir = 0
	if dir != 0 and not _floor_ahead(dir):
		dir = 0
	if dir != 0 and _wall_ahead(dir):
		dir = 0
	if dir != 0:
		facing = dir
		velocity.x = dir * tuning.approach_speed()


func _enter_windup(dir: int) -> void:
	state = State.WINDUP
	_state_timer = 0.0
	_lunge_dir = dir
	velocity.x = 0.0
	Audio.play_sfx(&"resident_windup", global_position)


func _tick_windup(delta: float) -> void:
	velocity.x = 0.0
	_state_timer += delta
	if _state_timer >= tuning.windup_time:
		_enter_lunge()


func _enter_lunge() -> void:
	state = State.LUNGE
	_state_timer = 0.0
	_lunge_traveled = 0.0
	attack_box.active = true
	Audio.play_sfx(&"resident_lunge", global_position)


func _tick_lunge(delta: float) -> void:
	var next_pos := global_position + Vector2(_lunge_dir * tuning.lunge_speed() * delta, 0.0)
	var leaves_lane: bool = _group != null and _group.is_in_lane(global_position) and not _group.is_in_lane(next_pos)
	if not _floor_ahead(_lunge_dir) or _wall_ahead(_lunge_dir) or leaves_lane:
		_enter_recovery()
		return
	velocity.x = _lunge_dir * tuning.lunge_speed()
	_state_timer += delta
	_lunge_traveled += tuning.lunge_speed() * delta
	if _state_timer >= tuning.lunge_time or _lunge_traveled >= tuning.lunge_distance():
		_enter_recovery()


func _enter_recovery() -> void:
	attack_box.active = false
	velocity.x = 0.0
	state = State.RECOVERY
	_state_timer = 0.0
	if _group != null:
		_group.release_attack_token(self)


func _tick_recovery(delta: float) -> void:
	velocity.x = 0.0
	_state_timer += delta
	if _state_timer >= tuning.recovery_time:
		state = State.APPROACH


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


func _on_hit(damage: int, _hit_position: Vector2, _direction: Vector2) -> void:
	if state == State.DEFEATED:
		return
	_health -= damage
	_hit_flash_timer = HIT_FLASH_TIME
	if _health <= 0:
		_defeat()


func _defeat() -> void:
	if state == State.DEFEATED:
		return
	state = State.DEFEATED
	attack_box.active = false
	hit_zone.monitorable = false
	velocity = Vector2.ZERO
	if _group != null:
		_group.release_attack_token(self)
	if entity_id != "" and Session:
		Session.mark_defeated(entity_id)
	defeated.emit(entity_id)
	_defeat_timer = DEFEAT_FADE_TIME
	Audio.play_sfx(&"resident_defeat", global_position)
	queue_redraw()


func is_windup_active() -> bool:
	return state == State.WINDUP


func is_attack_active() -> bool:
	return state == State.LUNGE and attack_box.active


# --- warning / lunge-hurtbox overlay ------------------------------------------
# The character body itself is rendered by the "Visual" child node
# (scripts/actors/visuals/resident_visual.gd); this root still draws the
# combat-telegraph overlays directly since they're anchored to gameplay
# state (attack_box position, windup timing), not to the character art.

func _draw() -> void:
	if state == State.WINDUP:
		var lean: float = clampf(_state_timer / maxf(0.001, tuning.windup_time), 0.0, 1.0)
		_draw_warning(lean)
	elif state == State.LUNGE:
		_draw_lunge_hurtbox()


## Visible feedback for the lunge's active damaging hitbox (03: "lunge
## hurtbox is visible"). AttackBox is a direct child of this node with no
## rotation/scale of its own, so its local `position` (kept current each
## tick by _update_attack_box_position) is directly usable here.
func _draw_lunge_hurtbox() -> void:
	var c := WARN_COLOR
	c.a = 0.35
	var half := ATTACK_BOX_SIZE * 0.5
	var rect := Rect2(attack_box.position - half, ATTACK_BOX_SIZE)
	draw_rect(rect, c)
	draw_rect(rect, WARN_COLOR, false, 2.0)


func _draw_warning(lean: float) -> void:
	# Interface-and-accessibility.md / M6: reduced-motion keeps the (shape-
	# based) warning fully visible but drops the pulsing animation.
	var settings := get_node_or_null("/root/Settings")
	var reduced_motion: bool = settings != null and settings.get_reduced_motion()
	# AD-05 fix: the pulse used to dip to 0.2 alpha with no outline, measuring
	# well under 2:1 contrast against sky/lawn/wall backdrops in a capture
	# review. Never below 0.8 now (still pulses, just shallowly), plus a
	# warm-charcoal outline stroke so the shape itself carries contrast even
	# at the dimmest point of the pulse or in grayscale.
	var pulse: float = 0.95 if reduced_motion else 0.9 + 0.1 * sin(lean * TAU * 3.0)
	var c := WARN_COLOR
	c.a = pulse
	var top := Vector2(0.0, -HEIGHT - 22.0)
	var pts := PackedVector2Array([
		top + Vector2(-8.0, 14.0), top + Vector2(8.0, 14.0), top + Vector2(0.0, -6.0),
	])
	draw_colored_polygon(pts, c)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), OUTLINE, 2.0, true)
	draw_rect(Rect2(top + Vector2(-1.5, -2.0), Vector2(3.0, 8.0)), OUTLINE)
	draw_circle(top + Vector2(0.0, 10.0), 1.6, OUTLINE)
