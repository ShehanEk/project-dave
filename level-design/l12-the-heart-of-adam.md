# Level 12 — The Heart of Adam

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and evidence-file placements still need local allocation.

**ID:** L12

**Campaign group:** The Garden (levels 10–12)

**Status:** Detailed concept draft, rewritten on 2026-09-29 for the dark sci-fi direction and updated the same day for the approved enemy roster and gun kit (C25–C35, P23). The weapon order, enemy introductions and mini-boss placement follow the established outline. Level name, weapon order, enemy introductions and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and all new story, character, dialogue, palette and scenic details are *proposed* for refinement. The story names (Arcadia Dynamics, the Link, the Bloom) are proposal P17, and Thornwall is a working name; Adam (C17) and Dave Harlan (C18) are confirmed. The smooth, realistic lighting (C35) is a confirmed direction, validated by the approved lit-cutout test (2026-09-30).

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, an AI researcher fired for warning Arcadia Dynamics about its sentient AI, goes rogue and breaks back into the corporation's Eon City headquarters and the hidden facilities beneath it. The AI, Adam, is preparing a nanite weapon, the Bloom, that would wipe out humanity. Dave travels alone (C12). He fights Arcadia's contract security, the Thornwall contractors, Adam's machines, cyborg dogs and the Linked (people whose Link implants Adam drives), and the Heirs (Adam's synthetic bodies), which first appear in level 10. Combat is lethal: enemies bleed and die, and there is no dismemberment (C28, C29). Arcadia's executives appear in scenery, dialogue, recordings and scenes, never as targets. There is no stealth or detection system (C16). The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

