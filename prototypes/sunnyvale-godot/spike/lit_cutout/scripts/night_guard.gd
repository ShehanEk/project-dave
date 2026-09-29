extends CharacterBody2D
## SE01 Night Guard for the lit-cutout test (C35): the basic enemy on the
## Brawler loop (C26) — patrol, notice the hero and bark, walk at him with
## the baton up, wind up (the baton tip glows amber, then red for the last
## 0.25 s, with a crackle), one committed overhead strike, then a winded
## recovery that is the punish window. Three hits. Hits never interrupt
## him; they bleed (C29). Death is a ragdoll (see ragdoll.gd).
##
## Drawn by the lit cutout rig (cutout_rig.gd) and posed by rig_animator.gd.
## The hero is only hurt through AttackBox during the strike; enemies and
## the hero never body-block. No class_name (import-cache rule).

signal died(guard: Node, ragdoll: Node)

enum State { PATROL, STALK, WINDUP, SWING, RECOVER, DEAD }

const Rig := preload("res://spike/lit_cutout/scripts/cutout_rig.gd")
const Animator := preload("res://spike/lit_cutout/scripts/rig_animator.gd")
const Ragdoll := preload("res://spike/lit_cutout/scripts/ragdoll.gd")
const Blood := preload("res://spike/lit_cutout/scripts/blood.gd")
const DISC := preload("res://spike/lit_cutout/art/light_disc_smooth.png")
const SND := {
	"crackle": preload("res://spike/lit_cutout/audio/baton_crackle.wav"),
	"swing": preload("res://spike/lit_cutout/audio/baton_swing.wav"),
	"hit": preload("res://spike/lit_cutout/audio/flesh_hit.wav"),
	"fall": preload("res://spike/lit_cutout/audio/body_fall.wav"),
}

const GRAVITY := 1800.0
const PATROL_SPEED := 60.0
const STALK_SPEED := 100.0
const NOTICE_RANGE := 520.0
const ENGAGE_RANGE := 84.0
const FLOOR_BAND := 64.0
const WINDUP_TIME := 0.5
const RED_TIME := 0.25
const SWING_TIME := 0.22
const SWING_ACTIVE_FROM := 0.07
const SWING_ACTIVE_TO := 0.2
const SWING_STEP_SPEED := 60.0
const RECOVER_TIME := 1.2
const HEALTH := 3
const DEATH_PUSH := 300.0
const AMBER := Color("#FFB02E")
const ALARM := Color("#FF3B4E")
const BARKS := {
	"notice": ["Harlan! Get on the fucking ground!", "Security! Don't you move!", "There he is — hands where I can see them!"],
	"windup": ["Don't make me do this!", "Last warning!"],
	"hurt": ["Fuck — he's shooting!", "Shit! Shots fired!"],
	"recover": ["Stay down, damn it..."],
}

@export var patrol_min_x: float = 0.0
@export var patrol_max_x: float = 0.0
@export var start_facing: int = -1
## Test hook: off = he stands and never attacks (for lighting inspection).
@export var aggressive: bool = true

var state: State = State.PATROL
var health: int = HEALTH
var rig: Node2D
var anim
var hit_zone: HitZone
var attack_box: AttackBox
var tell_light: PointLight2D
var bark_label: Label
var _t: float = 0.0
var _flash: float = 0.0
var _hurt_barked: bool = false
var _bark_t: float = 0.0
var _windups: int = 0
var _players: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("enemy")
	collision_layer = 1 << 2
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	floor_snap_length = 8.0
	var body_shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(22.0, 94.0)
	body_shape.shape = r
	body_shape.position = Vector2(0.0, -47.0)
	add_child(body_shape)

	rig = Rig.new()
	rig.name = "Rig"
	add_child(rig)   # builds itself in _ready
	rig.facing = start_facing
	anim = Animator.new()

	hit_zone = HitZone.new()
	hit_zone.name = "HitZone"
	var hs := CollisionShape2D.new()
	var hr := RectangleShape2D.new()
	hr.size = Vector2(30.0, 96.0)
	hs.shape = hr
	hs.position = Vector2(0.0, -48.0)
	hit_zone.add_child(hs)
	add_child(hit_zone)
	hit_zone.hit.connect(_on_hit)

	attack_box = AttackBox.new()
	attack_box.name = "AttackBox"
	attack_box.damage = 1
	var ab := CollisionShape2D.new()
	var ar := RectangleShape2D.new()
	ar.size = Vector2(46.0, 56.0)
	ab.shape = ar
	attack_box.add_child(ab)
	add_child(attack_box)

	tell_light = PointLight2D.new()
	tell_light.name = "TellLight"
	tell_light.texture = DISC
	tell_light.texture_scale = 0.55
	tell_light.height = 14.0
	tell_light.energy = 0.0
	tell_light.color = AMBER
	tell_light.blend_mode = Light2D.BLEND_MODE_ADD
	tell_light.position = Vector2(0.0, 25.5)
	rig.joints["baton"].add_child(tell_light)

	bark_label = Label.new()
	bark_label.name = "Bark"
	bark_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bark_label.size = Vector2(300.0, 24.0)
	bark_label.position = Vector2(-150.0, -150.0)
	bark_label.add_theme_font_size_override("font_size", 15)
	bark_label.add_theme_color_override("font_color", Color("#E8EDF2"))
	bark_label.add_theme_color_override("font_outline_color", Color("#05070B"))
	bark_label.add_theme_constant_override("outline_size", 6)
	bark_label.z_index = 40
	bark_label.visible = false
	add_child(bark_label)

	for k in SND:
		var p := AudioStreamPlayer2D.new()
		p.stream = SND[k]
		p.bus = &"SFX" if AudioServer.get_bus_index(&"SFX") >= 0 else &"Master"
		add_child(p)
		_players[k] = p
	_enter(State.PATROL)


