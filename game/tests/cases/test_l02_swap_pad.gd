extends TestCase
## M3: Level 2's real swap pad in A01's coolant plant (level-design/swap-pad-for-level-2.md,
## l02-alignment.md: the Boom Broom rests on L02-A01-PAD01 as L02-W02-P01; G03's safe
## trial). The intent of Level 1's run-time pad tests (test_m4_regress_pad_decline_toast,
## test_m7_regress_prompt_above_hero) on the placed pad, plus the cross-type swap.
## Contracts under test:
##   1. The pad is placed: A01's Entities/WeaponPad at x 1300, pad_id L02-A01-PAD01,
##      resting the Boom Broom (its own gun lies on it); the level has a swap pad, so the
##      HUD shows the held copy's tag; the prompt names the weapon on the pad.
##   2. The prompt sits above Dave's head and hides while the pad's toast shows.
##   3. Declining changes nothing and shows no "Weapon swapped" toast.
##   4. Confirming swaps across types: the Broom in hand and on the pivot, the Scrapjack
##      lying on the pad; swapping back and forth any number of times (the safe trial)
##      never refills or duplicates anything (the Broom keeps its spent shells).
##   5. The save whitelist accepts both states (and their commits load back), and still
##      refuses a duplicate, a third copy or a bad shell count.
##   6. A death after an uncommitted swap restores the committed weapon, the pad and the
##      Broom's shells, and the rebuilt level and the hero agree.
##   7. The M1 handover carries a held Broom into the next level (its type, stage and
##      shells) as that level's own hand copy, beside the pad's copy.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const PAD_ID := "L02-A01-PAD01"
const BROOM := "L02-W02-P01"
const JACK := "L02-W01-P01"
const HERO_H := 96.0


func run() -> void:
	await _test_pad_placed()
	await _test_prompt_above_hero()
	await _test_decline()
	await _test_swap_and_swap_back()
	_test_save_whitelist()
	await _test_restore_rolls_back()
	await _test_carry_into_next_level()
	release_all()
	CheckpointService.clear()
	Session.new_run()


func _build_level() -> LevelDirector:
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	await physics_frames(3)
	return lvl


func _pad(lvl: LevelDirector) -> WeaponPad:
	return lvl.areas[0].get_node_or_null("Entities/WeaponPad") as WeaponPad


func _free(node: Node) -> void:
	if is_instance_valid(node):
		node.queue_free()
	await physics_frames(2)


func _round_trip(state: Dictionary) -> Dictionary:
	return JSON.parse_string(JSON.stringify(state))


func _valid(state: Dictionary) -> Dictionary:
	return CheckpointService.validate_snapshot(_round_trip(state))


## Stands Dave on the pad and opens its dialog.
func _open_dialog(lvl: LevelDirector, pad: WeaponPad) -> void:
	lvl.hero.global_position = pad.global_position + Vector2(0, -1)
	await physics_frames(3)
	pad.interact(lvl.hero)
	await physics_frames(2)


# --- 1. the pad is placed -------------------------------------------------------------------------

