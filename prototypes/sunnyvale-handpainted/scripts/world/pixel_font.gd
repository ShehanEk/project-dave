extends RefCounted
## The pixel-art sign font (Sheet 10): the user's bitmap font sheet
## (concept-art/env-sunnyvale/sunnyvale-font-v1.webp), cut by
## tools/art/import_pixel_font.py into an atlas and a glyph table
## (assets/environment/sunnyvale/font/font.png and font.json) and drawn by
## Scenery for its sign and hologram text. No `class_name` (M6 art-pass import-
## cache rule): Scenery preloads it by path.
##
## The font is 5 x 7 pixels (capitals, digits and . , ! ? - ' : / + & ( ));
## the glyphs are pure white and the caller tints them. A font pixel is drawn
## as a whole number of art pixels (1 or 2; 1 art pixel is 1.5 world px, like
## every painted piece), so a letter is never scaled by a fraction: 1 art pixel
## per font pixel is finer than the sign panels' own pixels (2 x 2 art pixels),
## 2 art pixels per font pixel is exactly one panel pixel.
##
## Text is drawn in capitals only (a lowercase letter is drawn as its capital).
## The canvas item that draws it must use `texture_filter` NEAREST
## (`make_crisp()`); `has_font()` is false when the PNG or JSON is missing (an
## export without the art), and the caller keeps its smooth UI-font text as
## the fallback.
##
## Sizes below are in font pixels unless a function says world px.

const ART := 1.5
const DIR := "res://assets/environment/sunnyvale/font/"
## Blank font rows between two lines of text.
const LINE_GAP := 2

static var _dir := DIR
static var _loaded := false
static var _atlas: Texture2D = null
static var _glyphs := {}
static var _cap := 7
static var _gap := 1
static var _space := 3


## Points the font at another folder (tests simulate a missing export with a
## folder that does not exist) and forgets what was loaded; `use_dir()` with no
## argument restores the real one.
static func use_dir(dir: String = DIR) -> void:
	_dir = dir
	_loaded = false
	_atlas = null
	_glyphs = {}


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var png: String = _dir + "font.png"
	var json: String = _dir + "font.json"
	if not ResourceLoader.exists(png) or not FileAccess.file_exists(json):
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(json))
	if not data is Dictionary or not (data as Dictionary).get("glyphs") is Dictionary:
		return
	var tex: Texture2D = load(png)
	if tex == null:
		return
	_atlas = tex
	_glyphs = data["glyphs"]
	_cap = int(data.get("cap_height", 7))
	_gap = int(data.get("gap", 1))
	_space = int(data.get("space", 3))


static func has_font() -> bool:
	_load()
	return _atlas != null and not _glyphs.is_empty()


static func texture() -> Texture2D:
	_load()
	return _atlas


## The glyph table (capital -> {x, y, w, h, adv, oy}, font px; read only), for
## code that builds its own text from the atlas (scripts/ui/pixel_ui.gd: the
## HUD's bitmap Font and the key caps).
static func glyphs() -> Dictionary:
	_load()
	return _glyphs


## The nearest filter every canvas item that draws this font needs.
static func make_crisp(c: CanvasItem) -> void:
	c.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


## Height of a capital letter, in font pixels.
static func cap_height() -> int:
	_load()
	return _cap


## True when `ch` (one character) can be drawn: a glyph, or a space.
static func has_glyph(ch: String) -> bool:
	_load()
	var u: String = ch.to_upper()
	return u == " " or _glyphs.has(u)


## True when every character of `text` can be drawn.
static func covers(text: String) -> bool:
	if not has_font():
		return false
	for i in text.length():
		if not has_glyph(text[i]):
			return false
	return true


## The characters of `text` the font cannot draw (for tests and warnings).
static func missing(text: String) -> String:
	var out := ""
	for i in text.length():
		if not has_glyph(text[i]) and out.find(text[i]) < 0:
			out += text[i]
	return out


## How far the pen moves after `ch`, in font pixels.
static func advance(ch: String) -> int:
	_load()
	var u: String = ch.to_upper()
	if _glyphs.has(u):
		return int(_glyphs[u]["adv"])
	return _space


## The width of one line of `text`, in font pixels: its glyphs and the gaps
## between them, without a trailing gap.
static func width(text: String) -> int:
	_load()
	var w := 0
	for i in text.length():
		w += advance(text[i])
	if text != "" and _glyphs.has(text[text.length() - 1].to_upper()):
		w -= _gap
	return maxi(w, 0)


## The size of `lines` stacked, in font pixels: the widest line by the capitals
## and the gaps between them.
static func block_size(lines: PackedStringArray) -> Vector2i:
	var w := 0
	for line in lines:
		w = maxi(w, width(line))
	var n: int = lines.size()
	return Vector2i(w, 0 if n == 0 else n * _cap + (n - 1) * LINE_GAP)


