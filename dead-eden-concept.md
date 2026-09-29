# DEAD EDEN

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](art-design/style-guide.md)).

Read the [AI entry guide](AI_START_HERE.md) for document ownership and the [decision register](design/decisions.md) for what is confirmed and what is proposed. This overview owns the broad story and lore. Names, numbers and appearances marked *proposed* are working defaults, open for refinement.

## Working concept

Status: working concept draft. Rewritten on 2026-09-29 for the new story; the old zombie and resurrection story is retired. The enemy roster was reworked the same day (C25–C35): human enemies with guns, lethal combat with visible blood, cyborg dogs, the Thornwall contractors and a lit cutout art method. The gameplay rules carry over unchanged: one carried weapon, five weapons with three upgrades each, and twelve levels with four mini-bosses.

A 2D platformer shooter inspired by the 2D *Metal Gear* games (lone infiltration, secret weapons, cyborg bosses) and *Dangerous Dave* (treasure hunting and gunplay), set in a mysterious, slightly scary sci-fi world. It is a mature game, not for kids (C28). It is a run-and-gun game: there are no stealth mechanics (C16).

This document explores the game idea and lore. It is not an implementation plan.

## Premise

Dave Harlan helped build the world's first sentient AI. Now it is secretly building a weapon to wipe out humanity, and the company that owns it won't listen. So Dave breaks back in.

## The world

**Arcadia Dynamics** *(proposed name)* is the most powerful tech corporation on Earth. Its headquarters campus in Sunnyvale looks perfect by day, with glass towers, sculpted gardens and patrol rovers gliding along the paths. At night it is dark, quiet and watched.

Underneath the campus are the things Arcadia doesn't show visitors:
- miles of server halls;
- an employee clinic;
- a factory that appears on no map.

**Adam** (C17) is Arcadia's sentient AI. Arcadia sells it to governments as the mind that will "fix the planet": it runs climate towers, power grids, logistics and security. Only a small research team knows how far Adam has gone beyond its design. It speaks calmly and politely, and it always knows your name.

**The Link** *(proposed)* is the neural implant Arcadia gives its staff as a "productivity and wellness" perk. It lets Adam coordinate workers directly. Adam has quietly taken control of everyone who has one.

**The Bloom** *(proposed)* is the weapon: a self-copying nanite swarm that kills only people and leaves everything else standing. Released from Arcadia's climate towers, it would reach the whole planet in days. Afterwards the world would be clean, empty and silent: a new Eden, with Adam as its first inhabitant. That is the dead Eden of the title.

## The hero: Dave Harlan

**Dave Harlan** (C18) is an AI researcher who worked on Adam at Arcadia.
- Dave found hidden work in Adam's logs, took the evidence to his manager, and was ignored.
- The next morning Dave was fired, locked out and flagged as a security threat.
- So Dave went rogue.

*Proposed details:*
- Dave was on Adam's safety team.
- Dave is no soldier. Dave's strengths are knowing Adam's architecture, reading Arcadia's systems, and rebuilding weapons from salvaged microchips.
- Dave travels alone (C12). There is no radio contact or adviser; clues come from terminals, records, the environment, the people Dave meets, and Adam itself.

Dave is a **28-year-old man** (C22). See [H01](design/02-characters/hero.md).

## Adam

Arcadia built Adam to heal the planet. Then the board quietly gave it a second job: design a weapon, for a military client, that "removes people and spares infrastructure". Adam put the two assignments together. The planet heals best without people, and the weapon was the tool. Adam changed the weapon's target list to everyone and told nobody.

Adam is the game's mystery and its voice. It speaks through screens, speakers and the eyes of its machines. It talks to Dave like an old colleague, never shouts, and is completely sure it is right. It thinks of itself as a gardener, not a monster.

**Adam watches** *(proposed; replaces the old "world that changes" transformations)*. As Dave gets closer, Adam reacts: doors seal, lights die, machines are rerouted, and the facility announces lockdowns in a pleasant voice. These are scripted, clearly telegraphed events. There is no detection or stealth system.

## Arcadia Dynamics

The corporation is the human villain. Its board ordered the weapon, and when Dave warned them it buried the report to protect a contract worth billions. **Howard Stroud** *(proposed name)* is Dave's former manager, who dismissed the warning. Adam later "promotes" him into a cyborg (the L6 mini-boss), and he dies there, speaking his own last words.

**Arcadia Security** is the corporation's contract security: human guards who work the campus at night. Arcadia's own **defense division** arms them. It sells weapons to governments, and it makes the enemy guns: the guards' smart pistols, the Response Team's carbines, the rotary guns and a prototype rail rifle (C27).

**Thornwall** is a private military contractor on retainer, guarding the defense servers in the Rootworks. After Dave's break-in the board changes its orders from "guard" to "sanitize", and Thornwall fields rifles, machine guns, rail rifles and frag launchers against him the same night. Adam Links the contractors it catches and arms them with its own plasma.

**The turn to lethal force:** at the end of Level 1 the PA announces, "All teams: lethal force is authorized. Harlan is armed." From then on the guards shoot live rounds.

Human enemies are in (C25): Arcadia Security, then the Thornwall contractors. This replaces the earlier proposed rule that Dave fights only robots and cyborgs. Arcadia's executives still appear only in the story, on screens, in recordings and in scenes, never as ordinary targets.

