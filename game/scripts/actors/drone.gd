class_name Drone
extends CharacterBody2D
## The Drone template (C26, M4): the flying diver, first the M02 Security Drone. Loop:
## hover a span at its set height (where it was placed) with a slight bob -> notice Dave
## below it -> (attack token) the tell: it noses up and stops almost still while the
## lightbar goes amber, then red for the last `red_time` (its announcement now and then);
## the aim follows Dave's last grounded spot at head height (at most 3 H/s, no lead) and
## locks at red -> a straight, committed dive at the locked spot (it cannot turn once it
## starts; the AttackBox is live only here) -> it hangs at head height, fork spent, fans
## spooling down (the punish window) -> it climbs back to its height -> rests -> again.
## Hits never interrupt it. Sparks and oil, never blood; destroyed, it falls apart into
## debris that settles in an oil stain (C28, C29).
##
## Fairness (P23): a tell starts only while Dave stands on a floor and the drone is at
## least 1 H inside the camera's view; the dive goes at his last grounded spot, never at
## him in the air; sidestepping the locked spot always avoids it. Everything else is
## DroneTuning data. The node's origin is the hull's centre (it flies).

signal defeated(entity_id: String)

enum State { PATROL, TELL, DIVE, HANG, CLIMB, DEFEATED }

const Rig := preload("res://scripts/actors/lit/cutout_rig.gd")
const Ragdoll := preload("res://scripts/actors/lit/ragdoll.gd")
const Blood := preload("res://scripts/effects/blood.gd")
const Lights := preload("res://scripts/actors/lit/lights.gd")
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")
const BarkMap := preload("res://scripts/audio/bark_map.gd")
## Batch 7: the shock fork crackles through the dive (PixelFx "shock_arc", one play after
## another at the rig's `fork_tip` socket, riding on the fork), never before it (no tell of its
## own: the lightbar is the tell).
const PixelFx := preload("res://scripts/effects/pixel_fx.gd")

const H := 96.0
## The hull's size (px), for probes and the warning cue.
const HULL_HALF := Vector2(22.0, 8.0)
const AMBER := Color("#FFB02E")
const ALARM := Color("#FF3B4E")
const OUTLINE := Color("#05070B")
## Adam's own hardware (C60): the underglow strip and its light.
const NEON := Color("#FF3DD5")
const HIT_FLASH := 0.2
const BARK_TIME := 1.8
const DEBRIS_SPREAD := 150.0
## How fast it settles onto its hover height (1/s), and drifts to a stop in the tell.
const HOVER_SPRING := 6.0
const TELL_BRAKE := 10.0

@export var tuning: DroneTuning
@export var entity_id: String = ""
## Patrol span in the owning AreaRoot's local space; unbounded = its start x +- the
## tuning's patrol_half_span.
@export var patrol_min_x: float = -INF
@export var patrol_max_x: float = INF
@export var start_facing: int = -1

var state: State = State.PATROL
var facing: int = -1
var health: int = 2
var rig: Node2D
var _state_timer: float = 0.0
var _rest_t: float = 999.0
var _home_y: float = 0.0
var _span: Vector2 = Vector2(-INF, INF)
var _noticed: bool = false
var _tells: int = 0
var _group: EncounterGroup = null
var _area_root: Node2D = null
var _hero_ground: Vector2 = Vector2.ZERO
var _has_ground: bool = false
## The dive's target: Dave's grounded spot at head height, followed through amber.
var _lock_point: Vector2 = Vector2.ZERO
var _locked: bool = false
var _dive_dir: Vector2 = Vector2.DOWN
var _dive_len: float = 0.0
var _dived: float = 0.0
var _pitch: float = 0.0
var _fork: float = 0.0
var _arc: Node = null
var _fan_phase: float = 0.0
var _fan_speed: float = 40.0
var _anim_t: float = 0.0
var _flash: float = 0.0
var _bark_t: float = 0.0
var _tell_light: PointLight2D
var _underglow: PointLight2D
var _lens_glow: Sprite2D
var _fans: Array[String] = []
var _rng := RandomNumberGenerator.new()

@onready var hit_zone: HitZone = $HitZone
@onready var attack_box: AttackBox = $AttackBox
@onready var bark_label: Label = $Bark


