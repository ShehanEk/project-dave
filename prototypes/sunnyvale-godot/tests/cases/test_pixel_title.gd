extends TestCase
## The pixel title screen (2026-10-07): the DEAD EDEN logo and the night-campus
## backdrop under the menu.
##   1. Both pictures load at the sizes the importer writes (logo 150x33,
##      backdrop 1280x720).
##   2. The backdrop is linear filtered, covers the whole window (any shape),
##      and the logo is nearest filtered at a whole-number scale (5x on the
##      1280x720 base canvas, never fractional on a smaller or bigger one).
##   3. TitleLabel is still there with the text DEAD EDEN (hidden behind the
##      logo, and the logo carries it as its accessible name); the text-size
##      bases still cover it.
##   4. All four buttons exist and are focusable, in the same order; Continue
##      follows the save state.
##   5. Nothing overlaps the logo, and the menu never covers the glowing tower
##      or Dave in the backdrop; the Controls view swaps the logo for its
##      table and back.
##   6. The emblem glow follows the backdrop, breathes, and holds still under
##      reduced motion.
##   7. With the art missing the screen still works: text title, plain
##      background, every button.

const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
const LOGO_PATH := "res://assets/ui/pixel/title_logo.png"
const BACKDROP_PATH := "res://assets/ui/pixel/title_backdrop.png"
const LOGO_NATIVE := Vector2(150, 33)
const BACKDROP_NATIVE := Vector2(1280, 720)

## Things in the 1280x720 backdrop the menu must leave visible (stage px): the
## glowing tower with its flanking blocks, and Dave in the lower left.
const TOWER_RECT := Rect2(295, 65, 195, 340)
const DAVE_RECT := Rect2(195, 455, 70, 175)

var _cs: Node
var _orig_save_dir := ""
var _test_dir := ""
var _orig_reduced := false
var _orig_text_size := ""


func run() -> void:
	_cs = get_node("/root/CheckpointService")
	_orig_save_dir = _cs.get_save_dir()
	_test_dir = "user://test_runs/pixel_title_%d" % Time.get_ticks_usec()
	_cs.set_save_dir(_test_dir)
	_cs.clear()
	_orig_reduced = Settings.get_reduced_motion()
	_orig_text_size = Settings.get_text_size()
	Settings.set_reduced_motion(false)
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)

	_test_art_files()
	await _test_base_canvas_layout()
	await _test_title_label_and_accessibility()
	await _test_buttons_and_focus()
	await _test_nothing_overlaps()
	await _test_controls_view_swaps_logo()
	await _test_window_shapes()
	await _test_live_resize()
	await _test_glow_and_reduced_motion()
	await _test_text_size_large()
	await _test_missing_art_fallback()

	Settings.set_reduced_motion(_orig_reduced)
	Settings.set_text_size(_orig_text_size)
	_cs.clear()
	_cs.remove_dir_recursive(_test_dir)
	_cs.set_save_dir(_orig_save_dir)


## A title screen inside a SubViewport of an exact size (the window shape).
func _make_title(vp_size: Vector2i, configure: Callable = Callable()) -> Array:
	var vp := SubViewport.new()
	vp.size = vp_size
	vp.disable_3d = true
	vp.transparent_bg = false
	add_child(vp)
	var title: TitleScreen = load(TITLE_SCENE).instantiate()
	if configure.is_valid():
		configure.call(title)
	vp.add_child(title)
	await physics_frames(4)
	return [vp, title]


func _free_title(pair: Array) -> void:
	pair[0].queue_free()
	await physics_frames(2)


func _rect_of(c: Control) -> Rect2:
	return Rect2(c.global_position, c.size)


# --- 1. The art files -----------------------------------------------------------

