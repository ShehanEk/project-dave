class_name Hound
extends Brawler
## K01 Hound (M4): Arcadia Security's cyborg guard dog, a four-legged Brawler with a
## double lunge (BrawlerTuning `lunge_count` 2): it drops low as its jaw guard glows
## amber, then red for the last 0.25 s (a growl and a servo whine), lunges 2 H along the
## floor, crouches 0.5 s with its own amber-then-red blip (turning to face Dave through
## the amber part), lunges once more, then stands rigid (the punish window: 2 hits). The
## attack box is low (a held jump clears it); the hit zone is 0.8 H tall so a level shot
## lands. With a Night Guard handler (`handler_path`), the handler's tell starts no
## sooner than 1.5 s after the chain ends, and the two never attack together
## (brawler.gd's handler gate). It bleeds red; on death its legs twitch for about a
## second, then the body settles as a corpse.
##
## Only the lights are its own (C60, neon per controller): the spine strip glows lime
## (Arcadia Security) while it has a living handler, magenta (Adam) without one; the
## collar's status light is a small steady teal while it waits and a small dim amber
## once it hunts, and so is the visor's sensor point. None of them is a tell or a
## detection state (C16); all go dark on death.

## Batch 7: each lunge kicks up a puff of floor dust behind it (PixelFx "lunge_dust", at the
## paws' line, thrown back from the lunge).
const PixelFx := preload("res://scripts/effects/pixel_fx.gd")

const LIME := Color("#C6FF3D")
const MAGENTA := Color("#FF3DD5")
const TEAL := Color("#3FE0D0")
## The rig parts that carry each light (the K01 part list).
const NEON_JOINT := "torso"
const COLLAR_JOINT := "neck"
const VISOR_JOINT := "head"


## The tell's glow on the jaw guard (an additive halo along the teeth line, like the
## Staffer's hand glows), shown through the crouch and the lunge in the tell's colour.
var _jaw_glow: Sprite2D


func _build_visual() -> void:
	super()
	if rig == null or not rig.joints.has(tuning.tell_joint):
		return
	_jaw_glow = Sprite2D.new()
	_jaw_glow.name = "JawGlow"
	_jaw_glow.texture = Lights.soft_disc()
	_jaw_glow.scale = Vector2(0.2, 0.09)
	_jaw_glow.position = rig.sockets["tell"]["pos"] if rig.sockets.has("tell") else tuning.tell_offset
	_jaw_glow.z_index = 12
	_jaw_glow.light_mask = 0
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_jaw_glow.material = mat
	_jaw_glow.visible = false
	rig.joints[tuning.tell_joint].add_child(_jaw_glow)


func _update_lights(delta: float) -> void:
	super(delta)
	if rig == null:
		return
	if _jaw_glow != null:
		var on: bool = _tell_light.energy > 0.0
		_jaw_glow.visible = on
		var c: Color = _tell_light.color
		_jaw_glow.modulate = Color(c.r, c.g, c.b, 0.9)
	var hunting: bool = _noticed or state == State.APPROACH or is_in_chain() or state == State.RECOVERY
	rig.set_emissive(NEON_JOINT, neon_color(), 1.1)
	rig.set_emissive(COLLAR_JOINT, AMBER if hunting else TEAL, 0.9 if hunting else 1.1)
	rig.set_emissive(VISOR_JOINT, AMBER, 0.7 if hunting else 0.0)


func _enter(s: State) -> void:
	super(s)
	if s == State.STRIKE:
		_kick_dust()


## The lunge's dust, behind the dog's hind paws on the floor (null without the strip).
func _kick_dust() -> Node:
	var host := _effect_host()
	if host == null or not is_on_floor():
		return null
	var back := Vector2(-float(_strike_dir) * tuning.body_half_width * 0.6, 0.0)
	return PixelFx.spawn("lunge_dust", global_position + back, host, {"flip": _strike_dir > 0})


## Lime with a living handler, magenta when Adam drives it.
func neon_color() -> Color:
	return LIME if has_handler() else MAGENTA