func _ready() -> void:
	add_to_group("enemy")
	if tuning == null:
		tuning = load("res://data/tuning/security_drone.tres")
	if entity_id != "" and Session and Session.is_defeated(entity_id):
		queue_free()
		return
	collision_layer = 1 << 2  # layer 3: enemy_body
	collision_mask = 1        # layer 1: world only
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	health = tuning.health
	facing = 1 if start_facing >= 0 else -1
	_rng.seed = hash(entity_id) if entity_id != "" else 1
	attack_box.damage = tuning.damage
	hit_zone.hit.connect(_on_hit)
	_group = _find_ancestor(EncounterGroup) as EncounterGroup
	_area_root = _find_ancestor(AreaRoot) as Node2D
	_home_y = global_position.y
	_span = _patrol_span()
	_anim_t = _rng.randf() * 10.0
	_build_visual()


func _find_ancestor(type) -> Node:
	var p := get_parent()
	while p:
		if is_instance_of(p, type):
			return p
		p = p.get_parent()
	return null


func _leash() -> Node2D:
	return _area_root if _area_root else (get_parent() as Node2D)


## The patrol span in leash-local x.
func _patrol_span() -> Vector2:
	var leash := _leash()
	var x: float = leash.to_local(global_position).x if leash else global_position.x
	var lo := patrol_min_x if patrol_min_x > -INF else x - tuning.patrol_half_span
	var hi := patrol_max_x if patrol_max_x < INF else x + tuning.patrol_half_span
	return Vector2(lo, hi)


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
	# Its pale shell levels off earlier under a lamp, like the rover's (patrol_rover.gd).
	for m in rig._materials:
		(m as ShaderMaterial).set_shader_parameter("knee_start", 0.4)
		(m as ShaderMaterial).set_shader_parameter("knee_soft", 3.0)
	for j in rig.order:
		if String(rig.defs[j].get("role", j)).begins_with("fan"):
			_fans.append(j)
	_tell_light = PointLight2D.new()
	_tell_light.name = "TellLight"
	_tell_light.texture = Lights.soft_disc()
	# Small and gentle: on the pale hull a bigger light washed the whole drone pink
	# (the rover's lesson); the lightbar's own glow carries the tell.
	_tell_light.texture_scale = 0.45
	_tell_light.height = 14.0
	_tell_light.energy = 0.0
	_tell_light.color = AMBER
	_tell_light.blend_mode = Light2D.BLEND_MODE_ADD
	var sock: Dictionary = rig.sockets.get("tell", {})
	var bar := _part("lightbar")
	if bar != "":
		rig.joints[bar].add_child(_tell_light)
		_tell_light.position = sock.get("pos", Vector2.ZERO)
	else:
		rig.add_child(_tell_light)
	# The small, dim, steady amber point at the canopy lens while it hunts.
	_lens_glow = Sprite2D.new()
	_lens_glow.name = "LensGlow"
	_lens_glow.texture = Lights.soft_disc()
	_lens_glow.scale = Vector2.ONE * 0.09
	_lens_glow.modulate = Color(AMBER, 0.0)
	_lens_glow.z_index = 12
	_lens_glow.light_mask = 0
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lens_glow.material = mat
	var lens: Dictionary = rig.sockets.get("lens_light", {})
	var lj: String = lens.get("joint", _part("hull"))
	if lj != "" and rig.joints.has(lj):
		rig.joints[lj].add_child(_lens_glow)
		_lens_glow.position = lens.get("pos", Vector2.ZERO)
	# Adam's magenta underglow: a soft steady light under the belly, dimmer than the tell.
	_underglow = PointLight2D.new()
	_underglow.name = "Underglow"
	_underglow.texture = Lights.soft_disc()
	_underglow.texture_scale = 0.6
	_underglow.scale = Vector2(1.4, 0.6)
	_underglow.position = Vector2(0.0, 9.0)
	_underglow.height = 6.0
	_underglow.energy = 0.45
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


func _get_hero() -> CharacterBody2D:
	return get_tree().get_first_node_in_group("hero") as CharacterBody2D


func _hero_alive(hero: CharacterBody2D) -> bool:
	return hero != null and not ("_died_emitted" in hero and hero._died_emitted)


func _physics_process(delta: float) -> void:
	if state == State.DEFEATED:
		return
	_state_timer += delta
	_anim_t += delta
	_track_hero()
	match state:
		State.PATROL:
			_rest_t += delta
			_tick_patrol(delta)
		State.TELL:
			_tick_tell(delta)
		State.DIVE:
			_tick_dive(delta)
		State.HANG:
			velocity = Vector2.ZERO
			if _state_timer >= tuning.hang_time:
				_enter(State.CLIMB)
		State.CLIMB:
			_tick_climb(delta)
	if state != State.DIVE:
		move_and_slide()
	_update_presentation(delta)


func _track_hero() -> void:
	var hero := _get_hero()
	if hero == null:
		return
	if hero.is_on_floor() or not _has_ground:
		_hero_ground = hero.global_position
		_has_ground = true


