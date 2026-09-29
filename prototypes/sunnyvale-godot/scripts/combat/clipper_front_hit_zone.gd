class_name ClipperFrontHitZone
extends HitZone
## The Clipper's front shell: always blocks (per CONVENTIONS.md HitZone
## contract, unchanged) but also reports each blocked frontal hit so the
## Clipper can count "ineffective" shots and show the one-time motor hint.
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
