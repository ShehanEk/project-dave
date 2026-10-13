# Level 2 "Alignment": build plan

The design is [L02 Alignment](../../level-design/l02-alignment.md) (C59). The game is `game/` (C61). The enemy look follows the [roster redesign](../../art-design/roster-painted-redesign.md) (C60). Level 1's plan and lessons ([level-01-sunnyvale](../level-01-sunnyvale/README.md), especially `10-lessons-and-workflow.md`) still apply: smallest change in the existing project, `tools/test.sh` after every step, the exported-build check, a learning-log row per pass, commit only on "commit".

## Milestones

| # | Milestone | Done when | Needs the user |
| --- | --- | --- | --- |
| M0 | Move and decide | The game is in `game/`; C59–C61 recorded; docs and briefs updated; tests and export pass from `game/`. | — |
| M1 | Campaign framework | Levels are data (a level definition: id, areas, start weapon, pads, keycard, switches, intro scene, next level); Session and saves carry the level id, the held weapon type, upgrades and wallet across levels; finishing Level 1 leads into Level 2; a debug flag starts any level; Level 1 plays and tests exactly as before. | — |
| M2 | Level 2 greybox | Six areas A01–A06 built with the Level 1 kit as placeholder art (indoors, no rain except the bridge), checkpoints CP00–CP05, keycard and freight-lift exit, microchips, evidence file, workbench; route bot can finish it. | — |
| M3 | Boom Broom | Second weapon type W02: spread, knockback, pump, shell reload, held on the aim pivot by its grip; the swap pad in A01 with a safe trial; HUD icon; upgrades table. Placeholder art until its sheet. | Boom Broom parts sheet |
| M4 | New enemies | Gunner template with the EG01 pistol round (Sidearm Guard); Drone template (Security Drone); Hound as a four-legged lit rig with a double lunge (Brawler); placed as E01–E07 under the fairness rules. Placeholder looks until sheets. | Sidearm Guard, Hound, Security Drone sheets |
| M5 | Story and lockdown | Sky-bridge entry scene, Adam's lines as subtitles, A04 sliding partitions and racks (rail lamps, chime, caption, never closing on Dave), the Lattice hologram (animated light), console sequence, exit PA. | — |
| M6 | Lab art | One lab style frame approved first, then the lab sheets imported (walls, floors, partitions, racks, props, the hologram, freight lift); every placement checked in game. | Style frame, then sheets |
| M7 | Finish | Audio placeholders (or ElevenLabs if asked), tests for every new system, full suite, exported build plays Level 1 into Level 2 to the end. | Playtest |

## Art order (C56 rule: one still first)

1. **Lab style frame** (prompt below), approved before any lab sheet.
2. Then one combined prompt for: lab environment sheets, Boom Broom parts, Sidearm Guard (three looks), Hound (two looks), Security Drone (two liveries), pistol and shotgun effects, Boom Broom HUD icon.

### Lab style frame prompt (attach `concept-art/style-handpainted/style-frame-v2.webp`, 16:9)

Store the result as `concept-art/style-handpainted/lab-style-frame-v1.webp`.

> Use the attached image as the reference for painting technique, palette and lighting: the same detailed hand-painted 2D style, painterly brushwork and night mood. Do not reuse its scene; paint the interior below.
>
> Hand-painted 2D side-scrolling action game screenshot, wide 16:9, strict side view, flat orthographic, high resolution.
>
> Setting: the Cognition Lab, the AI research tower of a rich tech megacorporation, at night after a lockdown. Corporate cyberpunk interior: clean, expensive, clinical and slightly sinister.
>
> Palette and light: deep navy and graphite dominate. The scenery's light is only teal-cyan, soft warm amber and cold white: emergency white strip lights, teal screen glow, a few warm amber desk lamps in glass office pods. No pink, purple or green neon in the scenery.
>
> Composition: three layers. The front layer (the play area) is the sharpest, with the most contrast; each layer behind it is hazier, bluer and lower in contrast. The floor's top edge sits about three quarters of the way down the image.
>
> Front layer: the walkable lab floor seen exactly from the side as a thick slab: pale composite panels with a thin glowing cyan seam at every joint and a crisp cold-white lit top edge. Under it, filling the bottom of the image: dark graphite service wall panels with vents and a cable tray. On the floor: a white lab bench with two monitors, a sliding glass partition on a floor rail with small amber rail lamps, and a server rack with blinking teal lights.
>
> Middle layer: a four-storey atrium. Suspended catwalks with glass balustrades and cyan light rails; glass-walled training cells holding server racks and white robotic test arms; on one side a tall netted drone flight cage. In the centre, a huge slowly turning teal hologram of an AI's neural network: an arch-shaped lattice of light points and lines (the company's arch logo), lighting the atrium.
>
> Back layer: the atrium's tall glass wall with the rainy city outside: megatowers with teal and amber light bands and faint hologram ads, hazy behind wet glass.
>
> Characters, small (about one sixth of the image height), on the floor, each with a thin cool rim light: on the left, Dave Harlan, an energetic athletic Caucasian man of 28 with short tousled brown hair and a confident look, in a burnt-orange zip jacket over a charcoal hoodie, a white ID card on a lanyard, dark cargo trousers with knee pads, brown boots and fingerless gloves, in a ready stance aiming a chunky rust-red and cream nail-gun pistol with copper coils; on the right, facing him, a fit, alert Caucasian security officer in a navy uniform with neon lime piping and a light tactical vest, in a two-hand stance aiming a sleek white-and-graphite pistol whose small muzzle lamp glows amber; above them, a sleek white composite ducted-fan security drone with a magenta underglow strip and a lightbar, nose tipped up.
>
> Mood: tense, sleek, clinical, corporate cyberpunk.
>
> Avoid: stone, brick, trees, plants, vines, anything medieval or rustic; pink or purple neon in the scenery; readable text (screens and signs show only abstract shapes and light bars); pixel art; 3D render; UI.

