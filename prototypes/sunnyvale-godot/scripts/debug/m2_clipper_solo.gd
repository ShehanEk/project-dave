extends Node2D
## M2 isolated Clipper test (A02-style first-Clipper setup): stone backstop,
## safe jumping space, and a raised observation step in one camera view.
## Wires the independent GameCamera to the Hero at runtime.

func _ready() -> void:
	var hero: Node2D = $Hero
	var camera: Camera2D = $GameCamera
	camera.target = hero
