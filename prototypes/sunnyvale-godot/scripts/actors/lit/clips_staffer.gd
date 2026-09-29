extends RefCounted
## LK01 Staffer: hand-keyed placeholder clips for the human lit rig
## (degrees; see rig_animator.gd for the conventions). Adam walks the body
## upright like a puppet: stiff, too even, arms hanging dead, then a sudden
## low crouch and a fast two-handed grab. A converted Mixamo clip of the
## same name in assets/characters/lit/staffer/mocap/ replaces one of these.

const STAND := {"pelvis": 0, "torso": 1, "head": 6, "near_upper_arm": 2, "near_forearm": -4, "near_hand": 4,
		"far_upper_arm": -2, "far_forearm": -6, "far_hand": 4, "near_thigh": -1, "near_shin": 2,
		"far_thigh": 2, "far_shin": 2}

const CLIPS := {
	# Standing in a doorway before Adam turns it loose: head bowed, a slow sway.
	"dormant": {"length": 4.0, "loop": true, "keys": [
		[0.0, STAND],
		[2.0, {"pelvis": 0, "torso": 2.5, "head": 10, "near_upper_arm": 3, "near_forearm": -4, "near_hand": 4,
			"far_upper_arm": -1, "far_forearm": -6, "far_hand": 4, "near_thigh": -1, "near_shin": 2,
			"far_thigh": 2, "far_shin": 2, "root": Vector2(0.4, 0.2)}],
		[4.0, STAND]]},
	# A stiff, even puppet walk: little knee, no arm swing, head held level.
	"shamble": {"length": 1.2, "loop": true, "keys": [
		[0.0, {"pelvis": 1, "torso": 0, "head": 2, "near_thigh": -18, "near_shin": 3, "far_thigh": 16,
			"far_shin": 8, "near_upper_arm": 3, "near_forearm": -3, "far_upper_arm": -2, "far_forearm": -4,
			"near_foot": 8, "far_foot": -9}],
		[0.3, {"pelvis": 0, "torso": 0, "head": 2, "near_thigh": -3, "near_shin": 3, "far_thigh": -8,
			"far_shin": 32, "near_upper_arm": 2, "near_forearm": -3, "far_upper_arm": -2, "far_forearm": -4,
			"far_foot": -6}],
		[0.6, {"pelvis": 1, "torso": 0, "head": 2, "near_thigh": 16, "near_shin": 8, "far_thigh": -18,
			"far_shin": 3, "near_upper_arm": 2, "near_forearm": -3, "far_upper_arm": -2, "far_forearm": -4,
			"near_foot": -9, "far_foot": 8}],
		[0.9, {"pelvis": 0, "torso": 0, "head": 2, "near_thigh": -8, "near_shin": 32, "far_thigh": -3,
			"far_shin": 3, "near_upper_arm": 2, "near_forearm": -3, "far_upper_arm": -2, "far_forearm": -4,
			"near_foot": -6}],
		[1.2, {"pelvis": 1, "torso": 0, "head": 2, "near_thigh": -18, "near_shin": 3, "far_thigh": 16,
			"far_shin": 8, "near_upper_arm": 3, "near_forearm": -3, "far_upper_arm": -2, "far_forearm": -4,
			"near_foot": 8, "far_foot": -9}]]},
	# The tell: a sudden low crouch, both hands forward at waist height.
	"windup": {"length": 0.65, "loop": false, "keys": [
		[0.0, STAND],
		[0.12, {"pelvis": 6, "torso": 14, "head": -10, "near_upper_arm": -40, "near_forearm": -30, "near_hand": 10,
			"far_upper_arm": -46, "far_forearm": -26, "far_hand": 10, "near_thigh": -26, "near_shin": 40,
			"far_thigh": -8, "far_shin": 30}],
		[0.65, {"pelvis": 8, "torso": 26, "head": -18, "near_upper_arm": -66, "near_forearm": -16, "near_hand": 14,
			"far_upper_arm": -72, "far_forearm": -12, "far_hand": 14, "near_thigh": -40, "near_shin": 62,
			"far_thigh": -14, "far_shin": 48}]]},
	# The committed grab: long, low and fast, arms straight out.
	"lunge": {"length": 0.3, "loop": false, "keys": [
		[0.0, {"pelvis": 8, "torso": 26, "head": -18, "near_upper_arm": -66, "near_forearm": -16, "near_hand": 14,
			"far_upper_arm": -72, "far_forearm": -12, "far_hand": 14, "near_thigh": -40, "near_shin": 62,
			"far_thigh": -14, "far_shin": 48}],
		[0.3, {"pelvis": 14, "torso": 44, "head": -30, "near_upper_arm": -88, "near_forearm": -4, "near_hand": 4,
			"far_upper_arm": -92, "far_forearm": -2, "far_hand": 4, "near_thigh": -42, "near_shin": 30,
			"far_thigh": 26, "far_shin": 20}]]},
	# The stumble after a grab: off balance, arms loose — the punish window.
	"stumble": {"length": 0.8, "loop": false, "keys": [
		[0.0, {"pelvis": 14, "torso": 44, "head": -30, "near_upper_arm": -88, "near_forearm": -4, "near_hand": 4,
			"far_upper_arm": -92, "far_forearm": -2, "far_hand": 4, "near_thigh": -42, "near_shin": 30,
			"far_thigh": 26, "far_shin": 20}],
		[0.35, {"pelvis": 10, "torso": 30, "head": 14, "near_upper_arm": -30, "near_forearm": -20, "near_hand": 20,
			"far_upper_arm": -10, "far_forearm": -30, "far_hand": 20, "near_thigh": -24, "near_shin": 36,
			"far_thigh": 10, "far_shin": 24}],
		[0.8, {"pelvis": 4, "torso": 12, "head": 10, "near_upper_arm": -6, "near_forearm": -8, "near_hand": 8,
			"far_upper_arm": -4, "far_forearm": -10, "far_hand": 8, "near_thigh": -8, "near_shin": 14,
			"far_thigh": 4, "far_shin": 10}]]},
}
