# Shunt Event System v1

## Location-Based Content and Narrative Events

### Goal

Introduce a reusable Event Engine that allows locations to contain interactive content such as tutorials, lore discoveries, investigations, scavenging opportunities, and future quest-like experiences.

The first implementation target is the starting location: **Player Squat**.

These initial events are intended to teach core game systems while establishing the setting and tone of Shunt.

---

# Design Principles

## Events Are Content

Events are immutable content definitions loaded into a registry at boot.

Events should never store player state.

Player progression is stored separately on the character.

---

## Locations Reference Events

Locations should only contain event IDs.

Locations do not embed event definitions directly.

Example:

```elixir
%Location{
  key: "player_squat",
  name: "Player Squat",

  events: [
    "player_squat_deck",
    "player_squat_neural_port",
    "player_squat_knowledge_chits"
  ],

  exits: [...]
}
```

---

## Events Are Not Quests

The Event Engine should become the foundational content system.

Future systems should be implemented as specialized forms of events:

* Tutorials
* Lore interactions
* Investigations
* Faction interactions
* Scavenging opportunities
* Narrative scenes
* Quests

Avoid building a separate quest architecture initially.

---

# Initial Player Squat Events

## Broken Deck

Purpose:

Introduce:

* The Latticework
* Ghostwork skill
* Street Alchemy skill
* Equipment repair concepts

Narrative Hook:

The player owns a damaged Deck that no longer connects properly to the Latticework.

Potential Rewards:

```elixir
{:xp, :ghostwork, 50}
```

or

```elixir
{:knowledge, :repairing_decks}
```

---

## Burnt-Out Neural Port

Purpose:

Introduce:

* Augmentations
* Chrome & Meat skill
* Body modification culture

Narrative Hook:

A discarded neural port sits among the player's belongings, damaged beyond use.

Potential Rewards:

```elixir
{:xp, :chrome_and_meat, 50}
```

or

```elixir
{:knowledge, :augmentations}
```

---

## Stolen Kaspav Authority Knowledge-Chits

Purpose:

Introduce:

* Kaspav Authority
* Information economy
* Web skill

Narrative Hook:

The player possesses several stolen Authority knowledge-chits containing fragments of restricted information.

Potential Rewards:

```elixir
{:xp, :web, 50}
```

or

```elixir
{:knowledge, :authority_networks}
```

---

# Event Data Structure

Create a generic event definition.

```elixir
defmodule Shunt.Content.Event do
  @enforce_keys [:id, :title, :steps]

  defstruct [
    :id,
    :title,
    :description,
    :repeatable?,
    :requirements,
    :steps
  ]
end
```

---

# Event Registry

Events should be loaded into ETS during boot.

Example registry:

```elixir
defmodule Shunt.Content.EventRegistry do
  def get!(id) do
    case :ets.lookup(:content, {:event, id}) do
      [{_, event}] -> event
      [] -> raise "Missing event #{id}"
    end
  end
end
```

Boot loading:

```elixir
:ets.insert(
  :content,
  {{:event, event.id}, event}
)
```

---

# Content Organization

Recommended structure:

```text
priv/content/events/

├── player_squat/
│   ├── broken_deck.exs
│   ├── neural_port.exs
│   └── knowledge_chits.exs
```

Future content should be organized by location.

---

# Event Step Model

Events consist of steps connected by choices.

Example:

```elixir
%Event{
  id: "player_squat_deck",
  title: "Broken Deck",

  steps: [
    %{
      id: "inspect",
      text: """
      Your Deck lies cracked and silent.
      Once it linked you to the Latticework.
      """,

      choices: [
        %{label: "Examine circuitry", next: "circuitry"},
        %{label: "Leave it alone", complete: true}
      ]
    },

    %{
      id: "circuitry",
      text: """
      Most of the hardware can be salvaged,
      but the lattice coupler is ruined.
      """,

      rewards: [
        {:knowledge, :ghostwork}
      ],

      complete: true
    }
  ]
}
```

---

# Character Event Progression

Content remains immutable.

Character records progression.

Example:

```elixir
%Character{
  completed_events: MapSet.new(),

  event_state: %{
    "player_squat_deck" => %{
      current_step: "circuitry"
    }
  }
}
```

---

# Location Rendering

When viewing a location:

```text
PLAYER SQUAT

A narrow cube of salvaged sheet metal.

Points of Interest

• Broken Deck
• Burnt-Out Neural Port
• Knowledge Chits

Exits

• Maintenance Corridor
```

Events should appear separately from exits.

Recommended distinction:

```elixir
location.events
location.exits
```

Do not mix the two concepts.

---

# Event Interaction Flow

## Start Event

Player selects:

```text
Inspect Broken Deck
```

LiveView event:

```elixir
handle_event("start_event", %{"id" => event_id}, socket)
```

Load event:

```elixir
event =
  EventRegistry.get!(event_id)
```

Render first step.

---

## Make Choice

Player selects:

```text
Examine circuitry
```

LiveView event:

```elixir
handle_event(
  "event_choice",
  %{"event_id" => id, "choice" => choice},
  socket
)
```

Flow:

```text
Current Step
    ↓
Choice
    ↓
Next Step
    ↓
Apply Rewards
    ↓
Persist Progress
```

---

# Recommended Reward Types

Knowledge:

```elixir
{:knowledge, :ghostwork}
```

Experience:

```elixir
{:xp, :web, 50}
```

Items:

```elixir
{:item, "scrap_coupler"}
```

Flags:

```elixir
{:flag, :learned_about_latticework}
```

Future systems should process rewards through a centralized reward application module.

---

# Future Expansion

The Event Engine should support:

## Skill Checks

```elixir
requirements: [
  {:skill, :ghostwork, 10}
]
```

---

## World State Requirements

```elixir
requirements: [
  {:world_flag, :riot_active}
]
```

---

## Repeatable Content

```elixir
repeatable?: true
```

Potential future support:

```elixir
cooldown: :daily
```

---

## Dynamic Events

Examples:

* Gang activity
* Authority inspections
* Black market opportunities
* Familiar encounters
* Narrative consequences

All should be built using the same event architecture.

---

# MVP Scope

Implement only the following:

1. Event struct
2. Event registry
3. Event loading at boot
4. Location event references
5. Character event progression tracking
6. Event rendering in LiveView
7. Event choice handling
8. Event completion tracking
9. Three Player Squat tutorial events

Do not build:

* Quest system
* Dynamic world events
* Skill checks
* Repeatable content
* Cooldowns

The goal is to establish a stable Event Engine that future systems can build upon.
