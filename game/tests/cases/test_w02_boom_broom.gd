extends TestCase
## M3: W02 Boom Broom, Dave's pump shotgun (art-design/weapons/w02-boom-broom.md,
## scripts/weapons/boom_broom.gd, data/tuning/w02_boom_broom.tres).
## Contracts under test:
##   1. The held-weapon swap: a W02 in hand puts the Boom Broom on AimPivot (the
##      Scrapjack leaves), Dave's arm takes its grip, and swapping back restores the
##      Scrapjack, which still fires bolts as before.
##   2. Hold, grip and muzzle at every C50 aim step, facing right and left: the gun sits
##      at the step's hold, the fist is on its grip, the muzzle marker is the rig's muzzle
##      socket, ahead of the grip along the barrel.
##   3. Spread and pellet count: 6 pellets, evenly fanned across 22 degrees (jitter kept
##      inside the cone), centred on the exact shot direction.
##   4. Range falloff: full damage close, a pellet or two far away, nothing past max range.
##   5. Knockback: a hit body is pushed away from Dave; a Rover only staggers.
##   6. The pump: one blast per pump_time while fire is held, the pump slides back and
##      forward, one shell is thrown per blast, and the gun is not ready while pumping.
##   7. Shells: a blast spends one; an empty tube feeds one shell per shell_insert_time
##      from the reserve; firing stops a reload and keeps the shells already in; a short
##      tube tops up after reload_delay idle; empty with no reserve, it only clicks. The
##      count lives in Session per instance.
##   8. Upgrades by type: W02's own stage (Extended Tube 4 -> 6 without new shells,
##      Incendiary Shells burn, Twin Shell spends two), never the Scrapjack's; the
##      workbench offers the held type's upgrade; the HUD shows the Broom and its shells.
##   9. The reload key (R) feeds shells at once, queues behind a pump, does nothing on a full
##      tube or an empty reserve (a click) and is cut short by firing; the alternate fire
##      action (right mouse, Q) fires the Twin Shell at stage 3 and does nothing below it.
##  10. Dave's far hand holds the pump at every aim step (checked in 2) and follows its
##      stroke; with the Scrapjack his far arm is the clip's.

const HERO_SCENE := "res://scenes/actors/hero.tscn"
const NIGHT_GUARD_SCENE := "res://scenes/actors/night_guard.tscn"
const ROVER_SCENE := "res://scenes/actors/patrol_rover.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const WORKBENCH_PANEL := "res://scenes/ui/workbench_panel.tscn"
const PAD := "L02-A01-PAD01"
const BROOM := "L02-W02-P01"
const BlockScript := preload("res://scripts/world/block.gd")
const FLOOR_Y := 560.0
## The far hand stays within this of the pump's socket: the arm is straight at the hold's reach
## (about 5 px short at a level aim), the glove still on the pump.
const SUPPORT_REACH := 6.0

var tuning: ShotgunTuning


func run() -> void:
	tuning = load("res://data/tuning/w02_boom_broom.tres")
	check(tuning is ShotgunTuning, "the Boom Broom has its own tuning resource (ShotgunTuning)")
	check_eq(tuning.weapon_type, "W02", "...for type W02")
	check_eq(tuning.tube_capacity, 4, "the brief: four shells loaded")
	check_eq(tuning.reserve_capacity, 24, "S02: up to 24 in reserve")
	check(is_equal_approx(tuning.shell_insert_time, 0.7), "S02: about 0.7 s per shell")
	await _test_held_swap()
	await _test_hold_at_every_step()
	await _test_spread()
	await _test_falloff()
	await _test_knockback()
	await _test_pump()
	await _test_shells()
	await _test_upgrades()
	await _test_reload_key_and_alt_fire()
	await _test_support_hand_follows_pump()
	release_all()
	Session.new_run()


# --- helpers --------------------------------------------------------------------------------

func _floor() -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(-1500, FLOOR_Y)
	b.size = Vector2(4000, 200)
	add_child(b)
	return b


func _hero(pos: Vector2 = Vector2(0, FLOOR_Y - 1.0)) -> Hero:
	var hero: Hero = load(HERO_SCENE).instantiate()
	add_child(hero)
	hero.debug_invulnerable = true
	hero.global_position = pos
	hero.use_aim_override = true
	hero.ground_aim_limit_enabled = false   # these tests sweep every aim step on the floor
	hero.aim_override = pos + Vector2(400.0, -48.0)
	return hero


