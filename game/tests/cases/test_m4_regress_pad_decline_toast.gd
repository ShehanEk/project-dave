extends TestCase
## REGRESSION (ADV-04): declining the pad swap used to show the "Weapon
## swapped" toast anyway — SwapConfirm's `closed` signal carried no
## information about whether a swap happened, and WeaponPad always toasted
## on close. Fixed by having `closed(swapped: bool)` say so, and only
## toasting when `swapped` is true.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"


func run() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	# Level 1 has no swap pad since C51 (it returns in Level 2); the pad code is kept and
	# tested by placing one where it used to stand.
	var pad: WeaponPad = load("res://scenes/objects/weapon_pad.tscn").instantiate()
	pad.pad_id = "L01-A05-PAD01"
	pad.position = Vector2(1780, 0)
	level.areas[4].get_node("Entities").add_child(pad)
	await physics_frames(2)
	level.hero.global_position = pad.global_position
	await physics_frames(2)
	pad.interact(level.hero)
	await physics_frames(2)
	check(pad._dialog != null, "setup: swap dialog opened")
	pad._dialog._on_decline()
	await physics_frames(2)
	check_eq(Session.equipped_weapon(), "L01-W01-P01", "decline leaves P01 equipped")
	var toast: ToastLabel = pad.get_node_or_null("Toast")
	check(toast != null, "pad has a toast")
	if toast:
		check(not (toast.visible and toast.text == "Weapon swapped"),
				"decline must not show 'Weapon swapped' (visible=%s text=%s)" % [toast.visible, toast.text])
	level.queue_free()
	await physics_frames(2)