## The size of `text` (one line) in world px when each font pixel is
## `art_per_px` art pixels.
static func measure(text: String, art_per_px: int = 1) -> Vector2:
	_load()
	return Vector2(width(text), _cap) * float(art_per_px) * ART


## Splits `text` at spaces into lines no wider than `max_px` font pixels
## (greedy). A single word wider than the limit stays whole on its own line.
static func wrap_words(text: String, max_px: int) -> PackedStringArray:
	var lines := PackedStringArray()
	var cur := ""
	for word in text.split(" ", false):
		var trial: String = word if cur == "" else cur + " " + word
		if cur != "" and width(trial) > max_px:
			lines.append(cur)
			cur = word
		else:
			cur = trial
	if cur != "":
		lines.append(cur)
	return lines


## `text` split at the one space that leaves the two lines most even; empty
## when it has no space.
static func split_even(text: String) -> PackedStringArray:
	var best := PackedStringArray()
	var best_w := 1 << 30
	for i in text.length():
		if text[i] != " ":
			continue
		var a: String = text.substr(0, i).strip_edges()
		var b: String = text.substr(i + 1).strip_edges()
		if a == "" or b == "":
			continue
		var w: int = maxi(width(a), width(b))
		if w < best_w:
			best_w = w
			best = PackedStringArray([a, b])
	return best


## Chooses how to set `text` in a box of `max_w` x `max_h` world px: the largest
## whole number of art pixels per font pixel (2, then 1) at which it fits on
## one line, on two even lines, or (at 1) wrapped onto up to `max_lines`
## lines. `scales` limits which art-pixels-per-font-pixel are tried, in order.
## Returns {} when nothing fits, else
##   {"lines": PackedStringArray, "scale": art px per font px,
##    "size": Vector2 (world px: the widest line by the block's height)}.
static func fit(text: String, max_w: float, max_h: float, max_lines: int = 3, scales: Array = [2, 1]) -> Dictionary:
	if not has_font() or not covers(text):
		return {}
	var t: String = text.strip_edges()
	for s in scales:
		var cands: Array = [PackedStringArray([t])]
		var two: PackedStringArray = split_even(t)
		if not two.is_empty():
			cands.append(two)
		if max_lines > 2:
			cands.append(wrap_words(t, int(max_w / (float(s) * ART))))
		for lines in cands:
			if lines.size() > max_lines:
				continue
			var b: Vector2i = block_size(lines)
			var size: Vector2 = Vector2(b) * float(s) * ART
			if size.x <= max_w + 0.001 and size.y <= max_h + 0.001:
				return {"lines": lines, "scale": int(s), "size": size}
	return {}


## Draws one line of `text` with its capitals' top edge at `pos.y` and its left
## edge (`HORIZONTAL_ALIGNMENT_LEFT`), centre (`_CENTER`) or right edge
## (`_RIGHT`) at `pos.x`, in world px of `c`'s canvas, `art_per_px` art pixels
## per font pixel, tinted by `color`. Snaps to the 1.5 px art grid. Returns the
## width drawn, in world px.
static func draw_line(c: CanvasItem, text: String, pos: Vector2, art_per_px: int, color: Color,
		align: int = HORIZONTAL_ALIGNMENT_LEFT) -> float:
	if not has_font() or text == "":
		return 0.0
	var s: float = float(art_per_px) * ART
	var w: float = float(width(text)) * s
	var x: float = pos.x
	if align == HORIZONTAL_ALIGNMENT_CENTER:
		x -= w * 0.5
	elif align == HORIZONTAL_ALIGNMENT_RIGHT:
		x -= w
	x = roundf(x / ART) * ART
	var y: float = roundf(pos.y / ART) * ART
	for i in text.length():
		var u: String = text[i].to_upper()
		if _glyphs.has(u):
			var g: Dictionary = _glyphs[u]
			c.draw_texture_rect_region(_atlas, Rect2(x, y + float(g["oy"]) * s, float(g["w"]) * s, float(g["h"]) * s),
					Rect2(float(g["x"]), float(g["y"]), float(g["w"]), float(g["h"])), color)
		x += float(advance(u)) * s
	return w


## Draws `lines` (as `fit()` returns them) stacked inside the block whose
## top-left corner is `top_left` (world px) and whose width is `block_w` world
## px, each line centred in it. Every line's left edge lands on a whole number
## of font pixels from the block's left edge, so at 2 art pixels per font pixel
## the text sits on the same 3 world px grid as the panel it is drawn on when
## `top_left` does.
static func draw_block(c: CanvasItem, lines: PackedStringArray, top_left: Vector2, block_w: float,
		art_per_px: int, color: Color) -> void:
	if not has_font() or lines.is_empty():
		return
	var s: float = float(art_per_px) * ART
	for i in lines.size():
		var w: float = float(width(lines[i])) * s
		var off: float = floorf((block_w - w) * 0.5 / s) * s
		draw_line(c, lines[i], top_left + Vector2(off, float(i * (_cap + LINE_GAP)) * s), art_per_px, color)
