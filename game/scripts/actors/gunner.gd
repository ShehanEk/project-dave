class_name Gunner
extends CharacterBody2D
## The Gunner template (C26, M4): the aimed shooter, first the SE02 Sidearm Guard with
## the EG01 pistol. Loop: hold a post (or walk a beat) -> notice Dave (a bark) -> walk in
## to range -> (attack token) the tell: a deep two-hand stance, the muzzle lamp amber,
## then red for the last `red_time` with a lock click -> one round -> a rooted reload
## (the slide rack: the punish window) -> again. Hits never interrupt the tell, the shot
## or the reload; he bleeds (C29) and dies into a ragdoll that drops the pistol as a prop
## (C28), never a pickup.
##
## The fairness rules (encounter-and-boss-fairness.md, P23), as code:
##   - On Dave's floor the round flies flat at 0.5 H with no spread, so a held jump clears
##     it and a 0.6 H crate stops it (EnemyRound sweeps against the world).
##   - From another floor it flies at Dave's last grounded spot plus 0.5 H. The aim point
##     follows that spot at most aim_track_speed (3 H/s, slower than Dave, no lead)
##     through the amber part and locks when the lamp turns red. Such a tell needs a clear
##     line as wide as a round; without one he walks to his floor's edge (he leans over).
##   - Never at an airborne Dave: a tell only starts while Dave stands on a floor, and the
##     aim only ever follows his last grounded spot, never him in the air.
##   - The readability gate: a tell starts, and the round leaves, only while his body is
##     at least camera_margin_h (1 H) inside the camera's view; at the gate's end of the
##     tell he holds his fire instead (no round, no reload).
##   - One round alive at a time (the screen caps' pistol 1); a same-floor gunner turns to
##     face Dave only between shots.
##   - A round's hit costs 1 health with half knockback (EnemyRound).
##
## Everything that tells one gunner from another is GunnerTuning data: health, timings,
## the gun, the look and the barks. The whole body is the HitZone. No class_name rule
## exception: gameplay scripts keep theirs (CONVENTIONS.md).

signal defeated(entity_id: String)
signal fired(round: Node)

enum State { PATROL, APPROACH, AIM, FIRE, RELOAD, DEFEATED }

const Rig := preload("res://scripts/actors/lit/cutout_rig.gd")
const Animator := preload("res://scripts/actors/lit/rig_animator.gd")
const Ragdoll := preload("res://scripts/actors/lit/ragdoll.gd")
const Blood := preload("res://scripts/effects/blood.gd")
const Lights := preload("res://scripts/actors/lit/lights.gd")
const BarkMap := preload("res://scripts/audio/bark_map.gd")
const PixelFx := preload("res://scripts/effects/pixel_fx.gd")

const H := 96.0
const WIDTH := 22.0
const HEIGHT := 94.0
const HALF_WIDTH := WIDTH * 0.5
## Where he looks from, for "can he see Dave" (a wall hides Dave; a low crate does not).
const EYE_HEIGHT := 82.0
## Dave counts as on the gunner's floor for walking in within this band (px).
const WALK_FLOOR_BAND := 64.0
const AMBER := Color("#FFB02E")
const ALARM := Color("#FF3B4E")
const OUTLINE := Color("#05070B")
const TEAL := Color("#3FE0D0")
## The muzzle flash light (EG01's preset): ivory, one short pulse.
const FLASH_IVORY := Color("#F2EBD3")
const FLASH_TIME := 0.06
const HIT_FLASH := 0.25
const BARK_TIME := 1.8
const BARK_VOICE_GAP := 0.1
const BARK_VOICE_MAX := 2.9
const DEATH_PUSH := 300.0
## How fast the arms swing to a new aim angle (radians/s).
const ARM_TURN_SPEED := 5.0

@export var tuning: GunnerTuning
@export var entity_id: String = ""
## Optional walking beat, in the owning AreaRoot's local space (like a Brawler's).
@export var patrol_min_x: float = -INF
@export var patrol_max_x: float = INF
@export var start_facing: int = -1