## A Level 2 run with the Boom Broom in hand (swapped off the A01 pad).
func _broom_run() -> void:
	Session.new_run("L02")
	var r := Session.swap_weapon(PAD)
	check(r.get("ok", false), "setup: the A01 pad swap gives Dave the Boom Broom")


## A plain body with a HitZone (a stand-in enemy with no AI): 40 x 96 on the floor at `x`.
func _dummy(x: float, record: Array) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	body.collision_layer = 4
	body.collision_mask = 1
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 96)
	cs.shape = rect
	cs.position = Vector2(0, -48)
	body.add_child(cs)
	var zone := HitZone.new()
	var zs := CollisionShape2D.new()
	zs.shape = rect
	zs.position = Vector2(0, -48)
	zone.add_child(zs)
	body.add_child(zone)
	zone.hit.connect(func(d: int, _p: Vector2, _dir: Vector2): record.append(d))
	add_child(body)
	body.global_position = Vector2(x, FLOOR_Y)
	return body


func _gun(hero: Hero) -> BoomBroom:
	return hero.held_weapon() as BoomBroom


## Aims level at shoulder height and fires one blast through the gun's own path.
func _blast_level(hero: Hero, gun: BoomBroom) -> void:
	hero.aim_override = hero.aim_pivot.global_position + Vector2(600.0 * hero.facing, 0.0)
	await physics_frames(3)
	gun.action = BoomBroom.Action.READY
	check(gun.try_blast(), "setup: the blast goes off")
	await physics_frames(1)


# --- 1. the held-weapon swap ------------------------------------------------------------------

func _test_held_swap() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	check(hero.held_weapon() is Scrapjack, "Level 2 starts with the Scrapjack on the pivot")
	check_eq(hero.held_weapon_type, "W01", "...held type W01")
	Session.swap_weapon(PAD)
	await physics_frames(3)
	var gun := hero.held_weapon()
	check(gun is BoomBroom, "a swap to the Boom Broom puts the Boom Broom on AimPivot")
	check_eq(String(gun.name) if gun else "", "BoomBroom", "...named BoomBroom")
	check(hero.get_node_or_null("AimPivot/Scrapjack") == null, "...and the Scrapjack is gone from the pivot (one carried weapon)")
	check_eq(hero.held_weapon_type, "W02", "...held type W02")
	var visual = hero.get_node("Visual")
	check(visual._gun == gun, "Dave's arm holds the new gun")
	check(visual.grip_error() < 3.0, "...by its grip (%.2f px off)" % visual.grip_error())
	var aim_pivot_children := hero.aim_pivot.get_children().filter(func(c): return c is BoomBroom or c is Scrapjack)
	check_eq(aim_pivot_children.size(), 1, "exactly one gun on the pivot")
	# Swap back: the Scrapjack returns and fires bolts as before.
	Session.swap_weapon(PAD)
	await physics_frames(3)
	var sj := hero.held_weapon()
	check(sj is Scrapjack and String(sj.name) == "Scrapjack", "swapping back puts the Scrapjack (AimPivot/Scrapjack) back")
	check(hero.get_node_or_null("AimPivot/BoomBroom") == null or hero.get_node("AimPivot/BoomBroom").is_queued_for_deletion(),
			"...and the Broom leaves the pivot")
	var fired := [0]
	(sj as Scrapjack).fired.connect(func(): fired[0] += 1)
	press(&"fire")
	await seconds(0.5)
	release(&"fire")
	check(fired[0] >= 1, "the Scrapjack still fires (%d shots)" % fired[0])
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 2. hold, grip and muzzle at every aim step -----------------------------------------------