# --- behaviour -------------------------------------------------------------------------

func _tick_patrol(_delta: float) -> void:
	var hero := _get_hero()
	if _hero_noticed(hero):
		if not _noticed:
			_noticed = true
		if _rest_t >= tuning.rest_time and _can_start_tell(hero):
			if _group == null or _group.request_attack_token(self):
				_enter(State.TELL)
				return
	var leash := _leash()
	var x: float = leash.to_local(global_position).x if leash else global_position.x
	if x <= _span.x:
		facing = 1
	elif x >= _span.y:
		facing = -1
	elif is_on_wall():
		facing = -facing
	elif _group != null and not _group.allows_step(global_position, facing, 24.0):
		facing = -facing
	var bob := 0.0 if _reduced_motion() else sin(_anim_t * 2.2) * tuning.bob_px
	velocity.x = facing * tuning.patrol_speed()
	velocity.y = (_home_y + bob - global_position.y) * HOVER_SPRING


func _hero_noticed(hero: CharacterBody2D) -> bool:
	if _group != null and not _group.is_active:
		return false
	if not _hero_alive(hero):
		return false
	var d: Vector2 = hero.global_position - global_position
	return absf(d.x) <= tuning.notice_range and d.y >= 0.0 and d.y <= tuning.notice_below and can_see(hero)


## A clear line from the hull to Dave's middle (the world only).
func can_see(hero: CharacterBody2D) -> bool:
	var q := PhysicsRayQueryParameters2D.create(global_position, hero.global_position + Vector2(0.0, -H * 0.5))
	q.collision_mask = 1
	return get_world_2d().direct_space_state.intersect_ray(q).is_empty()


## Dave on a floor (never airborne), the dive within reach and below it, and the drone
## well inside the camera's view.
func _can_start_tell(hero: CharacterBody2D) -> bool:
	if not hero.is_on_floor() or not _has_ground or not is_on_camera():
		return false
	var target := _dive_target(_hero_ground)
	if target.y <= global_position.y + 8.0:
		return false
	return global_position.distance_to(target) <= tuning.dive_max()


## Where a dive at Dave standing at `ground` ends: head height over his feet.
func _dive_target(ground: Vector2) -> Vector2:
	return ground + Vector2(0.0, -tuning.hang_height())


## The readability gate (P23): the hull at least camera_margin_h inside the camera's view.
## Without a camera (isolated tests) the gate is open.
func is_on_camera() -> bool:
	var cam := get_viewport().get_camera_2d() if get_viewport() else null
	if cam == null:
		return true
	var size: Vector2 = get_viewport_rect().size / cam.zoom
	var view := Rect2(cam.get_screen_center_position() - size * 0.5, size)
	return view.grow(-tuning.camera_margin_h * H).has_point(global_position)


func _tick_tell(delta: float) -> void:
	# It stops almost still, holding its height.
	velocity.x = move_toward(velocity.x, 0.0, TELL_BRAKE * tuning.patrol_speed() * delta)
	velocity.y = (_home_y - global_position.y) * HOVER_SPRING
	if not _locked:
		var want := _dive_target(_hero_ground)
		_lock_point = _lock_point.move_toward(want, tuning.aim_track_speed() * delta)
		if absf(_lock_point.x - global_position.x) > 2.0:
			facing = 1 if _lock_point.x > global_position.x else -1
		if _state_timer >= tuning.windup_time - tuning.red_time:
			_locked = true
	if _state_timer >= tuning.windup_time:
		_enter(State.DIVE)


func _tick_dive(delta: float) -> void:
	var remaining := _dive_len - _dived
	var step := minf(tuning.dive_speed() * delta, remaining)
	velocity = _dive_dir * (step / maxf(delta, 0.0001))
	var before := global_position
	move_and_slide()
	_dived += (global_position - before).length()
	if get_slide_collision_count() > 0 or _dived >= _dive_len - 0.5 or step <= 0.0:
		_enter(State.HANG)


func _tick_climb(delta: float) -> void:
	velocity.x = 0.0
	velocity.y = -tuning.climb_speed()
	if global_position.y - tuning.climb_speed() * delta <= _home_y or is_on_ceiling():
		velocity.y = 0.0
		_enter(State.PATROL)


