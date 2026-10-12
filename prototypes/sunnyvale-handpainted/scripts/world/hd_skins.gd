extends RefCounted
## The hand-painted HD environment (C56, tools/art/import_hd_env.py):
## - Swap textures: an HD texture at a pixel piece's exact layout (its size times a scale k)
##   under assets/environment/hd/ in place of the PNG at the same path under .../sunnyvale/
##   (the walkway and wall strips, the far and campus layers). The skins keep slicing in the
##   pixel piece's art px; blit() scales only the source rectangle and draws the HD texture
##   smooth, lit through its normal map when it has one.
## - Props (props/props.json): HD pieces with their own sizes and slices, drawn by PropSkins in
##   place of the pixel prop: `scale` world px per texel, `anchor_x` the column standing on the
##   prop's origin, and per prop the lamp's head/pole/lens rows, the landmark's head and
##   repeating shaft, the railing's bay.
## No class_name (preloaded by path).

const PIXEL_ROOT := "res://assets/environment/sunnyvale/"
const HD_ROOT := "res://assets/environment/hd/"
const PROPS_JSON := HD_ROOT + "props/props.json"

static var enabled: bool = true
static var _swaps := {}
static var _props: Dictionary = {}
static var _props_loaded := false
static var _prop_tex := {}


static func _canvas_texture(path: String) -> CanvasTexture:
	var ct := CanvasTexture.new()
	ct.diffuse_texture = load(path)
	var nrm := path.get_basename() + "_n.png"
	if ResourceLoader.exists(nrm):
		ct.normal_texture = load(nrm)
	ct.specular_color = Color(0.3, 0.32, 0.38)
	ct.specular_shininess = 0.3
	# Mipmapped: the paintings are drawn several times smaller than painted, and without mip levels
	# their fine brushwork aliases into noise.
	ct.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return ct


## [the texture to draw, HD texels per pixel-piece texel] for a pixel piece's texture.
static func swap(tex: Texture2D) -> Array:
	if tex == null or not enabled:
		return [tex, 1.0]
	var path := tex.resource_path
	if _swaps.has(path):
		return _swaps[path]
	var out := [tex, 1.0]
	if path.begins_with(PIXEL_ROOT):
		var hd := HD_ROOT + path.substr(PIXEL_ROOT.length())
		if ResourceLoader.exists(hd):
			var ct := _canvas_texture(hd)
			out = [ct, float(ct.diffuse_texture.get_width()) / float(tex.get_width())]
	_swaps[path] = out
	return out


## draw_texture_rect_region() with `src` in the pixel piece's texels.
static func blit(c: CanvasItem, tex: Texture2D, dst: Rect2, src: Rect2, tint: Color = Color.WHITE) -> void:
	var s: Array = swap(tex)
	var k: float = s[1]
	c.draw_texture_rect_region(s[0], dst, Rect2(src.position * k, src.size * k), tint)


static func prop(name: String) -> Dictionary:
	if not enabled:
		return {}
	if not _props_loaded:
		_props_loaded = true
		if FileAccess.file_exists(PROPS_JSON):
			var d = JSON.parse_string(FileAccess.get_file_as_string(PROPS_JSON))
			if typeof(d) == TYPE_DICTIONARY:
				_props = d
	if not _props.has(name) or not ResourceLoader.exists(HD_ROOT + "props/%s.png" % name):
		return {}
	return _props[name]


static func prop_texture(name: String) -> CanvasTexture:
	if not _prop_tex.has(name):
		_prop_tex[name] = _canvas_texture(HD_ROOT + "props/%s.png" % name)
	return _prop_tex[name]


## Texture rows [r0, r1) of prop `name` drawn with their top at world y `y`, the anchor column on x 0.
static func prop_rows(c: CanvasItem, name: String, r0: float, r1: float, y: float, tint: Color = Color.WHITE,
		scale: float = 0.0) -> void:
	var p := prop(name)
	var tex := prop_texture(name)
	var s: float = scale if scale > 0.0 else float(p["scale"])
	var w: float = tex.get_width()
	c.draw_texture_rect_region(tex, Rect2(Vector2(-float(p["anchor_x"]) * s, y), Vector2(w * s, (r1 - r0) * s)),
			Rect2(0.0, r0, w, r1 - r0), tint)
