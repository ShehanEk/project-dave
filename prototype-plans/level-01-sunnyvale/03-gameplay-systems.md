# 03 — Prototype gameplay contracts

**Visual direction (C11, C15):** [hand-drawn 2D in a dark night-campus palette](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24); there are no selected scene images for the new look.

## Movement and input

Use the [player rules](../../design/01-core/player-controls.md). Prototype input actions: move_left/right (A/D or arrows), jump (Space), aim (mouse), fire (left button), interact (E), pause (Escape), journal (Tab); the built prototype also maps skip (Enter, ends a noninteractive scene early) and help (F1, the controls view). These are proposed defaults, not hard-coded checks scattered across scripts. Fire may repeat while held at the configured interval. Quickcycle changes cadence only.

Proposed blockout scale: H = 96 px, run 4H/s (384 px/s), jump apex 1.6H, time to apex 0.42s, coyote grace 0.10s, jump buffer 0.12s. Derive starting gravity and takeoff velocity from the chosen apex and time; tune against the gap course. Releasing jump early cuts the rising arc. Permit useful air steering and firing while moving.

No double jump, dash, climb, ladder, fall-through floor, or reload input is needed in this slice. The pistol has no magazine. Movement and collision use the physics step; visual animation never determines whether the character is grounded. There is no stealth input or state (no crouch-hide, no noise, no vision cones): Metal Gear is a mood reference only (C16).

## Pistol and upgrade

| Parameter | Untested seed |
| --- | --- |
| Basic shot | 1 damage; finite visible bolt; one valid hit then despawn |
| Base interval | 0.32s |
| Quickcycle interval | 0.24s |
| Ammo / reload | Unlimited basic fire / none |
| Upgrade | Stage 1 Quickcycle; 40 microchips; buy once per run |
| Stage 2 / 3 | Not purchasable in L01; no extra ability or attachment implemented |
| Collision | Stops at solid scenery; use swept movement/raycast validation to prevent tunneling |
| Lifetime | Despawn out of range/offscreen after a short bounded flight |

Preserve the [W01 silhouette and stage-1 attachment](../../art-design/weapons/w01-scrapjack-pistol.md). Choose bolt speed/range in M1 and record it in the tuning resource and handoff. Damage and cadence cannot silently differ between input devices.

The optional depot pad performs an **atomic exchange** between the one equipped instance and the one world instance. Cancel means no change. Swapping again uses the same IDs. Do not create a third gun, duplicate progression, reset shots in flight, or make a second equipment slot. Same-type swaps prove the rule; other weapon implementations are deferred.

## Staffer — CY01

The Staffer is a cyborg: an Arcadia night-shift employee whose coin-sized Link implant, behind the ear, Adam controls ([identity brief](../../art-design/linked/lk01-staffer.md)). It replaces the old zombie Resident and keeps that enemy's combat role and numbers.

Proposed states: idle/patrol → slow approach → lunge windup → short committed lunge → recovery → approach; hit reaction and defeated states as appropriate. Ground/ledge sensors keep it within its lane.

