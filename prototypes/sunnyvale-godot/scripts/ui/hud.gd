class_name Hud
extends CanvasLayer
## Always-on HUD (04-godot-architecture.md "UI reads state/signals, requests
## actions, never directly edits saved wallets or story flags"). Added by
## LevelDirector once, alongside the Hero/GameCamera it never recreates;
## connects to Session exactly once in `_ready()` and disconnects in
## `_exit_tree()`. Reads the held Scrapjack's own `is_ready()` for the
## fire-readiness cue but never mutates it or Session.
##
## M6 (C11 hand-drawn presentation pass): health segments are warm-charcoal-
## outlined flat Panels (not plain color rects) so they read as chunky C11
## shapes rather than blockout tiles; the held weapon gets its own small
## drawn icon (`scripts/ui/weapon_icon.gd`) alongside the existing text tag
## and Quickcycle pip; the gem count gets a matching gem-diamond icon
## (`scripts/ui/gem_icon.gd`). Every HUD label carries a dark outline so it
## stays legible over both Sunnyvale's bright cream/sky scenery and the
## depot's darker quarantine palette without depending on a backing panel.

const HEALTH_FULL := Color("#df9e80")     # peach (Sunnyvale palette)
const HEALTH_EMPTY := Color("#c9bfa4")    # muted cream — "lost" segment
const HEALTH_OUTLINE := Color("#332a20")  # warm charcoal (C11 contour)
const READY_COLOR := Color("#87b45e")     # lawn green — ready to fire
## Deliberately much darker than READY_COLOR (not just a different hue): the
## fire-readiness dot must still read as "not yet" in grayscale, per
## interface-and-accessibility.md "do not rely on hue alone".
const COOLDOWN_COLOR := Color("#4a4438")  # dark warm charcoal-gray — cooling down
const QUICKCYCLE_COLOR := Color("#a9714a")

var _hero: Node = null
var _weapon: Node = null
var _health_styles: Array[StyleBoxFlat] = []

@onready var _health_row: HBoxContainer = $TopBar/HealthRow
@onready var _wallet_label: Label = $TopBar/WalletLabel
@onready var _weapon_icon: Control = $TopBar/WeaponBox/WeaponIcon
@onready var _weapon_tag_label: Label = $TopBar/WeaponBox/TagLabel
@onready var _weapon_pip: ColorRect = $TopBar/WeaponBox/QuickcyclePip
@onready var _weapon_ready: ColorRect = $TopBar/WeaponBox/ReadyDot
@onready var _objective_label: Label = $ObjectiveLabel
@onready var _toast: ToastLabel = $Toast


func _ready() -> void:
	layer = 15
	for child in _health_row.get_children():
		if child is Panel:
			var style := StyleBoxFlat.new()
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.border_color = HEALTH_OUTLINE
			style.corner_radius_top_left = 4
			style.corner_radius_top_right = 4
			style.corner_radius_bottom_right = 4
			style.corner_radius_bottom_left = 4
			style.bg_color = HEALTH_EMPTY
			child.add_theme_stylebox_override("panel", style)
			_health_styles.append(style)
	if Session:
		Session.health_changed.connect(_on_health_changed)
		Session.wallet_changed.connect(_on_wallet_changed)
		Session.objective_changed.connect(_on_objective_changed)
		Session.weapon_swapped.connect(_on_weapon_changed)
		Session.upgrade_purchased.connect(_on_upgrade_changed)
		Session.checkpoint_committed.connect(_on_checkpoint_committed)
		Session.save_failed.connect(_on_save_failed)
		Session.artifact_recorded.connect(_on_artifact_recorded)
		Session.snapshot_restored.connect(_on_snapshot_restored)
		Session.run_reset.connect(_on_run_reset)
		_on_health_changed(Session.get_health(), Session.MAX_HEALTH)
		_on_wallet_changed(Session.get_wallet())
		_on_objective_changed(Session.get_objective())
	_refresh_weapon()
	_apply_text_size()
	var settings := get_node_or_null("/root/Settings")
	if settings and not settings.changed.is_connected(_apply_text_size):
		settings.changed.connect(_apply_text_size)


