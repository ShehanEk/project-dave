extends TestCase
## C35 lit cutout enemies, as Level 1 uses them. The Night Guard's rig
## builds with its lit material, every pose keeps the feet on the floor, a
## hit bleeds (a spray and a wound on the part it struck), and three hits
## kill him into a pinned ragdoll that lands on the floor (never through it),
## keeps its joints inside their limits and settles into a still corpse with
## a blood pool. The Staffer's rig builds and holds its dormant pose while
## its encounter is asleep. The Patrol Rover's machine rig builds with every
## part it drives, and a destroyed rover bursts into loose debris that
## settles in a pool of oil, never blood.

const BlockScript := preload("res://scripts/world/block.gd")
const Blood := preload("res://scripts/effects/blood.gd")
const FLOOR_Y := 560.0


func run() -> void:
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(-200.0, FLOOR_Y)
	floor_b.size = Vector2(2400.0, 200.0)
	add_child(floor_b)
	await _test_night_guard()
	await _test_staffer_dormant()
	await _test_rover_wreck()
	Blood.clear()


func _is_lit(rig) -> bool:
	for jname in rig.order:
		var s: Sprite2D = rig.sprites[jname]
		if not (s.material is ShaderMaterial and (s.material as ShaderMaterial).get_shader_parameter("normal_atlas") != null):
			return false
	return true


func _pools(host: Node) -> Array:
	var out := []
	for c in host.get_children():
		if c is Sprite2D and (c as Sprite2D).texture != null and (c as Sprite2D).texture.resource_path.ends_with("pool.png"):
			out.append(c)
	return out


func _test_night_guard() -> void:
	var host := Node2D.new()
	add_child(host)
	var guard: Brawler = load("res://scenes/actors/night_guard.tscn").instantiate()
	guard.name = "Guard"
	guard.position = Vector2(500.0, FLOOR_Y)
	host.add_child(guard)
	await physics_frames(3)

	var rig = guard.rig
	check(rig != null, "the Night Guard builds its lit rig")
	if rig == null:
		return
	check_eq(rig.order.size(), 16, "the Night Guard rig has 16 parts")
	check(_is_lit(rig), "every Night Guard part draws with the lit shader and a normal atlas")
	check(guard.hit_zone.bleeds, "a Night Guard bleeds when shot")

	# Ground lock: whatever the pose, the lowest sole touches y = 0.
	for clip in ["idle", "walk", "stalk", "windup", "swing", "recover"]:
		var planted := true
		for k in 5:
			rig.apply_pose(guard.anim.sample(clip, float(k) * 0.1))
			planted = planted and absf(rig._ground_error()) < 0.05
		check(planted, "the %s clip keeps the Night Guard's feet on the floor" % clip)

	# A hit bleeds: a spray under the host and a wound on the part it struck.
	var before := host.get_child_count()
	var at := guard.global_position + Vector2(0.0, -70.0)
	var struck: String = rig.nearest_joint(at)
	guard.hit_zone.take_hit(1, at, Vector2.RIGHT)
	await physics_frames(1)
	check(host.get_child_count() > before, "a hit sprays blood")
	check((rig.sprites[struck] as Sprite2D).get_child_count() > 0, "a hit leaves a wound on the part it struck (%s)" % struck)

	# Two more hits kill him into a ragdoll that stays behind.
	for i in 2:
		guard.hit_zone.take_hit(1, at, Vector2.RIGHT)
		await physics_frames(1)
	check(not is_instance_valid(guard), "the third hit kills the Night Guard")
	var ragdoll = host.get_node_or_null("Body_Guard")
	check(ragdoll != null, "the dead guard leaves a ragdoll body")
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
	var worst_joint := ""
	for jname in resting:
		if resting[jname] > worst_rest:
			worst_rest = resting[jname]
			worst_joint = jname
	check(worst < deg_to_rad(75.0), "ragdoll joints never overshoot their limits by more than 75° (worst %.1f°)" % rad_to_deg(worst))
	check(worst_rest < deg_to_rad(20.0), "the body comes to rest with every joint within 20° of its range (worst %.1f° at %s)" % [rad_to_deg(worst_rest), worst_joint])
	await seconds(3.2)
	check(ragdoll.is_settled(), "the ragdoll settles into a still corpse within a few seconds")
	var corpse: Node2D = ragdoll.get_node_or_null("Corpse")
	check(corpse != null, "the settled body is kept as a corpse")
	if corpse:
		var on_floor := true
		for part in corpse.get_children():
			var y := (part as Node2D).global_position.y
			on_floor = on_floor and y > FLOOR_Y - 70.0 and y < FLOOR_Y + 4.0
		check(on_floor, "the corpse lies on the floor, not through it")
	check(_pools(host).size() >= 1, "a blood pool spreads under the settled body")
	host.queue_free()
	Blood.clear()
	await physics_frames(2)


