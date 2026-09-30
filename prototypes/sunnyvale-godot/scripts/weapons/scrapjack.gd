class_name Scrapjack
extends Node2D
## W01 Scrapjack pistol — the hero's one equipped weapon, mounted on the
## hero's AimPivot (this node's parent). Holding "fire" repeats at the
## interval for the currently earned W01 stage (Session.weapon_stage).
## Infinite shots; no magazine/reload/ammo of any kind.
##
## Visuals only (M6, C11 hand-drawn style per w01-scrapjack-pistol.md): a
## chunky L silhouette — rust-red upper housing bolted to an aged-cream lower
## frame, a dark-steel muzzle ring, a teal-wrapped grip, and three visible
## fastener heads — with the Quickcycle flywheel cover attached flush to the
## left rear housing once earned (Session.weapon_stage). `held` (M6, purely
## cosmetic) switches between the aim-pivot-mounted firing pose and a resting
## ground/pad pose (no recoil/flash, small contact shadow); cadence, damage,
## the muzzle clamp and its ray logic are untouched by any of this.

signal fired

@export var tuning: WeaponTuning
@export var bolt_scene: PackedScene
## M6 (cosmetic only): true while mounted on the hero's AimPivot and fired
## normally; false draws the same weapon resting flat (ground/pad look, per
## 05-content-and-assets.md), with no recoil/flash and a small contact
## shadow. Never read by _try_fire()/cadence/damage/the muzzle-clamp ray.
@export var held: bool = true

@onready var _muzzle: Marker2D = $Muzzle
@onready var _quickcycle: Node2D = $Quickcycle

var _cooldown: float = 0.0
var _recoil_timer: float = 0.0
var _hero: Node = null
var _quickcycle_spin: float = 0.0

const OUTLINE := Color("#332a20")        # warm charcoal (C11 contour)
const UPPER_FILL := Color("#b96b4c")     # rust-red upper housing
const LOWER_FILL := Color("#dcceaf")     # aged-cream lower frame
const STEEL_FILL := Color("#424a4d")     # dark steel (muzzle ring, fasteners)
const GRIP_FILL := Color("#438f88")      # teal wrap
const QUICKCYCLE_FILL := Color("#a9714a")  # copper flywheel cover
const AMBER := Color("#e8b65a")          # amber indicator / muzzle flash

## M6.5 Kenney integration pass (assets/kenney/README.md section 5): a small
## particle-pack burst that augments (never replaces) the drawn amber flash
## in `_draw()` below. No class_name on the puff script (see its own doc
## comment) — reached through this plain preload + its static `spawn()`.
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")

## C35 lit cutouts: each shot also flashes a short, smooth light at the
## muzzle (see `_flash_muzzle_light()`), warm ivory like every muzzle flash in
## the kit, so Dave and anyone near him are lit, through their normal maps,
## from the muzzle's real position and height.
const FLASH_COLOR := Color("#FFE4BD")
const FLASH_TIME := 0.07
const FLASH_ENERGY := 2.4
const FLASH_HEIGHT := 26.0
const FLASH_RADIUS := 140.0


func _ready() -> void:
	if tuning == null:
		tuning = load("res://data/tuning/w01_scrapjack.tres")
	if bolt_scene == null:
		bolt_scene = load("res://scenes/weapons/scrap_bolt.tscn")
	# Fixed scene shape is Hero > AimPivot > Scrapjack; resolved lazily
	# (not here) since child _ready() runs before the Hero's own _ready().


func _physics_process(delta: float) -> void:
	if _quickcycle:
		_quickcycle.visible = _current_stage() >= 1
		# Visible dial spin (w01-scrapjack-pistol.md "spins faster during
		# firing"), purely cosmetic: idle tick plus a burst while recoil is
		# still settling from a shot.
		var spin_rate: float = 1.4 + (9.0 if _recoil_timer > 0.0 else 0.0)
		_quickcycle_spin = wrapf(_quickcycle_spin + spin_rate * delta, 0.0, TAU)
		_quickcycle.rotation = _quickcycle_spin
	# M6 (cosmetic): a resting ground/pad instance (held = false) never reads
	# input or fires — only the hero's own held instance does. Untouched
	# below this guard: cadence/cooldown/recoil timing and the fire path.
	if not held:
		queue_redraw()
		return
	if _hero == null:
		_hero = get_parent().get_parent()  # AimPivot -> Hero
	_cooldown = maxf(0.0, _cooldown - delta)
	_recoil_timer = maxf(0.0, _recoil_timer - delta)

	var input_ok: bool = _hero == null or _hero.input_enabled
	if input_ok and Input.is_action_pressed("fire") and _cooldown <= 0.0:
		_try_fire()
	queue_redraw()


