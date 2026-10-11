extends TestCase
## Pixel UI (Sheets 11 and 12: concept-art/ui-sunnyvale/ui-frames-v2.webp and
## ui-icons-v1.webp, cut by tools/art/import_pixel_ui.py into assets/ui/pixel/):
##   1. the shared theme (assets/ui/c11_theme.tres) is nine-slice StyleBoxTexture
##      frames, nearest filtered, at 3 px per UI pixel, its text colours kept;
##   2. the HUD draws the pixel health segments (a lost one flashes first), the
##      weapon slot with the pixel Scrapjack (and it fits the top bar), the
##      chip and keycard icons, and the lit/dark readiness light;
##   3. readiness and health differ in luminance, not only hue;
##   4. key caps exist for the bindings (letters, Space, arrows, mice) and a key
##      the font cannot letter falls back to text; tutorial prompts and the
##      Controls table use them at whole-pixel scales;
##   5. the text-size setting still scales the HUD labels, the two pixel-font
##      labels by a whole number of px per font pixel;
##   6. toasts carry their icon; the interact prompt wears the prompt tag;
##   7. with the PNGs missing everything falls back (code-drawn icons, text
##      key labels, the UI font, the flat toast plate).

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")
const PixelFont := preload("res://scripts/world/pixel_font.gd")
const InputIconMap := preload("res://scripts/ui/input_icon_map.gd")
const THEME := "res://assets/ui/c11_theme.tres"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const PROMPT_SCENE := "res://scenes/objects/tutorial_prompt.tscn"
const CONTROLS_SCENE := "res://scenes/ui/controls_panel.tscn"
const MISSING_DIR := "res://__no_pixel_ui_here__/"


func run() -> void:
	Session.new_run()
	_theme()
	await _hud_pieces()
	_luminance()
	await _ready_light_follows_weapon()
	_key_caps()
	await _prompt_and_controls_use_caps()
	await _text_size()
	await _toasts_and_prompt_tag()
	await _menus()
	await _fallback()


# --- helpers ------------------------------------------------------------------------

func _key(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	return e


func _mouse(button: int) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = button
	return e


## Relative luminance (sRGB) of a colour.
func _lum(c: Color) -> float:
	var f := func(v: float) -> float: return v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4)
	return 0.2126 * f.call(c.r) + 0.7152 * f.call(c.g) + 0.0722 * f.call(c.b)


## The colour at the centre of a piece.
func _centre(piece: String) -> Color:
	var img := PixelUi.image(piece)
	return img.get_pixel(img.get_width() / 2, img.get_height() / 2) if img else Color.TRANSPARENT


func _image_of(tex: Texture2D) -> Image:
	var t: Texture2D = (tex as CanvasTexture).diffuse_texture if tex is CanvasTexture else tex
	return t.get_image() if t else null


# --- 1. theme -------------------------------------------------------------------------