var state: State = State.PATROL
var facing: int = -1
var health: int = 3
var rig: Node2D
var anim
## The gun prop rig on the near hand (a cutout_rig.gd node), or null without art.
var gun: Node2D
var _state_timer: float = 0.0
var _rest_t: float = 999.0
var _noticed: bool = false
var _hurt_barked: bool = false
var _windups: int = 0
var _reloads: int = 0
var _group: EncounterGroup = null
var _area_root: Node2D = null
## Dave's last grounded position (his feet), the only spot a gun ever aims at.
var _hero_ground: Vector2 = Vector2.ZERO
var _has_ground: bool = false
## The tell's aim point (world): Dave's grounded spot + 0.5 H, followed through amber.
var _aim_point: Vector2 = Vector2.ZERO
var _locked: bool = false
## True when the locked shot is on his own floor: flat at 0.5 H.
var _flat: bool = true
## The arms' aim offset from level (radians, + down, in his facing space).
var _arm_aim: float = 0.0
var _live_rounds: Array = []
var _tell_light: PointLight2D
var _flash_light: PointLight2D
var _since_shot: float = 999.0
var _lamp_joint: String = ""
var _slide_joint: String = ""
var _slide_rest: Vector2 = Vector2.ZERO
var _flash: float = 0.0
var _stagger_t: float = 0.0
var _stagger_cd: float = 0.0
var _hit_anim: bool = false
var _holding: bool = false
var _bark_t: float = 0.0
var _bark_player: Node = null
var _bark_stream: AudioStream = null
var _rng := RandomNumberGenerator.new()

@onready var hit_zone: HitZone = $HitZone
@onready var bark_label: Label = $Bark


func _ready() -> void:
	add_to_group("enemy")
	if tuning == null:
		tuning = load("res://data/tuning/sidearm_guard.tres")
	if entity_id != "" and Session and Session.is_defeated(entity_id):
		queue_free()
		return
	collision_layer = 1 << 2  # layer 3: enemy_body
	collision_mask = 1        # layer 1: world only
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	floor_snap_length = 8.0
	health = tuning.health
	facing = 1 if start_facing >= 0 else -1
	_rng.seed = hash(entity_id) if entity_id != "" else 1
	hit_zone.bleeds = true
	hit_zone.hit.connect(_on_hit)
	_group = _find_ancestor(EncounterGroup) as EncounterGroup
	_area_root = _find_ancestor(AreaRoot) as Node2D
	_build_visual()
	_play_state_clip(0.0)


func _find_ancestor(type) -> Node:
	var p := get_parent()
	while p:
		if is_instance_of(p, type):
			return p
		p = p.get_parent()
	return null


## The rig this gunner draws: one of the tuning's looks, picked by entity id (he keeps his
## face across reloads), else the tuning's rig_path.
func rig_path_for_look() -> String:
	var paths: Array = []
	for pth in tuning.rig_variants:
		if FileAccess.file_exists(pth):
			paths.append(pth)
	if paths.is_empty():
		return tuning.rig_path
	var key: String = entity_id if entity_id != "" else String(name)
	return paths[posmod(hash(key), paths.size())]


func _build_visual() -> void:
	var path := rig_path_for_look()
	if path == "" or not FileAccess.file_exists(path):
		return
	rig = Rig.new()
	rig.name = "Rig"
	rig.rig_path = path
	add_child(rig)
	rig.facing = facing
	for j in tuning.strip_joints:
		rig.remove_joint(j)
	var clips: Dictionary = {}
	if tuning.clips_script != "":
		clips = load(tuning.clips_script).CLIPS
	anim = Animator.new(clips, path.get_base_dir().path_join("mocap_gunner"))
	_build_gun()


