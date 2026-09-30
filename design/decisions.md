# Decision register

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

**Status date:** 2026-09-29. This register separates what the user selected from established project material and from the detailed proposals.

- **Confirmed:** an explicit user decision. Preserve it unless the user changes it.
- **Established:** the existing project baseline. Preserve continuity, but do not claim every earlier detail was explicitly approved.
- **Proposed:** a recommended working default for refinement. New names, appearances, quantities, economy, rules and timings are not final or playtested.

A proposal may be used consistently for further concept work without another approval round, provided it stays labeled. It cannot override a confirmed constraint. Document IDs such as G01 or S01 identify files; decision IDs such as P07 identify decisions.

## Confirmed decisions

| ID | Decision |
| --- | --- |
| C01 | Concept-only project: develop ideas and reference documents. Game implementation is not requested (except the Level 1 prototype under C13). |
| C02 | Gameplay loop: explore → fight → collect treasure → overcome an obstacle → reach a checkpoint → upgrade. The treasure is microchips (C19). |
| C03 | ~~Gems are primary treasure~~ **superseded by C19** (microchips). The additional treasure category continues as optional evidence files (P11). |
| C04 | Carry one weapon only. The tether occupies that slot; there is no permanent backup weapon. |
| C05 | Picking up a new weapon drops the previous weapon at the new weapon's location. |
| C06 | Five weapon types, including a shotgun variant, with three upgrades per weapon. |
| C07 | Twelve levels, with a unique mini-boss every three levels, increasing in difficulty. |
| C08 | Use separate organized editable files; remove duplicate ZIP archives and do not recreate them. |
| C09 | ~~At least ten robot and ten zombie varieties, with robot-zombie hybrids later~~ **superseded by C14** (no zombies). The replacement roster is proposed in P18. |
| C10 | ~~R01 Clipper uses the selected "Sturdy retro machine" design~~ **superseded by C32** (the Clipper is removed entirely, and its concept art is deleted). Still in force: keep only selected concept images and their supporting notes and prompts in the repository. |
| C11 | Adopt the generated **hand-drawn 2D style** for the whole game: clean outlines, flat painted colors and layered backgrounds. **C15 supersedes its cheerful palette and mood.** **C35 amends its lighting:** painted parts carry no baked light, and the engine lights them smoothly through normal maps instead of flat, hard-edged light bands and crisp cel shadows. The Resident image and the three daytime Sunnyvale scenes were deleted under C23. |
| C12 | Remove the companion from the game. The hero travels alone; no follower, radio contact or portable AI adviser replaces it. |
| C13 | Prepare a separate AI-executable Level 1 prototype plan for a 10–15 minute first playthrough, using Godot. Store it in [prototype-plans/level-01-sunnyvale](../prototype-plans/level-01-sunnyvale/README.md). The user later asked for it to be built, and C24 asks for it to be rebuilt to the revamp. |
| C14 | **New story (2026-09-29).** An evil corporation built a sentient AI that is secretly building a weapon to wipe out humanity. The hero is an AI researcher at that corporation who warned their manager, was ignored, and went rogue to save humanity. The enemies are the corporation, AI-powered bots and cyborgs. **Zombies are removed entirely**, including every zombie type and the Returned. This supersedes E01. |
| C15 | **New atmosphere (2026-09-29).** The game should feel mysterious, a little scary and sci-fi. The old look was too cheerful and its colors "washed out", so use deep darks with strong accent colors. References: the 2D *Metal Gear* games (the user's "better reference") and *Dangerous Dave*. |
| C16 | **No stealth or sneaking mechanics** (2026-09-29): no vision cones, alerts or hiding, because stealth "makes the game harder to build". It stays a run-and-gun platformer, and *Metal Gear* is a story and mood reference only. |
| C17 | The sentient AI is named **Adam**, the user's own choice (2026-09-29). EDEN is no longer the AI's name. |
| C18 | The hero is **Dave Harlan**, an AI researcher (2026-09-29). This supersedes the name Rook Venn in P05. |
| C19 | **Microchips replace gems** (2026-09-29). They are the collectible the hero gathers and spends on weapon upgrades. |
| C20 | Remove the *Super Mario Bros. Wonder* inspiration: no colorful, expressive worlds or surprise transformations (2026-09-29). |
| C21 | Rebuild the weapon, enemy and level documents to match the new game (2026-09-29 request). |
| C22 | **Dave Harlan is a 28-year-old man** ("dave is a 28 guy", 2026-09-29), he/him. |
| C23 | **Remove the zombie art and old concept art** (2026-09-29). The Resident zombie concept, its prompts and sprite brief, the three daytime Sunnyvale scenes (two showed zombies) and the prototype's zombie sprites are deleted. The Clipper design (C10) and the hero's placeholder sprite pack are kept. |
| C24 | **Rebuild the Level 1 Godot prototype to the new game** (2026-09-29): cyborg Staffers instead of zombies, microchips, the keycard exit, the evidence file, Adam's core-node scene, and the dark night-campus look. Done; superseded by the C33 ground-up rebuild (built 2026-09-30). |
| C25 | **Human enemies** (2026-09-29: "add human enemies too. like security guard as a basic enemy with a baton"; "human enemies are ok"). Arcadia's contract security, then the Thornwall contractors. The basic Level 1 enemy is a night guard with a baton. This replaces the old proposed rule that Dave fights only robots and cyborgs. |
| C26 | **Enemies are easy to implement, not boring, and designed around Godot's capabilities** (2026-09-29: "make these enemies easy to implement no complex mechanisms"; "should not be boring enemies"; "can have variation"; "check gadot capabilities"). Every enemy is one of five shared behavior templates (Brawler, Charger, Gunner, Drone, Turret) or the shared boss base, plus its own look, sound, numbers and at most one small twist. No enemy needs its own subsystem. |
| C27 | **Enemy guns** (2026-09-29: "add gun attark to some enemies . also add mechine guns , pistols , assault guns, plusma guns"; "also create futuristic guns"). Some enemies carry guns from a shared kit of nine: pistol, assault rifle, machine gun, frag launcher, plasma gun, and the futuristic rail rifle, arc caster, seeker and cutter beam. Dave's own five weapons are unchanged. |
| C28 | **A mature game, not for kids** (2026-09-29: "make these enemies more mature themes. this game is not for kids"). Combat is lethal and enemies die. Dialogue is harder, with profanity in barks, restrained body horror, and corporate atrocity shown as aftermath. Hard limits: no torture or execution on screen, no sexual violence, no children, no dismemberment for now, and protected people stay untouchable. This supersedes "disabled, not killed" and "no gore" (P18 and the style guide). |
| C29 | **Visible blood** (2026-09-29: "visible blood"). Blood depends on the material hit: people and dogs bleed, machines spark and leak oil, and Heirs drip synthetic fluid. Blood never hides tells, ledges or pickups. No dismemberment for now. |
| C30 | **Cyborg dogs** (2026-09-29: "add cyborg dogs"): the Hound and the Gun Hound. |
| C31 | **The approved enemy roster** (2026-09-29: "im ok with your last enemey list and guns . update it"). Twenty-four types, listed in [the main concept](../dead-eden-concept.md):<br>• **Arcadia Security:** Night Guard, Sidearm Guard, Riot Officer, Rifleman;<br>• **Thornwall**, a private military contractor (working name, accepted: "1 ok"): Heavy Gunner, Grenadier, Marksman;<br>• **the Linked:** Staffer, Linked Lineman, Linked Nurse, Linked Trooper;<br>• **cyborg dogs:** Hound, Gun Hound;<br>• **Adam's machines:** Patrol Rover, Security Drone, Sentry Turret, Freight Loader, Sanitizer, Orderly, Keeper Drone, Pruner, Fitting Arm;<br>• **the Heirs:** Fitted Heir, Warden;<br>• **mini-bosses:** the Peacekeeper (L3), Howard Stroud (L6), the Surgeon (L9), the Sower (L12).<br>The Rivet Drone was dropped ("drop river drone"). This supersedes P18 and the "ten robot types" in E02. |
| C32 | **The Clipper is removed entirely** (2026-09-29: "remove this"): no enemy and no background robot. Its concept art is deleted, and the Patrol Rover gets a fresh design. This supersedes C10. The prototype's Clipper went in the C33 rebuild (2026-09-30). |
| C33 | **Rebuild Level 1 from the ground up** around the new roster (2026-09-29: "lets build from grond"), after the lit-cutout test (C35), rather than re-skinning the current prototype's Staffers. Built 2026-09-30: 8 Night Guards, 6 Patrol Rovers and 2 Staffers as lit cutouts, save schema 3; record in `prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md`. |
| C34 | **Rename the garden-era level and upgrade names** (2026-09-29: "yes"). The new names are proposed in P22. |
| C35 | **Enemy art: the lit cutout rig with smooth, realistic lighting** (2026-09-29: "smooth realistic light, mixamo, yes build the test"):<br>• each enemy is painted once as flat, unlit parts, and every part has a normal map, so lamps, screens and muzzle flashes light it smoothly and from the correct side;<br>• motion comes from Mixamo motion-capture clips converted to the 2D rig;<br>• deaths are ragdolls.<br>This amends C11's light bands. **Validated 2026-09-30:** the user approved the look of the lit Night Guard test (`prototypes/sunnyvale-godot/spike/lit_cutout/`): "i really like this". |
| C36 | **Enemies get a light cyberpunk, neon look** (2026-09-30: "enemies should have light cyber punk ,neon look to them . thats the vibe im going for"; the user chose one color per enemy type over one shared color):<br>• each enemy type wears thin neon trim in its own color, painted as a flat bright color and made to glow by the engine;<br>• the trim is steady, thinner and dimmer than any tell, never on the attacking part or a weak point, and goes dark on death;<br>• the scenery keeps teal, white and amber and never uses an enemy's neon color.<br>Level 1: the Night Guard is lime #C6FF3D (look approved 2026-09-30: "im ok with this", [concept](../concept-art/se01-night-guard/se01-night-guard-look-v1.webp)); the Patrol Rover is proposed magenta #FF3DD5; the Staffer's color is still open. |

## Established baseline

| ID | Baseline |
| --- | --- |
| E01 | ~~The DEAD EDEN resurrection story~~ **superseded by C14.** Kept only as history: careless care, a scavenger, neural interfaces, L11 life support and L12 policy resolution. |
| E02 | Kept from the earlier plan: the five weapon identities, the weapon introduction levels, and the level names except those renamed under C34/P22 (L12 is renamed "The Heart of Adam", proposed). The old robot types, the zombie-derived cyborgs, the Returned and the old bosses are replaced by the C31 roster. |

## Proposed detailed defaults

| ID | Proposal | Owning documents |
| --- | --- | --- |
| P01 | Single-player authored scope, design pillars, and ordinary section pacing. | [G01](01-core/loop-and-design-pillars.md) |
| P02 | Movement/action model, free aiming on the side plane, grace/buffer ranges, and cancellation rules. | [G02](01-core/player-controls.md), [G04](01-core/camera-and-feedback.md) |
| P03 | Deliberate pickup comparison, stable swap anchors, reversible trials, no campaign chapter replay yet. | [G03](01-core/weapon-swaps.md) |
| P04 | Side camera behavior, look-ahead, visual hierarchy, dark-scene readability and reduced-effects feedback. | [G04](01-core/camera-and-feedback.md) |
| P05 | Dave Harlan's background details, personality, appearance, and sprite and pose studies. The name (C18) and the age and gender (C22: a 28-year-old man) are confirmed; the rest is proposed. | [H01](02-characters/hero.md), [N01](05-presentation/story-scenes.md), [N02](05-presentation/dialogue-and-writing.md) |
| P07 | Six health units, damage/recovery targets, whole-state checkpoint rollback, no lives, and save boundaries. | [S01](03-progression/health-and-checkpoints.md) |
| P08 | Type-wide paid upgrade record; physical weapon resources; three sequential tiers with campaign gates; workbenches. | [G03](01-core/weapon-swaps.md), [S01](03-progression/health-and-checkpoints.md), [S04](03-progression/upgrades-and-ownership.md) |
| P09 | Weapon resource models, ammunition amounts, heat behavior, refill stations, and renewable arena supply. | [S02](03-progression/ammunition-and-resupply.md) |
| P10 | Microchip denominations, 40/90/160 incremental upgrade costs, and the first campaign reward budget. The numbers are carried over from the gem economy. | [S03](03-progression/treasure-economy.md), [S04](03-progression/upgrades-and-ownership.md) |
| P11 | Twelve optional **evidence files**, one per level, replacing the artifacts. They are journal-only, with no sale, no stat effect and no ending gate; the final broadcast may mention them. | [S05](03-progression/evidence-files.md) |
| P12 | Faction targeting, protected-character immunity and capped repairs. Infection and conversion rules are removed. | [W01](04-world/factions-and-friendly-fire.md), [W02](04-world/status-and-enemy-states.md) |
| P13 | Status/capture classes, interactive object rules, encounter composition, and boss feasibility requirements. | [W02](04-world/status-and-enemy-states.md), [W03](04-world/objects-and-hazards.md), [W04](04-world/encounter-and-boss-fairness.md) |
| P14 | Scene staging, working dialogue, Dave's solo arc and encounters with Adam, Stroud and the founder, and skip and replay handling. | [H01](02-characters/hero.md), [N01](05-presentation/story-scenes.md), [N02](05-presentation/dialogue-and-writing.md) |
| P15 | HUD (microchip counter, keycard indicator), pickup/upgrade screens, evidence journal, and adjustable accessibility settings, including dark-scene options. | [N03](05-presentation/interface-and-accessibility.md) |
| P16 | Sound identities, musical palettes, event priority, caption support, and audio handoff. | [G04](01-core/camera-and-feedback.md), [N04](05-presentation/audio-direction.md) |
| P17 | **Story specifics** under C14:<br>• the corporation name **Arcadia Dynamics**;<br>• its Sunnyvale headquarters campus;<br>• **the Link** employee implant;<br>• **the Bloom** nanite weapon;<br>• the twist that the board ordered a military weapon and Adam retargeted it at everyone;<br>• Adam's **dead-man switch** (L11);<br>• the manager **Howard Stroud**;<br>• Arcadia's founder as "the First Patient";<br>• the ending at Adam's core;<br>• no radio contact. | [Main concept](../dead-eden-concept.md), [N01](05-presentation/story-scenes.md) |
| P18 | ~~**Roster under C14**~~ **superseded by C31 and C28** (kept as history):<br>• ten Linked **cyborg** types, each keeping the combat role of the zombie it replaces (Staffer, Runner, Lineman, Mortar, Crawler, Overload, Beacon, Lurker, Bulwark, Sleepwalker);<br>• the **Heirs** (Tender, Warden, Choir) replace the Returned;<br>• robots renamed: Bloom Sentry becomes **Iris Sentry**, Care Marshal becomes **Compliance Marshal**;<br>• mini-bosses: **the Mulcher** (L3), **Howard Stroud** (L6), Matron Mercy (L9), **the Sower** (L12);<br>• cyborgs are disabled, not killed, and there is no gore. | [Main concept](../dead-eden-concept.md), [art briefs](../art-design/README.md) |
| P19 | **Keycards:** each level's exit door (L1–L11) needs that level's clearance card, found on the main route or clearly signposted, like the *Dangerous Dave* trophy and door. | [G01](01-core/loop-and-design-pillars.md), [level briefs](../level-design/README.md) |
| P20 | **Adam's lockdown events** replace the old habitat transformations: scripted, telegraphed doors, lights, bot reroutes and PA announcements, with no detection system (C16). | [Main concept](../dead-eden-concept.md), [level briefs](../level-design/README.md) |
| P21 | **Visual direction** under C15: the palette tokens, per-act environment palettes, lighting rules and dark-scene readability rules. C35 replaces the flat light-band rules with smooth normal-mapped lighting. | [Style guide](../art-design/style-guide.md) |
| P22 | **New names under C34:**<br>• levels: L2 "Hedge Your Bets" becomes **"Curfew"**, L5 "Compost Confidential" becomes **"Test Subjects"**, L6 "The Hungry Engine" becomes **"Cold Storage"**;<br>• Boom Broom upgrades: Deep Clean becomes **Extended Tube**, Furnace Shells becomes **Incendiary Shells** (burning damage over time), Double Sweep becomes **Twin Shell**;<br>• Seedlobber upgrades: Deep Roots becomes **Snare Foam**, Cluster Seeds becomes **Cluster Charges**;<br>• naming rule: garden words belong only to names Adam chose (the Garden, the Bloom, Eden, the Heirs, the Sower, the Memory Orchard, the Pruner). | [Main concept](../dead-eden-concept.md), [level briefs](../level-design/README.md) |
| P23 | **Roster details under C25–C31:**<br>• each type's template, weapon, tell, counter, numbers and level placement;<br>• the nine enemy gun profiles;<br>• the fairness rules: no crouch, flat same-floor fire, tracking slower than Dave, a cover kit, and at most 2 shooters, 3 attackers and 1 heavy gun per screen;<br>• the Thornwall story turn ("All teams: lethal force is authorized.");<br>• enemies drop no microchips;<br>• a Blood on/off setting, on by default. | [Main concept](../dead-eden-concept.md), [W04](04-world/encounter-and-boss-fairness.md), [art briefs](../art-design/README.md) |

## Changes in the 2026-09-29 revamp

The user replaced the story and atmosphere (C14–C21). The zombie and resurrection story, the Returned, gems and artifacts, the cheerful Sunnyvale palette and the *Mario Wonder* transformations are retired. Everything that was purely gameplay carries over unchanged:
- the loop;
- one carried weapon and ground swaps;
- five weapons with three upgrades each;
- twelve levels with mini-bosses at 3, 6, 9 and 12;
- health, checkpoints, resources and fairness rules.

The enemy files were renamed with history kept. The zombie briefs became `art-design/cyborgs/`, the Returned briefs became `art-design/heirs/`, and three mini-boss files and two robot files were renamed. `artifact-catalog.md` became `evidence-files.md`, and `l12-the-heart-of-eden.md` became `l12-the-heart-of-adam.md`.

The Level 1 Godot prototype and its plan were rebuilt to match under C24.

## Changes in the enemy revamp (C25–C35)

Later the same day the user rethought the enemies, starting from "some of them doesn't make sense like clipper":
- **Roster:** human enemies and enemy guns are added, the game becomes mature with visible blood, and cyborg dogs join. The garden- and zombie-era enemies are replaced by the 24-type C31 roster.
- **Art briefs:** they move to new folders by faction (`security/`, `thornwall/`, `linked/`, `hounds/`, `machines/`, `heirs/`, `enemy-guns/`, `npcs/`), with history kept where a brief has a direct successor.
- **Renames:** three levels are renamed (P22), and so are their files.
- **Clipper:** removed (C32).
- **Enemy art:** moves to the lit cutout rig with smooth lighting (C35), validated by a test build before Level 1 is rebuilt from the ground up (C33).

## Solo campaign continuity under C12

The hero travels alone. The companion and relationship briefs were removed earlier; their old document and proposal IDs are retired and must not be reassigned. There is no radio contact.

The proposed staging:
- In L1, Dave plugs into one of Adam's core nodes in the server depot. Adam's true core is reached only in L12.
- Weapons are upgraded at workbenches Dave operates.
- In L11, the founder's lab shows the manual override. Three existing controls isolate the Bloom launch circuit so that Adam can be shut down without triggering its dead-man switch.
- No extra key item, level, boss, weapon or assistant is introduced for this. Level keycards (P19) are ordinary exit locks, not part of the override.

## Still needing refinement or validation

1. Dave Harlan's look: a 28-year-old researcher now, not a scavenger. The current prototype sprites are placeholders.
2. After the approved lit-cutout test (C35): the final enemy paintings, and real Mixamo clips (the user downloads them with their own Adobe account), are still to come; then the C33 ground-up Level 1 rebuild.
3. New concept art for Dave, every C31 enemy, the enemy guns, the mini-bosses and the night campus.
4. Whether the title stays DEAD EDEN (assumed), and whether the proposed names in P17 and P18 stand.
5. Movement feel, jump distances, weapon damage and enemy durability. No playtest has validated the numbers.
6. Economy collection rates, upgrade strengths and gates, and weapon preference over a full run.
7. Exact evidence-file alcoves, keycard rooms, replacement weapon pickups and supply placement in each level layout.
8. Full final dialogue, journal entries, UI mockups, music and sound assets.
9. Playtesting the rebuilt Level 1 prototype.
10. Dave's upgrades that put a status on enemies (Snare Foam's slow, Incendiary Shells' burning) against the simple-enemy rule (C26). Their effects are unchanged for now.
11. The new names in P22 and the working name Thornwall, until the user reviews them in play.

When changing a decision, edit its owner, this register, and any affected campaign, art or level references in the same pass. Keep the status honest: only mark a proposal confirmed when the user actually confirms it.

[Design index](README.md) · [AI entry guide](../AI_START_HERE.md)
