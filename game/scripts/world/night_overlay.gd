extends CanvasLayer
## Revamp (C24) night-look screen treatment, instanced by LevelDirector when
## `res://scenes/world/night_overlay.tscn` exists: a soft vignette, very
## subtle film grain and scanlines, and — once Adam's lockdown is on
## (`Session` story flag `awakening_done`) — a faint, slow alarm-red pulse
## around the screen edges.
##
## Sits on its own CanvasLayer BELOW every UI layer (HUD is 15, subtitles
## 18, dialogs 20+), so it never covers or tints UI; it only shades the
## world under it. It never takes mouse input (the Screen rect ignores the
## mouse, so aiming and clicks pass straight through).
##
## Reduced motion (Settings, live): no grain and no scanlines, and the
## lockdown edge glow is held steady instead of pulsing. Even at full
## motion the pulse is a slow sine (well under one cycle a second) that
## never flashes, and it never tints the middle of the screen.
##
## The lockdown edge fades in over a moment when the flag flips live, and
## is simply present when a level loads or rebuilds already in lockdown. No
## `class_name` (world-visual import-cache rule).

const LAYER := 5
const ALARM := Color("#FF3B4E")
const VIGNETTE := Color("#03040A")
const VIGNETTE_STRENGTH := 0.45
const GRAIN_STRENGTH := 0.035
const GRAIN_FPS := 12.0
const SCANLINE_STRENGTH := 0.05
const ALARM_PULSE_HZ := 0.3
const ALARM_MIN := 0.05
const ALARM_MAX := 0.12
const ALARM_FADE_TIME := 1.5

const SHADER_CODE := """
shader_type canvas_item;
render_mode unshaded;

uniform vec2 screen_size = vec2(1280.0, 720.0);
uniform vec3 vignette_color : source_color = vec3(0.012, 0.016, 0.04);
uniform float vignette_strength = 0.45;
uniform float grain_strength = 0.035;
uniform float grain_seed = 0.0;
uniform float scanline_strength = 0.05;
uniform vec3 alarm_color : source_color = vec3(1.0, 0.231, 0.306);
uniform float alarm_strength = 0.0;

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	vec2 uv = UV;
	vec2 c = (uv - 0.5) * 2.0;
	float d = length(c * vec2(1.0, 0.92));
	float vig = smoothstep(0.78, 1.45, d) * vignette_strength;
	float scan = step(mod(uv.y * screen_size.y, 3.0), 1.0) * scanline_strength;
	float dark_a = 1.0 - (1.0 - vig) * (1.0 - scan);
	float aspect = screen_size.x / max(screen_size.y, 1.0);
	float edge = min(min(uv.x, 1.0 - uv.x) * aspect, min(uv.y, 1.0 - uv.y));
	float alarm_a = (1.0 - smoothstep(0.0, 0.12, edge)) * alarm_strength;
	float n = hash12(floor(uv * screen_size) + grain_seed * 37.0) - 0.5;
	float grain_a = abs(n) * 2.0 * grain_strength;
	vec3 grain_c = n > 0.0 ? vec3(1.0) : vec3(0.0);
	// One blended layer: darken (vignette + scanline), then the alarm edge
	// over it, then grain on top — composited as premultiplied colour.
	vec3 pm = vignette_color * dark_a;
	float a = dark_a;
	pm = alarm_color * alarm_a + pm * (1.0 - alarm_a);
	a = alarm_a + a * (1.0 - alarm_a);
	pm = grain_c * grain_a + pm * (1.0 - grain_a);
	a = grain_a + a * (1.0 - grain_a);
	COLOR = a > 0.0001 ? vec4(pm / a, a) : vec4(0.0);
}
"""

var _mat: ShaderMaterial
var _reduced_motion: bool = false
var _t: float = 0.0
## 0..1 — how far the lockdown edge glow has faded in.
var _alarm: float = 0.0
var _grain_clock: float = 0.0

@onready var _screen: ColorRect = $Screen


func _ready() -> void:
	layer = LAYER
	_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = SHADER_CODE
	_mat = ShaderMaterial.new()
	_mat.shader = shader
	_mat.set_shader_parameter("vignette_color", VIGNETTE)
	_mat.set_shader_parameter("vignette_strength", VIGNETTE_STRENGTH)
	_mat.set_shader_parameter("alarm_color", ALARM)
	_screen.material = _mat
	_screen.resized.connect(_on_resized)
	_on_resized()
	var settings := get_node_or_null("/root/Settings")
	if settings:
		settings.changed.connect(_on_settings_changed)
	_on_settings_changed()
	# A level that loads (or rebuilds) already in lockdown shows it at once.
	_alarm = 1.0 if _lockdown_active() else 0.0
	_update_alarm()


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_on_settings_changed):
		settings.changed.disconnect(_on_settings_changed)


func _process(delta: float) -> void:
	_t += delta
	var target := 1.0 if _lockdown_active() else 0.0
	_alarm = move_toward(_alarm, target, delta / ALARM_FADE_TIME)
	_update_alarm()
	if not _reduced_motion:
		_grain_clock += delta
		if _grain_clock >= 1.0 / GRAIN_FPS:
			_grain_clock = 0.0
			_mat.set_shader_parameter("grain_seed", fmod(_t * 7.31, 97.0))


func _lockdown_active() -> bool:
	return Session != null and Session.get_story("awakening_done") == true


func _update_alarm() -> void:
	var pulse := 0.5
	if not _reduced_motion:
		pulse = 0.5 + 0.5 * sin(_t * TAU * ALARM_PULSE_HZ)
	_mat.set_shader_parameter("alarm_strength", _alarm * lerpf(ALARM_MIN, ALARM_MAX, pulse))


func _on_settings_changed() -> void:
	var settings := get_node_or_null("/root/Settings")
	_reduced_motion = settings != null and settings.get_reduced_motion()
	_mat.set_shader_parameter("grain_strength", 0.0 if _reduced_motion else GRAIN_STRENGTH)
	_mat.set_shader_parameter("scanline_strength", 0.0 if _reduced_motion else SCANLINE_STRENGTH)


func _on_resized() -> void:
	_mat.set_shader_parameter("screen_size", _screen.size if _screen.size.x > 0.0 else Vector2(1280.0, 720.0))
