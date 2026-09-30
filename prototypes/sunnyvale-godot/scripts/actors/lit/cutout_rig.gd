extends Node2D
## Lit cutout rig (C35): one painted character or machine split into parts,
## each a Sprite2D region of a shared albedo atlas, lit through a matching
## normal atlas by assets/shaders/lit_part.gdshader. Joints are plain
## Node2Ds (position = the pivot in the parent's space, rotation = the
## pose), so a pose is just a set of local rotations (rig_animator.gd).
##
## Built from a rig.json written by the tools in tools/art/ (see
## tools/art/README.md). Faces right; `facing = -1` mirrors the whole rig
## (the normals follow the mirror). Humans keep the lowest sole on the floor
## ("ground_lock"); machines are posed directly by their owner. Pure
## presentation: no collision, no gameplay state. No class_name
## (visual-script import-cache rule).

const LitShader := preload("res://assets/shaders/lit_part.gdshader")
const FAR_TINT := Color(0.74, 0.75, 0.8)
const DEFAULT_SOLE_POINTS: Array[Vector2] = [Vector2(-3.9, 5.2), Vector2(4.0, 5.2), Vector2(12.6, 5.2)]
## The night: how bright a part is with no light on it (about 45%). The same
## level as Dave (hero_visual.gd AMBIENT), so a painted color, a skin tone
## above all, reads the same on every character and still reads away from the
## lamps; a bluer, darker night turned warm skin muddy brown.
const DEFAULT_AMBIENT := Color(0.45, 0.45, 0.54)

@export_file("*.json") var rig_path: String = ""

var joints: Dictionary = {}     # name -> Node2D
var sprites: Dictionary = {}    # name -> Sprite2D
var defs: Dictionary = {}       # name -> joint definition (JSON)
var order: Array[String] = []   # parents before children
## Named attachment points from rig.json: name -> {"joint": String, "pos": Vector2}
## (a tell light, a spark point, a machine's core).
var sockets: Dictionary = {}
var kind: String = "human"
var texture_scale: float = 1.0 / 3.0
## Shared by every part that has no material of its own; painted emissive
## spots (status LEDs, lamp lenses, an implant light) glow in their own
## painted colour.
var body_material: ShaderMaterial
var facing: int = 1:
	set(v):
		facing = 1 if v >= 0 else -1
		scale.x = float(facing)

var _rest_pos: Dictionary = {}
var _ground_lock: bool = true
var _sole_points: Array[Vector2] = []
var _materials: Array[ShaderMaterial] = []
var _joint_materials: Dictionary = {}   # joint -> its own ShaderMaterial
var _albedo: Texture2D
var _normal: Texture2D
var _spec: Texture2D


func _ready() -> void:
	if joints.is_empty() and rig_path != "":
		build()


func build() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(rig_path))
	var dir := rig_path.get_base_dir()
	_albedo = load(dir.path_join(data["albedo"]))
	_normal = load(dir.path_join(data["normal"]))
	_spec = load(dir.path_join(data["spec"]))
	texture_scale = 1.0 / float(data["texture_scale"])
	kind = String(data.get("kind", "human"))
	_ground_lock = bool(data.get("ground_lock", kind == "human"))
	_sole_points = DEFAULT_SOLE_POINTS.duplicate()
	if data.has("sole_points"):
		_sole_points.clear()
		for p in data["sole_points"]:
			_sole_points.append(Vector2(p[0], p[1]))
	for sname in data.get("sockets", {}):
		var sock: Dictionary = data["sockets"][sname]
		sockets[sname] = {"joint": String(sock["joint"]), "pos": Vector2(sock["pos"][0], sock["pos"][1])}
	body_material = _make_material()
	body_material.set_shader_parameter("emissive_energy", 1.3)
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
		s.material = body_material
		if j.get("far", false):
			s.self_modulate = FAR_TINT
		# World lights (bit 1) and the character-only moonlight rim (bit 2).
		s.light_mask = 1 | 2
		node.add_child(s)
		sprites[jname] = s


func _make_material() -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = LitShader
	m.set_shader_parameter("normal_atlas", _normal)
	m.set_shader_parameter("spec_atlas", _spec)
	m.set_shader_parameter("ambient", Vector3(DEFAULT_AMBIENT.r, DEFAULT_AMBIENT.g, DEFAULT_AMBIENT.b))
	_materials.append(m)
	return m


## Gives one part its own material whose emissive spots glow in `color`
## instead of their painted colour (a baton tip or a lightbar tell, a
## battery core). Returns it; later calls return the same material.
func joint_material(jname: String) -> ShaderMaterial:
	if _joint_materials.has(jname):
		return _joint_materials[jname]
	var m := _make_material()
	m.set_shader_parameter("emissive_tint", 1.0)
	m.set_shader_parameter("emissive_energy", 0.0)
	_joint_materials[jname] = m
	if sprites.has(jname):
		(sprites[jname] as Sprite2D).material = m
	return m


func set_emissive(jname: String, color: Color, energy: float) -> void:
	if not sprites.has(jname):
		return
	var m := joint_material(jname)
	m.set_shader_parameter("emissive_color", Vector3(color.r, color.g, color.b))
	m.set_shader_parameter("emissive_energy", energy)


## The first joint tagged with `role` in rig.json (machines), or "".
func joint_for_role(role: String) -> String:
	for jname in order:
		if String(defs[jname].get("role", "")) == role:
			return jname
	return ""


## Applies local joint rotations (radians); "root" is an extra offset for
## the root joint (world px). Joints missing from the pose keep rotation 0.
func apply_pose(pose: Dictionary) -> void:
	for jname in order:
		joints[jname].rotation = pose.get(jname, 0.0)
	var root_name: String = order[0]
	var root: Node2D = joints[root_name]
	root.position = _rest_pos[root_name] + (pose.get("root", Vector2.ZERO) as Vector2)
	if _ground_lock:
		root.position.y += _ground_error()


## How far the lowest sole point sits above (negative) or below (positive)
## the ground line y = 0, in rig space; subtracted so the feet stay planted.
func _ground_error() -> float:
	var lowest := -INF
	for foot in ["near_foot", "far_foot"]:
		if not joints.has(foot):
			continue
		var to_rig: Transform2D = _to_rig(joints[foot])
		for p in _sole_points:
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
	for m in _materials:
		m.set_shader_parameter("normals_on", 1.0 if on else 0.0)


func set_ambient(c: Color) -> void:
	for m in _materials:
		m.set_shader_parameter("ambient", Vector3(c.r, c.g, c.b))


func set_flash(amount: float) -> void:
	for m in _materials:
		m.set_shader_parameter("flash", amount)


## Global position of a point given in a joint's local (unflipped) space.
func joint_point(jname: String, local: Vector2) -> Vector2:
	return (joints[jname] as Node2D).global_transform * local


## The joint whose collider is closest to `global_pos` (for wounds and for
## where a killing shot pushes). `skip` names joints never chosen.
func nearest_joint(global_pos: Vector2, skip: Array = ["baton"]) -> String:
	var best := ""
	var best_d := INF
	for jname in order:
		if skip.has(jname):
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
