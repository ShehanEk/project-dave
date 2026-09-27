class_name ResidentTuning
extends Resource
## Resident (Z01) tuning seed. Health/speed/timings come from
## 03-gameplay-systems.md and prototype-spec.json; gravity is an M2 authoring
## choice (not specified there) matching a simple grounded walker.

@export var health: int = 3
@export var approach_speed_h_per_s: float = 0.8   ## slow approach, in hero-heights/s
@export var windup_time: float = 0.65             ## visible lean + raised hands
@export var lunge_distance_h: float = 1.2         ## short committed lunge, in H
@export var lunge_time: float = 0.30
@export var recovery_time: float = 0.80
@export var damage: int = 1

## Chosen in M2: how close (px) the hero must be, on the same floor band,
## before a lunge is requested. Comfortably inside the lunge's own reach
## (lunge_distance_h * H) so the attack can actually land.
@export var engage_range: float = 108.0
## Vertical band (px) considered "the same floor" for engagement.
@export var floor_band: float = 64.0
## Authoring choice: grounded-walker gravity (not specified by 03).
@export var gravity: float = 1800.0

const H := 96.0


func approach_speed() -> float:
	return approach_speed_h_per_s * H


func lunge_distance() -> float:
	return lunge_distance_h * H


func lunge_speed() -> float:
	return lunge_distance() / lunge_time
