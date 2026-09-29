# DEAD EDEN — Core gameplay rules

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](art-design/style-guide.md)).

For the complete specification, start with the [AI entry guide](AI_START_HERE.md), the [detailed design documents](design/README.md) and the [decision register](design/decisions.md). This file is the short overview; the detailed system files own the proposed rules.

## Confirmed decisions

The game remains a concept project, apart from the Level 1 prototype. These decisions take priority over earlier descriptions that assumed several carried weapons or a permanent backup pistol.

- **Solo hero (C12):** Dave Harlan explores alone, with no companion, follower or radio contact.
- **Core loop:** Explore → fight → collect treasure → overcome an obstacle → reach a checkpoint → upgrade → explore again.
- **Treasure (C19):** microchips. They are the collectible Dave gathers and spends on weapon upgrades.
- **Weapon limit:** Dave carries exactly one weapon at a time.
- **Weapon pickup:** taking a new weapon drops the previous one where the new weapon was found.
- **Arsenal:** five weapon types with three upgrades each. This is the total roster, not the number Dave carries.
- **No stealth (C16):** it is a run-and-gun platformer, with no vision cones, alerts or hiding.
- **Lethal, mature combat (C28, C29):** the game is not for kids. Enemies (people, dogs, machines and the Heirs) can die and their bodies stay, and blood is visible by material.
- **Armed enemies (C25, C27):** some enemies are human and carry guns from a nine-gun kit. Enemy guns are never pickups; Dave's arsenal stays five weapons.

## How the loop plays

| Step | Player experience | Purpose |
| --- | --- | --- |
| Explore | Read the route in the dark, spot enemies, look for alternate paths, microchips and the level's keycard. | Build curiosity and give the player choices. |
| Fight | Handle an encounter using the one carried weapon, cover and the environment. Read each enemy's tell, jump or take cover, then punish the opening. | Make positioning and familiarity with that weapon matter. |
| Collect treasure | Gather the microchips placed along the route and in alcoves; investigate promising places for evidence files. | Reward progress and exploration. |
| Overcome an obstacle | Cross a platforming section, use a visible switch, survive one of Adam's lockdown events, or exploit a weapon-appropriate opening. | Vary the challenge between fights. |
| Reach a checkpoint | Secure a safe stopping point and prepare for the next section. | Give relief and a clear sense of progress. |
| Upgrade | Re-flash microchips into the carried weapon at a workbench, when the checkpoint has one and Dave has enough chips. | Turn exploration rewards into a visible improvement. |

This is the recurring rhythm, not a rigid six-step lock on every room. Microchips can be collected while exploring, and a quiet story section need not contain a fight. Reaching a checkpoint never requires buying an upgrade before continuing.

## Treasure

### Microchips: the main collectible (C19)

