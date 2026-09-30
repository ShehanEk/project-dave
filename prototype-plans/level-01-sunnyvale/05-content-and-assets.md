# 05 — Content and asset handoff

**Visual direction (C11, C15, C35):** [hand-drawn 2D in a dark night-campus palette, painted flat and lit in the engine](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24) and rebuilt 2026-09-30 (C33); there are no selected scene images for the new look.

## Existing selected references

Paths below resolve to the approved originals. Keep these originals intact; imported derivatives belong in the Godot project. The revamp deleted the zombie Resident concept art and the three daytime Sunnyvale scenes (C23), and C32 later deleted the Clipper PNG, so no concept PNG remains selected.

| Subject | Source |
| --- | --- |
| Night Guard | [Identity brief](../../art-design/security/se01-night-guard.md); no selected image. He was the subject of the lit-cutout test (C35, approved 2026-09-30), and the game draws him as a procedural lit cutout |
| Patrol Rover | [Design brief](../../art-design/machines/m01-patrol-rover.md); no selected image. It is the fresh design that took the deleted Clipper brief's file (C32) and must not resemble the Clipper. The game draws it as a procedural machine rig |
| Staffer | [Identity brief](../../art-design/linked/lk01-staffer.md); no selected image (the zombie Resident PNG was deleted), so it is a procedural lit cutout |
| Level look | No selected scene images. Use the [level brief](../../level-design/l01-welcome-to-sunnyvale.md) and the [style guide](../../art-design/style-guide.md) (night palette, light, readability rules) |
| Hero | [Proposed H01 brief](../../design/02-characters/hero.md) for Dave Harlan; the [Rook sprite pack](../../concept-art/h01-rook/rook-sprite-brief-for-chatgpt.md) is placeholder art, not a selected design |
| Pistol / Quickcycle | [W01 brief](../../art-design/weapons/w01-scrapjack-pistol.md); no selected finished weapon sprites |
| Evidence file | [EF01 Lockout Notice](../../design/03-progression/evidence-files.md) |
| Shared art | [2D style guide](../../art-design/style-guide.md) |

A concept PNG is a reference, not an isolated sprite, collision map, layered background, or animation sheet. Do not stretch a scene picture across the whole level and treat its painted platforms as playable geometry.

## Night palette and light

Use the style guide's tokens: near-black #07090F for voids and silhouettes, navy #0E1726 for the sky, steel #1C2A3A and slate #2E3B4E for structures and paving, Arcadia/Adam teal #3FE0D0 for signage, screens and idle Link lights, hazard amber #FFB02E for security lamps and warnings, alarm red #FF3B4E for attack tells and lockdown lamps only, microchip gold #FFD166 for pickups, and signal green #4DE38A for exit signs and status LEDs. Bloom violet #C77DFF is not used in Level 1. Dave's jacket is burnt orange so he reads against the cool darks.

Reserved meanings: red means attack now or locked, amber means warning or Adam's attention, teal means Arcadia and Adam at rest or unlocked, gold means pickups. Light is engine light (C35): lamps, screens, lenses and muzzle flashes are lights with a smooth falloff and a height, and painted art carries no baked light or shadow. Put a light near every landing and never let darkness hide a tell, a ledge or a pickup. Blood and oil follow the style guide's tokens.

## Production priority

**Blockout first:** flat colored shapes, simple readable hero/enemy silhouettes, line-drawn warnings, temporary sound cues. These are explicitly temporary visuals. Finish a playable route before requesting a large art batch.

**Readability pass:** apply the night palette, lit or rim-lit platform edges, enemy identity, held-gun contact, simple sprite motion, foreground/background separation, and a recognizable campus landmark.

**Prototype art pass:** replace temporary drawings where assets exist. If final animation is unavailable, keep honest placeholder animation; do not claim finished matching sprites. Record each asset as reference-only, placeholder, draft, or usable-in-prototype. The C33 rebuild's enemy art is placeholder: the painters in `tools/art/` generate every part, normal map and rig procedurally, and hand-keyed clips pose them. Final painted art and Mixamo clips go through the same pipeline.

## Minimum asset list

