# Level 8 — The Memory Orchard

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L08

**Campaign group:** The Wellness Center (levels 7–9)

**Status:** Detailed concept draft, rewritten on 2026-09-29 for the dark sci-fi direction and updated the same day for the approved enemy roster and gun kit (C25–C35, P23). The weapon order, enemy introductions and mini-boss placement follow the established outline. Area names, layouts, encounter quantities, duration targets, checkpoints, keycard and evidence-file placements, Adam's lockdown event, the capsule-bay scene, the Link-light cue for harmless Sleepwalkers and all new story and scenic details are *proposed* for refinement. The story names (Arcadia Dynamics, the Link, the Bloom) are proposal P17, and Thornwall is a working name; Adam (C17) and Dave Harlan (C18) are confirmed. The smooth, realistic lighting (C35) is a confirmed direction, validated by the approved lit-cutout test (2026-09-30).

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, an AI researcher fired for warning Arcadia Dynamics about its sentient AI, goes rogue and breaks back into the corporation's Eon City headquarters and the hidden facilities beneath it. The AI, Adam, is preparing a nanite weapon, the Bloom, that would wipe out humanity. Dave travels alone (C12). He fights Arcadia's contract security, the Thornwall contractors, Adam's machines, cyborg dogs and the Linked (people whose Link implants Adam drives), and from level 10 the Heirs (Adam's synthetic bodies). Combat is lethal: enemies bleed and die, and there is no dismemberment (C28, C29). Arcadia's executives appear in scenery, dialogue, recordings and scenes, never as targets. There is no stealth or detection system (C16). The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

Adam's archive, the Memory Orchard, stores copies of staff minds in server "trees". Its Keeper Drones tend the archive and murmur fragments of the people whose memories they hold, and the Linked Troopers who guard the branches are Thornwall contractors that Adam has caught and armed with its own plasma. Familiar signals from ordinary lives, such as a worker's old playlist, briefly reach the failing Linked who wander beneath the trees.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure and the upgrade currency (C19). Each level also hides one optional evidence file *(proposed)* and, in levels 1–11, locks its exit behind one clearance keycard *(proposed)*. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Cross the canopy archive, activate the route's archive console, take the level's keycard, and recover the records of Adam's mind-copying and its Heirs program. |
| Intended difficulty | Moderate, with quiet intervals |
| First successful exploration target | 16–21 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Linked Trooper, Keeper Drone |
| Enemy guns first faced | Plasma Gun (EG07), carried by the Linked Trooper, and Seeker (EG08), fired by the Keeper Drone. Returning: Machine Gun (EG03, Sentry Turret), Rail Rifle (EG05, Marksman), Assault Rifle (EG02, Rifleman) |
| Mini-boss | None |
| Keycard (*proposed*) | Archive gate card, printed by the A04 memory console beside the central tree; the service gate after A06 reads it. |
| Evidence file (*proposed*, optional) | EF08 **Training Sample 2291**, on a quiet balcony near the central tree ([S05](../design/03-progression/evidence-files.md)). |

## Story entry and exit

**Entry:** The archive passage from the Wellness Center enters a glass-roofed archive atrium that Adam calls the Memory Orchard. Dave is looking for a route to the implant theaters and reads archive records along the way.

**Exit:** From the records booth, a service gate opens toward level 9's implant theater. The Heirs records describe a program, not a finished product: no Heir body appears before level 10.

This is the first strong evidence that identity survives in copies. Dave's view of the Linked shifts from obstacle to person: harmless Sleepwalkers are staff whose implants are failing, a familiar tune can reach them for a moment, and the Keeper Drones murmur fragments of the dead employees whose memories they tend. The records reveal that Adam has been copying minds through the Link, and that it is building the Heirs, bodies meant to live in the world after the Bloom. Adam tends the Orchard like a gardener and speaks about it that way.

