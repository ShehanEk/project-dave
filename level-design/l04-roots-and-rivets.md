# Level 4 — Roots and Rivets

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L04

**Campaign group:** The Rootworks

**Status:** Detailed concept draft, updated on 2026-09-29 for the approved enemy roster (C25–C35). The new enemy types are the Sentry Turret and the Freight Loader, and Thornwall's contractors arrive: the Riflemen from here on are Thornwall men. Names, weapon order, enemy introductions and mini-boss placement follow the established outline, and the story beats follow the concept document's level table. Layouts, encounter quantities, duration targets, checkpoints, and every new name, prop and scenic detail are *proposed* for refinement. The enemy art direction (C35) is confirmed direction, validated: the user approved the lit Night Guard test on 2026-09-30.

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, a fired AI researcher who went rogue, works alone through the facilities of Arcadia Dynamics *(proposed name)*, now beneath its Sunnyvale campus, to expose Adam, Arcadia's sentient AI, which is secretly building a weapon to wipe out humanity. Dave fights human enemies (Arcadia Security's guards and, from this level, the contractors of Thornwall, a private military contractor *(working name)*), the Linked (staff whose Link implants Adam drives), Adam's machines and cyborg dogs (C25, C30). Combat is lethal: every enemy bleeds according to what it is made of and stays where it falls (C28, C29). The Heirs first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