func _theme() -> void:
	var theme: Theme = load(THEME)
	check(theme != null, "the shared theme loads")
	if theme == null:
		return
	var frames := {
		["Panel", "panel"]: "panel", ["PanelContainer", "panel"]: "panel",
		["Button", "normal"]: "button_normal", ["Button", "hover"]: "button_hover",
		["Button", "pressed"]: "button_pressed", ["Button", "disabled"]: "button_disabled",
		["Button", "focus"]: "focus", ["OptionButton", "normal"]: "button_normal",
		["HSlider", "slider"]: "slider_track", ["HSlider", "grabber_area"]: "slider_fill",
		["HSeparator", "separator"]: "divider", ["CheckButton", "focus"]: "focus",
	}
	for key in frames:
		var sb := theme.get_stylebox(key[1], key[0])
		var where := "%s/%s" % [key[0], key[1]]
		check(sb is StyleBoxTexture, "%s is a StyleBoxTexture (got %s)" % [where, sb.get_class() if sb else "null"])
		if not sb is StyleBoxTexture:
			continue
		var st := sb as StyleBoxTexture
		check(PixelUi.is_crisp(st.texture), "%s draws its texture with nearest filtering" % where)
		var native := PixelUi.image(frames[key])
		var tex_size: Vector2 = st.texture.get_size() if st.texture else Vector2.ZERO
		if native:
			check_eq(tex_size, Vector2(native.get_size()) * 3.0, "%s is the %s piece at 3 px per UI pixel" % [where, frames[key]])
		if frames[key] != "divider":
			check(st.texture_margin_left > 0.0 and st.texture_margin_top > 0.0 and int(st.texture_margin_left) % 3 == 0,
					"%s nine-slices on whole UI pixels (margin %.0f)" % [where, st.texture_margin_left])
			check(st.axis_stretch_horizontal == StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH,
					"%s stretches its plain edges" % where)
	for icon in [["CheckButton", "checked"], ["CheckButton", "unchecked"], ["HSlider", "grabber"], ["OptionButton", "arrow"]]:
		var tex := theme.get_icon(icon[1], icon[0])
		check(tex != null and PixelUi.is_crisp(tex), "%s/%s is a nearest-filtered pixel icon" % icon)
	var normal := theme.get_stylebox("normal", "CheckButton")
	check(normal is StyleBoxEmpty, "a CheckButton draws no button frame behind its checkbox")
	check_eq(theme.get_color("font_color", "Label"), Color(0.847, 0.886, 0.925, 1), "label text keeps the theme's pale colour")
	check_eq(theme.get_color("font_color", "Button"), Color(0.847, 0.886, 0.925, 1), "button text keeps the theme's pale colour")
	var fill := _centre("panel")
	check(fill.a == 1.0 and _lum(fill) < 0.02, "the panel fill is opaque dark navy (contrast at least the old 96% plate)")
	var text_l := _lum(Color(0.847, 0.886, 0.925))
	check((text_l + 0.05) / (_lum(fill) + 0.05) >= 7.0, "pale text on the panel fill is at least 7:1")


# --- 2. HUD pieces ----------------------------------------------------------------------

func _hud_pieces() -> void:
	Session.new_run()
	var hud: Hud = await spawn(HUD_SCENE)
	# Six shown; a seventh (Scrap Plating, C53) waits hidden until the upgrade is fitted.
	var segs: Array = hud.get_node("TopBar/HealthRow").get_children().filter(func(c): return c.visible)
	check_eq(segs.size(), 6, "six health segments")
	check_eq(hud.get_node("TopBar/HealthRow").get_child_count(), 7, "one spare segment for Scrap Plating")
	for s in segs:
		check(s.has_art() and s.piece == "health_full", "%s draws the pixel full segment at full health" % s.name)
		check_eq(s.custom_minimum_size, Vector2(27, 36), "%s is 9 x 12 UI px at 3 px each" % s.name)
	Session.apply_damage(2)
	await physics_frames(1)
	check(segs[3].piece == "health_full" and segs[4].piece == "health_flash" and segs[5].piece == "health_flash",
			"the two segments just lost flash pale")
	await seconds(Hud.HIT_FLASH_TIME + 0.1)
	check(segs[4].piece == "health_empty" and segs[5].piece == "health_empty", "...then show the empty segment")
	Session.heal_full()
	await physics_frames(1)
	check(segs[5].piece == "health_full", "healing fills them again with no flash")

	var weapon: Control = hud.get_node("TopBar/WeaponBox/WeaponIcon")
	check(weapon.has_art(), "the weapon slot draws the pixel slot and Scrapjack")
	var gun := PixelUi.texture("weapon_scrapjack")
	check(gun != null and gun.get_size().x >= 20.0 and gun.get_size().x <= 28.0,
			"the Scrapjack icon is about 24 UI px wide (got %s)" % str(gun.get_size() if gun else Vector2.ZERO))
	check_eq(weapon.custom_minimum_size, weapon.slot_size() * 3.0, "the slot is its UI pixels at 3 px each")
	var box: Control = hud.get_node("TopBar/WeaponBox")
	check(weapon.size.x <= box.size.x and weapon.size.y <= hud.get_node("TopBar").size.y,
			"the slot fits inside the WeaponBox and the top bar")
	var top_bar: Control = hud.get_node("TopBar")
	Session.take_keycard("L01-KC01", "L01-KC01-P")
	await physics_frames(2)
	check(top_bar.get_global_rect().end.x < 1280.0 - 460.0,
			"the whole top bar (keycard shown) ends left of the objective's box (ends at %.0f)" % top_bar.get_global_rect().end.x)
	for path in ["TopBar/ChipIcon", "TopBar/KeycardIcon", "TopBar/WeaponBox/QuickcyclePip", "TopBar/WeaponBox/ReadyDot"]:
		check(hud.get_node(path).has_art(), "%s draws its pixel piece" % path)
	for piece in ["chip", "keycard", "weapon_scrapjack", "health_full", "ready_lit"]:
		check(PixelUi.is_crisp(PixelUi.texture(piece)), "%s is nearest filtered" % piece)
	check(PixelUi.uses_font(hud._wallet_label), "the wallet count is set in the pixel font")
	check(PixelUi.uses_font(hud._weapon_tag_label), "the weapon tag is set in the pixel font")
	check(not PixelUi.uses_font(hud._objective_label), "the objective sentence stays in the UI font")
	check(hud._objective_banner.visible and hud._objective_banner.size.x > 0.0, "the objective sits on the banner strip")
	check(hud._objective_banner.size.x < hud._objective_label.size.x,
			"the banner hugs the objective's text, not the label's whole width")
	hud.queue_free()
	await physics_frames(2)


