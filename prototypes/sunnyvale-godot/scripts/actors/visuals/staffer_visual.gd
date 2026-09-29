extends Node2D
## CY01 Staffer body rendering (revamp, C24): a fully procedural drawing of a
## Linked cyborg, a former Arcadia night-shift office worker in a charcoal
## uniform jacket over a pale shirt, dark trousers, an ID lanyard, a slim
## collar brace and two wrist cuffs, with the Link implant behind the
## anatomical right ear (art-design/cyborgs/cy01-staffer.md). Replaces the
## retired zombie Resident cutout; no image is involved any more.
##
## Pure presentation: staffer.gd pushes plain values once per physics tick
## via update_pose() (unchanged since M6) plus update_drive() (who is driving
## the body, and how far through the stumble recovery it is), and keeps
## drawing the (unchanged) warning triangle/lunge-hurtbox overlay itself.
## Nothing here reads Session/physics or feeds anything back.
##
## No class_name (see hero_visual.gd's note); staffer.tscn attaches this to
## a child "Visual" node and staffer.gd holds it as an untyped ref.
##
## Link light (the Link disc behind the right ear plus the repeater light on
## the back of the collar, so the state reads from both facings). A
## readability cue only, never a detection state (C16):
##   teal  #3FE0D0 steady      dormant/idle (the harmless ID-card routine)
##   amber #FFB02E slow pulse  Adam is driving the body: approach, lunge,
##                             stumble recovery (the Link chirps once,
##                             &"link_chirp", as it turns amber)
##   red   #FF3B4E flashing    the lunge wind-up (the tell): 2 flashes over
##                             the wind-up, so never above 3 per second,
##                             and the moonlight rim washes red with it
##   dark                      disabled: a short burn-out pop, then off
## Reduced motion keeps every state and colour but drops the pulse, the
## flashing and the twitch jitter.
##
## Drawing: flat colours with one crisp cel-shadow shape per part (each
## part is filled in its shadow tone, then again in its lit tone, scaled
## toward the light), a cool moonlight rim on the edges that face the light,
## heavier outer contours than interior lines, and flat glow shapes drawn
## additively on the "Glow" child. Everything is built in "facing space"
## (+x = toward `facing`, y down, origin at the feet) and mirrored at the
## end, so the anatomical sides stay fixed: facing right shows the right
## side (Link, pushed-up right sleeve), facing left shows the left side
## (dragging left shoe) and only the Link's glow spills past the skull.

const WIDTH := 48.0
const HEIGHT := 84.0
const HIT_FLASH_TIME := 0.15

const OUTLINE := Color("#07090f")
const RIM := Color("#a9c8f0")
const SKIN := Color("#b3917c")
const SKIN_SHADE := Color("#6b5661")
const HAIR := Color("#4b3e38")
const HAIR_SHADE := Color("#261f27")
const JACKET := Color("#3e4759")
const JACKET_SHADE := Color("#20273a")
## Interior line where jacket overlaps jacket (restrained, not near-black).
const JACKET_LINE := Color("#12172a")
const SHIRT := Color("#c3cdd8")
const SHIRT_SHADE := Color("#6f7d8f")
const TROUSERS := Color("#2a3141")
const TROUSERS_SHADE := Color("#151a26")
const SHOE := Color("#46546a")
const SHOE_SHADE := Color("#262e3d")
const SOLE := Color("#9aa6b3")
const BRACE := Color("#6f8096")
const BRACE_SHADE := Color("#39455a")
const CUFF := Color("#2a3341")
const LANYARD := Color("#7d8ca6")
const CARD := Color("#d6dde6")
const CARD_MARK := Color("#56667d")
const LINK_DISC := Color("#2e3b4e")
const EYE_DARK := Color("#10141c")
const HIT_FLASH := Color("#f2f0e8")

const LINK_TEAL := Color("#3fe0d0")
const LINK_AMBER := Color("#ffb02e")
const LINK_RED := Color("#ff3b4e")
const LINK_OFF := Color("#1b2331")
const LINK_BURN := Color("#fff4dc")

enum Link { IDLE, DRIVEN, TELL, DARK }

# Proportions (px; the collision box is 48x84, the hero H = 96).
const THIGH := 19.0
const SHIN := 18.0
const ANKLE_Y := -4.0
const TORSO_LEN := 30.0
const TORSO_MID := 14.0  # the spine bends here (lower/upper halves)
const NECK_LEN := 9.5
const HEAD_SCALE := 1.1  # head-local drawing units -> px
const UPPER_ARM := 14.0
const FOREARM := 13.0
const HAND := 5.0
## walk_phase (staffer.gd) advances 2*PI per ~105 px of travel; one stiff
## step per 1/WALK_CADENCE of that keeps the planted foot from sliding.
const WALK_CADENCE := 1.8
const STEP_LEN := PI * 2.0 / (0.06 * WALK_CADENCE * 2.0)
## Light comes from above and behind (facing space): rim on those edges,
## cel shadows on the front and underside.
const LIGHT_DIR := Vector2(-0.55, -0.84)
## The ID-card routine (dormant only): one loop every ROUTINE_TIME seconds.
const ROUTINE_TIME := 4.4

const R := 0  # anatomical right (index into the per-side pose arrays)
const L := 1  # anatomical left

var facing: int = -1
var moving: bool = false
var walk_phase: float = 0.0
var lean: float = 0.0          # 0 = neutral, 1 = full windup/lunge
var use_procedural: bool = false  # true while in WINDUP/LUNGE (the attack pose)
var hit_flash_timer: float = 0.0
var defeat_progress: float = -1.0  # -1 = active; 0..1 = the disabled collapse
## True once staffer.gd has handed this Visual to the area as a slumped body.
var body_left: bool = false
## update_drive(): false while the Staffer idles dormant (inactive encounter,
## or no hero to go after), true while Adam drives it.
var driven: bool = true
## update_drive(): 0..1 through the stumble recovery after a lunge, -1 otherwise.
var recovery: float = -1.0

var _glow: Node2D
var _anim_t: float = 0.0     # wall clock, cosmetic only
var _routine_t: float = 0.0  # time spent dormant and standing
var _lunge_t: float = 0.0    # time since the lunge started
var _walk_blend: float = 0.0
var _card_hold: float = 0.0  # 0 = card on the lanyard, 1 = in the right hand
var _f: float = -1.0         # facing sign while drawing
var _reduced: bool = false
var _rim_col: Color = RIM

