extends TestCase
## M6.5 Kenney integration pass — the reusable one-shot puff effect
## (scripts/effects/kenney/kenney_puff.gd, scenes/effects/kenney_puff.tscn)
## and Scenery's LAMP/BEACON light-mask glow (scripts/objects/scenery.gd):
##   1. A spawned puff frees itself on its own after its configured life.
##   2. Spawning every known puff kind (50 total, well past any single call
##      site's real usage) produces zero errors and every one still frees
##      itself — the "never grows unbounded" contract the audio pool docs
##      already hold elsewhere in this project.
##   3. Settings.reduced_motion disables the alarm beacon's pulsing ring
##      (scenery.gd `_process()`) without hiding it — same shape, dimmer,
##      never fully hidden, per style guide "respect Settings reduced
##      motion".
##   4. A LAMP Scenery's glow swaps utility -> lockdown textures live via
##      `set_lamp_examination_mode()`, the same call EnvironmentState makes
##      (revamp C24: that call now means Adam's lockdown) — and its real
##      PointLight2D takes the lockdown color with it, then returns to cold
##      white.
##   5. A lockdown LAMP's slow chase pulse runs only with reduced_motion off;
##      with it on, the lamp holds a steady light (never hidden).
##   6. The night overlay (scenes/world/night_overlay.tscn) sits above the
##      world but below every UI CanvasLayer (HUD is 15), never takes the
##      mouse, and only shows its lockdown edge once `awakening_done` is set.
##   7. (C35 lit cutouts) The smooth light textures are really smooth (a
##      downward cone with its apex at the centre, and a round falloff), not
##      the old stepped bands.
##   8. Lamp, beacon and fountain lights sit at their real source with a
##      `height`; a lockdown lamp's swivel turns its light about the head.
##   9. The depot's ceiling fixtures carry the same kind of light, one per
##      fixture, sitting at the fixture.
##  10. The moonlight scene: a faint, cool DirectionalLight2D set to light-mask
##      bit 2, the characters' bit (the Compatibility renderer ignores that
##      mask for directional lights, so it also washes the world; see
##      night_lighting.gd).
##  11. A shot flashes a short warm light at the muzzle that frees itself.
##
## Never touches a real save (no Session.commit()/CheckpointService write in
## this case at all, so no throwaway-dir redirect is needed — matches the
## pattern other purely-visual M6 cases use).

const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")
const SCENERY_SCENE := "res://scenes/objects/scenery.tscn"


func run() -> void:
	await _test_puff_self_frees()
	await _test_spawn_fifty_effects_no_errors()
	await _test_beacon_pulse_respects_reduced_motion()
	await _test_lamp_glow_lockdown_swap()
	await _test_lockdown_lamp_respects_reduced_motion()
	await _test_night_overlay_below_ui()
	_test_smooth_light_textures()
	await _test_world_lights_at_source_with_height()
	await _test_depot_fixture_lights()
	await _test_moonlight_scene()
	await _test_muzzle_flash_light()


func _make_host() -> Node:
	var host := Node2D.new()
	add_child(host)
	return host


# --- 1. a puff frees itself -------------------------------------------------

func _test_puff_self_frees() -> void:
	var host := _make_host()
	KenneyPuff.spawn(&"chip_sparkle", Vector2(100.0, 100.0), host)
	check_eq(host.get_child_count(), 1, "spawn() adds exactly one puff node under the host")
	var fx := host.get_child(0)
	# chip_sparkle's lifetime (0.35s) * 1.4 + 0.15 life-timeout margin, plus
	# slack for the fixed test step.
	await seconds(1.0)
	check(not is_instance_valid(fx), "the puff frees itself once its configured life elapses")
	check_eq(host.get_child_count(), 0, "the host is left with no leftover puff children")
	host.queue_free()
	await physics_frames(2)


# --- 2. spawn every kind, 50 total, no errors, all self-free ----------------

