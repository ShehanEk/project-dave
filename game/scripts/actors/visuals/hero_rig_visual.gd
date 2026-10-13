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
## stays within about one art pixel of the grip. The far arm follows the clips, except
## that a two-handed gun (the Boom Broom's `support` socket on its pump) has the far hand
## on it, posed the same way.
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
## Dave under a street lamp (2026-10-10): his parts sheet gives his hair the gloss of leather,
## so a lamp above him put a white patch on his hair, and his pale painted skin at full lamp
## light read as flat white. His shine is cut right down and his light levels off earlier
## than the enemies' (the shader's soft limit, knee_start 0.7 for everyone else).
const RIG_SPEC_GAIN := 0.12
const RIG_KNEE_START := 0.3
const RIG_KNEE_SOFT := 4.0
## Crossfade into each clip (s).
const BLEND := {&"idle": 0.15, &"run": 0.08, &"backpedal": 0.1, &"jump_rise": 0.06, &"jump_fall": 0.1, &"land": 0.03,
		&"hurt": 0.03, &"interact": 0.06, &"defeated": 0.08}
## The run clip's length: one stride cycle (TAU of hero.gd's stride phase).
const RUN_LENGTH := 1.0
## True while the stride phase runs backward (backing off toward the aim).
var _backpedal := false
## Where the Scrapjack's grip is when the gun has no rig (its GRIP_LOCAL).
const GUN_GRIP_LOCAL := Vector2(2.0, 3.0)
## The fallback (the Rook frames' smooth arm): where the gun goes so its grip
## sits in that arm's fist (hero.tscn places the gun for the pixel rig).
const FALLBACK_GUN_POSITION := Vector2(32.5, -0.9)
const BLOOD_SOCKETS := ["blood_head", "blood_chest", "blood_belly", "blood_arm", "blood_thigh"]
## C50: where the gun's grip sits from the shoulder at each aim step (hero.gd's aim_step,
## in 22.5-degree steps: -4 straight up .. 0 level .. 4 straight down), in the aim pivot's
## frame (x along the aim, y to the aim's lower or forward side). Closer than the arm's
## full reach, so the elbow bends; straight up holds the gun forward of his face, straight
## down forward of his legs. Set for every other step; the steps between take the middle.
const GUN_HOLD := {
	# The run-and-gun hold (Metal Slug, Contra): the arm nearly straight from the shoulder, the
	# gun out in front of him at every angle (C57 had it held close, the elbow bent: 15/16, 20/5,
	# 21/3, 20/0, 16/-17). The painted gun is drawn at 0.85 of its imported size
	# (scrapjack.gd ART_SCALE).
	-4: Vector2(31.0, 5.0),
	-2: Vector2(32.0, 3.0),
	0: Vector2(33.0, 2.0),
	2: Vector2(32.0, 0.0),
	4: Vector2(28.0, -18.0),
}
## The two-handed hold: the rear hand near the chest so the far hand can reach the pump a
## forearm further on (C57's close hold, which suits a shouldered gun).
const GUN_HOLD_TWO_HANDED := {
	-4: Vector2(14.0, 8.0),
	-2: Vector2(17.0, 4.0),
	0: Vector2(18.0, 2.5),
	2: Vector2(17.0, 0.0),
	4: Vector2(14.0, -9.0),
}
## Aim lean: the torso and head pitch with the aim (radians per radian of aim pitch; up is
## negative), so aiming up leans him back with his chin up and aiming down leans him over the
## gun, not just the arm moving. Whole rig steps on the pixel rig (snap_rotation).
const AIM_LEAN_TORSO := 0.12
const AIM_LEAN_HEAD := 0.22

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
		(m as ShaderMaterial).set_shader_parameter("spec_gain", RIG_SPEC_GAIN)
		(m as ShaderMaterial).set_shader_parameter("knee_start", RIG_KNEE_START)
		(m as ShaderMaterial).set_shader_parameter("knee_soft", RIG_KNEE_SOFT)
	anim = AnimatorScript.new(Clips.CLIPS)
	anim.play("idle", true, 0.0)
	rig.apply_pose(anim.advance(0.0))
	# After hero.gd (which turns AimPivot) and the Scrapjack (which recoils): see aim_arm().
	process_physics_priority = 100