func _test_pad_placed() -> void:
	Session.new_run("L02")
	var def := LevelDefs.get_def("L02")
	check_eq(def.world_weapons, {BROOM: PAD_ID}, "l02.tres rests the Boom Broom L02-W02-P01 on L02-A01-PAD01")
	check(LevelDefs.WEAPON_TYPES.has("W02"), "W02 is a weapon type Dave can carry")
	check_eq(Session.equipped_weapon(), JACK, "Level 2 starts with Dave's Scrapjack in hand")
	check_eq(Session.weapon_on_pad(PAD_ID), BROOM, "...and the Broom on the pad")
	var lvl := await _build_level()
	var pad := _pad(lvl)
	check(pad != null, "A01 has its WeaponPad (the M2 slot is now the real pad)")
	if pad == null:
		await _free(lvl)
		return
	check_eq(pad.pad_id, PAD_ID, "pad_id L02-A01-PAD01")
	check_eq(pad.position.x, 1300.0, "at x 1300 (the blueprint)")
	check(lvl.areas[0].get_node_or_null("Entities/Slot_SwapPad") == null, "the placeholder slot is gone")
	check(lvl.has_swap_pad(), "LevelDirector finds the level's swap pad")
	check(lvl.hud._weapon_tag_label.visible, "...so the HUD shows the held copy's workshop tag")
	check(pad.display_gun() is BoomBroom, "the Broom itself lies on the pad")
	check(not (pad.display_gun() as BoomBroom).held, "...as a resting gun, not a held one")
	check(lvl.hero.held_weapon() is Scrapjack, "Dave holds the Scrapjack")
	check_eq(pad.get_prompt(), "Swap: Boom Broom", "the prompt names the weapon on the pad")
	# At least 3 H from every other prompt in A01.
	for n in lvl.areas[0].get_node("Entities").get_children():
		if n is Interactable and n != pad:
			check(absf((n as Node2D).position.x - pad.position.x) >= 3.0 * HERO_H,
					"the pad is 3 H from %s" % n.name)
	await _free(lvl)


# --- 2. the prompt above Dave ---------------------------------------------------------------------

func _test_prompt_above_hero() -> void:
	Session.new_run("L02")
	var lvl := await _build_level()
	var pad := _pad(lvl)
	var hero: Hero = lvl.hero
	hero.global_position = pad.global_position + Vector2(0, -1)
	await physics_frames(4)
	var label := hero.prompt_label
	check(label.visible, "the prompt shows on the pad")
	check_eq(label.text, "Swap: Boom Broom", "...the pad's own prompt")
	var head_top := hero.global_position.y - HERO_H
	var rect := label.get_global_rect()
	check(rect.end.y <= head_top, "the prompt (bottom %.1f) clears Dave's head (top %.1f)" % [rect.end.y, head_top])
	check(absf(rect.get_center().x - hero.global_position.x) <= 1.0, "...centred on him")
	var toast: ToastLabel = pad.get_node_or_null("Toast")
	check(toast != null, "the pad has its toast")
	if toast:
		toast.show_message("Weapon swapped")
		await physics_frames(2)
		check(not label.visible, "the prompt hides while the toast shows")
		await seconds(ToastLabel.HOLD_TIME + ToastLabel.FADE_TIME + 0.2)
		check(label.visible, "...and comes back after it")
	await _free(lvl)


# --- 3. declining ---------------------------------------------------------------------------------

func _test_decline() -> void:
	Session.new_run("L02")
	var lvl := await _build_level()
	var pad := _pad(lvl)
	await _open_dialog(lvl, pad)
	check(pad._dialog != null, "interact opens the swap dialog")
	if pad._dialog == null:
		await _free(lvl)
		return
	var title: Label = pad._dialog.get_node("Panel/VBox/TitleRow/TitleLabel")
	check(title.text.contains("Boom Broom") and title.text.contains("Scrapjack"), "the dialog names both weapons: %s" % title.text)
	check(title.text.contains("stays on the pad"), "...and says the old one stays on the pad")
	check(not lvl.hero.input_enabled, "Dave waits while the dialog is open")
	pad._dialog._on_decline()
	await physics_frames(2)
	check_eq(Session.equipped_weapon(), JACK, "decline: the Scrapjack stays in hand")
	check_eq(Session.weapon_on_pad(PAD_ID), BROOM, "decline: the Broom stays on the pad")
	check(lvl.hero.held_weapon() is Scrapjack, "decline: the pivot still holds the Scrapjack")
	check(lvl.hero.input_enabled, "decline: Dave moves again")
	var toast: ToastLabel = pad.get_node_or_null("Toast")
	check(toast != null and not (toast.visible and toast.text == "Weapon swapped"), "decline shows no 'Weapon swapped' toast")
	await _free(lvl)


