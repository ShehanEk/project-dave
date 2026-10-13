class_name BoomBroom
extends Node2D
## W02 Boom Broom (M3): Dave's pump-action industrial shotgun, his second weapon type
## (art-design/weapons/w02-boom-broom.md). Like the Scrapjack it hangs on the hero's
## AimPivot (hero.gd swaps the node there when the held weapon's type changes) and turns
## with the C50 aim steps; Dave's arm holds it by its grip (the rig's origin, GRIP_LOCAL)
## and the blast leaves at the `muzzle` socket. Tuning: data/tuning/w02_boom_broom.tres
## (ShotgunTuning, every number there).
##
## Firing. Holding `fire` blasts whenever the gun is ready: `pellet_count` pellets fan out
## evenly across `spread_degrees` (plus a little jitter, kept inside the cone) along the
## hero's exact shot direction (hero.shot_direction(), like the Scrapjack). Each pellet is
## a ray from the muzzle (mask world | hittable) up to `max_range`; the pellets that reach
## a target add up pellet_damage x falloff(distance), and the target takes the sum rounded
## (at least 1) in ONE take_hit(), so it bleeds, flinches and dies once per blast. A target
## between the shoulder and the muzzle (point blank, overlapping Dave) takes every pellet at
## full damage, and a wall there stops the blast (the Scrapjack's muzzle clamp). A hit
## enemy is pushed away (scripts/combat/knockback.gd), by the share of the blast that
## reached it; the Patrol Rover only staggers, the Drone flies further.
##
## The pump. A blast spends one shell and starts the pump (`pump_time`): the pump slides
## back, the spent shell flies from the ejection port (scripts/effects/shell_casing.gd),
## the pump runs forward and the gun is ready again. Shells: the held instance's own count
## in Session (`loaded` in the tube, `reserve`), so a swap, a checkpoint and a death all
## keep them honest; a gun with no Session entry (a demo) keeps its own. The reload feeds
## one shell every `shell_insert_time`: on its own when the tube is empty, or after
## `reload_delay` s without firing while a shell is missing; firing stops it (the shells
## already in stay in). An empty gun with an empty reserve clicks.
##
## Upgrades (Session.weapon_stage("W02"), cumulative, fitted parts shown on the rig):
## 1 Extended Tube (the tube holds 6), 2 Incendiary Shells (a hit target burns:
## scripts/combat/burn.gd; ember pellets), 3 Twin Shell (`try_twin_blast()`: two shells,
## more pellets and push, a longer recovery; bound to an optional `fire_alt` action when
## the project has one; there is none yet).
##
## `held = false` draws the same gun resting on a pad (no input, a contact shadow; the pad
## draws the copy's workshop tag), like the Scrapjack.

signal fired(pellets: int)
signal pumped
signal shell_loaded(loaded: int, reserve: int)

enum Action { READY, PUMP, RELOAD }

@export var tuning: ShotgunTuning
@export var held: bool = true

@onready var _muzzle: Marker2D = $Muzzle

const RIG_PATH := "res://assets/characters/lit/boom_broom/rig.json"
const CutoutRig := preload("res://scripts/actors/lit/cutout_rig.gd")
const PixelFx := preload("res://scripts/effects/pixel_fx.gd")
const Knockback := preload("res://scripts/combat/knockback.gd")
const Burn := preload("res://scripts/combat/burn.gd")
const BlastTrails := preload("res://scripts/effects/blast_trails.gd")
const ShellCasing := preload("res://scripts/effects/shell_casing.gd")
## Where the fist holds the grip, in this node's space (the Scrapjack's, so the same
## GUN_HOLD per aim step puts the fist in the same place).
const GRIP_LOCAL := Vector2(2.0, 3.0)
## The placeholder rig is painted at 55 world px long; drawn at this share (about 50 px,
## the brief's 0.92 m at Dave's 96 px for 1.70 m).
const ART_SCALE := 0.9
## How long after a pad swap the new gun racks its pump, ready (the Scrapjack's click).
const READY_CLICK_DELAY := 0.25
## The flash light: warm ivory like every firearm flash, hotter with Incendiary Shells.
const FLASH_COLOR := Color("#FFE4BD")
const INCENDIARY_FLASH_COLOR := Color("#FFB070")
const FLASH_TIME := 0.09
const FLASH_HEIGHT := 26.0
const EMBER := Color("#FF9436")
## The view's kick on a blast (GameFeel.shot gives the Scrapjack's 2.2; this adds to it).
const BLAST_KICK := 3.5
## Ejected shells: thrown up and back from the port (px/s, in the gun's frame), spinning.
const EJECT_VELOCITY := Vector2(-70.0, -190.0)
const EJECT_SPIN := 14.0
## The stage each upgrade part shows from.
const UPGRADE_PARTS := {"ext_tube": 1, "heat_collar": 2, "twin_pod": 3}
## How far below and ahead of the grip a shell being fed starts (the underside port), px.
const FEED_FROM := Vector2(9.0, 7.0)
const FEED_TO := Vector2(9.0, 0.5)
## At most this many wall sparks per blast (six pellets on one wall read as one spark).
const MAX_WALL_SPARKS := 2

