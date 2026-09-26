# Level 4 — Roots and Rivets

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L04

**Campaign group:** Beneath the roots

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2D platformer shooter. A lone scavenger explores a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

Beneath immaculate lawns, giant living roots wind through a freight network that has been carrying the same supplies for centuries.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Recover the Arc Welder, traverse freight and server-root galleries, and open the botanical waste-processing route. |
| Intended difficulty | Easy–moderate |
| First successful exploration target | 14–18 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | Arc Welder |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder |
| New enemy types | Loadbearer, Patchbot, Clinger |
| Mini-boss | None |

## Story entry and exit

**Entry:** The parade lift deposits the hero in a quiet receiving bay. Floor indicators trace a route toward the hospital's water and treatment infrastructure.

**Exit:** An unlocked compost freight door leads to level 5. A maintenance log explains why the underground routines never stopped.

The contrast is between enormous automation and the absence of anyone checking its purpose. The hero compares old service manuals with the working machines and sees how obsolete orders have continued without human oversight.

## What the level looks like

Large rounded concrete ribs support low industrial halls. Chunky yellow freight machines work beside cream server cabinets wrapped in thick brown roots. Small luminous root buds illuminate copper pipes and abandoned order trays. Keep a believable service building underneath the growth; this is a functioning facility, not a generic cave.

**Palette and lighting:** Mustard industrial yellow #D0A84C, cream server shells #DAD5BF, teal shadows #3C6769, bark brown #715943, sparse cyan utility lights #7ACCC5. Warm pools at workstations distinguish refuge from dark recesses.

**Navigation landmark:** A massive root passes through the center of a transparent server cooling drum and reappears across two adjacent halls.

## Foreground, playable plane, and background

- **Foreground framing:** A few thick pipe bends and root ends frame the edges. Ceiling roots cannot hide a Clinger whose attack has begun.
- **Playable plane:** Clearly edged service walkways, slow conveyors, crate tops, fixed shelving landings, and an accessible maintenance floor under the first moving belts.
- **Background depth:** Deep server aisles, distant freight routes, inactive storage robots, and the enormous root cooling drum. Background belts carry scenery rather than surprise projectiles.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Receiving bay → A02 Repair workshop → A03 Freight stack → A04 Ceiling gallery → A05 Conveyor junction → A06 Compost door.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L04-A01 — Receiving bay

**Space and placement:** Exit the lift onto a safe ledge above one slow conveyor. A lower service floor catches failed jumps. Show a root breaking a decorative panel without changing the route.

**Player experience and lesson:** Introduce underground scale and conveyor motion before combat. A single familiar Clipper occupies the far fixed landing.

**Completion and connection:** Follow a bright workshop lamp into A02.

### L04-A02 — Repair workshop

**Space and placement:** A quiet bench contains the Arc Welder. Two inert conductive targets sit close enough to show a short chain, beside clear floor space.

**Player experience and lesson:** Teach short range and overheating. Demonstrate the gauge and a safe cooling pause before any repair enemy is active.

**Completion and connection:** Weapon collection opens a normal service door into A03; no weapon-specific electrical lock is required.

### L04-A03 — Freight stack

**Space and placement:** One Loadbearer stacks a crate, lifts another overhead, then throws toward a marked position. The room has permanent waist-high cover and an unobstructed upper firing ledge.

**Player experience and lesson:** Introduce the exposed belly during lifting. Then reveal one Patchbot repairing a damaged Clipper in a second, adjacent bay.

**Completion and connection:** The hero can shoot the repair unit first or interrupt with the welder; clearing the bay opens the route to A04.

### L04-A04 — Ceiling gallery

**Space and placement:** A short, brightly edge-lit corridor contains one Clinger on a low ceiling above a wide safe floor. The next alcove contains a second Clinger at a different height.

**Player experience and lesson:** Make the gripping posture and drop warning visible. Shooting the first enemy loosens its grip before the player enters its landing zone.

**Completion and connection:** A quiet server alcove provides a checkpoint before A05.

### L04-A05 — Conveyor junction

**Space and placement:** Two short conveyor segments connect fixed islands. Put one Loadbearer on the far island and one Patchbot behind a crate. A Clinger appears only in the final fixed-floor section.

**Player experience and lesson:** Combine crate cover and repair priority while leaving a stable retreat. Never combine the first ceiling drop with a forced belt jump.

**Completion and connection:** A stationary stair leads to A06.

### L04-A06 — Compost door

**Space and placement:** A quiet control room has a large readable service diagram and a manual switch. Behind glass, old automated treatment orders cycle without human approval.

**Player experience and lesson:** A readable maintenance log explains that EDEN's central sleep never halted local routines. Interact with the switch to release the botanical waste door.

**Completion and connection:** Enter level 5 without a timed escape or new boss.

## Signature environment change

EDEN requests rerouting and reverses one demonstrated conveyor after its warning arrows visibly change. The player stands on a fixed island during the first reversal; later reversals always preserve a route back to that island.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Introduce each of the three new enemy roles separately. Later allow one heavy cargo threat plus one repair helper; ceiling ambushes occur after landing. Arc Welder is useful but never the only damage source.

- [Resident](../art-design/zombies/z01-resident.md) — established behavior or returning type.
- [Clipper](../art-design/robots/r01-clipper.md) — established behavior or returning type.
- [Loadbearer](../art-design/robots/r09-loadbearer.md) — first introduction in this level.
- [Patchbot](../art-design/robots/r07-patchbot.md) — first introduction in this level.
- [Clinger](../art-design/zombies/z05-clinger.md) — first introduction in this level.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A02, saving the chosen carried weapon and the swap location.
- In the server alcove after A04.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- A visible crate-stack cache accessible through ordinary jumps in A03.
- A side server recess in A05 contains an old maintenance recording about daily routines continuing without central supervision.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Low conveyor hum, hollow crate impacts, distant cooling fans, and gentle electronic chimes from servers. Patchbot repair pulses should be audible over machinery.