func _test_art_files() -> void:
	check(ResourceLoader.exists(LOGO_PATH), "the logo texture is imported")
	check(ResourceLoader.exists(BACKDROP_PATH), "the backdrop texture is imported")
	var logo: Texture2D = load(LOGO_PATH)
	var backdrop: Texture2D = load(BACKDROP_PATH)
	check(logo != null and backdrop != null, "both textures load")
	if logo == null or backdrop == null:
		return
	check_eq(Vector2(logo.get_size()), LOGO_NATIVE, "the logo is its native pixel size (150x33 texels)")
	check_eq(Vector2(backdrop.get_size()), BACKDROP_NATIVE, "the backdrop is exactly the 1280x720 base canvas")
	var logo_img := logo.get_image()
	check(logo_img.detect_alpha() != Image.ALPHA_NONE, "the logo is transparent around its letters")
	var has_clear := false
	var top_row_opaque := false
	var left_col_opaque := false
	for y in logo_img.get_height():
		for x in logo_img.get_width():
			var a := logo_img.get_pixel(x, y).a
			has_clear = has_clear or a == 0.0
			top_row_opaque = top_row_opaque or (y == 0 and a == 1.0)
			left_col_opaque = left_col_opaque or (x == 0 and a == 1.0)
	check(has_clear and top_row_opaque and left_col_opaque, "the logo is trimmed tight to its drawing, with clear texels inside")
	check(backdrop.get_image().detect_alpha() == Image.ALPHA_NONE, "the backdrop is opaque")


# --- 2. Scaling and filtering on the base canvas -----------------------------------

func _test_base_canvas_layout() -> void:
	var pair: Array = await _make_title(Vector2i(1280, 720))
	var title: TitleScreen = pair[1]
	var backdrop: TextureRect = title.get_node("Backdrop")
	var logo: TextureRect = title.get_node("Logo")

	check(backdrop.texture != null and backdrop.visible, "the backdrop shows")
	check_eq(backdrop.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR,
			"the backdrop illustration is linear filtered")
	check_eq(backdrop.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_COVERED,
			"the backdrop covers the window, keeping its aspect")
	check_eq(backdrop.expand_mode, TextureRect.EXPAND_IGNORE_SIZE, "the backdrop ignores its native size")
	check_eq(_rect_of(backdrop), Rect2(Vector2.ZERO, Vector2(1280, 720)), "the backdrop fills the whole viewport")
	var backdrop_index := backdrop.get_index()
	check(backdrop_index < title.get_node("Panel").get_index() and backdrop_index < logo.get_index(),
			"the backdrop is drawn behind the logo and menu")

	check(logo.texture != null and logo.visible, "the logo shows")
	check_eq(logo.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "the logo is nearest filtered (crisp pixels)")
	check(title.logo_scale >= 3, "on the base canvas the logo is shown big (scale %d)" % title.logo_scale)
	check_eq(title.logo_scale, 5, "on the 1280x720 canvas the logo is 5x")
	check_eq(logo.size, LOGO_NATIVE * 5.0, "the logo is exactly 5x its native size (750x165)")
	check_eq(logo.stretch_mode, TextureRect.STRETCH_SCALE, "the logo stretches to its whole-number size")
	check(_rect_of(logo).position.x == floorf(_rect_of(logo).position.x) and _rect_of(logo).position.y == floorf(_rect_of(logo).position.y),
			"the logo sits on a whole pixel")
	check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(_rect_of(logo)), "the logo is wholly on screen")
	check(_rect_of(logo).position.y < 120.0 and _rect_of(logo).get_center().x > 640.0,
			"the logo sits in the sky at the top right")
	check(not _rect_of(logo).intersects(TOWER_RECT), "the logo does not cover the glowing tower")
	await _free_title(pair)


# --- 3. TitleLabel and the logo's accessible name ----------------------------------

func _test_title_label_and_accessibility() -> void:
	var pair: Array = await _make_title(Vector2i(1280, 720))
	var title: TitleScreen = pair[1]
	var label: Label = title.get_node("Panel/VBox/TitleLabel")
	check(label != null, "TitleLabel is still in the tree")
	check_eq(label.text, "DEAD EDEN", "TitleLabel still reads DEAD EDEN")
	check(not label.visible, "the text title hides behind the logo while the logo shows")
	check_eq(title._title_label, label, "the script still holds TitleLabel")
	check_eq(title.get_node("Logo").accessibility_name, "DEAD EDEN", "the logo's accessible name is DEAD EDEN")
	check(title._text_size_bases.has(label), "TitleLabel stays in the text-size bases")
	check(title._text_size_bases.has(title.get_node("Tagline")), "the tagline scales with the text-size setting too")
	check(String(title.get_node("Tagline").text).begins_with("Level 1"), "the tagline is kept")
	await _free_title(pair)


