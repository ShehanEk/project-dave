#!/usr/bin/env python3
"""Synthetic Mixamo-named test clip for tools/art/mixamo_to_rig.py.

Builds (inside Blender) an armature with Mixamo bone names ("mixamorig:" prefix)
in a T-pose facing -Y, keys a 1-second walk-like cycle (thighs +-25 deg about the
X axis, knees bending, arms counter-swinging, pelvis/torso/head lean, hip bob and
travel), exports it to FBX and writes the expected local 2D angles.

  Blender -b --factory-startup --python tools/art/make_test_armature.py -- \
      --out-dir DIR [--name test_walk] [--facing -y|+y|+x|-x] [--frames 31] \
      [--prefix mixamorig:] [--object-scale 1.0] [--omit HeadTop_End,...]
      [--tpose-arms] [--no-anim]
      -> DIR/<name>.fbx and DIR/<name>.expected.json

  python3 tools/art/make_test_armature.py --compare DIR/x.expected.json DIR/x.json
      -> table of expected vs converted angles at a few frames, sign checks, PASS/FAIL

  python3 tools/art/make_test_armature.py --run-suite [--blender PATH] [--out-dir DIR]
      -> builds several clips, runs the converter on them (spawning Blender) and checks everything

The expected angles are derived analytically from the keyed motion (they never go
through the converter's projection code), and the generator asserts its own poses
physically, e.g. a thigh with a negative canvas angle really puts the knee toward
world -Y = forward. Rig convention: canvas x = forward, y down, radians, positive =
clockwise on screen; rest = pelvis/torso/head up, limbs down, feet forward.
"""
import argparse
import json
import math
import os
import re
import subprocess
import sys
import tempfile
import traceback

HERE = os.path.dirname(os.path.abspath(__file__))
CONVERTER = os.path.join(HERE, "mixamo_to_rig.py")
DEFAULT_BLENDER = "/Applications/Blender.app/Contents/MacOS/Blender"

# The 15 rig joints (deliberately NOT imported from the converter: the test must not share its code).
JOINTS = [
    "pelvis", "torso", "head",
    "near_upper_arm", "near_forearm", "near_hand",
    "far_upper_arm", "far_forearm", "far_hand",
    "near_thigh", "near_shin", "near_foot",
    "far_thigh", "far_shin", "far_foot",
]

# ---------------------------------------------------------------------------
# Skeleton and motion model (pure Python)
# ---------------------------------------------------------------------------

D = math.radians
BASE_FOOT = D(20.0)     # the foot bone slopes 20 deg toe-down at rest (canvas +)
ARM_SPLAY = D(12.0)     # arms hang 12 deg outward from vertical: lateral part must be ignored
LEG_SPLAY = D(3.0)
FRAME_RATE = 30
HIP_HEIGHT_PX = 51.0
MARKER_FRAMES = 9       # frames shown by --compare

# joint rest positions in metres: x lateral (+X = character's LEFT), -Y forward, z up
REST = {"Hips": (0, 0, .95), "Spine": (0, 0, 1.03), "Spine1": (0, 0, 1.15), "Spine2": (0, 0, 1.27),
        "Neck": (0, 0, 1.45), "Head": (0, 0, 1.52), "HeadTop_End": (0, 0, 1.74)}
PARENT_OF = {"Hips": None, "Spine": "Hips", "Spine1": "Spine", "Spine2": "Spine1", "Neck": "Spine2",
             "Head": "Neck", "HeadTop_End": "Head"}
ROT_JOINT = {"Hips": "pelvis", "Spine": "torso", "Spine1": "torso", "Spine2": "torso", "Neck": "torso",
             "Head": "head", "HeadTop_End": "head"}
_toe_drop = math.tan(BASE_FOOT)
for _S, _sx, _side in (("Left", 1, "far"), ("Right", -1, "near")):
    REST.update({
        _S + "Shoulder": (_sx * .03, 0, 1.40), _S + "Arm": (_sx * .17, 0, 1.42),
        _S + "ForeArm": (_sx * .45, 0, 1.42), _S + "Hand": (_sx * .70, 0, 1.42),
        _S + "HandMiddle1": (_sx * .79, 0, 1.42),
        _S + "UpLeg": (_sx * .09, 0, .92), _S + "Leg": (_sx * .09, 0, .50), _S + "Foot": (_sx * .09, 0, .09),
        _S + "ToeBase": (_sx * .09, -.13, .09 - .13 * _toe_drop),
        _S + "Toe_End": (_sx * .09, -.20, .09 - .20 * _toe_drop)})
    PARENT_OF.update({
        _S + "Shoulder": "Spine2", _S + "Arm": _S + "Shoulder", _S + "ForeArm": _S + "Arm",
        _S + "Hand": _S + "ForeArm", _S + "HandMiddle1": _S + "Hand",
        _S + "UpLeg": "Hips", _S + "Leg": _S + "UpLeg", _S + "Foot": _S + "Leg",
        _S + "ToeBase": _S + "Foot", _S + "Toe_End": _S + "ToeBase"})
    ROT_JOINT.update({
        _S + "Shoulder": "torso", _S + "Arm": _side + "_upper_arm", _S + "ForeArm": _side + "_forearm",
        _S + "Hand": _side + "_hand", _S + "HandMiddle1": _side + "_hand",
        _S + "UpLeg": _side + "_thigh", _S + "Leg": _side + "_shin",
        _S + "Foot": _side + "_foot", _S + "ToeBase": _side + "_foot", _S + "Toe_End": _side + "_foot"})
