# DEAD EDEN — Concept art

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

On 2026-09-29 the user asked to remove the zombie art and old concept images (C23). The Resident zombie and the three daytime Sunnyvale scenes, two of which showed zombies, were deleted. Later that day the user removed the Clipper entirely, with no enemy and no background scenery (C32), and its concept art was deleted too. Deleted tracked files remain in git history only.

What is kept:

| Asset | Status | Image | Notes |
| --- | --- | --- | --- |
| H01 hero sprite pack (Rook) | The user's generated sprites for the old hero, Rook. They are now **placeholder art for Dave Harlan** in the Godot prototype. Under C35 their frames also get normal maps, so Dave is lit like the enemies. | [sprites-v1](h01-rook/sprites-v1/) | [Generation prompt](h01-rook/generation-prompt.md) · [Sprite prompts](h01-rook/sprite-prompts.md) · [ChatGPT brief](h01-rook/rook-sprite-brief-for-chatgpt.md) *(pre-revamp; a Dave brief in the new look will replace it)* |

No enemy concept image is selected yet. New concept art is still needed in the new look for:
- Dave, a 28-year-old AI researcher;
- the enemy roster: Arcadia Security, Thornwall, the Linked, the cyborg dogs, Adam's machines and the Heirs;
- the four mini-bosses;
- the nine enemy guns;
- Arcadia's campus at night.

New enemy art follows the lit cutout pipeline (C35). Each enemy is one evenly lit, flat-color, side-view full-body painting, split into rig parts with a normal map for each part, then rigged with Mixamo motion and ragdoll deaths. Status: **confirmed and validated** (the lit Night Guard test next to Dave, approved 2026-09-30). A concept image is therefore a source painting for that pipeline, not a lit illustration.

Use the [style guide](../art-design/style-guide.md) and the [art briefs](../art-design/README.md). The hand-drawn 2D base (C11) is amended by the lit cutout method (C35), with the dark sci-fi palette and mood (C15).

Each PNG is a painting or illustration, not a finished sprite sheet, rig or environment kit. Written mechanics and routes stay authoritative.

[Decision register](../design/decisions.md) · [AI entry guide](../AI_START_HERE.md)
