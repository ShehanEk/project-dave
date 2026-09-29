extends TestCase
## REGRESSION (ENG-01): a HitZone that overlaps the hero's shoulder (e.g. a
## Staffer the hero walked into — no body blocking between them, or one that
## lunged past while the hero was immune) is aimed at directly, horizontally.
## The muzzle-clamp ray must find it and register a hit/blocked outcome
## instead of letting the bolt's own sweep start beyond it.

const BlockScript := preload("res://scripts/world/block.gd")
const HitZoneScript := preload("res://scripts/combat/hit_zone.gd")


func run() -> void:
	for dx in [60.0, 0.0, 8.0, -8.0]:  # 60 = control (not overlapping)
		await _probe(dx)


func _probe(dx: float) -> void:
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(0, 560)
	floor_b.size = Vector2(2000, 200)
	add_child(floor_b)

	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = Vector2(600, 560)
	hero.use_aim_override = true
	await physics_frames(3)

	# Staffer-sized whole-body HitZone (48x84, feet on floor) at hero.x+dx.
	var zone: HitZone = HitZoneScript.new()
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(48, 84)
	cs.shape = rect
	cs.position = Vector2(0, -42)
	zone.add_child(cs)
	add_child(zone)
	zone.global_position = Vector2(600 + dx, 560)
	var hits := [0]
	zone.hit.connect(func(_d, _p, _dir): hits[0] += 1)

	# Aim horizontally right at the zone's centre height.
	hero.aim_override = Vector2(2000, hero.aim_pivot.global_position.y)
	await physics_frames(2)
	press("fire")
	await seconds(1.0)
	release("fire")
	await physics_frames(5)
	check(hits[0] > 0, "overlapping enemy HitZone (dx=%.0f) aimed at horizontally takes a hit (hits=%d)" % [dx, hits[0]])

	hero.queue_free()
	zone.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
