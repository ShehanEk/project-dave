class_name ScrapBolt
extends Node2D
## Finite, visible W01 shot. Swept each physics step with a raycast
## (prev -> next) against world + hittable (mask 17 = layer1|layer5) so it
## never tunnels through a thin wall at high speed. Exactly one valid
## resolution (hit or blocked) then despawn; despawns unresolved at max
## range. Mask excludes hero/pickups/interactables by construction.
##
## Look (C37): a kinetic tracer slug, a short tracer-ivory streak with a
## dark outline, a bright head and a trail that fades behind it, carrying a
## small light so it lights what it passes. Never amber, gold or green (those
## are tells and pickups). HIT and BLOCKED get distinct ImpactSpark shapes
## (see that script), never color alone.

const Lights := preload("res://scripts/actors/lit/lights.gd")
const OUTLINE := Color("#0B0D10")
const TRACER := Color("#F2EBD3")        # tracer ivory (style guide)
const CORE := Color("#FFFDF4")
## The streak's length behind the head once it is clear of the muzzle, px.
const TRAIL := 30.0
const HIT_COLOR := Color("#FFF6E2")     # a hit: white-hot sparks
const BLOCK_COLOR := Color("#C9D3DC")   # blocked: cool steel sparks

var tuning: WeaponTuning
var direction: Vector2 = Vector2.RIGHT
var _traveled: float = 0.0
var _spent: bool = false
var _light: PointLight2D


func _ready() -> void:
	_light = PointLight2D.new()
	_light.texture = Lights.soft_disc()
	_light.texture_scale = 0.4
	_light.color = TRACER
	_light.energy = 0.5
	_light.height = 18.0
	_light.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(_light)


func setup(start: Vector2, dir: Vector2, weapon_tuning: WeaponTuning) -> void:
	global_position = start
	direction = dir.normalized() if dir.length() > 0.001 else Vector2.RIGHT
	tuning = weapon_tuning
	rotation = direction.angle()
	# Spawned at the world origin then moved here: without this reset,
	# physics interpolation draws its first frame partway from the origin.
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	if _spent or tuning == null:
		return
	var prev := global_position
	var step := direction * tuning.bolt_speed * delta
	var next := prev + step

	var space_state := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(prev, next)
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = 17  # layer1 world (1) | layer5 hittable (16)
	# A very close-range shot's swept segment can start already inside the
	# target's shape (e.g. muzzle length > remaining distance); without this
	# a ray whose origin is inside a shape reports no hit at all.
	params.hit_from_inside = true
	var result := space_state.intersect_ray(params)

	if not result.is_empty():
		var collider = result.get("collider")
		if collider is HitZone:
			var outcome: StringName = collider.take_hit(tuning.damage, result.position, direction)
			_resolve(outcome, result.position, outcome == &"hit" and collider.bleeds)
		else:
			_resolve(&"blocked", result.position)
		return

	global_position = next
	_traveled += step.length()
	queue_redraw()
	if _traveled >= tuning.max_range:
		queue_free()


func _resolve(outcome: StringName, at: Vector2, bled: bool = false) -> void:
	_spent = true
	global_position = at
	if outcome == &"hit":
		GameFeel.hit_pause()
	var audio := get_node_or_null("/root/Audio")
	if bled:
		# The target shows its own blood (and plays its own hit sound).
		queue_free()
		return
	var spark := ImpactSpark.new()
	spark.dir = direction
	var is_hit: bool = outcome == &"hit"
	spark.color = HIT_COLOR if is_hit else BLOCK_COLOR
	spark.shape = ImpactSpark.Shape.HIT if is_hit else ImpactSpark.Shape.BLOCKED
	spark.global_position = at
	get_parent().add_child(spark)
	if audio:
		audio.play_sfx(&"bolt_hit" if is_hit else &"bolt_blocked", at)
	queue_free()


func _draw() -> void:
	if _spent:
		return
	# The streak grows out of the muzzle (never back over the gun), then
	# keeps its length.
	var tail := -minf(TRAIL, _traveled)
	var head := 5.0
	var outline := PackedVector2Array([
		Vector2(head + 1.5, 0.0), Vector2(head - 2.0, 2.8), Vector2(tail, 1.2),
		Vector2(tail - 1.0, 0.0), Vector2(tail, -1.2), Vector2(head - 2.0, -2.8),
	])
	var dark := Color(OUTLINE, 0.75)
	var dark_clear := Color(OUTLINE, 0.0)
	draw_polygon(outline, PackedColorArray([dark, dark, dark_clear, dark_clear, dark_clear, dark]))
	var body := PackedVector2Array([
		Vector2(head, 0.0), Vector2(head - 2.0, 1.7), Vector2(tail, 0.4),
		Vector2(tail, -0.4), Vector2(head - 2.0, -1.7),
	])
	var clear := Color(TRACER, 0.0)
	draw_polygon(body, PackedColorArray([CORE, TRACER, clear, clear, TRACER]))
	draw_circle(Vector2(head - 1.5, 0.0), 1.6, CORE)
