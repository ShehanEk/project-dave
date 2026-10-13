extends TestCase
## REGRESSION (ADV-07): CheckpointService.validate_snapshot() used to accept
## several tampered-but-well-typed saves (a third weapon instance, the same
## instance both held and on a pad, a deleted world weapon, an out-of-range
## upgrade stage, an extra top-level field, a negative chip value, an absurd
## wallet, health 0), and Hero.take_damage() treated health 0 as "already
## dead", permanently undamageable. Its own doc says validate_snapshot()
## rejects "an out-of-range value, a non-whitelisted id string ... or a
## missing/extra field" — fixed to actually enforce that, plus removed
## Hero's own health<=0 gate as defense in depth.

var cs: Node


func _base() -> Dictionary:
	return Session.default_state()


func _rejects(mutated: Dictionary, label: String) -> void:
	var v: Dictionary = cs.validate_snapshot(JSON.parse_string(JSON.stringify(mutated)))
	check(not v.ok, "tampered save should be rejected: %s" % label)


func run() -> void:
	cs = get_node("/root/CheckpointService")
	check(cs.validate_snapshot(JSON.parse_string(JSON.stringify(_base()))).ok, "baseline default_state validates")

	var s := _base()
	s["world_weapons"] = {"L01-W01-P02": "L01-A05-PAD01", "L01-W01-P03": "L01-A05-PAD01"}
	_rejects(s, "third weapon instance P03 on the pad")

	s = _base()
	s["equipped_weapon"] = "L01-W01-P02"  # P02 also still on the pad
	_rejects(s, "same instance both held and on the pad")

	s = _base()
	s["world_weapons"] = {}
	_rejects(s, "P02 deleted from the world")

	s = _base()
	s["upgrades"] = {"W01": 3}
	_rejects(s, "W01 stage 3 (prototype has only Quickcycle stage 1)")

	s = _base()
	s["evil"] = "res://scenes/debug/m4_demo.tscn"
	_rejects(s, "extra top-level field carrying a scene path")

	s = _base()
	s["collected"] = {"L01-A01-G001": -500}
	_rejects(s, "negative chip value in collected")

	s = _base()
	s["wallet"] = 1e300
	_rejects(s, "wallet 1e300")

	s = _base()
	s["health"] = 0
	_rejects(s, "health 0 (a committed checkpoint can never be dead)")

	# What does health 0 do if it IS loaded? take_damage() refuses when
	# health <= 0, so the hero can never be hurt again.
	Session.load_from_snapshot(s)
	var level: LevelDirector = load("res://scenes/levels/level_01.tscn").instantiate()
	add_child(level)
	await physics_frames(4)
	var hurt: bool = level.hero.take_damage(1, level.hero.global_position + Vector2(10, 0))
	check(hurt, "health-0 Continue: hero should still be damageable (take_damage returned %s, health=%d)"
			% [hurt, Session.get_health()])
	level.queue_free()
	await physics_frames(2)
