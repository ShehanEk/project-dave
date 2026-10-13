extends TestCase
## Regression (found in M2): Hero.take_damage() set the hit's knockback AFTER
## Session.apply_damage(). On a lethal hit `died` fires inside apply_damage(), and
## LevelDirector (without the death beat, as in the tests) moves Dave to his respawn
## marker right there; the knockback set afterwards then pushed him ~16 px off it. The
## knockback now goes on before the damage, so respawn_at() clears it. A hit that does
## not kill still knocks Dave back as before.

const H := 96.0


func run() -> void:
	await _test_level("L01", "CP02", "Respawn_CP02")
	await _test_level("L02", "CP01", "Respawn_CP01")
	await _test_non_lethal_hit_still_knocks_back()


func _build(level_id: String) -> LevelDirector:
	var lvl: LevelDirector = load("res://scenes/levels/level.tscn").instantiate()
	lvl.level_def = LevelDefs.get_def(level_id)
	add_child(lvl)
	await physics_frames(3)
	return lvl


func _test_level(level_id: String, cp: String, marker_name: String) -> void:
	release_all()
	CheckpointService.clear()
	Session.new_run(level_id)
	var lvl := await _build(level_id)
	var def := lvl.level_def
	var entry: Array = def.checkpoint_markers[cp]
	# Commit the checkpoint, so the death comes back to its marker.
	lvl._place_hero_at_checkpoint(cp)
	await physics_frames(10)
	Session.commit(cp)
	# Dave dies somewhere else, hit from his left (the old knockback pushed him right).
	var area: AreaRoot = lvl.areas[entry[0]]
	lvl.hero.respawn_at(area.global_position + Vector2(area.width * 0.5, -300.0))
	await physics_frames(2)
	var died := lvl.hero.take_damage(999, lvl.hero.global_position + Vector2(-40.0, 0.0))
	await seconds(1.5)
	var marker: Marker2D = lvl.areas[entry[0]].get_marker(marker_name)
	# Markers stand 4 px over their floor (Dave drops onto it): measure along the floor.
	var off: Vector2 = lvl.hero.global_position - marker.global_position
	check(died, "%s: the lethal hit lands" % level_id)
	check(lvl.hero.is_on_floor() and absf(off.x) <= 2.0 and off.y >= -0.5 and off.y <= 6.0,
			"%s: after a lethal hit Dave settles on his respawn marker %s (off by %s)" % [level_id, marker_name, str(off)])
	lvl.queue_free()
	await physics_frames(2)
	CheckpointService.clear()


func _test_non_lethal_hit_still_knocks_back() -> void:
	release_all()
	Session.new_run("L01")
	var lvl := await _build("L01")
	await physics_frames(10)
	var start := lvl.hero.global_position
	var health := Session.get_health()
	check(lvl.hero.take_damage(1, start + Vector2(-40.0, 0.0)), "a 1-damage hit lands")
	await seconds(0.6)
	check_eq(Session.get_health(), health - 1, "it costs 1 health")
	check(lvl.hero.global_position.x - start.x >= 8.0,
			"a hit that does not kill still knocks Dave back, away from the source (moved %.1f px)" % (lvl.hero.global_position.x - start.x))
	lvl.queue_free()
	await physics_frames(2)
	Session.new_run()
