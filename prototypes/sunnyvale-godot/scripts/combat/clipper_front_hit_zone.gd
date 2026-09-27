class_name ClipperFrontHitZone
extends HitZone
## The Clipper's front shell: always blocks (per CONVENTIONS.md HitZone
## contract, unchanged) but also reports each blocked frontal hit so the
## Clipper can count "ineffective" shots and show the one-time motor hint.

signal blocked_hit


func take_hit(damage: int, hit_position: Vector2, direction: Vector2) -> StringName:
	var outcome: StringName = super.take_hit(damage, hit_position, direction)
	if outcome == &"blocked":
		blocked_hit.emit()
	return outcome