## Hangs the gun prop on the carrier's hand (the rig's "gun" socket, else gun_offset),
## with its muzzle tell light and flash light.
func _build_gun() -> void:
	if tuning.gun_rig_path == "" or not FileAccess.file_exists(tuning.gun_rig_path):
		return
	if not rig.joints.has(tuning.gun_joint):
		return
	gun = Rig.new()
	gun.name = "Gun"
	gun.rig_path = tuning.gun_rig_path
	var hand: Node2D = rig.joints[tuning.gun_joint]
	hand.add_child(gun)
	var sock: Dictionary = rig.sockets.get("gun", {})
	gun.position = sock["pos"] if sock.has("pos") and sock.get("joint", "") == tuning.gun_joint else tuning.gun_offset
	gun.rotation = deg_to_rad(tuning.gun_rotation_deg)
	# Under the fist (the hand draws at z 10), over the forearm and the far arm.
	gun.z_index = 8
	var lamp: Dictionary = gun.sockets.get("lamp", gun.sockets.get("muzzle", {}))
	_lamp_joint = lamp.get("joint", gun.order[0] if not gun.order.is_empty() else "")
	var slide: String = gun.joint_for_role("slide")
	if slide != "":
		_slide_joint = slide
		_slide_rest = gun.joints[slide].position
	# The status strip is a small, steady teal light (never a tell).
	var frame: String = gun.joint_for_role("frame")
	if frame != "" and frame != _lamp_joint:
		gun.set_emissive(frame, TEAL, 0.7)
	_tell_light = PointLight2D.new()
	_tell_light.name = "TellLight"
	_tell_light.texture = Lights.soft_disc()
	_tell_light.texture_scale = 0.9
	_tell_light.height = 12.0
	_tell_light.energy = 0.0
	_tell_light.color = AMBER
	_tell_light.blend_mode = Light2D.BLEND_MODE_ADD
	if gun.joints.has(_lamp_joint):
		gun.joints[_lamp_joint].add_child(_tell_light)
		_tell_light.position = lamp.get("pos", Vector2.ZERO)
	else:
		gun.add_child(_tell_light)
	_flash_light = PointLight2D.new()
	_flash_light.name = "MuzzleFlash"
	_flash_light.texture = Lights.soft_disc()
	_flash_light.texture_scale = 1.5 * H * 2.0 / 128.0
	_flash_light.height = 0.3 * H
	_flash_light.energy = 0.0
	_flash_light.color = FLASH_IVORY
	_flash_light.blend_mode = Light2D.BLEND_MODE_ADD
	_tell_light.get_parent().add_child(_flash_light)
	_flash_light.position = _tell_light.position


func _get_hero() -> CharacterBody2D:
	return get_tree().get_first_node_in_group("hero") as CharacterBody2D


func _hero_alive(hero: CharacterBody2D) -> bool:
	return hero != null and not ("_died_emitted" in hero and hero._died_emitted)


func _physics_process(delta: float) -> void:
	if state == State.DEFEATED:
		return
	_state_timer += delta
	_rest_t += delta
	_since_shot += delta
	_stagger_t = maxf(0.0, _stagger_t - delta)
	_stagger_cd = maxf(0.0, _stagger_cd - delta)
	_live_rounds = _live_rounds.filter(func(r): return is_instance_valid(r) and not r.is_queued_for_deletion())
	_track_hero()
	_apply_gravity(delta)
	match state:
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
		State.AIM:
			velocity.x = 0.0
			_tick_aim(delta)
		State.FIRE:
			velocity.x = 0.0
			if _state_timer >= tuning.fire_time:
				_enter(State.RELOAD)
		State.RELOAD:
			velocity.x = 0.0
			if _state_timer >= tuning.reload_time:
				_enter(State.APPROACH)
	move_and_slide()
	_update_presentation(delta)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += tuning.gravity * delta
	else:
		velocity.y = 0.0


## Remembers where Dave last stood on a floor: the only place a gun aims.
func _track_hero() -> void:
	var hero := _get_hero()
	if hero == null:
		return
	if hero.is_on_floor() or not _has_ground:
		_hero_ground = hero.global_position
		_has_ground = true


# --- behaviour ---------------------------------------------------------------------

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
	if not _hero_alive(hero):
		return false
	# Proximity only, like a Brawler (no stealth, C16): the clear line gates the shot.
	var d: Vector2 = hero.global_position - global_position
	return absf(d.x) <= tuning.notice_range and absf(d.y) <= tuning.notice_vertical


## A clear line from his eyes to Dave's shoulders (the world only: a low crate never
## hides Dave, there is no stealth, C16; a wall or a floor does).
func can_see(hero: CharacterBody2D) -> bool:
	var q := PhysicsRayQueryParameters2D.create(global_position + Vector2(0.0, -EYE_HEIGHT),
			hero.global_position + Vector2(0.0, -H * 0.85))
	q.collision_mask = 1
	return get_world_2d().direct_space_state.intersect_ray(q).is_empty()


