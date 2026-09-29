#!/usr/bin/env python3
"""Convert Mixamo motion-capture clips (FBX) into 2D joint-rotation keyframes
for the side-view cutout rig (15 joints, near/far limbs) used by the game.

Runs INSIDE Blender (headless; Blender 5.x bundles the FBX importer):

  Blender -b --python tools/spike/mixamo_to_rig.py -- <input.fbx> <output.json> [options]
  Blender -b --python tools/spike/mixamo_to_rig.py -- <dir of .fbx> <output dir> [options]
  python3 tools/spike/mixamo_to_rig.py --selftest      # pure-math checks, no Blender

Options
  --fps N               output frame rate (default 30); the clip is resampled
                        over the action's frame range (scene range if none)
  --in-place            zero the forward (x) root motion, keep the y bob
  --forward=+x|-x|+y|-y|auto
                        world direction the character faces (default auto:
                        feet at the first frame, cross-checked with the hip
                        line; falls back to -y)
  --hip-height-px N     game-pixel height the rest hip height maps to (51)
  --hip-ref frame0|rest measure that hip height in the first frame (default)
                        or in the armature's rest pose (steadier across clips)
  --foot-offset auto|RAD
                        radians subtracted from both feet (toe-down positive).
                        Mixamo's ankle->toe bone slopes ~20-40 deg toe-down, so a
                        flat-footed pose reads about +0.4 with the default 0; 'auto'
                        subtracts the rest-pose foot slope so flat feet read 0
  --loop-tol RAD        "loop" is true when the first and last frame agree
                        within this many radians on every joint (default 0.05)
  --importer auto|legacy|native
                        auto = import_scene.fbx, else wm.fbx_import

Conventions (match the Godot rig exactly)
  Canvas: x = the character's forward direction (sprite faces right), y DOWN,
  angles in radians, positive = clockwise on screen (Godot).
  Rest directions (all local rotations 0): pelvis/torso/head point UP (0,-1),
  arms and legs (thigh, shin, upper arm, forearm, hand) point DOWN (0,1),
  feet point FORWARD (1,0).
  global_rot(j) = angle(bone_dir) - angle(rest_dir(j));
  local_rot(j)  = wrap_pi(global_rot(j) - global_rot(parent(j))); pelvis local = global.
  Projection: up = world +Z; canvas_x = dot(v, forward), canvas_y = -v.z.
  near = the character's RIGHT side (the camera sees it), far = LEFT.

Mixamo bone -> joint (vector between bone HEADS; prefix "mixamorig:" etc. ignored)
  pelvis Hips>Spine   torso Spine>Neck   head Head>HeadTop_End
  near/far_upper_arm {R,L}Arm>ForeArm   _forearm ForeArm>Hand   _hand Hand>HandMiddle1
  near/far_thigh {R,L}UpLeg>Leg   _shin Leg>Foot   _foot Foot>ToeBase (else Toe_End)
  When the end bone is missing the start bone's head->tail is used instead.
"""
import argparse
import json
import math
import os
import re
import sys
import traceback

try:  # only available inside Blender; the math below runs anywhere
    import bpy
except ImportError:  # pragma: no cover
    bpy = None

# ---------------------------------------------------------------------------
# The rig (single source of truth; keep in step with the Godot side)
# ---------------------------------------------------------------------------

JOINTS = [
    "pelvis", "torso", "head",
    "near_upper_arm", "near_forearm", "near_hand",
    "far_upper_arm", "far_forearm", "far_hand",
    "near_thigh", "near_shin", "near_foot",
    "far_thigh", "far_shin", "far_foot",
]  # parents always precede children

PARENT = {
    "pelvis": None, "torso": "pelvis", "head": "torso",
    "near_upper_arm": "torso", "near_forearm": "near_upper_arm", "near_hand": "near_forearm",
    "far_upper_arm": "torso", "far_forearm": "far_upper_arm", "far_hand": "far_forearm",
    "near_thigh": "pelvis", "near_shin": "near_thigh", "near_foot": "near_shin",
    "far_thigh": "pelvis", "far_shin": "far_thigh", "far_foot": "far_shin",
}

_UP, _DOWN, _FORWARD = (0.0, -1.0), (0.0, 1.0), (1.0, 0.0)  # canvas y is DOWN
REST_DIR = {
    "pelvis": _UP, "torso": _UP, "head": _UP,
    "near_foot": _FORWARD, "far_foot": _FORWARD,
}
for _j in JOINTS:
    REST_DIR.setdefault(_j, _DOWN)
REST_ANGLE = {j: math.atan2(d[1], d[0]) for j, d in REST_DIR.items()}


