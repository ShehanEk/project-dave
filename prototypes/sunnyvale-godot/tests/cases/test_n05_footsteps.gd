extends TestCase
## N05 — the hero's footsteps (scripts/actors/hero.gd `_update_footsteps()`,
## scripts/world/surface_map.gd): one `footstep_*` cue per FOOTSTEP_STRIDE of
## ground run under his own power, chosen by the surface under his feet.
## Contracts under test (see CONVENTIONS.md "Audio"):
##   1. SurfaceMap picks paving / metal / roof per area (A01 A02 A04 A06 paving,
##      A03 roof, A05 metal), mixed areas by the block under his feet (the
##      roofs' street run-in and landing are paving, a roof slab is roof, a
##      moving platform is metal), and paving when nothing says otherwise.
##   2. The three cues are real, loaded sounds.
##   3. A run of D px sounds 1 + floor((D - FIRST_FOOTSTEP_DISTANCE) / STRIDE)
##      steps, in either direction, the first one promptly; the stride is one
##      foot contact of the rig's run cycle.
##   4. No steps while standing, airborne, pushing a wall, with input off, or
##      dead.
##   5. In the real area scenes, a hero walking on a roof slab, the roofs'
##      street, and the depot floor sounds roof, paving and metal.
## Throwaway state only: Session is a fresh run and Telemetry never starts a log
## (no run_start()); nothing is saved.

const BlockScript := preload("res://scripts/world/block.gd")
const SurfaceMap := preload("res://scripts/world/surface_map.gd")

const PAVING := &"footstep_paving"
const METAL := &"footstep_metal"
const ROOF := &"footstep_roof"

const A03_ROOFS := "res://scenes/levels/areas/a03_roofs.tscn"
const A05_DEPOT := "res://scenes/levels/areas/a05_depot.tscn"

## The surface chosen for each of the six areas, in LevelDirector's x-order.
const EXPECTED_AREAS := [
	["L01-A01", PAVING],
	["L01-A02", PAVING],
	["L01-A03", ROOF],
	["L01-A04", PAVING],
	["L01-A05", METAL],
	["L01-A06", PAVING],
]


func run() -> void:
	_test_lookup_per_area()
	_test_lookup_per_block()
	_test_cues_are_loaded()
	await _test_area_scenes_use_the_table()
	await _test_step_count_follows_distance()
	await _test_first_step_is_prompt()
	await _test_no_steps_standing()
	await _test_no_steps_airborne()
	await _test_no_steps_without_motion_under_own_power()
	await _test_surface_under_feet_in_real_areas()
	Session.new_run()


# --- helpers ------------------------------------------------------------------

func _make_floor(x: float, y: float, w: float, h: float = 200.0) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	add_child(b)
	return b


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	return hero


## A hero settled on the floor at `pos`, standing still, no steps counted yet.
func _settled_hero(pos: Vector2) -> Hero:
	var hero := _make_hero(pos)
	await physics_frames(4)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	await physics_frames(2)
	return hero


## Lets a hero placed a few px above the floor (an area's spawn marker) settle onto it.
func _land(hero: Hero) -> void:
	var ticks := 0
	while not hero.is_on_floor() and ticks < 60:
		await physics_frames(1)
		ticks += 1
	hero.velocity = Vector2.ZERO
	await physics_frames(1)


func _expected_steps(distance: float) -> int:
	if distance < Hero.FIRST_FOOTSTEP_DISTANCE:
		return 0
	return 1 + int(floor((distance - Hero.FIRST_FOOTSTEP_DISTANCE) / Hero.FOOTSTEP_STRIDE))


# --- 1. the lookup ----------------------------------------------------------------

func _test_lookup_per_area() -> void:
	for entry in EXPECTED_AREAS:
		check_eq(SurfaceMap.for_area(entry[0]), entry[1], "%s walks on %s" % [entry[0], entry[1]])
	check_eq(SurfaceMap.for_area(""), PAVING, "no area (an isolated test scene) defaults to paving")
	check_eq(SurfaceMap.for_area("L99-A99"), PAVING, "an unknown area defaults to paving")
	check_eq(SurfaceMap.DEFAULT, PAVING, "the default surface is paving")
	check_eq(SurfaceMap.for_collider(null), PAVING, "no floor found defaults to paving")