# --- 3. luminance, not only hue ----------------------------------------------------------

func _luminance() -> void:
	var lit := _lum(_centre("ready_lit"))
	var dark := _lum(_centre("ready_dark"))
	check(lit - dark > 0.4, "the ready light is far brighter than the not-ready light (L %.2f vs %.2f)" % [lit, dark])
	check((lit + 0.05) / (dark + 0.05) > 5.0, "...a contrast ratio over 5:1, readable in greyscale")
	var full := _lum(_centre("health_full"))
	var empty := _lum(_centre("health_empty"))
	check((full + 0.05) / (empty + 0.05) > 3.0, "a full health segment is much lighter than an empty one (L %.2f vs %.2f)" % [full, empty])
	var flash := _lum(_centre("health_flash"))
	check(flash > full, "the hit flash is the lightest segment")
	var pip := _lum(_centre("pip_lit"))
	check(pip - _lum(_centre("pip_dark")) > 0.3, "the Quickcycle pip's lit piece is far brighter than its dark one")


func _ready_light_follows_weapon() -> void:
	var hud: Hud = await spawn(HUD_SCENE)
	var script := GDScript.new()
	script.source_code = "extends Node\nvar ok := true\nfunc is_ready() -> bool:\n\treturn ok\n"
	script.reload()
	var stub := Node.new()
	stub.set_script(script)
	add_child(stub)
	hud._weapon = stub
	await physics_frames(2)
	check(hud.is_fire_ready_shown(), "a ready weapon lights the readiness light")
	stub.ok = false
	await physics_frames(2)
	check(not hud.is_fire_ready_shown() and hud._weapon_ready.piece == "ready_dark", "a cooling weapon darkens it")
	check_eq(hud._weapon_ready.fallback_color, Hud.COOLDOWN_COLOR, "...with the dark COOLDOWN_COLOR as its no-art colour")
	hud._weapon = null
	stub.queue_free()
	hud.queue_free()
	await physics_frames(2)


# --- 4. key caps ------------------------------------------------------------------------------

