# Shunt NPC Architecture: First-Class World Objects

> **Reviewed against codebase 2026-06-24; design decisions resolved 2026-06-24.** Review
> callouts (`> 🔎 REVIEW:`) flag where the original proposal touched something that already
> exists or works differently than assumed; `> ✅ DECIDED:` callouts record the resolution.
> See **Decisions Log** at the end for the full list. Pilot scope: build this against
> `maintenance_tunnel_junkie` only; the five existing Fixer NPCs are explicitly deferred
> (see **Pilot Scope** section).

## Overview

This document proposes a refactor of Shunt's event system so that NPCs become persistent world entities rather than merely entry points into event chains.

The primary goal is to support:

* Repeatable NPC interactions
* Relationship progression
* Persistent familiarity between player and NPC
* Narrative arcs that unfold over multiple interactions
* Future systems such as reputation, favors, merchants, companions, and faction relationships

---

# Problem Statement

Current structure:

```text
Location
 └─ Action
      └─ Event
```

> 🔎 REVIEW: There is no "Action" layer in the current code. `Location` is a plain map
> (content `.exs` file, no Ecto schema) with an `events: [event_id, ...]` field, and
> `movement_live.ex` renders that list directly as "Points of Interest" buttons — one
> button per event, no intermediate Action struct. The real current structure is:
>
> ```text
> Location
>  └─ Event
> ```
>
> So the proposed change is `Location → Event` becoming `Location → NPC → Event`, not the
> removal of an Action layer that never existed. Worth fixing this section so the doc's
> framing matches reality.

Example:

```text
Maintenance Tunnel
 └─ Talk to Tunnel Junkie
      └─ Tunnel Junkie Event
```

This works for one-off encounters but becomes difficult when:

* The player should remember previous interactions
* New dialogue options should unlock
* Old introductory dialogue should disappear
* NPCs need persistent progression

The event itself is currently carrying state that should belong to the NPC relationship.

> 🔎 REVIEW: Confirmed. The Tunnel Junkie exists *only* as
> `priv/content/events/maintenance_tunnel_junkie/maintenance_tunnel_junkie.exs`
> (`%Shunt.Events.Event{id: "shunt9_maintenance_tunnel_junkie", ...}`), referenced from
> `priv/content/locations/shunt9/shunt9_maintenance_tunnel.exs` via `events: [...]`. There
> is no NPC content record for it today — good pilot candidate, matches the user's choice.

---

# Proposed Architecture

Refactor NPCs into first-class world entities.

New structure:

```text
Location
 ├─ NPC: Tunnel Junkie
 ├─ NPC: Scrap Broker
 └─ NPC: Transit Drifter

NPC
 ├─ Relationship State
 ├─ Story Progression
 ├─ Repeatable Events
 └─ Services
```

Locations contain NPCs.

NPCs determine which events are available.

Player relationships determine which content is shown.

> 🔎 REVIEW: There are already two different things in the codebase that could be called
> "NPC," and this doc's new concept needs to say explicitly how it relates to both — see
> **Codebase Findings #1** below. The short version: the five NPCs in `Shunt.Npcs`
> (`mother_graft`, `rook`, `nine_iron`, `splice`, `tally`) are global Fixers shown on a Hub
> screen, not bound to any location, with hand-written trade functions per NPC key. They
> are unrelated to the location-bound "encounter NPC" concept this doc is building. Per
> the user's direction we are deferring them — see **Pilot Scope**.

---

# NPC Definition

```elixir
defmodule Shunt.World.NPC do
  @enforce_keys [:id, :name]

  defstruct [
    :id,
    :name,
    :description,

    # Current home location
    :location_id,

    # Ordered narrative progression
    story_arcs: [],

    # Content available after progression ends
    repeatable_events: [],

    # Optional future systems
    services: []
  ]
end
```

