# 05 — Content and asset handoff

**Visual direction (C11, C15):** [hand-drawn 2D in a dark night-campus palette](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24); there are no selected scene images for the new look.

## Existing selected references

Paths below resolve to the approved originals. Keep these originals intact; imported derivatives belong in the Godot project. The revamp deleted the zombie Resident concept art and the three daytime Sunnyvale scenes (C23), and C32 later deleted the Clipper PNG, so no concept PNG remains selected.

| Subject | Source |
| --- | --- |
| Clipper (removed, C32) | Its selected PNG and identity brief were deleted with it; the brief's file became the fresh [Patrol Rover](../../art-design/machines/m01-patrol-rover.md) design, which must not resemble the Clipper. The C24 build still draws the Clipper procedurally until the C33 rebuild |
| Staffer | [Identity brief](../../art-design/linked/lk01-staffer.md); no selected image (the zombie Resident PNG was deleted), so it is drawn procedurally |
| Level look | No selected scene images. Use the [level brief](../../level-design/l01-welcome-to-sunnyvale.md) and the [style guide](../../art-design/style-guide.md) (night palette, drawn light, readability rules) |
| Hero | [Proposed H01 brief](../../design/02-characters/hero.md) for Dave Harlan; the [Rook sprite pack](../../concept-art/h01-rook/rook-sprite-brief-for-chatgpt.md) is placeholder art, not a selected design |
| Pistol / Quickcycle | [W01 brief](../../art-design/weapons/w01-scrapjack-pistol.md); no selected finished weapon sprites |
| Evidence file | [EF01 Lockout Notice](../../design/03-progression/evidence-files.md) |
| Shared art | [2D style guide](../../art-design/style-guide.md) |

A concept PNG is a reference, not an isolated sprite, collision map, layered background, or animation sheet. Do not stretch a scene picture across the whole level and treat its painted platforms as playable geometry.

## Night palette and drawn light

Use the style guide's tokens: near-black #07090F for voids and silhouettes, navy #0E1726 for the sky, steel #1C2A3A and slate #2E3B4E for structures and paving, Arcadia/Adam teal #3FE0D0 for signage, screens and idle Link lights, hazard amber #FFB02E for security lamps and warnings, alarm red #FF3B4E for attack tells and lockdown lamps only, microchip gold #FFD166 for pickups, and signal green #4DE38A for exit signs and status LEDs. Bloom violet #C77DFF is not used in Level 1. Dave's jacket is burnt orange so he reads against the cool darks.

Reserved meanings: red means attack now or locked, amber means warning or Adam's attention, teal means Arcadia and Adam at rest or unlocked, gold means pickups. Light is drawn as flat pools, rim light and flat glow shapes; put a light near every landing and never let darkness hide a tell, a ledge or a pickup.

## Production priority

**Blockout first:** flat colored shapes, simple readable hero/enemy silhouettes, line-drawn warnings, temporary sound cues. These are explicitly temporary visuals. Finish a playable route before requesting a large art batch.

**Readability pass:** apply the night palette, lit or rim-lit platform edges, enemy identity, held-gun contact, simple sprite motion, foreground/background separation, and a recognizable campus landmark.

**Prototype art pass:** replace temporary drawings where assets exist. If final animation is unavailable, keep honest placeholder animation; do not claim finished matching sprites. Record each asset as reference-only, placeholder, draft, or usable-in-prototype.

## Minimum asset list

| ID family | Needed for this slice |
| --- | --- |
| HERO | Idle, run, jump rise/fall, land, aim/fire upper body, hit, defeated, interact; empty-hand base plus separate held gun (Dave Harlan; the placeholder Rook pack covers these until new art exists) |
| CY01 | Stiff idle and walk, twitch windup with a red Link flash, lunge, recovery, hit, defeated (Link light dies, body slumps, no gore; C24 build, superseded by C28 and C29); Arcadia night-shift workwear and a coin-sized Link implant behind the ear |
| R01 | Roll, eye/shear windup, charge, wall stall with exposed rear, recovery, hit, defeated; two separate eye stalks and two blades; lenses amber, red only from windup to the end of an attack |
| W01 | Base and Quickcycle held/ground drawings, recoil, bolt, small muzzle flash, blocked/hit marks |
| ENV | Ground/porch/roof/wall modules, safe platform top edges (lit or rim-lit), moving maintenance platform, tracks, stone backstop (planter), raised planter bed, service walkway |
| LANDMARK | Campus landmark (the Arcadia emblem tower sign; "Sunny" smile holograms), fountain, depot doorway, Adam's core node (server cabinet behind glass), facilities console, hatch, exit wicket with card reader (locked and unlocked states) |
| PROPS | Recovery station, workbench, weapon pad, target, microchip/cluster/cache, EF01 Lockout Notice, clearance keycard, med-patch, route lever, guard post with desk (A02) |
| STORY | Night state and lockdown state: path-light and barrier rotation, red depot lights, console indicators, the landmark's amber pulse |
| BACKGROUND | Two layers of glass office wings and lawns, distant towers with a few lit windows, night sky, sparse framing vegetation; keep animation subordinate |
| UI | Health segments, single-gun icon, stage marker, microchips, keycard icon, interaction marker, subtitle backing, simple panels |

Use full-body side-view readability. Frame anchors: feet aligned to one baseline; weapon grip/muzzle markers consistent across recoil; Clipper rear hit zone tied to the motor. Every character keeps a readable rim or outline in the dark. Do not auto-mirror asymmetrical reference details without checking. Collision and hit zones remain separate from painted outlines.

Suggested sprite source scale: draw hero at 192 px high for a displayed 96 px starting scale; match other characters proportionally and use filtering that preserves the selected linework. This is a production proposal, not an instruction to regenerate existing approved art. Test edges at game scale before drawing many frames.

## Sound and written content

Required functional cues: pistol fire/hit/blocked; hero hurt; Staffer implant chirp (as the Link turns amber), windup, lunge and defeat; Clipper scrape/charge/stall; chip; evidence file; keycard pickup, reader denial and wicket unlock; interact; checkpoint; purchase; the SC01 uplink tick, Adam's chime and the lockdown alarm; exit. One dark ambient campus-at-night loop and one tense lockdown loop are sufficient. No voice acting needed; Adam's subtitles plus a chime communicate SC01.

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

Use descriptive names such as cy01_staffer_windup and l01_depot_core_node. Record source path, dimensions, pivot, animation state, and status in the implementation's asset inventory. Leave final sprites and layered backgrounds marked missing until delivered.
