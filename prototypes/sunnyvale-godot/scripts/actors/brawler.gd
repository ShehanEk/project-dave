class_name Brawler
extends CharacterBody2D
## The Brawler template (C26): the melee walker behind the SE01 Night Guard
## and the LK01 Staffer. Loop: dormant or patrolling -> notice the hero (a
## bark) -> walk in -> (attack token) windup: the tell glows amber, then red
## for the last `red_time` -> one committed strike (a baton swing or a low
## grab) -> recovery, the punish window -> walk in again. Hits never
## interrupt it; people bleed (C29). At zero health the body becomes a
## ragdoll that stays where it falls (C28) until the area is rebuilt.
##
## Everything that tells a guard from a Staffer is BrawlerTuning data. The
## whole body is the HitZone; the hero is only ever hurt through AttackBox,
## active solely during the strike, never from body overlap (layer 3 masks
## only layer 1 world — enemies and the hero never body-block each other).

signal defeated(entity_id: String)

enum State { DORMANT, PATROL, APPROACH, WINDUP, STRIKE, RECOVERY, DEFEATED }

const Rig := preload("res://scripts/actors/lit/cutout_rig.gd")
const Animator := preload("res://scripts/actors/lit/rig_animator.gd")
const Ragdoll := preload("res://scripts/actors/lit/ragdoll.gd")
const Blood := preload("res://scripts/effects/blood.gd")
const Lights := preload("res://scripts/actors/lit/lights.gd")

const H := 96.0
const WIDTH := 22.0
const HEIGHT := 94.0
const HALF_WIDTH := WIDTH * 0.5
const AMBER := Color("#FFB02E")
const ALARM := Color("#FF3B4E")
const OUTLINE := Color("#05070B")
const HIT_FLASH := 0.25
const BARK_TIME := 1.8
## Velocity kick (px/s) the killing shot gives the ragdoll part it hit.
const DEATH_PUSH := 300.0

@export var tuning: BrawlerTuning
@export var entity_id: String = ""
## Optional walking beat, in the owning AreaRoot's local space (every area
## authors positions there), independent of the EncounterGroup lane.
@export var patrol_min_x: float = -INF
@export var patrol_max_x: float = INF
@export var start_facing: int = -1

var state: State = State.PATROL
var facing: int = -1
var health: int = 3
var rig: Node2D
var anim
var _state_timer: float = 0.0
var _strike_dir: int = -1
var _lunge_traveled: float = 0.0
var _flash: float = 0.0
var _noticed: bool = false
var _hurt_barked: bool = false
var _windups: int = 0
var _bark_t: float = 0.0
var _group: EncounterGroup = null
var _area_root: Node2D = null
var _tell_light: PointLight2D
var _hand_glows: Array[Sprite2D] = []
var _holding: bool = false
var _stagger_t: float = 0.0
var _stagger_cd: float = 0.0
var _hit_anim: bool = false
var _rng := RandomNumberGenerator.new()

@onready var hit_zone: HitZone = $HitZone
@onready var attack_box: AttackBox = $AttackBox
@onready var bark_label: Label = $Bark


func _ready() -> void:
	add_to_group("enemy")
	if tuning == null:
		tuning = load("res://data/tuning/night_guard.tres")
	if entity_id != "" and Session and Session.is_defeated(entity_id):
		queue_free()
		return
	collision_layer = 1 << 2  # layer 3: enemy_body
	collision_mask = 1        # layer 1: world only (never body-blocks the hero)
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	floor_snap_length = 8.0
	health = tuning.health
	facing = 1 if start_facing >= 0 else -1
	_rng.seed = hash(entity_id) if entity_id != "" else 1
	attack_box.damage = tuning.damage
	(attack_box.get_node("CollisionShape2D").shape as RectangleShape2D).size = tuning.attack_box_size
	hit_zone.bleeds = true
	hit_zone.hit.connect(_on_hit)
	_group = _find_ancestor(EncounterGroup) as EncounterGroup
	_area_root = _find_ancestor(AreaRoot) as Node2D
	_build_visual()
	state = State.DORMANT if tuning.dormant_until_active else State.PATROL
	_play_state_clip(0.0)
	_update_attack_box_position()


func _find_ancestor(type) -> Node:
	var p := get_parent()
	while p:
		if is_instance_of(p, type):
			return p
		p = p.get_parent()
	return null


