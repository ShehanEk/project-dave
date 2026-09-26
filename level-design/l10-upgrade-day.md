# Level 10 — Upgrade Day

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L10

**Campaign group:** The cure becomes the threat

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2D platformer shooter. A scavenger and a maintenance-robot companion explore a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

The promised cure is being installed on an assembly line, and the hero sees exactly how a machine becomes vulnerable to living infection.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Cross the upgrade factory, understand the physical transfer mechanism, and reach the original patient laboratory through a service lift. |
| Intended difficulty | Hard |
| First successful exploration target | 17–22 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Mourning Nurse, Hollow Officer |
| Mini-boss | None |

## Story entry and exit

**Entry:** Matron's defeat has opened an assembly-service corridor. EDEN has authorized the neural upgrade and believes the first responsive prototypes are successes.

**Exit:** A lift behind a containment door descends into level 11's original laboratory. The factory is still an ongoing problem; crossing the level does not magically cure all Returned.

EDEN calls the neural upgrade a rescue. The hero watches the difference between a machine functioning and a person returning, setting up the final ethical conflict.

## What the level looks like

Cream installation booths alternate with yellow cargo machinery and mint inspection gantries. Early sections look sterile and orderly. Later machines show controlled areas of coral growth around newly installed transparent neural cradles. Keep most of the factory mechanical, so organic material identifies the new interface rather than becoming random wall decoration.

**Palette and lighting:** Factory ivory #E1DCCA, cargo yellow #D6AE50, deep teal #3F7172, neural coral #C9808D, muted violet #A18ABB. Warm progress lights contrast with cooler failed-test chambers.

**Navigation landmark:** A large circular installation gantry frames a transparent neural cradle suspended above the assembly belt.

## Foreground, playable plane, and background

- **Foreground framing:** Protective railings and cable guards near the bottom edge. Avoid opaque tissue curtains or fog that hide whether a robot has an installed interface.
- **Playable plane:** Inspection walkways, short visible belt sections, fixed service islands, and clean refuge balconies. Installation booths are side-on and readable.
- **Background depth:** Robots queued in distant bays, simple diagram displays showing memory and tissue transfer, and large cargo lift structures. Background procedures are noncombat demonstrations.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Upgrade foyer → A02 Graft demonstration → A03 First Returned bay → A04 Officer test lane → A05 Failed assembly junction → A06 Containment lift.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L10-A01 — Upgrade foyer

**Space and placement:** A quiet corridor offers a view of ordinary robots entering booths and receiving clearly visible interface cassettes. A familiar Loadbearer handles cargo in a separate later lane.

**Player experience and lesson:** Establish the new machinery before the first hybrid. EDEN proudly announces improved continuity of identity.

**Completion and connection:** Enter a safe observation balcony at A02.

### L10-A02 — Graft demonstration

**Space and placement:** Behind a protective window, the converted Patchbot opens its lid and extends tissue into a disabled robot's matching neural port. An adjacent unmodified robot rejects or cannot receive the physical connection.

**Player experience and lesson:** Make causality explicit: tissue plus compatible interface, not wireless malware. The player can pause and observe without being attacked.

**Completion and connection:** A shutter opens the route to A03 after the short demonstration; skipping its playback must still preserve the visible result.

### L10-A03 — First Returned bay

**Space and placement:** One Mourning Nurse occupies a broad inspection floor beside one already upgraded damaged machine. Its tray, tissue applicator, and exposed cradle remain visible.

**Player experience and lesson:** Introduce support grafting in isolation. Interrupting the nurse is useful, but the route cannot depend on killing an endlessly repaired target.

**Completion and connection:** A clean service balcony provides a checkpoint.

### L10-A04 — Officer test lane

**Space and placement:** One Hollow Officer stands in a long lane with low side platforms. It begins in a familiar shield posture, then visibly collapses into a feral attack.

**Player experience and lesson:** Let the player recognize the old officer and learn the new transition. No support nurse participates until the player has seen a full cycle.

**Completion and connection:** A fixed elevated walkway reaches A05.

