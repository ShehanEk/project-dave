extends RefCounted
## SE01 Night Guard: hand-keyed clips for the human lit rig (degrees; see
## rig_animator.gd for the conventions). All hand-keyed (C38): the Mixamo
## clips flattened badly onto the side-on cutouts (the arm thrown straight
## up, a deep bow for a flinch, both arms reaching out in the recovery), so
## every move is posed here for the side view.

const IDLE_A := {"pelvis": 0, "torso": 2, "head": -2, "near_upper_arm": 6, "near_forearm": -28, "near_hand": 8,
		"baton": -48, "far_upper_arm": -4, "far_forearm": -14, "near_thigh": -3, "near_shin": 4,
		"far_thigh": 4, "far_shin": 3}
const IDLE_B := {"pelvis": 0, "torso": 3.4, "head": -3.6, "near_upper_arm": 7.5, "near_forearm": -30,
		"near_hand": 8, "baton": -46, "far_upper_arm": -5.5, "far_forearm": -16, "near_thigh": -3,
		"near_shin": 4, "far_thigh": 4, "far_shin": 3, "root": Vector2(0, 0.3)}

const RECOVER_A := {"pelvis": 5, "torso": 11, "head": -6, "near_upper_arm": -8, "near_forearm": -14,
		"near_hand": 6, "baton": -72, "far_upper_arm": -22, "far_forearm": 8, "far_hand": -16,
		"near_thigh": -14, "near_shin": 22, "far_thigh": 8, "far_shin": 18, "root": Vector2(3.0, 0.8)}
const RECOVER_B := {"pelvis": 6, "torso": 15, "head": -9, "near_upper_arm": -6, "near_forearm": -12,
		"near_hand": 6, "baton": -74, "far_upper_arm": -24, "far_forearm": 10, "far_hand": -16,
		"near_thigh": -15, "near_shin": 24, "far_thigh": 8, "far_shin": 20, "root": Vector2(3.0, 1.4)}
const HIT_A := {"pelvis": -3, "torso": -10, "head": -14, "near_upper_arm": -38, "near_forearm": -70,
		"near_hand": 0, "baton": -52, "far_upper_arm": -48, "far_forearm": -52, "near_thigh": 6,
		"near_shin": 14, "far_thigh": -8, "far_shin": 18, "root": Vector2(-3.0, 1.5)}
const HIT_B := {"pelvis": -4, "torso": -13, "head": -17, "near_upper_arm": -42, "near_forearm": -72,
		"near_hand": 0, "baton": -54, "far_upper_arm": -52, "far_forearm": -54, "near_thigh": 8,
		"near_shin": 16, "far_thigh": -10, "far_shin": 20, "root": Vector2(-3.8, 2.0)}