func _enter(s: State) -> void:
	state = s
	_state_timer = 0.0
	match s:
		State.PATROL:
			_rest_t = 0.0
		State.TELL:
			_tells += 1
			_locked = false
			_lock_point = _dive_target(_hero_ground)
			facing = 1 if _lock_point.x >= global_position.x else -1
			_play_sfx(tuning.sfx_tell)
			if _tells % 2 == 1:
				_bark(tuning.voice_tell)
		State.DIVE:
			_locked = true
			var to := _lock_point - global_position
			_dive_len = minf(to.length(), tuning.dive_max())
			_dive_dir = to.normalized() if to.length() > 0.5 else Vector2.DOWN
			_dived = 0.0
			attack_box.active = true
			_play_sfx(tuning.sfx_dive)
		State.HANG:
			velocity = Vector2.ZERO
			attack_box.active = false
			if _group != null:
				_group.release_attack_token(self)
			if rig != null:
				var tip: Dictionary = rig.sockets.get("fork_tip", {})
				var at: Vector2 = rig.joint_point(tip["joint"], tip["pos"]) if tip.has("joint") and rig.joints.has(tip["joint"]) else global_position
				KenneyPuff.spawn(&"machine_smoke", at, _effect_host())
		State.CLIMB:
			attack_box.active = false


# --- damage ------------------------------------------------------------------------------

func _on_hit(damage: int, hit_position: Vector2, direction: Vector2) -> void:
	if state == State.DEFEATED:
		return
	health -= damage
	_flash = HIT_FLASH
	var host := _effect_host()
	KenneyPuff.spawn(&"machine_spark", hit_position, host)
	Blood.oil_drip(host, hit_position, direction)
	_play_sfx(tuning.sfx_hit)
	if health <= 0:
		_defeat(hit_position, direction)


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
	_play_sfx(tuning.sfx_destroyed)
	GameFeel.kill(self)
	var host := _effect_host()
	KenneyPuff.spawn(&"machine_smoke", global_position, host)
	KenneyPuff.spawn(&"machine_spark", global_position, host)
	if rig != null:
		# Everything goes dark: the lightbar, the lens, the magenta strip.
		rig.darken_emissive()
		rig.set_flash(0.0)
		if is_instance_valid(_lens_glow):
			_lens_glow.queue_free()
		var wreck := Ragdoll.new()
		wreck.name = "Wreck_" + (entity_id if entity_id != "" else String(name))
		wreck.z_index = z_index
		host.add_child(wreck)
		var push: Vector2 = direction.normalized() * 120.0 if direction != Vector2.ZERO else Vector2.ZERO
		wreck.build(rig, push, hit_position, Vector2.ZERO, false, DEBRIS_SPREAD)
		wreck.settled.connect(_on_wreck_settled.bind(host))
		rig = null
	defeated.emit(entity_id)
	queue_free()


static func _on_wreck_settled(_pieces: Node2D, centre: Vector2, host: Node) -> void:
	if is_instance_valid(host):
		Blood.oil_pool(host, centre, 40.0)
		Audio.play_sfx(&"debris_clatter", centre)


func _effect_host() -> Node:
	if _area_root != null and is_instance_valid(_area_root):
		return _area_root
	var scene := get_tree().current_scene
	return scene if scene != null else get_parent()


# --- queries (tests, the lab) ------------------------------------------------------------

func is_windup_active() -> bool:
	return state == State.TELL


func is_tell_red() -> bool:
	return state == State.TELL and _state_timer >= tuning.windup_time - tuning.red_time


func is_diving() -> bool:
	return state == State.DIVE


func is_hanging() -> bool:
	return state == State.HANG


func locked_point() -> Vector2:
	return _lock_point


func is_lock_set() -> bool:
	return _locked


func home_y() -> float:
	return _home_y


func tell_color() -> Color:
	if _tell_light == null or _tell_light.energy <= 0.0:
		return Color(0, 0, 0, 0)
	return _tell_light.color


# --- presentation ------------------------------------------------------------------------

func _reduced_motion() -> bool:
	var settings := get_node_or_null("/root/Settings")
	return settings != null and settings.get_reduced_motion()