func _test_hold_at_every_step() -> void:
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var gun := _gun(hero)
	var visual = hero.get_node("Visual")
	check(gun != null and gun.rig != null, "the Broom is a lit cutout prop rig (the placeholder parts)")
	if gun == null or gun.rig == null:
		hero.queue_free()
		floor_b.queue_free()
		return
	for part in ["body", "pump", "shell"]:
		check(gun.rig.joints.has(part), "the rig has its `%s` part" % part)
	for sock in ["grip", "muzzle", "eject"]:
		check(gun.rig.sockets.has(sock), "the rig has its `%s` socket" % sock)
	check(not (gun.rig.sprites["shell"] as Sprite2D).visible, "the loose shell part is hidden on the gun")
	var steps_seen := {}
	for facing in [1, -1]:
		for deg in [-90.0, -67.5, -45.0, -22.5, 0.0, 22.5, 45.0, 67.5, 89.0]:
			var a := deg_to_rad(deg)
			var dir := Vector2(cos(a) * facing, sin(a))
			if absf(dir.x) < 0.001:
				dir.x = 0.001 * facing
			hero.aim_override = hero.aim_pivot.global_position + Vector2(400.0 * facing, 0.0)
			await physics_frames(2)
			hero.aim_override = hero.aim_pivot.global_position + dir * 400.0
			await physics_frames(3)
			var tag := "facing %d, aim %.1f deg" % [facing, deg]
			var step: int = hero.aim_step
			steps_seen[step] = true
			check(gun.position.is_equal_approx(visual.gun_hold(step)), "%s: the Broom sits at step %d's hold" % [tag, step])
			check(visual.grip_error() < 3.0, "%s: the fist holds the Broom's grip (%.2f px off)" % [tag, visual.grip_error()])
			check(visual.support_error() < SUPPORT_REACH, "%s: the far hand holds the pump (%.2f px off)" % [tag, visual.support_error()])
			var grip: Vector2 = gun.rig.global_position
			var muzzle := gun.get_muzzle_global_position()
			var sock: Dictionary = gun.rig.sockets["muzzle"]
			check(muzzle.distance_to(gun.rig.joint_point(sock["joint"], sock["pos"])) < 0.5,
					"%s: the muzzle marker is the rig's muzzle socket" % tag)
			var along: float = (muzzle - grip).dot(gun.global_transform.x.normalized())
			check(along > 25.0 and along < 45.0, "%s: the muzzle is %.1f px ahead of the grip along the barrel" % [tag, along])
			var shot: Vector2 = hero.shot_direction()
			var barrel := gun.global_transform.x.normalized()
			check(absf(wrapf(shot.angle() - barrel.angle(), -PI, PI)) <= Hero.AIM_STEP * 0.5 + 0.02,
					"%s: the blast goes at most half a step off the barrel" % tag)
	check(steps_seen.has(-4) and steps_seen.has(0) and steps_seen.has(4), "straight up, level and straight down reached")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 3. spread and pellet count -----------------------------------------------------------------

func _test_spread() -> void:
	var angles := BoomBroom.pellet_angles(6, 22.0)
	check_eq(angles.size(), 6, "six pellet angles")
	check(is_equal_approx(angles[0], deg_to_rad(-11.0)) and is_equal_approx(angles[5], deg_to_rad(11.0)),
			"the fan runs edge to edge of the 22-degree cone")
	check(is_equal_approx(angles[1] - angles[0], angles[3] - angles[2]), "evenly spaced")
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var gun := _gun(hero)
	gun.rng.seed = 7
	await _blast_level(hero, gun)
	var dirs: Array = gun.last_blast.get("directions", [])
	check_eq(dirs.size(), tuning.pellet_count, "a blast throws pellet_count (6) pellets")
	check_eq((gun.last_blast.get("paths", []) as Array).size(), 6, "...each with its own path (ray)")
	var fwd: Vector2 = gun.last_blast.get("forward", Vector2.RIGHT)
	var lo := INF
	var hi := -INF
	for d in dirs:
		var off: float = wrapf((d as Vector2).angle() - fwd.angle(), -PI, PI)
		lo = minf(lo, off)
		hi = maxf(hi, off)
	check(lo >= deg_to_rad(-11.0) - 0.001 and hi <= deg_to_rad(11.0) + 0.001, "every pellet stays inside the cone")
	check(hi - lo >= deg_to_rad(18.0), "the pellets fill the cone (%.1f of 22 degrees)" % rad_to_deg(hi - lo))
	var exact: Vector2 = (hero.aim_override - hero.aim_pivot.global_position).normalized()
	check(absf(wrapf(fwd.angle() - exact.angle(), -PI, PI)) < 0.01, "the fan is centred on the exact aim")
	# Twin Shell's fan is wider and fuller (stage 3 data).
	check_eq(tuning.twin_pellet_count, 10, "Twin Shell throws 10 pellets")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 4. range falloff ---------------------------------------------------------------------------