var action: int = Action.READY
var _action_t: float = 0.0
var _action_len: float = 0.0
var _ejected := 0
var _to_eject := 1
var _pump_played := false
var _idle_t: float = 0.0
var _recoil_timer: float = 0.0
var _hero: Node = null
var _instance_id: String = ""
var _local_ammo: Dictionary = {}
var _fire_was_pressed := false
var _alt_was_pressed := false
var _muzzle_light: PointLight2D = null
var _heat: float = 0.0
var _twin_flash: float = 0.0
var rng := RandomNumberGenerator.new()
var rig: Node2D = null
var _pump_rest := Vector2.ZERO
var _feed: Sprite2D = null
## The last blast, for tests and the capture demo: {"directions": [Vector2], "paths":
## [[from, to, stopped]], "targets": {HitZone: {"damage", "pellets", "outcome"}}, "twin"}.
var last_blast: Dictionary = {}
## Shells thrown so far (tests).
var shells_ejected: int = 0


func _ready() -> void:
	if tuning == null:
		tuning = load("res://data/tuning/w02_boom_broom.tres")
	rng.randomize()
	_build_rig()
	if held and Session:
		if not Session.weapon_swapped.is_connected(_on_weapon_swapped):
			Session.weapon_swapped.connect(_on_weapon_swapped)
		if not Session.snapshot_restored.is_connected(_on_snapshot_restored):
			Session.snapshot_restored.connect(_on_snapshot_restored)


func _exit_tree() -> void:
	if Session:
		if Session.weapon_swapped.is_connected(_on_weapon_swapped):
			Session.weapon_swapped.disconnect(_on_weapon_swapped)
		if Session.snapshot_restored.is_connected(_on_snapshot_restored):
			Session.snapshot_restored.disconnect(_on_snapshot_restored)


# --- the held instance and its shells ---------------------------------------------------

## A swap to another Boom Broom copy keeps this node: cancel the pump or reload (S02:
## "swapping cancels unfinished ... reload actions") and rack the new copy.
func _on_weapon_swapped(_old_id: String, _new_id: String) -> void:
	_cancel_actions()
	if held and is_inside_tree() and Session and Session.weapon_type_of(Session.equipped_weapon()) == "W02":
		announce_ready()


func _on_snapshot_restored(_checkpoint_id: String) -> void:
	_cancel_actions()


func _cancel_actions() -> void:
	action = Action.READY
	_action_t = 0.0
	_idle_t = 0.0


## The rack a beat after the gun comes into Dave's hands at a pad (hero.gd calls this
## when it puts this gun on the pivot because of a swap).
func announce_ready() -> void:
	if held and is_inside_tree():
		get_tree().create_timer(READY_CLICK_DELAY).timeout.connect(_play_ready)


func _play_ready() -> void:
	if is_inside_tree():
		_play(tuning.sfx_pump)


func _sync_instance() -> void:
	var id := Session.equipped_weapon() if Session else ""
	if id != _instance_id:
		_instance_id = id
		_cancel_actions()


func _uses_session_ammo() -> bool:
	return Session != null and _instance_id != "" and Session.has_ammo(_instance_id)