const CLIPS := {
	"idle": {"length": 3.2, "loop": true, "keys": [[0.0, IDLE_A], [1.6, IDLE_B], [3.2, IDLE_A]]},
	"walk": {"length": 1.0, "loop": true, "keys": [
		[0.0, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": -24, "near_shin": 6, "far_thigh": 20,
			"far_shin": 14, "near_upper_arm": 10, "near_forearm": -30, "near_hand": 8, "baton": -48,
			"far_upper_arm": -14, "far_forearm": -22, "near_foot": 10, "far_foot": -12}],
		[0.25, {"pelvis": 1, "torso": 3, "head": -3, "near_thigh": -4, "near_shin": 5, "far_thigh": -12,
			"far_shin": 52, "near_upper_arm": 4, "near_forearm": -30, "near_hand": 8, "baton": -48,
			"far_upper_arm": -4, "far_forearm": -18, "far_foot": -8}],
		[0.5, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": 20, "near_shin": 14, "far_thigh": -24,
			"far_shin": 6, "near_upper_arm": -4, "near_forearm": -34, "near_hand": 8, "baton": -48,
			"far_upper_arm": 14, "far_forearm": -14, "near_foot": -12, "far_foot": 10}],
		[0.75, {"pelvis": 1, "torso": 3, "head": -3, "near_thigh": -12, "near_shin": 52, "far_thigh": -4,
			"far_shin": 5, "near_upper_arm": 2, "near_forearm": -30, "near_hand": 8, "baton": -48,
			"far_upper_arm": 4, "far_forearm": -16, "near_foot": -8}],
		[1.0, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": -24, "near_shin": 6, "far_thigh": 20,
			"far_shin": 14, "near_upper_arm": 10, "near_forearm": -30, "near_hand": 8, "baton": -48,
			"far_upper_arm": -14, "far_forearm": -22, "near_foot": 10, "far_foot": -12}]]},
	# Walking at the hero with the baton up and ready.
	"stalk": {"length": 0.78, "loop": true, "keys": [
		[0.0, {"pelvis": 4, "torso": 9, "head": -8, "near_thigh": -26, "near_shin": 8, "far_thigh": 20,
			"far_shin": 16, "near_upper_arm": -24, "near_forearm": -62, "near_hand": 4, "baton": -62,
			"far_upper_arm": -22, "far_forearm": -30, "near_foot": 10, "far_foot": -12}],
		[0.195, {"pelvis": 3, "torso": 9, "head": -8, "near_thigh": -4, "near_shin": 5, "far_thigh": -12,
			"far_shin": 54, "near_upper_arm": -26, "near_forearm": -60, "near_hand": 4, "baton": -62,
			"far_upper_arm": -14, "far_forearm": -30, "far_foot": -8}],
		[0.39, {"pelvis": 4, "torso": 9, "head": -8, "near_thigh": 20, "near_shin": 16, "far_thigh": -26,
			"far_shin": 8, "near_upper_arm": -22, "near_forearm": -64, "near_hand": 4, "baton": -62,
			"far_upper_arm": -6, "far_forearm": -28, "near_foot": -12, "far_foot": 10}],
		[0.585, {"pelvis": 3, "torso": 9, "head": -8, "near_thigh": -12, "near_shin": 54, "far_thigh": -4,
			"far_shin": 5, "near_upper_arm": -26, "near_forearm": -60, "near_hand": 4, "baton": -62,
			"far_upper_arm": -14, "far_forearm": -30, "near_foot": -8}],
		[0.78, {"pelvis": 4, "torso": 9, "head": -8, "near_thigh": -26, "near_shin": 8, "far_thigh": 20,
			"far_shin": 16, "near_upper_arm": -24, "near_forearm": -62, "near_hand": 4, "baton": -62,
			"far_upper_arm": -22, "far_forearm": -30, "near_foot": 10, "far_foot": -12}]]},
	# Baton raised overhead (held at the end).
	"windup": {"length": 0.5, "loop": false, "keys": [
		[0.0, {"pelvis": 3, "torso": 6, "head": -6, "near_upper_arm": -40, "near_forearm": -60, "near_hand": 4,
			"baton": -60, "far_upper_arm": -20, "far_forearm": -30, "near_thigh": -6, "near_shin": 6,
			"far_thigh": 6, "far_shin": 6}],
		[0.3, {"pelvis": -2, "torso": -8, "head": 4, "near_upper_arm": -178, "near_forearm": -46,
			"near_hand": -12, "baton": -26, "far_upper_arm": -66, "far_forearm": -38, "near_thigh": 10,
			"near_shin": 10, "far_thigh": -16, "far_shin": 12, "root": Vector2(-1.5, 0)}],
		[0.5, {"pelvis": -3, "torso": -11, "head": 6, "near_upper_arm": -192, "near_forearm": -42,
			"near_hand": -12, "baton": -28, "far_upper_arm": -72, "far_forearm": -40, "near_thigh": 12,
			"near_shin": 10, "far_thigh": -18, "far_shin": 12, "root": Vector2(-2.5, 0)}]]},
	# The committed overhead strike, stepping in.
	"swing": {"length": 0.22, "loop": false, "keys": [
		[0.0, {"pelvis": -3, "torso": -11, "head": 6, "near_upper_arm": -192, "near_forearm": -42,
			"near_hand": -12, "baton": -28, "far_upper_arm": -72, "far_forearm": -40, "near_thigh": 12,
			"near_shin": 10, "far_thigh": -18, "far_shin": 12, "root": Vector2(-2.5, 0)}],
		[0.1, {"pelvis": 3, "torso": 12, "head": -2, "near_upper_arm": -120, "near_forearm": -30,
			"near_hand": -4, "baton": -30, "far_upper_arm": 0, "far_forearm": -30, "near_thigh": -12,
			"near_shin": 16, "far_thigh": 4, "far_shin": 12, "root": Vector2(2.0, 0)}],
		[0.22, {"pelvis": 6, "torso": 22, "head": -4, "near_upper_arm": -64, "near_forearm": -20,
			"near_hand": 6, "baton": -36, "far_upper_arm": 26, "far_forearm": -22, "near_thigh": -28,
			"near_shin": 24, "far_thigh": 16, "far_shin": 16, "root": Vector2(5.0, 0)}]]},
	# Winded after the swing: the punish window. Bent at the waist and
	# breathing hard, but head up and watching Dave, the baton hanging and
	# the free hand braced on the knee.
	"recover": {"length": 1.2, "loop": true, "keys": [
		[0.0, RECOVER_A], [0.6, RECOVER_B], [1.2, RECOVER_A]]},
	# Shot: the head snaps back and he rocks back a step, arms jolting up,
	# then he gathers himself into the stalk.
	"hit": {"length": 0.45, "loop": false, "keys": [
		[0.0, HIT_A],
		[0.12, HIT_B],
		[0.45, {"pelvis": 4, "torso": 9, "head": -8, "near_thigh": -26, "near_shin": 8, "far_thigh": 20,
			"far_shin": 16, "near_upper_arm": -24, "near_forearm": -62, "near_hand": 4, "baton": -62,
			"far_upper_arm": -22, "far_forearm": -30, "near_foot": 10, "far_foot": -12}]]},
}