func _build_visual() -> void:
	if tuning.rig_path == "" or not FileAccess.file_exists(tuning.rig_path):
		return
	rig = Rig.new()
	rig.name = "Rig"
	rig.rig_path = tuning.rig_path
	add_child(rig)   # builds itself in _ready
	rig.facing = facing
	var clips: Dictionary = {}
	if tuning.clips_script != "":
		clips = load(tuning.clips_script).CLIPS
	anim = Animator.new(clips, tuning.rig_path.get_base_dir().path_join("mocap"))
	_tell_light = PointLight2D.new()
	_tell_light.name = "TellLight"
	_tell_light.texture = Lights.soft_disc()
	_tell_light.texture_scale = 1.1
	_tell_light.height = 14.0
	_tell_light.energy = 0.0
	_tell_light.color = AMBER
	_tell_light.blend_mode = Light2D.BLEND_MODE_ADD
	_tell_light.position = tuning.tell_offset
	if rig.joints.has(tuning.tell_joint):
		rig.joints[tuning.tell_joint].add_child(_tell_light)
	else:
		rig.add_child(_tell_light)
	if tuning.tell_hand_glow:
		for hand in ["near_hand", "far_hand"]:
			if not rig.joints.has(hand):
				continue
			# A small soft halo, not a disc: the tell reads as the hand
			# lighting up.
			var g := Sprite2D.new()
			g.texture = Lights.soft_disc()
			g.scale = Vector2.ONE * 0.2
			g.position = Vector2(0.5, 3.5)
			g.z_index = 12
			g.light_mask = 0
			var mat := CanvasItemMaterial.new()
			mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			g.material = mat
			g.visible = false
			rig.joints[hand].add_child(g)
			_hand_glows.append(g)


func _get_hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero") as Node2D


func _physics_process(delta: float) -> void:
	if state == State.DEFEATED:
		return
	_state_timer += delta
	_stagger_t = maxf(0.0, _stagger_t - delta)
	_stagger_cd = maxf(0.0, _stagger_cd - delta)
	_apply_gravity(delta)
	match state:
		State.DORMANT:
			velocity.x = 0.0
			if _group == null or _group.is_active:
				_enter(State.APPROACH)
				_notice()
		State.PATROL:
			if _stagger_t > 0.0:
				velocity.x = 0.0
			else:
				_tick_patrol()
		State.APPROACH:
			if _stagger_t > 0.0:
				velocity.x = 0.0
			else:
				_tick_approach()
		State.WINDUP:
			velocity.x = 0.0
			if _state_timer >= tuning.windup_time:
				_enter(State.STRIKE)
		State.STRIKE:
			_tick_strike(delta)
		State.RECOVERY:
			velocity.x = 0.0
			if _state_timer >= tuning.recovery_time:
				_enter(State.APPROACH)
	_update_attack_box_position()
	move_and_slide()
	_update_presentation(delta)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += tuning.gravity * delta
	else:
		velocity.y = 0.0


# --- behaviour ---------------------------------------------------------------

func _tick_patrol() -> void:
	velocity.x = 0.0
	if _hero_noticed():
		_notice()
		_enter(State.APPROACH)
		return
	if tuning.patrol_speed() <= 0.0:
		return
	var leash: Node2D = _area_root if _area_root else (get_parent() as Node2D)
	var local_x: float = leash.to_local(global_position).x if leash else global_position.x
	if local_x <= patrol_min_x:
		facing = 1
	elif local_x >= patrol_max_x:
		facing = -1
	if not _can_step(facing):
		facing = -facing
		return
	velocity.x = facing * tuning.patrol_speed()


func _hero_noticed() -> bool:
	if _group != null and not _group.is_active:
		return false
	var hero := _get_hero()
	if hero == null or ("_died_emitted" in hero and hero._died_emitted):
		return false
	var d: Vector2 = hero.global_position - global_position
	return absf(d.y) <= tuning.floor_band and absf(d.x) <= tuning.notice_range


func _notice() -> void:
	if _noticed:
		return
	_noticed = true
	_bark(tuning.voice_notice)


func _tick_approach() -> void:
	velocity.x = 0.0
	var hero := _get_hero()
	if hero == null or (_group != null and not _group.is_active):
		_set_holding(true)
		return
	var dx: float = hero.global_position.x - global_position.x
	var same_floor: bool = absf(hero.global_position.y - global_position.y) <= tuning.floor_band
	if same_floor and absf(dx) <= tuning.engage_range:
		facing = 1 if dx >= 0.0 else -1
		var can_attack: bool = _group == null or _group.request_attack_token(self)
		if can_attack:
			_strike_dir = facing
			_enter(State.WINDUP)
		else:
			# In reach but another enemy in the group holds the attack
			# token: he waits his turn standing, not running in place.
			_set_holding(true)
		return
	var dir: int = 1 if dx > 0.0 else -1
	facing = dir
	var moving: bool = same_floor and _can_step(dir)
	if moving:
		velocity.x = dir * tuning.approach_speed()
	_set_holding(not moving)


