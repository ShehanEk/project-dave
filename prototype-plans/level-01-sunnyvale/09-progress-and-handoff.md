# 09 — Progress and next-agent handoff

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md). [Selected references](../../concept-art/l01-sunnyvale/README.md).

## Current state

**Planning status:** Complete, pending any user refinements.  
**Implementation status:** Not started.  
**Engine:** Godot selected by user; exact version not yet pinned.  
**Duration:** 750-second main-route design budget; no measured playtest.  
**Build directory:** prototypes/sunnyvale-godot/ (planned; not created).  
**Next action:** When asked to execute, begin M0 using 08's master or M0 prompt.

| Milestone | Status | Evidence |
| --- | --- | --- |
| M0 Setup | Not started | None |
| M1 Hero/pistol | Not started | None |
| M2 Enemies | Not started | None |
| M3 Full blockout | Not started | None |
| M4 Progression/save | Not started | None |
| M5 Story/exit | Not started | None |
| M6 Presentation | Not started | None |
| M7 Validation/export | Not started | None |

## Baseline and outstanding prerequisites

This plan includes and depends on the companion-removal revision (C12). Use a checkout containing both this folder and the updated solo narrative. Preserve unrelated local or staged work when starting implementation. Publishing changes is separate from running a local prototype.

Needed at build time: an available Godot 4 stable runtime; matching Windows export templates for M7; actual first-time players for the timing gate. No third-party service or paid asset is required. The selected PNGs exist, but finished hero/weapon sprites, animation sets, and modular scenery are not supplied.

## Planning decisions and proposed defaults

| Topic | Status / choice |
| --- | --- |
| Godot | User selected |
| Duration | User requested 10–15 minutes; proposed central budget 12:30 |
| Rendering / protagonist | Confirmed hand-drawn 2D; solo hero |
| Language / platform / renderer | Proposed GDScript / Windows / Compatibility |
| Engine patch | Unset; record at M0 |
| Input | Proposed keyboard/mouse first; controller deferred |
| Local level expansion | Proposed 32 beats, 15 enemies, 2 optional branches, extra recovery points |
| Build scope | W01 + Quickcycle only; no boss or later weapon |
| Art | Existing selected reference PNGs; placeholder-first implementation |
| Version control | Existing signing settings remain in force; no signing bypass |

## Update after each implementation session

~~~text
Date / agent / milestone:
Exact Godot version / executable:
Starting state and pre-existing changes:
Implemented behavior:
Files changed:
Checks actually run and outcomes:
Timing / machine measurements, if any:
Remaining errors / placeholders / unverified gates:
Design deviations and reasons:
Save/schema compatibility notes:
Next concrete action:
~~~

Use statuses **not started**, **in progress**, **implemented, unverified**, **verified**, or **blocked by [specific prerequisite]**. Only mark M7 verified after all applicable completion gates pass. Keep estimates separate from observations.

When a tuning number, count, route, or milestone changes, update its owner and prototype-spec.json together. Do not silently rewrite the broad campaign from a prototype experiment.
