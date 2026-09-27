extends Node2D
## M1 movement/pistol test course. Wires the independent GameCamera to the
## Hero at runtime (an exported Node2D can't be pointed at a scene sibling
## from the .tscn file itself in Godot 4's text format).

func _ready() -> void:
	var hero: Node2D = $Hero
	var camera: Camera2D = $GameCamera
	camera.target = hero
