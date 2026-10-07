extends "res://scripts/actors/visuals/hero_visual.gd"
## Dave Harlan as a pixel-art lit cutout rig (2026-10-07), like the Night
## Guard, the Staffer, the Patrol Rover and the Scrapjack: the user's pixel
## parts sheet (concept-art/h01-dave/h01-dave-parts-pixel-v1.webp) imported by
## tools/art/import_parts_sheet.py dave into assets/characters/lit/dave/, drawn
## by scripts/actors/lit/cutout_rig.gd (nearest filtering, joints posed in
## rotation steps of about one art pixel, lit by the engine's lights through
## the parts' normal maps) and posed by hand-keyed clips
## (scripts/actors/lit/clips_dave.gd) through rig_animator.gd.
##
## Same public API as hero_visual.gd (this script extends it), so hero.gd is
## unchanged: update_pose() once per physics tick with plain values,
## shoulder_offset() (the near shoulder of the posed rig, where hero.gd keeps
## AimPivot), `aim_pivot`, `facing`, the gun hidden when defeated, light masks
## 1 | 2 and the shared lit-part shader. Without the rig's art (an export
## missing assets/characters/lit/dave/rig.json, or `rig_path` pointed
## elsewhere) every method falls back to the Rook frames of hero_visual.gd.
##
## THE AIM. The Scrapjack stays on AimPivot and turns with the aim, smoothly,
## as before (hero.gd); the near arm (upper arm, forearm, the gripping hand) is
## posed every physics tick, after hero.gd has turned AimPivot and the gun has
## recoiled (process_physics_priority), so the fist sits on the gun's grip: the
## hand lines up with the gun, the wrist goes where that puts it, and the
## shoulder and elbow are solved as a two-bone chain (the elbow bends below
## the line, so it hangs down for a level aim, forward for an aim up and back
## for an aim down). Each joint is set in the rig's rotation steps, the forearm
## and the hand re-solved after the joint above them is stepped, so the fist
## stays within about one art pixel of the grip. The far arm follows the clips.
## No class_name (hero.tscn attaches this by path).

const RigScript := preload("res://scripts/actors/lit/cutout_rig.gd")
const AnimatorScript := preload("res://scripts/actors/lit/rig_animator.gd")
const Clips := preload("res://scripts/actors/lit/clips_dave.gd")
const RIG_PATH := "res://assets/characters/lit/dave/rig.json"
## The gun's draw layer (relative z), between the near upper arm (7) and the
## near forearm and fist (10): its frame and battery at 8, its barrel and upper
## housing at 9, so the fist wraps the grip and the gun is in front of the body.
const GUN_Z := 7
## Dave's lights wrap a little further round an edge than the enemies' (0.2).
const RIG_WRAP := 0.3
## Crossfade into each clip (s).
const BLEND := {&"idle": 0.15, &"run": 0.08, &"jump_rise": 0.06, &"jump_fall": 0.1, &"land": 0.03,
		&"hurt": 0.03, &"interact": 0.06, &"defeated": 0.08}
## The run clip's length: one stride cycle (TAU of hero.gd's stride phase).
const RUN_LENGTH := 1.0
## Where the Scrapjack's grip is when the gun has no rig (its GRIP_LOCAL).
const GUN_GRIP_LOCAL := Vector2(2.0, 3.0)
## The fallback (the Rook frames' smooth arm): where the gun goes so its grip
## sits in that arm's fist (hero.tscn places the gun for the pixel rig).
const FALLBACK_GUN_POSITION := Vector2(32.5, -0.9)
const BLOOD_SOCKETS := ["blood_head", "blood_chest", "blood_belly", "blood_arm", "blood_thigh"]

@export_file("*.json") var rig_path: String = RIG_PATH

var rig: Node2D = null
var anim = null
var _state: StringName = &"idle"
var _wrist: Node2D = null
var _was_defeated: bool = false


func _ready() -> void:
	if not FileAccess.file_exists(rig_path):
		super._ready()
		return
	rig = RigScript.new()
	rig.name = "Rig"
	rig.rig_path = rig_path
	add_child(rig)
	for m in rig._materials:
		(m as ShaderMaterial).set_shader_parameter("wrap", RIG_WRAP)
	anim = AnimatorScript.new(Clips.CLIPS)
	anim.play("idle", true, 0.0)
	rig.apply_pose(anim.advance(0.0))
	# After hero.gd (which turns AimPivot) and the Scrapjack (which recoils): see aim_arm().
	process_physics_priority = 100