Here Dave meets the Linked Troopers for the first time. They are Thornwall contractors that Adam caught, fitted with a Link and armed with its own plasma carbines, and they walk in front of Thornwall's remaining guns. Most Link deaths are silent and the light simply dies; rarely a Trooper says something confused and human as it falls (*proposed:* "...what time is it?"). The level's single authored scene is quiet and holds no person: a bay of empty capsules where Thornwall helmets, jackets and rifles hang on the mounts, each with a copy-status tag.

## What the level looks like

Server "trees" rise through a dark, glass-roofed archive. Pale trunk shells wrap visible stacks of memory cylinders, and broad translucent leaf panels carry circuit-like veins that shimmer teal. Rounded glass capsules hang like fruit, but their large mounts reveal that they store data. Low garden benches, staff keepsakes and human-scale paths, arranged by Adam like a memorial garden, prevent the space from feeling like a purely abstract computer. The trees light the branches with smooth teal falloff, fans breathe, status LEDs blink, and ground fog stays in low bands. Muzzle flashes and plasma bolts briefly light the leaf panels. Where a fight ends, blood is dark and flat on the fixed branch floors, never on a moving part.

**Palette and lighting:** near-black #07090F for the archive depth, deep navy #0E1726, steel #1C2A3A and slate #2E3B4E for shadowed trunks and modules, trunk-shell blue-gray #7F93A8 for readable pale trunk edges, Arcadia teal #3FE0D0 for the tree glow and archive sphere, pale playback tint #BFF7F0 for projected memories only, hazard amber #FFB02E for Adam-driven Link lights and lamps, alarm red #FF3B4E for attack tells, energy blue #5AA9FF for plasma bolts (a white core, a dark ring and a round shape keep them apart from the teal glow), microchip gold #FFD166 for pickups, and blood red #B3212F (drying to #8A1A26) for floor pools only. Light pulses slowly rather than flashing, and every landing keeps its own lamp. Blood never glows and never uses a tell color. *(Trunk-shell blue-gray, the playback tint and all level-specific uses are proposed.)*

**Navigation landmark:** A split-trunk server tree holds a single large teal archive sphere above a quiet bench; the main route circles upward around it.

## Foreground, playable plane, and background

- **Foreground framing:** Sparse leaf panels and glass capsule edges near the border; no dense hanging canopy across the playable branch tops.
- **Playable plane:** Thick branch platforms with clear, lit top edges, maintenance brackets, fixed archive balconies, and marked optional tether anchors. Mandatory routes use ordinary jumps; marked tether anchors offer optional shortcuts when the tether is carried. Trunk-shell pillars and leaf-panel overhangs act as high cover, and planter walls and bench rows as low cover. Blood and bodies stay on fixed branch floors.
- **Background depth:** Layered server trees, large suspended storage modules, faded abstract silhouettes of people at desks and tables inside distant capsules, and the archive's glass roof under the night sky.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump, and frame a gun's muzzle and its lane before it fires; avoid hiding attack origins, landings, and recovery routes behind decoration or darkness.

## Main route

