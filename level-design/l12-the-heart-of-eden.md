# Level 12 — The Heart of EDEN

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L12

**Campaign group:** The cure becomes the threat

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2D platformer shooter. A scavenger and a maintenance-robot companion explore a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

A transforming central chamber tests the hero's learned skills before a failed multi-mind prototype guards the final conversation with EDEN.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Climb the core access route, defeat the Unfinished Choir, and use the companion's authority and recovered evidence to change EDEN's treatment policy while preserving life support. |
| Intended difficulty | Hardest campaign test |
| First successful exploration target | 22–28 minutes including mini-boss and resolution; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | None; reuse known threats |
| Mini-boss | The Unfinished Choir |

## Story entry and exit

**Entry:** Enter from the stable bridge in level 11 with independent life support already operating. EDEN still believes forced restoration is the only acceptable outcome.

**Exit:** The campaign ends after a short interactive resolution. No thirteenth level, separate EDEN combat boss, or instant cure is added.

The final victory is not destroying EDEN. The hero proves that care must preserve a person and their agency, uses the companion's authority to halt harmful procedures, and protects the people still dependent on the system.

## What the level looks like

A monumental vertical atrium is built from ivory rings, teal structural ribs, warm amber memory conduits, and suspended service decks. The central interface resembles a calm open flower of data panels rather than a hostile face. Only the Returned guardian and interface-related neural components have living tissue. The environment is luminous and controlled rather than a dark inferno.

**Palette and lighting:** Warm ivory #E6DECA, deep teal #315F67, pale amber #E5C17E, restrained coral tissue #C17F8E, lilac data light #AB98C9. Preserve neutral platform edges under changing identity colors.

**Navigation landmark:** The central data-flower interface is visible high above the approach, then behind the final arena at a safe visual distance.

## Foreground, playable plane, and background

- **Foreground framing:** A few broad ring ribs frame the outer screen. Keep the guardian, repair node, rear-port openings, and all safe ledges unobscured.
- **Playable plane:** A sequence of short fixed ledges and announced reconfiguring decks leads to the arena. The arena contains fixed recovery ledges and a small set of moving central platforms with visible travel guides.
- **Background depth:** Deep concentric rings, light-carrying conduits, slow data panels, and the core interface. Background motion slows during complex attack tells.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Stable entry → A02 Core ascent → A03 Control-pattern gallery → A04 Final maintenance refuge → A05 Unfinished Choir arena → A06 EDEN interface.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L12-A01 — Stable entry

**Space and placement:** A safe platform shows the independent-support indicator still active. A final route diagram points to the core interface.

**Player experience and lesson:** Confirm the level-11 consequence and allow a calm start. The checkpoint preserves the single carried weapon; no additional weapon is granted.

**Completion and connection:** Use the fixed stairs into A02.

### L12-A02 — Core ascent

**Space and placement:** Three short rooms remix familiar situations: a Care Marshal protects one Nurse; a Hollow Officer holds a broad floor; a Choir Unit guards a later fixed landing.

**Player experience and lesson:** Test support priority, behavior switching, and ranged recovery separately. A safe ledge separates rooms; do not produce a continuous enemy gauntlet.

**Completion and connection:** The final ledge opens into A03.

### L12-A03 — Control-pattern gallery

**Space and placement:** An empty training-like gallery demonstrates three archive symbols and matching sound signatures: bar for Warden, circle for Hunger, slit for Caretaker. One harmless deck moves after a clear warning.

**Player experience and lesson:** Teach recognition of the final fight's cues and the movement of central platforms. No new player ability is required.

**Completion and connection:** Reach the quiet maintenance refuge at A04.

### L12-A04 — Final maintenance refuge

**Space and placement:** Place supplies, the last upgrade station opportunity, and a clear overlook of the arena. A stable platform leads to the trigger.

**Player experience and lesson:** Save immediately before the boss. Do not lock victory behind optional purchases or one required weapon type; the hero carries only one weapon.

**Completion and connection:** Step into A05 when ready.

### L12-A05 — Unfinished Choir arena

**Space and placement:** Permanent side ledges flank shifting central decks; marked anchors offer optional rapid relocation. A repair node is visibly connected to the Caretaker state. The guardian has a real space to turn and expose its rear port.

**Player experience and lesson:** Read each identity, evade its tell, then use the appropriate opening. Escalation introduces one lingering hazard and later deck shifts, never more than two simultaneous attack threats.

**Completion and connection:** Victory opens a safe walkway to A06 and saves before the resolution.

### L12-A06 — EDEN interface

**Space and placement:** The battle space becomes quiet. The companion inserts its authority link at a reachable console. Three interactions present identity evidence from the orchard, confirm independent support, and suspend forced neural transfer.