def _build_segments():
    """joint -> (start bone, candidate end bones); lower-case Mixamo names."""
    seg = {
        "pelvis": ("hips", ("spine",)),
        "torso": ("spine", ("neck",)),
        "head": ("head", ("headtop_end",)),
    }
    for side, s in (("near", "right"), ("far", "left")):
        seg[side + "_upper_arm"] = (s + "arm", (s + "forearm",))
        seg[side + "_forearm"] = (s + "forearm", (s + "hand",))
        seg[side + "_hand"] = (s + "hand", (s + "handmiddle1",))
        seg[side + "_thigh"] = (s + "upleg", (s + "leg",))
        seg[side + "_shin"] = (s + "leg", (s + "foot",))
        seg[side + "_foot"] = (s + "foot", (s + "toebase", s + "toe_end"))
    return seg


SEGMENTS = _build_segments()
FOOT_POINTS = tuple(s + k for s in ("right", "left") for k in ("foot", "toebase", "toe_end"))
HIP_LINE = ("rightupleg", "leftupleg")

DEGENERATE_RATIO = 0.05   # projected length < 5% of 3D length: direction unreliable
MIN_FOOT_HORIZ = 0.25     # foot vector must be at least this horizontal to give a facing
MIN_HIP_HORIZ = 0.25


class ConversionError(Exception):
    """Expected, user-facing failure (printed without a traceback)."""


def log(msg):
    print("[mixamo_to_rig] " + msg, flush=True)


# ---------------------------------------------------------------------------
# Pure math (no Blender): world-space vectors -> canvas angles
# ---------------------------------------------------------------------------

def wrap_pi(a):
    return (a + math.pi) % (2.0 * math.pi) - math.pi


def _sub(a, b):
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def _norm(v):
    return math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])


def _r(x, digits):
    return round(x, digits) + 0.0  # + 0.0 turns -0.0 into 0.0


def _num(x, digits):
    """Fixed-notation JSON number that always has a decimal point (never 1e-05)."""
    t = ("%.*f" % (digits, x)).rstrip("0")
    if t.endswith("."):
        t += "0"
    return "0.0" if t == "-0.0" else t


_PREFIX = re.compile(r"^mixamorig\d*[:_.\-]?", re.I)


def bone_key(name):
    """'mixamorig1:LeftUpLeg', 'Armature|mixamorig:LeftUpLeg', 'LeftUpLeg.001' -> 'leftupleg'."""
    n = name.split("|")[-1].split(":")[-1]
    n = _PREFIX.sub("", n)
    n = re.sub(r"\.\d{3}$", "", n)
    return n.lower()


def build_plan(available):
    """Resolve which bones define each joint. -> (plan, missing start bones, joints using head->tail)."""
    plan, missing, fallback = {}, [], []
    for joint in JOINTS:
        start, ends = SEGMENTS[joint]
        if start not in available:
            missing.append(start)
            continue
        end = next((e for e in ends if e in available), None)
        if end is None:
            fallback.append(joint)
        plan[joint] = (start, end)
    return plan, missing, fallback


def needed_keys(plan, available):
    keys = {"hips"} | set(HIP_LINE) | {k for k in FOOT_POINTS if k in available}
    for start, end in plan.values():
        keys.add(start)
        if end:
            keys.add(end)
    return keys


def joint_vectors(pose, plan):
    """pose: {bone key: (head xyz, tail xyz)} in world space -> {joint: world vector}."""
    out = {}
    for joint, (start, end) in plan.items():
        head, tail = pose[start]
        out[joint] = _sub(pose[end][0] if end else tail, head)
    return out


def canvas_angle(v, fwd):
    """Angle of world vector v in the side view (Godot: y down, clockwise +), or
    None when v points (almost) along the view axis and has no usable direction."""
    cx = v[0] * fwd[0] + v[1] * fwd[1]
    cy = -v[2]
    l3, l2 = _norm(v), math.hypot(cx, cy)
    if l3 < 1e-12 or l2 < DEGENERATE_RATIO * l3:
        return None
    return math.atan2(cy, cx)


def solve_frame(vecs, fwd, prev_global=None, foot_offset=0.0):
    """{joint: world vector} -> (local rotations, global rotations, degenerate joints).
    A degenerate joint keeps its previous global rotation (0 on the first frame).
    foot_offset (radians) is subtracted from both feet's global rotation."""
    prev_global = prev_global or {}
    glob, degenerate = {}, []
    for j in JOINTS:
        a = canvas_angle(vecs[j], fwd)
        if a is None:
            degenerate.append(j)
            glob[j] = prev_global.get(j, 0.0)
        else:
            glob[j] = wrap_pi(a - REST_ANGLE[j] - (foot_offset if j.endswith("_foot") else 0.0))
    local = {}
    for j in JOINTS:
        p = PARENT[j]
        local[j] = wrap_pi(glob[j] - glob[p]) if p else wrap_pi(glob[j])
    return local, glob, degenerate


