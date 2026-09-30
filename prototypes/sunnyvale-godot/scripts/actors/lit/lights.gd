extends RefCounted
## Small smooth light textures for actor-carried lights (a tell glowing on
## a baton, a lightbar, hands), built once from a radial gradient so actors
## need no light-texture file. World lights (lamps, beacons) use
## SceneryDraw's own smooth textures. No class_name.

static var _soft_disc: Texture2D = null


## A round light with a smooth falloff; 128 px across at texture_scale 1.
static func soft_disc() -> Texture2D:
	if _soft_disc == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.35, 0.7, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0.15), Color(1, 1, 1, 0)])
		var t := GradientTexture2D.new()
		t.gradient = g
		t.width = 128
		t.height = 128
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.0, 0.5)
		_soft_disc = t
	return _soft_disc