Beneath the campus lawns, hanging cable bundles wind through the freight and server halls of the Rootworks. A freight network keeps carrying server racks for a purpose its workers were never told, until a contract shows that Arcadia itself took the order, and the contractors who guard the defense servers receive new orders: sanitize.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure (C19). Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location. Proposed additions: one optional evidence file per level, and one keycard per level that opens the exit door. There is no stealth or detection system (C16).

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Recover the Arc Welder, traverse the freight and server galleries as Thornwall's contractors take over the halls, find Arcadia's weapon contract in the freight control room, and use the level's keycard to open the recycling freight door to the recycling route. |
| Intended difficulty | Easy–moderate |
| First successful exploration target | 14–18 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | Arc Welder |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder |
| New enemy types | Sentry Turret, Freight Loader (Thornwall Riflemen also appear from here, as the Rifleman type in Thornwall gear) |
| Enemy guns first faced | None new. The Sentry Turret's rotary (EG03) and the Riflemen's rifles (EG02, Thornwall's are taped TK-12s) were first met in level 3; here they serve Adam's machines and Thornwall. |
| Mini-boss | None |
| Keycard *(proposed)* | Level 4 clearance card from the lit card slot of the contracts terminal in A06, on the main route, released when Dave opens the contract file. It opens the recycling freight door. |

## Story entry and exit

**Entry:** The service lift from the Parade of Progress terminus deposits Dave in a quiet Rootworks receiving bay. Floor guide lines trace a route toward the freight door that leads to the recycling plant, and the door's amber-ringed card reader is glimpsed at the end of the lines, so the locked exit and the empty keycard indicator are seen before the card is found *(proposed)*.

**Thornwall arrives.** From the lift ledge Dave sees a freight elevator across the bay lower a fire team into the receiving bay: contractors in plain dark tactical gear with worn, taped rifles and a small Thornwall mark. They fan out along an upper gallery on their way to their posts in the halls ahead. The moment is scripted and safe (control returns throughout, and nothing depends on being seen), and a contractor's radio gives the new order in flat, cold words: "Sanitize the level. Nobody walks out." *(proposed)* These are the men who guard the Rootworks' defense servers. The Rifleman met in level 3 in Arcadia's Response Team gear is now a Thornwall man, and from here the Riflemen Dave meets are Thornwall's.

**Exit:** A keycard-locked recycling freight door leads to level 5's recycling plant. Before it, at the contracts terminal in the freight control room (scene SC04 in the [story scenes](../design/05-presentation/story-scenes.md)), Dave finds Arcadia's contract: a military order for a weapon that "removes people and spares infrastructure". The project is the Bloom, and it is Arcadia's own. *Proposed:* the signature block is blacked out and the target list is missing, so who ordered it and whom it is aimed at stay open for later levels. A duty board beside the terminal explains the contractors' arrival: Thornwall's standing retainer to guard the defense servers, and tonight's order changed from "guard" to "sanitize" by the board's security committee, with no names *(proposed)*.

The contrast is between enormous automation and the people who signed for it. Dave compares the freight manifests with the contract and sees that the shipments have a purpose after all, and that Arcadia itself took the order. Adam's lines are *proposed*: at the reversal, "Freight rerouting in progress. Thank you for your patience." At the control terminal: "Welcome back, Dr. Harlan." Dave's reply is short and dry: "Someone signed this."

## What the level looks like

Large rounded concrete ribs support low, black industrial halls. Chunky amber-striped freight machines work beside server racks whose walls blink with teal and green status LEDs, and thick cable bundles hang from the ceilings and cross the halls like roots. Small amber work lamps light copper pipes and abandoned order trays, and flat, low bands of cooling mist drift across the floor. Shuttered turret housings sit in the walls and ceilings of the defense-server halls, and Thornwall's guard posts, plain barricades of crates with a field desk, stand at the doors. Keep a believable service building underneath the cabling; this is a functioning facility, not a generic cave.

**Palette and lighting:** Black halls #07090F with steel #1C2A3A machinery and slate #2E3B4E floor plates; blinking teal #3FE0D0 and green #3DDC84 *(proposed)* server LEDs; cable roots in near-black navy #0E1726 sheaths with a teal rim light; hazard amber #FFB02E work lamps and freight-machine stripes; alarm red #FF3B4E emergency strobes, used sparingly and only as lockdown telegraphs (reduced-flash settings apply). Light is smooth, realistic engine light cast by the work lamps, LEDs and strobes in the scene (C35): amber lamps at workstations light the refuges brighter than the dark recesses, there is a light near every landing, every source is visible in the scene, and no light pool is painted into the scenery. Blood (#B3212F, drying to #8A1A26) reads on the slate floor plates; machine oil is #14181E with a #46566A sheen rim.

**Navigation landmark:** A massive cable root, thick as a tree trunk, passes through the center of a transparent server-cooling drum full of dark water and reappears across two adjacent halls.

## Foreground, playable plane, and background

- **Foreground framing:** A few thick pipe bends and hanging cable ends frame the edges. Ceiling cables cannot hide a turret's shutter, an attack origin or a tell.
- **Playable plane:** Clearly edged service walkways, slow conveyors, crate tops, fixed shelving landings, and an accessible maintenance floor under the first moving belts, all with lit top edges. Low crates (0.6 H) and solid rack blocks (at least 1.2 H) are fixed to static floors as cover. Blood pools sit on static floors only, never on a belt.
- **Background depth:** Deep server aisles with blinking LEDs, distant freight routes, inactive storage machines, and the enormous cable-root cooling drum. Background belts carry scenery rather than surprise projectiles.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration or darkness.

## Main route

```text
A01 Receiving bay → A02 Repair workshop → A03 Freight stack → A04 Turret gallery → A05 Conveyor junction → A06 Recycling door.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L04-A01 — Receiving bay

**Space and placement:** Exit the lift onto a safe ledge above one slow conveyor. A lower service floor catches failed jumps. Show a hanging cable bundle sagging from a torn ceiling panel, swaying, without changing the route. The Thornwall arrival is staged here, as scenery seen from the ledge. A single Patrol Rover, gliding a fixed route on the far fixed landing, is the only enemy; the landing ends in a wall, so a jumped charge stalls against it.

**Player experience and lesson:** Introduce underground scale and conveyor motion before combat. The Rover is a returning type, so this is a low-pressure refresher: jump the charge, then shoot the battery while it stalls.

**Completion and connection:** Follow a bright amber workshop lamp into A02.

### L04-A02 — Repair workshop

**Space and placement:** A quiet workbench contains the Arc Welder, an Arcadia repair tool. Two inert conductive targets sit close enough to show a short chain, beside clear floor space.

**Player experience and lesson:** Teach short range and overheating. Demonstrate the gauge and a safe cooling pause before any enemy is active.

**Completion and connection:** Weapon collection opens a normal service door into A03; no weapon-specific electrical lock is required.

### L04-A03 — Freight stack

**Space and placement:** One Freight Loader occupies a long freight floor, alone. Dave enters on a raised upper ledge reached by a short stair; permanent low crates (0.6 H) sit on the upper ledge, out of the Loader's lane, and the ledge has a direct firing line down to the floor. In an adjacent bay, one Thornwall Rifleman holds the far side of an open freight lane behind a low crate.

**Player experience and lesson:** Introduce the Loader's tell alone: its forks drop as its beacon goes amber, then red, with a horn blast, then it rams down its whole floor, too tall to jump. The answer is to get off its floor onto the ledge, then hit the rear power unit while it stalls. Then reveal the Rifleman as the first Thornwall man in the halls: he shoulders the carbine as its lamp goes amber, then red, then fires two flat 3-round bursts. Dave can jump one burst at a time, stand behind the low crate, or close in during the magazine swap.

**Completion and connection:** Dave can clear the bay or slip past the lane; clearing the bay opens the route to A04.

### L04-A04 — Turret gallery

**Space and placement:** A short, brightly edge-lit corridor contains one Sentry Turret in a wall mount above a wide safe floor. A run of solid server-rack blocks (at least 1.2 H, with lit top edges) gives high cover within 3 H of every standing spot on the floor. The next alcove, a screen away, contains a second Turret on a different wall at a different height. The two never share a screen.

**Player experience and lesson:** Make the shutter opening, the rising spin-up whine and the collar glow (amber, then red) visible. The stream's aim point creeps after Dave, slower than he runs, so keep running or get behind a rack, then hit the open core during the overheat. Shooting the first turret's exposed core before the player enters the second alcove teaches the pattern under low pressure.

**Completion and connection:** A quiet server alcove provides a checkpoint before A05.

### L04-A05 — Conveyor junction

**Space and placement:** Two short conveyor segments connect fixed islands. Put one Freight Loader on the near island's long floor, with a raised shelf and a stair beside it so Dave can leave its floor, and one Thornwall Rifleman behind a low crate on the far island. A Sentry Turret appears only in the final fixed-floor section, a screen away from the islands.

**Player experience and lesson:** Combine floor-leaving, crate cover and target priority while leaving a stable retreat: Dave can shoot the Rifleman from the shelf, or use the Loader's stall. Never combine the first turret stream with a forced belt jump, and no gun lane covers a belt ride.

**Completion and connection:** A stationary stair leads to A06.

### L04-A06 — Recycling door

**Space and placement:** A quiet freight control room has a large readable service diagram, a contracts terminal with a lit card slot, a duty board, and the recycling door's card reader and manual release switch. The door is the level's keycard door, with an amber ring and bar symbol while locked and a teal ring and chevron once open. Behind glass, the automated shipping orders cycle without human approval.

**Player experience and lesson:** Dave opens the terminal, which greets Dr. Harlan by name, and finds Arcadia's contract: a military order for a weapon that "removes people and spares infrastructure", under the project name the Bloom. Opening the file releases the card slot, and Dave takes the level's keycard *(proposed)*. The duty board shows Thornwall's retainer and tonight's changed order. Seat the card in the reader and interact with the switch to release the recycling freight door; without the card the reader gives a harmless "card required" cue. The contract is mandatory story, not the level's optional evidence file.

**Completion and connection:** Enter level 5 without a timed escape or new boss.

## Adam's lockdown event

Adam reroutes the freight. The telegraph comes first: the warning arrows visibly change, amber lamps pulse, a chime sounds and a caption appears, with a polite PA announcement on the first. Then one demonstrated conveyor reverses, and the server racks riding it never crush Dave. Dave stands on a fixed island during the first reversal; later reversals always preserve a route back to that island. The event is scripted and telegraphed. There is no stealth or detection system (C16), so no reroute is triggered by being seen; Adam simply changes the freight to suit its schedule. No gun lane covers a belt while it moves.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced lockdown change. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Introduce the Freight Loader (A03) and the Sentry Turret (A04) separately, each alone. Later allow one heavy threat plus one Thornwall Rifleman; the turret never shares a screen with another heavy gun. The Arc Welder is useful but never the only damage source. Returning types (Night Guards for the last time, Sidearm Guards, Riot Officers, Patrol Rovers, Security Drones and Staffers) may hold optional side lanes but not the introduction encounters.

The Freight Loader is a heavy charger: too tall to jump, so Dave leaves its floor, then hits the rear power unit during the stall. The Sentry Turret spins up for about a second (amber, then red for the last 0.25 s), then streams for about 1.2 s with an aim point that creeps after Dave slower than he runs, then overheats with its core open. It is placed within reach of high cover and never at long range. Thornwall Riflemen fire two flat bursts per volley at this level, never at an airborne Dave, and they fire only when at least 1 H inside the camera edge.

Combat is lethal (C28) and visible (C29). Thornwall men, Night Guards and Staffers bleed red, and bodies stay where they fell, restored as static corpses after a death or a Continue. A dead Rifleman's rifle falls as a prop, never a pickup. The Loader and the Turret spark, leak black oil and burst into debris parts (C35) that settle clear of stairs, ledges and pickups. Blood pools sit on static floors only and never hide a tell, a ledge or a pickup. Keep landings, pickups and the contracts terminal clear of likely body positions. A corpse is not cover.

Placement rules used here (P23): at most 2 shooters, 3 attackers and 1 heavy gun per screen (each screen here holds at most one turret and one Rifleman), every machine-gun spot has high cover or another floor within 3 H, no pit edge within 1.5 H behind Dave's standing spots in a gun lane, the camera shows a gun's muzzle and its lane before it fires, and the Linked never block progress. The rules are owned by [encounter and boss fairness](../design/04-world/encounter-and-boss-fairness.md).

- [Rifleman](../art-design/security/se04-rifleman.md) — established behavior; a Thornwall man from this level.
- [Night Guard](../art-design/security/se01-night-guard.md) — established behavior or returning type (last level).
- [Patrol Rover](../art-design/machines/m01-patrol-rover.md) — established behavior or returning type.
- [Freight Loader](../art-design/machines/m04-freight-loader.md) — first introduction in this level.
- [Sentry Turret](../art-design/machines/m03-sentry-turret.md) — first introduction in this level.
- [Machine gun, HG-40 "Thresher" (EG03)](../art-design/enemy-guns/eg03-machine-gun.md) and [assault rifle (EG02)](../art-design/enemy-guns/eg02-assault-rifle.md) — met in level 3, now on the Turrets and on Thornwall.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md) — an Arcadia repair tool that shocks its targets and disrupts exposed machine systems.

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry, the level's workbench checkpoint *(proposed)*.
- After A02, saving the chosen carried weapon and the swap location.
- In the server alcove after A04.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently, and bodies of enemies that were already killed are restored as static corpses; swapped weapons, collected microchips and the keycard must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

*Proposed:* the A06 control room holds no enemies, so it needs no extra checkpoint. Opening the contracts terminal is a story interaction that commits the contract as read, the card comes from the same interaction, and a card taken after the last checkpoint returns to its slot on death.

## Optional exploration and rewards

Microchips are the primary reward in this level. They are hand-placed in caches and alcoves; enemies drop nothing *(proposed)*. Evidence files are additional discoveries: one optional memo, recording or log per level that proves what Arcadia or Adam did. They go in the journal, have no stat effect and never gate the ending; the [evidence-file catalog](../design/03-progression/evidence-files.md) owns the final list, and how they are presented remains open. Ordinary scenery and mandatory story beats, including the contract, do not automatically become evidence files. Spending microchips at workbenches is the working economy proposal.

- A visible crate-stack microchip cache accessible through ordinary jumps in A03.
- A worker rest shelf in a side server recess off A05, reached from a fixed island by a short ordinary lift that rejoins the main route, holds the level's evidence file: EF04, the Bay 9 Voice Memo, a palm-size grey field recorder with a belt clip and a small teal status light. A Rootworks technician records that the racks in Bay 9 do not cool servers, that nobody will say what they are for, that a contractor team on retainer guards the door and will not say either, and that Adam signs every requisition itself; the memo ends mid-sentence at the shift bell. It adds a voice to the contract on the main route and does not replace it, and it is not the level's keycard.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Low server hum, conveyor rumble, hollow crate impacts, distant cooling fans, dripping coolant, and distant unanswered alarms. Adam's warm, reverberant PA voice announces the freight rerouting politely. Thornwall is cold and flat: short radio calls and taped rifles, one "brrt" cue per burst and a magazine clatter. The Sentry Turret's shutter clacks open and its rotary whine rises in pitch as the collar glows, then a held chatter loop on its own audio player and a steam hiss at overheat. The Freight Loader gives a fork clunk and a horn blast before it rams. Hits land with restrained wet impacts (C28).

## Environment asset kit and layer separation

**Required kit:** Concrete support arches; conveyor modules and end rollers; service floor plates; crate variants (including low crates, 0.6 H); server racks in three variants (dim background racks, solid cover or platform blocks at least 1.2 H with a lit top edge, and conveyor cargo) and cabinets; thick cable-root junctions and hanging cable bundles; clear cooling drum; pipe elbows; workshop workbench; shuttered turret housings for ceiling and wall mounts (closed and open states); Thornwall guard posts (crate barricades and a field desk); freight lane markings; freight elevator and receiving-bay gallery; contracts terminal with lit card slot and a duty board; keycard-door recycling freight door with card reader and release switch (amber locked and teal open states); worker rest shelf with a short service lift.

**Separate objects:** Keep conveyors and crates separate from fixed collision floors. Only solid racks collide or can be stood on; background racks never damage and are never platforms. Hanging cable bundles crossing cabinets need distinct drawing layers so they never hide landings. The cooling drum is background scenery, not an implied swimming space. The terminal, card reader and freight door are separate props with matching locked and open states. Floor plates stay plain enough that a blood pool reads on them.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers; work lamps, LEDs and strobes are engine lights, and mist bands and blood live on the effects layer. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No tether use, machine conversion, Wellness Center imagery, Heirs, Marksmen, plasma or lava foundry aesthetic. Do not require a gun to power environmental switches unless the concept later explicitly adds that mechanic. Cable roots are cables, never plants or organic growth. No stealth: status LEDs, emergency strobes and drones warn or decorate, and never form detection cones or alert states (C16). Nothing here shows torture, execution, sexual violence, children, dismemberment, or blood and bodies painted into the scenery (blood is added in the engine).

Preserve the established number of levels, the 24-type enemy roster (C31), weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art; Dave has no final design yet, so keep Dave a small silhouette in a warm burnt-orange jacket.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
This is environment concept art and a lighting reference. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Paint concrete, steel, cable sheathing and machinery as clean, flat base colors with dark outlines and simple material marks so they can be split into modules; draw cooling mist as flat, low-contrast bands. Because this is a mood reference, show the halls as smooth, realistic light from the work lamps, LEDs and strobes in the scene, with a light near every landing; the final scenery is painted without baked light pools or shadows, and the engine adds the lighting. Preserve the level-specific palette and mood, and keep playable surfaces, enemies, attack lanes, microchips and landings clear. No photorealism, glossy chrome, pixel art or franchise assets. Blood appears only as a few restrained floor stains (#B3212F, drying to #8A1A26), never on the architecture, and there are no bodies; the final scenery carries none, because the engine adds blood.

Create one wide 16:9 environment keyframe for level 4, "Roots and Rivets".
Narrative purpose: Beneath the campus lawns, hanging cable bundles wind through the freight and server halls of the Rootworks. A freight network keeps carrying server racks for a purpose its workers were never told, until a contract shows that Arcadia itself took the order, and the contractors who guard the defense servers receive new orders.
Physical setting: Large rounded concrete ribs support low, black industrial halls. Chunky amber-striped freight machines work beside server racks whose walls blink with teal and green status LEDs, and thick cable bundles hang from the ceilings and cross the halls like roots. Small amber work lamps light copper pipes and abandoned order trays, and flat, low bands of cooling mist drift across the floor. Shuttered turret housings sit in the walls, and plain crate barricades with a field desk stand at a door. Keep a believable service building underneath the cabling; this is a functioning facility, not a generic cave.
Color and lighting: Black halls #07090F with steel #1C2A3A machinery and slate #2E3B4E floor plates; blinking teal #3FE0D0 and green #3DDC84 server LEDs; cable roots in near-black navy #0E1726 sheaths with a teal rim light; hazard amber #FFB02E work lamps and freight-machine stripes; alarm red #FF3B4E only for a distant emergency strobe. Amber lamps at workstations light the refuges brighter than the dark recesses.
Landmark: A massive cable root, thick as a tree trunk, passes through the center of a transparent server-cooling drum full of dark water and reappears across two adjacent halls.
Composition to show: A side-view freight bay with a fixed hero ledge on the left, a short belt over a lower return floor, a heavy Freight Loader with lowered forks on the right, a small Thornwall contractor in plain dark tactical gear behind a low crate, and a huge cable root glowing with teal rim light inside a cooling drum behind.
Foreground: A few thick pipe bends and hanging cable ends frame the edges. Ceiling cables cannot hide a turret shutter or an attack origin.
Playable plane: Clearly edged service walkways, slow conveyors, crate tops, fixed shelving landings, and an accessible maintenance floor under the first moving belts, all with lit top edges.
Background: Deep server aisles with blinking LEDs, distant freight routes, inactive storage machines, and the enormous cable-root cooling drum. Background belts carry scenery rather than surprise projectiles.
Show only this level's appropriate era and threats: Freight Loader, Sentry Turret, Thornwall Rifleman, Night Guard, Patrol Rover, Staffer; no boss. Keep the number of characters low and their poses subordinate to environment readability. If Dave appears, draw a small silhouette in a warm burnt-orange jacket carrying exactly one weapon. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No tether use, machine conversion, Wellness Center imagery, Heirs, or lava foundry aesthetic. Do not require a gun to power environmental switches unless the concept later explicitly adds that mechanic. No vision cones or detection beams; no dismemberment, exposed organs, bodies, or more than a few restrained blood stains on the floor.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, no UI, no watermark, no textual labels, no logos, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Design a clean side-elevation level-layout study for DEAD EDEN level 4, "Roots and Rivets". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Receiving bay → A02 Repair workshop → A03 Freight stack → A04 Turret gallery → A05 Conveyor junction → A06 Recycling door.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L04-A01: Receiving bay. Exit the lift onto a safe ledge above one slow conveyor. A lower service floor catches failed jumps. Show a hanging cable bundle sagging from a torn ceiling panel without changing the route; a freight elevator across the bay lowers a small fire team. Connection: Follow a bright amber workshop lamp into A02.
L04-A02: Repair workshop. A quiet workbench contains the Arc Welder. Two inert conductive targets sit close enough to show a short chain, beside clear floor space. Connection: Weapon collection opens a normal service door into A03; no weapon-specific electrical lock is required.
L04-A03: Freight stack. One Freight Loader occupies a long freight floor; Dave enters on a raised upper ledge with low crates out of its lane and a direct firing line down. In an adjacent bay, one Thornwall Rifleman stands behind a low crate. Connection: Clearing the bay opens the route to A04.
L04-A04: Turret gallery. A short, brightly edge-lit corridor contains one Sentry Turret in a wall mount above a wide safe floor, with solid server-rack blocks as high cover. The next alcove contains a second turret on a different wall, a screen away. Connection: A quiet server alcove provides a checkpoint before A05.
L04-A05: Conveyor junction. Two short conveyor segments connect fixed islands. Put one Freight Loader on the near island's long floor with a raised shelf beside it, and one Thornwall Rifleman behind a low crate on the far island. A turret appears only in the final fixed-floor section. Connection: A stationary stair leads to A06.
L04-A06: Recycling door. A quiet freight control room has a large readable service diagram, a contracts terminal with a lit card slot, a duty board, and the recycling door's card reader and manual release switch (amber ring while locked, teal ring once open). Behind glass, the automated shipping orders cycle without human approval. Connection: Enter level 5 without a timed escape or new boss.
Use dark simple masses for architecture, clean, evenly lit top edges for playable surfaces (mark where a lamp sits near every landing), muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Draw low cover (0.6 H) and high cover (at least 1.2 H) as distinct shapes. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 4, "Roots and Rivets". Match these materials and colors: Black halls #07090F with steel #1C2A3A machinery and slate #2E3B4E floor plates; teal #3FE0D0 and green #3DDC84 server LED housings; cable roots in near-black navy #0E1726 sheaths; hazard amber #FFB02E work-lamp housings and freight-machine stripes. Lamp and LED colors belong to the lamp objects; the engine casts the light, so do not paint light pools or glow into the pieces.
Required asset family: Concrete support arches; conveyor modules and end rollers; service floor plates; crate variants (including low crates, 0.6 H); server racks in three variants (dim background racks, solid cover or platform blocks at least 1.2 H with a top edge for a lamp, and conveyor cargo) and cabinets; thick cable-root junctions and hanging cable bundles; clear cooling drum; pipe elbows; workshop workbench; shuttered turret housings for ceiling and wall mounts (closed and open states); guard posts made of plain crate barricades and a field desk; freight lane markings; freight elevator and receiving-bay gallery; contracts terminal with lit card slot and a duty board; keycard-door recycling freight door with card reader and release switch (amber locked and teal open states); worker rest shelf with a short service lift.
Separation rules: Keep conveyors and crates separate from fixed collision floors. Only solid racks collide or can be stood on; background racks never damage and are never platforms. Hanging cable bundles crossing cabinets need distinct drawing layers so they never hide landings. The cooling drum is background scenery, not an implied swimming space. The terminal, card reader and freight door are separate props with matching locked and open states.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows, light pools or rim light, on a flat mid-grey (or transparent) background. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. Keep floor plates plain so a blood pool can read on them later. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, painted-in blood, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
The line above sets the visual baseline for any visual suggestion; this is a written design task, not an image request.
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 4 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, evidence files are optional finds, and each level's exit door needs its keycard. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, keycard placement, the enemy fairness caps (at most 2 shooters, 3 attackers and 1 heavy gun per screen, high cover within 3 H of every machine-gun spot, no pit edge behind a gun lane), and absence of a mini-boss in this brief.
Do not silently add weapons, enemies, enemy guns, bosses, traversal skills, unearned upgrades, conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not make protected people (harmless Sleepwalkers, the staff held in the clinic, the level 11 founder, Arcadia's executives) into targets, and do not add a radio contact or companion. Never add torture or execution on screen, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- Both new enemies (the Freight Loader and the Sentry Turret) are met alone before any mixed encounter.
- Arc Welder pickup and its practice space precede the first turret.
- Conveyor reversal cannot strand or crush the player, and no gun lane covers a belt.
- Every Sentry Turret spot has high cover or another floor within 3 H, and the two turrets never share a screen.
- The contract shows the weapon is Arcadia's own project while its signatures and target list stay hidden; the duty board shows Thornwall's orders changed to "sanitize"; Adam's retargeting is not revealed until level 9.
- The keycard comes from the A06 contracts terminal's card slot on the main route, is seen as a goal (the locked recycling freight door) before it is found, and opens only the recycling freight door.
- Thornwall's arrival is a safe, scripted moment, and nothing depends on being seen.
- Bodies stay, and blood never hides a tell, a ledge or a pickup.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects and darkness do not hide platform edges.
- Checkpoints preserve earned tools, the keycard and completed story beats without duplicating rewards.
- Art matches the text, the night palette and the approved enemy and weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
