extends TestCase
## N05 (ElevenLabs audio pass) — the three interface and weapon ticks that only
## exist as ElevenLabs sounds and are wired to one moment each:
##   `ui_pause`    the pause menu opening (Pause, Tab's Journal, F1's Controls).
##                 Closing keeps its `ui_back`, and the old `ui_move` rollover no
##                 longer doubles the opening.
##   `toast_save`  the HUD's "Progress saved" toast appearing, once per toast: not
##                 on CP04 (the lockdown stinger's moment, whose HUD toast is
##                 skipped), not on a failed save or an evidence file (their own
##                 cues), and once, not twice, when a recovery station shows its
##                 own local toast too.
##   `ready_click` the held Scrapjack after a pad swap (Session.weapon_swapped), a
##                 beat after the `swap` clunk: positional at the gun, once, never
##                 on a shot and never from a resting gun.
##
## How a play is observed: Audio hands each one-shot to a pooled
## AudioStreamPlayer[2D] and sets its `stream`, so the test empties the pools,
## triggers the moment, and counts the pool players holding a stream of that cue.
## (Two plays inside one frame land on two players, so a double play shows as 2.)
## Saves and the playtest log go to a throwaway dir, never the real ones.

const HUD_SCENE := "res://scenes/ui/hud.tscn"
const PAUSE_SCENE := "res://scenes/ui/pause.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const GUN_SCENE := "res://scenes/weapons/scrapjack.tscn"
const STATION_SCENE := "res://scenes/objects/recovery_station.tscn"
const BlockScript := preload("res://scripts/world/block.gd")
const PAD_ID := "L01-A05-PAD01"


func run() -> void:
	var base_dir: String = CheckpointService.get_save_dir()
	var base_playtest: String = Telemetry.get_playtest_dir()
	var test_dir := "user://test_runs/n05_ui_ticks_%d" % Time.get_ticks_usec()
	CheckpointService.set_save_dir(test_dir)
	Telemetry.set_playtest_dir(test_dir)

	_test_cues_are_the_eleven_takes()
	await _test_pause_menu_open_plays_ui_pause()
	await _test_saved_toast_plays_toast_save_once()
	await _test_swap_plays_ready_click_once()

	Session.new_run()
	CheckpointService.debug_force_write_failure(false)
	CheckpointService.clear()
	CheckpointService.remove_dir_recursive(test_dir)
	# The runner's own throwaway dir (AUD-01), never DEFAULT_SAVE_DIR.
	CheckpointService.set_save_dir(base_dir)
	Telemetry.set_playtest_dir(base_playtest)


# --- the probe ------------------------------------------------------------------

## Stops and empties every pooled one-shot player, so what holds a stream after
## this was played since.
func _reset_pools() -> void:
	for p in Audio._sfx_pool:
		p.stop()
		p.stream = null
	for p in Audio._sfx2d_pool:
		p.stop()
		p.stream = null


## How many pooled players (flat and positional) hold one of `cue`'s streams.
func _plays(cue: StringName) -> int:
	var streams: Array = Audio._sfx_pools.get(cue, {}).get("streams", [])
	var n := 0
	for p in Audio._sfx_pool:
		if p.stream != null and streams.has(p.stream):
			n += 1
	for p in Audio._sfx2d_pool:
		if p.stream != null and streams.has(p.stream):
			n += 1
	return n


## The positional players currently holding one of `cue`'s streams.
func _positional_players(cue: StringName) -> Array:
	var streams: Array = Audio._sfx_pools.get(cue, {}).get("streams", [])
	var out := []
	for p in Audio._sfx2d_pool:
		if p.stream != null and streams.has(p.stream):
			out.append(p)
	return out


func _tap(action: StringName) -> void:
	press(action)
	await physics_frames(1)
	release(action)
	await physics_frames(1)


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load(HERO_SCENE).instantiate()
	add_child(hero)
	hero.debug_invulnerable = true
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.use_aim_override = true
	hero.aim_override = pos + Vector2(300.0, 0.0)
	return hero


func _make_floor() -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(-1000, 560)
	b.size = Vector2(2000, 200)
	add_child(b)
	return b


# --- 0. the three cues are the ElevenLabs takes ----------------------------------