## {"loaded", "reserve"} of the held instance.
func ammo() -> Dictionary:
	if _uses_session_ammo():
		return Session.weapon_ammo(_instance_id)
	if _local_ammo.is_empty():
		_local_ammo = {"loaded": capacity(), "reserve": tuning.reserve_capacity}
	return _local_ammo.duplicate()


func loaded() -> int:
	return int(ammo().get("loaded", 0))


func reserve() -> int:
	return int(ammo().get("reserve", 0))


func capacity() -> int:
	return tuning.capacity_for_stage(_current_stage())


func _set_ammo(new_loaded: int, new_reserve: int) -> void:
	if _uses_session_ammo():
		Session.set_weapon_ammo(_instance_id, new_loaded, new_reserve)
	else:
		_local_ammo = {"loaded": clampi(new_loaded, 0, capacity()), "reserve": clampi(new_reserve, 0, tuning.reserve_capacity)}


func _current_stage() -> int:
	return Session.weapon_stage(tuning.weapon_type) if Session else 0


## True while a blast can go off now (the HUD's readiness light): pumped, a shell in.
func is_ready() -> bool:
	return action != Action.PUMP and loaded() >= 1


func is_pumping() -> bool:
	return action == Action.PUMP


func is_reloading() -> bool:
	return action == Action.RELOAD


# --- per tick ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_update_upgrade_parts()
	if not held:
		queue_redraw()
		return
	if _hero == null and get_parent():
		_hero = get_parent().get_parent()  # AimPivot -> Hero
	_sync_instance()
	_recoil_timer = maxf(0.0, _recoil_timer - delta)
	_heat = maxf(0.0, _heat - delta / 1.2)
	_twin_flash = maxf(0.0, _twin_flash - delta)
	var input_ok: bool = _hero == null or not ("input_enabled" in _hero) or _hero.input_enabled
	var firing: bool = input_ok and Input.is_action_pressed("fire")
	var alt: bool = input_ok and InputMap.has_action("fire_alt") and Input.is_action_pressed("fire_alt")
	_tick_action(delta, firing or alt)
	if alt and not _alt_was_pressed and _current_stage() >= 3:
		try_twin_blast()
	elif firing:
		if is_ready():
			_blast(false)
		elif not _fire_was_pressed and loaded() <= 0 and reserve() <= 0:
			_play(tuning.sfx_empty)
	_fire_was_pressed = firing
	_alt_was_pressed = alt
	_update_muzzle_light(delta)
	_update_rig()
	queue_redraw()


## The pump and the reload, advanced by `delta`. `wants_fire`: the trigger is held.
func _tick_action(delta: float, wants_fire: bool) -> void:
	match action:
		Action.PUMP:
			_action_t += delta
			if not _pump_played and _action_t >= tuning.pump_back_at:
				_pump_played = true
				_play(tuning.sfx_pump)
			if _ejected < _to_eject and _action_t >= tuning.eject_at:
				while _ejected < _to_eject:
					_eject_shell(_ejected)
					_ejected += 1
			if _action_t >= _action_len:
				action = Action.READY
				_action_t = 0.0
				_idle_t = 0.0
				pumped.emit()
		Action.RELOAD:
			var a := ammo()
			if wants_fire and int(a["loaded"]) >= 1:
				# The reload can stop to fire (the brief); the shell being fed stays in reserve.
				action = Action.READY
				_action_t = 0.0
				return
			_action_t += delta
			if _action_t >= tuning.shell_insert_time:
				_action_t -= tuning.shell_insert_time
				var l := int(a["loaded"]) + 1
				var r := int(a["reserve"]) - 1
				_set_ammo(l, r)
				_play(tuning.sfx_shell_in)
				shell_loaded.emit(l, r)
				if l >= capacity() or r <= 0:
					action = Action.READY
					_action_t = 0.0
		_:
			if wants_fire:
				_idle_t = 0.0
			else:
				_idle_t += delta
			var a := ammo()
			var l := int(a["loaded"])
			if int(a["reserve"]) > 0 and l < capacity() and (l == 0 or (not wants_fire and _idle_t >= tuning.reload_delay)):
				action = Action.RELOAD
				_action_t = 0.0


# --- the blast --------------------------------------------------------------------------

