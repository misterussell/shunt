# SHUNT — Character Mode System (Laying Low v1)

## Objective

Implement the first iteration of a generalized **Character Mode System**, using **Laying Low**
as the initial production mode.

A "mode" is a temporary, player-chosen character state that layers an alternate interaction
loop over the existing game without a separate location, screen, or parallel gameplay
architecture. Future modes (hospitalized, incarcerated, on the run, …) should be a *content*
problem, not an architectural one.

Laying Low represents a player intentionally avoiding attention after generating excessive Heat:
high-risk activity gives way to a small loop of low-profile activities that advance time, bleed
Heat down, and occasionally trigger narrative interruptions.

> **Naming note:** the original version of this doc was written as an abstract spec before this
> audit. This revision grounds every concept in the real modules and records four scope decisions
> made with the project owner (see *Resolved Decisions*). Treat it as a design target, not a rigid
> spec — where the codebase offers a cleaner extension point than described here, prefer it.

---

# Codebase Grounding (audited 2026-07-09)

Confirmed against the current code before writing this revision — not assumed. Every abstract
concept in the sprint brief maps to something that already exists.

| Doc concept | Reality in the code |
|---|---|
| Player state store | `Shunt.Players.Server` — `lib/shunt/players/server.ex`. GenServer per player, started lazily by `Shunt.Players.lookup_or_start/1`. State is a `%Shunt.Players.Player{}` (`lib/shunt/players/player.ex`). |
| Mutation pipeline | `Shunt.Players.dispatch(player_id, resolver_fun)` (`lib/shunt/players.ex:32-36`). The resolver returns `{:ok, effects}` / `{:ok, effects, extra_meta}` / `{:error, reason}`. `Server.dispatch_effects/3` (`server.ex:36-47`) applies them via `Effects.apply/2` and persists with `Repo.update`. |
| Effect engine | `Shunt.Effects.apply(player, effects) :: {changes, meta}` (`lib/shunt/effects.ex:10-14`). One clause per effect tuple. New effect types are new clauses here, not a new module. |
| Effects vocabulary (existing) | `{:scrip,n}` `{:cred,n}` `{:heat,n}` `{:inventory,k,n}` `{:rumor,k}` `{:contact,k}` `{:knowledge,k}` `{:npc_loyalty,k,n}` `{:discover_location,k}` `{:set,field,value}` … — every Laying Low reward maps onto existing effects. |
| Heat | **Partially built.** `Shunt.Heat` (`lib/shunt/heat.ex`) has bands (`@low 30`, `@medium 60`, `@high 85`), `clamp/1`, and `resolve/2` which fires a random escalation event on an *upward* band crossing (`heat.ex:19-29`). Pool: `priv/content/heat_events/*.exs`, drawn by `Shunt.Heat.Catalog.events_for_band/1`. **There is no passive decay** — reduction is already purely action-driven, which matches this mode's philosophy. |
| Requirements gating | `Shunt.Requirements.met?/2` (`lib/shunt/requirements.ex:11-13`) is the *universal* filter — exits, POI events, NPCs, atmosphere tiers, lattice leads, district facts, modules all funnel through it. Predicate clauses are `check/2` (`requirements.ex:28-72`). |
| Action availability | Location-sourced. `Shunt.World` collects exits / POI-events / NPCs / repairables, each requirements-filtered, assembled in `movement_live.ex:317-324`. **There is no character-centric action source today** — every action comes from a location. |
| Events | `%Shunt.Events.Event{id, title, description, steps, requirements, on_complete, repeatable}` (`lib/shunt/events/event.ex`). Resolved by `Shunt.Events` (`start`/`current_step`/`choose`). Rewards live only in `on_complete` (choices carry no effects — content-integrity enforced). Events are **location-scoped**; the only global random-pool event system is Heat. |
| Content loading | `Shunt.Content.Store` (`lib/shunt/content/store.ex`) — `@sources` `{table, dir}` list → one ETS table each, at boot. Adding a content type is one line + `.exs` files. Read via `Shunt.Content.all/1` / `fetch!/2`. |
| Existing "Lay Low" | `Shunt.Players.lay_low/1` (`players.ex:46-52`) — a one-shot `{:cred, -10}, {:heat, -20}`, wired to a hub button (`hub_live.ex:36-40, 256-263`). This is the **seed** this mode absorbs and expands. |
| Territory / relocation | `Shunt.Territory.relocate/2` (`territory.ex:181-192`) already exists — an *upgrade-only* premises progression move. See *Resolved Decisions* #3. |
| Income reservoir (time) | `Shunt.Territory` accrues offline income as `rate * min((now - last_collected)/3600, cap_hours)` (`territory.ex:92-99, 127-128`). **This is the only time model in the codebase — there is no game clock, turn counter, or day/hour field.** See *Resolved Decisions* #1. |
| LiveView boundary | Presentation-only (AGENTS.md). Activities must be resolved by a context module that returns effects; the LiveView only dispatches and renders. |

