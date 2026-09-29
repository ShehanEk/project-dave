extends Node2D
## Lit cutout rig (C35 lit-cutout test): one painted character split into
## parts, each a Sprite2D region of a shared albedo atlas, lit through a
## matching normal atlas by lit_part.gdshader. Joints are plain Node2Ds
## (position = the pivot in the parent's space, rotation = the pose), so a
## pose is just a set of local rotations; see rig_clips.gd.
##
## Built from the JSON written by tools/spike/paint_night_guard.py. Faces
## right; `facing = -1` mirrors the whole rig (normals follow the mirror).
## Pure presentation: no collision, no gameplay state. No class_name
## (visual-script import-cache rule).

const LitShader := preload("res://spike/lit_cutout/shaders/lit_part.gdshader")
const FAR_TINT := Color(0.74, 0.75, 0.8)
## Sole points of the boot in foot-local world px (heel, toe): the ground
## lock keeps the lowest of them on y = 0.
const SOLE_POINTS: Array[Vector2] = [Vector2(-3.9, 5.2), Vector2(4.0, 5.2), Vector2(12.6, 5.2)]

@export_file("*.json") var rig_path: String = "res://spike/lit_cutout/art/night_guard_rig.json"

var joints: Dictionary = {}     # name -> Node2D
var sprites: Dictionary = {}    # name -> Sprite2D
var defs: Dictionary = {}       # name -> joint definition (JSON)
var order: Array[String] = []   # parents before children
var texture_scale: float = 1.0 / 3.0
var body_material: ShaderMaterial
var baton_material: ShaderMaterial
var facing: int = 1:
	set(v):
		facing = 1 if v >= 0 else -1
		scale.x = float(facing)

var _rest_pos: Dictionary = {}
var _albedo: Texture2D
var _normal: Texture2D
var _spec: Texture2D


func _ready() -> void:
	if joints.is_empty():
		build()


func build() -> void:
	var text := FileAccess.get_file_as_string(rig_path)
	var data: Dictionary = JSON.parse_string(text)
	var dir := rig_path.get_base_dir()
	_albedo = load(dir.path_join(data["albedo"]))
	_normal = load(dir.path_join(data["normal"]))
	_spec = load(dir.path_join(data["spec"]))
	texture_scale = 1.0 / float(data["texture_scale"])
	body_material = _make_material()
	body_material.set_shader_parameter("emissive_energy", 1.3)
	baton_material = _make_material()
	baton_material.set_shader_parameter("emissive_tint", 1.0)
	for j in data["joints"]:
		var jname: String = j["name"]
		var node := Node2D.new()
		node.name = jname
		node.position = Vector2(j["pos"][0], j["pos"][1])
		var parent_name: String = j["parent"]
		var parent: Node = self if parent_name == "" else joints[parent_name]
		parent.add_child(node)
		joints[jname] = node
		defs[jname] = j
		order.append(jname)
		_rest_pos[jname] = node.position
		var part: Dictionary = data["parts"][j["part"]]
		var s := Sprite2D.new()
		s.name = "Sprite"
		s.texture = _albedo
		s.region_enabled = true
		s.region_rect = Rect2(part["rect"][0], part["rect"][1], part["rect"][2], part["rect"][3])
		s.centered = false
		s.offset = -Vector2(part["pivot"][0], part["pivot"][1])
		s.scale = Vector2(texture_scale, texture_scale)
		s.z_index = int(j["z"])
		s.z_as_relative = true
		s.material = baton_material if jname == "baton" else body_material
		if j["far"]:
			s.self_modulate = FAR_TINT
		# A lit character is lit by the world lights (bit 1) and the
		# character-only moon fill (bit 2).
		s.light_mask = 1 | 2
		node.add_child(s)
		sprites[jname] = s


func _make_material() -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = LitShader
	m.set_shader_parameter("normal_atlas", _normal)
	m.set_shader_parameter("spec_atlas", _spec)
	return m


## Applies local joint rotations (radians); "root" is an extra pelvis offset
## (world px). Joints missing from the pose keep their rest rotation (0).
func apply_pose(pose: Dictionary, ground_lock: bool = true) -> void:
	for jname in order:
		joints[jname].rotation = pose.get(jname, 0.0)
	var root_off: Vector2 = pose.get("root", Vector2.ZERO)
	var pelvis: Node2D = joints["pelvis"]
	pelvis.position = _rest_pos["pelvis"] + root_off
	if ground_lock:
		pelvis.position.y += _ground_error()


## How far the lowest sole point sits above (negative) or below (positive)
## the ground line y = 0, in rig space; subtracted so the feet stay planted.
func _ground_error() -> float:
	var lowest := -INF
	for foot in ["near_foot", "far_foot"]:
		if not joints.has(foot):
			continue
		var to_rig: Transform2D = _to_rig(joints[foot])
		for p in SOLE_POINTS:
			lowest = maxf(lowest, (to_rig * p).y)
	return -lowest if lowest > -INF else 0.0


func _to_rig(node: Node2D) -> Transform2D:
	var t := Transform2D.IDENTITY
	var n: Node = node
	while n != null and n != self:
		t = (n as Node2D).transform * t
		n = n.get_parent()
	return t


func set_normals_enabled(on: bool) -> void:
	for m in [body_material, baton_material]:
		m.set_shader_parameter("normals_on", 1.0 if on else 0.0)


func set_ambient(c: Color) -> void:
	for m in [body_material, baton_material]:
		m.set_shader_parameter("ambient", Vector3(c.r, c.g, c.b))


func set_flash(amount: float) -> void:
	for m in [body_material, baton_material]:
		m.set_shader_parameter("flash", amount)


## The baton tip's tell glow (amber, then red) — emissive only; the tell's
## PointLight2D lives on the guard.
func set_tell(color: Color, energy: float) -> void:
	baton_material.set_shader_parameter("emissive_color", Vector3(color.r, color.g, color.b))
	baton_material.set_shader_parameter("emissive_energy", energy)


## Global position of a point given in a joint's local (unflipped) space.
func joint_point(jname: String, local: Vector2) -> Vector2:
	return (joints[jname] as Node2D).global_transform * local


## The joint whose ragdoll collider is closest to `global_pos` (for wounds
## and for where a killing shot pushes).
func nearest_joint(global_pos: Vector2, skip_baton: bool = true) -> String:
	var best := ""
	var best_d := INF
	for jname in order:
		if skip_baton and jname == "baton":
			continue
		var col: Dictionary = defs[jname]["collider"]
		var t: Transform2D = (joints[jname] as Node2D).global_transform
		var d := INF
		if col["type"] == "circle":
			var c: Vector2 = t * Vector2(col["c"][0], col["c"][1])
			d = global_pos.distance_to(c) - float(col["r"])
		else:
			var a: Vector2 = t * Vector2(col["a"][0], col["a"][1])
			var b: Vector2 = t * Vector2(col["b"][0], col["b"][1])
			d = global_pos.distance_to(Geometry2D.get_closest_point_to_segment(global_pos, a, b)) - float(col["r"])
		if d < best_d:
			best_d = d
			best = jname
	return best
