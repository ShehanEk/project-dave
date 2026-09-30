# 04 — Godot implementation architecture

**Visual direction (C11, C15, C35):** [hand-drawn 2D in a dark night-campus palette, painted flat and lit in the engine](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24) and rebuilt 2026-09-30 (C33); there are no selected scene images for the new look.

**Status:** Implemented (M0–M7), rebuilt to the revamp (C24), then rebuilt again around the new enemy roster (C33); this file describes the rebuilt game. It is the design; the project's own `CONVENTIONS.md` fixes the exact contracts, IDs and commands. M0 pinned **Godot 4.7.2.stable.official** and verified the documented APIs against it. All paths below are relative to prototypes/sunnyvale-godot/ unless stated otherwise.

## Small project structure

~~~text
project.godot
scenes/
  main.tscn
  levels/level_01.tscn
  levels/areas/a01_gate.tscn, a02_gardens.tscn, a03_roofs.tscn,
                a04_square.tscn, a05_depot.tscn, a06_exit.tscn
  actors/hero.tscn, night_guard.tscn, staffer.tscn, patrol_rover.tscn, game_camera.tscn
  weapons/scrapjack.tscn, scrap_bolt.tscn
  objects/recovery_station.tscn, workbench.tscn
  objects/chip.tscn, chip_cache.tscn, evidence_pickup.tscn, keycard.tscn
  objects/weapon_pad.tscn, med_patch.tscn
  objects/moving_platform.tscn, route_switch.tscn, service_walkway.tscn
  objects/core_node.tscn, exit_wicket.tscn, emergency_hatch.tscn
  world/night_overlay.tscn            (optional screen overlay, revamp)
  world/night_lighting.tscn           (optional moonlight for the lit characters, C35)
  ui/hud.tscn, pause.tscn, workbench_panel.tscn, swap_confirm.tscn,
     completion.tscn, title_screen.tscn, subtitle_panel.tscn, controls_panel.tscn
  debug/                              (capture and demo scenes and the enemy lab, not exported)
scripts/
  actors/ (brawler.gd, patrol_rover.gd; lit/ holds the cutout-rig code), weapons/, objects/, ui/,
  levels/, world/, combat/, audio/, effects/ (blood), tuning/
  main.gd, session.gd, checkpoint_service.gd, settings.gd, telemetry.gd
  levels/level_director.gd
data/
  tuning/, audio/
assets/
  characters/ (lit/ enemy rigs, rook/ Dave and his normal maps), effects/blood/, shaders/, ui/, audio/, kenney/
tests/
  run_tests.gd, test_case.gd, area_harness.gd, cases/
tools/                                (art/ holds the rig painters and Mixamo converters)
reports/
  functional-matrix.md, asset-inventory.md, pacing-risk.md, export-report.md, playtests/
~~~

This is the layout as built, not a demand to generate empty files. Create only what a completed milestone needs. Items the original plan listed but the build never needed (`data/encounters/`, `data/dialogue/`, `assets/weapons/`, `assets/environments/`, `tests/state_contracts.gd`) were folded into the scenes, scripts and `tests/cases/` (the state-contract harness is `tests/cases/test_m4_state_contracts.gd`). Keep editor caches, test saves, and exported binaries out of source control. Later AI agents should preserve the repository's existing concept files and staged work.

## Scene responsibilities