func setup(pivot: Node2D) -> void:
	if rig == null:
		super.setup(pivot)
		var gun := _find_gun(pivot)
		if gun:
			gun.position = FALLBACK_GUN_POSITION
		return
	aim_pivot = pivot
	if pivot == null:
		return
	set_gun(_find_gun(pivot))
	_wrist = pivot.get_node_or_null("WristLight") as Node2D
	var wl := _wrist as PointLight2D
	if wl:
		wl.texture = SceneryDrawScript.smooth_disc_texture()
	_place_wrist_light()


## The gun on the aim pivot: the Scrapjack or (M3) the Boom Broom.
func _find_gun(pivot: Node2D) -> Node2D:
	if pivot == null:
		return null
	for n in ["Scrapjack", "BoomBroom"]:
		var g := pivot.get_node_or_null(n) as Node2D
		if g != null and not g.is_queued_for_deletion():
			return g
	return null


## Takes `gun` as the one the near fist holds (hero.gd calls this when the held weapon's
## type changes, M3): its rig is drawn between the upper arm and the fist, in two layers
## (each gun's parts by their own order: z 1-2 under, 3 and up over), and the arm aims at
## its grip. The Rook-frame fallback just remembers it.
func set_gun(gun: Node2D) -> void:
	_gun = gun
	if gun == null:
		return
	if rig == null:
		gun.position = FALLBACK_GUN_POSITION
		return
	var gun_rig: Node2D = gun.get("rig")
	if gun_rig != null:
		gun_rig.z_index = GUN_Z
		for jname in gun_rig.sprites:
			var s: Sprite2D = gun_rig.sprites[jname]
			s.z_index = 1 if int(gun_rig.defs[jname]["z"]) <= 2 else 2
	_gun.visible = not defeated


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
	if p_moving and not is_equal_approx(p_stride_phase, stride_phase):
		_backpedal = p_stride_phase < stride_phase
	elif not p_moving:
		_backpedal = false
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
	if _state == &"run" or _state == &"backpedal":
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
		# Backing off toward the aim (the stride phase running backward): the backpedal (C57).
		return &"backpedal" if _backpedal else &"run"
	return &"idle"


func _process(delta: float) -> void:
	if rig == null:
		super._process(delta)


func _physics_process(_delta: float) -> void:
	if rig != null:
		aim_arm()


## Poses the near arm so the fist holds the gun's grip (see the header), and for a gun with a
## support socket (the Boom Broom's pump) the far arm too, so the far hand wraps it. Runs
## after hero.gd has placed and turned AimPivot this tick; does nothing while defeated (the
## clip's arm) or without an aim pivot and gun.
func aim_arm() -> void:
	if rig == null or defeated or aim_pivot == null or _gun == null or not rig.joints.has("near_hand"):
		return
	var to_rig: Transform2D = rig.global_transform.affine_inverse()
	var grip: Vector2 = to_rig * _gun_grip_global()
	var fwd: Vector2 = to_rig.basis_xform((_gun as Node2D).global_transform.x).normalized()
	# The hand lines up with the gun: its length (+y, the fingers) along the barrel, so the
	# fist's grip runs down the gun's grip.
	var hand_rot := fwd.angle() - PI * 0.5
	_lean_with_aim(fwd.angle())
	# The lean moved the shoulders: re-read where the arms hang from (the solve reads the joints).
	_solve_arm("near", "grip", grip, hand_rot)
	var support := _support_point(to_rig)
	if support != Vector2.INF and rig.joints.has("far_hand"):
		_solve_arm("far", "grip_far", support, hand_rot)
	_place_wrist_light()


## Pitches the torso and head with the aim (`pitch`: the barrel's angle in the rig's own
## right-facing frame, up negative), on top of the clip's pose, before the arms are solved.
## Not while defeated (the aim arm does not run then either).
func _lean_with_aim(pitch: float) -> void:
	var p := clampf(wrapf(pitch, -PI, PI), -PI * 0.5, PI * 0.5)
	if rig.joints.has("torso"):
		var torso: Node2D = rig.joints["torso"]
		torso.rotation = rig.snap_rotation("torso", torso.rotation + p * AIM_LEAN_TORSO)
	if rig.joints.has("head"):
		var head: Node2D = rig.joints["head"]
		head.rotation = rig.snap_rotation("head", head.rotation + p * AIM_LEAN_HEAD)