func _test_falloff() -> void:
	check(is_equal_approx(tuning.falloff(10.0), 1.0) and is_equal_approx(tuning.falloff(tuning.falloff_start), 1.0),
			"full damage up to falloff_start")
	var mid := tuning.falloff((tuning.falloff_start + tuning.falloff_end) * 0.5)
	check(mid < 1.0 and mid > tuning.falloff_min, "less in between (%.2f)" % mid)
	check(is_equal_approx(tuning.falloff(tuning.falloff_end), tuning.falloff_min), "falloff_min at falloff_end")
	check_eq(tuning.falloff(tuning.max_range + 1.0), 0.0, "nothing past max range")
	check_eq(tuning.blast_damage(6.0 * tuning.pellet_damage), 5, "six close pellets: 4.5 -> 5 damage")
	check_eq(tuning.blast_damage(0.1), 1, "any pellet that connects does at least 1")
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var gun := _gun(hero)
	var results := {}
	for dist in [70.0, 330.0, 480.0]:
		var hits: Array = []
		var dummy := _dummy(hero.aim_pivot.global_position.x + 30.0 + dist, hits)
		await physics_frames(2)
		await _blast_level(hero, gun)
		var report: Dictionary = gun.last_blast.get("targets", {})
		var pellets := 0
		for zone in report:
			pellets += int(report[zone]["pellets"])
		results[dist] = [hits.duplicate(), pellets]
		dummy.queue_free()
		await physics_frames(2)
		gun._set_ammo(4, 24)
	var close: Array = results[70.0]
	var far: Array = results[330.0]
	var out_of_range: Array = results[480.0]
	check_eq(close[0].size(), 1, "a blast hits a target once (one take_hit per blast)")
	check_eq(close[1], 6, "point blank: all six pellets reach it")
	check(not close[0].is_empty() and int(close[0][0]) >= 4, "point blank: heavy damage (%s)" % str(close[0]))
	check(far[1] < 6 and far[1] >= 1, "far: only some pellets reach it (%d)" % far[1])
	check(not far[0].is_empty() and int(far[0][0]) < int(close[0][0]) and int(far[0][0]) >= 1,
			"far: much less damage (%s vs %s)" % [str(far[0]), str(close[0])])
	check(out_of_range[0].is_empty(), "past max range: no damage")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 5. knockback -------------------------------------------------------------------------------

func _test_knockback() -> void:
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var gun := _gun(hero)
	var hits: Array = []
	var dummy := _dummy(hero.global_position.x + 110.0, hits)
	await physics_frames(3)
	var x0 := dummy.global_position.x
	await _blast_level(hero, gun)
	check(dummy.get_node_or_null("BlastKnockback") != null, "the hit body gets a push")
	await seconds(0.6)
	var moved := dummy.global_position.x - x0
	check(moved > 35.0, "a point-blank blast throws it %.1f px away from Dave" % moved)
	check(dummy.get_node_or_null("BlastKnockback") == null, "...and the push has worn off")
	# Pushed the other way when Dave faces left.
	gun._set_ammo(4, 24)
	await seconds(tuning.pump_time)
	dummy.global_position = Vector2(hero.global_position.x - 110.0, FLOOR_Y)
	await physics_frames(2)
	hero.aim_override = hero.global_position + Vector2(-400.0, -48.0)
	await physics_frames(3)
	var x1 := dummy.global_position.x
	await _blast_level(hero, gun)
	await seconds(0.6)
	check(dummy.global_position.x < x1 - 35.0, "facing left it flies left (%.1f px)" % (x1 - dummy.global_position.x))
	dummy.queue_free()
	# A real enemy (a Night Guard made tough enough to survive the blast) is shoved too.
	var guard: Brawler = load(NIGHT_GUARD_SCENE).instantiate()
	add_child(guard)
	guard.global_position = Vector2(hero.global_position.x + 120.0, FLOOR_Y)
	await physics_frames(3)
	guard.health = 99
	hero.aim_override = hero.global_position + Vector2(400.0, -48.0)
	gun._set_ammo(4, 24)
	await seconds(tuning.pump_time)
	await _blast_level(hero, gun)
	var kb: Node = guard.get_node_or_null("BlastKnockback")
	check(kb != null, "a Night Guard hit by the blast gets the push")
	var pushed := 0.0
	for i in 40:
		if not is_instance_valid(kb):
			break
		pushed = kb.moved
		await physics_frames(1)
	check(pushed > 25.0, "...and is shoved %.1f px back" % pushed)
	# Heavy and light enemies.
	var rover: Node = load(ROVER_SCENE).instantiate()
	check(is_equal_approx(gun.knockback_scale_for(rover), tuning.heavy_knockback_scale) and tuning.heavy_knockback_scale < 0.5,
			"the Patrol Rover only staggers (x%.2f)" % gun.knockback_scale_for(rover))
	check(is_equal_approx(gun.knockback_scale_for(guard), 1.0), "a person takes the whole push")
	rover.free()
	guard.queue_free()
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 6. the pump --------------------------------------------------------------------------------

