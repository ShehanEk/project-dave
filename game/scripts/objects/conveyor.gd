extends StaticBody2D
## Level 2's hazard H3, the conveyor (level-design/l02-alignment.md; A06's loading entry): a
## floor section that carries whoever stands on it along at `speed` px/s in `direction`.
##
## CONTRACT, like Block (scripts/world/block.gd): `position` is the TOP-LEFT corner, `size` the
## extent in px, the top surface (the belt) sits at the node's y, solid on the world layer (1).
## The belt is `BELT_HEIGHT` thick at the top; the rest is the machine under it.
##
## THE CARRY is Godot's own platform velocity: a StaticBody2D reports its
## `constant_linear_velocity` as the velocity of the surface, and a CharacterBody2D that stands
## on it with move_and_slide() is moved by it each tick (Hero, whose motion_mode is GROUNDED).
## Nothing here moves a body or touches hero.gd. Hero sets `platform_on_leave =
## PLATFORM_ON_LEAVE_DO_NOTHING`, so the moment he leaves the belt (a jump, a step off the end)
## the belt's velocity is simply dropped, never added to his own: a jump goes straight up, a walk
## off the end drops straight down, with no launch (design-guide: moving surfaces carry the
## hero's position without an unexpected launch impulse). While on the belt his own velocity is
## unchanged (`hero.velocity.x` is his running only; the carry is extra), so his ground speed
## is `run_speed + direction * speed` with the belt and `run_speed - speed` against it: against
## it he still makes progress as long as `speed < run_speed` (384 px/s). Keep `speed` at 192
## px/s (half a run) or less; the default is 120.
##
## `direction` (+1 right, -1 left, the belt's travel) and `running` can change at runtime
## (`set_direction()`, `set_running()`): Adam's lockdown reroutes conveyors, with a warning the
## level supplies (the design guide's "preview" rule). A change is instant and never launches.
##
## LOOK (stand-in until Batch 8; `piece` names a painted lab piece tiled along the belt when its
## art exists): a dark rubber belt with slat lines and rust-orange chevrons pointing the way it
## runs, sliding over a steel housing with rollers at both ends; optionally `cargo` decorative
## crates ride along behind Dave (drawn on the layer behind the actors, no collision: they are
## breakables in the real level, which the level adds as separate objects). The top edge keeps the
## cold white lit edge every walkable surface has. Reduced motion: the belt, chevrons and crates
## hold still (the chevrons still point the way); the carry itself is physics and always happens.
##
## No `class_name`; reach it by path or scene (scenes/objects/conveyor.tscn).

const BELT_HEIGHT := 18.0
const OUTLINE := Color("#05070B")
const HOUSING := Color("#1B2736")
const HOUSING_LIGHT := Color("#2C3D54")
const RUBBER := Color("#0F151E")
const SLAT := Color("#1E2A3A")
const CHEVRON := Color("#C0652C")   # matte rust-orange safety paint: warm, not a glowing tell
const TOP_EDGE := Color("#D8E6F0")
const TOP_BEVEL := Color("#5A718C")
const CRATE := Color("#6B4A32")
const CRATE_DARK := Color("#3E2B1E")
const SLAT_GAP := 28.0
const CHEVRON_GAP := 84.0
const CRATE_SIZE := Vector2(46.0, 34.0)

const LabSkins := preload("res://scripts/world/lab_skins.gd")

@export var size: Vector2 = Vector2(384.0, 40.0):
	set(v):
		size = v
		_rebuild()
## The belt's speed in px/s (magnitude). Stay at or under 192 (half the run speed).
@export var speed: float = 120.0:
	set(v):
		speed = v
		_apply_velocity()
## +1 the belt carries right, -1 left.
@export_enum("Left:-1", "Right:1") var direction: int = 1:
	set(v):
		direction = 1 if v >= 0 else -1
		_apply_velocity()
		queue_redraw()
## false: the belt is stopped (and carries nothing).
@export var running: bool = true:
	set(v):
		running = v
		_apply_velocity()
## Decorative crates riding the belt (drawn, not physical).
@export var cargo: int = 0:
	set(v):
		cargo = maxi(v, 0)
		queue_redraw()
## A painted lab piece (Batch 8) tiled along the belt; "" or a missing piece = the stand-in.
@export var piece: String = ""

var _shape_node: CollisionShape2D = null
var _scroll: float = 0.0       ## how far the belt has slid (px), visual only
var _cargo_layer: Node2D = null


func _ready() -> void:
	collision_layer = 1  # world
	collision_mask = 0
	_rebuild()
	_apply_velocity()
	# The crates ride on a layer behind the actors (z -1): they must not hide Dave's feet.
	_cargo_layer = Node2D.new()
	_cargo_layer.name = "Cargo"
	_cargo_layer.z_index = -1
	add_child(_cargo_layer)
	_cargo_layer.draw.connect(_draw_cargo)
	set_process(true)


func _rebuild() -> void:
	if not is_inside_tree():
		return
	if _shape_node == null:
		_shape_node = CollisionShape2D.new()
		_shape_node.name = "Shape"
		add_child(_shape_node)  # generated, not saved
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape_node.shape = rect
	_shape_node.position = size * 0.5
	queue_redraw()


## The surface velocity now: what a body standing on the belt is carried at.
func belt_velocity() -> Vector2:
	return Vector2(float(direction) * speed, 0.0) if running else Vector2.ZERO


