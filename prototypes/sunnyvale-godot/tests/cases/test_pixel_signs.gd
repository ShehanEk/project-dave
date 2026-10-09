extends TestCase
## Sheet 10 (sign lettering): the sign text is set in the user's pixel font
## (scripts/world/pixel_font.gd, cut from the font sheet by
## tools/art/import_pixel_font.py) on the painted sign panels of the buildings
## sheet (scripts/world/sign_skins.gd), and the hologram projectors hang on the
## painted projector housing with their text in the same font. The code-drawn
## look with the smooth UI font stays as the fallback when the art is missing.

const PixelFont := preload("res://scripts/world/pixel_font.gd")
const SignSkins := preload("res://scripts/world/sign_skins.gd")
const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const SCENERY := "res://scenes/objects/scenery.tscn"
const ART := 1.5


func run() -> void:
	_font()
	_fitting()
	_slicing()
	await _level_signs()
	await _fallback()


## The font loads, measures, and is white so the game can tint it.
func _font() -> void:
	check(PixelFont.has_font(), "the pixel font loads (atlas and glyph table)")
	check_eq(PixelFont.cap_height(), 7, "capitals are 7 font pixels tall")
	check_eq(PixelFont.width("A"), 5, "a capital is 5 pixels wide")
	check_eq(PixelFont.width("1"), 3, "the one is 3 pixels wide")
	check_eq(PixelFont.width("AB"), 11, "a glyph's advance is its width and a 1-pixel gap, none after the last")
	check_eq(PixelFont.width("A B"), 14, "a space is 3 pixels")
	check_eq(PixelFont.width(""), 0, "an empty line has no width")
	check_eq(PixelFont.width("a"), PixelFont.width("A"), "lowercase draws as its capital")
	check_eq(PixelFont.measure("AB", 2), Vector2(33.0, 21.0), "2 art pixels per font pixel is 3 world px each: 11 x 7 pixels is 33 x 21")
	check_eq(PixelFont.measure("AB"), Vector2(16.5, 10.5), "and 1 art pixel is 1.5 world px")
	check_eq(PixelFont.block_size(PackedStringArray(["AB", "A"])), Vector2i(11, 16), "two lines are 7 + 2 + 7 pixels tall")
	var glyphs: Dictionary = PixelFont._glyphs
	check_eq(glyphs.size(), 48, "26 letters, 10 digits and 12 punctuation marks")
	check(int(glyphs["Q"]["h"]) == 9 and int(glyphs["Q"]["oy"]) == 0, "Q hangs 2 rows below the baseline")
	check(int(glyphs[","]["oy"]) + int(glyphs[","]["h"]) == 9, "so does the comma")
	check_eq(int(glyphs["."]["oy"]), 6, "the full stop sits on the baseline")
	for ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-':/+&()":
		check(PixelFont.has_glyph(ch), "the font has %s" % ch)
	check(PixelFont.has_glyph(" "), "and a space")
	check(not PixelFont.has_glyph("@"), "but not an @")
	check_eq(PixelFont.missing("OK @ #"), "@#", "missing() lists what the font lacks")
	var img: Image = PixelFont.texture().get_image()
	var white := true
	var solid := 0
	for y in img.get_height():
		for x in img.get_width():
			var c: Color = img.get_pixel(x, y)
			if c.a > 0.0:
				solid += 1
				white = white and c.a == 1.0 and c.r == 1.0 and c.g == 1.0 and c.b == 1.0
	check(solid > 400 and white, "the atlas is pure white and solid (%d pixels), so the tint is the colour" % solid)
	for ch in glyphs:
		var g: Dictionary = glyphs[ch]
		var any := false
		for y in int(g["h"]):
			for x in int(g["w"]):
				any = any or img.get_pixel(int(g["x"]) + x, int(g["y"]) + y).a > 0.0
		check(any, "the glyph rect of %s holds pixels" % ch)


