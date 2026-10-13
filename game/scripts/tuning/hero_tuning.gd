class_name HeroTuning
extends Resource
## Hero movement/combat tuning seed (M1). Values come from
## prototype-spec.json / 03-gameplay-systems.md. Gravity and jump takeoff
## velocity are DERIVED from apex height + time-to-apex, never hand-tuned
## separately, so the two numbers can't drift apart.

@export var height_px: float = 96.0
@export var run_speed: float = 384.0  ## px/s, 4H/s

## Apex height as a multiple of hero height (1.6H).
@export var jump_apex_h: float = 1.6
## Seconds from takeoff to apex; with jump_apex_h this derives gravity/velocity.
@export var jump_time_to_apex: float = 0.42

@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.12

## Early jump-release cuts the rise: remaining upward velocity is multiplied
## by this factor the instant "jump" is released while still ascending.
@export var jump_cut_multiplier: float = 0.45

@export var ground_acceleration: float = 3600.0  ## px/s^2 while grounded
@export var ground_deceleration: float = 4200.0  ## px/s^2 braking/turning, grounded
@export var air_acceleration: float = 2200.0     ## px/s^2 while airborne
@export var air_deceleration: float = 1400.0     ## px/s^2 braking/turning, airborne

## Extra multiplier on gravity once falling (snappier descent), matches most
## platformer feel guides; 1.0 disables it.
@export var fall_gravity_multiplier: float = 1.35

@export var damage_immunity_time: float = 1.0
@export var knockback_speed: float = 220.0     ## horizontal, away from source
@export var knockback_up_speed: float = 170.0  ## small upward pop


func jump_apex_px() -> float:
	return jump_apex_h * height_px


## Derived: gravity = 2h / t^2 (px/s^2, positive magnitude; apply as +y).
func gravity() -> float:
	var t := jump_time_to_apex
	return 2.0 * jump_apex_px() / (t * t)


## Derived: takeoff speed = 2h / t (px/s, magnitude; apply as -y velocity).
func jump_velocity() -> float:
	var t := jump_time_to_apex
	return 2.0 * jump_apex_px() / t


func fall_gravity() -> float:
	return gravity() * fall_gravity_multiplier