# --- 4. Buttons, focus and the Continue state --------------------------------------

func _test_buttons_and_focus() -> void:
	_cs.clear()
	var pair: Array = await _make_title(Vector2i(1280, 720))
	var title: TitleScreen = pair[1]
	var buttons := {
		"New Game": title.get_node("Panel/VBox/MainView/ButtonRow/NewGameButton"),
		"Continue": title.get_node("Panel/VBox/MainView/ButtonRow/ContinueButton"),
		"Controls": title.get_node("Panel/VBox/MainView/ButtonRow/ControlsButton"),
		"Quit": title.get_node("Panel/VBox/MainView/ButtonRow/QuitButton"),
	}
	for key in buttons:
		var b: Button = buttons[key]
		check(b != null and b.visible, "%s button exists and is shown" % key)
		check(b.focus_mode == Control.FOCUS_ALL, "%s button takes focus" % key)
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(_rect_of(b)), "%s button is on screen" % key)
	check(buttons["New Game"].has_focus(), "New Game has focus first")
	check(buttons["Continue"].disabled, "no save: Continue is disabled")
	check_eq(buttons["New Game"].find_next_valid_focus(), buttons["Continue"], "focus order: New Game, Continue")
	check_eq(buttons["Continue"].find_next_valid_focus(), buttons["Controls"], "focus order: Continue, Controls")
	check_eq(buttons["Controls"].find_next_valid_focus(), buttons["Quit"], "focus order: Controls, Quit")
	await _free_title(pair)

	Session.new_run()
	check(Session.commit("CP02"), "setup: a valid save exists")
	pair = await _make_title(Vector2i(1280, 720))
	title = pair[1]
	check(not title.get_node("Panel/VBox/MainView/ButtonRow/ContinueButton").disabled, "with a save: Continue is enabled")
	var snapshots := []
	title.continue_confirmed.connect(func(snapshot: Dictionary): snapshots.append(snapshot))
	title.get_node("Panel/VBox/MainView/ButtonRow/ContinueButton").pressed.emit()
	check_eq(snapshots.size(), 1, "with a save: Continue loads it")

	# The New Game confirmation still works in the new layout (its own focus).
	title._on_new_game_pressed()
	await physics_frames(3)
	check_eq(title._view, TitleScreen.View.NEW_GAME_CONFIRM, "a save makes New Game ask first")
	check(title._cancel_button.has_focus(), "the confirmation starts on Cancel")
	check(title.get_node("Logo").visible, "the logo stays up behind the confirmation")
	var panel_rect := _rect_of(title.get_node("Panel"))
	check(panel_rect.encloses(_rect_of(title._confirm_button)) and panel_rect.encloses(_rect_of(title._cancel_button)),
			"Confirm and Cancel sit inside the panel")
	check(not panel_rect.intersects(_rect_of(title.get_node("Logo"))), "the confirmation does not cover the logo")
	title._on_new_game_cancel()
	check(title._new_game_button.has_focus(), "Cancel returns focus to New Game")
	await _free_title(pair)
	_cs.clear()


# --- 5. Nothing overlaps -----------------------------------------------------------

func _test_nothing_overlaps() -> void:
	var pair: Array = await _make_title(Vector2i(1280, 720))
	var title: TitleScreen = pair[1]
	var logo := _rect_of(title.get_node("Logo"))
	var tagline := _rect_of(title.get_node("Tagline"))
	var panel := _rect_of(title.get_node("Panel"))
	var screen := Rect2(Vector2.ZERO, Vector2(1280, 720))
	check(not logo.intersects(tagline), "the tagline sits clear of the logo")
	check(not logo.intersects(panel), "the menu sits clear of the logo")
	check(not tagline.intersects(panel), "the menu sits clear of the tagline")
	check(screen.encloses(panel) and screen.encloses(tagline), "the menu and tagline are on screen")
	check(not panel.intersects(TOWER_RECT), "the menu does not cover the glowing tower")
	check(not panel.intersects(DAVE_RECT), "the menu does not cover Dave")
	check(not tagline.intersects(TOWER_RECT), "the tagline stays off the tower")
	# The panel hugs its buttons (the backdrop shows under the rest).
	var last: Button = title._quit_button
	check(panel.end.y >= _rect_of(last).end.y and panel.end.y - _rect_of(last).end.y < 60.0,
			"the menu panel is only as tall as its content")
	check(title.get_node("Panel").self_modulate.a < 1.0, "the menu panel lets the backdrop show through")
	await _free_title(pair)


