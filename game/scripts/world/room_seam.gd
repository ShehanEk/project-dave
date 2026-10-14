@tool
extends Node2D
## A room seam (Level 2 v2 architecture kit, l02-alignment.md "Rooms with walls and doors: an
## area is a chain of rooms joined by door frames, airlocks and stairwells, so every seam reads as
## passing from one space to the next"): a doorway drawn across an area's height at the node's x.
## A wall pier (panelled, seen edge-on) comes down from the ceiling to a lintel, the door leaf is
## slid up into it (hazard-striped edge), a head light washes the opening, two slim jambs stand on
## the floor and a lit sign panel on the pier shows an abstract icon. An AIRLOCK is two such
## frames with a short grated chamber between them.
##
## Purely visual (behind the actors, never on a walkable edge) unless `solid_lintel`, which makes
## the pier above the opening world-layer solid (a jump can't pass over the seam). No class_name
## (import-cache rule): preload it by path. Place it under an area's Scenery with its origin on the
## floor line (local y 0 of the floor Dave walks through).

const Arch := preload("res://scripts/world/lab_structure.gd")

enum Style { DOORWAY, AIRLOCK }

## Ceiling height over the floor (px). 0: the underside of the ROOF block above (Block group
## "terrain_block"), else FALLBACK_HEIGHT.
@export var height: float = 0.0:
	set(v):
		height = maxf(v, 0.0)
		_rebuild()
## Height of the opening (2.5 H).
@export var door_height: float = 240.0:
	set(v):
		door_height = maxf(v, 120.0)
		_rebuild()
## The wall's thickness as seen edge-on.
@export var pier_width: float = 64.0:
	set(v):
		pier_width = maxf(v, 16.0)
		_rebuild()
@export var style: Style = Style.DOORWAY:
	set(v):
		style = v
		queue_redraw()
## The sign panel's icon (Arch.Icon: NONE, ARROW, LAB, RANGE, KENNEL, DRONE, CELLS, LATTICE, LIFT,
## STAIRS, HAZARD).
@export var icon: int = 1:
	set(v):
		icon = v
		queue_redraw()
## Make the pier above the opening solid (world layer 1).
@export var solid_lintel: bool = false:
	set(v):
		solid_lintel = v
		_rebuild()

const FALLBACK_HEIGHT := 460.0
## The airlock's two frames stand this far apart (centre to centre).
const AIRLOCK_GAP := 150.0

var _body: StaticBody2D


func _ready() -> void:
	z_index = -2
	_rebuild()


## The ceiling height used (px over the floor).
func resolved_height() -> float:
	if height > 0.0:
		return height
	if is_inside_tree():
		var others: Array = []
		for n in get_tree().get_nodes_in_group("terrain_block"):
			if n.has_method("get_rect_global"):
				others.append([n.get_rect_global(), int(n.get("kind"))])
		var y: float = Arch.ceiling_above(others, global_position, 2000.0)
		if not is_nan(y):
			return global_position.y - y
	return FALLBACK_HEIGHT


## The frames' centre xs (local).
func frame_xs() -> Array:
	if style == Style.AIRLOCK:
		return [-AIRLOCK_GAP * 0.5, AIRLOCK_GAP * 0.5]
	return [0.0]


func _rebuild() -> void:
	if not is_inside_tree():
		return
	if solid_lintel:
		if _body == null:
			_body = StaticBody2D.new()
			_body.name = "Lintel"
			_body.collision_layer = 1
			_body.collision_mask = 0
			add_child(_body)  # no owner: generated, never saved into scenes
		for ch in _body.get_children():
			ch.free()
		var h: float = resolved_height()
		for fx in frame_xs():
			var shape := CollisionShape2D.new()
			var rect := RectangleShape2D.new()
			rect.size = Vector2(pier_width, maxf(h - door_height, 1.0))
			shape.shape = rect
			shape.position = Vector2(float(fx), -(h + door_height) * 0.5)
			_body.add_child(shape)
	elif _body != null:
		_body.queue_free()
		_body = null
	queue_redraw()


func _draw() -> void:
	var h: float = resolved_height()
	var lintel: float = -door_height
	var gx: float = global_position.x
	if style == Style.AIRLOCK:
		# The chamber: a darker back wall and a grated floor between the two frames.
		var cw: float = AIRLOCK_GAP
		draw_rect(Rect2(Vector2(-cw * 0.5, -h), Vector2(cw, h + lintel)), Arch.GRAPHITE_DARK)
		draw_rect(Rect2(Vector2(-cw * 0.5, lintel - 6.0), Vector2(cw, 6.0)), Arch.STEEL_DARK)
		var x: float = -cw * 0.5 + 6.0
		while x < cw * 0.5 - 4.0:
			draw_line(Vector2(x, -6.0), Vector2(x, -1.0), Arch.STEEL_DARK, 2.0)
			x += 8.0
	for i in frame_xs().size():
		var fx: float = frame_xs()[i]
		var pier := Rect2(Vector2(fx - pier_width * 0.5, -h), Vector2(pier_width, h - door_height))
		Arch.wall_face(self, pier, gx + fx)
		var ic: int = icon if i == 0 else Arch.Icon.NONE
		Arch.doorway(self, fx, lintel, 0.0, pier_width, ic)
