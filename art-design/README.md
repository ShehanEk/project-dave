# DEAD EDEN — Art design reference pack

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](style-guide.md)).

Use the [visual style guide](style-guide.md) with every brief. The enemy art method is the lit cutout rig (C35): flat painted parts, a normal map for each part, smooth engine lighting, hand-keyed motion (C38) and ragdoll deaths. Status: **confirmed direction, validated by the approved lit-cutout test (2026-09-30)**, with the Night Guard as the test subject. No enemy image is selected yet. The zombie and old daytime concept art was deleted (C23), and the [concept-art gallery](../concept-art/README.md) keeps only the hero's placeholder sprites.

For the hero, see [Dave Harlan](../design/02-characters/hero.md). For the optional collectibles, see [evidence files](../design/03-progression/evidence-files.md). Use the [AI entry guide](../AI_START_HERE.md) to connect these visuals to the gameplay rules.

These are forty-three standalone asset briefs for image generation and later rig and animation production: twenty-four enemy types (four Arcadia Security, three Thornwall, four Linked, two cyborg dogs, nine machines and two Heirs), four mini-bosses, nine enemy guns, five of Dave's weapons with all fifteen upgrades, and one protected NPC. Arcadia's founder (L11) is a non-combat story character, and Dave is not an enemy or weapon asset; both are outside this pack.

## Start here

1. Read the [style guide](style-guide.md): the lit cutout rendering rule, light in the engine, the palette tokens and reserved color meanings, blood and the mature-content limits, and dark-scene readability.
2. Open one asset brief and copy its **neutral design** prompt, which starts with the standard prompt opening, into your image generator. Ask for one evenly lit, flat-color, side-view full-body painting on a flat mid-grey or transparent background, with no baked shadows, no painted-in blood and no gun (unless the brief is a gun brief).
3. Approve one result for the asset. Start with the Night Guard, the test subject.
4. Split the approved painting into rig parts with hidden overlap under the joints. The brief's **Rig parts, normal maps and sockets** section lists the parts, pivots, the gun socket and the fluid type (blood, oil or lymph). Make a normal map for every part (green = up), pack the parts and maps into an atlas, and build the rig.
5. Hand-key the rig's moves for the side view (C38: motion capture flattens badly onto side-on cutouts). Add the tell pose, the ragdoll death (machines and bosses burst into debris parts) and the blood layers (spray, wound marks, floor pools) separately.
6. Check every asset in the engine, under night lighting, at gameplay size, against a dark background and as a solid silhouette. The tell must read.

These files contain art direction and prompts. There are no finished paintings, rigs or animations. Gameplay abilities follow the [game concept](../dead-eden-concept.md). Appearances, scales and attachments are proposals.

Each brief covers:
- identity, dimensions and silhouette;
- appearance and palette;
- behavior and limitations;
- rig parts, normal maps and sockets (parts, pivots, the gun socket and the fluid type);
- pose and state references;
- consistency rules;
- complete image prompts.

Mini-boss briefs also cover arena relationships and phases. Enemy gun briefs also cover the gun's futuristic look, muzzle-flash light, projectile look and who carries it. Weapon briefs also cover handling and three cumulative upgrade designs, with prompts.

## Coverage

| Category | Briefs | Included |
| --- | ---: | --- |
| Arcadia Security | 4 | Human campus contract security (Acts 1–2) |
| Thornwall | 3 | Human private military contractors (Acts 2–3) |
| The Linked | 4 | People driven by Adam through their Link implants, including captured Thornwall contractors |
| Cyborg dogs | 2 | The Hound and the Gun Hound |
| Adam's machines | 9 | Adam's machines from the campus to the Garden |
| Heirs | 2 | Adam's synthetic bodies, from Level 10 |
| Mini-bosses | 4 | Levels 3, 6, 9 and 12 |
| Enemy guns | 9 | Look, muzzle-flash light and projectile look of each gun in the shared kit |
| Dave's weapons | 5 | Base plus three upgrade stages per weapon |
| Protected NPC | 1 | The harmless Sleepwalker (no combat, no hit zone) |
| **Total asset briefs** | **43** | **24 enemy types and 15 weapon upgrades** |

The first six rows are the 24 enemy types (C31).

## Arcadia Security

Human campus contract security.