## Text fits a box at 2 art pixels per font pixel when it can, else 1; it wraps
## onto two lines at a space; it never scales a pixel.
func _fitting() -> void:
	var calm: Dictionary = PixelFont.fit("PLEASE REMAIN CALM", 312.0, 60.0)
	check_eq(calm["scale"], 2, "a wide hologram's text is drawn at 2 art pixels per font pixel")
	check_eq(calm["lines"], PackedStringArray(["PLEASE REMAIN CALM"]), "on one line")
	var welcome: Dictionary = PixelFont.fit("WELCOME TO EON CITY", 150.0, 40.0)
	check_eq(welcome["scale"], 1, "a narrow sign's text uses 1 art pixel per font pixel")
	check_eq(welcome["lines"], PackedStringArray(["WELCOME TO", "EON CITY"]), "and wraps at a space")
	check(welcome["size"].x <= 150.0 and welcome["size"].y <= 40.0, "inside the box (%s)" % [welcome["size"]])
	check_eq(PixelFont.fit("ROOF WALK", 90.0, 14.0)["lines"], PackedStringArray(["ROOF WALK"]), "short text stays on one line when it fits")
	check(PixelFont.fit("EXITS CLOSED FOR YOUR COMFORT", 10.0, 10.0).is_empty(), "text that fits nowhere is reported")
	check(PixelFont.fit("CAFÉ", 300.0, 60.0).is_empty(), "so is text with a character the font lacks (the caller keeps the UI font)")
	var lines: PackedStringArray = PixelFont.split_even("FRONT GARDENS")
	check_eq(lines, PackedStringArray(["FRONT", "GARDENS"]), "split_even() breaks at the space")
	check(PixelFont.split_even("LOCKDOWN").is_empty(), "and returns nothing for one word")
	check_eq(PixelFont.wrap_words("A B C D", 14), PackedStringArray(["A B", "C D"]), "wrap_words() fills a line greedily")
	for ch_scale in [1, 2]:
		var m: Vector2 = PixelFont.measure("X", ch_scale)
		check(is_equal_approx(fmod(m.x, ART), 0.0) and is_equal_approx(fmod(m.y, ART), 0.0), "a glyph is a whole number of art pixels at %d x" % ch_scale)


## A panel of any size is its end caps with one column and one row repeated: the
## blits tile the board exactly and never read outside the piece.
func _slicing() -> void:
	check(SignSkins.has_panels() and SignSkins.has_projector(), "the three sign panels and the projector are imported")
	for piece in SignSkins.PANELS:
		var size: Vector2i = SignSkins.PANELS[piece]["size"]
		check_eq(SignSkins.texture(piece).get_size(), Vector2(size), "%s is %d x %d art pixels" % [piece, size.x, size.y])
		var tex: Texture2D = SignSkins.texture(piece)
		var fixed: Vector2i = SignSkins._fixed(piece)
		for dc in [0, 2, 6, 40]:
			for dr in [0, 2, 8, 30]:
				var cols: int = fixed.x + dc
				var rows: int = fixed.y + dr
				var area := 0.0
				var inside := true
				var seen := PackedByteArray()
				seen.resize(cols * rows)
				var overlap := false
				for sl in SignSkins.slices(piece, cols, rows):
					var src: Rect2 = sl[0]
					var dst: Rect2 = sl[1]
					area += dst.get_area()
					inside = inside and Rect2(Vector2.ZERO, tex.get_size()).encloses(src) and Rect2(0.0, 0.0, cols, rows).encloses(dst)
					for y in int(dst.size.y):
						for x in int(dst.size.x):
							var k: int = (int(dst.position.y) + y) * cols + int(dst.position.x) + x
							overlap = overlap or seen[k] == 1
							seen[k] = 1
				check(inside and not overlap and area == float(cols * rows),
						"%s at %d x %d art px: the pieces tile the board exactly (%.0f of %d)" % [piece, cols, rows, area, cols * rows])
	var tinted_green: Texture2D = SignSkins.tinted("sign_m", Color("#4DE38A"))
	check(tinted_green != SignSkins.texture("sign_m"), "a green tint makes its own recoloured copy of the panel")
	check_eq(SignSkins.tinted("sign_m", Color("#3FE0D0")), SignSkins.texture("sign_m"), "and teal draws the panel as it is")
	var frame: Color = tinted_green.get_image().get_pixel(10, 2)
	check(absf(frame.h - Color("#4DE38A").h) < 0.02, "the green panel's frame is green (hue %.2f)" % frame.h)
	var amber_frame: Color = SignSkins.tinted("sign_m", Color("#FFB02E")).get_image().get_pixel(10, 2)
	check(absf(amber_frame.h - Color("#FFB02E").h) < 0.02, "the lockdown panel's frame is amber (hue %.2f)" % amber_frame.h)
	var dark: Color = tinted_green.get_image().get_pixel(0, 0)
	check(dark.v < 0.15, "the dark glass stays dark")