func _notice() -> void:
	if _noticed:
		return
	_noticed = true
	_bark(tuning.voice_notice)


func _tick_approach() -> void:
	velocity.x = 0.0
	var hero := _get_hero()
	if not _hero_alive(hero) or (_group != null and not _group.is_active):
		_set_holding(true)
		return
	var dx: float = hero.global_position.x - global_position.x
	# Between shots he turns to face Dave.
	if absf(dx) > 2.0:
		facing = 1 if dx > 0.0 else -1
	if _ready_to_aim(hero):
		if _group == null or _group.request_attack_token(self):
			_enter(State.AIM)
			return
		_set_holding(true)
		return
	# Walk in while Dave stands on his floor beyond range; with Dave on another floor,
	# step up to the edge until the muzzle has a clear line down to him (the brief: he
	# leans over the edge). _can_step stops him at the edge.
	var same_floor: bool = absf(_hero_ground.y - global_position.y) <= WALK_FLOOR_BAND
	var far: bool = absf(dx) > tuning.engage_range() * 0.8
	var blocked: bool = not same_floor and not _shot_clear(_ground_target(_hero_ground))
	var moving: bool = (same_floor and far or blocked) and _can_step(facing)
	if moving:
		velocity.x = facing * tuning.approach_speed()
	_set_holding(not moving)


## Every gate a tell must pass before it starts: rested, a free round, Dave on a floor
## (never airborne), seen, in range and in front, and the gunner well inside the view.
func _ready_to_aim(hero: CharacterBody2D) -> bool:
	if _rest_t < tuning.rest_time or _live_rounds.size() >= tuning.max_live_rounds:
		return false
	if not hero.is_on_floor() or not _has_ground:
		return false
	if not can_see(hero) or not is_on_camera():
		return false
	var target := _ground_target(_hero_ground)
	var dx: float = (target.x - global_position.x) * float(facing)
	if dx < 8.0:
		return false
	if is_same_floor(_hero_ground):
		return absf(target.x - flat_origin().x) <= tuning.engage_range()
	if shot_origin(target).distance_to(target) > tuning.engage_range() or not _shot_clear(target):
		return false
	var ang := _aim_angle_to(target)
	return ang <= deg_to_rad(tuning.aim_down_max_deg) and ang >= -deg_to_rad(tuning.aim_up_max_deg)


## Where a flat round leaves: ahead of his feet at round_height (the stance's muzzle).
func flat_origin() -> Vector2:
	return global_position + Vector2(facing * tuning.flat_muzzle_x, -tuning.round_height())


## Where a round at `target` (another floor) leaves: shot_reach from the stance
## shoulder toward it. Pose-independent, so the clear-line check and the shot agree.
func shot_origin(target: Vector2) -> Vector2:
	var pivot := _shot_pivot()
	return pivot + (target - pivot).normalized() * tuning.shot_reach


func _shot_pivot() -> Vector2:
	return global_position + Vector2(tuning.shot_pivot.x * facing, tuning.shot_pivot.y)


## A clear line (the world only) from the shot's origin to `target`, as wide as a round
## with a little to spare, so a shot down past a ledge never clips its corner.
func _shot_clear(target: Vector2) -> bool:
	var from := shot_origin(target)
	var n := (target - from).normalized().orthogonal() * (EnemyRound.HALF_THICK + 2.0)
	var space := get_world_2d().direct_space_state
	for off in [Vector2.ZERO, n, -n]:
		var q := PhysicsRayQueryParameters2D.create(from + off, target + off)
		q.collision_mask = 1
		if not space.intersect_ray(q).is_empty():
			return false
	return true


## A grounded spot on his own floor (within same_floor_band): the round goes flat.
func is_same_floor(ground: Vector2) -> bool:
	return absf(ground.y - global_position.y) <= tuning.same_floor_band


## The point a round aims at for Dave standing at `ground`: 0.5 H above his feet.
func _ground_target(ground: Vector2) -> Vector2:
	return ground + Vector2(0.0, -tuning.round_height())


