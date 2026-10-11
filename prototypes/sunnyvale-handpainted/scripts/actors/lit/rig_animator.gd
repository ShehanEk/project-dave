extends RefCounted
## Poses a lit cutout rig over time (C35): plays one clip at a time with a
## short crossfade, plus a decaying additive layer for hit jolts. Clips are
## hand-keyed per character (clips_*.gd, degrees) until Mixamo clips are
## converted by tools/art/mixamo_to_rig.py: a converted clip saved as
## <mocap_dir>/<clip>.json replaces the hand-keyed clip of the same name.
##
## Rotations are local, clockwise-positive (Godot 2D), the rig facing right:
## a thigh swinging forward is negative, a knee bending is positive, a
## torso leaning forward is positive. "root" offsets the pelvis (world px);
## the rig's ground lock keeps the lowest sole on the floor.

const DEG := PI / 180.0

var clips: Dictionary = {}
var mocap_dir: String = ""
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


func _init(p_clips: Dictionary = {}, p_mocap_dir: String = "") -> void:
	clips = p_clips
	mocap_dir = p_mocap_dir
	_load_mocap()


## Any converted Mixamo clip in mocap_dir overrides the hand-keyed clip of
## the same name (e.g. walk.json).
func _load_mocap() -> void:
	if mocap_dir == "" or not DirAccess.dir_exists_absolute(mocap_dir):
		return
	for f in DirAccess.get_files_at(mocap_dir):
		if not f.ends_with(".json"):
			continue
		var data = JSON.parse_string(FileAccess.get_file_as_string(mocap_dir.path_join(f)))
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
	return bool(clips[c]["loop"])


func _length(c: String) -> float:
	if _mocap.has(c):
		var m: Dictionary = _mocap[c]
		return float(m["frames"].size() - 1) / float(m["fps"])
	return float(clips[c]["length"])


func sample(c: String, t: float) -> Dictionary:
	if _mocap.has(c):
		var pose := _sample_mocap(_mocap[c], t)
		# Mocap has no baton: keep the hand-keyed baton angle for this clip.
		if clips.has(c) and not pose.has("baton"):
			pose["baton"] = _sample_keys(c, fmod(t, float(clips[c]["length"])) if bool(clips[c]["loop"]) else minf(t, float(clips[c]["length"]))).get("baton", 0.0)
		return pose
	return _sample_keys(c, t)


func _sample_keys(c: String, t: float) -> Dictionary:
	var keys: Array = clips[c]["keys"]
	var n := keys.size()
	var i := 0
	while i < n - 2 and t > float(keys[i + 1][0]):
		i += 1
	var t0: float = keys[i][0]
	var t1: float = keys[i + 1][0]
	var u := clampf((t - t0) / maxf(t1 - t0, 0.0001), 0.0, 1.0)
	var loop: bool = clips[c]["loop"]
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