- [SE01 — Night Guard](security/se01-night-guard.md) — Level 1: the basic human enemy, a night-shift guard whose shock baton glows before one overhead swing. He bleeds and stays down, and he handles the Act 1 Hounds. The test subject for the lit cutout rig.
- [SE02 — Sidearm Guard](security/se02-sidearm-guard.md) — Level 2: a guard with the AS-9 "Civic" smart pistol who aims from a two-hand stance and racks the slide to reload.
- [SE03 — Riot Officer](security/se03-riot-officer.md) — Level 3: a shield-and-maul brawler whose shield blocks Dave's bolts while a Rifleman's rounds pass through him.
- [SE04 — Rifleman](security/se04-rifleman.md) — Level 3: an assault-rifle soldier firing 3-round bursts. He is Arcadia's Response Team at L3 and a Thornwall man from L4 to L9.

## Thornwall

Human private military contractors.

- [TW01 — Heavy Gunner](thornwall/tw01-heavy-gunner.md) — Level 5: plants a rotary machine gun behind a drum pack, drawn at 1.1x scale. Cover-only on its floor.
- [TW02 — Grenadier](thornwall/tw02-grenadier.md) — Level 5: a gas-masked contractor with a bandolier who lobs frags from the GL-6 launcher.
- [TW03 — Marksman](thornwall/tw03-marksman.md) — Level 6: a long-coated sniper on a far perch, with the RX-2 rail rifle and a tracking sight line.

## The Linked

People driven by Adam through the Link implant.

- [LK01 — Staffer](linked/lk01-staffer.md) — Level 1, at the alarm exit: a night-shift employee with a stapled port who drops into a low lunge and grabs. It never blocks progress.
- [LK02 — Linked Lineman](linked/lk02-linked-lineman.md) — Level 6: a Rootworks electrician with cables sutured into his forearms, who rams an arc rod into the deck.
- [LK03 — Linked Nurse](linked/lk03-linked-nurse.md) — Level 7: blood-spotted scrubs and a tray of caustic sterilant vials, which she tosses in an arc.
- [LK04 — Linked Trooper](linked/lk04-linked-trooper.md) — Level 8: a captured Thornwall contractor armed with Adam's plasma carbine.

## Cyborg dogs

- [K01 — Hound](hounds/k01-hound.md) — Level 2: a debarked K9 with a steel jaw, a lens eye and a cable tail, which lunges after a wet wheeze. Arcadia's with a Night Guard handler in Act 1, Adam-driven in L7–L8, Garden-built in L11.
- [K02 — Gun Hound](hounds/k02-gun-hound.md) — Level 5: Thornwall's K9, with a back-mounted assault rifle that fires low bursts.

## Adam's machines

- [M01 — Patrol Rover](machines/m01-patrol-rover.md) — Level 1: a security rover that rocks back and charges its lane. A fresh design.
- [M02 — Security Drone](machines/m02-security-drone.md) — Level 2: a flying drone with shock prongs that dives at a locked spot, then hangs at head height.
- [M03 — Sentry Turret](machines/m03-sentry-turret.md) — Level 4: a rotary machine-gun turret whose aim creeps after Dave; its open core is the weak point.
- [M04 — Freight Loader](machines/m04-freight-loader.md) — Level 4: a heavy freight ram, too tall to jump, with a rear power unit to hit.
- [M05 — Sanitizer](machines/m05-sanitizer.md) — Level 7: the clinic's disposal unit, with a low burning jet.
- [M06 — Orderly](machines/m06-orderly.md) — Level 7: a clinic transport that charges, then beeps and reverses, with a body bag on its stretcher deck.
- [M07 — Keeper Drone](machines/m07-keeper-drone.md) — Level 8: a lantern drone that releases one shootable homing seeker per lap, over a dead employee's murmur.
- [M08 — Pruner](machines/m08-pruner.md) — Level 10: a Garden-built beam turret whose petal cowl opens before its cutter beam.
- [M09 — Fitting Arm](machines/m09-fitting-arm.md) — Level 10: a gripper claw that sweeps a wide arc just above the floor.

## Heirs

- [HE01 — Fitted Heir](heirs/he01-fitted-heir.md) — Level 10: a pale-ceramic Heir wearing a dead colleague's scanned face, which leaps to land past Dave. Hits drip grey-rose lymph.
- [HE02 — Warden](heirs/he02-warden.md) — Level 11: a plated Heir with a palm plasma emitter and a dead guard's recorded shout.

## Mini-bosses

