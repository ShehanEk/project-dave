# Lit-cutout art tools (C35)

Every enemy is a **lit cutout rig**: its parts are painted flat (no baked light), each with a matching normal map and a spec/emissive map, packed into one atlas and described by a `rig.json` that `scripts/actors/lit/cutout_rig.gd` reads. The engine's lights shade the parts smoothly through `res://assets/shaders/lit_part.gdshader`. Dave's frame sprites get auto normal maps so he is lit the same way.

The painters here generate placeholder art procedurally. Final art is painted by hand (or generated) and goes through the same split → normal map → atlas → `rig.json` steps. Only numpy and Pillow are needed. Every tool is deterministic: it seeds its own noise, so a rerun writes the same pixels.

## Commands

Run from the project root (`prototypes/sunnyvale-godot`):

```bash
python3 tools/art/paint_night_guard.py     # SE01 Night Guard  -> assets/characters/lit/night_guard/
python3 tools/art/paint_staffer.py         # LK01 Staffer      -> assets/characters/lit/staffer/
python3 tools/art/paint_patrol_rover.py    # M01 Patrol Rover  -> assets/characters/lit/patrol_rover/
python3 tools/art/paint_blood.py           # blood decals      -> assets/effects/blood/
python3 tools/art/make_normal_maps.py      # Dave's Rook frames -> assets/characters/rook/normals/
python3 tools/art/import_parts_sheet.py night_guard   # a generated parts sheet -> assets/characters/lit/night_guard/
python3 tools/art/import_parts_sheet.py patrol_rover  # a generated parts sheet -> assets/characters/lit/patrol_rover/
python3 tools/art/import_parts_sheet.py scrapjack     # a generated parts sheet -> assets/characters/lit/scrapjack/
```

Add `--preview DIR` to a rig painter to also write `DIR/<name>_preview.png`: each preview pose at 3x, then gameplay size (1x, shown enlarged), 2x, mirrored, and a flat silhouette. The previews are a software copy of the shader under a lamp, a muzzle flash and the moon rim. Write them outside the project (for example `/tmp/art-previews`).

After changing art, re-import it:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import
```

## Files

| File | What |
| --- | --- |
| `lit_rig_common.py` | The shared core: `Part` (paint flat colour, materials, emissive masks and a height field in a part's own frame), geometry helpers, blur and an exact distance transform, downsampling, atlas packing, normal encoding, the `rig.json` writer and the software preview |
| `import_parts_sheet.py` | Imports a generated parts sheet (the brief's "Image prompt 4") as a rig: finds each part, scales the sheet to the gameplay height, reads the skeleton off joint anchors marked in its `SHEETS` table, and writes the atlas, normal and spec maps (the enemy's exact neon color becomes the glow mask) and `rig.json`. A machine (the rover) is assembled instead: each part's pivot is placed on the chassis, parts can be rotated or scaled to fit, and the scale comes from its length; a flat grey background is flood-filled away. `--preview DIR` writes the assembled rest pose. A prop (the Scrapjack) is assembled around the point where the hand holds it, which becomes the rig's origin, and a part's glow colors can be limited to boxes (the copper coils, not the painted rust). The Night Guard's art comes from here since 2026-09-30, the Patrol Rover's since 2026-10-03 and the Scrapjack's since 2026-10-04 |
| `paint_night_guard.py` | The lit-cutout test's procedural guard. Superseded by the imported sheet; running it overwrites the Night Guard with the placeholder |
| `paint_staffer.py` | The Linked night-shift employee: the guard's joints minus `baton` |
| `paint_patrol_rover.py` | The lit-cutout test's procedural rover. Superseded by the imported sheet; running it overwrites the Patrol Rover with the placeholder |
| `paint_blood.py` | Wound marks, the floor pool, the spray droplet and the flat helpers used by `scripts/effects/blood.gd` |
| `make_normal_maps.py` | Normal maps from the silhouette and painted detail of every PNG in `assets/characters/rook/`, plus `dave_spec.png` |
| `build_guard_mocap.py` | Turns the Night Guard's converted Mixamo clips (Idle, Walking, Running, Bash, Hit Reaction; downloaded 2026-09-30) into his game clips in `assets/characters/lit/night_guard/mocap/`: gaits timed so the feet don't slide at his speeds, the Bash split into windup, swing and recover and retimed to his tuning (its wind-up arm rebuilt to rise in front and hold overhead, since the capture's swing round behind him flattens to a windmill), and a fast hit flinch. The mocap overrides the hand-keyed clips of the same name |
| `mixamo_to_rig.py`, `make_test_armature.py` | Mixamo FBX clip → per-joint rotations for the human rigs (Blender); see [README-mixamo.md](README-mixamo.md) |

## Texture conventions

| Texture | Channels |
| --- | --- |
| `albedo.png` | Flat base colours with dark outlines and a mild, non-directional cavity shade; A = coverage |
| `normal.png` | Godot's 2D convention: R = +x (right), G = +y **up**, B = z stored directly (Godot decodes z = b). Flat = (128, 128, 255). Transparent texels hold the flat normal |
| `spec.png` | R = specular strength, G = gloss, B = emissive mask, A = coverage |

All three share one layout. Parts are drawn at `texture_scale` atlas pixels per world pixel (3), so a sprite is scaled by 1/3.

## `rig.json`

```json
{"name": "LK01 Staffer", "kind": "human", "texture_scale": 3,
 "albedo": "albedo.png", "normal": "normal.png", "spec": "spec.png",
 "ground_lock": true, "sole_points": [[-3.9, 4.5], [4.0, 4.5], [10.6, 4.5]],
 "parts": {"torso": {"rect": [x, y, w, h], "pivot": [px, py]}, ...},
 "joints": [{"name": "torso", "part": "torso", "parent": "pelvis", "pos": [0.3, -5.5], "z": 5, "far": false,
             "collider": {"type": "capsule", "a": [0, -2], "b": [0, -21.5], "r": 6}, "mass": 22, "limit": [-35, 75],
             "rest_dir": -90, "role": "..."}, ...],
 "sockets": {"port_light": {"joint": "head", "pos": [-2.8, -4.4]}, ...}}
