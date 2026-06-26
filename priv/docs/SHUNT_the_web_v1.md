# Shunt Feature: The Web (Social & Criminal Networks) — v1

## Goal

The Web is a data-driven progression layer that sits on top of the existing NPC,
Event, and World systems. It introduces no separate quest engine, relationship
engine, or social-graph system.

Instead it:

* Reuses existing event content and event progression
* Adds new reward types (trust, favors, knowledge, contacts)
* Adds new requirement types that gate world content
* Tracks player relationships, favors, knowledge, and contacts on the player
* Unlocks new locations, exits, and events through social progression

The player fantasy:

> Build trust, collect favors, learn secrets, discover contacts, and leverage
> those relationships to reach opportunities other players never see.

---

# Design Philosophy

The Web is not content. NPCs, Events, and Locations remain the content
containers. The Web is a layer that modifies **what content becomes available**.

The central design split that keeps both feelings intact:

* **The arc spine is the existing linear NPC progression.** An NPC's `story_arcs`
  advance one at a time via the `npc_progression` index. This preserves the
  authored, one-step-at-a-time story feel — untouched by The Web.
* **"The world opening up" is requirement-gating.** The trust, favors, and
  knowledge an arc pays out are what reveal *new locations, exits, and points of
  interest* branching off the spine.

```text
NPC story arc (linear spine)
  │  pays out
  ▼
Trust / Favors / Knowledge / Contacts   (player ledger)
  │  satisfies
  ▼
Requirements on Locations / Exits / POI Events
  │  reveals
  ▼
More world to explore  →  more NPCs  →  more arcs
```

No graph engine is required. Every edge in the social network is expressed
entirely through content.

---

# Player State

The Web ledger lives directly on the `Shunt.Players.Player` schema (see the
`AddWebLedgerToPlayers` migration):

```elixir
field :reputation, :map, default: %{}            # %{"juno" => %{trust: 20, favors: 1}}
field :knowledge, {:array, :string}, default: []  # ["juno_secret_supplier"]
field :contacts, {:array, :string}, default: []   # ["rose_broker"]
```

Notes:

* `reputation` is keyed by a short relationship handle (e.g. `"juno"`), not the
  full world-NPC id. This is the player-facing relationship key used by Web
  rewards and requirements.
* `knowledge` and `contacts` are string arrays (deduped on write), mirroring the
  existing `discovered_locations` pattern. Ecto has no set type; arrays persist
  cleanly and the effects below keep them unique.
* This deliberately avoids dedicated structs (`%Relationship{}`, `%Rumor{}`,
  etc.). All progression is data-driven.

The existing `npc_loyalty` system (the five Fixer NPCs, with bands and pricing)
is **separate** from `reputation` and untouched by v1.

---

# New Reward / Effect Types

These are applied through `Shunt.Effects.apply/2` — list them in an event's
`on_complete`.

## Trust / Favors

```elixir
{:modify_rep, "juno", :trust, 10}   # raise trust
{:modify_rep, "juno", :favors, 1}   # owe a favor
{:modify_rep, "juno", :favors, -1}  # spend a favor
```

`dim` is `:trust` or `:favors`. The value is clamped at a minimum of 0; the npc
and dimension entries are created on first use.

## Knowledge

```elixir
{:knowledge, "juno_secret_supplier"}
```

Appends to `player.knowledge` (idempotent).

## Contact Discovery

```elixir
{:contact, "rose_broker"}
```

Appends to `player.contacts` (idempotent). Reserved for the first cross-NPC
edge; not used by the v1 content slice.

Currency rewards use the existing `{:scrip, n}` / `{:cred, n}` effects — there is
no `:credits`.

---

# New Requirement Types

Requirements are evaluated by `Shunt.Requirements.met?/2`. A requirement list is
met only when **every** entry passes; an empty list is always met.

```elixir
{:knows, "rook"}                       # key in player.knowledge
{:contact_known, "rose_broker"}        # key in player.contacts
{:rep_at_least, "juno", :trust, 20}    # reputation[npc][dim] >= n (missing -> 0)
{:has_item, "juno_parcel"}             # inventory[key] >= 1 (carried-item gate)
```

`{:knows, ...}` replaces the older `{:flag, :atom}` form; all gating keys are now
strings, consistent with the rest of the content model.

<!-- TODO: document the {:has_item, key} requirement (met when player.inventory has key at
count >= 1), the :quest_items content category, and the multi-location errand pattern. Cover
the two task entry styles: "dispatch" (accept grants a carried item that gates leg 1) and
"persistent-gate" (an existing knowledge/rep gate covers leg 1); both share the return-token
mechanic (leg 1 grants a token, the report POI is gated by {:has_item, token}). Use the
reworked Juno move_package / quiet_pickup / supplier_investigation errands as worked examples. -->


---

# Where Requirements Apply (hide-entirely)