def _horizontal_unit(v, min_len):
    h = math.hypot(v[0], v[1])
    if h < min_len or h < 1e-12:
        return None
    return (v[0] / h, v[1] / h)


def detect_forward(pose):
    """Facing direction (unit vector in the XY plane) from a single pose.
    Primary: mean of the foot vectors Foot->ToeBase projected to XY. Cross-check
    and fallback: the hip line (left hip -> right hip) rotated a quarter turn
    about +Z (forward = up x right). -> (fwd or None, source, warning or None)."""
    feet = None
    vecs = []
    for s in ("right", "left"):
        foot = pose.get(s + "foot")
        toe = pose.get(s + "toebase") or pose.get(s + "toe_end")
        if foot and toe:
            vecs.append(_sub(toe[0], foot[0]))
        elif foot:
            vecs.append(_sub(foot[1], foot[0]))
    if vecs:
        tot = tuple(sum(c) for c in zip(*vecs))
        mean_len = sum(_norm(v) for v in vecs) / len(vecs)
        feet = _horizontal_unit(tot, MIN_FOOT_HORIZ * mean_len)
    hips = None
    r, l = pose.get(HIP_LINE[0]), pose.get(HIP_LINE[1])
    if r and l:
        d = _sub(r[0], l[0])
        hips = _horizontal_unit((-d[1], d[0], 0.0), MIN_HIP_HORIZ * _norm(d))
    if feet:
        warn = None
        if hips and feet[0] * hips[0] + feet[1] * hips[1] < 0.5:
            warn = ("feet and hip line disagree about the facing direction; using the feet "
                    "- pass --forward=... if the result looks mirrored")
        return feet, "feet@frame0", warn
    if hips:
        return hips, "hip line@frame0", "foot vectors unusable at the first frame"
    return None, "none", "could not detect the facing direction"


def foot_slope(pose, plan, fwd):
    """Mean canvas angle of the two feet in a pose (rest pose: how far toe-down a flat foot reads)."""
    angles = []
    for j in ("near_foot", "far_foot"):
        if j in plan:
            a = canvas_angle(joint_vectors(pose, {j: plan[j]})[j], fwd)
            if a is not None:
                angles.append(wrap_pi(a - REST_ANGLE[j]))
    return sum(angles) / len(angles) if angles else None


def hip_height(pose):
    """Hips head z above the lowest foot point (foot, toe base, toe end heads)."""
    zs = [pose[k][0][2] for k in FOOT_POINTS if k in pose]
    if not zs:
        raise ConversionError("no foot bones found to measure the hip height")
    return pose["hips"][0][2] - min(zs)


def resample_times(start, end, src_fps, out_fps):
    """Source-frame numbers to sample so the clip plays at out_fps."""
    step = src_fps / out_fps
    n = int(math.floor((end - start) / step + 1e-6)) + 1
    return [start + i * step for i in range(max(n, 1))]


def is_loop(first, last, tol):
    return max(abs(wrap_pi(first[j] - last[j])) for j in JOINTS) <= tol


FORWARD_AXES = {"+x": (1.0, 0.0), "-x": (-1.0, 0.0), "+y": (0.0, 1.0), "-y": (0.0, -1.0)}


# ---------------------------------------------------------------------------
# Blender side
# ---------------------------------------------------------------------------

def _operator_exists(module, name):
    try:
        getattr(getattr(bpy.ops, module), name).get_rna_type()
        return True
    except Exception:
        return False


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)  # empty scene, fresh fps/range


def import_fbx(path, importer="auto"):
    legacy = importer in ("auto", "legacy")
    native = importer in ("auto", "native")
    if legacy and not _operator_exists("import_scene", "fbx"):
        try:  # the add-on may have been switched off in the user's preferences
            import addon_utils
            addon_utils.enable("io_scene_fbx", default_set=False, persistent=False)
        except Exception:
            pass
    if legacy and _operator_exists("import_scene", "fbx"):
        used = "import_scene.fbx"
        result = bpy.ops.import_scene.fbx(filepath=path, automatic_bone_orientation=True,
                                          ignore_leaf_bones=False, use_anim=True)
    elif native and _operator_exists("wm", "fbx_import"):
        used = "wm.fbx_import"
        result = bpy.ops.wm.fbx_import(filepath=path, ignore_leaf_bones=False, use_anim=True)
    else:
        raise ConversionError(
            "No FBX importer available in this Blender (%s). Expected bpy.ops.import_scene.fbx "
            "(the bundled 'io_scene_fbx' add-on: Preferences > Add-ons > Import-Export: FBX) or "
            "bpy.ops.wm.fbx_import." % getattr(bpy.app, "version_string", "unknown version"))
    if "FINISHED" not in result:
        raise ConversionError("%s did not finish (%s): %s" % (used, sorted(result), path))
    return used


