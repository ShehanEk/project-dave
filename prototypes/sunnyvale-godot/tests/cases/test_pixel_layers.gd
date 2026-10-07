extends TestCase
## C39: the outdoor areas' sky layer draws the user's painted pixel-art far
## layer (sky and city skyline) and their campus layer draws the painted
## campus offices: both are loaded, drawn crisp (nearest filtering) and
## repeating, and move slower than the camera (their own parallax), the
## campus faster than the far city. The old code-drawn towers, pavilions,
## hedges, path lights and billboard are gone. The terrain blocks draw the
## painted terrain pieces, and the street furniture the painted props (C42).
## The server depot's backdrop draws the painted wall (Sheet 5) in place of
## its code-drawn racks and cables.

func run() -> void:
	Session.new_run()
	var area: Node2D = load("res://scenes/levels/areas/a02_gardens.tscn").instantiate()
	add_child(area)
	await physics_frames(2)
	var sky = area.get_node("Background/Sky")
	var homes = area.get_node("Background/Homes")
	check(sky._far != null, "the sky layer loads the painted far layer")
	check_eq(sky.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "it is drawn crisp, pixel for pixel")
	check_eq(sky.texture_repeat, CanvasItem.TEXTURE_REPEAT_ENABLED, "and repeats sideways")
	check(sky.is_processing(), "it redraws as the camera moves (its own parallax)")
	check(homes._towers.is_empty(), "the campus layer no longer draws the old towers")
	check(sky.FAR_DEPTH > 0.5 and sky.FAR_DEPTH < 1.0, "the far layer moves slower than the camera")
	check(homes._campus != null, "the campus layer loads the painted campus offices")
	check_eq(homes.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "they are drawn crisp too")
	check_eq(homes.texture_repeat, CanvasItem.TEXTURE_REPEAT_ENABLED, "and repeat sideways")
	check(homes.is_processing(), "the campus redraws as the camera moves")
	check(homes._pavilions.is_empty() and homes._hedges.is_empty() and homes._billboards.is_empty() \
			and homes._path_lights.is_empty(), "the old drawn pavilions, hedges, lights and billboard are gone")
	check(homes.CAMPUS_DEPTH > 0.0 and homes.CAMPUS_DEPTH < sky.FAR_DEPTH, "the campus moves faster than the far city")
	area.queue_free()
	await physics_frames(2)
	await _terrain()


