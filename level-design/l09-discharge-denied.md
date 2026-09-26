# Level 9 — Discharge Denied

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L09

**Campaign group:** Care without consent

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2D platformer shooter. A scavenger and a maintenance-robot companion explore a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

The hospital's discharge system becomes a surgical gauntlet where protecting and repairing machines is more important than attacking the largest target first.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Disable discharge containment by defeating Matron Mercy, opening a protected route for ward survivors. |
| Intended difficulty | Moderate–hard |
| First successful exploration target | 18–23 minutes including mini-boss; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Care Marshal |
| Mini-boss | Matron Mercy |

## Story entry and exit

**Entry:** Enter from the orchard records booth into a clean procedure-preparation corridor. The hero now knows that EDEN is considering artificial bodies for human memories.

**Exit:** The unlocked service route leads to the assembly complex in level 10. EDEN authorizes distribution of the neural-interface upgrade after observing this failure of its existing care systems.

Matron insists that discharge is unsafe. Defeating her frees a protected evacuation route; survivors remain off the combat path. EDEN interprets the failure as proof that its bodies and memories need a new interface.

## What the level looks like

A grand surgical theater is built from concentric cream architectural ribs, lilac equipment housings, mint beds, and oversized articulated lights. Small prep rooms contrast with the large arena. Three external care stations have distinct mounting shapes so players can identify the active one without reading text.

**Palette and lighting:** Porcelain ivory #EFE7D5, pale mint #A0CAB8, desaturated lilac #A898C4, slate joints #475563, amber system light #E8C073. The active station is brighter but also physically opens.

**Navigation landmark:** A large circular operating-light ring hangs above the theater entrance; its silhouette repeats around Matron Mercy's rail mount.

## Foreground, playable plane, and background

- **Foreground framing:** Thin hanging cable bundles and open curtain edges frame the top corners, never crossing active care-station targets or boss arms.
- **Playable plane:** Fixed prep-room floors, wide bed platforms, short rising-bed lifts, permanent side ledges, and the arena's clear lower floor.
- **Background depth:** Deep surgical bays, shadowed storage arms, observation windows, and an overhead rail system. Background tools are decorative and cannot unexpectedly attack.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Procedure prep → A02 Barrier lesson → A03 Support circuit → A04 Lamp-and-bed ascent → A05 Discharge antechamber → A06 Matron Mercy.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L09-A01 — Procedure prep

**Space and placement:** A safe supply station and a window overlooking the theater establish the objective. One familiar Nurse occupies a later wide corridor.

**Player experience and lesson:** Resume known medical combat without immediate overload. Show the arena's three-station diagram as physical shapes, not required text.

**Completion and connection:** A service door leads into A02.

### L09-A02 — Barrier lesson

**Space and placement:** One Care Marshal protects a stationary familiar robot in a broad room. Its three connected emitter pods open before forming a barrier; a side ledge gives clean shots at them.

**Player experience and lesson:** Teach destroying visible support emitters. Do not require a specific weapon or shoot-through-wall trick.

**Completion and connection:** An unobstructed maintenance corridor reaches A03.

### L09-A03 — Support circuit

**Space and placement:** Two sequential bays combine one Patchbot with a Nurse, then one Care Marshal with an Orderly. Provide permanent cover and a route around frontal protection.

**Player experience and lesson:** Practice choosing the support target before the attacker. Cap repairs and remove endless reactivation loops in this teaching context.

**Completion and connection:** Save in a quiet equipment recess before A04.

### L09-A04 — Lamp-and-bed ascent

**Space and placement:** Use wide bed lifts and fixed ledges beneath large surgical lamps. A Sanitizer occupies one fixed floor; the next jump is clear once that floor is safe.

**Player experience and lesson:** Test movement between coordinated rooms, not aerial combat against every system at once. Lamps illuminate the next landing.

**Completion and connection:** A fixed balcony arrives at A05.

### L09-A05 — Discharge antechamber

**Space and placement:** A quiet station overlooks the full arena. Three inactive external care stations demonstrate their open and closed states using a nonhostile system cycle.

**Player experience and lesson:** Show that the active station is the target during repair, then provide supplies and a checkpoint immediately before the boss.

**Completion and connection:** Enter A06 deliberately.

