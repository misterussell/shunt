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

> **Naming note:** this document originally used generic terms ("CharacterServer", "Character Aggregate", "Event Engine") written before the codebase existed. The actual modules are named after `Player`, not `Character` (there is no `Character` anywhere in the code). This revision renames every section to the real module names so it can be implemented directly. See "Codebase Grounding" below for the audit this revision is based on.

---

# Codebase Grounding (audited 2026-06-23)

Before writing this revision, the following was confirmed against the current code (not assumed):

| Doc concept | Reality |
|---|---|
| CharacterServer | `Shunt.Players.Server` — `lib/shunt/players/server.ex`. GenServer per player, registered via `Registry`, started lazily by `Shunt.Players.lookup_or_start/1` (`lib/shunt/players.ex:18-30`). |
| Character struct | `Shunt.Players.Player` — `lib/shunt/players/player.ex`. Ecto schema, fields: `cred`, `scrip`, `heat`, `current_offer_key`, `held_item_key`, four skill tiers, `inventory` (map), `npc_loyalty` (map). **No location field exists today.** |
| Event Engine | Doesn't exist as a named module. The actual convention: a context module (`Shunt.Fencing`, `Shunt.Npcs`, `Shunt.Crafting`, `Shunt.Players`) exposes `can_x?/1` + `x/1` function pairs taking a `%Player{}` and returning `{:ok, effects}` / `{:ok, effects, extra_meta}` / `{:error, reason}`. Dispatched via `Shunt.Players.dispatch(player_id, &Module.fun/1)` (`lib/shunt/players.ex:32-36`), which routes to the GenServer. |
| Effect Engine | `Shunt.Effects` — `lib/shunt/effects.ex`. One module, one `apply/2` function, pattern-matching effect tuples (`{:scrip, delta}`, `{:cred, delta}`, `{:heat, delta}`, `{:inventory, key, delta}`, `{:npc_loyalty, key, delta}`, `{:set, field, value}`). New effect types are new clauses here, not a new module. |
| World State | Doesn't exist. Closest analog: `Shunt.Content` (`lib/shunt/content.ex`) — two generic functions, `all/1` and `fetch!/2`, over ETS tables. Tables are seeded once at boot by `Shunt.Content.Store` (`lib/shunt/content/store.ex`) from a hardcoded `@sources` list of `{table, directory}` pairs (currently `:npcs`, `:fencing_items`, `:raws`, `:recipes`, `:heat_events`, `:skill_trees`). |
| Content Registry | Confirmed pattern. Each content item is one `.exs` file evaluating to a map with a `key` field (**not** `id` — see every file under `priv/content/npcs/`, `priv/content/raws/`, etc.). The loader inserts `{item.key, item}` into ETS (`Shunt.Content.Store.load_source/2`). |
| `meta.deltas` | `Shunt.Effects.apply/2` returns `{changes, meta}` where `meta.deltas` is hardcoded to `Map.take(changes, [:scrip, :cred, :heat])` (`lib/shunt/effects.ex:7,15-19`). It will never include `location_id` — that's not a delta-able numeric field. LiveView already reads other non-delta fields (e.g. `held_item_key`) directly off the returned `%Player{}` rather than off `meta.deltas` (`lib/shunt_web/live/hub_live.ex:84,118`) — movement should follow that same pattern. |
| Narrative feed | Doesn't exist anywhere. The closest thing is a single transient `status` string assign in `HubLive` (`lib/shunt_web/live/hub_live.ex:39` etc.), overwritten on every action, not a list/feed. No LiveView in this codebase uses `stream/3` yet — every existing LiveView (`HubLive`, `SkillsLive`) uses plain assigns only. |
| SVG / graph rendering | Doesn't exist anywhere in the app. This would be the first SVG/visual-graph UI in the codebase. |
| Auth / `current_scope` | Doesn't exist. There is no accounts/session system at all — `Shunt.Players.get_player!/0` (`lib/shunt/players.ex:14-16`) assumes exactly one row in the `players` table, and `HubLive.mount/3` calls it directly (`lib/shunt_web/live/hub_live.ex:14`). The game is currently single-player-per-deployment. This doc does not need to solve multiplayer/auth. |
| Requirements gating | No generic requirements checker exists. No faction-level reputation field exists on `Player` (only per-NPC `npc_loyalty`). No story-flags field exists at all. Building `{:rep, ...}` / `{:flag, ...}` exit gating today means inventing that state ahead of any other feature needing it. |