def pick_armature():
    """The imported armature with the most Mixamo bones. -> (object, {bone key: pose bone name})."""
    best = None
    required = {s for s, _ in SEGMENTS.values()}
    for ob in bpy.data.objects:
        if ob.type != "ARMATURE":
            continue
        keys = {}
        for pb in ob.pose.bones:
            keys.setdefault(bone_key(pb.name), pb.name)
        score = len(required & set(keys))
        if best is None or score > best[0]:
            best = (score, ob, keys)
    if best is None:
        raise ConversionError("the FBX contains no armature (skeleton)")
    return best[1], best[2]


def clip_range(scene, arm):
    act = arm.animation_data.action if arm.animation_data else None
    if act is not None:
        lo, hi = act.frame_range
        return float(lo), float(hi), act.name
    return float(scene.frame_start), float(scene.frame_end), None


def sample_pose(scene, arm, frame, name_of):
    """Evaluated world-space (head, tail) of the wanted pose bones at a source frame."""
    whole = int(math.floor(frame + 1e-6))
    sub = frame - whole
    scene.frame_set(whole, subframe=sub if sub > 1e-6 else 0.0)
    ev = arm.evaluated_get(bpy.context.evaluated_depsgraph_get())
    mw = ev.matrix_world
    pose = {}
    for key, bone in name_of.items():
        pb = ev.pose.bones[bone]
        pose[key] = (tuple(mw @ pb.head), tuple(mw @ pb.tail))
    return pose


def rest_pose(arm, name_of):
    mw = arm.matrix_world
    pose = {}
    for key, bone in name_of.items():
        b = arm.data.bones[bone]
        pose[key] = (tuple(mw @ b.head_local), tuple(mw @ b.tail_local))
    return pose


def write_json(path, clip):
    """Valid JSON, one frame per line so clips stay diffable; numbers in fixed notation."""
    head = ",\n".join('"%s": %s' % (k, json.dumps(clip[k])) for k in
                      ("name", "source", "fps", "frame_count", "loop", "joints", "hip_height_px"))
    rows = ",\n".join(
        '{"root": [%s, %s], "rot": {%s}}' % (
            _num(f["root"][0], 4), _num(f["root"][1], 4),
            ", ".join('"%s": %s' % (j, _num(f["rot"][j], 5)) for j in clip["joints"]))
        for f in clip["frames"])
    with open(path, "w") as fh:
        fh.write("{\n%s,\n\"frames\": [\n%s\n]\n}\n" % (head, rows))