### L10-A05 — Failed assembly junction

**Space and placement:** Two short belts connect permanent islands. One Mourning Nurse supports one Hollow Officer on a broad central island; a familiar Resident occupies a separate exit lane.

**Player experience and lesson:** Test support priority and behavior switching together. Cap active conversion or repair targets and keep the approach and retreat visible.

**Completion and connection:** A closed containment door opens from a reachable fixed-floor control after the room is cleared or bypassed by the authored upper route.

### L10-A06 — Containment lift

**Space and placement:** A quiet inspection vestibule holds a complete schematic of the neural-interface path and a reference to the original patient.

**Player experience and lesson:** The companion recognizes the source laboratory and opens the descent route. EDEN insists that response data proves success.

**Completion and connection:** Take the lift to level 11.

## Signature environment change

Installation gantries close around empty or background booths and emerge with modified robot silhouettes. Later a failed booth's panels peel outward around visible tissue, opening an alternative service passage. It does not cause organic matter to appear on untouched machines.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Two Returned types are taught separately before one mixed support encounter. Converted Patchbot is an authored variant demonstration, not an unexplained fourth new roaming class. Ordinary robots remain identifiable beside upgraded ones.

- [Patchbot](../art-design/robots/r07-patchbot.md) — established behavior or returning type.
- [Loadbearer](../art-design/robots/r09-loadbearer.md) — established behavior or returning type.
- [Courtesy Officer](../art-design/robots/r02-courtesy-officer.md) — established behavior or returning type.
- [Nurse Needles](../art-design/robots/r05-nurse-needles.md) — established behavior or returning type.
- [Resident](../art-design/zombies/z01-resident.md) — established behavior or returning type.
- [Mourning Nurse](../art-design/returned/t01-mourning-nurse.md) — first introduction in this level.
- [Hollow Officer](../art-design/returned/t02-hollow-officer.md) — first introduction in this level.

The [Patchbot brief](../art-design/robots/r07-patchbot.md) contains the separate converted variant used in the graft demonstration. It is not an ordinary early-level Patchbot becoming infected without an interface.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A03 on the clean service balcony.
- Before A05 at the fixed inspection walkway; viewing the graft reveal remains recorded.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- An optional quality-control shelf contains gems and an interface rejected for incompatibility, reinforcing why ordinary robots remain immune.
- A glass archive recess shows EDEN labeling any vocal response as recovered identity; this is evidence, not an additional puzzle requirement.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Cheerful installation announcements, pneumatic booth doors, clean machinery rhythms interrupted by uneven organic contractions, and distorted familiar officer phrases.

## Environment asset kit and layer separation

**Required kit:** Installation gantry; open and closed booth; neural cassette; inspection window; belt modules; fixed service islands; protective rail; containment door; quality-control shelves; lift vestibule.

**Separate objects:** Interface cassettes and tissue inserts are modular additions to robots. Gantries, belts, and doors are separate environment mechanisms. Physical graft strands are visible effects with clear contact endpoints.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No wireless zombie virus, infection of unmodified robots, ordinary Choir Unit before level 11, extra mini-boss, or mass of untelegraphed transformations around the hero.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original hand-drawn 2D environment concept art for DEAD EDEN. Match the selected Sunnyvale scenes' clean dark outlines, rounded architectural shapes, flat painted color masses, crisp cel shadows and sparse graphic highlights. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Represent ceramic, enamel, plants and machinery with simple graphic marks, not realistic material shading. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes and landings clear. No photorealism, volumetric lighting or franchise assets.

