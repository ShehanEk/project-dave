extends TestCase
## Level 2 v2's hazards (scripts/objects/hazard_vent.gd, vent_sequencer.gd, conveyor.gd):
##   - H1/H2 the cycle: IDLE -> WARN (0.8 s) -> ACTIVE (steam 1.2 s, cable 1.0 s) -> IDLE, in
##     that order, the warning always first; amber warning turning red for its last 0.25 s;
##   - damage only while ACTIVE, one hit per immunity window, nothing outside the area, a held
##     jump clears the cable strip;
##   - reduced motion: the warning glow is steady and the arc holds one shape; normal motion
##     breathes at most 1.5 Hz;
##   - S5 the sequencer: vents fire in order `spacing` apart, they do not cycle on their own,
##     the wave loops after `rest`, reverse and the approach trigger work;
##   - H3 the conveyor: a standing hero is carried about speed x time, jumping off or walking
##     off the end adds no launch, and walking against the belt still makes progress.

const VENT_SCENE := "res://scenes/objects/hazard_vent.tscn"
const SEQ_SCENE := "res://scenes/objects/vent_sequencer.tscn"
const CONVEYOR_SCENE := "res://scenes/objects/conveyor.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const HazardVent := preload("res://scripts/objects/hazard_vent.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const FLOOR_Y := 560.0
const TICK := 1.0 / 60.0


func run() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)
	await _test_cycle_steam()
	await _test_cycle_cable_and_defaults()
	await _test_red_tell()
	await _test_phase_never_starts_live()
	await _test_damage_only_active()
	await _test_cable_jump_clears()
	await _test_reduced_motion()
	await _test_sequencer_order_and_loop()
	await _test_sequencer_reverse_and_approach()
	await _test_conveyor_carry()
	await _test_conveyor_leaving()
	await _test_conveyor_against()
	await _test_conveyor_rules()
	Settings.set_reduced_motion(base_reduced)
	release_all()
	Session.new_run()


# --- helpers -------------------------------------------------------------------------------

func _floor() -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(-1500, FLOOR_Y)
	b.size = Vector2(4000, 200)
	add_child(b)
	return b


func _hero(pos: Vector2, input: bool = false) -> Hero:
	var hero: Hero = load(HERO_SCENE).instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.input_enabled = input
	return hero


func _vent(kind: int = HazardVent.Kind.STEAM, at: Vector2 = Vector2(0, FLOOR_Y), autostart: bool = true) -> Area2D:
	var v: Area2D = load(VENT_SCENE).instantiate()
	v.kind = kind
	v.autostart = autostart
	v.position = at
	return v


func _clear() -> void:
	release_all()
	for c in get_children():
		c.queue_free()
	await physics_frames(2)


## Steps `ticks` physics frames and returns the frames at which `vent.state` changed, as
## [[tick, new_state], ...] (tick counted from 0 at the first frame stepped).
func _transitions(vent: Node, ticks: int) -> Array:
	var out: Array = []
	var last: int = vent.state
	for i in ticks:
		await physics_frames(1)
		if vent.state != last:
			last = vent.state
			out.append([i, last])
	return out


# --- 1. the cycle ----------------------------------------------------------------------------