func setup(pivot: Node2D) -> void:
	if rig == null:
		super.setup(pivot)
		var gun := pivot.get_node_or_null("Scrapjack") as Node2D if pivot else null
		if gun:
			gun.position = FALLBACK_GUN_POSITION
		return
	aim_pivot = pivot
	if pivot == null:
		return
	_gun = pivot.get_node_or_null("Scrapjack") as CanvasItem
	var gun_rig: Node2D = _gun.get("rig") if _gun else null
	if gun_rig != null:
		# Two draw layers for the gun's four parts (the frame and the battery cell under the
		# barrel and the housing, as their own order has them), so the whole gun fits between
		# the upper arm and the fist.
		gun_rig.z_index = GUN_Z
		for jname in gun_rig.sprites:
			var s: Sprite2D = gun_rig.sprites[jname]
			s.z_index = 1 if int(gun_rig.defs[jname]["z"]) <= 2 else 2
	_wrist = pivot.get_node_or_null("WristLight") as Node2D
	var wl := _wrist as PointLight2D
	if wl:
		wl.texture = SceneryDrawScript.smooth_disc_texture()
	_place_wrist_light()


func update_pose(p_facing: int, p_moving: bool, p_grounded: bool, p_vertical_velocity: float,
		p_stride_phase: float, p_is_firing: bool, p_immune: bool, p_defeated: bool,
		p_land_squash_timer: float, p_hit_pose_timer: float, p_interact_pose_timer: float) -> void:
	if rig == null:
		super.update_pose(p_facing, p_moving, p_grounded, p_vertical_velocity, p_stride_phase, p_is_firing,
				p_immune, p_defeated, p_land_squash_timer, p_hit_pose_timer, p_interact_pose_timer)
		return
	facing = p_facing
	moving = p_moving
	grounded = p_grounded
	vertical_velocity = p_vertical_velocity
	stride_phase = p_stride_phase
	is_firing = p_is_firing
	immune = p_immune
	defeated = p_defeated
	land_squash_timer = p_land_squash_timer
	hit_pose_timer = p_hit_pose_timer
	interact_pose_timer = p_interact_pose_timer
	_pose(get_physics_process_delta_time())


func _pose(delta: float) -> void:
	var want := _pick_state()
	# Back on his feet after a death (hero.respawn_at): straight to the new pose, no blend out of
	# the kneel (and no interpolated frame between them).
	var revived := _was_defeated and not defeated
	if want != _state:
		var blend: float = 0.0 if revived else float(BLEND.get(want, 0.1))
		anim.play(String(want), true, blend)
		_state = want
	_was_defeated = defeated
	if _state == &"run":
		# The cycle follows the stride (distance run), so its cadence is his speed's and it plays
		# backward when he backpedals.
		anim.speed = 0.0
		anim.time = fposmod(stride_phase, TAU) / TAU * RUN_LENGTH
	else:
		anim.speed = 1.0
	var pose: Dictionary = anim.advance(delta)
	if hit_pose_timer > 0.0 and not _reduced_motion():
		# The hit wiggle (the old frame shake), whole art pixels on a pixel rig.
		var shake := sin(hit_pose_timer * 60.0) * 2.0 * (hit_pose_timer / HIT_POSE_TIME)
		pose["root"] = (pose.get("root", Vector2.ZERO) as Vector2) + Vector2(shake, 0.0)
	rig.facing = facing
	rig.apply_pose(pose)
	if revived:
		rig.reset_physics_interpolation()
	# A downed hero isn't still holding the pistol up; hide it (the arm hangs with the clip).
	if _gun:
		_gun.visible = not defeated
	_place_wrist_light()


## The clip for the current pose. Priority (as the Rook frames): defeated, hurt,
## interact, airborne, landing, running, idle.
func _pick_state() -> StringName:
	if defeated:
		return &"defeated"
	if hit_pose_timer > 0.0:
		return &"hurt"
	if interact_pose_timer > 0.0:
		return &"interact"
	if not grounded:
		return &"jump_rise" if vertical_velocity < RISE_SPEED else &"jump_fall"
	if land_squash_timer > 0.0:
		return &"land"
	if moving:
		return &"run"
	return &"idle"


func _process(delta: float) -> void:
	if rig == null:
		super._process(delta)


func _physics_process(_delta: float) -> void:
	if rig != null:
		aim_arm()


