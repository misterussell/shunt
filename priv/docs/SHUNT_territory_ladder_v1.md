# Territory Ladder — Design

> **Status:** Agreed design, ready for implementation planning.
> **Date:** 2026-06-30
> **Scope:** GDD Ladder 1 (Territory). First mechanic to give the player a persistent
> physical base — a "hideout" they upgrade and return to — and the project's first
> non-event-driven progression system.

---

## 1. Goal

Make Territory feel like a **physical place the player comes back to** — a hideout /
workshop / base of operations that grows as they spend cred and scrip. Each upgrade
grants a new mechanic, opportunity, or status. This is a brand-new progression axis:
today the only progression is event-driven narrative, rumors, and Ghostwork.

**Explicitly out of scope for v1:** wiring Territory into conditional events or NPCs.
That is deferred content built on this foundation.

---

## 2. Core model

Territory is a home upgraded along **two coupled paths**:

- **Premises (the shell)** — the base is a real, navigable home *location* with a
  **class** (1–5). Class sets the *ceiling* on which modules can run. You raise it by
  **relocating** to a better space — an occasional, gated milestone.
- **Modules (the guts)** — capabilities bought à la carte on the Hideout page. Modules
  are the primary climb. The **tier name is derived purely from which keystone modules
  you hold** (an ordinal `{tier, requirements}` rule, exactly like a District fact).

