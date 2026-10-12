extends RefCounted
## The pixel-art UI (Sheets 11 and 12): the pieces tools/art/import_pixel_ui.py
## cuts into assets/ui/pixel/ (one texel per UI pixel), the HUD's bitmap font
## and the key caps. No `class_name` (import-cache rule): callers preload it by
## path, like pixel_font.gd.
##
## Scale: one UI pixel is SCALE (3) canvas px on the 1280x720 canvas (a 12-pixel
## chip icon is 36 px). In-world UI (tutorial prompts, the interact prompt,
## object toasts) uses 3 world px per UI pixel, the world's own object and
## building pixel (2 x 2 art pixels of 1.5 world px). The Controls table draws
## its key caps at 2 px per UI pixel so its nine rows fit the panel unscrolled.
##
## Filtering: every texture this hands out is a CanvasTexture with nearest
## filtering wrapped around the PNG, so a piece stays crisp whatever the
## drawing node's own `texture_filter` is (text keeps the node's filter). The
## theme (assets/ui/c11_theme.tres) wraps its x3 frames the same way.
##
## Hand-painted (batch 3, C56, tools/art/import_hd_ui.py): when a piece has a painted twin under
## assets/ui/hd/ (HD_K texels per UI pixel), `texture()` and `scaled_texture()` hand out the
## painted one, smooth and mipmapped, still reporting the pixel piece's size (an ImageTexture size
## override), so every caller lays it out exactly as before. The key caps are built the same way
## with their legends set in the Rajdhani font, and `font()` is Rajdhani SemiBold in place of the
## bitmap font. `image()` stays the pixel piece (layouts are measured on it).
##
## Fallback: `texture()` is null and `has_piece()` false when a PNG is missing
## (an export without the art, or `use_dir()` pointed at an empty folder in a
## test); every caller then keeps its code-drawn look or its text.

const PixelFont := preload("res://scripts/world/pixel_font.gd")

const DIR := "res://assets/ui/pixel/"
## Canvas px per UI pixel (HUD and menus) and world px per UI pixel (in-world UI).
const SCALE := 3
## The panel, tag, banner and button frames' border: a dark outline pixel and
## two teal ones, UI px.
const FRAME_BORDER := 3
## Ink for the key caps' legends (the sheets' outline colour).
const INK := Color("#07090F")
## The longest key label put on a cap ("ENTER", "SPACE", "SHIFT"); a longer
## label ("SEMICOLON" on a headless run) is shown as text instead.
const MAX_CAP_CHARS := 5
## Face rows of a key cap: one blank row, the 7-row capitals, one blank row.
const CAP_FACE_ROWS := 9
## Blank face columns either side of a cap's legend.
const CAP_PAD := 2
const ARROW_PIECES := {"←": "arrow_left", "→": "arrow_right", "↑": "arrow_up", "↓": "arrow_down"}
## The HUD font's nominal size: a Label's font size is divided by this and
## rounded to a whole number of canvas px per font pixel (Godot's
## FIXED_SIZE_SCALE_INTEGER_ONLY), so 20-24 draws 3 px per font pixel and the
## Large text sizes 25-31 draw 4 px.
const FONT_BASE := 7

static var _dir := DIR
static var _textures := {}
static var _images := {}
static var _caps := {}
static var _scaled := {}
static var _font: FontFile = null
static var _font_built := false

const HD_DIR := "res://assets/ui/hd/"
## Painted texels per UI pixel (tools/art/import_hd_ui.py UI_K).
const HD_K := 6
const HD_FONT := "res://assets/fonts/Rajdhani-SemiBold.ttf"
## Outline (canvas px) round the HUD's Rajdhani text, so it reads over the world unbacked.
const HD_OUTLINE := 6
static var hd_enabled := true
static var _hd_dir := HD_DIR
static var _hd_font := HD_FONT
static var _font_is_hd := false
static var _hd_images := {}