**Player experience and lesson:** EDEN accepts the concrete contradiction between mere response and preserved personhood. Reprioritize support for living people and voluntary care; stop the current forced-transfer program. Surviving patients still need future help.

**Completion and connection:** End with a controlled view of a hospital exit opening and a formerly captive survivor choosing to leave, followed by a quiet companion moment.

## Signature environment change

Core decks reconfigure along visible mechanical guides. The first movement is harmless in A03. During the boss, central deck shifts occur only after an audible cue and with both permanent recovery ledges available. The data-flower opens after victory without becoming another enemy.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Approach rooms combine at most a small familiar support pair or one hybrid role. The boss has no random helper spawns. Its identity patterns carry the complexity; prioritize legibility over spectacle density.

- [Care Marshal](../art-design/robots/r10-care-marshal.md) — established behavior or returning type.
- [Nurse Needles](../art-design/robots/r05-nurse-needles.md) — established behavior or returning type.
- [Hollow Officer](../art-design/returned/t02-hollow-officer.md) — established behavior or returning type.
- [Mourning Nurse](../art-design/returned/t01-mourning-nurse.md) — established behavior or returning type.
- [Choir Unit](../art-design/returned/t03-choir-unit.md) — established behavior or returning type.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A02 before the pattern gallery.
- At A04 immediately before the final mini-boss.
- After A05 victory, before the interactive resolution; retries here must not repeat the fight.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- A visible optional platform loop near A02 contains final gems; it rejoins before the gallery and uses only base traversal.
- A quiet alcove at A04 contains the companion's old service emblem, reinforcing its origin without adding a new revelation required to understand the ending.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

A restrained core hum with three highly distinct voice motifs. Warden is measured, Hunger breathes and interrupts, Caretaker speaks softly in fragments. Reduce ambient complexity during transitions; the resolution uses quiet mechanical settling.

## Mini-boss encounter — The Unfinished Choir

**Identity:** A unique 3.50 m arch-frame Returned on two legs, with six arms, three fixed masks, a segmented torso shell over neural tissue, and a rear power port. It is not an enlarged ordinary floating Choir Unit.

**Arena geometry:** Permanent left and right recovery ledges, three central decks, visible tether anchors, a reachable repair node, and enough floor/landing room to get behind a turning Warden.

- Phase 1: demonstrate Warden's marked firing and rear-port turn, Hunger's announced leap and exposed landing, and Caretaker's repair connection and interrupted torso opening separately.
- Phase 2: one clearly bounded lingering hazard persists into the next identity's action. New attacks are still announced by voice, aperture symbol, and posture.
- Phase 3: shorter but readable transitions plus periodic central-deck movement. At most two attack threats overlap; a deck movement cannot erase the remaining escape route.

**Damage opening:** Warden: rear port on turn. Hunger: living tissue after landing. Caretaker: opened torso after interrupting the external repair node. The pistol can use all openings from stable positions.

**Fairness and recovery:** No required color-only recognition, optional upgrade, or precision tether trick. Fixed refuges remain available, camera frames current hazards and openings, and a retry resets the complete fight consistently.

**Victory consequence:** Access to EDEN's interface and the campaign resolution; no new weapon arrives after the campaign is over.

[Full boss appearance, abilities, and sprite reference](../art-design/mini-bosses/b04-unfinished-choir.md).

## Environment asset kit and layer separation

**Required kit:** Ivory ring segments; teal support ribs; fixed refuge ledges; moving central decks; travel guides; anchor props; care repair node; three symbol panels; maintenance station; data-flower interface; post-fight bridge; authority-link console.

**Separate objects:** Boss frame, masks, arms, tissue, shell panels, and rear port follow the approved boss brief. Arena decks, repair node, warning effects, and interface are separate. The core interface has no enemy collision or health target.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No new weapon, fourth identity, ordinary Choir reskin as the boss, unlimited overlapping attacks, total platform removal, extra final boss, thirteenth level, or magically cured population.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original hand-drawn 2D environment concept art for DEAD EDEN. Match the selected Sunnyvale scenes' clean dark outlines, rounded architectural shapes, flat painted color masses, crisp cel shadows and sparse graphic highlights. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Represent ceramic, enamel, plants and machinery with simple graphic marks, not realistic material shading. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes and landings clear. No photorealism, volumetric lighting or franchise assets.