## An approach that can't go on (the lane's edge, a ledge, a wall, Dave on
## another floor, waiting for the group's attack token) holds its ground in
## the idle pose, facing Dave, instead of walking in place.
func _set_holding(on: bool) -> void:
	if on == _holding:
		return
	_holding = on
	if anim == null or state != State.APPROACH:
		return
	var c: String = tuning.clip_idle if on else tuning.clip_stalk
	if anim.clips.has(c) or anim.has_mocap(c):
		anim.play(c, false, 0.2)


## One walking step toward `dir` keeps the feet on floor, clear of walls and
## inside the encounter lane.
func _can_step(dir: int) -> bool:
	if _group != null and not _group.allows_step(global_position, dir):
		return false
	return _floor_ahead(dir) and not _wall_ahead(dir)


func _tick_strike(delta: float) -> void:
	if tuning.strike == BrawlerTuning.Strike.LUNGE:
		var next_pos := global_position + Vector2(_strike_dir * tuning.lunge_speed() * delta, 0.0)
		var leaves_lane: bool = _group != null and _group.is_in_lane(global_position) and not _group.is_in_lane(next_pos)
		if not _floor_ahead(_strike_dir) or _wall_ahead(_strike_dir) or leaves_lane:
			_enter(State.RECOVERY)
			return
		velocity.x = _strike_dir * tuning.lunge_speed()
		_lunge_traveled += tuning.lunge_speed() * delta
		if _state_timer >= tuning.lunge_time or _lunge_traveled >= tuning.lunge_distance():
			_enter(State.RECOVERY)
	else:
		var stepping: bool = _state_timer < 0.12 and _can_step(_strike_dir)
		velocity.x = _strike_dir * tuning.swing_step_speed if stepping else 0.0
		attack_box.active = _state_timer >= tuning.swing_active_from and _state_timer <= tuning.swing_active_to
		if _state_timer >= tuning.swing_time:
			_enter(State.RECOVERY)


func _enter(s: State) -> void:
	var was := state
	state = s
	_state_timer = 0.0
	_holding = false
	_hit_anim = false
	if was == State.DORMANT and tuning.link_joint != "":
		# Adam takes the body over: the Link light steadies with a chirp.
		_play_sfx(&"link_chirp")
	match s:
		State.WINDUP:
			velocity.x = 0.0
			_windups += 1
			if _windups % 2 == 0:
				_bark(tuning.voice_windup)
			_play_sfx(tuning.sfx_windup)
		State.STRIKE:
			_lunge_traveled = 0.0
			if tuning.strike == BrawlerTuning.Strike.LUNGE:
				attack_box.active = true
			_play_sfx(tuning.sfx_strike)
		State.RECOVERY:
			attack_box.active = false
			velocity.x = 0.0
			if _group != null and was == State.STRIKE:
				_group.release_attack_token(self)
	_play_state_clip(0.04 if s == State.STRIKE else 0.18)


func _floor_ahead(dir: int) -> bool:
	var probe_x: float = global_position.x + dir * (HALF_WIDTH + 8.0)
	var q := PhysicsRayQueryParameters2D.create(Vector2(probe_x, global_position.y - 4.0), Vector2(probe_x, global_position.y + 40.0))
	q.collision_mask = 1
	return not get_world_2d().direct_space_state.intersect_ray(q).is_empty()


func _wall_ahead(dir: int) -> bool:
	var y: float = global_position.y - HEIGHT * 0.5
	var q := PhysicsRayQueryParameters2D.create(Vector2(global_position.x + dir * (HALF_WIDTH - 2.0), y),
			Vector2(global_position.x + dir * (HALF_WIDTH + 10.0), y))
	q.collision_mask = 1
	return not get_world_2d().direct_space_state.intersect_ray(q).is_empty()


## Keeps the AttackBox on the strike side only, so it can never reach a hero
## behind the brawler (combat fairness: damage only from attack boxes the
## tell points toward).
func _update_attack_box_position() -> void:
	var dir: int = _strike_dir if state == State.STRIKE else facing
	attack_box.position = Vector2(dir * tuning.attack_box_offset.x, tuning.attack_box_offset.y)


