class_name Hud
extends CanvasLayer
## Always-on HUD (04-godot-architecture.md "UI reads state/signals, requests
## actions, never directly edits saved wallets or story flags"). Added by
## LevelDirector once, alongside the Hero/GameCamera it never recreates;
## connects to Session exactly once in `_ready()` and disconnects in
## `_exit_tree()`. Reads the held Scrapjack's own `is_ready()` for the
## fire-readiness cue but never mutates it or Session.
##
## Pixel UI (Sheets 11 and 12, scripts/ui/pixel_ui.gd; 3 canvas px per UI
## pixel): the six health segments are the sheet's full/empty pieces (a
## segment just lost flashes pale for HIT_FLASH_TIME first); the weapon slot
## frame holds the pixel Scrapjack (`weapon_icon.gd`); the fire-readiness
## light and the Quickcycle pip are the sheet's lit/dark lights; the microchip
## (`chip_icon.gd`) and keycard (`keycard_icon.gd`) are the sheet's icons. The
## two short capitals labels (the weapon tag "P01" and the wallet "Chips: 65",
## drawn CHIPS: 65) are set in the pixel sign font with a baked dark outline,
## a whole 3 canvas px per font pixel at Normal text size and 4 at Large;
## the objective sits on the pixel banner strip in the UI font, and toasts
## (a pixel save mark, warning or evidence folder beside them) stay in the UI
## font too. Every piece falls back to its code-drawn look and every label to
## the outlined UI font when the art is missing.
##
## Accessibility: the readiness light is a bright green when ready and a dark
## steel when not (a large luminance step, not only a hue change — interface-
## and-accessibility.md "do not rely on hue alone"); a full health segment is
## a bright orange and an empty one a dark slate, likewise.

const PixelUi := preload("res://scripts/ui/pixel_ui.gd")

const HEALTH_FULL := Color("#e07a3f")     # Dave's burnt orange
const HEALTH_EMPTY := Color("#2e3b4e")    # slate — "lost" segment
const HEALTH_FLASH := Color("#ffe6ce")    # pale — the segment just lost
const HEALTH_OUTLINE := Color("#07090f")  # near-black contour
const READY_COLOR := Color("#4de38a")     # signal green — ready to fire
## Deliberately much darker than READY_COLOR (not just a different hue): the
## fire-readiness dot must still read as "not yet" in grayscale, per
## interface-and-accessibility.md "do not rely on hue alone".
const COOLDOWN_COLOR := Color("#1c2a3a")  # steel — cooling down
const QUICKCYCLE_COLOR := Color("#ffb02e")
const LEVEL_KEYCARD := "L01-KC01"
## Pixel pieces (assets/ui/pixel/).
const PIECE_HEALTH_FULL := "health_full"
const PIECE_HEALTH_EMPTY := "health_empty"
const PIECE_HEALTH_FLASH := "health_flash"
const PIECE_READY := "ready_lit"
const PIECE_COOLDOWN := "ready_dark"
## How long a segment just lost shows the pale hit-flash piece.
const HIT_FLASH_TIME := 0.25
## Space between the objective text and the banner's edge (UI px).
const BANNER_PAD_X := 5
const BANNER_PAD_Y := 2

var _hero: Node = null
var _weapon: Node = null
var _health_segments: Array[Control] = []
var _shown_health := -1
var _flash_from := 0
var _flash_to := 0
## C53 low-health warning: at LOW_HEALTH or less the health row pulses red, slowly
## (LOW_HEALTH_HZ, well under any flashing limit); with Reduced Motion it holds a steady red.
const LOW_HEALTH := 2
const LOW_HEALTH_HZ := 1.4
const LOW_HEALTH_TINT := Color(1.0, 0.42, 0.38)
var _low_health_t := 0.0
var _flash_left := 0.0

@onready var _health_row: HBoxContainer = $TopBar/HealthRow
@onready var _wallet_label: Label = $TopBar/WalletLabel
@onready var _weapon_icon: Control = $TopBar/WeaponBox/WeaponIcon
@onready var _weapon_tag_label: Label = $TopBar/WeaponBox/TagLabel
@onready var _weapon_pip: Control = $TopBar/WeaponBox/QuickcyclePip
@onready var _weapon_ready: Control = $TopBar/WeaponBox/ReadyDot
@onready var _objective_label: Label = $ObjectiveLabel
@onready var _objective_banner: Control = $ObjectiveLabel/Banner
@onready var _keycard_icon: Control = $TopBar/KeycardIcon
@onready var _toast: ToastLabel = $Toast
## An upgrade was just bought ("W01" Quickcycle or "A01" Scrap Plating, "" none); the next
## checkpoint toast says so instead of "Progress saved".
var _upgrade_pending := ""


