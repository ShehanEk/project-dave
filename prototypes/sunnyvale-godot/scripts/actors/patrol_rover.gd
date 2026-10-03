class_name PatrolRover
extends CharacterBody2D
## M01 Patrol Rover, the Charger template (C26): Arcadia's squat wheeled
## campus security robot with its speed governor removed. Patrols its lane
## -> acquires an on-plane hero -> (token) windup: it rocks back, the
## lightbar goes amber then red, the wheels spin in place ("Speed limit
## override accepted") -> a straight grounded charge (cannot turn or jump;
## brakes at a ledge) -> hitting a wall or backstop stalls it with the rear
## battery hatch open, OR a missed charge brakes -> recovery -> patrol. The
## armored front always blocks shots (distinct feedback); the rear battery
## only accepts damage while stalled. AttackBox (contact damage) is live
## only during the charge. Destroyed, it bursts into debris (C35).
##
## The behaviour is the old Clipper's, kept as-is (its timings and
## fairness were tested); only the machine it drives changed (C32).

signal defeated(entity_id: String)
signal hint_requested(text: String)

const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")
const Rig := preload("res://scripts/actors/lit/cutout_rig.gd")
const Ragdoll := preload("res://scripts/actors/lit/ragdoll.gd")
const Blood := preload("res://scripts/effects/blood.gd")
const Lights := preload("res://scripts/actors/lit/lights.gd")

enum State { PATROL, WINDUP, CHARGE, STALL, RECOVERY, DEFEATED }

const H := 96.0
## The imported machine (2026-10-03) is a long, low patrol car: the body
## box spans the chassis, and the bumper reaches its front edge.
const WIDTH := 92.0
const HEIGHT := 48.0
const HALF_WIDTH := WIDTH * 0.5
const HIT_FLASH_TIME := 0.15
const HINT_DISPLAY_TIME := 4.0
const HINT_TEXT := "Armored! Make it crash into something solid, then shoot the battery on its back."
const HINT_BASE_FONT_SIZE := 24
const BARK_TIME := 1.8
const VOICE_NOTICE := "Please remain where you are. You are not authorized."
const VOICE_WINDUP := "Speed limit override accepted."
## Red for the last part of the windup (roster tell rule).
const RED_TIME := 0.25
const WHEEL_RADIUS := 11.0
## The hatch hinges at its front edge: opening swings its rear end up.
const HATCH_OPEN := 1.1
## Speed (px/s) the wreck's parts are thrown apart at.
const DEBRIS_SPREAD := 220.0

const OUTLINE := Color("#05070B")
const IVORY := Color("#efe5cf")
const HIT_FLASH := Color("#f4d78a")
const AMBER := Color("#FFB02E")
const ALARM := Color("#FF3B4E")
const TEAL := Color("#3FE0D0")
## Its type's neon (C36): the flank strip glows from the rig, and this
## light casts the underglow on the floor beneath it.
const NEON := Color("#FF3DD5")

@export var tuning: ChargerTuning
@export var entity_id: String = ""
## Optional patrol leash, independent of an EncounterGroup's lane_rect, in
## the owning AreaRoot's local space (the same space every entity in an
## area is placed in), so a standalone rover (tests, demos) doesn't wander
## arbitrarily far on open ground. Defaults to unbounded.
@export var patrol_min_x: float = -INF
@export var patrol_max_x: float = INF

