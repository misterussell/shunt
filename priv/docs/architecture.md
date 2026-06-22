# Shunt — Runtime Architecture
## Phase 1: Player Process, Event Engine, Effect Engine, Content Registry

> **Status:** Agreed design, staged for implementation. Source: `SHUNT_Elixir_Phoenix_Architecture.md` (engineering handoff doc), adapted to this codebase's actual state and house rules (see "Decisions vs. the source doc" below).

---

## Why this exists

The source architecture doc proposes a `CharacterServer → Event Engine → Effect Engine` separation as the central pattern for Shunt: state ownership, content execution, and state mutation each get their own layer. This document is the adapted, codebase-specific version of that proposal — scoped to what's needed *now*, before Market Shifts, Skill Tier Unlock, and Territory Progression (GDD Sprint 2 items 1, 4, 5) add more systems on top of the current ad-hoc pattern.

This is Phase 1 only. See "Explicitly deferred" at the bottom for what's intentionally not in this document.

---

## Decisions vs. the source doc

The source doc was written generically; these are the calls made to fit this specific codebase and its house rules (`CLAUDE.md`: "Singleton is an anti-pattern in Elixir. Functional always."):

1. **Naming**: the doc says "Character" (`CharacterServer`, "Character Aggregate"). This codebase already uses "Player" everywhere (`Shunt.Players`, `Shunt.Players.Player`, the `players` table). We use `Shunt.Players.Server`, not `CharacterServer` — same concept, existing vocabulary.
2. **Multiplayer readiness without auth**: there are no accounts yet — `Players.get_player!/0` returns the one existing row. Rather than build a single named process (which would need rework later), the player process layer is `Registry` + `DynamicSupervisor` keyed by `player_id` from day one. Today `player_id` is just the existing row's primary key; when real accounts exist, only how `player_id` is obtained changes, not the process machinery.
3. **Singleton exception**: the doc recommends singleton GenServers for World State Service and Market Service (genuinely global mutable state). That looks like it conflicts with "singletons are an anti-pattern," but the existing `Npcs.Store` already establishes the precedent: a named singleton GenServer is acceptable when there really is exactly one of something (one NPC content registry, one market). The anti-pattern rule targets service-locator-style singletons standing in for what should be passed explicitly, not unique shared state coordinators. (Market/World State Service design itself is deferred — see below — but this precedent will carry forward to that design.)
4. **Persistence strategy**: the doc lists "batch persistence" as a `CharacterServer` responsibility. This design keeps **synchronous write-through** — every effect still calls `Repo.update` immediately, same as today, just routed through the new layers instead of inlined in context modules. No crash-recovery/dirty-state-flush logic is built. Batching can be revisited if write volume ever becomes a real bottleneck; it isn't one for a single-player prototype.
5. **Event Engine scope**: the doc's Event Engine is built for branching content (`Opportunity → select Event from pool → present Choices → resolve Choice → generate Effects`). Nothing in this codebase has player-facing choices yet — `take_offer`, `scavenge`, `flesh_tithe`, etc. each resolve to one fixed outcome. This design builds a **lean Action Resolver** sized to that reality: existing context modules (`Fencing`, `Crafting`, `Npcs`) become effect-list-producing functions. The full Opportunity/Choice/event-pool layer is deferred until Bespoke commissions are actually designed (GDD's primary quest format, not yet built).

---

## 1. Process & Player Identity Architecture

- `Shunt.Players.Registry` — `Registry, keys: :unique`, started in `application.ex`.
- `Shunt.Players.Supervisor` — `DynamicSupervisor`, started in `application.ex`.
- `Shunt.Players.Server` — GenServer, one per `player_id`, registered via `{:via, Registry, {Shunt.Players.Registry, player_id}}`. Holds the loaded `%Player{}` struct as its only state, loaded from Postgres on first start.
  - `Shunt.Players.lookup_or_start(player_id)` — starts the server under the `DynamicSupervisor` if not already running, returns its pid. Called from `DashboardLive.mount/3`.
  - `Shunt.Players.dispatch(player_id, resolver_fun)` — `GenServer.call`s the server with a `(player -> {:ok, effects} | {:ok, effects, meta} | {:error, reason})` function (see Section 3).