Content with unmet requirements is **hidden entirely** — not shown as locked or
redacted. The world-facing helpers in `Shunt.World` project a player-specific
view:

* **Locations** carry an optional top-level `requirements:` list.
* **Exits** (`%Shunt.World.Exit{}`) carry an optional `requirements:` list.
* **Events** (`%Shunt.Events.Event{}`) carry an optional `requirements:` list,
  used for **points-of-interest (POI) events** only. NPC story-arc events ignore
  it — their ordering is the linear `npc_progression` index.

Key functions:

* `World.location_accessible?(player, id)` — location's own requirements met.
* `World.available_exits(player, id)` — exits whose requirements are met **and**
  whose destination location is accessible.
* `World.accessible_locations(player)` — the map view: locations reachable from
  the current location via available exits (breadth-first), each with its exits
  narrowed to the available ones.
* `World.points_of_interest(player, id)` — a location's event ids whose event
  requirements are met.

`Shunt.Movement.can_move?/2` enforces `available_exits` server-side, so a hidden
exit cannot be traversed even if the client forges a move. The LiveView consumes
these helpers and never evaluates requirements itself (presentation boundary).

**Why reachability, not a simple filter:** exits are written both ways but a
requirement usually sits on only one direction, and a location can be gated while
its exit is open. A naive per-item filter would leave dangling map edges or let a
player slip in through the open return exit. BFS over *available* exits hides the
whole unreachable branch cleanly.

---

# Worked Example: Juno

Juno is a smuggler and contraband broker who works the Shunt 9 Bazaar. The v1
content slice (`priv/content/.../juno/...`, `shunt9_bazaar_juno.exs`) is the
reference pattern for authoring Web content.

## The NPC and arc spine

```elixir
%Shunt.World.NPC{
  id: "shunt9_bazaar_juno",
  name: "Juno",
  location_id: "shunt9_bazaar",
  story_arcs: [
    "shunt9_bazaar_juno_move_package",
    "shunt9_bazaar_juno_quiet_pickup"
  ],
  repeatable_events: ["shunt9_bazaar_juno_odd_job"]
}
```

The arc is linear: completing an event bumps `npc_progression` and the NPC offers
the next one. (Provide at least one `repeatable_events` entry — once the arc is
done, `current_event/2` draws from the repeatable pool.)

## Arc event 1 — Move a Package

Available immediately (no requirements; ordering is the arc index).

```elixir
%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_move_package",
  title: "Move a Package",
  on_complete: [
    {:scrip, 50},
    {:modify_rep, "juno", :trust, 10},
    {:npc_progression, "shunt9_bazaar_juno", 1}
  ],
  steps: [ ... ]
}
```

## Arc event 2 — Quiet Pickup

The pivot: it pays out the knowledge that opens the world.

```elixir
on_complete: [
  {:modify_rep, "juno", :trust, 10},     # trust now 20
  {:modify_rep, "juno", :favors, 1},
  {:knowledge, "juno_secret_supplier"},
  {:npc_progression, "shunt9_bazaar_juno", 1}
]
```

## Reveal A — knowledge unlocks a location

`shunt9_supplier_drop` is gated at the **location** level and reached by an open
exit from the bazaar. It is hidden until the player knows the supplier.

```elixir
# shunt9_supplier_drop.exs
requirements: [{:knows, "juno_secret_supplier"}]
```

## Reveal B — trust unlocks an exit

The `bazaar -> shunt9_cargo_chute` **exit** is gated on a trust threshold. It
appears once trust reaches 20.

```elixir
%Exit{
  id: "bazaar_to_cargo_chute",
  to: "shunt9_cargo_chute",
  requirements: [{:rep_at_least, "juno", :trust, 20}]
}
```

## A gated point of interest

`shunt9_bazaar_juno_supplier_investigation` is a POI event listed on the bazaar,
gated by the same knowledge. It surfaces at the bazaar only after the player
learns the supplier.

```elixir
requirements: [{:knows, "juno_secret_supplier"}],
on_complete: [{:scrip, 150}, {:modify_rep, "juno", :trust, 10}]
```

## The first network edge (expansion hook)

A future arc event can pay out `{:contact, "rose_broker"}`, and Rose's first
event/exit can require `{:contact_known, "rose_broker"}`. That single pair forms
the first edge of the social network — Juno introduces Rose — with no graph
system:

```text
Juno  →  introduces  →  Rose
```

---

# Future Phase (Not In Scope)

Deferred until the core loop proves fun:

* Explicit relationship graphs
* Faction influence networks
* Rumor boards
* Social manipulation systems
* Gang politics simulation
* Dynamic leverage generation
* Contact loyalty decay
* Converging the Fixer `npc_loyalty` model with `reputation`

The v1 focus is the loop:

```text
Events → Trust / Favors / Knowledge → Revealed Locations, Exits, POIs → More Events
```

If that loop is engaging, further Web systems layer on top without replacing this
architecture.