func _test_spawn_fifty_effects_no_errors() -> void:
	var host := _make_host()
	# M7 Kenney part B added `max_concurrent` (a deliberate rate-limit — see
	# kenney_puff.gd's own `_active_counts` doc comment) to a couple of
	# Clipper-specific kinds so rapid fire never floods the screen; a capped
	# kind being CAPPED here would be the feature working, not a silent drop,
	# so this "spawn a big burst, prove nothing is silently lost" check only
	# exercises the uncapped kinds. The cap itself is proven directly by
	# test_kenney_part_b.gd's own frontal-clang case.
	var kinds: Array = []
	for k in KenneyPuff.CONFIGS.keys():
		if not KenneyPuff.CONFIGS[k].has("max_concurrent"):
			kinds.append(k)
	var spawned := 0
	while spawned < 50:
		for kind in kinds:
			KenneyPuff.spawn(kind, Vector2(spawned * 4.0, 0.0), host)
			spawned += 1
			if spawned >= 50:
				break
	check_eq(host.get_child_count(), 50, "all 50 requested puffs were actually added (no silent drops)")
	# Longest configured life is checkpoint_sparkle (0.50s) -> life ~0.85s.
	await seconds(1.2)
	check_eq(host.get_child_count(), 0,
			"every one of the 50 puffs freed itself — no leak from spawning effects in a burst")
	host.queue_free()
	await physics_frames(2)


# --- 3. reduced_motion holds the beacon ring steady but visible -------------

func _test_beacon_pulse_respects_reduced_motion() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()

	Settings.set_reduced_motion(false)
	var beacon_normal: Node2D = load(SCENERY_SCENE).instantiate()
	beacon_normal.kind = Scenery.Kind.BEACON
	beacon_normal.size = Vector2(36.0, 36.0)
	add_child(beacon_normal)
	await physics_frames(1)
	check(beacon_normal.is_processing(),
			"a BEACON scenery prop processes (pulses) its ring when reduced_motion is off")
	var ring_normal: Sprite2D = beacon_normal._beacon_ring
	check(ring_normal != null and ring_normal.visible,
			"the pulsing ring is present and visible with reduced_motion off")
	var alpha_before: float = ring_normal.modulate.a
	await seconds(0.3)
	check(not is_equal_approx(ring_normal.modulate.a, alpha_before),
			"the ring's alpha actually changes frame to frame while pulsing (reduced_motion off)")
	beacon_normal.queue_free()
	await physics_frames(2)

	Settings.set_reduced_motion(true)
	var beacon_reduced: Node2D = load(SCENERY_SCENE).instantiate()
	beacon_reduced.kind = Scenery.Kind.BEACON
	beacon_reduced.size = Vector2(36.0, 36.0)
	add_child(beacon_reduced)
	await physics_frames(1)
	check(not beacon_reduced.is_processing(),
			"a BEACON scenery prop does NOT process (does not pulse) its ring when reduced_motion is on")
	var ring_reduced: Sprite2D = beacon_reduced._beacon_ring
	check(ring_reduced != null and ring_reduced.visible and ring_reduced.modulate.a > 0.0,
			"reduced_motion never hides the alarm ring outright — same shape, just held steady")
	var alpha_held: float = ring_reduced.modulate.a
	await seconds(0.3)
	check(is_equal_approx(ring_reduced.modulate.a, alpha_held),
			"the held-steady ring's alpha does not drift on its own while reduced_motion is on")
	beacon_reduced.queue_free()
	await physics_frames(2)

	Settings.set_reduced_motion(base_reduced)


# --- 4. LAMP glow swaps utility <-> lockdown live --------------------------