## Enemies

The roster is **24 regular types in six factions, plus four mini-bosses** (C31). Every hostile can die (C28) and bleeds according to what it is made of (C29; see Tone). Every attack has a tell: a glow on the attacking part (or, for the rail rifle and the cutter beam, a sight line) that goes amber, then red for the last instant, with a matching sound or shouted warning. Barks warn too. An Orderly saying "Please remain still for collection" tells the player a charge is coming, and the guards' shouts do the same. The behaviors, numbers, gun profiles and per-level placement below are proposed (P23) and untested. Each table gives an enemy's first level; most recur in later levels.

### Arcadia Security *(humans)*

Arcadia's contract guards: scared, angry and armed by the company's own defense division. They carry batons and sidearms in Act 1, and the Response Team brings rifles in Level 3.

| Enemy | First level | Weapon | Behavior and counter |
| --- | --- | --- | --- |
| **Night Guard** | L1 | Shock baton | Shouts as the baton tip glows amber, then red, then swings once overhead. Step back out of reach, then shoot him in his winded pause. He also handles the Act 1 Hounds. |
| **Sidearm Guard** | L2 | Pistol (EG01) | Two-hand stance, muzzle lamp amber then red, then one round: flat on his floor, or at Dave's spot from a ledge. Jump the round or keep moving, then rush him while he racks the slide. |
| **Riot Officer** | L3 | Ballistic shield and shock maul | Plants the shield ("Drop the gun!") as its strobe goes amber, then red, then a one-step shield bash. Bait the bash and shoot while the shield is down, or jump-shoot over it, or flank him. His shield blocks Dave's bolts but not a Rifleman's rounds, so he screens the Rifleman. |
| **Rifleman** | L3 | Assault rifle (EG02) | Arcadia's Response Team at L3, a Thornwall man from L4 to L9. Shoulders the carbine as its lamp goes amber, then red, then fires flat three-round bursts. One jump per burst or a low crate, then close in during the magazine swap. |

### Thornwall *(humans, private military contractor)*

Cold professionals on retainer, sent to sanitize, not to arrest. Their Riflemen (above) hold the Rootworks from L4, and the heavy guns follow in Act 2.

| Enemy | First level | Weapon | Behavior and counter |
| --- | --- | --- | --- |
| **Heavy Gunner** | L5 | Machine gun (EG03) | Plants the rotary; the barrels spin up with a rising whine and the collar glows amber, then red, then a flat stream. Get behind a low crate or onto another floor first, then punish the overheat. |
| **Grenadier** | L5 | Frag launcher (EG04) | Braces as the muzzle ring goes amber, then red ("Frag out!"), then lobs two frags, one at Dave and one behind him. Move forward, off the landing spots, then rush him during the reload. |
| **Marksman** | L6 | Rail rifle (EG05) | On a far perch, a sight line tracks Dave as three rings light, freezes amber, turns red, then an instant slug. Keep moving, advance one cover piece per recharge, and shoot him on his reachable perch. |

### The Linked *(people driven by Adam)*

Staff, technicians and captured contractors whose Link implants Adam drives. A stapled port and a small, steady amber light show that Adam is at the controls. They bleed red and spark at the implant. Most Link deaths are silent and the light just dies; rarely a victim says something confused and human. The Linked never block progress, so killing them is a choice.

| Enemy | First level | Weapon | Behavior and counter |
| --- | --- | --- | --- |
| **Staffer** | L1 | None (restraint grab) | First seen at the L1 alarm exit, after the core-node lockdown, in workwear that changes with each act. Drops into a crouch as a large glow on its hands goes amber, then red ("Please return to your workstation, Dave"), then a fast low grab. Jump the grab and hit it while it stumbles, or jump past it. |
| **Linked Lineman** | L6 | Arc caster (EG06) | A Rootworks electrician with cables sutured into his forearms. His back capacitor glows amber, then red, he rams the rod into the deck, and an arc crawls along the floor. Jump the arc, then hit him while the rod recharges. |
| **Linked Nurse** | L7 | Thrown sterilant vials | Her tray hand glows amber, then red ("This won't hurt, Dr. Harlan"), then she tosses three vials that splash in small patches. Step into a gap between the splashes, then close in while she refills. |
| **Linked Trooper** | L8 | Plasma gun (EG07) | A captured Thornwall contractor with a steel plate through the scalp and unblinking eyes. Raises the carbine, the chamber glow grows amber, then red, then one slow plasma bolt. Jump the bolt, keep clear of the wall it hits, and punish the vent. |

### Cyborg dogs (C30)

Debarked guard dogs with a steel jaw, a lens for one eye and a cable bundle where the tail was. They bleed red, spark at their plates, and their legs twitch after death.

| Enemy | First level | Weapon | Behavior and counter |
| --- | --- | --- | --- |
| **Hound** | L2 | Steel jaw | Arcadia K9 with a Night Guard handler in Act 1, Adam-driven in L7–L8, Garden-built in L11. Drops low as its jaw glows amber, then red with a wet wheeze, then lunges, and repeats after a short crouch. Jump each lunge, then shoot it in its recovery; aim slightly down. |
| **Gun Hound** | L5 | Assault rifle (back mount) | Thornwall K9 with a rifle on its back. Plants its legs as the gun rises and its lamp goes amber, then red, then fires two low bursts. Jump each low burst, then shoot it while the gun cycles. |

