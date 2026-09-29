extends Node2D
## Tiny reusable one-shot particle puff (M6.5 Kenney integration pass —
## assets/kenney/README.md section 5, `particle-pack` Transparent variant).
## Purely cosmetic, self-freeing, never read by gameplay/physics: muzzle
## flash, hero landing dust, chip/checkpoint sparkle, staffer defeat puff,
## pit-fall dust all go through the single `spawn()` factory below instead of
## each call site hand-rolling its own CPUParticles2D.
##
## No `class_name` (M6-style scripts added mid this workflow phase — the
## import cache is not refreshed until `tools/test.sh` next runs without
## NOIMPORT=1 — see hero_visual.gd's own note on the same rule): every call
## site reaches this through a plain `preload()` constant and the static
## `spawn()` function, never static typing against a class name.
##
## Kept short (<=0.5s) and low alpha throughout (style guide C11: "effects
## carry little style, so they blend in" — never a shape that competes with
## feet, edges, chips, or attack warnings) and respects
## `Settings.reduced_motion` the same way scripts/effects/impact_spark.gd
## does: fewer particles and less travel distance, never fully hidden.

const TEX_MUZZLE := preload("res://assets/kenney/particle-pack/muzzle_02.png")
const TEX_DIRT_SMALL := preload("res://assets/kenney/particle-pack/dirt_01.png")
const TEX_DIRT_BIG := preload("res://assets/kenney/particle-pack/dirt_03.png")
const TEX_STAR := preload("res://assets/kenney/particle-pack/star_04.png")
const TEX_STAR_SOFT := preload("res://assets/kenney/particle-pack/star_05.png")
const TEX_SMOKE := preload("res://assets/kenney/particle-pack/smoke_02.png")
## M7 Kenney part B: the three candidates staged (not wired) by the earlier
## Kenney pass — assets/kenney/README.md "Staged for the LATER Clipper pass".
## `star_01`/`star_02` are a `particle-pack` cutout kept in its own folder
## because they're used at a different (Clipper-specific) scale/tint than
## `TEX_STAR`/`TEX_STAR_SOFT` above; `whitePuff00` is from `smoke-particles`.
const TEX_CLIPPER_SPARK := preload("res://assets/kenney/particles/clipper_later/star_01_metal_spark.png")
const TEX_CLIPPER_STEAM := preload("res://assets/kenney/particles/clipper_later/whitePuff00_stall_steam.png")

# Sunnyvale palette (CONVENTIONS.md / art-design/style-guide.md C11).
const CREAM := Color("#D8E2EC")  # night pass: cool white
const PEACH := Color("#E07A3F")  # night pass: Dave orange
const GOLD := Color("#FFD166")  # microchip gold
const TEAL_GLOW := Color("#3FE0D0")  # Arcadia/Adam teal
const CHARCOAL := Color("#07090F")
const AMBER := Color("#FFB02E")
## Warm white/amber for the Clipper's metallic deflection spark (task brief:
## "palette-tinted (warm white/amber)") — a touch paler than plain AMBER so it
## reads as a bright momentary flash, not the same tone as the STALL glow.
const WARM_SPARK := Color("#f4d9a0")

