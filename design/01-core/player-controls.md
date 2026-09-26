# DEAD EDEN — Player movement, aiming, and action rules

**Document ID:** G02  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Input actions, jump behavior, aiming, action priorities, and movement exclusions.

**Decision references:** C04, C05, P02 — see the [decision register](../decisions.md).  
**Read with:** [weapon swaps](weapon-swaps.md) · [camera and feedback](camera-and-feedback.md) · [health and checkpoints](../03-progression/health-and-checkpoints.md)

## Proposed control model

Use move, jump, aim, fire, alternate fire when unlocked, reload where applicable, interact, and pause. The game remains on one side-view plane. Bindings are remappable; these are action definitions rather than mandatory keyboard keys.

Aim with a pointer or right stick within the gameplay plane. On a controller without active aim input, aim defaults toward the last facing direction. Keyboard-only play has an optional directional aiming scheme. Facing follows deliberate aim while firing and movement otherwise. The body can reverse without a forced turning delay.

## Movement

Walk or run according to input magnitude; digital input uses the standard running speed. Use quick acceleration, predictable braking, and useful air steering. Momentum matters on conveyors and moving platforms, but abrupt invisible friction changes should not decide a jump.

**Untested starting ranges:** about 4 hero-heights per second running speed, a 1.5–1.8 hero-height jump apex, roughly 0.10 seconds of jump grace after leaving an edge, and a 0.10–0.15 second jump input buffer. Tune these against actual body size and platform layouts; do not turn them into established canon.

A short jump-button press gives a lower arc; holding gives the full jump. Jumping does not require a stamina resource. Movement includes no double jump, dash, roll, wall run, swimming, ladder system, or universal wall climb.

## Platforms and interactions

Only clearly marked thin platforms allow a down-plus-jump drop-through. Solid floors never do. Moving platforms carry the hero's position without adding an unexpected launch impulse.

A tether anchor is usable only while the Graviton Tether occupies the single weapon slot. It is not a permanent movement upgrade. All mandatory routes have ordinary movement or interactable alternatives.

Interact chooses the nearest eligible object in a small visible range. The prompt highlights exactly one object. If a weapon and checkpoint overlap, spatially separate their activation areas rather than making the same button unpredictably choose.

## Shooting while moving

Running and jumping permit ordinary firing. Weapon recoil has a visible upper-body response; it does not automatically create an unapproved rocket-jump mechanic. Heavy shots may briefly push the body, but cannot make an otherwise safe landing impossible without a readable rule.

Weapon-specific exceptions own their timing: the shotgun pumps, the Arc Welder can overheat, and the pistol's optional Power Shot charges. Alternate fire exists only when its named upgrade provides one.

Reload can be interrupted by firing a loaded round. Jumping and movement remain available during reload; damage may interrupt the animation but does not delete already loaded ammunition. No reload is required for heat-only tools.

## Action priority and cancellation

Death overrides actions. Damage response briefly interrupts aim but preserves player movement recovery. Pause is available outside short transition moments. An interaction that changes equipment requires deliberate confirmation; running over a gun is insufficient.

An unfinished optional charge is canceled by a weapon swap. A swap cannot occur while the tether holds an object; the player releases it first. Releasing a held object is always possible.

## Accessibility and acceptance

Provide separate settings for aim assistance, stick dead zone, aim sensitivity, and hold/toggle actions where relevant. Input icons follow current bindings.

Check narrow ledges, low ceilings, diagonal shots, firing at close targets, simultaneous jump and reload, and landing on a moving platform. Exact binding layouts and movement numbers remain proposed until tested.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