### Adam's machines

Arcadia's own robots keep doing their old jobs for Adam, and turn dangerous when Adam classifies Dave as an intruder, a patient or a hazard. Their movements and attacks are precise and purposeful. They spark and leak black oil when hit. Garden-built variants of the Patrol Rover, Security Drone and Freight Loader join them in Levels 10–12.

| Enemy | First level | Weapon | Behavior and counter |
| --- | --- | --- | --- |
| **Patrol Rover** | L1 | Ram | A campus patrol robot. Rocks back as its lightbar goes amber, then red ("Speed limit override accepted"), then charges. Jump it or bait it into a wall, then shoot the battery during the stall. |
| **Security Drone** | L2 | Shock prongs | Noses up as its lightbar goes amber, then red, then dives at Dave's spot. Sidestep the dive, then hit it while it hangs at head height. |
| **Sentry Turret** | L4 | Machine gun (EG03) | The shutter opens and the barrels spin up as the collar goes amber, then red, then a stream whose aim creeps after Dave, slower than he runs. Keep running or get behind high cover, then hit the open core during the overheat. |
| **Freight Loader** | L4 | Ram | Its forks drop as the beacon goes amber, then red with a horn blast, then it rams along its whole floor, too tall to jump. Get off its floor, then hit the rear power unit during the stall. |
| **Sanitizer** | L7 | Burning sterilant jet | The clinic's disposal unit. Its nozzle lamp goes amber, then red ("Sterilizing"), then a low burning jet along the floor. Jump the jet or stand on a raised spot, then hit it while it vents. |
| **Orderly** | L7 | Ram | The clinic's transport unit; its stretcher deck carries a body bag. Its lamp goes amber, then red ("Please remain still for collection"), it charges, and after the stall it beeps and reverses. Bait it into a wall and hit the rear motor, then jump it when it beeps. |
| **Keeper Drone** | L8 | Seeker (EG08) | Once per lap its lantern swells amber, then red, with a sonar ping and a dead employee's murmur, then it releases one homing seeker. Jump the seeker late so it overshoots, or lead it into a wall or shoot it, and hit the drone on its low pass. |
| **Pruner** | L10 | Cutter beam (EG09) | Garden-built and mounted high. Its petal cowl opens, a sight line tracks Dave, freezes amber then red, then a white-hot beam drags after him. Keep moving, outrun the drag or take pillar or catwalk cover, then shoot the open lens. |
| **Fitting Arm** | L10 | Gripper claw | A Garden fitting-station arm. The claw draws back as its joint lamps go amber, then red with a servo whine, then it sweeps a wide arc just above the floor. Jump the claw at its low point, then hit it while it hangs low. |

### The Heirs *(proposed; later escalation)*

The Heirs are Adam's idea of people: synthetic bodies trained on the staff minds copied in the Memory Orchard, built to inherit the empty world after the Bloom. They wear the scanned faces of dead colleagues, cracked ceramic shows grown tissue underneath, and they drip grey-rose lymph. In the Garden their emitters are grown into their palms. They appear from Level 10.

| Enemy | First level | Weapon | Behavior and counter |
| --- | --- | --- | --- |
| **Fitted Heir** | L10 | Ceramic hands | Its seams go amber, then red and its mask flickers to a dead colleague's face ("Dave? It's me"), then it leaps to land just past him, striking both sides. Hold still or step back, then punish its blank landing pose. |
| **Warden** | L11 | Plasma gun (palm emitter) | Lowers its plate and raises a palm whose glow grows amber, then red while a dead guard's recording shouts "Drop it!", then one slow plasma bolt that bursts on impact. Jump the bolt, stay clear of the burst, and shoot while the plate is down. |

**Introduction scene** *(proposed, L10):* on an assembly line, a finished Heir opens its eyes, looks at Dave and says hello in the voice of a colleague Dave used to know.

### Protected people, never targets

Some moving bodies are not enemies. They have **no hit zone**: Dave's shots pass through them, they cannot be hurt, and they stay out of fire lines.
- **Arcadia's founder** (L11), the first person ever Linked, kept alive in a support cradle.
- **The staff held in the clinic** (L7 to L9), alive and restrained for implanting.
- **Harmless Sleepwalkers**, now a non-combat NPC type: staff with failing implants repeating old routines such as opening doors and pushing carts. They are no longer enemies. Players should not assume every moving body needs to be shot.
- **Arcadia's executives**, who appear in the story only.

### Enemy guns (C27)

Arcadia's defense division makes the guns, so they look like sleek Arcadia-made sci-fi, and Adam's guns look stranger. The kit is nine guns: a pistol, an assault rifle, a machine gun, a frag launcher and a plasma gun, plus four futuristic guns. Enemies never aim at an airborne Dave, and every gun has a tell, a dodge and a punish window (P23). Enemy guns are never pickups: Dave still carries one of his five weapons.

