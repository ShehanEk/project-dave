extends RefCounted
## SE02 Sidearm Guard: hand-keyed clips (degrees; rig_animator.gd has the conventions)
## for the human lit rig with the pistol prop on the near hand (gunner.gd). Until the
## SE02 sheets exist he wears the Night Guard HD rig without its baton, so these clips
## key the guard's skeleton (no baton key). Poses checked against the rig's numbers:
## in "aim" the deep bent-knee two-hand stance (leaning in, the rear heel up) holds both
## arms out low and the barrel level, the muzzle about 0.5 H (50 px) above the floor,
## where the round leaves (the brief); both arms share one shoulder pivot and the same
## angles, so the far (support) hand meets the grip. gunner.gd adds the aim angle to both upper arms for a shot at another floor.

const IDLE_A := {"pelvis": 0, "torso": 2, "head": -2, "near_upper_arm": 6, "near_forearm": -30, "near_hand": -40,
		"far_upper_arm": -4, "far_forearm": -14, "near_thigh": -3, "near_shin": 4, "near_foot": -1,
		"far_thigh": 4, "far_shin": 3, "far_foot": -7}
const IDLE_B := {"pelvis": 0, "torso": 3.4, "head": -3.6, "near_upper_arm": 7.5, "near_forearm": -32,
		"near_hand": -40, "far_upper_arm": -5.5, "far_forearm": -16, "near_thigh": -3, "near_shin": 4,
		"near_foot": -1, "far_thigh": 4, "far_shin": 3, "far_foot": -7, "root": Vector2(0, 0.3)}
## Low ready: both hands on the pistol in front of the belt, the muzzle down and ahead.
const READY_A := {"pelvis": 2, "torso": 5, "head": -4, "near_upper_arm": -30, "near_forearm": -36, "near_hand": -20,
		"far_upper_arm": -26, "far_forearm": -40, "far_hand": -14, "near_thigh": -10, "near_shin": 14,
		"near_foot": -4, "far_thigh": 8, "far_shin": 10, "far_foot": -12}
const READY_B := {"pelvis": 2, "torso": 6, "head": -5, "near_upper_arm": -31, "near_forearm": -35, "near_hand": -20,
		"far_upper_arm": -27, "far_forearm": -39, "far_hand": -14, "near_thigh": -10, "near_shin": 15,
		"near_foot": -4, "far_thigh": 8, "far_shin": 11, "far_foot": -12, "root": Vector2(0, 0.4)}
## The tell: a deep bent-knee two-hand stance, both arms straight out and low, the barrel
## level, the muzzle at about 0.5 H.
const AIM := {"pelvis": 8, "torso": 24, "head": -22, "near_upper_arm": -96, "near_forearm": -2, "near_hand": -24,
		"far_upper_arm": -94, "far_forearm": -4, "far_hand": -22, "near_thigh": -66, "near_shin": 108,
		"near_foot": -42, "far_thigh": 14, "far_shin": 80, "far_foot": -92}
const RECOIL := {"pelvis": 7, "torso": 21, "head": -20, "near_upper_arm": -104, "near_forearm": -6, "near_hand": -30,
		"far_upper_arm": -102, "far_forearm": -8, "far_hand": -28, "near_thigh": -66, "near_shin": 108,
		"near_foot": -42, "far_thigh": 14, "far_shin": 80, "far_foot": -92, "root": Vector2(-1.5, 0)}
## The slide rack, rooted, eyes on the pistol (the opening): the pistol up at the chest,
## the support hand pulling the slide back, then pushing it home.
const RACK_A := {"pelvis": 3, "torso": 14, "head": 14, "near_upper_arm": -20, "near_forearm": -70, "near_hand": -10,
		"far_upper_arm": -8, "far_forearm": -92, "far_hand": -20, "near_thigh": -14, "near_shin": 20,
		"near_foot": -6, "far_thigh": 10, "far_shin": 16, "far_foot": -18}
const RACK_B := {"pelvis": 3, "torso": 15, "head": 16, "near_upper_arm": -20, "near_forearm": -70, "near_hand": -10,
		"far_upper_arm": 6, "far_forearm": -78, "far_hand": -30, "near_thigh": -14, "near_shin": 20,
		"near_foot": -6, "far_thigh": 10, "far_shin": 16, "far_foot": -18, "root": Vector2(0, 0.6)}
const HIT_A := {"pelvis": -3, "torso": -10, "head": -14, "near_upper_arm": -38, "near_forearm": -60,
		"near_hand": -10, "far_upper_arm": -48, "far_forearm": -52, "near_thigh": 6,
		"near_shin": 14, "far_thigh": -8, "far_shin": 18, "root": Vector2(-3.0, 1.5)}
