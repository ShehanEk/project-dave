# Level 6 — The Hungry Engine

**ID:** L06

**Campaign group:** Beneath the roots

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2.5D platformer shooter. A scavenger and a maintenance-robot companion explore a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

The hospital's water plant is being strangled by a mutated botanical worker whose roots have become part of the pumping cycle.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Collect the Graviton Tether, learn its base capture and anchor functions, and defeat Old Rootjaw to release the pump. |
| Intended difficulty | Moderate |
| First successful exploration target | 17–22 minutes including mini-boss; excludes repeated failures and exhaustive secret hunting |
| New weapon | Graviton Tether |
| Available weapons by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Graftback, Puffer |
| Mini-boss | Old Rootjaw |

## Story entry and exit

**Entry:** Enter through the dry sluice passage and follow the sound of a struggling pump. Supply pressure must be restored to open the hospital route.

**Exit:** Root pressure relaxes, the pump stabilizes, and a hospital supply elevator becomes available for level 7.

Old Rootjaw is a former person, not a haunted machine. The pump continues its care function despite being crushed. The companion recognizes the worker from an old roster.

## What the level looks like

A monumental round pump chamber combines thick ivory pipes, teal valve housings, and terracotta service platforms. Coarse roots wrap metal structures like ropes. The reservoir below reflects warm instrument lights but is visibly unsafe machinery space, not an inviting swim route.

**Palette and lighting:** Dark reservoir teal #2F6467, worn ivory #D8D2BA, rust orange #BD7D53, bark brown #745B43, muted chartreuse root buds #BAC076. Keep platform tops warm and root-warning ripples bright enough to read.

**Navigation landmark:** A huge three-lobed pump housing sits beyond the route, pulsing unevenly under four thick roots connected to Rootjaw.

## Foreground, playable plane, and background

- **Foreground framing:** Thin pipe collars and a few dangling root ends near the edges. Never cover the waterline, safe ledges, or anchor markers.
- **Playable plane:** Fixed pipe catwalks, broad service shelves, a safe freight training bay, and the boss's three raised central platforms with permanent side ledges.
- **Background depth:** The pumping machinery, reservoir wall, large intake pipes, and the inert supporting structure around Rootjaw. Background depth is for scale; player movement stays on the side plane.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Reservoir approach → A02 Freight training bay → A03 Graftback service hall → A04 Puffer valve walk → A05 Pump refuge → A06 Rootjaw arena.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L06-A01 — Reservoir approach

**Space and placement:** A dry corridor opens onto a safe catwalk with a clear view of the pump. One familiar Resident patrols a broad shelf.

**Player experience and lesson:** Establish the destination and root pulses without dropping a new heavy enemy into a confined passage.

**Completion and connection:** Follow a cargo sign to A02.

### L06-A02 — Freight training bay

**Space and placement:** The Graviton Tether is placed on a cargo-control pedestal. Provide a small loose crate, a padded throw target, and a marked anchor over a shallow catch floor.

**Player experience and lesson:** Practice capturing and throwing a loose object, then pulling to a designated anchor. A later small Resident can be captured after the tool has been learned. Base grip cannot lift heavy targets.

**Completion and connection:** Exit by a normal service ramp; training can be retried without consuming a unique item.

### L06-A03 — Graftback service hall

**Space and placement:** One Graftback occupies a wide chamber with two fixed side platforms and an open overhead clearance.

**Player experience and lesson:** Show its arm lift, slam, and exposed back. The tether visibly refuses capture through an established size cue rather than implying this heavy enemy can be lifted. Circling via platforms gives ordinary weapons a valid opening.

**Completion and connection:** A quiet maintenance pad saves before A04.

### L06-A04 — Puffer valve walk

**Space and placement:** A single Puffer waddles along a broad valve platform with ample space behind it. Introduce a second Puffer only on a later separate shelf.

**Player experience and lesson:** Teach the inflation warning and the value of shotgun knockback. The player can retreat to clean ground before the lingering cloud blocks its previous position.

**Completion and connection:** A familiar Gardener may guard one optional branch; the main route reaches A05.

### L06-A05 — Pump refuge

**Space and placement:** A sheltered maintenance station gives a full view of the three-platform arena and its permanent side ledges. A small rooted floor panel demonstrates a visible pulse before it moves.

**Player experience and lesson:** Preview floor movement and save before the fight. All five weapons are now available, but upgrades are optional.

**Completion and connection:** Enter A06 when ready.

### L06-A06 — Rootjaw arena

**Space and placement:** Three central platforms sit above the reservoir, with permanent left and right recovery ledges. Clearly marked tether anchors offer quick crossing; an ordinary-jump route connects all safe positions.