## Points the pieces at another folder (tests simulate a missing export with a
## folder that does not exist) and forgets everything built; `use_dir()` with
## no argument restores the real one. Also forgets the font, so call it after
## `PixelFont.use_dir()` too.
static func use_dir(dir: String = DIR) -> void:
	_dir = dir
	_hd_dir = HD_DIR if dir == DIR else dir + "hd/"
	_hd_font = HD_FONT if dir == DIR else dir + "Rajdhani-SemiBold.ttf"
	_hd_images = {}
	_font_is_hd = false
	_textures = {}
	_images = {}
	_caps = {}
	_scaled = {}
	_font = null
	_font_built = false


## The piece `piece` (e.g. "chip") as a nearest-filtered texture, null when its
## PNG is missing.
static func texture(piece: String) -> Texture2D:
	if not _textures.has(piece):
		var path: String = _dir + piece + ".png"
		var png: Texture2D = load(path) if ResourceLoader.exists(path) else null
		var tex: Texture2D = null
		if png:
			tex = hd_texture(piece, Vector2i(png.get_size()))
			if tex == null:
				tex = crisp(png)
		_textures[piece] = tex
	return _textures[piece]


## The painted twin of `piece` (RGBA8, HD_K texels per UI pixel), null when there is none.
static func hd_image(piece: String) -> Image:
	if not hd_enabled:
		return null
	if not _hd_images.has(piece):
		var path: String = _hd_dir + piece + ".png"
		var img: Image = null
		if ResourceLoader.exists(path):
			var png: Texture2D = load(path)
			img = _rgba(png.get_image() if png else null)
		_hd_images[piece] = img
	return _hd_images[piece]


## `img` as a smooth, mipmapped texture that reports `size` (its layout size; it draws all of
## `img` over it).
static func smooth(img: Image, size: Vector2i) -> Texture2D:
	var big: Image = img.duplicate()
	big.generate_mipmaps()
	var it := ImageTexture.create_from_image(big)
	it.set_size_override(size)
	var ct := CanvasTexture.new()
	ct.diffuse_texture = it
	ct.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return ct


## The painted `piece` reporting `size`, null when it has no painted twin.
static func hd_texture(piece: String, size: Vector2i) -> Texture2D:
	var img := hd_image(piece)
	return smooth(img, size) if img != null else null


## True when `tex` is a painted piece (smooth, not nearest).
static func is_hd(tex: Texture2D) -> bool:
	return tex is CanvasTexture and (tex as CanvasTexture).texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


static func has_piece(piece: String) -> bool:
	return texture(piece) != null


## `tex` wrapped in a CanvasTexture with nearest filtering (null stays null).
static func crisp(tex: Texture2D) -> Texture2D:
	if tex == null or tex is CanvasTexture:
		return tex
	var ct := CanvasTexture.new()
	ct.diffuse_texture = tex
	ct.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return ct


## True when `tex` draws with nearest filtering on its own (tests).
static func is_crisp(tex: Texture2D) -> bool:
	return tex is CanvasTexture and (tex as CanvasTexture).texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST


## The piece's pixels (RGBA8), null when its PNG is missing.
static func image(piece: String) -> Image:
	if not _images.has(piece):
		var path: String = _dir + piece + ".png"
		var img: Image = null
		if ResourceLoader.exists(path):
			var png: Texture2D = load(path)
			img = _rgba(png.get_image() if png else null)
		_images[piece] = img
	return _images[piece]


static func _rgba(img: Image) -> Image:
	if img == null:
		return null
	var out: Image = img.duplicate()
	if out.is_compressed():
		out.decompress()
	out.convert(Image.FORMAT_RGBA8)
	return out