The dependency: **premises raises the ceiling → modules fill it → tier reads off the
modules.** A kitted-out small place can out-tier an empty big one. The only new
*persisted* state is "which modules are installed" + "current premises"; class and tier
are **derived** (derive-don't-store, matching `Shunt.District`).

### The ladder — human → infrastructure

The through-line is the GDD's own endpoint ("the player *is* infrastructure"): you start
as a person renting dead space and end as a piece of the city the grid routes through.
Early rungs are human roles; late rungs are infrastructure nouns from the lexicon.

Names are **provisional pending a Content Constitution pass** (see §9), but all are
infrastructure-first and lexicon-sourced.

| Tier | Status | Stratum / Premises anchor | Feel |
|----|----|----|----|
| 1 | **Squatter** | Underbelly — Shunt 9 corner *(exists)* | A claimed corner of dead space |
| 2 | **Tenant** | Underbelly — Shunt 9, a locked spot | You hold a fixed place |
| 3 | **Operator** | Underbelly — a safehouse | You *run* a place; first bleed income |
| 4 | **Fixture** | Underbelly ceiling | A permanent part of the block; people know where to find you |
| 5 | **Node** | Midgrid intake — Liftworks/Grayline foothold | A recognized point traffic routes through |
| 6 | **Junction** | Grayline | Multiple flows run through you |
| 7 | **Relay** | Grayline/Midgrid | You pass things along the line for others |
| 8 | **Hub** | Midgrid (established) | Flows concentrate at you |
| 9 | **Spine** | Midgrid → Spire-adjacent | Core infrastructure others depend on |
| 10 | **Grid** | Spire-adjacent | You *are* infrastructure; the city routes through you |

Premises are **coarse anchors** (~5 relocations across the 10 rungs); you climb most rungs
by installing modules, then relocate when you hit the class ceiling. Higher-stratum
relocations are gated by **more than scrip** — social standing / faction / knowledge, via
the Requirements engine — so Territory correlates with the Social Standing ladder without
duplicating it.

**v1 populates tiers 1–4** (real Shunt 9 premises + modules incl. the Latticework Bleed);
tiers 5–10's premises/modules drop in as those districts get built. They never derive
until authored, because `{:has_module, unauthored}` returns `false`.

---

## 3. Data model & engine extensions

### New player state (3 fields)

| Field | Type | Purpose |
|---|---|---|
| `premises_id` | `:string`, default `"shunt9_player_squat"` | Home base location — distinct from `location_id` (current location, which moves as you travel). Relocation sets this. |
| `modules` | `{:array, :string}`, default `[]` | Installed module keys. Append-only in v1 (you never uninstall a capability). |
| `last_collected` | `:utc_datetime`, default `nil` | Timestamp the income reservoir is computed from. `nil` until the first income module; set on collect. |

Premises *class* is **not** stored — read from the premises location's content. Tier is
**not** stored — derived from `modules`.

**Migration:** add the three columns to `players` with the defaults above.

### Requirements engine — 2 new checks

Both pure reads, fitting the existing `defp check/2` pattern in `Shunt.Requirements`:

- `{:has_module, key}` → `key in player.modules`
- `{:premises_at_least, class}` → class of `player.premises_id` ≥ `class`

### Effects engine — 1 new tuple

- `{:install_module, key}` → append-distinct into `:modules` (mirrors the existing
  `{:contact, …}` / `{:rumor, …}` handlers in `Shunt.Effects`).

Relocation and income-collect reuse the existing `{:set, field, value}` for `premises_id`
and `last_collected` — no new effect needed there.

### New context module `Shunt.Territory`

The domain owner. The LiveView never computes any of this (LiveView presentation
boundary).

- `premises(player)` / `premises_class(player)` — read the premises location content def.
- `tier(player)` → `{n, name}` — ordinal derivation modeled on `Shunt.District.derive`:
  rules ordered **deepest-first**, each self-contained on `{:has_module, …}` /
  `{:premises_at_least, …}`, first match wins, default Squatter.
- `available_modules(player)` / `available_relocations(player)` — catalog entries whose
  class + cred/scrip + Requirements are met and (for modules) not already owned.
- `install_module/2`, `relocate/2`, `collect/2` — pure resolvers returning
  `{:ok, effects}` / `{:error, reason}`, dispatched via `Players.dispatch`.
- Income helpers (`income_rate/1`, `reservoir_cap/1`, `reservoir/2`) — see §4.

### New content types (data-driven `.exs` drops)

- `:modules` (`priv/content/modules/*.exs`) — `key`, `name`, `description`,
  `cost: %{scrip:, cred:}`, gating `requirements` (incl. a `premises_class_min`), an
  `effect` spec (`:gate` flag-only, or `:income` with `rate` / `cap_hours` / trace), and
  optional in-world description hooks.
- **Premises data lives on the location content itself** — a location becomes a valid base
  by carrying a `:premises_class` and a `:relocation` block (cost + requirements). No
  separate content type; relocation targets are just locations flagged as premises.
- The **10-rung ladder** is one small def (`priv/content/territory/ladder.exs`): the
  ordinal `{tier, name, requirements}` list, ordered deepest-first.

Register the new sources in `Shunt.Content.Store`.

---

## 4. The Latticework Bleed & passive income

Income is **offline-earnings, computed on demand** — no scheduler, no ticking process.
An `:income` module declares a `rate` (scrip/hour) and `cap_hours`. The reservoir fills
off the wall clock and stops at the cap until collected.

### Derivation (pure functions in `Shunt.Territory`)

```
income_rate(player)      = Σ rate_i           over installed :income modules
reservoir_cap(player)    = Σ (rate_i × cap_hours_i)
elapsed_hours            = max(0, now − player.last_collected)   # clamps clock skew / nil
reservoir(player, now)   = min(income_rate × elapsed_hours, reservoir_cap) |> floor
```

With v1's single bleed module this reduces to `rate × min(elapsed, cap_hours)`. The `Σ`
form means future income modules just add rate + capacity with no rework.

### Collecting (the exposed moment)

Collect is an action on the Hideout page, dispatched as a pure resolver:

```elixir
def collect(player, now) do
  case reservoir(player, now) do
    0    -> {:error, :nothing_to_collect}
    take -> {:ok, [{:scrip, +take}, {:heat, +trace(take)}, {:set, :last_collected, now}]}
  end
end
```

- **`trace(take)`** scales Heat to the amount banked — the bleed runs quiet; cashing out
  is what gets traced through the Latticework. (Starter tuning: ~1 Heat per 30 scrip.)
- Because `{:heat, …}` routes through `Effects.apply → Heat.resolve`, a greedy collect
  that crosses a Heat threshold can **trip a Heat event mid-collect** — emergent risk,
  zero extra code. This is the tension that keeps income honest, satisfying the GDD's
  anti-idle stance alongside the reservoir cap.

### Time-source boundary

`now` is captured at the LiveView edge (`DateTime.utc_now()`) and **passed into** the
resolver, so `collect/2` and `reservoir/2` stay pure and unit-testable with a fixed `now`.

### Lifecycle

- Installing the (first) income module sets `last_collected = now`, starting accrual.
  Installing a *second* income module resets the shared timestamp — v1 has one bleed
  module, so we document "collect before installing another income module";
  banking-on-install is a trivial future add.
- Reservoir / `last_collected` **carry across relocation** — income comes from modules,
  not the shell. The collect action re-appears at the new base.
- `nil last_collected` ⇒ reservoir 0.

### Reservoir display

The Hideout page computes the reservoir at render-time (with `now`) and shows: current
take, rate, **% full / FULL**, and the **projected Heat the collect would cost** before
clicking. No live countdown in v1 (it'd need a periodic refresh); it updates on render and
after any action. A gentle auto-refresh is an easy later nicety.

### Starter content (v1 income module, all tunable)

| Module | rate | cap_hours | reservoir cap | trace |
|---|---|---|---|---|
| **Latticework Bleed** | 5 scrip/hr | 12 | 60 scrip | ~1 Heat / 30 scrip |

---

## 5. The Hideout page

A dedicated page (not a map POI) so it can grow into a real interior — floorplan,
inventory manager, visual module slots — beyond what the map/location pages allow.

- **Route & LiveView:** `live "/hideout", HideoutLive`, sibling to the map and the Web
  board, wrapped in `<Layouts.app …>`. It is the **interior** of the base; the map
  location is the **exterior**.
- **Entry — from the physical location:** when `location_id == premises_id`, the map
  location surfaces an **"Enter the Hideout"** link (`<.link navigate={~p"/hideout"}>`).
  The premises map location's short description can also shift with tier ("a dark squat" →
  "a powered, working unit"), so the exterior reflects progress while the interior is the
  page.
- **Access model (chosen): must be home to enter.** `/hideout` only works when
  `location_id == premises_id`; hitting the route from elsewhere redirects to the map.
  This makes collecting the bleed and managing upgrades a *reason to travel back* —
  reinforcing the "place you come back to" goal and adding one honest bit of friction to
  income collection.

### Page sections (top to bottom)

1. **Identity header** — premises name, derived **status/tier**, premises class,
   district/stratum. The "who am I now" readout.
2. **The Bleed** — income reservoir gauge (% full / FULL), current rate, **Collect
   Takings** button with the projected Heat cost shown before clicking. Flagship.
3. **Installed** — modules held, rendered as the place's "guts" (v1: simple list/grid;
   richer visuals land here later).
