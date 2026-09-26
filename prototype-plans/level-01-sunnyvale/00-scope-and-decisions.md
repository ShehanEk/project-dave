# 00 — Prototype scope and decisions

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md). [Selected references](../../concept-art/l01-sunnyvale/README.md).

## Authority

The user requested a Level 1 prototype plan lasting 10–15 minutes and selected **Godot** (C13). This task creates the plan only. A later explicit instruction to execute this plan authorizes implementation of this slice; the old concept-only guidance remains applicable to unrelated campaign work.

Preserve confirmed C02–C12 in [the decision register](../../design/decisions.md). All new numbers, encounter placements, technical choices beyond Godot itself, and timing estimates below are **prototype proposals**. The user's choice of Godot does not fix a particular version, renderer, or target platform.

## Working technical defaults

Use Godot 4 stable, GDScript, a Windows desktop target, and keyboard/mouse controls first. Use the Compatibility renderer as a provisional lightweight 2D choice. M0 records the exact installed stable version and confirms the documented nodes work in it. Do not upgrade the engine mid-slice without recording why. No external plugins are required.

The proposed art direction is already confirmed: hand-drawn 2D, clean outlines, flat colors, cel shadows, and layered scenery. Build the playable blockout first. Selected concept PNGs are references, not finished sprite sheets.

## Required playable scope

| Include | Exact boundary |
| --- | --- |
| One solo hero | Provisional Rook silhouette; movement, variable jump, aim, fire, interact, pause |
| One playable level | L01-A01 through L01-A06 in the established order |
| Two enemy classes | Z01 Resident and R01 Clipper; 9 Residents + 6 Clippers in 11 authored encounter groups |
| One weapon type | W01 Scrapjack Pistol, infinite basic shots, no magazine or reload |
| One available upgrade | Quickcycle, stage 1, 40 gems; stages 2–3 remain unavailable under campaign gates |
| One carried slot | Optional same-type pistol exchange in depot proves world-drop behavior without introducing the shotgun early |
| Treasure | 45 available main-route gems before the bench; one optional 20-value cache; optional A01 Welcome Key artifact |
| Story | Fixed power core, EDEN awakening once, quarantine exit, hero traveling alone |
| Persistence | Complete checkpoint snapshot, upgrade transaction, story flags, continue/restart |
| Presentation | Readable HUD, subtitles, basic audio, two environment states, completion screen |
| Delivery | Godot project and local Windows test export after implementation; timing evidence recorded separately |

## Out of scope

No companion, follower, boss, Returned, second weapon type, tether traversal, crafting, procedural generation, online systems, save-slot browser, full campaign menu, voice acting, external account, or cloud service. No ladders, dash, double jump, wall climb, swimming, or generic interaction that equips a hidden gun.

Ammunition packs, reload UI, and renewable ammo dispensers are unnecessary because the only weapon has infinite basic fire. Keep controller implementation and full input-remapping UI for a later pass; use named input actions now so they can be added. Do not claim full campaign accessibility coverage from this limited input slice.

## Explicit prototype elaborations

The [campaign Level 1 brief](../../level-design/l01-welcome-to-sunnyvale.md) establishes six areas but contains only a handful of sample encounters. This plan expands those areas into 32 beats and 11 encounter groups. It adds two recovery stations, one ordinary service-walkway switch, and a safe optional same-type weapon exchange. These are local prototype proposals, not additional levels or new mechanics.

The existing brief mentions an optional porch ladder even though the movement rules exclude ladders. For this prototype, use **stepped porch ledges and normal jumps**. The detailed system owners resolve the brief's older undecided health/economy notes: six health, a 40-gem first upgrade, optional journal-only artifacts, and complete checkpoint rollback.

The main campaign's first boss is still in Level 3 and the shotgun still begins in Level 2. Reaching the prototype wicket opens a completion screen, not a fabricated Level 2.

## Precedence during implementation

User changes → confirmed campaign constraints → this explicit prototype scope → linked system owners → area layout details → reference images. For numeric allocations use prototype-spec.json and update the corresponding prose in the same edit. If a physics test requires new dimensions, adjust dimensions rather than inventing an ability. Record deviations in [09](09-progress-and-handoff.md).