func _test_controls_view_swaps_logo() -> void:
	var pair: Array = await _make_title(Vector2i(1280, 720))
	var title: TitleScreen = pair[1]
	title._on_controls_pressed()
	await physics_frames(4)
	check_eq(title._view, TitleScreen.View.CONTROLS, "Controls opens")
	check(not title.get_node("Logo").visible, "the logo gives way to the Controls table")
	check(not title.get_node("Tagline").visible, "the tagline does too")
	check(not title.get_node("Panel/VBox/TitleLabel").visible, "the text title stays hidden in Controls")
	var panel := _rect_of(title.get_node("Panel"))
	check_eq(panel.size, Vector2(640, 500), "Controls gets the shared 640x500 host panel")
	check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(panel), "the Controls panel is on screen")
	check(not panel.intersects(TOWER_RECT), "the Controls panel does not cover the tower")
	check(not panel.intersects(DAVE_RECT), "the Controls panel does not cover Dave")
	check(panel.encloses(_rect_of(title._controls_view)), "the Controls view sits inside the panel")
	var back: Button = title._controls_view.get_node("BackButton")
	check(panel.encloses(_rect_of(back)) and back.has_focus(), "Back is inside the panel and focused")
	check_eq(title.get_node("Panel").self_modulate.a, 1.0, "the Controls table sits on a solid panel")
	title._on_controls_back()
	await physics_frames(4)
	check(title.get_node("Logo").visible and title.get_node("Tagline").visible, "back from Controls: the logo and tagline return")
	check(title._controls_button.has_focus(), "back from Controls: focus returns to the Controls button")
	check(_rect_of(title.get_node("Panel")).size.x == 400.0, "back from Controls: the compact menu returns")
	await _free_title(pair)


# --- window shapes -----------------------------------------------------------------

func _test_window_shapes() -> void:
	for vp_size in [Vector2i(1920, 1080), Vector2i(1000, 700), Vector2i(1800, 720), Vector2i(800, 600), Vector2i(1280, 960)]:
		var pair: Array = await _make_title(vp_size)
		var title: TitleScreen = pair[1]
		var view := Rect2(Vector2.ZERO, Vector2(vp_size))
		var tag := "%dx%d" % [vp_size.x, vp_size.y]
		var backdrop: TextureRect = title.get_node("Backdrop")
		var logo: TextureRect = title.get_node("Logo")
		check_eq(_rect_of(backdrop), view, "%s: the backdrop fills the window" % tag)
		check(title.logo_scale >= 1 and title.logo_scale <= 5, "%s: logo scale %d is a whole number from 1 to 5" % [tag, title.logo_scale])
		check_eq(logo.size, LOGO_NATIVE * float(title.logo_scale), "%s: the logo is an exact multiple of its native size" % tag)
		check(view.encloses(_rect_of(logo)), "%s: the logo is on screen" % tag)
		var panel := _rect_of(title.get_node("Panel"))
		check(view.encloses(panel), "%s: the menu is on screen" % tag)
		check(not panel.intersects(_rect_of(logo)), "%s: the menu does not cover the logo" % tag)
		check(not panel.intersects(_rect_of(title.get_node("Tagline"))), "%s: the menu does not cover the tagline" % tag)
		if vp_size.x >= 1280 and vp_size.y >= 720:
			check_eq(title.logo_scale, 5, "%s: room for the full 5x logo" % tag)
		else:
			check(title.logo_scale < 5, "%s: a small window gets a smaller whole-number logo" % tag)
		await _free_title(pair)