func _test_cues_are_the_eleven_takes() -> void:
	for cue in [&"ui_pause", &"toast_save", &"ready_click"]:
		check(Audio.has_cue(cue) and Audio.cue_source(cue) == &"eleven",
				"setup: %s plays its ElevenLabs take(s)" % String(cue))
	# The probe tells the cues apart by stream, so no two may share one.
	for a in [&"ui_pause", &"toast_save", &"ready_click", &"ui_move", &"ui_back", &"checkpoint", &"swap"]:
		for b in [&"ui_pause", &"toast_save", &"ready_click", &"ui_move", &"ui_back", &"checkpoint", &"swap"]:
			if a == b:
				continue
			var shared := false
			for s in Audio._sfx_pools.get(a, {}).get("streams", []):
				if (Audio._sfx_pools.get(b, {}).get("streams", []) as Array).has(s):
					shared = true
			check(not shared, "setup: %s and %s share no stream, so the probe can tell them apart" % [String(a), String(b)])


# --- 1. the pause menu opening ----------------------------------------------------

func _test_pause_menu_open_plays_ui_pause() -> void:
	Session.new_run()
	var floor_b := _make_floor()
	var hero := _make_hero(Vector2(100, 560))
	var menu: PauseMenu = load(PAUSE_SCENE).instantiate()
	add_child(menu)
	menu.setup(hero)
	# PauseMenu opens only after hero.input_enabled has held for 2 physics frames.
	await physics_frames(4)
	check(not get_tree().paused, "setup: the tree starts unpaused")

	_reset_pools()
	await _tap(&"pause")
	check_eq(menu._view, PauseMenu.View.MAIN, "pause opens the menu's main view")
	check(get_tree().paused, "...and pauses the tree")
	check_eq(_plays(&"ui_pause"), 1, "opening the pause menu plays ui_pause once")
	check_eq(_plays(&"ui_move"), 0, "...and not the old ui_move tick on top of it")

	_reset_pools()
	await _tap(&"pause")
	check_eq(menu._view, PauseMenu.View.CLOSED, "pause again resumes")
	check(not get_tree().paused, "...and unpauses the tree")
	check_eq(_plays(&"ui_pause"), 0, "closing the pause menu does not play ui_pause")
	check(_plays(&"ui_back") >= 1, "...it keeps ui_back")

	# Tab opens the Journal through the same _open(), with the same whoosh.
	await physics_frames(3)
	_reset_pools()
	await _tap(&"journal")
	check_eq(menu._view, PauseMenu.View.JOURNAL, "journal opens the menu on the Journal view")
	check_eq(_plays(&"ui_pause"), 1, "opening the Journal from gameplay plays ui_pause once")

	# Backing out of a sub-view and resuming play no ui_pause.
	_reset_pools()
	await _tap(&"pause")
	check_eq(menu._view, PauseMenu.View.MAIN, "pause from the Journal returns to the main view")
	check_eq(_plays(&"ui_pause"), 0, "going back to the main view does not play ui_pause")
	check(_plays(&"ui_back") >= 1, "...it plays ui_back")
	await _tap(&"pause")
	check(not get_tree().paused, "cleanup: resumed")

	menu.queue_free()
	hero.queue_free()
	floor_b.queue_free()
	get_tree().paused = false
	await physics_frames(2)


# --- 2. the "Progress saved" toast ------------------------------------------------