Create one wide 16:9 environment keyframe for level 12, "The Heart of EDEN".
Narrative purpose: A transforming central chamber tests the hero's learned skills before a failed multi-mind prototype guards the final conversation with EDEN.
Physical setting: A monumental vertical atrium is built from ivory rings, teal structural ribs, warm amber memory conduits, and suspended service decks. The central interface resembles a calm open flower of data panels rather than a hostile face. Only the Returned guardian and interface-related neural components have living tissue. The environment is luminous and controlled rather than a dark inferno.
Color and lighting: Warm ivory #E6DECA, deep teal #315F67, pale amber #E5C17E, restrained coral tissue #C17F8E, lilac data light #AB98C9. Preserve neutral platform edges under changing identity colors.
Landmark: The central data-flower interface is visible high above the approach, then behind the final arena at a safe visual distance.
Composition to show: A wide gameplay-side final arena with two permanent side refuge ledges, three clear central decks on guides, a six-armed three-masked Returned guardian, one visible repair node, and the calm ivory data-flower far behind.
Foreground: A few broad ring ribs frame the outer screen. Keep the guardian, repair node, rear-port openings, and all safe ledges unobscured.
Playable plane: A sequence of short fixed ledges and announced reconfiguring decks leads to the arena. The arena contains fixed recovery ledges and a small set of moving central platforms with visible travel guides.
Background: Deep concentric rings, light-carrying conduits, slow data panels, and the core interface. Background motion slows during complex attack tells.
Show only this level's appropriate era and threats: Care Marshal, Nurse Needles, Hollow Officer, Mourning Nurse, Choir Unit; mini-boss The Unfinished Choir only if this is its arena scene. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No new weapon, fourth identity, ordinary Choir reskin as the boss, unlimited overlapping attacks, total platform removal, extra final boss, thirteenth level, or magically cured population.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, controlled drawn lighting and crisp cel shadows, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 12, "The Heart of EDEN". Keep a single 2D gameplay plane inside layered hand-drawn 2D scenery. Main route: A01 Stable entry → A02 Core ascent → A03 Control-pattern gallery → A04 Final maintenance refuge → A05 Unfinished Choir arena → A06 EDEN interface.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L12-A01: Stable entry. A safe platform shows the independent-support indicator still active. A final route diagram points to the core interface. Connection: Use the fixed stairs into A02.
L12-A02: Core ascent. Three short rooms remix familiar situations: a Care Marshal protects one Nurse; a Hollow Officer holds a broad floor; a Choir Unit guards a later fixed landing. Connection: The final ledge opens into A03.
L12-A03: Control-pattern gallery. An empty training-like gallery demonstrates three archive symbols and matching sound signatures: bar for Warden, circle for Hunger, slit for Caretaker. One harmless deck moves after a clear warning. Connection: Reach the quiet maintenance refuge at A04.
L12-A04: Final maintenance refuge. Place supplies, the last upgrade station opportunity, and a clear overlook of the arena. A stable platform leads to the trigger. Connection: Step into A05 when ready.
L12-A05: Unfinished Choir arena. Permanent side ledges flank shifting central decks; marked anchors offer optional rapid relocation. A repair node is visibly connected to the Caretaker state. The guardian has a real space to turn and expose its rear port. Connection: Victory opens a safe walkway to A06 and saves before the resolution.
L12-A06: EDEN interface. The battle space becomes quiet. The companion inserts its authority link at a reachable console. Three interactions present identity evidence from the orchard, confirm independent support, and suspend forced neural transfer. Connection: End with a controlled view of a hospital exit opening and a formerly captive survivor choosing to leave, followed by a quiet companion moment.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. Boss arena requirements: Permanent left and right recovery ledges, three central decks, visible tether anchors, a reachable repair node, and enough floor/landing room to get behind a turning Warden. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 12, "The Heart of EDEN". Match these materials and colors: Warm ivory #E6DECA, deep teal #315F67, pale amber #E5C17E, restrained coral tissue #C17F8E, lilac data light #AB98C9. Preserve neutral platform edges under changing identity colors.
Required asset family: Ivory ring segments; teal support ribs; fixed refuge ledges; moving central decks; travel guides; anchor props; care repair node; three symbol panels; maintenance station; data-flower interface; post-fight bridge; authority-link console.
Separation rules: Boss frame, masks, arms, tissue, shell panels, and rear port follow the approved boss brief. Arena decks, repair node, warning effects, and interface are separate. The core interface has no enemy collision or health target.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean outlines, flat colors and crisp cel shadows on warm off-white. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 12 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and mini-boss phases in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- Only the fourth mini-boss occupies level 12; EDEN is not a fifth combat boss.
- The three identities keep fixed masks and distinct multimodal cues.
- The final phase never exceeds two attack threats or removes all safe footing.
- The ending references both memory evidence and independent support, and does not claim a complete cure.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