func _test_staffer_dormant() -> void:
	var group := EncounterGroup.new()
	group.is_active = false
	add_child(group)
	var staffer: Brawler = load("res://scenes/actors/staffer.tscn").instantiate()
	staffer.position = Vector2(900.0, FLOOR_Y)
	group.add_child(staffer)
	await physics_frames(3)
	var rig = staffer.rig
	check(rig != null, "the Staffer builds its lit rig")
	if rig == null:
		group.queue_free()
		return
	check_eq(rig.order.size(), 15, "the Staffer rig has 15 parts")
	check(_is_lit(rig), "every Staffer part draws with the lit shader and a normal atlas")
	check(staffer.state == Brawler.State.DORMANT, "a Staffer waits dormant while its encounter is asleep")
	for clip in ["dormant", "shamble", "windup", "lunge", "stumble"]:
		var planted := true
		for k in 5:
			rig.apply_pose(staffer.anim.sample(clip, float(k) * 0.1))
			planted = planted and absf(rig._ground_error()) < 0.05
		check(planted, "the Staffer's %s clip keeps its feet on the floor" % clip)
	group.is_active = true
	await physics_frames(2)
	check(staffer.state != Brawler.State.DORMANT, "the Staffer walks out once its encounter wakes")
	group.queue_free()
	await physics_frames(2)


func _test_rover_wreck() -> void:
	var host := Node2D.new()
	add_child(host)
	var rover: PatrolRover = load("res://scenes/actors/patrol_rover.tscn").instantiate()
	rover.name = "Rover"
	rover.position = Vector2(1400.0, FLOOR_Y)
	host.add_child(rover)
	await physics_frames(3)
	var rig = rover.rig
	check(rig != null, "the Patrol Rover builds its lit machine rig")
	if rig == null:
		return
	check_eq(rig.kind, "machine", "the rover's rig is a machine (no ground lock)")
	check(_is_lit(rig), "every rover part draws with the lit shader and a normal atlas")
	for role in ["chassis", "dome", "lightbar", "hatch", "battery", "wheel_near_front", "wheel_near_rear"]:
		check(rig.joint_for_role(role) != "", "the rover rig has a %s" % role)
	check(not rover.front_hit_zone.bleeds and not rover.rear_hit_zone.bleeds, "a machine never bleeds")

	rover.rear_hit_zone.blocks = false  # force the battery open for this direct test
	for i in rover.tuning.motor_health:
		rover.rear_hit_zone.take_hit(1, rover.rear_hit_zone.global_position, Vector2.RIGHT)
	await physics_frames(1)
	check(not is_instance_valid(rover), "the rover is destroyed once its battery is spent")
	var wreck = host.get_node_or_null("Wreck_Rover")
	check(wreck != null, "the destroyed rover leaves a wreck")
	if wreck == null:
		return
	var parts := 0
	var pins := 0
	for c in wreck.get_children():
		if c is RigidBody2D:
			parts += 1
		elif c is PinJoint2D:
			pins += 1
	check_eq(parts, rig_parts("res://assets/characters/lit/patrol_rover/rig.json"), "every rover part flies off as its own piece of debris")
	check_eq(pins, 0, "debris is loose: nothing is pinned")
	await seconds(3.4)
	check(wreck.is_settled(), "the debris settles within a few seconds")
	var pools := _pools(host)
	check(pools.size() == 1, "the wreck leaks one pool (got %d)" % pools.size())
	if pools.size() == 1:
		var tint: Color = (pools[0] as Sprite2D).modulate
		check(tint.r < 0.4 and tint.b >= tint.r, "the wreck's pool is dark oil, not blood")
	host.queue_free()
	Blood.clear()
	await physics_frames(2)


func rig_parts(path: String) -> int:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	return (data["joints"] as Array).size()
