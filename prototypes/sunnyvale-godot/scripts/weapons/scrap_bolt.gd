class_name ScrapBolt
extends Node2D
## Finite, visible W01 shot. Swept each physics step with a raycast
## (prev -> next) against world + hittable (mask 17 = layer1|layer5) so it
## never tunnels through a thin wall at high speed. Exactly one valid
## resolution (hit or blocked) then despawn; despawns unresolved at max
## range. Mask excludes hero/pickups/interactables by construction.
##
## Visuals only (M6, C11 hand-drawn style): warm charcoal contour, amber
## faceted bolt body per w01-scrapjack-pistol.md's palette. HIT and BLOCKED
## get distinct ImpactSpark shapes (see that script), never color alone.

const OUTLINE := Color("#332a20")       # warm charcoal (C11 contour)
const BOLT_FILL := Color("#e8b65a")     # amber indicator, w01 palette
const HIT_COLOR := Color("#8fe07a")
const BLOCK_COLOR := Color("#d9d2c4")

var tuning: WeaponTuning
var direction: Vector2 = Vector2.RIGHT
var _traveled: float = 0.0
var _spent: bool = false


func setup(start: Vector2, dir: Vector2, weapon_tuning: WeaponTuning) -> void:
	global_position = start
	direction = dir.normalized() if dir.length() > 0.001 else Vector2.RIGHT
	tuning = weapon_tuning
	rotation = direction.angle()


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
	if _traveled >= tuning.max_range:
		queue_free()


func _resolve(outcome: StringName, at: Vector2, bled: bool = false) -> void:
	_spent = true
	global_position = at
	var audio := get_node_or_null("/root/Audio")
	if bled:
		# The target shows its own blood (and plays its own hit sound).
		queue_free()
		return
	var spark := ImpactSpark.new()
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
	var len_ := 16.0
	var pts := PackedVector2Array([
		Vector2(len_, 0.0), Vector2(2.0, 5.0), Vector2(-len_ * 0.4, 0.0), Vector2(2.0, -5.0),
	])
	draw_colored_polygon(pts, BOLT_FILL)
	draw_polyline(pts + PackedVector2Array([pts[0]]), OUTLINE, 1.5)