func _test_pump() -> void:
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var gun := _gun(hero)
	hero.aim_override = hero.aim_pivot.global_position + Vector2(600.0, 0.0)
	await physics_frames(3)
	var times: Array = []
	gun.fired.connect(func(_n): times.append(Time.get_ticks_msec()))
	var frames: Array = []
	var frame := [0]
	gun.fired.connect(func(_n): frames.append(frame[0]))
	var max_stroke := 0.0
	var ready_during_pump := false
	var pump_x0: float = gun.rig.joints["pump"].position.x
	var shells0 := gun.shells_ejected
	press(&"fire")
	for i in int(2.2 * Engine.physics_ticks_per_second):
		await physics_frames(1)
		frame[0] += 1
		max_stroke = maxf(max_stroke, gun.pump_stroke())
		if gun.is_pumping() and gun.is_ready():
			ready_during_pump = true
	release(&"fire")
	check_eq(frames.size(), 4, "fire held for 2.2 s: four blasts (one per pump, four shells)")
	if frames.size() >= 2:
		var gap: float = float(frames[1] - frames[0]) / float(Engine.physics_ticks_per_second)
		check(absf(gap - tuning.pump_time) <= 2.0 / float(Engine.physics_ticks_per_second),
				"blasts are one pump apart (%.3f s, pump %.2f s)" % [gap, tuning.pump_time])
	check(max_stroke > 0.95, "the pump slides all the way back (%.2f)" % max_stroke)
	check(not ready_during_pump, "the gun is never ready while it pumps")
	await seconds(tuning.pump_time)
	check(not gun.is_pumping() and gun.pump_stroke() == 0.0 and is_equal_approx(gun.rig.joints["pump"].position.x, pump_x0),
			"after the pump, the pump is forward again at rest (x %.2f, rest %.2f)" % [gun.rig.joints["pump"].position.x, pump_x0])
	check_eq(gun.shells_ejected - shells0, 4, "one spent shell thrown per blast")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 7. shells and the reload -------------------------------------------------------------------