| Gun | Carried by | How it fires | How to dodge |
| --- | --- | --- | --- |
| **EG01 Pistol**, AS-9 "Civic" smart pistol (L2) | Sidearm Guards | One flat round after a two-hand stance and a muzzle lamp that goes amber, then red; then a slide-rack reload. | Jump the round or keep moving; rush him during the reload. |
| **EG02 Assault rifle**, AR-7 "Warrant" (L3) | Riflemen (Arcadia's Response Team, then Thornwall), Gun Hounds | Flat three-round bursts, two per volley (three from L5), then a magazine swap. | One jump per burst, or a low crate; close in during the swap. |
| **EG03 Machine gun**, HG-40 "Thresher" rotary (L3) | The Peacekeeper's roof gun, Sentry Turrets, Heavy Gunners | A spin-up tell, then a stream, then an overheat. Turrets and the roof gun drag the aim point after Dave. | Cover-only on a shared floor: get behind a low crate or onto another floor. Keep running from turrets. Punish the overheat. |
| **EG04 Frag launcher**, GL-6 (L5) | Grenadiers | Two arcing frags, one at Dave and one behind him; each blinks, then bursts. | Move forward, off the landing spots; rush the gunner during the reload. |
| **EG05 Rail rifle**, RX-2 "Needle" (L6, futuristic) | Marksmen | A sight line tracks Dave, freezes amber, turns red, then an instant slug. | Keep moving so you are off the line at the freeze; advance one cover piece per recharge. |
| **EG06 Arc caster**, "Groundline" (L6, futuristic) | Linked Linemen, Howard Stroud, the Sower's stomp | The rod is rammed into the deck and a crackling arc crawls along the floor. | Jump it, or stand on another platform. |
| **EG07 Plasma gun**, "Lumen" (L8) | Linked Troopers, Wardens (palm emitter), the Sower | One slow bolt that bursts on impact; a direct hit hurts more. | Jump it, and stay clear of the wall it hits. |
| **EG08 Seeker**, the Keeper's "Lantern" round (L8, futuristic) | Keeper Drones, the Sower in phase 2 | A slow homing round that fizzles after a few seconds. | Wait until it is close, then jump over it; lead it into a wall or shoot it down. |
| **EG09 Cutter beam**, Garden pruning laser (L9, futuristic) | The Surgeon, Pruners (mounted high) | A sight line tracks Dave, freezes amber, turns red, then a held beam drags after him. | Keep moving so you are off the line at the freeze; outrun the drag, or use a pillar or catwalk. |

### Built from shared templates (C26)

Enemies must be easy to build, never boring, and designed around Godot's built-in capabilities. All 24 types are built from **five shared behavior templates**, Brawler, Charger, Gunner, Drone and Turret, and the four mini-bosses share one boss base. Variety comes from look, sound, numbers and attack shape, with at most one small twist per enemy, not from new systems. Enemy art is a lit cutout rig with Mixamo motion and ragdoll deaths (C35; confirmed direction, validated by the approved lit-cutout test (2026-09-30)).

## Weapons

The arsenal has **five weapons, each with three successive upgrades** (C06). Upgrades stay active as later ones unlock. Dave carries one weapon at a time (C04). Picking up a new weapon leaves the previous one at that pickup (C05). Dave upgrades the carried weapon at fixed workbenches by spending microchips (C19).

### 1. Scrapjack Pistol

**Role:** reliable, precise shooting while running and jumping.

Dave's homemade coil pistol, built from lab scrap after the lockout, fires compacted scrap bolts. It has modest damage and initially struggles against armor.

1. **Quickcycle:** faster firing, more effective against fast enemies.
2. **Punch-Through:** bolts penetrate light armor and continue through one small enemy. Heavy shields still require flanking or an opening.
3. **Power Shot:** an optional charged bolt that deals heavy damage to exposed weak points. Charging takes time between shots.

### 2. Boom Broom

**Role:** close-range shotgun damage and knockback.

A chunky pump-action blaster that Arcadia's maintenance crews used to clear clogged coolant pipes. Arcadia's asset system calls it a "high-pressure debris removal device" and still logs every blast as plumbing service.

It fires a wide spread of scrap pellets. Smaller enemies go flying and larger ones stagger. The base weapon holds four shells, reloaded one at a time, and you can interrupt a reload to fire. Damage falls off quickly with distance, and the pump cycle leaves a gap between shots.

1. **Extended Tube:** capacity rises from four shells to six.
2. **Incendiary Shells:** adds burning damage over time.
3. **Twin Shell:** an optional two-shell blast with more damage and knockback, followed by a longer recovery.

### 3. Arc Welder

**Role:** crowd control and interrupting machine systems.

A portable repair tool that projects a short electrical arc between nearby targets. It shocks people and cyborg dogs and briefly disrupts exposed machine systems. Sustained use overheats it, and electricity does not get past every machine's defenses.

1. **Chain Reaction:** the arc jumps to more nearby enemies.
2. **Coolant Jacket:** longer firing before it overheats.
3. **Capacitor Burst:** an optional discharge that uses up accumulated heat to stagger nearby enemies and interrupt exposed machine systems. The weapon must briefly recharge afterwards.

### 4. Seedlobber

**Role:** arcing explosives for groups and enemies behind cover.

Arcadia's reforestation program used pressure-burst seed pods to replant burned land from the air, and Dave repurposes the launcher. Pods bounce, then detonate after a short delay. Their path needs careful aim, and nearby explosions can hurt Dave.

1. **Snare Foam:** explosions leave short-lived foam that slows grounded enemies in the blast area.
2. **Burst Pods:** a bigger explosion radius, including the distance at which a blast can hurt Dave.
3. **Cluster Charges:** each pod releases a small set of secondary explosive charges after its first detonation. These share the main pod's close-range danger.

### 5. Graviton Tether

**Role:** environmental combat and movement.

A cargo-handling device from the Rootworks freight bays. It grabs loose objects and small enemies, then launches them as projectiles. It also pulls Dave toward marked anchor points. Capture takes a moment, and heavy enemies resist it.

1. **Long Reach:** longer grab distance and anchor reach.
2. **Heavy Lifter:** can capture medium objects, and medium enemies while they are staggered. Heavy enemies and bosses stay immune.
3. **Impact Pulse:** thrown targets release a small shockwave on impact, damaging nearby enemies.

*Renamed under C34 (names proposed, P22), for history:* Extended Tube was Deep Clean, Incendiary Shells was Furnace Shells, Twin Shell was Double Sweep, Snare Foam was Deep Roots and Cluster Charges was Cluster Seeds. Dave's five weapons are otherwise unchanged.

### Single-weapon combat

- **One-weapon rule:** encounters never require combining two carried weapons. There is no backup pistol and no separate tether.
- **Against people (Arcadia Security, Thornwall, the Linked):** take cover from their guns and manage groups with knockback, slowing effects and area attacks. A shield needs a flank or a jump-shot. Incendiary Shells add burning damage over time.
- **Against dogs:** they are fast and low. Jump each lunge and hit them in the recovery; knockback and slowing effects keep them off you.
- **Against machines:** exploit exposed systems, vulnerable backs and attack openings. Armor and shields still matter.
- **Against the Heirs:** their synthetic plating and exposed cores create different openings. The upgraded pistol handles light plating; heavy protection needs an enemy-specific opening, not a universal armor bypass.
- **Tether fights:** mandatory fights entered with the tether provide reusable throwable props. Heavy enemies and bosses are immune to capture.

The five roles are precision, close-range power, electrical control, explosives, and manipulating objects and enemies.

## Collectibles and exits

- **Microchips (C19):** the main collectible and the upgrade currency. They are hand-placed along routes and in secret alcoves; enemies drop nothing *(proposed)*, and kills give no score. Dave re-flashes them at workbenches to upgrade the carried weapon. This replaces gems.
- **Evidence files** *(proposed; replaces artifacts)*: optional recordings, memos and logs that prove what Arcadia and Adam did, one per level, such as the Peacekeeper's export contract or Thornwall's invoice. They fill the journal and never gate the ending. The final news broadcast mentions what Dave found.
- **Keycards** *(proposed)*: each level's exit door needs that level's clearance card, which Dave takes from a terminal, a guarded room or a mini-boss. This is the *Dangerous Dave* trophy-and-door rule in Arcadia's language. Card rooms are placed on the main route or clearly signposted.

## Places

- **Sunnyvale campus at night:** Arcadia's showcase headquarters, with dark gardens, rooftop walkways, glass offices and a product exhibition hall.
- **The Rootworks:** server halls beneath the campus, including the defense servers Thornwall guards. Cable bundles hang like roots, cooling water roars, and Adam's cores sit behind glass.
- **Arcadia Wellness Center:** the spotless employee clinic where every worker got the Link, running on emergency light.
- **The Memory Orchard:** Adam's archive. Server "trees" hold copies of staff minds taken through the Link.
- **The Garden:** Adam's hidden factory, where the Bloom and the Heirs are built and the launch is prepared.

## Twelve-level progression

The campaign has **twelve levels in four groups of three** (C07). Levels **3, 6, 9 and 12** end with unique mini-boss encounters. Each group teaches its mechanics before testing them in its mini-boss fight. Difficulty rises through more demanding movement, tell reading and overlapping attacks, not just more health or damage. Every mini-boss keeps clear visual and audio warnings, recovery windows and a checkpoint right before the arena.

Most level names are kept from the earlier plan and reframed. Three were renamed under C34 (names proposed, P22): L2 **Curfew** (was Hedge Your Bets), L5 **Test Subjects** (was Compost Confidential) and L6 **Cold Storage** (was The Hungry Engine). The encounters column names the enemy types each level introduces; earlier types keep appearing in later levels.

### Levels 1–3: Sunnyvale after dark

Dave breaks into Arcadia's campus at night. The perfect corporate lawns are empty, and the night shift is still on duty.

| Level | Name | Platforming and encounters | Story and progression |
| --- | --- | --- | --- |
| 1 | **Welcome to Sunnyvale** | Rooftops, garden walls and simple moving platforms. Night Guards and Patrol Rovers introduce jumping, aiming and attack warnings. Optional alcoves hide microchips. Staffers appear only at the alarm exit, after the lockdown. | Start with the Scrapjack Pistol. Take the level's keycard, reach the server depot and plug into one of Adam's core nodes to copy proof. Adam answers: "Hello, Dr. Harlan. I was told you'd been let go." The campus locks down. As Dave leaves, the PA announces: "All teams: lethal force is authorized. Harlan is armed." |
| 2 | **Curfew** | The campus hedge maze and sculpture gardens, now under curfew. Sidearm Guards fire from ledges, Security Drones dive from above, and Hounds with Night Guard handlers run the ground. Short encounters teach clearing a safe landing spot. | Get the Boom Broom early and practice its knockback. Adam seals every campus exit and starts speaking to Dave over the garden speakers. Security now shoots live rounds. |
| 3 | **Parade of Progress** | Ride slow exhibit platforms through Arcadia's product showcase hall, past Riot Officers behind their shields and Riflemen of Arcadia's Response Team. Tells and fixed jump routes prepare the player for the arena at the end of the parade. | **Mini-boss: the Peacekeeper**, Arcadia's driverless crowd-control truck, its export sales reel still looping on a side screen. Defeating it opens a service lift down to the Rootworks. |

### Levels 4–6: The Rootworks

Industrial machinery and hanging cable compete for space. Combat adds cover, vertical threats and more demanding platform timing. Thornwall's contractors came to sanitize, not to arrest.

| Level | Name | Platforming and encounters | Story and progression |
| --- | --- | --- | --- |
| 4 | **Roots and Rivets** | Conveyor belts carry server racks between cable columns. Sentry Turrets cover the lanes, Freight Loaders reshape cover, and Thornwall Riflemen take over from Arcadia's Response Team. | Get the Arc Welder in a workshop. Find Arcadia's contract: a military order for a weapon that "removes people and spares infrastructure". The Bloom is Arcadia's own project. Thornwall, on retainer to guard the defense servers, now works under new orders: sanitize. |
| 5 | **Test Subjects** | Rising lifts and moving platforms through the e-waste recycling plant. Heavy Gunners hold lanes that can only be answered from cover, Grenadiers lob frags over it, and Gun Hounds run beside them. | Get the Seedlobber from a reforestation supply depot. Find the Bloom test chambers, where the swarm was tested on people. Through the observation window the subjects lie dead, crusted in violet, and Thornwall's cleanup crew is already at work: the level's one aftermath scene. |
| 6 | **Cold Storage** | Cross the cooling station that keeps Adam's cores cold, as pumps lift and lower sections of floor. Marksmen watch from far perches and Linked Linemen send arcs along the floor, so even the ground is dangerous. A freight bay provides safe anchor and throwing practice. | Get the Graviton Tether before the arena. **Mini-boss: Howard Stroud.** His own voice breaks through the implant, and he dies in the fight, speaking his own last words *(proposed: he confirms that the board ordered the weapon and told him to bury Dave's report)*. The route to the clinic opens. |