> 🔎 REVIEW: Every other content type in this codebase (`npcs`, `fencing_items`, `raws`,
> `recipes`, `heat_events`, `locations`) is a **plain map with a `:key` field**, not a
> struct, and `Content.Store.load_source/2` indexes those tables by `item.key`. Only
> `:events` is the odd one out, indexed by `item.id` because `Shunt.Events.Event` is a
> real struct.
>
> ✅ DECIDED: Keep `NPC` as a real struct, as drafted, with `:id` as the key field (same
> convention as `Shunt.Events.Event`). This means `priv/content/npcs/*.exs` files for
> story-driven NPCs will be `%Shunt.World.NPC{...}` literals, not plain maps — a different
> shape from the existing five Fixer NPC files (`%{key: "mother_graft", ...}`), which is
> fine since the Fixers are out of scope for this round (see **Pilot Scope**).
>
> Implementation note: `Content.Store.load_source/2`'s generic clause keys ETS entries by
> `item.key`, which a `%NPC{}` struct doesn't have. This needs a dedicated
> `load_source(:world_npcs, dir)` clause (mirroring the existing `:events` and
> `:skill_trees` special cases) that keys by `item.id` instead, added *before* the generic
> fallback clause since Elixir matches function clauses in source order.
>
> ✅ DECIDED (table split, found during implementation): this struct-based NPC content does
> **not** go into the existing `:npcs` table/`priv/content/npcs` directory. `Shunt.Npcs.list/0`
> feeds the Hub screen, and `hub_live.ex` assumes every `:npcs` entry has Fixer-shaped fields
> (`faction`, `trade_actions`) — mixing a `%Shunt.World.NPC{}` into that table crashes the Hub
> on render. Instead: a new source entry `{:world_npcs, "priv/content/world_npcs"}` and ETS
> table, with a new `Shunt.World.Npcs` module (mirroring `Shunt.Npcs`'s `get!/1`, plus
> `current_event/2`) — completely separate from `Shunt.Npcs`/`:npcs`/the Hub. Updated
> throughout this doc.

Example:

```elixir
%NPC{
  id: "shunt9_maintenance_tunnel_junkie",
  name: "Tunnel Junkie",

  location_id: "shunt9_maintenance_tunnel",

  story_arcs: [
    "shunt9_maintenance_tunnel_junkie_intro",
    "shunt9_maintenance_tunnel_junkie_parts_request",
    "shunt9_maintenance_tunnel_junkie_stash_problem"
  ],

  repeatable_events: [
    "shunt9_maintenance_tunnel_junkie_smalltalk",
    "shunt9_maintenance_tunnel_junkie_rumors"
  ]
}
```

> ✅ DECIDED: Zone-prefix all ids, matching the existing `shunt9_maintenance_tunnel` /
> `shunt9_maintenance_tunnel_junkie` convention already used by locations and events in
> this zone. Updated above.

---

# Location Integration

Locations expose NPCs directly.

```elixir
%{
  key: "shunt9_maintenance_tunnel",

  npcs: [
    "shunt9_maintenance_tunnel_junkie"
  ]
}
```

> ✅ DECIDED: `Location` itself is unaffected by the NPC struct decision — locations
> remain plain maps loaded from `priv/content/locations/**/*.exs`, keyed by `:key` (not
> `:id`), e.g. `%{key: "shunt9_maintenance_tunnel", name: ..., events: [...], exits:
> [...]}`. Adding `npcs: [...]` is just adding a key to that existing map in the `.exs`
> content file — no schema/struct/migration involved. Example above corrected to a plain
> map with `:key` and zone-prefixed ids.

UI rendering becomes:

```text
People Here

• Tunnel Junkie
```

instead of:

```text
Actions

• Talk to Tunnel Junkie
```

> 🔎 REVIEW: The actual current heading in `movement_live.ex` is "Points of Interest"
> (`movement_live.ex:100`), not "Actions" — minor, but worth matching if this section is
> meant to describe a real UI diff.

The interaction target becomes the NPC rather than an event.

---

# Player Relationship State

Each player stores progression separately.