# --- damage ------------------------------------------------------------------

func _on_hit(damage: int, hit_position: Vector2, direction: Vector2) -> void:
	if state == State.DEFEATED:
		return
	health -= damage
	var host := _effect_host()
	Blood.spray(host, hit_position, direction, health <= 0)
	_flash = HIT_FLASH
	_play_sfx(&"hit_flesh")
	if rig != null:
		var j: String = rig.nearest_joint(hit_position)
		Blood.wound(rig.sprites[j], hit_position, rig.defs[j]["collider"], rig.joints[j])
		# A jolt away from the shot; it never interrupts what the brawler does.
		var s := -1.0 if signf(direction.x) != float(facing) else 1.0
		anim.jolt({"torso": 0.16 * s, "head": 0.26 * s, "near_upper_arm": -0.12 * s, "far_upper_arm": -0.2 * s, "pelvis": 0.05 * s})
	if not _noticed:
		facing = -1 if direction.x > 0.0 else 1
		_notice()
		if state == State.PATROL or state == State.DORMANT:
			_enter(State.APPROACH)
	elif not _hurt_barked:
		_hurt_barked = true
		_bark(tuning.voice_hurt)
	if health <= 0:
		_defeat(hit_position, direction)
		return
	_flinch()


## The hit flinch: never during the windup or the swing (a hit never
## interrupts an attack); in the recovery it plays without changing the
## timing; walking, he also stops for a moment, at most once per cooldown.
func _flinch() -> void:
	if anim == null or tuning.clip_hit == "" or not (anim.clips.has(tuning.clip_hit) or anim.has_mocap(tuning.clip_hit)):
		return
	if state == State.WINDUP or state == State.STRIKE or _stagger_cd > 0.0:
		return
	anim.play(tuning.clip_hit, true, 0.05)
	_hit_anim = true
	_stagger_cd = tuning.hit_stagger_cooldown
	if state == State.PATROL or state == State.APPROACH:
		_stagger_t = tuning.hit_stagger_time
		velocity.x = 0.0


func _defeat(hit_position: Vector2, direction: Vector2) -> void:
	if state == State.DEFEATED:
		return
	state = State.DEFEATED
	attack_box.active = false
	hit_zone.set_deferred("monitorable", false)
	collision_layer = 0
	velocity = Vector2.ZERO
	if _group != null:
		_group.release_attack_token(self)
	if entity_id != "" and Session:
		Session.mark_defeated(entity_id)
	_play_sfx(tuning.sfx_defeat)
	GameFeel.kill(self)
	var host := _effect_host()
	if rig != null:
		# Dead: the neon trim (C36), a Staffer's Link light and any tell glow
		# go dark on the body.
		rig.body_material.set_shader_parameter("emissive_energy", 0.0)
		if tuning.tell_emissive:
			rig.set_emissive(tuning.tell_joint, Color.BLACK, 0.0)
		var rd := Ragdoll.new()
		rd.name = "Body_" + (entity_id if entity_id != "" else name)
		rd.z_index = z_index
		host.add_child(rd)
		var push := direction.normalized() * DEATH_PUSH + Vector2(0.0, -90.0)
		rd.build(rig, push, hit_position, Vector2.ZERO)
		rig = null
		rd.settled.connect(_on_body_settled.bind(host))
	# A defeat cue of its own (the Staffer's) already ends in the landing.
	if tuning.sfx_defeat == &"":
		get_tree().create_timer(0.45, false, true).timeout.connect(_play_at.bind(&"body_fall", global_position))
	defeated.emit(entity_id)
	queue_free()


static func _on_body_settled(_corpse: Node2D, torso_pos: Vector2, host: Node) -> void:
	if is_instance_valid(host):
		Blood.pool(host, torso_pos, 110.0)


## Effects and the body outlive this node under the owning area, so a
## checkpoint rebuild frees them with it.
func _effect_host() -> Node:
	if _area_root != null and is_instance_valid(_area_root):
		return _area_root
	var scene := get_tree().current_scene
	return scene if scene != null else get_parent()


# --- presentation ------------------------------------------------------------

func _play_state_clip(blend: float) -> void:
	if anim == null:
		return
	var c: String = tuning.clip_idle
	match state:
		State.DORMANT:
			c = "dormant" if anim.clips.has("dormant") else tuning.clip_idle
		State.PATROL:
			c = tuning.clip_walk if tuning.patrol_speed() > 0.0 else tuning.clip_idle
		State.APPROACH:
			c = tuning.clip_stalk
		State.WINDUP:
			c = tuning.clip_windup
		State.STRIKE:
			c = tuning.clip_strike
		State.RECOVERY:
			c = tuning.clip_recover
	if anim.clips.has(c) or anim.has_mocap(c):
		anim.play(c, true, blend)