func _key_caps() -> void:
	var a := InputIconMap.icon_for_event(_key(KEY_A))
	check(a != null and PixelUi.is_crisp(a), "A has a nearest-filtered key cap")
	for code in [KEY_D, KEY_W, KEY_S, KEY_E, KEY_F, KEY_Q, KEY_R, KEY_1, KEY_SPACE, KEY_LEFT, KEY_RIGHT,
			KEY_UP, KEY_DOWN, KEY_ESCAPE, KEY_TAB, KEY_ENTER, KEY_F1]:
		check(InputIconMap.icon_for_event(_key(code)) != null, "key %s has a key cap" % InputIconMap.key_label(code))
	var space := InputIconMap.icon_for_event(_key(KEY_SPACE))
	var wide := PixelUi.image("key_wide")
	if a and space and wide:
		check_eq(a.get_size(), Vector2(11, 14), "a letter cap is 11 x 14 UI px")
		check(space.get_size().x >= float(wide.get_width()) and space.get_size().y == a.get_size().y,
				"Space is the wide cap (at least the sheet's %d px), as tall as a letter" % wide.get_width())
	check(InputIconMap.icon_for_event(_key(KEY_A)) == a, "caps are built once and shared")
	check(InputIconMap.icon_for_event(_key(KEY_D)) != a, "D and A are different caps")
	var img := _image_of(a)
	var ink := 0
	if img:
		for y in img.get_height():
			for x in img.get_width():
				if img.get_pixel(x, y).is_equal_approx(PixelUi.INK) and x > 1 and x < img.get_width() - 2 and y > 1 and y < 9:
					ink += 1
	check(ink >= 10, "the A cap carries its letter in dark ink on the face (%d ink pixels)" % ink)
	var left_cap := InputIconMap.icon_for_event(_key(KEY_LEFT))
	check(left_cap != null and left_cap.get_size().x > a.get_size().x, "an arrow cap holds the 7-px arrow glyph")
	check(InputIconMap.icon_for_event(_mouse(MOUSE_BUTTON_LEFT)) == PixelUi.texture("mouse_left"), "the left mouse button is the mouse with the left button lit")
	check(InputIconMap.icon_for_event(_mouse(MOUSE_BUTTON_RIGHT)) == PixelUi.texture("mouse_right"), "the right mouse button is the mouse with the right button lit")
	check(InputIconMap.icon_for_event(_mouse(MOUSE_BUTTON_MIDDLE)) == null, "the middle button has no icon (text instead)")
	check(InputIconMap.static_icon("mouse_aim") != null, "Aim has the pixel mouse icon")
	check(InputIconMap.static_icon("mouse_move.svg") == InputIconMap.static_icon("mouse_aim"), "the old Kenney name maps to the same icon")
	check(PixelUi.key_cap("SEMICOLON") == null, "a label longer than a cap holds has no cap")
	check(PixelUi.key_cap(";") == null, "a label the pixel font cannot letter has no cap")
	var original := InputMap.action_get_events(&"interact")
	InputMap.action_erase_events(&"interact")
	InputMap.action_add_event(&"interact", _key(KEY_SEMICOLON))
	var tokens := InputIconMap.tokens_for_action(&"interact")
	check(tokens.size() == 1 and tokens[0].has("text") and tokens[0]["text"] == InputIconMap.key_label(KEY_SEMICOLON),
			"a key with no cap is a text token naming the key")
	InputMap.action_erase_events(&"interact")
	for e in original:
		InputMap.action_add_event(&"interact", e)


