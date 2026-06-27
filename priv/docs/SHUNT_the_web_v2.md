# Shunt Feature: The Web v2 — Rumor Board Investigation System

## Goal

The Web v2 extends the existing data-driven architecture with an investigation layer.
Players collect rumors through exploration, NPC dialogue, and Ghostwork. On the Web
skill page, they assemble those rumors into a theory and submit it for evaluation.
Matching an authored investigation unlocks new content; being wrong has consequences.

This is **not** a standalone subsystem. It reuses the existing event, effects,
requirements, and content-store architecture throughout.

---

## Design Philosophy

```text
Rumors (collected via events/ghostwork/exploration)
      ↓
Player assembles a theory (selects rumors on the board)
      ↓
Theory Resolver (pure function, matches against authored RumorConnections)
      ↓
Matching RumorConnection fires an Event (success / partial / failure)
      ↓
Outcome (existing effects pipeline: scrip, heat, knowledge, contacts, locations, etc.)
```

Rumors are content. Connections are content. Outcomes are authored Events.
The resolver is a pure function with no special-case logic.

---

## What Already Exists (No Changes Needed)

- `player.knowledge`, `player.contacts`, `player.reputation` — The Web v1 ledger
- `{:modify_rep, npc, dim, delta}` effect — trust/favor changes
- `{:knowledge, key}`, `{:contact, key}` effects
- `Requirements.met?/2` with `{:knows, ...}`, `{:rep_at_least, ...}`, `{:has_item, ...}`
- `Events.choose/3` and `Effects.apply/2` — the full event/outcome pipeline
- `player.completed_events` — tracks non-repeatable event completions
- `Content.Store` ETS pattern — new content tables follow the same shape

---

## New Player State

One new field on `Shunt.Players.Player` (requires a migration):

```elixir
field :rumors, {:array, :string}, default: []  # collected rumor ids
```

Kept separate from `player.knowledge` so the investigation board can enumerate
rumor collection directly without filtering all knowledge strings.

**No field for active theory** — the working theory is ephemeral socket state in
`WebLive`. Navigating away resets it. The rumor *collection* persists; the current
arrangement does not.

**No separate `solved_investigations` field** — success events are non-repeatable and
tracked in `player.completed_events`. Partial and failure events are repeatable, so
the player can keep refining a theory.

---

## New Effect Type

```elixir
{:rumor, "juno_supplier"}   # appends to player.rumors (idempotent)
```

Applied through the existing `Effects.apply/2` pipeline alongside any other reward.

---

## New Requirement Type

```elixir
{:has_rumor, "juno_supplier"}   # key in player.rumors
```

Gates content (exits, locations, POI events) behind rumor possession. Evaluated by
`Requirements.met?/2` the same as `{:knows, ...}` and `{:has_item, ...}`.

---

## New Content Types

### Rumor

A single piece of collected information. Lives in `priv/content/rumors/`.

```elixir
%Shunt.Web.Rumor{
  id: "juno_supplier",
  title: "Juno's Supplier",
  description: "Someone has been supplying Juno with corporate hardware.",
  source: "npc",          # display label only — "npc", "latticework", "location"
  tags: ["corporate", "smuggling", "juno"]  # display only, no effect on resolution
}
```

`source` and `tags` are flavor for the board UI. Neither affects the resolver.
Tags use strings, consistent with the rest of the content model.

Rumors do not contain connection logic. They are independent content reusable
across multiple investigations.

---

### RumorConnection

An authored investigation. Lives in `priv/content/rumor_connections/`.

```elixir
%Shunt.Web.RumorConnection{
  id: "supplier_conspiracy",
  rumors: ["juno_supplier", "missing_shipments", "vex_debts"],
  partial_threshold: 2,
  success_event_id: "supplier_conspiracy_success",
  partial_event_id: "supplier_conspiracy_partial",
  failure_event_id: "supplier_conspiracy_failure"
}
```

`partial_threshold` — if the player's submitted rumor set contains ≥ this many of
the connection's rumors (but not all), the partial event fires. Fewer matching
rumors = failure. Exact match = success.

A single rumor id can appear in many `RumorConnection` definitions.

---

## Theory Resolution

`Shunt.Web.resolve_theory(player, rumor_ids)` is a pure function.

Resolution order for each `RumorConnection`:

1. If submitted set exactly matches `connection.rumors` → `:success`
2. If overlap count ≥ `connection.partial_threshold` → `:partial`
3. Otherwise → `:failure`

The resolver walks all connections and returns the first match. If no connection
matches at any level, the global failure event fires.

The resolved event id is passed to `Events.choose/3` via the existing player
dispatch pipeline.

**Success events** are `repeatable: false` — tracked in `player.completed_events`,
cannot be re-triggered once solved.