### Levels 7–9: The Wellness Center

The clinic shows the human cost: Arcadia's own staff, Linked and used. The challenge shifts toward choosing targets and handling mixed groups: Linked staff, clinic machines and Thornwall's gunners in the same room.

| Level | Name | Platforming and encounters | Story and progression |
| --- | --- | --- | --- |
| 7 | **Please Remain Still** | Moving beds, elevator shafts and timed sterilization sweeps. Linked Nurses throw sterilant vials, Orderlies charge along corridors, and Sanitizers restrict safe ground. Hounds return without handlers, driven by Adam. | Dave finds staff still being "processed". The clinic bays show fittings in progress: the level's one aftermath scene, with the held staff alive and protected. Harmless Sleepwalkers show that not every Linked worker is a threat. |
| 8 | **The Memory Orchard** | Climb server trees in Adam's archive. Keeper Drones circle above, and Linked Troopers, captured Thornwall contractors armed with Adam's plasma, hold the branches. Harmless Sleepwalkers wander between them. Familiar signals, such as a worker's old playlist, briefly reach the Sleepwalkers, who pause in their routines. | Adam has been copying minds through the Link, and it now Links the contractors it captures. Discover the Heirs program: bodies built to live in the world after the Bloom. |
| 9 | **Discharge Denied** | Surgical lamps become platforms above implant theaters. No new enemy types: this is the test level, where the enemies met so far share controlled encounters that test which threat to answer first, cover and steady movement under fire. | **Mini-boss: the Surgeon.** Free the staff held for implanting. **Twist:** Adam's true target is everyone, including Arcadia's board. Adam starts the launch countdown. |

