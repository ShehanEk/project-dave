extends Node
## Settings (autoload) — minimal player-adjustable presentation options (M5
## part 2; interface-and-accessibility.md "Accessibility proposals" — M6
## extends this). Persisted through CheckpointService's SEPARATE settings
## file (`save_settings`/`load_settings`), never mixed into the checkpoint
## snapshot itself: a corrupt/missing settings file never blocks a save/load,
## and a corrupt/missing checkpoint never loses the player's settings.
##
## Applies audio bus volumes immediately (Master/Music/SFX — created by
## data/audio/default_bus_layout.tres). Other flags (`subtitles_enabled`,
## `text_size`, `reduced_motion`) are read directly by whoever cares
## (SubtitlePanel, EnvironmentState, Hud) rather than pushed through extra
## signals for every reader; `changed` fires on any update for the settings
## screen itself (and anyone who wants to react live) to refresh from.

signal changed

const TEXT_SIZE_NORMAL := "normal"
const TEXT_SIZE_LARGE := "large"

const DEFAULTS := {
	"subtitles_enabled": true,
	"text_size": TEXT_SIZE_NORMAL,
	"reduced_motion": false,
	"master_volume": 0.8,
	"music_volume": 0.8,
	"sfx_volume": 0.8,
}

var _values: Dictionary = DEFAULTS.duplicate(true)


func _ready() -> void:
	load_from_disk()


# --- persistence ---------------------------------------------------------------

func load_from_disk() -> void:
	var service := get_node_or_null("/root/CheckpointService")
	var loaded: Dictionary = service.load_settings() if service else {}
	_values = DEFAULTS.duplicate(true)
	for key in DEFAULTS:
		if loaded.has(key) and typeof(loaded[key]) == typeof(DEFAULTS[key]):
			_values[key] = loaded[key]
	_apply_audio()
	changed.emit()


func _save() -> void:
	var service := get_node_or_null("/root/CheckpointService")
	if service:
		service.save_settings(_values)
	changed.emit()


# --- subtitles / text size / motion --------------------------------------------

func get_subtitles_enabled() -> bool:
	return _values["subtitles_enabled"]


func set_subtitles_enabled(value: bool) -> void:
	_values["subtitles_enabled"] = value
	_save()


func get_text_size() -> String:
	return _values["text_size"]


func set_text_size(value: String) -> void:
	if value != TEXT_SIZE_NORMAL and value != TEXT_SIZE_LARGE:
		return
	_values["text_size"] = value
	_save()


## Convenience for readers that just want a font size in px for a given base
## (blockout style's own 20-28px range, per CONVENTIONS.md).
func scaled_font_size(base: int) -> int:
	return int(round(base * 1.25)) if get_text_size() == TEXT_SIZE_LARGE else base


func get_reduced_motion() -> bool:
	return _values["reduced_motion"]


func set_reduced_motion(value: bool) -> void:
	_values["reduced_motion"] = value
	_save()


# --- audio -----------------------------------------------------------------------

func get_master_volume() -> float:
	return _values["master_volume"]


func get_music_volume() -> float:
	return _values["music_volume"]


func get_sfx_volume() -> float:
	return _values["sfx_volume"]


func set_master_volume(value: float) -> void:
	_values["master_volume"] = clampf(value, 0.0, 1.0)
	_apply_bus_volume("Master", _values["master_volume"])
	_save()


func set_music_volume(value: float) -> void:
	_values["music_volume"] = clampf(value, 0.0, 1.0)
	_apply_bus_volume("Music", _values["music_volume"])
	_save()


func set_sfx_volume(value: float) -> void:
	_values["sfx_volume"] = clampf(value, 0.0, 1.0)
	_apply_bus_volume("SFX", _values["sfx_volume"])
	_save()


func _apply_audio() -> void:
	_apply_bus_volume("Master", _values["master_volume"])
	_apply_bus_volume("Music", _values["music_volume"])
	_apply_bus_volume("SFX", _values["sfx_volume"])


## Silently does nothing for a bus that doesn't exist (e.g. "Music"/"SFX" in a
## minimal test scene without the project's own audio bus layout loaded) —
## volume settings never crash a headless test run.
func _apply_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	AudioServer.set_bus_mute(idx, linear <= 0.0001)
	if linear > 0.0001:
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear))
