# 00 — Prototype scope and decisions

**Visual direction (C11, C15, C35):** [hand-drawn 2D in a dark night-campus palette, painted flat and lit in the engine](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24) and rebuilt 2026-09-30 (C33); there are no selected scene images for the new look.

**Status (C33):** Level 1 has been rebuilt from the ground up around the C31 roster, after the approved lit-cutout test (C35). It is built and the suite passes (2026-09-30). The enemies are the SE01 Night Guard, the M01 Patrol Rover and, at the alarm exit, the LK01 Staffer, all drawn as lit cutouts. The C24 build's disabled-not-killed Staffers (CY01, now LK01 in the [art briefs](../../art-design/linked/lk01-staffer.md)), the Clipper (removed under C32) and its no-gore rule are gone. Read them in [09](09-progress-and-handoff.md) as history that C25–C35 supersede.

## Authority

The user requested a Level 1 prototype plan lasting 10–15 minutes and selected **Godot** (C13). The plan was written first, a later explicit instruction authorized building it (M0–M7), C24 then asked for the built prototype to be rebuilt to the revamped story and look, and C33 then asked for Level 1 to be rebuilt from the ground up around the approved enemy roster. The old concept-only guidance remains applicable to unrelated campaign work.

Preserve the confirmed decisions in [the decision register](../../design/decisions.md): C02, C04–C08 and C10–C12 for gameplay, art and the solo hero, C14–C24 for the revamp (no zombies, dark mysterious atmosphere, **no stealth**, Adam, Dave Harlan, microchips, the first rebuild), and C25–C35 for the enemy roster: human enemies, lethal combat with visible blood, the Patrol Rover replacing the Clipper, the lit-cutout art and the ground-up rebuild (C33). C03 and C09 are superseded, and so is C10, the Clipper's design (by C32). All new numbers, encounter placements, technical choices beyond Godot itself, and timing estimates below are **prototype proposals**. The user's choice of Godot does not fix a particular version, renderer, or target platform; M0 pinned Godot 4.7.2.stable.official.

## Working technical defaults

Use Godot 4 stable, GDScript, a Windows desktop target, and keyboard/mouse controls first. Use the Compatibility renderer as a provisional lightweight 2D choice. M0 records the exact installed stable version and confirms the documented nodes work in it. Do not upgrade the engine mid-slice without recording why. No external plugins are required.

The art direction is confirmed: hand-drawn 2D rendering (C11), with clean outlines and flat colors, in the dark high-contrast night palette of the [style guide](../../art-design/style-guide.md) (C15, P21). C35 amended C11's lighting and the rebuild uses it: nothing is painted with baked light, the engine lights the flat paint smoothly, and each part has a normal map. Each enemy is a lit cutout rig of painted parts, and Dave's Rook frames get normal maps so he is lit the same way. Build the playable blockout first. No selected concept PNG remains: the Clipper's was deleted with the Clipper (C32). None of the three enemies has a selected image, and each is procedurally painted placeholder art, as the Rook sprite pack is for Dave. Concept PNGs are references, not finished sprite sheets.

## Required playable scope

| Include | Exact boundary |
| --- | --- |
| One solo hero | Dave Harlan, a 28-year-old AI researcher in a burnt-orange jacket (C18, C22); the placeholder Rook sprite pack stands in for his art; movement, variable jump, aim, fire, interact, pause |
| One playable level | L01-A01 through L01-A06 in the established order, on Arcadia's campus at night |
| Three enemy types | SE01 Night Guard (human), M01 Patrol Rover (robot) and LK01 Staffer (Linked cyborg); 8 Night Guards + 6 Patrol Rovers + 2 Staffers in 11 authored encounter groups |
| One weapon type | W01 Scrapjack Pistol, infinite basic shots, no magazine or reload |
| One available upgrade | Quickcycle, stage 1, 40 microchips; stages 2–3 remain unavailable under campaign gates |
| One carried slot | Optional same-type pistol exchange in the depot proves world-drop behavior without introducing the shotgun early |
| Treasure | 45 available main-route microchips before the workbench; one optional 20-chip cache; optional EF01 "Lockout Notice" evidence file |
| Exit lock | The level's clearance keycard, L01-KC01, sits on the A04 main route and opens the A06 exit wicket (P19) |
| Story | Fixed core node (one of Adam's), Adam answering once at the SC01 copy scene, lockdown, emergency hatch, a Security PA line at the exit wicket, hero traveling alone |
| Persistence | Complete checkpoint snapshot (including the keycard), upgrade transaction, story flags, continue/restart |
| Presentation | Readable HUD (chip wallet, keycard indicator), subtitles, basic audio, two environment states (night and lockdown), lit-cutout enemies that die and bleed, completion screen |
| Delivery | Godot project and local Windows test export after implementation; timing evidence recorded separately |

## Out of scope

No companion, follower, radio contact, boss, Heirs (the campaign's Level 10+ enemies), second weapon type, tether traversal, crafting, procedural generation, online systems, save-slot browser, full campaign menu, voice acting, external account, or cloud service. **No stealth or detection systems** (C16): no vision cones, alert states, hiding or noise. No ladders, dash, double jump, wall climb, swimming, or generic interaction that equips a hidden gun. The keycard is an exit lock, not an inventory or crafting item.

Ammunition packs, reload UI, and renewable ammo dispensers are unnecessary because the only weapon has infinite basic fire. Keep controller implementation and full input-remapping UI for a later pass; use named input actions now so they can be added. Do not claim full campaign accessibility coverage from this limited input slice.

## Explicit prototype elaborations

The [campaign Level 1 brief](../../level-design/l01-welcome-to-sunnyvale.md) establishes six areas but contains only a handful of sample encounters. This plan expands those areas into 32 beats and 11 encounter groups. It adds two recovery stations, one ordinary service-walkway switch, and a safe optional same-type weapon exchange. These are local prototype proposals, not additional levels or new mechanics.

One difference from the brief is deliberate: A06 has two Staffers and two Patrol Rovers, where the brief has two Staffers and no rovers. [02](02-area-blueprints.md) gives the reason.

An earlier version of the brief mentioned an optional porch ladder even though the movement rules exclude ladders. The rebuilt brief and this prototype use **stepped ledges and normal jumps**. The detailed system owners resolve the brief's older undecided health/economy notes: six health, a 40-chip first upgrade, optional journal-only evidence files, and complete checkpoint rollback. The keycard follows the brief's rule that it never becomes a softlock: it sits on the main route in A04, and a wicket reader visited without it only shows a harmless "card required" message.

The main campaign's first mini-boss is still in Level 3 and the shotgun still begins in Level 2. Reaching the prototype wicket with the keycard opens a completion screen, not a fabricated Level 2.

## Precedence during implementation

User changes → confirmed campaign constraints → this explicit prototype scope → linked system owners → area layout details → reference images. For numeric allocations use prototype-spec.json and update the corresponding prose in the same edit. If a physics test requires new dimensions, adjust dimensions rather than inventing an ability. Record deviations in [09](09-progress-and-handoff.md).