## Draws the frame piece `piece` (plain edges and middle, corners `margin` UI
## px) stretched over `rect` at `px` canvas px per UI pixel: corners whole,
## edges and middle stretched (they are one colour along their length, so
## nothing is distorted). False when the piece is missing.
static func draw_frame(c: CanvasItem, piece: String, rect: Rect2, margin: int, px: float = SCALE,
		modulate: Color = Color.WHITE) -> bool:
	var tex := texture(piece)
	if tex == null:
		return false
	var ts: Vector2 = tex.get_size()
	var m := float(margin)
	var dm: float = m * px
	var sx := [0.0, m, ts.x - m, ts.x]
	var sy := [0.0, m, ts.y - m, ts.y]
	var dx := [rect.position.x, rect.position.x + dm, rect.end.x - dm, rect.end.x]
	var dy := [rect.position.y, rect.position.y + dm, rect.end.y - dm, rect.end.y]
	for j in 3:
		for i in 3:
			var src := Rect2(sx[i], sy[j], sx[i + 1] - sx[i], sy[j + 1] - sy[j])
			var dst := Rect2(dx[i], dy[j], dx[i + 1] - dx[i], dy[j + 1] - dy[j])
			if src.size.x > 0.0 and src.size.y > 0.0 and dst.size.x > 0.0 and dst.size.y > 0.0:
				c.draw_texture_rect_region(tex, dst, src, modulate)
	return true


## A StyleBoxTexture of frame piece `piece` for a node drawn at `px` px per UI
## pixel: the 9-slice margins are `margin` UI px. Built from the native piece
## by repeating pixels (`px` must be whole), so a StyleBox's 1:1 corners come
## out at UI scale. Null when the piece is missing.
static func frame_style(piece: String, margin: int, px: int = SCALE) -> StyleBoxTexture:
	var tex := scaled_texture(piece, px)
	if tex == null:
		return null
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.set_texture_margin_all(float(margin * px))
	return sb


## The piece scaled up `px` times by repeating pixels (nearest filtered), for
## things that draw a texture 1 texel : 1 px (a StyleBox's corners, a Button's
## icon). Cached; null when the piece is missing.
static func scaled_texture(piece: String, px: int = SCALE) -> Texture2D:
	var key := "%s@%d" % [piece, px]
	if not _scaled.has(key):
		var img := image(piece)
		var tex: Texture2D = null
		if img != null and hd_image(piece) != null:
			tex = smooth(hd_image(piece), img.get_size() * px)
		elif img != null:
			var big: Image = img.duplicate()
			big.resize(img.get_width() * px, img.get_height() * px, Image.INTERPOLATE_NEAREST)
			tex = crisp(ImageTexture.create_from_image(big))
		_scaled[key] = tex
	return _scaled[key]


# --- the HUD font ---------------------------------------------------------------

