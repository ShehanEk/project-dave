class_name EnemyRound
extends Node2D
## One enemy gun round (M4: the EG01 pistol's, the Gunner template's shot). It flies
## straight from the muzzle at `speed`, swept each physics step by three parallel rays
## (its centre line and its top and bottom edge, HALF_THICK apart) against the world
## (layer 1) and the hero's hurtbox (layer 4), so it never tunnels: the first thing it
## meets resolves it. The world stops it (a low crate blocks a flat round; a floor or a
## wall stops an aimed one); the hero takes `damage` with half knockback (the fairness
## rules' projectile hit). Enemy hit zones are not in its mask, so a round passes
## through other enemies. It despawns unresolved after `max_range` px.
##
## Look (fairness rules, "Shot colors"): a short tracer-ivory streak with a dark
## outline, about a fifth of a hero height long, and a small light so it lights what it
## passes. Never amber, red, teal, gold, violet or green.
## Batch 7: the painted slug with its short trail (PixelFx "pistol_round", made white-hot on
## import and tinted tracer ivory here) replaces the drawn streak; a blocked round throws the
## painted pistol impact (sparks and chips fanning back toward the shooter) instead of the
## generic burst. The drawn look stays as the fallback.

signal resolved(outcome: StringName, at: Vector2)

const Lights := preload("res://scripts/actors/lit/lights.gd")
const OUTLINE := Color("#0B0D10")
const TRACER := Color("#F2EBD3")
const CORE := Color("#FFFDF4")
const BLOCK_COLOR := Color("#C9D3DC")
## Half the round's height (px): the sweep's top and bottom rays sit this far off its
## centre line, so a jump must lift Dave's feet clear of the whole round.
const HALF_THICK := 2.5
## The streak's length behind the head (0.2 H).
const LENGTH := 19.0
const MASK := 1 | 8   # world | hero_hurtbox
const PixelFx := preload("res://scripts/effects/pixel_fx.gd")

var direction: Vector2 = Vector2.RIGHT
var speed: float = 864.0
var max_range: float = 624.0
var damage: int = 1
var knockback_scale: float = 0.5
## The enemy that fired it (its Gunner), for "one round alive at a time".
var shooter: Node = null
var _traveled: float = 0.0
var _spent: bool = false
var _light: PointLight2D
var _slug: Sprite2D


func _ready() -> void:
	add_to_group("enemy_round")
	_light = PointLight2D.new()
	_light.texture = Lights.soft_disc()
	_light.texture_scale = 0.35
	_light.color = TRACER
	_light.energy = 0.45
	_light.height = 18.0
	_light.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(_light)
	_slug = PixelFx.spawn("pistol_round", Vector2.ZERO, self, {"local": true, "hold": true, "tint": TRACER})


## Places the round at `start`, flying along `dir`.
func setup(start: Vector2, dir: Vector2, p_speed: float, p_range: float, p_damage: int = 1) -> void:
	global_position = start
	direction = dir.normalized() if dir.length() > 0.001 else Vector2.RIGHT
	speed = p_speed
	max_range = p_range
	damage = p_damage
	if _slug != null:
		_slug.rotation = direction.angle()
	rotation = direction.angle()
	reset_physics_interpolation()


func is_spent() -> bool:
	return _spent


func _physics_process(delta: float) -> void:
	if _spent:
		return
	var prev := global_position
	var step := direction * speed * delta
	var hit := _sweep(prev, prev + step)
	if not hit.is_empty():
		_resolve(hit)
		return
	global_position = prev + step
	_traveled += step.length()
	queue_redraw()
	if _traveled >= max_range:
		_spent = true
		resolved.emit(&"expired", global_position)
		queue_free()


## The nearest hit along the step over the round's three rays, or {}.
func _sweep(from: Vector2, to: Vector2) -> Dictionary:
	var space := get_world_2d().direct_space_state
	var normal := Vector2(-direction.y, direction.x)
	var best := {}
	var best_d := INF
	for k in [0.0, -1.0, 1.0]:
		var off: Vector2 = normal * HALF_THICK * k
		var q := PhysicsRayQueryParameters2D.create(from + off, to + off)
		q.collision_mask = MASK
		q.collide_with_areas = true
		q.collide_with_bodies = true
		q.hit_from_inside = true
		var r := space.intersect_ray(q)
		if r.is_empty():
			continue
		var d: float = (r.position - off - from).dot(direction)
		if d < best_d:
			best_d = d
			best = r
			best["centre"] = from + direction * maxf(d, 0.0)
	return best


func _resolve(hit: Dictionary) -> void:
	_spent = true
	var at: Vector2 = hit["centre"]
	global_position = at
	var collider = hit.get("collider")
	var target: Node = null
	if collider is Area2D:
		var area := collider as Area2D
		target = area.owner if area.owner else area.get_parent()
	if target != null and target.has_method("take_damage"):
		target.take_damage(damage, at - direction * 8.0, knockback_scale)
		resolved.emit(&"hit", at)
	else:
		var spark := ImpactSpark.new()
		spark.dir = direction
		spark.color = BLOCK_COLOR
		spark.shape = ImpactSpark.Shape.BLOCKED
		spark.effect = "pistol_impact"
		spark.global_position = at
		if get_parent():
			get_parent().add_child(spark)
		var audio := get_node_or_null("/root/Audio")
		if audio:
			audio.play_sfx(&"bolt_blocked", at)
		resolved.emit(&"blocked", at)
	queue_free()


func _draw() -> void:
	if _spent or _slug != null:
		return
	var tail := -minf(LENGTH, _traveled + 4.0)
	var head := 3.0
	var outline := PackedVector2Array([
		Vector2(head + 1.5, 0.0), Vector2(head - 1.5, HALF_THICK + 0.5), Vector2(tail, 1.4),
		Vector2(tail - 1.0, 0.0), Vector2(tail, -1.4), Vector2(head - 1.5, -HALF_THICK - 0.5),
	])
	var dark := Color(OUTLINE, 0.8)
	var dark_clear := Color(OUTLINE, 0.0)
	draw_polygon(outline, PackedColorArray([dark, dark, dark_clear, dark_clear, dark_clear, dark]))
	var body := PackedVector2Array([
		Vector2(head, 0.0), Vector2(head - 1.5, HALF_THICK - 0.6), Vector2(tail, 0.5),
		Vector2(tail, -0.5), Vector2(head - 1.5, -HALF_THICK + 0.6),
	])
	var clear := Color(TRACER, 0.0)
	draw_polygon(body, PackedColorArray([CORE, TRACER, clear, clear, TRACER]))
	draw_circle(Vector2(head - 1.0, 0.0), 1.7, CORE)