> ✅ DECIDED: No new table, no new `Shunt.Characters` context, and no separate
> `reputation` stat. Story progression is a `:map` field on the existing `Player` schema,
> exactly mirroring the existing `npc_loyalty` field — "how much the NPC likes you" stays
> on `npc_loyalty` (reused as-is, banded `:hostile`/`:neutral`/`:favored` by
> `Shunt.Npcs.Loyalty`); this new field only tracks *which story stage* the player has
> reached, as a plain integer per NPC key. One migration line, no new schema/context, and
> it slots into `Effects.apply`'s existing `do_apply` pattern (see **Event-Driven
> Progression** below).

```elixir
# lib/shunt/players/player.ex
field :npc_progression, :map, default: %{}   # npc_key => integer stage
```

```elixir
# new migration
alter table(:players) do
  add :npc_progression, :map, default: %{}, null: false
end
```

Example:

```elixir
%{"shunt9_maintenance_tunnel_junkie" => 1}
```

Suggested progression meanings:

```text
0 = Never Met
1 = Met
2 = Acquaintance
3 = Trusted
```

The exact interpretation can remain content-specific.

---

# Event Resolution

When a player interacts with an NPC:

```elixir
Shunt.World.Npcs.current_event(player, npc_key)
```

> ✅ DECIDED: Takes a key and fetches internally, consistent with every comparable
> lookup in the codebase (`Events.current_step(player, event_id)`, `Npcs.get!(npc_key)`,
> `Loyalty.value(player, npc_key)`). Lives on the new `Shunt.World.Npcs` module, not
> `Shunt.Npcs` — see table-split decision under **NPC Definition**.

Resolver:

```elixir
def current_event(player, npc_key) do
  npc = get!(npc_key)
  progression = Map.get(player.npc_progression, npc_key, 0)
  Enum.at(npc.story_arcs, progression)
end
```

No separate relationship lookup needed — same pattern `Loyalty.value/2` already uses
against `player.npc_loyalty`.

Examples:

```text
progression = 0
→ junkie_intro
```

```text
progression = 1
→ junkie_parts_request
```

```text
progression = 2
→ junkie_stash_problem
```

---

# Progression Advancement

Completing an event advances relationship progression.

> ✅ DECIDED: No hand-rolled update function. Progression advances via a new
> `{:npc_progression, npc_key, delta}` effect tuple, handled by `Shunt.Effects` exactly
> like the existing `{:npc_loyalty, npc_key, delta}` clause — `Effects.apply/2` already has
> the machinery for "take a player, take effect tuples, return changes," and
> `Players.Server.dispatch_effects/3` already persists the result via
> `Ecto.Changeset.change(changes) |> Repo.update()`. See **Event-Driven Progression**
> below for the full effect.

The next interaction automatically exposes the next narrative arc.

---

# Repeatable Content

After all story arcs are completed:

```elixir
story_arcs = [
  "intro",
  "parts_request",
  "stash_problem"
]
```

Player reaches:

```elixir
progression = 3
```

Resolver falls back to repeatable content:

```elixir
def current_event(player, npc_key) do
  npc = get!(npc_key)
  progression = Map.get(player.npc_progression, npc_key, 0)

  if progression < length(npc.story_arcs) do
    Enum.at(npc.story_arcs, progression)
  else
    Enum.random(npc.repeatable_events)
  end
end
```

This creates the feeling that the NPC remains present in the world even after their main storyline is complete.

---

# Event-Driven Progression

Avoid hard-coding progression advancement into game logic.

Instead, allow events to declare completion effects.

Example:

```elixir
%Shunt.Events.Event{
  id: "shunt9_maintenance_tunnel_junkie_intro",

  on_complete: [
    {:npc_progression, "shunt9_maintenance_tunnel_junkie", 1}
  ]
}
```

Event completion executes:

```elixir
[
  {:npc_progression, "shunt9_maintenance_tunnel_junkie", 1}
]
```

Future examples:

```elixir
on_complete: [
  {:npc_progression, "shunt9_maintenance_tunnel_junkie", 1},

  {:inventory, "scrap_key", 1}
]
```

This keeps narrative content data-driven.