`player_id` is `Players.get_player!().id` — the existing single row's primary key. No accounts system is introduced by this design.

---

## 2. Effect Engine

New module `Shunt.Effects`. Effects are tagged tuples:

| Effect | Meaning |
|---|---|
| `{:scrip, delta}` | add delta (negative = spend), clamp ≥ 0 |
| `{:cred, delta}` | same, clamp ≥ 0 |
| `{:heat, delta}` | clamp 0–100, **and** runs `Heat.resolve/2` internally |
| `{:inventory, key, delta}` | adjust `player.inventory[key]` |
| `{:npc_loyalty, npc_key, delta}` | adjust loyalty, compute band transition |
| `{:set, field, value}` | escape hatch for `current_offer_key`, `held_item_key`, etc. |

`Shunt.Effects.apply(player, effects)` is a **pure function** — no `Repo`, no `PubSub`. Returns `{changes_map, meta}`:
- `changes_map` feeds `Ecto.Changeset.change(player, changes_map) |> Repo.update()`.
- `meta` carries things the caller reacts to after persistence (fired heat event for the flash, loyalty band transitions for `Signals`).

**Consolidation this creates**: today, "did a heat event fire, and if so subtract its scrip/cred loss" is duplicated across `Fencing.sell_held_item`, `Crafting.scavenge`, and `Crafting.sell_assembled`. In this design, `{:heat, delta}` handling lives in exactly one place inside `Effects.apply` — when a threshold-crossing event fires, it prepends that event's `{:scrip, -loss}` / `{:cred, -loss}` effects onto the remaining worklist before continuing, and records the event in `meta`. Resolvers no longer need to know event-loss exists. The same consolidation applies to `Npcs.Loyalty`'s duplicated `tap_loyalty_signals`/`emit_loyalty_signals` — band-transition computation happens once, centrally, inside `Effects.apply`.

`Shunt.Players.Server` is the only thing that calls `Effects.apply`, persists via `Repo.update`, and — only after a successful commit — emits `Signals` broadcasts from `meta`.

---

## 3. Action Resolvers (the lean Event Engine)

`Fencing`, `Crafting`, and `Npcs` keep their existing public function names (`take_offer/1`, `scavenge/1`, `flesh_tithe/1`, etc.). Each becomes a pure function: validates preconditions against a plain `%Player{}` struct, returns `{:ok, effects}` / `{:ok, effects, meta}` / `{:error, reason}` — no `Repo`, no `Ecto.Changeset`, no `PubSub`.

Example — `Fencing.take_offer/1` today does `Ecto.Changeset.change |> Repo.update`; after this change:

```elixir
def take_offer(%Player{current_offer_key: nil}), do: {:error, :no_offer}

def take_offer(%Player{current_offer_key: key, scrip: scrip}) do
  item = Catalog.fetch!(key)

  if scrip < item.buy_cost do
    {:error, :insufficient_scrip}
  else
    {:ok, [{:scrip, -item.buy_cost}, {:set, :current_offer_key, nil}, {:set, :held_item_key, key}]}
  end
end
```

This makes resolvers unit-testable as pure functions — assert on the returned effect list — without DB setup.

`Heat.resolve/2` is unchanged; it's already a self-contained "select one outcome from a pool" instance of the pattern, just called from inside `Effects.apply` now instead of from each resolver.

---

## 4. Content Registry Generalization

One generic `Shunt.Content.Store` GenServer (replacing `Shunt.Npcs.Store`) owns multiple named ETS tables — one per content type — configured at boot:

