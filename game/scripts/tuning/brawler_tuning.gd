class_name BrawlerTuning
extends Resource
## Brawler template tuning (C26): the melee walker shared by the SE01 Night
## Guard and the LK01 Staffer. The template's loop is the same for both —
## patrol or stand dormant, notice, walk in, wind up (the tell glows amber,
## then red for the last `red_time`), one committed strike, a recovery that
## is the punish window — and everything that makes one of them a guard with
## a baton and the other a Linked worker with a grab lives here, as data.
## Health/speed/timing seeds come from the roster (P23) and the old Staffer
## (03-gameplay-systems.md); the rest are authoring choices.

enum Strike { SWING, LUNGE }

@export var health: int = 3
@export var damage: int = 1
## Walking at the hero once noticed, in hero-heights/s.
@export var approach_speed_h_per_s: float = 0.8
## Walking a beat before noticing, in hero-heights/s (0 = stands still).
@export var patrol_speed_h_per_s: float = 0.0
## How far (px, same floor band) the hero is noticed from.
@export var notice_range: float = 520.0
## How close (px, same floor band) the hero must be before the windup.
@export var engage_range: float = 108.0
## Vertical band (px) considered "the same floor" for noticing/engaging.
@export var floor_band: float = 64.0
@export var gravity: float = 1800.0

@export var windup_time: float = 0.65
## The last part of the windup, when the tell turns from amber to red.
@export var red_time: float = 0.25
## SWING: a short step-in strike with a tall attack box (a baton).
## LUNGE: a long, fast, low committed lunge (a grab).
@export var strike: Strike = Strike.LUNGE
@export var lunge_distance_h: float = 1.2
@export var lunge_time: float = 0.30
## SWING only: how long the strike lasts, when its box is live, and how fast
## it steps in.
@export var swing_time: float = 0.22
@export var swing_active_from: float = 0.07
@export var swing_active_to: float = 0.2
@export var swing_step_speed: float = 60.0
@export var recovery_time: float = 0.80
## A lunge chain (the K01 Hound's double lunge, M4): after each lunge but the last it
## crouches again for `relunge_time`, its own amber-then-red blip (red for the last
## red_time), turning to face Dave through the amber part, then lunges again. 1 = the
## single strike every Level 1 brawler has.
@export var lunge_count: int = 1
@export var relunge_time: float = 0.5
## A K9 and its handler (M4, the fairness rules' "a handler starts 1.5 seconds after the
## chain"): the handler's windup waits until `handler_delay` after this brawler's lunge
## chain ends, and this brawler waits `handled_rest_time` after its chain (its recovery
## included) before another, so the handler gets his turn. Read from the K9's tuning.
@export var handler_delay: float = 1.5
@export var handled_rest_time: float = 3.2
## Attack box (px): size, and the centre's offset (x toward facing, y up).
@export var attack_box_size: Vector2 = Vector2(56.0, 60.0)
@export var attack_box_offset: Vector2 = Vector2(38.0, -46.0)
## Starts dormant (a still, bowed pose, a dim standby light) until its
## encounter activates — the Staffers in their doorways.
@export var dormant_until_active: bool = false

## The body's half width and height (px), for the floor and wall probes and the warning
## cue (a person: 11 x 94; the Hound is long and low).
@export var body_half_width: float = 11.0
@export var body_height: float = 94.0

@export_group("Presentation")
@export_file("*.json") var rig_path: String = ""
## Script with a `CLIPS` const (scripts/actors/lit/clips_*.gd) and the names
## this brawler plays for each state.
@export_file("*.gd") var clips_script: String = ""
@export var clip_idle: String = "idle"
@export var clip_walk: String = "walk"
@export var clip_stalk: String = "stalk"
@export var clip_windup: String = "windup"
@export var clip_strike: String = "swing"
@export var clip_recover: String = "recover"
## A flinch played when a shot lands outside the windup and swing ("" = the
## procedural jolt only). While walking he also stops for hit_stagger_time,
## at most once every hit_stagger_cooldown, so rapid fire can't pin him.
@export var clip_hit: String = ""
@export var hit_stagger_time: float = 0.4
@export var hit_stagger_cooldown: float = 1.5
## Joint the tell light hangs from, and where on it (joint-local px).
@export var tell_joint: String = "baton"
@export var tell_offset: Vector2 = Vector2(0.0, 25.5)
## Enemy look variants (C56): rig.json paths sharing one skeleton and clips; each enemy draws
## the one its entity id picks (rig_path when the list is empty). Looks only: stats, clips and
## timings are the tuning's.
@export var rig_variants: PackedStringArray = []
## The tell light's size (its texture_scale) and its peak energy at the end of the windup.
## Small for a body close to the light (the Hound's jaw would wash its whole head red).
@export var tell_light_scale: float = 1.1
@export var tell_light_energy: float = 1.6
## True if the tell joint's own painted emissive spot (the baton tip) glows
## with the tell colour too.
@export var tell_emissive: bool = true
## Hands that also get a tell glow sprite (the Staffer's grab).
@export var tell_hand_glow: bool = false
## A small steady driven light on the body (the Staffer's Link port):
## joint, joint-local point and the light's energy.
@export var link_joint: String = ""
@export var link_offset: Vector2 = Vector2.ZERO
## The hit jolt: joint -> radians, signed away from the shot (empty = a person's).
@export var hit_jolt: Dictionary = {}
## Parts that twitch after death (the Hound's legs), and for how long.
@export var death_twitch_joints: PackedStringArray = []
@export var death_twitch_time: float = 1.0
@export var voice_notice: PackedStringArray = []
@export var voice_windup: PackedStringArray = []
@export var voice_hurt: PackedStringArray = []
@export var sfx_windup: StringName = &""
@export var sfx_strike: StringName = &""
@export var sfx_defeat: StringName = &""

const H := 96.0


func approach_speed() -> float:
	return approach_speed_h_per_s * H


func patrol_speed() -> float:
	return patrol_speed_h_per_s * H


func lunge_distance() -> float:
	return lunge_distance_h * H


func lunge_speed() -> float:
	return lunge_distance() / lunge_time