## The readability gate (P23): his body is at least camera_margin_h inside the camera's
## view. Without a camera (isolated tests) the gate is open.
func is_on_camera() -> bool:
	var cam := get_viewport().get_camera_2d() if get_viewport() else null
	if cam == null:
		return true
	var size: Vector2 = get_viewport_rect().size / cam.zoom
	var view := Rect2(cam.get_screen_center_position() - size * 0.5, size)
	var inner := view.grow(-tuning.camera_margin_h * H)
	return inner.has_point(global_position + Vector2(0.0, -HEIGHT * 0.5))


func _tick_aim(delta: float) -> void:
	var red_from: float = tuning.windup_time - tuning.red_time
	if not _locked:
		# Amber: the aim point follows Dave's last grounded spot, no faster than
		# aim_track_speed and never round behind him.
		var want := _ground_target(_hero_ground)
		if (want.x - global_position.x) * float(facing) < 24.0:
			want.x = global_position.x + facing * 24.0
		_aim_point = _aim_point.move_toward(want, tuning.aim_track_speed() * delta)
		if _state_timer >= red_from:
			_lock()
	if _state_timer >= tuning.windup_time:
		if is_on_camera():
			_fire()
		else:
			# Off the readability gate at the moment of the shot: he holds his fire.
			if _group != null:
				_group.release_attack_token(self)
			_rest_t = 0.0
			_enter(State.APPROACH)


## Red: the aim locks (the lock click). On his own floor the shot is the flat line.
func _lock() -> void:
	_locked = true
	_flat = is_same_floor(_aim_point + Vector2(0.0, tuning.round_height()))
	if _flat:
		_aim_point = Vector2(global_position.x + facing * tuning.round_range(), global_position.y - tuning.round_height())
	_play_sfx(tuning.sfx_lock)


func _fire() -> void:
	var start := flat_origin()
	var dir := Vector2(facing, 0.0)
	if not _flat:
		start = shot_origin(_aim_point)
		dir = (_aim_point - start).normalized()
		if dir.x * float(facing) <= 0.0:
			dir = Vector2(facing, 0.0)
	# Muzzle clamp: a wall, or Dave himself, between his body and the muzzle resolves
	# the round right there (the round starts at the body's line and meets it at once).
	var origin := Vector2(global_position.x, start.y)
	var q := PhysicsRayQueryParameters2D.create(origin, start)
	q.collision_mask = 1 | 8
	q.collide_with_areas = true
	q.hit_from_inside = true
	if not get_world_2d().direct_space_state.intersect_ray(q).is_empty():
		start = origin
	var round: Node2D = tuning.round_scene.instantiate() if tuning.round_scene else EnemyRound.new()
	_effect_host().add_child(round)
	round.setup(start, dir, tuning.round_speed(), tuning.round_range(), tuning.damage)
	round.shooter = self
	_live_rounds.append(round)
	_play_sfx(tuning.sfx_fire)
	_since_shot = 0.0
	if gun != null and gun.joints.has(_lamp_joint):
		# The EG01 pistol's own painted flash (batch 7); Level 1's muzzle flash without it.
		var fx := "pistol_flash" if PixelFx.has_fx("pistol_flash") else "muzzle_flash"
		PixelFx.spawn(fx, _tell_light.position + Vector2(2.0, 0.0), gun.joints[_lamp_joint],
				{"local": true, "scale_mul": 1.0 if fx == "pistol_flash" else 0.6})
	if _group != null:
		_group.release_attack_token(self)
	fired.emit(round)
	_enter(State.FIRE)


## The muzzle's world position (the gun's "muzzle" socket), or a stand-in without art.
func muzzle_position() -> Vector2:
	if gun != null:
		var sock: Dictionary = gun.sockets.get("muzzle", {})
		if sock.has("joint") and gun.joints.has(sock["joint"]):
			return gun.joint_point(sock["joint"], sock["pos"])
	return global_position + Vector2(facing * 34.0, -tuning.round_height())


## The arms' angle (radians, + down) from the stance shoulder to `target`, in his
## facing space (the arms and the gun turn by it; the round flies along it).
func _aim_angle_to(target: Vector2) -> float:
	var v := target - _shot_pivot()
	return atan2(v.y, maxf(v.x * float(facing), 1.0))


func _set_holding(on: bool) -> void:
	if on == _holding:
		return
	_holding = on
	if anim == null or state != State.APPROACH:
		return
	var c: String = tuning.clip_ready if on else tuning.clip_stalk
	if anim.clips.has(c):
		anim.play(c, false, 0.2)