## Progress

- 2026-10-12: M0 started: game moved to `game/` (78/78 tests from the new folder), decisions C59–C61 recorded, doc updates running.
- 2026-10-12: M0 done: decisions C59–C61; enemy briefs, style guide, concept, level index, story scenes, start-here guide and project READMEs updated (two doc agents); EF02 became the "Reassignment Memo" (EF06 stays Dave's report); the Heirs now spark and leak oil (no lymph); the Peacekeeper's trim is magenta (a machine Adam drives).
- 2026-10-13: M1 done: LevelDef resources (`data/levels/l01.tres`, `l02.tres`), the `LevelDefs` registry, save schema 4 (`completed_levels`; per-level validation), carried state (weapon type, upgrades, wallet, evidence) vs per-level state, the completion screen's Continue into Level 2, `-- --level=L0x` debug flag; 79/79 tests, export `DONE ok`, the Level 2 stub loads indoors.
- 2026-10-13: M2 (areas, from `area-blueprints.md`) and M4 (Sidearm Guard, Security Drone, Hound with placeholder looks) started in parallel; M3 (Boom Broom) follows M2.
- 2026-10-13: the user sent the lab style frame (`concept-art/style-handpainted/lab-style-frame-v1.webp`); reviewed and recommended for approval; the Batch 7 combined prompt (13 sheets) is in `art-design/handpainted-style.md`, references in `concept-art/chatgpt-batch7-refs/`.
- 2026-10-13: M2 done: six areas (`scenes/levels/l02/a01_sky_bridge` … `a06_demo_floor`), CP00–CP05, workbench `UPG01`, 45 chips + a 20-chip cache, EF02 on Dave's desk, the A05 keycard console, the A06 freight-lift exit, A04's rail racks and partitions (pad, amber lamps, chime, caption; they hold still instead of crushing), `wet_until_x` (rain only over the bridge), lab ambience; the RouteBot finishes Level 2 (~78 s); `test_l02_areas.gd`. Blueprint changes are listed in CONVENTIONS "Level 2 greybox (M2)".
- 2026-10-13: M4 done: `Gunner` (Sidearm Guard, EG01 round), `Drone` (Security Drone), `Hound` (a Brawler with a double lunge and a handler gate); placeholder rigs by `tools/art/paint_pistol.py`, `paint_security_drone.py`, `paint_hound.py` with the painted sheets' part names; `test_l02_gunner/drone/hound.gd`; the lab `scenes/debug/enemy_lab_l02.tscn`. 83/83.
- 2026-10-13: M3 (Boom Broom + pad) and the enemy placement into Level 2 (with fair-fight tests) plus two Level 1 bug fixes (moving-platform blocker ray in offset areas; respawn knockback drift) started in parallel.
- 2026-10-13: enemy placement done: E01–E06 filled (handler-linked Hounds, drone heights inside the camera gate), `test_l02_encounters.gd` wins every fight with the base Scrapjack at 0 damage, fairness limits hold; Level 1 bugs fixed with regression tests (moving-platform blocker ray in offset areas; respawn knockback drift); the A06 demo crate removed (it let Dave wall off the Hound).
- 2026-10-13: M3 done: the Boom Broom (6 pellets, 22° cone, falloff to 420 px, knockback node, pump 0.62 s, shell reload 0.7 s, shells per weapon copy saved; upgrades by type), held-weapon swap on the aim pivot, the A01 pad (L02-A01-PAD01 resting L02-W02-P01), HUD shells; `test_w02_boom_broom.gd`, `test_l02_swap_pad.gd`; 88/88, export DONE ok.
- 2026-10-13: Batch 7 stored (13 sheets) and "process" started: enemy rigs + the Boom Broom rig (python import), lab environment, hologram, props, doors, effects and icons (Level 2 areas).
- 2026-10-13: Batch 7 processed: painted Sidearm Guards (three looks), Hound, Security Drone (enlarged), AS-9 pistol, Boom Broom; the LAB backdrop mode (atrium + lab strip), the Lattice hologram (additive, animated, static under Reduced motion), lab props and doors on every area, new effects (pistol flash/round/impact, shotgun blast/pellets/casing, shock arc, lunge dust) and HUD icons (Boom Broom, shells, Level 2 keycard and memo). 89/89 tests; export: newgame CP01, continue `DONE ok`; the pack holds every Level 2 rig, scene and lab asset.
- 2026-10-13: M5 done: Adam's lines over play (LevelDef `beat_lines` and `keycard_lines`, once per run, never holding Dave; a new set cuts short what is left of the last); SC02 in level (the sky-bridge greeting and "Generous.", the glass door that opens for Dave's badge and locks behind him, `bridge_door_locked`); A04's lockdown (emergency strips, the lab dimmed, six screens showing his file stamped TERMINATED, `sandbox_lockdown`, Adam's rack captions); the console scene (the archive line, Adam's archived rules, "Archived. Sure.", the hologram brightening, objective "Ride the freight lift down."); the exit line takes over; Adam's completion line. Saves from before the new flags still load. `test_l02_story.gd`; capture `scenes/debug/l02_story_demo.tscn`.
- Next: the M7 driver extended through Level 2, painted Boom Broom upgrade parts, voice clips and audio when the user asks, the between-levels SC02 shot (the campus gates sealing) if wanted.