const BASE_OBJECTIVE_SIZE := 20
const BASE_WALLET_SIZE := 24
const BASE_TAG_SIZE := 22


## Settings "text size" (M6: extended to every HUD label a player reads, not
## just the objective — interface-and-accessibility.md "scalable HUD/text").
func _apply_text_size() -> void:
	var settings := get_node_or_null("/root/Settings")
	var scale_fn := (func(base: int) -> int: return settings.scaled_font_size(base) if settings else base)
	_objective_label.add_theme_font_size_override("font_size", scale_fn.call(BASE_OBJECTIVE_SIZE))
	_wallet_label.add_theme_font_size_override("font_size", scale_fn.call(BASE_WALLET_SIZE))
	_weapon_tag_label.add_theme_font_size_override("font_size", scale_fn.call(BASE_TAG_SIZE))


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
		[Session.artifact_recorded, _on_artifact_recorded],
		[Session.snapshot_restored, _on_snapshot_restored],
		[Session.run_reset, _on_run_reset],
	]:
		if pair[0].is_connected(pair[1]):
			pair[0].disconnect(pair[1])


## LevelDirector calls this once, right after instancing both the Hero and
## this HUD, and again is never needed — the Hero/HUD pair lives for the
## whole run.
func setup(hero: Node) -> void:
	_hero = hero
	_weapon = hero.get_node_or_null("AimPivot/Scrapjack") if hero else null
	_refresh_weapon()


func _process(_delta: float) -> void:
	if _weapon and is_instance_valid(_weapon) and _weapon.has_method("is_ready"):
		_weapon_ready.color = READY_COLOR if _weapon.is_ready() else COOLDOWN_COLOR


func _on_health_changed(current: int, _maximum: int) -> void:
	for i in _health_styles.size():
		_health_styles[i].bg_color = HEALTH_FULL if i < current else HEALTH_EMPTY


func _on_wallet_changed(wallet: int) -> void:
	_wallet_label.text = "Gems: %d" % wallet


func _on_objective_changed(text: String) -> void:
	_objective_label.text = text


func _on_weapon_changed(_old_id: String, _new_id: String) -> void:
	_refresh_weapon()


func _on_upgrade_changed(_weapon_type: String, _stage: int) -> void:
	_refresh_weapon()


## sc01-double-toast: CP04 is CoreConsole's own SC01 completion commit, which
## already shows its own specific "EDEN awakens..." (or the honest
## save-failed) toast at the exact same instant — showing the generic
## "Progress saved" HUD toast on top of it put two unrelated messages on
## screen at once. Every other checkpoint has no toast of its own, so the
## HUD's is the only one and still shows normally.
func _on_checkpoint_committed(checkpoint_id: String) -> void:
	if checkpoint_id == "CP04":
		return
	if _toast:
		_toast.show_message("Progress saved")


func _on_save_failed(_reason: String, _checkpoint_id: String) -> void:
	if _toast:
		_toast.show_message("Save failed — progress since the last checkpoint is kept in memory only", 1.6, 0.8)


func _on_artifact_recorded(_artifact_id: String) -> void:
	if _toast:
		_toast.show_message("Artifact recorded")


func _on_snapshot_restored(_checkpoint_id: String) -> void:
	_refresh_weapon()


## ADV-03: "Play again" -> Session.new_run() on a HUD that is never recreated
## (LevelDirector only rebuilds the Areas) — without this the weapon tag/
## Quickcycle pip kept showing whatever was equipped/owned in the run that
## just ended.
func _on_run_reset() -> void:
	_refresh_weapon()


func _refresh_weapon() -> void:
	if Session == null:
		return
	var parts := Session.equipped_weapon().split("-")
	_weapon_tag_label.text = parts[-1] if parts.size() > 0 else ""
	var owns_quickcycle := Session.weapon_stage("W01") >= 1
	_weapon_pip.visible = owns_quickcycle
	_weapon_pip.color = QUICKCYCLE_COLOR
	if _weapon_icon and _weapon_icon.has_method("set_quickcycle_owned"):
		_weapon_icon.set_quickcycle_owned(owns_quickcycle)