func _test_cycle_steam() -> void:
	var v := _vent()
	v.idle_time = 0.5
	add_child(v)
	check_eq(v.state, HazardVent.State.IDLE, "steam vent starts idle (phase 0: the cycle opens with its quiet part)")
	check_eq(v.get_active_time(), 1.2, "steam: active 1.2 s by default")
	check_eq(v.warn_time, 0.8, "warn 0.8 s by default")
	check(v.collision_layer == 1 << 7 and v.collision_mask == 1 << 1, "the damage area is on the hazard layer and sees the hero body")
	var tr := await _transitions(v, 330)
	var order: Array = tr.map(func(t): return t[1])
	check(order.size() >= 6, "two and a half cycles show at least six transitions (got %d)" % order.size())
	var ok := true
	for i in order.size():
		var expect: int = [HazardVent.State.WARN, HazardVent.State.ACTIVE, HazardVent.State.IDLE][i % 3]
		ok = ok and order[i] == expect
	check(ok, "the order is always WARN -> ACTIVE -> IDLE: warning first (%s)" % str(order))
	# durations between transitions: idle 0.5, warn 0.8, active 1.2
	var d_warn := float(tr[1][0] - tr[0][0]) * TICK
	var d_active := float(tr[2][0] - tr[1][0]) * TICK
	var d_idle := float(tr[3][0] - tr[2][0]) * TICK
	check(absf(d_warn - 0.8) <= 0.04, "warn lasts 0.8 s (%.3f)" % d_warn)
	check(absf(d_active - 1.2) <= 0.04, "steam active lasts 1.2 s (%.3f)" % d_active)
	check(absf(d_idle - 0.5) <= 0.04, "idle lasts idle_time (%.3f)" % d_idle)
	check_eq(v.damage_rect(), Rect2(-36.0, -144.0, 72.0, 144.0), "the steam column is 72 x 144 (1.5 H) standing on the origin")
	check_eq(v.damage, 1, "it costs 1 health")
	await _clear()


func _test_cycle_cable_and_defaults() -> void:
	var c := _vent(HazardVent.Kind.CABLE)
	c.idle_time = 0.5
	add_child(c)
	check_eq(c.get_active_time(), 1.0, "cable: active 1.0 s by default")
	var tr := await _transitions(c, 220)
	check(tr.size() >= 3, "cable cycles")
	var d_active := float(tr[2][0] - tr[1][0]) * TICK
	check(absf(d_active - 1.0) <= 0.04, "the arc lasts 1.0 s (%.3f)" % d_active)
	check_eq(c.damage_rect(), Rect2(-96.0, -30.0, 192.0, 30.0), "the cable strip is `length` wide and 30 px tall, on the floor")
	# an explicit active_time wins; warn is never shorter than MIN_WARN
	c.active_time = 0.7
	check_eq(c.get_active_time(), 0.7, "active_time overrides the kind default")
	c.warn_time = 0.1
	check_eq(c.warn_duration(), HazardVent.MIN_WARN, "a warning is never shorter than MIN_WARN")
	await _clear()


func _test_red_tell() -> void:
	var v := _vent()
	v.idle_time = 0.2
	add_child(v)
	var warn_ticks := 0
	var red_ticks := 0
	var first_red_remaining := -1.0
	var amber_first := false
	var red_before_end := true
	var red_seen := false
	var active_red := false
	var cycle_done := false
	for i in 150:
		await physics_frames(1)
		if v.state == HazardVent.State.WARN and not cycle_done:
			warn_ticks += 1
			if warn_ticks == 1:
				amber_first = (not v.is_red_tell()) and v.lamp_color() == HazardVent.AMBER
			if v.is_red_tell():
				red_ticks += 1
				if not red_seen:
					red_seen = true
					first_red_remaining = v.warn_remaining()
				red_before_end = red_before_end and v.lamp_color() == HazardVent.RED
			else:
				check(not red_seen, "once the warning turns red it stays red")
				check_eq(v.lamp_color(), HazardVent.AMBER, "the early warning is amber")
		elif v.state == HazardVent.State.ACTIVE:
			cycle_done = true
			active_red = v.lamp_color() == HazardVent.RED
	check(amber_first, "the warning starts amber, not red")
	check(red_seen and first_red_remaining <= HazardVent.RED_TIME + TICK, "red begins at 0.25 s from the end (%.3f s left)" % first_red_remaining)
	check(absi(red_ticks - 15) <= 2, "about 0.25 s of red (%d ticks)" % red_ticks)
	check(red_before_end, "the lamp is red through the last 0.25 s")
	check(active_red, "the lamp stays red while the hazard is live")
	check_eq(v.lamp_color(), HazardVent.AMBER if v.state == HazardVent.State.WARN else v.lamp_color(), "lamp_color reads the current state")
	await _clear()