## The pixel sign font (scripts/world/pixel_font.gd) as a bitmap Font for
## Labels, with a 1-pixel dark outline baked around every glyph (so it reads
## over the world without a backing; the outline stays dark whatever colour the
## Label tints the glyphs) and the lowercase letters drawn as capitals. Null
## when the font PNG is missing. A Label using it needs `texture_filter`
## NEAREST (`use_font()` sets it).
static func font() -> FontFile:
	if _font_built:
		return _font
	_font_built = true
	_font_is_hd = false
	if hd_enabled and PixelFont.has_font() and ResourceLoader.exists(_hd_font):
		_font = load(_hd_font)
		_font_is_hd = _font != null
		if _font_is_hd:
			return _font
	if not PixelFont.has_font():
		return null
	var atlas := _rgba(PixelFont.texture().get_image())
	if atlas == null:
		return null
	var glyphs: Dictionary = PixelFont.glyphs()
	var cap: int = PixelFont.cap_height()
	var total_w := 0
	var max_h := 0
	for ch in glyphs:
		total_w += int(glyphs[ch]["w"]) + 3
		max_h = maxi(max_h, int(glyphs[ch]["h"]) + 2)
	var out := Image.create_empty(maxi(total_w, 1), maxi(max_h, 1), false, Image.FORMAT_RGBA8)
	var f := FontFile.new()
	f.fixed_size = FONT_BASE
	f.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.hinting = TextServer.HINTING_NONE
	f.allow_system_fallback = false
	var sz := Vector2i(FONT_BASE, 0)
	f.set_cache_ascent(0, FONT_BASE, float(cap + 1))
	f.set_cache_descent(0, FONT_BASE, 3.0)
	var x := 0
	for ch in glyphs:
		var g: Dictionary = glyphs[ch]
		var gx := int(g["x"])
		var gy := int(g["y"])
		var gw := int(g["w"])
		var gh := int(g["h"])
		for yy in gh:
			for xx in gw:
				if atlas.get_pixel(gx + xx, gy + yy).a < 0.5:
					continue
				for dy in [-1, 0, 1]:
					for dx in [-1, 0, 1]:
						var px: int = x + 1 + xx + dx
						var py: int = 1 + yy + dy
						if out.get_pixel(px, py).a < 0.5:
							out.set_pixel(px, py, INK)
		for yy in gh:
			for xx in gw:
				if atlas.get_pixel(gx + xx, gy + yy).a >= 0.5:
					out.set_pixel(x + 1 + xx, 1 + yy, Color.WHITE)
		for c in [String(ch), String(ch).to_lower()]:
			var cp: int = String(c).unicode_at(0)
			f.set_glyph_advance(0, FONT_BASE, cp, Vector2(float(g["adv"]), 0.0))
			f.set_glyph_offset(0, sz, cp, Vector2(-1.0, float(g["oy"]) - float(cap) - 1.0))
			f.set_glyph_size(0, sz, cp, Vector2(gw + 2, gh + 2))
			f.set_glyph_uv_rect(0, sz, cp, Rect2(x, 0, gw + 2, gh + 2))
			f.set_glyph_texture_idx(0, sz, cp, 0)
		x += gw + 3
	f.set_glyph_advance(0, FONT_BASE, 32, Vector2(float(PixelFont.advance(" ")), 0.0))
	f.set_texture_image(0, sz, 0, out)
	_font = f
	return _font


## Sets `label` in the HUD pixel font when the font exists and can draw all of
## its text, else back in the UI font (with its authored outline). Returns true
## when the pixel font is in use. The Label's own font size still decides the
## size (FONT_BASE), so the text-size setting keeps working.
static func use_font(label: Label) -> bool:
	if not label.has_meta(&"ui_outline_size"):
		label.set_meta(&"ui_outline_size", label.get_theme_constant("outline_size"))
	var f := font()
	if f != null and _font_is_hd:
		label.add_theme_font_override("font", f)
		var own: int = int(label.get_meta(&"ui_outline_size"))
		label.add_theme_constant_override("outline_size", own if own > 0 else HD_OUTLINE)
		label.texture_filter = CanvasItem.TEXTURE_FILTER_PARENT_NODE
		return true
	if f != null and PixelFont.covers(label.text):
		label.add_theme_font_override("font", f)
		# The outline is baked into the glyphs; a bitmap font draws no other.
		label.add_theme_constant_override("outline_size", 0)
		label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		return true
	if label.has_theme_font_override("font"):
		label.remove_theme_font_override("font")
	label.add_theme_constant_override("outline_size", int(label.get_meta(&"ui_outline_size")))
	label.texture_filter = CanvasItem.TEXTURE_FILTER_PARENT_NODE
	return false


## True when `label` is currently set in the HUD pixel font.
static func uses_font(label: Label) -> bool:
	return _font != null and label.has_theme_font_override("font") \
			and label.get_theme_font("font") == _font


## Whole canvas px per font pixel the HUD font draws at for `font_size`.
static func font_scale(font_size: int) -> int:
	return maxi(1, roundi(float(font_size) / float(FONT_BASE)))


# --- key caps -------------------------------------------------------------------

