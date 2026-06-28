# Shunt Feature Design & Implementation Review

## Feature: District Evolution & World State System (Shunt 9 Prototype)

## Objective

Design and implement the first iteration of a persistent, data-driven **District Evolution** system using **Shunt 9** as the initial proving ground.

The purpose of this feature is to connect existing gameplay systems (repair events, Ghostwork, Street Alchemy, rumors, NPCs, locations, etc.) through a shared world state rather than isolated event scripting.

This is intended to become a foundational gameplay system that other districts can eventually adopt.

---

# IMPORTANT

Before proposing an implementation plan, **review the existing codebase thoroughly.**

Do **not** assume new systems need to be created from scratch.

Identify and document:

* Existing event architecture
* Event resolution pipeline
* Effect/reward system
* NPC spawning/loading
* Location rendering
* Exit requirements
* Rumor implementation
* Ghostwork implementation
* Street Alchemy implementation
* Content registry
* World/content loading
* Persistence model
* Character progression/state

The implementation plan should integrate with the current architecture instead of replacing it.

Whenever possible:

* extend existing systems
* avoid duplicate abstractions
* preserve the data-driven philosophy already present in the project

---

# Design Goals

The world should gradually feel alive.

Instead of events simply rewarding the player, events should produce **changes in the world's persistent state**.

Those changes should naturally influence:

* locations
* NPC availability
* rumors
* Ghostwork interactions
* crafting stations
* exits
* future events

The player should experience the district evolving rather than completing scripted quest chains.

---

# Core Philosophy

Avoid:

```
Repair Relay

↓

Spawn Merchant

↓

Unlock Quest
```

Instead:

```
Repair Relay

↓

World State Updated

↓

Everything reacts to that state
```

Events should produce **facts**.

Systems consume those facts.

No feature should directly manipulate another feature whenever possible.

---

# Proposed World State Layer

Investigate introducing a persistent world state service.

The exact implementation is intentionally left open until after reviewing the existing architecture.

Conceptually the system stores facts such as:

```
district.power = offline

district.water = online

district.transit = partial

district.population = 2

district.commerce = 1

district.security = low
```

These values become shared inputs for every gameplay system.

---

# Shunt 9 Prototype

Use Shunt 9 as the first district to support evolution.

Current gameplay already includes repair events.

Leverage those instead of creating artificial demo content.

---

## Phase 0

Current district state.

Characteristics:

* mostly dark
* abandoned infrastructure
* sparse NPCs
* primitive crafting
* limited Ghostwork targets
* survival-focused rumors

---

## Phase 1 — Infrastructure

Existing repair events begin contributing toward district restoration.

Candidate systems:

* Power Relay
* Water Pump
* Ventilation
* Scrap Lift
* Transit Junction

Each successful repair updates world state.

Example:

```
district.power = online
```

---

# Immediate Reactions

Infrastructure should affect multiple systems simultaneously.

Examples:

## Locations

Descriptions evolve.

Before:

* dark hallways
* flickering emergency lights

After:

* powered lighting
* active machinery
* illuminated signs

No duplicate locations should be required if existing rendering can support conditional descriptions.

---

## NPC Availability

Power returning allows new NPCs to appear.

Examples:

* electronics vendor
* mechanic
* repair crews
* civilians

NPC spawning should become conditional on world state where appropriate.

---

## Ghostwork

Power enables:

* new terminals
* maintenance nodes
* surveillance systems
* control panels

Ghostwork content expands naturally without explicit unlock events.

---

## Crafting

Restored infrastructure enables:

* powered workbenches
* fabrication equipment
* advanced recipes

Again, availability should derive from world state rather than direct event scripting.

---

## Rumors

Rumors should evolve with the district.

Examples:

Early:

> Nobody lives down there anymore.

Later:

> Someone finally got the lights running.

Later:

> Traders have started coming back.

Rumors become another reflection of persistent world state.

---

# Phase 2 — Community Response

Infrastructure improvements should cause people to react.

Examples:

* markets become busier
* NPC dialogue changes
* more scavengers appear
* repair crews begin working
* civilians reclaim spaces

The district should visibly feel healthier.

---

# Phase 3 — Opportunity

Infrastructure creates gameplay opportunities.

Power may enable:

* locked maintenance doors
* cameras
* Ghostwork targets
* crafting benches

Water may enable:

* hydroponics
* food vendors
* brewing stations

Transit may enable:

* new exits
* traveling merchants
* courier jobs

The goal is cascading gameplay rather than isolated unlocks.

---

# Phase 4 — External Attention

As Shunt 9 becomes more valuable, outside factions begin responding.

Potential examples:

* corporate survey drones
* gang interest
* smugglers
* authority patrols

These should appear because the district state changed—not because a quest explicitly spawned them.

---

# District Projects

Investigate grouping related repairs into larger restoration initiatives.

Example:

```
Restore Bazaar Grid

Repair East Relay

Replace Junction Fuse

Fabricate Voltage Regulator

Reconnect Control Console
```

Completion of a project updates district-wide world state.

Projects provide long-term goals while allowing multiple gameplay systems to contribute.

---

# Design Principles

The implementation should favor declarative data.

Rather than:

```
Repair Relay

↓

Spawn Merchant
```

Prefer:

```
Merchant Requirements

Power = Online

Commerce >= 1

Population >= 2
```

The merchant appears because conditions are met.

---

# Hidden World State

Players should rarely see numerical values.

Avoid UI like:

```
Power 3/5
Population 4/8
```

Instead communicate progress through:

* descriptions
* NPC dialogue
* rumors
* available interactions
* environmental storytelling
* Ghostwork scans

Players observe the district changing organically.

---

# Integration Expectations

Review whether existing systems can consume world state:

* Locations
* Events
* NPCs
* Exits
* Ghostwork
* Rumors
* Crafting
* Quest progression

If they cannot, propose lightweight extension points rather than rewrites.

---

# Deliverables

After reviewing the codebase, provide:

## 1. Architecture Review

Explain:

* current strengths
* existing extension points
* architectural constraints
* reusable systems

---

## 2. Proposed World State Architecture

Describe:

* storage model
* persistence strategy
* APIs
* data flow
* ownership

Explain why this approach best fits the existing project.

---

## 3. Integration Plan

Describe how District Evolution integrates into:

* repair events
* locations
* NPCs
* Ghostwork
* Street Alchemy
* rumors
* exits
* quests

Highlight where existing systems can be reused.

---

## 4. Incremental Implementation Roadmap

Break implementation into small, reviewable milestones.

Suggested progression:

1. Introduce World State infrastructure
2. Connect repair events
3. Enable conditional location rendering
4. Enable NPC conditional availability
5. Integrate Ghostwork
6. Integrate rumors
7. Introduce district projects
8. Add external faction responses

Each milestone should leave the game in a playable state.

---

## 5. Risks & Recommendations

Identify:

* architectural risks
* performance considerations
* persistence concerns
* content authoring complexity
* testing strategy

Recommend any abstractions that will make future districts significantly easier to build.

---

# Success Criteria

A player who spends several hours in Shunt 9 should be able to return to earlier locations and immediately notice that the district has changed.

The evolution should emerge naturally from persistent world state, with existing systems reacting declaratively rather than through tightly coupled scripted event chains. The implementation should establish a reusable foundation that future districts can adopt with minimal custom code.