## The Twin Shell blast (stage 3): two shells at once. False (nothing happens) below stage
## 3, with fewer than 2 shells loaded (S02: unavailable with only 1), or while pumping.
func try_twin_blast() -> bool:
	if _current_stage() < 3 or action == Action.PUMP or loaded() < 2:
		return false
	_blast(true)
	return true


## Fires one blast now if the gun is ready (tests and demos; the player holds `fire`).
func try_blast() -> bool:
	if not is_ready():
		return false
	_blast(false)
	return true


## Evenly spaced pellet angles (radians, centred on 0) across `spread_deg`, edge to edge.
static func pellet_angles(count: int, spread_deg: float) -> Array[float]:
	var out: Array[float] = []
	if count <= 0:
		return out
	if count == 1:
		out.append(0.0)
		return out
	var half := deg_to_rad(spread_deg) * 0.5
	for i in count:
		out.append(lerpf(-half, half, float(i) / float(count - 1)))
	return out


## This blast's pellet directions around `forward`: the even fan plus jitter, inside the cone.
func pellet_directions(forward: Vector2, count: int, spread_deg: float) -> Array[Vector2]:
	var half := deg_to_rad(spread_deg) * 0.5
	var jitter := deg_to_rad(tuning.pellet_jitter_degrees)
	var out: Array[Vector2] = []
	for a in pellet_angles(count, spread_deg):
		var j := clampf(a + rng.randf_range(-jitter, jitter), -half, half)
		out.append(forward.rotated(j))
	return out


func _blast(twin: bool) -> void:
	var stage := _current_stage()
	var a := ammo()
	var spend := 2 if twin else 1
	_set_ammo(int(a["loaded"]) - spend, int(a["reserve"]))
	action = Action.PUMP
	_action_t = 0.0
	_action_len = tuning.twin_recovery_time if twin else tuning.pump_time
	_ejected = 0
	_to_eject = spend
	_pump_played = false
	_idle_t = 0.0
	_recoil_timer = tuning.recoil_recovery_time
	_heat = 1.0
	if twin:
		_twin_flash = 0.25
	var incendiary := stage >= 2
	_play(tuning.sfx_fire, _muzzle.global_position)
	_flash_muzzle_light(incendiary, twin)

	var pivot: Node2D = get_parent()
	var shoulder: Vector2 = pivot.global_position if pivot else global_position
	var muzzle_pos: Vector2 = _muzzle.global_position
	var forward: Vector2 = (pivot.global_transform.x if pivot else global_transform.x).normalized()
	var hero := pivot.get_parent() if pivot else null
	if hero and hero.has_method("shot_direction"):
		forward = hero.shot_direction()
	var count: int = tuning.twin_pellet_count if twin else tuning.pellet_count
	var spread: float = tuning.twin_spread_degrees if twin else tuning.spread_degrees
	var dirs := pellet_directions(forward, count, spread)

	var space := get_world_2d().direct_space_state
	var targets := {}   # HitZone -> {"shares", "pellets", "pos"}
	var paths: Array = []
	var wall_hits: Array[Vector2] = []
	var clamp_ray := _ray(space, shoulder, muzzle_pos)
	if not clamp_ray.is_empty():
		# Point blank: whatever lies between the shoulder and the muzzle takes the whole blast.
		var c = clamp_ray["collider"]
		if c is HitZone:
			targets[c] = {"shares": tuning.pellet_damage * float(count), "pellets": count, "pos": clamp_ray["position"]}
		else:
			wall_hits.append(clamp_ray["position"])
	else:
		for d in dirs:
			var to := muzzle_pos + d * tuning.max_range
			var r := _ray(space, muzzle_pos, to)
			if r.is_empty():
				paths.append([muzzle_pos, to, false])
				continue
			var at: Vector2 = r["position"]
			paths.append([muzzle_pos, at, true])
			var c = r["collider"]
			if c is HitZone:
				var t: Dictionary = targets.get(c, {"shares": 0.0, "pellets": 0, "pos": at})
				t["shares"] = float(t["shares"]) + tuning.pellet_damage * tuning.falloff(muzzle_pos.distance_to(at))
				t["pellets"] = int(t["pellets"]) + 1
				targets[c] = t
			elif wall_hits.size() < MAX_WALL_SPARKS:
				wall_hits.append(at)

	var any_hit := false
	var report := {}
	for zone in targets:
		var t: Dictionary = targets[zone]
		var dmg := tuning.blast_damage(float(t["shares"]))
		var outcome: StringName = (zone as HitZone).take_hit(dmg, t["pos"], forward)
		report[zone] = {"damage": dmg, "pellets": int(t["pellets"]), "outcome": outcome}
		if outcome == &"hit":
			any_hit = true
			if incendiary:
				Burn.ignite(zone, tuning.burn_ticks, tuning.burn_interval, tuning.burn_damage)
			_push(zone, float(t["shares"]) / maxf(tuning.pellet_damage * float(count), 0.001), twin, hero)
			if not (zone as HitZone).bleeds:
				_spark(t["pos"], forward, true)
				_play(&"bolt_hit", t["pos"])
		else:
			_spark(t["pos"], forward, false)
			_play(&"bolt_blocked", t["pos"])
	for at in wall_hits:
		_spark(at, forward, false)
	if not wall_hits.is_empty():
		_play(&"bolt_blocked", wall_hits[0])
	if any_hit:
		GameFeel.hit_pause()

	BlastTrails.spawn(_spawn_container(), muzzle_pos, forward, paths, tuning.pellet_trail_time, incendiary)
	# The painted shotgun blast (batch 7, sized for the Broom: muzzle_flash_scale 1.9 is its own
	# size); Level 1's muzzle flash scaled up without it.
	if PixelFx.has_fx("shotgun_blast"):
		PixelFx.spawn("shotgun_blast", Vector2.ZERO, _muzzle, {"local": true,
				"scale_mul": tuning.muzzle_flash_scale / 1.9 * (1.3 if twin else 1.0)})
	else:
		PixelFx.spawn("muzzle_flash", Vector2.ZERO, _muzzle, {"local": true,
				"scale_mul": tuning.muzzle_flash_scale * (1.3 if twin else 1.0)})
	GameFeel.shot(self, forward)
	var cam := get_viewport().get_camera_2d() if get_viewport() else null
	if cam and cam.has_method("kick"):
		cam.kick(-forward * BLAST_KICK * (1.5 if twin else 1.0) * _motion_scale())
	last_blast = {"directions": dirs, "paths": paths, "targets": report, "twin": twin, "forward": forward,
			"muzzle": muzzle_pos}
	fired.emit(count)


