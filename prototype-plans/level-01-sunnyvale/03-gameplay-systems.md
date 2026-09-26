# 03 — Prototype gameplay contracts

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md). [Selected references](../../concept-art/l01-sunnyvale/README.md).

## Movement and input

Use the [player rules](../../design/01-core/player-controls.md). Prototype input actions: move_left/right (A/D or arrows), jump (Space), aim (mouse), fire (left button), interact (E), pause (Escape), journal (Tab). These are proposed defaults, not hard-coded checks scattered across scripts. Fire may repeat while held at the configured interval. Quickcycle changes cadence only.

Proposed blockout scale: H = 96 px, run 4H/s (384 px/s), jump apex 1.6H, time to apex 0.42s, coyote grace 0.10s, jump buffer 0.12s. Derive starting gravity and takeoff velocity from the chosen apex and time; tune against the gap course. Releasing jump early cuts the rising arc. Permit useful air steering and firing while moving.

No double jump, dash, climb, ladder, fall-through floor, or reload input is needed in this slice. The pistol has no magazine. Movement and collision use the physics step; visual animation never determines whether the character is grounded.

## Pistol and upgrade

| Parameter | Untested seed |
| --- | --- |
| Basic shot | 1 damage; finite visible bolt; one valid hit then despawn |
| Base interval | 0.32s |
| Quickcycle interval | 0.24s |
| Ammo / reload | Unlimited basic fire / none |
| Upgrade | Stage 1 Quickcycle; 40 gems; buy once per run |
| Stage 2 / 3 | Not purchasable in L01; no extra ability or attachment implemented |
| Collision | Stops at solid scenery; use swept movement/raycast validation to prevent tunneling |
| Lifetime | Despawn out of range/offscreen after a short bounded flight |

Preserve the [W01 silhouette and stage-1 attachment](../../art-design/weapons/w01-scrapjack-pistol.md). Choose bolt speed/range in M1 and record it in the tuning resource and handoff. Damage and cadence cannot silently differ between input devices.

The optional depot pad performs an **atomic exchange** between the one equipped instance and the one world instance. Cancel means no change. Swapping again uses the same IDs. Do not create a third gun, duplicate progression, reset shots in flight, or make a second equipment slot. Same-type swaps prove the rule; other weapon implementations are deferred.

## Resident — Z01

Proposed states: idle/patrol → slow approach → lunge windup → short committed lunge → recovery → approach; hit reaction and defeated states as appropriate. Ground/ledge sensors keep it within its lane.

Seeds: 3 health, approach 0.8H/s, 0.65s windup, short lunge up to 1.2H over 0.30s, 0.80s recovery, one health of damage. Windup leans the torso and lifts the hands; lunge hurtbox is visible. Do not turn a harmless habitual wave into an untelegraphed hit. Ordinary body shots work. No glowing core, armor phase, grab, infection status, or resurrection.

## Clipper — R01

Proposed states: patrol → acquire on-plane hero → charge windup → straight ground charge → wall stall or missed-charge brake → recovery. Both eye stalks retract together and shears open during warning. It cannot turn instantly during its charge, jump, or continue across an unmarked ledge.

Seeds: 0.8s windup, charge 5H/s capped at 4H, 1.6s wall-stall recovery, 3 exposed-motor health, one health of charge/shear damage. Indestructible backstops make a stall possible in every lane. The rear motor is the valid damage zone during the stall; frontal shell hits give distinct blocked feedback. Successful basic shots never demand an upgrade. No organic infection.

First tutorial: the observation step provides a clear view of the warning, collision, and stalled rear opening. Place the hero's jump and landing so they can reach that rear opening before the recovery ends. Tune stall length if three base shots cannot fit comfortably.

## Combat fairness

At most two enemies may be active in a group and one may hold the attack token through its windup/active attack. Others can approach without contact damage but must not body-block every exit. After that attack, release the token fairly; do not let one enemy monopolize it. Player damage is from explicit attack hitboxes, not every sprite overlap.

No cross-group pursuit, attacks from unseen camera regions, random spawns, or damage while returning control after a scene. A shot shows hit/blocked feedback distinctly. Each enemy is defeated once; no random currency drops.

## Health, supplies, and checkpoints

Use six health units, one-health hits throughout L01, about one second of damage immunity, small knockback, and no limited lives. HS01/02/03 restore two health only when needed. Tutorial catch floors do no damage. The one marked exit pit costs one health and returns to a fixed safe foothold; at zero health perform checkpoint recovery instead.

CP00 is the new-game snapshot. CP01/02/03 are recovery stations activated by Interact: heal and commit. CP04 commits SC01 without automatic healing. The depot bench can separately service, save, and sell Quickcycle. CP05 saves completion. Reusing a station can heal and commit again but never respawns gems or defeated enemies.

A complete snapshot includes schema/build version, checkpoint/respawn ID, health, wallet, collected gem/cache IDs, artifact IDs, earned stages, equipped/world weapon IDs and fitted stages, defeated enemy IDs, SW01 state, story flags, and objective. Save a deep value copy. On rollback restore these together; do not combine a saved wallet with current uncollected gems.

Transient projectiles disappear. Surviving enemies return to safe idle placements and full starting health; defeated enemies stay defeated as saved. Platforms resume a safe phase. Partial fights cannot spawn an attack at the respawn point. New Game clears the whole run including upgrade and world pickups; Continue restores the last complete commit.

## Story states and UI

SC01 prerequisites: hero in safe depot, no active encounter, awakening_done false. Ordinary interaction activates the latch. Completion **and skip** set awakening_done=true, core_installed=true, hatch_open=true, objective="Reach the garden wicket", and CP04 together. The bench unlocks from that state. A repeated interaction only shows a short status line.

UI minimum: six health segments, one weapon/stage, readiness cue, gem wallet, current objective, highlighted single interaction, subtitle panel. Pause contains resume, objective/artifact journal, settings, restart checkpoint, and quit; explain rollback before restart. Completion totals derive from unique collected IDs, so spending does not lower "gems found."

Bench flow: inspect next stage → show 40-gem price and resulting wallet → confirm → deduct wallet and fit/record stage together → commit full snapshot → report success. Decline, insufficient funds, and repeat purchase leave state unchanged. A purchase also captures earlier artifact/switch/enemy progress; never save only the upgrade.

## Treasure allocation

Main route: A01 5 singles; A02 5 singles + 1 five-value cluster; A03 5 singles + 1 cluster; A04 10 singles + 2 clusters. Total **25 singles + 4 clusters = 45**, all before the depot. OPT02 adds one 20-value cache for **65 total**. OPT01 adds the zero-value A01 Welcome Key artifact.

Assign every pickup a stable ID. Contact collects loose gems; Interact opens the cache and records the artifact. No kill, idle wait, checkpoint replay, or weapon swap generates more gems. Collecting none and buying nothing must still permit completion.
