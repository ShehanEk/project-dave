extends RefCounted
## Poses the lit cutout rig over time (C35 lit-cutout test): plays one clip
## at a time with a short crossfade, plus a decaying additive layer for hit
## jolts. Clips are hand-keyed placeholders (degrees, below) until Mixamo
## clips are converted by tools/spike/mixamo_to_rig.py: a converted clip
## saved as res://spike/lit_cutout/mocap/<clip>.json replaces the hand-keyed
## clip of the same name automatically.
##
## Rotations are local, clockwise-positive (Godot 2D), the rig facing right:
## a thigh swinging forward is negative, a knee bending is positive, a
## torso leaning forward is positive. "root" offsets the pelvis (world px);
## the rig's ground lock keeps the lowest sole on the floor.

const DEG := PI / 180.0
const MOCAP_DIR := "res://spike/lit_cutout/mocap"

const IDLE_A := {"pelvis": 0, "torso": 2, "head": -2, "near_upper_arm": 6, "near_forearm": -28, "near_hand": 8,
		"baton": -48, "far_upper_arm": -4, "far_forearm": -14, "near_thigh": -3, "near_shin": 4,
		"far_thigh": 4, "far_shin": 3}
const IDLE_B := {"pelvis": 0, "torso": 3.4, "head": -3.6, "near_upper_arm": 7.5, "near_forearm": -30,
		"near_hand": 8, "baton": -46, "far_upper_arm": -5.5, "far_forearm": -16, "near_thigh": -3,
		"near_shin": 4, "far_thigh": 4, "far_shin": 3, "root": Vector2(0, 0.3)}

