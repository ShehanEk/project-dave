# DEAD EDEN — Core gameplay rules

**Approved visual direction (C11):** [Hand-drawn 2D](art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](concept-art/README.md).

For the complete organized specification, start with the [AI entry guide](AI_START_HERE.md), [twenty detailed design documents](design/README.md), and [decision register](design/decisions.md). This file is the short overview; detailed system files own the proposed rules.

## Confirmed decisions

The game remains a concept project. These decisions take priority over earlier descriptions that assumed several carried weapons or a permanent backup pistol.

- **Core loop:** Explore → fight → collect treasure → overcome an obstacle → reach a checkpoint → upgrade → explore again.
- **Primary treasure:** Gems.
- **Other treasure:** Artifacts can also be found.
- **Weapon limit:** The hero carries exactly one weapon at a time.
- **Weapon pickup:** Taking a new weapon drops the previous weapon at the location where the new weapon was found.
- **Arsenal:** Five weapon types with three upgrades each remain in the game. This is the total roster, not the number the hero carries.

## How the loop plays

| Step | Player experience | Purpose |
| --- | --- | --- |
| Explore | Read the route, spot enemies, look for alternate paths and visible treasure. | Build curiosity and give the player choices. |
| Fight | Handle an encounter using the one carried weapon and the environment. | Make positioning and familiarity with that weapon matter. |
| Collect treasure | Gather gems along the route and investigate promising places for artifacts. | Reward progress and exploration. |
| Overcome an obstacle | Cross a platforming section, use a visible switch, time a hazard, or exploit a weapon-appropriate opportunity. | Vary the challenge between fights. |
| Reach a checkpoint | Secure a safe stopping point and prepare for the next section. | Provide relief and a clear sense of progress. |
| Upgrade | Improve the carried weapon when the checkpoint offers an upgrade facility and the player has the required resources. | Turn exploration rewards into a visible improvement. |

This is the recurring rhythm, not a rigid six-step lock on every room. Gems may be collected while exploring, and a quiet story section need not contain a fight. Reaching a checkpoint should not require an upgrade purchase before the player can continue.

## Treasure

### Gems — primary collectible

Gems are the main visible reward. Use short gem trails to suggest an optional jump, small groups to reward a cleared encounter, and larger caches to reward a deliberate detour. Gem placement must not misleadingly promise a safe landing where none exists.

**Working economy proposal:** Spend gems on weapon upgrades at checkpoint maintenance facilities. [Treasure economy](design/03-progression/treasure-economy.md) proposes maintenance-credit crystals, values of 1/5/20, incremental upgrade prices of 40/90/160, and a twelve-level reward budget. These are untested defaults. [Checkpoint recovery](design/03-progression/health-and-checkpoints.md) defines the proposed collection rollback.

Older references to generic salvage caches now mean gem rewards unless a specific story object is described. Avoid silently adding a second primary currency or a mandatory materials grind.

### Artifacts — distinctive finds

Artifacts are an additional treasure category. **Working proposal:** Make them rarer, recognizable objects with a short story connection or collection value. They should feel different from a larger pile of gems.

The [artifact catalog](design/03-progression/artifact-catalog.md) now proposes twelve distinct finds, one per level. They record optional lore in the journal, cannot be sold, and do not grant powers or gate the ending. Names, appearance, and exact alcoves remain open to refinement.

Personal background props are not automatically collectible artifacts. Important story evidence remains on the main route; completing an optional artifact collection must not become an unannounced requirement to finish the campaign.

## One-weapon pickup and swap

The confirmed swap is simple: the hero approaches a weapon pickup, takes the new weapon, and leaves the previous one at that same pickup location.

**Proposed interaction details:** Use a deliberate interaction rather than automatically swapping on contact. Show the current and incoming weapon before the swap. The dropped weapon stays accessible while that area remains accessible, so the player can reconsider before moving on. Taking it again swaps the weapons back; it does not duplicate either one.

There is no carried secondary, hidden pistol, backpack arsenal, or checkpoint armory in this design. Checkpoints do not automatically recover weapons left elsewhere. The Graviton Tether occupies the same single slot as every other weapon; its grabbing and anchor-pull abilities are available only while it is carried.