## The painted terrain (C39 terrain sheet): blocks draw their piece crisp,
## the roofs' backstop is the AC unit, meeting blocks join, and the depot
## keeps its code-drawn look.
func _terrain() -> void:
	var level: Node2D = load("res://scenes/levels/level_01.tscn").instantiate()
	add_child(level)
	await physics_frames(3)
	var a2: Node = level.areas[1]
	var a3: Node = level.areas[2]
	var a5: Node = level.areas[4]
	var floor_b01: Block = a2.get_node("Geometry/FloorB01")
	var floor_gap1: Block = a2.get_node("Geometry/FloorGap1")
	check_eq(floor_b01.skin_name(), "walkway", "ground blocks draw the painted walkway")
	check_eq(floor_b01.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp, pixel for pixel")
	check_eq(floor_b01._joins("walkway"), Vector2i(1, 1), "a floor block between two others joins both, so no end caps show")
	check_eq(floor_gap1._joins("walkway").x, 1, "and its neighbour joins back")
	_paving(floor_b01, floor_gap1, a2.get_node("Geometry/LowerCatch"))
	check_eq((a3.get_node("Geometry/Terrace4b") as Block).skin_name(), "green_roof", "the roofs draw the green-roof slab")
	var ac: Block = a3.get_node("Geometry/E05Backstop")
	check_eq(ac.skin_name(), "ac_unit", "the roof backstop is the rooftop AC unit")
	check(ac.size.y <= 86.4, "and it is still an ordinary rise (%.0f px)" % ac.size.y)
	check_eq((level.areas[3].get_node("Geometry/E07Backstop") as Block).skin_name(), "stone_planter", "other backstops are the stone planter")
	check_eq((a5.get_node("Geometry/FloorMain") as Block).skin_name(), "", "the depot keeps its code-drawn floor until its own art")
	_props(level)
	_buildings(level)
	_pickups(level)
	_objects(level)
	_depot(level)
	level.queue_free()
	await physics_frames(2)


## The wet paving (paving sheet): the strip between its 1-pixel outline caps
## is the whole repeating period, its cold-white lit row is the walkway's
## edge, two floor blocks that meet continue one pattern (no caps there) while
## a lone block keeps its caps, and the wall face under it is one period deep.
func _paving(a: Block, b: Block, lone: Block) -> void:
	var skins = load("res://scripts/world/terrain_skins.gd")
	var s: Dictionary = skins.SKINS["walkway"]
	var tex: Texture2D = skins.texture(s["tex"])
	var tw: int = tex.get_width()
	var cols: Vector2i = s["cols"]
	check_eq(cols, Vector2i(1, tw - 1), "the paving repeats between its 1-pixel outline caps")
	check(tex.get_image().get_pixel(10, s["edge"]).get_luminance() > 0.8, "its edge row is the cold-white lit line")
	var th: int = tex.get_height()
	var pa: Array = skins.band_pieces(s, tw, s["from"], th, 0.0, a.size.x / skins.ART, a.global_position.x, a._joins("walkway"))
	var pb: Array = skins.band_pieces(s, tw, s["from"], th, 0.0, b.size.x / skins.ART, b.global_position.x, b._joins("walkway"))
	var period := float(cols.y - cols.x)
	var gap: float = fposmod(pa[-1][0].end.x - pb[0][0].position.x + period * 0.5, period) - period * 0.5
	check(absf(gap) < 0.01, "two floor blocks that meet continue one paving pattern (%.3f px apart)" % gap)
	check(pa[0][0].position.x >= cols.x and pb[0][0].position.x >= cols.x, "and draw no end cap where they meet")
	var pl: Array = skins.band_pieces(s, tw, s["from"], th, 0.0, lone.size.x / skins.ART, lone.global_position.x, lone._joins("walkway"))
	check(pl[0][0].size.x == 1.0 and pl[1][0].size.x == 1.0, "a lone block keeps 1-pixel outline caps on both ends")
	var face: Dictionary = skins.SKINS["wall_face"]
	check_eq(face["cols"], Vector2i(1, skins.texture(face["tex"]).get_width() - 1), "the wall face repeats between its caps too")
	check_eq(skins.FACE_DEPTH, face["to"] - face["from"], "and runs one wall period deep, so it ends on a mortar line")


## The painted street furniture (C42 props sheet): props draw their piece
## crisp while their glows stay smooth, a painted lamp's light sits at its
## lens, and the depot keeps its code-drawn props.
func _props(level: Node2D) -> void:
	var a2: Node = level.areas[1]
	var lamp: Scenery = a2.get_node("Scenery/LandingLamp_CourtA")
	check_eq(lamp.painted_piece(), "lamp", "garden lamps draw the painted lamp post")
	check_eq(lamp.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp, pixel for pixel")
	check_eq(lamp._lamp_glow_circle.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR, "while its glow stays smooth")
	var lens: Vector2 = lamp.to_global(Vector2(0.0, lamp.PropSkins.lamp_lens_y(lamp.size.y)))
	check(lamp._lamp_light.global_position.distance_to(lens) < 1.0,
			"its light sits at the painted lens (%s vs %s)" % [lamp._lamp_light.global_position, lens])
	check_eq((a2.get_node("Scenery/Fence1") as Scenery).painted_piece(), "fence", "railings draw the painted railing")
	check_eq((a2.get_node("Scenery/Shrub1") as Scenery).painted_piece(), "shrub", "hedges draw the painted hedge")
	check_eq((level.areas[4].get_node("Scenery/UtilityLampA") as Scenery).painted_piece(), "",
			"the depot keeps its code-drawn lamps until its own art")


## The painted buildings (C42 buildings sheet): the guard booth, entry gate,
## landmark tower, reflecting pool and doors draw their pieces, the landmark's
## glow sits on its painted emblem, and the depot's own door stays code-drawn.
func _buildings(level: Node2D) -> void:
	var a1: Node = level.areas[0]
	var a4: Node = level.areas[3]
	var a5: Node = level.areas[4]
	var a6: Node = level.areas[5]
	check_eq((a1.get_node("Scenery/House1") as Scenery).painted_piece(), "booth", "the guard booth is the painted booth")
	check_eq((a1.get_node("Scenery/EntryGate") as Scenery).painted_piece(), "gate", "the entry gate is the painted broken gate")
	var tower: Scenery = a1.get_node("Scenery/Clock")
	check_eq(tower.painted_piece(), "landmark", "the landmark is the painted tower")
	check(tower._clock_glow.position.is_equal_approx(tower._clock_emblem_center()), "its glow sits on the painted emblem")
	check_eq((a4.get_node("Scenery/Fountain") as Scenery).painted_piece(), "pool", "the reflecting pool is painted")
	check_eq((a4.get_node("Scenery/DepotDoor") as Scenery).painted_piece(), "depot_door", "the depot's outer door is painted")
	check_eq((a6.get_node("Scenery/AnnexDoors/AnnexDoor_E10") as Scenery).painted_piece(), "annex_door", "annex doors are the painted annex door")
	check_eq((a5.get_node("Scenery/DepotDoor") as Scenery).painted_piece(), "", "the depot's own door keeps its code-drawn look until its sheet")


## The painted depot wall (Sheet 5): the depot's backdrop loads it, draws it
## crisp on its own child canvas (the haze and lights stay smooth), repeats it
## across the area, stands it on the floor line with its top behind the ceiling
## block, tints it cool then red-leaning in lockdown, and no longer draws or
## animates the code racks and cables (which stay as the fallback); the
## ceiling fixtures keep working.
func _depot(level: Node2D) -> void:
	var depot = level.areas[4].get_node("Background/Interior")
	check(depot._depot_wall != null, "the depot backdrop loads the painted wall")
	var wall: Node2D = depot.get_node_or_null("Wall")
	check(wall != null and wall.show_behind_parent, "it draws on its own canvas, under the fill, haze and fixtures")
	check_eq(wall.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp, pixel for pixel")
	check_eq(wall.texture_repeat, CanvasItem.TEXTURE_REPEAT_ENABLED, "and repeats sideways")
	check(depot.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST, "while the haze and lights on the backdrop itself stay smooth")
	check(depot._racks.is_empty() and depot._cables.is_empty(), "the code-drawn racks and cables are gone")
	check(depot._anim == null and not depot.is_processing(), "and nothing animates or redraws on top of the painted wall")
	var img: Image = depot._depot_wall.get_image()
	var h: float = float(img.get_height()) * depot.FAR_ART_PX
	check(h >= -depot.CEILING_Y and h <= -depot.CEILING_Y + 40.0, "it stands on the floor with its top behind the ceiling block (%.0f px tall)" % h)
	check(float(depot.tile_width) / (float(img.get_width()) * depot.FAR_ART_PX) > 2.0, "and repeats across the area (%.1f times)" % (float(depot.tile_width) / (float(img.get_width()) * depot.FAR_ART_PX)))
	var edge := 0.0
	for y in img.get_height():
		var a: Color = img.get_pixel(0, y)
		var b: Color = img.get_pixel(img.get_width() - 1, y)
		edge += (absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)) / 3.0
	check(edge / float(img.get_height()) < 8.0 / 255.0, "its last column meets its first, so the repeat shows no seam")
	check(depot.DEPOT_TINT.b > depot.DEPOT_TINT.r, "the calm tint is slightly cool")
	check(depot.DEPOT_LOCKDOWN_TINT.r > depot.DEPOT_LOCKDOWN_TINT.b and depot.DEPOT_LOCKDOWN_TINT.r > depot.DEPOT_LOCKDOWN_TINT.g,
			"the lockdown tint leans red")
	check(depot._fixtures.size() >= 3 and depot._fixture_lights.size() == depot._fixtures.size(), "the ceiling fixtures and their lights are kept")
	check(depot._wall_tint().is_equal_approx(depot.DEPOT_TINT), "the calm wall takes the cool tint")
	depot.set_lockdown_mode(true, false)
	check_eq(depot._fixture_state(0), 2, "a settled lockdown still turns the fixtures alarm red")
	check(depot._wall_tint().is_equal_approx(depot.DEPOT_LOCKDOWN_TINT), "and the wall takes the red-leaning tint")
	depot.set_lockdown_mode(true, true)
	check_eq(depot._fixture_state(depot._fixtures.size() - 1), 0, "a live lockdown starts with the last bank still lit")
	check(depot._wall_tint().is_equal_approx(depot.DEPOT_TINT), "and the wall reddens as the banks switch, not at once")
	depot.set_lockdown_mode(false, false)
	# without the art (an export missing the PNG) the code-drawn racks and cables return
	depot._depot_wall = null
	depot._build_depot()
	check(not depot._racks.is_empty() and not depot._cables.is_empty(), "without the painted wall the code-drawn racks and cables are the fallback")
	check_eq(depot._fixture_lights.size(), depot._fixtures.size(), "and the fixtures' lights are rebuilt one each")


## The painted interactive objects (objects sheet): every station, the lever,
## the depot's bench, pad, core and hatch, and the service wicket draw their
## pieces crisp (the depot too) while their toasts stay smooth, and each
## state picks its own piece.
func _objects(level: Node2D) -> void:
	var skins = load("res://scripts/world/object_skins.gd")
	var a2: Node = level.areas[1]
	var a4: Node = level.areas[3]
	var a5: Node = level.areas[4]
	var a6: Node = level.areas[5]
	var station: RecoveryStation = a2.get_node("Entities/RecoveryStation_CP01")
	check_eq(station.painted_piece(), "recovery_station_off", "a waiting recovery station draws the lamp-off piece")
	check_eq(station.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp, pixel for pixel")
	check_eq((station.get_node("Toast") as Label).texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR, "while its toast text stays smooth")
	var lamp: Vector2 = station.lamp_position()
	check(lamp.y < -100.0 and lamp.y > -135.0 and absf(lamp.x) < 12.0, "its lamp is at the painted head (%s)" % lamp)
	Session.state["checkpoint_id"] = "CP01"
	check_eq(station.painted_piece(), "recovery_station_on", "the active checkpoint's lamp is lit")
	Session.state["checkpoint_id"] = ""
	check_eq(skins.piece_size("recovery_station_on"), Vector2(60.0, 135.0), "painted at 1.5 world px per art pixel, unscaled")
	check((a4.get_node("Entities/RecoveryStation_CP03") as RecoveryStation).painted_piece() != "", "every station is painted")
	var lever: RouteSwitch = a4.get_node("Entities/RouteSwitch_SW01")
	check_eq(lever.painted_piece(), "lever_up", "a lever that is not pulled draws the lever up")
	check_eq(lever.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "the lever is crisp")
	Session.set_switch("L01-SW01", true)
	check_eq(lever.painted_piece(), "lever_down", "a pulled lever draws the lever down")
	check(skins.at("lever_up", Vector2(14.0, 38.0)).is_equal_approx(skins.at("lever_down", Vector2(13.0, 30.0))),
			"the lever's plate stays put between states")
	var bench: Workbench = a5.get_node("Entities/Workbench")
	check_eq(bench.painted_piece(), "workbench", "the depot's workbench is painted")
	check_eq(bench.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp too")
	check_eq((a5.get_node("Entities/WeaponPad") as WeaponPad).painted_piece(), "weapon_pad", "so is its weapon pad")
	var core: CoreNode = a5.get_node("Entities/CoreNode")
	check_eq(core.painted_piece(), "core_calm", "the core node is calm teal before the lockdown")
	check_eq(core.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp")
	core._phase = "awake"
	check_eq(core.painted_piece(), "core_alarm", "and alarm amber once the lockdown is on")
	core._phase = "idle"
	var hatch: EmergencyHatch = a5.get_node("Geometry/Hatch")
	check_eq(hatch.painted_piece(), "hatch_closed", "the hatch is the closed door")
	check_eq(hatch.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp")
	check(skins.repeats("hatch_closed", hatch.size.y) >= 1, "its middle repeats to come close to the solid's height")
	Session.set_story("hatch_open", true)
	check_eq(hatch.painted_piece(), "hatch_open", "and the open doorway once the lockdown opens it")
	var wicket: ExitWicket = a6.get_node("Entities/ExitWicket")
	check_eq(wicket.painted_piece(), "gate_shut", "the hold-out gate is shut by the striped bar")
	check_eq(wicket.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp")
	wicket._open = true
	check_eq(wicket.painted_piece(), "gate_locked", "once open without the card it is the barred gate with the amber reader")
	Session.take_keycard("L01-KC01", "L01-KC01-P")
	check_eq(wicket.painted_piece(), "gate_open", "and with the card the open frame with the teal reader")


## The painted pickups, practice target and sized pieces (objects2 sheet):
## each draws its piece crisp (toasts smooth), the cluster its own piece, the
## sized ones stretch to any size without scaling a pixel and keep their
## collision, and the depot's target is painted too.
func _pickups(level: Node2D) -> void:
	var skins = load("res://scripts/world/pickup_skins.gd")
	var a1: Node = level.areas[0]
	var a3: Node = level.areas[2]
	var a4: Node = level.areas[3]
	var a5: Node = level.areas[4]
	var a6: Node = level.areas[5]
	check(not skins.has_piece("no_such_piece"), "a missing piece is reported, so the code-drawn look stays the fallback")
	var chip: Chip = a1.get_node("Entities/Chip_G001")
	check_eq(chip.painted_piece(), "chip", "a chip draws the painted chip")
	check_eq(chip.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp, pixel for pixel")
	check_eq(skins.piece_size("chip"), Vector2(30.0, 30.0), "painted at 1.5 world px per art pixel, unscaled")
	var cluster: Chip = level.find_child("ChipCluster_GC01", true, false)
	check_eq(cluster.painted_piece(), "chip_cluster", "a five-chip pickup draws the cluster")
	var card: Keycard = level.find_child("Keycard_KC01", true, false)
	check_eq(card.painted_piece(), "keycard", "the keycard is painted")
	check_eq(card.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp")
	check_eq((card.get_node("Toast") as Label).texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR, "while its toast text stays smooth")
	check_eq((level.find_child("MedPatch_HS01", true, false) as MedPatch).painted_piece(), "med_patch", "med-patches are painted")
	var folder: EvidencePickup = level.find_child("EvidencePickup_A01", true, false)
	check_eq(folder.painted_piece(), "evidence_folder", "the evidence file is the painted folder")
	check_eq((folder.get_node("Toast") as Label).texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR, "its toast stays smooth")
	var cache: ChipCache = level.find_child("ChipCache_OPT02", true, false)
	check_eq(cache.painted_piece(), "chip_cache", "the chip cache is painted, closed and opened")
	check_eq(cache.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp")
	var target: PracticeTarget = a1.get_node("Entities/PracticeTarget")
	check_eq(target.painted_piece(), "practice_target", "the practice target is painted")
	check_eq(target.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp")
	target.hit_zone.hit.emit(1, Vector2.ZERO, Vector2.RIGHT)
	check(target._flash_timer > 0.0, "a hit still flashes the painted target")
	check_eq((a5.get_node("Entities/PracticeTarget") as PracticeTarget).painted_piece(), "practice_target", "the depot's target is painted too")
	var walkway: ServiceWalkway = a4.get_node("Geometry/Walkway")
	check_eq(walkway.painted_piece(), "service_walkway", "the service walkway is painted")
	check_eq(walkway.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp")
	check_eq(((walkway.get_node("Shape") as CollisionShape2D).shape as RectangleShape2D).size, Vector2(walkway.width, walkway.thickness),
			"and its collision is still the plank's size")
	var platform: MovingPlatform = a3.get_node("Geometry/GapPlatform")
	check_eq(platform.painted_piece(), "moving_platform", "the moving platform is painted")
	check_eq(platform.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp")
	var lights: Array = platform.LIGHT_COLS.map(func(col): return skins.column_x("moving_platform", platform.width, col))
	check(lights[0] > 0.0 and lights[0] < lights[1] and lights[1] < lights[2] and lights[2] < platform.width,
			"its three lights sit in order inside it (%s)" % [lights])
	check(absf(lights[1] - platform.width * 0.5) < 3.0, "the middle light stays in the middle (%.1f)" % lights[1])
	var pit: PitHazard = a3.get_node("Entities/RoofPit_S1")
	check_eq(pit.painted_piece(), "pit_cover", "roof pits are the painted hazard cover")
	check_eq(pit.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "crisp")
	check_eq(((pit.get_node("CollisionShape2D") as CollisionShape2D).shape as RectangleShape2D).size, pit.size, "a pit's trigger still matches its size")
	check_eq((a6.get_node("Entities/PitHazard_B03") as PitHazard).painted_piece(), "pit_cover", "so is the exit pit")
	# stretching: end caps stay, the middle repeats, and a size is always filled exactly
	for piece in ["service_walkway", "moving_platform", "pit_cover"]:
		var cols: Array = skins.LAYOUTS[piece]["cols"]
		for w in [24, 40, 80, 106, 158, 320, 453]:
			var runs: Array = skins._col_runs(cols, w, 7, true)
			var total := 0
			var gaps := 0
			for run in runs:
				total += run.y - run.x
				gaps += 0 if run.z + run.y - run.x <= w else 1
			check(total == w and gaps == 0, "%s fills %d art columns exactly (%d)" % [piece, w, total])
		var full: Array = skins._col_runs(cols, 400, 0, false)
		check_eq((full[0] as Vector3i).x, 0, "%s keeps its left end cap" % piece)
		check_eq((full[-1] as Vector3i).y, int(skins.texture(piece).get_width()), "and its right end cap")
	var pit_rows: Array = skins._row_runs(skins.LAYOUTS["pit_cover"], 80)
	var rows := 0
	for run in pit_rows:
		rows += run.y - run.x
	check_eq(rows, 80, "a tall pit repeats its stripe rows to its height")
	check_eq((pit_rows[0] as Vector4i).x, 0, "under the top rail")
	check_eq((pit_rows[-1] as Vector4i).y, 36, "and over the bottom rail")
	check_eq((pit_rows[2] as Vector4i).w, 14, "each repeat of the stripes carries the diagonal on")