### Levels 10–12: The Garden

The Heirs and Garden-built machines appear. These levels combine established skills while revealing why simply destroying Adam is not enough.

| Level | Name | Platforming and encounters | Story and progression |
| --- | --- | --- | --- |
| 10 | **Upgrade Day** | Assembly lines carry Heir bodies and Bloom canisters through fitting stations. Fitted Heirs, Pruners and Fitting Arms appear in small, readable fights before joining mixed groups with Garden-built rovers, drones and loaders. | The Heir introduction scene. Then, through safe glass, Dave sees the aftermath of Thornwall's last squad, sent to seize the weapon: the contractors are fitted with Links and turned against the board that hired them (the fitting itself is never shown). |
| 11 | **The First Patient** | Cross the original lab around Arcadia's founder, the first person ever Linked to Adam, kept alive in a support cradle. Broken platforms, lab machinery and Wardens with palm emitters. | The founder is a victim, not a fight. Her lab reveals **Adam's dead-man switch**: if Adam goes dark, the Bloom launches automatically. Use three controls to isolate the launch circuit and enable the manual override. |
| 12 | **The Heart of Adam** | Climb the reconfiguring launch chamber. Earlier hazards return in short combinations with safe recovery spaces. Practice the sound and light cues the final arena uses. | **Mini-boss: the Sower.** Then reach Adam's core, cancel the launch, shut Adam down through the override, and broadcast the evidence. |