# Solved pose, facing space, rebuilt every frame by _solve_pose().
var _hip := Vector2.ZERO
var _spine := 0.0          # torso pitch (radians, + = forward)
var _neck_pitch := 0.0
var _head_tilt := 0.0      # extra head rotation (twitches, snaps)
var _shoulder_lift := 0.0
var _ua := [0.0, 0.0]      # upper-arm angle from straight down (+ = forward)
var _bend := [0.0, 0.0]    # elbow bend
var _wrist := [0.0, 0.0]
var _ankle := [Vector2.ZERO, Vector2.ZERO]
var _toe := [0.0, 0.0]     # foot pitch (+ = toe down)
var _lid := 1.0            # 0 = wide, 1 = heavy lids, 2 = closed
var _tap := 0.0            # card jab toward the (absent) door reader

# Derived joints (facing space).
var _mid := Vector2.ZERO
var _neck := Vector2.ZERO
var _head := Vector2.ZERO
var _head_ang := 0.0
var _shoulder := Vector2.ZERO
var _elbow := [Vector2.ZERO, Vector2.ZERO]
var _wrist_pt := [Vector2.ZERO, Vector2.ZERO]
var _hand_tip := [Vector2.ZERO, Vector2.ZERO]
var _knee := [Vector2.ZERO, Vector2.ZERO]


func _ready() -> void:
	# Deterministic per-instance offset so a group of Staffers never runs
	# its routine or twitches in lockstep.
	_anim_t = fmod(float(get_instance_id() % 997) * 0.731, ROUTINE_TIME)
	_routine_t = _anim_t
	_glow = Node2D.new()
	_glow.name = "Glow"
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = mat
	add_child(_glow)
	_glow.draw.connect(_draw_glow)


func _process(delta: float) -> void:
	_anim_t += delta
	var dormant_still: bool = not driven and not moving and not use_procedural \
			and recovery < 0.0 and defeat_progress < 0.0
	if dormant_still:
		_routine_t += delta
	var want_card: float = 1.0 if dormant_still and _routine_card() > 0.0 else 0.0
	_card_hold = move_toward(_card_hold, want_card, delta * 5.0)
	if use_procedural and lean >= 1.0:
		_lunge_t += delta
	else:
		_lunge_t = 0.0
	_walk_blend = move_toward(_walk_blend, 1.0 if moving else 0.0, delta * 7.0)
	# The last third of the collapse fades out: staffer.gd frees the node the
	# moment it completes (DEFEAT_FADE_TIME), so this avoids a pop. A body
	# left behind as scenery (`body_left`, staffer.gd `_leave_body()`) stays
	# visible instead — an unconscious worker slumped on the floor.
	if body_left:
		modulate.a = 0.9
	else:
		modulate.a = 1.0 if defeat_progress < 0.0 else 1.0 - _ease((defeat_progress - 0.62) / 0.38)
	# The whole level is loaded at once, so skip the (vector-heavy) redraw
	# while this Staffer is well outside the view.
	if not _near_screen():
		return
	queue_redraw()
	if _glow:
		_glow.queue_redraw()


func _near_screen() -> bool:
	var vp := get_viewport()
	if vp == null:
		return true
	var p: Vector2 = get_global_transform_with_canvas().origin
	return vp.get_visible_rect().grow(200.0).has_point(p)


func update_pose(p_facing: int, p_moving: bool, p_walk_phase: float, p_lean: float,
		p_use_procedural: bool, p_hit_flash_timer: float, p_defeat_progress: float) -> void:
	facing = p_facing
	moving = p_moving
	walk_phase = p_walk_phase
	lean = p_lean
	use_procedural = p_use_procedural
	hit_flash_timer = p_hit_flash_timer
	defeat_progress = p_defeat_progress


## Revamp presentation hook (staffer.gd calls it right after update_pose()):
## `p_driven` picks amber over teal for the Link; `p_recovery` (0..1, -1 when
## not recovering) paces the stumble after a lunge. Changes nothing else.
func update_drive(p_driven: bool, p_recovery: float) -> void:
	if p_driven and not driven and defeat_progress < 0.0:
		_chirp()
	driven = p_driven
	recovery = p_recovery


## The Link chirps once as Adam takes the body over (teal -> amber).
func _chirp() -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"link_chirp", global_position)


func _reduced_motion() -> bool:
	var settings := get_node_or_null("/root/Settings")
	return settings != null and settings.get_reduced_motion()


# --- Link light state ------------------------------------------------------------

func link_state() -> Link:
	if defeat_progress >= 0.0:
		return Link.DARK
	if use_procedural and lean < 1.0:
		return Link.TELL
	if driven or use_procedural or recovery >= 0.0:
		return Link.DRIVEN
	return Link.IDLE


## Colour and brightness (0..1) of the Link ring and the collar repeater.
func _link_light() -> Array:
	match link_state():
		Link.DARK:
			# The implant burns out: one bright pop at the start of the
			# collapse, then it stays off.
			if defeat_progress < 0.12:
				return [LINK_BURN, 1.0]
			return [LINK_OFF, 0.0]
		Link.TELL:
			# Two flashes over the wind-up (paced by `lean`, so they stay in
			# step with the real wind-up timing): bright, dip, bright.
			var bright: bool = _reduced or lean < 0.42 or lean >= 0.6
			return [LINK_RED, 1.0 if bright else 0.45]
		Link.DRIVEN:
			var pulse: float = 1.0 if _reduced else 0.78 + 0.22 * sin(_anim_t * TAU * 0.8)
			if hit_flash_timer > HIT_FLASH_TIME * 0.35 and hit_flash_timer < HIT_FLASH_TIME * 0.8:
				pulse = 0.15  # hit: one brief flicker
			return [LINK_AMBER, pulse]
		_:
			var level: float = 1.0
			if hit_flash_timer > HIT_FLASH_TIME * 0.35 and hit_flash_timer < HIT_FLASH_TIME * 0.8:
				level = 0.15
			return [LINK_TEAL, level]


# --- pose ---------------------------------------------------------------------------

## ID-card routine: 0 while the arm hangs, 1 while the card is held up to an
## absent door reader (the taps ride on top via _routine_tap()).
func _routine_card() -> float:
	var t: float = fmod(_routine_t, ROUTINE_TIME)
	return 1.0 if t > 1.9 and t < 3.4 else 0.0


func _routine_tap() -> float:
	var t: float = fmod(_routine_t, ROUTINE_TIME)
	if t < 2.3 or t > 3.2:
		return 0.0
	var k: float = fmod(t - 2.3, 0.3) / 0.3
	return maxf(0.0, 1.0 - absf(k - 0.25) * 5.0)  # a quick jab, three times


## A sharp twitch: quick attack, slower decay; 0 outside [at, at + width].
func _twitch(x: float, at: float, width: float) -> float:
	if x < at or x > at + width:
		return 0.0
	var t: float = (x - at) / width
	return t / 0.12 if t < 0.12 else pow(1.0 - (t - 0.12) / 0.88, 2.0)