## Environment asset kit and layer separation

**Required kit:** Concrete support arches; conveyor modules and end rollers; service floor plates; crate variants; server cabinets; thick root junctions; clear cooling drum; pipe elbows; workshop bench; freight door.

**Separate objects:** Keep conveyors and crates separate from fixed collision floors. Roots crossing cabinets need distinct organic drawing layers. The cooling drum is background scenery, not an implied swimming space.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No tether use, living robot infection, hospital nurses, or lava foundry aesthetic. Do not require a gun to power environmental switches unless the concept later explicitly adds that mechanic.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original hand-drawn 2D environment concept art for DEAD EDEN. Match the selected Sunnyvale scenes' clean dark outlines, rounded architectural shapes, flat painted color masses, crisp cel shadows and sparse graphic highlights. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Represent ceramic, enamel, plants and machinery with simple graphic marks, not realistic material shading. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes and landings clear. No photorealism, volumetric lighting or franchise assets.

Create one wide 16:9 environment keyframe for level 4, "Roots and Rivets".
Narrative purpose: Beneath immaculate lawns, giant living roots wind through a freight network that has been carrying the same supplies for centuries.
Physical setting: Large rounded concrete ribs support low industrial halls. Chunky yellow freight machines work beside cream server cabinets wrapped in thick brown roots. Small luminous root buds illuminate copper pipes and abandoned order trays. Keep a believable service building underneath the growth; this is a functioning facility, not a generic cave.
Color and lighting: Mustard industrial yellow #D0A84C, cream server shells #DAD5BF, teal shadows #3C6769, bark brown #715943, sparse cyan utility lights #7ACCC5. Warm pools at workstations distinguish refuge from dark recesses.
Landmark: A massive root passes through the center of a transparent server cooling drum and reappears across two adjacent halls.
Composition to show: A side-view freight bay with a fixed hero ledge on the left, a short belt over a lower return floor, a Loadbearer lifting a crate on the right, and a huge glowing root inside a cooling drum behind.
Foreground: A few thick pipe bends and root ends frame the edges. Ceiling roots cannot hide a Clinger whose attack has begun.
Playable plane: Clearly edged service walkways, slow conveyors, crate tops, fixed shelving landings, and an accessible maintenance floor under the first moving belts.
Background: Deep server aisles, distant freight routes, inactive storage robots, and the enormous root cooling drum. Background belts carry scenery rather than surprise projectiles.
Show only this level's appropriate era and threats: Resident, Clipper, Loadbearer, Patchbot, Clinger; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No tether use, living robot infection, hospital nurses, or lava foundry aesthetic. Do not require a gun to power environmental switches unless the concept later explicitly adds that mechanic.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, controlled drawn lighting and crisp cel shadows, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 4, "Roots and Rivets". Keep a single 2D gameplay plane inside layered hand-drawn 2D scenery. Main route: A01 Receiving bay → A02 Repair workshop → A03 Freight stack → A04 Ceiling gallery → A05 Conveyor junction → A06 Compost door.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L04-A01: Receiving bay. Exit the lift onto a safe ledge above one slow conveyor. A lower service floor catches failed jumps. Show a root breaking a decorative panel without changing the route. Connection: Follow a bright workshop lamp into A02.
L04-A02: Repair workshop. A quiet bench contains the Arc Welder. Two inert conductive targets sit close enough to show a short chain, beside clear floor space. Connection: Weapon collection opens a normal service door into A03; no weapon-specific electrical lock is required.
L04-A03: Freight stack. One Loadbearer stacks a crate, lifts another overhead, then throws toward a marked position. The room has permanent waist-high cover and an unobstructed upper firing ledge. Connection: The hero can shoot the repair unit first or interrupt with the welder; clearing the bay opens the route to A04.
L04-A04: Ceiling gallery. A short, brightly edge-lit corridor contains one Clinger on a low ceiling above a wide safe floor. The next alcove contains a second Clinger at a different height. Connection: A quiet server alcove provides a checkpoint before A05.
L04-A05: Conveyor junction. Two short conveyor segments connect fixed islands. Put one Loadbearer on the far island and one Patchbot behind a crate. A Clinger appears only in the final fixed-floor section. Connection: A stationary stair leads to A06.
L04-A06: Compost door. A quiet control room has a large readable service diagram and a manual switch. Behind glass, old automated treatment orders cycle without human approval. Connection: Enter level 5 without a timed escape or new boss.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 4, "Roots and Rivets". Match these materials and colors: Mustard industrial yellow #D0A84C, cream server shells #DAD5BF, teal shadows #3C6769, bark brown #715943, sparse cyan utility lights #7ACCC5. Warm pools at workstations distinguish refuge from dark recesses.
Required asset family: Concrete support arches; conveyor modules and end rollers; service floor plates; crate variants; server cabinets; thick root junctions; clear cooling drum; pipe elbows; workshop bench; freight door.
Separation rules: Keep conveyors and crates separate from fixed collision floors. Roots crossing cabinets need distinct organic drawing layers. The cooling drum is background scenery, not an implied swimming space.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean outlines, flat colors and crisp cel shadows on warm off-white. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 4 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- All three new enemy roles are observed before their mixed encounter.
- Arc Welder pickup and its practice space precede repair pressure.
- Conveyor reversal cannot strand or crush the player.
- Lore clearly separates sleeping central intelligence from continuing local automation.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