func _test_lookup_per_block() -> void:
	var kinds: Dictionary = BlockScript.Kind
	# The depot is steel throughout.
	for kind in [kinds.GROUND, kinds.PLATFORM, kinds.ROOF]:
		check_eq(SurfaceMap.for_block("L01-A05", kind), METAL, "depot block kind %d is metal" % kind)
	# The roofs: slabs are roof, the street run-in and landing (ground, porch) are paving,
	# the small ledges and the AC-unit backstops sit on the roof.
	check_eq(SurfaceMap.for_block("L01-A03", kinds.ROOF), ROOF, "a roof slab on the roofs is roof")
	check_eq(SurfaceMap.for_block("L01-A03", kinds.PORCH), PAVING, "the roofs' street (porch kind) is paving")
	check_eq(SurfaceMap.for_block("L01-A03", kinds.GROUND), PAVING, "the roofs' ground kind is paving")
	check_eq(SurfaceMap.for_block("L01-A03", kinds.PLATFORM), ROOF, "a ledge on the roofs is roof")
	check_eq(SurfaceMap.for_block("L01-A03", kinds.BACKSTOP), ROOF, "the rooftop AC unit is roof")
	# Everywhere else a block takes its area's paving, except a roof slab.
	for area_id in ["L01-A01", "L01-A02", "L01-A04", "L01-A06"]:
		for kind in [kinds.GROUND, kinds.PLATFORM, kinds.WALL, kinds.BACKSTOP, kinds.PORCH]:
			check_eq(SurfaceMap.for_block(area_id, kind), PAVING, "%s block kind %d is paving" % [area_id, kind])
	check_eq(SurfaceMap.for_block("L01-A04", kinds.ROOF), ROOF, "a roof-kind slab is roof in any area")
	check_eq(SurfaceMap.for_block("", kinds.GROUND), PAVING, "a block with no area is paving")

	# A moving platform is a steel plate, a bare body with no area is paving.
	var plat: Node = load("res://scenes/objects/moving_platform.tscn").instantiate()
	check_eq(SurfaceMap.for_collider(plat), METAL, "a moving platform is metal")
	plat.free()
	var bare := BlockScript.new()
	check_eq(SurfaceMap.for_collider(bare), PAVING, "a block with no AreaRoot above it is paving")
	bare.free()


# --- 2. the cues ------------------------------------------------------------------

func _test_cues_are_loaded() -> void:
	for cue in [PAVING, METAL, ROOF]:
		check(Audio.has_cue(cue), "%s is a loaded cue" % cue)
	# Every surface the table can answer is a loaded cue.
	for entry in EXPECTED_AREAS:
		check(Audio.has_cue(SurfaceMap.for_area(entry[0])), "the cue for %s is loaded" % entry[0])


func _test_area_scenes_use_the_table() -> void:
	var paths: Array[String] = LevelDirector.AREA_SCENE_PATHS
	check_eq(paths.size(), EXPECTED_AREAS.size(), "the level has the six areas this test knows")
	for i in mini(paths.size(), EXPECTED_AREAS.size()):
		var area: AreaRoot = (load(paths[i]) as PackedScene).instantiate()
		check_eq(area.area_id, EXPECTED_AREAS[i][0], "area %d is %s" % [i + 1, EXPECTED_AREAS[i][0]])
		check_eq(SurfaceMap.for_area(area.area_id), EXPECTED_AREAS[i][1],
				"%s (%s) maps to %s" % [area.area_id, paths[i].get_file(), EXPECTED_AREAS[i][1]])
		area.free()
	await physics_frames(1)


# --- 3. the step count --------------------------------------------------------------