- [B01 — The Peacekeeper](mini-bosses/b01-the-peacekeeper.md) — Level 3: Arcadia's driverless crowd-control truck, with a ram and a roof rotary machine gun.
- [B02 — Howard Stroud](mini-bosses/b02-howard-stroud.md) — Level 6: Dave's former manager, Linked and wired into the cooling station. He fights with a cable slam and floor arcs, and he dies speaking his own last words.
- [B03 — The Surgeon](mini-bosses/b03-the-surgeon.md) — Level 9: the implant theater's ceiling-rail surgical robot, with a cutting laser and an injector dive.
- [B04 — The Sower](mini-bosses/b04-the-sower.md) — Level 12: Adam's walking launch machine for the Bloom, with a stomp and arc wave, a chest plasma volley and seekers in phase 2.

## Enemy guns

The shared kit of nine. Any enemy can carry any gun, and each gun is a separate sprite with its own muzzle-flash light.

- [EG01 — Pistol](enemy-guns/eg01-pistol.md) — Level 2: Arcadia's AS-9 "Civic" smart pistol, a matte ivory slab with a status strip.
- [EG02 — Assault Rifle](enemy-guns/eg02-assault-rifle.md) — Level 3: Arcadia's AR-7 "Warrant", a compact graphite bullpup with a glowing ammo readout. Thornwall's are taped TK-12s.
- [EG03 — Machine Gun](enemy-guns/eg03-machine-gun.md) — Level 3: Arcadia's HG-40 "Thresher", a three-barrel rotary in a white shroud with a heat collar.
- [EG04 — Frag Launcher](enemy-guns/eg04-frag-launcher.md) — Level 5: Thornwall's GL-6, a stubby black revolving-drum launcher with a ring light.
- [EG05 — Rail Rifle](enemy-guns/eg05-rail-rifle.md) — Level 6: the RX-2 "Needle", an Arcadia prototype twin-rail rifle with three capacitor rings, field-tested by Thornwall. Futuristic.
- [EG06 — Arc Caster](enemy-guns/eg06-arc-caster.md) — Level 6: the "Groundline", a heavy insulated rod wired to a capacitor pack. Futuristic.
- [EG07 — Plasma Gun](enemy-guns/eg07-plasma-gun.md) — Level 8: Adam's "Lumen", a pearl-white carbine with a glass chamber, also grown into the Heirs' palms.
- [EG08 — Seeker](enemy-guns/eg08-seeker.md) — Level 8: the Keeper's "Lantern" round, a small pale finned eye that hunts. Futuristic.
- [EG09 — Cutter Beam](enemy-guns/eg09-cutter-beam.md) — Level 9: a lens in a ceramic petal cowl (a slim laser scalpel on the Surgeon). Futuristic.

## Dave's weapons

- [W01 — Scrapjack Pistol](weapons/w01-scrapjack-pistol.md) — Dave's homemade coil pistol; a dependable precision sidearm built from lab scrap.
- [W02 — Boom Broom](weapons/w02-boom-broom.md) — A pump-action maintenance blaster; the close-range weapon with the strongest punch.
- [W03 — Arc Welder](weapons/w03-arc-welder.md) — An Arcadia repair tool used for short-range electrical control.
- [W04 — Seedlobber](weapons/w04-seedlobber.md) — A reforestation pod launcher firing bouncing explosive pods.
- [W05 — Graviton Tether](weapons/w05-graviton-tether.md) — A freight-bay cargo device for grabbing, throwing and pulling Dave to marked anchors.

## Protected NPC

- [NPC01 — Sleepwalker](npcs/npc01-sleepwalker.md) — Staff with failing implants who repeat old routines. Harmless and protected: no combat, no hit zone, never a target.

## Suggested review order

1. **Night Guard first.** It is the test subject for the lit cutout rig (C35). Judge the smooth light, the proportions, the hand-keyed motion and the ragdoll death on him before anything else is painted, next to Dave (the [hero brief](../design/02-characters/hero.md)), whose frames get normal maps too.
2. Add the other Level 1 enemies: the Staffer, which tests the Link light and implant sparks, and the Patrol Rover, the first rigid-part machine (sparks, oil and a debris burst).
3. Add the first gun on a hand socket: the Sidearm Guard with the pistol and its muzzle-flash light. Then approve the rest of the gun kit.
4. Develop the Scrapjack for Dave's equipment family.
5. Approve the ordinary enemies by faction (Arcadia Security, the Hounds, Thornwall, the Linked, the machines) before the Heirs.
6. Leave the mini-bosses for last, and the Sower's studies until the design language is stable.