func _test_lamp_glow_lockdown_swap() -> void:
	var lamp: Node2D = load(SCENERY_SCENE).instantiate()
	lamp.kind = Scenery.Kind.LAMP
	lamp.size = Vector2(50.0, 150.0)
	add_child(lamp)
	await physics_frames(1)

	check(lamp.has_method("set_lamp_examination_mode"),
			"a LAMP Scenery exposes set_lamp_examination_mode() for EnvironmentState to call")
	var circle: Sprite2D = lamp._lamp_glow_circle
	var beam: Sprite2D = lamp._lamp_glow_beam
	var light: PointLight2D = lamp._lamp_light
	check(circle != null and beam != null, "a LAMP Scenery builds its glow circle + beam sprites in _ready()")
	check(light != null, "a LAMP Scenery carries a real PointLight2D for its light pool")
	check_eq(circle.texture, Scenery.GLOW_CIRCLE_UTILITY, "starts in the plain utility-lamp glow")

	var red := Color("#FF3B4E")
	lamp.set_lamp_examination_mode(true, false, red)
	check_eq(circle.texture, Scenery.GLOW_CIRCLE_LOCKDOWN, "lockdown swaps the circle to the brighter texture")
	check_eq(beam.texture, Scenery.GLOW_CONE_LOCKDOWN, "lockdown swaps the beam to the spotlight-cone texture")
	check(light.color.is_equal_approx(red), "the lamp's light takes the lockdown color it was given")

	lamp.set_lamp_examination_mode(false)
	check_eq(circle.texture, Scenery.GLOW_CIRCLE_UTILITY, "switching back restores the plain utility glow")
	check(light.color.r < 0.95 and light.color.b > 0.9, "switching back restores the cold-white light")

	lamp.queue_free()
	await physics_frames(2)


# --- 5. lockdown lamp chase respects reduced_motion ------------------------

func _test_lockdown_lamp_respects_reduced_motion() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()

	Settings.set_reduced_motion(false)
	var lamp: Node2D = load(SCENERY_SCENE).instantiate()
	lamp.kind = Scenery.Kind.LAMP
	lamp.size = Vector2(30.0, 150.0)
	add_child(lamp)
	await physics_frames(1)
	check(not lamp.is_processing(), "a lamp outside lockdown does not process (no pulse)")
	lamp.set_lamp_examination_mode(true)
	check(lamp.is_processing(), "a lockdown lamp pulses its slow chase with reduced_motion off")
	lamp.queue_free()
	await physics_frames(2)

	Settings.set_reduced_motion(true)
	var steady: Node2D = load(SCENERY_SCENE).instantiate()
	steady.kind = Scenery.Kind.LAMP
	steady.size = Vector2(30.0, 150.0)
	add_child(steady)
	await physics_frames(1)
	steady.set_lamp_examination_mode(true)
	check(not steady.is_processing(), "a lockdown lamp does NOT pulse with reduced_motion on")
	var light: PointLight2D = steady._lamp_light
	var energy_held: float = light.energy
	await seconds(0.4)
	check(light.visible and energy_held > 0.0 and is_equal_approx(light.energy, energy_held),
			"the reduced-motion lockdown light stays on, steady")
	steady.queue_free()
	await physics_frames(2)

	Settings.set_reduced_motion(base_reduced)


# --- 6. night overlay: above the world, below every UI layer ----------------

func _test_night_overlay_below_ui() -> void:
	const OVERLAY_SCENE := "res://scenes/world/night_overlay.tscn"
	const HUD_LAYER := 15  # scripts/ui/hud.gd
	check(ResourceLoader.exists(OVERLAY_SCENE), "the night overlay scene exists for LevelDirector to instance")
	Session.new_run()
	var overlay: CanvasLayer = load(OVERLAY_SCENE).instantiate()
	add_child(overlay)
	await physics_frames(2)
	check(overlay.layer > 0 and overlay.layer < HUD_LAYER,
			"the overlay sits above the world (layer %d > 0) and below the HUD (%d)" % [overlay.layer, HUD_LAYER])
	var screen: Control = overlay.get_node("Screen")
	check_eq(screen.mouse_filter, Control.MOUSE_FILTER_IGNORE, "the overlay never takes mouse input")
	var mat: ShaderMaterial = screen.material
	check(float(mat.get_shader_parameter("alarm_strength")) <= 0.0001,
			"no lockdown edge before awakening")
	# Set directly (no story_state_changed): the overlay polls the flag, and
	# this keeps the global audio director's lockdown music out of the case.
	Session.state["story"]["awakening_done"] = true
	await seconds(2.0)
	check(float(mat.get_shader_parameter("alarm_strength")) > 0.0,
			"the faint lockdown edge shows once awakening_done is set")
	overlay.queue_free()
	await physics_frames(2)
	Session.new_run()