func _test_step_count_follows_distance() -> void:
	# The stride is one foot contact of the rig's run cycle (TAU of stride phase).
	check(absf(Hero.FOOTSTEP_STRIDE * Hero.STRIDE_PHASE_PER_PX - PI) < 0.001,
			"a stride is half a run cycle of stride phase")
	var steps_per_second: float = load("res://data/tuning/hero.tres").run_speed / Hero.FOOTSTEP_STRIDE
	check(steps_per_second > 3.5 and steps_per_second < 6.5,
			"a run at full speed sounds %.1f steps a second" % steps_per_second)

	var floor_b := _make_floor(0, 560, 4000)
	for run_right in [true, false]:
		for hold_seconds in [1.0, 3.0]:
			var start_x := 300.0 if run_right else 3700.0
			var hero: Hero = await _settled_hero(Vector2(start_x, 560))
			check_eq(hero.footsteps_played, 0, "no steps before the run starts")
			var action := &"move_right" if run_right else &"move_left"
			await hold(action, hold_seconds)
			var distance := absf(hero.global_position.x - start_x)
			var expected := _expected_steps(distance)
			check(absi(hero.footsteps_played - expected) <= 1,
					"%s for %.0fs (%.0f px) sounds %d steps, expected about %d" % [
					action, hold_seconds, distance, hero.footsteps_played, expected])
			print("[test_n05_footsteps] %s %.0fs: %.0f px, %d steps (expected %d)" % [
					action, hold_seconds, distance, hero.footsteps_played, expected])
			check(hero.footsteps_played >= 4, "a %.0f s run sounds several steps (%d)" % [
					hold_seconds, hero.footsteps_played])
			# No floor under the rays of a scene with no AreaRoot: the default surface.
			check_eq(hero.last_footstep_cue, PAVING, "an isolated floor sounds paving")
			hero.queue_free()
			await physics_frames(1)
	floor_b.queue_free()
	await physics_frames(1)


func _test_first_step_is_prompt() -> void:
	var floor_b := _make_floor(0, 560, 3000)
	var hero: Hero = await _settled_hero(Vector2(300, 560))
	press("move_right")
	var ticks := 0
	while hero.footsteps_played == 0 and ticks < 60:
		await physics_frames(1)
		ticks += 1
	release("move_right")
	check(hero.footsteps_played >= 1, "the first step sounds after the run starts")
	check(ticks <= 10, "the first step is prompt, not a full stride later (%d ticks)" % ticks)
	var first_distance := hero.global_position.x - 300.0
	check(first_distance < Hero.FOOTSTEP_STRIDE * 0.5,
			"the first step comes well inside one stride (%.0f px)" % first_distance)
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


# --- 4. no steps -----------------------------------------------------------------------

func _test_no_steps_standing() -> void:
	var floor_b := _make_floor(0, 560, 2000)
	var hero: Hero = await _settled_hero(Vector2(300, 560))
	await seconds(1.0)
	check_eq(hero.footsteps_played, 0, "no steps while standing still")
	press("move_left")
	press("move_right")
	await seconds(1.0)
	release("move_left")
	release("move_right")
	check_eq(hero.footsteps_played, 0, "no steps while both directions cancel out")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_no_steps_airborne() -> void:
	var floor_b := _make_floor(0, 560, 3000)
	# Dropped from height while holding right: nothing sounds until he lands.
	var hero: Hero = await _settled_hero(Vector2(300, 100))
	press("move_right")
	var airborne_ticks := 0
	var steps_in_air := 0
	var prev := hero.footsteps_played
	for i in 120:
		await physics_frames(1)
		if not hero.is_on_floor():
			airborne_ticks += 1
			steps_in_air += hero.footsteps_played - prev
		prev = hero.footsteps_played
		if hero.is_on_floor() and airborne_ticks > 0:
			break
	check(airborne_ticks > 10, "the hero was airborne for a while (%d ticks)" % airborne_ticks)
	check_eq(steps_in_air, 0, "no steps while airborne (drop)")
	await seconds(0.8)
	check(hero.footsteps_played >= 1, "steps resume once he runs on the floor again")

	# A running jump: the counter holds still for every airborne tick.
	var before := hero.footsteps_played
	press("jump")
	await physics_frames(2)
	release("jump")
	steps_in_air = 0
	airborne_ticks = 0
	prev = hero.footsteps_played
	for i in 90:
		await physics_frames(1)
		if not hero.is_on_floor():
			airborne_ticks += 1
			steps_in_air += hero.footsteps_played - prev
		prev = hero.footsteps_played
	release("move_right")
	check(airborne_ticks > 5, "the running jump left the floor (%d ticks)" % airborne_ticks)
	check_eq(steps_in_air, 0, "no steps while airborne (running jump, %d before)" % before)
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_no_steps_without_motion_under_own_power() -> void:
	# Input off (a modal or SC01): he slides to a stop on his own, no steps.
	var floor_b := _make_floor(0, 560, 3000)
	var hero: Hero = await _settled_hero(Vector2(300, 560))
	hero.input_enabled = false
	hero.velocity.x = 384.0
	await seconds(1.0)
	check_eq(hero.footsteps_played, 0, "no steps while input is off, even sliding")
	hero.input_enabled = true
	hero.queue_free()

	# A wall: the run into it sounds, standing against it does not.
	var wall := _make_floor(900, 100, 100, 460)
	var runner: Hero = await _settled_hero(Vector2(300, 560))
	press("move_right")
	await seconds(2.0)
	var at_wall := runner.footsteps_played
	check(runner.global_position.x > 900.0 - 24.0, "the hero ran up to the wall (x=%.0f)" % runner.global_position.x)
	check(at_wall >= 4, "the run to the wall sounded steps (%d)" % at_wall)
	await seconds(1.0)
	release("move_right")
	check_eq(runner.footsteps_played, at_wall, "no steps while pushing against a wall")
	runner.queue_free()
	wall.queue_free()

	# Dead: the last hit lands, and holding right afterwards sounds nothing.
	Session.new_run()
	var dead: Hero = await _settled_hero(Vector2(300, 560))
	Session.state["health"] = 1
	check(dead.take_damage(5, Vector2(300, 560)), "the lethal hit lands")
	await seconds(1.0)
	var steps_when_dead := dead.footsteps_played
	press("move_right")
	await seconds(1.0)
	release("move_right")
	check(absf(dead.global_position.x - 300.0) > 100.0, "the dead hero's run input still moved him")
	check_eq(dead.footsteps_played, steps_when_dead, "no steps once dead")
	dead.queue_free()
	floor_b.queue_free()
	Session.new_run()
	await physics_frames(1)