func _ray(space: PhysicsDirectSpaceState2D, from: Vector2, to: Vector2) -> Dictionary:
	var q := PhysicsRayQueryParameters2D.create(from, to)
	q.collision_mask = 1 | 16  # layer 1 world | layer 5 hittable
	q.collide_with_areas = true
	q.collide_with_bodies = true
	q.hit_from_inside = true
	return space.intersect_ray(q)


## Pushes the enemy that owns `zone` away from Dave: `share` of the blast reached it.
func _push(zone: HitZone, share: float, twin: bool, hero: Node) -> void:
	var body := _owner_body(zone)
	if body == null:
		return
	var from_x: float = (hero as Node2D).global_position.x if hero is Node2D else global_position.x
	var side := signf(body.global_position.x - from_x)
	if side == 0.0:
		side = 1.0
	var speed := tuning.knockback_speed * clampf(share, 0.0, 1.0) * (tuning.twin_knockback_scale if twin else 1.0)
	speed *= knockback_scale_for(body)
	Knockback.push(body, side * speed, tuning.knockback_decay)


## The share of a push an enemy takes: the Rover (heavy, on wheels) staggers, the Drone
## (light, in the air) flies further, everyone else takes it whole.
func knockback_scale_for(body: Node) -> float:
	if body is PatrolRover:
		return tuning.heavy_knockback_scale
	if body is Drone:
		return tuning.light_knockback_scale
	return 1.0


static func _owner_body(zone: Node) -> CharacterBody2D:
	var n := zone.get_parent()
	for i in 4:
		if n == null:
			return null
		if n is CharacterBody2D:
			return n
		n = n.get_parent()
	return null


