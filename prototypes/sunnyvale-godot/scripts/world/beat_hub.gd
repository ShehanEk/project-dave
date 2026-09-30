class_name BeatHub
extends RefCounted
## Autoload-free static signal hub for BeatZone (per CONVENTIONS.md). A
## BeatZone calls BeatHub.get_instance().beat_entered.emit(...) on hero
## entry; a later Telemetry system (or the debug RouteBot, or a test) can
## connect without an autoload or a group-call broadcast.

signal beat_entered(beat_id: String, area_id: String)

static var _instance: BeatHub


static func get_instance() -> BeatHub:
	if _instance == null:
		_instance = BeatHub.new()
	return _instance
