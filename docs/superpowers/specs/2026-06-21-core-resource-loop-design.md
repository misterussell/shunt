# Shunt — Core Resource Loop Design

Date: 2026-06-21

## Context

This is the first game-feature sprint, per `priv/docs/gdd.md` Initial
Development Priority #1: implement the basic Scrip / Cred / Heat resource
model. The project is currently a bare `phx.new` scaffold (see
`docs/superpowers/specs/2026-06-21-project-scaffold-design.md`) — no auth,
no schemas, no game logic exists yet.

Design intent from discussion: Shunt is **not** an idle/auto-tick game.
Resources are generated through active player choices, not a background
clock. This sprint wires up the full resource loop (generate → display →
spend) using one placeholder generation action, ahead of the real Fencing
Mechanic (priority #2) which will replace it.

## Goals

- A persisted resource model (Cred, Scrip, Heat) the player can see and
  affect.
- One generation action and one spend action, proving the full loop works
  end-to-end.
- A plain wireframe UI — no theming, no design system (none exists yet).
- A seam for future auth: resource state belongs to a `Player`, fetched
  through a function that's trivial to swap for "current logged-in
  player" later, without touching the resource logic itself.

## Non-goals

- Real authentication or multi-player support. There is exactly one
  player row in the database, created explicitly via seeding rather
  than lazily ensured at request time (see Data model — singleton
  patterns, including lazy ensure-one-exists logic, are an anti-pattern
  in this codebase).
- The real Fencing Mechanic (buy-low/sell-high), Skill Trees, NPCs, or
  Crafting. "Do a Job" is an explicit placeholder for Fencing.
- Heat Events (threshold-triggered consequences) — explicitly priority
  #6, a separate future sprint. Heat is tracked and displayed but firing
  nothing yet.
- Visual theming/cyberpunk styling — plain Tailwind utility classes only.
- Passive/automatic generation of any kind.

## Data model

A `players` table, owned by a `Shunt.Players` context:

| Field | Type | Notes |
|-------|------|-------|
| `cred` | `:integer` | default `0`, floor `0` |
| `scrip` | `:integer` | default `0`, floor `0` |
| `heat` | `:integer` | default `0`, clamped to `[0, 100]` |

No `name` field — not used anywhere this sprint, so it's left out per
YAGNI. It can be added when something (an NPC system, a save-file list)
actually needs to display it.

`Shunt.Players` is the only module that touches `Shunt.Repo` or the
`Player` schema. The LiveView calls context functions exclusively.

**No lazy singleton:** the one player row is created explicitly by
`priv/repo/seeds.exs` calling `Shunt.Players.create_player!/0` once, not
by request-time "ensure it exists" logic. Lazily fetch-or-insert
("singleton") patterns are explicitly avoided — they reintroduce
process-singleton-style implicit global state and a check-then-insert
race even when backed by a plain DB row. `Shunt.Players.get_player!/0`
assumes the seeded row exists and simply fetches it; this is the seam
for future auth — when accounts exist, this function is replaced by
something keyed on `current_scope`, and `do_job/1` / `lay_low/1` are
unaffected since they already take a `%Player{}` struct as input.

## Context API

```elixir
Shunt.Players.create_player!/0  # -> %Player{} (called once, from seeds.exs)
Shunt.Players.get_player!/0     # -> %Player{}
Shunt.Players.do_job(%Player{}) # -> {:ok, %Player{}}
Shunt.Players.lay_low(%Player{}) # -> {:ok, %Player{}} | {:error, :insufficient_cred}
```

Placeholder balance (easy to retune later, not load-bearing design):

- **Do a Job**: `+15 Scrip, +5 Cred, +10 Heat`. Always available.
- **Lay Low**: `-10 Cred, -20 Heat`. Returns `{:error, :insufficient_cred}`
  if `cred < 10`; the LiveView also disables the button client-side as a
  UX nicety, but the context enforces the real guard.

Heat clamps to `[0, 100]`; Cred/Scrip clamp to a floor of `0`. Clamping
happens in the context function (plain `max/min` arithmetic on the
already-known increment), not via changeset validation, since these are
programmatic increments rather than user-submitted form data.

## LiveView / UI

Replaces the generated `/` route entirely: `ShuntWeb.DashboardLive`
replaces `PageController`'s `home.html.heex`. The generated welcome page
and `PageController` are removed.

Wireframe layout, stacked vertically, plain Tailwind utilities (no
custom design system exists yet):

```
+----------------------------------+
|  Cred: 5        Scrip: 15        |
|  Heat: [###-------] 10/100       |
+----------------------------------+
|  [ Do a Job ]      [ Lay Low ]   |
+----------------------------------+
```

DOM ids (for both visual targeting and test selectors):
`#resource-cred`, `#resource-scrip`, `#resource-heat`, `#do-job-button`,
`#lay-low-button`.

`mount/3` calls `get_player!/0` and assigns the struct.
`handle_event("do_job", _, socket)` and `handle_event("lay_low", _,
socket)` call the matching context function and re-assign the updated
player (or, for `lay_low`'s error case, no-op since the button is
disabled — the context guard is defense-in-depth, not surfaced as a
flash message this sprint).

## Testing

Kept intentionally light for this sprint — happy-path coverage proving
the loop works, not exhaustive edge cases (those can be added once real
balance/Heat-event work begins):

- `Shunt.PlayersTest`: `create_player!/0` creates a default player;
  `get_player!/0` returns the existing player; `do_job/1` increases
  cred/scrip/heat; `lay_low/1` decreases cred/heat.
- `ShuntWeb.DashboardLiveTest`: mount renders initial resource values;
  clicking `#do-job-button` updates the displayed values; clicking
  `#lay-low-button` updates the displayed values.

## Out of scope (future sprints)

- Fencing Mechanic replaces "Do a Job" with the real buy-low/sell-high
  loop (priority #2).
- Heat Event table fires real consequences at thresholds (priority #6).
- Auth/`phx.gen.auth` replaces the seeded-player seam once the
  player/save-state model is designed.
- Visual theming once a design system exists.
