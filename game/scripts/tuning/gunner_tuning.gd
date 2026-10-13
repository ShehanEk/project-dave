class_name GunnerTuning
extends Resource
## Gunner template tuning (C26, M4): the aimed shooter, first the SE02 Sidearm Guard
## with the EG01 pistol. The loop: hold a post or walk a beat -> notice Dave (a bark)
## -> walk in to range -> the tell (a deep two-hand stance, the muzzle lamp amber, then
## red for the last `red_time` with a lock click) -> one round -> a rooted reload (the
## punish window) -> again. Numbers are the briefs' (P23: 1 round at 9 H/s, 6.5 H
## range, a 1.2 s reload, 3 hits); the rest are authoring choices, recorded here.
## Everything that makes one gunner differ from another (gun, timings, look, barks)
## lives here, as data.

@export var health: int = 3
@export var damage: int = 1
## Walking a beat before noticing, and walking in to range, in hero-heights/s.
@export var patrol_speed_h_per_s: float = 0.0
@export var approach_speed_h_per_s: float = 1.1
## How far (px) the hero is noticed from, sideways and up or down.
@export var notice_range: float = 620.0
@export var notice_vertical: float = 360.0
## The tell starts only while Dave is within this distance of the muzzle (hero-heights)…
@export var engage_range_h: float = 6.0
## …and the round flies at most this far (fairness rules: every gun at most 6.5 H).
@export var round_range_h: float = 6.5
@export var round_speed_h_per_s: float = 9.0
## Dave's last grounded height within this band (px) of the gunner's own floor is "his
## floor": the round goes flat at round_height_h. Anything else is another floor: the
## round goes at Dave's last grounded spot, round_height_h above it, locked at red.
@export var same_floor_band: float = 24.0
@export var round_height_h: float = 0.5
## How fast the aim point follows Dave's grounded spot during the amber part of the
## tell (hero-heights/s, always slower than his 4, no lead). It locks at red.
@export var aim_track_speed_h_per_s: float = 3.0
## The arm can aim this far down (+) and up (-) from level, in degrees (the brief: about
## -60 to +30 from the shoulder).
## Where a round leaves, independent of the pose (the stance's numbers, facing right):
## a shot at another floor starts shot_reach px from the stance shoulder `shot_pivot`
## toward its target; a flat one starts flat_muzzle_x px ahead of his feet, at
## round_height_h. The drawn muzzle (the gun's socket) only places the flash.
@export var shot_pivot: Vector2 = Vector2(4.0, -57.0)
@export var shot_reach: float = 47.0
@export var flat_muzzle_x: float = 52.0
@export var aim_down_max_deg: float = 60.0
@export var aim_up_max_deg: float = 30.0
## The readability gate: he starts a tell, and fires, only while his body is at least
## this far inside the camera's view (hero-heights).
@export var camera_margin_h: float = 1.0
@export var gravity: float = 1800.0

@export var windup_time: float = 0.9
## The last part of the tell, when the lamp turns from amber to red and the aim locks.
@export var red_time: float = 0.25
## The shot and its recoil, then the rooted reload (the slide rack: the punish window).
@export var fire_time: float = 0.18
@export var reload_time: float = 1.2
## Rest after the reload before the next tell may start.
@export var rest_time: float = 0.3
## Rounds alive at once from one gunner (the screen caps: pistol 1).
@export var max_live_rounds: int = 1
## Hit flinch while walking (never during the tell, the shot or the reload).
@export var hit_stagger_time: float = 0.35
@export var hit_stagger_cooldown: float = 1.5

@export_group("Presentation")
## The carrier's rig and its looks (C56): rig.json paths sharing one skeleton and the
## clips; each gunner draws the one its entity id picks (rig_path when the list is empty).
@export_file("*.json") var rig_path: String = ""
@export var rig_variants: PackedStringArray = []
## Joints the borrowed rig loses (the Night Guard's baton while the Sidearm Guard has no
## sheet of its own).
@export var strip_joints: PackedStringArray = []
@export_file("*.gd") var clips_script: String = ""
@export var clip_idle: String = "idle"
@export var clip_walk: String = "walk"
## Walking in to range at low ready.
@export var clip_stalk: String = "stalk"
@export var clip_ready: String = "ready"
@export var clip_aim: String = "aim"
@export var clip_fire: String = "fire"
@export var clip_reload: String = "rack"
@export var clip_hit: String = "hit"
## The gun: a prop rig (its own rig.json, sockets "muzzle" and "lamp", optionally a
## joint with role "slide") hung on `gun_joint` at the carrier rig's "gun" socket when it
## has one, else at gun_offset, turned gun_rotation_deg.
@export_file("*.json") var gun_rig_path: String = ""
@export var gun_joint: String = "near_hand"
@export var gun_offset: Vector2 = Vector2(2.6, 4.7)
@export var gun_rotation_deg: float = 90.0
## How far back (px) the slide racks on the reload.
@export var slide_rack_px: float = 3.0
## The two upper arms the aim turns at the shoulder (the whole arm and gun aim, C35).
@export var aim_joints: PackedStringArray = ["near_upper_arm", "far_upper_arm"]
@export var round_scene: PackedScene
@export var voice_notice: PackedStringArray = []
@export var voice_windup: PackedStringArray = []
@export var voice_reload: PackedStringArray = []
@export var voice_hurt: PackedStringArray = []
## A last line cut off by death (caption only, now and then).
@export var voice_death: PackedStringArray = []
@export var sfx_lock: StringName = &""
@export var sfx_fire: StringName = &""
@export var sfx_reload: StringName = &""
@export var sfx_hit: StringName = &"hit_flesh"

const H := 96.0


func approach_speed() -> float:
	return approach_speed_h_per_s * H


func patrol_speed() -> float:
	return patrol_speed_h_per_s * H


func engage_range() -> float:
	return engage_range_h * H


func round_range() -> float:
	return round_range_h * H


func round_speed() -> float:
	return round_speed_h_per_s * H


func round_height() -> float:
	return round_height_h * H


func aim_track_speed() -> float:
	return aim_track_speed_h_per_s * H
