extends Node2D
## The Boom Broom's blast (M3), drawn: "a short broad fan of chunky stylized scrap
## particles, with a brief compressed-air ring" (w02-boom-broom.md). One node per blast,
## in world space: each pellet is a chunky scrap fleck that flies from the muzzle to where
## its ray ended (a hit, a wall, or max range) over `trail_time`, leaving a thin fading
## streak; a ring of pushed air opens at the muzzle. With Incendiary Shells the flecks
## burn ember orange. Purely cosmetic: the damage was dealt by the rays before this was
## made. Frees itself. Reduced Motion keeps every fleck and the ring, shorter and dimmer.
## Batch 7: the painted pellet spray (PixelFx "shotgun_pellets", bright specks fanning from the
## muzzle along the aim) bursts at the muzzle over the flecks' first moment; the flecks still
## carry each pellet to where its ray ended.
## No class_name (preload it by path).

const SCRAP := Color("#F2EBD3")      # the muzzle-flash ivory: hot scrap
const SCRAP_CORE := Color("#FFFDF4")
const EMBER := Color("#FF9436")
const STREAK := Color(1.0, 0.93, 0.8, 0.5)
const RING := Color(0.85, 0.92, 1.0, 0.55)
const FLECK_LENGTH := 9.0
const FLECK_WIDTH := 3.0
const RING_TIME := 0.14
const RING_FROM := 4.0
const RING_TO := 26.0
const PixelFx := preload("res://scripts/effects/pixel_fx.gd")

var muzzle := Vector2.ZERO
var forward := Vector2.RIGHT
## [[from: Vector2, to: Vector2, stopped: bool], ...]
var pellets: Array = []
var trail_time: float = 0.09
var incendiary := false
var _t := 0.0
var _life := 0.3
var _dim := 1.0


static func spawn(host: Node, at_muzzle: Vector2, aim: Vector2, pellet_paths: Array, time: float,
		burning: bool) -> Node2D:
	if host == null or not is_instance_valid(host):
		return null
	var b: Node2D = new()
	b.name = "BlastTrails"
	b.muzzle = at_muzzle
	b.forward = aim.normalized() if aim.length() > 0.001 else Vector2.RIGHT
	b.pellets = pellet_paths
	b.trail_time = maxf(time, 0.02)
	b.incendiary = burning
	b.z_index = 20
	host.add_child(b)
	return b


func _ready() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.get_reduced_motion():
		trail_time *= 0.7
		_dim = 0.6
	_life = maxf(trail_time, RING_TIME) + 0.08
	var spray := PixelFx.spawn("shotgun_pellets", to_local(muzzle), self, {"local": true,
			"rotation": forward.angle(), "tint": EMBER.lerp(Color.WHITE, 0.5) if incendiary else Color.WHITE})
	if spray != null:
		_life = maxf(_life, spray.total_time() + 0.02)


func _process(delta: float) -> void:
	_t += delta
	if _t >= _life:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var fleck_col := (EMBER if incendiary else SCRAP)
	for p in pellets:
		var from: Vector2 = p[0]
		var to: Vector2 = p[1]
		var k := clampf(_t / trail_time, 0.0, 1.0)
		var head := from.lerp(to, k)
		var fade := clampf(1.0 - (_t - trail_time) / 0.08, 0.0, 1.0) if _t > trail_time else 1.0
		var dir := (to - from).normalized() if to.distance_to(from) > 0.01 else forward
		# The thin streak behind the fleck.
		var tail := from.lerp(to, maxf(0.0, k - 0.45))
		draw_line(to_local(tail), to_local(head), Color(STREAK, STREAK.a * fade * _dim), 1.5)
		if k < 1.0:
			var a := to_local(head - dir * FLECK_LENGTH * 0.5)
			var b := to_local(head + dir * FLECK_LENGTH * 0.5)
			draw_line(a, b, Color(fleck_col, _dim), FLECK_WIDTH)
			draw_circle(to_local(head), FLECK_WIDTH * 0.45, Color(SCRAP_CORE, _dim))
	# The compressed-air ring, opening and fading at the muzzle.
	if _t < RING_TIME:
		var r := lerpf(RING_FROM, RING_TO, _t / RING_TIME)
		var alpha := (1.0 - _t / RING_TIME) * RING.a * _dim
		var c := to_local(muzzle + forward * r * 0.4)
		draw_set_transform(c, forward.angle(), Vector2(0.55, 1.0))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 28, Color(RING, alpha), 2.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