func _can_step(dir: int) -> bool:
	if _group != null and not _group.allows_step(global_position, dir):
		return false
	return _floor_ahead(dir) and not _wall_ahead(dir)


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


func _enter(s: State) -> void:
	var was := state
	state = s
	_state_timer = 0.0
	# APPROACH starts holding at low ready; walking in switches to the stalk.
	_holding = s == State.APPROACH
	_hit_anim = false
	match s:
		State.AIM:
			_windups += 1
			_locked = false
			_flat = true
			_aim_point = _ground_target(_hero_ground)
			if _windups % 2 == 1:
				_bark(tuning.voice_windup)
		State.RELOAD:
			_reloads += 1
			_play_sfx(tuning.sfx_reload)
			if _reloads % 2 == 1:
				_bark(tuning.voice_reload)
		State.APPROACH:
			if was == State.RELOAD:
				_rest_t = 0.0
	_play_state_clip(0.05 if s == State.FIRE else 0.16)


# --- damage --------------------------------------------------------------------------

func _on_hit(damage: int, hit_position: Vector2, direction: Vector2) -> void:
	if state == State.DEFEATED:
		return
	health -= damage
	var host := _effect_host()
	Blood.spray(host, hit_position, direction, health <= 0)
	_flash = HIT_FLASH
	_play_sfx(tuning.sfx_hit)
	if rig != null:
		var j: String = rig.nearest_joint(hit_position)
		if rig.sprites.has(j):
			Blood.wound(rig.sprites[j], hit_position, rig.defs[j]["collider"], rig.joints[j])
		var s := -1.0 if signf(direction.x) != float(facing) else 1.0
		anim.jolt({"torso": 0.14 * s, "head": 0.24 * s, "pelvis": 0.05 * s})
	if not _noticed:
		if state == State.PATROL:
			facing = -1 if direction.x > 0.0 else 1
		_notice()
		if state == State.PATROL:
			_enter(State.APPROACH)
	elif not _hurt_barked:
		_hurt_barked = true
		_bark(tuning.voice_hurt)
	if health <= 0:
		_defeat(hit_position, direction)
		return
	_flinch()


## The flinch: only while he holds or walks (a hit never interrupts the tell, the shot
## or the reload), at most once per cooldown.
func _flinch() -> void:
	if anim == null or not anim.clips.has(tuning.clip_hit):
		return
	if not (state == State.PATROL or state == State.APPROACH) or _stagger_cd > 0.0:
		return
	anim.play(tuning.clip_hit, true, 0.05)
	_hit_anim = true
	_stagger_cd = tuning.hit_stagger_cooldown
	_stagger_t = tuning.hit_stagger_time
	velocity.x = 0.0


func _defeat(hit_position: Vector2, direction: Vector2) -> void:
	if state == State.DEFEATED:
		return
	state = State.DEFEATED
	_stop_bark_voice()
	hit_zone.set_deferred("monitorable", false)
	collision_layer = 0
	velocity = Vector2.ZERO
	if _group != null:
		_group.release_attack_token(self)
	if entity_id != "" and Session:
		Session.mark_defeated(entity_id)
	GameFeel.kill(self)
	var host := _effect_host()
	_drop_gun(host, direction)
	if rig != null:
		rig.darken_emissive()
		var rd := Ragdoll.new()
		rd.name = "Body_" + (entity_id if entity_id != "" else String(name))
		rd.z_index = z_index
		host.add_child(rd)
		var push := direction.normalized() * DEATH_PUSH + Vector2(0.0, -90.0)
		rd.build(rig, push, hit_position, Vector2.ZERO)
		rig = null
		rd.settled.connect(_on_body_settled.bind(host))
	_death_caption(host)
	get_tree().create_timer(0.45, false, true).timeout.connect(_play_at.bind(&"body_fall", global_position))
	defeated.emit(entity_id)
	queue_free()