## One arm as a two-bone chain (`side` "near" or "far"): the upper arm and forearm are turned,
## in the rig's rotation steps, so the hand (turned to `hand_rot`, rig space) puts its
## `grip_socket` on `target` (rig space). The elbow bends below the shoulder-wrist line; an
## out-of-reach target leaves the arm straight toward it.
func _solve_arm(side: String, grip_socket: String, target: Vector2, hand_rot: float) -> void:
	var ua: Node2D = rig.joints[side + "_upper_arm"]
	var fa: Node2D = rig.joints[side + "_forearm"]
	var hand: Node2D = rig.joints[side + "_hand"]
	var parent_xf: Transform2D = rig._to_rig(ua.get_parent())
	var shoulder: Vector2 = parent_xf * ua.position
	var parent_rot: float = parent_xf.get_rotation()
	var v1: Vector2 = fa.position          # the elbow, in the upper arm's frame
	var v2: Vector2 = hand.position        # the wrist, in the forearm's frame
	var g: Vector2 = (rig.sockets[grip_socket]["pos"] as Vector2) if rig.sockets.has(grip_socket) else Vector2(0.0, 3.0)
	var wrist := target - g.rotated(hand_rot)
	var l1 := v1.length()
	var l2 := v2.length()
	var d := wrist - shoulder
	var dist := clampf(d.length(), absf(l1 - l2) + 0.01, l1 + l2 - 0.01)
	var cos_e := clampf((l1 * l1 + dist * dist - l2 * l2) / (2.0 * l1 * dist), -1.0, 1.0)
	# Elbow on the clockwise side of the shoulder-wrist line (below it for a level aim).
	var a1 := d.angle() + acos(cos_e)
	var r_ua: float = rig.snap_rotation(side + "_upper_arm", wrapf(a1 - v1.angle() - parent_rot, -PI, PI))
	var ua_rot := parent_rot + r_ua
	var elbow := shoulder + v1.rotated(ua_rot)
	var r_fa: float = rig.snap_rotation(side + "_forearm", wrapf((wrist - elbow).angle() - v2.angle() - ua_rot, -PI, PI))
	var fa_rot := ua_rot + r_fa
	var r_h: float = rig.snap_rotation(side + "_hand", wrapf(hand_rot - fa_rot, -PI, PI))
	ua.rotation = r_ua
	fa.rotation = r_fa
	hand.rotation = r_h


## True while the held gun is two-handed: its rig has a `support` socket (the Boom Broom's pump).
func two_handed() -> bool:
	if _gun == null or rig == null:
		return false
	var gun_rig: Node2D = _gun.get("rig")
	if gun_rig == null or not gun_rig.sockets.has("support"):
		return false
	return gun_rig.joints.has(gun_rig.sockets["support"]["joint"])


## Where the far hand holds the gun (its rig's `support` socket: the Boom Broom's pump, which
## slides back and forward as it pumps), in rig space; INF for a one-handed gun.
func _support_point(to_rig: Transform2D) -> Vector2:
	if not two_handed():
		return Vector2.INF
	var gun_rig: Node2D = _gun.get("rig")
	var sock: Dictionary = gun_rig.sockets["support"]
	return to_rig * gun_rig.joint_point(sock["joint"], sock["pos"])


## How far (world px) the far hand is from the gun's support point (tests); INF with none.
func support_error() -> float:
	if rig == null or _gun == null or not rig.sockets.has("grip_far"):
		return INF
	var p := _support_point(rig.global_transform.affine_inverse())
	if p == Vector2.INF:
		return INF
	var sock: Dictionary = rig.sockets["grip_far"]
	var hand_p: Vector2 = rig.joint_point(sock["joint"], sock["pos"])
	return hand_p.distance_to(rig.global_transform * p)


## Where hero.gd puts the held gun (the Scrapjack or the Boom Broom: both have their grip
## at the same spot in their own node) on the aim pivot for aim direction `step` (C50).
## The Rook-frame fallback keeps its one fixed spot.
func gun_hold(step: int) -> Vector2:
	if rig == null:
		return FALLBACK_GUN_POSITION
	var k := clampi(step, -4, 4)
	var table: Dictionary = GUN_HOLD_TWO_HANDED if two_handed() else GUN_HOLD
	# A two-handed gun is held closer, stock to his chest, so the far hand can reach its pump.
	return table[k] if table.has(k) else (table[k - 1] + table[k + 1]) * 0.5


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