func _test_phase_never_starts_live() -> void:
	# A phase that lands in ACTIVE starts at the top of the warning instead.
	var v := _vent()
	v.idle_time = 1.0
	v.phase = 2.2   # idle 0..1, warn 1..1.8, active 1.8..3.0
	add_child(v)
	check_eq(v.state, HazardVent.State.WARN, "a phase inside ACTIVE starts at the top of the WARN: never live on load")
	check(absf(v.warn_remaining() - 0.8) <= 0.001, "...with the full warning to run")
	await _clear()
	var w := _vent()
	w.idle_time = 1.0
	w.phase = 0.4   # inside the idle part: it starts idle, 0.6 s from its warning
	add_child(w)
	check_eq(w.state, HazardVent.State.IDLE, "a phase inside the quiet part starts idle")
	var tr := await _transitions(w, 60)
	check(tr.size() >= 1 and tr[0][1] == HazardVent.State.WARN and absf(float(tr[0][0]) * TICK - 0.6) <= 0.05,
			"...and warns after the rest of the idle part (%s)" % str(tr))
	await _clear()


# --- 2. damage -------------------------------------------------------------------------------

func _test_damage_only_active() -> void:
	Session.new_run()
	var floor_b := _floor()
	var v := _vent()
	v.idle_time = 0.5
	v.active_time = 0.8
	add_child(v)
	var hero := _hero(Vector2(0, FLOOR_Y - 1.0))
	hero.set_physics_process(false)   # parked inside the column
	var hits: Array = []
	v.hit.connect(func(h): hits.append(h))
	var start_health: int = Session.get_health()
	var hp_before_active := -1
	var hp_during_warn := true
	for i in 100:
		await physics_frames(1)
		if v.state != HazardVent.State.ACTIVE:
			if Session.get_health() != start_health:
				hp_during_warn = false
		elif hp_before_active < 0:
			hp_before_active = Session.get_health()
	check(hp_during_warn, "no damage while idle or warning, with Dave standing in the column")
	check_eq(hits.size(), 1, "an 0.8 s burst hurts a standing hero exactly once (the immunity window covers it)")
	check_eq(Session.get_health(), start_health - 1, "...for 1 health")
	await seconds(1.2)
	# repeat hits are one per immunity window: a 1.2 s steam burst over a hero who stays put can hit
	# again once the 1.0 s window closes, never sooner
	v.active_time = 1.2
	hits.clear()
	var times: Array = []
	v.hit.connect(func(_h): times.append(Engine.get_physics_frames()))
	hero._immune_timer = 0.0
	await seconds(4.0)
	check(hits.size() <= 2 and times.size() == hits.size(), "a standing hero takes at most 2 hits in a 1.2 s burst (got %d)" % times.size())
	if times.size() == 2:
		check(float(times[1] - times[0]) * TICK >= 0.98, "...and never closer than the 1.0 s immunity window (%.2f s)" % (float(times[1] - times[0]) * TICK))
	# outside the column: nothing
	hero.global_position = Vector2(200.0, FLOOR_Y - 1.0)
	await physics_frames(3)   # the area's overlap list catches up with the move
	hero._immune_timer = 0.0
	var hp := Session.get_health()
	await seconds(4.0)
	check_eq(Session.get_health(), hp, "a hero beside the column is never hurt")
	# above the column's top: nothing
	hero.global_position = Vector2(0.0, FLOOR_Y - 160.0)
	await physics_frames(3)
	hero._immune_timer = 0.0
	hp = Session.get_health()
	await seconds(4.0)
	check_eq(Session.get_health(), hp, "a hero above the 1.5 H column is never hurt")
	hero.queue_free()
	floor_b.queue_free()
	await _clear()