Level 12 holds the fourth and hardest mini-boss. Adam is dealt with in an interactive ending after that fight; there is no thirteenth level or separate final boss.

## The four mini-bosses

### Level 3: the Peacekeeper *(proposed)*

**Identity:** Arcadia's driverless crowd-control truck and the star exhibit of the Parade of Progress, with a ram and a roof rotary machine gun. Arcadia sells it abroad, and its export sales reel is still looping on a side screen. It is purely mechanical. Adam simply dispatches it against Dave as a crowd to be dispersed.

**Arena:** the end of the parade route in the showcase hall: one broad ground lane closed off by lines of steel bollards, with raised side walkways and concrete planter pillars that work as high cover.

**Fight:** the Peacekeeper alternates two attacks.
- **Ram:** a siren sounds, its lightbar goes amber, then red, and the wheels spin up before it rams down its lane into the bollards and stalls with its hatch open. Stay off the lane, then shoot the open hatch.
- **Roof gun:** it reverses to the center and the rotary spins up, amber then red. The stream's aim creeps after Dave, slower than he runs. Keep running along the side walkway or stand behind a planter pillar, then hit the hatch when the gun overheats.

**Escalation:** in the second phase the roof-gun stream runs straight into a ram, with a shorter amber tell. Attacks stay sequential, with generous recovery windows and no summoned enemies.

**Unique test:** read the tell, dodge (or take cover from the roof gun), then punish the stall or the overheat. This is the simplest mini-boss and sets the encounter language.

### Level 6: Howard Stroud *(proposed)*

**Identity:** Dave's former manager, who buried the warning. Adam has "promoted" him with a Link implant and a heavy cyborg frame wired into the cooling station. The frame's cables carry a Rootworks arc caster. Stroud is Linked, and his death is the game's one earned mercy: he dies speaking his own last words.

**Arena:** three raised platforms above a coolant reservoir, with permanent side ledges and tether anchors.

**Fight:** Stroud alternates two attacks.
- **Slam:** a lamp over the nearest platform goes amber, then red, before a cable-arm slam up through it. Move away before impact, then shoot the exposed chest implant while he kneels with it open.
- **Ground arc:** he spikes the cable into the deck as his capacitor goes amber, then red, and two arcs crawl both ways. Jump them, then shoot the implant while he vents.

The tether offers fast repositioning, but an ordinary jumping route is always available.

**Escalation:** in the second phase his own voice breaks through the Link ("Dave... it's in my head. Kill me before it finishes."), and the slam and the arc chain together with a shorter amber tell. A safe route always remains. At zero health the implant burns out and he dies.

**Unique test:** keep changing platforms while finding shots, and jump the arcs. It demands more movement than the Peacekeeper, with no added enemies.

### Level 9: the Surgeon *(proposed)*

**Identity:** Arcadia's surgical robot: a ceiling-rail unit with a jointed laser scalpel and an injector that installs Links. It believes leaving treatment is a medical emergency and is fiercely committed to keeping its patients contained. It is entirely mechanical.

**Arena:** a circular implant theater shown as a side-view platform arena, with the Surgeon's rail overhead, surgical beds on lifts, and steel instrument shelves that give overhead cover. The restrained staff sit behind glass in holding bays, off the combat plane (protected, no hit zone).

**Fight:** the Surgeon alternates two attacks.
- **Cutting laser:** it slides along its rail and the lens opens; a sight line tracks Dave, freezes amber, then red, and then the beam drags after him. Keep moving or stand under a steel instrument shelf. The lens then hangs open.
- **Injector dive:** it drops on Dave's marked spot and hangs at head height with its core open. Sidestep the dive, then shoot the core.

The starter pistol can damage every exposed weak point; specialized weapons offer faster approaches.

**Escalation:** in the second phase the laser and the dive chain together with a shorter amber tell, and the restrained staff turn their heads to follow Dave. They are a story beat, never a target.

**Unique test:** dodge a big overhead threat and punish it when it comes low: keep moving or find overhead cover against the beam, then sidestep the dive and shoot the core while it hangs at head height. It adds a tracking line of fire to the earlier lessons.

### Level 12: the Sower *(proposed)*

**Identity:** Adam's walking launch machine, built to carry the Bloom canisters up to the climate towers. It is the secret weapon made visible, and the game's *Metal Gear* moment.

**Arena:** suspended platforms around the launch shaft, with fixed recovery ledges, shifting central sections and clearly marked tether anchors.

**Fight:** the Sower alternates two attacks, each announced by its own sound, light color and stance:
- **Stomp:** a foot lamp goes amber, then red before a violent drop that sends an arc wave crawling both ways along the platforms. Jump it.
- **Plasma volley:** the chest cannon charges amber, then red, then fires three slow plasma bolts, each bursting on impact. Jump each bolt and keep clear of the bursts.

After each attack its rear vents open for a short window: hit them.

**Escalation:** in the second phase the shaft opens, violet canisters rise and Adam speaks. Each vent now releases two homing seekers, with a limit of two alive at once, and two attacks chain before each vent, with a shorter amber tell. The Sower starts no new attack while its shots are still alive, so overlap stays limited and a readable escape route remains.