# --- 4. swap, swap back -----------------------------------------------------------------------------

func _test_swap_and_swap_back() -> void:
	Session.new_run("L02")
	var lvl := await _build_level()
	var pad := _pad(lvl)
	var hero: Hero = lvl.hero
	await _open_dialog(lvl, pad)
	pad._dialog._on_confirm()
	await physics_frames(3)
	check_eq(Session.equipped_weapon(), BROOM, "confirm: the Boom Broom is held")
	check_eq(Session.weapon_on_pad(PAD_ID), JACK, "confirm: Dave's Scrapjack rests on the pad")
	check(hero.held_weapon() is BoomBroom, "...the Broom is on Dave's aim pivot")
	check(pad.display_gun() is Scrapjack, "...and the Scrapjack lies on the pad")
	var toast: ToastLabel = pad.get_node_or_null("Toast")
	check(toast != null and toast.visible and toast.text == "Weapon swapped", "confirm shows 'Weapon swapped'")
	check_eq(pad.get_prompt(), "Swap: Scrapjack", "the prompt now offers the Scrapjack back")
	check_eq(lvl.hud.ammo_text(), "4/24", "the HUD shows the Broom's shells")
	# Spend a shell, then swap back and forth: nothing is refilled or duplicated.
	var gun := hero.held_weapon() as BoomBroom
	hero.aim_override = hero.aim_pivot.global_position + Vector2(600, 0)
	hero.use_aim_override = true
	await physics_frames(2)
	check(gun.try_blast(), "setup: one blast")
	await physics_frames(2)
	check_eq(Session.weapon_ammo(BROOM), {"loaded": 3, "reserve": 24}, "setup: 3 + 24 left")
	for i in 3:
		check(Session.swap_weapon(PAD_ID).ok, "swap %d goes through" % (i + 1))
		await physics_frames(2)
	check_eq(Session.equipped_weapon(), JACK, "after an odd number more, the Scrapjack is back in hand")
	check(hero.held_weapon() is Scrapjack, "...and on the pivot")
	check(pad.display_gun() is BoomBroom, "...and the Broom back on the pad")
	check_eq(Session.weapon_ammo(BROOM), {"loaded": 3, "reserve": 24}, "the Broom on the pad kept its 3 + 24: a swap refills nothing")
	var instances: Array = [Session.equipped_weapon()]
	instances.append_array(Session.state["world_weapons"].keys())
	instances.sort()
	check_eq(instances, [JACK, BROOM], "still exactly the two copies, one held, one on the pad")
	check_eq(lvl.hud.ammo_text(), "", "the HUD drops the shell count with the Scrapjack in hand")
	await _free(lvl)


# --- 5. the save whitelist ---------------------------------------------------------------------------

