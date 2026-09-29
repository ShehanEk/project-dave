# Level 3 — Parade of Progress

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L03

**Campaign group:** Sunnyvale after dark

**Status:** Detailed concept draft, updated on 2026-09-29 for the approved enemy roster (C25–C35). The mini-boss is now the Peacekeeper (C31), and the new enemy types are the Riot Officer and the Rifleman of Arcadia's Response Team. Names, weapon order, enemy introductions and mini-boss placement follow the established outline, and the story beats follow the concept document's level table. Layouts, encounter quantities, duration targets, checkpoints, and every new name, prop and scenic detail are *proposed* for refinement. The enemy art direction (C35) is confirmed direction, validated: the user approved the lit Night Guard test on 2026-09-30.

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, a fired AI researcher who went rogue, works alone through the Sunnyvale campus of Arcadia Dynamics *(proposed name)* at night to expose Adam, Arcadia's sentient AI, which is secretly building a weapon to wipe out humanity. Dave fights human enemies (Arcadia Security's guards and, later, the contractors of Thornwall), the Linked (staff whose Link implants Adam drives), Adam's machines and cyborg dogs (C25, C30). Combat is lethal: every enemy bleeds according to what it is made of and stays where it falls (C28, C29). The Heirs first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

Arcadia's product showcase hall runs its nightly Parade of Progress for an empty audience. The exhibit floats become a moving obstacle course, Arcadia's Response Team moves in with riot shields and rifles, and the show ends with its star exhibit, a driverless crowd-control truck, dispersing Dave as an unauthorized assembly.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure (C19). Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location. Proposed additions: one optional evidence file per level, and one keycard per level that opens the exit door. There is no stealth or detection system (C16).

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Ride and cross the Parade of Progress route, learn the new shield and rifle patterns, then defeat the Peacekeeper, take the level's keycard from the arena console and use the service lift to the Rootworks. |
| Intended difficulty | Easy; first boss test |
| First successful exploration target | 14–18 minutes including mini-boss; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom |
| New enemy types | Riot Officer, Rifleman (Arcadia's Response Team) |
| Enemy guns first faced | Assault rifle, AR-7 "Warrant" (EG02), carried by the Riflemen; machine gun, HG-40 "Thresher" (EG03), the Peacekeeper's roof gun |
| Mini-boss | The Peacekeeper |
| Keycard *(proposed)* | Level 3 clearance card, granted by the arena console after the Peacekeeper is disabled. It opens the lift door under the Arcadia arch. |

## Story entry and exit

**Entry:** Dave enters through a one-way service door behind the showcase hall's staging bay. The Parade of Progress, Arcadia's nightly exhibit route, is running for an empty hall, and the Response Team, Arcadia's tactical security, has been called to it. The only service lift down to the Rootworks is at the terminus of the route, in the arena where the Peacekeeper, the parade's star exhibit, waits.

**Exit:** The lift descends from the terminus, through a keycard-locked lift door under the Arcadia arch, into level 4's utility freight corridor and receiving bay. The campus is the front; the real Arcadia is underneath (scene SC03 in the [story scenes](../design/05-presentation/story-scenes.md)).

Adam describes Dave, over the hall's speakers, as an unauthorized assembly obstructing a scheduled event, and dispatches the Peacekeeper to disperse it. The Parade keeps looping in the background after the boss falls, emphasizing Adam's persistent routines, and the Peacekeeper's export sales reel keeps playing on its side screen: Arcadia sells this machine to governments. Adam's lines are *proposed*. At the start: "Welcome to the Parade of Progress. Please keep clear of the moving exhibits." At the arena, dispatching the machine: "Unauthorized assembly detected." Before each ram, the truck's own loudspeaker carries Arcadia's calm dispersal notice: "Please clear the lane. Thank you." After the fight: "The Parade of Progress has concluded. Thank you for attending." Beyond that notice the Peacekeeper never speaks; it only sirens, revs, chatters and strains. Dave's reply is short and dry: "That's a crowd of one." The Response Team barks hard, scared and angry, as subtitles plus non-verbal shouts: the Riot Officer's "Drop the gun!" and a Rifleman's "Response Team, moving. Harlan is armed." *(proposed)*.

## What the level looks like

Slow exhibit floats on floor tracks carry chunky, life-size displays of Arcadia's products through a vast showcase hall: a mock climate tower, smiling service mascots, a "Safe Campus" tableau with a patrol rover and a security drone, and, in the last stretch, glass cases of Arcadia Defense products under soft spotlights, all under striped canopies and inflated-looking metal balloons. The hall is dark between spotlit exhibits, and each spotlight pool holds one display. Floats have visible powered wheel bases rather than levitating decorations. A giant Arcadia arch over the terminus hides a service lift beneath it, revealed after the fight. Side screens along the route loop a cheerful export sales reel for the Peacekeeper, showing only the truck, bollards and dummy targets, never people.

**Palette and lighting:** Near-black hall #07090F under a navy #0E1726 ceiling; steel #1C2A3A float chassis and slate #2E3B4E deck plates; cold spotlight white #D8E6F0 *(proposed)* on each exhibit; Arcadia teal #3FE0D0 arch ring, screens and signage; hazard amber #FFB02E float lamps and firing apertures; alarm red #FF3B4E attack tells; microchip gold #FFD166 pickups. Light is smooth, realistic engine light cast by the spotlights, screens and lamps in the scene (C35): there is a light near every landing, every light source is visible in the scene, every float edge, refuge and attack origin carries its own light, and no light pool is painted into the scenery. The hall is dark between exhibits, but darkness never hides a tell or a landing. Blood (#B3212F, drying to #8A1A26) reads on the deck plates; machine oil is #14181E with a #46566A sheen rim. Danger comes from people and machinery.

**Navigation landmark:** A giant Arcadia arch, an original teal arch-and-leaf emblem *(proposed)* ringed in light, with a closed floor hatch beneath it, visible from the staging yard and repeatedly along the route. The Peacekeeper's curved lightbar echoes the arch's shape.

## Foreground, playable plane, and background

- **Foreground framing:** Sparse bunting, hanging holographic banners and low planter edges frame the screen. Suspend banners high enough not to cover airborne targets, jump trajectories or blood on the floor.
- **Playable plane:** Stationary viewing steps and stands, slow float decks, connecting service platforms, and a wide terminal plaza, each with a lit top edge. Show wheel clearance beneath moving float decks. Blood pools sit on the static floors only, never on a float deck.
- **Background depth:** Additional parade lanes, looping holographic crowd silhouettes cheering at empty seats, facade sets of an idealized Arcadia city, and the hall's dark ceiling. Background floats cannot be entered or mistaken for active platforms.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration or darkness.

## Main route

```text
A01 Staging yard → A02 Viewing stand → A03 Security checkpoint → A04 Parade crossing → A05 Terminus refuge → A06 Peacekeeper arena.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L03-A01 — Staging yard

**Space and placement:** Board a low stationary exhibit float in the hall's indoor staging yard, then cross to a second float moving slowly along a short visible track. A fixed service ledge runs below the practice jump. Adam's PA announces the first float movement before it starts. Open riot-shield racks and rifle cases in the far corner show where the Response Team has just deployed (background props only).

**Player experience and lesson:** Teach movement relative to a float without attacking enemies or full-screen forced scrolling.

**Completion and connection:** Step onto a stationary viewing platform at A02.

### L03-A02 — Viewing stand

**Space and placement:** One Rifleman of the Response Team holds a wide stationary viewing stand at the far end of a lane of low crates (0.6 H). A float moves slowly along its own track beside the lane as scenery, never as moving cover and never carrying the shooter. The lane's rear is a wall, not an open pit edge.

**Player experience and lesson:** Teach the rifle's rhythm alone. The Rifleman shoulders the carbine as its lamp goes amber, then red, then fires two flat 3-round bursts about a second apart, then swaps magazines for a moment, rooted. Dave can jump one burst at a time with a ground beat between, stand behind a low crate (it blocks all same-floor fire, and Dave can shoot over it), or close in during the magazine swap. He turns to face Dave only between bursts and never aims at an airborne Dave.

**Completion and connection:** A stationary ramp leads into A03.

### L03-A03 — Security checkpoint

**Space and placement:** A single Riot Officer blocks a flat visitor-screening lane in the exhibit hall. A low overpass allows an obvious route behind it.

**Player experience and lesson:** Demonstrate front shielding, the shield strobe going amber, then red with the shout "Drop the gun!", the one-step bash, and the exposed side and back. His shield blocks Dave's bolts from the front. Bait the bash and shoot while the shield is down, jump-shoot over it, or flank him by the overpass. No second enemy interrupts the first observation.

**Completion and connection:** The back of the lane reconnects to the main float route at A04.

### L03-A04 — Parade crossing

**Space and placement:** Two slow floats move along offset sections, with stationary refuges between. Place one Staffer at a routine on the first stationary landing. On the far stationary landing, beyond the second float, place a Riot Officer with a Rifleman behind him and a low crate beside them. The two groups are separated by camera space, and exhibit panels keep the far pair's lane closed until Dave stands on the last stationary refuge, so no gun lane covers a float ride. The floats carry no enemies.

**Player experience and lesson:** Combine timing and target selection without attacking from outside the screen. The officer's shield blocks Dave's bolts but the Rifleman's rounds pass through him, so Dave must flank, bait the bash, jump-shoot over the shield or use the crate. That is one shooter and one attacker on the far landing. The Staffer never blocks the way: Dave can jump past it. A missed jump falls to a service path that rejoins the last refuge.

**Completion and connection:** Climb fixed steps to A05.

### L03-A05 — Terminus refuge

**Space and placement:** A maintenance kiosk, supplies, and the visible closed arena gate sit beneath the Arcadia arch. A sealed safety window shows a small looping "how it works" exhibit: the Peacekeeper's sales reel, with the truck ramming a bollard line and its roof gun chattering at dummy targets.

**Player experience and lesson:** Establish the bollards and the concrete planter pillars as the boss's arena furniture, then save immediately before the fight at the kiosk, the level's boss-preparation workbench checkpoint *(proposed)*. The arch and the lift door's amber-ringed card reader are visible above the arena gate, and were glimpsed from the staging yard, so the locked exit and the empty keycard indicator are seen before the card is earned.

**Completion and connection:** Enter A06 deliberately via the plaza gate.

### L03-A06 — Peacekeeper arena

**Space and placement:** A broad indoor demonstration plaza, the hall's "Safe Streets of Tomorrow" exhibit *(proposed)*, has a ground lane between two reinforced bollard lines, raised side walkways along both edges with concrete planter pillars standing on them, and steps that connect each walkway back to the lane at both ends. Reserve the ground lane for the ram. A side screen loops the sales reel. A parade control console *(proposed)*, a broad teal screen with a hand-height control, stands dark at the foot of the arch.

**Player experience and lesson:** Read the tell, dodge, punish the stall: read the siren and the lightbar, leave the lane or hold a jump onto a walkway to clear the ram, then shoot the open hatch during the stall. Against the roof gun, keep running along a walkway or stand behind a planter pillar; the stream's aim creeps after Dave, slower than he runs. The roof gun and the ram occur separately in phase 1.

**Completion and connection:** Victory wakes the console, which grants the level's keycard; Adam may speak through its screen. The card opens the floor hatch and the noncombat maintenance lift to level 4.

## Adam's lockdown event

After the Peacekeeper falls, Adam closes the show with a polite announcement. The finishing arch folds its decorative panels outward to reveal service lift machinery, the show lights dim except along the lift route, and the exhibits keep looping for an empty hall. The lift door is the level's keycard door: an amber ring and bar symbol while locked, a teal ring and chevron once the card opens it. This is scripted and telegraphed: a chime and a caption precede the panels' movement, the panels move visibly before the lift is usable, and the console prompt names the next step. During the fight the plaza layout stays fixed, so the player learns the boss rather than an arena transformation. There is no stealth or detection system (C16): spotlights are lighting only, never vision cones.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced lockdown change. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

The Rifleman and the Riot Officer are introduced independently, in A02 and A03. Later combine only familiar behaviors on stable landings: the Riot Officer screens the Rifleman. Returning types (Night Guards with their Hounds, Sidearm Guards, Patrol Rovers, Security Drones and Staffers) may hold optional side lanes, but never an introduction encounter or the arena. No ordinary enemies spawn during the Peacekeeper's fight.

The rifle fires 3-round bursts about 0.08 s apart, two bursts per volley at this level, then a rooted magazine swap. Rounds fly flat at 0.5 H with a small fixed jitter: a held jump clears them, a low crate blocks them, and a Rifleman never aims at an airborne Dave. The Riot Officer's shield blocks Dave's bolts from the front, but enemy shots pass through enemies, so his shield screens a Rifleman from Dave and not Dave from the Rifleman. Every tell reads through the reserved colors, always amber first and red for the last 0.25 s: the carbine's lamp, the shield's strobe, the Peacekeeper's lightbar and rotary collar.

Combat is lethal (C28) and visible (C29). Riflemen, Riot Officers and Staffers bleed red (a Staffer also throws white sparks at the stapled port), and bodies stay where they fell, restored as static corpses after a death or a Continue. A dead Rifleman's carbine falls as a prop, never a pickup. The Peacekeeper is a machine: it sparks, leaks black oil and, when disabled, bursts into debris parts that settle clear of the lane, the console and the lift (C35). Blood pools sit on static floors only and never hide a tell, a ledge or a pickup. Keep landings, pickups and the arena console clear of likely body positions. A corpse is not cover.

Placement rules used here (P23): at most 2 shooters, 3 attackers and 1 heavy gun per screen (this level has at most one shooter on a screen outside the arena, and the only heavy gun is the boss's roof gun), low crates (0.6 H) beside every rifle lane, high cover (a pillar of at least 1.2 H) for the roof gun, no pit edge within 1.5 H behind Dave's standing spots in a gun lane, the camera shows a gun's muzzle and its lane before it fires, and the Linked never block progress. The rules are owned by [encounter and boss fairness](../design/04-world/encounter-and-boss-fairness.md).

- [Night Guard](../art-design/security/se01-night-guard.md) — established behavior or returning type (also the Hound's handler).
- [Sidearm Guard](../art-design/security/se02-sidearm-guard.md) — established behavior or returning type.
- [Staffer](../art-design/linked/lk01-staffer.md) — established behavior or returning type.
- [Hound](../art-design/hounds/k01-hound.md) — established behavior or returning type, with a Night Guard handler (its last Act 1 level).
- [Patrol Rover](../art-design/machines/m01-patrol-rover.md) — established behavior or returning type.
- [Security Drone](../art-design/machines/m02-security-drone.md) — established behavior or returning type.
- [Riot Officer](../art-design/security/se03-riot-officer.md) — first introduction in this level.
- [Rifleman](../art-design/security/se04-rifleman.md) — first introduction in this level (Arcadia's Response Team).
- [Assault rifle, AR-7 "Warrant" (EG02)](../art-design/enemy-guns/eg02-assault-rifle.md) — first faced in this level.
- [Machine gun, HG-40 "Thresher" (EG03)](../art-design/enemy-guns/eg03-machine-gun.md) — the Peacekeeper's roof gun, first faced in this level.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry, the level's workbench checkpoint *(proposed)*.
- After A03 on a stationary viewing platform.
- At A05 immediately before the boss, a boss-preparation workbench checkpoint; boss retries restore the arena, supplies, and the Peacekeeper's first phase.
- After the Peacekeeper is disabled, as a story checkpoint that commits at once.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently, and bodies of enemies that were already killed are restored as static corpses; swapped weapons, collected microchips and the keycard must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

*Proposed:* defeating the Peacekeeper commits at once, so a later death never repeats the fight, and the console is then ready to grant the card. The keycard comes only from the console, never from a drop, and a card taken after the post-fight checkpoint returns to the console on death. The arena is empty of enemies after victory, so nothing else needs retrying.

## Optional exploration and rewards

Microchips are the primary reward in this level. They are hand-placed in caches and alcoves; enemies drop nothing *(proposed)*. Evidence files are additional discoveries: one optional memo, recording or log per level that proves what Arcadia or Adam did. They go in the journal, have no stat effect and never gate the ending; the [evidence-file catalog](../design/03-progression/evidence-files.md) owns the final list, and how they are presented remains open. Ordinary scenery and mandatory story beats do not automatically become evidence files. Spending microchips at workbenches is the working economy proposal.

- A small balcony microchip cache reached from the slow float timing route in A04.
- A VIP viewing niche above the parade route, reached by ordinary jumps from the last A04 stationary refuge and so before the arena, holds the level's evidence file: EF03, the Peacekeeper Export Contract, a signed order page in a clear sleeve with a red "EXPORT" tab and a clipped price sheet. The screen beside the niche loops the Peacekeeper's sales reel. The order is Arcadia's sale of forty Peacekeeper crowd-control trucks to three governments, with the roof rotary gun priced as a "perimeter denial" option. An attached demo agenda has Adam presenting its climate, grid and logistics work and offering to "assist the delegation's decisions", with deployment scheduling delegated to Adam. It shows what Arcadia sells and foreshadows Adam's reach only: it does not name the Bloom, and the Peacekeeper does not need it to activate. The file is not the level's keycard.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

A slow, slightly off-key brass-and-synth parade march plays to an empty hall, over float motor rumble, hall reverb, distant unanswered alarms, and a low server hum from racks in the ceiling. Staffers carry implant chirps, and Adam's warm, reverberant PA voice announces each stage of the show, in the manner of an upbeat showcase announcer. The Response Team brings boots, shield plants and hard barks (subtitles plus non-verbal shouts). The rifle is one "brrt" cue per burst, then a magazine clatter; the Riot Officer's shield strobe and thunk carry his tell. The truck's loudspeaker carries an unmistakable spoken warning before each ram, under a straining engine, while the rest of the Peacekeeper is siren, wheel-spin, a rising rotary whine, a held chatter loop on its own audio player, and a steam hiss at overheat. The sales reel's cheerful voice-over (selling "riot management" and "perimeter denial", *proposed*) keeps looping. Quiet the music slightly during attack cues, and keep hit sounds to restrained wet impacts (C28).

## Mini-boss encounter — the Peacekeeper

**Identity:** Arcadia's driverless crowd-control truck and the star exhibit of the Parade of Progress: a heavy armored vehicle with a ram plow and a roof-mounted rotary machine gun, with no driver and no crew. It is fully mechanical. Arcadia sells it abroad, and its export sales reel still loops on a side screen. Adam has dispatched it against Dave as an unauthorized assembly. Dimensions, wheels and design are in the boss brief.

**Arena geometry:** One ground ram lane between two reinforced bollard lines, raised side walkways along both edges for running and jumping clear, concrete planter pillars at least 1.2 H tall standing on the walkways as high cover, and steps that connect the walkways back into the lane. The roof gun fires from 1.5 H up, so only high cover (a pillar, or an overhang with at least 1.1 H of headroom) protects Dave from it; a low crate does not. No gun lane has a pit edge within 1.5 H behind Dave's standing spots.

- Phase 1, ram: the siren sounds, the lightbar goes amber, then red, and the wheels spin for about a second before it rams its whole lane into the bollards (2 damage if it hits Dave) and stalls for about 3 s with its hatch open.
- Phase 1, roof gun: it reverses to the center and the rotary spins up, amber, then red, then a stream of about 1.5 s whose aim point creeps after Dave at a speed well under his run. Keep running along a walkway or stand behind a planter pillar. The overheat then opens the hatch for about 1.8 s.
- Phase 2 (at half health): the stream runs straight into a ram, and the amber part of each tell shortens; red stays 0.25 s. Keep the same arena and body; no helpers, and no new windup while its shots are alive.

**Damage opening:** The open hatch, after a ram stall or after the roof gun's overheat. Either available weapon can deal damage from an unobstructed position; at least one stable position (a side walkway) has a direct line to it after each opening.

**Fairness and recovery:** The ram lane and the bollard endpoints are visible before motion. The ram covers the whole lane, so Dave leaves the lane or holds a jump onto a walkway, and every roof-gun position has a pillar or another floor within 3 H. Do not stack the roof gun with a ram except in phase 2's chain, where the stream ends before the ram's siren starts.

**Victory consequence:** A hand-placed microchip cache opens in the arena (kills drop nothing), the level's keycard comes from the arena console *(proposed)*, and the Rootworks lift opens; no sixth weapon or automatic unplanned upgrade. Victory commits a story checkpoint at once. The console stays dark and locked during the fight. When the Peacekeeper is disabled (its lightbar dies and it bursts into debris parts that settle clear of the lane, the console and the lift) the console lights teal and its card slot opens; the keycard then opens the lift door under the arch. The sales reel keeps looping.

[Full boss appearance, abilities, and sprite reference](../art-design/mini-bosses/b01-the-peacekeeper.md).

## Environment asset kit and layer separation

**Required kit:** Float deck and wheel chassis; canopy supports; exhibit displays (mock climate tower, service mascots, a "Safe Campus" tableau with a patrol rover and a security drone, glass cases of Arcadia Defense products); viewing steps and viewing stands; barrier modules; low crates (0.6 H); concrete planter pillars (at least 1.2 H); reinforced bollard lines; service refuge platforms; Arcadia arch; folding arch panels; floor lift hatch and keycard-door lift door with card reader (amber locked and teal open states); parade control console (dark and awake states); visitor-screening lane props; Response Team shield racks and rifle cases (background); sales-reel screens (looping, abstract imagery only); VIP viewing niche with the export-contract memo pickup.

**Separate objects:** Floats, wheels, rideable decks, and track motion remain distinct. The Peacekeeper is a separate boss asset; bollard lines and planter pillars have clear collision faces and readable impact states. The lift door, console and folding arch panels are separate props with matching closed and open states. Floor tops stay plain enough that a blood pool reads on them.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers; spotlights, screens and banners' light are engine lights, and blood lives on the effects layer. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No floor collapse, summon phase, new weapon, Heirs, Thornwall contractors, or mandatory tether. Do not make the player jump over the full boss height from flat ground without a designed raised escape route. No stealth: spotlights and holographic banners are scenery, never detection cones or alert states (C16). The Peacekeeper is driverless, with no person in or under it, and the sales reel shows only bollards and dummy targets, never people. Nothing here shows torture, execution, sexual violence, children, dismemberment, or blood and bodies painted into the scenery (blood is added in the engine).

Preserve the established number of levels, the 24-type enemy roster (C31), weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art; Dave has no final design yet, so keep Dave a small silhouette in a warm burnt-orange jacket.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
This is environment concept art and a lighting reference. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Paint steel, canvas, glass and machinery as clean, flat base colors with dark outlines and simple material marks so they can be split into modules. Because this is a mood reference, show the hall as smooth, realistic light from the spotlights, screens and lamps in the scene, with a light near every landing; the final scenery is painted without baked light pools or shadows, and the engine adds the lighting. Preserve the level-specific palette and mood, and keep playable surfaces, enemies, attack lanes, microchips and landings clear. No photorealism, glossy chrome, pixel art or franchise assets. Blood appears only as a few restrained floor stains (#B3212F, drying to #8A1A26), never on the architecture, and there are no bodies; the final scenery carries none, because the engine adds blood.

Create one wide 16:9 environment keyframe for level 3, "Parade of Progress".
Narrative purpose: Arcadia's product showcase hall runs its nightly Parade of Progress for an empty audience. The exhibit floats become a moving obstacle course, Arcadia's Response Team moves in with riot shields and rifles, and the show ends with its star exhibit, a driverless crowd-control truck, dispersing Dave as an unauthorized assembly.
Physical setting: Slow exhibit floats on floor tracks carry chunky, life-size displays of Arcadia's products through a vast showcase hall: a mock climate tower, smiling service mascots, and glass cases of defense products, all under striped canopies and inflated-looking metal balloons. The hall is dark between spotlit exhibits, and each spotlight pool holds one display. Floats have visible powered wheel bases rather than levitating decorations. A giant Arcadia arch over the terminus hides a service lift beneath it, revealed after the fight. A side screen loops a cheerful sales reel showing only a truck, bollards and dummy targets.
Color and lighting: Near-black hall #07090F under a navy #0E1726 ceiling; steel #1C2A3A float chassis and slate #2E3B4E deck plates; cold spotlight white #D8E6F0 on each exhibit; Arcadia teal #3FE0D0 arch ring, screens and signage; hazard amber #FFB02E float lamps and firing apertures; alarm red #FF3B4E attack tells only. The hall is dark between exhibits, but darkness never hides a tell or a landing: every float edge, refuge and attack origin carries its own light.
Landmark: A giant Arcadia arch, an original teal arch-and-leaf emblem ringed in light, with a closed floor hatch beneath it. The Peacekeeper's curved lightbar echoes the arch's shape.
Composition to show: A wide gameplay-side arena shot: reinforced bollard lines at left and right, raised side walkways along both edges with concrete planter pillars standing on them, the Peacekeeper (a heavy driverless armored truck with a ram plow and a roof-mounted rotary machine gun, no driver visible) in the center lane, a side screen looping the sales reel, and the Arcadia arch behind the closed maintenance lift.
Foreground: Sparse bunting, hanging holographic banners and low planter edges frame the screen. Suspend banners high enough not to cover airborne targets or jump trajectories.
Playable plane: Stationary viewing steps and stands, slow float decks, connecting service platforms, and a wide terminal plaza, each with a lit top edge. Show wheel clearance beneath moving float decks.
Background: Additional parade lanes, looping holographic crowd silhouettes cheering at empty seats, facade sets of an idealized Arcadia city, and the hall's dark ceiling. Background floats cannot be entered or mistaken for active platforms.
Show only this level's appropriate era and threats: Night Guard, Sidearm Guard, Riot Officer, Rifleman, Staffer, Security Drone; the mini-boss the Peacekeeper only if this is its arena scene. Keep the number of characters low and their poses subordinate to environment readability. If Dave appears, draw a small silhouette in a warm burnt-orange jacket carrying exactly one weapon. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No floor collapse, summon phase, new weapon, Heirs, Thornwall contractors, or mandatory tether. Do not make the player jump over the full boss height from flat ground without a designed raised escape route. No vision cones or detection beams; no dismemberment, exposed organs, people harmed by the truck, bodies, or more than a few restrained blood stains on the floor.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, no UI, no watermark, no readable text, no real-world logos (draw Arcadia's arch emblem and signage only as abstract teal shapes), no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Design a clean side-elevation level-layout study for DEAD EDEN level 3, "Parade of Progress". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Staging yard → A02 Viewing stand → A03 Security checkpoint → A04 Parade crossing → A05 Terminus refuge → A06 Peacekeeper arena.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L03-A01: Staging yard. Board a low stationary exhibit float in the hall's indoor staging yard, then cross to a second float moving slowly along a short visible track. A fixed service ledge runs below the practice jump. Connection: Step onto a stationary viewing platform at A02.
L03-A02: Viewing stand. One Rifleman holds a wide stationary viewing stand at the far end of a lane of low crates, beside a slowly moving float that is scenery only. Connection: A stationary ramp leads into A03.
L03-A03: Security checkpoint. A single Riot Officer blocks a flat visitor-screening lane. A low overpass allows an obvious route behind it. Connection: The back of the lane reconnects to the main float route at A04.
L03-A04: Parade crossing. Two slow floats move along offset sections, with stationary refuges between. One Staffer stands on the first stationary landing; a Riot Officer with a Rifleman behind him and a low crate beside them hold the far stationary landing, separated by camera space. Connection: Climb fixed steps to A05.
L03-A05: Terminus refuge. A maintenance kiosk, supplies, and the visible closed arena gate sit beneath the Arcadia arch. A sealed safety window loops a small sales-reel exhibit of the truck ramming a bollard line. Connection: Enter A06 deliberately via the plaza gate.
L03-A06: Peacekeeper arena. A broad indoor demonstration plaza has a ground lane between two reinforced bollard lines, raised side walkways along both edges with concrete planter pillars on them, and steps back down to the lane. A dark control console stands at the foot of the arch. Connection: Victory wakes the console, which grants the keycard that opens the floor hatch (amber ring while locked, teal ring once open) and the noncombat maintenance lift to level 4.
Use dark simple masses for architecture, clean, evenly lit top edges for playable surfaces (mark where a lamp sits near every landing), muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Draw low cover (0.6 H) and high cover (at least 1.2 H) as distinct shapes. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. Boss arena requirements: one ground ram lane between two reinforced bollard lines, raised side walkways along both edges, concrete planter pillars at least 1.2 H tall standing on the walkways for high cover, and steps that connect the walkways back into the lane. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 3, "Parade of Progress". Match these materials and colors: Near-black hall #07090F under a navy #0E1726 ceiling; steel #1C2A3A float chassis and slate #2E3B4E deck plates; Arcadia teal #3FE0D0 arch ring, screens and signage; hazard amber #FFB02E float lamps and firing apertures. Spotlight and lamp colors belong to the lamp objects; the engine casts the light, so do not paint light pools or glow into the pieces.
Required asset family: Float deck and wheel chassis; canopy supports; exhibit displays (mock climate tower, service mascots, a "Safe Campus" tableau with a patrol rover and a security drone, glass cases of defense products); viewing steps and viewing stands; barrier modules; low crates (0.6 H); concrete planter pillars (at least 1.2 H); reinforced bollard lines; service refuge platforms; Arcadia arch; folding arch panels; floor lift hatch and keycard-door lift door with card reader (amber locked and teal open states); parade control console (dark and awake states); visitor-screening lane props; sales-reel screens; VIP viewing niche with the export-contract memo pickup.
Separation rules: Floats, wheels, rideable decks, and track motion remain distinct. The Peacekeeper is a separate boss asset; bollard lines and planter pillars have clear collision faces and readable impact states. The lift door, console and folding arch panels are separate props with matching closed and open states.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows, light pools or rim light, on a flat mid-grey (or transparent) background. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. Keep floor tops plain so a blood pool can read on them later. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, painted-in blood, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
The line above sets the visual baseline for any visual suggestion; this is a written design task, not an image request.
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 3 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, evidence files are optional finds, and each level's exit door needs its keycard. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, keycard placement, the enemy fairness caps (at most 2 shooters, 3 attackers and 1 heavy gun per screen, low and high cover for every gun lane, no pit edge behind a gun lane), and mini-boss phases in this brief.
Do not silently add weapons, enemies, enemy guns, bosses, traversal skills, unearned upgrades, conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not make protected people (harmless Sleepwalkers, the staff held in the clinic, the level 11 founder, Arcadia's executives) into targets, and do not add a radio contact or companion. Never add torture or execution on screen, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The boss is only at the end of level 3.
- Both new enemies have individual teaching encounters, and the first enemy gun after level 2's pistol (the rifle) is met alone, with a low crate beside it.
- A camera-stable refuge exists between each moving float section, and no gun lane covers a float ride.
- The Peacekeeper's second phase is harder through sequence length, not extra enemy clutter, and the roof gun always has a pillar or another floor within 3 H.
- The keycard comes only from the arena console after victory, is never a boss drop, is seen as a goal (the locked lift door under the arch) before it is earned, and opens only the lift door.
- Victory commits at once, so a later death never repeats the fight.
- Adam's announcements telegraph the parade, the truck's own notice and siren telegraph the rams, and nothing depends on being seen: there is no stealth or detection.
- Bodies stay, and blood never hides a tell, a ledge or a pickup.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects and darkness do not hide platform edges.
- Checkpoints preserve earned tools, the keycard and completed story beats without duplicating rewards.
- Art matches the text, the night palette and the approved enemy and weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
