extends Node2D
## M2 demo course geometry: an isolated Resident encounter followed by an
## A02-style Clipper/backstop encounter. Wires the independent GameCamera to
## the Hero at runtime.

func _ready() -> void:
	var hero: Node2D = $Hero
	var camera: Camera2D = $GameCamera
	camera.target = hero