const CLIPS := {
	"idle": {"length": 3.2, "loop": true, "keys": [[0.0, IDLE_A], [1.6, IDLE_B], [3.2, IDLE_A]]},
	"walk": {"length": 1.0, "loop": true, "keys": [
		[0.0, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": -24, "near_shin": 6, "far_thigh": 20,
			"far_shin": 14, "near_upper_arm": 10, "near_forearm": -30, "near_hand": 8, "baton": -48,
			"far_upper_arm": -14, "far_forearm": -22, "near_foot": 10, "far_foot": -12}],
		[0.25, {"pelvis": 1, "torso": 3, "head": -3, "near_thigh": -4, "near_shin": 5, "far_thigh": -12,
			"far_shin": 52, "near_upper_arm": 4, "near_forearm": -30, "near_hand": 8, "baton": -48,
			"far_upper_arm": -4, "far_forearm": -18, "far_foot": -8}],
		[0.5, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": 20, "near_shin": 14, "far_thigh": -24,
			"far_shin": 6, "near_upper_arm": -4, "near_forearm": -34, "near_hand": 8, "baton": -48,
			"far_upper_arm": 14, "far_forearm": -14, "near_foot": -12, "far_foot": 10}],
		[0.75, {"pelvis": 1, "torso": 3, "head": -3, "near_thigh": -12, "near_shin": 52, "far_thigh": -4,
			"far_shin": 5, "near_upper_arm": 2, "near_forearm": -30, "near_hand": 8, "baton": -48,
			"far_upper_arm": 4, "far_forearm": -16, "near_foot": -8}],
		[1.0, {"pelvis": 2, "torso": 3, "head": -3, "near_thigh": -24, "near_shin": 6, "far_thigh": 20,
			"far_shin": 14, "near_upper_arm": 10, "near_forearm": -30, "near_hand": 8, "baton": -48,
			"far_upper_arm": -14, "far_forearm": -22, "near_foot": 10, "far_foot": -12}]]},
	# Walking at the hero with the baton up and ready.
	"stalk": {"length": 0.78, "loop": true, "keys": [
		[0.0, {"pelvis": 4, "torso": 9, "head": -8, "near_thigh": -26, "near_shin": 8, "far_thigh": 20,
			"far_shin": 16, "near_upper_arm": -24, "near_forearm": -62, "near_hand": 4, "baton": -62,
			"far_upper_arm": -22, "far_forearm": -30, "near_foot": 10, "far_foot": -12}],
		[0.195, {"pelvis": 3, "torso": 9, "head": -8, "near_thigh": -4, "near_shin": 5, "far_thigh": -12,
			"far_shin": 54, "near_upper_arm": -26, "near_forearm": -60, "near_hand": 4, "baton": -62,
			"far_upper_arm": -14, "far_forearm": -30, "far_foot": -8}],
		[0.39, {"pelvis": 4, "torso": 9, "head": -8, "near_thigh": 20, "near_shin": 16, "far_thigh": -26,
			"far_shin": 8, "near_upper_arm": -22, "near_forearm": -64, "near_hand": 4, "baton": -62,
			"far_upper_arm": -6, "far_forearm": -28, "near_foot": -12, "far_foot": 10}],
		[0.585, {"pelvis": 3, "torso": 9, "head": -8, "near_thigh": -12, "near_shin": 54, "far_thigh": -4,
			"far_shin": 5, "near_upper_arm": -26, "near_forearm": -60, "near_hand": 4, "baton": -62,
			"far_upper_arm": -14, "far_forearm": -30, "near_foot": -8}],
		[0.78, {"pelvis": 4, "torso": 9, "head": -8, "near_thigh": -26, "near_shin": 8, "far_thigh": 20,
			"far_shin": 16, "near_upper_arm": -24, "near_forearm": -62, "near_hand": 4, "baton": -62,
			"far_upper_arm": -22, "far_forearm": -30, "near_foot": 10, "far_foot": -12}]]},
	# Baton raised overhead (held at the end).
	"windup": {"length": 0.5, "loop": false, "keys": [
		[0.0, {"pelvis": 3, "torso": 6, "head": -6, "near_upper_arm": -40, "near_forearm": -60, "near_hand": 4,
			"baton": -60, "far_upper_arm": -20, "far_forearm": -30, "near_thigh": -6, "near_shin": 6,
			"far_thigh": 6, "far_shin": 6}],
		[0.3, {"pelvis": -2, "torso": -8, "head": 4, "near_upper_arm": -178, "near_forearm": -46,
			"near_hand": -12, "baton": -26, "far_upper_arm": -66, "far_forearm": -38, "near_thigh": 10,
			"near_shin": 10, "far_thigh": -16, "far_shin": 12, "root": Vector2(-1.5, 0)}],
		[0.5, {"pelvis": -3, "torso": -11, "head": 6, "near_upper_arm": -192, "near_forearm": -42,
			"near_hand": -12, "baton": -28, "far_upper_arm": -72, "far_forearm": -40, "near_thigh": 12,
			"near_shin": 10, "far_thigh": -18, "far_shin": 12, "root": Vector2(-2.5, 0)}]]},
	# The committed overhead strike, stepping in.
	"swing": {"length": 0.22, "loop": false, "keys": [
		[0.0, {"pelvis": -3, "torso": -11, "head": 6, "near_upper_arm": -192, "near_forearm": -42,
			"near_hand": -12, "baton": -28, "far_upper_arm": -72, "far_forearm": -40, "near_thigh": 12,
			"near_shin": 10, "far_thigh": -18, "far_shin": 12, "root": Vector2(-2.5, 0)}],
		[0.1, {"pelvis": 3, "torso": 12, "head": -2, "near_upper_arm": -120, "near_forearm": -30,
			"near_hand": -4, "baton": -30, "far_upper_arm": 0, "far_forearm": -30, "near_thigh": -12,
			"near_shin": 16, "far_thigh": 4, "far_shin": 12, "root": Vector2(2.0, 0)}],
		[0.22, {"pelvis": 6, "torso": 22, "head": -4, "near_upper_arm": -64, "near_forearm": -20,
			"near_hand": 6, "baton": -36, "far_upper_arm": 26, "far_forearm": -22, "near_thigh": -28,
			"near_shin": 24, "far_thigh": 16, "far_shin": 16, "root": Vector2(5.0, 0)}]]},
	# Winded after the swing: the punish window.
	"recover": {"length": 1.2, "loop": true, "keys": [
		[0.0, {"pelvis": 8, "torso": 24, "head": 8, "near_upper_arm": -14, "near_forearm": -22,
			"near_hand": 6, "baton": -70, "far_upper_arm": -26, "far_forearm": -46, "far_hand": -20,
			"near_thigh": -16, "near_shin": 28, "far_thigh": 6, "far_shin": 24, "root": Vector2(4.0, 0)}],
		[0.6, {"pelvis": 8, "torso": 29, "head": 12, "near_upper_arm": -10, "near_forearm": -18,
			"near_hand": 6, "baton": -74, "far_upper_arm": -30, "far_forearm": -50, "far_hand": -20,
			"near_thigh": -18, "near_shin": 30, "far_thigh": 6, "far_shin": 26, "root": Vector2(4.0, 0)}],
		[1.2, {"pelvis": 8, "torso": 24, "head": 8, "near_upper_arm": -14, "near_forearm": -22,
			"near_hand": 6, "baton": -70, "far_upper_arm": -26, "far_forearm": -46, "far_hand": -20,
			"near_thigh": -16, "near_shin": 28, "far_thigh": 6, "far_shin": 24, "root": Vector2(4.0, 0)}]]},
}