## A key cap for `label` (as input_icon_map.gd's key_label() names a key): the
## arrows get their arrow glyph, "Space" the wide cap with SPACE, any other
## label of 1 to MAX_CAP_CHARS characters the pixel font can draw gets them in
## dark ink on the blank cap (widened for more than one character). Null when
## the label cannot be drawn or a piece is missing; the caller shows text.
## Built once per label, at one texel per UI pixel.
static func key_cap(label: String) -> Texture2D:
	if _caps.has(label):
		return _caps[label]
	var img := _build_cap(label)
	var tex: Texture2D = null
	if img != null:
		var hd := _build_cap_hd(label, img.get_size())
		tex = smooth(hd, img.get_size()) if hd != null else crisp(ImageTexture.create_from_image(img))
	_caps[label] = tex
	return tex


## The painted cap for `label` at HD_K texels per UI pixel of the pixel cap's `size`: the blank
## painted cap nine-sliced to it, the legend (Rajdhani, or the painted arrow) inked on its face.
## Null when a painted piece or the font is missing.
static func _build_cap_hd(label: String, size: Vector2i) -> Image:
	var arrow: bool = ARROW_PIECES.has(label)
	var base := "key_cap" if arrow or label.length() == 1 else "key_wide"
	var src := hd_image(base)
	if src == null:
		return null
	var w: int = size.x * HD_K
	var h: int = size.y * HD_K
	var out := nine_image(src, w, h)
	# The face: inside the outline, above the cap's darker lower bevel.
	var face := Rect2i(HD_K * 2, HD_K, w - HD_K * 4, (CAP_FACE_ROWS + 1) * HD_K)
	var legend: Image = null
	if arrow:
		legend = hd_image(ARROW_PIECES[label])
		if legend != null:
			legend = legend.duplicate()
			var lb: Rect2i = legend.get_used_rect()
			legend = legend.get_region(lb)
			var ls: float = float(face.size.y) * 0.62 / float(maxi(lb.size.y, 1))
			legend.resize(maxi(1, roundi(lb.size.x * ls)), maxi(1, roundi(lb.size.y * ls)), Image.INTERPOLATE_LANCZOS)
	else:
		legend = text_image(label.to_upper(), roundi(face.size.y * 0.58))
	if legend == null:
		return null
	_ink_over(out, legend, face.position + (face.size - legend.get_size()) / 2)
	return out


## `legend`'s coverage drawn in INK over `dst` at `at`.
static func _ink_over(dst: Image, legend: Image, at: Vector2i) -> void:
	for y in legend.get_height():
		for x in legend.get_width():
			var a: float = legend.get_pixel(x, y).a
			var px := at + Vector2i(x, y)
			if a <= 0.0 or px.x < 0 or px.y < 0 or px.x >= dst.get_width() or px.y >= dst.get_height():
				continue
			var under: Color = dst.get_pixel(px.x, px.y)
			dst.set_pixel(px.x, px.y, Color(under.lerp(INK, a), maxf(under.a, a)))


## `src` nine-sliced to `w` x `h`: its corners (0.3 of its shorter side) kept at one scale, its
## edges and face stretched.
static func nine_image(src: Image, w: int, h: int) -> Image:
	var sw: int = src.get_width()
	var sh: int = src.get_height()
	var cs: int = int(mini(sw, sh) * 0.3)
	var d: int = clampi(roundi(cs * minf(float(w) / sw, float(h) / sh)), 1, mini(w, h) / 2 - 1)
	var sx := [0, cs, sw - cs, sw]
	var sy := [0, cs, sh - cs, sh]
	var dx := [0, d, w - d, w]
	var dy := [0, d, h - d, h]
	var out := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	for j in 3:
		for i in 3:
			var r := Rect2i(sx[i], sy[j], sx[i + 1] - sx[i], sy[j + 1] - sy[j])
			var dw: int = dx[i + 1] - dx[i]
			var dh: int = dy[j + 1] - dy[j]
			if r.size.x <= 0 or r.size.y <= 0 or dw <= 0 or dh <= 0:
				continue
			var part: Image = src.get_region(r)
			part.resize(dw, dh, Image.INTERPOLATE_BILINEAR)
			out.blit_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), Vector2i(dx[i], dy[j]))
	return out


