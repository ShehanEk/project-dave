extends Sprite2D
## A one-shot pixel-art effect (Sheet 9): the user's generated animation
## strips (concept-art/env-sunnyvale/sunnyvale-effects-v1.webp, cut and reduced
## to a true pixel grid by tools/art/import_pixel_effects.py into
## assets/effects/pixel/<effect>.png, one horizontal strip per effect, and
## effects.json with the frame counts, sizes and anchors).
##
## `PixelFx.spawn()` adds one of these under a host, plays the strip once with
## nearest filtering and frees itself at the last frame. Six effects:
## muzzle_flash, bullet_impact, landing_dust, machine_break, checkpoint_sparkle
## and chip_glint. Bright ones (flash, impact, sparkle, glint) draw additive,
## dust and the machine's smoke with plain alpha. An effect is drawn with its
## anchor on the spawn point (the muzzle's left edge, the floor under the dust,
## the centre of a burst), `px` world px per art px (the characters' and props'
## 1.5, or 2 x that like the objects and pickups).
##
## Cosmetic only: nothing reads it back. Honors `Settings.reduced_motion` the
## way the effects it replaces did (fewer frames: a shorter, calmer play, and
## the additive ones dimmer), never a missing cue. `has_fx()` is false when a
## strip is missing, which keeps the old smooth effect as the fallback.
##
## No `class_name` (M6 art-pass import-cache rule): callers preload it by path.

const DIR := "res://assets/effects/pixel/"

## Per effect: seconds per frame, additive blend, world px per art px, z index
## (combat effects above the actors' rigs, which reach z 11; the rest where the
## smooth ones were), alpha, and the frames kept under reduced motion.
const FX := {
	"muzzle_flash": {"frame_time": 0.022, "add": true, "px": 1.5, "z": 20, "alpha": 1.0, "reduced": [0, 1]},
	"bullet_impact": {"frame_time": 0.05, "add": true, "px": 3.0, "z": 20, "alpha": 1.0, "reduced": [0, 1, 3]},
	"landing_dust": {"frame_time": 0.06, "add": false, "px": 2.0, "z": 0, "alpha": 0.8, "reduced": [0, 1, 3]},
	"machine_break": {"frame_time": 0.07, "add": false, "px": 3.0, "z": 20, "alpha": 1.0, "reduced": [0, 2, 3, 5]},
	"checkpoint_sparkle": {"frame_time": 0.09, "add": true, "px": 3.0, "z": 0, "alpha": 1.0, "reduced": [0, 2, 4]},
	"chip_glint": {"frame_time": 0.07, "add": true, "px": 3.0, "z": 0, "alpha": 1.0, "reduced": [0, 1, 3]},
}
## Additive effects are dimmed by this under reduced motion.
const REDUCED_GLOW := 0.6

static var _meta: Dictionary = {}
static var _meta_loaded := false
static var _textures := {}
static var _additive: CanvasItemMaterial

var effect: String = ""
var _frames: Array = []        # frame indices in the strip, in play order
var _frame_time: float = 0.05
var _delay: float = 0.0
var _t: float = 0.0
var _shown: int = -1
var _size := Vector2i.ZERO     # frame size in art px
var _anchor := Vector2i.ZERO
var _crop := Rect2i()          # the part of the frame drawn (the whole frame by default)
var _reduced_motion := false


static func _load_meta() -> Dictionary:
	if not _meta_loaded:
		_meta_loaded = true
		var f := FileAccess.open(DIR + "effects.json", FileAccess.READ)
		if f != null:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				_meta = parsed
	return _meta


static func strip_texture(fx_name: String) -> Texture2D:
	if not _textures.has(fx_name):
		var path: String = DIR + fx_name + ".png"
		_textures[fx_name] = load(path) if ResourceLoader.exists(path) else null
	return _textures[fx_name]


## True when the effect's strip, its frame data and its settings all exist; the
## caller keeps its smooth effect when this is false.
static func has_fx(fx_name: String) -> bool:
	return FX.has(fx_name) and _load_meta().has(fx_name) and strip_texture(fx_name) != null


static func frame_count(fx_name: String) -> int:
	return int(_load_meta().get(fx_name, {}).get("frames", 0))


static func _is_reduced() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var settings: Node = tree.root.get_node_or_null("/root/Settings") if tree else null
	return settings != null and settings.get_reduced_motion()


## The frames an effect plays: `want` (all of them when empty), cut down to the
## reduced-motion set when `reduced`.
static func frames_for(fx_name: String, want: Array = [], reduced: bool = false) -> Array:
	var all: Array = want.duplicate() if not want.is_empty() else range(frame_count(fx_name))
	if not reduced:
		return all
	var keep: Array = all.filter(func(i): return FX[fx_name]["reduced"].has(i))
	return keep if not keep.is_empty() else [all[0]] if not all.is_empty() else []