Microchips are the main visible reward, drawn as small gold-contact chips (#FFD166) that glint in the dark:
- short chip trails suggest an optional jump;
- small groups reward a cleared encounter;
- larger caches reward a deliberate detour;
- enemies drop nothing *(proposed)*: every chip is hand-placed.

Chip placement must never misleadingly promise a safe landing where there is none.

**Working economy proposal:** spend microchips on weapon upgrades at workbenches. [Treasure economy](design/03-progression/treasure-economy.md) proposes chip values of 1/5/20, incremental upgrade prices of 40/90/160 and a twelve-level reward budget, all carried over from the earlier gem economy. These are untested defaults. [Checkpoint recovery](design/03-progression/health-and-checkpoints.md) defines the proposed collection rollback.

Do not silently add a second currency or a mandatory materials grind.

### Evidence files: optional finds (proposed)

Evidence files replace the old artifacts: memos, recordings, logs and photos that prove what Arcadia and Adam did. [Evidence files](design/03-progression/evidence-files.md) proposes twelve, one per level. They fill the journal, cannot be sold, grant no powers and never gate the ending. The final news broadcast mentions the ones Dave found.

Story information the player needs stays on the main route. Collecting every evidence file must never become an unannounced requirement.

### Keycards: level exits (proposed)

Each level's exit door (L1–L11) needs that level's clearance card, like the trophy that opens the exit door in *Dangerous Dave*. The card is on the main route or clearly signposted: a terminal, a guarded room, or the mini-boss arena console on levels 3, 6 and 9. L12 ends at Adam's core instead. A keycard is an exit lock, not an inventory item or a puzzle chain.

## One-weapon pickup and swap

The confirmed swap is simple: Dave approaches a weapon pickup, takes the new weapon, and leaves the previous one at that same pickup location.

**Proposed interaction details:**
- Use a deliberate interaction rather than swapping automatically on contact.
- Show the current and incoming weapon before the swap.
- The dropped weapon stays available while that area is accessible, so the player can reconsider before moving on.
- Taking it again swaps the weapons back; it never duplicates either one.

There is no secondary weapon, hidden pistol, backpack arsenal or checkpoint armory. Checkpoints do not recover weapons left elsewhere. The Graviton Tether occupies the same single slot as every other weapon; its grab and anchor-pull abilities work only while it is carried.

Meeting a new weapon at its planned introduction level does not force the player to keep it. Every introduction offers a safe trial area and a chance to swap back before a one-way exit.

## Checkpoints and upgrades

**Working persistence proposal:** a checkpoint commits all of these together:
- the one held weapon;
- world pickups and resources;
- the microchip wallet;
- earned upgrade stages;
- evidence files;
- the level's keycard;
- encounters and story objectives.

Death or reload restores that complete snapshot and rolls back later changes. See [health and checkpoints](design/03-progression/health-and-checkpoints.md).

**Working upgrade proposal:** Dave uses a fixed workbench to upgrade the carried weapon through its three successive stages. Purchased stages are recorded by weapon type and apply to later physical copies of that type. This record is not a stored arsenal. Each physical weapon keeps its ammunition, heat and fitted stage when dropped, and swapping never refills it. See [upgrades and ownership](design/03-progression/upgrades-and-ownership.md).

Recovery stations heal Dave and service the carried weapon. Ammunition, heat, reload and renewable supply rules are in [weapon resources](design/03-progression/ammunition-and-resupply.md). A required fight can never become impossible because a finite supply ran out.

## Consequences for levels and combat

- **No required multi-weapon combos.**
- **One weapon must suffice.** Every mandatory encounter needs a viable approach with every weapon that can legitimately be carried into it, without optional upgrades.
- **Tether use is a choice.** Mandatory routes have ordinary movement or interactable alternatives. No main-route jump assumes Dave carries a gun and the tether at once.
- **Tether combat needs throwables.** A mandatory fight entered with the tether must contain reachable, replenishable throwable objects. Bosses stay immune to capture.
- **Short-range weapons need access.** Provide safe approaches and firing positions for the Boom Broom and Arc Welder.
- **The Seedlobber needs workable openings.** Cover and boss exposure windows must allow a pod's arc and fuse.
- **No surprise weapon lock.** Preview the coming challenge before a one-way transition or pickup choice.
- **Darkness never hides gameplay.** Tells, weak points, landings and pickups stay readable (see the [style guide](art-design/style-guide.md)).
- **Enemy guns are fair.** Every gun has a tell (a glow or sight line that goes amber, then red) and an answer: jump, keep moving, take cover or punish the recovery. Enemies never aim at an airborne Dave (P23, proposed).
- **Protected people are never required targets.** This covers harmless Sleepwalkers, the held clinic staff, the founder and Arcadia's executives (story only). They have no hit zone.

## Example loop

Dave crosses Arcadia's campus gardens at night carrying the Scrapjack. A Night Guard swears at him and raises his baton as its tip glows amber; Dave steps back out of reach and drops him in his winded pause, and the guard stays down. A trail of glinting microchips leads over a planter to a workbench checkpoint. Nearby, the Boom Broom is offered in a safe practice space. Choosing it leaves the Scrapjack at the Boom Broom's pickup spot, and Dave can test the shotgun and swap back before leaving.

Dave re-flashes collected chips into the carried weapon. A side alcove holds an evidence file: a memo about the Link rollout. The keycard for the exit sits on a guard post's terminal further along the main route.

## Instructions for another AI

Treat the confirmed decisions as fixed. Keep the economy, persistence, interaction, keycard and evidence-file proposals labeled as proposals. Do not invent an inventory wheel, secondary pistol, checkpoint weapon storage, free tether tool, compulsory combo, extra weapon (including enemy guns as pickups), fourth upgrade or stealth system. A character image may show only the carried weapon; never put spare guns on Dave's back or belt.

[Main concept](dead-eden-concept.md) · [Level briefs](level-design/README.md) · [Art references](art-design/README.md)