> ✅ DECIDED: `{:npc_progression, npc_key, delta}` — a signed delta, consistent with the
> existing `{:npc_loyalty, npc_key, delta}` effect shape, rather than a fixed
> `{:advance_relationship, id}` "advance by one" verb. Lets future content skip ahead or
> roll back a stage without a second effect type. "Grant item" content (the old
> `{:grant_item, key}` idea) just reuses the existing `{:inventory, key, delta}` clause —
> no new effect needed there.
>
> This slots into existing plumbing as a small, contained change:
>
> * `Shunt.Events.Event` (`lib/shunt/events/event.ex`) currently has only
>   `[:id, :title, :description, :steps]`. Add `on_complete: []` as a non-enforced field.
> * `Shunt.Events.choose/3`'s private `complete_event/2` (`lib/shunt/events.ex:54`)
>   currently only returns `{:set, :completed_events, ...}` + `{:set, :event_state, ...}`
>   effects. It already runs through `Players.dispatch` → `Effects.apply` (confirmed:
>   `movement_live.ex:40` calls `Players.dispatch(player_id, &Events.choose(&1, event_id,
>   choice))`), so prepending `event.on_complete` to the returned effects list needs no new
>   dispatch path.
> * `{:npc_progression, npc_key, delta}` needs one new `do_apply` clause in
>   `Shunt.Effects` (`lib/shunt/effects.ex`), mirroring the existing `{:npc_loyalty,
>   npc_key, delta}` clause but writing to `player.npc_progression` instead.
> * Dropped `{:unlock_event, event_id}` from the pilot — there's no concept of "locked"
>   events today (an event is available simply by being listed in a location's `events`
>   list, or, in the new model, an NPC's `story_arcs`/`repeatable_events`), and story-arc
>   ordering already makes "next event" availability implicit. Revisit only if a future NPC
>   needs non-linear unlocks.
> * `priv/content/events/player_squat/*.exs` already has three event files with an unused
>   `rewards: [{:knowledge, :ghostwork}]` key on individual steps that nothing in `lib/`
>   reads. `on_complete` (event-level) supersedes that never-implemented `rewards`
>   (step-level) mechanism going forward — don't build both.

---

# Suggested Content Organization

```text
content/
├─ locations/
│  └─ shunt9/
│     └─ shunt9_maintenance_tunnel.exs
│
├─ world_npcs/
│  └─ shunt9_maintenance_tunnel_junkie.exs
│
└─ events/
   └─ maintenance_tunnel_junkie/
      ├─ intro.exs
      ├─ parts_request.exs
      ├─ stash_problem.exs
      └─ rumors.exs
```

Catalogs:

```text
World
 ├─ Locations
 ├─ NPCs
 └─ Events
```

> ✅ DECIDED: Flat-by-topic event directory, matching the existing convention (e.g.
> `priv/content/events/player_squat/player_squat_deck.exs`), not a new `events/npc/`
> umbrella. `Content.Store.load_source/2` already walks every source directory
> recursively (`Path.wildcard(Path.join(..., "**/*.exs"))`), so nested directories work
> today with zero loader changes — only the new `load_source(:world_npcs, dir)` clause
> noted under **NPC Definition** is required.

---

# Runtime Flow

```text
Player enters location
        ↓
Location exposes NPCs
        ↓
Player selects NPC
        ↓
Relationship determines progression
        ↓
NPC resolves current story arc
        ↓
Event loads
        ↓
Player completes event
        ↓
Relationship updates
        ↓
Future interactions expose new content
```

---

# Future Expansion Opportunities

This architecture naturally supports:

* Merchant NPCs
* Faction contacts
* Reputation systems
* Favor tracking
* Companion recruitment
* Familiar relationships
* Betrayal and rivalry systems
* Daily interactions
* Randomized dialogue pools
* Location-specific NPC schedules

Because all progression is attached to the NPC relationship rather than individual events, these systems can be layered in without changing the event engine's fundamental structure.

---

# Key Design Decision

The core principle of this architecture is:

> Events are temporary content.
> NPCs are persistent world entities.

The memory of previous interactions belongs to the player-NPC relationship, not to the event itself.

This should be treated as a foundational design rule for future content systems.

---

# Pilot Scope

Per direction: build this architecture against **`maintenance_tunnel_junkie` only** for
the first pass. Explicitly out of scope for this round:

* `Shunt.Npcs` and its five Fixer NPCs (`mother_graft`, `rook`, `nine_iron`, `splice`,
  `tally`) — these stay exactly as they are (global, Hub-rendered, hand-written trade
  functions, `player.npc_loyalty`-based). No migration of them onto the new
  story-arc/relationship model in this round.
* The Hub screen (`hub_live.ex`) and its loyalty-band trade-action UI.
* `{:unlock_event, ...}` (see callout above — likely unneeded given arc-index ordering).
* Any second NPC beyond the Tunnel Junkie.

The new machinery needed for the pilot, in dependency order:

1. New `{:world_npcs, "priv/content/world_npcs"}` source entry +
   `Content.Store.load_source(:world_npcs, dir)` clause, keying by `item.id` (new — needed
   because NPC is a struct, unlike the other plain-map content types; kept separate from
   `:npcs` so the Hub screen's Fixer-shaped assumptions aren't disturbed).
2. `priv/content/world_npcs/shunt9_maintenance_tunnel_junkie.exs` — new `%Shunt.World.NPC{}`
   content file, plus a new `Shunt.World.Npcs` module (`get!/1`, later `current_event/2`).
3. `npcs: [...]` field added to
   `priv/content/locations/shunt9/shunt9_maintenance_tunnel.exs`.
4. `npc_progression: :map` field + migration on `Player`.
5. `on_complete` field on `Shunt.Events.Event` + wiring in `Events.choose/3`'s
   `complete_event/2`.
6. New `Effects` clause for `{:npc_progression, npc_key, delta}`.
7. Split the existing single-file `maintenance_tunnel_junkie.exs` event into the
   intro/parts_request/stash_problem story arc (zone-prefixed ids), with `on_complete`
   advancing progression between them.
8. UI: location rendering switches from listing the event directly to listing the NPC,
   which resolves to "whatever event is current" before opening the event modal.

---

# Decisions Log

Resolved 2026-06-24:

1. **NPC representation** — real struct (`Shunt.World.NPC`, `:id` field), as originally
   drafted. Requires a dedicated `Content.Store.load_source(:npcs, dir)` clause keyed by
   `item.id` (the generic clause assumes `item.key`).
2. **Loyalty vs. reputation/progression** — reuse the existing `player.npc_loyalty` (0–100,
   banded) as the single relationship-strength axis. No separate `reputation` field. Story
   progression is tracked independently as a plain integer stage counter, not a second
   strength stat.
3. **Storage** — `:map` field on `Player` (`npc_progression`), mirroring `npc_loyalty`. No
   new `npc_relationships` table, no new `Shunt.Characters` context.
4. **Effect shape** — `{:npc_progression, npc_key, delta}`, a signed delta consistent with
   the existing `{:npc_loyalty, npc_key, delta}` shape, not a fixed `{:advance_relationship,
   id}` verb.
5. **Naming convention** — zone-prefix all new ids (`shunt9_maintenance_tunnel_junkie`,
   `shunt9_maintenance_tunnel_junkie_intro`, etc.), matching existing location/event ids in
   this zone.
6. **Table split** (found during implementation) — story-driven `Shunt.World.NPC` content
   lives in its own `:world_npcs` ETS table / `priv/content/world_npcs` directory /
   `Shunt.World.Npcs` module, not the existing `:npcs` table. `Shunt.Npcs.list/0` feeds the
   Hub screen, and `hub_live.ex` assumes every `:npcs` entry has Fixer-shaped fields
   (`faction`, `trade_actions`); mixing the new struct into that table would crash the Hub.

Still open / deferred, not blocking the pilot:

* Whether `{:unlock_event, ...}` is ever needed — dropped from the pilot, arc-index
  ordering covers it for now (see **Event-Driven Progression**).
* Whether/when the five Fixer NPCs migrate onto this model — explicitly out of scope (see
  **Pilot Scope**).