func _prompt_and_controls_use_caps() -> void:
	var size_before: String = Settings.get_text_size()
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	var prompt: TutorialPrompt = load(PROMPT_SCENE).instantiate()
	prompt.text = "Move"
	prompt.icon_actions = [&"move_left", &"move_right"]
	add_child(prompt)
	await physics_frames(2)
	var icons: Array = prompt.get_node("Panel/Row/Icons").get_children()
	var want := [PixelUi.key_cap("A"), PixelUi.key_cap("D"), PixelUi.key_cap("←"), PixelUi.key_cap("→")]
	var got := icons.map(func(n): return n.texture if n is TextureRect else null)
	check(got == want, "Move shows A D ← → as key caps, paired like the Controls table")
	if icons.size() > 0 and icons[0] is TextureRect:
		check_eq(icons[0].custom_minimum_size, icons[0].texture.get_size() * 3.0, "prompt caps draw at 3 world px per UI pixel")
	var panel: PanelContainer = prompt.get_node("Panel")
	var style := panel.get_theme_stylebox("panel")
	check(style is StyleBoxTexture and PixelUi.is_crisp(style.texture), "the prompt panel is the pixel tag frame")
	var text_label: Label = prompt.get_node("Panel/Row/TextLabel")
	check(text_label.get_global_rect().end.x <= panel.get_global_rect().end.x + 0.5, "the prompt's text stays inside its panel")
	check(absf(panel.position.x + panel.size.x * 0.5) <= 1.0, "the prompt panel stays centred on its node")
	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	await physics_frames(2)
	if icons.size() > 0 and icons[0] is TextureRect:
		check_eq(icons[0].custom_minimum_size, icons[0].texture.get_size() * 4.0, "Large text size draws them at a whole 4 px")
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	prompt.queue_free()
	await physics_frames(2)

	var controls: ControlsPanel = await spawn(CONTROLS_SCENE)
	for i in controls._icon_boxes.size():
		for child in controls._icon_boxes[i].get_children():
			check(child is TextureRect and PixelUi.is_crisp(child.texture)
					and child.custom_minimum_size == child.texture.get_size() * 2.0,
					"Controls row %d icons are pixel caps at 2 px per UI pixel" % i)
	check(_lum(ControlsPanel.NAME_COLOR) > 0.6 and _lum(ControlsPanel.TIP_COLOR) > 0.4,
			"the Controls table's text is light on the dark panel")
	controls.queue_free()
	await physics_frames(2)
	Settings.set_text_size(size_before)


# --- 5. text size -----------------------------------------------------------------------------

func _text_size() -> void:
	var size_before: String = Settings.get_text_size()
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	var hud: Hud = await spawn(HUD_SCENE)
	var wallet_normal: int = hud._wallet_label.get_theme_font_size("font_size")
	var tag_normal: int = hud._weapon_tag_label.get_theme_font_size("font_size")
	var obj_normal: int = hud._objective_label.get_theme_font_size("font_size")
	check_eq(PixelUi.font_scale(wallet_normal), 3, "the wallet's pixel font is 3 px per font pixel at Normal")
	check_eq(PixelUi.font_scale(tag_normal), 3, "so is the weapon tag")
	var h_normal: float = hud._wallet_label.get_minimum_size().y
	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	await physics_frames(2)
	check(hud._objective_label.get_theme_font_size("font_size") > obj_normal, "the objective grows at Large")
	check_eq(PixelUi.font_scale(hud._wallet_label.get_theme_font_size("font_size")), 4, "the wallet grows to a whole 4 px per font pixel")
	check_eq(PixelUi.font_scale(hud._weapon_tag_label.get_theme_font_size("font_size")), 4, "so does the weapon tag")
	check(hud._wallet_label.get_minimum_size().y > h_normal, "the wallet label really is taller at Large")
	Settings.set_text_size(size_before)
	hud.queue_free()
	await physics_frames(2)


# --- 6. toasts and the interact prompt -----------------------------------------------------------

func _toasts_and_prompt_tag() -> void:
	var hud: Hud = await spawn(HUD_SCENE)
	var toast: ToastLabel = hud._toast
	check(toast.get_theme_stylebox("normal") is StyleBoxTexture, "the toast sits on the pixel banner strip")
	hud._on_checkpoint_committed("CP01")
	await physics_frames(2)
	check_eq(toast.icon_piece(), "save", "Progress saved carries the save mark")
	var icon: TextureRect = toast.get_node("Icon")
	var f := toast.get_theme_font("font")
	var text_w: float = f.get_string_size(toast.text, HORIZONTAL_ALIGNMENT_LEFT, -1, toast.get_theme_font_size("font_size")).x
	check(icon.position.x + icon.size.x <= (toast.size.x - text_w) * 0.5 + 0.5, "the save mark sits left of the centred text")
	hud._on_save_failed("save_failed", "CP01")
	await physics_frames(2)
	check_eq(toast.icon_piece(), "warning", "a failed save carries the warning triangle")
	var sb := toast.get_theme_stylebox("normal")
	check(sb.content_margin_left >= icon.position.x + icon.size.x, "the long message's text starts right of the icon")
	hud._on_evidence_recorded("EF01")
	await physics_frames(2)
	check_eq(toast.icon_piece(), "evidence", "an evidence file carries the folder")
	hud.queue_free()
	await physics_frames(2)

	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	await physics_frames(1)
	var label: Label = hero.prompt_label
	check(label.get_theme_stylebox("normal") is StyleBoxTexture, "the interact prompt wears the pixel prompt tag")
	check(label.get_node_or_null("Tail") != null, "...with its pointer under it")
	hero.queue_free()
	await physics_frames(2)


