extends TestCase
## M0 smoke: Session autoload exists, new run matches T01 values, and a
## commit/restore round trip is a deep copy.

func run() -> void:
	var s := get_node_or_null("/root/Session")
	check(s != null, "Session autoload present")
	if s == null:
		return
	check_eq(s.get_health(), 6, "new run health")
	check_eq(s.get_wallet(), 0, "new run wallet")
	check_eq(s.weapon_stage("W01"), 0, "new run W01 stage")
	check_eq(s.equipped_weapon(), "L01-W01-P01", "starting weapon instance")
	check_eq(s.get_story("core_installed"), true, "core installed")
	check_eq(s.get_story("awakening_done"), false, "EDEN asleep")
	check_eq(s.state["checkpoint_id"], "CP00", "checkpoint CP00")
	s.collect("L01-A01-G001", 1)
	s.apply_damage(2)
	check_eq(s.get_wallet(), 1, "wallet after collect")
	check(not s.collect("L01-A01-G001", 1), "repeat collect refused")
	s.restore_committed()
	check_eq(s.get_wallet(), 0, "restore rolls back wallet")
	check_eq(s.get_health(), 6, "restore rolls back health")
	check(not s.is_collected("L01-A01-G001"), "restore rolls back collected flag")
	for action in ["move_left", "move_right", "jump", "fire", "interact", "pause", "journal"]:
		check(InputMap.has_action(action), "input action " + action)