**Partial and failure events** are `repeatable: true` — the player can keep
refining and resubmitting.

---

## Authored Outcome Events

Each outcome is a standard `%Shunt.Events.Event{}` authored in `priv/content/events/`.
All existing effect types are available.

### Success

```elixir
%Event{
  id: "supplier_conspiracy_success",
  repeatable: false,
  on_complete: [
    {:discover_location, "freight_tunnel"},
    {:contact, "dex_broker"},
    {:rumor, "freight_tunnel_shipments"},
    {:scrip, 200}
  ],
  steps: [...]
}
```

### Partial

```elixir
%Event{
  id: "supplier_conspiracy_partial",
  repeatable: true,
  on_complete: [
    {:rumor, "authority_involvement"}   # new lead to collect and connect
  ],
  steps: [...]
}
```

### Failure

```elixir
%Event{
  id: "supplier_conspiracy_failure",
  repeatable: true,
  on_complete: [
    {:heat, 15}
    # Trust penalties (e.g. {:modify_rep, "juno", :trust, -10}) are added here
    # later, once reputation is surfaced in the UI. No code changes needed —
    # it's a content-file edit.
  ],
  steps: [...]
}
```

---

## Content Store Changes

Two new ETS tables added to `Shunt.Content.Store`:

```elixir
{:rumors, "priv/content/rumors"},
{:rumor_connections, "priv/content/rumor_connections"}
```

Each follows the existing `load_source/2` pattern — one `.exs` file per entry,
keyed by `id`.

A new `Shunt.Web` context module exposes:

```elixir
Shunt.Web.get_rumor!(id)          # fetches from :rumors ETS
Shunt.Web.all_rumor_connections() # fetches all from :rumor_connections ETS
Shunt.Web.resolve_theory(player, rumor_ids)
  # → {:success | :partial | :failure, event_id}
```

---

## LiveView: WebLive

`/skills/the-web` gets its own `ShuntWeb.WebLive`, replacing the current stub in
`SkillsLive, :web`.

### Board State (socket assigns)

```elixir
assign(:rumors, player_rumors)          # list of %Rumor{} the player has collected
assign(:selected, MapSet.new())         # ids currently in the working theory
assign(:result, nil)                    # last resolution outcome, nil when idle
```

### Events

- `"toggle_rumor"` — adds/removes a rumor id from `:selected`
- `"investigate"` — calls `Web.resolve_theory/2`, fires the resolved event via
  `Players.dispatch/2`, sets `:result`
- `"clear"` — resets `:selected` to empty

### UI (V1)

Click-to-select from the collected rumor collection. No drag-and-drop.

The board communicates "investigation interface" through styling:
- Dark panel background
- Rumor cards showing title, source label, and tags
- Selected state highlighted with neon accent
- Submit button active only when ≥ 2 rumors are selected

The draggable board with animated connection lines is a future UI milestone,
addable without touching the backend.

---

## How Rumors Are Acquired

Rumors surface through the existing content systems — no new acquisition mechanism:

- **NPC arc events** — `on_complete: [{:rumor, "juno_supplier"}, ...]`
- **POI events** — a location event grants a rumor on completion
- **Ghostwork** — ICE nodes or programs yield rumors as rewards
- **Location discovery** — `{:rumor, key}` in a `{:discover_location}` event's effects

The rumor reward is just another entry in an `on_complete` list.

---

## Worked Example: Supplier Conspiracy

### Acquisition

1. Player completes Juno's `quiet_pickup` arc event → receives `{:rumor, "juno_supplier"}`
2. Player hacks a corporate relay ICE node → receives `{:rumor, "missing_shipments"}`
3. Player talks to a corrupt officer POI event → receives `{:rumor, "vex_debts"}`

### Board

Player opens `/skills/the-web`. Three rumor cards are displayed. They select all
three and click Investigate.

### Resolution

Resolver checks `supplier_conspiracy`:

- Submitted: `["juno_supplier", "missing_shipments", "vex_debts"]`
- Connection: `["juno_supplier", "missing_shipments", "vex_debts"]`
- Exact match → `:success` → fires `supplier_conspiracy_success`

### Outcome

```text
New location unlocked: Freight Tunnel
New contact unlocked: Dex
New rumor collected: "freight_tunnel_shipments"
+200 scrip
```

The investigation expands naturally — new rumor in hand, new connection to find.

---

## Future Phases (Out of Scope for V2)

- Draggable board with animated connection lines
- Trust penalties on failure (content-only change, no code needed)
- Reputation UI to surface trust values
- Tag-based partial matching
- `{:has_rumor, key}` requirement gates on exits and locations
- Faction-scale conspiracies spanning multiple RumorConnections
- Rumor decay or expiry