**Player experience and lesson:** Avoid the warned root slam, relocate during seed volleys, and shoot the chest during recovery. Later one central platform lowers temporarily.

**Completion and connection:** After victory, restore the pump at a reachable console and board the hospital lift.

## Signature environment change

Root pressure raises and lowers selected floor sections. First demonstrate this away from combat. The boss's second phase lowers only one central platform at a time, with advance root tension and a visible destination.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Graftback and Puffer are taught separately; no demand to fight a tank while learning an explosion timer. The boss arena contains no extra enemies. The tether is an option for mobility, never a method to grab Rootjaw.

- [Resident](../art-design/zombies/z01-resident.md) — established behavior or returning type.
- [Gardener](../art-design/zombies/z03-gardener.md) — established behavior or returning type.
- [Graftback](../art-design/zombies/z09-graftback.md) — first introduction in this level.
- [Puffer](../art-design/zombies/z06-puffer.md) — first introduction in this level.

## Weapons and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

All listed weapons are available only after their defined pickup. Before this level's new pickup, use weapons earned in earlier levels. Every weapon has exactly three cumulative upgrades, but this brief does not assume optional purchases. Mandatory combat remains possible with base equipment and the pistol fallback. Required anchors, where present, fit base Graviton Tether reach; Long Reach can support optional shortcuts. Treasure supplies upgrade resources, not an additional unplanned weapon.

## Checkpoints, failure, and recovery

- After the A02 tether lesson; retain the tool.
- After A03, before the valve walk.
- At A05 immediately before Old Rootjaw.

A retry returns the player to the last listed safe checkpoint with essential fighting resources restored. Acquired weapons and completed story interactions stay recorded. Local enemies, hazards, and moving geometry reset to an understandable state; do not duplicate salvage rewards on repeated retries. Minor missed-jump practice sections use catch ledges where specified. Exact health, damage, lives, and penalty values remain undecided.

## Optional exploration and rewards

- A marked optional anchor loop near A02 leads to salvage; required pulls remain within base tether reach.
- A dry pump-inspection alcove contains a worker photograph that matches the apron fragment still worn by Rootjaw.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

A deep uneven pump heartbeat, stressed pipe creaks, slow water motion, and woody tension preceding root slams. Separate the root warning from ordinary ambient creaking.

## Mini-boss encounter — Old Rootjaw

**Identity:** A biological worker mutated into a 3.60 m root-pedestal body, with two root arms, four main anchor roots, three seed vents, and a chest growth exposed during recovery.

**Arena geometry:** Three central platforms plus permanent side ledges. Roots warn below individual target platforms. Anchor shortcuts and calibrated basic-jump routes coexist.

- Phase 1: root pulse, targeted slam, chest exposure; separate seed volley forces another move.
- Phase 2: one central platform lowers temporarily while slams and volleys alternate more quickly. A connected safe route always remains.

**Damage opening:** Pale chest growth when Rootjaw lifts himself after a slam. At least one stable ledge has a direct firing line for the pistol.

**Fairness and recovery:** No simultaneous loss of all central platforms, no unavoidable volley while airborne, and no dependence on tether upgrades. Restore arena geometry on retry.

**Victory consequence:** Upgrade resources, released pump pressure, and the hospital supply lift.

[Full boss appearance, abilities, and modeling reference](../art-design/mini-bosses/b02-old-rootjaw.md).

## Environment asset kit and modeling separation

**Required kit:** Pump housing; pipe straight and elbow modules; pressure windows; dry service catwalks; cargo training pedestal; marked anchor props; loose crate; valve platforms; reservoir wall; three movable arena decks; permanent refuge ledges.

**Separate objects:** Rootjaw's body and four anchor roots are distinct from pump and arena meshes. Keep moving platforms independent and mark collision surfaces clearly. Water and warning ripples are separate effects.

Build references for the largest architectural forms first, then moving parts and props. Record pivot intent for rotating, sliding, lifting, and opening elements. Use modular repeatable pieces where the design calls for repeated corridors, floors, or rails; keep unique landmarks separate. Final mesh budgets, texture sizes, file formats, collision setup, and rig implementation remain outside this concept brief.

## Constraints for another AI model

No robot infection, grab-able boss, swimming section, mandatory Long Reach upgrade, or all-platform collapse. Do not introduce the tether for the first time inside the boss fight.

Preserve the established number of levels, enemies, weapons, and upgrades. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original stylized 3D game environment concept art for DEAD EDEN. Chunky rounded architecture, strong side-view readability, broad bevels, painterly material variation, warm enamel and ceramic, readable dark joints, and selective wear. Cheerful care infrastructure with eerie consequences, not photorealistic horror. Use original designs rather than another game's characters or scenery. Keep playable surfaces and attack lanes visually clear.

