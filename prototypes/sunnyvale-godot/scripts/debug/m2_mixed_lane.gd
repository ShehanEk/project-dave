extends Node2D
## M2 T06 mixed lane: one EncounterGroup with a Resident and a Clipper.
## Wires the independent GameCamera to the Hero at runtime.

func _ready() -> void:
	var hero: Node2D = $Hero
	var camera: Camera2D = $GameCamera
	camera.target = hero