Three scope decisions were made with the project owner before writing the phases below:

1. **Narrative feed is ephemeral**, not DB-persisted (LiveView stream/assign only, cleared on reconnect).
2. **Exit is not a separate content type/table.** It's an embedded field on `Location` (`exits: [...]`), not a parallel `:exits` ETS table.
3. **Exit `requirements` stay `[]` through Phase 4.** Faction rep, story flags, and a `RequirementsEngine` are explicitly deferred — not part of this feature's scope.

---

# Architectural Principles

This feature must respect the existing architectural decisions:

1. LiveView remains presentation-only — see the "LiveView presentation boundary" rules in `AGENTS.md`, and `lib/shunt_web/live/hub_live.ex` / `lib/shunt_web/live/skills_live.ex` as existing precedent (they dispatch to context modules and render the returned `%Player{}` + `meta`; they never compute game state).
2. `Shunt.Players.Server` owns active player state.
3. A new context module (`Shunt.Movement`, following the `Shunt.Fencing`/`Shunt.Npcs` convention) resolves the move action — there is no separate "Engine" to introduce.
4. `Shunt.Effects` applies state mutations — extended with one new clause, not a new module.
5. A new thin module (`Shunt.World`) owns read-only world topology queries over the existing `Shunt.Content` ETS layer — not a new GenServer/process, since locations and exits are static content like NPCs and recipes already are.
6. Static location content lives in the Content Registry (`priv/content/locations/*.exs`, loaded via the existing generic `Shunt.Content.Store.load_source/2`).

The location graph is not a UI feature.

The location graph is a gameplay system that will later be visualized in LiveView.

---

# High-Level Ownership

## Content Registry

Owns:

```elixir
Location   # exits are embedded on Location, not a separate content type
```

Responsibilities:

* Load location definitions from `priv/content/locations/*.exs`
* Serve read-only world topology via `Shunt.Content.all/1` / `Shunt.Content.fetch!/2`

Required change: add `{:locations, "priv/content/locations"}` to the `@sources` list in `Shunt.Content.Store` (`lib/shunt/content/store.ex:5-12`). This list is a compile-time module attribute — it must be edited directly, content files alone are not auto-discovered.

The Content Registry is the source of truth for the map.

---

## World (pure query module — not a GenServer)

`Shunt.World`, mirroring the existing `Shunt.Npcs` module (`lib/shunt/npcs.ex:11-15`, which is just `list/0` + `get!/1` over `Shunt.Content`):

```elixir
World.get_location(key)
# Content.fetch!(:locations, key)

World.exits(location_key)
# Content.fetch!(:locations, location_key).exits

World.connected?(from, to)
# to in Enum.map(World.exits(from), & &1.to)
```

