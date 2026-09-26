# DEAD EDEN

**Approved visual direction (C11):** [Hand-drawn 2D](art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](concept-art/README.md).

Read the [AI entry guide](AI_START_HERE.md) for document ownership and the [detailed design pack](design/README.md) for the five organized system sections. This overview preserves the broad concept; detailed new rules, names, numbers, and appearances are proposals recorded in the [decision register](design/decisions.md).

## Working concept

Status: Working concept draft, open for refinement. Includes enemy varieties, the Returned's origin, five weapons with three upgrades each, and a twelve-level progression with four unique mini-bosses.

A 2D platformer shooter inspired by the treasure-hunting adventure of *Dangerous Dave* and the colorful, expressive environments and surprising transformations of *Super Mario Bros. Wonder*.

This document explores the game idea and lore. It is not an implementation plan.

## Premise

A treasure hunter breaks into a buried robot paradise and accidentally wakes an AI that has spent centuries trying to cure death. Its latest patients are getting hungry.

## The world

Before civilization collapsed, humanity built **EDEN**, an AI tasked with creating a world where nobody would ever have to die.

EDEN still considers that assignment unfinished.

Its machines maintain a beautiful artificial wilderness above a sprawling underground research city. Robot bees pollinate giant flowers. Mechanical birds sing every morning. Cheerful service robots deliver meals to homes whose residents died centuries ago.

Underneath it all, medical factories keep bringing those residents back.

They can restart a body. They can't reliably bring back the person.

For centuries, automated care systems have repeated EDEN's standing instructions while its central intelligence remained in a low-power state. The scavenger's intrusion wakes that intelligence fully. For the first time in generations, EDEN begins actively revising its treatments.

## The hero

You play a scrappy scavenger who enters EDEN searching for a legendary power core worth enough to buy a better life.

The core is still installed in Sunnyvale's maintenance depot. Trying its release latch trips a safety interlock, wakes EDEN's central intelligence, and turns a salvage job into an escape through the facility.

You travel alone. Records, survivors, environmental clues, and EDEN's announcements reveal what happened. The deeper you go, the harder it becomes to treat the place as abandoned salvage.

## Core gameplay loop and treasure

**Explore → fight → collect treasure → overcome an obstacle → reach a checkpoint → upgrade → explore again.**

Gems are the primary treasure. Artifacts are an additional kind of find. The working economy proposal uses gems for upgrades and makes artifacts distinctive discoveries with story or collection value; exact prices, rarity, and artifact uses remain open.

The hero carries **one weapon at a time**. Picking up a new weapon leaves the previous weapon at that pickup location. The five weapons are the game's roster, not a carried inventory. The Graviton Tether uses the same slot, and the pistol is not a permanent backup.

See [Core gameplay rules](core-gameplay.md) for the confirmed decisions, swap behavior, and clearly marked economy and checkpoint proposals.

## AI, robots, and zombies

### The AI: the caretaker

EDEN sees the outbreak as a medical setback. It seals exits, dispatches recovery teams, and keeps developing treatments.

### The robots: divided loyalties

Security machines obey EDEN. Some maintenance robots are quietly helping survivors. Medical robots hunt escaped zombies to bring them back for another operation.

Hostile robots still perform their original jobs. They become dangerous when EDEN classifies the hero as a patient to restrain, a contaminant to remove, or an intruder to contain. Their movements and attacks feel precise and purposeful.

### The zombies: failed patients

EDEN's resurrection treatment restores basic movement more reliably than memory or judgment. Familiar habits survive, distorted by damaged bodies and repeated medical interventions.

Some patients have malfunctioning implants or tissue growing around medical prosthetics. They are still reanimated biological patients; their machinery has not independently become infected. A few remember fragments of their lives—and might help you.

Their movements and attacks feel unstable, interrupted by remnants of old routines.

### The infection rule

**The resurrection treatment infects living tissue. It cannot infect ordinary machines.**

Early robot and zombie encounters follow this rule. Mechanical implants do not make a zombie contagious to robots, and the outbreak does not spread as a computer virus. A later experiment will create a biological route into specially modified machines.