var state: State = State.PATROL
var facing: int = -1
var rig: Node2D
var _patrol_dir: int = -1
var _lock_dir: int = -1
var _state_timer: float = 0.0
var _traveled: float = 0.0
var _motor_health: int = 3
var _motor_hit_flash_timer: float = 0.0
var _shell_hit_flash_timer: float = 0.0
var _hint_timer: float = 0.0
var _frontal_hits: int = 0
var _hint_shown: bool = false
var _noticed: bool = false
var _windups: int = 0
var _bark_t: float = 0.0
var _wheel_angle: float = 0.0
var _anim_t: float = 0.0
var _hatch_open: float = 0.0
var _group: EncounterGroup = null
var _area_root: Node2D = null
var _tell_light: PointLight2D
var _underglow: PointLight2D
## Local-space point of the most recent blocked frontal hit, valid only
## while _shell_hit_flash_timer > 0 (the deflection spark draws there).
var _shell_hit_flash_local_pos: Vector2 = Vector2.ZERO
## The wall/backstop this charge most recently stalled against, so the
## stall can leave a one-time crack mark on it (only Block opts in).
var _last_stall_wall: Node = null

@onready var front_hit_zone: ArmorHitZone = $FrontHitZone
@onready var rear_hit_zone: HitZone = $RearHitZone
## Fills the centre strip between Front/RearHitZone, so a shot straight
## down through the shell's middle still gets feedback. Always blocks.
@onready var shell_hit_zone: HitZone = $ShellHitZone
@onready var attack_box: AttackBox = $AttackBox
## Screen-anchored (a CanvasLayer child) so it can never sit over the hero.
@onready var hint_label: Label = $HintLayer/HintLabel
@onready var bark_label: Label = $Bark


func _ready() -> void:
	add_to_group("enemy")
	if tuning == null:
		tuning = load("res://data/tuning/patrol_rover.tres")
	if entity_id != "" and Session and Session.is_defeated(entity_id):
		queue_free()
		return
	collision_layer = 1 << 2  # layer 3: enemy_body
	collision_mask = 1        # layer 1: world only
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	_motor_health = tuning.motor_health
	attack_box.damage = tuning.damage
	rear_hit_zone.blocks = true  # only exposed while stalled
	_group = _find_ancestor(EncounterGroup) as EncounterGroup
	_area_root = _find_ancestor(AreaRoot) as Node2D
	front_hit_zone.blocked_hit.connect(_on_front_blocked_hit)
	rear_hit_zone.hit.connect(_on_rear_hit)
	if hint_label:
		hint_label.text = HINT_TEXT
		hint_label.visible = false
		_apply_hint_text_size()
		var settings := get_node_or_null("/root/Settings")
		if settings and not settings.changed.is_connected(_apply_hint_text_size):
			settings.changed.connect(_apply_hint_text_size)
	_build_visual()
	_update_zone_positions()


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_apply_hint_text_size):
		settings.changed.disconnect(_apply_hint_text_size)


func _apply_hint_text_size() -> void:
	if not hint_label:
		return
	var settings := get_node_or_null("/root/Settings")
	hint_label.add_theme_font_size_override("font_size",
			settings.scaled_font_size(HINT_BASE_FONT_SIZE) if settings else HINT_BASE_FONT_SIZE)


func _find_ancestor(type) -> Node:
	var p := get_parent()
	while p:
		if is_instance_of(p, type):
			return p
		p = p.get_parent()
	return null


func _build_visual() -> void:
	if tuning.rig_path == "" or not ResourceLoader.exists(tuning.rig_path):
		return
	rig = Rig.new()
	rig.name = "Rig"
	rig.rig_path = tuning.rig_path
	add_child(rig)
	rig.facing = facing
	_tell_light = PointLight2D.new()
	_tell_light.name = "TellLight"
	_tell_light.texture = Lights.soft_disc()
	# Small and gentle: sitting on the rover's own pale shell, a bigger or
	# brighter light washed the whole body pink or amber.
	_tell_light.texture_scale = 0.7
	_tell_light.height = 16.0
	_tell_light.energy = 0.0
	_tell_light.color = AMBER
	_tell_light.blend_mode = Light2D.BLEND_MODE_ADD
	# On the lightbar's "tell" socket, so its light falls on the rover's own
	# shell and on whoever stands in front of it.
	var sock: Dictionary = rig.sockets.get("tell", {})
	var bar: String = sock.get("joint", _part("lightbar"))
	if bar != "" and rig.joints.has(bar):
		rig.joints[bar].add_child(_tell_light)
		_tell_light.position = sock.get("pos", Vector2.ZERO)
	else:
		rig.add_child(_tell_light)
		_tell_light.position = Vector2(0.0, -HEIGHT)
	# The magenta underglow: a flat pool on the floor under the chassis,
	# steady and dimmer than the tell.
	_underglow = PointLight2D.new()
	_underglow.name = "Underglow"
	_underglow.texture = Lights.soft_disc()
	_underglow.texture_scale = 0.9
	_underglow.scale = Vector2(1.5, 0.45)
	_underglow.position = Vector2(0.0, -3.0)
	_underglow.height = 4.0
	_underglow.energy = 0.55
	_underglow.color = NEON
	_underglow.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(_underglow)


