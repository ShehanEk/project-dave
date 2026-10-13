extends Node2D
## Rain and neon glow for the corporate cyberpunk night (C58), instanced by
## LevelDirector when `res://scenes/world/atmosphere.tscn` exists.
##
## - Far rain: a world-space rect just in front of the campus backdrop (z -55)
##   and behind the play plane, thin, dim and slower, sliding at PARALLAX_FAR.
## - Near rain: on the Screen CanvasLayer (above the foreground row, below the
##   night overlay and the HUD), sparser, longer streaks that slide a little
##   faster than the camera and pick up the light behind them (a streak in
##   front of a lamp or a sign is brighter and takes its colour).
## - Splashes: small rings and droplets where rain meets the top of a solid
##   (a ray down the screen against the world layer), drawn in the world.
## - Glow: a screen pass on the same layer that adds a soft halo around the
##   scenery's neon only: teal-cyan and warm amber (C58) and near-white light.
##   It reads the screen's blurred mip levels and keys each one by hue and
##   brightness, so Dave's burnt-orange jacket, the night sky and the enemies'
##   own trim colours (lime, magenta, electric blue: they glow by their own
##   masks, C36) are left alone. The HUD sits on higher layers and is untouched.
##
## Rain never falls inside an `indoors` area (AreaRoot, the depot): the shaders
## get those spans in world x and fade the rain out across a soft edge there.
## Reduced motion (Settings, live) turns the rain and splashes off; the glow is
## static and stays. No `class_name` (world-visual import-cache rule).

## Above the foreground row (3), below the night overlay (5) and the HUD (15).
const LAYER := 4
## Just in front of the campus backdrop (-60), behind scenery (-10) and blocks.
const FAR_Z := -55
## Above blocks and props, so a splash on a ledge is never hidden by it.
const SPLASH_Z := 2
const WORLD_MASK := 1
## How fast each rain layer slides compared with the camera (1 = the world).
const PARALLAX_FAR := 0.7
const PARALLAX_NEAR := 1.25
## Splashes per second across a full view, and how long one lasts.
const SPLASH_RATE := 34.0
const SPLASH_LIFE := 0.36
const SPLASH_COLOR := Color(0.78, 0.88, 0.98, 0.75)
## Rain fades over this many world px at the edge of a dry (indoors) span.
const DRY_EDGE := 48.0
const MAX_DRY := 2

## One layer of streaks: world px (cell = column width, drop spacing).
const FAR_RAIN := {
	"cell": Vector2(7.0, 170.0), "drop_len": 26.0, "width_px": 0.9, "speed": 760.0,
	"slant": 0.16, "density": 0.7, "alpha": 0.2, "lit": 0.3, "seed": 3.0,
}
const NEAR_RAIN := {
	"cell": Vector2(16.0, 300.0), "drop_len": 58.0, "width_px": 1.5, "speed": 1250.0,
	"slant": 0.18, "density": 0.36, "alpha": 0.2, "lit": 0.8, "seed": 11.0,
}

const GLOW := {
	"strength": 1.8, "warm_gain": 0.7, "white_gain": 0.45, "min_src": 0.3,
}