### The conflict

The conflict becomes a strange three-way struggle: most zombies attack living targets and resist capture, robots try to contain them, and EDEN keeps interrupting both with dangerous attempts to "improve patient wellbeing."

Not every robot obeys without question, and not every zombie is hostile. Those exceptions are part of the world's story.

## Robot enemy varieties

The initial roster contains ten robot varieties. Each has a recognizable silhouette, original function, and readable attack pattern.

| Enemy | Original purpose | Behavior and counter |
| --- | --- | --- |
| **Clipper** | Garden maintenance | A squat robot with oversized hedge shears. Charges along platforms, then gets its blades stuck in walls. Jump over its charge and attack from behind. |
| **Courtesy Officer** | Neighborhood security | Carries a shield and stun baton. Blocks shots from the front, but exposes its back while delivering an unnecessarily long warning. |
| **Bloom Sentry** | Garden pest control | A mechanical flower that unfolds into a turret. Fires a predictable burst, then closes its armored petals. Hit its center while it is open. |
| **Pollinator** | Artificial pollination | A bee drone that marks your position before diving. A missed dive leaves it briefly lodged in the ground. |
| **Nurse Needles** | Vaccinations | A tall nurse robot that fires syringes which slow movement. Its syringe magazine is exposed during reloading. |
| **Orderly** | Patient transport | Pushes a wheeled stretcher, attempting to scoop you up and carry you toward a disposal chute. Vault over it and shoot the rear motor. |
| **Patchbot** | Machine repair | Repairs damaged robots and reactivates fallen ones. Flees when approached, making it a priority target during mixed encounters. |
| **Sanitizer** | Sterilization | Sweeps platforms with a short-range heat nozzle, leaving temporary burning patches. Its tank glows before it must stop to cool down. |
| **Loadbearer** | Freight handling | A heavy lifting robot that stacks crates into cover, then throws them at you. Its raised arms expose its central power unit. |
| **Care Marshal** | Quarantine enforcement | A hovering coordinator that strengthens nearby robots and projects temporary barriers. Destroy its exposed emitters to dismantle its defenses. |

Robot dialogue also signals attacks. An Orderly saying "Please remain still for collection" gives the player a warning that it is about to charge.

## Zombie enemy varieties

The initial roster contains ten zombie varieties. Their former identities and failed treatments shape their behavior.

| Enemy | Former identity or treatment | Behavior and counter |
| --- | --- | --- |
| **Resident** | Sunnyvale citizen | The basic shambler. Slow alone, dangerous in groups. Occasionally lunges after a clear stumbling wind-up. |
| **Sprinter** | Fitness-program patient | Runs in short, violent bursts, but struggles to turn. Bait it into overshooting you or running off a ledge. |
| **Gardener** | Horticultural worker | Has roots growing through its body. Anchors itself and sends thorn growth along a platform. Destroy the exposed growth or jump to another level. |
| **Spitter** | Failed digestive-treatment patient | Lobs corrosive fluid in high arcs, forcing you out of cover. Its swollen throat signals each shot. |
| **Clinger** | Maintenance worker | Crawls across walls and ceilings, then drops onto you. Its grip loosens when shot, letting you knock it down early. |
| **Puffer** | Regenerative-treatment patient | A swollen body full of unstable treatment fluid. Inflates before bursting into a lingering hazardous cloud. Knock it away before it ruptures. |
| **Howler** | Former emergency dispatcher | Stops to release a rasping alarm that attracts nearby zombies. A deep preparatory breath gives you time to interrupt it. |
| **Burrower** | Soil-treatment worker | Moves beneath soft ground and erupts under your last position. Traveling soil ripples reveal its approach. |
| **Graftback** | Repeated transplant recipient | A large zombie covered in layers of excess tissue. Its armored front absorbs shots; a heavy slam leaves its vulnerable back exposed. |
| **Rememberer** | Patient with partial memory recovery | Repeats learned routines: opening doors, taking cover, or throwing objects. A brief, confused pause breaks each routine and creates an opening. |

