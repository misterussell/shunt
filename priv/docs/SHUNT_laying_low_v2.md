# Sprint Passoff: Character Mode System (Laying Low v1)

## Objective

Implement the first iteration of a generalized **Character Mode System** using **Laying Low** as the initial production feature.

This sprint is intended to establish the underlying architecture for temporary gameplay states that modify player interaction without requiring separate game systems or locations.

Future modes (hospitalized, incarcerated, on the run, etc.) should be able to build upon the same framework.

---

# First Task: Review the Existing Codebase

Before implementing anything, perform a thorough review of the existing systems to understand how they currently interact.

Pay particular attention to:

* Character state management
* Action generation and filtering
* Event resolution
* World state progression
* Time advancement
* Heat (or equivalent wanted/suspicion mechanics)
* Node/location architecture
* Content loading and registration
* Existing reward/effect pipelines
* UI rendering for available actions

The implementation should integrate with the current architecture instead of introducing duplicate concepts.

If an existing system already solves part of this problem, extend it rather than replacing it.

---

# Sprint Goals

The completed sprint should introduce a reusable Mode System capable of:

* Tracking temporary character gameplay modes.
* Altering available player actions.
* Providing mode-specific event pools.
* Supporting action-driven time advancement.
* Supporting action-driven Heat reduction.
* Remaining compatible with the existing data-driven architecture.

The goal is not simply to implement Laying Low, but to establish a reusable framework that future gameplay modes can leverage.

---

# Design Principles

The implementation should strive for the following characteristics:

* Character-centric rather than location-centric.
* Data-driven where practical.
* Easily extensible.
* Compatible with existing action/event systems.
* Minimal special-case logic.
* Avoid introducing parallel gameplay architectures.

Laying Low should feel like an alternate interaction state layered over the existing game rather than an entirely separate gameplay mode.

---

# Evaluate Existing Architecture

During implementation planning, determine whether existing systems already provide suitable extension points for:

## Character State

Is there already a generalized mechanism capable of tracking temporary player states?

If so, determine whether it can be extended rather than introducing a dedicated mode implementation.

---

## Action Availability

Review how player actions are currently collected and presented.

Determine the cleanest point for introducing mode-aware filtering or augmentation.

Avoid hardcoding Laying Low checks throughout the action system.

---

## Event Pools

Review how random events are currently selected.

Investigate whether event selection can become mode-aware without significantly increasing complexity.

The preferred solution should allow future modes to contribute their own event pools.

---

## Time Progression

Review how time currently advances throughout gameplay.

Laying Low actions should integrate into whatever progression model already exists.

Avoid implementing an isolated timing system.

---

## Heat

Review how Heat currently exists within the project.

If Heat has not yet been fully implemented, design the Mode System so that Heat integration remains straightforward when completed.

---

# Laying Low (Version 1)

The first production mode should represent a player intentionally avoiding attention after generating excessive Heat.

While in this mode:

* High-risk activities should be restricted.
* Low-profile activities become available.
* Time continues advancing.
* Heat gradually decreases.
* New narrative opportunities become available.

The player should remain engaged instead of waiting for passive timers.

---

# Initial Laying Low Activities

These activities represent the initial gameplay loop.

## Rest

Purpose:

Passive recovery.

Suggested behavior:

* Advance time.
* Reduce Heat.
* Trigger narrative flavor.

---

## Gather Rumors

Purpose:

Continue progressing through the social and information systems while remaining hidden.

Potential outcomes:

* New rumors.
* Future jobs.
* New contacts.
* World state information.

Suggested behavior:

* Advance time.
* Small Heat reduction.

---

## Visit Contact

Purpose:

Maintain or expand relationships while remaining out of public view.

Potential outcomes:

* Relationship progression.
* Information.
* Favors.
* Services.

Suggested behavior:

* Advance time.
* Moderate Heat reduction.

---

## Train

Purpose:

Allow downtime to contribute toward long-term progression.

Potential outcomes:

* Skill progression.
* Practice events.
* Narrative development.

Suggested behavior:

* Advance time.
* Small Heat reduction.

---

## Burn Evidence

Purpose:

Actively reduce Heat through player investment.

Potential outcomes:

* Significant Heat reduction.
* Resource costs.
* Possible future narrative consequences.

Suggested behavior:

* Advance time.
* Large Heat reduction.

---

## Relocate Safehouse

Purpose:

Reduce attention through relocation.

Potential outcomes:

* Large Heat reduction.
* Financial cost.
* Future location-based consequences.

Suggested behavior:

* Advance time.
* Significant Heat reduction.

---

# Heat Reduction / Time Progression

Rather than relying on passive timers, Laying Low should encourage active decision-making.

Each activity should generally:

* Advance world time.
* Apply Heat reduction.
* Resolve an event.
* Apply any additional rewards or consequences.

Suggested starting values for balancing:

| Activity           | Heat Reduction | Time Advancement |
| ------------------ | -------------: | ---------------: |
| Rest               |             -5 |          6 hours |
| Gather Rumors      |             -3 |          4 hours |
| Visit Contact      |             -5 |          6 hours |
| Train              |             -2 |          8 hours |
| Burn Evidence      |            -15 |          4 hours |
| Relocate Safehouse |            -20 |         12 hours |

These values should be treated as tuning parameters rather than fixed implementation requirements.

---

# Laying Low Event Pool

While in this mode, consider introducing a dedicated event pool containing narrative interruptions unique to hiding from attention.

Initial examples include:

* Witness Recognizes You
* Police Inquiry
* Old Associate Arrives
* Rival Tracks Safehouse

The implementation should ideally make it straightforward for future modes to provide their own event collections.

---

# Deliverables

By the end of the sprint, the project should ideally support:

* A generalized Character Mode framework.
* Laying Low as the first implemented mode.
* Mode-aware action availability.
* Mode-aware event selection.
* Action-driven time progression.
* Action-driven Heat reduction.
* A complete gameplay loop that allows players to meaningfully engage while reducing Heat.

---

# Stretch Goals

If the implementation naturally supports additional flexibility without significantly increasing complexity, consider designing the framework so future modes can customize:

* Available actions.
* Event pools.
* UI presentation.
* Restrictions.
* Passive effects.
* Progression rules.

The objective is to make future modes primarily a content problem rather than an architectural problem.

---

# Final Notes

Do not treat this document as a rigid implementation specification.

Use it as a design target while allowing the existing codebase to dictate the final architecture.

If the current systems provide cleaner extension points than those suggested here, prefer solutions that align with the existing project structure and preserve the project's data-driven philosophy.