func _test_shells() -> void:
	_broom_run()
	check_eq(Session.held_ammo(), {"loaded": 4, "reserve": 24}, "the A01 Broom starts with its authored 4 + 24")
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var gun := _gun(hero)
	await _blast_level(hero, gun)
	check_eq(gun.loaded(), 3, "a blast spends one shell")
	check_eq(Session.held_ammo()["loaded"], 3, "...counted in Session for the held instance")
	# Empty the tube: the reload starts by itself and feeds one shell every 0.7 s.
	gun._set_ammo(0, 24)
	gun.action = BoomBroom.Action.READY
	await physics_frames(2)
	check(gun.is_reloading(), "an empty tube starts feeding shells at once")
	await seconds(tuning.shell_insert_time + 0.05)
	check_eq(Session.held_ammo(), {"loaded": 1, "reserve": 23}, "one shell in after 0.7 s, taken from the reserve")
	# Firing stops the reload and keeps the shell already in.
	press(&"fire")
	await physics_frames(2)
	release(&"fire")
	check_eq(gun.loaded(), 0, "fire during the reload: the shell already in is fired")
	check_eq(gun.reserve(), 23, "...and the reserve keeps the rest")
	# Release and wait: it reloads to a full tube, one by one.
	await seconds(tuning.pump_time + 4.0 * tuning.shell_insert_time + 0.2)
	check_eq(Session.held_ammo(), {"loaded": 4, "reserve": 19}, "four shells fed one at a time (4 + 19)")
	check(not gun.is_reloading(), "...then it stops at a full tube")
	# A short tube tops up after reload_delay without firing.
	gun._set_ammo(3, 19)
	await seconds(tuning.reload_delay + tuning.shell_insert_time + 0.1)
	check_eq(gun.loaded(), 4, "a short tube tops up on its own after a pause")
	# Empty with no reserve: no blast, only the click.
	gun._set_ammo(0, 0)
	await physics_frames(2)
	var fired := [0]
	gun.fired.connect(func(_n): fired[0] += 1)
	press(&"fire")
	await seconds(0.3)
	release(&"fire")
	check_eq(fired[0], 0, "an empty Broom with no reserve does not fire")
	check(not gun.is_ready() and not gun.is_reloading(), "...and has nothing to feed")
	# The station refill (S02): the held Broom full again.
	check(Session.refill_held_weapon(), "a station refills the held Broom")
	check_eq(Session.held_ammo(), {"loaded": 4, "reserve": 24}, "...to 4 + 24")
	check(not Session.weapon_ammo("L02-W01-P01").size(), "the Scrapjack has no shell count at all")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 8. upgrades by type ------------------------------------------------------------------------

