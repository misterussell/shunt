# SHUNT — Location Graph & Movement System Specification

## Purpose

This document extends the existing SHUNT architecture and introduces the first implementation of physical space within the game world.

The goal is to establish:

* A player location model
* A graph-based navigation system
* Movement actions and events
* Location-driven gameplay expansion
* A foundation for the future LiveView map interface

This system should integrate cleanly with the existing architecture defined in `SHUNT_Elixir_Phoenix_Architecture.md`.

---

# Architectural Principles

This feature must respect the existing architectural decisions:

1. LiveView remains presentation-only.
2. CharacterServer owns active player state.
3. Event Engine resolves gameplay actions.
4. Effect Engine applies state mutations.
5. World State owns world topology.
6. Static location content lives in the Content Registry.

The location graph is not a UI feature.

The location graph is a gameplay system that will later be visualized in LiveView.

---

# High-Level Ownership

## Content Registry

Owns:

```elixir
Location
Exit
```

Responsibilities:

* Load location definitions
* Load location connections
* Serve read-only world topology

The Content Registry is the source of truth for the map.

---

## World State Service

Owns:

* Access to loaded locations
* Graph traversal queries
* Future dynamic location modifiers

Examples:

```elixir
WorldState.get_location(id)

WorldState.get_exits(location_id)

WorldState.connected?(from, to)
```

World State does not own player positions.

---

## Character Aggregate

Add:

```elixir
%Character{
  ...
  location_id: "shunt9_bazaar",
  discovered_locations: MapSet.new()
}
```

Responsibilities:

* Current player position
* Known/discovered locations

Location is persistent character state.

---

## Event Engine

Introduce:

```elixir
MoveAction
```

Flow:

Move Action
↓
Validate Destination
↓
Generate Events
↓
Generate Effects

The Event Engine never mutates state directly.

---

## Effect Engine

Introduce:

```elixir
LocationChanged
LocationDiscovered
NarrativeAdded
```

Effects update character state.

Example:

```elixir
{:location_changed, "shunt9_scrapyard"}

{:discover_location, "shunt9_scrapyard"}
```

---

# Content Definitions

## Location

Locations are static content.

Example:

```elixir
%Location{
  id: "shunt9_bazaar",
  name: "Shunt 9 Bazaar",

  short_description:
    "The beating heart of Shunt 9.",

  description:
    "Hundreds of stalls crowd the abandoned transit platform.",

  tags: [
    :market,
    :underbelly
  ],

  graph_position: {500, 300}
}
```

Notes:

graph_position exists specifically for future LiveView map rendering.

Store coordinates as world-space positions.

Do not calculate UI layout dynamically.

---

## Exit

Connections between locations.

Example:

```elixir
%Exit{
  from: "shunt9_bazaar",
  to: "shunt9_scrapyard",

  requirements: []
}
```

Future examples:

```elixir
requirements: [
  {:rep, :syndicate, :trusted}
]
```

or

```elixir
requirements: [
  {:flag, :maintenance_pass}
]
```

---

# Initial Shunt 9 Graph

Recommended starter map:

```text
                 Power Relay
                      |
                      |
Scrap Yard ---- Bazaar ---- Food Stalls
                      |
                      |
               Burned Platform
                      |
                      |
             Maintenance Tunnel
                      |
                      |
                 Player Squat
```

Keep the initial graph small.

5–8 locations is sufficient.

---

# Movement Flow

## Step 1

Player clicks connected location.

LiveView emits:

```elixir
{:move_to, location_id}
```

---

## Step 2

CharacterServer receives request.

Delegates to Event Engine.

---

## Step 3

Event Engine validates:

```elixir
WorldState.connected?(
  current_location,
  destination
)
```

and

RequirementsEngine.check(...)

````

---

## Step 4

Event Engine emits effects.

Example:

```elixir
[
  {:location_changed, destination},
  {:discover_location, destination},
  {:narrative, "..."}
]
````

---

## Step 5

Effect Engine applies effects.

Character state updated.

PubSub broadcast emitted.

LiveView rerenders.

---

# Narrative Integration

Movement should automatically create narrative output.

Example:

```text
You leave the Bazaar.

The smell of hot circuitry fades as you descend into the Scrap Yard.

Mountains of twisted metal loom overhead.
```

This establishes the future narrative feed.

Movement becomes the first producer of narrative entries.

---

# Action Resolution

Do NOT attach actions directly to locations.

Avoid:

```elixir
%Location{
  actions: [...]
}
```

Instead create:

```elixir
ActionResolver.available_actions(
  character,
  world_state
)
```

The resolver composes actions from:

* Current location
* Active NPCs
* Character skills
* Faction standing
* Heat state
* Active opportunities
* Story flags

This keeps the system extensible.

---

# LiveView Rendering Strategy

Initial implementation:

SVG-based graph.

Example:

```text
○ Scrap Yard

│

● Bazaar

│

○ Burned Platform
```

Legend:

```text
● Current Location
○ Available Location
🔒 Locked Location
```

The UI renders graph_position values from location content.

LiveView should not calculate movement rules.

It should only visualize state.

---

# Future Extensions

This architecture should support:

* Ambient events
* NPC spawning
* Heat encounters
* Faction checkpoints
* Territory control
* Dynamic world modifiers
* Secret locations
* Narrative discoveries

without modifying the core movement model.

Everything should build on:

Location
Exit
MoveAction
LocationChanged

as the foundational primitives.

---

# Sprint Deliverables

Phase 1

* Location schema
* Exit schema
* Content loading
* Character location state
* Movement action
* Movement effects

Phase 2

* Graph SVG renderer
* Connected-node navigation
* PubSub updates

Phase 3

* Narrative entries on movement
* Discovery tracking

Phase 4

* Ambient location events
* Dynamic action resolution

Success Criteria:

A player can visually navigate between locations in Shunt 9 using a graph-based map, while all movement flows through the Event Engine and Effect Engine architecture already established in the project.