func _test_save_whitelist() -> void:
	Session.new_run("L02")
	var jack_state := Session.state.duplicate(true)
	check(_valid(jack_state).ok, "a save with the Scrapjack held and the Broom on the pad validates")
	Session.swap_weapon(PAD_ID)
	Session.set_weapon_ammo(BROOM, 2, 17)
	var broom_state := Session.state.duplicate(true)
	check(_valid(broom_state).ok, "a save with the Broom held (2 + 17) and the Scrapjack on the pad validates (%s)" % _valid(broom_state).get("error", ""))
	CheckpointService.clear()
	check(Session.commit("CP00"), "the swapped state commits")
	var loaded := CheckpointService.load_latest()
	check(loaded.ok, "...and loads back")
	if loaded.ok:
		Session.load_from_snapshot(loaded.snapshot)
		check_eq(Session.equipped_weapon(), BROOM, "loaded: the Broom held")
		check_eq(Session.held_ammo(), {"loaded": 2, "reserve": 17}, "loaded: its shells are ints again (2 + 17)")
	# A save from before M3 (no shell counts) still loads: the Broom starts full.
	var old := _round_trip(jack_state)
	old.erase("weapon_ammo")
	check(CheckpointService.validate_snapshot(old).ok, "a save without weapon_ammo (before M3) still validates")
	Session.load_from_snapshot(old)
	check_eq(Session.weapon_ammo(BROOM), {"loaded": 4, "reserve": 24}, "...and its Broom loads full")
	# Tampering is still refused.
	var dup := broom_state.duplicate(true)
	dup["world_weapons"] = {BROOM: PAD_ID}
	check(not _valid(dup).ok, "refused: the Broom both held and on the pad")
	var third := broom_state.duplicate(true)
	third["world_weapons"] = {JACK: PAD_ID, "L02-W02-P03": PAD_ID}
	check(not _valid(third).ok, "refused: a third copy smuggled onto the pad")
	var other_pad := broom_state.duplicate(true)
	other_pad["world_weapons"] = {JACK: "L02-A02-PAD01"}
	check(not _valid(other_pad).ok, "refused: a pad the level does not have")
	var jack_ammo := broom_state.duplicate(true)
	jack_ammo["weapon_ammo"][JACK] = {"loaded": 4, "reserve": 4}
	check(not _valid(jack_ammo).ok, "refused: a shell count on the Scrapjack")
	var too_many := broom_state.duplicate(true)
	too_many["weapon_ammo"][BROOM] = {"loaded": 9, "reserve": 4}
	check(not _valid(too_many).ok, "refused: more shells than any tube holds")
	var big_reserve := broom_state.duplicate(true)
	big_reserve["weapon_ammo"][BROOM] = {"loaded": 2, "reserve": 99}
	check(not _valid(big_reserve).ok, "refused: a reserve over 24")
	var bad_key := broom_state.duplicate(true)
	bad_key["weapon_ammo"]["res://x.tscn"] = {"loaded": 1, "reserve": 1}
	check(not _valid(bad_key).ok, "refused: a stray key in weapon_ammo")
	var frac := broom_state.duplicate(true)
	frac["weapon_ammo"][BROOM] = {"loaded": 2.5, "reserve": 4}
	check(not _valid(frac).ok, "refused: half a shell")
	var stage2 := broom_state.duplicate(true)
	stage2["upgrades"]["W02"] = 2
	check(not _valid(stage2).ok, "refused: a W02 stage past what can be bought yet")
	stage2["upgrades"]["W02"] = 1
	check(_valid(stage2).ok, "W02 stage 1 (the Extended Tube) is fine")
	CheckpointService.clear()


# --- 6. a death after an uncommitted swap -------------------------------------------------------------

func _test_restore_rolls_back() -> void:
	Session.new_run("L02")
	CheckpointService.clear()
	var lvl := await _build_level()
	var hero: Hero = lvl.hero
	check(Session.commit("CP00"), "setup: CP00 committed with the Scrapjack held")
	Session.swap_weapon(PAD_ID)
	await physics_frames(3)
	var gun := hero.held_weapon() as BoomBroom
	check(gun != null, "setup: the Broom is in hand (uncommitted)")
	hero.use_aim_override = true
	hero.aim_override = hero.aim_pivot.global_position + Vector2(600, 0)
	await physics_frames(2)
	if gun:
		gun.try_blast()
	await physics_frames(2)
	check_eq(Session.weapon_ammo(BROOM)["loaded"], 3, "setup: a shell spent")
	# Die: LevelDirector restores the committed snapshot and rebuilds the areas.
	hero.debug_invulnerable = false
	Session.state["health"] = 1
	hero._immune_timer = 0.0
	hero.take_damage(1, hero.global_position + Vector2(20, 0))
	await physics_frames(8)
	check_eq(Session.equipped_weapon(), JACK, "the death rolled the swap back: the Scrapjack in hand")
	check_eq(Session.weapon_on_pad(PAD_ID), BROOM, "...the Broom back on the pad")
	check_eq(Session.weapon_ammo(BROOM), {"loaded": 4, "reserve": 24}, "...with the shells it had at CP00")
	check(hero.held_weapon() is Scrapjack, "the hero's pivot holds the Scrapjack again")
	check(hero.get_node_or_null("AimPivot/BoomBroom") == null or hero.get_node("AimPivot/BoomBroom").is_queued_for_deletion(),
			"...and no Broom")
	var pad := _pad(lvl)
	check(pad != null and pad.display_gun() is BoomBroom, "the rebuilt pad shows the Broom resting")
	check_eq(lvl.hud.ammo_text(), "", "the HUD shows no shells (the Scrapjack is unlimited)")
	await _free(lvl)
	CheckpointService.clear()


