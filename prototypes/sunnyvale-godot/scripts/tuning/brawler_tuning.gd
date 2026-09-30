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
## Attack box (px): size, and the centre's offset (x toward facing, y up).
@export var attack_box_size: Vector2 = Vector2(56.0, 60.0)
@export var attack_box_offset: Vector2 = Vector2(38.0, -46.0)
## Starts dormant (a still, bowed pose, a dim standby light) until its
## encounter activates — the Staffers in their doorways.
@export var dormant_until_active: bool = false

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
## Joint the tell light hangs from, and where on it (joint-local px).
@export var tell_joint: String = "baton"
@export var tell_offset: Vector2 = Vector2(0.0, 25.5)
## True if the tell joint's own painted emissive spot (the baton tip) glows
## with the tell colour too.
@export var tell_emissive: bool = true
## Hands that also get a tell glow sprite (the Staffer's grab).
@export var tell_hand_glow: bool = false
## A small steady driven light on the body (the Staffer's Link port):
## joint, joint-local point and the light's energy.
@export var link_joint: String = ""
@export var link_offset: Vector2 = Vector2.ZERO
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