## One flat recipe table so every call site just names a `kind` — never
## hand-tunes CPUParticles2D fields itself. `speed_min/max` are px/s,
## `scale_min/max` are CPUParticles2D `scale_amount` (this texture is a
## 512x512 source, so these read as roughly 25-130px on screen), `gravity`
## is px/s^2 (a small negative y drifts a puff gently upward instead of
## falling, per particle).
const CONFIGS := {
	&"muzzle_flash": {
		"texture": TEX_MUZZLE, "color": AMBER, "amount": 5, "lifetime": 0.10,
		"spread": 16.0, "speed_min": 60.0, "speed_max": 120.0,
		"scale_min": 0.10, "scale_max": 0.16, "gravity": Vector2.ZERO, "alpha": 0.85,
	},
	&"landing_dust": {
		"texture": TEX_DIRT_SMALL, "color": CREAM, "amount": 5, "lifetime": 0.30,
		"spread": 50.0, "speed_min": 20.0, "speed_max": 55.0,
		"scale_min": 0.10, "scale_max": 0.16, "gravity": Vector2(0.0, 120.0), "alpha": 0.5,
	},
	&"pit_dust": {
		"texture": TEX_DIRT_BIG, "color": PEACH, "amount": 9, "lifetime": 0.40,
		"spread": 70.0, "speed_min": 30.0, "speed_max": 90.0,
		"scale_min": 0.14, "scale_max": 0.22, "gravity": Vector2(0.0, 160.0), "alpha": 0.55,
	},
	# scale_min/max bumped ~2.7x over the initial pass (0.08-0.13 etc.): at
	# real gameplay camera scale (zoom 1.0) the original values rendered as
	# only a handful of near-invisible pixels once `star_04`/`star_05`'s own
	# low peak alpha (~223/255 and ~213/255 of a 512px source) was factored
	# in — confirmed by pixel-sampling a capture at the real camera distance,
	# not just an isolated close-up. These larger sizes plus a higher `alpha`
	# keep the sparkle short-lived (life unchanged) but actually legible
	# during play, while staying well short of `dirt_03`'s (pit dust) footprint.
	&"chip_sparkle": {
		"texture": TEX_STAR, "color": GOLD, "amount": 6, "lifetime": 0.35,
		"spread": 180.0, "speed_min": 20.0, "speed_max": 50.0,
		"scale_min": 0.22, "scale_max": 0.34, "gravity": Vector2(0.0, -20.0), "alpha": 0.95,
	},
	&"chip_sparkle_cluster": {
		"texture": TEX_STAR, "color": GOLD, "amount": 12, "lifetime": 0.40,
		"spread": 180.0, "speed_min": 25.0, "speed_max": 65.0,
		"scale_min": 0.27, "scale_max": 0.42, "gravity": Vector2(0.0, -20.0), "alpha": 0.95,
	},
	&"checkpoint_sparkle": {
		"texture": TEX_STAR_SOFT, "color": TEAL_GLOW, "amount": 8, "lifetime": 0.50,
		"spread": 180.0, "speed_min": 10.0, "speed_max": 35.0,
		"scale_min": 0.30, "scale_max": 0.44, "gravity": Vector2(0.0, -15.0), "alpha": 0.95,
	},
	&"defeat_puff": {
		"texture": TEX_SMOKE, "color": Color(0.55, 0.5, 0.45, 1.0), "amount": 6, "lifetime": 0.45,
		"spread": 40.0, "speed_min": 10.0, "speed_max": 30.0,
		"scale_min": 0.16, "scale_max": 0.26, "gravity": Vector2(0.0, -25.0), "alpha": 0.5,
	},
	# --- M7 Kenney part B: R01 Clipper readability (frontal clang + defeat) ---
	# Short (<=0.3s per the task brief) metallic burst at the exact impact
	# point, ADDITIVE to clipper.gd's own hand-drawn spark/chevron (the shape
	# cue) and clipper_visual.gd's shield-flash — never a replacement for
	# either, since those two are what actually reads as "armored" at a
	# glance; this is the extra material-feel polish on top. `max_concurrent`
	# (checked by spawn() below) is what keeps rapid fire from flooding the
	# screen with overlapping bursts.
	&"clipper_spark": {
		"texture": TEX_CLIPPER_SPARK, "color": WARM_SPARK, "amount": 5, "lifetime": 0.18,
		"spread": 180.0, "speed_min": 70.0, "speed_max": 150.0,
		"scale_min": 0.12, "scale_max": 0.20, "gravity": Vector2.ZERO, "alpha": 0.95,
		"max_concurrent": 3,
	},
	# Clipper defeat (task brief: "a small smoke puff + a few spark bits"),
	# both one-shot and fired together only once, from `clipper.gd::_defeat()`.
	&"clipper_defeat_smoke": {
		"texture": TEX_CLIPPER_STEAM, "color": CREAM, "amount": 4, "lifetime": 0.4,
		"spread": 50.0, "speed_min": 10.0, "speed_max": 30.0,
		"scale_min": 0.20, "scale_max": 0.30, "gravity": Vector2(0.0, -30.0), "alpha": 0.6,
	},
	&"clipper_defeat_spark": {
		"texture": TEX_CLIPPER_SPARK, "color": WARM_SPARK, "amount": 6, "lifetime": 0.25,
		"spread": 180.0, "speed_min": 40.0, "speed_max": 110.0,
		"scale_min": 0.12, "scale_max": 0.18, "gravity": Vector2(0.0, 60.0), "alpha": 0.9,
	},
}