func _test_cable_jump_clears() -> void:
	Session.new_run()
	var c := _vent(HazardVent.Kind.CABLE)
	c.idle_time = 0.3
	add_child(c)
	var hero := _hero(Vector2(0, FLOOR_Y - 40.0))   # feet 40 px up: over the 30 px strip
	hero.set_physics_process(false)
	var hp := Session.get_health()
	await seconds(2.5)
	check_eq(Session.get_health(), hp, "a hero whose feet are 40 px up passes over the 30 px arc through a whole burst")
	hero.global_position = Vector2(0, FLOOR_Y - 8.0)   # feet 8 px up: inside it
	hero._immune_timer = 0.0
	await seconds(3.2)
	check(Session.get_health() < hp, "a hero whose feet are 8 px up is hit")
	hero.queue_free()
	await _clear()


# --- 3. reduced motion -------------------------------------------------------------------------

func _test_reduced_motion() -> void:
	var v := _vent()
	v.idle_time = 0.2
	add_child(v)
	var cable := _vent(HazardVent.Kind.CABLE)
	cable.idle_time = 0.2
	add_child(cable)
	# normal motion: samples of the warning glow breathe, smoothly, at most 1.5 Hz
	Settings.set_reduced_motion(false)
	var normal: Array = []
	var step_max := 0.0
	var arc_steps: Dictionary = {}
	var last_g := -1.0
	for i in 200:
		await physics_frames(1)
		if v.state == HazardVent.State.WARN:
			var g: float = v.glow_level()
			if last_g >= 0.0:
				step_max = maxf(step_max, absf(g - last_g))
			last_g = g
			normal.append(g)
		else:
			last_g = -1.0
		if cable.state == HazardVent.State.ACTIVE:
			arc_steps[cable.arc_step()] = true
	var lo := 9.0
	var hi := -1.0
	for g in normal:
		lo = minf(lo, g)
		hi = maxf(hi, g)
	check(normal.size() > 20 and hi - lo > 0.05, "normal motion: the warning glow breathes (%.2f..%.2f)" % [lo, hi])
	check(hi <= 1.0 and lo >= 0.5, "...but never blinks off (never below 0.5)")
	check(step_max < 0.08, "...smoothly, frame to frame (largest step %.3f)" % step_max)
	check(HazardVent.GLOW_HZ < 2.0, "the glow's rate is under the 2 Hz flash limit")
	check(arc_steps.size() >= 2, "normal motion: the arc re-forms while live")
	# reduced motion: steady
	Settings.set_reduced_motion(true)
	var steady: Array = []
	var arc_steps_r: Dictionary = {}
	for i in 220:
		await physics_frames(1)
		if v.state == HazardVent.State.WARN:
			steady.append(v.glow_level())
		if cable.state == HazardVent.State.ACTIVE:
			arc_steps_r[cable.arc_step()] = true
	var all_same := steady.size() > 20
	for g in steady:
		all_same = all_same and is_equal_approx(g, steady[0])
	check(all_same, "reduced motion: the warning glow is steady")
	check_eq(arc_steps_r.size(), 1, "reduced motion: the arc holds one shape")
	check(v.glow_level() == 0.0 or v.glow_level() == 1.0 or is_equal_approx(v.glow_level(), 0.85), "reduced motion: only steady glow levels")
	Settings.set_reduced_motion(false)
	await _clear()


# --- 4. the sequencer ------------------------------------------------------------------------

func _wave_rig(n: int, spacing: float, rest: float, autostart: bool = true) -> Node2D:
	var seq: Node2D = load(SEQ_SCENE).instantiate()
	seq.spacing = spacing
	seq.rest = rest
	seq.autostart = autostart
	seq.position = Vector2(0, FLOOR_Y)
	for i in n:
		var v := _vent()
		v.name = "Vent%d" % i
		v.position = Vector2(float(i) * 150.0, 0.0)
		v.idle_time = 0.5   # would cycle by itself if left alone
		seq.add_child(v)
	add_child(seq)
	return seq


