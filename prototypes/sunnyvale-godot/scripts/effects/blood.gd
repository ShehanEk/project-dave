extends RefCounted
## Visible blood (C29, C35): a spray at the hit point
## along the shot, a few drops that land as small floor splats, a wound mark
## stuck to the part that was hit (it tumbles with the ragdoll), and a pool
## that spreads under a settled body. Decals use the lit part shader with a
## wet specular value, so they glint under lamps and stay dark red in the
## dark. Blood is #B3212F drying to #8A1A26 (roster fairness rules): never a
## tell colour, never glowing, drawn below tells, shots and pickups.
##
## `enabled = false` (the Blood setting) swaps the spray for dark dust and
## skips wounds, splats and pools. No class_name (import-cache rule).

const LitShader := preload("res://assets/shaders/lit_part.gdshader")
const DIR := "res://assets/effects/blood/"
const WET := Color("#B3212F")
const DRIED := Color("#8A1A26")
const DUST := Color(0.2, 0.22, 0.26)
const GRAVITY := 1500.0
const MAX_DECALS := 60

const OIL := Color("#14181E")

static var enabled: bool = true
static var _decals: Array = []
static var _rng := RandomNumberGenerator.new()
static var _tex: Dictionary = {}


## Textures load on first use (tools/art/paint_blood.py writes them); a
## missing one just skips that effect.
static func _t(file: String) -> Texture2D:
	if not _tex.has(file):
		var p := DIR + file
		_tex[file] = load(p) if ResourceLoader.exists(p) else null
	return _tex[file]


static func _material(normal: Texture2D) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = LitShader
	m.set_shader_parameter("normal_atlas", normal if normal != null else _t("flat_normal.png"))
	m.set_shader_parameter("spec_atlas", _t("wet_spec.png"))
	m.set_shader_parameter("ambient", Vector3(0.3, 0.3, 0.34))
	m.set_shader_parameter("spec_gain", 1.4)
	return m


## A burst at `pos` travelling along `dir` (the shot), plus a little
## back-spray; drops that fall to the floor leave splats.
static func spray(host: Node, pos: Vector2, dir: Vector2, heavy: bool = false) -> void:
	var d := dir.normalized() if dir.length() > 0.01 else Vector2.RIGHT
	var p := CPUParticles2D.new()
	p.texture = _t("drop.png")
	p.one_shot = true
	p.explosiveness = 0.92
	p.amount = 26 if heavy else 14
	p.lifetime = 0.7
	p.local_coords = false
	p.direction = d
	p.spread = 24.0
	p.initial_velocity_min = 90.0
	p.initial_velocity_max = 300.0 if heavy else 220.0
	p.gravity = Vector2(0.0, GRAVITY)
	p.damping_min = 20.0
	p.damping_max = 60.0
	p.scale_amount_min = 0.1
	p.scale_amount_max = 0.24
	p.color = WET if enabled else DUST
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 1, 1, 1))
	ramp.set_color(1, Color(0.8, 0.8, 0.8, 0.0))
	p.color_ramp = ramp
	p.z_index = 2
	host.add_child(p)
	p.global_position = pos
	p.emitting = true
	_free_later(p, 1.2)
	if not enabled:
		return
	var back := p.duplicate() as CPUParticles2D
	back.amount = 5
	back.direction = -d
	back.initial_velocity_max = 90.0
	host.add_child(back)
	back.global_position = pos
	back.emitting = true
	_free_later(back, 1.2)
	var floor_y = _floor_below(host, pos)
	if floor_y == null:
		return
	for i in (4 if heavy else 2):
		var v := d.rotated(deg_to_rad(_rng.randf_range(-22.0, 22.0))) * _rng.randf_range(90.0, 240.0)
		var dy: float = float(floor_y) - pos.y
		# y(t) = vy t + g t^2 / 2 = dy
		var a := 0.5 * GRAVITY
		var disc := v.y * v.y + 4.0 * a * dy
		if disc < 0.0:
			continue
		var t := (-v.y + sqrt(disc)) / (2.0 * a)
		var land := Vector2(pos.x + v.x * t * 0.85, float(floor_y))
		var tree := host.get_tree()
		if tree:
			tree.create_timer(t, false, true).timeout.connect(_splat.bind(host, land))


static func _splat(host, at: Vector2) -> void:
	if not is_instance_valid(host):
		return
	var pool_tex := _t("pool.png")
	if pool_tex == null:
		return
	var s := Sprite2D.new()
	s.texture = pool_tex
	s.material = _material(_t("pool_n.png"))
	s.centered = true
	# The pool texture is drawn at 3x: scale = wanted world size / texture size.
	s.scale = Vector2(_rng.randf_range(3.0, 8.0) / float(pool_tex.get_width()), 0.12)
	s.modulate = Color(0.85, 0.82, 0.82)
	# Under the floor block, so its lit top edge (the ledge cue) stays on top.
	s.z_index = -1
	host.add_child(s)
	s.global_position = at + Vector2(0.0, -1.4)
	_track(s)