## `text` (one line) set in the HUD font (Rajdhani) as white coverage on clear, its capitals
## `cap_px` tall; null without the painted font.
static func text_image(text: String, cap_px: int) -> Image:
	var f := font()
	if f == null or not _font_is_hd or text == "":
		return null
	# Rajdhani's capitals are about 0.62 of the font size (measured on "H").
	var fs: int = maxi(8, roundi(float(cap_px) / 0.62))
	var sz := Vector2i(fs, 0)
	f.render_range(0, sz, 0x20, 0x7E)
	var glyphs := []
	var pen := 0.0
	var top := 0
	var bottom := 0
	for i in text.length():
		var g: int = f.get_glyph_index(fs, text.unicode_at(i), 0)
		var off: Vector2 = f.get_glyph_offset(0, sz, g)
		var gs: Vector2 = f.get_glyph_size(0, sz, g)
		glyphs.append([g, pen, off, gs])
		top = mini(top, int(off.y))
		bottom = maxi(bottom, int(off.y + gs.y))
		pen += f.get_glyph_advance(0, fs, g).x
	var out := Image.create_empty(maxi(1, ceili(pen) + 2), maxi(1, bottom - top), false, Image.FORMAT_RGBA8)
	for e in glyphs:
		var gs: Vector2 = e[3]
		if gs.x <= 0.0 or gs.y <= 0.0:
			continue
		var atlas: Image = f.get_texture_image(0, sz, f.get_glyph_texture_idx(0, sz, e[0]))
		if atlas == null:
			continue
		var uv: Rect2 = f.get_glyph_uv_rect(0, sz, e[0])
		var gx: int = int(e[1] + e[2].x) + 1
		var gy: int = int(e[2].y) - top
		for y in int(uv.size.y):
			for x in int(uv.size.x):
				var a: float = atlas.get_pixel(int(uv.position.x) + x, int(uv.position.y) + y).a
				var p := Vector2i(gx + x, gy + y)
				if a > 0.0 and p.x >= 0 and p.y >= 0 and p.x < out.get_width() and p.y < out.get_height():
					out.set_pixel(p.x, p.y, Color(1, 1, 1, maxf(a, out.get_pixel(p.x, p.y).a)))
	var used: Rect2i = out.get_used_rect()
	return out.get_region(used) if used.size.x > 0 else null


static func _build_cap(label: String) -> Image:
	var legend: Image = null
	var base := "key_cap"
	if ARROW_PIECES.has(label):
		legend = _inked(image(ARROW_PIECES[label]))
	else:
		var text := label.to_upper()
		if text.length() < 1 or text.length() > MAX_CAP_CHARS or text.strip_edges() != text:
			return null
		if not PixelFont.covers(text):
			return null
		legend = _text_image(text)
		if text.length() > 1:
			base = "key_wide"
	var cap := image(base)
	if cap == null or legend == null:
		return null
	var cw: int = cap.get_width()
	var ch: int = cap.get_height()
	# The cap's rows: outline, face (to the band), band, outline.
	var band := 1
	var mid: int = cw / 2
	var face_col: Color = cap.get_pixel(mid, 1)
	while band < ch - 1 and cap.get_pixel(mid, band).is_equal_approx(face_col):
		band += 1
	var rows := [0]
	for i in CAP_FACE_ROWS:
		rows.append(1)
	for r in range(band, ch - 1):
		rows.append(r)
	rows.append(ch - 1)
	var inner: int = maxi(legend.get_width(), 5) + 2 * CAP_PAD
	var w: int = inner + 2
	var out := Image.create_empty(w, rows.size(), false, Image.FORMAT_RGBA8)
	for y in rows.size():
		for x in w:
			var sx: int = 0 if x == 0 else (cw - 1 if x == w - 1 else 1)
			out.set_pixel(x, y, cap.get_pixel(sx, rows[y]))
	var lx: int = 1 + (inner - legend.get_width()) / 2
	var ly := 2
	for y in legend.get_height():
		for x in legend.get_width():
			if legend.get_pixel(x, y).a >= 0.5 and ly + y < rows.size() - 1:
				out.set_pixel(lx + x, ly + y, INK)
	return out