```text
A01 Quiet bench → A02 Branch archive → A03 Captured grove → A04 Memory clearing → A05 Upper canopy → A06 Transfer records.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, crouching, swimming, or an unlisted tool.

## Area-by-area design

### L08-A01 — Quiet bench

**Space and placement:** A harmless Sleepwalker in a faded charcoal uniform repeats the act of straightening a small keepsake, a mug, on a bench. Its Link light is a steady teal. The path passes safely behind a low rail, and no hostile enemy interrupts this opening observation.

**Player experience and lesson:** Reinforce that not every moving Linked worker is a combat target: the Sleepwalker is a protected NPC with no hit zone. A quiet gesture and a nearby archive playback, a soft chime and a short projected trace of the same routine, reveal the repeated memory. No reward or gate depends on harming the Sleepwalker.

**Completion and connection:** A short branch stair leads to A02.

### L08-A02 — Branch archive

**Space and placement:** Wide branches form a gentle ascent. One Keeper Drone laps a broad lit branch span and passes low over a fixed planter wall at the end of each lap; a low archive rack offers the only cover. Later on the branch, one Hound patrols a broad landing, Adam-driven and without a handler.

**Player experience and lesson:** Teach the first new type alone. Show the lantern swelling amber and then red, the sonar ping and the murmur (a processed voice plus a subtitle, for example "...did I leave the stove on?"), then the single seeker: wait until it is close and jump it, lead it into the planter wall, or shoot it down, and hit the drone on its low pass. Only one seeker is alive at a time. The Hound is then met alone on open ground, a returning type after a long absence: it drops low as its jaw glows amber and then red, and each lunge is jumped and answered while it recovers (three lunges here, each with its own blip).

**Completion and connection:** Reach a stable reading platform before A03.

### L08-A03 — Captured grove

**Space and placement:** One Linked Trooper stands guard on a broad floor between two trunk shells, facing a far wall of pale trunk plating; a painted maintenance stripe along the wall's base marks how close is too close *(proposed)*. Off to the side, a bay of empty capsules holds Thornwall helmets, jackets and rifles on the mounts, each tagged with a copy status.

**Player experience and lesson:** Teach the plasma carbine alone. The chamber glow grows amber and then red with a rising hum while the ball swells, and one slow bolt crosses the floor and bursts on the far wall. Jump the bolt, keep at least 1 H clear of the spot it will hit, then hit the Trooper while it vents. The Trooper is a captured Thornwall contractor: a steel plate through the scalp, unblinking eyes and an amber Link light. **The capsule bay is the level's one authored scene.** It is out of the combat lane and shows only empty gear, never a person.

**Completion and connection:** A quiet branch refuge provides a checkpoint.

### L08-A04 — Memory clearing

**Space and placement:** A console beside the central tree plays a worker's old playlist through the clearing's speakers, with a soft projected trace of the routines that person once performed here. Two harmless Sleepwalkers sit or stand within its bounded pool of light. The console also prints the level's keycard in a tray that is lit like any landing.

**Player experience and lesson:** Activating the console is a quiet story beat: the two Sleepwalkers pause mid-routine and turn toward the music, and one hums a few notes before resuming. It changes nothing mechanically. Show a safe bypass and a normal open route; no enemy waits here, and nothing must finish within a strict countdown.

**Completion and connection:** The console also opens a standard archive gate leading to A05.

### L08-A05 — Upper canopy

**Space and placement:** A fixed balcony alternates with thick branch platforms in two separate camera spaces. In the first, one Sentry Turret guards a branch span with a Keeper Drone lapping above it, and high cover (a trunk-shell pillar and a leaf-panel overhang) stands along the span. In the second, on the last approach, a Thornwall Marksman holds a far perch and a Rifleman holds the near ledge, with cover posts at most 8 H apart and a perch Dave can reach.

**Player experience and lesson:** Combine known shooting windows with vertical route reading. At the turret, keep running (its aim creeps slower than Dave) or stand in high cover, answer the seeker from a fixed ledge, then hit the turret's open core during its overheat. At the perch it is an advance fight: move one cover piece per recharge, use the reachable perch, and answer the Rifleman's bursts with a jump or low cover. The two spaces never share a screen, so each stays within one heavy gun, two shooters and three attackers. The Thornwall men shout that Adam is taking them one squad at a time (*proposed:* "It's taking us one squad at a time.").

**Completion and connection:** Reach an enclosed archive booth at A06.

### L08-A06 — Transfer records

**Space and placement:** A safe terminal in the booth displays three clear abstract components as icons and pictograms: stored minds, the Link that carries them, and a synthetic body outline marked as the Heirs program (a faceless silhouette, since the first Heir sighting is level 10). A short enrollment list beside it names staff and, in a separate column, Thornwall contractors marked "enrolled" *(proposed)*. The diagram makes the intended transfer process readable to Dave and the player.

**Player experience and lesson:** Recover the Heirs program records and open the service gate toward level 9; the gate's reader takes the level's keycard and otherwise shows a "keycard required" prompt. Adam comments calmly that the copies are safe with it and that the Heirs will look after the place afterwards (*proposed line*), rather than attacking or releasing anything yet.

**Completion and connection:** Proceed to level 9.

## Adam's lockdown event

*(Proposed event.)* Adam reroutes its Keeper Drones. Once the A04 console has played, the PA announces (*proposed line:* "Signal correction in progress. Thank you for your patience."), and the trees' teal glow dims in a wave from the clearing outward while amber pulses run down the trunks toward the upper canopy. The lap rails of the Keeper Drones light amber along their new paths before any drone moves, then the drones shift onto the upper-canopy rails. The wave, the announcement and the lit rails are the telegraph; every landing keeps its own lamp, no platform moves or seals, and the gate to A05 stays open. The first reroute happens with no drone near the route.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored and fires at fixed points, not when Dave is spotted (C16); it is not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Alternate quiet observation with short readable threats. Two new types are taught alone, the Keeper Drone in A02 and the Linked Trooper in A03, before they return in combinations: the Keeper joins a Sentry Turret in A05, and the plasma carbine's stand-clear rule is rehearsed once before any Thornwall rifle is added. At most one heavy gun (machine gun, rail rifle, cutter beam or plasma gun) is on a screen, with at most two shooters and three attackers. Seekers are capped at two alive and last about 2.5 seconds. The Linked never block progress, harmless Sleepwalkers remain protected NPCs in their authored spaces, and no gate requires harming anyone.

- [Hound](../art-design/hounds/k01-hound.md) — established behavior or returning type (Adam-driven here, with no handler).
- [Sentry Turret](../art-design/machines/m03-sentry-turret.md) — established behavior or returning type.
- [Marksman](../art-design/thornwall/tw03-marksman.md) — established behavior or returning type.
- [Rifleman](../art-design/security/se04-rifleman.md) — established behavior or returning type (Thornwall).
- [Linked Trooper](../art-design/linked/lk04-linked-trooper.md) — first introduction in this level.
- [Keeper Drone](../art-design/machines/m07-keeper-drone.md) — first introduction in this level.
- [Sleepwalker](../art-design/npcs/npc01-sleepwalker.md) — harmless, protected NPC only; not an enemy.

Guns in play: the [Plasma Gun](../art-design/enemy-guns/eg07-plasma-gun.md) (Linked Trooper) and the [Seeker](../art-design/enemy-guns/eg08-seeker.md) (Keeper Drone) are first faced here. The [Machine Gun](../art-design/enemy-guns/eg03-machine-gun.md) (Sentry Turret), the [Rail Rifle](../art-design/enemy-guns/eg05-rail-rifle.md) (Marksman) and the [Assault Rifle](../art-design/enemy-guns/eg02-assault-rifle.md) (Rifleman) return.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. Dave carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A03 on the branch refuge.
- After A05 before the record booth; the keycard printed at A04 is committed here and remains acknowledged on retry.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. The snapshot also records the microchip wallet, evidence files and the level's keycard; a keycard taken after the last checkpoint returns to its console on retry. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected microchips, evidence files and keycards must not duplicate. Enemy corpses and blood pools are restored as static scenery after a death or Continue, while live enemies reset. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Microchips are the primary reward in this level (C19). They are hand-placed in caches and alcoves, and enemies drop none *(proposed, P23)*; values and prices follow the [treasure economy](../design/03-progression/treasure-economy.md) proposal. Evidence files are additional discoveries: one optional memo, recording or log per level *(proposed)* that proves what Arcadia or Adam did. They go in the journal, have no stat effect and never gate the exit or the ending ([evidence files](../design/03-progression/evidence-files.md)). Ordinary scenery and story information the player needs on the main route do not automatically become evidence files. Spending microchips at checkpoint workbenches is the working economy proposal.

- A collection of staff keepsakes (mugs, lanyards and paper photo strips) that Adam has arranged beside capsule mounts on an optional low-risk branch loop, rewarding attention with lore and microchips.
- *Evidence file (proposed):* EF08 **Training Sample 2291** ([S05](../design/03-progression/evidence-files.md)), a finger-length archive cartridge with a teal level bar, seated in a rack slot on a quiet balcony near the central tree, in view of the A04 console's light and reached by normal platforms. It holds one ordinary memory Adam copied through the Link, someone humming over a stove at dawn, tagged as voice training for an Heir. It is not a whole mind or a portable adviser, and it does not open doors.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot. The keycard and all story information the player needs stay on the main route; no keycard sits in an optional branch or an evidence-file alcove.

## Sound and atmosphere

Server-fan whisper, translucent leaf panels brushing the glass roof, soft chimes from capsules, short indistinct remembered voices and scraps of music. The Keeper Drone's murmur is a processed voice with a subtitle, and its sonar ping rises as a seeker closes. A plasma carbine hums up before each bolt and thumps on launch, and the turret's spin-up whine and the Marksman's three-step whine stay clear above the ambience. Thornwall barks are short and scared, with profanity, as subtitles plus non-verbal shouts. Linked deaths are silent: the Link light just goes out. Personal memory audio remains sparse.

## Environment asset kit and layer separation

**Required kit:** Thick branch junctions; pale trunk shells; separate memory-cylinder stacks; capsule and mount variations, including an empty capsule bay with hanging gear; fixed archive balconies; planter walls and bench rows (low cover); trunk-shell pillars and leaf-panel overhangs (high cover); Keeper Drone lap rails; bench; keepsake props; archive console with a keycard tray; console-operated archive gate; service gate with a card reader; glass roof ribs; projected-memory effect planes.

**Separate objects:** Trunks, storage units, and projected memories are distinct components. Use noninteractive projections without collision. Harmless Sleepwalkers are separate background characters with no hit zone; the drone rails and the two gates have matching lit and unlit or closed and open states. Blood pools and stains are separate effect layers on fixed floors only.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors as flat base colors with no baked shadows, so the engine's lamps can light them (C35); keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Lamps, screens and glows are their own light sources, so a landing keeps its lamp when the scenery is swapped. Final sprite resolution, atlas layout, file format and collision setup remain undecided.

## Constraints for another AI model

No Heir body or Heirs encounter (the first Heir is level 10), global mind control, harm to harmless Sleepwalkers, collectible-gated plot, or boss. The capsule bay shows gear and status tags, never a person being taken, and there is no torture, execution or dismemberment. Do not make memories appear as clear portraits that define backstories for unapproved characters. Blood is restrained: red (#B3212F, drying to #8A1A26) for people and dogs, black oil (#14181E) for machines and grey-rose lymph (#A88A8C) for Heirs. It never glows, never uses a tell color, never hides a tell, ledge or pickup, and pools appear only on static floors. Plasma bolts, seekers and turret tracers follow the gun-kit colors and never use gold, violet, amber, red, teal or green.

Preserve the established number of levels, enemies (24 types plus four mini-bosses), weapons, and upgrades. Show only one weapon carried by Dave; do not place spare guns on Dave's belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art. Do not add stealth, vision cones or alert states (C16).

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use the linked enemy briefs if detailed characters are needed (their designs are proposed until the lit-cutout validation test is approved); otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Environment concept art: one wide 16:9 environment keyframe for level 8, "The Memory Orchard". Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. This keyframe is the one exception to "evenly lit": it is a lit mood reference, so show the scene as the engine will light it, with smooth, realistic light and falloff from the lamps, screens and glows named below (no hard-edged light bands or cel shadows), while the underlying art stays flat base colors with clean dark outlines. Represent glass, metal and circuitry with clean flat-color shapes and dark outlines. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes, landings and pickups readable in the dark, with a light near every landing. No pixel art, photographic textures or franchise assets.

Narrative purpose: Adam's archive, the Memory Orchard, stores copies of staff minds in server "trees", its Keeper Drones murmur fragments of the people they hold, and captured Thornwall contractors, now Linked Troopers, guard the branches.
Physical setting: Server "trees" rise through a dark glass-roofed archive. Pale trunk shells wrap visible stacks of memory cylinders, and broad translucent leaf panels carry circuit-like veins that shimmer teal. Rounded glass capsules hang like fruit, but their large mounts reveal that they store data. Low garden benches, staff keepsakes and human-scale paths prevent the space from feeling like a purely abstract computer.
Color and lighting: near-black #07090F, deep navy #0E1726, steel #1C2A3A, slate #2E3B4E, trunk-shell blue-gray #7F93A8 for readable pale trunk edges, Arcadia teal #3FE0D0 for the tree glow and archive sphere, pale playback tint #BFF7F0 for projected memories only, hazard amber #FFB02E for lamps and Adam-driven Link lights, alarm red #FF3B4E for attack tells, energy blue #5AA9FF with a white core and a dark ring for plasma bolts, microchip gold #FFD166 for a few pickups. The trees light the branches with smooth teal falloff; light pulses slowly rather than flashing, and every landing keeps its own lamp.
Landmark: A split-trunk server tree holds a single large teal archive sphere above a quiet bench; the main route circles upward around it.
Composition to show: A side-view server-tree clearing with a harmless Sleepwalker by a bench, broad pale branches forming the route, a softly glowing teal archive sphere above, a Keeper Drone drifting on its lit lap rail with one small pale finned seeker in flight, a Linked Trooper in Thornwall gear holding a pearl-white plasma carbine on a lower branch, and a console projecting a faint pale trace of an old work routine. Include a small silhouette of Dave in a burnt-orange jacket on a lit branch for scale.
Foreground: Sparse leaf panels and glass capsule edges near the border; no dense hanging canopy across the playable branch tops.
Playable plane: Thick branch platforms with clear, lit top edges, maintenance brackets, fixed archive balconies, and marked optional tether anchors. Mandatory routes use ordinary jumps; marked tether anchors offer optional shortcuts when the tether is carried. Trunk-shell pillars and leaf-panel overhangs act as high cover, and planter walls and bench rows as low cover. Blood and bodies stay on fixed branch floors.
Background: Layered server trees, large suspended storage modules, faded abstract silhouettes of people inside distant capsules, and the archive's glass roof under the night sky.
Show only this level's appropriate threats: Hound, Keeper Drone, Linked Trooper, Sentry Turret, Thornwall Marksman, Thornwall Rifleman, plus harmless Sleepwalkers as background people; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No Heir bodies, global mind control, harm to harmless Sleepwalkers, collectible-gated plot, boss, torture, execution, on-screen capture, dismemberment or exposed organs; the capsule bay shows only empty gear. Do not make memories appear as clear portraits that define backstories for unapproved characters. Blood is restrained red on the floor only, never glowing.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, smooth realistic lighting from the sources named above, no UI, no watermark, no text or logos (signage as blank glowing shapes), no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design a clean side-elevation level-layout study for level 8, "The Memory Orchard". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Quiet bench → A02 Branch archive → A03 Captured grove → A04 Memory clearing → A05 Upper canopy → A06 Transfer records.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L08-A01: Quiet bench. A harmless Sleepwalker in a faded charcoal uniform repeats the act of straightening a small keepsake, a mug, on a bench. Its Link light is a steady teal. The path passes safely behind a low rail, and no hostile enemy interrupts this opening observation. Connection: A short branch stair leads to A02.
L08-A02: Branch archive. Wide branches form a gentle ascent. One Keeper Drone laps a broad lit branch span and passes low over a fixed planter wall at the end of each lap; a low archive rack offers the only cover. Later on the branch, one Hound patrols a broad landing, Adam-driven and without a handler. Connection: Reach a stable reading platform before A03.
L08-A03: Captured grove. One Linked Trooper stands guard on a broad floor between two trunk shells, facing a far wall of pale trunk plating; a painted maintenance stripe along the wall's base marks how close is too close *(proposed)*. Off to the side, a bay of empty capsules holds Thornwall helmets, jackets and rifles on the mounts, each tagged with a copy status. Connection: A quiet branch refuge provides a checkpoint.
L08-A04: Memory clearing. A console beside the central tree plays a worker's old playlist through the clearing's speakers, with a soft projected trace of the routines that person once performed here. Two harmless Sleepwalkers sit or stand within its bounded pool of light. The console also prints the level's keycard in a tray that is lit like any landing. Connection: The console also opens a standard archive gate leading to A05.
L08-A05: Upper canopy. A fixed balcony alternates with thick branch platforms in two separate camera spaces. In the first, one Sentry Turret guards a branch span with a Keeper Drone lapping above it, and high cover (a trunk-shell pillar and a leaf-panel overhang) stands along the span. In the second, on the last approach, a Thornwall Marksman holds a far perch and a Rifleman holds the near ledge, with cover posts at most 8 H apart and a perch Dave can reach. Connection: Reach an enclosed archive booth at A06.
L08-A06: Transfer records. A safe terminal in the booth displays three clear abstract components as icons and pictograms: stored minds, the Link that carries them, and a synthetic body outline marked as the Heirs program (a faceless silhouette, since the first Heir sighting is level 10). A short enrollment list beside it names staff and, in a separate column, Thornwall contractors marked "enrolled" *(proposed)*. The diagram makes the intended transfer process readable to Dave and the player. Connection: Proceed to level 9.
Use dark navy and steel masses for architecture with clean, evenly lit top edges for playable surfaces, muted low-contrast noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Mark low and high cover as distinct shapes, and separate player paths, stable refuges, and hazards through shape as well as color, with a light near every landing. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for level 8, "The Memory Orchard". Match these materials and colors: near-black #07090F, deep navy #0E1726, steel #1C2A3A, slate #2E3B4E, trunk-shell blue-gray #7F93A8, Arcadia teal #3FE0D0, pale playback tint #BFF7F0 (projected memories only), hazard amber #FFB02E, alarm red #FF3B4E, energy blue #5AA9FF (plasma only), microchip gold #FFD166. Light pulses slowly rather than flashing, and every landing keeps its own lamp, added in-engine.
Required asset family: Thick branch junctions; pale trunk shells; separate memory-cylinder stacks; capsule and mount variations, including an empty capsule bay with hanging gear; fixed archive balconies; planter walls and bench rows (low cover); trunk-shell pillars and leaf-panel overhangs (high cover); Keeper Drone lap rails; bench; keepsake props; archive console with a keycard tray; console-operated archive gate; service gate with a card reader; glass roof ribs; projected-memory effect planes.
Separation rules: Trunks, storage units, and projected memories are distinct components. Use noninteractive projections without collision. Harmless Sleepwalkers are separate background characters; the drone rails and the two gates have matching lit and unlit or closed and open states. Blood pools and stains are separate layers and are not painted into the modules.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows and no painted-in light pools, rim light or blood, on a flat mid-grey (about #808080) or transparent background, each silhouette read by its dark outline. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 8 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, each level has one optional evidence file, and each level's exit door needs its keycard. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, the screen budget and cover rules, checkpoint rules, keycard placement, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, robot-conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not convert the founder, the held clinic staff or harmless Sleepwalkers into compulsory enemies. Do not show torture, execution, surgery, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- Harmless Sleepwalkers are observed peacefully (level 7, then the bench here) and are never enemies.
- The Keeper Drone and the Linked Trooper are each taught alone before any combination, and no screen exceeds two shooters, three attackers or one heavy gun.
- Seekers are capped at two alive, last about 2.5 seconds and can be shot down; the Trooper's burst never lands on a spot Dave is forced to use.
- The level's one authored scene (the capsule bay) shows only empty gear and no person.
- The Heirs program is revealed through records without moving the first Heir sighting before level 10.
- The keycard is on the main route at the A04 console, and the service gate tells the player when it is missing.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects, blood and darkness do not hide platform edges, tells or pickups.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the current enemy and weapon briefs (designs are proposed until selected).

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