func _ready() -> void:
	add_to_group("hud")
	layer = 15
	for child in _health_row.get_children():
		if child is Control and child.has_method("set_piece"):
			child.fallback_outline = HEALTH_OUTLINE
			_health_segments.append(child)
	# C53: a spare segment for Scrap Plating (+1 max health), shown only once it is fitted.
	if not _health_segments.is_empty():
		var extra: Control = _health_segments[-1].duplicate()
		extra.name = "Health%d" % _health_segments.size()
		_health_row.add_child(extra)
		extra.fallback_outline = HEALTH_OUTLINE
		_health_segments.append(extra)
	_weapon_pip.set_piece("pip_lit", QUICKCYCLE_COLOR)
	_objective_label.resized.connect(_layout_objective_banner)
	if Session:
		Session.health_changed.connect(_on_health_changed)
		Session.wallet_changed.connect(_on_wallet_changed)
		Session.objective_changed.connect(_on_objective_changed)
		Session.weapon_swapped.connect(_on_weapon_changed)
		Session.upgrade_purchased.connect(_on_upgrade_changed)
		Session.checkpoint_committed.connect(_on_checkpoint_committed)
		Session.save_failed.connect(_on_save_failed)
		Session.evidence_recorded.connect(_on_evidence_recorded)
		Session.keycard_taken.connect(_on_keycard_taken)
		Session.snapshot_restored.connect(_on_snapshot_restored)
		Session.run_reset.connect(_on_run_reset)
		_on_health_changed(Session.get_health(), Session.max_health())
		_on_wallet_changed(Session.get_wallet())
		_on_objective_changed(Session.get_objective())
	_refresh_weapon()
	_refresh_keycard()
	_apply_text_size()
	var settings := get_node_or_null("/root/Settings")
	if settings and not settings.changed.is_connected(_apply_text_size):
		settings.changed.connect(_apply_text_size)


const BASE_OBJECTIVE_SIZE := 20
const BASE_WALLET_SIZE := 24
const BASE_TAG_SIZE := 22


## Settings "text size" (M6: extended to every HUD label a player reads, not
## just the objective — interface-and-accessibility.md "scalable HUD/text").
## The two pixel-font labels take the same font sizes; the pixel font turns
## them into whole canvas px per font pixel (3 at Normal, 4 at Large).
func _apply_text_size() -> void:
	var settings := get_node_or_null("/root/Settings")
	var scale_fn := (func(base: int) -> int: return settings.scaled_font_size(base) if settings else base)
	_objective_label.add_theme_font_size_override("font_size", scale_fn.call(BASE_OBJECTIVE_SIZE))
	_wallet_label.add_theme_font_size_override("font_size", scale_fn.call(BASE_WALLET_SIZE))
	_weapon_tag_label.add_theme_font_size_override("font_size", scale_fn.call(BASE_TAG_SIZE))
	_layout_objective_banner.call_deferred()


func _exit_tree() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.changed.is_connected(_apply_text_size):
		settings.changed.disconnect(_apply_text_size)
	if Session == null:
		return
	for pair in [
		[Session.health_changed, _on_health_changed],
		[Session.wallet_changed, _on_wallet_changed],
		[Session.objective_changed, _on_objective_changed],
		[Session.weapon_swapped, _on_weapon_changed],
		[Session.upgrade_purchased, _on_upgrade_changed],
		[Session.checkpoint_committed, _on_checkpoint_committed],
		[Session.save_failed, _on_save_failed],
		[Session.evidence_recorded, _on_evidence_recorded],
		[Session.keycard_taken, _on_keycard_taken],
		[Session.snapshot_restored, _on_snapshot_restored],
		[Session.run_reset, _on_run_reset],
	]:
		if pair[0].is_connected(pair[1]):
			pair[0].disconnect(pair[1])


## LevelDirector calls this once, right after instancing both the Hero and
## this HUD, and again is never needed — the Hero/HUD pair lives for the
## whole run.
## The held gun's workshop tag ("P01") matters only where a second copy can be
## swapped in: LevelDirector turns it on in a level with a swap pad (none in Level 1
## since the pad was taken out on 2026-10-08; see level-design/swap-pad-for-level-2.md).
var show_weapon_tag := false


