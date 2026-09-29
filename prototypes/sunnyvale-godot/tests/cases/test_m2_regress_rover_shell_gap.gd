extends TestCase
## REGRESSION (R1-03 / ENG-02): a bolt fired straight down onto the middle of
## a Patrol Rover (hero on a ledge above / jumping over a charge) must
## resolve on the Rover's shell (hit or blocked), never pass through the gap
## between Front/RearHitZone to the floor beneath it.

const BlockScript := preload("res://scripts/world/block.gd")


func run() -> void:
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(0, 560)
	floor_b.size = Vector2(2000, 200)
	add_child(floor_b)

	var rover: PatrolRover = load("res://scenes/actors/patrol_rover.tscn").instantiate()
	# Pin it in place with a near-zero patrol leash rather than disabling
	# process_mode: disabling a CollisionObject2D's processing also disables
	# its children's Area2D collision detection in Godot, which would make
	# every HitZone here silently unhittable and defeat the probe.
	rover.patrol_min_x = 799.0
	rover.patrol_max_x = 801.0
	add_child(rover)
	rover.global_position = Vector2(800, 560)
	await physics_frames(5)

	var rover_events := [0]
	rover.front_hit_zone.blocked_hit.connect(func(_p): rover_events[0] += 1)
	rover.rear_hit_zone.hit.connect(func(_d, _p, _dir): rover_events[0] += 1)

	for off in [0.0, -8.0, 8.0]:
		var bolt: ScrapBolt = load("res://scenes/weapons/scrap_bolt.tscn").instantiate()
		add_child(bolt)
		var start := Vector2(rover.global_position.x + off, 560 - 200)
		bolt.setup(start, Vector2.DOWN, load("res://data/tuning/w01_scrapjack.tres"))
		var last_pos := start
		for i in 40:
			await physics_frames(1)
			if not is_instance_valid(bolt):
				break
			last_pos = bolt.global_position
		var before: int = rover_events[0]
		print("PROBE bolt x_off=%.0f last_pos=%s rover_events=%d" % [off, str(last_pos), before])
		check(last_pos.y < 560 - 40.0,
				"a bolt fired down onto the Rover's body centre (x_off=%.0f) stops on the Rover, not the floor under it (stopped at y=%.1f, floor=560, rover top=512)" % [off, last_pos.y])
	rover.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