func _update_presentation(delta: float) -> void:
	if _bark_t > 0.0:
		_bark_t -= delta
		bark_label.visible = _bark_t > 0.0
		bark_label.modulate.a = clampf(_bark_t / 0.4, 0.0, 1.0)
	queue_redraw()
	if rig == null:
		return
	rig.facing = facing
	var moving: bool = absf(velocity.x) > 4.0
	if _hit_anim:
		anim.speed = 1.0
		if anim.is_finished() and _stagger_t <= 0.0:
			_hit_anim = false
			_holding = false
			_play_state_clip(0.2)
		rig.apply_pose(anim.advance(delta))
		_update_lights(delta)
		return
	match state:
		State.PATROL:
			anim.speed = absf(velocity.x) / 70.0 if moving else 1.0
			var want: String = tuning.clip_walk if moving else tuning.clip_idle
			if anim.clip != want and (anim.clips.has(want) or anim.has_mocap(want)):
				anim.play(want, false, 0.2)
		State.APPROACH:
			anim.speed = maxf(absf(velocity.x) / maxf(tuning.approach_speed(), 1.0), 0.35)
		_:
			anim.speed = 1.0
	rig.apply_pose(anim.advance(delta))
	_update_lights(delta)


func _update_lights(delta: float) -> void:
	# The tell: amber, then red for the last red_time; its light falls on the
	# brawler's own arm and face (and on the hero, up close).
	var energy := 0.0
	var color := AMBER
	if state == State.WINDUP:
		var k := clampf(_state_timer / tuning.windup_time, 0.0, 1.0)
		color = ALARM if _state_timer >= tuning.windup_time - tuning.red_time else AMBER
		energy = lerpf(0.5, 1.6, k)
	elif state == State.STRIKE:
		color = ALARM
		energy = 1.4
	_tell_light.color = color
	_tell_light.energy = energy
	if tuning.tell_emissive:
		rig.set_emissive(tuning.tell_joint, color, energy * 2.2)
	for g in _hand_glows:
		g.visible = energy > 0.0
		g.modulate = Color(color.r, color.g, color.b, clampf(energy * 0.55, 0.0, 0.85))
	# A driven body's Link light is steady amber; a dormant one is dim.
	if tuning.link_joint != "":
		rig.body_material.set_shader_parameter("emissive_energy", 0.45 if state == State.DORMANT else 1.3)
	_flash = maxf(0.0, _flash - delta * 4.0)
	rig.set_flash(_flash)


func _bark(lines: PackedStringArray) -> void:
	if lines.is_empty() or bark_label == null:
		return
	bark_label.text = lines[_rng.randi_range(0, lines.size() - 1)]
	bark_label.visible = true
	_bark_t = BARK_TIME


func _play_sfx(cue: StringName) -> void:
	if cue != &"":
		Audio.play_sfx(cue, global_position)


static func _play_at(cue: StringName, at: Vector2) -> void:
	Audio.play_sfx(cue, at)


func is_windup_active() -> bool:
	return state == State.WINDUP


func is_attack_active() -> bool:
	return state == State.STRIKE and attack_box.active


# --- backup warning cue ------------------------------------------------------
# The tell is the light, the sound and the pose; the small warning triangle
# stays as a backup cue (roster fairness rules), drawn over the head during
# the windup only.

func _draw() -> void:
	if state != State.WINDUP:
		return
	var settings := get_node_or_null("/root/Settings")
	var reduced_motion: bool = settings != null and settings.get_reduced_motion()
	var red: bool = _state_timer >= tuning.windup_time - tuning.red_time
	var c: Color = ALARM if red else AMBER
	c.a = 0.95 if reduced_motion else 0.9 + 0.1 * sin(_state_timer * TAU * 3.0)
	var top := Vector2(0.0, -HEIGHT - 26.0)
	var pts := PackedVector2Array([top + Vector2(-8.0, 14.0), top + Vector2(8.0, 14.0), top + Vector2(0.0, -6.0)])
	draw_colored_polygon(pts, c)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), OUTLINE, 2.0, true)
	draw_rect(Rect2(top + Vector2(-1.5, -2.0), Vector2(3.0, 8.0)), OUTLINE)
	draw_circle(top + Vector2(0.0, 10.0), 1.6, OUTLINE)