func _apply_velocity() -> void:
	constant_linear_velocity = belt_velocity()


func set_direction(d: int) -> void:
	direction = d


func set_running(on: bool) -> void:
	running = on


func get_rect_global() -> Rect2:
	return Rect2(global_position, size)


func _reduced() -> bool:
	var settings := get_node_or_null("/root/Settings")
	return settings != null and settings.get_reduced_motion()


func _process(delta: float) -> void:
	if not _reduced():
		_scroll += belt_velocity().x * delta
	queue_redraw()
	if _cargo_layer:
		_cargo_layer.queue_redraw()


# --- drawing ---------------------------------------------------------------------

func _draw() -> void:
	var w := size.x
	var h := size.y
	var belt_h := minf(BELT_HEIGHT, h)
	# The housing under the belt.
	draw_rect(Rect2(0.0, belt_h, w, maxf(h - belt_h, 0.0)), HOUSING)
	draw_rect(Rect2(0.0, belt_h, w, 2.0), HOUSING_LIGHT)
	# rollers along the housing, rotating with the belt's travel
	var roller_y := belt_h + (h - belt_h) * 0.5
	var roller_r := minf((h - belt_h) * 0.32, 9.0)
	if roller_r > 2.0:
		var n := maxi(int(w / 48.0), 2)
		for i in n:
			var cx := w * (float(i) + 0.5) / float(n)
			draw_circle(Vector2(cx, roller_y), roller_r, OUTLINE)
			draw_circle(Vector2(cx, roller_y), roller_r - 1.5, HOUSING_LIGHT)
			var a := _scroll / roller_r
			draw_line(Vector2(cx, roller_y), Vector2(cx, roller_y) + Vector2(cos(a), sin(a)) * (roller_r - 2.0), OUTLINE, 1.5)
	# The belt: rubber, slat lines and chevrons sliding with it.
	draw_rect(Rect2(0.0, 0.0, w, belt_h), RUBBER)
	if piece != "" and LabSkins.has(piece):
		_draw_piece(w, belt_h)
	else:
		var x := fposmod(_scroll, SLAT_GAP)
		while x < w:
			draw_line(Vector2(x, 2.0), Vector2(x, belt_h - 1.0), SLAT, 1.5)
			x += SLAT_GAP
		var cx := fposmod(_scroll, CHEVRON_GAP) - CHEVRON_GAP
		var d := float(direction)
		var mid := belt_h * 0.5 + 1.0
		var half_h := belt_h * 0.36
		while cx < w + CHEVRON_GAP:
			var p := cx + CHEVRON_GAP * 0.5
			if p > 8.0 and p < w - 8.0:
				var tip := Vector2(p + 8.0 * d, mid)
				draw_polyline(PackedVector2Array([Vector2(p - 6.0 * d, mid - half_h), tip, Vector2(p - 6.0 * d, mid + half_h)]), CHEVRON, 3.5, true)
			cx += CHEVRON_GAP
	# the end drums, over the belt's ends
	for ex in [0.0, w]:
		draw_circle(Vector2(ex, belt_h * 0.5), belt_h * 0.5 + 1.0, OUTLINE)
		draw_circle(Vector2(ex, belt_h * 0.5), belt_h * 0.5 - 1.0, HOUSING_LIGHT)
	draw_rect(Rect2(0.0, 0.0, w, h), OUTLINE, false, 2.0)
	# the walkable edge goes on last (the cold white lit edge every standing surface carries)
	draw_rect(Rect2(2.0, 2.0, w - 4.0, 2.0), TOP_BEVEL)
	draw_rect(Rect2(2.0, 0.0, w - 4.0, 2.0), TOP_EDGE)


## A painted piece tiled along the belt at its own scale (Batch 8 will fix its layout).
func _draw_piece(w: float, belt_h: float) -> void:
	var piece_w := LabSkins.world_size(piece).x
	if piece_w < 8.0:
		return
	var x := fposmod(_scroll, piece_w) - piece_w
	while x < w:
		if x >= 0.0 and x + piece_w <= w:
			LabSkins.draw(self, piece, 0.0, LabSkins.DIM, false, x + piece_w * 0.5, 1.0)
		x += piece_w


func _draw_cargo() -> void:
	if cargo <= 0:
		return
	var w := size.x
	var gap := (w + CRATE_SIZE.x) / float(cargo)
	var base := 0.0 if _reduced() else _scroll
	for i in cargo:
		var x := fposmod(base + float(i) * gap + gap * 0.5, w + CRATE_SIZE.x) - CRATE_SIZE.x
		# fade in and out at the ends, where the crates come from and go to
		var fade := clampf(minf(x + CRATE_SIZE.x, w - x) / 24.0, 0.0, 1.0)
		if fade <= 0.0:
			continue
		var r := Rect2(Vector2(x, -CRATE_SIZE.y + 2.0), CRATE_SIZE * (1.0 if i % 2 == 0 else Vector2(0.8, 1.2)))
		r.position.y = 2.0 - r.size.y
		var tint := Color(1, 1, 1, fade)
		_cargo_layer.draw_rect(r, CRATE * tint)
		_cargo_layer.draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 3.0), CRATE_DARK * tint)
		_cargo_layer.draw_rect(Rect2(r.position.x + r.size.x * 0.5 - 2.0, r.position.y, 4.0, r.size.y), CRATE_DARK * tint)
		_cargo_layer.draw_rect(r, OUTLINE * tint, false, 2.0)