func _spark(at: Vector2, forward: Vector2, hit: bool) -> void:
	var spark := ImpactSpark.new()
	spark.dir = forward
	spark.color = ScrapBolt.HIT_COLOR if hit else ScrapBolt.BLOCK_COLOR
	spark.shape = ImpactSpark.Shape.HIT if hit else ImpactSpark.Shape.BLOCKED
	spark.global_position = at
	_spawn_container().add_child(spark)


func _eject_shell(index: int) -> void:
	if rig == null:
		return
	var sock: Dictionary = rig.sockets.get("eject", {})
	var at: Vector2 = global_position
	if not sock.is_empty() and rig.joints.has(sock["joint"]):
		at = rig.joint_point(sock["joint"], sock["pos"])
	# Up and back in the gun's own frame (flipped with Dave's facing by the pivot).
	var v := global_transform.basis_xform(EJECT_VELOCITY).normalized() * EJECT_VELOCITY.length()
	v.y = minf(v.y, -120.0)
	v += Vector2(rng.randf_range(-20.0, 20.0) + float(index) * 25.0, rng.randf_range(-20.0, 10.0))
	ShellCasing.throw(_spawn_container(), rig, at, v, EJECT_SPIN * (1.0 if rng.randf() < 0.5 else -1.0),
			tuning.sfx_shell_drop)
	shells_ejected += 1


# --- the look ---------------------------------------------------------------------------

func _build_rig() -> void:
	if not ResourceLoader.exists(RIG_PATH):
		return
	rig = CutoutRig.new()
	rig.name = "Rig"
	rig.rig_path = RIG_PATH
	add_child(rig)
	move_child(rig, 0)
	rig.position = GRIP_LOCAL
	# Under the arm; Dave's rig (hero_rig_visual.gd set_gun) re-layers it between his upper
	# arm and his fist.
	rig.z_index = -8
	var s := ART_SCALE / maxf(absf(scale.x), 0.001)
	rig.scale = Vector2(s, s)
	if rig.joints.has("pump"):
		_pump_rest = rig.joints["pump"].position
	if rig.sprites.has("shell"):
		(rig.sprites["shell"] as Sprite2D).visible = false
		# The shell being fed into the underside port during a reload.
		var src: Sprite2D = rig.sprites["shell"]
		_feed = Sprite2D.new()
		_feed.name = "FeedShell"
		_feed.texture = src.texture
		_feed.region_enabled = true
		_feed.region_rect = src.region_rect
		_feed.centered = false
		_feed.offset = src.offset
		_feed.scale = src.scale
		_feed.material = src.material
		_feed.light_mask = src.light_mask
		_feed.rotation = PI * 0.5
		_feed.visible = false
		_feed.z_index = 0
		rig.joints[rig.order[0]].add_child(_feed)
	var sock: Dictionary = rig.sockets.get("muzzle", {})
	if not sock.is_empty() and rig.joints.has(sock["joint"]):
		var j: Node2D = rig.joints[sock["joint"]]
		_muzzle.position = rig.position + (j.position + sock["pos"]) * s
	_update_upgrade_parts()
	_update_rig()


func _update_upgrade_parts() -> void:
	if rig == null:
		return
	var stage := _current_stage()
	for part in UPGRADE_PARTS:
		if rig.sprites.has(part):
			(rig.sprites[part] as Sprite2D).visible = stage >= int(UPGRADE_PARTS[part])


func _motion_scale() -> float:
	var settings := get_node_or_null("/root/Settings")
	return 0.5 if (settings and settings.get_reduced_motion()) else 1.0