const RAIN_SHADER := """
shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform vec2 origin = vec2(0.0);
uniform float world_x0 = 0.0;
uniform vec2 span = vec2(1066.0, 600.0);
uniform vec2 cell = vec2(12.0, 240.0);
uniform float drop_len = 40.0;
uniform float width_px = 1.0;
uniform float speed = 1000.0;
uniform float slant = 0.18;
uniform float density = 0.5;
uniform float alpha = 0.2;
uniform float lit = 0.0;
uniform float seed = 0.0;
uniform float amount = 1.0;
uniform float dry_edge = 48.0;
uniform vec4 dry_a = vec4(1e9, -1e9, 0.0, 0.0);
uniform vec4 dry_b = vec4(1e9, -1e9, 0.0, 0.0);
uniform vec3 tint : source_color = vec3(0.70, 0.80, 0.93);

float h1(float n) {
	return fract(sin(n * 12.9898 + seed * 78.233) * 43758.5453);
}

float dry(float x, vec4 s) {
	return smoothstep(s.x - dry_edge, s.x + dry_edge, x) * (1.0 - smoothstep(s.y - dry_edge, s.y + dry_edge, x));
}

void fragment() {
	vec2 p = origin + UV * span;
	float wx = world_x0 + UV.x * span.x;   // the real world x, for the dry spans
	float wet = (1.0 - dry(wx, dry_a)) * (1.0 - dry(wx, dry_b)) * amount;
	float x = p.x - p.y * slant;
	float col = floor(x / cell.x);
	float r1 = h1(col);
	float r2 = h1(col + 17.0);
	float r3 = h1(col + 41.0);
	float spd = speed * (0.82 + 0.36 * r3);
	float y = p.y - TIME * spd + r2 * cell.y * 7.0;
	float cy = floor(y / cell.y);
	float ly = y - cy * cell.y;
	float r4 = h1(col * 3.1 + cy * 7.7);
	float len = drop_len * (0.7 + 0.6 * r4);
	float on = step(r1, density) * step(0.2, r4);
	float lx = x - (col + 0.5 + (r2 - 0.5) * 0.6) * cell.x;
	float aa = max(fwidth(lx), 0.001);
	float line = 1.0 - smoothstep(width_px * 0.5, width_px * 0.5 + aa, abs(lx));
	float body = smoothstep(0.0, len, ly) * step(ly, len);
	float a = on * line * body * alpha * wet;
	vec3 light = textureLod(screen_tex, SCREEN_UV, 4.0).rgb;
	vec3 c = tint * (1.0 - 0.35 * lit) + light * lit * 1.6;
	COLOR = vec4(c, clamp(a * (1.0 + lit * dot(light, vec3(0.6))), 0.0, 1.0));
}
"""

const GLOW_SHADER := """
shader_type canvas_item;
render_mode blend_add, unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float strength = 1.0;
uniform float warm_gain = 0.7;
uniform float white_gain = 0.45;
uniform float min_src = 0.3;
uniform float lod_bias = 0.0;

float hue(vec3 c) {
	float mx = max(c.r, max(c.g, c.b));
	float mn = min(c.r, min(c.g, c.b));
	float d = mx - mn;
	if (d < 1e-4) return 0.0;
	float h;
	if (mx == c.r) h = mod((c.g - c.b) / d, 6.0);
	else if (mx == c.g) h = (c.b - c.r) / d + 2.0;
	else h = (c.r - c.g) / d + 4.0;
	return h * 60.0;
}

// How much of `e` (light above its surroundings at one blur size) is scenery
// neon: teal-cyan, warm amber or near-white, from a source bright enough.
vec3 neon(vec3 e, vec3 src) {
	float mx = max(e.r, max(e.g, e.b));
	float mn = min(e.r, min(e.g, e.b));
	float sat = (mx - mn) / max(mx, 1e-4);
	float h = hue(e);
	float colourful = smoothstep(0.25, 0.45, sat);
	float cyan = 1.0 - smoothstep(16.0, 30.0, abs(h - 178.0));
	float amber = 1.0 - smoothstep(8.0, 16.0, abs(h - 38.0));
	float g = colourful * max(cyan, amber * warm_gain) + (1.0 - colourful) * white_gain;
	float smx = max(src.r, max(src.g, src.b));
	return e * g * smoothstep(min_src, min_src + 0.2, smx);
}

void fragment() {
	vec3 b1 = textureLod(screen_tex, SCREEN_UV, 1.0 + lod_bias).rgb;
	vec3 b2 = textureLod(screen_tex, SCREEN_UV, 2.0 + lod_bias).rgb;
	vec3 b3 = textureLod(screen_tex, SCREEN_UV, 3.0 + lod_bias).rgb;
	vec3 b4 = textureLod(screen_tex, SCREEN_UV, 4.0 + lod_bias).rgb;
	vec3 b5 = textureLod(screen_tex, SCREEN_UV, 5.0 + lod_bias).rgb;
	vec3 b6 = textureLod(screen_tex, SCREEN_UV, 6.0 + lod_bias).rgb;
	// Light above its surroundings at four sizes (a difference of blurs): a
	// thin neon line keeps a wide halo, a big evenly lit area only glows at
	// its edges, and dark areas add nothing.
	vec3 g = neon(max(b1 - b3, vec3(0.0)), b1) * 0.55;
	g += neon(max(b2 - b4, vec3(0.0)), b2) * 0.5;
	g += neon(max(b3 - b5, vec3(0.0)), b3) * 0.42;
	g += neon(max(b4 - b6, vec3(0.0)), b4) * 0.34;
	COLOR = vec4(g * strength, 1.0);
}
"""