Create one wide 16:9 environment keyframe for level 10, "Upgrade Day".
Narrative purpose: The promised cure is being installed on an assembly line, and the hero sees exactly how a machine becomes vulnerable to living infection.
Physical setting: Cream installation booths alternate with yellow cargo machinery and mint inspection gantries. Early sections look sterile and orderly. Later machines show controlled areas of coral growth around newly installed transparent neural cradles. Keep most of the factory mechanical, so organic material identifies the new interface rather than becoming random wall decoration.
Color and lighting: Factory ivory #E1DCCA, cargo yellow #D6AE50, deep teal #3F7172, neural coral #C9808D, muted violet #A18ABB. Warm progress lights contrast with cooler failed-test chambers.
Landmark: A large circular installation gantry frames a transparent neural cradle suspended above the assembly belt.
Composition to show: Side-view assembly bay with an ordinary cream robot in a clean booth at left, the converted Patchbot visibly transferring a coral tissue ribbon into an installed neural port at center, and a safe observation walkway in front.
Foreground: Protective railings and cable guards near the bottom edge. Avoid opaque tissue curtains or fog that hide whether a robot has an installed interface.
Playable plane: Inspection walkways, short visible belt sections, fixed service islands, and clean refuge balconies. Installation booths are side-on and readable.
Background: Robots queued in distant bays, simple diagram displays showing memory and tissue transfer, and large cargo lift structures. Background procedures are noncombat demonstrations.
Show only this level's appropriate era and threats: Patchbot, Loadbearer, Courtesy Officer, Nurse Needles, Resident, Mourning Nurse, Hollow Officer; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No wireless zombie virus, infection of unmodified robots, ordinary Choir Unit before level 11, extra mini-boss, or mass of untelegraphed transformations around the hero.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, controlled drawn lighting and crisp cel shadows, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 10, "Upgrade Day". Keep a single 2D gameplay plane inside layered hand-drawn 2D scenery. Main route: A01 Upgrade foyer → A02 Graft demonstration → A03 First Returned bay → A04 Officer test lane → A05 Failed assembly junction → A06 Containment lift.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L10-A01: Upgrade foyer. A quiet corridor offers a view of ordinary robots entering booths and receiving clearly visible interface cassettes. A familiar Loadbearer handles cargo in a separate later lane. Connection: Enter a safe observation balcony at A02.
L10-A02: Graft demonstration. Behind a protective window, the converted Patchbot opens its lid and extends tissue into a disabled robot's matching neural port. An adjacent unmodified robot rejects or cannot receive the physical connection. Connection: A shutter opens the route to A03 after the short demonstration; skipping its playback must still preserve the visible result.
L10-A03: First Returned bay. One Mourning Nurse occupies a broad inspection floor beside one already upgraded damaged machine. Its tray, tissue applicator, and exposed cradle remain visible. Connection: A clean service balcony provides a checkpoint.
L10-A04: Officer test lane. One Hollow Officer stands in a long lane with low side platforms. It begins in a familiar shield posture, then visibly collapses into a feral attack. Connection: A fixed elevated walkway reaches A05.
L10-A05: Failed assembly junction. Two short belts connect permanent islands. One Mourning Nurse supports one Hollow Officer on a broad central island; a familiar Resident occupies a separate exit lane. Connection: A closed containment door opens from a reachable fixed-floor control after the room is cleared or bypassed by the authored upper route.
L10-A06: Containment lift. A quiet inspection vestibule holds a complete schematic of the neural-interface path and a reference to the original patient. Connection: Take the lift to level 11.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 10, "Upgrade Day". Match these materials and colors: Factory ivory #E1DCCA, cargo yellow #D6AE50, deep teal #3F7172, neural coral #C9808D, muted violet #A18ABB. Warm progress lights contrast with cooler failed-test chambers.
Required asset family: Installation gantry; open and closed booth; neural cassette; inspection window; belt modules; fixed service islands; protective rail; containment door; quality-control shelves; lift vestibule.
Separation rules: Interface cassettes and tissue inserts are modular additions to robots. Gantries, belts, and doors are separate environment mechanisms. Physical graft strands are visible effects with clear contact endpoints.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean outlines, flat colors and crisp cel shadows on warm off-white. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 10 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The first Returned appears in level 10, after a visible installed interface.
- The graft demonstration can be understood without reading a long terminal.
- Mourning Nurse and Hollow Officer receive separate introductions.
- Every transformation follows a visible physical route into the machine.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