# --- 7. the light textures are smooth, not stepped bands ----------------------

func _alpha_at(img: Image, x: int, y: int) -> float:
	return img.get_pixel(x, y).a


func _test_smooth_light_textures() -> void:
	var cone: Texture2D = SceneryDraw.smooth_cone_texture()
	var disc: Texture2D = SceneryDraw.smooth_disc_texture()
	check(cone != null and disc != null, "the smooth cone and disc light textures are generated")
	check_eq(SceneryDraw.smooth_cone_texture(), cone, "the cone texture is built once and shared")
	var ci := cone.get_image()
	var di := disc.get_image()
	var n := ci.get_width()
	var c := n / 2
	# Many distinct alpha levels along the beam's axis: a falloff, not bands.
	var levels := {}
	for y in range(c, n):
		levels[int(round(_alpha_at(ci, c, y) * 255.0))] = true
	check(levels.size() >= 24, "the cone's alpha falls off smoothly along its axis (%d levels, stepped bands had 3)" % levels.size())
	# The apex is at the centre and the beam points down.
	check(_alpha_at(ci, c, c + 8) > 0.9, "the cone is brightest at its apex, at the texture centre")
	check(_alpha_at(ci, c, c + n / 4) > 0.3, "the beam carries on down the axis")
	check(_alpha_at(ci, c, c - n / 4) < 0.1, "nothing above the apex but a faint halo (the cone points down)")
	check(_alpha_at(ci, c + n / 3, c + 8) < 0.05, "the beam does not spread sideways at the apex's height")
	check(_alpha_at(ci, c + n / 8, c + n / 4) < _alpha_at(ci, c, c + n / 4), "the beam is dimmer off its axis")
	# Symmetric about the axis, and dark at the texture's edges.
	check(absf(_alpha_at(ci, c + 40, c + 120) - _alpha_at(ci, c - 41, c + 120)) < 0.01, "the cone is left-right symmetric")
	check(_alpha_at(ci, c, n - 1) < 0.02 and _alpha_at(ci, 0, c) < 0.02, "the cone fades out before the texture edge")
	# The disc: bright core, monotonic falloff, dark rim, round.
	var dn := di.get_width()
	var dc := dn / 2
	check(_alpha_at(di, dc, dc) > 0.95, "the disc's core is at full strength")
	var prev := 2.0
	var monotonic := true
	for x in range(dc, dn):
		var a := _alpha_at(di, x, dc)
		if a > prev + 0.004:
			monotonic = false
		prev = a
	check(monotonic, "the disc falls off steadily from its centre")
	check(_alpha_at(di, dn - 1, dc) < 0.02, "the disc is dark at its rim")
	check(absf(_alpha_at(di, dc + 50, dc) - _alpha_at(di, dc, dc + 50)) < 0.02, "the disc is round")


# --- 8. world lights sit at their source, with a height -----------------------

