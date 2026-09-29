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

