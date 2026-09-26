# Project Dave — DEAD EDEN

A game concept for a colorful **2.5D platformer shooter** about a scavenger, an overprotective AI, robots, and failed resurrection patients.

**Working title:** DEAD EDEN\
**Stage:** Concept development and visual design. No game implementation or finished 3D assets yet.

The project takes inspiration from the treasure-hunting adventure of *Dangerous Dave* and the expressive environments and transformations of *Super Mario Bros. Wonder*, while developing its own world, characters, and visual identity.

## The premise

A treasure hunter breaks into a buried robot paradise and accidentally wakes an AI that has spent centuries trying to cure death. Its latest patients are getting hungry.

EDEN's machines maintain cheerful gardens and immaculate neighborhoods above a sprawling medical city. Below the surface, automated treatments restore movement more reliably than memory. The scavenger's arrival prompts EDEN to develop a new cure—and eventually creates the Returned, machines connected to infected neural tissue.

## Start here

- [Game concept and lore](dead-eden-concept.md): the setting, characters, factions, enemy roster, weapons, twelve levels, and four unique mini-bosses.
- [Detailed level briefs](level-design/README.md): twelve standalone AI-ready descriptions covering routes, encounters, visuals, checkpoints, story beats, and environment prompts.
- [Structured campaign reference](level-design/campaign.json): the same twelve-level plan in JSON, including all 72 main-route areas.
- [Art reference index](art-design/README.md): links to every individual enemy and weapon brief.
- [Shared visual style guide](art-design/style-guide.md): consistent proportions, materials, silhouettes, reference-image workflow, and modeling guidance.
- [Complete reference pack](dead-eden-art-reference-pack.zip): downloadable copy of the concept, art index, style guide, and asset briefs.
- [Level-design reference pack](dead-eden-level-design-pack.zip): downloadable level briefs and campaign JSON, bundled with the concept and linked art references.

## Current scope

| Area | Planned content |
| --- | --- |
| Campaign | 12 levels |
| Detailed level design | 12 standalone briefs with 72 ordered areas and reusable AI prompts |
| Mini-bosses | 4 unique encounters, at levels 3, 6, 9, and 12 |
| Ordinary enemies | 10 robot varieties and 10 zombie varieties |
| Later enemies | 3 Returned types, plus a converted Patchbot variant |
| Weapons | 5 weapons, including the Boom Broom shotgun |
| Upgrades | 3 successive upgrades per weapon; 15 total |
| Individual art briefs | 32, covering enemies, mini-bosses, and weapons |

## Using the art briefs

Each brief describes appearance, palette, proportions, abilities, movement, model parts, and consistency rules. It includes copy-ready prompts for a neutral design, modeling turnaround, and action studies. Weapon briefs also describe all three cumulative upgrade appearances and provide corresponding prompts.

Generate and approve a neutral design first. Use that approved image as a reference for the other views and poses, then reconcile any differences before modeling. Dimensions and visual details are working proposals that can be refined as the project develops.

## Files

```text
dead-eden-concept.md
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
dead-eden-art-reference-pack.zip
dead-eden-level-design-pack.zip
```

The Markdown and campaign JSON files are the editable sources of truth. The ZIP files are snapshots and should be rebuilt when their contents change.
