extends Node2D
## Rook sprite rig — the generated Rook sprite pack (concept-art/h01-rook/
## sprites-v1/, made with ChatGPT from rook-sprite-brief-for-chatgpt.md),
## cleaned, scale-normalised and aligned by tools/process_rook_sprites.py
## into assets/characters/rook/ (2x textures, 256x256, hero origin at
## (128, 248)). Replaces the M6 procedural vector Rook.
##
## Pure presentation: hero.gd pushes plain pose values once per physics tick
## (update_pose) and asks shoulder_offset() where the current frame's near
## shoulder is, so it can keep AimPivot on that shoulder. This node never
## reads Session/Input/physics and never touches collision.
##
## Rig: a Body sprite (the frame for the current state; every body frame is
## drawn without the near arm) plus an Arm sprite parented to AimPivot, so
## the arm rotates with the aim around the shoulder and the Scrapjack (also
## on AimPivot, placed at the arm's fist in hero.tscn and scaled to 0.65 so
## the chunky pistol is ~18% of Rook's height, not the ~28% it was sized for
## on the old blocky hero) sits in the hand.
##
## No class_name (hero.tscn attaches this by path; hero.gd calls it through
## an untyped `visual` reference).

const Frames := preload("res://scripts/actors/visuals/rook_frames.gd")

const TEXTURES := {
	&"idle_1": preload("res://assets/characters/rook/rook_idle_1.png"),
	&"idle_2": preload("res://assets/characters/rook/rook_idle_2.png"),
	&"run_1": preload("res://assets/characters/rook/rook_run_1.png"),
	&"run_2": preload("res://assets/characters/rook/rook_run_2.png"),
	&"run_3": preload("res://assets/characters/rook/rook_run_3.png"),
	&"run_4": preload("res://assets/characters/rook/rook_run_4.png"),
	&"run_5": preload("res://assets/characters/rook/rook_run_5.png"),
	&"run_6": preload("res://assets/characters/rook/rook_run_6.png"),
	&"jump_rise": preload("res://assets/characters/rook/rook_jump_rise.png"),
	&"jump_fall": preload("res://assets/characters/rook/rook_jump_fall.png"),
	&"land": preload("res://assets/characters/rook/rook_land.png"),
	&"hurt": preload("res://assets/characters/rook/rook_hurt.png"),
	&"defeated": preload("res://assets/characters/rook/rook_defeated.png"),
	&"interact": preload("res://assets/characters/rook/rook_interact.png"),
}
const ARM_TEXTURE := preload("res://assets/characters/rook/rook_arm.png")

const RUN_FRAMES: Array[StringName] = [&"run_1", &"run_2", &"run_3", &"run_4", &"run_5", &"run_6"]
## Idle breathing: alternate the two idle frames at this interval.
const IDLE_BREATH_TIME := 0.7
## Vertical speed (px/s, up is negative) above which an airborne hero shows
## the rising frame; at or past the apex it shows the falling frame.
const RISE_SPEED := -40.0
## Kept for hero.gd's timers (it owns the countdowns; these are the lengths
## this rig was tuned against).
const LAND_SQUASH_TIME := 0.12
const HIT_POSE_TIME := 0.2
const INTERACT_POSE_TIME := 0.35

var aim_pivot: Node2D = null

var facing: int = 1
var moving: bool = false
var grounded: bool = true
var vertical_velocity: float = 0.0
var stride_phase: float = 0.0
var is_firing: bool = false
var immune: bool = false
var defeated: bool = false
var land_squash_timer: float = 0.0
var hit_pose_timer: float = 0.0
var interact_pose_timer: float = 0.0

var _frame: StringName = &"idle_1"
var _idle_time: float = 0.0
var _body: Sprite2D
var _arm: Sprite2D
var _gun: CanvasItem


func _ready() -> void:
	_body = Sprite2D.new()
	_body.name = "Body"
	_body.centered = true
	_body.offset = Frames.CANVAS_OFFSET
	_body.scale = Vector2(Frames.TEXTURE_SCALE, Frames.TEXTURE_SCALE)
	_body.texture = TEXTURES[_frame]
	add_child(_body)