func _test_sequencer_order_and_loop() -> void:
	var seq := _wave_rig(4, 0.5, 1.0, false)
	await physics_frames(3)
	for v in seq.get_children():
		check(v.driven and not v.is_cycling(), "%s is driven: it does not cycle on its own" % v.name)
	await seconds(3.0)
	for v in seq.get_children():
		check_eq(v.state, HazardVent.State.IDLE, "%s stays idle with no wave (3 s)" % v.name)
	var fires: Array = []    # [index, tick]
	var actives: Dictionary = {}
	var warns: Dictionary = {}
	seq.vent_fired.connect(func(i, _v): fires.append([i, Engine.get_physics_frames()]))
	for v in seq.get_children():
		var name_v: String = v.name
		v.state_changed.connect(func(s):
			if s == HazardVent.State.ACTIVE and not actives.has(name_v + str(actives.size())):
				actives[name_v + "@" + str(Engine.get_physics_frames())] = true
			if s == HazardVent.State.WARN:
				warns[name_v + "@" + str(Engine.get_physics_frames())] = true)
	seq.start()
	# one period: 3 x 0.5 + 0.8 + 1.2 + rest 1.0 = 4.5 s; watch 2.4 periods
	check(absf(seq.period() - 4.5) <= 0.001, "period = (n-1) x spacing + warn + active + rest (%.3f)" % seq.period())
	await seconds(4.5 * 2.0 + 2.0)
	check(fires.size() >= 8, "the wave loops: at least two full waves (%d fires)" % fires.size())
	var in_order := true
	for i in fires.size():
		in_order = in_order and fires[i][0] == i % 4
	check(in_order, "vents fire in order 0,1,2,3,0,1,2,3")
	for i in range(1, 4):
		var gap := float(fires[i][1] - fires[i - 1][1]) * TICK
		check(absf(gap - 0.5) <= 0.04, "vent %d fires 0.5 s after vent %d (%.3f)" % [i, i - 1, gap])
	var wave_gap := float(fires[4][1] - fires[0][1]) * TICK
	check(absf(wave_gap - 4.5) <= 0.08, "the next wave starts one period later (%.3f s)" % wave_gap)
	# the steam of vent i starts warn after its fire: the front moves one vent per spacing
	check(seq.get_child(0).get_active_time() == 1.2, "each vent still shows its own full warning and burst")
	# never two steps at once: every WARN is preceded by a fire (all warns come from fire())
	check(warns.size() >= 8, "every fire shows a warning (%d warns for %d fires)" % [warns.size(), fires.size()])
	seq.stop()
	await physics_frames(2)
	for v in seq.get_children():
		check_eq(v.state, HazardVent.State.IDLE, "stop() idles every vent")
	await _clear()