func set_weapon_tag_shown(on: bool) -> void:
	show_weapon_tag = on
	_weapon_tag_label.visible = on


func setup(hero: Node) -> void:
	_hero = hero
	_weapon = hero.get_node_or_null("AimPivot/Scrapjack") if hero else null
	_refresh_weapon()


func _process(delta: float) -> void:
	if _weapon and is_instance_valid(_weapon) and _weapon.has_method("is_ready"):
		set_fire_ready(_weapon.is_ready())
	if _flash_left > 0.0:
		_flash_left -= delta
		if _flash_left <= 0.0:
			_show_health(_shown_health)
	_update_low_health(delta)


## True while the health row is showing the low-health warning.
func is_low_health_warning() -> bool:
	return _shown_health > 0 and _shown_health <= LOW_HEALTH


func _update_low_health(delta: float) -> void:
	if not is_low_health_warning():
		_low_health_t = 0.0
		_health_row.modulate = Color.WHITE
		return
	_low_health_t += delta
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.get_reduced_motion():
		_health_row.modulate = LOW_HEALTH_TINT
		return
	var p := 0.5 + 0.5 * sin(_low_health_t * TAU * LOW_HEALTH_HZ)
	_health_row.modulate = Color.WHITE.lerp(LOW_HEALTH_TINT, p)


## Lights the fire-readiness light (bright green) or darkens it (dark steel).
func set_fire_ready(ready: bool) -> void:
	_weapon_ready.set_piece(PIECE_READY if ready else PIECE_COOLDOWN, READY_COLOR if ready else COOLDOWN_COLOR)


func is_fire_ready_shown() -> bool:
	return _weapon_ready.piece == PIECE_READY


func _on_health_changed(current: int, _maximum: int) -> void:
	if _shown_health >= 0 and current < _shown_health:
		_flash_from = current
		_flash_to = _shown_health
		_flash_left = HIT_FLASH_TIME
	elif current > _shown_health:
		_flash_left = 0.0
	_shown_health = current
	_show_health(current)


func _show_health(current: int) -> void:
	var max_hp: int = Session.max_health() if Session else _health_segments.size()
	for i in _health_segments.size():
		_health_segments[i].visible = i < max_hp
		if i < current:
			_health_segments[i].set_piece(PIECE_HEALTH_FULL, HEALTH_FULL)
		elif _flash_left > 0.0 and i >= _flash_from and i < _flash_to:
			_health_segments[i].set_piece(PIECE_HEALTH_FLASH, HEALTH_FLASH)
		else:
			_health_segments[i].set_piece(PIECE_HEALTH_EMPTY, HEALTH_EMPTY)


func _on_wallet_changed(wallet: int) -> void:
	_wallet_label.text = "Chips: %d" % wallet
	PixelUi.use_font(_wallet_label)


func _on_objective_changed(text: String) -> void:
	_objective_label.text = text
	_layout_objective_banner.call_deferred()


## Fits the banner strip behind the objective's text (right-aligned, so the
## banner hugs the text's right end, not the Label's whole 444 px width).
func _layout_objective_banner() -> void:
	if not is_instance_valid(_objective_banner):
		return
	var text := _objective_label.text
	_objective_banner.visible = text != "" and _objective_banner.has_art()
	if not _objective_banner.visible:
		return
	var s := float(PixelUi.SCALE)
	if not _objective_label.has_theme_stylebox_override("normal"):
		# Insets the text by the banner's padding (the Label keeps its rect).
		var inset := StyleBoxEmpty.new()
		inset.content_margin_left = BANNER_PAD_X * s
		inset.content_margin_right = BANNER_PAD_X * s
		_objective_label.add_theme_stylebox_override("normal", inset)
	var f := _objective_label.get_theme_font("font")
	var fs := _objective_label.get_theme_font_size("font_size")
	var width := _objective_label.size.x
	var inner := width - 2.0 * BANNER_PAD_X * s
	var block: Vector2 = f.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_RIGHT, inner, fs, -1,
			TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND)
	var lines := maxi(_objective_label.get_line_count(), 1)
	var h := maxf(block.y, float(lines) * f.get_height(fs))
	var w := minf(block.x, inner) + 2.0 * BANNER_PAD_X * s
	_objective_banner.position = Vector2(roundf(width - w), -BANNER_PAD_Y * s)
	_objective_banner.size = Vector2(roundf(w), roundf(h + 2.0 * BANNER_PAD_Y * s))