func setup(pivot: Node2D) -> void:
	aim_pivot = pivot
	if pivot == null:
		return
	_gun = pivot.get_node_or_null("Scrapjack") as CanvasItem
	_arm = Sprite2D.new()
	_arm.name = "Arm"
	_arm.texture = ARM_TEXTURE
	_arm.centered = false
	_arm.offset = -Frames.ARM_SHOULDER_PX
	_arm.scale = Vector2(Frames.TEXTURE_SCALE, Frames.TEXTURE_SCALE)
	# Added after the Scrapjack so the fist and the index finger along the
	# side are drawn over the gun's rear, reading as a held grip.
	pivot.add_child(_arm)


## Reduced motion (interface-and-accessibility.md) removes the hit wiggle
## only; the hurt pose and tint still show.
func _reduced_motion() -> bool:
	var settings := get_node_or_null("/root/Settings")
	return settings != null and settings.get_reduced_motion()


## Called once per physics tick from hero.gd with plain values only.
func update_pose(p_facing: int, p_moving: bool, p_grounded: bool, p_vertical_velocity: float,
		p_stride_phase: float, p_is_firing: bool, p_immune: bool, p_defeated: bool,
		p_land_squash_timer: float, p_hit_pose_timer: float, p_interact_pose_timer: float) -> void:
	facing = p_facing
	moving = p_moving
	grounded = p_grounded
	vertical_velocity = p_vertical_velocity
	stride_phase = p_stride_phase
	is_firing = p_is_firing
	immune = p_immune
	defeated = p_defeated
	land_squash_timer = p_land_squash_timer
	hit_pose_timer = p_hit_pose_timer
	interact_pose_timer = p_interact_pose_timer
	_apply()


func _process(delta: float) -> void:
	_idle_time += delta
	# Idle breathing advances in real time between physics updates.
	if _frame == &"idle_1" or _frame == &"idle_2":
		_set_frame(_pick_frame())
	var shake := 0.0
	if hit_pose_timer > 0.0 and not _reduced_motion():
		shake = sin(hit_pose_timer * 60.0) * 2.0 * (hit_pose_timer / HIT_POSE_TIME)
	position.x = shake


## Which frame the current pose shows. Priority: defeated, hurt, interact,
## landing, airborne, running, idle.
func _pick_frame() -> StringName:
	if defeated:
		return &"defeated"
	if hit_pose_timer > 0.0:
		return &"hurt"
	if interact_pose_timer > 0.0:
		return &"interact"
	if not grounded:
		return &"jump_rise" if vertical_velocity < RISE_SPEED else &"jump_fall"
	if land_squash_timer > 0.0:
		return &"land"
	if moving:
		var i := int(fposmod(stride_phase, TAU) / TAU * RUN_FRAMES.size()) % RUN_FRAMES.size()
		return RUN_FRAMES[i]
	return &"idle_1" if int(_idle_time / IDLE_BREATH_TIME) % 2 == 0 else &"idle_2"


func _apply() -> void:
	_set_frame(_pick_frame())
	_body.flip_h = facing < 0
	# The immunity tint is applied to the whole Hero by hero.gd; nothing
	# extra here (stacking both made Rook look sunburnt).
	if _arm:
		_arm.visible = not defeated
	# A downed hero isn't still holding the pistol up; hide it with the arm.
	if _gun:
		_gun.visible = not defeated


func _set_frame(name: StringName) -> void:
	if name == _frame:
		return
	_frame = name
	_body.texture = TEXTURES[name]


## Current frame name (tests / debugging).
func current_frame() -> StringName:
	return _frame


## The current frame's near shoulder relative to the hero origin, mirrored
## for facing. hero.gd keeps AimPivot here so the arm stays attached.
func shoulder_offset() -> Vector2:
	var s: Vector2 = Frames.SHOULDER[_frame]
	return Vector2(s.x * facing, s.y)
