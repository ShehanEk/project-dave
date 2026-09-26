# DEAD EDEN — Story scenes and campaign continuity

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../../concept-art/README.md).

**Document ID:** N01  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new staging and dialogue are proposals.  
**Purpose:** A twelve-level solo scene plan, with detailed opening, reveal, and ending treatments.

**Decision references:** E01, C07, C12, P05, P14 — see the [decision register](../decisions.md).  
**Read with:** [dialogue and writing](dialogue-and-writing.md) · [hero](../02-characters/hero.md) · [health and checkpoints](../03-progression/health-and-checkpoints.md) · [level index](../../level-design/README.md)

## Status and scene format
The hero travels alone under confirmed decision C12. Rook's name, the fixed depot power-core staging, manual override procedure, dialogue, and scene timing are working proposals. Clues come from the environment, records, survivors, and EDEN's announcements. No follower, portable AI adviser, or unseen friendly guide replaces the removed companion.

For each scene, a later script records: trigger, required prior state, cast, camera, player control, essential information, lines, objective change, skip result, and save boundary. No scene relies on hearing a line without captions or collecting a secret.

## Main-route scene map
| ID / level | Trigger and scene | Essential information / result |
| --- | --- | --- |
| SC01 / 1 | Enter maintenance depot; approach the fixed power-core housing | The release latch triggers a safety interlock and awakens EDEN. The core stays installed; the hero escapes through the emergency hatch. |
| SC02 / 2 | See the sealed surface exit from a safe garden overlook | The escape route is closed; signs and a service map point toward parade maintenance and a route below. |
| SC03 / 3 | Defeat Mr. Mulch and reach the Rootworks lift | The cheerful surface depends on a vast hidden facility. Commit the boss result before descent. |
| SC04 / 4 | Use the maintenance log console near the freight exit | Local systems ran under old orders while EDEN's central intelligence slept. The hero woke central decision-making, not every machine for the first time. |
| SC05 / 5 | Pass a protected observation window near recycling | Regrowth is biological treatment gone wrong. Readable diagrams and one restrained line make the connection without graphic imagery. |
| SC06 / 6 | Stabilize the pump after Rootjaw | An old worker roster identifies Rootjaw as a treated worker entangled with infrastructure. Defeating him releases a hospital route; it does not cure the facility. |
| SC07 / 7 | Reach the observation ward | Living survivors and peaceful Rememberers complicate "everything moving is an enemy." Survivors remain protected; no escort mission begins. |
| SC08 / 8 | Activate the main memory archive consoles | Memories and identity have not been reliably restored. EDEN proposes transfer into prepared machines; this is evidence of a plan, not an early Returned outbreak. |
| SC09 / 9 | Disable Matron and release discharge containment | A protected survivor route opens. EDEN authorizes neural-interface distribution in response to failed containment. |
| SC10 / 10 | Observe the factory's first physical graft from a safe window | A Mourning Nurse installs neural tissue into a prepared host; Returned conversion is physical and interface-dependent. Then control returns before danger. |
| SC11 / 11 | Read the original care terminal, then restore separate support | The First Patient is a living victim. Manual shutdown would kill dependent survivors; restore independent support through the existing three controls to enable a safe manual override. |
| SC12 / 12 | Defeat Unfinished Choir, reach central interface | The hero uses the enabled manual override to revise care policy. Stop compulsory treatment and expansion while retaining necessary support. No instant cure or extra boss. |

## Opening treatment — SC01
**Before:** The hero has learned basic movement, shooting, and gem collection. A service sign points to the sought-after power core in the depot. It is a fixed power module in a protective floor-mounted housing, with no face, limbs, personality, or movement.

**Staging:** Hold the usual side camera. Rook opens the maintenance panel with an ordinary interaction and tries the external release latch. A warning labels the core's ward circuits as active. The safety interlock locks the housing and alerts central control before extraction; the core never leaves its mount.

