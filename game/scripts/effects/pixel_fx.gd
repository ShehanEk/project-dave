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
## The hand-painted strips (batch 3, tools/art/import_hd_ui.py): per effect `k` texels per art px,
## its frame `cell` in texels and its frame count. Drawn smooth in place of the pixel strip, at the
## same size and anchor (the pixel effects.json still gives both).
const HD_DIR := "res://assets/effects/hd/"
static var hd_enabled := true

## Batch 7 (Level 2, tools/art/import_hd_ui.py --batch7): painted-only effects with no pixel
## strip; their HD effects.json entry also carries `frame_size` and `anchor` in art px. The Sidearm
## Guard's pistol (pistol_flash, pistol_round, pistol_impact), the Boom Broom's (shotgun_blast,
## shotgun_pellets, shell_casing), the drone's shock fork (shock_arc) and the Hound's lunge
## (lunge_dust). `opts.hold` keeps a one-frame effect up (no timer: the round's slug).
##
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
	"pistol_flash": {"frame_time": 0.026, "add": true, "px": 1.5, "z": 20, "alpha": 1.0, "reduced": [0, 1]},
	"pistol_round": {"frame_time": 1.0, "add": false, "px": 1.5, "z": 3, "alpha": 1.0, "reduced": [0]},
	"pistol_impact": {"frame_time": 0.05, "add": true, "px": 1.5, "z": 20, "alpha": 1.0, "reduced": [0, 1, 3]},
	"shotgun_blast": {"frame_time": 0.03, "add": true, "px": 1.5, "z": 20, "alpha": 1.0, "reduced": [0, 1]},
	"shotgun_pellets": {"frame_time": 0.07, "add": true, "px": 1.5, "z": 20, "alpha": 0.9, "reduced": [0]},
	"shell_casing": {"frame_time": 0.06, "add": false, "px": 1.5, "z": 12, "alpha": 1.0, "reduced": [0, 2]},
	"shock_arc": {"frame_time": 0.05, "add": true, "px": 1.5, "z": 12, "alpha": 1.0, "reduced": [0, 2]},
	"lunge_dust": {"frame_time": 0.07, "add": false, "px": 1.5, "z": 0, "alpha": 0.85, "reduced": [0, 1, 3]},
}
## Additive effects are dimmed by this under reduced motion.
const REDUCED_GLOW := 0.6

static var _meta: Dictionary = {}
static var _meta_loaded := false
static var _textures := {}
static var _hd_meta: Dictionary = {}
static var _hd_loaded := false
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
var _k := 1.0                  # strip texels per art px (1 for the pixel strip)
var _cell := Vector2i.ZERO     # one frame's size in strip texels


static func _load_meta() -> Dictionary:
	if not _meta_loaded:
		_meta_loaded = true
		var f := FileAccess.open(DIR + "effects.json", FileAccess.READ)
		if f != null:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				_meta = parsed
	return _meta


static func _load_hd() -> Dictionary:
	if not _hd_loaded:
		_hd_loaded = true
		var f := FileAccess.open(HD_DIR + "effects.json", FileAccess.READ)
		if f != null:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				_hd_meta = parsed
	return _hd_meta


## The painted strip and its texels per art px, or [null, 1.0] when there is none (or it does not
## have the pixel strip's frame count).
static func hd_strip(fx_name: String) -> Array:
	if not hd_enabled:
		return [null, 1.0]
	var m: Dictionary = _load_hd().get(fx_name, {})
	var path: String = HD_DIR + fx_name + ".png"
	if m.is_empty() or int(m.get("frames", 0)) != frame_count(fx_name) or not ResourceLoader.exists(path):
		return [null, 1.0]
	var key := "hd:" + fx_name
	if not _textures.has(key):
		_textures[key] = load(path)
	return [_textures[key], float(m["k"])]


## The effect's frame data (frames, frame_size, anchor in art px): the pixel strip's, or for a
## painted-only effect its HD entry.
static func meta_for(fx_name: String) -> Dictionary:
	var m: Dictionary = _load_meta().get(fx_name, {})
	if not m.is_empty():
		return m
	var hd: Dictionary = _load_hd().get(fx_name, {})
	return hd if hd_enabled and hd.has("frame_size") else {}


## True for a painted-only effect (no pixel strip).
static func hd_only(fx_name: String) -> bool:
	return not _load_meta().has(fx_name) and _load_hd().get(fx_name, {}).has("frame_size")


static func strip_texture(fx_name: String) -> Texture2D:
	if not _textures.has(fx_name):
		var path: String = DIR + fx_name + ".png"
		_textures[fx_name] = load(path) if ResourceLoader.exists(path) else null
	return _textures[fx_name]


## True when the effect's strip, its frame data and its settings all exist; the
## caller keeps its smooth effect when this is false.
static func has_fx(fx_name: String) -> bool:
	if not FX.has(fx_name):
		return false
	if _load_meta().has(fx_name):
		return strip_texture(fx_name) != null
	return not meta_for(fx_name).is_empty() and hd_strip(fx_name)[0] != null


static func frame_count(fx_name: String) -> int:
	return int(meta_for(fx_name).get("frames", 0))


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
	var meta: Dictionary = meta_for(fx_name)
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
	_k = 1.0
	_cell = _size
	var hd: Array = hd_strip(fx_name)
	if hd[0] != null:
		texture = hd[0]
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_k = hd[1]
		var c: Array = _load_hd()[fx_name]["cell"]
		_cell = Vector2i(int(c[0]), int(c[1]))
	centered = false
	region_enabled = true
	flip_h = opts.get("flip", false)
	z_index = cfg["z"]
	var px: float = float(cfg["px"]) * float(opts.get("scale_mul", 1.0)) / _k
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
	set_process(not opts.get("hold", false))
	if opts.has("rotation"):
		rotation = float(opts["rotation"])


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
	region_rect = Rect2(_frames[i] * _cell.x + _crop.position.x * _k, _crop.position.y * _k,
			_crop.size.x * _k, _crop.size.y * _k)
	# The anchor sits on the node's origin; a mirrored frame is mirrored about it.
	var left: float = float(_crop.position.x - _anchor.x) * _k
	var top: float = float(_crop.position.y - _anchor.y) * _k
	offset = Vector2(-(left + _crop.size.x * _k) if flip_h else left, top)


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