Seeds: 3 health, approach 0.8H/s, 0.65s windup, short lunge up to 1.2H over 0.30s, 0.80s recovery, one health of damage. Movement is stiff and puppet-like, then suddenly fast. Windup reads as a twitch: the Staffer crouches and coils forward, the arms come up with fluttering fingers and the head snaps sideways in jerks that build toward the lunge, while the Link light flashes red (the Link light is teal at rest, amber while Adam drives the body, and red before an attack; see the style guide), and the windup sound is an implant chirp (the level brief's sound notes); a tiny chirp also sounds once as the Link turns amber and Adam takes the body over. The lunge hurtbox is visible. Do not turn a harmless habitual routine (badging a door, carrying a tray) into an untelegraphed hit. Ordinary body shots work.

In the C24 build, Staffers are disabled, not killed: on defeat the Link light dies and the body slumps unconscious, with no gore, blood or wounds (C28 and C29 supersede this: every enemy now dies and bleeds). Mechanically that is one ordinary defeat. No armor phase, grab, status effect, or revival. The Link light is a tell, not a detection state: no vision cone, alert icon or hiding.

## Clipper — R01 (C24 build; removed under C32)

The Clipper is one of Adam's machines, a campus groundskeeping robot with oversized hedge shears (its selected design, C10, was deleted when the Clipper was removed under C32). It stays purely mechanical.

Proposed states: patrol → acquire on-plane hero → charge windup → straight ground charge → wall stall or missed-charge brake → recovery. Both eye stalks retract together and shears open during warning, and its lenses turn alarm red as the stalks draw back and stay red until the charge ends (amber while hunting, dark when disabled; the style guide's lens-light rule, a readability cue and never a detection state). It cannot turn instantly during its charge, jump, or continue across an unmarked ledge.

Seeds: 0.8s windup, charge 5H/s capped at 4H, 1.6s wall-stall recovery, 3 exposed-motor health, one health of charge/shear damage. Indestructible backstops make a stall possible in every lane. The rear motor is the valid damage zone during the stall; frontal shell hits give distinct blocked feedback. Successful basic shots never demand an upgrade.

First tutorial: the observation step provides a clear view of the warning, collision, and stalled rear opening. Place the hero's jump and landing so they can reach that rear opening before the recovery ends. Tune stall length if three base shots cannot fit comfortably.

## Combat fairness

At most two enemies may be active in a group and one may hold the attack token through its windup/active attack. Others can approach without contact damage but must not body-block every exit. After that attack, release the token fairly; do not let one enemy monopolize it. Player damage is from explicit attack hitboxes, not every sprite overlap.

No cross-group pursuit, attacks from unseen camera regions, random spawns, or damage while returning control after a scene. A shot shows hit/blocked feedback distinctly. Each enemy is defeated once; no random currency drops. Every tell is carried by motion, sound and shape as well as by the reserved tell colors (red means attack now), and darkness must never hide one.

## Health, supplies, and checkpoints

Use six health units, one-health hits throughout L01, about one second of damage immunity, small knockback, and no limited lives. Med-patches HS01/02/03 restore two health only when needed. Tutorial catch floors do no damage. The one marked exit pit costs one health and returns to a fixed safe foothold; at zero health perform checkpoint recovery instead.

CP00 is the new-game snapshot. CP01/02/03 are recovery stations activated by Interact: heal and commit. CP04 commits SC01 without automatic healing. The depot workbench can separately service, save, and sell Quickcycle. CP05 saves completion. Reusing a station can heal and commit again but never respawns chips or defeated enemies.

A complete snapshot includes schema/build version, checkpoint/respawn ID, health, wallet, collected chip/cache IDs, evidence file IDs, keycard IDs, earned stages, equipped/world weapon IDs and fitted stages, defeated enemy IDs, SW01 state, story flags, and objective. Save a deep value copy. On rollback restore these together; do not combine a saved wallet with current uncollected chips.

Transient projectiles disappear. Surviving enemies return to safe idle placements and full starting health; defeated enemies stay defeated as saved. Platforms resume a safe phase. Partial fights cannot spawn an attack at the respawn point. New Game clears the whole run including upgrade and world pickups; Continue restores the last complete commit.

## Keycard and exit lock

Each campaign level's exit door needs that level's clearance card (P19, the *Dangerous Dave* trophy-and-door rule in Arcadia's language). Level 1 has one card, **L01-KC01**, picked up by contact on the A04 far porch just past the CP03 station (pickup entity L01-KC01-P). It is an exit lock, not inventory: it never occupies the weapon slot, is never sold or dropped by an enemy, and opens only the A06 exit wicket.

- **Locked:** the wicket's card reader shows a locked light. Entering without the card shows a harmless "Clearance card required" message, plays a reader-buzz cue, and never ends the level or damages the hero. The card is on the main route, so a player who reaches the wicket without it only has to walk back to the A04 far porch: this is a reminder, not a puzzle, and the level must never become a softlock over the card.
- **Unlocked:** once the card is held the reader shows its unlocked state, and crossing the wicket plays an unlock cue and commits CP05.
- **State:** the card is recorded in `state["keycards"]` (whitelisted `L01-KC##` IDs) and its pickup entity is recorded as collected with zero chip value. It follows checkpoint rollback like every pickup: taken after the last commit, it returns on death; committed, it never duplicates. CP04 and later commits retain it.
- **HUD:** a small card icon appears in the top bar once the card is held.

## Story states and UI

SC01 prerequisites: hero in the safe depot, no active encounter, awakening_done false. Ordinary interaction with the core node's maintenance port ("Plug in") starts the copy scene. Completion **and skip** set awakening_done=true (Adam has answered and the lockdown has begun; the flag keeps its original name), core_installed=true, hatch_open=true, objective="Escape through the service wicket.", and CP04 together. The workbench unlocks from that state. A repeated interaction only shows a short status line ("Uplink severed. Lockdown active.").

The objective sequence is "Reach the server depot." → "Plug into Adam's core node." (set on first entering A05) → "Escape through the service wicket." (SC01) → "Sunnyvale complete." (the wicket).

UI minimum: six health segments, one weapon/stage, readiness cue, microchip wallet, keycard indicator (shown once the card is held), current objective, highlighted single interaction, subtitle panel. Pause contains resume, journal (objective and evidence file), controls, settings, restart checkpoint, and quit; explain rollback before restart. Completion totals derive from unique collected IDs, so spending does not lower "chips found."

Workbench flow: inspect next stage → show 40-chip price and resulting wallet → confirm → deduct wallet and fit/record stage together → commit full snapshot → report success. Decline, insufficient funds, and repeat purchase leave state unchanged. A purchase also captures earlier evidence/keycard/switch/enemy progress; never save only the upgrade.

## Treasure allocation

Main route: A01 5 singles; A02 5 singles + 1 five-value cluster; A03 5 singles + 1 cluster; A04 10 singles + 2 clusters. A single is one microchip and a cluster is a small stack worth five. Total **25 singles + 4 clusters = 45**, all before the depot. OPT02 adds one 20-chip cache for **65 total**. OPT01 adds the zero-value EF01 "Lockout Notice" evidence file. The keycard is a main-route item with zero chip value.

Assign every pickup a stable ID. Contact collects loose chips and the keycard; Interact opens the cache and records the evidence file. No kill, idle wait, checkpoint replay, or weapon swap generates more chips. Collecting none and buying nothing must still permit completion (the main-route keycard is still needed to leave).