func _hero() -> Node2D:
	return get_tree().get_first_node_in_group("hero") as Node2D


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_t += delta
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0
	match state:
		State.PATROL:
			_tick_patrol()
		State.STALK:
			_tick_stalk()
		State.WINDUP:
			_tick_windup()
		State.SWING:
			_tick_swing()
		State.RECOVER:
			velocity.x = 0.0
			if _t >= RECOVER_TIME:
				_enter(State.STALK)
	move_and_slide()
	_update_attack_box()
	_update_presentation(delta)


func _tick_patrol() -> void:
	if not aggressive or patrol_max_x <= patrol_min_x:
		velocity.x = 0.0
		if anim.clip != "idle":
			anim.play("idle")
	else:
		if global_position.x <= patrol_min_x:
			rig.facing = 1
		elif global_position.x >= patrol_max_x:
			rig.facing = -1
		velocity.x = PATROL_SPEED * rig.facing
		if not _floor_ahead(rig.facing):
			rig.facing = -rig.facing
	if aggressive and _hero_in_notice_range():
		_bark("notice")
		_enter(State.STALK)


func _hero_in_notice_range() -> bool:
	var hero := _hero()
	if hero == null or ("_died_emitted" in hero and hero._died_emitted):
		return false
	var d := hero.global_position - global_position
	return absf(d.y) <= FLOOR_BAND and absf(d.x) <= NOTICE_RANGE


func _tick_stalk() -> void:
	var hero := _hero()
	if hero == null:
		velocity.x = 0.0
		return
	var dx := hero.global_position.x - global_position.x
	var same_floor := absf(hero.global_position.y - global_position.y) <= FLOOR_BAND
	rig.facing = 1 if dx >= 0.0 else -1
	if same_floor and absf(dx) <= ENGAGE_RANGE:
		_enter(State.WINDUP)
		return
	var dir: int = rig.facing
	if not _floor_ahead(dir) or _wall_ahead(dir) or not same_floor:
		velocity.x = 0.0
	else:
		velocity.x = STALK_SPEED * dir


func _tick_windup() -> void:
	velocity.x = 0.0
	if _t >= WINDUP_TIME:
		_enter(State.SWING)


func _tick_swing() -> void:
	velocity.x = SWING_STEP_SPEED * rig.facing if _t < 0.12 and _floor_ahead(rig.facing) else 0.0
	attack_box.active = _t >= SWING_ACTIVE_FROM and _t <= SWING_ACTIVE_TO
	if _t >= SWING_TIME:
		attack_box.active = false
		_enter(State.RECOVER)


func _enter(s: State) -> void:
	state = s
	_t = 0.0
	match s:
		State.PATROL:
			anim.play("walk" if aggressive and patrol_max_x > patrol_min_x else "idle", true, 0.2)
		State.STALK:
			anim.play("stalk", true, 0.2)
		State.WINDUP:
			anim.play("windup", true, 0.1)
			_play("crackle")
			_windups += 1
			if _windups % 2 == 0:
				_bark("windup")
		State.SWING:
			anim.play("swing", true, 0.04)
			_play("swing")
		State.RECOVER:
			anim.play("recover", true, 0.18)


func _update_attack_box() -> void:
	attack_box.position = Vector2(34.0 * rig.facing, -60.0)