def convert_file(src, dst, args):
    name = os.path.splitext(os.path.basename(src))[0]
    reset_scene()
    importer = import_fbx(os.path.abspath(src), args.importer)
    scene = bpy.context.scene
    arm, bones = pick_armature()
    if len(bpy.data.actions) > 1:
        log("WARNING: %s: the file holds %d actions (%s); using the one assigned to the armature"
            % (name, len(bpy.data.actions), ", ".join(a.name for a in bpy.data.actions)))

    plan, missing, fallback = build_plan(set(bones))
    if missing:
        raise ConversionError(
            "%s: not a Mixamo skeleton? missing bones %s; armature '%s' has e.g. %s"
            % (name, ", ".join(missing), arm.name, ", ".join(sorted(bones.values())[:6])))
    for j in fallback:
        log("WARNING: %s: end bone for '%s' not found, using head->tail of %s"
            % (name, j, plan[j][0]))
    name_of = {k: bones[k] for k in needed_keys(plan, set(bones))}

    lo, hi, action = clip_range(scene, arm)
    if action is None:
        log("WARNING: %s: no animation found, using the scene frame range %g..%g" % (name, lo, hi))
    src_fps = scene.render.fps / (scene.render.fps_base or 1.0)
    if src_fps <= 0:
        src_fps = 30.0
    times = resample_times(lo, hi, src_fps, args.fps)
    poses = [sample_pose(scene, arm, t, name_of) for t in times]

    # facing direction
    if args.forward == "auto":
        fwd, how, warn = detect_forward(poses[0])
        if fwd is None:
            fwd, how = FORWARD_AXES["-y"], "fallback -y"
        if warn:
            log("WARNING: %s: %s" % (name, warn))
    else:
        fwd, how = FORWARD_AXES[args.forward], "--forward=" + args.forward

    # scale: rest hip height -> --hip-height-px
    rest = rest_pose(arm, name_of)
    h0 = hip_height(poses[0])
    h_rest = hip_height(rest)
    height = h0 if args.hip_ref == "frame0" else h_rest
    if height <= 1e-9:
        raise ConversionError("%s: hip height is %g; cannot scale (try --hip-ref rest)" % (name, height))
    if h_rest > 1e-9 and abs(h0 - h_rest) > 0.1 * h_rest:
        log("WARNING: %s: hip height at frame 0 (%.4g) differs from the rest pose (%.4g) by %d%%; "
            "scale is taken from %s (use --hip-ref rest for a scale shared by all clips)"
            % (name, h0, h_rest, round(100 * abs(h0 - h_rest) / h_rest), args.hip_ref))
    scale = args.hip_height_px / height

    # feet: the ankle->toe bone slopes toe-down even when the sole is flat
    slope = foot_slope(rest, plan, fwd)
    foot_off = (slope or 0.0) if args.foot_offset == "auto" else args.foot_offset
    if foot_off == 0.0 and slope is not None and abs(slope) > 0.1:
        log("NOTE: %s: the rest-pose feet slope %.2f rad (toe-down +), so a flat-footed pose reads about that "
            "on near_foot/far_foot; --foot-offset auto (or %.2f) makes flat feet read 0" % (name, slope, slope))

    frames, prev, degenerate = [], {}, {}
    hips0 = poses[0]["hips"][0]
    for pose in poses:
        local, prev, bad = solve_frame(joint_vectors(pose, plan), fwd, prev, foot_off)
        for j in bad:
            degenerate[j] = degenerate.get(j, 0) + 1
        d = _sub(pose["hips"][0], hips0)
        rx = 0.0 if args.in_place else scale * (d[0] * fwd[0] + d[1] * fwd[1])
        frames.append({"root": [_r(rx, 4), _r(-scale * d[2], 4)],
                       "rot": {j: _r(local[j], 5) for j in JOINTS}})
    for j, n in sorted(degenerate.items()):
        log("WARNING: %s: %s points along the view axis in %d/%d frames (direction held)"
            % (name, j, n, len(frames)))

    loop = len(frames) > 1 and is_loop(frames[0]["rot"], frames[-1]["rot"], args.loop_tol)
    fps = int(args.fps) if float(args.fps).is_integer() else args.fps
    clip = {"name": name, "source": "mixamo", "fps": fps, "frame_count": len(frames),
            "loop": loop, "joints": JOINTS, "hip_height_px": float(args.hip_height_px),
            "frames": frames}
    write_json(dst, clip)
    log("OK %s -> %s | %d frames @ %g fps (source %g..%g @ %.4g fps, %s) | loop=%s | "
        "forward=(%.3f, %.3f) [%s] | hip %.4g -> %.4g px/unit | foot offset %.3f | end root=(%.2f, %.2f) px"
        " | via %s"
        % (os.path.basename(src), dst, len(frames), args.fps, lo, hi, src_fps,
           action or "no action", loop, fwd[0], fwd[1], how, height, scale, foot_off,
           frames[-1]["root"][0], frames[-1]["root"][1], importer))
    return clip


# ---------------------------------------------------------------------------
# Command line
# ---------------------------------------------------------------------------

def _forward_arg(text):
    t = text.strip().lower()
    if t == "auto":
        return t
    if t in ("x", "y"):
        t = "+" + t
    if t not in FORWARD_AXES:
        raise argparse.ArgumentTypeError("expected +x, -x, +y, -y or auto, got %r" % text)
    return t


def _foot_offset_arg(text):
    if text.strip().lower() == "auto":
        return "auto"
    try:
        return float(text)
    except ValueError:
        raise argparse.ArgumentTypeError("expected auto or a number of radians, got %r" % text)