| Owner | Responsibility |
| --- | --- |
| Main | Boots a new run or valid Continue, hosts level and interface, owns the title screen |
| Level01 / LevelDirector | Area order, encounter activation, objectives, lockdown state, completion (SC01's own scene lives in CoreNode) |
| Six area scenes | Static geometry, placed entity IDs, safe entry/exit, camera bounds, reference props |
| Hero | Input, physics movement, health, one equipped weapon; no story logic |
| Night Guard and Staffer (`Brawler`) / Patrol Rover (`PatrolRover`) | Local state machines, warnings, attack token requests, hit/death reporting; a death hands the rig to a ragdoll (people) or a debris wreck (the rover) |
| Cutout rig | Builds an enemy's lit parts from its `rig.json`, poses them for the owner and lights them through `lit_part.gdshader` (`scripts/actors/lit/`); no collision and no gameplay state |
| Scrapjack | Cadence, held pose, bolt emission; stage from earned upgrade record |
| Interactable objects | One highlighted action, stable ID, value-state reporting |
| CoreNode | The SC01 copy scene: plug-in, Adam's answer, story flags and the CP04 commit |
| Keycard / ExitWicket | The card is a contact pickup that records `L01-KC01` through Session; the wicket checks the card and announces the moment it is reached, and LevelDirector owns completion |
| Session | One run's current value state and latest complete committed snapshot |
| CheckpointService | Snapshot serialization/restoration; complete purchase/save transaction |
| UI | Reads state/signals; requests actions, never directly edits saved wallets or story flags |

Use reusable scenes and a few small resources for tuning. Avoid an entity framework, dependency-injection system, or full campaign manager for this slice. Keep one level loaded in memory to simplify checkpoint restoration; streamed levels are unnecessary until measured performance requires them.

## Godot node choices

Use CharacterBody2D for the hero and grounded enemies, a CollisionShape2D for their physical shape, Area2D sensors for attacks/interactions, and separate visual nodes. Follow the physics-step movement approach in the official [2D movement overview](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html); adapt the controller to this platformer's jump rules.

Use separate TileMapLayer nodes for static collision tiles and decorative tile layers, with individual scenes for moving platforms, consoles, and landmarks. TileMapLayer represents one tile layer; multiple nodes provide multiple layers. Verify its availability in the pinned engine, and do not start new work on the deprecated TileMap node. See the official [TileMapLayer reference](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html). The built prototype uses one blockout `Block` node per solid (a collision rectangle drawn in `_draw()`) instead of tilemaps, which keeps every platform edge explicit and easy to light.

An independently bounded Camera2D follows the hero. CanvasLayer contains the HUD and menus. Choose Sprite2D plus AnimationPlayer or AnimatedSprite2D according to the supplied asset type; neither final rigging nor generated animation sheets are a prerequisite for a blockout. As built, the hero swaps Sprite2D frames from the placeholder Rook sprite pack (each frame with a normal map), and the enemies are lit cutout rigs: Sprite2D parts of a shared atlas under one shader, posed by code from hand-keyed clips (a Mixamo converter is ready). Their painted parts are procedural placeholder art.

**Night look.** Painted parts carry no light of their own (C35); the engine lights them. Lamps, beacons, the fountain and the depot's fixtures are additive `PointLight2D` nodes with smooth falloff textures (`SceneryDraw.smooth_cone_texture()` and `smooth_disc_texture()`), each placed at its real source with a `height`, because a normal-mapped character takes its lighting direction from where the light is. Shadows stay off and the lights reach only the world layer, never the UI. Each shot also flashes a short muzzle light. Dave and the enemies are shaded by `assets/shaders/lit_part.gdshader` (normal-mapped, with specular and emissive maps) and sit under a faint cool moonlight from `scenes/world/night_lighting.tscn`, which LevelDirector instances next to the night overlay. It is meant as a rim on characters only; in Godot 4.7.2's Compatibility renderer the directional light also faintly washes the world (the note in `scripts/world/night_lighting.gd` explains). Platform tops keep thin lit or rim-lit edges, and flat glow shapes (optionally additive glow sprites from `assets/kenney/light-masks/`) stay as halos, over a dark navy-black campus. A screen-space night overlay (a vignette, faint grain and scanlines, and a slow alarm-red edge pulse once the lockdown starts, on a canvas layer below every UI layer) is instanced by LevelDirector when `scenes/world/night_overlay.tscn` exists. Darkness is a composition tool: a light near every landing, lit or rim-lit platform tops, and no tell, ledge or pickup ever hidden by shadow or foreground (see the [style guide](../../art-design/style-guide.md)). Reduced motion is honored, and alarms and strobes stay slow, with no more than three flashes per second and no full-screen flashes.

## Scale, camera, and input

Starting viewport: 1280 × 720, resizable window, maintain an approximately 16:9 gameplay composition. Prototype hero H = 96 world pixels. Keep displayed hero height near one-eighth of screen height; adjust camera zoom and viewport handling together. Test a smaller window and a wider monitor for readable prompts and exposed landings.

Use named Input Map actions from [03](03-gameplay-systems.md). Map mouse aim into world coordinates before aiming the held pistol. Clamp the aim pivot so the muzzle never starts behind collision. Pause stops gameplay and timers while leaving its own UI responsive. Record any unavailable input/device support honestly.

Use static collisions with simple shapes; decorative foliage, sky and distant campus figures have none. The hero and enemies collide with world geometry. Attack sensors determine damage; enemy visual/body overlap alone does not cause damage. Player bolts query solid world and enemy hit zones, never treasure or the hero. Enemy attacks only affect the hero. Interaction sensors cannot catch projectiles. There are no vision or detection sensors: nothing in this slice reacts to being seen (C16).

## State and event contracts

Session signals: health_changed, wallet_changed, enemy_defeated(entity_id), pickup_collected(entity_id), evidence_recorded(evidence_id), keycard_taken(keycard_id), weapon_swapped(old_id,new_id), upgrade_purchased, checkpoint_committed, story_state_changed, level_completed. Use one authoritative owner for each mutation. Do not subscribe twice after Continue.

Stable placement IDs come from [02](02-area-blueprints.md). Additional IDs: W01-P01, W01-P02, SW01, UPG01, SC01, HS01–HS03, KC01; prefix with L01 in saved records. Loose chips use area + G001…; clusters use area + GC01…; the cache uses OPT02-CACHE01 (the `G` in the chip IDs predates the microchip rename and is kept so IDs, saves and tests stay stable). The evidence file is EF01 (pickup entity L01-OPT01-A01) and the keycard is L01-KC01 (pickup entity L01-KC01-P). Enemy IDs are the group ID, the enemy's code and a number (L01-E08-SE01-02): SE01 Night Guard, M01 Patrol Rover, LK01 Staffer. Changing IDs after saves exist requires resetting prototype saves or a documented migration; the revamp raised the save schema to version 2 (added the keycards field), and the C33 rebuild raised it to version 3 because every enemy ID changed (an older save's defeated list would name enemies that no longer exist), so a save from an older build is rejected as incompatible and falls back to New Game.