# --- 7. carrying the Broom into the next level (M1's carried-weapon-type rule) ----------------------

func _test_carry_into_next_level() -> void:
	# Level 3 is not built yet, so a finished Level 1 holding a Boom Broom stands in for "a
	# level finished with the Broom in hand" (Level 1 accepts it now that W02 is a carried
	# type: its hand copy L01-W02-P01 with the second Scrapjack still on its pad);
	# Session.next_level_state() is the same handover for any pair of levels.
	var from := Session.default_state()
	from["checkpoint_id"] = "CP05"
	from["upgrades"] = {"W01": 0, "A01": 0, "W02": 1}
	from["equipped_weapon"] = "L01-W02-P01"
	from["world_weapons"] = {"L01-W01-P02": "L01-A05-PAD01"}
	from["weapon_ammo"] = {"L01-W02-P01": {"loaded": 2, "reserve": 10}}
	from["story"]["awakening_done"] = true
	from["story"]["level_complete"] = true
	check(_valid(from).ok, "setup: a finished level holding the Broom validates (%s)" % _valid(from).get("error", ""))
	var next := Session.next_level_state(from, "L02")
	check_eq(next["level"], "L02", "handover: into Level 2")
	check_eq(next["equipped_weapon"], "L02-W02-P02", "the held TYPE carries over as the level's own hand copy (P02: P01 is the pad's)")
	check_eq(next["weapon_ammo"].get("L02-W02-P02", {}), {"loaded": 2, "reserve": 10}, "...with the shells it had")
	check_eq(next["world_weapons"], {BROOM: PAD_ID}, "the level's own Broom still rests on its pad")
	check_eq(next["weapon_ammo"].get(BROOM, {}), {"loaded": 4, "reserve": 24}, "...with its authored shells")
	check_eq(int(next["upgrades"].get("W02", 0)), 1, "the Broom's stage carries over (Extended Tube)")
	check(_valid(next).ok, "the handover state validates (%s)" % _valid(next).get("error", ""))
	# Live, through Session.advance_to_level(): the next level starts with the Broom in hand.
	CheckpointService.clear()
	Session.load_from_snapshot(_round_trip(from))
	check(Session.advance_to_level("L02"), "advance_to_level saves the next level's start")
	var lvl := await _build_level()
	var hero: Hero = lvl.hero
	check(hero.held_weapon() is BoomBroom, "the new level's hero holds the Boom Broom")
	check_eq((hero.held_weapon() as BoomBroom).capacity(), 6, "...fitted with the earned Extended Tube")
	check_eq(lvl.hud.ammo_text(), "2/10", "...and the HUD shows its carried shells")
	check(_pad(lvl).display_gun() is BoomBroom, "the pad's own Broom lies there too")
	# A swap there trades one Broom copy for the other: same type, the pivot keeps its gun.
	var before := hero.held_weapon()
	check(Session.swap_weapon(PAD_ID).ok, "the pad trades Broom for Broom")
	await physics_frames(2)
	check(hero.held_weapon() == before, "...the same gun node stays on the pivot")
	check_eq(Session.held_ammo(), {"loaded": 4, "reserve": 24}, "...now reading the pad copy's shells")
	check_eq(lvl.hud.ammo_text(), "4/24", "...shown on the HUD")
	await _free(lvl)
	CheckpointService.clear()