var clip: String = "idle"
var time: float = 0.0
var speed: float = 1.0
var _from: Dictionary = {}
var _last: Dictionary = {}
var _blend: float = 1.0
var _blend_time: float = 0.15
var _additive: Dictionary = {}
var _additive_t: float = 0.0
var _additive_len: float = 0.25
var _mocap: Dictionary = {}


func _init() -> void:
	_load_mocap()


## Any converted Mixamo clip in MOCAP_DIR overrides the hand-keyed clip of
## the same name (e.g. walk.json).
func _load_mocap() -> void:
	if not DirAccess.dir_exists_absolute(MOCAP_DIR):
		return
	for f in DirAccess.get_files_at(MOCAP_DIR):
		if not f.ends_with(".json"):
			continue
		var data = JSON.parse_string(FileAccess.get_file_as_string(MOCAP_DIR.path_join(f)))
		if data is Dictionary and data.has("frames") and data.has("fps"):
			_mocap[f.get_basename()] = data


func has_mocap(clip_name: String) -> bool:
	return _mocap.has(clip_name)


func play(clip_name: String, restart: bool = true, blend_time: float = 0.15) -> void:
	if clip_name == clip and not restart:
		return
	_from = _last.duplicate()
	_blend = 0.0 if blend_time > 0.0 else 1.0
	_blend_time = maxf(blend_time, 0.001)
	clip = clip_name
	time = 0.0


func is_finished() -> bool:
	return not _loops(clip) and time >= _length(clip)


## A decaying jolt on top of the clip (a hit): radians per joint.
func jolt(offsets: Dictionary, duration: float = 0.25) -> void:
	_additive = offsets
	_additive_t = duration
	_additive_len = duration


func advance(delta: float) -> Dictionary:
	time += delta * speed
	if _loops(clip):
		time = fposmod(time, _length(clip))
	else:
		time = minf(time, _length(clip))
	var pose := sample(clip, time)
	if _blend < 1.0:
		_blend = minf(1.0, _blend + delta / _blend_time)
		var k := _blend * _blend * (3.0 - 2.0 * _blend)
		pose = _lerp_pose(_from, pose, k)
	if _additive_t > 0.0:
		_additive_t = maxf(0.0, _additive_t - delta)
		var w := _additive_t / _additive_len
		w = w * w
		for j in _additive:
			pose[j] = pose.get(j, 0.0) + float(_additive[j]) * w
	_last = pose
	return pose


func _loops(c: String) -> bool:
	if _mocap.has(c):
		return bool(_mocap[c].get("loop", true))
	return bool(CLIPS[c]["loop"])


func _length(c: String) -> float:
	if _mocap.has(c):
		var m: Dictionary = _mocap[c]
		return float(m["frames"].size() - 1) / float(m["fps"])
	return float(CLIPS[c]["length"])