---

# Resolved Decisions

Four scope decisions made with the project owner. They shape everything below.

### 1. "Advance time" maps onto the income reservoir

There is no game clock to advance. The only time model is the offline-income reservoir, whose
size is a function of `now - last_collected`. So an activity that "advances N hours" pushes
`last_collected` **backward** by N hours, which makes the reservoir accrue N more hours of income
(up to its cap) on the next collect. Downtime becomes economically real — laying low quietly
banks passive income.

This is a single new effect clause, mirroring how movement added `{:discover_location}`:

```elixir
{:advance_time, hours}
# last_collected = DateTime.add(player.last_collected, -hours * 3600)
```

`Shunt.Effects` stays mode-agnostic; only this one clause is added. Tuning notes:

- Accrual is **capped** at each income module's `cap_hours` — advancing past the cap yields no
  extra scrip (correct "you can't bank forever" semantics).
- A player with no income modules still passes time narratively but earns nothing.
- Guard `nil` `last_collected` (schema allows it) — treat as a no-op.

### 2. Character mode is a stored field + a requirements predicate

Add a single field to `Player` and a single predicate to `Shunt.Requirements`:

```elixir
# lib/shunt/players/player.ex
field :mode, :string, default: nil        # nil / "none" = normal; "laying_low" = the mode

# lib/shunt/requirements.ex — new check/2 clause
def check(%Player{mode: mode}, {:mode, m}), do: mode == to_string(m)
```

Because *every* content surface routes through `Requirements.met?/2`, this one predicate makes
the whole content graph mode-gateable with no changes to `World` or the LiveView. Store `mode`
as a bounded string; **never** `String.to_atom/1` on input (AGENTS.md). Entering/leaving the mode
is a `{:set, :mode, "laying_low"}` / `{:set, :mode, nil}` effect — no new effect type needed.

### 3. Relocate Safehouse is cut from v1

The brief's "Relocate Safehouse" collides with the existing `Shunt.Territory.relocate/2`, which
is an upgrade-only progression move (relocate *up* a premises class, gated + paid). A
heat-shedding "ditch the compromised safehouse" verb is a different concept and would conflate
progression with hiding. **Deferred:** ship the mode without it; revisit once the framework is
proven and the two relocation semantics can be designed together.

### 4. UI surface stays an open question (see below)

Where the activity loop renders is deliberately *not* resolved here — see *UI Surface*.

---

# Architecture

Laying Low introduces **one new context module and two small engine extensions**, and reuses
everything else.

```
Player clicks an activity (Rest / Gather Rumors / …)
        │
        ▼
Players.dispatch(player_id, &Shunt.LayingLow.rest/1)      # same path as every other action
        │
        ▼
Shunt.LayingLow.rest(player) -> {:ok, effects, meta}      # pure resolver, returns effects
        │
        ▼
Shunt.Effects.apply/2  ->  Players.Server persists  ->  LiveView re-renders
```

### New: `Shunt.LayingLow` (context module)