## A rig joint by its role in rig.json, falling back to the joint's name.
func _part(role: String) -> String:
	if rig == null:
		return ""
	var j: String = rig.joint_for_role(role)
	if j == "" and rig.joints.has(role):
		j = role
	return j


func _physics_process(delta: float) -> void:
	if _hint_timer > 0.0:
		_hint_timer -= delta
		if _hint_timer <= 0.0 and hint_label:
			hint_label.visible = false
	if state == State.DEFEATED:
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
	_update_presentation(delta)
	queue_redraw()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += tuning.gravity * delta
	else:
		velocity.y = 0.0


func _get_hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero")


func _has_line_of_sight(hero: Node2D) -> bool:
	# Aim both ends at mid-body height, not the feet: a ray ending exactly on
	# the floor's top surface can register the floor itself as in the way.
	var eye: Vector2 = global_position + Vector2(0.0, -HEIGHT * 0.75)
	var target: Vector2 = hero.global_position + Vector2(0.0, -Hero.H * 0.5)
	var params := PhysicsRayQueryParameters2D.create(eye, target)
	params.collision_mask = 1  # world only
	return get_world_2d().direct_space_state.intersect_ray(params).is_empty()


func _tick_patrol(_delta: float) -> void:
	var hero := _get_hero()
	if hero != null and (_group == null or _group.is_active):
		var dx: float = hero.global_position.x - global_position.x
		var dy: float = hero.global_position.y - global_position.y
		var same_floor: bool = absf(dy) <= tuning.floor_band
		if same_floor and absf(dx) <= tuning.acquire_range and _has_line_of_sight(hero):
			if not _noticed:
				_noticed = true
				_bark(VOICE_NOTICE)
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
	# patrol_min_x/max_x are AREA-local; the assembled level offsets every
	# area, so convert through the owning AreaRoot (or the parent, in an
	# isolated scene) before comparing.
	var leash_space: Node2D = _area_root if _area_root else (get_parent() as Node2D)
	var next_local_x: float = leash_space.to_local(Vector2(next_x, global_position.y)).x if leash_space else next_x
	var blocked_by_leash: bool = next_local_x < patrol_min_x or next_local_x > patrol_max_x
	if not _floor_ahead(_patrol_dir) or _wall_ahead(_patrol_dir) or blocked_by_lane or blocked_by_leash:
		_patrol_dir = -_patrol_dir
		velocity.x = 0.0
		Audio.play_sfx(&"rover_patrol", global_position)
	facing = _patrol_dir


func _enter_windup(dir: int) -> void:
	state = State.WINDUP
	_state_timer = 0.0
	_lock_dir = dir
	facing = dir
	velocity.x = 0.0
	_windups += 1
	if _windups % 2 == 1:
		_bark(VOICE_WINDUP)
	Audio.play_sfx(&"rover_windup", global_position)


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
	Audio.play_sfx(&"rover_charge", global_position)


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
		if col.get_normal().x * float(_lock_dir) < -0.3:
			_enter_stall(col.get_collider())
			return
	if _traveled >= tuning.charge_max_distance():
		_enter_brake_recovery()


