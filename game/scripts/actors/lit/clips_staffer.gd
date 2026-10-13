extends RefCounted
## LK01 Staffer: hand-keyed placeholder clips for the human lit rig
## (degrees; see rig_animator.gd for the conventions). C57 (2026-10-11): no
## zombie look; Adam drives an alert, upright body with a brisk, even walk,
## then a sudden low crouch and a fast two-handed grab. A converted Mixamo clip of the
## same name in assets/characters/lit/staffer/mocap/ replaces one of these.
## `lanyard` (the ID card on its lanyard, a pixel-rig joint on the torso) hangs
## back toward upright when the body leans, and swings a few degrees as he walks.

const STAND := {"pelvis": 0, "torso": 0, "head": -2, "near_upper_arm": 3, "near_forearm": -8, "near_hand": 4,
		"far_upper_arm": -3, "far_forearm": -10, "far_hand": 4, "near_thigh": -3, "near_shin": 3,
		"far_thigh": 3, "far_shin": 3, "far_foot": -6}

const CLIPS := {
	# Standing by before Adam sends it (C57: alert, not asleep): upright and still, head level,
	# then one crisp look ahead and back, as if listening.
	"dormant": {"length": 4.0, "loop": true, "keys": [
		[0.0, STAND],
		[1.6, STAND],
		[1.8, {"pelvis": 0, "torso": -1, "head": -7, "near_upper_arm": 3, "near_forearm": -8, "near_hand": 4,
			"far_upper_arm": -3, "far_forearm": -10, "far_hand": 4, "near_thigh": -3, "near_shin": 3,
			"far_thigh": 3, "far_shin": 3, "far_foot": -6}],
		[2.6, {"pelvis": 0, "torso": -1, "head": -7, "near_upper_arm": 3, "near_forearm": -8, "near_hand": 4,
			"far_upper_arm": -3, "far_forearm": -10, "far_hand": 4, "near_thigh": -3, "near_shin": 3,
			"far_thigh": 3, "far_shin": 3, "far_foot": -6}],
		[2.8, STAND],
		[4.0, STAND]]},
	# A brisk, even, purposeful walk (C57; the clip keeps its old name): upright with a slight
	# forward lean, head level, a clean arm swing against the legs, every step the same.
	"shamble": {"length": 1.0, "loop": true, "keys": [
		[0.0, {"lanyard": 4, "pelvis": 2, "torso": 4, "head": -4, "near_thigh": -26, "near_shin": 6, "far_thigh": 20,
			"far_shin": 14, "near_upper_arm": 22, "near_forearm": -16, "far_upper_arm": -24, "far_forearm": -20,
			"near_foot": 10, "far_foot": -10}],
		[0.25, {"lanyard": -2, "pelvis": 1, "torso": 4, "head": -4, "near_thigh": -4, "near_shin": 6, "far_thigh": -10,
			"far_shin": 44, "near_upper_arm": 2, "near_forearm": -12, "far_upper_arm": -2, "far_forearm": -14,
			"far_foot": -6}],
		[0.5, {"lanyard": 4, "pelvis": 2, "torso": 4, "head": -4, "near_thigh": 20, "near_shin": 14, "far_thigh": -26,
			"far_shin": 6, "near_upper_arm": -24, "near_forearm": -20, "far_upper_arm": 22, "far_forearm": -16,
			"near_foot": -10, "far_foot": 10}],
		[0.75, {"lanyard": -2, "pelvis": 1, "torso": 4, "head": -4, "near_thigh": -10, "near_shin": 44, "far_thigh": -4,
			"far_shin": 6, "near_upper_arm": -2, "near_forearm": -14, "far_upper_arm": 2, "far_forearm": -12,
			"near_foot": -6}],
		[1.0, {"lanyard": 4, "pelvis": 2, "torso": 4, "head": -4, "near_thigh": -26, "near_shin": 6, "far_thigh": 20,
			"far_shin": 14, "near_upper_arm": 22, "near_forearm": -16, "far_upper_arm": -24, "far_forearm": -20,
			"near_foot": 10, "far_foot": -10}]]},
	# The tell: a sudden low crouch, both hands forward at waist height.
	"windup": {"length": 0.65, "loop": false, "keys": [
		[0.0, STAND],
		[0.12, {"lanyard": -17, "pelvis": 6, "torso": 14, "head": -10, "near_upper_arm": -40, "near_forearm": -30, "near_hand": 10,
			"far_upper_arm": -46, "far_forearm": -26, "far_hand": 10, "near_thigh": -26, "near_shin": 40,
			"far_thigh": -8, "far_shin": 30}],
		[0.65, {"lanyard": -28, "pelvis": 8, "torso": 26, "head": -18, "near_upper_arm": -66, "near_forearm": -16, "near_hand": 14,
			"far_upper_arm": -72, "far_forearm": -12, "far_hand": 14, "near_thigh": -40, "near_shin": 62,
			"far_thigh": -14, "far_shin": 48}]]},
	# The committed grab: long, low and fast, arms straight out.
	"lunge": {"length": 0.3, "loop": false, "keys": [
		[0.0, {"lanyard": -28, "pelvis": 8, "torso": 26, "head": -18, "near_upper_arm": -66, "near_forearm": -16, "near_hand": 14,
			"far_upper_arm": -72, "far_forearm": -12, "far_hand": 14, "near_thigh": -40, "near_shin": 62,
			"far_thigh": -14, "far_shin": 48}],
		[0.3, {"lanyard": -45, "pelvis": 14, "torso": 44, "head": -30, "near_upper_arm": -88, "near_forearm": -4, "near_hand": 4,
			"far_upper_arm": -92, "far_forearm": -2, "far_hand": 4, "near_thigh": -42, "near_shin": 30,
			"far_thigh": 26, "far_shin": 20}]]},
	# The stumble after a grab: off balance, arms loose — the punish window.
	"stumble": {"length": 0.8, "loop": false, "keys": [
		[0.0, {"lanyard": -45, "pelvis": 14, "torso": 44, "head": -30, "near_upper_arm": -88, "near_forearm": -4, "near_hand": 4,
			"far_upper_arm": -92, "far_forearm": -2, "far_hand": 4, "near_thigh": -42, "near_shin": 30,
			"far_thigh": 26, "far_shin": 20}],
		[0.35, {"lanyard": -32, "pelvis": 10, "torso": 30, "head": 14, "near_upper_arm": -30, "near_forearm": -20, "near_hand": 20,
			"far_upper_arm": -10, "far_forearm": -30, "far_hand": 20, "near_thigh": -24, "near_shin": 36,
			"far_thigh": 10, "far_shin": 24}],
		[0.8, {"lanyard": -13, "pelvis": 4, "torso": 12, "head": 10, "near_upper_arm": -6, "near_forearm": -8, "near_hand": 8,
			"far_upper_arm": -4, "far_forearm": -10, "far_hand": 8, "near_thigh": -8, "near_shin": 14,
			"far_thigh": 4, "far_shin": 10}]]},
}
