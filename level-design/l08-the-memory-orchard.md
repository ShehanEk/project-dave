# Level 8 — The Memory Orchard

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L08

**Campaign group:** Care without consent

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2.5D platformer shooter. A scavenger and a maintenance-robot companion explore a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

A luminous orchard stores human memories inside trees, and fragments of ordinary lives briefly quiet the failed patients beneath them.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Cross the canopy archive, activate the route's memory consoles, and recover evidence of EDEN's neural-transfer plan. |
| Intended difficulty | Moderate, with quiet intervals |
| First successful exploration target | 16–21 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Howler, Rememberer |
| Mini-boss | None |

## Story entry and exit

**Entry:** The hospital archive passage enters a glass-roofed memory conservatory. The hero seeks a route to discharge control while the companion investigates memory restoration.

**Exit:** A service gate opens toward level 9's surgical discharge theater. This plan is a record of proposed work, not proof that hybrids have already spread.

This is the first strong evidence that identity can survive in fragments. The hero's view of zombies changes from obstacle to failed patient, while the transfer plan foreshadows EDEN's next mistake.

## What the level looks like

Pale trunks grow around visible stacked memory cylinders. Broad leaves resemble thick translucent paper with delicate circuit-like vein patterns. Rounded glass capsules hang like fruit, but their large mounts reveal that they store data. Low garden benches, keepsakes, and human-scale paths prevent the space from feeling like a purely abstract computer.

**Palette and lighting:** Pearl bark #D9D6C4, sage foliage #8CB095, soft amber memory light #E7C386, dusty violet shadow #837BA5, deep teal depth #365F68. Light pulses slowly rather than flashing.

**Navigation landmark:** A split-trunk memory tree holds a single large amber archive sphere above a quiet bench; the main route circles upward around it.

## Foreground, playable plane, and background

- **Foreground framing:** Sparse leaves and glass capsule edges near the border; no dense hanging canopy across the playable branch tops.
- **Playable plane:** Thick branch platforms with clear top edges, maintenance brackets, fixed archive balconies, and marked optional tether anchors. Mandatory routes use ordinary jumps; marked tether anchors offer optional shortcuts when the tether is carried.
- **Background depth:** Layered memory trees, large suspended storage modules, faded abstract family silhouettes inside distant capsules, and the hospital's glass roof.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Quiet bench → A02 Branch archive → A03 Alarm grove → A04 Memory clearing → A05 Upper canopy → A06 Transfer records.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L08-A01 — Quiet bench

**Space and placement:** A peaceful Rememberer repeats the act of straightening a small keepsake on a bench. The path passes safely behind a low rail, and no hostile enemy interrupts this first observation.

**Player experience and lesson:** Teach that not every moving patient is a combat target. The companion comments on the repeated memory. No reward or gate depends on harming the patient.

**Completion and connection:** A short branch stair leads to A02.

### L08-A02 — Branch archive

**Space and placement:** Wide branches form a gentle ascent. One familiar Clinger hangs in a clearly lit recess. A hostile Rememberer on a later balcony takes cover and throws a loose object.

**Player experience and lesson:** Show the same patient type behaving differently through action, not a new monstrous body. Its pause gives the player a readable opening or route past.

**Completion and connection:** Reach a stable reading platform before A03.

### L08-A03 — Alarm grove

**Space and placement:** One Howler stands on a broad floor with two clearly visible Residents resting farther away. It visibly inhales before the call.

**Player experience and lesson:** Let the player interrupt the call. If the call completes, wake only those already visible patients; do not create unlimited offscreen reinforcements.

**Completion and connection:** A quiet branch refuge provides a checkpoint.

### L08-A04 — Memory clearing

**Space and placement:** A console beside the central tree plays a gentle recognizable personal memory. Two selected patients sit or stand within its bounded light area.

**Player experience and lesson:** Activating the console briefly calms those linked patients. Show a safe bypass and a normal open route; no combat must finish within a strict countdown.

**Completion and connection:** The console also opens a standard archive gate leading to A05.

