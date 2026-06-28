# Street Alchemy - Repair Economy (Implementation Investigation)

## Overview

Street Alchemy currently supports the following gameplay loop:

* Scavenge raw materials from the world.
* Learn crafting recipes.
* Assemble items from static recipes.
* Progress the skill through crafted tools (currently the Scrap-Forged Soldering Iron unlocks Street Alchemy Level 1).

The next evolution of the skill should shift its identity away from simply crafting items and toward **repairing the Underbelly itself**.

The design goal is to make Street Alchemy the profession that restores failing infrastructure, keeps settlements functioning, and solves practical problems for NPCs.

This document is **not** an implementation specification. Before proposing an architecture, review the existing codebase and determine how much of this feature can be built using the current event, NPC, quest, and content systems.

---

# Primary Design Goals

Street Alchemy should answer the question:

> "What can I fix?"

instead of only:

> "What can I build?"

Repairs should feel like solving real-world problems rather than completing generic crafting quests.

Whenever possible, leverage existing content systems instead of introducing entirely new gameplay frameworks.

---

# Existing Systems To Review

Before proposing any implementation, review the current architecture for:

* Event system
* NPC interactions
* Quest progression
* Repeatable events
* Content registry
* World objects
* Location interactions
* Crafting system
* Inventory and item requirements
* Skill progression
* Character state persistence

The preferred solution should extend existing systems instead of replacing them.

---

# Core Concept

Introduce persistent repairable infrastructure throughout the world.

Examples include:

* Generators
* Freight elevators
* Water purifiers
* Lighting systems
* Security gates
* Ventilation units
* Communications equipment
* Market machinery

These should exist as persistent world objects rather than disposable quest objectives.

---

# Desired Gameplay Loop

1. Player discovers broken infrastructure.

2. NPCs naturally reference the problem.

3. Player chooses to investigate.

4. Player inspects the object.

5. Street Alchemy skill influences the quality of information revealed.

6. Player gathers or crafts required materials.

7. Player performs a repair using available tools and components.

8. The repaired object changes the state of the location.

---

# Inspection System

Repairs should begin with diagnosis rather than immediately revealing a shopping list.

Example progression:

Street Alchemy 0

* "It's broken."

Street Alchemy 1

* "Looks like an electrical failure."

Street Alchemy 2

* "The starter relay has burned out."

Street Alchemy 3

* "Coolant leaked onto the relay, causing the failure."

Higher skill should improve understanding rather than simply unlocking recipes.

Investigate whether this can reuse existing event text or conditional content.

---

# Repair Solutions

Repairs should support multiple valid solutions.

Example:

Generator requires a functioning relay.

Possible repairs:

* Standard Relay
* Military Relay
* Improvised Relay

Each option should produce different outcomes.

Possible effects include:

* Reliability
* Temporary repairs
* Permanent repairs
* Future breakdown chances
* Additional world benefits

The implementation should support multiple acceptable solutions without requiring custom code per repair.

---

# Persistent Tools

Crafted tools should become reusable equipment.

Examples:

* Scrap-Forged Soldering Iron
* Portable Welder
* Diagnostic Probe
* Precision Toolkit

These should generally be requirements rather than consumable crafting ingredients.

Review whether existing item requirement systems already support this distinction.

---

# NPC Integration

Repairs should originate naturally through NPC dialogue.

Rather than using a generic job board, NPCs should reference problems occurring in the world.

Example:

"The generator's been acting up all week."

The player may choose to investigate.

Determine how existing NPC dialogue and event progression systems can support this organically.

---

# World State Changes

Repairs should produce visible changes.

Examples:

Repairing lights:

* Dark descriptions become illuminated.
* New NPCs appear.
* Additional interactions unlock.

Repairing a freight lift:

* New locations become accessible.

Repairing a generator:

* Vendors return.
* Machinery activates.
* Future events become available.

Review existing world state systems to determine whether location descriptions, exits, NPCs, or events already support conditional availability.

---

# Temporary vs Permanent Repairs

Not every repair needs to be permanent.

Examples:

Temporary repair

* Faster
* Uses cheaper materials
* May fail later

Permanent repair

* Better materials
* More work
* Lasting world improvement

Investigate whether the existing architecture can naturally support state transitions such as:

Broken

↓

Patched

↓

Repaired

---

# Reputation Opportunities

Instead of only rewarding Street Alchemy experience, successful repairs could influence how NPCs perceive the player.

Potential rewards:

* Discounts
* Unique repair contracts
* Access to Patchworkers
* Rare crafting knowledge
* Additional dialogue
* New quest chains

Review whether this fits naturally into existing NPC progression or reputation systems.

---

# Scaling

The repair economy should naturally grow with player progression.

Examples:

Early

* Lamps
* Fans
* Locks

Mid Game

* Generators
* Elevators
* Workshops

Late Game

* Transit systems
* Factories
* Communications arrays
* District infrastructure

---

# Architectural Goals

The preferred implementation should:

* Be highly data-driven.
* Minimize feature-specific code.
* Reuse existing content systems wherever possible.
* Allow content creators to author new repairs without writing custom logic.
* Treat repairable infrastructure as first-class world content.

---

# Deliverable

After reviewing the codebase, produce an implementation proposal that includes:

1. An assessment of how the existing architecture supports this feature.

2. Any new data structures that would be required.

3. Whether repairs should be modeled as:

   * Events
   * World objects
   * Quests
   * A new content type
   * Or an extension of an existing system.

4. Required engine changes.

5. Proposed content authoring workflow.

6. An incremental implementation plan with milestones.

The proposal should prioritize extending existing architecture over introducing parallel systems.
