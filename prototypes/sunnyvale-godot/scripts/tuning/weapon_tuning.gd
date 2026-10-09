class_name WeaponTuning
extends Resource
## Per-weapon-type tuning seed (M1: W01 Scrapjack only).
## Cadence/damage come from 03-gameplay-systems.md; bolt speed/range are
## chosen here and recorded in 09-progress-and-handoff.md.

@export var weapon_type: String = "W01"
@export var damage: int = 1
@export var base_interval: float = 0.32       ## stage 0, seconds between shots
@export var quickcycle_interval: float = 0.18 ## stage 1 (Quickcycle): 0.24 until C52 (playtest: too small to notice)

## Chosen in M1: fast enough to feel hitscan-adjacent at this course's scale
## (screen width ~13.3 hero-heights) while still being a visible, finite bolt.
@export var bolt_speed: float = 960.0   ## px/s (10H/s)
@export var max_range: float = 640.0    ## px (~6.7H), despawns beyond this

@export var muzzle_flash_time: float = 0.06
@export var recoil_distance: float = 5.0
@export var recoil_recovery_time: float = 0.09


func interval_for_stage(stage: int) -> float:
	return quickcycle_interval if stage >= 1 else base_interval


## Shots per second at `stage` (the workbench shows this, not the interval).
func shots_per_second(stage: int) -> float:
	return 1.0 / interval_for_stage(stage)
