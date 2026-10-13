extends Node2D
## Moonlight for the night campus (C35 lit cutouts): one faint, cold
## DirectionalLight2D from the upper left. Dave and the enemies are normal
## mapped, so it gives them a cool rim that keeps them readable in the dark.
##
## Lit characters sit on light masks 1 | 2: bit 1 is the world lights (lamps,
## beacons, the depot's fixtures) and bit 2 is the moon, which is why the
## light sets `range_item_cull_mask = 2`. KNOWN LIMIT (Godot 4.7.2, the
## Compatibility renderer): DirectionalLight2D ignores that mask, so the moon
## also washes the whole world (blocks, props, backdrops, sky) with the same
## faint cool light, multiplying every colour by about 1.2. That wash is part
## of the approved lit-cutout look (the test scene had it too), so it stays;
## black stays black, and nothing is hidden by it. A strictly character-only
## rim would need a camera-following PointLight2D instead (those do honour
## the mask).
##
## Instanced by LevelDirector next to the night overlay when
## `res://scenes/world/night_lighting.tscn` exists. Static: nothing here moves
## or flashes, so reduced motion has nothing to change. No `class_name`
## (world-visual import-cache rule).

## Light-mask bit the moon is meant to reach (characters).
const MOON_MASK := 2

@onready var moon: DirectionalLight2D = $Moonlight


func set_enabled(on: bool) -> void:
	moon.enabled = on