## How long a play lasts, seconds (its delay not counted).
static func duration(fx_name: String, want: Array = [], reduced: bool = false) -> float:
	if not FX.has(fx_name):
		return 0.0
	return frames_for(fx_name, want, reduced).size() * float(FX[fx_name]["frame_time"])


## Plays `effect` once under `host`, anchored at `at` (a global position, or the
## host's own space with `local`), and returns the node, or null when the strip
## is missing (the caller then draws its smooth effect). `opts`:
##   frames: Array   which frames to play, in order (default all)
##   delay: float    seconds before the first frame shows
##   tint: Color     multiplies the strip's colours
##   local: bool     `at` is in the host's space; the effect then inherits the
##                   host's rotation and flips (a gun's muzzle turns with the
##                   aim) and its size is held at `px` world px per art px
##   scale_mul: float  a multiple of the effect's own pixel size
##   half: Vector2i  draw only the half of the frame on that side of the anchor
##                   (a glancing hit sends sparks back one way)
##   flip: bool      mirror it sideways
static func spawn(effect_name: String, at: Vector2, host: Node, opts: Dictionary = {}) -> Sprite2D:
	if host == null or not is_instance_valid(host) or not has_fx(effect_name):
		return null
	var fx: Sprite2D = new()
	fx._setup(effect_name, opts)
	host.add_child(fx)
	if opts.get("local", false):
		fx.position = at
		var parent := host as Node2D
		if parent != null:
			var gs: Vector2 = parent.global_transform.get_scale().abs()
			fx.scale = Vector2(fx.scale.x / maxf(gs.x, 0.001), fx.scale.y / maxf(gs.y, 0.001))
	else:
		fx.global_position = at
	# Physics interpolation would otherwise draw the first frame partway from
	# the origin, where it entered the tree.
	fx.reset_physics_interpolation()
	return fx


func _setup(fx_name: String, opts: Dictionary) -> void:
	effect = fx_name
	var cfg: Dictionary = FX[fx_name]
	var meta: Dictionary = _load_meta()[fx_name]
	_reduced_motion = _is_reduced()
	_frames = frames_for(fx_name, opts.get("frames", []), _reduced_motion)
	_frame_time = cfg["frame_time"]
	_delay = opts.get("delay", 0.0)
	var fs: Array = meta["frame_size"]
	var an: Array = meta["anchor"]
	_size = Vector2i(int(fs[0]), int(fs[1]))
	_anchor = Vector2i(int(an[0]), int(an[1]))
	_crop = Rect2i(Vector2i.ZERO, _size)
	var half: Vector2i = opts.get("half", Vector2i.ZERO)
	if half.x < 0:
		_crop = Rect2i(0, 0, _anchor.x, _size.y)
	elif half.x > 0:
		_crop = Rect2i(_anchor.x, 0, _size.x - _anchor.x, _size.y)
	elif half.y < 0:
		_crop = Rect2i(0, 0, _size.x, _anchor.y)
	elif half.y > 0:
		_crop = Rect2i(0, _anchor.y, _size.x, _size.y - _anchor.y)
	texture = strip_texture(fx_name)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	centered = false
	region_enabled = true
	flip_h = opts.get("flip", false)
	z_index = cfg["z"]
	var px: float = float(cfg["px"]) * float(opts.get("scale_mul", 1.0))
	scale = Vector2(px, px)
	var glow: float = REDUCED_GLOW if (_reduced_motion and cfg["add"]) else 1.0
	modulate = Color(opts.get("tint", Color.WHITE))
	modulate.a *= float(cfg["alpha"]) * glow
	if cfg["add"]:
		if _additive == null:
			_additive = CanvasItemMaterial.new()
			_additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = _additive
	visible = _delay <= 0.0
	_show(0)
	set_process(true)


## Which strip frame is showing (-1 before the first).
func current_frame() -> int:
	return _frames[_shown] if _shown >= 0 and _shown < _frames.size() else -1


## Seconds until it frees itself, delay included.
func total_time() -> float:
	return _delay + _frames.size() * _frame_time


func _show(i: int) -> void:
	if _frames.is_empty():
		return
	_shown = i
	region_rect = Rect2(_frames[i] * _size.x + _crop.position.x, _crop.position.y, _crop.size.x, _crop.size.y)
	# The anchor sits on the node's origin; a mirrored frame is mirrored about it.
	var left: float = float(_crop.position.x - _anchor.x)
	var top: float = float(_crop.position.y - _anchor.y)
	offset = Vector2(-(left + _crop.size.x) if flip_h else left, top)


func _process(delta: float) -> void:
	_t += delta
	if _t < _delay:
		return
	visible = true
	var i := int((_t - _delay) / _frame_time)
	if i >= _frames.size():
		queue_free()
		return
	if i != _shown:
		_show(i)