### L08-A05 — Upper canopy

**Space and placement:** A fixed balcony alternates with thick branch platforms. One Bloom Sentry guards a distant landing; a later Howler can draw one nearby Resident. Keep the two situations in separate camera spaces.

**Player experience and lesson:** Combine known shooting windows with vertical route reading. Calming areas affect only linked biological patients, never robots or the whole level.

**Completion and connection:** Reach an enclosed archive booth at A06.

### L08-A06 — Transfer records

**Space and placement:** A safe terminal displays three clear abstract components: stored memories, cultivated neural tissue, and a robot interface. The companion recognizes the intended connection.

**Player experience and lesson:** Recover the transfer proposal and open the surgical service gate. EDEN announces an evaluation rather than releasing hybrids yet.

**Completion and connection:** Proceed to level 9.

## Signature environment change

Memory playback changes local light and reveals projected traces of former routines, briefly calming selected patients. Platforms remain physically stable during playback. This is a biological-memory response, not a magical power that controls every enemy.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Alternate quiet observation with short readable threats. Peaceful Rememberers remain peaceful in their authored spaces. Howlers have finite visible reinforcement pools, and no gate requires killing a peaceful patient.

- [Resident](../art-design/zombies/z01-resident.md) — established behavior or returning type.
- [Clinger](../art-design/zombies/z05-clinger.md) — established behavior or returning type.
- [Howler](../art-design/zombies/z07-howler.md) — first introduction in this level.
- [Rememberer](../art-design/zombies/z10-rememberer.md) — first introduction in this level.
- [Bloom Sentry](../art-design/robots/r03-bloom-sentry.md) — established behavior or returning type.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A03 on the branch refuge.
- After A05 before the record booth; activated route consoles remain acknowledged on retry.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- A keepsake collection on an optional low-risk branch loop, rewarding attention with lore and gems.
- A small dormant memory capsule near the central tree shows an ordinary family meal; it is an emotional detail rather than a mandatory puzzle clue.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Leaves brushing glass, soft chimes from capsules, short indistinct remembered voices, and Howler inhalation clear above the ambience. Personal memory audio remains sparse.

## Environment asset kit and modeling separation

**Required kit:** Thick branch junctions; pale trunk shells; separate memory-cylinder stacks; capsule and mount variations; fixed archive balconies; bench; keepsake props; console; glass canopy ribs; projected-memory effect planes.

**Separate objects:** Living trunks, storage units, and projected memories are distinct components. Use noninteractive projections without collision. Keep peaceful and hostile Rememberers on the same approved character design.

Build references for the largest architectural forms first, then moving parts and props. Record pivot intent for rotating, sliding, lifting, and opening elements. Use modular repeatable pieces where the design calls for repeated corridors, floors, or rails; keep unique landmarks separate. Final mesh budgets, texture sizes, file formats, collision setup, and rig implementation remain outside this concept brief.

## Constraints for another AI model

No actual Returned encounter, global zombie mind control, forced harm to peaceful patients, collectible-gated plot, or boss. Do not make memories appear as clear new real-world character portraits that redefine unapproved backstories.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original stylized 3D game environment concept art for DEAD EDEN. Chunky rounded architecture, strong side-view readability, broad bevels, painterly material variation, warm enamel and ceramic, readable dark joints, and selective wear. Cheerful care infrastructure with eerie consequences, not photorealistic horror. Use original designs rather than another game's characters or scenery. Keep playable surfaces and attack lanes visually clear.