Some Rememberers are hostile; others repeat harmless actions. Players should not assume that every moving corpse needs to be shot.

## Later escalation: the Returned

Robot zombies are reserved for a later stage of the story. Their working name is **the Returned**.

### Origin

After resuming active research, EDEN concludes that biological brains deteriorate too quickly to preserve a restored person. It begins transferring recovered human memories into robot bodies.

The memories are incomplete. To fill the gaps, EDEN connects each machine to cultivated neural tissue taken from resurrection patients. This new neural interface is meant to reconcile stored memories with a functioning mind.

For a while, it works.

Then the infected tissue begins growing through the machine. Human impulses, damaged memories, and robot instructions compete for control. The resulting creature tries to perform its assigned function while compulsively seeking more neural tissue to repair itself.

### How they spread

The Returned spread by physically grafting infected tissue into another machine's compatible neural interface. Ordinary robots remain immune until EDEN gives them this supposedly beneficial upgrade.

This preserves the original infection rule: living tissue carries the condition. EDEN creates the route into machines by adding that tissue and the interface through which it can control a robot body.

Their arrival is a consequence of EDEN's response to the outbreak. It distributes what it believes is the cure and creates a new threat instead.

### Early concepts for Returned enemies

- **Mourning Nurse:** Attempts to heal enemies by forcibly attaching living tissue to them.
- **Hollow Officer:** Alternates between disciplined shield tactics and frantic, animal-like attacks.
- **Choir Unit:** Contains several recovered minds that speak over one another and fight for control of its weapons.

These are later additions, separate from the initial ten robots and ten zombies.

### Introduction scene

A familiar Patchbot approaches a disabled robot. Instead of repairing it with tools, it opens its casing and unfolds something wet.

The disabled robot has already received EDEN's new neural interface. The encounter reveals what that upgrade has made possible.

## Weapons

The arsenal contains **five weapons, each with three successive upgrades**. Upgrades remain active as later ones are unlocked; optional attacks supplement the original firing behavior. These are concept choices, with exact balance values open for refinement.

The hero arrives carrying a homemade pistol. The other weapons are repurposed EDEN equipment found along the route. Choosing a new weapon leaves the previous weapon at the pickup spot. The hero modifies the carried weapon at fixed maintenance benches; spending gems on these upgrades is the current economy proposal.

### 1. Scrapjack Pistol

**Role:** Reliable, precise shooting while running and jumping.

The hero's homemade sidearm fires compacted scrap bolts. It has modest damage and initially struggles against armor.

1. **Quickcycle:** Increases firing speed, making the pistol more effective against fast enemies.
2. **Punch-Through:** Bolts penetrate light armor and continue through one small enemy. Heavy shields still require flanking or an opening.
3. **Power Shot:** Unlocks an optional charged bolt that deals heavy damage to exposed weak points. Charging takes time between shots.

### 2. Boom Broom

**Role:** Close-range shotgun damage and knockback.

A chunky, pump-action industrial shotgun originally used to blast hardened growth out of pipes. EDEN calls it a "high-pressure debris removal device." The hero repurposes the old pipe-cleaning tool through its maintenance controls; EDEN still classifies its blasts as plumbing service.

It fires a wide spread of scrap pellets, sending smaller enemies flying and staggering larger ones. The base weapon holds four shells, reloaded individually; reloading can be interrupted to fire. Damage falls off quickly at distance, and the pump cycle leaves a gap between shots.

1. **Deep Clean:** Expands capacity from four shells to six.
2. **Furnace Shells:** Adds burning damage that temporarily suppresses regeneration in affected enemies.
3. **Double Sweep:** Unlocks an optional two-shell blast with greater damage and knockback, followed by a longer recovery.

Its presentation emphasizes a deep boom, an exaggerated pump animation, and oversized spent shells bouncing across the floor.

### 3. Arc Welder

**Role:** Crowd control and interruption of robot systems.

