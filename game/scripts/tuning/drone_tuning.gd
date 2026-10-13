class_name DroneTuning
extends Resource
## Drone template tuning (C26, M4): the flying diver, first the M02 Security Drone. The
## loop: hover a patrol span at its set height -> notice Dave below (it is entirely
## mechanical: no bark until the tell) -> (attack token) the tell: it noses up and stops
## almost still while the lightbar goes amber, then red for the last `red_time`, the aim
## following Dave's last grounded spot and locking at red -> a straight, committed dive
## at the locked spot -> it hangs at head height (the punish window) -> climbs back ->
## rests -> again. Numbers: the brief's (2 hits; the hang at head height) and authoring
## choices recorded here (P23 has no drone numbers beyond the tell rule).

@export var health: int = 2
@export var damage: int = 1
## Drifting along its span, in hero-heights/s, with a slight bob (px).
@export var patrol_speed_h_per_s: float = 0.9
@export var bob_px: float = 3.0
## Without patrol bounds, it hovers this far either side of where it was placed (px).
@export var patrol_half_span: float = 160.0
## Dave is noticed within this distance sideways, and this far below its hover height (px).
@export var notice_range: float = 520.0
@export var notice_below: float = 480.0
@export var windup_time: float = 1.0
@export var red_time: float = 0.25
## The aim follows Dave's last grounded spot this fast through the amber part (H/s,
## slower than Dave's 4, no lead), and locks at red.
@export var aim_track_speed_h_per_s: float = 3.0
## The dive: a straight line at this speed, at most this long (hero-heights).
@export var dive_speed_h_per_s: float = 7.0
@export var dive_max_h: float = 6.5
## Where the dive ends: its body's centre this high above Dave's locked grounded spot
## (head height, hero-heights).
@export var hang_height_h: float = 0.85
## The punish window at head height, fans spooling down and the fork spent.
@export var hang_time: float = 1.6
@export var climb_speed_h_per_s: float = 2.4
## After climbing back, before the next tell may start.
@export var rest_time: float = 1.0
## The readability gate (P23): it starts a tell only at least this far inside the view.
@export var camera_margin_h: float = 1.0
## Pitch in the tell (nose up, negative) and in the dive (nose down), degrees.
@export var tell_pitch_deg: float = -16.0
@export var dive_pitch_deg: float = 26.0
## The fork's swing (degrees) from folded to the dive.
@export var fork_dive_deg: float = -150.0
@export_file("*.json") var rig_path: String = "res://assets/characters/lit/security_drone/rig.json"
## Look variants (C56: Arcadia white, Garden-built): rig.json paths sharing one layout and
## roles; each drone draws the one its entity id picks.
@export var rig_variants: PackedStringArray = []
## Its announcement in the tell (every other tell), and the cues.
@export var voice_tell: PackedStringArray = []
@export var sfx_tell: StringName = &""
@export var sfx_dive: StringName = &""
@export var sfx_hit: StringName = &""
@export var sfx_destroyed: StringName = &""

const H := 96.0


func patrol_speed() -> float:
	return patrol_speed_h_per_s * H


func aim_track_speed() -> float:
	return aim_track_speed_h_per_s * H


func dive_speed() -> float:
	return dive_speed_h_per_s * H


func dive_max() -> float:
	return dive_max_h * H


func hang_height() -> float:
	return hang_height_h * H


func climb_speed() -> float:
	return climb_speed_h_per_s * H