func _enter_stall(wall: Node = null) -> void:
	state = State.STALL
	attack_box.active = false
	velocity = Vector2.ZERO
	_state_timer = 0.0
	rear_hit_zone.blocks = false
	Audio.play_sfx(&"rover_stall", global_position)
	KenneyPuff.spawn(&"machine_smoke", global_position + Vector2(-facing * 20.0, -30.0), _effect_host())
	# The token is held only through windup/charge; release it now so
	# another enemy can take its turn while this one sits stalled.
	if _group != null:
		_group.release_attack_token(self)
	# Crack the stone this charge hit, once (only Block opts in).
	_last_stall_wall = wall
	if wall != null and "cracked" in wall:
		wall.cracked = true


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
	var params := PhysicsRayQueryParameters2D.create(Vector2(probe_x, global_position.y - 4.0), Vector2(probe_x, global_position.y + 40.0))
	params.collision_mask = 1
	return not get_world_2d().direct_space_state.intersect_ray(params).is_empty()


func _wall_ahead(dir: int) -> bool:
	var y: float = global_position.y - HEIGHT * 0.5
	var params := PhysicsRayQueryParameters2D.create(Vector2(global_position.x + dir * (HALF_WIDTH - 2.0), y),
			Vector2(global_position.x + dir * (HALF_WIDTH + 10.0), y))
	params.collision_mask = 1
	return not get_world_2d().direct_space_state.intersect_ray(params).is_empty()


func _update_zone_positions() -> void:
	var f := float(facing)
	front_hit_zone.position = Vector2(f * (HALF_WIDTH - 10.0), -HEIGHT * 0.55)
	rear_hit_zone.position = Vector2(-f * (HALF_WIDTH - 12.0), -HEIGHT * 0.55)
	# Fixed at the body's centre: Front/Rear mirror around x = 0 as facing
	# flips, so the gap between them is always this same strip.
	shell_hit_zone.position = Vector2(0.0, -HEIGHT * 0.55)
	attack_box.position = Vector2(f * (HALF_WIDTH + 6.0), -HEIGHT * 0.5)


## One-shot effects and the wreck outlive this node under the owning area,
## so a checkpoint rebuild frees them with it.
func _effect_host() -> Node:
	if _area_root != null and is_instance_valid(_area_root):
		return _area_root
	var scene := get_tree().current_scene
	return scene if scene != null else get_parent()


func _on_front_blocked_hit(hit_position: Vector2) -> void:
	if state == State.DEFEATED:
		return
	_shell_hit_flash_timer = HIT_FLASH_TIME
	_shell_hit_flash_local_pos = to_local(hit_position)
	KenneyPuff.spawn(&"armor_spark", hit_position, _effect_host())
	Audio.play_sfx(&"rover_armor", hit_position)
	_frontal_hits += 1
	if _frontal_hits >= tuning.frontal_hint_threshold and not _hint_shown:
		_hint_shown = true
		hint_requested.emit(HINT_TEXT)
		# The hint supersedes any tutorial prompt still on screen.
		get_tree().call_group(&"tutorial_prompt", &"dismiss")
		if hint_label:
			hint_label.visible = true
		_hint_timer = HINT_DISPLAY_TIME


func _on_rear_hit(damage: int, hit_position: Vector2, direction: Vector2) -> void:
	if state == State.DEFEATED:
		return
	_motor_health -= damage
	_motor_hit_flash_timer = HIT_FLASH_TIME
	KenneyPuff.spawn(&"armor_spark", hit_position, _effect_host())
	if _motor_health <= 0:
		_defeat(hit_position, direction)


