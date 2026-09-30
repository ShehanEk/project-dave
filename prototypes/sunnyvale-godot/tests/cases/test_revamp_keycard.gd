extends TestCase
## Revamp (C24, level-design L01 / P19): the A04 clearance keycard and the
## A06 exit wicket's lock. The card is a contact pickup on the main route;
## the wicket refuses to end the level until it is held; the HUD shows a
## card icon while it is; the save accepts only whitelisted keycard ids; a
## rollback to a checkpoint from before the pickup puts the card back.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const PLAZA_INDEX := 3
const EXIT_INDEX := 5
const KEYCARD := "L01-KC01"


func run() -> void:
	await _test_wicket_locked_then_unlocked()
	await _test_save_whitelist()
	await _test_rollback_restores_card()


func _test_wicket_locked_then_unlocked() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	var card := level.areas[PLAZA_INDEX].get_node_or_null("Entities/Keycard_KC01")
	check(card != null, "the plaza (A04) has the clearance keycard")
	check(not Session.has_keycard(KEYCARD), "a fresh run starts without the keycard")
	var icon: Control = level.hud.get_node("TopBar/KeycardIcon")
	check(not icon.visible, "the HUD keycard icon is hidden before pickup")

	var wicket: ExitWicket = level.areas[EXIT_INDEX].get_node("Entities/ExitWicket")
	var denied := [false]
	wicket.wicket_denied.connect(func(): denied[0] = true)
	check(not wicket.is_unlocked(), "the wicket reader starts locked")
	level.hero.global_position = wicket.global_position
	await physics_frames(4)
	check(denied[0], "entering the wicket without the card is refused")
	check(not level.level_ended_flag, "the level does not end without the card")

	level.hero.global_position = card.global_position
	await physics_frames(4)
	check(Session.has_keycard(KEYCARD), "touching the card takes it")
	check(Session.is_collected("L01-KC01-P"), "the card's pickup entity is marked collected")
	check(icon.visible, "the HUD keycard icon shows once the card is held")
	check(wicket.is_unlocked(), "the wicket reader unlocks once the card is held")

	level.hero.global_position = wicket.global_position + Vector2(-400.0, 0.0)
	await physics_frames(3)
	level.hero.global_position = wicket.global_position
	await physics_frames(4)
	check(level.level_ended_flag, "with the card, the wicket ends the level")
	level.queue_free()
	await physics_frames(2)


func _test_save_whitelist() -> void:
	Session.new_run()
	var good: Dictionary = Session.state.duplicate(true)
	good["keycards"] = [KEYCARD]
	check(CheckpointService.validate_snapshot(good).ok, "a save holding L01-KC01 validates")
	var bad: Dictionary = Session.state.duplicate(true)
	bad["keycards"] = ["res://evil"]
	check(not CheckpointService.validate_snapshot(bad).ok, "a non-whitelisted keycard id is rejected")
	var missing: Dictionary = Session.state.duplicate(true)
	missing.erase("keycards")
	check(not CheckpointService.validate_snapshot(missing).ok, "a save with no keycards field is rejected")


func _test_rollback_restores_card() -> void:
	Session.new_run()
	Session.commit("CP00")
	Session.take_keycard(KEYCARD, "L01-KC01-P")
	check(Session.has_keycard(KEYCARD), "setup: card taken after CP00")
	Session.restore_committed()
	check(not Session.has_keycard(KEYCARD), "rolling back to CP00 drops the uncommitted card")
	var plaza: Node = load("res://scenes/levels/areas/a04_square.tscn").instantiate()
	add_child(plaza)
	await physics_frames(2)
	check(plaza.get_node_or_null("Entities/Keycard_KC01") != null, "the rebuilt plaza has the card again")
	plaza.queue_free()
	await physics_frames(2)