## `img`'s opaque pixels in ink.
static func _inked(img: Image) -> Image:
	if img == null:
		return null
	var out: Image = img.duplicate()
	for y in out.get_height():
		for x in out.get_width():
			if out.get_pixel(x, y).a >= 0.5:
				out.set_pixel(x, y, INK)
	return out


## `text` (capitals, one line) set in the pixel font, white on clear, as tall
## as the capitals plus the descent.
static func _text_image(text: String) -> Image:
	var atlas := _rgba(PixelFont.texture().get_image()) if PixelFont.has_font() else null
	if atlas == null:
		return null
	var glyphs: Dictionary = PixelFont.glyphs()
	var w: int = maxi(PixelFont.width(text), 1)
	var out := Image.create_empty(w, PixelFont.cap_height() + 2, false, Image.FORMAT_RGBA8)
	var pen := 0
	for i in text.length():
		var u: String = text[i]
		if glyphs.has(u):
			var g: Dictionary = glyphs[u]
			for yy in int(g["h"]):
				for xx in int(g["w"]):
					var p := atlas.get_pixel(int(g["x"]) + xx, int(g["y"]) + yy)
					var ty: int = int(g["oy"]) + yy
					if p.a >= 0.5 and pen + xx < w and ty < out.get_height():
						out.set_pixel(pen + xx, ty, Color.WHITE)
		pen += PixelFont.advance(u)
	return out


# --- in-world tags ----------------------------------------------------------------

## Backs the hero's interact prompt (a Label in world space: "Save", "Pull
## lever", "Workbench") with the pixel prompt tag at 3 world px per UI pixel:
## the tag's box nine-sliced to the text (`prompt_box`) and its pointer
## (`prompt_tail`) centred under it, pointing down at the hero. The Label is
## re-anchored to hug its text, centred where it was, its bottom edge where
## its bottom was (it grows upward), so the pointer's tip ends 1 UI pixel
## lower. False (and the Label unchanged) when either PNG is missing.
static func dress_prompt_label(label: Label) -> bool:
	var sb := frame_style("prompt_box", 2)
	var tail := texture("prompt_tail")
	if sb == null or tail == null:
		return false
	sb.content_margin_left = 4.0 * SCALE
	sb.content_margin_right = 4.0 * SCALE
	sb.content_margin_top = 1.0 * SCALE
	sb.content_margin_bottom = 1.0 * SCALE
	label.add_theme_stylebox_override("normal", sb)
	var cx: float = (label.offset_left + label.offset_right) * 0.5
	var bottom: float = label.offset_bottom
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	label.offset_left = cx
	label.offset_right = cx
	label.offset_top = bottom
	label.offset_bottom = bottom
	var t := TextureRect.new()
	t.name = "Tail"
	t.texture = tail
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ts: Vector2 = tail.get_size() * float(SCALE)
	t.anchor_left = 0.5
	t.anchor_right = 0.5
	t.anchor_top = 1.0
	t.anchor_bottom = 1.0
	t.offset_left = -floorf(ts.x * 0.5 / SCALE) * SCALE
	t.offset_right = t.offset_left + ts.x
	t.offset_top = -float(SCALE)
	t.offset_bottom = ts.y - float(SCALE)
	label.add_child(t)
	return true


## The toast backing (the banner strip, nine-sliced, 3 px per UI pixel) with
## content margins for a one- or two-line message; null without the PNG.
static func toast_style() -> StyleBoxTexture:
	var sb := frame_style("banner", 4)
	if sb == null:
		return null
	sb.content_margin_left = 5.0 * SCALE
	sb.content_margin_right = 5.0 * SCALE
	sb.content_margin_top = 2.0 * SCALE
	sb.content_margin_bottom = 2.0 * SCALE
	return sb
