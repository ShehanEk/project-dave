extends Sprite2D
## One spent Boom Broom shell (M3): "a single oversized shell ejects and bounces"
## (w02-boom-broom.md). A copy of the gun rig's `shell` part (same atlas, same lit
## material, so lamps light it like the gun), thrown from the ejection port up and back,
## spinning; it falls, bounces once or twice on the floor below (found by one ray when it
## is thrown), lies there a moment and fades out. Cosmetic only: no collision, no pickup.
## Lives in the current scene, so a level rebuild clears it. No class_name.
## Batch 7: with the painted casing strip (PixelFx "shell_casing": two tumbling views and the
## shell on its side) the casing shows those frames instead of the rig's part, at the part's
## length, turning through them as it spins and lying on its side once at rest (smooth, unlit).

const GRAVITY := 1100.0
const RESTITUTION := 0.35
const FRICTION := 0.55
const REST_TIME := 1.2
const FADE_TIME := 0.4
## How far below the port it looks for a floor; with none it falls this far and goes.
const FLOOR_PROBE := 420.0
const PixelFx := preload("res://scripts/effects/pixel_fx.gd")

var velocity := Vector2.ZERO
var spin := 0.0
var drop_cue: StringName = &""
var bounces := 0
var _floor_y := INF
var _fall_limit := INF
var _resting := 0.0
var _played := false
## The painted strip's frames (empty: the rig part).
var _frames: Array = []
var _cell := Vector2.ZERO


static func throw(host: Node, rig: Node2D, at: Vector2, vel: Vector2, spin_rate: float, cue: StringName) -> Sprite2D:
	if host == null or rig == null or not rig.sprites.has("shell"):
		return null
	var src: Sprite2D = rig.sprites["shell"]
	var s: Sprite2D = new()
	s.name = "ShellCasing"
	s.texture = src.texture
	s.region_enabled = true
	s.region_rect = src.region_rect
	s.centered = false
	s.offset = src.offset
	s.material = src.material
	s.light_mask = src.light_mask
	s.texture_filter = src.texture_filter
	var gs: Vector2 = src.global_transform.get_scale().abs()
	s.scale = gs
	var hd: Array = PixelFx.hd_strip("shell_casing") if PixelFx.has_fx("shell_casing") else [null, 1.0]
	if hd[0] != null:
		# The painted casing at the rig shell's own length.
		var meta: Dictionary = PixelFx.meta_for("shell_casing")
		var c: Array = meta["cell"]
		s._cell = Vector2(float(c[0]), float(c[1]))
		s._frames = range(int(meta["frames"]))
		s.texture = hd[0]
		s.material = null
		s.light_mask = 0
		s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		s.centered = true
		s.offset = Vector2.ZERO
		var length: float = maxf(src.region_rect.size.x, src.region_rect.size.y) * maxf(gs.x, gs.y)
		var k: float = length / (s._cell.x * 0.8)
		s.scale = Vector2(k, k)
		s._show_frame(0)
	s.z_index = 12
	s.velocity = vel
	s.spin = spin_rate
	s.drop_cue = cue
	host.add_child(s)
	s.global_position = at
	s.reset_physics_interpolation()
	s._find_floor()
	return s


func _show_frame(i: int) -> void:
	region_rect = Rect2(Vector2(float(_frames[i]) * _cell.x, 0.0), _cell)


func _find_floor() -> void:
	_fall_limit = global_position.y + FLOOR_PROBE
	var space := get_world_2d().direct_space_state if is_inside_tree() else null
	if space == null:
		return
	var q := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0.0, FLOOR_PROBE), 1)
	var hit := space.intersect_ray(q)
	if not hit.is_empty():
		_floor_y = (hit["position"] as Vector2).y - 2.0


func _physics_process(delta: float) -> void:
	if _resting > 0.0 or (bounces >= 2 and absf(velocity.y) < 40.0 and global_position.y >= _floor_y - 0.5):
		_resting += delta
		var a := clampf(1.0 - (_resting - REST_TIME) / FADE_TIME, 0.0, 1.0)
		modulate.a = a
		if a <= 0.0:
			queue_free()
		return
	velocity.y += GRAVITY * delta
	position += velocity * delta
	rotation += spin * delta
	if not _frames.is_empty():
		# Tumbling: the views turn with the spin.
		_show_frame(int(absf(rotation) / (PI / 3.0)) % 2)
	if global_position.y >= _floor_y:
		global_position.y = _floor_y
		if not _played and drop_cue != &"":
			_played = true
			var audio := get_node_or_null("/root/Audio")
			if audio:
				audio.play_sfx(drop_cue, global_position)
		bounces += 1
		velocity = Vector2(velocity.x * FRICTION, -absf(velocity.y) * RESTITUTION)
		spin *= 0.5
		if bounces >= 2 or absf(velocity.y) < 40.0:
			velocity = Vector2.ZERO
			rotation = snappedf(rotation, PI)
			_resting = 0.001
			if not _frames.is_empty():
				_show_frame(_frames.size() - 1)   # on its side
				rotation = 0.0
	elif global_position.y > _fall_limit:
		queue_free()