4. **Catalog** — purchasable modules gated by class + cred/scrip + Requirements.
   Affordable ones buyable; ones blocked by class show **locked/aspirational** ("Requires
   a bigger space — relocate"), so the player can see what's upstairs.
5. **Relocate** — available premises whose class exceeds current and whose requirements are
   met: cost, ceiling unlocked, and the gate. Unreachable higher rungs show as locked
   goals.

### Data flow

Mirrors `DashboardLive`: mount resolves `player_id`, `lookup_or_start`, subscribes to
`Signals`, assigns the player. `handle_event`s dispatch to the pure `Territory` resolvers
(`install_module/2`, `relocate/2`, `collect/2`) via `Players.dispatch`; `now` is captured
at the edge and passed in. Derived values (tier, reservoir, catalog availability) are
recomputed on render — **plain assigns, not streams** (the catalog is a small, fully
re-derived collection; streams are for large/growing ones).

All key elements carry DOM ids for tests (`#hideout-tier`, `#bleed-collect`,
`#module-catalog`, `#relocate-…`, etc.).

---

## 6. v1 scope & content

Engine ships complete (§§2–5). Content populates **tiers 1–4** in the Underbelly.

### v1 ladder keystones

| Tier | Status | Keystone requirement |
|---|---|---|
| 1 | Squatter | *(default — no module)* |
| 2 | Tenant | `{:has_module, "stash"}` |
| 3 | Operator | `{:has_module, "latticework_bleed"}` *(needs class ≥ 2)* |
| 4 | Fixture | `{:has_module, "drop_point"}` |

### v1 modules (`priv/content/modules/`)

| key | class min | cost (illustrative) | effect |
|---|---|---|---|
| `stash` | 1 | scrip | **gate** — Tenant keystone; secures the place (description shift) |
| `latticework_bleed` | 2 | scrip + cred | **income** — flagship mechanic (§4) |
| `drop_point` | 2 | scrip + cred | **gate** — Fixture keystone; a front people route through |

**Honest scoping note:** in v1 only the **bleed** delivers a new *mechanic*. `stash` and
`drop_point` are **status keystones** — their reward is raising the tier, shifting the
hideout's look/description, and unlocking the next module/relocation band; their downstream
payoffs (storage limits, front interactions) are deferred content, consistent with "don't
wire events/NPCs yet." The loop still closes: buy → tier rises → ceiling/identity changes →
next goal appears.

### v1 premises (data on location content, both in Shunt 9)

- `shunt9_player_squat` → add `premises_class: 1` *(exists; the start)*.
- **One new class-2 location** (a reclaimed Shunt 9 safehouse — provisional name pending
  the Constitution pass) with `premises_class: 2`, a `relocation: %{cost: …,
  requirements: […]}` block, and an exit wired into the Shunt 9 map graph so it's
  navigable.

This proves the one v1 relocation: Squatter/Tenant in the Squat → relocate → install the
Bleed → Operator → Fixture.

---

## 7. Testing strategy

- **`Shunt.Territory` pure unit tests** (no DB): tier derivation per `{modules, class}`
  combo; `available_modules` / `available_relocations` gating (class, cred/scrip,
  requirements); income math (`income_rate`, `reservoir_cap`, `reservoir` with a fixed
  `now`, clamping nil/negative elapsed); `collect/2` (take, scaled Heat, timestamp set,
  `:nothing_to_collect`); `install_module/2` & `relocate/2` (cost/class/requirement
  errors).
- **`Requirements`**: `{:has_module, …}` and `{:premises_at_least, …}` checks.
- **`Effects`**: `{:install_module, …}` append-distinct.
- **`Players.Server` integration**: dispatch install/relocate/collect persists the new
  fields; assert a **greedy collect that crosses a Heat threshold trips a Heat event** (the
  §4 spillover).
- **`HideoutLive`**: access gate (redirect when `location_id != premises_id`); renders
  tier/reservoir/catalog by DOM id; Collect updates scrip+heat; buy module; relocate;
  locked modules visible. Test via `element/2` / `has_element/2`, never raw HTML.
- **Content load**: `:modules` + the territory ladder def load into `Shunt.Content`;
  premises metadata reads off locations.
- **House rules**: content `:ets` tests run **sync** (they touch global tables); assert on
  **specific keys/elements, not exact catalog counts**.

---

## 8. Architecture fit

Everything lives inside established patterns:

- Pure resolvers → effects → `Players.dispatch` (the Action Resolver / Effect Engine
  layers).
- Declarative Requirements gating for module/premises/relocation availability.
- Derive-don't-store for class and tier (the `Shunt.District` ordinal-fact precedent).
- Content as `.exs` drops loaded into `Shunt.Content` ETS.
- A dedicated LiveView sibling to the existing map and Web-board pages.

The map gains exactly one thing — the "Enter the Hideout" link at the base. No existing
rendering path changes otherwise.

---

## 9. Follow-ups / deferred

- **Content Constitution pass** on the 10 tier-status names and the new premises name;
  add the recurring tier terms to `SHUNT_LEXICON.md` (Constitution Rule 5).
- Tiers 5–10 premises + modules, authored as their districts come online.
- Active-effect modules beyond income (Heat decay / safety, action discounts, storage
  caps) — each adds a seam into another system; deferred until the v1 loop is proven.
- Banking-the-reservoir-on-install when a second income module is added.
- Wiring Territory tier / `{:has_module, …}` into conditional events and NPCs.
- Optional live reservoir auto-refresh on the Hideout page.