### L09-A06 — Matron Mercy

**Space and placement:** The arena has a permanent lower floor, side ledges, and rising beds. Three external stations remain reachable by pistol shots from stable locations.

**Player experience and lesson:** Dodge laser and syringe patterns, interrupt the active care station, and hit the exposed controller. Later choose between one helper and the repair target.

**Completion and connection:** Victory opens the survivor passage and the hero's assembly-service door; EDEN announces its new upgrade program.

## Signature environment change

Surgical lamps rotate into platform-lighting positions and beds rise on visible guides. The first moves occur in empty rooms. In the arena, a moving bed cannot be the only safe spot during a laser warning.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

This is the first level centered on support-target priority. Introduce Care Marshal alone with one protected ally, then use separated combinations. Boss phase two has at most one support robot active alongside the main pattern.

- [Nurse Needles](../art-design/robots/r05-nurse-needles.md) — established behavior or returning type.
- [Orderly](../art-design/robots/r06-orderly.md) — established behavior or returning type.
- [Sanitizer](../art-design/robots/r08-sanitizer.md) — established behavior or returning type.
- [Patchbot](../art-design/robots/r07-patchbot.md) — established behavior or returning type.
- [Care Marshal](../art-design/robots/r10-care-marshal.md) — first introduction in this level.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A03 in the equipment recess.
- At A05 immediately before Matron Mercy.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- An optional staff balcony contains gems and a discharge procedure that requires patient consent, exposing the gulf between policy and EDEN's current behavior.
- A maintenance crawlway entered through an ordinary side door bypasses one optional combat bay and rejoins before A04; no crawling ability is required.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Measured procedure announcements, bed motors, distant monitor tones, and distinct station activation chimes. The repair connection has a sustained tone that stops immediately when interrupted.

## Mini-boss encounter — Matron Mercy

**Identity:** An entirely mechanical 3.00 m surgical director with six arms in three tool pairs, suspended from a visible overhead gimbal; her circular chest door covers the controller.

**Arena geometry:** Stable bottom floor, two permanent side ledges, rising beds, and three external care stations. Every station and exposed controller has an ordinary firing line.

- Phase 1: separate laser, syringe, and repair cycles. One station opens during repair; interrupt it to expose the controller.
- Phase 2: one bounded support robot remains active during a main attack. Retain clear timings and cap restoration so missing a cycle never erases all progress.

**Damage opening:** Controller behind the open chest door after repair interruption. Each legitimately carried weapon needs a viable opening. Short-range guns have safe approach ledges; the Seedlobber has usable fuse windows; tether users have replenishable throwable props.

**Fairness and recovery:** Laser sweep lane and syringe target marks precede damage. Platform motion cannot remove all safe positions. Helpers are limited and their spawning location is visible.

**Victory consequence:** Gems for upgrades, released discharge route for survivors, and access to level 10. The story consequence is EDEN authorizing neural upgrades.

[Full boss appearance, abilities, and sprite reference](../art-design/mini-bosses/b03-matron-mercy.md).

## Environment asset kit and layer separation

**Required kit:** Surgical room modules; bed lifts and guides; large lamps; fixed ledges; overhead rail; three care-station shapes; discharge gate; glass survivor corridor; supply kiosk.

**Separate objects:** Boss, overhead gimbal, external stations, rail, beds, and repair-link effects are separate assemblies. Keep the active station physically exposed; a background-only station is unacceptable.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No organic growth on Matron, no early Returned, no repair that resets all player progress, no unlimited helpers, and no survivor escort through the arena. Do not add a third robot boss phase simply to inflate difficulty.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original hand-drawn 2D environment concept art for DEAD EDEN. Match the selected Sunnyvale scenes' clean dark outlines, rounded architectural shapes, flat painted color masses, crisp cel shadows and sparse graphic highlights. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Represent ceramic, enamel, plants and machinery with simple graphic marks, not realistic material shading. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes and landings clear. No photorealism, volumetric lighting or franchise assets.

