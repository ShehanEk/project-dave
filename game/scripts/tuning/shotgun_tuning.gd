class_name ShotgunTuning
extends WeaponTuning
## W02 Boom Broom tuning seed (M3): data/tuning/w02_boom_broom.tres. The brief
## (art-design/weapons/w02-boom-broom.md) and the resource table
## (design/03-progression/ammunition-and-resupply.md) give: a wide scrap-pellet blast,
## strong close damage that falls off with range, knockback on small enemies and a
## stagger on large ones, a pump between shots ("a deliberate recovery gap"), 4 loaded
## shells and up to 24 in reserve, shells fed one at a time at about 0.7 s each (a
## reload can stop to fire), and three upgrades: Extended Tube (4 -> 6 shells),
## Incendiary Shells (burning damage over time) and Twin Shell (an optional two-shell
## blast with more damage and knockback and a longer recovery). Every number not in
## those two documents is PROPOSED here and untested (marked "proposed").
##
## Damage. HitZone takes whole numbers, so a blast adds up its pellets' damage per
## target (pellet_damage x falloff(distance) for each pellet that reaches it) and the
## target takes that sum rounded, at least 1. Enemies have 2-3 health and a Scrapjack
## bolt does 1, so a point-blank blast (6 x 0.75 = 4.5 -> 5) drops any of them, while
## at falloff_end it is down to a pellet or two (1).

## Pellets per blast (proposed).
@export var pellet_count: int = 6
## The whole cone, edge to edge, degrees (proposed): about 1.5 H wide at 4 H.
@export var spread_degrees: float = 22.0
## Random turn added to each evenly spaced pellet, degrees, kept inside the cone (proposed).
@export var pellet_jitter_degrees: float = 1.5
## One pellet's damage at point blank, before falloff (proposed).
@export var pellet_damage: float = 0.75
## Falloff (proposed): full damage to falloff_start px, then linear down to falloff_min
## of it at falloff_end px; a pellet stops at max_range (WeaponTuning) px.
@export var falloff_start: float = 120.0
@export var falloff_end: float = 360.0
@export var falloff_min: float = 0.25

@export_group("Knockback")
## A blast's push on the enemy body, px/s, scaled by the share of pellets that hit it and
## their falloff (proposed); it decays at knockback_decay px/s^2 (about 55 px all told).
@export var knockback_speed: float = 420.0
@export var knockback_decay: float = 1600.0
## Large enemies stagger rather than fly (the brief): their share of the push (proposed).
@export var heavy_knockback_scale: float = 0.25
## Light flyers (the Security Drone) are thrown further (proposed).
@export var light_knockback_scale: float = 1.25

@export_group("Pump and shells")
## Seconds from a blast to the next possible blast: the pump (proposed).
@export var pump_time: float = 0.62
## The pump's stroke within pump_time (proposed): back at pump_back_at, the spent shell
## ejected at eject_at, forward again at pump_forward_at.
@export var pump_back_at: float = 0.1
@export var eject_at: float = 0.22
@export var pump_forward_at: float = 0.4
## How far the pump slides back, world px (proposed).
@export var pump_travel: float = 5.0
## Loaded shells (the brief: 4; Extended Tube: 6) and the reserve (S02: up to 24).
@export var tube_capacity: int = 4
@export var extended_tube_capacity: int = 6
@export var reserve_capacity: int = 24
## One shell fed into the tube (S02: about 0.7 s). The reload starts on its own once the
## tube is empty, or after reload_delay s without firing while a shell is missing
## (proposed: there is no reload key yet); firing stops it, keeping the shells already in.
@export var shell_insert_time: float = 0.7
@export var reload_delay: float = 0.45

@export_group("Upgrades")
## Incendiary Shells (stage 2, proposed): a hit sets the target burning for burn_ticks
## ticks of burn_damage, one every burn_interval s.
@export var burn_damage: int = 1
@export var burn_ticks: int = 2
@export var burn_interval: float = 0.8
## Twin Shell (stage 3, proposed): spends exactly 2 shells (S02), more pellets, more push,
## a longer recovery.
@export var twin_pellet_count: int = 10
@export var twin_spread_degrees: float = 26.0
@export var twin_knockback_scale: float = 1.6
@export var twin_recovery_time: float = 1.1

@export_group("Feel")
## Recoil lifts the muzzle (the brief: "a solid shoulder kick"), degrees, settling over
## recoil_recovery_time (WeaponTuning) (proposed).
@export var muzzle_lift_degrees: float = 9.0
## The muzzle flash strip's size against the Scrapjack's, and the flash light (proposed).
@export var muzzle_flash_scale: float = 1.9
@export var flash_energy: float = 3.4
@export var flash_radius: float = 220.0
## Pellet streaks: how long one shows, s (proposed).
@export var pellet_trail_time: float = 0.09

@export_group("Sounds")
## Placeholder cues (existing Audio cues) until the Boom Broom's own sounds exist.
@export var sfx_fire: StringName = &"rover_destroyed"
@export var sfx_pump: StringName = &"latch"
@export var sfx_shell_in: StringName = &"ready_click"
@export var sfx_shell_drop: StringName = &"debris_clatter"
@export var sfx_empty: StringName = &"keycard_denied"


## The pump is the Boom Broom's firing interval (stages never change it; Twin Shell has
## its own longer recovery).
func interval_for_stage(_stage: int) -> float:
	return pump_time


## Shells the tube holds at `stage`: Extended Tube (stage 1 and up) raises it.
func capacity_for_stage(stage: int) -> int:
	return extended_tube_capacity if stage >= 1 else tube_capacity


## One pellet's damage share at `distance` px from the muzzle: 1 to falloff_start, down to
## falloff_min at falloff_end and beyond (0 past max_range, where a pellet stops).
func falloff(distance: float) -> float:
	if distance > max_range:
		return 0.0
	if distance <= falloff_start:
		return 1.0
	var t := clampf((distance - falloff_start) / maxf(falloff_end - falloff_start, 0.001), 0.0, 1.0)
	return lerpf(1.0, falloff_min, t)


## The whole damage a target takes from the pellets that reached it: their summed
## damage shares, rounded, at least 1 when any pellet reached it.
func blast_damage(shares: float) -> int:
	if shares <= 0.0:
		return 0
	return maxi(1, roundi(shares))
