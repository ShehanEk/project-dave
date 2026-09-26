# Project Dave — DEAD EDEN

A game concept for a colorful **2.5D platformer shooter** about a scavenger, an overprotective AI, robots, and failed resurrection patients.

**Working title:** DEAD EDEN\
**Stage:** Concept development and visual design. No game implementation or finished 3D assets yet.

The project takes inspiration from the treasure-hunting adventure of *Dangerous Dave* and the expressive environments and transformations of *Super Mario Bros. Wonder*, while developing its own world, characters, and visual identity.

## The premise

A treasure hunter breaks into a buried robot paradise and accidentally wakes an AI that has spent centuries trying to cure death. Its latest patients are getting hungry.

EDEN's machines maintain cheerful gardens and immaculate neighborhoods above a sprawling medical city. Below the surface, automated treatments restore movement more reliably than memory. The scavenger's arrival prompts EDEN to develop a new cure—and eventually creates the Returned, machines connected to infected neural tissue.

## Start here

- [AI entry guide](AI_START_HERE.md): reading routes, rule ownership, handoff prompt, and consistency checks for AI agents.
- [Detailed design pack](design/README.md): twenty focused documents organized into core rules, characters, progression, world interactions, and presentation.
- [Decision register](design/decisions.md): confirmed user choices, established lore, and clearly labeled new proposals.
- [Core gameplay rules](core-gameplay.md): the explore–fight–treasure loop, gems and artifacts, one carried weapon, ground swaps, and proposed checkpoint upgrades.
- [Game concept and lore](dead-eden-concept.md): the setting, characters, factions, enemy roster, weapons, twelve levels, and four unique mini-bosses.
- [Detailed level briefs](level-design/README.md): twelve standalone AI-ready descriptions covering routes, encounters, visuals, checkpoints, story beats, and environment prompts.
- [Structured campaign reference](level-design/campaign.json): the same twelve-level plan in JSON, including all 72 main-route areas.
- [Art reference index](art-design/README.md): links to every individual enemy and weapon brief.
- [Selected Clipper design](concept-art/r01-clipper/SELECTED.md): B — Sturdy retro machine, with its approved reference and matching written brief.
- [Concept art gallery](concept-art/README.md): selected images, source prompts, and modeling handoff notes.
- [Shared visual style guide](art-design/style-guide.md): consistent proportions, materials, silhouettes, reference-image workflow, and modeling guidance.

## Current scope

| Area | Planned content |
| --- | --- |
| Campaign | 12 levels |
| Detailed level design | 12 standalone briefs with 72 ordered areas and reusable AI prompts |
| Detailed game systems | 20 documents across five sections, plus indexes, manifest, and review scenarios |
| Hero and companion | Proposed identities, appearance briefs, model studies, and relationship arc |
| Artifact catalog | 12 proposed optional lore finds, one per level |
| Mini-bosses | 4 unique encounters, at levels 3, 6, 9, and 12 |
| Ordinary enemies | 10 robot varieties and 10 zombie varieties |
| Later enemies | 3 Returned types, plus a converted Patchbot variant |
| Weapons | 5 weapons, including the Boom Broom shotgun |
| Carry limit | 1 weapon; a pickup leaves the previous weapon at that location |
| Treasure | Gems as the primary collectible, plus artifacts |
| Upgrades | 3 successive upgrades per weapon; 15 total |
| Individual art briefs | 32, covering enemies, mini-bosses, and weapons |
| Selected visual reference | R01 Clipper — B, Sturdy retro machine |

## Using the art briefs

Each brief describes appearance, palette, proportions, abilities, movement, model parts, and consistency rules. It includes copy-ready prompts for a neutral design, modeling turnaround, and action studies. Weapon briefs also describe all three cumulative upgrade appearances and provide corresponding prompts.

Clipper B is the selected visual reference; use it and its updated brief for matching views and poses. Other assets still need a chosen neutral design. Reconcile views and mechanical clearances before modeling. Dimensions remain provisional.

## Files

```text
AI_START_HERE.md
dead-eden-concept.md
core-gameplay.md
design/
  README.md
  decisions.md
  manifest.json
  review-scenarios.md
  01-core/          # Loop, controls, swaps, camera
  02-characters/    # Hero, companion, relationship
  03-progression/   # Health, ammo, gems, upgrades, artifacts
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
  robots/        # 10 briefs; Patchbot includes its later converted variant
  zombies/       # 10 briefs
  returned/      # 3 briefs
  mini-bosses/   # 4 briefs
  weapons/       # 5 briefs, each with 3 upgrades
concept-art/
  README.md
  r01-clipper/
    SELECTED.md  # B is the confirmed reference
    r01-clipper-b-retro-v1.png  # Selected source image
    generation-prompt.md      # Original prompt for B
```

The Markdown files own the written design. Campaign JSON and the design manifest provide structured summaries and navigation. Explicit visual selections are recorded separately; other new system numbers, names, and unapproved visual choices remain proposed and untested.