FOOT_BONES = [s + k for s in ("Right", "Left") for k in ("Foot", "ToeBase", "Toe_End")]
YAW = {"-y": 0.0, "+x": 90.0, "+y": 180.0, "-x": -90.0}   # armature object rotation about Z


def local_angles(phi):
    """Expected local rotations of the 15 joints at walk phase phi (rig convention)."""
    L = {"pelvis": D(4) + D(2) * math.cos(2 * phi),        # forward lean is positive
         "torso": D(3) + D(1.5) * math.sin(2 * phi),
         "head": D(-2) + D(2) * math.sin(phi)}
    for side, ph, elbow in (("near", 0.0, (35, 10, .5)), ("far", math.pi, (25, 8, 1.2))):
        s = math.sin(phi + ph)
        L[side + "_thigh"] = -D(25) * s                    # s > 0 swings FORWARD -> negative
        L[side + "_shin"] = D(30) + D(25) * math.sin(phi + ph - .6)   # knee bend >= 5 deg -> positive
        L[side + "_foot"] = BASE_FOOT + D(10) * math.sin(phi + ph + 1.0)
        L[side + "_upper_arm"] = D(20) * s                 # counter-swings against the same-side leg
        L[side + "_forearm"] = -(D(elbow[0]) + D(elbow[1]) * math.sin(phi + elbow[2]))  # bent forward -> negative
        L[side + "_hand"] = D(6) * math.sin(2 * (phi + ph) + .3)
    return L


def cumulative(L):
    """Global rotation about the lateral axis per joint. The foot's rest slope is not a rotation."""
    G = {"pelvis": L["pelvis"]}
    G["torso"] = G["pelvis"] + L["torso"]
    G["head"] = G["torso"] + L["head"]
    for s in ("near", "far"):
        G[s + "_thigh"] = G["pelvis"] + L[s + "_thigh"]
        G[s + "_shin"] = G[s + "_thigh"] + L[s + "_shin"]
        G[s + "_foot"] = G[s + "_shin"] + L[s + "_foot"] - BASE_FOOT
        G[s + "_upper_arm"] = G["torso"] + L[s + "_upper_arm"]
        G[s + "_forearm"] = G[s + "_upper_arm"] + L[s + "_forearm"]
        G[s + "_hand"] = G[s + "_forearm"] + L[s + "_hand"]
    return G


def root_motion(k):
    """(forward metres, up metres, sideways metres) of the hips at frame index k."""
    phi = 2 * math.pi * k / FRAME_RATE
    return 1.2 * k / FRAME_RATE, .025 * math.sin(2 * phi), .01 * math.sin(phi)


def wrap_pi(a):
    return (a + math.pi) % (2 * math.pi) - math.pi


def expected_loop(rows, tol=1e-6):
    return len(rows) > 1 and max(abs(wrap_pi(rows[0][j] - rows[-1][j])) for j in JOINTS) <= tol


# ---------------------------------------------------------------------------
# Blender: build, animate, export
# ---------------------------------------------------------------------------