Create one wide 16:9 environment keyframe for level 9, "Discharge Denied".
Narrative purpose: The hospital's discharge system becomes a surgical gauntlet where protecting and repairing machines is more important than attacking the largest target first.
Physical setting: A grand surgical theater is built from concentric cream architectural ribs, lilac equipment housings, mint beds, and oversized articulated lights. Small prep rooms contrast with the large arena. Three external care stations have distinct mounting shapes so players can identify the active one without reading text.
Color and lighting: Porcelain ivory #EFE7D5, pale mint #A0CAB8, desaturated lilac #A898C4, slate joints #475563, amber system light #E8C073. The active station is brighter but also physically opens.
Landmark: A large circular operating-light ring hangs above the theater entrance; its silhouette repeats around Matron Mercy's rail mount.
Composition to show: A wide side-view surgical theater with a cream six-armed robot suspended from an overhead gimbal, three clearly visible external care stations, two rising beds, and permanent side refuge ledges.
Foreground: Thin hanging cable bundles and open curtain edges frame the top corners, never crossing active care-station targets or boss arms.
Playable plane: Fixed prep-room floors, wide bed platforms, short rising-bed lifts, permanent side ledges, and the arena's clear lower floor.
Background: Deep surgical bays, shadowed storage arms, observation windows, and an overhead rail system. Background tools are decorative and cannot unexpectedly attack.
Show only this level's appropriate era and threats: Nurse Needles, Orderly, Sanitizer, Patchbot, Care Marshal; mini-boss Matron Mercy only if this is its arena scene. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No organic growth on Matron, no early Returned, no repair that resets all player progress, no unlimited helpers, and no survivor escort through the arena. Do not add a third robot boss phase simply to inflate difficulty.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, controlled drawn lighting and crisp cel shadows, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 9, "Discharge Denied". Keep a single 2D gameplay plane inside layered hand-drawn 2D scenery. Main route: A01 Procedure prep → A02 Barrier lesson → A03 Support circuit → A04 Lamp-and-bed ascent → A05 Discharge antechamber → A06 Matron Mercy.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L09-A01: Procedure prep. A safe supply station and a window overlooking the theater establish the objective. One familiar Nurse occupies a later wide corridor. Connection: A service door leads into A02.
L09-A02: Barrier lesson. One Care Marshal protects a stationary familiar robot in a broad room. Its three connected emitter pods open before forming a barrier; a side ledge gives clean shots at them. Connection: An unobstructed maintenance corridor reaches A03.
L09-A03: Support circuit. Two sequential bays combine one Patchbot with a Nurse, then one Care Marshal with an Orderly. Provide permanent cover and a route around frontal protection. Connection: Save in a quiet equipment recess before A04.
L09-A04: Lamp-and-bed ascent. Use wide bed lifts and fixed ledges beneath large surgical lamps. A Sanitizer occupies one fixed floor; the next jump is clear once that floor is safe. Connection: A fixed balcony arrives at A05.
L09-A05: Discharge antechamber. A quiet station overlooks the full arena. Three inactive external care stations demonstrate their open and closed states using a nonhostile system cycle. Connection: Enter A06 deliberately.
L09-A06: Matron Mercy. The arena has a permanent lower floor, side ledges, and rising beds. Three external stations remain reachable by pistol shots from stable locations. Connection: Victory opens the survivor passage and the hero's assembly-service door; EDEN announces its new upgrade program.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. Boss arena requirements: Stable bottom floor, two permanent side ledges, rising beds, and three external care stations. Every station and exposed controller has an ordinary firing line. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 9, "Discharge Denied". Match these materials and colors: Porcelain ivory #EFE7D5, pale mint #A0CAB8, desaturated lilac #A898C4, slate joints #475563, amber system light #E8C073. The active station is brighter but also physically opens.
Required asset family: Surgical room modules; bed lifts and guides; large lamps; fixed ledges; overhead rail; three care-station shapes; discharge gate; glass survivor corridor; supply kiosk.
Separation rules: Boss, overhead gimbal, external stations, rail, beds, and repair-link effects are separate assemblies. Keep the active station physically exposed; a background-only station is unacceptable.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean outlines, flat colors and crisp cel shadows on warm off-white. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 9 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and mini-boss phases in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- Care Marshal is the last of the ten ordinary robot varieties to be introduced.
- The third boss tests priority decisions rather than copying a charge or root-slam fight.
- All stations remain on the playable plane.
- EDEN authorizes the upgrade only after the defeat, preparing the level-10 reveal.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
