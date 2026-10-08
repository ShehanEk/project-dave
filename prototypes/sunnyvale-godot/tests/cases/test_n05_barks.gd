extends TestCase
## N05 (ElevenLabs audio pass) — the guards' and Staffers' recorded barks.
## Every voice_notice / voice_windup / voice_hurt line in data/tuning/night_guard.tres
## and staffer.tres has a recording (scripts/audio/bark_map.gd maps the caption text to
## its cue), and when an enemy says one, the recording plays from that enemy:
##   - the three moments each play the cue that matches the caption on screen: the
##     notice (first sight or first hit), the windup (every second one) and the first
##     hit after noticing; positional, at the speaker, exactly once;
##   - a dead enemy (the killing shot's bark, a body queued for removal) plays nothing;
##   - a line with no recording stays caption-only;
##   - the group's one voice at a time is held for the recording's length, so two
##     enemies' barks never overlap, and the hold is back to the caption's own length
##     for a line with no recording.
##
## How a play is observed: Audio hands each one-shot to a pooled AudioStreamPlayer[2D]
## and sets its `stream`, so the test empties the pools, triggers the moment, and counts
## the pool players holding a stream of that cue (as test_n05_ui_ticks.gd does).
## Saves and the playtest log go to a throwaway dir, never the real ones.