## Resizing the window live re-lays the screen out (a window drag, fullscreen).
func _test_live_resize() -> void:
	var pair: Array = await _make_title(Vector2i(1280, 720))
	var vp: SubViewport = pair[0]
	var title: TitleScreen = pair[1]
	check_eq(title.logo_scale, 5, "live resize: starts at 5x")
	vp.size = Vector2i(1000, 700)
	await physics_frames(4)
	var view := Rect2(Vector2.ZERO, Vector2(1000, 700))
	check_eq(title.logo_scale, 4, "live resize: a narrower window drops to 4x")
	check_eq(_rect_of(title.get_node("Backdrop")), view, "live resize: the backdrop follows the window")
	check(view.encloses(_rect_of(title.get_node("Panel"))), "live resize: the menu stays on screen")
	check(not _rect_of(title.get_node("Panel")).intersects(_rect_of(title.get_node("Logo"))), "live resize: the menu clears the logo")
	vp.size = Vector2i(1280, 720)
	await physics_frames(4)
	check_eq(title.logo_scale, 5, "live resize: back to 5x")
	await _free_title(pair)


# --- 6. Glow and reduced motion ----------------------------------------------------

func _test_glow_and_reduced_motion() -> void:
	Settings.set_reduced_motion(false)
	var pair: Array = await _make_title(Vector2i(1280, 720))
	var title: TitleScreen = pair[1]
	var glow: TextureRect = title.get_node("Glow")
	check(glow.visible and glow.material is CanvasItemMaterial, "the emblem glow is on")
	check_eq((glow.material as CanvasItemMaterial).blend_mode, CanvasItemMaterial.BLEND_MODE_ADD, "the glow adds light")
	check(_rect_of(glow).get_center().distance_to(TitleScreen.GLOW_CENTER) < 1.0,
			"the glow sits on the tower emblem at the base size")
	check(title._glow_tween != null and title._glow_tween.is_valid(), "motion on: the glow breathes")
	var a0 := glow.modulate.a
	await seconds(1.0)
	check(not is_equal_approx(glow.modulate.a, a0), "motion on: the glow's strength changes over time")
	check(glow.mouse_filter == Control.MOUSE_FILTER_IGNORE, "the glow never eats clicks")

	Settings.set_reduced_motion(true)
	await physics_frames(2)
	check(title._glow_tween == null, "reduced motion: the glow animation is stopped")
	var held := glow.modulate.a
	await seconds(1.0)
	check_eq(glow.modulate.a, held, "reduced motion: the glow holds still")
	check(glow.visible, "reduced motion: the glow stays lit")
	Settings.set_reduced_motion(false)
	await physics_frames(2)
	check(title._glow_tween != null and title._glow_tween.is_valid(), "motion back on: the glow breathes again")
	await _free_title(pair)

	# Reduced motion already on when the screen opens: no animation at all.
	Settings.set_reduced_motion(true)
	pair = await _make_title(Vector2i(1280, 720))
	check(pair[1]._glow_tween == null, "opened under reduced motion: no glow animation")
	await _free_title(pair)
	Settings.set_reduced_motion(false)

	# Under a window of another shape the glow follows the covered backdrop.
	pair = await _make_title(Vector2i(1600, 900))
	var big_glow: TextureRect = pair[1].get_node("Glow")
	check(_rect_of(big_glow).get_center().distance_to(TitleScreen.GLOW_CENTER * 1.25) < 1.0,
			"at 1600x900 the glow scales with the backdrop")
	await _free_title(pair)
	pair = await _make_title(Vector2i(1280, 960))
	var tall_glow: TextureRect = pair[1].get_node("Glow")
	var cover := 960.0 / 720.0
	var expect := (Vector2(1280, 960) - Vector2(1280, 720) * cover) * 0.5 + TitleScreen.GLOW_CENTER * cover
	check(_rect_of(tall_glow).get_center().distance_to(expect) < 1.0,
			"in a taller window the glow follows the cropped backdrop")
	await _free_title(pair)


# --- Text size ---------------------------------------------------------------------