No new process is needed. Locations are static content, already served read-concurrently by ETS via `Shunt.Content.Store`. A GenServer would only be justified once something needs *dynamic* per-request world state (the doc's "future dynamic location modifiers" in Future Extensions) — not for Phase 1-4.

`World` does not own player positions.

---

## Player Aggregate

Add to `Shunt.Players.Player` (`lib/shunt/players/player.ex`):

```elixir
field :location_id, :string
field :discovered_locations, {:array, :string}, default: []
```

Notes:

* **Not `MapSet.new()`.** Ecto has no native MapSet type — exactly the same reason `inventory` and `npc_loyalty` are plain maps rather than custom structs. Store `discovered_locations` as a plain string list; dedupe with `Enum.member?/2` before appending (or `Enum.uniq/1` after), don't introduce a MapSet anywhere it has to round-trip through Ecto.
* New migration following the precedent of `add_fencing_fields_to_players` / `add_npc_loyalty_to_players` — e.g. `add_location_to_players`.
* `location_id` needs a concrete starting value. `Shunt.Players.create_player!/0` (`lib/shunt/players.ex:10-12`) inserts a bare `%Player{}` relying on schema defaults — decide the starting location now (e.g. `"shunt9_player_squat"`) and either set it as the field default or set it explicitly in `create_player!/0`.

Responsibilities:

* Current player position (`location_id`)
* Known/discovered locations (`discovered_locations`)

Location is persistent player state, same durability tier as `inventory`/`npc_loyalty`.

---

## Movement (context module, not "Event Engine")

New module `Shunt.Movement`, following the exact shape of `Shunt.Players.lay_low/1` (`lib/shunt/players.ex:46-52`) and `Shunt.Npcs.flesh_tithe/1`:

```elixir
Movement.can_move?(player, destination)
# World.connected?(player.location_id, destination)
# (no requirements check in Phase 1-4 — Exit requirements are always [])

Movement.move(player, destination)
# {:ok, effects, %{narrative: text}} | {:error, :not_connected}
```

Flow:

Move Action
↓
Validate Destination (`World.connected?/2`)
↓
Build effects list
↓
Return `{:ok, effects, extra_meta}`

Dispatched from LiveView exactly like every other action:

```elixir
Players.dispatch(player_id, &Movement.move(&1, destination))
```

`Shunt.Movement` never mutates state directly — same as every other context module.

---

## Effects (extend `Shunt.Effects`, no new module)

Two changes to `lib/shunt/effects.ex`:

1. **Location change** — no new effect type needed. Reuse the existing generic setter already used for `current_offer_key`/`held_item_key` (`{:set, field, value}`, `lib/shunt/effects.ex:72-74`):

   ```elixir
   {:set, :location_id, destination}
   ```

2. **Discovery** — one new clause in `do_apply/4`, mirroring the existing `{:inventory, key, delta}` clause (`lib/shunt/effects.ex:47-52`):

   ```elixir
   {:discover_location, location_key}
   # appends location_key to acc's discovered_locations if not already present
   ```

Narrative text is **not** an effect. Effects mutate `Player` fields; narrative text isn't player state. It travels through the existing third-tuple `extra_meta` channel that `Shunt.Crafting.scavenge/1` already uses for `%{gained_raw: raw.key}` — `Shunt.Players.Server.dispatch_effects/3` (`lib/shunt/players/server.ex:36-46`) already merges `extra_meta` into the `meta` map returned to the caller, so no server change is needed.

Example return from `Movement.move/2`:

```elixir
{:ok,
 [
   {:set, :location_id, "shunt9_scrapyard"},
   {:discover_location, "shunt9_scrapyard"}
 ],
 %{narrative: "You leave the Bazaar. Mountains of twisted metal loom overhead."}}
```

The LiveView reads `player.location_id` and `meta.narrative` directly — same pattern already used for `player.held_item_key` (`lib/shunt_web/live/hub_live.ex:84`), not `meta.deltas` (which only ever covers `scrip`/`cred`/`heat`).

---

## PubSub

Optional for Phase 1-3. The game is currently single-player-per-deployment (`Players.get_player!/0` assumes one row) — there's no second viewer to notify yet. If/when needed, mirror `Shunt.Npcs.Signals` exactly (`lib/shunt/npcs/signals.ex`):

```elixir
defmodule Shunt.Movement.Signals do
  @topic "movement_signals"
  def subscribe, do: Phoenix.PubSub.subscribe(Shunt.PubSub, @topic)
  def location_changed(player_id, location_key), do: ...
end
```

Defer until a concrete second consumer (a future map-spectator view, multiplayer, etc.) exists.

---

# Content Definitions

## Location

Locations are static content. One file per location under `priv/content/locations/`.

```elixir
%{
  key: "shunt9_bazaar",
  name: "Shunt 9 Bazaar",

  short_description:
    "The beating heart of Shunt 9.",

  description:
    "Hundreds of stalls crowd the abandoned transit platform.",

  tags: [
    :market,
    :underbelly
  ],

  graph_position: {500, 300},

  exits: [
    %{to: "shunt9_scrapyard", requirements: []},
    %{to: "shunt9_food_stalls", requirements: []},
    %{to: "shunt9_power_relay", requirements: []},
    %{to: "shunt9_burned_platform", requirements: []}
  ]
}
```

Notes:

* `key`, not `id` — matches every other content type (`priv/content/npcs/*.exs`, `priv/content/raws/*.exs`, etc. all use `key` as the ETS lookup field; `Content.fetch!/2` looks up by it directly).
* `graph_position` exists specifically for future LiveView map rendering. Store coordinates as world-space positions. Do not calculate UI layout dynamically.
* **Exits are one-directional and not auto-mirrored.** If Bazaar lists an exit to Scrap Yard, Scrap Yard's own file must separately list an exit back to Bazaar. There is no bidirectional-link helper — write both sides.
* Future `requirements` entries (e.g. `{:rep, :syndicate, :trusted}`, `{:flag, :maintenance_pass}`) are explicitly out of scope through Phase 4 — see Future Extensions. Every exit ships with `requirements: []`.

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

5–8 locations is sufficient. Remember: every line in this diagram is two exits (one per direction), each written into its own location's file.

---

# Movement Flow

## Step 1

Player clicks connected location.

LiveView `handle_event("move_to", %{"location" => destination}, socket)`.

---

## Step 2

LiveView calls:

```elixir
Players.dispatch(socket.assigns.player_id, &Movement.move(&1, destination))
```

This routes through `Shunt.Players.Server` (the same GenServer every other action already goes through) — no new server is introduced.

---

## Step 3

`Shunt.Movement.move/2` validates:

```elixir
World.connected?(player.location_id, destination)
```

`requirements` checks are a no-op through Phase 4 (always `[]`).

---

## Step 4

`Shunt.Movement.move/2` returns:

```elixir
{:ok,
 [
   {:set, :location_id, destination},
   {:discover_location, destination}
 ],
 %{narrative: "..."}}
```

---

## Step 5

`Shunt.Effects.apply/2` applies the effects, `Players.Server.dispatch_effects/3` persists via `Repo.update`, and returns `{:ok, player, meta}` to the LiveView — same path every other action already takes. LiveView re-renders from the returned `player` and `meta.narrative`. No PubSub broadcast required for Phase 1-3 (see PubSub note above).

---

# Narrative Integration

Movement should automatically create a narrative line.

Example:

```text
You leave the Bazaar.

The smell of hot circuitry fades as you descend into the Scrap Yard.

Mountains of twisted metal loom overhead.
```

Per the ephemeral-feed decision: keep the last N entries (e.g. 20) in a LiveView `stream/3` assign, appended on each successful move, **not** persisted to the database. This will be the first use of `stream/3` in this codebase (existing LiveViews use plain assigns only) — follow the standard streams pattern from `AGENTS.md` (`phx-update="stream"`, parent DOM id, `stream_delete` if trimming old entries).

Movement becomes the first producer of narrative entries.

---

# Action Resolution

Do NOT attach actions directly to locations.

Avoid:

```elixir
%{
  key: "shunt9_bazaar",
  actions: [...]
}
```

The doc's original `ActionResolver.available_actions/2` concept is sound but is explicitly **out of scope for this feature** (Phase 5+, see Sprint Deliverables). The current codebase precedent for "what can I do here" is hardcoded per-NPC `cond do` blocks in the LiveView template (`lib/shunt_web/live/hub_live.ex:290-336`) — building a generic resolver is a bigger lift than the rest of this feature and shouldn't block shipping movement itself.

---

# LiveView Rendering Strategy

Initial implementation:

SVG-based graph, rendering `graph_position` from each location's content.

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

This will be the **first SVG/visual-graph UI anywhere in this codebase** — there's no existing precedent to follow, so budget extra time for it relative to the rest of the feature. If it proves to be a bigger lift than expected, a plain Tailwind list/grid of connected-location buttons (matching the rest of the app's visual language) is an acceptable fallback for Phase 2, with the SVG graph following in Phase 4.