func _update_presentation(delta: float) -> void:
	match state:
		State.PATROL:
			anim.speed = absf(velocity.x) / 70.0 if anim.clip == "walk" else 1.0
		State.STALK:
			anim.speed = maxf(absf(velocity.x) / STALK_SPEED, 0.35)
		_:
			anim.speed = 1.0
	rig.apply_pose(anim.advance(delta))
	# The tell: amber, then red for the last RED_TIME; the baton tip glows
	# and its light falls on the guard's own arm and face.
	var tell_energy := 0.0
	var tell_color := AMBER
	if state == State.WINDUP:
		var k := clampf(_t / WINDUP_TIME, 0.0, 1.0)
		tell_color = ALARM if _t >= WINDUP_TIME - RED_TIME else AMBER
		tell_energy = lerpf(0.5, 1.6, k)
	elif state == State.SWING:
		tell_color = ALARM
		tell_energy = 1.4 * (1.0 - _t / SWING_TIME) + 0.3
	tell_light.color = tell_color
	tell_light.energy = tell_energy
	rig.set_tell(tell_color, tell_energy * 2.2)
	_flash = maxf(0.0, _flash - delta * 4.0)
	rig.set_flash(_flash)
	if _bark_t > 0.0:
		_bark_t -= delta
		bark_label.visible = _bark_t > 0.0
		bark_label.modulate.a = clampf(_bark_t / 0.4, 0.0, 1.0)


func _bark(kind: String) -> void:
	var lines: Array = BARKS[kind]
	bark_label.text = lines[_rng.randi_range(0, lines.size() - 1)]
	bark_label.visible = true
	_bark_t = 1.8


func _play(k: String) -> void:
	if _players.has(k):
		_players[k].play()


func _on_hit(damage: int, hit_position: Vector2, direction: Vector2) -> void:
	if state == State.DEAD:
		return
	health -= damage
	var host := get_parent()
	Blood.spray(host, hit_position, direction, health <= 0)
	var j: String = rig.nearest_joint(hit_position)
	Blood.wound(rig.sprites[j], hit_position, rig.defs[j]["collider"], rig.joints[j])
	_flash = 0.25
	_play("hit")
	_suppress_spark.call_deferred(hit_position)
	# A jolt away from the shot; it never interrupts what he is doing.
	var from_front := signf(direction.x) != float(rig.facing)
	var s := -1.0 if from_front else 1.0
	anim.jolt({"torso": 0.16 * s, "head": 0.26 * s, "near_upper_arm": -0.12 * s, "far_upper_arm": -0.2 * s, "pelvis": 0.05 * s})
	if state == State.PATROL and aggressive:
		rig.facing = -1 if direction.x > 0.0 else 1
		_bark("notice")
		_enter(State.STALK)
	elif not _hurt_barked:
		_hurt_barked = true
		_bark("hurt")
	if health <= 0:
		_die(hit_position, direction)


func _die(hit_position: Vector2, direction: Vector2) -> void:
	state = State.DEAD
	attack_box.active = false
	hit_zone.set_deferred("monitorable", false)
	collision_layer = 0
	tell_light.energy = 0.0
	bark_label.visible = false
	var host := get_parent()
	var rd := Ragdoll.new()
	rd.name = "Ragdoll"
	rd.z_index = z_index
	host.add_child(rd)
	var push := direction.normalized() * DEATH_PUSH + Vector2(0.0, -90.0)
	rd.build(rig, push, hit_position, velocity)
	rig = null
	var fall_player: AudioStreamPlayer2D = _players["fall"]
	remove_child(fall_player)
	rd.add_child(fall_player)
	fall_player.global_position = global_position
	rd.get_tree().create_timer(0.45, false, true).timeout.connect(fall_player.play.bind(0.0))
	rd.settled.connect(func(_corpse: Node2D, torso_pos: Vector2) -> void:
		Blood.pool(host, torso_pos, 110.0))
	died.emit(self, rd)
	queue_free()


## People bleed instead of showing the bolt's green HIT spark (roster rule:
## the spark is suppressed on anything with a fluid). ScrapBolt spawns the
## spark right after take_hit() returns, so remove it a moment later.
func _suppress_spark(at: Vector2) -> void:
	var tree := get_tree()
	if tree == null:
		return
	for root in [tree.current_scene, tree.root]:
		if root == null:
			continue
		for c in root.get_children():
			if c is ImpactSpark and (c as Node2D).global_position.distance_to(at) < 3.0:
				c.queue_free()


func _floor_ahead(dir: int) -> bool:
	var probe_x := global_position.x + dir * 18.0
	var q := PhysicsRayQueryParameters2D.create(Vector2(probe_x, global_position.y - 4.0), Vector2(probe_x, global_position.y + 40.0))
	q.collision_mask = 1
	return not get_world_2d().direct_space_state.intersect_ray(q).is_empty()


func _wall_ahead(dir: int) -> bool:
	var y := global_position.y - 48.0
	var q := PhysicsRayQueryParameters2D.create(Vector2(global_position.x, y), Vector2(global_position.x + dir * 22.0, y))
	q.collision_mask = 1
	return not get_world_2d().direct_space_state.intersect_ray(q).is_empty()
