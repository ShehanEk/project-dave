class_name MaintenanceBench
extends Interactable
## L01-UPG01. Locked until the depot story event (M5's SC01) sets
## `awakening_done` — M4 tests set that flag directly on Session (no
## player-facing dev toggle exists or is added here, per
## 06-build-milestones.md M4's "a development toggle may simulate it for
## this milestone only"). Once unlocked, interact opens BenchPanel (the real
## Service/Quickcycle purchase flow); this script never mutates Session
## itself — BenchPanel is the only thing that calls Session.heal_full() /
## Session.commit() / Session.purchase_upgrade(). Child Marker2D "Respawn" is
## the safe spot UPG01 (the purchase checkpoint) uses via
## LevelDirector.CHECKPOINT_MARKERS.

const OUTLINE := Color("#332a20")
const BODY := Color("#7d7365")
const TOP := Color("#c9b38a")
const LOCKED_TINT := Color(0.55, 0.55, 0.55)
const PANEL_SCENE := "res://scenes/ui/bench_panel.tscn"

var _panel: CanvasLayer = null


func _init() -> void:
	super()
	entity_id = "L01-UPG01"
	prompt = "Bench"


func can_interact(_hero: Node) -> bool:
	return Session != null and Session.get_story("awakening_done") == true


func interact(hero: Node) -> void:
	super(hero)
	if _panel != null:
		return
	_panel = load(PANEL_SCENE).instantiate()
	var host := get_tree().current_scene if get_tree().current_scene else get_tree().root
	host.add_child(_panel)
	if hero and "input_enabled" in hero:
		hero.input_enabled = false
	_panel.closed.connect(_on_panel_closed.bind(hero))


func _on_panel_closed(hero: Node) -> void:
	_panel = null
	if hero and "input_enabled" in hero:
		hero.input_enabled = true
	queue_redraw()


func _draw() -> void:
	var unlocked := can_interact(null)
	var body := BODY if unlocked else BODY.lerp(LOCKED_TINT, 0.5)
	draw_rect(Rect2(Vector2(-50.0, -40.0), Vector2(100.0, 40.0)), body)
	draw_rect(Rect2(Vector2(-54.0, -48.0), Vector2(108.0, 10.0)), TOP)
	draw_rect(Rect2(Vector2(-50.0, -40.0), Vector2(100.0, 40.0)), OUTLINE, false, 3.0)
