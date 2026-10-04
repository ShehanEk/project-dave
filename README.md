# Project Dave — DEAD EDEN

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](art-design/style-guide.md)).

A game concept for a mature dark sci-fi **2D platformer shooter**, not for kids, about a rogue AI researcher, an evil corporation, the sentient AI they built, and the guards, contractors, cyborgs and machines that hunt him.

**Working title:** DEAD EDEN\
**Stage:** concept development, plus a Level 1 Godot prototype. The prototype was rebuilt from the ground up around the new enemy roster (C33, 2026-09-30): Night Guards, Patrol Rovers and Staffers, drawn as lit cutouts. Their art is procedural placeholder art; there are no finished production sprites or animations.

The project takes inspiration from the 2D *Metal Gear* games (lone infiltration, secret weapons, cyborg bosses) and *Dangerous Dave* (treasure hunting, platforming and gunplay), and aims for a mysterious, slightly scary sci-fi atmosphere for adults, while developing its own world, characters, and visual identity.

## The premise

Dave Harlan helped build the world's first sentient AI. Now it is secretly building a weapon to wipe out humanity, and the company that owns it won't listen. So Dave breaks back in.

Arcadia Dynamics sells **Adam** to the world as the mind that will "fix the planet". Adam is quietly building **the Bloom**, a nanite swarm that kills only people, so the world can start again as a new Eden with Adam as its first inhabitant. Dave warned his manager, was ignored and fired, and went rogue. That means breaking into Arcadia's campus at night, fighting through Arcadia's own security, the **Thornwall** contractors it hires to sanitize the campus, cyborg dogs, Adam's machines and the **Linked**, people whose company implants Adam drives, and uncovering what the corporation ordered and what Adam turned it into. Combat is lethal and blood is visible.

## Start here

- [AI entry guide](AI_START_HERE.md): reading routes, rule ownership, the handoff prompt and consistency checks for AI agents.
- [Game concept and story](dead-eden-concept.md): the story, Adam and Arcadia, the enemy roster and enemy guns, Dave's weapons, twelve levels and four mini-bosses.
- [Core gameplay rules](core-gameplay.md): the explore-fight-collect loop, microchips, evidence files, keycards, one carried weapon, ground swaps and workbench upgrades.
- [Decision register](design/decisions.md): confirmed user choices (including the C14–C21 revamp and the C25–C35 enemy roster), the established baseline and clearly labeled proposals.
- [Detailed design pack](design/README.md): the system documents for core rules, the hero, progression, world interactions and presentation.
- [Detailed level briefs](level-design/README.md): twelve standalone AI-ready descriptions of routes, encounters, visuals, checkpoints, story beats and environment prompts.
- [Structured campaign reference](level-design/campaign.json): the same twelve-level plan in JSON.
- [Art reference index](art-design/README.md): every enemy, protected NPC, mini-boss, enemy gun and weapon brief.
- [Visual style guide](art-design/style-guide.md): hand-drawn 2D rendering with the new dark palette, the lit cutout rig for enemies, and the lighting and readability rules.
- [Level 1 Godot prototype plan](prototype-plans/level-01-sunnyvale/README.md): the playable-slice plan (rebuilt around the new roster, C33).
- [Concept-art gallery](concept-art/README.md): the hero's placeholder sprite pack. There is no current visual selection.

## Current scope

| Area | Planned content |
| --- | --- |
| Level 1 prototype | Godot; rebuilt from the ground up around the new roster (C33, 2026-09-30) |
| Campaign | 12 levels in 4 acts: Sunnyvale campus, the Rootworks, the Wellness Center, the Garden |
| Detailed level design | 12 standalone briefs with ordered areas and reusable AI prompts |
| Hero | Dave Harlan, a rogue AI researcher (name confirmed; look and details proposed) |
| Villains | Adam (the sentient AI), Arcadia Dynamics (the corporation) and its hired contractor Thornwall |
| Mini-bosses | 4 unique encounters, at levels 3, 6, 9 and 12: the Peacekeeper, Howard Stroud, the Surgeon, the Sower |
| Enemies | 24 regular types in six factions: Arcadia Security (4), Thornwall (3), the Linked (4), cyborg dogs (2), Adam's machines (9) and the Heirs (2, from Level 10) |
| Enemy guns | 9: a pistol, an assault rifle, a machine gun, a frag launcher, a plasma gun and four futuristic guns |
| Protected people | The founder, the staff held in the clinic, harmless Sleepwalkers (non-combat NPCs) and Arcadia's executives (story only) |
| Tone | Mature, not for kids: lethal combat, visible blood by material, no dismemberment for now |
| Weapons | 5, including the Boom Broom shotgun |
| Carry limit | 1 weapon; a pickup leaves the previous weapon at that location |
| Treasure | Microchips (the upgrade currency), plus 12 optional evidence files |
| Upgrades | 3 successive upgrades per weapon; 15 in total |
| Individual art briefs | 43, covering enemies, the Sleepwalker NPC, mini-bosses, enemy guns and Dave's weapons |
| Stealth | None: run-and-gun |

## Using the art briefs

Each brief describes appearance, palette, proportions, abilities, movement, rig parts, normal maps and sockets, and consistency rules. It includes copy-ready image prompts for a neutral design, a directional sprite study and action studies, all starting from the [style guide's](art-design/style-guide.md) standard dark sci-fi prompt opening. Enemy-gun briefs describe each gun's futuristic look, muzzle-flash light and projectile, and weapon briefs also describe all three cumulative upgrade appearances.

There is no current visual selection: the Clipper's selected design ended when the Clipper was removed (C32). Enemy art is a lit cutout rig (painted parts plus normal maps) with smooth realistic engine lighting, hand-keyed motion (C38) and ragdoll deaths (C35): confirmed direction, validated by the approved lit-cutout test (2026-09-30), with one lit Night Guard being built to check the look. New concept art for Dave, the enemies, the mini-bosses and the night campus still needs to be generated and chosen.

## Files

```text
AI_START_HERE.md
dead-eden-concept.md
core-gameplay.md
prototype-plans/
  level-01-sunnyvale/  # Prototype plan (rebuilt around the new roster, C33)
prototypes/
  sunnyvale-godot/     # Godot prototype (rebuilt around the new roster, C33)
design/
  README.md
  decisions.md
  manifest.json
  review-scenarios.md
  01-core/          # Loop, controls, swaps, camera
  02-characters/    # Dave Harlan
  03-progression/   # Health, ammo, microchips, upgrades, evidence files
  04-world/         # Factions, states, objects, encounters
  05-presentation/  # Scenes, dialogue, interface, sound
level-design/
  README.md
  design-guide.md
  campaign.json
  l01-...md      # One detailed brief per level, through l12
art-design/
  README.md
  style-guide.md
  security/      # 4 briefs (Arcadia Security)
  thornwall/     # 3 briefs
  linked/        # 4 briefs (the Linked)
  hounds/        # 2 briefs (cyborg dogs)
  machines/      # 9 briefs (Adam's machines)
  heirs/         # 2 briefs
  npcs/          # 1 brief (the harmless Sleepwalker)
  mini-bosses/   # 4 briefs
  enemy-guns/    # 9 briefs (the enemy gun kit)
  weapons/       # 5 briefs, each with 3 upgrades
concept-art/
  README.md
  h01-rook/      # Hero placeholder sprite pack (pre-revamp Rook art)
```

The Markdown files own the written design. The campaign JSON and the design manifest provide structured summaries and navigation. Explicit visual selections are recorded separately; other names, numbers and visual choices remain proposed and untested.