Encountering a new weapon at its planned introduction level does not force the player to keep it. Give each introduction a safe trial area and a chance to swap back before a one-way exit. Earlier weapon lists describe types introduced by that point, not an inventory available for instant switching.

## Checkpoints and upgrades

**Working persistence proposal:** A checkpoint commits the one held weapon, world pickups, resources, wallet, earned upgrade stages, artifacts, encounters, and story objectives together. Death or reload restores that complete snapshot, rolling back changes after it. Purchases and major story milestones commit complete states. See [health and checkpoints](design/03-progression/health-and-checkpoints.md) for recovery, story-save differences, and level boundaries.

**Working upgrade proposal:** A maintenance facility modifies the carried weapon through its three successive stages. Purchased stages are recorded by weapon type and apply to later physical copies when picked up. This record is not a stored arsenal. Each physical weapon retains its ammunition, heat, and fitted stage when dropped; swapping never refills it. See [upgrades and ownership](design/03-progression/upgrades-and-ownership.md).

Recovery stations heal and service the one carried weapon. Story-only saves preserve current resources. Proposed ammunition, heat, reload, and renewable supply rules are defined in [weapon resources](design/03-progression/ammunition-and-resupply.md). Their quantities remain untested. Required fights cannot become impossible because a finite supply ran out.

## Consequences for levels and combat

- **No required multi-weapon combos.** Earlier shotgun-then-tether and Seedlobber-then-Arc examples are removed from the intended combat loop.
- **One weapon must suffice.** Each mandatory encounter needs a viable approach with every weapon that can legitimately be carried into it, without requiring optional upgrades.
- **Tether use is a choice.** Mandatory routes have ordinary movement or interactable alternatives. Tether anchors open shortcuts or optional approaches. No main-route jump assumes the hero carries a gun and the tether simultaneously.
- **Tether combat needs ammunition in the environment.** A mandatory fight entered with the tether must contain reachable, replenishable throwable objects, or an equivalent already-established environmental damage source. The boss itself remains immune to capture. [Environmental objects](design/04-world/objects-and-hazards.md) and the resource file define a proposed supply-pad design.
- **Short-range weapons need access.** Provide safe approaches and firing positions for the Boom Broom and Arc Welder, not only distant pistol sightlines.
- **Seedlobber needs workable openings.** Cover and boss exposure windows must accommodate a baseline pod's arc and fuse. Avoid forcing a damaging explosion at the hero's feet.
- **No surprise weapon lock.** Preview the coming challenge before a one-way transition or pickup choice. Do not require the player to retrieve a weapon from an inaccessible earlier level.

## Example loop

The hero explores a hedge garden while carrying the Scrapjack, fights a Resident, follows a gem trail over a planter, and reaches a maintenance checkpoint. Nearby, the Boom Broom is offered in a safe practice space. Choosing it leaves the Scrapjack at the Boom Broom's pickup spot. The hero can test the shotgun and swap back before leaving.

Under the proposed economy, the player spends collected gems to improve the carried weapon. A side alcove may hold an artifact with a short story description. The next section supports whichever single weapon the player chose.

## Instructions for another AI

Treat the confirmed decisions as fixed. Keep the economy, persistence, interaction, and artifact-use proposals labeled as proposals until refined. Do not invent an inventory wheel, secondary pistol, checkpoint weapon storage, free tether tool, compulsory combo, extra weapon, or fourth upgrade. A character image may show only the carried weapon; do not place spare guns on the hero's back or belt.

## Proposed defaults and remaining refinement

The detailed pack now supplies working proposals for the economy, artifact use, weapon resources, upgrade ownership, checkpoint rollback, and maintenance facilities. They are not user-confirmed balance values.

Still refine movement feel, damage and durability, reward collection rates, upgrade strength, exact replacement-pickup and artifact locations, and checkpoint spacing. Chapter replay remains future scope. Use the [decision register](design/decisions.md) to track changes without mixing confirmed choices and proposals.

[Main concept](dead-eden-concept.md) · [Level briefs](level-design/README.md) · [Art references](art-design/README.md)