func _current_stage() -> int:
	return Session.weapon_stage(tuning.weapon_type) if Session else 0


## The held instance's small workshop tag (e.g. "P01"), read fresh from
## Session every draw so a pad swap updates it immediately (weapon-swaps.md
## "Distinguish instances by a small workshop tag").
func _current_tag() -> String:
	if Session == null:
		return ""
	var parts := Session.equipped_weapon().split("-")
	return parts[-1] if parts.size() > 0 else ""


## True while the next shot can fire immediately (HUD fire-readiness cue).
func is_ready() -> bool:
	return _cooldown <= 0.0


func _try_fire() -> void:
	_cooldown = tuning.interval_for_stage(_current_stage())
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"pistol_fire_quick" if _current_stage() >= 1 else &"pistol_fire",
				_muzzle.global_position)
	KenneyPuff.spawn(&"muzzle_flash", _muzzle.global_position, _spawn_container())
	_flash_muzzle_light(_muzzle.global_position)

	var pivot: Node2D = get_parent()
	var shoulder: Vector2 = pivot.global_position
	var muzzle_pos: Vector2 = _muzzle.global_position
	var forward: Vector2 = pivot.global_transform.x.normalized()

	# Muzzle clamp: never spawn a bolt behind/inside world collision, and
	# never skip past an enemy HitZone that already lies between the
	# shoulder and the muzzle (ENG-01) — e.g. an enemy the hero is
	# overlapping, since enemies and the hero never body-block each other.
	# Ray from the shoulder to the muzzle tip against world OR hittable; the
	# first thing it finds resolves the shot right there instead of letting
	# ScrapBolt's own sweep start beyond it.
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(shoulder, muzzle_pos)
	params.collision_mask = 1 | 16  # layer1 world | layer5 hittable
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.hit_from_inside = true
	var block := space_state.intersect_ray(params)
	if not block.is_empty():
		var collider = block.get("collider")
		var resolved_hit := false
		if collider is HitZone:
			var outcome: StringName = collider.take_hit(tuning.damage, block.position, forward)
			resolved_hit = outcome == &"hit"
			if resolved_hit and collider.bleeds:
				# Same rule as ScrapBolt: the target shows its own blood and
				# plays its own hit sound, so no spark here.
				return
		var spark := ImpactSpark.new()
		spark.color = ScrapBolt.HIT_COLOR if resolved_hit else ScrapBolt.BLOCK_COLOR
		spark.shape = ImpactSpark.Shape.HIT if resolved_hit else ImpactSpark.Shape.BLOCKED
		spark.global_position = block.position
		_spawn_container().add_child(spark)
		if audio:
			audio.play_sfx(&"bolt_hit" if resolved_hit else &"bolt_blocked", block.position)
		return

	var bolt: ScrapBolt = bolt_scene.instantiate()
	_spawn_container().add_child(bolt)
	bolt.setup(muzzle_pos, forward, tuning)

	_recoil_timer = tuning.recoil_recovery_time
	fired.emit()


