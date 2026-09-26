# 04 — Godot implementation architecture

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md). [Selected references](../../concept-art/l01-sunnyvale/README.md).

**Status:** Proposed implementation design. No engine project exists yet. M0 must check the installed Godot 4 stable version, record its exact patch, and verify required APIs against that version. All future paths below are relative to prototypes/sunnyvale-godot/ unless stated otherwise.

## Small project structure

~~~text
project.godot
scenes/
  main.tscn
  levels/level_01.tscn
  levels/areas/a01_gate.tscn ... a06_exit.tscn
  actors/hero.tscn, resident.tscn, clipper.tscn
  weapons/scrapjack.tscn, scrap_bolt.tscn
  objects/recovery_station.tscn, maintenance_bench.tscn
  objects/gem.tscn, gem_cache.tscn, artifact.tscn
  objects/weapon_pad.tscn, care_capsule.tscn
  objects/moving_platform.tscn, route_switch.tscn
  objects/core_console.tscn, exit_wicket.tscn
  ui/hud.tscn, pause.tscn, bench_panel.tscn, completion.tscn
scripts/
  actors/, weapons/, objects/, ui/
  session.gd, checkpoint_service.gd, level_director.gd
data/
  tuning/, encounters/, dialogue/
assets/
  characters/, weapons/, environments/, ui/, audio/
tests/
  state_contracts.gd
reports/
  build-notes.md, playtests/
~~~

This is a planned layout, not a demand to generate empty files. Create only what a completed milestone needs. Keep editor caches, test saves, and exported binaries out of source control. Later AI agents should preserve the repository's existing concept files and staged work.

## Scene responsibilities

| Owner | Responsibility |
| --- | --- |
| Main | Boots a new run or valid Continue, hosts level and interface |
| Level01 / LevelDirector | Area order, encounter activation, objectives, SC01, quarantine state, completion |
| Six area scenes | Static geometry, placed entity IDs, safe entry/exit, camera bounds, reference props |
| Hero | Input, physics movement, health, one equipped weapon; no story logic |
| Resident / Clipper | Local state machines, warnings, attack token requests, hit/death reporting |
| Scrapjack | Cadence, held pose, bolt emission; stage from earned upgrade record |
| Interactable objects | One highlighted action, stable ID, value-state reporting |
| Session | One run's current value state and latest complete committed snapshot |
| CheckpointService | Snapshot serialization/restoration; complete purchase/save transaction |
| UI | Reads state/signals; requests actions, never directly edits saved wallets or story flags |

Use reusable scenes and a few small resources for tuning. Avoid an entity framework, dependency-injection system, or full campaign manager for this slice. Keep one level resident in memory to simplify checkpoint restoration; streamed levels are unnecessary until measured performance requires them.

## Godot node choices

Use CharacterBody2D for the hero and grounded enemies, a CollisionShape2D for their physical shape, Area2D sensors for attacks/interactions, and separate visual nodes. Follow the physics-step movement approach in the official [2D movement overview](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html); adapt the controller to this platformer's jump rules.

Use separate TileMapLayer nodes for static collision tiles and decorative tile layers, with individual scenes for moving platforms, consoles, and landmarks. TileMapLayer represents one tile layer; multiple nodes provide multiple layers. Verify its availability in the pinned engine, and do not start new work on the deprecated TileMap node. See the official [TileMapLayer reference](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html).

An independently bounded Camera2D follows the hero. CanvasLayer contains the HUD and menus. Choose Sprite2D plus AnimationPlayer or AnimatedSprite2D according to the supplied asset type; neither final rigging nor generated animation sheets are a prerequisite for a blockout.

## Scale, camera, and input

Starting viewport: 1280 × 720, resizable window, maintain an approximately 16:9 gameplay composition. Prototype hero H = 96 world pixels. Keep displayed hero height near one-eighth of screen height; adjust camera zoom and viewport handling together. Test a smaller window and a wider monitor for readable prompts and exposed landings.

Use named Input Map actions from [03](03-gameplay-systems.md). Map mouse aim into world coordinates before aiming the held pistol. Clamp the aim pivot so the muzzle never starts behind collision. Pause stops gameplay and timers while leaving its own UI responsive. Record any unavailable input/device support honestly.

Use static collisions with simple shapes; decorative leaves, clouds, and distant inhabitants have none. The hero and enemies collide with world geometry. Attack sensors determine damage; enemy visual/body overlap alone does not cause damage. Player bolts query solid world and enemy hit zones, never treasure or the hero. Enemy attacks only affect the hero. Interaction sensors cannot catch projectiles.

## State and event contracts

Suggested signals: health_changed, wallet_changed, enemy_defeated(entity_id), pickup_collected(entity_id), weapon_swapped(old_id,new_id), upgrade_purchased, checkpoint_committed, story_state_changed, level_completed. Use one authoritative owner for each mutation. Do not subscribe twice after Continue.

Stable placement IDs come from [02](02-area-blueprints.md). Additional IDs: W01-P01, W01-P02, SW01, UPG01, SC01, HS01–HS03; prefix with L01 in saved records. Loose gems use area + G001…; clusters use area + GC01…; cache uses OPT02-CACHE01. Changing IDs after saves exist requires resetting prototype saves or a documented migration.

A saved record contains values and whitelisted IDs, not arbitrary executable scene paths or live node references. Reconstruct the fixed level, then apply collected/defeated/door/weapon flags, then place the hero at the safe checkpoint marker, then enable input. A completed SC01 applies the settled quarantine arrangement before the hero appears.

## Save design

Use a versioned JSON record under user:// for the prototype, with one checkpoint save and one settings file. The official [saving games guide](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html) explains persistence and JSON/FileAccess; this project's complete snapshot and purchase rules are additional design requirements.

Prepare and validate a complete new snapshot before replacing the prior save. Write a temporary file, close it, keep a last-known-good backup, then replace the checkpoint file using APIs supported by the pinned version. Publish the new committed state only on successful save; on failure restore the prior transaction state and explain the failure. Do not leave an upgrade paid for but unavailable.

Malformed or incompatible saves must not crash into a half-loaded level. Offer a new run or a valid backup with an honest message. New Game replaces the run only after the UI's ordinary restart confirmation. Do not put user saves inside the repository.

## Validation and export

Use Godot's command-line import/headless capabilities for script/resource loading and the state-contract harness; verify command syntax against the pinned executable. Use the editor or normal game launch for visual, input, and collision testing. A successful headless launch alone proves neither playability nor pacing.

Export only after templates matching the pinned engine are installed. Produce a Windows test build and a short launch/readme report. Use the official [command-line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html) for editor/import/export options. These docs were checked during planning; use version-matched documentation if stable changes later.
