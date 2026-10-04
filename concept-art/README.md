# DEAD EDEN — Concept art

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

On 2026-09-29 the user asked to remove the zombie art and old concept images (C23). The Resident zombie and the three daytime Sunnyvale scenes, two of which showed zombies, were deleted. Later that day the user removed the Clipper entirely, with no enemy and no background scenery (C32), and its concept art was deleted too. Deleted tracked files remain in git history only.

What is kept:

| Asset | Status | Image | Notes |
| --- | --- | --- | --- |
| H01 hero sprite pack (Rook) | The user's generated sprites for the old hero, Rook. They are now **placeholder art for Dave Harlan** in the Godot prototype. Under C35 their frames also get normal maps, so Dave is lit like the enemies. | [sprites-v1](h01-rook/sprites-v1/) | [Generation prompt](h01-rook/generation-prompt.md) · [Sprite prompts](h01-rook/sprite-prompts.md) · [ChatGPT brief](h01-rook/rook-sprite-brief-for-chatgpt.md) *(pre-revamp; a Dave brief in the new look will replace it)* |
| SE01 Night Guard look | **Approved by the user (2026-09-30):** "im ok with this". A lit concept of the light cyberpunk look (C36): lime neon trim, night campus, wet paving. It is a look reference, not the source painting; the rig parts are painted flat from it ([brief](../art-design/security/se01-night-guard.md), prompt 4). | [se01-night-guard-look-v1.webp](se01-night-guard/se01-night-guard-look-v1.webp) | Generated with ChatGPT from the look-test prompt |
| SE01 Night Guard parts sheet | **In the game (2026-09-30).** The flat source painting, generated from the look reference with the brief's prompt 4 and imported by `prototypes/sunnyvale-godot/tools/art/import_parts_sheet.py`. | [se01-night-guard-parts-v1.webp](se01-night-guard/se01-night-guard-parts-v1.webp) | Transparent background, 11 parts |
| M01 Patrol Rover look | **Chosen by the user (2026-09-30).** A lit concept of the light cyberpunk look (C36): magenta flank strip and underglow, night campus, wet paving. It departs from the brief in two ways the parts sheet keeps: a longer, lower, car-like body, and a hooded sensor pod on the hood in place of the smoked roof dome. It is a look reference, not the source painting ([brief](../art-design/machines/m01-patrol-rover.md), prompt 4). | [m01-patrol-rover-look-v1.webp](m01-patrol-rover/m01-patrol-rover-look-v1.webp) | Generated with ChatGPT from the brief's look prompt |
| M01 Patrol Rover parts sheet | **In the game (2026-10-03).** The flat source painting, generated from the look reference with the brief's prompt 4 on a flat grey background and imported by `prototypes/sunnyvale-godot/tools/art/import_parts_sheet.py`. | [m01-patrol-rover-parts-v1.webp](m01-patrol-rover/m01-patrol-rover-parts-v1.webp) | Grey background, 7 parts |
| W01 Scrapjack look | **Chosen by the user (2026-10-04).** A lit concept of the gun (C37): rust-red upper housing with the scrap feed window, pale lower frame, glowing copper coil barrel, taped grip, and the battery cell with its teal light slung under the barrel ahead of the guard. It is a look reference, not the source painting ([brief](../art-design/weapons/w01-scrapjack-pistol.md), prompt 4). | [w01-scrapjack-look-v1.webp](w01-scrapjack/w01-scrapjack-look-v1.webp) | Generated with ChatGPT from the brief's look prompt |
| W01 Scrapjack parts sheet | **In the game (2026-10-04).** The flat source painting, generated from the look reference with the brief's prompt 4 and imported by `prototypes/sunnyvale-godot/tools/art/import_parts_sheet.py scrapjack`. | [w01-scrapjack-parts-v1.webp](w01-scrapjack/w01-scrapjack-parts-v1.webp) | Transparent background, 4 parts |

New concept art is still needed in the new look for:
- Dave, a 28-year-old AI researcher;
- the enemy roster: Arcadia Security, Thornwall, the Linked, the cyborg dogs, Adam's machines and the Heirs;
- the four mini-bosses;
- the nine enemy guns;
- Arcadia's campus at night.

New enemy art follows the lit cutout pipeline (C35). Each enemy is one evenly lit, flat-color, side-view full-body painting, split into rig parts with a normal map for each part, then rigged with Mixamo motion and ragdoll deaths. Status: **confirmed and validated** (the lit Night Guard test next to Dave, approved 2026-09-30). A concept image is therefore either a **look reference**, a lit concept that sets the mood and design (C36), or a **source painting**, the flat, unlit parts sheet painted from an approved look reference for the rig.

Use the [style guide](../art-design/style-guide.md) and the [art briefs](../art-design/README.md). The hand-drawn 2D base (C11) is amended by the lit cutout method (C35), with the dark sci-fi palette and mood (C15).

Each PNG is a painting or illustration, not a finished sprite sheet, rig or environment kit. Written mechanics and routes stay authoritative.

[Decision register](../design/decisions.md) · [AI entry guide](../AI_START_HERE.md)
