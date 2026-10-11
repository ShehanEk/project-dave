class_name Workbench
extends Interactable
## L01-UPG01. Locked until the depot story event (M5's SC01) sets
## `awakening_done` — M4 tests set that flag directly on Session (no
## player-facing dev toggle exists or is added here, per
## 06-build-milestones.md M4's "a development toggle may simulate it for
## this milestone only"). Once unlocked, interact opens WorkbenchPanel (the real
## Service/Quickcycle purchase flow); this script never mutates Session
## itself — WorkbenchPanel is the only thing that calls Session.heal_full() /
## Session.commit() / Session.purchase_upgrade(). Child Marker2D "Respawn" is
## the safe spot UPG01 (the purchase checkpoint) uses via
## LevelDirector.CHECKPOINT_MARKERS.

const OUTLINE := Color("#07090F")
const BODY := Color("#1C2A3A")
const TOP := Color("#2E3B4E")
const LAMP_ON := Color("#3FE0D0")
const LAMP_OFF := Color("#FFB02E")
const LOCKED_TINT := Color(0.3, 0.3, 0.35)
const PANEL_SCENE := "res://scenes/ui/workbench_panel.tscn"
## The painted pixel-art look (objects sheet), drawn through ObjectSkins; the
## code-drawn look below stays as the fallback. Dimmed while locked, with a
## small status lamp (teal usable, amber locked) on the pegboard's corner.
const ObjectSkins := preload("res://scripts/world/object_skins.gd")
const PIECE := "workbench"
const LOCKED_PAINT := Color(0.55, 0.58, 0.66)
## The status lamp's centre, art px from the piece's top-left corner.
const LAMP_ART := Vector2(126.0, 10.0)

var _panel: CanvasLayer = null


func _init() -> void:
	super()
	entity_id = "L01-UPG01"
	prompt = "Workbench"


func _ready() -> void:
	if painted_piece() != "":
		ObjectSkins.make_crisp(self)


## The ObjectSkins piece this bench draws, or "" for the code-drawn look.
func painted_piece() -> String:
	return PIECE if ObjectSkins.has_piece(PIECE) else ""


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
	# C52: a Quickcycle bought in this visit is announced on the HUD once the panel is gone,
	# where it can be read (the one raised at the purchase faded behind the panel).
	var bought: bool = _panel != null and _panel.bought
	var bought_plating: bool = _panel != null and _panel.bought_plating
	_panel = null
	if (bought or bought_plating) and get_tree():
		var hud := get_tree().get_first_node_in_group("hud")
		if hud and bought_plating and hud.has_method("announce_plating"):
			hud.announce_plating()
		elif hud and hud.has_method("announce_quickcycle"):
			hud.announce_quickcycle()
	if hero and "input_enabled" in hero:
		hero.input_enabled = true
	queue_redraw()


func _draw() -> void:
	# A steel workbench with a hanging task lamp: teal when usable, amber while
	# locked (before the depot event).
	var unlocked := can_interact(null)
	if painted_piece() != "":
		ObjectSkins.draw(self, PIECE, Color.WHITE if unlocked else LOCKED_PAINT)
		var lamp := ObjectSkins.at(PIECE, LAMP_ART)
		var col := LAMP_ON if unlocked else LAMP_OFF
		draw_circle(lamp, 10.0, Color(col, 0.25))
		draw_rect(Rect2(lamp - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), col)
		return
	var body := BODY if unlocked else BODY.lerp(LOCKED_TINT, 0.5)
	draw_rect(Rect2(Vector2(-50.0, -40.0), Vector2(100.0, 40.0)), body)
	draw_rect(Rect2(Vector2(-54.0, -48.0), Vector2(108.0, 10.0)), TOP)
	draw_line(Vector2(-54.0, -48.0), Vector2(54.0, -48.0), Color(LAMP_ON if unlocked else LAMP_OFF, 0.6), 2.0)
	for x in [-30.0, -6.0, 18.0]:
		draw_rect(Rect2(Vector2(x, -34.0), Vector2(16.0, 10.0)), Color("#0E1726"))
	var lamp := LAMP_ON if unlocked else LAMP_OFF
	draw_line(Vector2(34.0, -48.0), Vector2(34.0, -78.0), OUTLINE, 3.0)
	draw_circle(Vector2(34.0, -80.0), 9.0, Color(lamp, 0.25))
	draw_circle(Vector2(34.0, -80.0), 4.0, lamp)
	draw_rect(Rect2(Vector2(-50.0, -40.0), Vector2(100.0, 40.0)), OUTLINE, false, 3.0)