## Live count of not-yet-freed instances per `kind`, only tracked for kinds
## whose CONFIGS entry sets `max_concurrent` (every other kind is uncapped, as
## before). This is what stops rapid Clipper fire from flooding the screen
## with overlapping spark bursts (task brief: "capped count so rapid fire
## doesn't flood the screen") without touching `bolt_blocked` audio or the
## shape-based cues in clipper.gd/clipper_visual.gd, which never rate-limit.
static var _active_counts: Dictionary = {}

var _life: float = 0.4
var _t: float = 0.0
## Set by spawn() only for a kind whose CONFIGS entry has `max_concurrent`, so
## `_exit_tree()` knows which counter to decrement; "" for every uncapped kind.
var _counted_kind: StringName = &""
## The CONFIGS key this instance was configured with (every spawn() call sets
## it, capped or not) — purely informational, never read by gameplay/physics;
## lets a caller (or a test) identify which effect a given child node is
## without guessing from its texture. See `_configure()` below.
var effect_kind: StringName = &""
@onready var _particles: CPUParticles2D = $Particles


func _ready() -> void:
	set_process(false)


## Instances one puff under `host` at `at` (global position) and configures
## it for `kind`. A no-op for an unknown kind, a null host, or (for a capped
## kind — see `_active_counts` above) when that many are already live (never
## crashes a call site over a typo, same defensive shape as Audio.play_sfx's
## own unknown-cue handling — though every kind here is used by exactly one
## owner script, so a typo would be caught immediately by NOIMPORT=1
## tools/test.sh's spawn-50-effects case).
static func spawn(kind: StringName, at: Vector2, host: Node) -> void:
	if host == null or not is_instance_valid(host) or not CONFIGS.has(kind):
		return
	var cfg: Dictionary = CONFIGS[kind]
	var cap: int = cfg.get("max_concurrent", -1)
	var counted_kind: StringName = &""
	if cap >= 0:
		var live: int = _active_counts.get(kind, 0)
		if live >= cap:
			return
		_active_counts[kind] = live + 1
		counted_kind = kind
	var scene: PackedScene = load("res://scenes/effects/kenney_puff.tscn")
	var fx: Node2D = scene.instantiate()
	host.add_child(fx)
	fx.global_position = at
	fx._counted_kind = counted_kind
	fx._configure(kind)


func _exit_tree() -> void:
	if _counted_kind != &"" and _active_counts.has(_counted_kind):
		_active_counts[_counted_kind] = maxi(0, _active_counts[_counted_kind] - 1)


func _configure(kind: StringName) -> void:
	effect_kind = kind
	var cfg: Dictionary = CONFIGS[kind]
	var settings := get_node_or_null("/root/Settings")
	var reduced: bool = settings != null and settings.get_reduced_motion()
	var amount: int = cfg["amount"]
	var speed_scale: float = 1.0
	if reduced:
		amount = maxi(2, int(ceil(amount * 0.5)))
		speed_scale = 0.5
	_particles.texture = cfg["texture"]
	_particles.amount = amount
	_particles.lifetime = cfg["lifetime"]
	_particles.one_shot = true
	_particles.explosiveness = 1.0
	_particles.spread = cfg["spread"]
	_particles.initial_velocity_min = cfg["speed_min"] * speed_scale
	_particles.initial_velocity_max = cfg["speed_max"] * speed_scale
	_particles.gravity = cfg["gravity"]
	_particles.scale_amount_min = cfg["scale_min"]
	_particles.scale_amount_max = cfg["scale_max"]
	var col: Color = cfg["color"]
	col.a = cfg["alpha"]
	_particles.color = col
	_particles.emitting = true
	_life = cfg["lifetime"] * 1.4 + 0.15
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
	if _t >= _life:
		queue_free()