var far_rain: ColorRect
var near_rain: ColorRect
var glow: ColorRect
var splashes: Node2D
var screen: CanvasLayer

var _far_mat: ShaderMaterial
var _near_mat: ShaderMaterial
var _glow_mat: ShaderMaterial
var _reduced_motion := false
## Dry spans in world x (Vector2(x0, x1)), from the level's indoors areas.
var _dry: Array[Vector2] = []
## Live splashes: [x, y, age, seed].
var _splash: Array = []
var _splash_debt := 0.0
var _dry_clock := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # the rain keeps falling behind the pause menu
	_rng.seed = 5801
	far_rain = ColorRect.new()
	far_rain.name = "FarRain"
	far_rain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	far_rain.z_index = FAR_Z
	_far_mat = _rain_material(FAR_RAIN)
	far_rain.material = _far_mat
	add_child(far_rain)

	splashes = Node2D.new()
	splashes.name = "Splashes"
	splashes.z_index = SPLASH_Z
	splashes.draw.connect(_draw_splashes)
	add_child(splashes)

	screen = CanvasLayer.new()
	screen.name = "Screen"
	screen.layer = LAYER
	add_child(screen)
	near_rain = _full_rect("NearRain")
	_near_mat = _rain_material(NEAR_RAIN)
	near_rain.material = _near_mat
	screen.add_child(near_rain)
	glow = _full_rect("Glow")
	var gs := Shader.new()
	gs.code = GLOW_SHADER
	_glow_mat = ShaderMaterial.new()
	_glow_mat.shader = gs
	for k in GLOW:
		_glow_mat.set_shader_parameter(k, GLOW[k])
	glow.material = _glow_mat
	screen.add_child(glow)   # after the near rain: the glow is drawn last

	refresh_dry_spans()
	var settings := get_node_or_null("/root/Settings")
	if settings:
		settings.changed.connect(_on_settings_changed)
	_on_settings_changed()


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_on_settings_changed):
		settings.changed.disconnect(_on_settings_changed)


## Re-reads the indoors areas (call after the level builds or rebuilds its areas).
## Each indoors area is dry over its `dry_span()` (an area can start outdoors,
## AreaRoot.wet_until_x); spans that touch are merged into one, so a run of
## indoors areas (all of Level 2 after its sky bridge) fits the shaders' two.
func refresh_dry_spans() -> void:
	_dry.clear()
	var lvl := get_parent()
	var raw: Array[Vector2] = []
	if lvl != null and "areas" in lvl:
		for a in lvl.get("areas"):
			if is_instance_valid(a) and a is AreaRoot and (a as AreaRoot).indoors:
				var ar := a as AreaRoot
				var local := ar.dry_span()
				if local.y > local.x:
					raw.append(Vector2(ar.global_position.x + local.x, ar.global_position.x + local.y))
	raw.sort_custom(func(p: Vector2, q: Vector2) -> bool: return p.x < q.x)
	for s in raw:
		if not _dry.is_empty() and s.x <= _dry[-1].y + 0.5:
			var last: Vector2 = _dry[-1]
			last.y = maxf(last.y, s.y)
			_dry[-1] = last
		else:
			_dry.append(s)
	var spans: Array[Vector4] = [Vector4(1e9, -1e9, 0, 0), Vector4(1e9, -1e9, 0, 0)]
	for i in mini(_dry.size(), MAX_DRY):
		spans[i] = Vector4(_dry[i].x, _dry[i].y, 0, 0)
	for m in [_far_mat, _near_mat]:
		m.set_shader_parameter("dry_a", spans[0])
		m.set_shader_parameter("dry_b", spans[1])


## True when rain falls at this world x (outdoors, motion allowed).
func is_wet(x: float) -> bool:
	if _reduced_motion:
		return false
	for s in _dry:
		if x >= s.x - DRY_EDGE and x <= s.y + DRY_EDGE:
			return false
	return true