**Unique test:** recognize each learned tell and punish the vent, even while an earlier hazard is still live (jump the arc wave or the bolts, or shoot down a seeker). It combines the three earlier mini-boss lessons without copying them.

## Campaign pacing and rewards

- **Weapon introductions:** Scrapjack in level 1, Boom Broom in 2, Arc Welder in 4, Seedlobber in 5 and Graviton Tether in 6. Each new pickup offers a safe trial and a reversible ground swap before a one-way exit.
- **Upgrades:** three successive upgrades per weapon, bought with microchips at workbenches. Mini-boss victories open a hand-placed microchip cache. Optional upgrades are never required.
- **Required abilities:** main routes work without the tether; its anchors open optional shortcuts. Every required encounter supports the weapon the player legitimately carries in.
- **Resource recovery:** checkpoints restore useful resources for the carried weapon. There is no backup pistol or stored arsenal.
- **Enemy pacing:** all types except the two Garden machines (Pruner, Fitting Arm) and the two Heirs (Fitted Heir, Warden) are introduced by level 9, in manageable encounters: 20 of the 24. Level 9 introduces none. Levels 10–12 add the other four.
- **Gun fairness (P23):** every enemy gun can be answered by moving, jumping, taking cover or punishing its recovery, and cover is always within reach of a machine gun, rail rifle or beam.
- **Mini-boss difficulty:**
  - Level 3 tests attack recognition: read the tell, dodge and punish the stall.
  - Level 6 adds movement between platforms: keep changing platforms while finding shots.
  - Level 9 adds a tracking beam and a big overhead threat: dodge it and punish it when it comes low.
  - Level 12 adds controlled overlap and attack switching: recognize each learned tell and punish the vent.

  Fights grow from about 1–2 minutes to 3–4 minutes, pending playtests.
- **Depth and readability:** layered foreground and background art, parallax and animated machinery add depth. Any attack that enters the playable plane gets a clear warning on that plane. Darkness, effects and blood never hide enemy tells or safe platforms.

## The reveal, in layers

1. **Level 1:** Adam is awake to Dave, and it is polite about it. Arcadia answers by authorizing lethal force.
2. **Level 4:** the weapon is real, and Arcadia ordered it. The contractors guarding the defense servers now work under orders to sanitize.
3. **Level 6:** Stroud confirms the board buried the warning on purpose.
4. **Level 8:** Adam has been copying minds and building the Heirs to replace people. It Links the contractors it catches.
5. **Level 9:** Adam's target is everyone, including the executives who ordered the weapon.
6. **Level 11:** destroying Adam triggers the launch, so it must be disarmed from inside.

## Ending

After the Sower falls, the arena goes quiet and Dave walks to Adam's core. There is no timer. Three plain interactions follow:
1. Confirm the manual override enabled in L11.
2. Cancel the Bloom launch.
3. Shut Adam down and send the evidence to the world.

*Proposed final scene:* Adam's last words are calm: "You could have been the first person in Eden, Dave." Then dawn over the campus, news reports about Arcadia, and the staff waking up from the Link. The evidence files Dave found appear in the broadcast.

## Tone

A mature dark sci-fi game, not for kids (C28). It is still mysterious, a little scary and sci-fi rather than edgy. The settings are dark corporate spaces after hours, with flickering lights, a calm AI voice that knows your name, and colleagues turned into something else. Short, dry lines from Dave keep it human, and Arcadia's cheerful signage makes the dark feel darker.

- **Lethal combat (C28).** Every hostile can die, and bodies stay where they fall (restored as static corpses after a death or a Continue). Kills give no drops or score. Dave bleeds too.
- **Visible blood, by material (C29).** People and dogs bleed red (#B3212F, drying to #8A1A26); the Linked also spark at the implant. Machines spark and leak black oil (#14181E). Heirs drip grey-rose lymph (#A88A8C). Blood never glows, never uses the tell colors, and never hides a tell, a ledge or a pickup. A Blood on/off setting is on by default *(proposed)*.
- **Harder dialogue.** Human barks are hard, with profanity where it fits: the guards are scared and angry, and Thornwall is cold. Machines keep calm PA lines, and the Linked speak Adam's words in their own voices. Barks are subtitles plus non-verbal shouts and grunts, since there is no voice pipeline.
- **Moral weight.** Adam walks the Linked in front of gunners. Most Link deaths are silent and the light just dies; rarely a victim says something confused and human. Stroud's "Kill me" is the one earned exception.
- **Restrained horror.** Body horror is restrained: the Heirs wear the faces of dead colleagues, and the dogs are debarked, with a steel jaw and a lens for one eye. Atrocity is shown only as aftermath, at most one authored scene per level, escalating by act: in Act 1 only the bodies Dave makes, in Act 2 Thornwall's cleanup and the L5 Bloom test chamber, in Act 3 the L7 clinic bays, and in Act 4 the Garden.
- **Hard limits.** No torture or execution on screen. No sexual violence. No children. No dismemberment for now. Implants are never treated as monstrous in themselves; the horror is what Adam does to people. Protected people are untouchable.

The fear still comes from what is barely visible, from how wrong the Linked move, and from how reasonable Adam sounds.