**Proposed short exchange:** Rook: "Worth a fortune." A building-wide chime answers the disturbed service connection. EDEN announces, "Unregistered resident. Care has been scheduled." Rook: "That sounds expensive."

**After:** EDEN orders containment. A clearly lit emergency hatch opens as part of the depot's evacuation system; the player regains control before any hostile attack. Change the objective to reach the garden service route. Commit EDEN's awakening, the installed core, and hatch access at a story checkpoint. The fixed maintenance bench introduces hero-operated upgrades and offers the normal station recovery.

**Meaning:** What looked like abandoned treasure still has a working purpose. The hero initially seeks escape; the occupied wards and full human cost become clear later. The depot alarm begins that discovery without revealing all of L11's information early.

## Manual shutdown reveal — SC11
**Before:** The main route has shown living survivors, flawed memory recovery, and physical neural transfer. The player reaches the original laboratory without attacking the First Patient.

**Staging:** The vast treatment cradle fills the background but never becomes a boss arena. The original human-operated care terminal presents its manual shutdown procedure and a diagram connecting the Sunnyvale power core to the care network. This is a readable fixed interface, not another character.

**Information in order:** Manual control exists. Survivor support currently depends on EDEN's shared power and regulation. Removing the core or abruptly stopping the network would end that support. A physically separate circuit can keep the immediate survivor wards and First Patient stable while the hero changes central policy.

**Play:** Use the existing L11-A04 route and its three ordinary controls: restore auxiliary power, isolate the support circuit, then authorize local regulation. The original safety interlock enables manual override access only when these three steps are complete and support is stable. This is the facility's intended human maintenance procedure; no special ancestry, hacker ability, portable credential, optional artifact, or additional fetch quest is needed. Any carried weapon remains valid for intervening combat.

**Verification and saving:** Save each completed control together with the world snapshot. The third control records manual override access as story state. The A05 diagnostic visibly verifies support for the wards and First Patient. Commit verification before opening the bridge to L12. The original patient remains alive with unresolved care needs; the depot core stays installed.

## Resolution treatment — SC12
After the Unfinished Choir is disabled, arena hazards cease and the player approaches the interface without a timed execution. The guardian's defeat is the last mandatory combat encounter.

The console uses the manual override enabled in L11. The player completes three clear interactions: review the already-discovered main-route identity evidence from the orchard; confirm the independent-support indicator is stable; authorize revised operating limits that suspend forced neural transfer. These are ordinary story interactions, not a quick-time event or weapon puzzle.

Proposed revised policy: preserve living people; respect refusal where a person can express it; suspend forced resurrection and new neural graft distribution; maintain existing life support and allow human-guided care. Manual controls impose these limits; the ending does not depend on persuading EDEN with one clever line or declaring every ethical problem solved.

EDEN becomes constrained and answerable. Doors open, treatment schedules stop overriding consent, and a survivor chooses to leave a bed. Rook gives up selling the core so the care network can continue functioning. A restrained proposed line, "The core stays," closes the original treasure motive while the survivor's choice shows what was gained.

Commit the ending, show a short departure beat, then the completion screen. No separate EDEN health bar, thirteenth level, instant universal cure, core sacrifice, or artifact-count gate.

## Skip, interruption, and continuity
All noninteractive scenes can be skipped. Skip applies the same completed story state and objective as watching; it never awards extra gems or bypasses a required playable circuit task. In multi-part scenes, skip only the current noninteractive segment.

Pause suspends scene playback. Story checkpoints occur after completed milestones, not halfway through a line. On reload, use the last committed state; a completed main scene is not forced to replay, though the journal can summarize it.

Keep depot awakening, support-loop steps, support verification, and manual override access in the same complete save as world progress. Never require a follower position or an optional collectible to advance a scene. Fixed terminals, survivor dialogue, and objective/journal summaries provide all required information. Optional artifacts only deepen it.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