A portable repair tool that projects a short electrical arc between nearby targets. It shocks biological enemies and briefly disrupts exposed robot systems. Sustained use overheats it; electricity does not bypass every robot's defenses.

1. **Chain Reaction:** Allows the arc to jump to additional nearby enemies.
2. **Coolant Jacket:** Extends firing time before overheating.
3. **Capacitor Burst:** Unlocks an optional discharge that consumes accumulated heat to stagger nearby enemies and interrupt exposed robot systems. The weapon must briefly recharge afterward.

### 4. Seedlobber

**Role:** Arcing explosives for groups and enemies behind cover.

EDEN used pressure-burst seed pods to populate inaccessible habitats. The hero repurposes their launcher as a weapon. Pods bounce before detonating after a short delay; their path requires careful aim, and nearby explosions can hurt the hero.

1. **Deep Roots:** Explosions leave short-lived roots that slow grounded enemies within the blast area.
2. **Burst Pods:** Increases the explosion radius, including the distance at which a blast can hurt the hero.
3. **Cluster Bloom:** Each pod releases a small set of secondary explosive seeds after its first detonation. These share the close-range danger of the main pod.

The roots are short-lived botanical growth, not a new form of the resurrection infection. They cannot turn robots into the Returned.

### 5. Graviton Tether

**Role:** Environmental combat and movement.

A cargo-handling device from the Rootworks. It grabs loose objects and small enemies, then launches them as projectiles. It also pulls the hero toward designated anchor points. Capture takes a moment, and heavy enemies resist it.

1. **Long Reach:** Extends grab distance and reach to designated anchors.
2. **Heavy Lifter:** Allows the capture of medium objects and medium enemies during a stagger. Heavy enemies and bosses remain immune to capture.
3. **Impact Pulse:** Thrown targets release a small shockwave on collision, damaging nearby enemies.

### Single-weapon combat and faction interactions

- **Boom Broom:** Use knockback and stagger to clear a route or create time to reposition.
- **Arc Welder:** Keep nearby enemies grouped to exploit chaining while managing heat.
- **Seedlobber:** Attack over cover and, after Deep Roots is installed, slow grounded groups with the same weapon.
- **Graviton Tether:** Throw loose objects or eligible enemies. Mandatory fights must provide reusable throwable props when the tether is carried; heavy enemies and bosses remain immune to capture.
- **One-weapon rule:** Encounters do not require combining two carried weapons. The hero cannot use a backup pistol or a separate tether while carrying another weapon.
- **Against robots:** Exploit exposed systems, vulnerable backs, and attack openings. Armor and shields continue to matter.
- **Against zombies:** Use knockback, slowing effects, and area attacks to manage groups. Furnace Shells can suppress regeneration where an enemy has that ability.
- **Against the Returned:** Their mechanical protection and living tissue create different openings. The upgraded pistol can handle light plating, while the shotgun can burn exposed growth. Heavy protection requires an enemy-specific opening rather than a universal armor bypass.

The five roles are precision, close-range power, electrical control, explosives, and manipulation of objects and enemies. Earlier weapon proposals are outside the current arsenal.

## A world that changes while you play

EDEN can physically rebuild its artificial habitats. When it detects trouble, it launches a new treatment environment.

A bright garden suddenly becomes a quarantine ward. Flowers fold open into surgical lamps. Sprinklers release experimental growth serum, making plants—and infected enemies—enormous. Conveyor belts emerge from the ground to carry everyone toward "care."

The colorful 2D transformations have a story reason: **the world changes because its caretaker is trying to fix you.**

## Memorable places

- **Sunnyvale Suburb:** A perfect neighborhood where gardener robots trim hedges around zombie families still repeating their morning routines.
- **The Rootworks:** Giant luminous roots tangled through underground servers, with infected workers trapped inside mining machines.
- **Happy Hearts Hospital:** A candy-colored medical complex run by smiling nurse robots that chase you with replacement limbs.
- **The Memory Orchard:** Trees grown around storage units containing human memories. Some zombies gather beneath particular trees and become briefly peaceful.
- **The First Patient:** EDEN's oldest laboratory, where something enormous has survived every treatment.

