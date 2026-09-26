# 05 — Content and asset handoff

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md). [Selected references](../../concept-art/l01-sunnyvale/README.md).

## Existing selected references

Paths below resolve to the approved originals. Keep these originals intact; imported derivatives belong in the later Godot project.

| Subject | Source |
| --- | --- |
| Clipper | [Selected 2D PNG](../../concept-art/r01-clipper/r01-clipper-2d-v1.png), [identity brief](../../art-design/robots/r01-clipper.md) |
| Resident | [Selected 2D PNG](../../concept-art/z01-resident/z01-resident-2d-v1.png), [identity brief](../../art-design/zombies/z01-resident.md) |
| Front gardens | [A02 keyframe](../../concept-art/l01-sunnyvale/l01-a02-front-gardens-2d-v1.png) |
| Neighborhood square | [A04 keyframe](../../concept-art/l01-sunnyvale/l01-a04-neighborhood-square-2d-v1.png) |
| Quarantine exit | [A06 keyframe](../../concept-art/l01-sunnyvale/l01-a06-quarantine-exit-2d-v1.png) |
| Hero | [Proposed H01 brief](../../design/02-characters/hero.md); no selected finished hero sprite |
| Pistol / Quickcycle | [W01 brief](../../art-design/weapons/w01-scrapjack-pistol.md); no selected finished weapon sprites |
| Artifact | [A01 Welcome Key](../../design/03-progression/artifact-catalog.md) |
| Shared art | [2D style guide](../../art-design/style-guide.md) |

The five PNGs are concept references, not isolated sprites, collision maps, layered backgrounds, or animation sheets. Do not stretch a scene picture across the whole level and treat its painted platforms as playable geometry.

## Production priority

**Blockout first:** flat colored shapes, simple readable hero/enemy silhouettes, line-drawn warnings, temporary sound cues. These are explicitly temporary visuals. Finish a playable route before requesting a large art batch.

**Readability pass:** apply palette, strong platform edges, enemy identity, held-gun contact, simple sprite motion, foreground/background separation, and a recognizable sun clock.

**Prototype art pass:** replace temporary drawings where assets exist. If final animation is unavailable, keep honest placeholder animation; do not claim finished matching sprites. Record each asset as reference-only, placeholder, draft, or usable-in-prototype.

## Minimum asset list

| ID family | Needed for this slice |
| --- | --- |
| HERO | Idle, run, jump rise/fall, land, aim/fire upper body, hit, defeated, interact; empty-hand base plus separate held gun |
| Z01 | Slouch/idle, walk, windup, lunge, recovery, hit, defeated; preserve outfit and humanoid shape |
| R01 | Roll, eye/shear windup, charge, wall stall with exposed rear, recovery, hit, defeated; two separate eye stalks and two blades |
| W01 | Base and Quickcycle held/ground drawings, recoil, bolt, small muzzle flash, blocked/hit marks |
| ENV | Ground/porch/roof/wall modules, safe platform top edges, moving maintenance platform, tracks, stone backstop, raised flowerbed, service walkway |
| LANDMARK | Clock, fountain, depot doorway, mounted core housing, care console, hatch, exit wicket |
| PROPS | Recovery station, upgrade bench, weapon pad, target, gem/cluster/cache, Welcome Key, care capsule, route lever |
| STORY | Happy garden state and quarantine state: lamp rotation, rail rotation, ceiling pattern, console indicators |
| BACKGROUND | Two home layers, lawns, sky-ceiling pattern, sparse framing vegetation; keep animation subordinate |
| UI | Health segments, single-gun icon, stage marker, gems, interaction marker, subtitle backing, simple panels |

Use full-body side-view readability. Frame anchors: feet aligned to one baseline; weapon grip/muzzle markers consistent across recoil; Clipper rear hit zone tied to the motor. Do not auto-mirror asymmetrical reference details without checking. Collision and hit zones remain separate from painted outlines.

Suggested sprite source scale: draw hero at 192 px high for a displayed 96 px starting scale; match other characters proportionally and use filtering that preserves the selected linework. This is a production proposal, not an instruction to regenerate existing approved art. Test edges at game scale before drawing many frames.

## Sound and written content

Required functional cues: pistol fire/hit/blocked; hero hurt; Resident windup; Clipper scrape/charge/stall; gem; artifact; interact; checkpoint; purchase; latch/alarm; exit. One light suburb loop and one restrained quarantine variation are sufficient. No voice acting needed; EDEN subtitles plus a chime communicate SC01.

Keep sound effects distinguishable at low volume. Provide master/music/effects controls, subtitles on by default, adjustable text size, and an option to reduce shake/background motion. Neither audio nor color alone signals an attack.

Short proposed objective sequence:
1. Find the maintenance depot.
2. Inspect the mounted power core.
3. Reach the garden wicket.
4. Sunnyvale complete.

SC01 text can be adapted from [story scenes](../../design/05-presentation/story-scenes.md): Rook notes the core's value; the interlock warns of active wards; EDEN announces scheduled care. The full support-network revelation remains in Level 11.

## Asset handoff rules

When later producing art, request one subject/state at a time using its selected reference and written brief. Specify side-view pose, complete silhouette, consistent scale, and separate effects. Keep licensing/provenance notes for every external asset actually used. Do not require an asset-store purchase or introduce unreviewed third-party content just to finish the prototype.

Use descriptive names such as z01_resident_windup and l01_depot_core. Record source path, dimensions, pivot, animation state, and status in the implementation's asset inventory. Leave final sprites and layered backgrounds marked missing until delivered.