func _test_sequencer_reverse_and_approach() -> void:
	# reverse: last to first
	var seq := _wave_rig(3, 0.3, 1.0, false)
	seq.reverse = true
	await physics_frames(3)
	var order: Array = []
	seq.vent_fired.connect(func(_i, v): order.append(String(v.name)))
	seq.start()
	await seconds(1.2)
	check_eq(order, ["Vent2", "Vent1", "Vent0"], "reverse fires the last vent first")
	seq.stop()
	await _clear()
	# approach: nothing until the hero crosses x
	var seq2 := _wave_rig(3, 0.3, 1.0, true)
	seq2.start_on_approach = true
	seq2.approach_x = 1000.0
	seq2.approach_dir = 1
	var hero := _hero(Vector2(0, FLOOR_Y - 1.0))
	hero.set_physics_process(false)
	await seconds(1.5)
	for v in seq2.get_children():
		check_eq(v.state, HazardVent.State.IDLE, "%s waits for the hero to approach" % v.name)
	hero.global_position = Vector2(1100.0, FLOOR_Y - 1.0)
	await seconds(0.3)
	check_eq(seq2.get_child(0).state, HazardVent.State.WARN, "the hero passing approach_x starts the wave")
	await _clear()
	# approach by area
	var seq3 := _wave_rig(2, 0.3, 1.0, true)
	seq3.start_on_approach = true
	var trigger := Area2D.new()
	trigger.name = "Trigger"
	trigger.collision_layer = 0
	trigger.collision_mask = 1 << 1
	trigger.position = Vector2(500.0, FLOOR_Y - 50.0)
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(100, 100)
	cs.shape = rs
	trigger.add_child(cs)
	add_child(trigger)
	seq3.approach_area = seq3.get_path_to(trigger)
	var hero2 := _hero(Vector2(0, FLOOR_Y - 1.0))
	hero2.set_physics_process(false)
	await seconds(1.0)
	check_eq(seq3.get_child(0).state, HazardVent.State.IDLE, "the trigger area waits for the hero")
	hero2.global_position = Vector2(500.0, FLOOR_Y - 1.0)
	await seconds(0.4)
	check_eq(seq3.get_child(0).state, HazardVent.State.WARN, "the hero inside the trigger area starts the wave")
	await _clear()


# --- 5. the conveyor -------------------------------------------------------------------------

func _conveyor(speed: float = 120.0, dir: int = 1, at: Vector2 = Vector2(0, FLOOR_Y), size: Vector2 = Vector2(1200, 40)) -> StaticBody2D:
	var c: StaticBody2D = load(CONVEYOR_SCENE).instantiate()
	c.speed = speed
	c.direction = dir
	c.size = size
	c.position = at
	add_child(c)
	return c


func _test_conveyor_carry() -> void:
	var c := _conveyor(120.0, 1)
	var hero := _hero(Vector2(200.0, FLOOR_Y - 2.0))
	await seconds(0.4)
	check(hero.is_on_floor(), "the hero stands on the conveyor")
	check(absf(hero.global_position.y - FLOOR_Y) <= 1.0, "...with his feet on its top surface (the node's y)")
	var x0 := hero.global_position.x
	await seconds(2.0)
	var dx := hero.global_position.x - x0
	check(absf(dx - 240.0) <= 14.0, "carried about speed x time to the right (2 s at 120 px/s: %.1f px)" % dx)
	check(absf(hero.velocity.x) < 1.0, "his own velocity is unchanged by the carry (%.2f)" % hero.velocity.x)
	check(hero.is_on_floor(), "...and he stays on the floor")
	# reverse it: carried back
	c.set_direction(-1)
	x0 = hero.global_position.x
	await seconds(1.0)
	dx = hero.global_position.x - x0
	check(absf(dx + 120.0) <= 10.0, "reversed: carried left at the same speed (%.1f px)" % dx)
	# stop it: no drift
	c.set_running(false)
	await physics_frames(3)
	x0 = hero.global_position.x
	await seconds(1.0)
	check(absf(hero.global_position.x - x0) < 1.0, "a stopped belt carries nothing")
	check_eq(c.belt_velocity(), Vector2.ZERO, "...and reports no surface velocity")
	hero.queue_free()
	await _clear()