## Every sign in the level draws its text on a painted panel, in a colour that
## says what it is (exit signs green, the lockdown amber or red), and every
## hologram sets its text in the pixel font on the painted projector.
func _level_signs() -> void:
	Session.new_run()
	var level: Node2D = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	var texts := {}
	var signs := 0
	var projectors := 0
	for node in level.find_children("*", "Scenery", true, false):
		var s: Scenery = node
		if s.kind == Scenery.Kind.SIGN:
			signs += 1
			texts[s.text] = true
			check(PixelFont.covers(s.text), "the pixel font covers the sign text \"%s\"" % s.text)
			var plan: Dictionary = SignSkins.plan(s.text, s.size)
			check(not plan.is_empty(), "\"%s\" fits a painted panel" % s.text)
			if plan.is_empty():
				continue
			check_eq(s.painted_sign(), plan["piece"], "%s (%s) draws the painted panel %s" % [s.name, s.text, plan["piece"]])
			check(str(s.painted_sign()).begins_with("sign_"), "%s draws one of the three sign panels" % s.name)
			check_eq(s.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "%s is drawn crisp, pixel for pixel" % s.name)
			var cols: int = plan["cols"]
			var rows: int = plan["rows"]
			check(float(cols) * ART <= s.size.x + 0.01, "%s's board (%.0f px) stays inside the sign's width (%.0f px)" % [s.name, float(cols) * ART, s.size.x])
			check(float(rows) * ART <= s.size.y * 0.85,
					"%s's board is no taller than its footprint allows (%.0f of %.0f px)" % [s.name, float(rows) * ART, s.size.y])
			# the text sits inside the frame with room to spare, on whole art pixels
			var block: Vector2 = plan["block"]
			var at: Vector2i = plan["text_at"]
			var bw: int = roundi(block.x / ART)
			var bh: int = roundi(block.y / ART)
			check(at.x >= SignSkins.CAP + SignSkins.PAD_X and at.x + bw <= cols - SignSkins.CAP - SignSkins.PAD_X,
					"\"%s\" fits between the frame's sides (x %d..%d of %d)" % [s.text, at.x, at.x + bw, cols])
			check(at.y >= SignSkins.CAP and at.y + bh <= rows - SignSkins.CAP,
					"\"%s\" fits between the frame's top and bottom (y %d..%d of %d)" % [s.text, at.y, at.y + bh, rows])
			check(plan["scale"] in [1, 2], "\"%s\" is 1 or 2 art pixels per font pixel" % s.text)
			var tint: Color = s.sign_tint()
			if s.text.contains("EXIT"):
				check_eq(tint, Scenery.SIGNAL_GREEN, "the exit sign is signal green")
			else:
				check_eq(tint, Scenery.TEAL, "%s is teal" % s.text)
		elif s.kind == Scenery.Kind.CLOUD_PROJECTOR:
			projectors += 1
			texts[s.text] = true
			check_eq(s.painted_sign(), "projector", "%s hangs on the painted projector" % s.name)
			check_eq(s.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "%s is drawn crisp" % s.name)
			var rect_w: float = s.size.x - 8.0
			var rect_h: float = s.size.y * 0.72 - 4.0
			var fit: Dictionary = PixelFont.fit(s.text, rect_w, rect_h)
			check(not fit.is_empty(), "\"%s\" fits its hologram in the pixel font" % s.text)
			if not fit.is_empty():
				check(fit["size"].x <= rect_w and fit["size"].y <= rect_h, "and stays inside it (%s of %.0f x %.0f)" % [fit["size"], rect_w, rect_h])
	check(signs >= 8 and projectors >= 5, "the level has its signs and holograms (%d, %d)" % [signs, projectors])
	for t in ["WELCOME TO EON CITY", "FRONT GARDENS", "GARDEN PATH", "ROOF WALK", "SERVICE WICKET", "STAFF ANNEX", "SERVER DEPOT",
			"THIS WAY", "EMERGENCY EXIT", "LOCKDOWN", "PLEASE REMAIN CALM", "EXITS CLOSED FOR YOUR COMFORT"]:
		check(texts.has(t), "the level has \"%s\"" % t)
		check(PixelFont.covers(t), "and the font covers it")
	check(PixelFont.covers("L01-TEST-SAMPLE"), "the test sample text is covered too")
	# the exit sign in the depot goes green, and a lockdown turns a sign amber or red
	var depot: Node = level.areas[4]
	var exit_sign: Scenery = depot.get_node("Scenery/ExitSign")
	check_eq(exit_sign.painted_sign(), SignSkins.plan(exit_sign.text, exit_sign.size)["piece"], "the depot's signs are painted too")
	check_eq(exit_sign.sign_tint(), Scenery.SIGNAL_GREEN, "the exit sign is green")
	exit_sign.set_lamp_examination_mode(true, false, Scenery.ALARM)
	check_eq(exit_sign.sign_tint(), Scenery.SIGNAL_GREEN, "and stays green in the lockdown")
	var entry: Scenery = depot.get_node("Scenery/EntrySign")
	check_eq(entry.sign_tint(), Scenery.TEAL, "a plain sign is teal")
	entry.set_lamp_examination_mode(true, false, Scenery.ALARM)
	check_eq(entry.sign_tint(), Scenery.ALARM, "the lockdown turns it alarm red")
	var red: Color = SignSkins.tinted("sign_m", entry.sign_tint()).get_image().get_pixel(10, 2)
	check(absf(red.h - Scenery.ALARM.h) < 0.02 or absf(red.h - Scenery.ALARM.h) > 0.98, "its panel's frame is red too (hue %.2f)" % red.h)
	entry.set_lamp_examination_mode(false)
	check_eq(entry.sign_tint(), Scenery.TEAL, "and ends with it")
	level.queue_free()
	await physics_frames(2)