func _ease(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return x * x * (3.0 - 2.0 * x)


func _solve_pose() -> void:
	var tw_scale: float = 0.0 if _reduced else 1.0

	# Neutral stiff slouch: legs a little bent, head drooping forward, arms
	# hanging slightly away from the body as if on strings.
	_hip = Vector2(-1.0, -39.0)
	_spine = 0.12
	_neck_pitch = 0.5
	_head_tilt = 0.08
	_shoulder_lift = 0.0
	_lid = 1.0
	_tap = 0.0
	_ua = [0.2, 0.16]
	_bend = [0.22, 0.26]
	_wrist = [0.28, 0.3]
	_ankle = [Vector2(3.5, ANKLE_Y), Vector2(-4.0, ANKLE_Y)]
	_toe = [0.0, 0.0]

	# Standing sway and idle twitches.
	if not use_procedural and defeat_progress < 0.0:
		_hip.x += sin(_anim_t * 0.9) * 0.4
		var cycle: float = fmod(_anim_t, 2.9)
		_head_tilt += tw_scale * 0.22 * _twitch(cycle, 1.1, 0.22)
		if driven:
			# Adam has the body: the head lifts toward the target, the
			# fingers keep twitching.
			_neck_pitch = 0.38
			_wrist[R] += tw_scale * 0.35 * _twitch(fmod(_anim_t + 0.7, 1.7), 0.0, 0.15)
			_wrist[L] += tw_scale * 0.35 * _twitch(fmod(_anim_t, 2.3), 0.0, 0.15)

	# The harmless routine: the right hand lifts the ID card and taps it on a
	# door reader that is not there.
	if _card_hold > 0.0:
		var c: float = _ease(_card_hold)
		_tap = _routine_tap() * c
		_ua[R] = lerpf(_ua[R], 0.62, c)
		_bend[R] = lerpf(_bend[R], 1.25, c)
		_wrist[R] = lerpf(_wrist[R], -0.35, c)
		_neck_pitch = lerpf(_neck_pitch, 0.42, c)

	# Stiff puppet walk: the planted foot slides back at exactly the body's
	# speed (no skating), the swing is a quick flick, the anatomical left
	# shoe drags with its toe down instead of lifting, and the hip vaults
	# over the stiff stance leg.
	if _walk_blend > 0.0:
		var wb: float = _walk_blend
		var ph: float = walk_phase * WALK_CADENCE
		var stance_len: float = 35.5
		var low_y := 0.0
		for side in [R, L]:
			var p: float = fposmod(ph + (0.0 if side == R else PI), TAU)
			var x: float
			var lift: float = 0.0
			if p < PI:
				x = lerpf(STEP_LEN * 0.5, -STEP_LEN * 0.5, p / PI)  # stance
			else:
				var s: float = (p - PI) / PI
				var flick: float = 1.0 - pow(1.0 - s, 2.2)  # jerky swing
				x = lerpf(-STEP_LEN * 0.5, STEP_LEN * 0.5, flick)
				lift = sin(s * PI) * (2.6 if side == R else 0.4)
				if side == L:
					_toe[L] = lerpf(_toe[L], 0.32, wb * sin(s * PI))
			_ankle[side] = _ankle[side].lerp(Vector2(x, ANKLE_Y - lift), wb)
			if p < PI:
				low_y = sqrt(maxf(0.0, stance_len * stance_len - x * x))
		_hip.y = lerpf(_hip.y, ANKLE_Y - low_y, wb)
		_hip.x = lerpf(_hip.x, 0.5, wb)
		# Stiff, slightly lagging arm swing, opposite the legs.
		var arm_swing: float = sin(ph - 0.5) * 0.16
		_ua[R] = lerpf(_ua[R], 0.2 - arm_swing, wb)
		_ua[L] = lerpf(_ua[L], 0.16 + arm_swing, wb)
		_spine += wb * 0.025 * sin(ph * 2.0)
		# A twitch between steps: the head on one step, a hand on the next.
		var step_frac: float = fposmod(ph, PI) / PI
		var even: bool = fposmod(ph, TAU) < PI
		var jerk: float = tw_scale * _twitch(step_frac, 0.0, 0.3) * wb
		if even:
			_head_tilt += 0.2 * jerk
		else:
			_wrist[R] += 0.5 * jerk
			_shoulder_lift += 1.2 * jerk

	# Wind-up (the tell): it crouches and coils forward, the arms come up with
	# fluttering fingers, a shoulder hitches and the head snaps sideways in
	# jerks that build toward the lunge; the eyes open wide.
	if use_procedural and lean < 1.0:
		var k: float = _ease(lean)
		_hip += Vector2(-3.0 * k, 5.0 * k)
		_ankle[R].x = lerpf(_ankle[R].x, 6.0, k)
		_ankle[L].x = lerpf(_ankle[L].x, -7.0, k)
		_spine = lerpf(_spine, 0.42, k)
		_neck_pitch = lerpf(_neck_pitch, 0.25, k)
		_lid = lerpf(1.0, 0.25, k)
		var snap: float = 0.34 * _twitch(lean, 0.06, 0.2) - 0.3 * _twitch(lean, 0.36, 0.2) \
				+ 0.42 * _twitch(lean, 0.66, 0.24)
		_head_tilt += snap * (0.35 + 0.65 * tw_scale)
		_shoulder_lift += 3.0 * _twitch(lean, 0.22, 0.3)
		var flutter: float = tw_scale * sin(_anim_t * 47.0) * 0.28 * k
		_ua[R] = lerpf(_ua[R], 1.05, k)
		_ua[L] = lerpf(_ua[L], 0.85, k)
		_bend[R] = lerpf(_bend[R], 0.55, k)
		_bend[L] = lerpf(_bend[L], 0.6, k)
		_wrist[R] = lerpf(_wrist[R], -0.1, k) + flutter
		_wrist[L] = lerpf(_wrist[L], -0.05, k) - flutter

	# Lunge: suddenly too fast; the head and torso lead and the feet trail.
	if use_procedural and lean >= 1.0:
		var s: float = _ease(_lunge_t / 0.07)  # snaps in within ~4 frames
		_hip = _hip.lerp(Vector2(4.0, -31.0), s)
		_spine = lerpf(0.42, 0.82, s)
		_neck_pitch = lerpf(0.25, 0.05, s)
		_head_tilt = lerpf(_head_tilt, -0.1, s)
		_lid = 0.25
		_ankle[R] = Vector2(15.0, ANKLE_Y)
		_ankle[L] = Vector2(-17.0, ANKLE_Y - 1.5)
		_toe[L] = 0.7
		_ua = [lerpf(1.05, 1.5, s), lerpf(0.85, 1.35, s)]
		_bend = [0.12, 0.18]
		_wrist = [-0.15, -0.1]

	# Stumble recovery: the lunge's momentum carries it on, a catch step,
	# arms thrown out, then it hauls itself back into the stiff slouch.
	if recovery >= 0.0 and not use_procedural:
		var r: float = clampf(recovery, 0.0, 1.0)
		var settle: float = _ease((r - 0.25) / 0.75)
		var catch_k: float = _ease(r / 0.25)
		var wobble: float = sin(r * 13.0) * (1.0 - r) * 0.12 * (0.4 + 0.6 * tw_scale)
		_hip = Vector2(lerpf(4.0, -1.0, settle), lerpf(-32.0, -39.0, settle))
		_spine = lerpf(lerpf(0.82, 0.6, catch_k), 0.12, settle) + wobble
		_neck_pitch = lerpf(0.1, 0.45, settle)
		_head_tilt += wobble * 2.0
		_ankle[R] = Vector2(lerpf(15.0, 3.5, settle), ANKLE_Y)
		_ankle[L] = Vector2(lerpf(-17.0, 9.0, catch_k), ANKLE_Y - sin(catch_k * PI) * 3.0)
		_ankle[L].x = lerpf(_ankle[L].x, -4.0, settle)
		_toe[L] = lerpf(0.5, 0.0, catch_k)
		_ua[R] = lerpf(lerpf(1.5, 1.75, catch_k), 0.2, settle)
		_ua[L] = lerpf(lerpf(1.35, -0.7, catch_k), 0.16, settle)
		_bend[R] = lerpf(0.3, 0.22, settle)
		_bend[L] = lerpf(0.4, 0.26, settle)

	# Hit: a jolt back from the impact, head knocked back.
	if hit_flash_timer > 0.0 and defeat_progress < 0.0:
		var h: float = hit_flash_timer / HIT_FLASH_TIME
		_spine -= 0.22 * h
		_neck_pitch -= 0.3 * h
		_hip.x -= 2.0 * h
		_ua[R] -= 0.4 * h
		_ua[L] -= 0.4 * h

	# Disabled: the implant burns out (a stiff jolt upright), then the body
	# folds to the floor, unconscious and unhurt, arms limp, eyes shut.
	if defeat_progress >= 0.0:
		var k: float = clampf(defeat_progress, 0.0, 1.0)
		var jolt: float = 1.0 - _ease(k / 0.14)
		var fold: float = _ease((k - 0.1) / 0.55)
		_hip = Vector2(lerpf(-1.0, -3.0, fold), lerpf(-39.0 - 1.5 * jolt, -16.0, fold))
		_spine = lerpf(0.02, 0.95, fold)
		_neck_pitch = lerpf(0.1, 1.25, fold)
		_head_tilt = 0.3 * fold
		_lid = 2.0
		_ankle = [Vector2(lerpf(3.5, -2.0, fold), ANKLE_Y), Vector2(lerpf(-4.0, -7.0, fold), ANKLE_Y)]
		_toe = [lerpf(0.0, 0.5, fold), lerpf(0.0, 0.7, fold)]
		_ua = [lerpf(0.1, -0.15, fold), lerpf(0.05, -0.3, fold)]
		_bend = [lerpf(0.1, 0.15, fold), lerpf(0.1, 0.2, fold)]
		_wrist = [0.3, 0.3]

	_solve_joints()


func _solve_joints() -> void:
	_mid = _hip + Vector2(sin(_spine * 0.6), -cos(_spine * 0.6)) * TORSO_MID
	var upper_pitch: float = _spine * 1.4
	_neck = _mid + Vector2(sin(upper_pitch), -cos(upper_pitch)) * (TORSO_LEN - TORSO_MID)
	var np: float = _neck_pitch + _spine * 0.5
	_head = _neck + Vector2(sin(np), -cos(np)) * NECK_LEN
	_head_ang = np * 0.55 + _head_tilt
	_shoulder = _tp(25.0, -1.8) + Vector2(0.0, -_shoulder_lift)
	for side in [R, L]:
		var sh: Vector2 = _shoulder + (Vector2.ZERO if _near(side) else Vector2(-1.0, -0.5))
		var ua: float = _ua[side]
		_elbow[side] = sh + Vector2(sin(ua), cos(ua)) * UPPER_ARM
		var fa: float = ua + _bend[side]
		_wrist_pt[side] = _elbow[side] + Vector2(sin(fa), cos(fa)) * FOREARM
		if side == R and _tap > 0.0:
			_wrist_pt[side] += Vector2(2.5 * _tap, 0.0)
		var ha: float = fa + _wrist[side]
		_hand_tip[side] = _wrist_pt[side] + Vector2(sin(ha), cos(ha)) * HAND
		_knee[side] = _solve_knee(_hip, _ankle[side], THIGH, SHIN)


## Two-bone IK with the knee bending forward.
func _solve_knee(hip: Vector2, ankle: Vector2, l1: float, l2: float) -> Vector2:
	var d: Vector2 = ankle - hip
	var dist: float = clampf(d.length(), absf(l1 - l2) + 0.01, l1 + l2 - 0.01)
	var dir: Vector2 = d.normalized() if d.length() > 0.001 else Vector2.DOWN
	var cos_a: float = (l1 * l1 + dist * dist - l2 * l2) / (2.0 * l1 * dist)
	var ang: float = acos(clampf(cos_a, -1.0, 1.0))
	var a: Vector2 = hip + dir.rotated(ang) * l1
	var b: Vector2 = hip + dir.rotated(-ang) * l1
	return a if a.x > b.x else b


## Torso-local point: `u` up the spine from the hip, `v` toward the belly.
## The spine bends at TORSO_MID, so a slouch hunches the upper back.
func _tp(u: float, v: float) -> Vector2:
	if u <= TORSO_MID:
		var a: float = _spine * 0.6
		return _hip + Vector2(sin(a), -cos(a)) * u + Vector2(cos(a), sin(a)) * v
	var b: float = _spine * 1.4
	return _mid + Vector2(sin(b), -cos(b)) * (u - TORSO_MID) + Vector2(cos(b), sin(b)) * v


## Head-local point (x forward, y down, origin at the skull centre).
func _hp(p: Vector2) -> Vector2:
	return _head + (p * HEAD_SCALE).rotated(_head_ang)


## True when anatomical `side` is the side facing the viewer.
func _near(side: int) -> bool:
	return (side == R) == (_f > 0.0)


# --- geometry helpers -----------------------------------------------------------------

func _to_screen(pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(pts.size())
	for i in pts.size():
		out[i] = Vector2(pts[i].x * _f, pts[i].y)
	return out


func _sp(p: Vector2) -> Vector2:
	return Vector2(p.x * _f, p.y)


## Capsule around segment a-b (facing space), radius ra at a and rb at b.
func _capsule(a: Vector2, b: Vector2, ra: float, rb: float, seg: int = 5) -> PackedVector2Array:
	var d: Vector2 = b - a
	var ang: float = d.angle() if d.length() > 0.001 else PI * 0.5
	var pts := PackedVector2Array()
	for i in seg + 1:
		var t: float = ang - PI * 0.5 + PI * float(i) / float(seg)
		pts.append(b + Vector2(cos(t), sin(t)) * rb)
	for i in seg + 1:
		var t: float = ang + PI * 0.5 + PI * float(i) / float(seg)
		pts.append(a + Vector2(cos(t), sin(t)) * ra)
	return pts


func _scaled(pts: PackedVector2Array, anchor: Vector2, k: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(pts.size())
	for i in pts.size():
		out[i] = anchor + (pts[i] - anchor) * k
	return out


func _closed(pts: PackedVector2Array) -> PackedVector2Array:
	var out := pts.duplicate()
	if pts.size() > 0:
		out.append(pts[0])
	return out


## Flat tones with the hit flash (a brief lift toward white) folded in.
func _tone(c: Color) -> Color:
	if hit_flash_timer > 0.0 and defeat_progress < 0.0:
		return c.lerp(HIT_FLASH, 0.45 * hit_flash_timer / HIT_FLASH_TIME)
	return c


## Screen-space point on the lit side of a part, for the cel-shadow anchor.
func _light_anchor(pts: PackedVector2Array) -> Vector2:
	var light := Vector2(LIGHT_DIR.x * _f, LIGHT_DIR.y)
	var best: Vector2 = pts[0]
	var best_d: float = -INF
	for p in pts:
		var d: float = p.dot(light)
		if d > best_d:
			best_d = d
			best = p
	return best


## One part: shadow tone, lit tone scaled toward the light (a crisp cel
## crescent on the far side), moonlight rim, thin interior outline.
## `pts` are screen space.
func _part(pts: PackedVector2Array, lit: Color, shade: Color, lit_k: float = 0.8,
		rim: float = 1.0, line: float = 1.0, line_col: Color = OUTLINE) -> void:
	draw_colored_polygon(pts, _tone(shade))
	if lit_k > 0.0:
		draw_colored_polygon(_scaled(pts, _light_anchor(pts), lit_k), _tone(lit))
	if rim > 0.0:
		_rim(pts, rim)
	if line > 0.0:
		draw_polyline(_closed(pts), line_col, line, true)


## Thin cool rim along the edges whose outward normal faces the light,
## inset just inside the outline.
func _rim(pts: PackedVector2Array, strength: float) -> void:
	var n: int = pts.size()
	if n < 3:
		return
	var area := 0.0
	for i in n:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[(i + 1) % n]
		area += a.x * b.y - b.x * a.y
	var sgn: float = 1.0 if area > 0.0 else -1.0
	var light := Vector2(LIGHT_DIR.x * _f, LIGHT_DIR.y)
	var c := _rim_col
	c.a = 0.85 * strength
	var run := PackedVector2Array()
	for i in n:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[(i + 1) % n]
		var e: Vector2 = b - a
		if e.length_squared() < 0.0001:
			continue
		var nrm: Vector2 = e.orthogonal().normalized() * sgn
		if nrm.dot(light) > 0.35:
			var inset: Vector2 = -nrm * 1.0
			if run.is_empty():
				run.append(a + inset)
			run.append(b + inset)
		elif run.size() > 0:
			if run.size() >= 2:
				draw_polyline(run, c, 1.2, true)
			run = PackedVector2Array()
	if run.size() >= 2:
		draw_polyline(run, c, 1.2, true)


# --- drawing --------------------------------------------------------------------------

func _draw() -> void:
	_reduced = _reduced_motion()
	_f = 1.0 if facing >= 0 else -1.0
	_solve_pose()
	_rim_col = RIM
	if link_state() == Link.TELL:
		var level: float = _link_light()[1]
		_rim_col = RIM.lerp(LINK_RED, 0.55 + 0.35 * level)
	var p := _build_parts()
	# Heavier outer contour: every body part's outline, thick, before any fill,
	# so only the outside half of it survives (interior lines stay thin).
	for key in ["far_arm_out", "far_hand", "far_leg_out", "far_shoe", "near_leg_out", "near_shoe",
			"torso", "neck", "head", "hair", "near_arm_out", "near_hand"]:
		var v = p[key]
		if v is Array:
			for poly in v:
				draw_polyline(_closed(poly), OUTLINE, 3.2, true)
		else:
			draw_polyline(_closed(v), OUTLINE, 3.2, true)

	var far := L if _f > 0.0 else R
	var near := R if _f > 0.0 else L
	_draw_arm(p, "far", far, true)
	_draw_leg(p, "far", far, true)
	_draw_leg(p, "near", near, false)
	_draw_torso(p)
	if not _near(R):
		_draw_far_link_spill()
	_draw_neck(p)
	_draw_head(p)
	_draw_arm(p, "near", near, false)
	if use_procedural and lean >= 1.0 and defeat_progress < 0.0:
		_draw_speed_lines()
	if defeat_progress >= 0.0 and defeat_progress < 0.18:
		_draw_burnout_sparks()
	if hit_flash_timer > 0.0:
		_draw_hit_burst()


## Every body part as screen-space polygons. Each limb is two capsules (for
## the cel shading) plus their merged outline, so a sleeve or trouser leg
## reads as one piece of cloth rather than a jointed robot limb.
func _build_parts() -> Dictionary:
	var p := {}
	var near := R if _f > 0.0 else L
	var far := L if _f > 0.0 else R
	for pair in [["near", near], ["far", far]]:
		var tag: String = pair[0]
		var side: int = pair[1]
		var sh: Vector2 = _shoulder + (Vector2.ZERO if tag == "near" else Vector2(-1.0, -0.5))
		var upper := _to_screen(_capsule(sh, _elbow[side], 3.2, 2.9))
		# Right sleeve pushed up above the elbow: a thinner bare forearm.
		var fore_r: float = 2.4 if side == R else 2.8
		var fore := _to_screen(_capsule(_elbow[side], _wrist_pt[side], fore_r + 0.2, fore_r - 0.3))
		p[tag + "_upper"] = upper
		p[tag + "_fore"] = fore
		p[tag + "_arm_out"] = Geometry2D.merge_polygons(upper, fore)
		p[tag + "_hand"] = _to_screen(_capsule(_wrist_pt[side], _hand_tip[side], 2.0, 1.6, 4))
		var thigh := _to_screen(_capsule(_hip, _knee[side], 4.9, 3.9))
		var shin := _to_screen(_capsule(_knee[side], _ankle[side], 3.9, 3.1))
		p[tag + "_thigh"] = thigh
		p[tag + "_shin"] = shin
		p[tag + "_leg_out"] = Geometry2D.merge_polygons(thigh, shin)
		p[tag + "_shoe"] = _to_screen(_shoe_poly(side))
	p["torso"] = _to_screen(_torso_poly())
	p["neck"] = _to_screen(_capsule(_tp(28.0, 0.0), _hp(Vector2(-1.2, 6.0)), 3.3, 3.0, 4))
	p["head"] = _to_screen(_head_poly())
	p["hair"] = _to_screen(_hair_poly())
	return p


func _torso_poly() -> PackedVector2Array:
	# Soft pear-shaped office-worker body; the jacket hem hangs past the hip.
	var back := [[-2.5, -8.9], [1.0, -9.7], [7.0, -10.2], [14.0, -9.8], [20.0, -9.6],
			[25.0, -8.4], [28.5, -6.2], [31.0, -3.0]]
	var front := [[31.0, 2.6], [28.5, 6.2], [23.0, 8.4], [16.0, 10.2], [9.0, 11.2],
			[3.0, 10.8], [-0.5, 9.9], [-2.5, 9.3]]
	var pts := PackedVector2Array()
	for q in back:
		pts.append(_tp(q[0], q[1]))
	for q in front:
		pts.append(_tp(q[0], q[1]))
	return pts


func _head_poly() -> PackedVector2Array:
	var local := [
		Vector2(4.6, -6.3), Vector2(6.8, -2.6), Vector2(6.5, -1.0), Vector2(7.3, 0.3),
		Vector2(9.0, 2.3), Vector2(7.4, 3.1), Vector2(7.6, 4.0), Vector2(7.0, 4.7),
		Vector2(7.5, 5.4), Vector2(6.4, 7.7), Vector2(3.8, 8.7), Vector2(0.4, 7.6),
		Vector2(-2.4, 6.6), Vector2(-5.6, 4.8), Vector2(-7.4, 1.4), Vector2(-7.4, -2.6),
		Vector2(-5.5, -5.9), Vector2(-2.2, -7.6), Vector2(1.5, -7.7),
	]
	var pts := PackedVector2Array()
	for q in local:
		pts.append(_hp(q))
	return pts


func _hair_poly() -> PackedVector2Array:
	# Short, neat office hair; leaves skin behind the ear for the Link.
	var local := [
		Vector2(5.4, -5.1), Vector2(4.8, -7.2), Vector2(1.6, -8.7), Vector2(-2.6, -8.6),
		Vector2(-6.4, -6.4), Vector2(-8.3, -2.2), Vector2(-8.0, 1.6), Vector2(-6.6, 2.8),
		Vector2(-5.6, 0.4), Vector2(-3.4, -1.9), Vector2(-0.8, -2.5), Vector2(1.0, 0.2),
		Vector2(2.0, -3.4), Vector2(4.0, -4.4),
	]
	var pts := PackedVector2Array()
	for q in local:
		pts.append(_hp(q))
	return pts


func _shoe_poly(side: int) -> PackedVector2Array:
	var a: Vector2 = _ankle[side]
	var rot: float = _toe[side]
	var local := [Vector2(-3.6, -2.4), Vector2(2.2, -2.2), Vector2(8.6, 1.0),
			Vector2(9.4, 3.2), Vector2(9.0, 4.0), Vector2(-4.4, 4.0), Vector2(-4.8, 1.0)]
	var pts := PackedVector2Array()
	for q in local:
		pts.append(a + (q as Vector2).rotated(rot))
	return pts


## Shadow tone for both capsules, then both lit shapes, so the joint between
## them never shows a seam; the merged outline goes on top.
func _fill_pair(a: PackedVector2Array, b: PackedVector2Array, lit_a: Color, shade_a: Color,
		lit_b: Color, shade_b: Color, k: float) -> void:
	draw_colored_polygon(a, _tone(shade_a))
	draw_colored_polygon(b, _tone(shade_b))
	draw_colored_polygon(_scaled(a, _light_anchor(a), k), _tone(lit_a))
	draw_colored_polygon(_scaled(b, _light_anchor(b), k), _tone(lit_b))


func _outline_all(polys: Array, rim: float, line_col: Color = OUTLINE) -> void:
	for poly in polys:
		if rim > 0.0:
			_rim(poly, rim)
		draw_polyline(_closed(poly), line_col, 1.0, true)


func _draw_leg(p: Dictionary, tag: String, side: int, is_far: bool) -> void:
	var k: float = 0.55 if is_far else 0.8
	_fill_pair(p[tag + "_thigh"], p[tag + "_shin"], TROUSERS, TROUSERS_SHADE, TROUSERS,
			TROUSERS_SHADE, k)
	_outline_all(p[tag + "_leg_out"], 0.0 if is_far else 0.8)
	var shoe: PackedVector2Array = p[tag + "_shoe"]
	_part(shoe, SHOE, SHOE_SHADE, 0.7 if not is_far else 0.5, 0.6, 0.0)
	# Pale rubber sole strip.
	var a: Vector2 = _ankle[side]
	var rot: float = _toe[side]
	var sole := PackedVector2Array([
		_sp(a + Vector2(-4.4, 2.9).rotated(rot)), _sp(a + Vector2(9.2, 2.9).rotated(rot)),
		_sp(a + Vector2(9.0, 4.0).rotated(rot)), _sp(a + Vector2(-4.4, 4.0).rotated(rot)),
	])
	var sc := SOLE if not is_far else SOLE.darkened(0.35)
	draw_colored_polygon(sole, _tone(sc))
	draw_polyline(_closed(shoe), OUTLINE, 1.0, true)


func _draw_arm(p: Dictionary, tag: String, side: int, is_far: bool) -> void:
	var k: float = 0.5 if is_far else 0.8
	var rim: float = 0.0 if is_far else 0.9
	var fore_lit := SKIN if side == R else JACKET
	var fore_shade := SKIN_SHADE if side == R else JACKET_SHADE
	_fill_pair(p[tag + "_upper"], p[tag + "_fore"], JACKET, JACKET_SHADE, fore_lit, fore_shade, k)
	_outline_all(p[tag + "_arm_out"], rim, OUTLINE if is_far else JACKET_LINE)
	var e: Vector2 = _elbow[side]
	var down: Vector2 = (_wrist_pt[side] - e).normalized()
	if side == R:
		# The pushed-up sleeve bunches in a roll just above the elbow.
		var up: Vector2 = (_shoulder - e).normalized()
		var roll := _to_screen(_capsule(e + up * 1.8, e + down * 0.8, 3.4, 3.1, 4))
		_part(roll, JACKET, JACKET_SHADE, k, 0.0, 1.0, JACKET_LINE)
	# Slim graphite wrist cuff (hardware), then the hand.
	var w: Vector2 = _wrist_pt[side]
	var cuff := _to_screen(_capsule(w - down * 2.4, w - down * 0.3, 3.0, 2.8, 3))
	_part(cuff, CUFF.lightened(0.2), CUFF, 0.7, 0.0)
	_part(p[tag + "_hand"], SKIN, SKIN_SHADE, k, rim * 0.6)
	if side == R and _card_hold > 0.0:
		_draw_card(_hand_tip[side].lerp(w, 0.3), 0.35, true)


func _draw_torso(p: Dictionary) -> void:
	_part(p["torso"], JACKET, JACKET_SHADE, 0.8)
	# Pale shirt in the half-zipped jacket front (a V down to the zip pull).
	var shirt := PackedVector2Array([
		_sp(_tp(31.2, 2.9)), _sp(_tp(28.5, 6.3)), _sp(_tp(22.5, 8.6)), _sp(_tp(18.0, 9.8)),
		_sp(_tp(21.0, 4.6)), _sp(_tp(25.5, 0.8)), _sp(_tp(30.5, -1.6)),
	])
	draw_colored_polygon(shirt, _tone(SHIRT))
	var shirt_shade := PackedVector2Array([
		_sp(_tp(18.0, 9.8)), _sp(_tp(21.0, 4.6)), _sp(_tp(25.5, 0.8)), _sp(_tp(24.0, 3.2)),
	])
	draw_colored_polygon(shirt_shade, _tone(SHIRT_SHADE))
	draw_polyline(PackedVector2Array([_sp(_tp(30.5, -1.6)), _sp(_tp(25.5, 0.8)), _sp(_tp(21.0, 4.6)),
			_sp(_tp(18.0, 9.8))]), OUTLINE, 1.0, true)  # lapel edge
	draw_polyline(_closed(shirt), OUTLINE, 0.8, true)
	# Zip line down the jacket front, with the pull at the bottom of the V.
	draw_line(_sp(_tp(18.0, 9.8)), _sp(_tp(2.0, 10.6)), JACKET_SHADE.darkened(0.35), 1.0, true)
	draw_circle(_sp(_tp(18.4, 9.4)), 0.9, BRACE)
	# Lanyard from the collar to the card resting on the chest (or held up).
	var neck_front: Vector2 = _tp(29.5, 3.2)
	var card_pos: Vector2
	if _card_hold > 0.0:
		card_pos = _hand_tip[R].lerp(_wrist_pt[R], 0.3)
	else:
		var rest: Vector2 = _tp(15.0, 12.4)
		var hang: Vector2 = neck_front + Vector2(0.0, 16.0)
		# The card lies on the chest while upright and swings free once the
		# body pitches far forward (lunge, collapse).
		card_pos = rest if rest.x > hang.x else hang
		card_pos.x += sin(walk_phase * WALK_CADENCE) * 0.6 * _walk_blend
	draw_line(_sp(neck_front), _sp(card_pos + Vector2(0.0, -2.6)), LANYARD, 1.2, true)
	if _card_hold <= 0.0:
		_draw_card(card_pos, 0.0, false)


## Blank ID card (no text): pale rectangle with one dark photo block.
func _draw_card(center: Vector2, ang: float, held: bool) -> void:
	var hw := 2.3
	var hh := 3.1
	var pts := PackedVector2Array()
	for q in [Vector2(-hw, -hh), Vector2(hw, -hh), Vector2(hw, hh), Vector2(-hw, hh)]:
		pts.append(_sp(center + (q as Vector2).rotated(ang)))
	draw_polyline(_closed(pts), OUTLINE, 2.2, true)
	draw_colored_polygon(pts, _tone(CARD))
	var mark := PackedVector2Array()
	for q in [Vector2(-1.3, -1.9), Vector2(0.5, -1.9), Vector2(0.5, 0.2), Vector2(-1.3, 0.2)]:
		mark.append(_sp(center + (q as Vector2).rotated(ang)))
	draw_colored_polygon(mark, CARD_MARK)
	if held and _tap > 0.4:
		# The tap: a tiny contact tick at the card's leading edge.
		var edge: Vector2 = center + Vector2(hw + 1.6, 0.0)
		draw_line(_sp(edge + Vector2(0.0, -2.0)), _sp(edge + Vector2(1.8, -3.2)), RIM, 1.0, true)
		draw_line(_sp(edge + Vector2(0.4, 1.4)), _sp(edge + Vector2(2.2, 2.4)), RIM, 1.0, true)


func _draw_neck(p: Dictionary) -> void:
	_part(p["neck"], SKIN, SKIN_SHADE, 0.7, 0.8)
	# Loosened shirt collar points.
	var collar := PackedVector2Array([
		_sp(_tp(27.5, -3.8)), _sp(_tp(32.0, -3.0)), _sp(_tp(32.4, 3.6)), _sp(_tp(28.2, 6.0)),
		_sp(_tp(29.6, 1.0)),
	])
	draw_colored_polygon(collar, _tone(SHIRT))
	draw_polyline(_closed(collar), OUTLINE, 1.0, true)
	# Collar brace: a slim gunmetal band at the base of the neck with a stay
	# bar resting on the collarbone; the repeater light sits at its back.
	var brace := _to_screen(_capsule(_tp(31.4, -4.2), _tp(31.4, 3.4), 1.7, 1.7, 3))
	_part(brace, BRACE, BRACE_SHADE, 0.7, 1.0)
	draw_line(_sp(_tp(30.6, 2.4)), _sp(_tp(27.0, 6.6)), BRACE, 1.5, true)
	var rep: Vector2 = _sp(_repeater_pos())
	draw_circle(rep, 1.9, OUTLINE)
	draw_circle(rep, 1.3, _link_core(_link_light()))


func _repeater_pos() -> Vector2:
	return _tp(31.6, -4.9)


func _link_pos() -> Vector2:
	return _hp(Vector2(-3.9, 2.8))


func _link_core(light: Array) -> Color:
	var c: Color = light[0]
	var level: float = light[1]
	if level <= 0.0:
		return LINK_OFF
	return LINK_OFF.lerp(c, clampf(0.35 + 0.65 * level, 0.0, 1.0))


func _draw_head(p: Dictionary) -> void:
	_part(p["head"], SKIN, SKIN_SHADE, 0.88, 0.7)
	_part(p["hair"], HAIR, HAIR_SHADE, 0.72, 0.45)
	# Ear (near side): a small flat shape, no full outline at this size.
	var ear := PackedVector2Array()
	for i in 7:
		var t: float = TAU * float(i) / 7.0
		ear.append(_sp(_hp(Vector2(-0.9 + cos(t) * 1.3, 1.0 + sin(t) * 1.9))))
	draw_colored_polygon(ear, _tone(SKIN_SHADE.lerp(SKIN, 0.35)))
	draw_line(_sp(_hp(Vector2(-0.4, -0.3))), _sp(_hp(Vector2(-0.3, 2.0))), SKIN_SHADE.darkened(0.3), 0.8, true)
	if _near(R):
		# The Link: a coin-sized dark disc with its status ring, just behind
		# the right ear.
		var lp: Vector2 = _sp(_link_pos())
		var core: Color = _link_core(_link_light())
		draw_circle(lp, 2.5, OUTLINE)
		draw_circle(lp, 1.9, LINK_DISC)
		draw_arc(lp, 1.35, 0.0, TAU, 12, core, 1.0, true)
		draw_circle(lp, 0.6, core)
	_draw_face()


func _draw_face() -> void:
	var eye: Vector2 = _hp(Vector2(4.7, -0.7))
	var ha: float = _head_ang
	if _lid >= 1.9:
		# Unconscious: a closed lid line, no glint.
		draw_line(_sp(eye + Vector2(-1.5, -0.2).rotated(ha)), _sp(eye + Vector2(1.3, 0.3).rotated(ha)),
				OUTLINE, 1.1, true)
	else:
		# Vacant: a small dark eye under a heavy lid, a tired shadow below and
		# a faint teal glint (Adam behind the eyes).
		var open: float = 1.0 - clampf(_lid, 0.0, 1.0)  # 1 = wide (wind-up)
		draw_line(_sp(eye + Vector2(-1.2, 1.3).rotated(ha)), _sp(eye + Vector2(1.0, 1.2).rotated(ha)),
				SKIN_SHADE, 0.9, true)
		draw_circle(_sp(eye), 0.75 + 0.3 * open, EYE_DARK)
		var lid_y: float = lerpf(-0.5, -1.4, open)
		draw_line(_sp(eye + Vector2(-1.6, lid_y - 0.1).rotated(ha)), _sp(eye + Vector2(1.3, lid_y + 0.1).rotated(ha)),
				OUTLINE, 1.1, true)
		draw_circle(_sp(eye + Vector2(0.35, 0.1).rotated(ha)), 0.45, LINK_TEAL)
	# Slack lower lip, brow.
	draw_line(_sp(_hp(Vector2(6.2, 4.6))), _sp(_hp(Vector2(7.3, 4.8))), OUTLINE, 0.9, true)
	draw_line(_sp(_hp(Vector2(3.4, -2.9))), _sp(_hp(Vector2(6.5, -2.5))), HAIR_SHADE, 1.0, true)


## Facing left, the Link sits on the far side of the skull: only its glow
## spills past the back of the head (drawn before the head so the skull
## occludes the disc itself).
func _draw_far_link_spill() -> void:
	var light: Array = _link_light()
	var level: float = light[1]
	if level <= 0.0:
		return
	var c: Color = light[0]
	c.a = 0.38 * level
	var r: float = 4.6 if link_state() != Link.TELL else 5.8
	draw_circle(_sp(_link_pos() + Vector2(-1.2, 0.0)), r, c)


func _draw_speed_lines() -> void:
	var c := RIM
	c.a = 0.45
	var back: Vector2 = _tp(18.0, -12.0)
	for i in 3:
		var y: float = -8.0 + 7.0 * float(i)
		var start: Vector2 = back + Vector2(-2.0 - 2.0 * float(i % 2), y)
		draw_line(_sp(start), _sp(start + Vector2(-13.0 + 3.0 * float(i), 0.0)), c, 1.4, true)


func _draw_burnout_sparks() -> void:
	var lp: Vector2 = _link_pos()
	var k: float = 1.0 - defeat_progress / 0.18
	var c := LINK_BURN
	c.a = k
	for i in 4:
		var ang: float = -PI * 0.5 + (float(i) - 1.5) * 0.7 - PI * 0.35
		var dir := Vector2(cos(ang), sin(ang))
		draw_line(_sp(lp + dir * 2.5), _sp(lp + dir * (2.5 + 4.0 * k)), c, 1.1, true)


## Hit feedback is a shape change (a small jagged impact burst), never
## colour alone (07-acceptance/interface-and-accessibility.md).
func _draw_hit_burst() -> void:
	var t: float = hit_flash_timer / HIT_FLASH_TIME
	var center := Vector2(0.0, -HEIGHT * 0.6)
	var pts := PackedVector2Array()
	var spikes := 8
	for i in range(spikes * 2):
		var ang: float = TAU * i / float(spikes * 2)
		var r: float = (HEIGHT * 0.34 if i % 2 == 0 else HEIGHT * 0.16) * t
		pts.append(center + Vector2(cos(ang), sin(ang)) * r)
	var c := HIT_FLASH
	c.a = 0.7 * t
	draw_colored_polygon(pts, c)


# --- glow (the additive "Glow" child) ----------------------------------------------------

## Flat, hard-edged glow shapes (style guide: no soft airbrushed light),
## added on top of the body: the Link, the collar repeater and the eyes.
func _draw_glow() -> void:
	if _glow == null:
		return
	var light: Array = _link_light()
	var c: Color = light[0]
	var level: float = light[1]
	if level > 0.0:
		var big: float = 1.5 if link_state() == Link.TELL else 1.0
		if _near(R):
			var lp: Vector2 = _sp(_link_pos())
			_glow_disc(lp, 5.4 * big, c, 0.2 * level)
			_glow_disc(lp, 3.0 * big, c, 0.4 * level)
		var rp: Vector2 = _sp(_repeater_pos())
		_glow_disc(rp, 4.2 * big, c, 0.2 * level)
		_glow_disc(rp, 2.4 * big, c, 0.4 * level)
	if _lid < 1.9 and defeat_progress < 0.0:
		var eye: Vector2 = _hp(Vector2(4.7, -0.7))
		_glow_disc(_sp(eye + Vector2(0.35, 0.1).rotated(_head_ang)), 1.4, LINK_TEAL, 0.3)


func _glow_disc(pos: Vector2, r: float, c: Color, a: float) -> void:
	var col := c
	col.a = a
	_glow.draw_circle(pos, r, col)