A saved record contains values and whitelisted IDs, not arbitrary executable scene paths or live node references. Reconstruct the fixed level, then apply collected/defeated/door/weapon/keycard flags, then place the hero at the safe checkpoint marker, then enable input. A completed SC01 applies the settled lockdown arrangement before the hero appears.

## Save design

Use a versioned JSON record under user:// for the prototype, with one checkpoint save and one settings file. The official [saving games guide](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html) explains persistence and JSON/FileAccess; this project's complete snapshot and purchase rules are additional design requirements.

Prepare and validate a complete new snapshot before replacing the prior save. Write a temporary file, close it, keep a last-known-good backup, then replace the checkpoint file using APIs supported by the pinned version. Publish the new committed state only on successful save; on failure restore the prior transaction state and explain the failure. Do not leave an upgrade paid for but unavailable.

Malformed or incompatible saves must not crash into a half-loaded level. Offer a new run or a valid backup with an honest message. New Game replaces the run only after the UI's ordinary restart confirmation. Do not put user saves inside the repository.

## Validation and export

Use Godot's command-line import/headless capabilities for script/resource loading and the state-contract harness; verify command syntax against the pinned executable. Use the editor or normal game launch for visual, input, and collision testing. A successful headless launch alone proves neither playability nor pacing.

Export only after templates matching the pinned engine are installed. Produce a Windows test build and a short launch/readme report. Use the official [command-line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html) for editor/import/export options. These docs were checked during planning; use version-matched documentation if stable changes later.
