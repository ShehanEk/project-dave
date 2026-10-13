extends TestCase
## C50: Dave's arm and gun turn in 22.5-degree steps (16 directions round him), the shot
## goes exactly where the player points, and each step has its own hold so the elbow bends
## and the gun stays in front of him (hero.gd _update_aim_pivot(), shot_direction();
## hero_rig_visual.gd GUN_HOLD / gun_hold()). Playtest 2026-10-08: the free-turning,
## full-reach one-handed arm "looks really strange" (it swung over his face aiming up and
## its pixels shimmered through every angle).
## Contracts under test, facing right and left:
##   1. Every aim snaps to the nearest step: the pivot's angle is a whole number of steps,
##      at most half a step from the aim, and nearby aims share a step (so the arm holds
##      still while the cursor wanders inside a step).
##   2. Each step puts the gun at its own hold; the fist stays on the grip; the elbow is
##      bent (the grip is well inside the arm's full reach).
##   3. Straight up holds the gun in front of his face, never behind or over his head;
##      straight down holds it in front of his legs.
##   4. The shot direction is the exact aim, not the step.

const HERO := "res://scenes/actors/hero.tscn"
const BlockScript := preload("res://scripts/world/block.gd")


func run() -> void:
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.size = Vector2(3000, 64)
	floor_b.position = Vector2(-500, 0)
	add_child(floor_b)
	var hero: Hero = load(HERO).instantiate()
	add_child(hero)
	hero.global_position = Vector2(800, -1)
	hero.use_aim_override = true
	await physics_frames(4)
	var visual = hero.get_node("Visual")
	var gun: Node2D = hero.get_node("AimPivot/Scrapjack")
	check(visual.has_method("gun_hold"), "the hero's visual gives a hold per aim step")
	check(visual.rig != null, "Dave is the pixel rig")
	if visual.rig == null:
		hero.queue_free()
		floor_b.queue_free()
		return
	var reach: float = _arm_reach(visual.rig)

	for facing in [1, -1]:
		var steps := {}
		for deg in [-90.0, -80.0, -60.0, -40.0, -25.0, -10.0, -4.0, 0.0, 4.0, 13.0, 30.0, 50.0, 70.0, 89.0]:
			var a := deg_to_rad(deg)
			var dir := Vector2(cos(a) * facing, sin(a))
			if absf(dir.x) < 0.001:
				dir.x = 0.001 * facing
			# Face the right way first (the aim inside FACING_DEADZONE keeps the facing).
			hero.aim_override = hero.aim_pivot.global_position + Vector2(400.0 * facing, 0.0)
			await physics_frames(2)
			hero.aim_override = hero.aim_pivot.global_position + dir * 400.0
			await physics_frames(3)
			var tag := "facing %d, aim %.0f deg" % [facing, deg]
			check_eq(hero.facing, facing, "%s: facing" % tag)
			var rel := Vector2(hero.aim_pivot.global_transform.x.x * facing, hero.aim_pivot.global_transform.x.y).angle()
			var step := int(round(rel / Hero.AIM_STEP))
			check(absf(rel - step * Hero.AIM_STEP) < 0.001, "%s: the gun is on a whole step (%.2f deg)" % [tag, rad_to_deg(rel)])
			check_eq(step, hero.aim_step, "%s: aim_step says the same step" % tag)
			check(absf(rel - a) <= Hero.AIM_STEP * 0.5 + 0.01, "%s: at most half a step off the aim" % tag)
			steps[step] = steps.get(step, 0) + 1
			check(gun.position.is_equal_approx(visual.gun_hold(step)), "%s: the gun sits at step %d's hold" % [tag, step])
			check(visual.grip_error() < 3.0, "%s: the fist holds the grip (%.2f px off)" % [tag, visual.grip_error()])
			var grip_dist: float = hero.aim_pivot.global_position.distance_to(visual._gun_grip_global())
			check(grip_dist < reach - 4.0, "%s: the elbow is bent (grip %.1f px from the shoulder, full reach %.1f)" % [tag, grip_dist, reach])
			# (The shoulder moves a little with the pose, so measure from where it is now.)
			var exact: Vector2 = (hero.aim_override - hero.aim_pivot.global_position).normalized()
			var shot: Vector2 = hero.shot_direction()
			check(absf(wrapf(shot.angle() - exact.angle(), -PI, PI)) < 0.01, "%s: the shot goes exactly at the aim" % tag)
			if step == Hero.AIM_STEP_MIN:
				# Forward of the face: the grip is ahead of the head's centre by more than the
				# head's radius.
				var head: Vector2 = visual.rig.joint_point("head", Vector2(3.1, -10.3))
				var ahead: float = (visual._gun_grip_global().x - head.x) * facing
				check(ahead > 6.0, "%s: straight up holds the gun in front of his face (%.1f px ahead of the head)" % [tag, ahead])
			if step == Hero.AIM_STEP_MAX:
				var hip: Vector2 = visual.rig.joint_point("pelvis", Vector2.ZERO)
				var ahead_legs: float = (visual._gun_grip_global().x - hip.x) * facing
				check(ahead_legs > 10.0, "%s: straight down holds the gun in front of his legs (%.1f px ahead)" % [tag, ahead_legs])
		check(steps.has(-4) and steps.has(4) and steps.has(0), "facing %d: straight up, level and straight down all reached" % facing)
		check(steps.get(0, 0) >= 3, "facing %d: aims a few degrees either side of level share the level step" % facing)

	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


## Shoulder to the fist's grip with the arm straight (upper arm + forearm + the grip's
## place in the hand).
func _arm_reach(rig: Node2D) -> float:
	var fa: Node2D = rig.joints["near_forearm"]
	var hand: Node2D = rig.joints["near_hand"]
	var g: Vector2 = rig.sockets["grip"]["pos"] if rig.sockets.has("grip") else Vector2(0, 3)
	return (fa.position.length() + hand.position.length() + g.length()) * absf(rig.global_scale.x)
