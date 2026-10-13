extends Node
## Incendiary Shells (M3, the Boom Broom's stage 2): "burning damage over time on
## affected enemies" (w02-boom-broom.md). `ignite()` adds this to a HitZone that just took
## a blast; it deals `damage` through the zone's own take_hit() (so the enemy bleeds,
## flinches and dies by its usual rules) once every `interval` s, `ticks` times, with a
## small ember burst each time, then frees itself. Another blast while it burns restarts
## the count. A zone that blocks (armor) or stops listening (the enemy died) does not
## burn. No class_name (preload it by path).

const NODE_NAME := "Burning"
const EMBER := Color("#FF9436")

var zone: HitZone = null
var ticks_left: int = 0
var interval: float = 0.8
var damage: int = 1
var ticks_dealt: int = 0
var _t: float = 0.0


static func ignite(hit_zone: HitZone, ticks: int, every: float, amount: int) -> Node:
	if hit_zone == null or not is_instance_valid(hit_zone) or hit_zone.blocks or not hit_zone.monitorable:
		return null
	if ticks <= 0 or amount <= 0:
		return null
	var b: Node = hit_zone.get_node_or_null(NODE_NAME)
	if b == null:
		b = new()
		b.name = NODE_NAME
		hit_zone.add_child(b)
	b.zone = hit_zone
	b.ticks_left = ticks
	b.interval = maxf(every, 0.05)
	b.damage = amount
	b._t = 0.0
	return b


func _physics_process(delta: float) -> void:
	if zone == null or not is_instance_valid(zone) or not zone.monitorable or ticks_left <= 0:
		queue_free()
		return
	_t += delta
	if _t < interval:
		return
	_t -= interval
	ticks_left -= 1
	ticks_dealt += 1
	var at := _centre()
	_ember(at)
	zone.take_hit(damage, at, Vector2.UP)
	if ticks_left <= 0:
		queue_free()


## The middle of the zone's first shape (a HitZone's own origin can sit at the feet).
func _centre() -> Vector2:
	for c in zone.get_children():
		if c is CollisionShape2D:
			return (c as CollisionShape2D).global_position
	return zone.global_position


func _ember(at: Vector2) -> void:
	var spark := ImpactSpark.new()
	spark.dir = Vector2.UP
	spark.color = EMBER
	spark.shape = ImpactSpark.Shape.HIT
	spark.life = 0.3
	spark.global_position = at
	var tree := get_tree()
	var host: Node = tree.current_scene if tree.current_scene != null else tree.root
	host.add_child(spark)
