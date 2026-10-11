class_name ArmorHitZone
extends HitZone
## An armored front (the Patrol Rover's padded bumper and shell): always
## blocks (per CONVENTIONS.md HitZone contract, unchanged) but also reports
## each blocked hit so the owner can count "ineffective" shots and show its
## one-time hint.
## `blocked_hit` carries the impact position (world space) so the owner can
## place its "armored" deflection feedback (M7 readability pass) right where
## the shot actually landed — existing listeners that take no arguments
## (e.g. a bare `func(): ...` lambda) still work: Godot drops the extra
## argument for them.

signal blocked_hit(hit_position: Vector2)


func take_hit(damage: int, hit_position: Vector2, direction: Vector2) -> StringName:
	var outcome: StringName = super.take_hit(damage, hit_position, direction)
	if outcome == &"blocked":
		blocked_hit.emit(hit_position)
	return outcome
