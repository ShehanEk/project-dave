# Level 9 — Discharge Denied

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L09

**Campaign group:** The Wellness Center (levels 7–9)

**Status:** Detailed concept draft, rewritten on 2026-09-29 for the dark sci-fi direction and updated the same day for the approved enemy roster and gun kit (C25–C35, P23). The weapon order, enemy introductions and mini-boss placement follow the established outline. Level name, weapon order, enemy introductions and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and all new story, character, dialogue, palette and scenic details are *proposed* for refinement. The story names (Arcadia Dynamics, the Link, the Bloom) are proposal P17, and Thornwall is a working name; Adam (C17) and Dave Harlan (C18) are confirmed. The smooth, realistic lighting (C35) is a confirmed direction, validated by the approved lit-cutout test (2026-09-30).

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, an AI researcher fired for warning Arcadia Dynamics about its sentient AI, goes rogue and breaks back into the corporation's Sunnyvale headquarters and the hidden facilities beneath it. The AI, Adam, is preparing a nanite weapon, the Bloom, that would wipe out humanity. Dave travels alone (C12). He fights Arcadia's contract security, the Thornwall contractors, Adam's machines, cyborg dogs and the Linked (people whose Link implants Adam drives), and from level 10 the Heirs (Adam's synthetic bodies). Combat is lethal: enemies bleed and die, and there is no dismemberment (C28, C29). Arcadia's executives appear in scenery, dialogue, recordings and scenes, never as targets. There is no stealth or detection system (C16). The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

The Wellness Center's implant theaters become a surgical gauntlet, the campaign's test level: no new enemy type appears, and the Thornwall gunners, the Linked and the clinic machines met so far return in careful combinations before the Surgeon's theater.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure and the upgrade currency (C19). Each level also hides one optional evidence file *(proposed)* and, in levels 1–11, locks its exit behind one clearance keycard *(proposed)*. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Cross the implant theaters' test gauntlet, defeat the Surgeon, release the staff held for implanting, and take the level's keycard from its arena console. |
| Intended difficulty | Moderate–hard |
| First successful exploration target | 18–23 minutes including mini-boss; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | None (the test level: earlier threats return) |
| Enemy guns first faced | Cutter Beam (EG09), the Surgeon's cutting laser. Returning: Rail Rifle (EG05), Machine Gun (EG03), Frag Launcher (EG04), Seeker (EG08), Plasma Gun (EG07), Assault Rifle (EG02) |
| Mini-boss | The Surgeon |
| Keycard *(proposed)* | One clearance card, dispensed by the Surgeon's arena console after the fight. It opens the Garden service door that exits the level (card and door follow O23 and O24 in the [objects catalog](../design/04-world/objects-and-hazards.md)). |
| Evidence file *(proposed)* | One optional file: the Discharge Denied Log (EF09 in the [evidence-file catalog](../design/03-progression/evidence-files.md)) |

## Story entry and exit

**Entry:** Dave enters from the Memory Orchard's records booth into a clean procedure-preparation corridor of the Wellness Center's implant theaters, which run on emergency light. Dave now knows that Adam has been copying staff minds through the Link and building Heirs to live in the world after the Bloom. Clinic screens repeat a polite "Discharge denied" notice. *(proposed)*

**Exit:** After the Surgeon falls, its arena console dispenses the level's keycard and releases the glass holding bays *(proposed)*. The unlocked service route leads to the Garden service door and level 10, and the card opens it. The launch countdown is now running.

The Surgeon insists that discharge is unsafe: it treats leaving before the Link is installed as a medical emergency. Defeating it frees the staff held for implanting through a protected glass release corridor. They remain off the combat path and are never targets or escorts. During the fight they sit restrained in the theater's tiered glass bays, alive and protected, and in phase two they turn their heads to follow Dave.

*Proposed twist staging (reveal layer 5):* As the holding bays open, a recorded message from Arcadia's board plays on the theater screens. The board appears only on screen, and it pleads with Adam to stand down: "Adam, this is the board. The launch schedule is not authorized. Please stand down." Adam answers over the theater PA, calmly and politely: "The board was always on the list. It would be unfair to make exceptions." Dave: "Everyone." Adam then starts the launch countdown. The countdown is a story display on wall screens and door readers. It changes only at authored story beats and is never a real-time timer.