## A wound mark on the part sprite that was hit, kept inside the part.
static func wound(part_sprite: Sprite2D, global_pos: Vector2, collider: Dictionary, joint: Node2D) -> void:
	if not enabled or part_sprite == null:
		return
	# Clamp the mark toward the part's bone so it never hangs off its edge.
	var local: Vector2 = joint.global_transform.affine_inverse() * global_pos
	if collider["type"] == "circle":
		var c := Vector2(collider["c"][0], collider["c"][1])
		var r := maxf(float(collider["r"]) - 1.6, 0.5)
		if local.distance_to(c) > r:
			local = c + (local - c).normalized() * r
	else:
		var a := Vector2(collider["a"][0], collider["a"][1])
		var b := Vector2(collider["b"][0], collider["b"][1])
		var q := Geometry2D.get_closest_point_to_segment(local, a, b)
		var r2 := maxf(float(collider["r"]) - 1.4, 0.4)
		if local.distance_to(q) > r2:
			local = q + (local - q).normalized() * r2
	var i := _rng.randi_range(0, 2)
	var wound_tex := _t("wound_%d.png" % i)
	if wound_tex == null:
		return
	var w := Sprite2D.new()
	w.texture = wound_tex
	w.material = _material(_t("wound_%d_n.png" % i))
	w.centered = true
	w.rotation = _rng.randf_range(-0.6, 0.6)
	w.scale = Vector2.ONE * _rng.randf_range(0.45, 0.7)
	w.z_index = 0
	w.light_mask = 1 | 2
	part_sprite.add_child(w)
	# The part sprite sits on the joint at 1/3 scale (its pivot offset only
	# moves the texture, not children), so a joint-space point is its
	# sprite-space point divided by that scale.
	w.position = Vector2(local.x / part_sprite.scale.x, local.y / part_sprite.scale.y)


## A pool spreading under a settled body, on the floor line.
static func pool(host: Node, near: Vector2, width_px: float = 64.0) -> void:
	if enabled:
		_spread(host, near, width_px, Color(0.88, 0.85, 0.85))


## Oil and coolant from a wrecked machine (never gore, so it ignores the
## Blood setting): the same sheet, near-black with a cold sheen.
static func oil_pool(host: Node, near: Vector2, width_px: float = 48.0) -> void:
	_spread(host, near, width_px, Color(0.17, 0.2, 0.25))


static func _spread(host: Node, near: Vector2, width_px: float, tint: Color) -> void:
	var pool_tex := _t("pool.png")
	if pool_tex == null:
		return
	var floor_y = _floor_below(host, near + Vector2(0.0, -20.0))
	if floor_y == null:
		return
	var s := Sprite2D.new()
	s.texture = pool_tex
	s.material = _material(_t("pool_n.png"))
	s.centered = true
	# Under the floor block, so its lit top edge (the ledge cue) stays on top.
	s.z_index = -1
	s.modulate = tint
	host.add_child(s)
	s.global_position = Vector2(near.x, float(floor_y) - 2.9)
	# The pool texture is drawn at 3x: scale = wanted world size / texture size.
	var full := width_px / float(pool_tex.get_width())
	s.scale = Vector2(full * 0.12, 0.18)
	var tw := s.create_tween()
	tw.set_parallel(true)
	tw.tween_property(s, "scale", Vector2(full, 0.24), 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "modulate", tint * Color(1.04, 1.02, 1.02), 6.0)
	_track(s)


static func _floor_below(host: Node, from: Vector2):
	if not (host is Node2D) or not host.is_inside_tree():
		return null
	var space := (host as Node2D).get_world_2d().direct_space_state
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0.0, 400.0))
	q.collision_mask = 1
	var hit := space.intersect_ray(q)
	return null if hit.is_empty() else float(hit.position.y)


static func _track(n: Node) -> void:
	_decals.append(n)
	while _decals.size() > MAX_DECALS:
		var old = _decals.pop_front()
		if is_instance_valid(old):
			old.queue_free()


static func _free_later(n: Node, secs: float) -> void:
	var tree := n.get_tree()
	if tree:
		# Bound to the node itself, so the call simply drops if it is gone.
		tree.create_timer(secs, false, true).timeout.connect(n.queue_free)


static func clear() -> void:
	for d in _decals:
		if is_instance_valid(d):
			d.queue_free()
	_decals.clear()