func _test_conveyor_leaving() -> void:
	# jumping off: straight up, straight down, no launch
	var c := _conveyor(180.0, 1)
	var hero := _hero(Vector2(300.0, FLOOR_Y - 2.0), true)
	var x_start := hero.global_position.x
	await seconds(0.5)
	var x_before := hero.global_position.x
	press(&"jump")
	await physics_frames(2)
	release(&"jump")
	var max_vx := 0.0
	var air_ticks := 0
	var x_takeoff := hero.global_position.x
	for i in 90:
		await physics_frames(1)
		if not hero.is_on_floor():
			air_ticks += 1
			max_vx = maxf(max_vx, absf(hero.velocity.x))
		if air_ticks > 5 and hero.is_on_floor():
			break
	var x_landed := hero.global_position.x
	check(air_ticks > 10, "setup: the hero left the belt in a jump (%d ticks)" % air_ticks)
	check(max_vx < 1.0, "jumping off a belt adds no horizontal launch: his velocity.x stays his own, 0 (%.2f)" % max_vx)
	check(absf(x_landed - x_takeoff) < 12.0, "...he lands where he left it, the belt's speed dropped in the air (%.1f px)" % (x_landed - x_takeoff))
	check(x_before - x_start > 60.0, "(he was carried before the jump: %.1f px)" % (x_before - x_start))
	hero.queue_free()
	await _clear()
	# walking (carried) off the end: drops straight down onto a lower floor, no launch
	var lower := _floor()
	var belt := _conveyor(180.0, 1, Vector2(0, FLOOR_Y - 120.0), Vector2(400, 40))
	var h2 := _hero(Vector2(300.0, FLOOR_Y - 122.0))
	await seconds(0.3)
	check(h2.is_on_floor(), "setup: standing near the belt's end")
	var vx_after := 0.0
	var left := false
	for i in 120:
		await physics_frames(1)
		if not h2.is_on_floor():
			left = true
			vx_after = maxf(vx_after, absf(h2.velocity.x))
	check(left, "he was carried off the belt's end")
	check(vx_after < 1.0, "...and falls with no horizontal launch (velocity.x %.2f)" % vx_after)
	var fell_x := h2.global_position.x
	check(fell_x > 400.0 and fell_x < 450.0, "...landing within a step of the end (x %.1f)" % fell_x)
	h2.queue_free()
	belt.queue_free()
	lower.queue_free()
	await _clear()


func _test_conveyor_against() -> void:
	var c := _conveyor(120.0, 1)
	var hero := _hero(Vector2(800.0, FLOOR_Y - 2.0), true)
	await seconds(0.4)
	var x0 := hero.global_position.x
	press(&"move_left")
	await seconds(1.0)
	release(&"move_left")
	var dx := hero.global_position.x - x0
	check(dx < -200.0, "walking against a 120 px/s belt still makes progress: about run speed - belt (%.1f px in 1 s)" % dx)
	check(absf(dx - (-(384.0 - 120.0))) <= 40.0, "...net speed run_speed - speed (%.1f)" % dx)
	await seconds(0.4)
	x0 = hero.global_position.x
	press(&"move_right")
	await seconds(1.0)
	release(&"move_right")
	dx = hero.global_position.x - x0
	check(absf(dx - (384.0 + 120.0)) <= 40.0, "with the belt: net speed run_speed + speed (%.1f px)" % dx)
	# the fastest belt the design allows (half a run) still lets him walk against it
	c.speed = 192.0
	await seconds(0.5)
	x0 = hero.global_position.x
	press(&"move_left")
	await seconds(1.0)
	release(&"move_left")
	check(hero.global_position.x - x0 < -150.0, "against a 192 px/s belt (the design's ceiling) he still gains ground")
	hero.queue_free()
	await _clear()


func _test_conveyor_rules() -> void:
	var c := _conveyor(120.0, 1, Vector2(100, FLOOR_Y), Vector2(500, 40))
	c.cargo = 3
	await physics_frames(2)
	var shapes := 0
	for n in c.find_children("*", "CollisionShape2D", true, false):
		shapes += 1
	check_eq(shapes, 1, "the cargo crates are drawn, not physical: one collision shape")
	check_eq(c.collision_layer, 1, "the conveyor is solid on the world layer")
	check_eq(c.get_rect_global(), Rect2(100, FLOOR_Y, 500, 40), "position is the top-left and size the extent, like a Block")
	check_eq(c.constant_linear_velocity, Vector2(120.0, 0.0), "the surface velocity is direction x speed")
	c.direction = -1
	check_eq(c.constant_linear_velocity, Vector2(-120.0, 0.0), "direction -1 reverses it")
	await _clear()
