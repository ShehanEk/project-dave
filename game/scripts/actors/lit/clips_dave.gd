extends RefCounted
## H01 Dave Harlan: hand-keyed clips for his pixel-art lit rig (degrees; see
## rig_animator.gd for the conventions), played by hero_rig_visual.gd. They
## take over from the old Rook frames one for one: idle (two breathing beats,
## IDLE_BREATH_TIME 0.7 each), run (six keys over one stride cycle, sampled by
## hero.gd's stride phase, so the cadence follows his speed and runs backward
## when he backpedals), jump_rise, jump_fall, land (LAND_SQUASH_TIME 0.12),
## hurt (HIT_POSE_TIME 0.2), interact (INTERACT_POSE_TIME 0.35: the free hand
## reaches out to plug in) and defeated (he drops to one knee).
##
## C57 (2026-10-11): reworked for an energetic young man: a ready, springy idle, a driving run
## with a flight phase ("lift") between steps, a springy take-off and a separate backpedal.
##
## The near arm holds the Scrapjack: while the gun shows, hero_rig_visual.gd
## poses it every tick so the fist stays on the gun's grip (the aim), and the
## near-arm keys here only matter when it does not (defeated). `hood` (the
## hoodie's hood behind the neck) sways a few degrees; `lanyard` (the revoked
## ID badge) is counter-rotated against the lean of the pelvis and torso so the
## card hangs, and swings as he runs.

## The aiming arm's keys, used only when the visual does not aim it.
const AIM := {"near_upper_arm": -84, "near_forearm": -14, "near_hand": 0}

## Idle (C57: an energetic 28-year-old, not a tired one): a ready stance, feet apart, knees a
## little bent, chest up and head up, with a light bounce on the second beat. Each foot is turned
## back by its leg's lean (foot = -(thigh + shin)), so both soles stand flat on the floor.
const IDLE_A := {"pelvis": 1, "torso": 4, "head": -5, "hood": 0, "lanyard": -4,
		"far_upper_arm": 6, "far_forearm": -34, "far_hand": 4,
		"near_thigh": -12, "near_shin": 12, "near_foot": 0, "far_thigh": 10, "far_shin": 10, "far_foot": -20,
		"near_upper_arm": -84, "near_forearm": -14, "near_hand": 0}
## The second beat: weight settles into the knees, then springs back up.
const IDLE_B := {"pelvis": 2, "torso": 6, "head": -6, "hood": 3, "lanyard": -6,
		"far_upper_arm": 9, "far_forearm": -38, "far_hand": 4,
		"near_thigh": -15, "near_shin": 18, "near_foot": -3, "far_thigh": 8, "far_shin": 16, "far_foot": -24,
		"near_upper_arm": -84, "near_forearm": -14, "near_hand": 0, "lift": -0.6}

## Run keys (one stride cycle = 1.0): contact, passing (the body lowest, the knee high), push-off
## into the flight (the body lifted off the floor), then the same with the legs swapped. A
## driving forward lean with the head up, long strides, the free arm pumping against the far leg.
const RUN_0 := {"pelvis": 6, "torso": 13, "head": -11, "hood": -4, "lanyard": -16,
		"near_thigh": -48, "near_shin": 20, "near_foot": -10, "far_thigh": 34, "far_shin": 46, "far_foot": 20,
		"far_upper_arm": -44, "far_forearm": -70, "near_upper_arm": -84, "near_forearm": -14, "lift": 0.5}
const RUN_1 := {"pelvis": 5, "torso": 14, "head": -12, "hood": 2, "lanyard": -8,
		"near_thigh": -16, "near_shin": 36, "near_foot": 4, "far_thigh": -18, "far_shin": 104, "far_foot": 12,
		"far_upper_arm": -6, "far_forearm": -62, "near_upper_arm": -84, "near_forearm": -14, "lift": -1.0}
const RUN_2 := {"pelvis": 6, "torso": 13, "head": -11, "hood": 6, "lanyard": -12,
		"near_thigh": 26, "near_shin": 22, "near_foot": 22, "far_thigh": -52, "far_shin": 56, "far_foot": -8,
		"far_upper_arm": 36, "far_forearm": -46, "near_upper_arm": -84, "near_forearm": -14, "lift": 3.0}