func _on_weapon_changed(_old_id: String, _new_id: String) -> void:
	_refresh_weapon()


func _on_upgrade_changed(weapon_type: String, stage: int) -> void:
	_refresh_weapon()
	# C52: the generic "Progress saved" that follows the purchase (UPG01) gives way to this.
	if stage >= 1 and (weapon_type == "W01" or weapon_type == "A01"):
		_upgrade_pending = weapon_type
		_refresh_health_row()


## "Quickcycle online": raised when the bench is bought from and again when its panel closes.
func announce_quickcycle() -> void:
	if _toast == null:
		return
	var tuning: WeaponTuning = load("res://data/tuning/w01_scrapjack.tres")
	var faster := roundi((tuning.base_interval / tuning.quickcycle_interval - 1.0) * 100.0)
	_toast.show_message("Quickcycle online: %d%% faster fire" % faster, 2.4, ToastLabel.FADE_TIME, "pip_lit")
	_play_sfx(&"ready_click")


## "Scrap Plating fitted" (C53): raised like the Quickcycle's.
func announce_plating() -> void:
	if _toast == null:
		return
	_toast.show_message("Scrap Plating fitted: %d health" % Session.max_health(), 2.4, ToastLabel.FADE_TIME, "pip_lit")
	_play_sfx(&"ready_click")


func _refresh_health_row() -> void:
	if Session:
		_show_health(Session.get_health())


## sc01-double-toast: CP04 is CoreNode's own SC01 completion commit, which
## already shows its own specific "Partial copy saved..." (or the honest
## save-failed) toast at the exact same instant — showing the generic
## "Progress saved" HUD toast on top of it put two unrelated messages on
## screen at once. Every other checkpoint has no toast of its own, so the
## HUD's is the only one and still shows normally.
func _on_checkpoint_committed(checkpoint_id: String) -> void:
	if checkpoint_id == "CP04":
		return
	if _upgrade_pending != "":
		var which := _upgrade_pending
		_upgrade_pending = ""
		if which == "A01":
			announce_plating()
		else:
			announce_quickcycle()
		return
	if _toast:
		_toast.show_message("Progress saved", ToastLabel.HOLD_TIME, ToastLabel.FADE_TIME, "save")
		# The small "saved" double tick (N05), with the visible toast and nowhere
		# else: the checkpoint bong is Audio's own on the same signal, the station's
		# local toast and the workbench's panel line are silent, and CP04's toast
		# (skipped above) sits under the lockdown stinger.
		_play_sfx(&"toast_save")


## Interface cues go through the Audio autoload when there is one (tests and
## demo scenes run without it).
func _play_sfx(cue: StringName) -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(cue)


func _on_save_failed(_reason: String, _checkpoint_id: String) -> void:
	if _toast:
		_toast.show_message("Save failed — progress since the last checkpoint is kept in memory only", 1.6, 0.8, "warning")


func _on_evidence_recorded(_evidence_id: String) -> void:
	if _toast:
		_toast.show_message("Evidence file saved", ToastLabel.HOLD_TIME, ToastLabel.FADE_TIME, "evidence")


func _on_keycard_taken(_keycard_id: String) -> void:
	_refresh_keycard()


func _on_snapshot_restored(_checkpoint_id: String) -> void:
	_refresh_weapon()
	_refresh_keycard()


## ADV-03: "Play again" -> Session.new_run() on a HUD that is never recreated
## (LevelDirector only rebuilds the Areas) — without this the weapon tag/
## Quickcycle pip kept showing whatever was equipped/owned in the run that
## just ended.
func _on_run_reset() -> void:
	_refresh_weapon()
	_refresh_keycard()


func _refresh_keycard() -> void:
	if _keycard_icon:
		_keycard_icon.visible = Session != null and Session.has_keycard(LEVEL_KEYCARD)


func _refresh_weapon() -> void:
	if Session == null:
		return
	var parts := Session.equipped_weapon().split("-")
	_weapon_tag_label.text = parts[-1] if parts.size() > 0 else ""
	_weapon_tag_label.visible = show_weapon_tag
	PixelUi.use_font(_weapon_tag_label)
	var owns_quickcycle := Session.weapon_stage("W01") >= 1
	_weapon_pip.visible = owns_quickcycle
	if _weapon_icon and _weapon_icon.has_method("set_quickcycle_owned"):
		_weapon_icon.set_quickcycle_owned(owns_quickcycle)
