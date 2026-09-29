extends TestCase
## C35 lit-cutout test build (spike/lit_cutout): the Night Guard rig builds
## with its lit material, poses keep the feet on the floor, three hits kill
## him into a pinned ragdoll that lands on the floor (never through it) and
## keeps its joints inside their limits, and the settled body becomes a
## still corpse with a blood pool.

const BlockScript := preload("res://scripts/world/block.gd")
const GuardScript := preload("res://spike/lit_cutout/scripts/night_guard.gd")
const Blood := preload("res://spike/lit_cutout/scripts/blood.gd")
const FLOOR_Y := 560.0


func run() -> void:
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(-200.0, FLOOR_Y)
	floor_b.size = Vector2(2000.0, 200.0)
	add_child(floor_b)
	var host := Node2D.new()
	add_child(host)
	var guard: CharacterBody2D = GuardScript.new()
	guard.aggressive = false
	guard.position = Vector2(500.0, FLOOR_Y)
	host.add_child(guard)
	await physics_frames(3)

	var rig = guard.rig
	check_eq(rig.order.size(), 16, "the Night Guard rig has 16 parts")
	var lit := true
	for jname in rig.order:
		var s: Sprite2D = rig.sprites[jname]
		lit = lit and s.material is ShaderMaterial and (s.material as ShaderMaterial).get_shader_parameter("normal_atlas") != null
	check(lit, "every rig part draws with the lit shader and a normal atlas")

	# Ground lock: whatever the pose, the lowest sole touches y = 0.
	for clip in ["idle", "walk", "stalk", "windup", "swing", "recover"]:
		for k in 5:
			var pose: Dictionary = guard.anim.sample(clip, float(k) * 0.1)
			rig.apply_pose(pose)
			check(absf(rig._ground_error()) < 0.05, "%s pose keeps the feet on the floor" % clip)

	# Three hits kill him into a ragdoll.
	var died := [null]
	guard.died.connect(func(_g, rd): died[0] = rd)
	for i in 3:
		guard.hit_zone.take_hit(1, guard.global_position + Vector2(0.0, -70.0), Vector2.RIGHT)
		await physics_frames(1)
	var ragdoll = died[0]
	check(ragdoll != null, "the third hit kills the guard and makes a ragdoll")
	if ragdoll == null:
		return
	var bodies := 0
	var pins := 0
	for c in ragdoll.get_children():
		if c is RigidBody2D:
			bodies += 1
		elif c is PinJoint2D:
			pins += 1
	check_eq(bodies, 11, "every limb part becomes a physics body (hands, feet and head ride on their forearm, shin and torso)")
	check_eq(pins, 9, "parts are pinned at their joints (the baton falls free)")

	# Let it fall: a joint may overshoot for a moment on impact, but no more
	# than a little, and it rests back near its range; nothing falls through.
	var worst := 0.0
	var resting := {}
	for i in 200:
		await physics_frames(1)
		if ragdoll.is_settled():
			break
		for jname in ragdoll.limits:
			var rel: float = ragdoll.relative_angle(jname)
			var lim: Vector2 = ragdoll.limits[jname]
			var over := maxf(lim.x - rel, rel - lim.y)
			worst = maxf(worst, over)
			resting[jname] = over
	var worst_rest := 0.0
	for jname in resting:
		worst_rest = maxf(worst_rest, resting[jname])
	check(worst < deg_to_rad(75.0), "ragdoll joints never overshoot their limits by more than 75° (worst %.1f°)" % rad_to_deg(worst))
	check(worst_rest < deg_to_rad(20.0), "the body comes to rest with every joint within 20° of its range (worst %.1f°)" % rad_to_deg(worst_rest))
	await seconds(3.2)
	check(ragdoll.is_settled(), "the ragdoll settles into a still corpse within a few seconds")
	var corpse: Node2D = ragdoll.get_node_or_null("Corpse")
	check(corpse != null, "the settled body is kept as a corpse")
	if corpse:
		var ok := true
		for part in corpse.get_children():
			var y := (part as Node2D).global_position.y
			ok = ok and y > FLOOR_Y - 70.0 and y < FLOOR_Y + 4.0
		check(ok, "the corpse lies on the floor, not through it")
	var pools := 0
	for c in host.get_children():
		if c is Sprite2D and (c as Sprite2D).texture == Blood.POOL:
			pools += 1
	check(pools >= 1, "a blood pool spreads under the settled body")
	Blood.clear()