func _test_text_size_large() -> void:
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	var pair: Array = await _make_title(Vector2i(1280, 720))
	var title: TitleScreen = pair[1]
	var base: int = title._title_label.get_theme_font_size("font_size")
	var new_game_base: int = title._new_game_button.get_theme_font_size("font_size")
	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	await physics_frames(4)
	check_eq(title._title_label.get_theme_font_size("font_size"), Settings.scaled_font_size(base),
			"TitleLabel still scales with the text-size setting")
	check_eq(title._new_game_button.get_theme_font_size("font_size"), Settings.scaled_font_size(new_game_base),
			"the buttons still scale with the text-size setting")
	var screen := Rect2(Vector2.ZERO, Vector2(1280, 720))
	var panel := _rect_of(title.get_node("Panel"))
	check(screen.encloses(panel), "Large text: the menu is still wholly on screen")
	check(not panel.intersects(_rect_of(title.get_node("Logo"))), "Large text: the menu clears the logo")
	check(not panel.intersects(_rect_of(title.get_node("Tagline"))), "Large text: the menu clears the (wrapped) tagline")
	check(not _rect_of(title.get_node("Tagline")).intersects(_rect_of(title.get_node("Logo"))), "Large text: the tagline clears the logo")
	check(screen.encloses(_rect_of(title.get_node("Tagline"))), "Large text: the tagline stays on screen")
	check(panel.encloses(_rect_of(title._quit_button)), "Large text: Quit stays inside the panel")
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	await _free_title(pair)


# --- 7. Missing art ----------------------------------------------------------------

func _test_missing_art_fallback() -> void:
	var missing := func(t: TitleScreen) -> void:
		t.logo_path = "res://assets/ui/pixel/_no_such_logo.png"
		t.backdrop_path = "res://assets/ui/pixel/_no_such_backdrop.png"
	var pair: Array = await _make_title(Vector2i(1280, 720), missing)
	var title: TitleScreen = pair[1]
	check(not title.get_node("Logo").visible, "no logo art: the logo is not drawn")
	check(not title.get_node("Backdrop").visible, "no backdrop art: the backdrop is not drawn")
	check(not title.get_node("Glow").visible, "no backdrop art: the glow is not drawn either")
	check(title.get_node("Background").visible, "the plain dark background still shows")
	var label: Label = title.get_node("Panel/VBox/TitleLabel")
	check(label.visible and label.text == "DEAD EDEN", "no logo art: the text title DEAD EDEN stands in")
	check(title._new_game_button.has_focus(), "no art: New Game still has focus")
	var screen := Rect2(Vector2.ZERO, Vector2(1280, 720))
	var panel := _rect_of(title.get_node("Panel"))
	check(screen.encloses(panel), "no art: the menu is on screen")
	for key in ["NewGameButton", "ContinueButton", "ControlsButton", "QuitButton"]:
		var b: Button = title.get_node("Panel/VBox/MainView/ButtonRow/%s" % key)
		check(b.visible and panel.encloses(_rect_of(b)), "no art: %s sits inside the panel" % key)
	check(not panel.intersects(_rect_of(title.get_node("Tagline"))), "no art: the menu clears the tagline")

	# Every view still works, and the signals still fire.
	var fired := [0]
	title.new_game_confirmed.connect(func(): fired[0] += 1)
	title._on_new_game_pressed()
	check_eq(fired[0], 1, "no art: New Game (no save) starts straight away")
	title._on_controls_pressed()
	await physics_frames(3)
	check_eq(title._view, TitleScreen.View.CONTROLS, "no art: Controls opens")
	title._on_controls_back()
	await physics_frames(2)
	check(title.get_node("Panel/VBox/TitleLabel").visible, "no art: the text title returns with the main view")
	await _free_title(pair)

	# One art file present and one missing is fine too.
	var only_backdrop := func(t: TitleScreen) -> void:
		t.logo_path = "res://assets/ui/pixel/_no_such_logo.png"
	pair = await _make_title(Vector2i(1280, 720), only_backdrop)
	check(pair[1].get_node("Backdrop").visible and not pair[1].get_node("Logo").visible, "backdrop without a logo works")
	check(pair[1].get_node("Panel/VBox/TitleLabel").visible, "backdrop without a logo: the text title shows")
	await _free_title(pair)