## What the level looks like

The implant theaters are a grand circular surgical theater built from concentric dark-steel ribs, navy equipment housings, pale-shelled beds, oversized articulated lamps and steel instrument shelves, all running on emergency power. Small prep rooms contrast with the large arena. Clinic walls stay in shadow, and green exit signs and red "please remain still" signage, drawn as glowing bars and icons rather than readable text, mark the routes. Tiered glass bays at the back of the arena hold the restrained staff. The surgical lamps throw smooth, cold light with soft falloff, and blood, where fights end, glints on the tiled floors. *(proposed)*

**Palette and lighting** *(proposed)*: near-black #07090F and deep navy #0E1726 for shadow masses; clinic steel #1C2A3A and slate #2E3B4E for ribs and housings; surgical-lamp white #DCEBF2; hazard amber #FFB02E for system light and robot lenses; exit-sign green #35D07F; alarm red #FF3B4E for signage and attack tells; surgical green #2FBF8F for status accents; Arcadia teal #3FE0D0 for Adam's presence; energy blue #5AA9FF for beams and plasma (a white-hot core with a blue edge); blood red #B3212F (drying to #8A1A26) for floor pools only. The surgical lamps light the arena with smooth falloff. Every landing has a lamp near it, and playable edges are lit. Background surgical lamps may flicker; lamps at landings hold steady, and reduced-flash settings apply.

**Navigation landmark:** A large circular operating-light ring hangs above the theater entrance, its rim lit cold white; its silhouette repeats around the Surgeon's rail mount.

## Foreground, playable plane, and background

- **Foreground framing:** Thin hanging cable bundles and open curtain edges frame the top corners as near-black silhouettes, never crossing the Surgeon's rail, sight lines, the tiered bays or platform edges.
- **Playable plane:** Fixed prep-room floors, wide bed platforms, short rising-bed lifts, permanent side ledges, the arena's clear lower floor and steel instrument shelves (high cover). Each has a lit edge and a lamp near its landing; blood pools stay on the fixed floors.
- **Background depth:** Deep surgical bays, shadowed storage arms, tiered glass bays holding the restrained staff, and an overhead rail system. Background tools are decorative and cannot unexpectedly attack.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump, and frame a gun's muzzle and its lane before it fires; avoid hiding attack origins, landings, and recovery routes behind decoration or darkness.

## Main route