const BarkMap := preload("res://scripts/audio/bark_map.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const GUARD := "res://scenes/actors/night_guard.tscn"
const STAFFER := "res://scenes/actors/staffer.tscn"
const GUARD_TUNING := "res://data/tuning/night_guard.tres"
const STAFFER_TUNING := "res://data/tuning/staffer.tres"
const FIELDS: Array[String] = ["voice_notice", "voice_windup", "voice_hurt"]
const FLOOR_Y := 560.0


func run() -> void:
	var base_dir: String = CheckpointService.get_save_dir()
	var base_playtest: String = Telemetry.get_playtest_dir()
	var test_dir := "user://test_runs/n05_barks_%d" % Time.get_ticks_usec()
	CheckpointService.set_save_dir(test_dir)
	Telemetry.set_playtest_dir(test_dir)
	Session.new_run()

	_test_every_line_has_a_cue()
	_test_hold_covers_the_recordings()
	await _test_three_moments(GUARD, GUARD_TUNING, "Night Guard")
	await _test_three_moments(STAFFER, STAFFER_TUNING, "Staffer")
	await _test_every_line_plays_its_own_cue(GUARD, GUARD_TUNING, "Night Guard")
	await _test_every_line_plays_its_own_cue(STAFFER, STAFFER_TUNING, "Staffer")
	await _test_dead_enemy_plays_none()
	await _test_line_without_recording_is_caption_only()
	await _test_group_never_overlaps_two_barks()

	Session.new_run()
	CheckpointService.clear()
	CheckpointService.remove_dir_recursive(test_dir)
	CheckpointService.set_save_dir(base_dir)
	Telemetry.set_playtest_dir(base_playtest)


# --- the probe ---------------------------------------------------------------

## Stops and empties every pooled one-shot player, so what holds a stream after
## this was played since.
func _reset_pools() -> void:
	for p in Audio._sfx_pool:
		p.stop()
		p.stream = null
	for p in Audio._sfx2d_pool:
		p.stop()
		p.stream = null


## The pooled players (flat and positional) holding one of `cue`'s streams.
func _holders(cue: StringName) -> Array:
	var streams: Array = Audio._sfx_pools.get(cue, {}).get("streams", [])
	var out := []
	for p in Audio._sfx_pool:
		if p.stream != null and streams.has(p.stream):
			out.append(p)
	for p in Audio._sfx2d_pool:
		if p.stream != null and streams.has(p.stream):
			out.append(p)
	return out


func _all_bark_cues() -> Array:
	var out := []
	for cue in BarkMap.CUES.values():
		if not out.has(cue):
			out.append(cue)
	return out


## How many bark recordings are playing, across all eleven cues.
func _bark_plays() -> int:
	var n := 0
	for cue in _all_bark_cues():
		n += _holders(cue).size()
	return n


## The bark cues with a player holding them, in cue order.
func _playing_barks() -> Array:
	var out := []
	for cue in _all_bark_cues():
		if not _holders(cue).is_empty():
			out.append(cue)
	return out


## The longest take of `cue`, in seconds, measured from the loaded streams.
func _longest(cue: StringName) -> float:
	var longest := 0.0
	for s in Audio._sfx_pools.get(cue, {}).get("streams", []):
		longest = maxf(longest, (s as AudioStream).get_length())
	return longest


func _make_floor() -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(0.0, FLOOR_Y)
	b.size = Vector2(4000.0, 200.0)
	add_child(b)
	return b


## An enemy standing on the floor (alone, or as a child of `parent`), settled for two
## frames. No hero exists, so it only waits: every bark here is a moment the test
## triggers itself (a Staffer, which has no group or an active one, wakes by itself
## and says its notice line on the way: `_test_three_moments` uses an inactive group).
func _spawn(scene: String, x: float, parent: Node = null) -> Brawler:
	var b: Brawler = load(scene).instantiate()
	(parent if parent != null else self).add_child(b)
	b.global_position = Vector2(x, FLOOR_Y)
	await physics_frames(2)
	return b


## An EncounterGroup that stays inactive until `activate()`, so a Staffer stays dormant.
func _make_group() -> EncounterGroup:
	var group := EncounterGroup.new()
	group.wait_for_trigger = true
	add_child(group)
	return group


func _lines(tuning_path: String, field: String) -> PackedStringArray:
	return (load(tuning_path) as BrawlerTuning).get(field)


## One bark was said just now: the caption is one of `lines`, exactly its recording
## plays (once, nothing else), and it comes from the speaker's position.
func _check_spoken(b: Brawler, lines: PackedStringArray, label: String) -> void:
	var text: String = b.bark_label.text
	check(b.bark_label.visible, "%s: the caption shows" % label)
	check(lines.has(text), "%s: the caption is one of the tuning's lines (%s)" % [label, text])
	var cue: StringName = BarkMap.cue_for(text)
	check(cue != &"", "%s: the caption has a recording (%s)" % [label, text])
	check_eq(_holders(cue).size(), 1, "%s: its recording plays once (%s)" % [label, String(cue)])
	check_eq(_bark_plays(), 1, "%s: and no other bark plays with it" % label)
	for p in _holders(cue):
		check(p is AudioStreamPlayer2D and p.global_position.distance_to(b.global_position) < 1.0,
				"%s: positional, at the speaker" % label)


# --- 1. the data: every line has a recording --------------------------------------

func _test_every_line_has_a_cue() -> void:
	var used := {}
	var lines_seen := 0
	for path in [GUARD_TUNING, STAFFER_TUNING]:
		for field in FIELDS:
			var lines := _lines(path, field)
			check(not lines.is_empty(), "%s.%s has lines" % [path.get_file(), field])
			for text in lines:
				lines_seen += 1
				var cue: StringName = BarkMap.cue_for(text)
				check(cue != &"", "%s.%s has a recording: %s" % [path.get_file(), field, text])
				check(Audio.has_cue(cue), "...and %s exists in Audio" % String(cue))
				check_eq(Audio.cue_source(cue), &"eleven", "...and it is an ElevenLabs take: %s" % String(cue))
				used[cue] = true
	check(lines_seen >= 12, "setup: checked the tuning's lines (%d)" % lines_seen)
	# No orphan recordings: each of the eleven cues is some line's.
	for cue in BarkMap.CUES.values():
		check(used.has(cue), "%s is spoken by a tuning line" % String(cue))
	check_eq(_all_bark_cues().size(), 11, "BarkMap maps to eleven cues")
	check_eq(BarkMap.cue_for("a line nobody recorded"), &"", "an unmapped line has no cue")
	check_eq(BarkMap.cue_for(""), &"", "an empty line has no cue")


## The group's voice hold is the recording's longest take plus the gap, and stays
## inside the cap (so a longer clip than the cap would show up here, not as an overlap).
func _test_hold_covers_the_recordings() -> void:
	for cue in _all_bark_cues():
		var longest := _longest(cue)
		check(longest > 0.5, "setup: %s has a measurable take (%.2f s)" % [String(cue), longest])
		check(longest + Brawler.BARK_VOICE_GAP <= Brawler.BARK_VOICE_MAX,
				"%s (%.2f s) fits under the hold cap (%.1f s)" % [String(cue), longest, Brawler.BARK_VOICE_MAX])
		check(Brawler._cue_seconds(cue) >= longest - 0.001,
				"the hold measures the whole of %s (%.2f s)" % [String(cue), Brawler._cue_seconds(cue)])


# --- 2. the three moments ---------------------------------------------------------

func _test_three_moments(scene: String, tuning_path: String, label: String) -> void:
	Session.new_run()
	var floor_b := _make_floor()
	var t := load(tuning_path) as BrawlerTuning

	# Notice, by sight: a Staffer wakes (its group activating) and speaks; a Guard
	# notices the hero (the same call the walk into range makes).
	var group := _make_group()
	var b := await _spawn(scene, 500.0, group)
	_reset_pools()
	if t.dormant_until_active:
		check_eq(b.state, Brawler.State.DORMANT, "%s: setup: dormant until the group is active" % label)
		check_eq(_bark_plays(), 0, "%s: a dormant enemy says nothing" % label)
		group.activate()
		await physics_frames(2)
	else:
		b._notice()
	_check_spoken(b, t.voice_notice, label + " notice")
	# Noticing again says nothing more.
	_reset_pools()
	b._notice()
	check_eq(_bark_plays(), 0, "%s: a second notice plays no bark" % label)

	# Hurt: the first hit once he has noticed (this hit does not kill), once only.
	_reset_pools()
	b.hit_zone.take_hit(1, b.global_position, Vector2.LEFT)
	check(is_instance_valid(b) and b.health > 0 and b.state != Brawler.State.DEFEATED, "%s: setup: the hit left him alive" % label)
	_check_spoken(b, t.voice_hurt, label + " hurt")
	b.queue_free()
	group.queue_free()
	await physics_frames(2)

	# Notice by being shot first: the first hit on an unaware (or dormant) enemy.
	group = _make_group()
	b = await _spawn(scene, 500.0, group)
	_reset_pools()
	b.hit_zone.take_hit(1, b.global_position, Vector2.LEFT)
	_check_spoken(b, t.voice_notice, label + " first-hit notice")
	b.queue_free()
	group.queue_free()
	await physics_frames(2)

	# Windup: every second one speaks. Called through _enter(), the path the fight uses.
	group = _make_group()
	b = await _spawn(scene, 500.0, group)
	_reset_pools()
	b._enter(Brawler.State.WINDUP)
	check_eq(_bark_plays(), 0, "%s: the first windup is silent" % label)
	_reset_pools()
	b._enter(Brawler.State.WINDUP)
	_check_spoken(b, t.voice_windup, label + " windup")
	_reset_pools()
	b._enter(Brawler.State.WINDUP)
	check_eq(_bark_plays(), 0, "%s: the third windup is silent again" % label)
	_reset_pools()
	b._enter(Brawler.State.WINDUP)
	_check_spoken(b, t.voice_windup, label + " fourth windup")
	b.queue_free()
	group.queue_free()
	await physics_frames(2)

	floor_b.queue_free()
	await physics_frames(2)


## Many barks from one enemy: every one plays the recording of the caption it shows,
## and across the draws every line of the list is heard.
func _test_every_line_plays_its_own_cue(scene: String, tuning_path: String, label: String) -> void:
	var floor_b := _make_floor()
	var b := await _spawn(scene, 500.0)
	for field in FIELDS:
		var lines := _lines(tuning_path, field)
		var heard := {}
		for i in 40:
			_reset_pools()
			b._bark(lines)
			var text: String = b.bark_label.text
			heard[text] = true
			var cue: StringName = BarkMap.cue_for(text)
			check(_playing_barks() == [cue], "%s %s: '%s' plays %s and only that" % [label, field, text, String(cue)])
		for text in lines:
			check(heard.has(text), "%s %s: '%s' was heard over the draws" % [label, field, text])
	b.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 3. the dead do not talk ------------------------------------------------------

func _test_dead_enemy_plays_none() -> void:
	Session.new_run()
	var floor_b := _make_floor()
	# Alone in an inactive group, so only the Staffer below is dormant; everyone else has
	# no group, so a refused voice claim can never be what keeps them quiet.
	var group := _make_group()

	# The killing shot is where a bark would be chosen: a Guard who has noticed him
	# says his hurt line on the first hit after, and an unaware one his notice line on
	# the first. Dead on that very hit, neither says it (the caption is as before).
	var guard := await _spawn(GUARD, 500.0)
	guard._notice()
	_reset_pools()
	guard.hit_zone.take_hit(guard.tuning.health, guard.global_position, Vector2.LEFT)
	check(guard.state == Brawler.State.DEFEATED and guard.is_queued_for_deletion(), "setup: one big hit kills the Guard who had noticed")
	check_eq(_bark_plays(), 0, "a Guard's killing shot plays no hurt bark")

	var g1 := await _spawn(GUARD, 700.0)
	_reset_pools()
	g1.hit_zone.take_hit(g1.tuning.health, g1.global_position, Vector2.LEFT)
	check(g1.state == Brawler.State.DEFEATED, "setup: one big hit kills the unaware Guard")
	check_eq(_bark_plays(), 0, "a Guard killed before he noticed plays no notice bark")

	# The same for a Staffer, dormant (the group is inactive) and awake.
	var s1 := await _spawn(STAFFER, 900.0, group)
	check_eq(s1.state, Brawler.State.DORMANT, "setup: the Staffer is dormant")
	_reset_pools()
	s1.hit_zone.take_hit(s1.tuning.health, s1.global_position, Vector2.LEFT)
	check(s1.state == Brawler.State.DEFEATED, "setup: one big hit kills the dormant Staffer")
	check_eq(_bark_plays(), 0, "a dormant Staffer killed outright plays no notice bark")

	var s2 := await _spawn(STAFFER, 1100.0)  # no group: wakes and notices by itself
	_reset_pools()
	s2.hit_zone.take_hit(s2.tuning.health, s2.global_position, Vector2.LEFT)
	check(s2.state == Brawler.State.DEFEATED, "setup: one big hit kills the awake Staffer")
	check_eq(_bark_plays(), 0, "an awake Staffer's killing shot plays no hurt bark")

	# A corpse or a body freed this frame says nothing, whoever asks.
	var g2 := await _spawn(GUARD, 1300.0)
	g2.state = Brawler.State.DEFEATED
	_reset_pools()
	g2._bark(g2.tuning.voice_notice)
	check_eq(_bark_plays(), 0, "an enemy in the defeated state plays no bark")
	g2.state = Brawler.State.PATROL
	g2.queue_free()
	_reset_pools()
	g2._bark(g2.tuning.voice_windup)
	check_eq(_bark_plays(), 0, "an enemy queued for removal plays no bark")

	# Control: the same call from a living Guard does speak (the probe is not blind).
	var g3 := await _spawn(GUARD, 1500.0)
	_reset_pools()
	g3._bark(g3.tuning.voice_notice)
	check_eq(_bark_plays(), 1, "control: a living Guard speaks")

	g3.queue_free()
	group.queue_free()
	floor_b.queue_free()
	await physics_frames(3)


# --- 4. a line with no recording stays caption-only ---------------------------------

func _test_line_without_recording_is_caption_only() -> void:
	var floor_b := _make_floor()
	var group := EncounterGroup.new()
	add_child(group)
	var b := await _spawn(GUARD, 500.0, group)
	var t := b.tuning.duplicate() as BrawlerTuning
	t.voice_notice = PackedStringArray(["A line nobody has recorded yet."])
	b.tuning = t
	_reset_pools()
	b._notice()
	check_eq(b.bark_label.text, "A line nobody has recorded yet.", "the caption shows as always")
	check(b.bark_label.visible, "...visible")
	check_eq(_bark_plays(), 0, "...and no recording plays")
	var held: int = group._voice_free_frame - Engine.get_physics_frames()
	check_eq(held, int(Brawler.BARK_TIME * Engine.physics_ticks_per_second),
			"...and the group holds its voice for the caption's own length only")
	b.queue_free()
	group.queue_free()
	floor_b.queue_free()
	await physics_frames(3)


# --- 5. one voice at a time, held for the recording ---------------------------------

func _test_group_never_overlaps_two_barks() -> void:
	var floor_b := _make_floor()
	var group := EncounterGroup.new()
	add_child(group)
	var a := await _spawn(GUARD, 500.0, group)
	var b := await _spawn(GUARD, 700.0, group)
	check(a._group == group and b._group == group, "setup: both Guards belong to the group")

	_reset_pools()
	a._notice()
	var playing := _playing_barks()
	check_eq(playing.size(), 1, "the first Guard speaks and his recording plays")
	check_eq(_bark_plays(), 1, "...once")
	if playing.size() == 1:
		var cue: StringName = playing[0]
		var held: int = group._voice_free_frame - Engine.get_physics_frames()
		var clip_frames := int(ceil(_longest(cue) * Engine.physics_ticks_per_second))
		check(held >= clip_frames, "the group holds the voice for the whole recording (%d frames held, %d long: %s)" % [held, clip_frames, String(cue)])
		check(held >= int(Brawler.BARK_TIME * Engine.physics_ticks_per_second), "...and never less than the caption's time")

		# The second Guard notices at once: refused, no caption, no recording.
		b._notice()
		check(not b.bark_label.visible, "a second Guard noticing at once shows no caption")
		check_eq(_bark_plays(), 1, "...and plays no second recording")

		# Still refused with the first clip half over and one frame before it ends.
		var half := int(held * 0.5)
		await physics_frames(half)
		b._bark(b.tuning.voice_hurt)
		check_eq(_bark_plays(), 1, "half way through the recording, still only one bark plays")
		check(not b.bark_label.visible, "...and still no second caption")
		await physics_frames(held - half - 2)
		b._bark(b.tuning.voice_windup)
		check_eq(_bark_plays(), 1, "just before the recording ends, still only one bark plays")

		# Once the hold is up the other Guard may speak, and does.
		await physics_frames(3)
		_reset_pools()
		b._bark(b.tuning.voice_windup)
		check_eq(_bark_plays(), 1, "after the recording the second Guard speaks")
		check(b.bark_label.visible, "...with his caption")

	a.queue_free()
	b.queue_free()
	group.queue_free()
	floor_b.queue_free()
	await physics_frames(3)