func _draw() -> void:
	var settings := get_node_or_null("/root/Settings")
	var motion_scale: float = 0.5 if (settings and settings.get_reduced_motion()) else 1.0

	var kick: float = 0.0
	if held and tuning and tuning.recoil_recovery_time > 0.0:
		kick = -tuning.recoil_distance * motion_scale * (_recoil_timer / tuning.recoil_recovery_time)
	var o := Vector2(kick, 0.0)

	if not held:
		# Ground/pad resting pose: a small flat contact shadow reads as
		# "resting here", never drawn while mounted/firing on the hero.
		draw_set_transform(o + Vector2(6, 11), 0.0, Vector2(1.6, 0.4))
		draw_circle(Vector2.ZERO, 10.0, Color(0.0, 0.0, 0.0, 0.22))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Chunky L silhouette (w01-scrapjack-pistol.md): rust-red upper housing
	# bolted to an aged-cream lower frame, three visible fastener heads, a
	# recessed side feed window, a dark-steel muzzle ring with a thick inner
	# ring, and a teal-wrapped grip. Overall footprint (x -9..27.5, y -9..8)
	# matches the earlier blockout exactly, kept close to AimPivot (this
	# node's parent) so its full rotated reach — however the hero is aiming —
	# never sweeps back far enough from AimPivot (hero.tscn, well below the
	# head) to cross the head circle (R1-01: was clipping across the face at
	# up-angled and even neutral aim).
	var housing := Rect2(o + Vector2(-5, -8), Vector2(26, 16))
	draw_rect(Rect2(o + Vector2(-5, 0), Vector2(26, 8)), LOWER_FILL)    # lower cream frame
	draw_rect(Rect2(o + Vector2(-5, -8), Vector2(26, 8)), UPPER_FILL)   # upper rust-red housing
	draw_rect(Rect2(o + Vector2(6, -4), Vector2(8, 6)), STEEL_FILL)     # recessed side feed window
	for i in 3:
		draw_circle(o + Vector2(-2, -6 + i * 6), 1.3, STEEL_FILL)       # 3 fastener heads
	draw_rect(Rect2(o + Vector2(-8, -9), Vector2(5, 6)), GRIP_FILL)     # teal-wrapped grip
	draw_circle(o + Vector2(22, 0), 5.5, STEEL_FILL)                    # muzzle ring
	draw_circle(o + Vector2(22, 0), 2.6, OUTLINE)                       # thick dark inner ring
	draw_rect(housing, OUTLINE, false, 2.0)
	draw_rect(Rect2(o + Vector2(-8, -9), Vector2(5, 6)), OUTLINE, false, 1.5)
	draw_circle(o + Vector2(22, 0), 5.5, OUTLINE, false, 2.0)

	if held and _recoil_timer > 0.0 and tuning and tuning.recoil_recovery_time > 0.0:
		var flash_k: float = _recoil_timer / tuning.recoil_recovery_time
		draw_circle(o + Vector2(28, 0), (2.5 + 2.5 * flash_k) * motion_scale, AMBER)  # small muzzle flash

	# AD-07 fix: this used to draw unconditionally, which put the tag on the
	# hero's chest in every gameplay frame (held is true for the one instance
	# actually mounted on the hero) — it duplicated the HUD's own weapon tag
	# and read as a stray label on the character. "Distinguish instances by a
	# small workshop tag" (weapon-swaps.md) only matters for a RESTING
	# instance (ground/pad) where more than one tag could be on screen; the
	# held gun's tag is already covered by the HUD.
	var tag := _current_tag()
	if not held and tag != "":
		var font := ThemeDB.fallback_font
		# M6 integration fix: when held (mounted on the hero's AimPivot),
		# this node inherits AimPivot's own rotation + facing-flip
		# (hero.gd `_update_aim_pivot()`, unchanged) so the housing can point
		# any direction. Left unchecked, that same transform mirrors/rotates
		# this draw_string call too — readable while aiming right, garbled
		# (reversed glyphs) while aiming left/up/down. Counter it for the tag
		# ONLY (never the housing/flash/shadow above, which are meant to
		# rotate with the weapon): draw at a fixed global position with zero
		# rotation/scale by feeding draw_set_transform_matrix() the inverse of
		# this node's own accumulated global transform composed with the
		# desired upright placement.
		var desired_global: Vector2 = global_transform * (o + Vector2(-8, -12))
		draw_set_transform_matrix(global_transform.affine_inverse() * Transform2D(0.0, desired_global))
		draw_string(font, Vector2.ZERO, tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#efe0be"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func get_muzzle_global_position() -> Vector2:
	return _muzzle.global_position


## A brief smooth point light at the muzzle. It lives under the same
## container as the bolts and sparks (not under this weapon), so it outlives a
## freed gun and is freed with the scene; it fades over FLASH_TIME and frees
## itself. It never moves, so it is drawn uninterpolated. Halved under
## reduced motion, like the drawn flash.
func _flash_muzzle_light(at: Vector2) -> void:
	var settings := get_node_or_null("/root/Settings")
	var k: float = 0.5 if (settings and settings.get_reduced_motion()) else 1.0
	var light := SceneryDraw.make_light(_spawn_container(), SceneryDraw.smooth_disc_texture(),
			Vector2.ZERO, FLASH_RADIUS, FLASH_COLOR, FLASH_ENERGY * k, FLASH_HEIGHT)
	light.name = "MuzzleFlashLight"
	light.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	light.global_position = at
	var tween := light.create_tween()
	tween.tween_property(light, "energy", 0.0, FLASH_TIME)
	tween.tween_callback(light.queue_free)


## Parent for spawned bolts/sparks (ENG-05): the current scene when one is
## loaded, so a level rebuild (Session.restore_committed() then the level
## re-instanced, per CONVENTIONS) frees them along with everything else,
## instead of leaving them parented under the tree root where they'd outlive
## the rollback and keep sweeping stale coordinates. Falls back to root for
## isolated test/demo scenes run directly with `-s`, which never set a
## current_scene.
func _spawn_container() -> Node:
	var scene := get_tree().current_scene
	return scene if scene != null else get_tree().root
