# Lit-cutout test: SE01 Night Guard (C35)

This test checks the new enemy art direction before Level 1 is rebuilt (C33). It has:
- one Night Guard painted as flat parts;
- smooth engine lighting through normal maps;
- a ragdoll death and visible blood (C29);
- Dave, lit the same way, under a real Level 1 path lamp on the night campus.

It is self-contained: nothing outside `spike/`, `tools/spike/` and one test case (`tests/cases/test_spike_lit_cutout.gd`) was added or changed. It never saves; the save folder and play-log folder are redirected to `user://lit_cutout_test_throwaway`.

## Run it

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path prototypes/sunnyvale-godot res://spike/lit_cutout/lit_cutout_test.tscn
```

Add `-- --autoplay` to watch a scripted 16-second demo instead of playing.

| Key | Does |
| --- | --- |
| A / D, Space or W, mouse, left click | Move, jump, aim, fire (the normal controls) |
| R | Spawn a new guard |
| K | Kill the guard (ragdoll test) |
| N | Normal maps on/off (lit vs flat, same lights) |
| L | Lamp style: smooth (new) or the old stepped bands |
| M | Moonlight rim on/off |
| B | Blood on/off (the proposed setting) |
| Z | Zoom 1x/2x (use 2x to judge the lighting) |
| T | Slow motion |
| I | Dave invulnerable |
| P | Guard passive (stands for inspection) or aggressive |
| F1 | Help on/off |
| Esc | Quit |

## What to judge
- **Lighting:** the guard's shading follows the lights: the lamp above him, Dave's muzzle flash, his own baton glow and the moon rim. Compare with N (flat).
- **Realism of the placeholder art:** the guard's painting was generated in code by `tools/spike/paint_night_guard.py`. Final art is painted by hand (or generated) and run through the same split → normal map → atlas steps. The test is about the method, not this drawing.
- **Motion:** hand-keyed placeholder poses. Mixamo clips replace them automatically (see below).
- **Death and blood:**
  - the ragdoll falls from the shot;
  - blood sprays and leaves floor splats;
  - wound marks stick to the part that was hit;
  - the body settles, and a pool spreads under it.

## Files
| Path | What |
| --- | --- |
| `art/` | Painted atlas (albedo, normal, spec), rig JSON, blood decals, smooth light textures, Dave's auto normal maps |
| `shaders/lit_part.gdshader` | Flat albedo + normal map + spec; `ambient` is the unlit night level |
| `scripts/cutout_rig.gd` | Builds the part rig from the JSON; poses it; keeps the feet on the floor |
| `scripts/rig_animator.gd` | Hand-keyed clips, crossfades, hit jolts; loads Mixamo clips from `mocap/` |
| `scripts/night_guard.gd` | The Brawler loop: patrol → bark → stalk → wind-up (amber, then red) → strike → winded |
| `scripts/ragdoll.gd`, `scripts/ragdoll_part.gd` | Death: pinned physics parts with joint limits, settling into a still corpse |
| `scripts/blood.gd` | Spray, splats, wounds and pools, all drawn with the lit shader |
| `scripts/lit_hero_adapter.gd` | Lights Dave the same way and adds a muzzle-flash light, without editing hero files |
| `lit_cutout_test.tscn/.gd` | The test scene |

## Tools
```bash
python3 tools/spike/paint_night_guard.py
```
Repaints the guard atlas and rig, the blood decals and the light textures.

```bash
python3 tools/spike/make_normal_maps.py
```
Makes normal maps for Dave's Rook frames.

```bash
python3 tools/spike/make_spike_audio.py
```
Makes the placeholder baton, hit and fall sounds.

After changing art, re-import it:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path prototypes/sunnyvale-godot --import
```

## Adding Mixamo motion
1. Download clips from mixamo.com with your own Adobe account, as FBX, "Without Skin", with In Place ticked where offered. Suggested clips: an idle, a walk, an overhead melee strike and a death.
2. Convert them with Blender. `--foot-offset auto` levels Mixamo's toe-down foot bones, and `--in-place` drops the forward travel, which gameplay supplies. See `tools/spike/README-mixamo.md` for details.

   ```bash
   /Applications/Blender.app/Contents/MacOS/Blender -b --python tools/spike/mixamo_to_rig.py -- clip.fbx spike/lit_cutout/mocap/walk.json --in-place --foot-offset auto
   ```
3. Save each result as `spike/lit_cutout/mocap/<clip>.json`, where `<clip>` is `idle`, `walk`, `stalk`, `windup`, `swing` or `recover`. It replaces the hand-keyed clip of the same name the next time the scene starts.

## Known limits
- **Joint limits:** Godot 4.7's PinJoint2D angular limits were unstable in a probe, so `ragdoll_part.gd` enforces the joint limits itself.
- **Hit spark:** the bolt's green HIT spark is removed on people, who bleed instead. This is a test-only hook in `night_guard.gd`, pending a proper change to `scrap_bolt.gd` when Level 1 is rebuilt.
- **Level lighting:** only the characters and blood are normal-mapped. Blocks, props and backdrops keep their flat art under the smooth lamp light.

## Remove it
Delete `spike/`, `tools/spike/` and `tests/cases/test_spike_lit_cutout.gd`.