```

- **Texture files** are relative to the JSON's folder. **`parts`** gives each part's atlas rect and its pivot in texels.
- **`joints`** are listed parents first. `pos` is the pivot in the parent's frame (world px, y down; the root's is in rig space, whose origin is on the floor under the character). `z` is the draw order; `far` parts are tinted darker by the rig. `limit` is the ragdoll range in degrees (null = free). `rest_dir` is the canvas angle the bone points along at zero rotation.
- **Colliders** are in the joint's local world px: `circle` {c, r} or `capsule` {a, b, r}. Every joint has a collider and a mass, so a death can turn every part into a physics body.
- **`kind`** is `human` (a ragdoll; `ground_lock` keeps the lowest of the `sole_points`, in foot-local world px, on the floor) or `machine` (posed directly by its owner; `ground_lock: false`; every joint has a `role` naming what it is, for the owner's code).
- **`sockets`** name points for lights, sparks and fluids, in a joint's local world px.

## The rigs

| Rig | Joints | Emissive spots (spec B) | Sockets |
| --- | --- | --- | --- |
| Night Guard | pelvis, torso, head, near/far upper arm, forearm, hand, thigh, shin, foot, `baton` | baton tip, chest lamp lens, radio LED | `tell`, `chest_lamp`, `radio_led` |
| Staffer | the guard's minus `baton`; the near forearm is bare (`forearm_bare`, the sleeve pushed up) | the Link port lens behind the near ear (dull amber) | `port_light`, `grip_near`, `grip_far` |
| Patrol Rover | `chassis` (root) → `dome`, `lightbar`, `bumper`, `hatch`, `battery`, `wheel_near_front`, `wheel_near_rear`, `wheel_far_front`, `wheel_far_rear` | dome lens (dull amber), the six lightbar lenses, the battery's gauge and cells | `lens_light`, `tell`, `core`, `spark_bumper`, `spark_hatch`, `spark_dome`, `oil_drip` |

- An emissive spot glows in its painted colour on the rig's shared material. `cutout_rig.gd`'s `set_emissive(joint, colour, energy)` gives one part its own material that glows in `colour` instead: the guard's baton tell, the Staffer's port (energy 0 on death), the Rover's lightbar tell and teal battery.
- **Rover pivots:** the chassis at mid-wheelbase, axle height (`(0, -9)`). Each wheel is at its hub, so a rotation spins it. The dome is at its base centre. The hatch is a clamshell lid hinged at its lower rear edge: a **negative** rotation (about -70°) flips it up and back and exposes the battery bay.
- **Staffer motion:** it has the same joints and rest directions as the guard, so the same human clips drive it. Its pelvis sits at 49.5 px, so convert Mixamo clips for it with `--hip-height-px 49.5`.

## Adding a rig

1. Copy a painter. Draw each part in its own frame: the joint pivot is at (0, 0), +x is the way the rig faces, and +y runs down the bone (limbs hang down; torso, pelvis and head point up). Paint hidden overlap under every joint, and paint far limbs and hidden sides complete.
2. Build a part from these calls:
   - `body` or `shell` for its volume;
   - `patch`, `bump`, `seam` and `ridge` for detail;
   - `tint` and `tint_stroke` for flat colour changes;
   - `emissive=1` on a patch, or `emit`, for lenses and lights.

   Never paint light, shadow, blood or glow into the albedo.
3. List the joints (parents first), write with `write_atlas` and `write_rig_json`, and check the result with `--preview`, then in the engine under a lamp with both facings.