const RUN_3 := {"pelvis": 6, "torso": 13, "head": -11, "hood": -4, "lanyard": -16,
		"far_thigh": -48, "far_shin": 20, "far_foot": -10, "near_thigh": 34, "near_shin": 46, "near_foot": 20,
		"far_upper_arm": 40, "far_forearm": -40, "near_upper_arm": -84, "near_forearm": -14, "lift": 0.5}
const RUN_4 := {"pelvis": 5, "torso": 14, "head": -12, "hood": 2, "lanyard": -8,
		"far_thigh": -16, "far_shin": 36, "far_foot": 4, "near_thigh": -18, "near_shin": 104, "near_foot": 12,
		"far_upper_arm": 8, "far_forearm": -52, "near_upper_arm": -84, "near_forearm": -14, "lift": -1.0}
const RUN_5 := {"pelvis": 6, "torso": 13, "head": -11, "hood": 6, "lanyard": -12,
		"far_thigh": 26, "far_shin": 22, "far_foot": 22, "near_thigh": -52, "near_shin": 56, "near_foot": -8,
		"far_upper_arm": -34, "far_forearm": -66, "near_upper_arm": -84, "near_forearm": -14, "lift": 3.0}

## Backpedal (moving away from the aim while firing): upright, leaning a little back, short
## quick steps with the knees bent, the free arm out for balance. Symmetric, so it reads the
## same played backward (the stride phase runs backward while he backs off).
const BACK_0 := {"pelvis": -1, "torso": -3, "head": -4, "hood": 2, "lanyard": 4,
		"near_thigh": -22, "near_shin": 22, "near_foot": -4, "far_thigh": 16, "far_shin": 30, "far_foot": 8,
		"far_upper_arm": -16, "far_forearm": -44, "near_upper_arm": -84, "near_forearm": -14, "lift": 0.0}
const BACK_1 := {"pelvis": -1, "torso": -2, "head": -4, "hood": 0, "lanyard": 2,
		"near_thigh": -4, "near_shin": 18, "near_foot": 2, "far_thigh": -6, "far_shin": 62, "far_foot": 8,
		"far_upper_arm": -8, "far_forearm": -46, "near_upper_arm": -84, "near_forearm": -14, "lift": 1.2}
const BACK_2 := {"pelvis": -1, "torso": -3, "head": -4, "hood": 2, "lanyard": 4,
		"far_thigh": -22, "far_shin": 22, "far_foot": -4, "near_thigh": 16, "near_shin": 30, "near_foot": 8,
		"far_upper_arm": -2, "far_forearm": -40, "near_upper_arm": -84, "near_forearm": -14, "lift": 0.0}
const BACK_3 := {"pelvis": -1, "torso": -2, "head": -4, "hood": 0, "lanyard": 2,
		"far_thigh": -4, "far_shin": 18, "far_foot": 2, "near_thigh": -6, "near_shin": 62, "near_foot": 8,
		"far_upper_arm": -10, "far_forearm": -44, "near_upper_arm": -84, "near_forearm": -14, "lift": 1.2}

## Rising: a springy take-off, the lead knee driven up, the trailing leg still extended, the
## free arm thrown up and forward.
const RISE := {"pelvis": -2, "torso": 6, "head": -8, "hood": 10, "lanyard": 8,
		"near_thigh": -70, "near_shin": 92, "near_foot": 6, "far_thigh": 18, "far_shin": 34, "far_foot": 24,
		"far_upper_arm": -64, "far_forearm": -40, "far_hand": -6, "near_upper_arm": -84, "near_forearm": -14}
## Falling: legs reaching down for the floor, the free arm out ahead for balance.
const FALL := {"pelvis": -4, "torso": -2, "head": 0, "hood": -8, "lanyard": -24,
		"near_thigh": -26, "near_shin": 24, "near_foot": 10, "far_thigh": 12, "far_shin": 30, "far_foot": 18,
		"far_upper_arm": -72, "far_forearm": -34, "far_hand": -10, "near_upper_arm": -84, "near_forearm": -14}