func _update_presentation(delta: float) -> void:
	if _bark_t > 0.0:
		_bark_t -= delta
		bark_label.visible = _bark_t > 0.0
		bark_label.modulate.a = clampf(_bark_t / 0.4, 0.0, 1.0)
	queue_redraw()
	_flash = maxf(0.0, _flash - delta * 5.0)
	attack_box.position = Vector2(facing * 6.0, 4.0)
	if rig == null:
		return
	rig.facing = facing
	var calm := _reduced_motion()
	# Pitch: a lean into the drift, nose up in the tell, nose down along the dive.
	var want_pitch := 0.0
	var want_fork := 0.0
	var fan_want := 40.0
	match state:
		State.PATROL:
			want_pitch = deg_to_rad(4.0) * signf(velocity.x) * float(facing)
		State.TELL:
			want_pitch = deg_to_rad(tuning.tell_pitch_deg)
			fan_want = 46.0
		State.DIVE:
			want_pitch = clampf(atan2(_dive_dir.y, absf(_dive_dir.x)), 0.0, deg_to_rad(tuning.dive_pitch_deg + 30.0))
			want_fork = deg_to_rad(tuning.fork_dive_deg)
			fan_want = 60.0
		State.HANG:
			want_fork = deg_to_rad(tuning.fork_dive_deg)
			fan_want = 14.0
			if not calm:
				want_pitch = deg_to_rad(3.0) * sin(_state_timer * 7.0) * maxf(0.0, 1.0 - _state_timer)
		State.CLIMB:
			want_pitch = deg_to_rad(-6.0)
			fan_want = 52.0
	_pitch = move_toward(_pitch, want_pitch, 4.0 * delta)
	_fork = move_toward(_fork, want_fork, (14.0 if state == State.DIVE else 3.0) * delta)
	if state == State.DIVE and not is_instance_valid(_arc):
		_arc = _spawn_arc()
	_fan_speed = move_toward(_fan_speed, fan_want, 60.0 * delta)
	_fan_phase += _fan_speed * delta * (0.35 if calm else 1.0)
	var pose := {}
	var hull := _part("hull")
	if hull != "":
		pose[hull] = _pitch
	var fork := _part("fork")
	if fork != "":
		pose[fork] = _fork
	rig.apply_pose(pose)
	for f in _fans:
		# The two-frame spin: the disc flips edge-on and back.
		(rig.joints[f] as Node2D).scale.x = 1.0 if fmod(_fan_phase, 2.0) < 1.0 else -0.55
	# The lightbar: dark on patrol, amber then red through the tell, red in the dive, a
	# small point after it.
	var color := AMBER
	var bar_energy := 0.12
	var light_energy := 0.0
	match state:
		State.TELL:
			color = ALARM if is_tell_red() else AMBER
			bar_energy = 2.4
			light_energy = lerpf(0.25, 0.55, clampf(_state_timer / tuning.windup_time, 0.0, 1.0))
		State.DIVE:
			color = ALARM
			bar_energy = 2.4
			light_energy = 0.5
		State.HANG, State.CLIMB:
			bar_energy = 0.3
	var bar := _part("lightbar")
	if bar != "":
		rig.set_emissive(bar, color, bar_energy)
	_tell_light.color = color
	_tell_light.energy = light_energy
	if is_instance_valid(_lens_glow):
		_lens_glow.modulate = Color(AMBER, 0.75 if _noticed else 0.0)
	rig.set_flash(_flash)


## One crackle of the shock arc at the fork's tip (null without the strip or the socket).
func _spawn_arc() -> Node:
	if rig == null:
		return null
	var tip: Dictionary = rig.sockets.get("fork_tip", {})
	if not tip.has("joint") or not rig.joints.has(tip["joint"]):
		return null
	return PixelFx.spawn("shock_arc", tip["pos"], rig.joints[tip["joint"]], {"local": true})


## True while a shock arc plays at the fork (tests).
func is_arcing() -> bool:
	return is_instance_valid(_arc)


func _bark(lines: PackedStringArray) -> void:
	if lines.is_empty() or bark_label == null:
		return
	if _group != null and not _group.claim_voice(self, BARK_TIME):
		return
	var text: String = lines[_rng.randi_range(0, lines.size() - 1)]
	bark_label.text = text
	bark_label.visible = true
	_bark_t = BARK_TIME
	var cue: StringName = BarkMap.cue_for(text)
	if cue != &"" and Audio.has_cue(cue):
		Audio.play_sfx(cue, global_position)


func _play_sfx(cue: StringName) -> void:
	if cue != &"":
		Audio.play_sfx(cue, global_position)


# --- backup warning cue --------------------------------------------------------------------

func _draw() -> void:
	if state != State.TELL:
		return
	var c: Color = ALARM if is_tell_red() else AMBER
	c.a = 0.95 if _reduced_motion() else 0.9 + 0.1 * sin(_state_timer * TAU * 3.0)
	var top := Vector2(0.0, -HULL_HALF.y - 30.0)
	var pts := PackedVector2Array([top + Vector2(-8.0, 14.0), top + Vector2(8.0, 14.0), top + Vector2(0.0, -6.0)])
	draw_colored_polygon(pts, c)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), OUTLINE, 2.0, true)
	draw_rect(Rect2(top + Vector2(-1.5, -2.0), Vector2(3.0, 8.0)), OUTLINE)
	draw_circle(top + Vector2(0.0, 10.0), 1.6, OUTLINE)