## Poses the near arm so the fist holds the gun's grip (see the header). Runs
## after hero.gd has placed and turned AimPivot this tick; does nothing while
## defeated (the clip's arm) or without an aim pivot and gun.
func aim_arm() -> void:
	if rig == null or defeated or aim_pivot == null or _gun == null or not rig.joints.has("near_hand"):
		return
	var to_rig: Transform2D = rig.global_transform.affine_inverse()
	var grip: Vector2 = to_rig * _gun_grip_global()
	var fwd: Vector2 = to_rig.basis_xform((_gun as Node2D).global_transform.x).normalized()
	var ua: Node2D = rig.joints["near_upper_arm"]
	var fa: Node2D = rig.joints["near_forearm"]
	var hand: Node2D = rig.joints["near_hand"]
	var parent_xf: Transform2D = rig._to_rig(ua.get_parent())
	var shoulder: Vector2 = parent_xf * ua.position
	var parent_rot: float = parent_xf.get_rotation()
	var v1: Vector2 = fa.position          # the elbow, in the upper arm's frame
	var v2: Vector2 = hand.position        # the wrist, in the forearm's frame
	var g: Vector2 = (rig.sockets["grip"]["pos"] as Vector2) if rig.sockets.has("grip") else Vector2(0.0, 3.0)
	# The hand lines up with the gun: its length (+y, the fingers) along the barrel, so the
	# fist's grip runs down the gun's grip.
	var hand_rot := fwd.angle() - PI * 0.5
	var wrist := grip - g.rotated(hand_rot)
	var l1 := v1.length()
	var l2 := v2.length()
	var d := wrist - shoulder
	var dist := clampf(d.length(), absf(l1 - l2) + 0.01, l1 + l2 - 0.01)
	var cos_e := clampf((l1 * l1 + dist * dist - l2 * l2) / (2.0 * l1 * dist), -1.0, 1.0)
	# Elbow on the clockwise side of the shoulder-wrist line (below it for a level aim).
	var a1 := d.angle() + acos(cos_e)
	var r_ua: float = rig.snap_rotation("near_upper_arm", wrapf(a1 - v1.angle() - parent_rot, -PI, PI))
	var ua_rot := parent_rot + r_ua
	var elbow := shoulder + v1.rotated(ua_rot)
	var r_fa: float = rig.snap_rotation("near_forearm", wrapf((wrist - elbow).angle() - v2.angle() - ua_rot, -PI, PI))
	var fa_rot := ua_rot + r_fa
	var r_h: float = rig.snap_rotation("near_hand", wrapf(hand_rot - fa_rot, -PI, PI))
	ua.rotation = r_ua
	fa.rotation = r_fa
	hand.rotation = r_h
	_place_wrist_light()


## The gun's grip (where the fist goes), global: the gun rig's origin, which
## scrapjack.gd kicks back on a shot, so the fist recoils with the gun.
func _gun_grip_global() -> Vector2:
	var gun_rig: Node2D = _gun.get("rig")
	if gun_rig != null:
		return gun_rig.global_position
	return (_gun as Node2D).global_transform * GUN_GRIP_LOCAL


## The fist's grip point (the rig's `grip` socket), global.
func grip_global() -> Vector2:
	if rig == null or not rig.sockets.has("grip"):
		return Vector2.INF
	var sock: Dictionary = rig.sockets["grip"]
	return rig.joint_point(sock["joint"], sock["pos"])


## How far (world px) the fist is from the gun's grip (tests).
func grip_error() -> float:
	if rig == null or _gun == null:
		return INF
	return grip_global().distance_to(_gun_grip_global())


## The small wrist light (AimPivot/WristLight) rides on the near forearm's cuff
## (the rig's `wrist_light` socket).
func _place_wrist_light() -> void:
	if rig == null or _wrist == null or not rig.sockets.has("wrist_light"):
		return
	var sock: Dictionary = rig.sockets["wrist_light"]
	_wrist.global_position = rig.joint_point(sock["joint"], sock["pos"])


## Where a hit on Dave bleeds from: the rig's blood socket (head, chest, belly,
## near upper arm, near thigh) nearest `from` (global), in global space.
func blood_point(from: Vector2) -> Vector2:
	if rig == null:
		return global_position + Vector2(0.0, -56.0)
	var best := Vector2.INF
	for sname in BLOOD_SOCKETS:
		if not rig.sockets.has(sname):
			continue
		var sock: Dictionary = rig.sockets[sname]
		var p: Vector2 = rig.joint_point(sock["joint"], sock["pos"])
		if best == Vector2.INF or p.distance_to(from) < best.distance_to(from):
			best = p
	return best


func set_normals_enabled(on: bool) -> void:
	if rig == null:
		super.set_normals_enabled(on)
		return
	_normals_on = on
	rig.set_normals_enabled(on)


## The clip showing (the Rook frame's name in the fallback).
func current_frame() -> StringName:
	return _state if rig != null else super.current_frame()


## The near shoulder of the posed rig relative to the hero origin, mirrored
## for facing. hero.gd keeps AimPivot here.
func shoulder_offset() -> Vector2:
	if rig == null:
		return super.shoulder_offset()
	var ua: Node2D = rig.joints["near_upper_arm"]
	var s: Vector2 = rig._to_rig(ua.get_parent()) * ua.position
	return position + Vector2(s.x * float(facing), s.y)