New route: `live "/map", MovementLive` added to the single existing `:browser` scope in `lib/shunt_web/router.ex:17-25`. No `live_session`/auth gate needed — none exist anywhere in this app today.

LiveView should not calculate movement rules. It should only visualize state returned by `Shunt.Movement`/`Shunt.Effects`.

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

**Explicitly deferred, not designed here:** faction-level reputation, story flags, and a generic `RequirementsEngine` for exit gating. None of that state exists on `Player` today, and inventing it just to unblock one exit would be solving a problem nothing else has yet. Design these together, as their own feature, once a concrete consumer needs them (e.g. a faction-checkpoint exit).

Everything in this feature builds on:

```
Location (with embedded exits)
Shunt.Movement
{:set, :location_id, _} / {:discover_location, _} effects
```

as the foundational primitives.

---

# Sprint Deliverables

## Phase 1 — Foundation (data + movement core, no UI)

* Migration: `location_id` (string), `discovered_locations` ({:array, :string}, default `[]`) on `players`
* Decide and set a starting `location_id` for new/existing players
* `{:locations, "priv/content/locations"}` added to `Shunt.Content.Store.@sources`
* 5–8 location files under `priv/content/locations/*.exs` (`key`, `name`, descriptions, `tags`, `graph_position`, embedded `exits` with `requirements: []`), both directions written for every connection
* `Shunt.World`: `get_location/1`, `exits/1`, `connected?/2`
* `Shunt.Movement`: `can_move?/2`, `move/2`
* `Shunt.Effects`: new `{:discover_location, key}` clause
* Tests: `Shunt.World` queries, `Shunt.Movement` validation + effects, migration round-trip