func _defeat(hit_position: Vector2 = Vector2.INF, direction: Vector2 = Vector2.ZERO) -> void:
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
	Audio.play_sfx(&"rover_destroyed", global_position)
	var host := _effect_host()
	var centre := global_position + Vector2(0.0, -HEIGHT * 0.5)
	KenneyPuff.spawn(&"machine_smoke", centre, host)
	KenneyPuff.spawn(&"machine_spark", centre, host)
	if rig != null:
		# Dead: the lightbar, the battery, the sensor lens and the neon go
		# dark on the wreck.
		for role in ["lightbar", "battery"]:
			var j := _part(role)
			if j != "":
				rig.set_emissive(j, Color.BLACK, 0.0)
		rig.body_material.set_shader_parameter("emissive_energy", 0.0)
		rig.set_flash(0.0)
		var wreck := Ragdoll.new()
		wreck.name = "Wreck_" + (entity_id if entity_id != "" else name)
		wreck.z_index = z_index
		host.add_child(wreck)
		var at: Vector2 = hit_position if hit_position != Vector2.INF else centre
		var push: Vector2 = direction.normalized() * 160.0 if direction != Vector2.ZERO else Vector2.ZERO
		wreck.build(rig, push, at, Vector2.ZERO, false, DEBRIS_SPREAD)
		wreck.settled.connect(_on_wreck_settled.bind(host))
		rig = null
	defeated.emit(entity_id)
	queue_free()


static func _on_wreck_settled(_pieces: Node2D, centre: Vector2, host: Node) -> void:
	if is_instance_valid(host):
		Blood.oil_pool(host, centre, 48.0)
		Audio.play_sfx(&"debris_clatter", centre)


func is_stalled() -> bool:
	return state == State.STALL


func is_windup_active() -> bool:
	return state == State.WINDUP


func is_charging() -> bool:
	return state == State.CHARGE


# --- presentation ------------------------------------------------------------

func _update_presentation(delta: float) -> void:
	_anim_t += delta
	if _bark_t > 0.0:
		_bark_t -= delta
		bark_label.visible = _bark_t > 0.0
		bark_label.modulate.a = clampf(_bark_t / 0.4, 0.0, 1.0)
	if rig == null:
		return
	rig.facing = facing
	var settings := get_node_or_null("/root/Settings")
	var calm: bool = settings != null and settings.get_reduced_motion()
	# Wheels roll with the ground speed; in the windup they spin in place.
	var spin := velocity.x * float(facing) * delta / WHEEL_RADIUS
	if state == State.WINDUP:
		spin = 22.0 * delta
	_wheel_angle += spin
	var pose := {}
	for role in ["wheel_near_front", "wheel_near_rear", "wheel_far_front", "wheel_far_rear"]:
		var w := _part(role)
		if w != "":
			pose[w] = _wheel_angle
	var chassis := _part("chassis")
	var tilt := 0.0
	var bob := Vector2.ZERO
	match state:
		State.PATROL:
			bob.y = 0.0 if calm else sin(_anim_t * 9.0) * 0.35
		State.WINDUP:
			# Rocking back on the rear wheels, nose up, shaking with the spin.
			tilt = -0.07 * clampf(_state_timer / 0.2, 0.0, 1.0)
			if not calm:
				bob.x = sin(_anim_t * 60.0) * 0.5
		State.CHARGE:
			tilt = 0.035
		State.STALL:
			var k := clampf(1.0 - _state_timer / 0.35, 0.0, 1.0)
			tilt = 0.05 * k * (1.0 if calm else cos(_state_timer * 40.0))
	if chassis != "":
		pose[chassis] = tilt
	pose["root"] = bob
	# The rear hatch swings open for the stall, exposing the battery.
	var hatch_target := 1.0 if state == State.STALL else 0.0
	_hatch_open = move_toward(_hatch_open, hatch_target, delta / 0.2)
	var hatch := _part("hatch")
	if hatch != "":
		pose[hatch] = HATCH_OPEN * _hatch_open * _hatch_open * (3.0 - 2.0 * _hatch_open)
	rig.apply_pose(pose)
	# Lightbar (lens-light rule): dim amber on patrol, full amber once it has
	# seen the hero, amber then red through the windup, red on the charge.
	var color := AMBER
	var bar_energy := 0.5
	var light_energy := 0.0
	match state:
		State.PATROL, State.RECOVERY:
			bar_energy = 1.2 if _noticed else 0.5
		State.WINDUP:
			color = ALARM if _state_timer >= tuning.windup_time - RED_TIME else AMBER
			bar_energy = 2.2
			light_energy = lerpf(0.3, 0.9, clampf(_state_timer / tuning.windup_time, 0.0, 1.0))
		State.CHARGE:
			color = ALARM
			bar_energy = 2.4
			light_energy = 0.9
		State.STALL:
			bar_energy = 0.35
	var bar := _part("lightbar")
	if bar != "":
		rig.set_emissive(bar, color, bar_energy)
	_tell_light.color = color
	_tell_light.energy = light_energy
	# The battery core glows teal (a power unit); bright and pulsing while
	# the hatch is open, flaring when it takes a hit.
	var battery := _part("battery")
	if battery != "":
		var e := 0.6
		if state == State.STALL:
			e = 1.6 + (0.0 if calm else 0.5 * sin(_anim_t * 10.0))
		if _motor_hit_flash_timer > 0.0:
			e = 3.0
		rig.set_emissive(battery, TEAL, e)
	rig.set_flash(0.3 if _shell_hit_flash_timer > 0.0 else 0.0)