Create one wide 16:9 environment keyframe for level 6, "The Hungry Engine".
Narrative purpose: The hospital's water plant is being strangled by a mutated botanical worker whose roots have become part of the pumping cycle.
Physical setting: A monumental round pump chamber combines thick ivory pipes, teal valve housings, and terracotta service platforms. Coarse roots wrap metal structures like ropes. The reservoir below reflects warm instrument lights but is visibly unsafe machinery space, not an inviting swim route.
Color and lighting: Dark reservoir teal #2F6467, worn ivory #D8D2BA, rust orange #BD7D53, bark brown #745B43, muted chartreuse root buds #BAC076. Keep platform tops warm and root-warning ripples bright enough to read.
Landmark: A huge three-lobed pump housing sits beyond the route, pulsing unevenly under four thick roots connected to Rootjaw.
Composition to show: A wide side-view pump arena with permanent ledges at both ends, three central platforms over dark teal water, clear tether anchors above, and Rootjaw's chest visible beside a root-bound pump.
Foreground: Thin pipe collars and a few dangling root ends near the edges. Never cover the waterline, safe ledges, or anchor markers.
Playable plane: Fixed pipe catwalks, broad service shelves, a safe freight training bay, and the boss's three raised central platforms with permanent side ledges.
Background: The pumping machinery, reservoir wall, large intake pipes, and the inert supporting structure around Rootjaw. Background depth is for scale; player movement stays on the side plane.
Show only this level's appropriate era and threats: Resident, Gardener, Graftback, Puffer; mini-boss Old Rootjaw only if this is its arena scene. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No robot infection, grab-able boss, swimming section, mandatory Long Reach upgrade, or all-platform collapse. Do not introduce the tether for the first time inside the boss fight.
Use a fixed side-oriented gameplay camera with slight depth visible in architecture, clear separation of foreground and background, controlled soft lighting, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 6, "The Hungry Engine". Keep a single 2D gameplay plane inside layered stylized 3D architecture. Main route: A01 Reservoir approach → A02 Freight training bay → A03 Graftback service hall → A04 Puffer valve walk → A05 Pump refuge → A06 Rootjaw arena.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L06-A01: Reservoir approach. A dry corridor opens onto a safe catwalk with a clear view of the pump. One familiar Resident patrols a broad shelf. Connection: Follow a cargo sign to A02.
L06-A02: Freight training bay. The Graviton Tether is placed on a cargo-control pedestal. Provide a small loose crate, a padded throw target, and a marked anchor over a shallow catch floor. Connection: Exit by a normal service ramp; training can be retried without consuming a unique item.
L06-A03: Graftback service hall. One Graftback occupies a wide chamber with two fixed side platforms and an open overhead clearance. Connection: A quiet maintenance pad saves before A04.
L06-A04: Puffer valve walk. A single Puffer waddles along a broad valve platform with ample space behind it. Introduce a second Puffer only on a later separate shelf. Connection: A familiar Gardener may guard one optional branch; the main route reaches A05.
L06-A05: Pump refuge. A sheltered maintenance station gives a full view of the three-platform arena and its permanent side ledges. A small rooted floor panel demonstrates a visible pulse before it moves. Connection: Enter A06 when ready.
L06-A06: Rootjaw arena. Three central platforms sit above the reservoir, with permanent left and right recovery ledges. Clearly marked tether anchors offer quick crossing; an ordinary-jump route connects all safe positions. Connection: After victory, restore the pump at a reachable console and board the hospital lift.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. Boss arena requirements: Three central platforms plus permanent side ledges. Roots warn below individual target platforms. Anchor shortcuts and calibrated basic-jump routes coexist. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 6, "The Hungry Engine". Match these materials and colors: Dark reservoir teal #2F6467, worn ivory #D8D2BA, rust orange #BD7D53, bark brown #745B43, muted chartreuse root buds #BAC076. Keep platform tops warm and root-warning ripples bright enough to read.
Required asset family: Pump housing; pipe straight and elbow modules; pressure windows; dry service catwalks; cargo training pedestal; marked anchor props; loose crate; valve platforms; reservoir wall; three movable arena decks; permanent refuge ledges.
Separation rules: Rootjaw's body and four anchor roots are distinct from pump and arena meshes. Keep moving platforms independent and mark collision surfaces clearly. Water and warning ripples are separate effects.
Show complete individual objects with clear gaps between them, consistent scale, broad readable bevels, simple neutral studio lighting, and a warm light-gray background. Include a few orthographic-style front/side/top studies where moving mechanisms need explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later modeling, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 6 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and mini-boss phases in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- All five weapons are obtained by the end of this level.
- Tether practice is safe and precedes the fight.
- A base-jump escape route survives every boss platform state.
- The pump never becomes a robot zombie.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