# --- menus -------------------------------------------------------------------------------------

func _menus() -> void:
	var swap: SwapConfirm = await spawn("res://scenes/ui/swap_confirm.tscn")
	check(swap.get_node("Panel/VBox/TitleRow/SwapIcon").has_art(), "the swap confirm shows the pixel swap arrows")
	swap.queue_free()
	var pause: PauseMenu = await spawn("res://scenes/ui/pause.tscn")
	check(pause._settings_button.icon != null and PixelUi.is_crisp(pause._settings_button.icon), "the Settings button carries the gear")
	for row in ["SubtitlesRow", "MasterRow", "MusicRow", "SfxRow"]:
		check(pause.get_node("Panel/VBox/SettingsView/%s/Icon" % row).has_art(), "%s has its pixel icon" % row)
	var heights := {}
	for b in pause._main_view.get_children():
		heights[b.get_combined_minimum_size().y] = true
	check_eq(heights.size(), 1, "every pause button is the same height with the gear on one")
	pause.queue_free()
	await physics_frames(2)


# --- 7. fallback without the art ----------------------------------------------------------------

func _fallback() -> void:
	PixelUi.use_dir(MISSING_DIR)
	PixelFont.use_dir(MISSING_DIR)
	check(not PixelUi.has_piece("chip") and PixelUi.font() == null, "setup: the pixel UI art and font are missing")
	var hud: Hud = await spawn(HUD_SCENE)
	var seg: Control = hud.get_node("TopBar/HealthRow/Health0")
	check(not seg.has_art() and seg.fallback_color == Hud.HEALTH_FULL, "a health segment falls back to its flat full colour")
	check(not hud.get_node("TopBar/WeaponBox/WeaponIcon").has_art(), "the weapon icon falls back to its code-drawn gun")
	check(not hud.get_node("TopBar/ChipIcon").has_art(), "the chip icon falls back to its code-drawn chip")
	check(not hud._objective_banner.visible, "no banner without its PNG")
	check(not PixelUi.uses_font(hud._wallet_label) and not hud._wallet_label.has_theme_font_override("font"),
			"the wallet falls back to the UI font")
	check_eq(hud._wallet_label.get_theme_constant("outline_size"), 5, "...with its authored outline back")
	check(not hud._toast.get_theme_stylebox("normal") is StyleBoxTexture, "the toast falls back to its flat plate")
	check(InputIconMap.icon_for_event(_key(KEY_A)) == null, "no key cap without the art")
	var prompt: TutorialPrompt = load(PROMPT_SCENE).instantiate()
	prompt.text = "Jump"
	prompt.icon_actions = [&"jump"]
	add_child(prompt)
	await physics_frames(2)
	var texts: Array = []
	for child in prompt.get_node("Panel/Row/Icons").get_children():
		check(child is Label, "without the art every key is a text token")
		if child is Label:
			texts.append(child.text)
	check(texts.has("[W]"), "...naming the key ([W] among %s)" % str(texts))
	check(prompt.get_node("Panel").get_theme_stylebox("panel") is StyleBoxFlat, "the prompt keeps its flat panel")
	prompt.queue_free()
	hud.queue_free()
	await physics_frames(2)
	PixelFont.use_dir()
	PixelUi.use_dir()
	check(PixelUi.has_piece("chip") and PixelUi.font() != null, "cleanup: the real art is back")