## The pistol leaves his hand as a prop (never a pickup): loose debris that settles.
func _drop_gun(host: Node, direction: Vector2) -> void:
	if gun == null or not is_instance_valid(gun):
		return
	var gt: Transform2D = gun.global_transform
	gun.get_parent().remove_child(gun)
	gun.darken_emissive()
	if is_instance_valid(_tell_light):
		_tell_light.queue_free()
	if is_instance_valid(_flash_light):
		_flash_light.queue_free()
	host.add_child(gun)
	gun.global_position = gt.origin
	gun.rotation = (gt.x * float(facing)).angle()
	gun.facing = facing
	var drop := Ragdoll.new()
	drop.name = "Gun_" + (entity_id if entity_id != "" else String(name))
	host.add_child(drop)
	var push := direction.normalized() * 140.0 + Vector2(0.0, -160.0)
	drop.build(gun, push, gt.origin, Vector2.ZERO, false, 40.0)
	gun = null


## Now and then his last line, cut off (caption only).
func _death_caption(host: Node) -> void:
	if tuning.voice_death.is_empty() or _rng.randf() > 0.34 or bark_label == null:
		return
	var label: Label = bark_label.duplicate()
	label.text = tuning.voice_death[_rng.randi_range(0, tuning.voice_death.size() - 1)]
	label.visible = true
	host.add_child(label)
	label.global_position = global_position + bark_label.position
	var tw := label.create_tween()
	tw.tween_interval(1.2)
	tw.tween_property(label, "modulate:a", 0.0, 0.6)
	tw.tween_callback(label.queue_free)


static func _on_body_settled(_corpse: Node2D, torso_pos: Vector2, host: Node) -> void:
	if is_instance_valid(host):
		Blood.pool(host, torso_pos, 110.0)


func _effect_host() -> Node:
	if _area_root != null and is_instance_valid(_area_root):
		return _area_root
	var scene := get_tree().current_scene
	return scene if scene != null else get_parent()


# --- presentation ----------------------------------------------------------------------

func _play_state_clip(blend: float) -> void:
	if anim == null:
		return
	var c: String = tuning.clip_idle
	match state:
		State.PATROL:
			c = tuning.clip_walk if tuning.patrol_speed() > 0.0 else tuning.clip_idle
		State.APPROACH:
			c = tuning.clip_ready
		State.AIM:
			c = tuning.clip_aim
		State.FIRE:
			c = tuning.clip_fire
		State.RELOAD:
			c = tuning.clip_reload
	if anim.clips.has(c):
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
		if anim.is_finished() and _stagger_t <= 0.0:
			_hit_anim = false
			_play_state_clip(0.2)
	elif state == State.PATROL:
		var want: String = tuning.clip_walk if moving else tuning.clip_idle
		anim.speed = absf(velocity.x) / 70.0 if moving else 1.0
		if anim.clip != want and anim.clips.has(want):
			anim.play(want, false, 0.2)
	else:
		anim.speed = 1.0
	var pose: Dictionary = anim.advance(delta)
	# The whole arm and the gun aim from the shoulder (a shot at another floor).
	var want_aim := 0.0
	if (state == State.AIM or state == State.FIRE) and not _flat_now():
		want_aim = clampf(_aim_angle_to(_aim_point), -deg_to_rad(tuning.aim_up_max_deg), deg_to_rad(tuning.aim_down_max_deg))
	_arm_aim = move_toward(_arm_aim, want_aim, ARM_TURN_SPEED * delta)
	if absf(_arm_aim) > 0.0001:
		for j in tuning.aim_joints:
			pose[j] = float(pose.get(j, 0.0)) + _arm_aim
	rig.apply_pose(pose)
	_update_gun(delta)


## During the amber part the arms already follow a shot at another floor.
func _flat_now() -> bool:
	if _locked:
		return _flat
	return is_same_floor(_aim_point + Vector2(0.0, tuning.round_height()))


func _update_gun(_delta: float) -> void:
	_flash = maxf(0.0, _flash - _delta * 4.0)
	rig.set_flash(_flash)
	if gun == null:
		return
	# The slide racks back through the middle of the reload.
	if _slide_joint != "":
		var back := 0.0
		if state == State.RELOAD:
			var t := _state_timer / maxf(tuning.reload_time, 0.01)
			back = tuning.slide_rack_px * clampf(sin(clampf((t - 0.2) / 0.6, 0.0, 1.0) * PI), 0.0, 1.0)
		gun.joints[_slide_joint].position = _slide_rest + Vector2(-back, 0.0)
	# The tell: the muzzle lamp amber, then red for the last red_time; dark otherwise.
	var energy := 0.0
	var color := AMBER
	if state == State.AIM:
		var k := clampf(_state_timer / tuning.windup_time, 0.0, 1.0)
		color = ALARM if is_tell_red() else AMBER
		energy = lerpf(0.7, 1.6, k)
	_tell_light.color = color
	_tell_light.energy = energy
	if _lamp_joint != "":
		gun.set_emissive(_lamp_joint, color, energy * 2.4)
	_flash_light.energy = 1.2 if _since_shot < FLASH_TIME else 0.0