func _bark(line: String) -> void:
	if bark_label == null:
		return
	bark_label.text = line
	bark_label.visible = true
	_bark_t = BARK_TIME


# --- overlays ------------------------------------------------------------------
# The windup warning triangle (a backup cue under the light, sound and pose)
# and the blocked-hit deflection spark are anchored to gameplay timing, so
# this root draws them.

func _draw() -> void:
	if state == State.WINDUP:
		_draw_warning()
	if _shell_hit_flash_timer > 0.0:
		_draw_blocked_spark()


## A bright deflection spark burst plus a small chevron glyph at the exact
## impact point, so a front hit reads "armored" by shape, never colour alone.
func _draw_blocked_spark() -> void:
	var k: float = clampf(_shell_hit_flash_timer / HIT_FLASH_TIME, 0.0, 1.0)
	var p := _shell_hit_flash_local_pos
	var c := HIT_FLASH
	c.a = k
	var spark_len: float = lerpf(2.0, 11.0, k)
	for i in 6:
		var ang: float = float(i) / 6.0 * TAU + 0.4
		draw_line(p, p + Vector2(cos(ang), sin(ang)) * spark_len, c, 2.0)
	var chevron := PackedVector2Array([p + Vector2(-6.0, -3.0), p + Vector2(0.0, 3.0), p + Vector2(6.0, -3.0)])
	draw_polyline(chevron, OUTLINE, 3.0, true)
	draw_polyline(chevron, IVORY, 1.6, true)


func _draw_warning() -> void:
	var settings := get_node_or_null("/root/Settings")
	var reduced_motion: bool = settings != null and settings.get_reduced_motion()
	var c: Color = ALARM if _state_timer >= tuning.windup_time - RED_TIME else AMBER
	c.a = 0.95 if reduced_motion else 0.9 + 0.1 * sin(_state_timer * TAU * 3.0)
	var top := Vector2(0.0, -HEIGHT - 44.0)
	var pts := PackedVector2Array([top + Vector2(-8.0, 14.0), top + Vector2(8.0, 14.0), top + Vector2(0.0, -6.0)])
	draw_colored_polygon(pts, c)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), OUTLINE, 2.0, true)
	draw_rect(Rect2(top + Vector2(-1.5, -2.0), Vector2(3.0, 8.0)), OUTLINE)
	draw_circle(top + Vector2(0.0, 10.0), 1.6, OUTLINE)