## Recoil (the gun kicks back and its muzzle lifts), the pump's stroke, the shell being fed,
## and the upgrade glows.
func _update_rig() -> void:
	var k: float = 0.0
	if held and tuning.recoil_recovery_time > 0.0:
		k = _recoil_timer / tuning.recoil_recovery_time
	var m := _motion_scale()
	rotation = -deg_to_rad(tuning.muzzle_lift_degrees) * k * k * m if held else 0.0
	if rig == null:
		return
	rig.position = GRIP_LOCAL + Vector2(-tuning.recoil_distance * k * m, 0.0)
	if rig.joints.has("pump"):
		rig.joints["pump"].position = _pump_rest + Vector2(-tuning.pump_travel * pump_stroke(), 0.0)
	if _feed:
		_feed.visible = held and action == Action.RELOAD
		if _feed.visible:
			var f := clampf(_action_t / maxf(tuning.shell_insert_time, 0.01), 0.0, 1.0)
			_feed.position = FEED_FROM.lerp(FEED_TO, smoothstep(0.15, 0.85, f))
	if rig.sprites.has("heat_collar"):
		rig.set_emissive("heat_collar", EMBER, 0.35 + 1.8 * _heat)
	if rig.sprites.has("twin_pod"):
		rig.set_emissive("twin_pod", EMBER, 0.5 + (2.5 if _twin_flash > 0.0 else 0.0))


## How far back the pump is, 0 (forward, at rest) .. 1 (fully back).
func pump_stroke() -> float:
	if action != Action.PUMP:
		return 0.0
	var t := _action_t
	var back_end := tuning.eject_at
	if t < tuning.pump_back_at:
		return 0.0
	if t < back_end:
		return smoothstep(tuning.pump_back_at, back_end, t)
	if t < tuning.pump_forward_at:
		return 1.0 - smoothstep(back_end, tuning.pump_forward_at, t)
	return 0.0


func _flash_muzzle_light(incendiary: bool, twin: bool) -> void:
	var k := _motion_scale()
	if _muzzle_light == null:
		_muzzle_light = SceneryDraw.make_light(_muzzle, SceneryDraw.smooth_disc_texture(),
				Vector2.ZERO, tuning.flash_radius, FLASH_COLOR, 0.0, FLASH_HEIGHT)
		_muzzle_light.name = "MuzzleFlashLight"
	_muzzle_light.color = INCENDIARY_FLASH_COLOR if incendiary else FLASH_COLOR
	_muzzle_light.energy = tuning.flash_energy * k * (1.3 if twin else 1.0)
	_muzzle_light.visible = true


func _update_muzzle_light(delta: float) -> void:
	if _muzzle_light == null:
		return
	var k := _motion_scale()
	_muzzle_light.energy = move_toward(_muzzle_light.energy, 0.0, tuning.flash_energy * k / FLASH_TIME * delta)
	_muzzle_light.visible = _muzzle_light.energy > 0.001


func _draw() -> void:
	if not held:
		# Resting on a pad: a small flat contact shadow (the pad names the copy).
		draw_set_transform(Vector2(10, 9), 0.0, Vector2(2.6, 0.4))
		draw_circle(Vector2.ZERO, 10.0, Color(0.0, 0.0, 0.0, 0.22))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if rig == null:
		_draw_placeholder()


## The drawn gun, for when the rig's art is missing: barrel, tube, pump, receiver, stock.
func _draw_placeholder() -> void:
	var o := GRIP_LOCAL
	draw_rect(Rect2(o + Vector2(-17, -7), Vector2(12, 9)), Color("#2F3438"))
	draw_rect(Rect2(o + Vector2(-6, -8.5), Vector2(16, 7)), Color("#E0702A"))
	draw_rect(Rect2(o + Vector2(9, -7.5), Vector2(25, 4.5)), Color("#AEB9BF"))
	draw_rect(Rect2(o + Vector2(8, -2.8), Vector2(22, 3.6)), Color("#444F58"))
	draw_rect(Rect2(o + Vector2(13 - tuning.pump_travel * pump_stroke(), -3.6), Vector2(10, 5.4)), Color("#3E9E7E"))
	draw_rect(Rect2(o + Vector2(-3, -2), Vector2(5, 8)), Color("#2F3438"))
	draw_rect(Rect2(o + Vector2(-6, -8.5), Vector2(16, 7)), Color("#0A0C10"), false, 1.5)


func get_muzzle_global_position() -> Vector2:
	return _muzzle.global_position


func _play(cue: StringName, at: Variant = null) -> void:
	if cue == &"":
		return
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue, at if at != null else global_position)


## Spawned effects live in the current scene (a level rebuild frees them), else the root.
func _spawn_container() -> Node:
	var scene := get_tree().current_scene
	return scene if scene != null else get_tree().root