def parse_args(argv):
    argv = list(argv)
    for flag in ("--forward", "--foot-offset"):  # allow "--forward -y" as well as "--forward=-y"
        for i, a in enumerate(argv[:-1]):
            if a == flag:
                argv[i:i + 2] = [flag + "=" + argv[i + 1]]
                break
    p = argparse.ArgumentParser(
        prog="mixamo_to_rig.py", description="Mixamo FBX -> 2D rig joint rotations (run inside Blender).")
    p.add_argument("input", nargs="?", help="input .fbx, or a directory of .fbx files")
    p.add_argument("output", nargs="?", help="output .json, or a directory (batch mode)")
    p.add_argument("--fps", type=float, default=30.0, help="output frame rate (default 30)")
    p.add_argument("--in-place", action="store_true", help="zero the forward root motion, keep the y bob")
    p.add_argument("--forward", type=_forward_arg, default="auto", metavar="+x|-x|+y|-y|auto",
                   help="world direction the character faces (default: auto-detect, else -y)")
    p.add_argument("--hip-height-px", type=float, default=51.0, help="pixels the rest hip height maps to (51)")
    p.add_argument("--hip-ref", choices=("frame0", "rest"), default="frame0",
                   help="measure the hip height in the first frame (default) or in the armature's rest pose")
    p.add_argument("--foot-offset", type=_foot_offset_arg, default=0.0, metavar="auto|RAD",
                   help="radians subtracted from both feet (toe-down +); auto = rest-pose foot slope (default 0)")
    p.add_argument("--loop-tol", type=float, default=0.05,
                   help="loop=true when first and last frame agree within this many radians (0.05)")
    p.add_argument("--importer", choices=("auto", "legacy", "native"), default="auto",
                   help="auto = import_scene.fbx, else wm.fbx_import")
    p.add_argument("--selftest", action="store_true", help="run the pure-math checks and exit")
    args = p.parse_args(argv)
    if args.fps <= 0 or args.hip_height_px <= 0:
        p.error("--fps and --hip-height-px must be positive")
    return p, args


def collect_jobs(inp, out):
    if os.path.isdir(inp):
        files = sorted(f for f in os.listdir(inp) if f.lower().endswith(".fbx"))
        if not files:
            raise ConversionError("no .fbx files in " + inp)
        if out.lower().endswith(".json"):
            raise ConversionError("batch mode needs an output DIRECTORY, got " + out)
        os.makedirs(out, exist_ok=True)
        return [(os.path.join(inp, f), os.path.join(out, os.path.splitext(f)[0] + ".json"))
                for f in files]
    if not os.path.isfile(inp):
        raise ConversionError("input not found: " + inp)
    if os.path.isdir(out):
        out = os.path.join(out, os.path.splitext(os.path.basename(inp))[0] + ".json")
    else:
        os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    return [(inp, out)]


def script_args():
    argv = sys.argv
    return argv[argv.index("--") + 1:] if "--" in argv else argv[1:]


def main(argv=None):
    parser, args = parse_args(script_args() if argv is None else argv)
    if args.selftest:
        return selftest()
    if not args.input or not args.output:
        parser.print_usage()
        log("ERROR: need <input> and <output>")
        return 2
    if bpy is None:
        log("ERROR: run this inside Blender: Blender -b --python %s -- <input.fbx> <output.json>"
            % os.path.basename(__file__))
        return 2
    try:
        jobs = collect_jobs(args.input, args.output)
    except ConversionError as e:
        log("ERROR: %s" % e)
        return 1
    failed = 0
    for src, dst in jobs:
        try:
            convert_file(src, dst, args)
        except ConversionError as e:
            failed += 1
            log("ERROR: %s: %s" % (os.path.basename(src), e))
        except Exception:
            failed += 1
            log("ERROR: %s: unexpected failure" % os.path.basename(src))
            traceback.print_exc()
    log("done: %d/%d converted" % (len(jobs) - failed, len(jobs)))
    return 1 if failed else 0


# ---------------------------------------------------------------------------
# Self-test: the sign conventions and helpers, checked without Blender
# ---------------------------------------------------------------------------