```elixir
@sources [
  {:npcs, "priv/content/npcs"},
  {:fencing_items, "priv/content/fencing"},
  {:raws, "priv/content/raws"},
  {:recipes, "priv/content/recipes"},
  {:heat_events, "priv/content/heat_events"},
  {:skill_trees, "priv/content/skills"}
]
```

For each source, it creates a public named ETS table and loads every `*.exs` file in that directory (`Code.eval_file/1`, insert by key) — the same mechanism `Npcs.Store` already uses. `Shunt.Content.all(table)` / `Shunt.Content.fetch!(table, key)` are generic accessors.

Existing catalog modules (`Fencing.Catalog`, `Crafting.RawCatalog`, `Crafting.RecipeCatalog`, `Heat.Catalog`, `Skills.Catalog`) **keep their current public API** (`items/0`, `fetch!/1`, `trees/0`) — only the implementation changes, from a `@items` module attribute to a thin delegate into `Shunt.Content`. No other call site in the codebase changes.

`priv/npcs/*.exs` moves to `priv/content/npcs/*.exs`. Other catalogs' data moves from module attributes into `priv/content/<type>/*.exs`, one file per item — except `skill_trees`, which loads as a single file (one nested tree structure, not a list of independent keyed items).

---

## 5. LiveView Data Flow

```
LiveView → Players.dispatch/2 → resolver (Event Engine) → Effects.apply/2 (Effect Engine)
         → Players.Server persists → LiveView update
```

`DashboardLive.mount/3`:

```elixir
def mount(_params, _session, socket) do
  player_id = Players.get_player!().id
  if connected?(socket), do: Signals.subscribe()
  {:ok, player} = Players.lookup_or_start(player_id) |> Players.current()
  {:ok, assign(socket, player_id: player_id) |> assign_player(player)}
end
```

`handle_event` callbacks dispatch instead of calling context functions directly:

```elixir
def handle_event("take_offer", _params, socket) do
  case Players.dispatch(socket.assigns.player_id, &Fencing.take_offer/1) do
    {:ok, player, _meta} -> {:noreply, assign_player(socket, player)}
    {:error, _reason} -> {:noreply, socket}
  end
end
```

Heat-event flashes read `meta.heat_event` from `dispatch/2`'s return instead of a third tuple element from the context function.

---

## 6. Testing Strategy

- **Resolvers** (`Fencing`, `Crafting`, `Npcs`): pure unit tests, no DB — assert on returned effect lists/errors given a plain `%Player{}` struct.
- **`Shunt.Effects`**: pure unit tests — assert `apply/2` produces the right `changes_map`/`meta` per effect type, including heat-event-prepend and loyalty-band-transition behavior, without `Repo` or `PubSub`.
- **`Shunt.Players.Server`**: integration tests — start a server, dispatch actions, assert persisted DB state and broadcast signals. This is where `Repo`/`PubSub` are actually exercised.
- **`Shunt.Content.Store`**: generalizes what `Npcs.Store` tests cover today, across all configured sources.
- **`DashboardLive`**: existing tests need minimal changes — rendered HTML/DOM IDs don't change, only the internal dispatch mechanism.

---

## Explicitly deferred (future design sessions, built on this foundation)

- **Requirements Engine / Unlock System** (source doc Phase 2) — generic `{:skill, ...}` / `{:flag, ...}` / `{:rep, ...}` checks and persistent unlocks. Needed before GDD Sprint 2 item 1 (Skill Tier Unlock).
- **Market Service / World State Service** (source doc Phase 3-4) — the singleton-exception precedent above applies, but the actual design (modifiers, rotation cadence, how Fencing/Crafting read them) is GDD Sprint 2 item 4.
- **Territory Ladder** (source doc Phase 4 / GDD Sprint 2 item 5).
- **Full Opportunity/Choice/event-pool Event Engine** — only needed once Bespoke commissions are designed.

Each gets its own brainstorming session once this foundation lands.
