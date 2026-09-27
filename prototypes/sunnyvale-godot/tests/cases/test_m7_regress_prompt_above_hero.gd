extends TestCase
## REGRESSION (AD-17 follow-up): Hero._update_interact_prompt() re-placed the
## PromptLabel 64 px above the highlighted interactable's origin every frame.
## For floor-level objects the hero stands beside (console, bench, pad) that
## is torso height, so the prompt drew over the hero. Fixed by leaving the
## label at its authored hero-relative offset (hero.tscn), and hiding it while
## the object's own Toast shows, since both share the band above the head.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const HERO_H := 96.0


func run() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	var hero: Hero = level.hero
	var pad: WeaponPad = level.areas[4].get_node("Entities/WeaponPad")
	hero.global_position = pad.global_position
	await physics_frames(4)

	var label := hero.prompt_label
	check(label.visible, "setup: prompt shows while standing on the pad")
	check_eq(label.text, "Swap", "prompt text comes from the pad")
	var head_top := hero.global_position.y - HERO_H
	var rect := label.get_global_rect()
	check(rect.end.y <= head_top,
			"prompt bottom %.1f clears hero head top %.1f" % [rect.end.y, head_top])
	check(absf(rect.get_center().x - hero.global_position.x) <= 1.0,
			"prompt centred on the hero (label cx=%.1f hero x=%.1f)" % [rect.get_center().x, hero.global_position.x])

	var toast: ToastLabel = pad.get_node_or_null("Toast")
	check(toast != null, "pad has a toast")
	if toast:
		toast.show_message("Weapon swapped")
		await physics_frames(2)
		check(not label.visible, "prompt hidden while the pad's toast is on screen")
		await seconds(ToastLabel.HOLD_TIME + ToastLabel.FADE_TIME + 0.2)
		check(not toast.visible, "setup: toast faded out")
		check(label.visible, "prompt returns once the toast is gone")
	level.queue_free()
	await physics_frames(2)