func _test_world_lights_at_source_with_height() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)
	var lamp: Node2D = load(SCENERY_SCENE).instantiate()
	lamp.kind = Scenery.Kind.LAMP
	lamp.size = Vector2(30.0, 150.0)
	lamp.position = Vector2(400.0, 0.0)
	add_child(lamp)
	await physics_frames(1)
	var light: PointLight2D = lamp._lamp_light
	var head: Vector2 = lamp.to_global(lamp._lamp_head() + Vector2(0.0, 4.0))
	check_eq(light.texture, SceneryDraw.smooth_cone_texture(), "a lamp's light is the smooth cone")
	check(light.height > 0.0, "a lamp's light has a height (%.0f) so normal-mapped characters are lit from it" % light.height)
	check(light.global_position.is_equal_approx(head), "a lamp's light sits AT the lamp head, not down its beam (%s vs %s)" % [light.global_position, head])
	check(light.energy >= 1.4 and light.energy <= 2.0, "a lamp's light is strong enough to show a pool (energy %.2f)" % light.energy)
	check(light.range_item_cull_mask == 1, "the lamp light reaches world items (bit 1) only, never the moon's character bit")
	# The reach clears the ground under the lamp, however tall it is.
	var ground_gap: float = absf(lamp._lamp_head().y)
	check(light.texture_scale * light.texture.get_width() * 0.5 > ground_gap, "the beam reaches past the ground line (reach %.0f, head at %.0f)" % [
			light.texture_scale * light.texture.get_width() * 0.5, ground_gap])
	# Lockdown: the head swivels and the light turns about it, staying put.
	lamp.set_lamp_examination_mode(true, false, Color("#FFB02E"))
	check(absf(lamp._lamp_pivot.rotation) > 0.05, "a lockdown lamp swivels its head")
	check(light.global_position.is_equal_approx(head), "the swivel turns the light about the head; it stays at the head")
	check(light.height > 0.0 and light.texture == SceneryDraw.smooth_cone_texture(), "a lockdown lamp keeps its height and cone")
	lamp.queue_free()

	var beacon: Node2D = load(SCENERY_SCENE).instantiate()
	beacon.kind = Scenery.Kind.BEACON
	beacon.size = Vector2(36.0, 36.0)
	add_child(beacon)
	var fountain: Node2D = load(SCENERY_SCENE).instantiate()
	fountain.kind = Scenery.Kind.FOUNTAIN
	fountain.size = Vector2(140.0, 110.0)
	add_child(fountain)
	await physics_frames(1)
	var bl: PointLight2D = beacon._beacon_light
	var fl: PointLight2D = fountain._fountain_light
	check(bl != null and fl != null, "beacons and fountains carry a real light")
	check_eq(bl.texture, SceneryDraw.smooth_disc_texture(), "a beacon's light is a smooth disc")
	check_eq(fl.texture, SceneryDraw.smooth_disc_texture(), "a fountain's light is a smooth disc")
	check(bl.height > 0.0 and fl.height > 0.0, "beacon (%.0f) and fountain (%.0f) lights have heights" % [bl.height, fl.height])
	check(bl.height > fl.height, "the beacon's dome hangs higher than the fountain's underlight")
	check(bl.global_position.is_equal_approx(beacon.to_global(Vector2(0.0, -36.0 * 0.62))), "the beacon light sits at its dome")
	beacon.queue_free()
	fountain.queue_free()
	await physics_frames(2)
	Settings.set_reduced_motion(base_reduced)


# --- 9. the depot's ceiling fixtures --------------------------------------------

func _test_depot_fixture_lights() -> void:
	var backdrop := Parallax2D.new()
	backdrop.set_script(load("res://scripts/world/visuals/area_backdrop.gd"))
	backdrop.set("mode", 2)  # DEPOT
	backdrop.set("tile_width", 2000.0)
	backdrop.set("horizon_y", 0.0)
	add_child(backdrop)
	await physics_frames(1)
	var lights: Array = backdrop._fixture_lights
	var fixtures: Array = backdrop._fixtures
	check(fixtures.size() >= 3 and lights.size() == fixtures.size(), "one light per ceiling fixture (%d lights, %d fixtures)" % [lights.size(), fixtures.size()])
	var ok := true
	for i in lights.size():
		var l: PointLight2D = lights[i]
		var at := Vector2(float(fixtures[i]), backdrop.CEILING_Y + 8.0)
		if l.texture != SceneryDraw.smooth_cone_texture() or l.height <= 0.0 or not l.position.is_equal_approx(at):
			ok = false
	check(ok, "every depot fixture's light is a smooth cone with a height, placed AT its fixture")
	var floor_gap: float = 0.0 - (backdrop.CEILING_Y + 8.0)
	var l0: PointLight2D = lights[0]
	check(l0.texture_scale * l0.texture.get_width() * 0.5 > floor_gap, "a fixture's light reaches the depot floor")
	# Lockdown: the banks still switch off, then come back alarm red.
	backdrop.set_lockdown_mode(true, false)
	check(l0.visible and l0.color.is_equal_approx(backdrop.ALARM), "a settled lockdown turns the fixtures alarm red")
	backdrop.set_lockdown_mode(false, false)
	check(l0.visible and l0.color.is_equal_approx(backdrop.UTILITY_LIGHT), "and back to teal when the lockdown is off")
	backdrop.queue_free()
	await physics_frames(2)