func _test_upgrades() -> void:
	_broom_run()
	Session.state["wallet"] = 40
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var gun := _gun(hero)
	check(not (gun.rig.sprites["ext_tube"] as Sprite2D).visible, "stage 0: no Extended Tube fitted")
	# The workbench offers the HELD type's stage 1: the Extended Tube.
	var panel: CanvasLayer = load(WORKBENCH_PANEL).instantiate()
	add_child(panel)
	await physics_frames(2)
	var vb := "Panel/VBox/"
	check_eq(panel.weapon_type, "W02", "the workbench reads the held type (W02)")
	check_eq(panel.get_node(vb + "QuickcycleCard/Info/NameRow/NameLabel").text, "Extended Tube", "...and offers the Extended Tube")
	check(panel.get_node(vb + "QuickcycleCard/Info/RateGrid/NowValue").text.begins_with("4 shells"), "now: 4 shells")
	check(panel.get_node(vb + "QuickcycleCard/Info/RateGrid/QuickValue").text.begins_with("6 shells"), "fitted: 6 shells")
	var buy: Button = panel.get_node(vb + "UpgradeRowButtons/ConfirmButton")
	check(buy.text.contains("Extended Tube") and buy.text.contains("40"), "Buy Extended Tube (40): %s" % buy.text)
	await _blast_level(hero, gun)   # 3 shells left
	await seconds(tuning.pump_time)
	Session.set_story("awakening_done", true)
	panel._on_confirm_pressed()
	await physics_frames(2)
	check_eq(Session.weapon_stage("W02"), 1, "bought: W02 stage 1")
	check_eq(Session.weapon_stage("W01"), 0, "...the Scrapjack's own stage is untouched (upgrades are by type)")
	check_eq(gun.capacity(), 6, "Extended Tube: the tube holds 6")
	check_eq(gun.loaded(), 3, "...but no shell is created (S04: capacity grows, rounds do not)")
	check((gun.rig.sprites["ext_tube"] as Sprite2D).visible, "the Extended Tube is fitted on the rig")
	check(not (gun.rig.sprites["heat_collar"] as Sprite2D).visible, "...not yet the heat collar")
	check(CheckpointService.load_latest().ok, "the purchase saved a valid Level 2 snapshot with W02 stage 1")
	panel.queue_free()
	await seconds(tuning.reload_delay + 3.0 * tuning.shell_insert_time + 0.2)
	check_eq(gun.loaded(), 6, "the reload now fills the longer tube (6)")

	# Stage 2: Incendiary Shells (live state; not purchasable before Level 3).
	Session.state["upgrades"]["W02"] = 2
	await physics_frames(2)
	check((gun.rig.sprites["heat_collar"] as Sprite2D).visible, "stage 2: the heat collar is fitted, the tube kept")
	var hits: Array = []
	var dummy := _dummy(hero.global_position.x + 200.0, hits)
	await physics_frames(2)
	await _blast_level(hero, gun)
	var burning: Node = null
	for c in dummy.get_children():
		if c is HitZone:
			burning = c.get_node_or_null("Burning")
	check(burning != null, "an Incendiary blast sets the target burning")
	var before := hits.size()
	await seconds(tuning.burn_interval * tuning.burn_ticks + 0.2)
	check_eq(hits.size() - before, tuning.burn_ticks, "it burns for %d ticks of damage after the blast" % tuning.burn_ticks)
	dummy.queue_free()

	# Stage 3: Twin Shell spends two shells, never with one; below stage 3 it does nothing.
	Session.state["upgrades"]["W02"] = 1
	await seconds(tuning.pump_time)
	gun._set_ammo(4, 10)
	check(not gun.try_twin_blast(), "no Twin Shell below stage 3")
	Session.state["upgrades"]["W02"] = 3
	await physics_frames(2)
	check((gun.rig.sprites["twin_pod"] as Sprite2D).visible, "stage 3: the twin pod is fitted")
	check(gun.try_twin_blast(), "Twin Shell at stage 3")
	check_eq(gun.loaded(), 2, "...spends exactly two shells")
	check_eq((gun.last_blast.get("directions", []) as Array).size(), tuning.twin_pellet_count, "...with more pellets")
	check(gun.is_pumping() and is_equal_approx(gun._action_len, tuning.twin_recovery_time), "...and a longer recovery")
	await seconds(tuning.twin_recovery_time + 0.05)
	gun._set_ammo(1, 0)
	check(not gun.try_twin_blast(), "never with only one shell (S02)")
	check(gun.try_blast(), "...a normal blast still works")

	# The HUD: the Broom's icon, its pip and its shells.
	Session.state["upgrades"]["W02"] = 1
	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	await physics_frames(2)
	hud.setup(hero)
	Session.set_weapon_ammo(BROOM, 5, 12)
	await physics_frames(2)
	var icon: Control = hud.get_node("TopBar/WeaponBox/WeaponIcon")
	check_eq(icon.weapon_type(), "W02", "the HUD slot shows the Boom Broom")
	check_eq(icon.gun_piece, "weapon_boom_broom", "...its icon piece")
	check(icon.has_art(), "...painted (the placeholder icon exists)")
	check_eq(hud.ammo_text(), "5/12", "the HUD shows the shells: tube / reserve")
	check(hud._weapon_pip.visible, "the pip lights for the Broom's stage 1")
	Session.swap_weapon(PAD)
	await physics_frames(3)
	check_eq(icon.weapon_type(), "W01", "swapped back: the Scrapjack's icon")
	check_eq(hud.ammo_text(), "", "...and no shell count for the Scrapjack")
	check(not hud._weapon_pip.visible, "...nor the Broom's pip (the Scrapjack has no Quickcycle)")
	hud.queue_free()
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
	CheckpointService.clear()


# --- 9. the reload key and the alternate fire ------------------------------------------------------

func _has_key(action: StringName, keycode: int) -> bool:
	for e in InputMap.action_get_events(action):
		if e is InputEventKey and (e as InputEventKey).physical_keycode == keycode:
			return true
	return false


func _has_mouse(action: StringName, button: int) -> bool:
	for e in InputMap.action_get_events(action):
		if e is InputEventMouseButton and (e as InputEventMouseButton).button_index == button:
			return true
	return false