## Without the font (or the panels) a sign keeps its code-drawn board and UI
## font; the projector keeps its housing but sets its text in the UI font.
func _fallback() -> void:
	PixelFont.use_dir("res://assets/environment/sunnyvale/no_such_font/")
	check(not PixelFont.has_font(), "a missing font is reported")
	check(not PixelFont.covers("A"), "and covers nothing")
	check(PixelFont.fit("A", 100.0, 100.0).is_empty(), "so nothing is fitted")
	check(SignSkins.plan("ROOF WALK", Vector2(110.0, 60.0)).is_empty(), "and no sign panel is planned")
	var sign: Scenery = load(SCENERY).instantiate()
	sign.kind = Scenery.Kind.SIGN
	sign.size = Vector2(110.0, 60.0)
	sign.text = "ROOF WALK"
	add_child(sign)
	var holo: Scenery = load(SCENERY).instantiate()
	holo.kind = Scenery.Kind.CLOUD_PROJECTOR
	holo.size = Vector2(160.0, 55.0)
	holo.text = "LOCKDOWN"
	add_child(holo)
	await physics_frames(3)
	check_eq(sign.painted_sign(), "", "the sign keeps its code-drawn board")
	check(sign.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST, "and its smooth UI-font text")
	check_eq(sign.sign_tint(), Scenery.TEAL, "in the same teal")
	check_eq(holo.painted_sign(), "projector", "the projector housing needs no font")
	check(not holo._pixel_text(), "but its text is the UI font")
	sign.queue_free()
	holo.queue_free()
	await physics_frames(2)
	PixelFont.use_dir()
	check(PixelFont.has_font(), "restoring the folder brings the font back")
	# a sign whose text has a character the font lacks keeps the code-drawn board too
	var odd: Scenery = load(SCENERY).instantiate()
	odd.kind = Scenery.Kind.SIGN
	odd.size = Vector2(110.0, 60.0)
	odd.text = "CAFÉ"
	add_child(odd)
	await physics_frames(2)
	check_eq(odd.painted_sign(), "", "a sign with a character the font lacks keeps the UI font")
	odd.queue_free()
	await physics_frames(2)