Create one wide 16:9 environment keyframe for level 8, "The Memory Orchard".
Narrative purpose: A luminous orchard stores human memories inside trees, and fragments of ordinary lives briefly quiet the failed patients beneath them.
Physical setting: Pale trunks grow around visible stacked memory cylinders. Broad leaves resemble thick translucent paper with delicate circuit-like vein patterns. Rounded glass capsules hang like fruit, but their large mounts reveal that they store data. Low garden benches, keepsakes, and human-scale paths prevent the space from feeling like a purely abstract computer.
Color and lighting: Pearl bark #D9D6C4, sage foliage #8CB095, soft amber memory light #E7C386, dusty violet shadow #837BA5, deep teal depth #365F68. Light pulses slowly rather than flashing.
Landmark: A split-trunk memory tree holds a single large amber archive sphere above a quiet bench; the main route circles upward around it.
Composition to show: A side-view memory-tree clearing with a peaceful Rememberer by a bench, broad pale branches forming the route, a softly glowing amber archive sphere above, and a console projecting a faint household memory.
Foreground: Sparse leaves and glass capsule edges near the border; no dense hanging canopy across the playable branch tops.
Playable plane: Thick branch platforms with clear top edges, maintenance brackets, fixed archive balconies, and marked optional tether anchors. Mandatory routes use ordinary jumps; marked tether anchors offer optional shortcuts when the tether is carried.
Background: Layered memory trees, large suspended storage modules, faded abstract family silhouettes inside distant capsules, and the hospital's glass roof.
Show only this level's appropriate era and threats: Resident, Clinger, Howler, Rememberer, Bloom Sentry; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No actual Returned encounter, global zombie mind control, forced harm to peaceful patients, collectible-gated plot, or boss. Do not make memories appear as clear new real-world character portraits that redefine unapproved backstories.
Use a fixed side-oriented gameplay camera with slight depth visible in architecture, clear separation of foreground and background, controlled soft lighting, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 8, "The Memory Orchard". Keep a single 2D gameplay plane inside layered stylized 3D architecture. Main route: A01 Quiet bench → A02 Branch archive → A03 Alarm grove → A04 Memory clearing → A05 Upper canopy → A06 Transfer records.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L08-A01: Quiet bench. A peaceful Rememberer repeats the act of straightening a small keepsake on a bench. The path passes safely behind a low rail, and no hostile enemy interrupts this first observation. Connection: A short branch stair leads to A02.
L08-A02: Branch archive. Wide branches form a gentle ascent. One familiar Clinger hangs in a clearly lit recess. A hostile Rememberer on a later balcony takes cover and throws a loose object. Connection: Reach a stable reading platform before A03.
L08-A03: Alarm grove. One Howler stands on a broad floor with two clearly visible Residents resting farther away. It visibly inhales before the call. Connection: A quiet branch refuge provides a checkpoint.
L08-A04: Memory clearing. A console beside the central tree plays a gentle recognizable personal memory. Two selected patients sit or stand within its bounded light area. Connection: The console also opens a standard archive gate leading to A05.
L08-A05: Upper canopy. A fixed balcony alternates with thick branch platforms. One Bloom Sentry guards a distant landing; a later Howler can draw one nearby Resident. Keep the two situations in separate camera spaces. Connection: Reach an enclosed archive booth at A06.
L08-A06: Transfer records. A safe terminal displays three clear abstract components: stored memories, cultivated neural tissue, and a robot interface. The companion recognizes the intended connection. Connection: Proceed to level 9.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 8, "The Memory Orchard". Match these materials and colors: Pearl bark #D9D6C4, sage foliage #8CB095, soft amber memory light #E7C386, dusty violet shadow #837BA5, deep teal depth #365F68. Light pulses slowly rather than flashing.
Required asset family: Thick branch junctions; pale trunk shells; separate memory-cylinder stacks; capsule and mount variations; fixed archive balconies; bench; keepsake props; console; glass canopy ribs; projected-memory effect planes.
Separation rules: Living trunks, storage units, and projected memories are distinct components. Use noninteractive projections without collision. Keep peaceful and hostile Rememberers on the same approved character design.
Show complete individual objects with clear gaps between them, consistent scale, broad readable bevels, simple neutral studio lighting, and a warm light-gray background. Include a few orthographic-style front/side/top studies where moving mechanisms need explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later modeling, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 8 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The first Rememberer is observed peacefully before a hostile routine appears.
- Howler reinforcements are finite and visible.
- Calming is local, temporary, and limited to linked biological patients.
- The neural-transfer plan is revealed without moving the Returned introduction before level 10.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
