extends Node
## Lights Dave like the enemies in the lit-cutout test (C35) without editing
## any hero file: at runtime it gives the hero's Body and Arm sprites the lit
## part shader, swaps in the auto-generated normal map for whichever Rook
## frame is showing (tools/spike/make_normal_maps.py), and flashes a short,
## smooth muzzle light every time the Scrapjack fires. No class_name.

const LitShader := preload("res://spike/lit_cutout/shaders/lit_part.gdshader")
const DISC := preload("res://spike/lit_cutout/art/light_disc_smooth.png")
const NORMAL_DIR := "res://spike/lit_cutout/art/rook_normals"
const SPEC := preload("res://spike/lit_cutout/art/rook_normals/dave_spec.png")
## Warm ivory, as every muzzle flash in the kit (roster fairness rules).
const FLASH_COLOR := Color("#FFE4BD")
const FLASH_TIME := 0.07
const FLASH_ENERGY := 2.4

var hero: Node2D
var enabled: bool = true
var _body: Sprite2D
var _arm: Sprite2D
var _body_mat: ShaderMaterial
var _arm_mat: ShaderMaterial
var _normals: Dictionary = {}   # albedo resource_path -> normal Texture2D
var _flash: PointLight2D
var _flash_t: float = 0.0


func setup(p_hero: Node2D) -> void:
	hero = p_hero
	_body = hero.get_node_or_null("Visual/Body") as Sprite2D
	_arm = hero.get_node_or_null("AimPivot/Arm") as Sprite2D
	_body_mat = _make_material()
	_arm_mat = _make_material()
	for s in [_body, _arm]:
		if s:
			s.light_mask = 1 | 2
	var gun := hero.get_node_or_null("AimPivot/Scrapjack")
	if gun and gun.has_signal("fired"):
		gun.fired.connect(_on_fired)
	_flash = PointLight2D.new()
	_flash.name = "MuzzleFlashLight"
	_flash.texture = DISC
	_flash.texture_scale = 1.1
	_flash.color = FLASH_COLOR
	_flash.energy = 0.0
	_flash.height = 26.0
	_flash.blend_mode = Light2D.BLEND_MODE_ADD
	hero.get_parent().add_child.call_deferred(_flash)
	set_enabled(true)


func _make_material() -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = LitShader
	m.set_shader_parameter("spec_atlas", SPEC)
	m.set_shader_parameter("ambient", Vector3(0.3, 0.3, 0.36))
	m.set_shader_parameter("wrap", 0.3)
	return m


func set_enabled(on: bool) -> void:
	enabled = on
	if _body:
		_body.material = _body_mat if on else null
	if _arm:
		_arm.material = _arm_mat if on else null


func set_normals_enabled(on: bool) -> void:
	for m in [_body_mat, _arm_mat]:
		m.set_shader_parameter("normals_on", 1.0 if on else 0.0)


func _normal_for(tex: Texture2D) -> Texture2D:
	if tex == null:
		return null
	var key := tex.resource_path
	if not _normals.has(key):
		var p := NORMAL_DIR.path_join(key.get_file().get_basename() + "_n.png")
		_normals[key] = load(p) if ResourceLoader.exists(p) else null
	return _normals[key]


func _process(delta: float) -> void:
	if hero == null or not is_instance_valid(hero):
		return
	if _body:
		_body_mat.set_shader_parameter("normal_atlas", _normal_for(_body.texture))
	if _arm:
		_arm_mat.set_shader_parameter("normal_atlas", _normal_for(_arm.texture))
	if _flash_t > 0.0:
		_flash_t = maxf(0.0, _flash_t - delta)
		_flash.energy = FLASH_ENERGY * (_flash_t / FLASH_TIME)
	elif _flash:
		_flash.energy = 0.0


func _on_fired() -> void:
	var gun := hero.get_node_or_null("AimPivot/Scrapjack")
	if gun == null or _flash == null or not _flash.is_inside_tree():
		return
	_flash.global_position = gun.get_muzzle_global_position()
	_flash.reset_physics_interpolation()
	_flash_t = FLASH_TIME
	_flash.energy = FLASH_ENERGY