# --- 10. the moonlight scene -------------------------------------------------------

func _test_moonlight_scene() -> void:
	const MOON_SCENE := "res://scenes/world/night_lighting.tscn"
	check(ResourceLoader.exists(MOON_SCENE), "the night lighting scene exists for LevelDirector to instance")
	var lighting: Node = load(MOON_SCENE).instantiate()
	add_child(lighting)
	await physics_frames(1)
	var moon: DirectionalLight2D = lighting.moon
	check(moon != null, "the scene carries the moonlight DirectionalLight2D")
	check_eq(moon.range_item_cull_mask, 2, "the moon is set to light-mask bit 2 (the characters' bit), not bit 1 (the world lights')")
	check(moon.energy >= 0.3 and moon.energy <= 0.45, "the moon is faint (energy %.2f)" % moon.energy)
	check(moon.color.b > moon.color.r and moon.color.is_equal_approx(Color("#7E93C9")), "the moon is cool blue (#7E93C9)")
	check(moon.height > 0.0 and moon.height < 1.0, "the moon has a low height for normal-mapped rim light")
	check_eq(moon.blend_mode, Light2D.BLEND_MODE_ADD, "the moon adds light")
	check(moon.rotation < 0.0, "the moon comes from the upper left")
	lighting.set_enabled(false)
	check(not moon.enabled, "the moon can be switched off")
	lighting.queue_free()
	await physics_frames(2)


# --- 11. a shot flashes a warm light at the muzzle ---------------------------------

func _test_muzzle_flash_light() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)
	Session.new_run()
	var holder := Node2D.new()
	add_child(holder)
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	hero.position = Vector2(0.0, -1.0)
	hero.use_aim_override = true
	hero.aim_override = Vector2(600.0, -70.0)
	holder.add_child(hero)
	await physics_frames(2)
	var gun: Scrapjack = hero.get_node("AimPivot/Scrapjack")
	check(_flash_lights().is_empty(), "no muzzle flash light before the first shot")
	gun._try_fire()
	var flashes := _flash_lights()
	check_eq(flashes.size(), 1, "one shot adds exactly one muzzle flash light")
	if flashes.size() == 1:
		var f: PointLight2D = flashes[0]
		check(f.color.is_equal_approx(Color("#FFE4BD")), "the flash is warm ivory (#FFE4BD)")
		check(f.energy > 1.5, "the flash starts bright (energy %.2f)" % f.energy)
		check(f.height > 10.0, "the flash has a height (%.0f) so characters are lit from the muzzle" % f.height)
		check(f.global_position.distance_to(gun.get_muzzle_global_position()) < 1.0, "the flash sits at the muzzle")
		check_eq(f.texture, SceneryDraw.smooth_disc_texture(), "the flash is a smooth disc")
		await seconds(0.3)
		check(not is_instance_valid(f), "the flash frees itself well within a third of a second")
	check(_flash_lights().is_empty(), "no flash lights are left behind")
	# Reduced motion halves the flash rather than removing the light.
	Settings.set_reduced_motion(true)
	await seconds(0.5)
	gun._try_fire()
	var soft := _flash_lights()
	check_eq(soft.size(), 1, "the flash still shows under reduced motion")
	if soft.size() == 1:
		check(soft[0].energy < 1.5 and soft[0].energy > 0.0, "and is softer (energy %.2f)" % soft[0].energy)
	# A gun freed mid-flash leaves nothing dangling: the flash outlives it.
	await seconds(0.3)
	holder.queue_free()
	await physics_frames(2)
	Settings.set_reduced_motion(base_reduced)
	Session.new_run()


func _flash_lights() -> Array:
	var out: Array = []
	for n in get_tree().root.find_children("MuzzleFlashLight*", "PointLight2D", true, false):
		out.append(n)
	return out