func sample(c: String, t: float) -> Dictionary:
	if _mocap.has(c):
		var pose := _sample_mocap(_mocap[c], t)
		# Mocap has no baton: keep the hand-keyed baton angle for this clip.
		if CLIPS.has(c) and not pose.has("baton"):
			pose["baton"] = _sample_keys(c, fmod(t, float(CLIPS[c]["length"])) if bool(CLIPS[c]["loop"]) else minf(t, float(CLIPS[c]["length"]))).get("baton", 0.0)
		return pose
	return _sample_keys(c, t)


func _sample_keys(c: String, t: float) -> Dictionary:
	var keys: Array = CLIPS[c]["keys"]
	var n := keys.size()
	var i := 0
	while i < n - 2 and t > float(keys[i + 1][0]):
		i += 1
	var t0: float = keys[i][0]
	var t1: float = keys[i + 1][0]
	var u := clampf((t - t0) / maxf(t1 - t0, 0.0001), 0.0, 1.0)
	var loop: bool = CLIPS[c]["loop"]
	var p0: Dictionary = keys[_idx(i - 1, n, loop)][1]
	var p1: Dictionary = keys[i][1]
	var p2: Dictionary = keys[i + 1][1]
	var p3: Dictionary = keys[_idx(i + 2, n, loop)][1]
	var out := {}
	var names := {}
	for p in [p0, p1, p2, p3]:
		for k in p:
			names[k] = true
	for k in names:
		if k == "root":
			out[k] = _cr_v(p0.get(k, Vector2.ZERO), p1.get(k, Vector2.ZERO), p2.get(k, Vector2.ZERO), p3.get(k, Vector2.ZERO), u)
		else:
			out[k] = _cr(float(p0.get(k, 0.0)), float(p1.get(k, 0.0)), float(p2.get(k, 0.0)), float(p3.get(k, 0.0)), u) * DEG
	return out


func _idx(i: int, n: int, loop: bool) -> int:
	if loop:
		# the last key duplicates the first; wrap over the n-1 unique keys
		return posmod(i, n - 1)
	return clampi(i, 0, n - 1)


static func _cr(a: float, b: float, c: float, d: float, u: float) -> float:
	var u2 := u * u
	var u3 := u2 * u
	return 0.5 * ((2.0 * b) + (-a + c) * u + (2.0 * a - 5.0 * b + 4.0 * c - d) * u2 + (-a + 3.0 * b - 3.0 * c + d) * u3)


static func _cr_v(a: Vector2, b: Vector2, c: Vector2, d: Vector2, u: float) -> Vector2:
	return Vector2(_cr(a.x, b.x, c.x, d.x, u), _cr(a.y, b.y, c.y, d.y, u))


func _sample_mocap(m: Dictionary, t: float) -> Dictionary:
	var frames: Array = m["frames"]
	var f := t * float(m["fps"])
	var i0 := clampi(int(floorf(f)), 0, frames.size() - 1)
	var i1 := clampi(i0 + 1, 0, frames.size() - 1)
	var u := f - floorf(f)
	var a: Dictionary = frames[i0]
	var b: Dictionary = frames[i1]
	var out := {}
	for k in a["rot"]:
		out[k] = lerp_angle(float(a["rot"][k]), float(b["rot"].get(k, a["rot"][k])), u)
	# Gameplay moves the body; keep only the vertical bob from root motion.
	var ra: Array = a["root"]
	var rb: Array = b["root"]
	out["root"] = Vector2(0.0, lerpf(float(ra[1]), float(rb[1]), u))
	return out


static func _lerp_pose(a: Dictionary, b: Dictionary, k: float) -> Dictionary:
	var out := {}
	var names := {}
	for p in [a, b]:
		for n in p:
			names[n] = true
	for n in names:
		if n == "root":
			out[n] = (a.get(n, Vector2.ZERO) as Vector2).lerp(b.get(n, Vector2.ZERO), k)
		else:
			# Hand keys are continuous (an arm raised overhead is -192°, not
			# +168°), so blend them straight; only a wrapped mocap angle more
			# than half a turn away takes the short way round.
			var va := float(a.get(n, 0.0))
			var vb := float(b.get(n, 0.0))
			out[n] = lerp_angle(va, vb, k) if absf(vb - va) > PI * 1.5 else lerpf(va, vb, k)
	return out