func _test_reload_key_and_alt_fire() -> void:
	check(InputMap.has_action("reload") and _has_key(&"reload", KEY_R), "the project binds `reload` to R")
	check(InputMap.has_action("fire_alt") and _has_mouse(&"fire_alt", MOUSE_BUTTON_RIGHT) and _has_key(&"fire_alt", KEY_Q),
			"...and `fire_alt` to the right mouse button and Q")
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var gun := _gun(hero)
	release_all()

	# R feeds shells at once, long before the idle reload would start.
	gun._set_ammo(2, 10)
	await physics_frames(2)
	check(not gun.is_reloading(), "setup: a short tube waits out reload_delay on its own")
	press(&"reload")
	await physics_frames(2)
	release(&"reload")
	check(gun.is_reloading(), "R starts feeding shells at once")
	await seconds(2.0 * tuning.shell_insert_time + 0.1)
	check_eq(Session.held_ammo(), {"loaded": 4, "reserve": 8}, "...two shells fed, one at a time (4 + 8)")
	check(not gun.is_reloading(), "...and it stops at a full tube")

	# Nothing to do on a full tube; the empty click with no reserve.
	check(not gun.request_reload() and not gun.is_reloading(), "R on a full tube does nothing")
	gun._set_ammo(2, 0)
	check(not gun.request_reload() and not gun.is_reloading(), "R with an empty reserve starts nothing (it clicks)")

	# A pump in progress finishes first; the reload then starts by itself.
	gun._set_ammo(3, 10)
	gun.action = BoomBroom.Action.READY
	check(gun.try_blast(), "setup: a blast goes off")
	check(gun.request_reload() and gun.is_pumping() and not gun.is_reloading(), "R during the pump is queued")
	await seconds(tuning.pump_time + 0.05)
	check(gun.is_reloading(), "...and starts when the pump is done")
	await seconds(2.0 * tuning.shell_insert_time + 0.1)
	check_eq(gun.loaded(), 4, "...feeding the tube back to 4")

	# Firing with a shell in cuts a manual reload short and keeps what is in.
	gun._set_ammo(2, 10)
	await physics_frames(2)
	check(gun.request_reload(), "setup: R asks for a reload")
	await physics_frames(2)
	check(gun.is_reloading(), "setup: reloading")
	press(&"fire")
	await physics_frames(3)
	release(&"fire")
	check(not gun.is_reloading() and gun.loaded() == 1, "firing stops the reload and fires a shell (loaded %d)" % gun.loaded())
	await seconds(tuning.pump_time + 0.05)

	# Alternate fire: nothing below stage 3, the Twin Shell at stage 3.
	Session.state["upgrades"]["W02"] = 1
	gun._set_ammo(4, 10)
	gun.action = BoomBroom.Action.READY
	await physics_frames(2)
	press(&"fire_alt")
	await physics_frames(3)
	release(&"fire_alt")
	check_eq(gun.loaded(), 4, "alternate fire does nothing below stage 3")
	Session.state["upgrades"]["W02"] = 3
	gun._set_ammo(4, 10)
	gun.action = BoomBroom.Action.READY
	await physics_frames(2)
	press(&"fire_alt")
	await physics_frames(3)
	release(&"fire_alt")
	check(bool(gun.last_blast.get("twin", false)) and gun.loaded() == 2, "alternate fire at stage 3 is the Twin Shell (two shells spent)")
	await seconds(tuning.twin_recovery_time + 0.05)
	press(&"fire_alt")   # the same press held does not fire a second one
	await physics_frames(2)
	release(&"fire_alt")
	Session.state["upgrades"]["W02"] = 0
	release_all()
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 10. the far hand follows the pump -----------------------------------------------------------

func _test_support_hand_follows_pump() -> void:
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var gun := _gun(hero)
	var visual = hero.get_node("Visual")
	check(visual.two_handed(), "the Boom Broom is two-handed (its rig has a support socket)")
	check(visual.support_error() < SUPPORT_REACH, "the far hand holds the pump at rest (%.2f px off)" % visual.support_error())
	var seen_back := false
	gun.action = BoomBroom.Action.READY
	check(gun.try_blast(), "setup: a blast goes off")
	var worst := 0.0
	for i in int(ceil(tuning.pump_time * 60.0)):
		await physics_frames(1)
		worst = maxf(worst, visual.support_error())
		if gun.pump_stroke() > 0.5:
			seen_back = true
	check(seen_back, "the pump slides back during the blast")
	check(worst < SUPPORT_REACH, "the far hand stays on the pump through its stroke (worst %.2f px)" % worst)
	# The Scrapjack is one-handed: his far arm is the clip's again.
	Session.swap_weapon(PAD)
	await physics_frames(3)
	check(not visual.two_handed() and visual.support_error() == INF, "with the Scrapjack the far arm is free")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