## Phase 2 — Surfacing in LiveView

* `MovementLive` (new route) or an extension of an existing LiveView — plain HTML/Tailwind list of connected locations (graph/SVG comes later, see Phase 4)
* `handle_event("move_to", ...)` → `Players.dispatch(player_id, &Movement.move(&1, destination))`
* Render current location name/description from `player.location_id`

## Phase 3 — Narrative + Discovery polish

* Ephemeral narrative feed via LiveView `stream/3` (last N entries, cleared on reconnect, no schema)
* Discovered-locations indicator using `player.discovered_locations`
* `Shunt.Movement.Signals` PubSub topic — only if a concrete second consumer exists by then

## Phase 4 — Graph visualization

* SVG renderer using `graph_position` (first SVG UI in this codebase — budget accordingly)
* ● / ○ / 🔒 legend

## Phase 5+ — Explicitly deferred, not yet scoped

* `ActionResolver` (dynamic action composition from location/skills/NPCs/flags)
* `RequirementsEngine` + faction reputation + story flags (exit gating beyond always-`[]`)
* Ambient location events, NPC spawning, territory control, dynamic world modifiers

---

Success Criteria:

A player can navigate between locations in Shunt 9 (text-list in Phase 2, graph-based map in Phase 4), while all movement flows through `Shunt.Movement` and `Shunt.Effects` — the same dispatch path (`Shunt.Players.dispatch/2` → `Shunt.Players.Server` → `Shunt.Effects.apply/2`) every other action in the game already uses.
