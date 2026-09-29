class_name ClipperTuning
extends Resource
## Clipper (R01) tuning seed. Windup/charge/stall/health come from
## 03-gameplay-systems.md and prototype-spec.json; patrol/acquire/brake
## values are M2 authoring choices (not specified there), recorded here.

@export var windup_time: float = 0.8
@export var charge_speed_h_per_s: float = 5.0    ## grounded charge, in hero-heights/s
@export var charge_max_distance_h: float = 4.0   ## hard cap on one charge
@export var wall_stall_time: float = 1.6         ## rear motor exposed after a wall hit
@export var motor_health: int = 3
@export var damage: int = 1

## Authoring choices (M2, not specified by 03):
@export var patrol_speed: float = 40.0           ## slow idle back-and-forth
@export var acquire_range: float = 640.0         ## line-of-sight acquire distance (px)
@export var floor_band: float = 64.0             ## "same floor band" vertical tolerance
@export var missed_charge_recovery_time: float = 0.6  ## brake -> recovery, no stall
@export var gravity: float = 1800.0
## Frontal (blocked) hits before the one-time motor hint is shown.
@export var frontal_hint_threshold: int = 2

const H := 96.0


func charge_speed() -> float:
	return charge_speed_h_per_s * H


func charge_max_distance() -> float:
	return charge_max_distance_h * H