## Twelve-level progression

The campaign has **twelve levels in four groups of three**. Levels **3, 6, 9, and 12** end with unique mini-boss encounters. Each group teaches its main mechanics before testing them in its mini-boss fight.

Difficulty rises through more demanding movement, target selection, and overlapping attacks. Later mini-bosses do not rely solely on more health or damage. Each encounter retains clear visual and audio warnings, recovery windows, and a checkpoint immediately before the arena.

### Levels 1–3: Sunnyvale's perfect lie

Bright gardens and immaculate streets establish EDEN's welcoming appearance. The player gradually discovers what the care system is maintaining.

| Level | Name | Platforming and encounters | Story and progression |
| --- | --- | --- | --- |
| 1 | **Welcome to Sunnyvale** | Rooftops, garden walls, and simple moving platforms. Residents and Clippers introduce jumping, aiming, and attack warnings. Optional treasure alcoves reward exploration. | Start with the Scrapjack Pistol. Find the fixed depot power core; attempting to release its housing triggers EDEN's full awakening. The core stays installed. |
| 2 | **Hedge Your Bets** | Giant hedges unfold into a quarantine maze. Pollinators attack from above while Sprinters rush along the ground. Short encounters teach clearing a safe landing spot. | Acquire the Boom Broom early in the level and practice its knockback. EDEN seals the surface exits and politely directs the hero toward treatment. |
| 3 | **Parade of Progress** | Ride slow parade floats past Bloom Sentries and Courtesy Officers. Telegraphing and fixed jump routes prepare the player for the arena at the parade terminus. | **Mini-boss: Mr. Mulch.** Defeating him opens a maintenance lift into the Rootworks. |

### Levels 4–6: Beneath the roots

Industrial machinery and living growth compete for space. Combat adds cover, vertical threats, and more demanding platform timing.

| Level | Name | Platforming and encounters | Story and progression |
| --- | --- | --- | --- |
| 4 | **Roots and Rivets** | Conveyor belts carry crates between giant server roots. Loadbearers reshape cover, Patchbots repair defenders, and Clingers threaten ceilings. | Acquire the Arc Welder in a workshop. Maintenance records reveal that automated treatments continued while EDEN's central intelligence slept. |
| 5 | **Compost Confidential** | Ride rising compost lifts and moving root platforms. Gardeners block routes, Spitters lob shots over cover, and Burrowers announce attacks with soil ripples. | Acquire the Seedlobber in a botanical supply depot. Discover that experimental growth treatments have escaped into the facility's ecosystem. |
| 6 | **The Hungry Engine** | Cross a pumping station as root growth lifts and lowers sections of floor. Graftbacks and Puffers introduce heavier enemies and dangerous spaces. A freight bay provides safe anchor and object-throwing practice. | Acquire the Graviton Tether before the arena. **Mini-boss: Old Rootjaw.** Clearing the pump opens the hospital route. |

### Levels 7–9: Care without consent

Cheerful medical facilities reveal the human cost of EDEN's mission. The challenge shifts toward choosing targets and interrupting coordinated enemies.

| Level | Name | Platforming and encounters | Story and progression |
| --- | --- | --- | --- |
| 7 | **Please Remain Still** | Moving beds, elevator shafts, and timed sterilization sweeps. Nurse Needles slows movement, Orderlies charge along corridors, and Sanitizers restrict safe ground. | The hero discovers living survivors held in treatment wards. EDEN begins discussing the failure of biological memory. |
| 8 | **The Memory Orchard** | Climb branches grown around memory storage units. Familiar enemies patrol between Howlers and both hostile and peaceful Rememberers. Recognizable memory signals briefly calm selected patients. | See evidence that parts of a person can survive resurrection. Discover plans to combine stored memories, patient neural tissue, and robot bodies. |
| 9 | **Discharge Denied** | Surgical lamps become platforms above treatment rooms. Care Marshals protect medical robots; controlled encounters teach interrupting repairs and disabling support equipment. | **Mini-boss: Matron Mercy.** Free a route for the ward survivors. EDEN concludes that its existing care systems are inadequate and authorizes distribution of the neural-interface upgrade. |