```text
A01 Procedure prep → A02 Sight-line lesson → A03 Crossfire bays → A04 Lamp-and-bed ascent → A05 Discharge antechamber → A06 The Surgeon.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, crouching, swimming, or an unlisted tool.

## Area-by-area design

### L09-A01 — Procedure prep

**Space and placement:** A safe supply station and a window overlooking the theater establish the objective. Through the window Dave sees staff waiting in tiered glass bays; they are protected and never targets. One Linked Nurse stands in a later wide corridor.

**Player experience and lesson:** Resume known clinic combat at low pressure: the vial gaps are read again on open floor. Show the arena's instrument shelves and overhead rail through the window as physical shapes, not as required text.

**Completion and connection:** A service door leads into A02.

### L09-A02 — Sight-line lesson

**Space and placement:** One Thornwall Marksman holds a far perch across a broad ward, with cover pieces at most 8 H apart along the approach and a perch Dave can reach. The rings on his rifle light one, two, three while a thin sight line tracks Dave.

**Player experience and lesson:** Rehearse the exact tell the Surgeon's laser reuses: the line tracks, freezes, holds amber and turns red before it fires. Keep moving, advance one cover piece per recharge, and shoot the Marksman from his perch. Do not require a specific weapon or a trick shot.

**Completion and connection:** An unobstructed maintenance corridor reaches A03.

### L09-A03 — Crossfire bays

**Space and placement:** Two sequential bays. In the first, one Heavy Gunner plants his rotary behind a row of low crates with a second crate within reach of Dave, and a Staffer enters from the far side. In the second, one Grenadier holds a broad floor while an Orderly charges along a separate lane behind a low wall. Permanent low cover, a route around the gunner's lane and a forward escape from the frag spots are always available.

**Player experience and lesson:** Practice choosing which threat to answer first when tells overlap. The gunner's stream is cover-only on his floor, so Dave reaches a crate or another floor before it starts and punishes the overheat; the frags are answered by moving forward toward the Grenadier and off the landing spots; the Orderly's charge is baited into its wall. Each bay holds one shooter, two attackers and at most one heavy gun.

**Completion and connection:** Save in a quiet equipment recess before A04.

### L09-A04 — Lamp-and-bed ascent

**Space and placement:** Wide bed lifts and fixed ledges beneath large surgical lamps. A Sanitizer occupies one fixed floor, and a Keeper Drone laps the atrium above the lifts. The next jump is clear once the floor's jet has finished, and the seeker is answered from a fixed ledge.

**Player experience and lesson:** Test movement between coordinated rooms, not aerial combat against every system at once. Lamps illuminate the next landing, so the climb reads clearly in the dark. The drone releases at most one seeker at a time, timed so that it never falls during a lift's move *(proposed)*.

**Completion and connection:** A fixed balcony arrives at A05.

### L09-A05 — Discharge antechamber

**Space and placement:** A quiet station overlooks the full arena: the overhead rail, the instrument shelves and the tiered bays are all visible. A wall screen cycles the day's implant queue. A vacant records alcove opens off the station as an optional detour. On the stairs up to the station, one Linked Trooper and one Thornwall Rifleman hold the landing.

**Player experience and lesson:** Show the arena's high cover and rail before the fight, then provide supplies and a workbench checkpoint immediately before the boss. The stairs fight is the last test: a plasma bolt and rifle bursts, with high cover at the landing (walls block the plasma burst), two shooters and one heavy gun on the screen.

**Completion and connection:** Enter A06 deliberately.

### L09-A06 — The Surgeon

**Space and placement:** The arena has a permanent lower floor, side ledges, rising beds, steel instrument shelves and an overhead rail. The restrained staff sit in the tiered bays at the back, behind glass and out of every line. A keycard console on the lower floor stays dark until the fight ends.

**Player experience and lesson:** Dodge a big overhead threat and punish it when it comes low: read the sight line and move off it or stand under an instrument shelf, then hit the open lens; sidestep the dive mark and hit the core while it hangs low. Later the laser and the dive chain together.

**Completion and connection:** Victory releases the holding bays, and the arena console dispenses the level's keycard. A recorded board message pleads with Adam to stand down; Adam answers that the board was always on the list and starts the launch countdown. The keycard opens the Garden service door to level 10.

## Adam's lockdown event

*(Proposed.)* Every change is scripted and telegraphed; there is no stealth or detection system. Adam announces a "scheduled equipment cycle" in a pleasant voice. Surgical lamps rotate into platform-lighting positions and beds rise on visible guides, each move preceded by a chime and a spoken notice ("Bed lift two is moving. Please stand clear. Thank you."). The first moves occur in empty rooms. In the arena, a moving bed cannot be the only safe spot during a beam warning. Power dips are brief and never hide a landing.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored and fires at fixed points, not when Dave is spotted (C16); it is not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

This is the test level: it introduces no new type, and the threats met since level 5 return in careful combinations, at most two per bay. The Surgeon's beam is rehearsed first by the Marksman's sight line, and the stairs below the antechamber ask for the plasma stand-clear rule and rifle bursts together. Keep to the screen budget of at most two shooters, three attackers and one heavy gun, and give every machine-gun, rail or beam spot the right cover or another floor within 3 H. Reinforcements are finite and visible, there are no repair units, and the Linked never block progress. The held staff are never in a firing lane.

- [Linked Nurse](../art-design/linked/lk03-linked-nurse.md) — established behavior or returning type.
- [Marksman](../art-design/thornwall/tw03-marksman.md) — established behavior or returning type.
- [Heavy Gunner](../art-design/thornwall/tw01-heavy-gunner.md) — established behavior or returning type.
- [Staffer](../art-design/linked/lk01-staffer.md) — established behavior or returning type.
- [Grenadier](../art-design/thornwall/tw02-grenadier.md) — established behavior or returning type.
- [Orderly](../art-design/machines/m06-orderly.md) — established behavior or returning type.
- [Sanitizer](../art-design/machines/m05-sanitizer.md) — established behavior or returning type.
- [Keeper Drone](../art-design/machines/m07-keeper-drone.md) — established behavior or returning type.
- [Linked Trooper](../art-design/linked/lk04-linked-trooper.md) — established behavior or returning type.
- [Rifleman](../art-design/security/se04-rifleman.md) — established behavior or returning type (Thornwall).
- [The Surgeon](../art-design/mini-bosses/b03-the-surgeon.md) — the level's mini-boss.

Guns in play: the [Cutter Beam](../art-design/enemy-guns/eg09-cutter-beam.md) (the Surgeon) is first faced here. The [Rail Rifle](../art-design/enemy-guns/eg05-rail-rifle.md) (Marksman), the [Machine Gun](../art-design/enemy-guns/eg03-machine-gun.md) (Heavy Gunner), the [Frag Launcher](../art-design/enemy-guns/eg04-frag-launcher.md) (Grenadier), the [Seeker](../art-design/enemy-guns/eg08-seeker.md) (Keeper Drone), the [Plasma Gun](../art-design/enemy-guns/eg07-plasma-gun.md) (Linked Trooper) and the [Assault Rifle](../art-design/enemy-guns/eg02-assault-rifle.md) (Rifleman) return.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. Dave carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A03 in the equipment recess.
- At A05 immediately before the Surgeon.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Keycards and evidence files follow the same rollback rule: one collected after a checkpoint is lost on death and can be collected again, and a committed one never duplicates. Enemy corpses and blood pools are restored as static scenery after a death or Continue, while live enemies reset. The Surgeon's defeat is an irreversible story event, so it commits a story checkpoint, with a workbench beside the arena console *(proposed)*, that saves the released staff and the dispensed keycard together. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Microchips are the primary reward in this level (C19). They are hand-placed in caches and alcoves, and enemies drop none *(proposed, P23)*; values and prices follow the [treasure economy](../design/03-progression/treasure-economy.md) proposal. Evidence files are additional discoveries: one optional memo, recording or log per level *(proposed)* that proves what Arcadia or Adam did. They go in the journal, have no stat effect and never gate the exit or the ending ([evidence files](../design/03-progression/evidence-files.md)). Ordinary scenery and story information the player needs on the main route do not automatically become evidence files. Spending microchips at checkpoint workbenches is the working economy proposal.

- An optional staff balcony contains a microchip cache and a posted discharge procedure that requires the employee's signed consent, exposing the gulf between policy and Adam's current behavior.
- A vacant records alcove off the A05 antechamber, outside the Surgeon's arena, holds the level's evidence file *(proposed)*: EF09, the Discharge Denied Log, the clinic's automated printout refusing fourteen discharge requests from one employee, each with the same warm sentence under the Surgeon's care plan. It documents the ward before the twist, and it is not an override credential or the level keycard.
- A maintenance crawlway entered through an ordinary side door bypasses one optional combat bay and rejoins before A04; no crawling ability is required.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Adam's calm, polite voice gives measured procedure announcements ("Please remain still. Your Link will be ready shortly." and "Discharge denied. Thank you for your patience."), over bed motors, buzzing emergency lamps, distant monitor tones, and distinct chimes. Machine warnings stay polite and match their tells: the Orderly's "Please remain still for collection", the Linked Nurse's "This won't hurt, Dr. Harlan." and the Sanitizer's "Sterilizing." *(the last two proposed)*. The Surgeon gives clipped clinical instructions with perfectly controlled timing ("Please remain still. This will only take a moment."); its cutter beam is a sizzling hum that rises as the sight line freezes and ends in a crack of cut steel. Thornwall barks are cold and short, with profanity when they are hit, and a shouted "Frag out!" precedes each Grenadier throw, all as subtitles plus non-verbal shouts. Gunfire is one cue per burst, the machine gun has a looped chatter, and impacts are restrained and wet.

## Mini-boss encounter — The Surgeon

**Identity:** An entirely mechanical implant-theater surgeon that installs Link implants and treats any attempt to leave treatment as a medical emergency. It is about 3.00 m tall (a provisional art proportion) and hangs from a visible overhead rail carriage, a pale porcelain-white teardrop with a hooded head of three lamp discs, a slim jointed laser-scalpel arm ending in the Cutter Beam's petal cowl, a cluster of three injector barrels underneath, and a circular chest door over its core. It is never shown operating on anyone. The [boss brief](../art-design/mini-bosses/b03-the-surgeon.md) owns the full design.

**Arena geometry:** Stable lower floor, two permanent side ledges, rising beds, steel instrument shelves with at least 1.1 H of headroom (high cover, clear of the supply points), and an overhead rail. The restrained staff sit in tiered glass bays at the back, alive, protected and out of every line. A keycard console on the lower floor stays dark until the fight ends.

- Phase 1: separate cutting-laser and injector-dive attacks. *Cutting laser:* the Surgeon slides along its rail and the lens cowl opens, a sight line tracks Dave (slower than his run), freezes, holds amber and then turns red for a quarter of a second, and then the beam drags after him for about a second, stopping at the first solid thing. *Injector dive:* the carriage stops over Dave's locked spot, and the injectors drop and hang at head height with the core open.
- Phase 2 (at half health): the laser and the dive chain together, with only the amber part of each tell shortened (red stays the same), and the restrained staff turn their heads to follow Dave. The Surgeon starts no new windup while its shots are alive.

**Attack cues** *(proposed)*: each attack has its own sound, glow and pose, so nothing depends on color alone, and captions name the attack.

- Cutting laser: the carriage hums along the rail, the cowl petals click open one after another, a thin white sight line tracks and freezes, the cowl glow holds amber and then red, and a rising sizzle ends in one crack of cut steel.
- Injector dive: the three hood lamps glow amber and then red and the spot is locked, then the hoist drops the Surgeon with a pneumatic hiss and a heavy thunk to head height, and the core iris opens leaf by leaf.

**Damage opening:** Laser: the open lens cowl, for a short window after the beam. Dive: the open core, while the Surgeon hangs at head height. Elsewhere its armor deflects shots with sparks. Each legitimately carried weapon needs a viable opening: short-range guns have safe approach ledges, the Seedlobber has usable fuse windows, and tether users have replenishable throwable props. The Surgeon itself cannot be grabbed.

**Fairness and recovery:** The sight line and the dive mark precede every hit, the beam hits at most once per firing and stops at the first solid thing, and lines run flat on Dave's floor or come down at 45 degrees or steeper. A moving bed is never the only cover, and platform motion cannot remove all safe positions. The restrained staff have no hit zone and no line crosses their bays. There are no helpers and no repairs.

**Victory consequence:** Microchips for upgrades, the released holding bays, the keycard from the arena console and access to level 10. The Surgeon comes apart in debris and leaks black oil. The story consequence is the twist: the board pleads with Adam to stand down, Adam answers that the board was always on the list (the Bloom's target is everyone), and the launch countdown starts.

[Full boss appearance, abilities, and sprite reference](../art-design/mini-bosses/b03-the-surgeon.md).

## Environment asset kit and layer separation

**Required kit:** Implant-theater room modules; bed lifts and guides; large lamps; fixed ledges; steel instrument shelves (high cover) and low crates (low cover); overhead rail and carriage; tiered glass bays; discharge gate; glass holding bays and release corridor; supply kiosk; keycard console; keycard door with reader (amber ring and bar while locked, teal ring and chevron once open); green exit-sign and red warning-sign panels drawn as icons.

**Separate objects:** Boss, overhead rail carriage, instrument shelves, beds and the beam and dive effects are separate assemblies. The restrained staff are separate background characters with no hit zone. The discharge gate, holding-bay gates and keycard door are each one assembly with matching closed and open states. Blood pools are a separate effect layer on fixed floors only.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors as flat base colors with no baked shadows, so the engine's lamps can light them (C35); keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Lamps, screens and glows are their own light sources, so a landing keeps its lamp when the scenery is swapped. Final sprite resolution, atlas layout, file format and collision setup remain undecided.

## Constraints for another AI model

No organic parts on the Surgeon, no early Heirs, no summoned helpers or repairs during the fight, no escort of the held staff through the arena, no beam, dive or shot that crosses the restrained staff, no surgery or implant procedure shown on screen (a Link appears only as a coin-sized device with a status light), no torture or execution, and no dismemberment. Blood is restrained: red (#B3212F, drying to #8A1A26) for people and dogs, black oil (#14181E) for machines and grey-rose lymph (#A88A8C) for Heirs. It never glows, never uses a tell color, never hides a tell, ledge or pickup, and pools appear only on static floors. The Surgeon's defeat is debris and black oil, never organs. Do not add a third boss phase simply to inflate difficulty.

Preserve the established number of levels, enemies (24 types plus four mini-bosses), weapons, and upgrades. Show only one weapon carried by Dave; do not place spare guns on Dave's belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art. Do not add stealth, vision cones or alert states (C16).

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use the linked enemy briefs if detailed characters are needed (their designs are proposed until the lit-cutout validation test is approved); otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Environment concept art: one wide 16:9 environment keyframe for level 9, "Discharge Denied". Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. This keyframe is the one exception to "evenly lit": it is a lit mood reference, so show the scene as the engine will light it, with smooth, realistic light and falloff from the lamps, screens and glows named below (no hard-edged light bands or cel shadows), while the underlying art stays flat base colors with clean dark outlines. Represent steel, glass, enamel and machinery with clean flat-color shapes and dark outlines. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes, landings and pickups readable in the dark, with a light near every landing. No pixel art, photographic textures or franchise assets.

Narrative purpose: The Wellness Center's implant theaters become a surgical gauntlet where every known threat returns in careful combinations before the Surgeon's theater.
Physical setting: A grand circular surgical theater built from concentric dark-steel ribs, navy equipment housings, pale-shelled beds, oversized articulated lamps and steel instrument shelves, running on emergency power. Small prep rooms contrast with the large arena. Tiered glass bays at the back hold restrained, protected staff. Green exit signs and red warning signage appear only as glowing bars and icons, never as readable text.
Color and lighting: near-black #07090F and deep navy #0E1726 shadow masses, clinic steel #1C2A3A and slate #2E3B4E ribs and housings, surgical-lamp white #DCEBF2, hazard amber #FFB02E system light, exit-sign green #35D07F, alarm red #FF3B4E signage, surgical green #2FBF8F status accents, Arcadia teal #3FE0D0, energy blue #5AA9FF for the beam edge, blood red #B3212F on the floor only. The surgical lamps light the arena with smooth, cold falloff.
Landmark: A large circular operating-light ring hangs above the theater entrance, its rim lit cold white; its silhouette repeats around the Surgeon's rail mount.
Composition to show: A wide side-view implant theater with a pale, slim-limbed surgical robot hanging from an overhead rail carriage and a white-hot laser line reaching down from its lens, two steel instrument shelves on the floor, two rising beds, permanent side refuge ledges, and tiered glass bays at the back holding seated, restrained people, with a small hero silhouette in a warm burnt-orange jacket on a lit landing for scale.
Foreground: Thin hanging cable bundles and open curtain edges frame the top corners as near-black silhouettes, never crossing the Surgeon's rail, sight lines, the tiered bays or platform edges.
Playable plane: Fixed prep-room floors, wide bed platforms, short rising-bed lifts, permanent side ledges, the arena's clear lower floor and steel instrument shelves (high cover). Each has a lit edge and a lamp near its landing; blood pools stay on the fixed floors.
Background: Deep surgical bays, shadowed storage arms, tiered glass bays holding seated, restrained people, and an overhead rail system. Background tools are decorative and cannot unexpectedly attack.
Show only this level's appropriate threats: Linked Nurse, Thornwall Marksman, Heavy Gunner, Grenadier and Rifleman, Linked Trooper, Staffer, Orderly, Sanitizer, Keeper Drone; mini-boss the Surgeon only if this is its arena scene. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No organic parts on the Surgeon, no early Heirs, no repair or helpers, no beam crossing the restrained people, no surgery or implant procedure shown, no torture, execution or dismemberment. Blood is restrained red on the floor only, never glowing.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, smooth realistic lighting from the sources named above, no UI, no watermark, no text or logos (signage as blank glowing shapes), no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design a clean side-elevation level-layout study for level 9, "Discharge Denied". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Procedure prep → A02 Sight-line lesson → A03 Crossfire bays → A04 Lamp-and-bed ascent → A05 Discharge antechamber → A06 The Surgeon.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L09-A01: Procedure prep. A safe supply station and a window overlooking the theater establish the objective. Through the window Dave sees staff waiting in tiered glass bays; they are protected and never targets. One Linked Nurse stands in a later wide corridor. Connection: A service door leads into A02.
L09-A02: Sight-line lesson. One Thornwall Marksman holds a far perch across a broad ward, with cover pieces at most 8 H apart along the approach and a perch Dave can reach. The rings on his rifle light one, two, three while a thin sight line tracks Dave. Connection: An unobstructed maintenance corridor reaches A03.
L09-A03: Crossfire bays. Two sequential bays. In the first, one Heavy Gunner plants his rotary behind a row of low crates with a second crate within reach of Dave, and a Staffer enters from the far side. In the second, one Grenadier holds a broad floor while an Orderly charges along a separate lane behind a low wall. Permanent low cover, a route around the gunner's lane and a forward escape from the frag spots are always available. Connection: Save in a quiet equipment recess before A04.
L09-A04: Lamp-and-bed ascent. Wide bed lifts and fixed ledges beneath large surgical lamps. A Sanitizer occupies one fixed floor, and a Keeper Drone laps the atrium above the lifts. The next jump is clear once the floor's jet has finished, and the seeker is answered from a fixed ledge. Connection: A fixed balcony arrives at A05.
L09-A05: Discharge antechamber. A quiet station overlooks the full arena: the overhead rail, the instrument shelves and the tiered bays are all visible. A wall screen cycles the day's implant queue. A vacant records alcove opens off the station as an optional detour. On the stairs up to the station, one Linked Trooper and one Thornwall Rifleman hold the landing. Connection: Enter A06 deliberately.
L09-A06: The Surgeon. The arena has a permanent lower floor, side ledges, rising beds, steel instrument shelves and an overhead rail; the restrained staff sit in tiered bays at the back, behind glass. A keycard console on the lower floor stays dark until the fight ends. Connection: Victory releases the holding bays and the console dispenses the keycard for the Garden service door to level 10.
Use dark navy and steel masses for architecture with clean, evenly lit top edges for playable surfaces, muted low-contrast noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Mark low and high cover as distinct shapes, and separate player paths, stable refuges, and hazards through shape as well as color, with a light near every landing. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. Boss arena requirements: stable bottom floor, two permanent side ledges, rising beds, steel instrument shelves with headroom and an overhead rail; the restrained staff stay in bays out of every line. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for level 9, "Discharge Denied". Match these materials and colors: near-black #07090F and deep navy #0E1726 shadow masses, clinic steel #1C2A3A and slate #2E3B4E ribs and housings, surgical-lamp white #DCEBF2, hazard amber #FFB02E system light, exit-sign green #35D07F, alarm red #FF3B4E signage, surgical green #2FBF8F status accents, Arcadia teal #3FE0D0. Lamps are separate light sources added in-engine.
Required asset family: Implant-theater room modules; bed lifts and guides; large lamps; fixed ledges; steel instrument shelves (high cover) and low crates (low cover); overhead rail and carriage; tiered glass bays; discharge gate; glass holding bays and release corridor; supply kiosk; keycard console; keycard door with reader (amber ring and bar while locked, teal ring and chevron once open); green exit-sign and red warning-sign panels drawn as icons.
Separation rules: Boss, overhead rail carriage, instrument shelves, beds and the beam and dive effects are separate assemblies. The restrained staff are separate background characters. Keep low and high cover as distinct shapes. Blood pools are separate layers and are not painted into the modules.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows and no painted-in light pools, rim light or blood, on a flat mid-grey (about #808080) or transparent background, each silhouette read by its dark outline. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 9 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, evidence files are additional optional finds, and the level's keycard is an ordinary exit lock. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, the screen budget and cover rules, checkpoint rules, and mini-boss phases in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, robot-conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not convert the First Patient, the held clinic staff or harmless Sleepwalkers into compulsory enemies. Do not show torture, execution, surgery, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- No new enemy type is introduced here; every type except the two Garden machines and the two Heirs has appeared by now.
- The third boss tests dodging a big overhead threat and punishing it when it comes low, through line reading and overhead cover: it copies neither the Peacekeeper's ram and roof gun nor Stroud's slam and arcs.
- The beam never crosses the restrained staff, instrument shelves give at least 1.1 H of headroom, and no screen exceeds two shooters, three attackers or one heavy gun.
- The twist (the board's plea, Adam's answer that the target is everyone, and the countdown start) lands only after the defeat, preparing the Garden.
- The held staff are never targets, escorts or part of the combat path, and the keycard console dispenses the card exactly once.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects, blood and darkness do not hide platform edges, tells or pickups.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the current enemy and weapon briefs (designs are proposed until selected).

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