## True during the red part of the tell (the last red_time).
func is_tell_red() -> bool:
	return state == State.AIM and _state_timer >= tuning.windup_time - tuning.red_time


func is_windup_active() -> bool:
	return state == State.AIM


func is_reloading() -> bool:
	return state == State.RELOAD


## The tell's current colour (amber or red), or transparent when it is dark.
func tell_color() -> Color:
	if _tell_light == null or _tell_light.energy <= 0.0:
		return Color(0, 0, 0, 0)
	return _tell_light.color


func locked_aim_point() -> Vector2:
	return _aim_point


func is_aim_locked() -> bool:
	return state == State.AIM and _locked


func live_round_count() -> int:
	return _live_rounds.size()


# --- barks ---------------------------------------------------------------------------

func _bark(lines: PackedStringArray) -> void:
	if lines.is_empty() or bark_label == null:
		return
	var rng_state := _rng.state
	var text: String = lines[_rng.randi_range(0, lines.size() - 1)]
	var cue := _bark_cue(text)
	var hold := BARK_TIME
	if cue != &"":
		hold = maxf(BARK_TIME, _cue_seconds(cue) + BARK_VOICE_GAP)
	if _group != null and not _group.claim_voice(self, hold):
		_rng.state = rng_state
		return
	bark_label.text = text
	bark_label.visible = true
	_bark_t = BARK_TIME
	if cue != &"":
		_stop_bark_voice()
		_bark_player = Audio.play_sfx(cue, global_position)
		_bark_stream = _bark_player.stream if _bark_player != null else null


func _stop_bark_voice() -> void:
	if _bark_player != null and _bark_stream != null and Audio:
		Audio.stop_player_if_playing(_bark_player, _bark_stream)
	_bark_player = null
	_bark_stream = null


func _exit_tree() -> void:
	_stop_bark_voice()


func _bark_cue(text: String) -> StringName:
	if state == State.DEFEATED or health <= 0 or is_queued_for_deletion():
		return &""
	var cue: StringName = BarkMap.cue_for(text)
	return cue if cue != &"" and Audio.has_cue(cue) else &""


static func _cue_seconds(cue: StringName) -> float:
	var longest := 0.0
	for s in Audio._sfx_pools.get(cue, {}).get("streams", []):
		longest = maxf(longest, (s as AudioStream).get_length())
	return minf(longest, BARK_VOICE_MAX)


func _play_sfx(cue: StringName) -> void:
	if cue != &"":
		Audio.play_sfx(cue, global_position)


static func _play_at(cue: StringName, at: Vector2) -> void:
	Audio.play_sfx(cue, at)


# --- backup warning cue ----------------------------------------------------------------
# The tell is the lamp, the click and the stance; the small warning triangle stays as a
# backup cue over the head during the tell only (roster fairness rules).

func _draw() -> void:
	if state != State.AIM:
		return
	var settings := get_node_or_null("/root/Settings")
	var reduced_motion: bool = settings != null and settings.get_reduced_motion()
	var c: Color = ALARM if is_tell_red() else AMBER
	c.a = 0.95 if reduced_motion else 0.9 + 0.1 * sin(_state_timer * TAU * 3.0)
	var top := Vector2(0.0, -HEIGHT - 26.0)
	var pts := PackedVector2Array([top + Vector2(-8.0, 14.0), top + Vector2(8.0, 14.0), top + Vector2(0.0, -6.0)])
	draw_colored_polygon(pts, c)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), OUTLINE, 2.0, true)
	draw_rect(Rect2(top + Vector2(-1.5, -2.0), Vector2(3.0, 8.0)), OUTLINE)
	draw_circle(top + Vector2(0.0, 10.0), 1.6, OUTLINE)