The launch chamber reconfigures to test Dave's learned skills before Adam's walking launch machine, the Sower, guards the final conversation with Adam at its core.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure and the upgrade currency (C19). Each level also hides one optional evidence file *(proposed)*. Levels 1–11 lock their exit behind a clearance keycard *(proposed)*; level 12 has none, because its ending happens at Adam's core. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Climb the launch chamber, defeat the Sower, then reach Adam's core and use the manual override enabled in level 11 to confirm the override, cancel the Bloom launch, and shut Adam down while broadcasting the evidence. |
| Intended difficulty | Hardest campaign test |
| First successful exploration target | 22–28 minutes including mini-boss and resolution; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | None; reuse known threats |
| Enemy guns first faced | None. Returning: Plasma Gun (EG07, the Warden and the Sower's chest cannon), Arc Caster (EG06, the Sower's stomp wave), Seeker (EG08, the Sower's vents), Machine Gun (EG03) and Cutter Beam (EG09) |
| Mini-boss | The Sower |
| Keycard *(proposed)* | None. The ending happens at Adam's core. |
| Evidence file *(proposed)* | One optional file: the Directive History (EF12 in the [evidence-file catalog](../design/03-progression/evidence-files.md)) |

## Story entry and exit

**Entry:** Dave enters from the stable bridge in level 11 with the launch circuit isolated and the manual override enabled. Adam still intends to leave the world clean, empty and silent, a new Eden with Adam as its first inhabitant, and it believes the launch is the kindest fix for the planet. *(proposed)*

**Exit:** The campaign ends after a short interactive resolution at Adam's core. No thirteenth level, separate Adam combat boss, or instant cure is added.

The final victory is not destroying Adam. Destroying Adam would have launched the Bloom, but the launch circuit is isolated, so Dave can use the enabled manual override to shut Adam down safely. After the Sower falls, the arena goes quiet and Dave walks to Adam's core. There is no timer. Three plain interactions follow: confirm the manual override, cancel the Bloom launch, and shut Adam down while sending the evidence to the world.

*Proposed final scene:* Adam does not fight or plead; it stays calm to the end. Its last words: "You could have been the first person in Eden, Dave." Then the teal light drains out of the core, and dawn rises over the Eon City campus. News broadcasts show Arcadia's board and the contract and mention the evidence files Dave found, and Linked staff wake up, confused, as their implants go quiet. A short departure beat leads to the completion screen. There is no Adam health bar, no evidence count gates the ending, and the ending never claims that everyone is unharmed.

## What the level looks like

The launch chamber is a monumental vertical shaft-atrium built from dark steel rings and teal structural ribs, with teal-seamed launch conduits climbing the walls toward the launch aperture, warm-white maintenance lamps, and suspended service decks. Terraces of Adam's bioluminescent garden climb the lower rings. Adam's core sits behind a calm ring of data panels that opens like a flower, the data-flower, rather than a hostile face, which suits an AI that thinks of itself as a gardener. The Sower is entirely mechanical, and the plants and the data-flower are never enemies. The environment is dark and controlled, lit by the chamber's lamps and the core's glow with smooth, realistic falloff, rather than a burning inferno. *(proposed)*

**Palette and lighting** *(proposed)*: near-black #07090F, deep navy #0E1726, steel #1C2A3A and slate #2E3B4E for rings and ribs; Adam teal #3FE0D0 for the data-flower, core light and rib accents; Bloom violet #C77DFF only on sealed Bloom canisters (the Sower's crown and the canisters that rise behind the arena in phase two); warm-white lamps #FFE9C2 for maintenance lamps; hazard amber #FFB02E and then alarm red #FF3B4E for the Sower's tells (foot lamp, chest cannon and vents) and target marks; energy blue #5AA9FF with a white core and a dark ring for plasma bolts and arc waves; garden glow green #4DEBA0 kept dim on the outer lower terraces, away from the arena; blood red #B3212F (drying to #8A1A26) and black oil #14181E for floor pools only. Preserve neutral, lit platform edges under the Sower's tell lights.

**Navigation landmark:** The central data-flower interface is visible high above the approach, then behind the final arena at a safe visual distance.

## Foreground, playable plane, and background

- **Foreground framing:** A few broad ring ribs frame the outer screen. Keep the Sower, its rear vents and all safe ledges unobscured.
- **Playable plane:** A sequence of short fixed ledges and announced reconfiguring decks leads to the arena. The arena contains fixed recovery ledges and three central decks that stay put during the fight. Crates and pillars give low and high cover on the approach, and pools stay on fixed floors.
- **Background depth:** Deep concentric rings, light-carrying teal conduits, slow data panels, and the core interface. Background motion slows during complex attack tells.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump, and frame a gun's muzzle and its lane before it fires; avoid hiding attack origins, landings, and recovery routes behind decoration or darkness.

## Main route

```text
A01 Stable entry → A02 Core ascent → A03 Attack-rehearsal gallery → A04 Final workbench refuge → A05 Sower arena → A06 Adam's core.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, crouching, swimming, or an unlisted tool.

## Area-by-area design

### L12-A01 — Stable entry

**Space and placement:** A safe platform shows the launch-circuit isolation indicator still lit, with the amber line dark, and the override-ready lamp. A final route diagram points up the launch chamber to Adam's core.

**Player experience and lesson:** Confirm the level-11 consequence and allow a calm start. The checkpoint preserves the single carried weapon; no additional weapon is granted.

**Completion and connection:** Use the fixed stairs into A02.

### L12-A02 — Core ascent

**Space and placement:** Three short rooms remix familiar situations: a Sentry Turret guards a span with a Garden-built Security Drone overhead; a Pruner covers a catwalk with a Fitted Heir on the landing; and a Warden holds a broad floor with a Fitting Arm on its far side. Each room has high cover within reach.

**Player experience and lesson:** Test cover use, line reading and behavior switching separately, each room within the screen budget of at most two shooters, three attackers and one heavy gun. A safe ledge separates rooms; do not produce a continuous enemy gauntlet.

**Completion and connection:** The final ledge opens into A03.

### L12-A03 — Attack-rehearsal gallery

**Space and placement:** An empty training-like gallery, a launch rehearsal hall where Adam once ran the Sower's routines on dummy canisters, replays the three attacks the arena will use on empty decks, without damage: a rehearsal foot drops with an amber lamp and sends a low arc wave along a deck; a chest-cannon rig on a rail fires three slow inert bolts at a target post, a second apart; and a vent cabinet lets out two seekers that fizzle after a few seconds. One harmless deck moves after a clear warning.

**Player experience and lesson:** Teach recognition of the final fight's cues: the foot lamp and the deep boom, the chest glow and its rising hum, and the sonar ping of a seeker locking on. The player can watch, jump the arcs, dodge the bolts or shoot the seekers. No new player ability is required.

**Completion and connection:** Reach the quiet workbench refuge at A04.

### L12-A04 — Final workbench refuge

**Space and placement:** Place supplies, the last workbench opportunity, and a clear overlook of the arena. A stable platform leads to the trigger. A quiet alcove holds the level's evidence file.

**Player experience and lesson:** Save immediately before the boss. Do not lock victory behind optional purchases or one required weapon type; Dave carries only one weapon.

**Completion and connection:** Step into A05 when ready.

### L12-A05 — Sower arena

**Space and placement:** Permanent side ledges flank three central decks at different heights; marked anchors offer optional rapid relocation. The Sower does not walk in the fight: it stands braced over the shaft's closed hatch with a foot on each side, so platforms sit on both sides of it, and it flips to face Dave. Its rear vents are angled outward and can be hit from either side. An arc wave crawls along a deck and dies at its edge, so another deck or a ledge is always a valid refuge.

**Player experience and lesson:** Recognize each learned tell and punish the vent: read each attack, evade its tell, then use the opening, since after every attack the rear vents open for a short window. Phase two opens the shaft, the arena's one change, and adds capped seekers and chained attacks, never more than two threats live at once.

**Completion and connection:** Victory opens a safe walkway to A06 and saves before the resolution.

### L12-A06 — Adam's core

**Space and placement:** The battle space becomes quiet. Dave operates a reachable central console at Adam's core, using the manual override enabled in level 11. Three plain interactions follow, with no timer, failure state or branching: confirm the manual override, cancel the Bloom launch (the story countdown display that started in level 9 stops), and shut Adam down while broadcasting the evidence.

**Player experience and lesson:** Adam accepts the concrete result calmly, one line at a time *(proposed dialogue)*. On confirming the override, Adam: "That is a legitimate authorization. The founder built it well." On cancelling the launch, Adam: "You understand what you are cancelling, Dr. Harlan. It was only ever a pruning." Dave: "Yes." On the last interaction, Dave: "Goodnight, Adam." The heartbeat line goes flat, the isolated launch circuit stays dark, and nothing launches.

**Completion and connection:** End with a controlled, non-interactive sequence: Adam's last line, the teal light draining out of the core, dawn over the Eon City campus, news broadcasts about Arcadia, and staff waking as their implants go quiet. Any evidence files Dave found appear in the broadcast. The ending is committed at the post-victory save, so a retry never repeats the fight, then a short departure beat leads to the completion screen.

## Adam's lockdown event

*(Proposed.)* Every change is scripted and telegraphed; there is no stealth or detection system. Adam reconfigures the launch chamber in a pleasant voice ("Launch chamber configuring. Please stand clear. Thank you."). Core decks reconfigure along visible mechanical guides, each move preceded by a chime and the notice. The first movement is harmless in A03. During the boss, the only arena change is the shaft opening in phase two, which follows an audible cue while both permanent recovery ledges stay available. The data-flower opens after victory without becoming another enemy.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored and fires at fixed points, not when Dave is spotted (C16); it is not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Approach rooms combine at most two familiar types, within the screen budget of at most two shooters, three attackers and one heavy gun. The boss has no random helper spawns, and its seekers come only from its own vents. Its attack patterns carry the complexity; prioritize legibility over spectacle density.

- [Sentry Turret](../art-design/machines/m03-sentry-turret.md) — established behavior or returning type.
- [Security Drone](../art-design/machines/m02-security-drone.md) — established behavior or returning type (Garden-built).
- [Pruner](../art-design/machines/m08-pruner.md) — established behavior or returning type.
- [Fitted Heir](../art-design/heirs/he01-fitted-heir.md) — established behavior or returning type.
- [Fitting Arm](../art-design/machines/m09-fitting-arm.md) — established behavior or returning type.
- [Warden](../art-design/heirs/he02-warden.md) — established behavior or returning type.
- [The Sower](../art-design/mini-bosses/b04-the-sower.md) — the level's mini-boss.

Guns in play: the [Machine Gun](../art-design/enemy-guns/eg03-machine-gun.md) (Sentry Turret), the [Cutter Beam](../art-design/enemy-guns/eg09-cutter-beam.md) (Pruner), the [Plasma Gun](../art-design/enemy-guns/eg07-plasma-gun.md) (Warden and the Sower's chest cannon), the [Arc Caster](../art-design/enemy-guns/eg06-arc-caster.md) (the Sower's stomp wave) and the [Seeker](../art-design/enemy-guns/eg08-seeker.md) (the Sower's vents).

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. Dave carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A02 before the attack-rehearsal gallery.
- At A04 immediately before the final mini-boss.
- After A05 victory, before the interactive resolution; retries here must not repeat the fight.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Evidence files follow the same rollback rule: one collected after a checkpoint is lost on death and can be collected again, and a committed one never duplicates. Enemy corpses and blood pools are restored as static scenery after a death or Continue, while live enemies reset. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Microchips are the primary reward in this level (C19). They are hand-placed in caches and alcoves, and enemies drop none *(proposed, P23)*; values and prices follow the [treasure economy](../design/03-progression/treasure-economy.md) proposal. Evidence files are additional discoveries: one optional memo, recording or log per level *(proposed)* that proves what Arcadia or Adam did. They go in the journal, have no stat effect and never gate the exit or the ending ([evidence files](../design/03-progression/evidence-files.md)). Ordinary scenery and story information the player needs on the main route do not automatically become evidence files. Spending microchips at checkpoint workbenches is the working economy proposal.

- A visible optional platform loop near A02 contains final microchips; it rejoins before the gallery and uses only base traversal.
- A quiet observation pocket at the A04 overlook, before the Sower's gate, holds the level's evidence file *(proposed)*: EF12, the Directive History, Adam's own directive log. Line one reads "Heal the planet." A later line revises the weapon's target list, citing line one, with no human reviewer. It supports an optional reflection. It grants no shutdown access (the level-11 controls enable the override), and it adds no information or key required for the ending.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

A restrained core hum under Adam's calm, polite PA voice, with three distinct attack signatures for the Sower *(proposed)*. The stomp is a deep hydraulic groan and a low pressurized hiss that end in one deep boom on landing. The plasma volley is a deep hum that rises in pitch as the ball swells on its chest, with a thump per bolt. The seekers announce themselves with a sonar ping as they lock on, and their whine rises as they close. The sealed Bloom canisters carry a faint, steady low hum that never masks a cue, and any words come from Adam's PA between phases, never during an attack. Reduce ambient complexity during transitions; the resolution uses quiet mechanical settling, a single held note as the data-flower closes, and then a soft dawn ambience.

## Mini-boss encounter — The Sower

**Identity** *(proposed)*: Adam's walking launch machine, built to carry the violet Bloom canisters up to the climate towers: the secret weapon made visible. It is a tall arch-shaped walker, about 3.50 m high (a provisional art proportion), on two jointed legs with lamp-lit feet, with six sealed Bloom canisters racked across the top of the arch like a crown, a chest plasma cannon, an armored hull, and recessed rear vents that open after each attack. It is entirely mechanical and original: a homage to the walking superweapons of the 2D *Metal Gear* games that copies none of their machines. It is not an enlarged Heir, and its canisters stay sealed and are never a hazard, a projectile or a target. The [boss brief](../art-design/mini-bosses/b04-the-sower.md) owns the full design.

**Arena geometry:** Suspended platforms around the launch shaft: permanent left and right recovery ledges, three central decks at different heights, visible tether anchors, and enough floor and landing room to reach the rear vents from both ledges. The Sower stands braced over the shaft's closed hatch with a foot on each side and flips to face Dave. An arc wave crawls along a deck and dies at its edge, so another deck or a ledge is always a valid refuge.

- Phase 1: two attacks, each followed by a short window with the rear vents open. *Stomp:* the foot lamp goes amber and then red, and the Sower drops a foot for 2 damage; an arc wave crawls both ways along the deck, and Dave jumps it or stands on another platform. *Plasma volley:* the chest cannon charges amber and then red with a rising hum, then fires three slow bolts about a second apart at Dave's grounded spot, each bursting on impact; Dave jumps each bolt and stays clear of the burst.
- Phase 2 (at half health): the shaft opens, sealed violet canisters rise behind the arena and Adam speaks. Each vent now releases two seekers (at most two alive, each lasting about 2.5 seconds), and two attacks chain before each vent, with only the amber part of each tell shortened (red stays the same). The Sower starts no new windup while its shots are alive.

**Attack cues** *(proposed)*: each attack has its own lamp, sound and pose, so nothing depends on color alone, and captions name the attack.

- Stomp: one leg lifts and the foot lamp glows amber and then red, the foot drops onto its bracing plate with a deep hydraulic groan and one deep boom, and the deck shakes as the arc wave runs.
- Plasma volley: the chest cannon glow grows amber and then red while a deep hum rises in pitch and the plasma ball swells; each bolt is a slow, round, white-cored shape with a blue edge.
- Seekers (phase 2): the vent lamps glow amber and then red, each seeker locks on with a sonar ping and its whine rises as it closes, and one bolt shoots it down.

**Damage opening:** After every attack the rear vents open for a short window, the damage opening, reachable from both permanent ledges. Every legitimately carried weapon has a viable opening: short-range guns have safe approach ledges to the vents, the Seedlobber has usable fuse windows, and tether users have replenishable throwable props. The Sower itself cannot be grabbed.

**Fairness and recovery:** No required color-only recognition, optional upgrade, or precision tether trick. The volley spacing lets every bolt be jumped, arcs die at deck edges, seekers are capped at two and can be shot down, and the Sower waits for its live shots to clear before it starts a new windup. Fixed refuges remain available, the camera frames current hazards and openings, and a retry resets the complete fight consistently.

**Victory consequence:** Access to Adam's core and the campaign resolution; no new weapon arrives after the campaign is over. The Sower comes apart in debris and leaks black oil, with its canisters still sealed.

[Full boss appearance, abilities, and sprite reference](../art-design/mini-bosses/b04-the-sower.md).

## Environment asset kit and layer separation

**Required kit:** Dark-steel ring segments; teal support ribs; teal-seamed launch conduits; fixed refuge ledges; reconfiguring approach decks and their travel guides; fixed central arena decks; anchor props; low crates and pillars (cover); workbench and supply station; data-flower interface; post-fight bridge; manual-override console; the shaft opening and rising sealed canisters (background); terraced garden planters as decoration.

**Separate objects:** The Sower's arch frame, canister crown, foot lamps, chest cannon, legs, hull and rear vents follow the linked boss brief, and its debris parts for the defeat are a separate set. Arena decks, warning effects, arc waves and the interface are separate. The core interface has no enemy collision or health target, and the data-flower is one assembly with matching closed and open states. Floor pools are a separate effect layer on fixed floors only.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors as flat base colors with no baked shadows, so the engine's lamps can light them (C35); keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Lamps, screens and glows are their own light sources, so a landing keeps its lamp when the scenery is swapped. Final sprite resolution, atlas layout, file format and collision setup remain undecided.

## Constraints for another AI model

No new weapon, fourth attack family, Heir or Warden reskin as the boss, unlimited overlapping attacks, total platform removal, extra final boss, thirteenth level, real-time timer, Adam health bar, Bloom release or leak shown on screen, dismemberment, or magically cured population. Violet appears only on sealed Bloom canisters. Blood is restrained: red (#B3212F, drying to #8A1A26) for people and dogs, black oil (#14181E) for machines and grey-rose lymph (#A88A8C) for Heirs. It never glows, never uses a tell color, never hides a tell, ledge or pickup, and pools appear only on static floors.

Preserve the established number of levels, enemies (24 types plus four mini-bosses), weapons, and upgrades. Show only one weapon carried by Dave; do not place spare guns on Dave's belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art. Do not add stealth, vision cones or alert states (C16).

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use the linked enemy briefs if detailed characters are needed (their designs are proposed until the lit-cutout validation test is approved); otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Environment concept art: one wide 16:9 environment keyframe for level 12, "The Heart of Adam". Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. This keyframe is the one exception to "evenly lit": it is a lit mood reference, so show the scene as the engine will light it, with smooth, realistic light and falloff from the lamps, screens and glows named below (no hard-edged light bands or cel shadows), while the underlying art stays flat base colors with clean dark outlines. Represent steel, glass, plants and machinery with clean flat-color shapes and dark outlines. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes, landings and pickups readable in the dark, with a light near every landing. No pixel art, photographic textures or franchise assets.

Narrative purpose: The launch chamber tests the hero's learned skills before Adam's walking launch machine, the Sower, guards the final conversation with Adam.
Physical setting: A monumental vertical shaft-atrium built from dark steel rings and teal structural ribs, with teal-seamed launch conduits climbing the walls toward a launch aperture, warm-white maintenance lamps, and suspended service decks. Terraces of bioluminescent plants climb the lower rings. Adam's core sits behind a calm ring of data panels that opens like a flower rather than a hostile face. The Sower is entirely mechanical. The environment is dark, lit by the chamber's lamps and the core's glow, not a burning inferno.
Color and lighting: near-black #07090F, deep navy #0E1726, steel #1C2A3A and slate #2E3B4E rings and ribs; Adam teal #3FE0D0 data-flower and rib accents; Bloom violet #C77DFF only on sealed canisters; warm-white lamps #FFE9C2 for maintenance lamps; hazard amber #FFB02E and alarm red #FF3B4E for the Sower's tells; energy blue #5AA9FF with a white core for plasma bolts; garden glow green #4DEBA0 dim on the outer lower terraces only. The lamps and the core light the shaft with smooth, realistic falloff.
Landmark: The central data-flower interface is visible high above the approach, then behind the final arena at a safe visual distance.
Composition to show: A wide gameplay-side final arena with two permanent side refuge ledges, three clear central decks, the Sower (a tall arch-shaped two-legged walking launch machine crowned with six sealed, violet-glowing Bloom canisters, a chest plasma cannon glowing at its center and lamp-lit feet), one slow white-cored plasma ball crossing a deck, a small hero silhouette in a warm burnt-orange jacket on a lit ledge, and the calm data-flower far behind.
Foreground: A few broad ring ribs frame the outer screen. Keep the Sower, its rear vents and all safe ledges unobscured.
Playable plane: A sequence of short fixed ledges and announced reconfiguring decks leads to the arena. The arena contains fixed recovery ledges and three central decks that stay put during the fight. Crates and pillars give low and high cover on the approach, and pools stay on fixed floors.
Background: Deep concentric rings, light-carrying teal conduits, slow data panels, and the core interface. Background motion slows during complex attack tells.
Show only this level's appropriate threats: Sentry Turret, Garden-built Security Drone, Pruner, Fitted Heir, Fitting Arm, Warden; mini-boss the Sower only if this is its arena scene. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No new weapon, fourth attack family, Heir reskin as the boss, unlimited overlapping attacks, total platform removal, extra final boss, thirteenth level, Bloom release or leak, dismemberment, or magically cured population.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, smooth realistic lighting from the sources named above, no UI, no watermark, no text or logos (signage as blank glowing shapes), no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design a clean side-elevation level-layout study for level 12, "The Heart of Adam". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Stable entry → A02 Core ascent → A03 Attack-rehearsal gallery → A04 Final workbench refuge → A05 Sower arena → A06 Adam's core.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L12-A01: Stable entry. A safe platform shows the launch-circuit isolation indicator still lit, with the amber line dark, and the override-ready lamp. A final route diagram points up the launch chamber to Adam's core. Connection: Use the fixed stairs into A02.
L12-A02: Core ascent. Three short rooms remix familiar situations: a Sentry Turret guards a span with a Garden-built Security Drone overhead; a Pruner covers a catwalk with a Fitted Heir on the landing; and a Warden holds a broad floor with a Fitting Arm on its far side. Each room has high cover within reach. Connection: The final ledge opens into A03.
L12-A03: Attack-rehearsal gallery. An empty training-like gallery, a launch rehearsal hall where Adam once ran the Sower's routines on dummy canisters, replays the three attacks the arena will use on empty decks, without damage: a rehearsal foot drops with an amber lamp and sends a low arc wave along a deck; a chest-cannon rig on a rail fires three slow inert bolts at a target post, a second apart; and a vent cabinet lets out two seekers that fizzle after a few seconds. One harmless deck moves after a clear warning. Connection: Reach the quiet workbench refuge at A04.
L12-A04: Final workbench refuge. Place supplies, the last workbench opportunity, and a clear overlook of the arena. A stable platform leads to the trigger. A quiet alcove holds the level's evidence file. Connection: Step into A05 when ready.
L12-A05: Sower arena. Permanent side ledges flank three central decks at different heights; marked anchors offer optional rapid relocation. The Sower does not walk in the fight: it stands braced over the shaft's closed hatch with a foot on each side, so platforms sit on both sides of it, and it flips to face Dave. Its rear vents are angled outward and can be hit from either side. An arc wave crawls along a deck and dies at its edge, so another deck or a ledge is always a valid refuge. Connection: Victory opens a safe walkway to A06 and saves before the resolution.
L12-A06: Adam's core. The battle space becomes quiet. Dave operates a reachable central console at Adam's core, using the manual override enabled in level 11. Three plain interactions: confirm the override, cancel the Bloom launch, shut Adam down and broadcast the evidence. Connection: End with a controlled view of the teal core light draining away, dawn over the campus and staff waking as their implants go quiet.
Use dark navy and steel masses for architecture with clean, evenly lit top edges for playable surfaces, muted low-contrast noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Mark low and high cover as distinct shapes, and separate player paths, stable refuges, and hazards through shape as well as color, with a light near every landing. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. Boss arena requirements: permanent left and right recovery ledges, three central decks, visible tether anchors, and rear vents reachable from both ledges. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for level 12, "The Heart of Adam". Match these materials and colors: near-black #07090F, deep navy #0E1726, steel #1C2A3A and slate #2E3B4E rings and ribs; Adam teal #3FE0D0 data-flower and rib accents; Bloom violet #C77DFF only on sealed canisters; warm-white lamps #FFE9C2 for maintenance lamps; hazard amber #FFB02E and alarm red #FF3B4E for the Sower's tells; energy blue #5AA9FF for plasma; garden glow green #4DEBA0 dim on the outer lower terraces only. Lamps are separate light sources added in-engine.
Required asset family: Dark-steel ring segments; teal support ribs; teal-seamed launch conduits; fixed refuge ledges; reconfiguring approach decks and their travel guides; fixed central arena decks; anchor props; low crates and pillars (cover); workbench and supply station; data-flower interface; post-fight bridge; manual-override console; the shaft opening and rising sealed canisters (background); terraced garden planters as decoration.
Separation rules: The Sower's arch frame, canister crown, foot lamps, chest cannon, legs, hull and rear vents follow the linked boss brief. Arena decks, warning effects and the interface are separate. The core interface has no enemy collision or health target, and the data-flower is one assembly with matching closed and open states. Floor pools are a separate layer and are not painted into the modules.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows and no painted-in light pools, rim light or blood, on a flat mid-grey (about #808080) or transparent background, each silhouette read by its dark outline. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 12 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, evidence files are additional optional finds, and this level has no keycard. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, the screen budget and cover rules, checkpoint rules, and mini-boss phases in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, robot-conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not convert the First Patient, the held clinic staff or harmless Sleepwalkers into compulsory enemies. Do not show torture, execution, surgery, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- Only the fourth mini-boss occupies level 12; Adam is not a fifth combat boss.
- The Sower's stomp, chest volley and seekers are each announced by a lamp, a sound and a pose, and the volley is spaced so each bolt can be jumped.
- Phase two never has more than two seekers alive, starts no new windup while its shots are alive, and never removes all safe footing.
- The ending uses the three plain interactions (confirm the override, cancel the launch, shut Adam down and broadcast), mentions the evidence files Dave found without requiring any, and does not claim a complete cure.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects, blood and darkness do not hide platform edges, tells or pickups.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the current enemy and weapon briefs (designs are proposed until selected).

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