func _process(delta: float) -> void:
	_dry_clock += delta
	if _dry_clock >= 0.5:   # areas can be rebuilt (a restart): keep the spans current
		_dry_clock = 0.0
		refresh_dry_spans()
	var view := _view_rect()
	far_rain.position = view.position
	far_rain.size = view.size
	_far_mat.set_shader_parameter("origin", view.position * PARALLAX_FAR)
	_far_mat.set_shader_parameter("span", view.size)
	_far_mat.set_shader_parameter("world_x0", view.position.x)
	_near_mat.set_shader_parameter("world_x0", view.position.x)
	_near_mat.set_shader_parameter("origin", view.position * PARALLAX_NEAR)
	_near_mat.set_shader_parameter("span", view.size)
	var px_h := get_viewport().get_visible_rect().size.y
	var win := get_window()
	if win != null and win.content_scale_mode != Window.CONTENT_SCALE_MODE_DISABLED:
		px_h = float(win.size.y)
	_glow_mat.set_shader_parameter("lod_bias", maxf(log(maxf(px_h, 1.0) / 720.0) / log(2.0), 0.0))
	_age_splashes(delta)
	splashes.queue_redraw()


func _physics_process(delta: float) -> void:
	if _reduced_motion:
		return
	var view := _view_rect()
	_splash_debt += SPLASH_RATE * delta * view.size.x / 1066.0
	var space := get_world_2d().direct_space_state
	while _splash_debt >= 1.0:
		_splash_debt -= 1.0
		var x := view.position.x + _rng.randf() * view.size.x
		if not is_wet(x):
			continue
		var hit := space.intersect_ray(PhysicsRayQueryParameters2D.create(
				Vector2(x, view.position.y - 40.0), Vector2(x, view.end.y + 40.0), WORLD_MASK))
		if hit.is_empty() or (hit.normal as Vector2).y > -0.7:
			continue
		_splash.append([x, (hit.position as Vector2).y, 0.0, _rng.randf()])


## The camera's view in world space (the whole viewport when there is no camera).
func _view_rect() -> Rect2:
	var vp := get_viewport()
	var size := vp.get_visible_rect().size
	var cam := vp.get_camera_2d()
	if cam == null:
		return Rect2(Vector2.ZERO, size)
	var world := size / cam.zoom
	return Rect2(cam.get_screen_center_position() - world * 0.5, world)


func _age_splashes(delta: float) -> void:
	var keep := []
	for s in _splash:
		s[2] += delta
		if s[2] < SPLASH_LIFE:
			keep.append(s)
	_splash = keep


func _draw_splashes() -> void:
	for s in _splash:
		var t: float = s[2] / SPLASH_LIFE
		var x: float = s[0]
		var y: float = s[1]
		var c := Color(SPLASH_COLOR, SPLASH_COLOR.a * (1.0 - t))
		# A small crown of three strokes thrown up from the impact (first half).
		if t < 0.55:
			var k := t / 0.55
			var reach: float = (5.0 + 3.0 * s[3]) * sin(k * PI)
			for ang in [-1.05, -1.57, -2.09]:
				var d := Vector2(cos(ang), sin(ang))
				var p0: Vector2 = Vector2(x, y - 0.5) + d * reach * 0.35
				splashes.draw_line(p0, p0 + d * reach * 0.65, c, 1.2, true)
		# A flat ring spreading over the surface.
		var r: float = lerpf(2.0, 9.0 + 4.0 * s[3], t)
		var ring := PackedVector2Array()
		for i in 15:
			var u := TAU * float(i) / 14.0
			ring.append(Vector2(x + cos(u) * r, y - 0.5 + sin(u) * r * 0.22))
		splashes.draw_polyline(ring, Color(c, c.a * 0.8), 1.1, true)
		# Two droplets flying up and out.
		for side in [-1.0, 1.0]:
			var dx: float = side * lerpf(1.5, 7.0 + 3.0 * s[3], t)
			var dy: float = -(12.0 + 6.0 * s[3]) * 4.0 * t * (1.0 - t)
			splashes.draw_circle(Vector2(x + dx, y - 1.0 + dy), 1.1, c)


func _rain_material(cfg: Dictionary) -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = RAIN_SHADER
	var m := ShaderMaterial.new()
	m.shader = sh
	for k in cfg:
		m.set_shader_parameter(k, cfg[k])
	m.set_shader_parameter("dry_edge", DRY_EDGE)
	return m


func _full_rect(rect_name: String) -> ColorRect:
	var r := ColorRect.new()
	r.name = rect_name
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.color = Color(1, 1, 1, 1)
	return r


func _on_settings_changed() -> void:
	var settings := get_node_or_null("/root/Settings")
	_reduced_motion = settings != null and settings.get_reduced_motion()
	var amount := 0.0 if _reduced_motion else 1.0
	_far_mat.set_shader_parameter("amount", amount)
	_near_mat.set_shader_parameter("amount", amount)
	if _reduced_motion:
		_splash.clear()