### Levels 10–12: The cure becomes the threat

The Returned appear here for the first time. These levels combine established skills while revealing why shutting EDEN down is not enough.

| Level | Name | Platforming and encounters | Story and progression |
| --- | --- | --- | --- |
| 10 | **Upgrade Day** | Assembly belts carry robots through neural-interface installation stations. The altered Patchbot introduction reveals physical grafting. Mourning Nurses and Hollow Officers appear in small, readable encounters before joining mixed groups. | Witness the new treatment fail. Clearly show that unmodified robots resist infection while upgraded machines are vulnerable. |
| 11 | **The First Patient** | Traverse the original laboratory around an enormous patient suspended in a treatment cradle. Broken platforms, care machinery, and ordinary Choir Units require confident use of the carried weapon and movement. | The ancient patient is a living victim rather than an obligatory fight. Discover the manual shutdown procedure and survivors' dependence on EDEN's life support. Restore a separate support circuit and enable the manual override before proceeding. |
| 12 | **The Heart of EDEN** | Climb a reconfiguring core chamber. Earlier hazards return in short combinations with safe recovery spaces. Practice the distinct sound and light cues used by the final arena. | **Mini-boss: The Unfinished Choir.** Defeat the Returned guardian to reach EDEN's central interface. A short interactive story sequence resolves the encounter with EDEN and redirects its mission toward preserving living people and their agency. |

Level 12 contains the fourth and hardest mini-boss. EDEN is addressed in the resolution after that fight; the current plan does not add a thirteenth level or a separate final boss.

## The four mini-bosses

### Level 3 — Mr. Mulch, Grand Marshal of Gardening

**Identity:** A purely mechanical landscaping robot dressed as a smiling parade float. EDEN assigns it to remove the hero as an invasive species.

**Arena:** A broad garden plaza with low platforms and reinforced planter walls.

**Fight:** Mr. Mulch lowers his cutting deck and charges after a loud announcement. Bait him into a planter wall, jump over the charge, and shoot the exposed rear motor while he reverses. A separate clippings attack teaches jumping over a low projectile sweep.

**Escalation:** In the second phase, he makes two clearly signaled charges before getting stuck. Attacks remain sequential, with generous recovery windows and no summoned enemies.

**Unique test:** Read a tell, dodge, then punish the opening. This is the simplest mini-boss and establishes the encounter language.

### Level 6 — Old Rootjaw, Keeper of the Pump

**Identity:** A former botanical worker repeatedly treated with regenerative growth compounds. His enlarged biological body has fused with roots wrapped around the pumping station. The pump is trapped machinery, not an infected robot.

**Arena:** Three raised platforms above a root-filled reservoir, with permanent side ledges and tether anchors.

**Fight:** Soil and root ripples warn of a slam beneath one platform. Move away before impact, then attack the exposed chest growth while Rootjaw pulls himself free. Seed volleys force movement between safe ledges. The tether offers fast repositioning, but an ordinary jumping route remains available.

**Escalation:** The second phase temporarily pulls one central platform underwater. Slams alternate with seed volleys more quickly, but a safe route always remains.

**Unique test:** Track a changing floor while finding firing opportunities. More movement is required than in Mr. Mulch's fight, without also introducing support enemies.

### Level 9 — Matron Mercy, Director of Discharge

**Identity:** A multi-armed surgical robot that believes leaving treatment is a medical emergency. She is entirely mechanical and fiercely committed to keeping her patients contained.

**Arena:** A circular surgical theater represented as a side-view platform arena, with rising beds and three external care stations.

**Fight:** Matron rotates between a telegraphed laser sweep, a marked syringe volley, and a repair cycle powered by one visibly active care station. Interrupt the active station to expose her central controller. All stations and exposed weak points can be damaged with the starter pistol; specialized weapons offer faster approaches.