def selftest():
    n = [0]

    def check(cond, what):
        n[0] += 1
        if not cond:
            raise AssertionError("selftest failed: " + what)

    def near(a, b, eps=1e-9):
        return abs(a - b) < eps

    d = math.radians
    check(near(wrap_pi(3 * math.pi / 2), -math.pi / 2) and near(wrap_pi(-4.0), 2 * math.pi - 4.0), "wrap_pi")
    check(_r(-0.000001, 5) == 0.0 and math.copysign(1.0, _r(-0.000001, 5)) > 0, "no negative zero")
    for raw in ("mixamorig:Hips", "mixamorig1:Hips", "mixamorig9:Hips", "Hips", "mixamorig_Hips",
                "Armature|mixamorig:Hips", "mixamorig:Hips.001"):
        check(bone_key(raw) == "hips", "bone_key(%r)" % raw)
    check(bone_key("mixamorig:LeftHandMiddle1") == "lefthandmiddle1" and
          bone_key("mixamorig:RightToe_End") == "righttoe_end", "bone_key keeps digits and _")
    check(len(JOINTS) == 15 and set(JOINTS) == set(PARENT) == set(SEGMENTS) == set(REST_DIR), "joint tables")
    check(all(PARENT[j] is None or JOINTS.index(PARENT[j]) < JOINTS.index(j) for j in JOINTS), "parents first")

    # explicit sign checks, character facing world -Y (Mixamo FBX imported into Blender)
    F = (0.0, -1.0)

    def pose_vectors(**over):
        v = {"pelvis": (0, 0, .1), "torso": (0, 0, .4), "head": (0, 0, .2),
             "near_upper_arm": (0, 0, -.3), "near_forearm": (0, 0, -.25), "near_hand": (0, 0, -.1),
             "far_upper_arm": (0, 0, -.3), "far_forearm": (0, 0, -.25), "far_hand": (0, 0, -.1),
             "near_thigh": (0, 0, -.42), "near_shin": (0, 0, -.4), "near_foot": (0, -.13, 0),
             "far_thigh": (0, 0, -.42), "far_shin": (0, 0, -.4), "far_foot": (0, -.13, 0)}
        v.update(over)
        return v

    loc, _, bad = solve_frame(pose_vectors(), F)
    check(not bad and all(near(loc[j], 0.0) for j in JOINTS), "rest pose gives all-zero rotations")
    loc, _, _ = solve_frame(pose_vectors(near_thigh=(0, -.42 * math.sin(d(25)), -.42 * math.cos(d(25)))), F)
    check(near(loc["near_thigh"], -d(25)) and loc["near_thigh"] < 0, "thigh swung FORWARD is NEGATIVE")
    check(near(loc["far_thigh"], 0.0) and near(loc["near_shin"], d(25)), "shin stays vertical: local = +25 deg")
    loc, _, _ = solve_frame(pose_vectors(near_shin=(0, .4 * math.sin(d(30)), -.4 * math.cos(d(30)))), F)
    check(near(loc["near_shin"], d(30)) and loc["near_shin"] > 0, "knee bend (foot goes back) is POSITIVE")
    loc, _, _ = solve_frame(pose_vectors(near_forearm=(0, -.25 * math.sin(d(40)), -.25 * math.cos(d(40)))), F)
    check(near(loc["near_forearm"], -d(40)) and loc["near_forearm"] < 0, "elbow bent FORWARD is NEGATIVE")
    loc, _, _ = solve_frame(pose_vectors(pelvis=(0, -.1 * math.sin(d(10)), .1 * math.cos(d(10)))), F)
    check(near(loc["pelvis"], d(10)) and near(loc["torso"], -d(10)), "forward lean +, child is relative")
    loc, _, _ = solve_frame(pose_vectors(near_foot=(0, 0, -.13)), F)
    check(near(loc["near_foot"], math.pi / 2), "toe pointing down = +90 deg")
    # lateral (toward/away from camera) components must not matter
    lat = pose_vectors(near_thigh=(0, -.42 * math.sin(d(25)), -.42 * math.cos(d(25))))
    lat = {j: (v[0] + .3, v[1], v[2]) for j, v in lat.items()}
    loc2, _, _ = solve_frame(lat, F)
    check(near(loc2["near_thigh"], -d(25)), "lateral offsets are projected away")
    # a vector along the view axis is degenerate: previous global rotation is held
    loc, glob, bad = solve_frame(pose_vectors(near_hand=(.1, 0, 0)), F, {"near_hand": .5})
    check(bad == ["near_hand"] and near(glob["near_hand"], .5), "degenerate joint holds its last rotation")
    # rotating the whole character about Z with its forward vector changes nothing
    for turn in (0, 90, 180, -90, 33):
        c, s = math.cos(d(turn)), math.sin(d(turn))
        rot = lambda v: (v[0] * c - v[1] * s, v[0] * s + v[1] * c, v[2])
        base = pose_vectors(near_thigh=(0, -.2, -.3), near_shin=(0, .1, -.4))
        a, _, _ = solve_frame(base, F)
        b, _, _ = solve_frame({j: rot(v) for j, v in base.items()}, rot((F[0], F[1], 0)))
        check(all(near(a[j], b[j], 1e-9) for j in JOINTS), "yaw invariance at %d deg" % turn)
    # mirrored forward flips the limb signs
    a, _, _ = solve_frame(pose_vectors(near_thigh=(0, -.3, -.3)), (0.0, -1.0))
    b, _, _ = solve_frame(pose_vectors(near_thigh=(0, -.3, -.3)), (0.0, 1.0))
    check(near(a["near_thigh"], -b["near_thigh"]) and a["near_thigh"] < 0, "opposite forward mirrors x")

    # facing detection from a pose (feet primary, hip line fallback)
    def stand(turn, reach=.13, drop=.05):
        """Standing pose facing world -Y (its right side is -X), then turned about Z."""
        c, s = math.cos(d(turn)), math.sin(d(turn))
        rot = lambda v: (v[0] * c - v[1] * s, v[0] * s + v[1] * c, v[2])
        p = {}
        for side, x in (("right", -.09), ("left", .09)):
            p[side + "upleg"] = (rot((x, 0, .9)), rot((x, 0, .5)))
            p[side + "foot"] = (rot((x, 0, .09)), rot((x, -.05, .05)))
            p[side + "toebase"] = (rot((x, -reach, .09 - drop)), rot((x, -reach - .07, .03)))
        return p

    for turn, want in ((0, (0, -1)), (90, (1, 0)), (180, (0, 1)), (-90, (-1, 0))):
        f, how, warn = detect_forward(stand(turn))
        check(f and near(f[0], want[0], 1e-9) and near(f[1], want[1], 1e-9) and how == "feet@frame0" and not warn,
              "detect_forward turn=%d" % turn)
    f, how, warn = detect_forward(stand(30))
    check(near(f[0], math.sin(d(30))) and near(f[1], -math.cos(d(30))), "detect_forward arbitrary yaw")
    f, how, warn = detect_forward(stand(0, reach=0.0, drop=.13))  # toes straight below the ankles
    check(how == "hip line@frame0" and near(f[1], -1.0) and warn, "feet degenerate -> hip line")
    nohips = stand(0, reach=0.0, drop=.13)
    del nohips["rightupleg"], nohips["leftupleg"]
    check(detect_forward(nohips)[0] is None, "nothing usable -> None")
    swapped = stand(0)
    swapped["rightupleg"], swapped["leftupleg"] = swapped["leftupleg"], swapped["rightupleg"]
    f, how, warn = detect_forward(swapped)
    check(f and near(f[1], -1.0) and warn and "disagree" in warn, "feet win, disagreement is reported")

    pose = {"hips": ((0, 0, .95), (0, 0, 1)), "rightfoot": ((0, 0, .1), (0, 0, 0)),
            "lefttoe_end": ((0, 0, .02), (0, 0, 0))}
    check(near(hip_height(pose), .93), "hip height uses the lowest foot point")

    check(_num(0.1047200, 5) == "0.10472" and _num(0.0, 5) == "0.0" and _num(-0.000001, 5) == "0.0" and
          _num(-0.3, 5) == "-0.3" and _num(100.0, 4) == "100.0" and _num(0.00003, 5) == "0.00003" and
          "e" not in _num(1e-9 + 3e-5, 5), "_num fixed notation, always a decimal point")
    loc0, _, _ = solve_frame(pose_vectors(near_foot=(0, -.13, -.0473)), F)
    loc1, _, _ = solve_frame(pose_vectors(near_foot=(0, -.13, -.0473)), F, None, d(20))
    check(near(loc0["near_foot"], d(20), 1e-3) and near(loc1["near_foot"], 0.0, 1e-3) and
          near(loc1["far_foot"], -d(20), 1e-9) and near(loc1["pelvis"], 0.0), "foot_offset shifts only the feet")
    rest = {"rightfoot": ((0, 0, .09), (0, 0, 0)), "righttoebase": ((0, -.13, .09 - .0473), (0, 0, 0)),
            "leftfoot": ((0, 0, .09), (0, 0, 0)), "lefttoebase": ((0, -.13, .09 - .0473), (0, 0, 0))}
    plan_f = {"near_foot": ("rightfoot", "righttoebase"), "far_foot": ("leftfoot", "lefttoebase")}
    check(near(foot_slope(rest, plan_f, F), d(20), 1e-3), "foot_slope of a toe-down foot")
    check(len(resample_times(1, 31, 30, 30)) == 31 and len(resample_times(1, 31, 30, 24)) == 25 and
          len(resample_times(1, 31, 30, 60)) == 61 and resample_times(5, 5, 30, 30) == [5] and
          len(resample_times(1, 31, 30000 / 1001.0, 30)) == 31, "resample_times counts")
    check(near(resample_times(1, 31, 30, 24)[1], 2.25), "resample_times spacing")

    a = {j: 0.0 for j in JOINTS}
    b = dict(a, near_thigh=0.04)
    c2 = dict(a, near_thigh=0.06)
    d2 = dict(a, head=math.pi - 0.01)
    e = dict(a, head=-math.pi + 0.01)
    check(is_loop(a, b, 0.05) and not is_loop(a, c2, 0.05) and is_loop(d2, e, 0.05), "loop tolerance incl. wrap")

    plan, missing, fb = build_plan({"hips", "spine", "neck", "head"})
    check("rightarm" in missing and plan["pelvis"] == ("hips", "spine") and plan["head"] == ("head", None)
          and "head" in fb, "build_plan reports missing bones and head->tail fallback")
    log("selftest OK (%d checks)" % n[0])
    return 0


if __name__ == "__main__":
    sys.exit(main())