Follows the `Shunt.Movement` / `Shunt.Fencing` convention — `can_x?/1` + `x/1` pairs taking a
`%Player{}`, returning `{:ok, effects}` / `{:ok, effects, meta}` / `{:error, reason}`. Owns:

- **Enter / leave** — `enter/1` (gated on excessive heat) sets `{:set, :mode, "laying_low"}`;
  `leave/1` sets `{:set, :mode, nil}`. Absorbs the existing `Players.lay_low/1` seed.
- **Activity resolvers** — `rest/1`, `gather_rumors/1`, `visit_contact/2`, `train/1`,
  `burn_evidence/1` (see *Activities*).
- **Event draw** — `roll_event/1`, mirroring `Heat.resolve` + `Heat.Catalog.events_for_band/1`:
  draw a random event from the interruption pool with some probability on each activity.

### Extension 1: `Shunt.Effects` — one clause

Add `{:advance_time, hours}` (Resolved Decision #1). Nothing else in Effects changes.

### Extension 2: `Shunt.Requirements` — one clause

Add `{:mode, m}` (Resolved Decision #2). This is the whole mode-awareness hook.

### Entry / exit

- **Entry gate** — `can_enter?/1`: heat at or above a band (the brief's "excessive Heat" — start
  at `:medium`/60, treat as tuning). Replaces the current `cred >= 10` gate on the hub button.
- **Exit** — player-driven `leave/1`, plus optional auto-resurface when heat reaches band
  `:none` (tuning). Left as content/balancing, not hardcoded.

### On *restricting* high-risk activity

The brief says high-risk activities should be restricted while hiding. Restricting *existing*
actions is the invasive inverse of gating — it would mean annotating every risky content file
with `{:mode_not, ...}`. For v1, keep this **minimal**: present the mode's own activity loop as
the primary surface rather than annotating the whole game. Full per-action restriction is a
stretch goal (a `{:mode_not, m}` predicate + selective tagging), not v1 scope.

---

# Activities

A key architecture constraint: rewards like rumors, contacts, and skills are granted by **event
`on_complete`**, not by ad-hoc random rolls inside a resolver (content-integrity tests enforce
this, and it keeps content data-driven). So each activity is:

> **a deterministic baseline** (`{:advance_time, h}` + `{:heat, -n}` + narrative) **plus, for the
> richer activities, a draw from a themed event pool** whose `on_complete` grants the payoff.

| Activity | Baseline effects | Themed event pool |
|---|---|---|
| **Rest** | `{:advance_time, 6}`, `{:heat, -5}` | none — narrative flavor only |
| **Gather Rumors** | `{:advance_time, 4}`, `{:heat, -3}` | rumor / contact / world-info events (`{:rumor,k}`, `{:contact,k}`, `{:knowledge,k}` via `on_complete`) |
| **Visit Contact** | `{:advance_time, 6}`, `{:heat, -5}` | NPC relationship events (`{:npc_loyalty,k,n}`, favors, services) |
| **Train** | `{:advance_time, 8}`, `{:heat, -2}` | practice / skill events |
| **Burn Evidence** | `{:advance_time, 4}`, `{:heat, -15}` + a resource cost (`{:scrip,-n}` or item) | consequence hooks (future narrative fallout) |
| ~~Relocate Safehouse~~ | — | **cut from v1** (Resolved Decision #3) |

Values are starting tuning parameters, not fixed requirements.

**Skill progression (Train):** skill tiers are integers set via `{:set, :ghostwork_tier, n}` —
there is no increment effect today. For v1, keep Train thin (time + heat + a practice event, or
narrative-only) and defer a proper `{:skill_tier, family, +1}` effect unless a themed event needs
it. Flag, don't silently invent.

### Interruption pool (global draw)

Independent of the themed pools, any activity can be interrupted by a random draw from a
Laying-Low interruption pool — mirroring exactly how `Heat.resolve` draws from a band pool:

- Witness Recognizes You
- Police Inquiry
- Old Associate Arrives
- Rival Tracks Safehouse

These are ordinary `%Shunt.Events.Event{}` files, tagged for the pool (either a dedicated
`priv/content/events/laying_low/` dir, or a `pool: :laying_low` field + `{:mode, :laying_low}`
requirement). `Shunt.LayingLow.roll_event/1` selects from them; the LiveView surfaces the drawn
event through the normal `Shunt.Events` step/choice flow. Making future modes contribute their own
pool is then a content-only change.

---

# UI Surface (open question)

Where the activity loop renders is unresolved. Two viable options:

**A. Dedicated mode panel (recommended, not decided).** A distinct Laying Low view/panel showing
the activity list while `mode == "laying_low"`, available regardless of location (truly
character-centric per the brief). Absorbs the current hub Lay Low button. Cost: a new LiveView
surface.

**B. Extra action group in the current location view.** Activities appear as an additional button
group in `movement_live` alongside Infrastructure / Points of Interest / People Here. Less new UI,
but ties a character-centric loop to a location screen, slightly against the brief's framing.

Either way, the LiveView stays presentation-only: it dispatches `&Shunt.LayingLow.<activity>/1`
and renders the returned `%Player{}` + `meta` (narrative, deltas). No game logic in the view.

---

# Phased Deliverables

## Phase 1 — Mode framework + engine extensions (no new UI)

- Migration: `mode` (string, nullable) on `players` (precedent: `add_npc_loyalty_to_players`).
- `Shunt.Effects`: `{:advance_time, hours}` clause (guard `nil` `last_collected`).
- `Shunt.Requirements`: `{:mode, m}` clause.
- `Shunt.LayingLow`: `can_enter?/1`, `enter/1`, `leave/1`. Absorb `Players.lay_low/1`.
- Tests: effect moves `last_collected` correctly (incl. cap + nil), `{:mode, m}` gating,
  enter/leave round-trip, enter gate on heat band.
- **Verify:** dispatch `enter/1` at high heat → `mode == "laying_low"`; a `{:advance_time, 6}`
  effect increases the reservoir read at a fixed `now`.

## Phase 2 — Activity loop + LiveView surface

- `Shunt.LayingLow`: `rest/1`, `gather_rumors/1`, `visit_contact/2`, `train/1`, `burn_evidence/1`
  (baseline effects; themed-event draw stubbed).
- LiveView surface (Option A or B once decided) dispatching the activities; render narrative +
  heat/time feedback.
- Tests: each resolver returns the expected baseline effects; LiveView renders the activity
  buttons by their DOM ids while in the mode and hides them otherwise.

## Phase 3 — Event pools

- Interruption pool content (`priv/content/events/laying_low/`) + `Shunt.LayingLow.roll_event/1`
  (random draw, `Heat.Catalog`-style), surfaced through `Shunt.Events`.
- Themed event pools for Gather Rumors / Visit Contact / Train, rewards via `on_complete`.
- Register any new content type in `Shunt.Content.Store.@sources`. Content-integrity: every
  `{:knows}`/`{:has_item}`/`{:contact_known}` in an event's `requirements` has a matching grant.

## Phase 4 — Polish / stretch

- Auto-resurface at heat band `:none`; heat/time UI feedback and mode indicator.
- **Stretch (explicitly deferred):** `{:mode_not, m}` restriction of existing high-risk actions;
  a `{:skill_tier, family, +1}` effect for Train; the cut Relocate-Safehouse verb.

Content voice for all activity/event text follows the five content docs + `SHUNT_STORY_CANON.md`.
Run `mix precommit` green (Credo + format + tests) before finishing (AGENTS.md).

---

# Success Criteria

A player at high Heat can enter Laying Low, run a loop of low-profile activities that advance time
(banking reservoir income), steadily reduce Heat, and occasionally hit narrative interruptions —
all flowing through the same `Players.dispatch → Effects.apply` path every other action uses. The
framework is reusable: a second mode is a new `Shunt.<Mode>` context + content, with no changes to
`Effects`, `Requirements`, `World`, or the content loader beyond what Laying Low already added.
