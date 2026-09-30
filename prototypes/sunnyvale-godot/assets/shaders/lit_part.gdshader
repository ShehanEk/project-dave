shader_type canvas_item;
// Lit cutout part (C35). The sprite texture is the flat
// painted albedo; `normal_atlas` and `spec_atlas` share its layout. The
// world's 2D lights shade the part smoothly through its normals, from the
// side each light is on; `ambient` is how bright a part is with no light on
// it (the night). spec_atlas: R = specular strength, G = gloss, B = emissive
// mask. Normals use Godot's 2D convention (G = up, B = z), and Godot turns
// them with the part, so a rotated or mirrored limb stays correctly lit.

uniform sampler2D normal_atlas : filter_linear;
uniform sampler2D spec_atlas : filter_linear;
uniform vec3 ambient : source_color = vec3(0.17, 0.19, 0.25);
// 1 = normal-mapped; 0 = the same lights with flat normals (A/B toggle).
uniform float normals_on = 1.0;
// Soft wrap so a light just behind the edge still grazes it.
uniform float wrap = 0.2;
uniform float spec_gain = 1.0;
// Emissive areas glow in their own painted colour (tint 0) or in
// `emissive_color` (tint 1, the baton's amber-then-red tell).
uniform vec3 emissive_color : source_color = vec3(1.0);
uniform float emissive_tint = 0.0;
uniform float emissive_energy = 0.0;
// Brief brightening when the part is hit.
uniform float flash = 0.0;

varying vec4 albedo_v;
varying vec4 spec_v;

void fragment() {
	vec4 albedo = COLOR;
	vec4 sp = texture(spec_atlas, UV);
	vec3 n = texture(normal_atlas, UV).rgb;
	NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), n, normals_on);
	albedo_v = albedo;
	spec_v = sp;
	vec3 emissive = mix(albedo.rgb, emissive_color, emissive_tint) * emissive_energy * sp.b;
	COLOR = vec4(albedo.rgb * (ambient + vec3(flash)) + emissive, albedo.a);
}

void light() {
	float ndl = dot(NORMAL, LIGHT_DIRECTION);
	float diff = clamp((ndl + wrap) / (1.0 + wrap), 0.0, 1.0);
	vec3 lc = LIGHT_COLOR.rgb * LIGHT_ENERGY;
	vec3 h = normalize(LIGHT_DIRECTION + vec3(0.0, 0.0, 1.0));
	float shin = exp2(spec_v.g * 10.0 + 1.0);
	float s = pow(max(dot(NORMAL, h), 0.0), shin) * spec_v.r * (shin + 8.0) / 25.0 * spec_gain;
	s *= step(0.0, ndl);
	LIGHT = vec4((albedo_v.rgb * diff + vec3(s)) * lc, LIGHT_COLOR.a);
}