const HIT_B := {"pelvis": -4, "torso": -13, "head": -17, "near_upper_arm": -42, "near_forearm": -62,
		"near_hand": -10, "far_upper_arm": -52, "far_forearm": -54, "near_thigh": 8,
		"near_shin": 16, "far_thigh": -10, "far_shin": 20, "root": Vector2(-3.8, 2.0)}


const CLIPS := {
	"idle": {"length": 3.2, "loop": true, "keys": [[0.0, IDLE_A], [1.6, IDLE_B], [3.2, IDLE_A]]},
	"walk": {"length": 1.0, "loop": true, "keys": [
		[0.0, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": -24, "near_shin": 6, "far_thigh": 20, "far_shin": 14, "near_foot": 10, "far_foot": -12, "near_upper_arm": 6, "near_forearm": -32, "near_hand": -40, "far_upper_arm": -6, "far_forearm": -18}],
		[0.25, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": -4, "near_shin": 5, "far_thigh": -12, "far_shin": 52, "far_foot": -8, "near_upper_arm": 6, "near_forearm": -32, "near_hand": -40, "far_upper_arm": -6, "far_forearm": -18}],
		[0.5, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": 20, "near_shin": 14, "far_thigh": -24, "far_shin": 6, "near_foot": -12, "far_foot": 10, "near_upper_arm": 6, "near_forearm": -32, "near_hand": -40, "far_upper_arm": -6, "far_forearm": -18}],
		[0.75, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": -12, "near_shin": 52, "far_thigh": -4, "far_shin": 5, "near_foot": -8, "near_upper_arm": 6, "near_forearm": -32, "near_hand": -40, "far_upper_arm": -6, "far_forearm": -18}],
		[1.0, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": -24, "near_shin": 6, "far_thigh": 20, "far_shin": 14, "near_foot": 10, "far_foot": -12, "near_upper_arm": 6, "near_forearm": -32, "near_hand": -40, "far_upper_arm": -6, "far_forearm": -18}]]},
	# Walking in to range with the pistol at low ready.
	"stalk": {"length": 0.8, "loop": true, "keys": [
		[0.0, {"pelvis": 3, "torso": 8, "head": -6, "near_thigh": -24, "near_shin": 6, "far_thigh": 20, "far_shin": 14, "near_foot": 10, "far_foot": -12, "near_upper_arm": -30, "near_forearm": -36, "near_hand": -20, "far_upper_arm": -26, "far_forearm": -40, "far_hand": -14}],
		[0.2, {"pelvis": 3, "torso": 8, "head": -6, "near_thigh": -4, "near_shin": 5, "far_thigh": -12, "far_shin": 52, "far_foot": -8, "near_upper_arm": -30, "near_forearm": -36, "near_hand": -20, "far_upper_arm": -26, "far_forearm": -40, "far_hand": -14}],
		[0.4, {"pelvis": 3, "torso": 8, "head": -6, "near_thigh": 20, "near_shin": 14, "far_thigh": -24, "far_shin": 6, "near_foot": -12, "far_foot": 10, "near_upper_arm": -30, "near_forearm": -36, "near_hand": -20, "far_upper_arm": -26, "far_forearm": -40, "far_hand": -14}],
		[0.6, {"pelvis": 3, "torso": 8, "head": -6, "near_thigh": -12, "near_shin": 52, "far_thigh": -4, "far_shin": 5, "near_foot": -8, "near_upper_arm": -30, "near_forearm": -36, "near_hand": -20, "far_upper_arm": -26, "far_forearm": -40, "far_hand": -14}],
		[0.8, {"pelvis": 3, "torso": 8, "head": -6, "near_thigh": -24, "near_shin": 6, "far_thigh": 20, "far_shin": 14, "near_foot": 10, "far_foot": -12, "near_upper_arm": -30, "near_forearm": -36, "near_hand": -20, "far_upper_arm": -26, "far_forearm": -40, "far_hand": -14}]]},
	"ready": {"length": 2.4, "loop": true, "keys": [[0.0, READY_A], [1.2, READY_B], [2.4, READY_A]]},
	# Into the stance and held there (the tell).
	"aim": {"length": 0.24, "loop": false, "keys": [[0.0, READY_A], [0.24, AIM]]},
	"fire": {"length": 0.18, "loop": false, "keys": [[0.0, AIM], [0.04, RECOIL], [0.18, AIM]]},
	"rack": {"length": 1.2, "loop": false, "keys": [
		[0.0, AIM], [0.22, RACK_A], [0.5, RACK_B], [0.7, RACK_A], [0.95, RACK_B], [1.2, READY_A]]},
	"hit": {"length": 0.45, "loop": false, "keys": [[0.0, HIT_A], [0.12, HIT_B], [0.45, READY_A]]},
}