def build(args):
    import bpy
    from mathutils import Matrix, Vector

    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.fps, scene.render.fps_base = FRAME_RATE, 1.0
    omit = {o for o in args.omit.split(",") if o}
    unknown = omit - set(REST)
    if unknown:
        raise SystemExit("unknown --omit bones: %s" % sorted(unknown))
    keys = [k for k in REST if k not in omit]                 # parents come before children
    if any(PARENT_OF[k] in omit for k in keys):
        raise SystemExit("--omit may only remove leaf bones")

    def tail_of(key):    # from the FULL skeleton so omitted leaves still leave a sensible tail
        kids = [c for c, p in PARENT_OF.items() if p == key]
        if kids:
            return Vector(REST[kids[0]])
        v = Vector(REST[key]) - Vector(REST[PARENT_OF[key]])
        return Vector(REST[key]) + v.normalized() * .05

    arm_data = bpy.data.armatures.new("TestArmature")
    arm = bpy.data.objects.new("Armature", arm_data)
    scene.collection.objects.link(arm)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    for key in keys:
        eb = arm_data.edit_bones.new(args.prefix + key)
        eb.head, eb.tail = REST[key], tail_of(key)
        if PARENT_OF[key]:
            eb.parent = arm_data.edit_bones[args.prefix + PARENT_OF[key]]
    bpy.ops.object.mode_set(mode="OBJECT")
    rest = {k: arm_data.bones[args.prefix + k].matrix_local.copy() for k in keys}
    rest_rot = {k: rest[k].to_3x3().to_4x4() for k in keys}

    def R(axis, a):
        return Matrix.Rotation(a, 3, axis)

    def static(key):     # T-pose -> arms hang down (splayed outward), legs slightly apart
        sx = -1 if key.startswith("Right") else 1
        base = key[5:] if sx < 0 else key[4:]
        if base in ("Arm", "ForeArm", "Hand", "HandMiddle1"):
            if args.tpose_arms:      # arms stay along the lateral axis: no usable side-view direction
                return Matrix.Identity(3)
            return R("Y", sx * (math.pi / 2 - ARM_SPLAY))
        if base in ("UpLeg", "Leg"):
            return R("Y", -sx * LEG_SPLAY)
        return Matrix.Identity(3)

    n = args.frames
    prev_q, heads, rows = {}, [], []
    for k in range(n):
        phi = 2 * math.pi * k / FRAME_RATE
        L = local_angles(phi)
        G = cumulative(L)
        fwd, up, side = root_motion(k)
        head, rot, mat = {}, {}, {}
        for key in keys:
            rot[key] = R("X", G[ROT_JOINT[key]]) @ static(key)
            par = PARENT_OF[key]
            if par is None:
                head[key] = Vector(REST[key]) + Vector((side, -fwd, up))
            else:
                head[key] = head[par] + rot[par] @ (Vector(REST[key]) - Vector(REST[par]))
            mat[key] = Matrix.Translation(head[key]) @ rot[key].to_4x4() @ rest_rot[key]
        check_physical(head, G, skip_arms=args.tpose_arms)
        for key in keys:
            pb = arm.pose.bones[args.prefix + key]
            par = PARENT_OF[key]
            if par is None:
                basis = rest[key].inverted() @ mat[key]
            else:
                basis = rest[key].inverted() @ rest[par] @ mat[par].inverted() @ mat[key]
            q = basis.to_quaternion()
            if key in prev_q and q.dot(prev_q[key]) < 0:
                q.negate()
            prev_q[key] = q
            pb.rotation_mode = "QUATERNION"
            if par is not None and basis.to_translation().length > 1e-5:
                raise SystemExit("internal error: non-root bone %s needs a translation" % key)
            if args.no_anim and k > 0:
                continue                 # static pose = frame 0, nothing keyed
            pb.rotation_quaternion = q
            if par is None:
                pb.location = basis.to_translation()
            if not args.no_anim:
                pb.keyframe_insert("rotation_quaternion", frame=k + 1)
                if par is None:
                    pb.keyframe_insert("location", frame=k + 1)
        heads.append(head)
        rows.append(L)

    if n > 1 and not args.no_anim:      # forward is world -Y: the hips must end up in front of where they began
        assert heads[-1]["Hips"].y < heads[0]["Hips"].y, "the walk must travel toward -Y (forward)"
        assert max(h["Hips"].z for h in heads) > heads[0]["Hips"].z, "the bob must go up (+Z)"

    # the animation must evaluate to the poses we computed
    for k in sorted({0} if args.no_anim else {0, n // 2, n - 1}):
        scene.frame_set(k + 1)
        bpy.context.view_layer.update()
        for key in keys:
            got = arm.pose.bones[args.prefix + key].head
            if (got - heads[k][key]).length > 1e-4:
                raise SystemExit("pose mismatch at frame %d bone %s: %s vs %s" % (k, key, tuple(got), tuple(heads[k][key])))

    scene.frame_start, scene.frame_end = 1, n
    scene.frame_set(1)
    arm.rotation_euler = (0.0, 0.0, D(YAW[args.facing]))
    arm.scale = (args.object_scale,) * 3

    os.makedirs(args.out_dir, exist_ok=True)
    fbx = os.path.join(args.out_dir, args.name + ".fbx")
    result = bpy.ops.export_scene.fbx(
        filepath=fbx, object_types={"ARMATURE"}, add_leaf_bones=False, bake_anim=not args.no_anim,
        bake_anim_use_all_bones=True, bake_anim_use_nla_strips=False, bake_anim_use_all_actions=False,
        bake_anim_force_startend_keying=True, bake_anim_simplify_factor=0.0,
        primary_bone_axis="Y", secondary_bone_axis="X", axis_forward="-Z", axis_up="Y")
    if "FINISHED" not in result:
        raise SystemExit("FBX export failed: %s" % result)

    # expected values: angles straight from the motion model, root from our own FK (metres -> px)
    h0 = heads[0]
    floor = min(h0[k][2] for k in FOOT_BONES if k in h0)
    px_per_unit = HIP_HEIGHT_PX / (h0["Hips"][2] - floor)
    yaw = D(YAW[args.facing])
    frames = []
    for k in range(n):
        dh = heads[k]["Hips"] - h0["Hips"]
        frames.append({"frame": k, "rot": {j: round(rows[k][j], 6) for j in JOINTS},
                       "root": [round(px_per_unit * -dh.y, 4), round(-px_per_unit * dh.z, 4)]})
    expected = {"name": args.name, "fps": FRAME_RATE, "frame_count": n, "joints": JOINTS,
                "expected_loop": expected_loop(rows), "hip_height_px": HIP_HEIGHT_PX,
                "facing": [round(math.sin(yaw), 6), round(-math.cos(yaw), 6)],
                "px_per_unit_armature_space": round(px_per_unit, 6),
                "report_frames": sorted({round(i * (n - 1) / (MARKER_FRAMES - 1)) for i in range(MARKER_FRAMES)}),
                "frames": frames}
    path = os.path.join(args.out_dir, args.name + ".expected.json")
    with open(path, "w") as fh:
        json.dump(expected, fh, indent=1)
    print("[make_test_armature] wrote %s (%d bones, %d frames, facing %s, object scale %g, prefix %r) and %s"
          % (fbx, len(keys), n, args.facing, args.object_scale, args.prefix, path))


def check_physical(head, G, skip_arms=False):
    """Anchor the generator to the real world (forward = -Y, up = +Z), not to the converter."""
    def forward_of(a, b):           # how far bone b's head lies in front of bone a's head
        return -(head[b][1] - head[a][1])

    def hanging(a, b, joint):       # hanging limb: a negative global angle means the tip is in front
        if a in head and b in head:
            assert (forward_of(a, b) > 0) == (G[joint] < 0), "%s: forward swing must be negative" % joint

    def leaning(a, b, joint):       # upright bone: a positive global angle means the tip leans forward
        if a in head and b in head:
            assert (forward_of(a, b) > 0) == (G[joint] > 0), "%s: forward lean must be positive" % joint

    for S, side in (("Right", "near"), ("Left", "far")):
        hanging(S + "UpLeg", S + "Leg", side + "_thigh")
        hanging(S + "Leg", S + "Foot", side + "_shin")
        if not skip_arms:
            hanging(S + "Arm", S + "ForeArm", side + "_upper_arm")
            hanging(S + "ForeArm", S + "Hand", side + "_forearm")
        if S + "ToeBase" in head:       # toe below the ankle <=> canvas angle in (0, pi)
            below = head[S + "ToeBase"][2] < head[S + "Foot"][2]
            assert below == (0 < BASE_FOOT + G[side + "_foot"] < math.pi), side + "_foot slope"
    leaning("Hips", "Spine", "pelvis")
    leaning("Spine", "Neck", "torso")
    leaning("Head", "HeadTop_End", "head")


# ---------------------------------------------------------------------------
# Compare converter output with the expected angles (no Blender needed)
# ---------------------------------------------------------------------------

def compare(exp_path, act_path, tol=1e-3, tol_interp=0.02, tol_root=0.05, out=print):
    """-> (problems, metrics). tol applies to frames that coincide with an expected frame,
    tol_interp to in-between frames (fps changes)."""
    with open(exp_path) as fh:
        exp = json.load(fh)
    with open(act_path) as fh:
        act = json.load(fh)
    problems, m = [], {}
    joints = exp["joints"]
    if act.get("joints") != joints or len(joints) != 15:
        problems.append("joint list is %s, expected 15 joints %s" % (act.get("joints"), joints))
    if act.get("source") != "mixamo" or act.get("hip_height_px") != exp["hip_height_px"]:
        problems.append("source/hip_height_px wrong: %r %r" % (act.get("source"), act.get("hip_height_px")))
    e_fps, a_fps = exp["fps"], act["fps"]
    want_n = int(math.floor((exp["frame_count"] - 1) / e_fps * a_fps + 1e-6)) + 1
    if act["frame_count"] != want_n or len(act["frames"]) != want_n:
        problems.append("frame_count %s (frames %d), expected %d" % (act["frame_count"], len(act["frames"]), want_n))
    if act["loop"] != exp["expected_loop"]:
        problems.append("loop is %s, expected %s" % (act["loop"], exp["expected_loop"]))
    m.update(joints=len(act.get("joints", [])), frame_count=act["frame_count"], loop=act["loop"], fps=a_fps)

    E = exp["frames"]
    worst = {"exact": [0.0, ""], "interp": [0.0, ""], "root_exact": [0.0, ""], "root_interp": [0.0, ""]}
    for i, fr in enumerate(act["frames"]):
        pos = i * e_fps / a_fps
        k0 = int(math.floor(pos + 1e-9))
        frac = pos - k0 if pos - k0 > 1e-6 else 0.0
        if k0 + (1 if frac else 0) >= len(E):
            continue
        kind = "interp" if frac else "exact"
        for j in joints:
            want = E[k0]["rot"][j] if not frac else (1 - frac) * E[k0]["rot"][j] + frac * E[k0 + 1]["rot"][j]
            err = abs(wrap_pi(fr["rot"][j] - want))
            if err > worst[kind][0]:
                worst[kind] = [err, "%s@out-frame %d" % (j, i)]
            if err > (tol_interp if frac else tol):
                problems.append("%s frame %d: got %.5f want %.5f (err %.5f)" % (j, i, fr["rot"][j], want, err))
        for c in (0, 1):
            want = E[k0]["root"][c] if not frac else (1 - frac) * E[k0]["root"][c] + frac * E[k0 + 1]["root"][c]
            err = abs(fr["root"][c] - want)
            if err > worst["root_" + kind][0]:
                worst["root_" + kind] = [err, "root[%d]@out-frame %d" % (c, i)]
            if err > (2 * tol_root if frac else tol_root):
                problems.append("root[%d] frame %d: got %.4f want %.4f px" % (c, i, fr["root"][c], want))
    m["max_rot_err_rad"] = round(worst["exact"][0], 6)
    m["max_rot_err_where"] = worst["exact"][1]
    m["max_rot_err_interp_rad"] = round(worst["interp"][0], 6)
    m["max_root_err_px"] = round(max(worst["root_exact"][0], worst["root_interp"][0]), 4)

    # sign checks on the converted data itself (independent of the expected table); a check only
    # applies when the expected clip really contains that motion (a half cycle has no backward swing)
    rot = lambda j: [f["rot"][j] for f in act["frames"]]
    thigh_e = [f["rot"]["near_thigh"] for f in E]
    fwd_k, back_k = thigh_e.index(min(thigh_e)), thigh_e.index(max(thigh_e))

    def actual_at(k, j):
        i = round(k * a_fps / e_fps)
        return act["frames"][i]["rot"][j] if 0 <= i < len(act["frames"]) else None

    signs = {}
    if min(thigh_e) < -0.2:
        signs["near_thigh at max forward swing (want < 0)"] = actual_at(fwd_k, "near_thigh")
        signs["near_upper_arm when near thigh is forward (want > 0)"] = actual_at(fwd_k, "near_upper_arm")
    if max(thigh_e) > 0.2:
        signs["near_thigh at max backward swing (want > 0)"] = actual_at(back_k, "near_thigh")
    signs["max near_forearm over clip (want < 0: elbow bent forward)"] = max(rot("near_forearm"))
    signs["max far_forearm over clip (want < 0)"] = max(rot("far_forearm"))
    signs["min near_shin over clip (want > 0: knee bent)"] = min(rot("near_shin"))
    signs["min far_shin over clip (want > 0)"] = min(rot("far_shin"))
    for label, value in signs.items():
        good = value is not None and ((value < 0) if "want <" in label else (value > 0))
        if not good:
            problems.append("sign check failed: %s = %s" % (label, value))
    m["signs"] = {k: (None if v is None else round(v, 4)) for k, v in signs.items()}

    out("clip %s: %d joints, %d frames @ %g fps, loop=%s (expected %s)"
        % (act.get("name"), len(act.get("joints", [])), act["frame_count"], a_fps, act["loop"], exp["expected_loop"]))
    show = [j for j in ("near_thigh", "far_thigh", "near_shin", "near_upper_arm", "near_forearm", "far_forearm",
                        "near_foot", "pelvis") if j in joints]
    cols = [k for k in exp["report_frames"] if abs(k * a_fps / e_fps - round(k * a_fps / e_fps)) < 1e-6]
    out("expected (e) vs converted (c) local rotations in radians (source frame index of the 30 fps clip):")
    out("%-15s" % "frame" + "".join("%9d" % k for k in cols))
    for j in show:
        out("%-12s e " % j + "".join("%9.4f" % E[k]["rot"][j] for k in cols))
        out("%-12s c " % "" + "".join("%9.4f" % actual_at(k, j) for k in cols))
    out("max |rot error| on matching frames %.6f rad (%s); in-between frames %.6f rad; max root error %.4f px"
        % (worst["exact"][0], worst["exact"][1], worst["interp"][0], m["max_root_err_px"]))
    for label, value in signs.items():
        out("  sign: %s = %s" % (label, None if value is None else round(value, 4)))
    out("RESULT %s%s" % ("PASS" if not problems else "FAIL", "" if not problems else "\n  " + "\n  ".join(problems[:12])))
    return problems, m


# ---------------------------------------------------------------------------
# Suite: build clips, convert them with Blender, check everything
# ---------------------------------------------------------------------------

def run_suite(blender, out_dir):
    import shutil
    os.makedirs(out_dir, exist_ok=True)
    tally = []

    def case(name, ok, detail=""):
        tally.append(ok)
        print("%s  %s%s" % ("PASS" if ok else "FAIL", name, ("  [" + detail + "]") if detail else ""), flush=True)

    def blender_run(script, *args):
        cmd = [blender, "-b", "--factory-startup", "--python", script, "--"] + list(args)
        p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        return p.returncode, p.stdout

    def build_clip(name, *extra):
        code, text = blender_run(os.path.abspath(__file__), "--out-dir", out_dir, "--name", name, *extra)
        if code != 0:
            print(text[-1500:])
        return code == 0

    def convert(src, dst, *extra):
        code, text = blender_run(CONVERTER, src, dst, *extra)
        return code, text

    def path(*p):
        return os.path.join(out_dir, *p)

    def load(p):
        with open(p) as fh:
            return json.load(fh)

    def fwd_of(text):
        mo = re.search(r"forward=\(([-\d.]+), ([-\d.]+)\) \[([^\]]+)\]", text)
        return (float(mo.group(1)), float(mo.group(2)), mo.group(3)) if mo else None

    def quiet_compare(exp, act, **kw):
        blank = {"max_rot_err_rad": float("nan"), "max_rot_err_where": "?", "max_root_err_px": float("nan"),
                 "max_rot_err_interp_rad": float("nan"), "frame_count": 0, "loop": None, "signs": {}}
        try:
            return compare(path(exp), path(act), out=lambda s: None, **kw)
        except (OSError, ValueError, KeyError) as e:
            return ["compare failed: %s" % e], blank

    # 0. converter self-test (pure math, plain python)
    p = subprocess.run([sys.executable, "-B", CONVERTER, "--selftest"], stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, universal_newlines=True)
    case("converter --selftest (pure math, no Blender)", p.returncode == 0, p.stdout.strip().split("] ")[-1])
    code, text = blender_run(CONVERTER, "--selftest")
    case("converter --selftest also runs inside Blender", code == 0 and "selftest OK" in text)
    p = subprocess.run([sys.executable, "-B", CONVERTER], stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                       universal_newlines=True)
    case("no arguments -> usage and exit 2", p.returncode == 2 and "usage:" in p.stdout)

    # 1. the main clip, converted with the exact documented command
    ok = build_clip("test_walk")
    case("build test_walk (-Y, 31 frames, physical self-checks passed)", ok)
    code, text = convert(path("test_walk.fbx"), path("test_walk.json"))
    problems, m = quiet_compare("test_walk.expected.json", "test_walk.json")
    f = fwd_of(text)
    case("walk: 15 joints, 31 frames, loop=true, rotations match expected", code == 0 and not problems,
         "max err %.2g rad at %s; root err %.3g px" % (m["max_rot_err_rad"], m["max_rot_err_where"], m["max_root_err_px"]))
    case("walk: forward auto-detected as -Y from the feet", f is not None and abs(f[0]) < 1e-6 and abs(f[1] + 1) < 1e-6
         and f[2] == "feet@frame0", str(f))
    sg = m["signs"]
    case("walk: signs (thigh fwd<0, knee>0, elbow<0)", bool(sg) and not any("sign check" in x for x in problems),
         "thigh fwd %s, knee min %s, elbow max %s" % (
             sg.get("near_thigh at max forward swing (want < 0)"), sg.get("min near_shin over clip (want > 0: knee bent)"),
             sg.get("max near_forearm over clip (want < 0: elbow bent forward)")))
    walk = load(path("test_walk.json")) if os.path.exists(path("test_walk.json")) else None
    if walk is None:
        case("walk output exists", False)
        print("\nSUITE: %d/%d checks passed" % (sum(tally), len(tally)))
        return 1
    case("walk: hip_height_px 51.0, name and root start at (0, 0)", walk["hip_height_px"] == 51.0
         and walk["name"] == "test_walk" and walk["frames"][0]["root"] == [0.0, 0.0])
    raw = open(path("test_walk.json")).read()
    case("walk: numbers are in fixed notation (no 1e-05) and rot values have <= 5 decimals",
         not re.search(r"[0-9][eE][-+]?[0-9]", raw) and not re.search(r"\.[0-9]{6,}", raw))
    case("walk: prints a NOTE about the rest-pose foot slope (default --foot-offset 0)",
         "NOTE: test_walk: the rest-pose feet slope" in text)

    # 2. forward override: same result for -y, mirrored for +y
    convert(path("test_walk.fbx"), path("w_fneg.json"), "--forward", "-y")
    convert(path("test_walk.fbx"), path("w_fpos.json"), "--forward=+y")
    a, b, c = walk, load(path("w_fneg.json")), load(path("w_fpos.json"))
    case("--forward -y (space form) == auto", a["frames"] == b["frames"])
    mirrored = all(abs(fa["rot"][j] + fc["rot"][j]) < 1e-4 for fa, fc in zip(a["frames"], c["frames"])
                   for j in JOINTS if not j.endswith("_foot"))
    feet = all(abs(wrap_pi(math.pi - fa["rot"][j]) - fc["rot"][j]) < 1e-4 for fa, fc in zip(a["frames"], c["frames"])
               for j in ("near_foot", "far_foot"))
    rx = all(abs(fa["root"][0] + fc["root"][0]) < 1e-3 and abs(fa["root"][1] - fc["root"][1]) < 1e-3
             for fa, fc in zip(a["frames"], c["frames"]))
    t8 = (a["frames"][8]["rot"]["near_thigh"], c["frames"][8]["rot"]["near_thigh"])
    case("--forward=+y mirrors x: limb rotations and root x flip sign, feet -> pi - foot", mirrored and feet and rx,
         "near_thigh f8: %.4f -> %.4f" % t8)

    # 3. in-place, hip-ref, native importer
    convert(path("test_walk.fbx"), path("w_inplace.json"), "--in-place")
    ip = load(path("w_inplace.json"))
    case("--in-place zeroes root x, keeps the y bob", all(f["root"][0] == 0.0 for f in ip["frames"])
         and [f["root"][1] for f in ip["frames"]] == [f["root"][1] for f in a["frames"]]
         and max(abs(f["root"][1]) for f in ip["frames"]) > 0.5,
         "max |y bob| %.2f px, x travel without flag %.2f px" % (
             max(abs(f["root"][1]) for f in ip["frames"]), a["frames"][-1]["root"][0]))
    code, text = convert(path("test_walk.fbx"), path("w_foot3.json"), "--foot-offset", "0.3")
    f3 = load(path("w_foot3.json"))
    shift = max(abs(wrap_pi(fa["rot"][j] - 0.3 - fb["rot"][j])) for fa, fb in zip(a["frames"], f3["frames"])
                for j in ("near_foot", "far_foot"))
    rest_same = all(fa["rot"][j] == fb["rot"][j] for fa, fb in zip(a["frames"], f3["frames"])
                    for j in JOINTS if not j.endswith("_foot"))
    case("--foot-offset 0.3 lowers both feet by exactly 0.3 rad and nothing else, no NOTE",
         code == 0 and shift < 1e-4 and rest_same and "NOTE:" not in text, "max deviation %.1e rad" % shift)
    code, text = convert(path("test_walk.fbx"), path("w_footauto.json"), "--foot-offset=auto")
    fa_ = load(path("w_footauto.json"))
    deltas = [wrap_pi(x["rot"][j] - y["rot"][j]) for x, y in zip(a["frames"], fa_["frames"])
              for j in ("near_foot", "far_foot")]
    G0 = cumulative(local_angles(0.0))     # in a round-tripped FBX the rest pose is the first frame's pose
    want = sum(G0[j] + BASE_FOOT for j in ("near_foot", "far_foot")) / 2      # mean global foot slope
    case("--foot-offset auto subtracts one constant, the mean rest-pose foot slope, from every foot value",
         code == 0 and max(deltas) - min(deltas) < 1e-4 and abs(deltas[0] - want) < 1e-3 and "NOTE:" not in text,
         "constant %.4f rad, expected %.4f" % (deltas[0], want))
    convert(path("test_walk.fbx"), path("w_rest.json"), "--hip-ref", "rest")
    case("--hip-ref rest runs (rest pose == frame 0 in a round-tripped FBX)",
         not quiet_compare("test_walk.expected.json", "w_rest.json")[0])
    code, text = convert(path("test_walk.fbx"), path("w_native.json"), "--importer", "native")
    pn, mn = quiet_compare("test_walk.expected.json", "w_native.json")
    case("--importer native (wm.fbx_import) gives the same answer", code == 0 and not pn,
         "max err %.2g rad" % mn["max_rot_err_rad"] if code == 0 else text[-300:])

    # 4. resampling
    for fps, want in ((24, 25), (60, 61), (15, 16)):
        convert(path("test_walk.fbx"), path("w_%d.json" % fps), "--fps", str(fps))
        pr, mr = quiet_compare("test_walk.expected.json", "w_%d.json" % fps)
        case("--fps %d -> %d frames, matches expected" % (fps, want), not pr and mr["frame_count"] == want,
             "exact-frame err %.2g, in-between err %.2g rad" % (mr["max_rot_err_rad"], mr["max_rot_err_interp_rad"]))

    # 5. every facing direction, prefix variant and object scale must give identical rotations
    for name, extra, want in (("test_walk_px", ("--facing", "+x", "--prefix", "mixamorig1:", "--object-scale", "0.01"), (1, 0)),
                              ("test_walk_nx", ("--facing", "-x", "--prefix="), (-1, 0)),
                              ("test_walk_py", ("--facing", "+y"), (0, 1))):
        ok = build_clip(name, *extra)
        code, text = convert(path(name + ".fbx"), path(name + ".json"))
        pr, mr = quiet_compare(name + ".expected.json", name + ".json")
        f = fwd_of(text)
        case("%s (%s): forward auto-detected %s, rotations and root match" % (name, " ".join(extra), want),
             ok and code == 0 and not pr and f is not None and abs(f[0] - want[0]) < 1e-3 and abs(f[1] - want[1]) < 1e-3,
             "forward %s, max err %.2g rad, root err %.3g px" % (f and f[:2], mr["max_rot_err_rad"], mr["max_root_err_px"]))

    # 6. a clip that does not loop
    ok = build_clip("test_half", "--frames", "16")
    convert(path("test_half.fbx"), path("test_half.json"))
    pr, mr = quiet_compare("test_half.expected.json", "test_half.json")
    case("half cycle (16 frames): loop=false and rotations match", ok and not pr and mr["loop"] is False,
         "frames %d" % mr["frame_count"])
    convert(path("test_walk.fbx"), path("w_looptol.json"), "--loop-tol", "1e-9")
    case("--loop-tol 1e-9 still accepts the exact walk cycle", load(path("w_looptol.json"))["loop"] is True)

    # 7. batch mode: a directory in, a directory out
    batch_in, batch_out = path("batch_in"), path("batch_out")
    shutil.rmtree(batch_in, ignore_errors=True)
    shutil.rmtree(batch_out, ignore_errors=True)
    os.makedirs(batch_in)
    for n in ("test_walk", "test_half", "test_walk_px"):
        shutil.copy(path(n + ".fbx"), batch_in)
    open(os.path.join(batch_in, "notes.txt"), "w").write("not an fbx")
    code, text = convert(batch_in, batch_out)
    outs = sorted(os.listdir(batch_out)) if os.path.isdir(batch_out) else []
    same = all(load(os.path.join(batch_out, n + ".json"))["frames"] == load(path(n + ".json"))["frames"]
               for n in ("test_walk", "test_half", "test_walk_px") if n + ".json" in outs)
    case("batch: 3 .fbx in a directory -> 3 JSON files identical to single-file runs (txt ignored)",
         code == 0 and outs == ["test_half.json", "test_walk.json", "test_walk_px.json"] and same and "3/3 converted" in text,
         ", ".join(outs))

    batch2_in, batch2_out = path("batch2_in"), path("batch2_out")
    shutil.rmtree(batch2_in, ignore_errors=True)
    shutil.rmtree(batch2_out, ignore_errors=True)
    os.makedirs(batch2_in)
    shutil.copy(path("test_walk.fbx"), os.path.join(batch2_in, "b_good.fbx"))
    open(os.path.join(batch2_in, "a_corrupt.fbx"), "w").write("this is not an fbx file")
    code, text = convert(batch2_in, batch2_out)
    good = os.path.join(batch2_out, "b_good.json")
    case("batch with a corrupt .fbx: reports it, still converts the good one, exit 1",
         code == 1 and "1/2 converted" in text and "a_corrupt.fbx" in text and os.path.exists(good)
         and load(good)["frames"] == a["frames"] and not os.path.exists(os.path.join(batch2_out, "a_corrupt.json")))

    # 8. failure modes: clear message and exit code 1
    code, text = convert(path("does_not_exist.fbx"), path("nope.json"))
    case("missing input -> exit 1 with a clear message", code == 1 and "input not found" in text)
    ok = build_clip("test_notmixamo", "--prefix", "Bone_")
    code, text = convert(path("test_notmixamo.fbx"), path("test_notmixamo.json"))
    case("non-Mixamo bone names -> exit 1, 'not a Mixamo skeleton', no output file",
         ok and code == 1 and "not a Mixamo skeleton" in text and "missing bones hips" in text
         and not os.path.exists(path("test_notmixamo.json")))
    ok = build_clip("test_nohand", "--omit", "LeftHand,LeftHandMiddle1")
    code, text = convert(path("test_nohand.fbx"), path("test_nohand.json"))
    err = [l for l in text.splitlines() if "ERROR" in l]
    case("Mixamo skeleton without the left hand -> exit 1 naming exactly that bone",
         ok and code == 1 and err and "missing bones lefthand;" in err[0] and not os.path.exists(path("test_nohand.json")),
         err[0].split("ERROR: ")[-1][:90] if err else text[-200:])
    code, text = convert(batch_in, path("batch.json"))
    case("batch mode with a *.json output path -> exit 1", code == 1 and "DIRECTORY" in text)

    # 9. fallbacks: leaf bones missing (head, hand, toe) -> head->tail of the parent, with a warning
    ok = build_clip("test_leafless", "--omit", "HeadTop_End,RightHandMiddle1,RightToeBase,RightToe_End")
    code, text = convert(path("test_leafless.fbx"), path("test_leafless.json"))
    pr, mr = quiet_compare("test_leafless.expected.json", "test_leafless.json", tol=0.02)
    warned = text.count("using head->tail")
    case("leaf bones omitted: warns 3x and falls back to head->tail (within 0.02 rad)",
         ok and code == 0 and warned == 3 and not pr, "warnings %d, max err %.3g rad" % (warned, mr["max_rot_err_rad"]))

    # 10. degenerate directions, a single pose, and a file without animation
    ok = build_clip("test_tpose", "--tpose-arms")
    code, text = convert(path("test_tpose.fbx"), path("test_tpose.json"))
    exp = load(path("test_tpose.expected.json"))
    tp = load(path("test_tpose.json")) if os.path.exists(path("test_tpose.json")) else {"frames": []}
    legs = max([abs(wrap_pi(f["rot"][j] - e["rot"][j])) for f, e in zip(tp["frames"], exp["frames"])
                for j in JOINTS if "arm" not in j and "hand" not in j] or [9])
    held = text.count("points along the view axis in 31/31 frames")
    case("arms along the view axis: 6 'direction held' warnings, no crash, every other joint still exact",
         ok and code == 0 and held == 6 and legs < 1e-3, "%d warnings, other joints max err %.2g rad" % (held, legs))
    ok = build_clip("test_pose1", "--frames", "1")
    code, text = convert(path("test_pose1.fbx"), path("test_pose1.json"))
    pr, mr = quiet_compare("test_pose1.expected.json", "test_pose1.json")
    case("single-frame clip: 1 frame, loop=false, pose matches expected", ok and code == 0 and not pr
         and mr["frame_count"] == 1 and mr["loop"] is False, "max err %.2g rad" % mr["max_rot_err_rad"])
    ok = build_clip("test_noanim", "--no-anim")
    code, text = convert(path("test_noanim.fbx"), path("test_noanim.json"))
    na = load(path("test_noanim.json")) if os.path.exists(path("test_noanim.json")) else {"frames": [], "loop": None}
    exp = load(path("test_noanim.expected.json"))
    same = all(f == na["frames"][0] for f in na["frames"]) if na["frames"] else False
    pose0 = max([abs(wrap_pi(na["frames"][0]["rot"][j] - exp["frames"][0]["rot"][j])) for j in JOINTS] or [9])
    case("FBX without animation: warns, uses the scene range (250 frames), identical static frames, pose exact",
         ok and code == 0 and "no animation found" in text and len(na["frames"]) == 250 and same
         and na["loop"] is True and pose0 < 1e-3, "%d frames, pose err %.2g rad" % (len(na["frames"]), pose0))

    print("\nSUITE: %d/%d checks passed" % (sum(tally), len(tally)))
    return 0 if all(tally) else 1


# ---------------------------------------------------------------------------

def script_args():
    argv = list(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:])
    for i, a in enumerate(argv[:-1]):      # argparse would take "-x" for a flag: merge "--facing -x"
        if a == "--facing":
            argv[i:i + 2] = ["--facing=" + argv[i + 1]]
            break
    return argv


def main():
    p = argparse.ArgumentParser(prog="make_test_armature.py", description=__doc__.split("\n\n")[0])
    p.add_argument("--out-dir", default=os.path.join(tempfile.gettempdir(), "mixamo_test"))
    p.add_argument("--name", default="test_walk")
    p.add_argument("--facing", choices=sorted(YAW), default="-y", help="world direction the character faces")
    p.add_argument("--frames", type=int, default=31, help="frames at 30 fps (31 = one full cycle)")
    p.add_argument("--prefix", default="mixamorig:")
    p.add_argument("--object-scale", type=float, default=1.0)
    p.add_argument("--omit", default="", help="comma list of leaf bones to leave out")
    p.add_argument("--tpose-arms", action="store_true", help="leave the arms in the T-pose (along the view axis)")
    p.add_argument("--no-anim", action="store_true", help="export the frame-0 pose without any animation")
    p.add_argument("--compare", nargs=2, metavar=("EXPECTED", "ACTUAL"))
    p.add_argument("--run-suite", action="store_true")
    p.add_argument("--blender", default=os.environ.get("BLENDER", DEFAULT_BLENDER),
                   help="Blender executable (default: $BLENDER, the macOS app, then blender on PATH)")
    args = p.parse_args(script_args())
    if args.compare:
        problems, _ = compare(*args.compare)
        return 1 if problems else 0
    if args.run_suite:
        import shutil
        blender = args.blender if os.path.exists(args.blender) else (shutil.which("blender") or args.blender)
        return run_suite(blender, args.out_dir)
    try:
        import bpy  # noqa: F401
    except ImportError:
        sys.exit("build mode runs inside Blender: Blender -b --factory-startup --python %s -- --out-dir DIR"
                 % os.path.basename(__file__))
    if args.frames < 1:
        sys.exit("--frames must be >= 1")
    try:
        build(args)
    except Exception:
        traceback.print_exc()
        return 1                     # Blender exits 0 after an uncaught exception, so be explicit
    return 0


if __name__ == "__main__":
    sys.exit(main())
