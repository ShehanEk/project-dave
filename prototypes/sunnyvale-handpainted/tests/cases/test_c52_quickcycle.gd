extends TestCase
## C52: the Quickcycle must be felt, and the workbench must be readable. Playtest 2026-10-08: "no
## difference after upgrade" (0.32 s to 0.24 s was too small to notice and nothing else changed).
## Contracts under test:
##   1. The Quickcycle fires at least 1.7 times as fast as the base gun (0.32 s to 0.18 s).
##   2. Its shot sounds higher than the base shot (pitch), and with it fitted a shot flares a
##      brighter, teal-white muzzle light and the flywheel spins up and glows teal.
##   3. The workbench panel names its two jobs, shows both fire rates, the price and what is
##      left, disables Buy without enough chips and says how many are missing, and after a buy
##      shows INSTALLED with no Buy button.
##   4. The HUD announces "Quickcycle online" instead of "Progress saved" after a purchase.

const BlockScript := preload("res://scripts/world/block.gd")
const PANEL := "res://scenes/ui/workbench_panel.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const TUNING := "res://data/tuning/w01_scrapjack.tres"


func run() -> void:
	_tuning()
	_sound()
	await _gun_feedback()
	await _panel()
	await _hud_toast()


func _tuning() -> void:
	var t: WeaponTuning = load(TUNING)
	check_eq(t.base_interval, 0.32, "the base Scrapjack keeps its 0.32 s interval")
	check_eq(t.quickcycle_interval, 0.18, "the Quickcycle fires every 0.18 s")
	check(t.shots_per_second(1) / t.shots_per_second(0) >= 1.7,
			"the Quickcycle is at least 1.7x the base fire rate (%.2fx)" % (t.shots_per_second(1) / t.shots_per_second(0)))


func _sound() -> void:
	var audio := get_node_or_null("/root/Audio")
	check(audio != null, "the Audio director is there")
	if audio == null:
		return
	var base_pitch: float = audio._sfx_pools[&"pistol_fire"]["pitch"]
	var quick_pitch: float = audio._sfx_pools[&"pistol_fire_quick"]["pitch"]
	check(quick_pitch >= base_pitch * 1.2, "the Quickcycle shot plays at least a minor third higher (%.2f vs %.2f)" % [quick_pitch, base_pitch])


func _gun_feedback() -> void:
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.size = Vector2(3000, 64)
	floor_b.position = Vector2(-500, 0)
	add_child(floor_b)
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = Vector2(800, -1)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(300.0, -40.0)
	await physics_frames(4)
	var gun: Scrapjack = hero.get_node("AimPivot/Scrapjack")

	Session.state["upgrades"]["W01"] = 0
	gun._try_fire()
	await physics_frames(1)
	var base_energy: float = gun._muzzle_light.energy
	var base_color: Color = gun._muzzle_light.color
	check(base_color.is_equal_approx(Scrapjack.FLASH_COLOR), "the base shot's muzzle light is the warm ivory")
	check(not gun._quickcycle.visible, "the flywheel is not shown before the upgrade")

	await seconds(0.6)
	Session.state["upgrades"]["W01"] = 1
	gun._try_fire()
	await physics_frames(1)
	check(gun._muzzle_light.color.is_equal_approx(Scrapjack.QUICK_FLASH_COLOR), "the Quickcycle shot's muzzle light is teal-white")
	check(gun._muzzle_light.energy > base_energy * 1.2,
			"the Quickcycle shot flares brighter (%.2f vs %.2f)" % [gun._muzzle_light.energy, base_energy])
	check(gun._quickcycle.visible, "the flywheel shows once fitted")
	check(gun._wheel_heat > 0.5, "a shot winds the flywheel up")
	check(gun._quickcycle.modulate.g > 1.3, "the wound-up flywheel glows teal (g %.2f)" % gun._quickcycle.modulate.g)
	var spin_before: float = gun._quickcycle_spin
	await physics_frames(3)
	var spin_fast := wrapf(gun._quickcycle_spin - spin_before, 0.0, TAU)
	await seconds(1.0)
	check(gun._wheel_heat < 0.01, "the flywheel winds down when the gun is idle")
	check(gun._quickcycle.modulate.is_equal_approx(Color.WHITE), "an idle flywheel is not lit")
	var idle_before: float = gun._quickcycle_spin
	await physics_frames(3)
	var spin_idle := wrapf(gun._quickcycle_spin - idle_before, 0.0, TAU)
	check(spin_fast > spin_idle * 4.0, "the wheel turns at least 4x as fast right after a shot (%.3f vs %.3f rad)" % [spin_fast, spin_idle])

	Session.state["upgrades"]["W01"] = 0
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