# --- 5. the real areas ---------------------------------------------------------------------

func _test_surface_under_feet_in_real_areas() -> void:
	Session.new_run()
	# A03: a roof slab sounds roof, the street run-in sounds paving.
	var roofs: AreaRoot = (load(A03_ROOFS) as PackedScene).instantiate()
	add_child(roofs)
	await physics_frames(2)
	var slab := roofs.get_node("Geometry/Terrace1") as Block
	var slab_hero: Hero = await _settled_hero(slab.global_position + Vector2(40.0, 0.0))
	await _land(slab_hero)
	check(slab_hero.is_on_floor(), "the hero stands on the roofs' first slab")
	await hold("move_right", 0.5)
	check(slab_hero.footsteps_played >= 2, "walking the slab sounds steps (%d)" % slab_hero.footsteps_played)
	check_eq(slab_hero.last_footstep_cue, ROOF, "a roof slab sounds roof")
	slab_hero.queue_free()
	await physics_frames(1)

	var street_hero: Hero = await _settled_hero(roofs.get_marker("FailsafeReset").global_position)
	await _land(street_hero)
	check(street_hero.is_on_floor(), "the hero stands on the roofs' street")
	await hold("move_right", 0.4)
	check(street_hero.footsteps_played >= 2, "walking the street sounds steps (%d)" % street_hero.footsteps_played)
	check_eq(street_hero.last_footstep_cue, PAVING, "the roofs' street sounds paving")
	street_hero.queue_free()
	roofs.queue_free()
	await physics_frames(2)

	# A05: the depot floor is steel.
	var depot: AreaRoot = (load(A05_DEPOT) as PackedScene).instantiate()
	add_child(depot)
	await physics_frames(2)
	var depot_hero: Hero = await _settled_hero(depot.get_marker("Spawn_CP00").global_position)
	await _land(depot_hero)
	check(depot_hero.is_on_floor(), "the hero stands on the depot floor")
	await hold("move_right", 0.4)
	check(depot_hero.footsteps_played >= 2, "walking the depot sounds steps (%d)" % depot_hero.footsteps_played)
	check_eq(depot_hero.last_footstep_cue, METAL, "the depot floor sounds metal")
	depot_hero.queue_free()
	depot.queue_free()
	await physics_frames(2)
	Session.new_run()