## Landing: a deep squash, feet flat.
const LAND := {"pelvis": 8, "torso": 20, "head": -14, "hood": 6, "lanyard": -24,
		"near_thigh": -62, "near_shin": 84, "near_foot": -22, "far_thigh": -40, "far_shin": 84, "far_foot": -44,
		"far_upper_arm": -30, "far_forearm": -40, "near_upper_arm": -84, "near_forearm": -14}
## Shot: the head snaps back, he rocks back onto his heels, the free arm flies up.
const HIT_A := {"pelvis": -5, "torso": -14, "head": -16, "hood": 10, "lanyard": 18,
		"near_thigh": 4, "near_shin": 10, "far_thigh": -36, "far_shin": 30, "far_foot": -8,
		"far_upper_arm": -70, "far_forearm": -40, "far_hand": -20, "near_upper_arm": -84, "near_forearm": -14}
const HIT_B := {"pelvis": -6, "torso": -17, "head": -20, "hood": 12, "lanyard": 22,
		"near_thigh": 6, "near_shin": 12, "far_thigh": -40, "far_shin": 34, "far_foot": -10,
		"far_upper_arm": -78, "far_forearm": -44, "far_hand": -20, "near_upper_arm": -84, "near_forearm": -14}
## Plugging in: he leans in and the free hand reaches out at chest height,
## below the gun arm.
const REACH := {"pelvis": 4, "torso": 12, "head": 8, "hood": -2, "lanyard": -16,
		"near_thigh": -18, "near_shin": 16, "near_foot": 2, "far_thigh": 8, "far_shin": 10,
		"far_upper_arm": -52, "far_forearm": -20, "far_hand": -18, "near_upper_arm": -84, "near_forearm": -14}
## Down: on the near knee, the far foot planted, slumped over it, head down,
## the gun arm hanging (the gun is hidden).
const SLUMP := {"pelvis": 6, "torso": 10, "head": 6, "hood": -6, "lanyard": -16,
		"near_thigh": -4, "near_shin": 34, "near_foot": 6, "far_thigh": -46, "far_shin": 52, "far_foot": 0,
		"far_upper_arm": -24, "far_forearm": -30, "near_upper_arm": 6, "near_forearm": -20, "near_hand": 6}
const KNEEL := {"pelvis": 10, "torso": 30, "head": 20, "hood": -22, "lanyard": -40,
		"near_thigh": -5, "near_shin": 85, "near_foot": 31, "far_thigh": -115, "far_shin": 100, "far_foot": 5,
		"far_upper_arm": -30, "far_forearm": -40, "far_hand": 10, "near_upper_arm": -12, "near_forearm": -34, "near_hand": 14}

const CLIPS := {
	"idle": {"length": 1.2, "loop": true, "keys": [[0.0, IDLE_A], [0.6, IDLE_B], [1.2, IDLE_A]]},
	# One stride cycle; hero_rig_visual.gd sets the time from hero.gd's stride phase.
	"run": {"length": 1.0, "loop": true, "keys": [
		[0.0, RUN_0], [1.0 / 6.0, RUN_1], [2.0 / 6.0, RUN_2], [0.5, RUN_3], [4.0 / 6.0, RUN_4], [5.0 / 6.0, RUN_5],
		[1.0, RUN_0]]},
	# One stride cycle like "run", driven by the stride phase (it plays backward as he backs off).
	"backpedal": {"length": 1.0, "loop": true, "keys": [
		[0.0, BACK_0], [0.25, BACK_1], [0.5, BACK_2], [0.75, BACK_3], [1.0, BACK_0]]},
	"jump_rise": {"length": 0.2, "loop": false, "keys": [[0.0, RISE], [0.2, RISE]]},
	"jump_fall": {"length": 0.3, "loop": false, "keys": [[0.0, RISE], [0.3, FALL]]},
	"land": {"length": 0.12, "loop": false, "keys": [[0.0, LAND], [0.12, LAND]]},
	"hurt": {"length": 0.2, "loop": false, "keys": [[0.0, HIT_A], [0.07, HIT_B], [0.2, HIT_A]]},
	"interact": {"length": 0.35, "loop": false, "keys": [[0.0, IDLE_A], [0.12, REACH], [0.35, REACH]]},
	"defeated": {"length": 0.6, "loop": false, "keys": [[0.0, HIT_B], [0.25, SLUMP], [0.6, KNEEL]]},
}
