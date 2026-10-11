# Mixamo clip -> 2D rig keyframes

**Unused (C38, 2026-10-05):** every enemy is hand-keyed for the side view; motion capture flattened badly onto the side-on cutouts. This converter is kept for reference only.

`mixamo_to_rig.py` turns a Mixamo FBX clip into per-frame local joint rotations for the
side-view cutout rig (15 joints) plus hip root motion. It is a Blender script (tested on
Blender 5.2.2, bundled FBX importer). `make_test_armature.py` builds a synthetic
Mixamo-named clip and checks the converter against angles worked out independently.

## Convert

```sh
BLENDER=/Applications/Blender.app/Contents/MacOS/Blender
cd prototypes/sunnyvale-godot

$BLENDER -b --python tools/art/mixamo_to_rig.py -- clips/Walking.fbx out/walking.json
$BLENDER -b --python tools/art/mixamo_to_rig.py -- clips/Walking.fbx out/walking.json --in-place --fps 24 --forward=-y
$BLENDER -b --python tools/art/mixamo_to_rig.py -- clips/ out/        # every .fbx -> one .json each
```

Mixamo download: Format FBX Binary, Skin "Without Skin" is enough, 30 fps, Keyframe Reduction "none",
"In Place" for gaits (or pass `--in-place`). Bone prefixes `mixamorig:`, `mixamorig1:` or none all work.
Exit code is 1 if any clip failed (batch mode keeps going). Every clip prints one
`[mixamo_to_rig] OK ...` line (frames, loop, detected forward, scale, root travel) and any
`WARNING`/`NOTE` lines; read them.

| Option | Default | Meaning |
|---|---|---|
| `--fps N` | 30 | output rate; resampled over the action's frame range (scene range if no action) |
| `--in-place` | off | zero root x, keep the y bob |
| `--forward=+x\|-x\|+y\|-y\|auto` | auto | world facing direction; auto = feet at the first frame (cross-checked with the hip line), else `-y` |
| `--hip-height-px N` | 51 | pixels the rest hip height maps to (the Night Guard's hip; the Staffer's is 49.5, the `pelvis` y in its rig.json) |
| `--hip-ref frame0\|rest` | frame0 | measure that hip height in the first frame (spec) or in the armature's rest pose |
| `--foot-offset auto\|RAD` | 0 | subtract from both feet (see Limitations); `auto` = rest-pose foot slope |
| `--loop-tol RAD` | 0.05 | `loop` is true when every joint of the first and last frame agrees within this |
| `--importer auto\|legacy\|native` | auto | `import_scene.fbx`, else `wm.fbx_import` |
| `--selftest` | | pure-math checks (works with plain `python3`, no Blender) |

## Output

```json
{"name": "walking", "source": "mixamo", "fps": 30, "frame_count": 31, "loop": true,
 "joints": ["pelvis", "torso", "head", "near_upper_arm", ... 15 names ...], "hip_height_px": 51.0,
 "frames": [ {"root": [x_px, y_px], "rot": {"pelvis": 0.10472, ...}}, ... ]}
```

`name` is the file name without `.fbx`. Rotations are local radians (5 decimals), root is the Hips
head relative to frame 0 in pixels (y down, so up is negative). Joints are the 15 in the rig
hierarchy (the brief said 16 but lists 15; edit `JOINTS`/`PARENT`/`REST_DIR`/`SEGMENTS` at the top of
the script to add one). For a loop the last frame repeats the first, so a looping player should
wrap at `frame_count - 1` (duration = `(frame_count-1)/fps`).

## Conventions

Canvas x = forward, y down, positive = clockwise on screen. Rest (all zeros): pelvis, torso, head up;
arms and legs down; feet forward. `local = wrap_pi(global - parent global)`, pelvis local = its global.
near = Mixamo `Right*` (the camera sees the right side), far = `Left*`. Up = world +Z,
`canvas_x = dot(v, forward)`, `canvas_y = -v.z`. Bone directions are head-to-head vectors (Hips>Spine,
Spine>Neck, Head>HeadTop_End, Arm>ForeArm, ForeArm>Hand, Hand>HandMiddle1, UpLeg>Leg, Leg>Foot,
Foot>ToeBase else Toe_End); a missing end bone falls back to the bone's head->tail with a warning.

| Motion | Sign |
|---|---|
| thigh / upper arm swings forward | negative |
| knee bends (foot goes back) | positive shin |
| elbow bends forward | negative forearm |
| body or head leans forward | positive |
| toe down | positive foot |

## Tests

```sh
python3 tools/art/mixamo_to_rig.py --selftest                                  # math only
python3 tools/art/make_test_armature.py --run-suite --out-dir /tmp/mixamo_test  # 35 checks, ~35 s
# by hand:
$BLENDER -b --factory-startup --python tools/art/make_test_armature.py -- --out-dir /tmp/mixamo_test
$BLENDER -b --python tools/art/mixamo_to_rig.py -- /tmp/mixamo_test/test_walk.fbx /tmp/mixamo_test/test_walk.json
python3 tools/art/make_test_armature.py --compare /tmp/mixamo_test/test_walk.expected.json /tmp/mixamo_test/test_walk.json
```

The suite builds a Mixamo-named skeleton, keys a walk (thighs +-25 deg, knees, arms, pelvis/torso/head lean,
hip bob and travel, arms/legs splayed sideways), exports FBX, converts it and compares with angles taken from the
motion model (the generator also asserts its poses physically: forward is world -Y). It also covers all four
facings, `mixamorig1:`/no prefix, object scale 0.01, `--forward`, `--in-place`, 15/24/60 fps, batch mode, both
importers, loop detection, leaf-bone fallbacks, arms along the view axis, a single-frame and an animation-less
file, and the error paths.

## Limitations

- Only synthetic Blender->FBX->Blender round trips were tested; no real Mixamo file was available. Real files may
  differ in rest pose (`--hip-ref rest`, `--foot-offset auto` read the imported rest pose, normally the T-pose).
- Side view drops everything toward or away from the camera (side steps, torso twist, arm abduction). A bone
  pointing along the view axis holds its last angle (warning). The far (Left) limbs are converted like the near
  ones; the game decides how to draw them occluded.
- Root = Hips head only (x forward, y up, no yaw, no ground contact or foot-slide fixing). Scale comes from the
  hip height in frame 0, so it varies by clip unless you use `--hip-ref rest`.
- Mixamo's ankle->toe bone slopes about 20-40 deg toe-down even with a flat foot, so with the default the feet read
  about +0.35..0.7 rad when standing (a `NOTE` prints the measured value). Use `--foot-offset auto` or adjust the sprite.
- Rotations of 180 deg or more wrap (a backflip's pelvis jumps between +pi and -pi).
- Head->tail fallbacks depend on the importer's bone axis snapping; real Mixamo files have all end bones.
- One armature and the action assigned to it are used (a warning lists extra actions).