func _panel() -> void:
	Session.new_run()
	Session.set_story("awakening_done", true)
	Session.state["wallet"] = 45
	var panel: WorkbenchPanel = load(PANEL).instantiate()
	add_child(panel)
	await physics_frames(2)
	var vb := "Panel/VBox/"
	check(panel.get_node(vb + "ServiceHeader").text.contains("REPAIR AND SAVE"), "section 1 is named: repair and save")
	check(panel.get_node(vb + "UpgradeHeader").text.contains("UPGRADES"), "section 2 is named: upgrades")
	check_eq(panel.get_node(vb + "ServiceRow/ServiceButton").text, "Repair and save", "the service button says what it does")
	check_eq(panel.get_node(vb + "HeaderRow/WalletLabel").text, "45", "the header shows the chip count")
	check_eq(panel.get_node(vb + "QuickcycleCard/Info/NameRow/StateLabel").text, "NOT INSTALLED", "before buying: not installed")
	check(panel.get_node(vb + "QuickcycleCard/Info/RateGrid/NowValue").text.begins_with("3.1"), "the base rate is shown (3.1 shots/s)")
	check(panel.get_node(vb + "QuickcycleCard/Info/RateGrid/QuickValue").text.begins_with("5.6"), "the Quickcycle rate is shown (5.6 shots/s)")
	var now_frac: float = panel.get_node(vb + "QuickcycleCard/Info/RateGrid/NowBar/Fill").anchor_right
	check(absf(now_frac - 0.32 / 0.32 * 0.18 / 0.32) < 0.01, "the base bar is the base rate as a share of the Quickcycle's (%.2f)" % now_frac)
	var buy: Button = panel.get_node(vb + "UpgradeRowButtons/ConfirmButton")
	check(buy.visible and not buy.disabled, "with 45 chips Buy can be pressed")
	check(buy.text.contains("40"), "the Buy button names the price (%s)" % buy.text)
	check(panel.get_node(vb + "BalanceLabel").text.contains("Choose"), "with 45 chips it says you can buy one of the two")

	Session.state["wallet"] = 12
	Session.wallet_changed.emit(12)
	check(buy.disabled, "with 12 chips Buy is disabled")
	check(panel.get_node(vb + "BalanceLabel").text.contains("13"), "it says how many chips are missing for the cheaper one (13)")

	Session.state["wallet"] = 45
	Session.wallet_changed.emit(45)
	panel._on_confirm_pressed()
	check_eq(Session.weapon_stage("W01"), 1, "buying fits the Quickcycle")
	check_eq(Session.get_wallet(), 5, "the 40 chips are spent")
	check(panel.bought, "the panel remembers a buy (the bench announces it on close)")
	check_eq(panel.get_node(vb + "QuickcycleCard/Info/NameRow/StateLabel").text, "INSTALLED", "after buying: installed")
	check(not buy.visible, "no Buy button once installed")
	check(panel.get_node(vb + "StatusLabel").text.begins_with("Quickcycle installed"), "the line at the bottom says what happened")
	check_eq(panel.get_node(vb + "HeaderRow/WalletLabel").text, "5", "the header chip count follows")

	var closed := [false]
	panel.closed.connect(func(): closed[0] = true)
	panel._on_decline_pressed()
	check(closed[0], "Close emits closed")
	await physics_frames(2)
	Session.state["upgrades"]["W01"] = 0


func _hud_toast() -> void:
	Session.new_run()
	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	await physics_frames(2)
	check(hud.is_in_group("hud"), "the HUD is findable by group")
	Session.checkpoint_committed.emit("CP02")
	check_eq(hud._toast.text, "Progress saved", "an ordinary checkpoint still says Progress saved")
	Session.upgrade_purchased.emit("W01", 1)
	Session.checkpoint_committed.emit("UPG01")
	check(hud._toast.text.begins_with("Quickcycle online"), "a Quickcycle purchase says so instead (%s)" % hud._toast.text)
	check(hud._toast.text.contains("78%"), "and how much faster (%s)" % hud._toast.text)
	Session.checkpoint_committed.emit("UPG01")
	check_eq(hud._toast.text, "Progress saved", "the next save is an ordinary one again")
	hud.queue_free()
	await physics_frames(2)