func _test_saved_toast_plays_toast_save_once() -> void:
	Session.new_run()
	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	await physics_frames(2)
	var toast: ToastLabel = hud._toast

	# A checkpoint commit: the HUD shows "Progress saved" and the cue plays with it,
	# next to Audio's own checkpoint bong (a different cue on the same signal).
	_reset_pools()
	check(Session.commit("CP02"), "setup: the throwaway save dir takes a commit")
	check(toast.visible and toast.text == "Progress saved", "a checkpoint commit shows the HUD's Progress saved toast")
	check_eq(_plays(&"toast_save"), 1, "the Progress saved toast plays toast_save exactly once")
	check_eq(_plays(&"checkpoint"), 1, "...next to the checkpoint bong, which Audio plays itself")

	_reset_pools()
	check(Session.commit("CP03"), "setup: a second commit")
	check_eq(_plays(&"toast_save"), 1, "the next Progress saved toast plays it again, once")

	# CP04 is CoreNode's own moment (its toast and the lockdown stinger): the HUD
	# shows no toast, so no toast tick.
	toast.visible = false
	_reset_pools()
	check(Session.commit("CP04"), "setup: CP04 commits")
	check(not toast.visible, "CP04 shows no HUD toast")
	check_eq(_plays(&"toast_save"), 0, "...and plays no toast_save")

	# A failed save shows its warning toast under its own cue.
	_reset_pools()
	CheckpointService.debug_force_write_failure(true)
	check(not Session.commit("CP05"), "setup: a forced write failure fails the commit")
	CheckpointService.debug_force_write_failure(false)
	check(toast.visible and toast.text.begins_with("Save failed"), "a failed save shows the HUD's warning toast")
	check_eq(_plays(&"save_failed"), 1, "...with the save_failed cue")
	check_eq(_plays(&"toast_save"), 0, "...and never toast_save")

	# An evidence file's toast has the evidence cue.
	_reset_pools()
	check(Session.record_evidence("EF01", "L01-OPT01-A01"), "setup: evidence EF01 is recorded")
	check(toast.visible and toast.text == "Evidence file saved", "an evidence file shows the HUD's Evidence file saved toast")
	check_eq(_plays(&"evidence"), 1, "...with the evidence cue")
	check_eq(_plays(&"toast_save"), 0, "...and not toast_save")

	# A recovery station shows its own local "Progress saved" toast on the same
	# commit. It is the same event and the same words, so still one tick, not two.
	var station: RecoveryStation = load(STATION_SCENE).instantiate()
	add_child(station)
	await physics_frames(2)
	toast.visible = false
	_reset_pools()
	station.interact(null)
	await physics_frames(1)
	check(station._toast.visible and station._toast.text == "Progress saved", "the station shows its own local toast too")
	check(toast.visible and toast.text == "Progress saved", "...and so does the HUD")
	check_eq(_plays(&"toast_save"), 1, "a station save plays toast_save once, not once per toast")

	station.queue_free()
	hud.queue_free()
	Session.new_run()
	CheckpointService.clear()
	await physics_frames(2)


# --- 3. the new gun clicks home after a pad swap ------------------------------------

func _test_swap_plays_ready_click_once() -> void:
	Session.new_run()
	var floor_b := _make_floor()
	var hero := _make_hero(Vector2(100, 560))
	var resting: Scrapjack = load(GUN_SCENE).instantiate()
	resting.held = false  # a gun lying on a pad, not the one in Dave's hand
	add_child(resting)
	await physics_frames(3)
	var gun: Scrapjack = hero.get_node("AimPivot/Scrapjack")
	check(gun.held, "setup: the hero's gun is the held one")

	# Shooting, even a burst, never clicks.
	_reset_pools()
	press(&"fire")
	await seconds(0.8)
	release(&"fire")
	check(_plays(&"pistol_fire") >= 1, "setup: the burst played pistol_fire (the probe sees the gun's cues)")
	check_eq(_plays(&"ready_click"), 0, "firing never plays ready_click")

	# The swap itself is the swap cue; the click comes a beat later, once.
	await seconds(0.3)
	_reset_pools()
	var result: Dictionary = Session.swap_weapon(PAD_ID)
	check(result.get("ok", false), "setup: the pad swap succeeds")
	check_eq(_plays(&"swap"), 1, "the swap itself plays swap, which Audio owns")
	check_eq(_plays(&"ready_click"), 0, "ready_click is not at the instant of the swap")
	await seconds(Scrapjack.READY_CLICK_DELAY + 0.2)
	check_eq(_plays(&"ready_click"), 1, "a beat after the swap the held gun plays ready_click, once (a resting gun does not)")
	var players := _positional_players(&"ready_click")
	check_eq(players.size(), 1, "...positionally")
	if players.size() == 1:
		check(players[0].global_position.distance_to(gun.global_position) < 40.0,
				"...at the gun in the hero's hand (%.1f px away)" % players[0].global_position.distance_to(gun.global_position))

	# A gun freed before the beat is up plays nothing and raises nothing.
	_reset_pools()
	Session.swap_weapon(PAD_ID)
	hero.queue_free()
	await seconds(Scrapjack.READY_CLICK_DELAY + 0.2)
	check_eq(_plays(&"ready_click"), 0, "a gun that left the tree before the beat plays no ready_click")

	resting.queue_free()
	floor_b.queue_free()
	Session.new_run()
	await physics_frames(2)
