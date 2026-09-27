extends Node2D
## M2 isolated Resident test: no EncounterGroup ancestor, so it attacks freely.
## Wires the independent GameCamera to the Hero at runtime.

func _ready() -> void:
	var hero: Node2D = $Hero
	var camera: Camera2D = $GameCamera
	camera.target = hero