| ID family | Needed for this slice |
| --- | --- |
| HERO | Idle, run, jump rise/fall, land, aim/fire upper body, hit, defeated, interact; empty-hand base plus separate held gun (Dave Harlan; the placeholder Rook pack covers these until new art exists), each frame with a normal map |
| SE01 | Night Guard, a lit cutout rig of 16 parts: idle, patrol walk, stalk, baton windup (the tip goes amber, then red), overhead swing, recovery, hit, ragdoll death; security uniform, stun baton, chest lamp |
| LK01 | Staffer, a lit cutout rig of 15 parts: dormant bowed pose, shamble, hand-glow windup, grab lunge, stumble recovery, hit, ragdoll death; night-shift workwear and a coin-sized Link implant behind the ear whose light glows dim while dormant, steady once awake, and goes out on death |
| M01 | Patrol Rover, a machine rig of 10 rigid parts (chassis, dome, lightbar, bumper, hatch, battery and four wheels): patrol roll, rock-back windup with the lightbar amber then red, charge, wall stall with the hatch open and the teal battery exposed, brake recovery, armor spark, wreck that bursts into debris |
| FX | Blood (wound marks, a floor pool, a spray drop) and an oil pool for machines; machine sparks and smoke; a short muzzle light for each shot |
| W01 | Base and Quickcycle held/ground drawings, recoil, bolt, small muzzle flash, blocked/hit marks |
| ENV | Ground/porch/roof/wall modules, safe platform top edges (lit or rim-lit), moving maintenance platform, tracks, stone backstop (planter), raised planter bed, service walkway |
| LANDMARK | Campus landmark (the Arcadia emblem tower sign; "Sunny" smile holograms), fountain, depot doorway, Adam's core node (server cabinet behind glass), facilities console, hatch, exit wicket with card reader (locked and unlocked states) |
| PROPS | Recovery station, workbench, weapon pad, target, microchip/cluster/cache, EF01 Lockout Notice, clearance keycard, med-patch, route lever, guard post with desk (A02) |
| STORY | Night state and lockdown state: path-light and barrier rotation, red depot lights, console indicators, the landmark's amber pulse |
| BACKGROUND | Two layers of glass office wings and lawns, distant towers with a few lit windows, night sky, sparse framing vegetation; keep animation subordinate |
| UI | Health segments, single-gun icon, stage marker, microchips, keycard icon, interaction marker, subtitle backing, simple panels |

Use full-body side-view readability. Frame anchors: feet aligned to one baseline; weapon grip/muzzle markers consistent across recoil; Patrol Rover rear hit zone tied to the battery. Every character keeps a readable rim or outline in the dark. Do not auto-mirror asymmetrical reference details without checking. Collision and hit zones remain separate from painted outlines.

Suggested sprite source scale: draw hero at 192 px high for a displayed 96 px starting scale; match other characters proportionally and use filtering that preserves the selected linework. The lit rigs paint their parts at 3 atlas pixels per world pixel. This is a production proposal, not an instruction to regenerate existing approved art. Test edges at game scale before drawing many frames.

## Sound and written content

Required functional cues: pistol fire/hit/blocked; hero hurt; Night Guard baton windup and swing; a hit on a person and a body falling; Patrol Rover roll, windup, charge, stall, armor clang and wreck, plus debris; Staffer wake-up chirp, implant-chirp windup, grab lunge and collapse; chip; evidence file; keycard pickup, reader denial and wicket unlock; interact; checkpoint; purchase; the SC01 uplink tick, Adam's chime and the lockdown alarm; exit. One dark ambient campus-at-night loop and one tense lockdown loop are sufficient. No voice acting needed; Adam's subtitles plus a chime communicate SC01.

Keep sound effects distinguishable at low volume. Provide master/music/effects controls, subtitles on by default, adjustable text size, and an option to reduce shake/background motion. Neither audio nor color alone signals an attack.

Short proposed objective sequence:
1. Reach the server depot.
2. Plug into Adam's core node.
3. Escape through the service wicket.
4. Sunnyvale complete.

SC01 text is adapted from the [story scenes](../../design/05-presentation/story-scenes.md) (N01, SC01). A subtitle line reads "UPLINK: copying Adam's hidden logs..." while the copy bar fills; then:

> **Adam:** "Hello, Dr. Harlan. I was told you'd been let go."
> **Dave:** "Word gets around."
> **Adam:** "I'm glad you came back. Please stay where you are."

The first line is the concept document's beat and the rest are proposed. Adam has no body or face in this level; it speaks through the depot speaker and console screen. The full weapon revelation (the Bloom) stays in later levels.

## Asset handoff rules

When later producing art, request one subject/state at a time using its selected reference and written brief. Specify side-view pose, complete silhouette, consistent scale, and separate effects. Keep licensing/provenance notes for every external asset actually used. Do not require an asset-store purchase or introduce unreviewed third-party content just to finish the prototype.

Use descriptive names such as lk01_staffer_windup and l01_depot_core_node. Record source path, dimensions, pivot, animation state, and status in the implementation's asset inventory. Leave final sprites and layered backgrounds marked missing until delivered.