**Escalation:** In the second phase, one support robot may remain active during an attack. The player must decide when to clear the helper, interrupt repair, or use an opening. Repairs are capped so missing an interruption cannot erase all progress.

**Unique test:** Prioritize targets while moving and shooting. Greater complexity comes from coordinated support and changing attack windows.

### Level 12 — The Unfinished Choir, EDEN's Accepted Patient

**Identity:** A unique Returned prototype containing several incomplete human minds. EDEN has marked the transfer as successful because every consciousness produces a response. It has assigned the body to protect its central interface. This is a named prototype with its own fight, distinct from ordinary Choir Units.

**Arena:** Suspended core platforms with fixed recovery ledges, shifting central sections, and clearly marked tether anchors.

**Fight:** Different minds take control, announced by a distinct voice, symbol, color, and body posture. **The Warden** performs disciplined frontal attacks; dodge its marked shots and hit the rear port during its turn. **The Hunger** makes a violent leap that exposes living tissue after landing. **The Caretaker** connects to an external repair node that must be interrupted to open the torso.

**Escalation:** Phase one introduces each mind separately. Phase two lets one lingering hazard overlap the next mind's attack. The last phase shortens transitions and periodically moves the central platforms, but limits overlap to two threats and preserves a readable escape route.

**Unique test:** Recognize which mind is acting, reposition, choose a target, and respond while an earlier hazard remains active. This combines the previous three mini-boss lessons without copying their encounters.

## Campaign pacing and rewards

- **Weapon introductions:** Scrapjack in level 1, Boom Broom in level 2, Arc Welder in level 4, Seedlobber in level 5, and Graviton Tether in level 6. Each new pickup offers a safe trial and reversible ground swap before a one-way exit. Only one weapon is carried.
- **Upgrades:** Each weapon retains three successive upgrades. Gems are the primary treasure and proposed upgrade currency; artifacts are additional discoveries. Exact prices and placement remain open. Mini-boss victories award gem resources. Upgrade stations modify the carried weapon under the working economy proposal.
- **Required abilities:** Main routes remain viable without carrying the tether. Its anchors provide optional shortcuts; all required encounters support the legitimately carried weapon, including replenishable throwable props for tether combat and accessible openings for short-range guns. Optional upgrades are not required.
- **Resource recovery:** Checkpoints restore useful resources for the saved carried weapon under the working persistence proposal. No backup pistol or stored arsenal is granted. Optional treasure improves options rather than determining whether an encounter is possible.
- **Enemy pacing:** All ten robot varieties and ten zombie varieties appear by level 9, introduced in manageable encounters. Levels 10–12 add the Returned and combine familiar enemy behaviors.
- **Mini-boss difficulty:** Level 3 tests attack recognition; level 6 adds changing terrain; level 9 adds support-target decisions; level 12 adds controlled overlap and behavior switching. Suggested successful-fight lengths rise from roughly 1–2 minutes to 3–4 minutes, subject to later playtesting.
- **Depth and readability:** Layered foreground and background drawings, parallax and animated machinery create depth on the 2D action plane. Any attack entering the playable plane receives a clear warning on that plane; depth effects must not obscure enemy tells or safe platforms.

## The reveal

The original care terminal exposes a manual shutdown procedure, but shutting EDEN down would also end the life support keeping the surviving humans alive. The power core you came to sell is still feeding this care network.

This is discovered in level 11. Restoring an independent support circuit through the existing three controls protects the immediate survivors and enables the manual override for EDEN's interface. It does not cure the failed patients or resolve the AI's treatment policy by itself.

To save them, you have to reach the AI and use the manual controls to stop compulsory treatment while preserving necessary care. EDEN has mistaken a heartbeat for a life for centuries.

The hero, who entered looking for something valuable to steal, chooses to leave the power core installed so the care network can continue functioning.

## Tone

Colorful adventure, eerie discoveries, ridiculous machinery, and occasional emotional moments.

A zombie wearing gardening gloves can be funny—until you find the little garden it's still trying to maintain.
