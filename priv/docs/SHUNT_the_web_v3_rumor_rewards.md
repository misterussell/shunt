# Shunt Feature: The Web v3 — Rumor Rewards & the Crack Reveal

## Status

**Design.** Extends `SHUNT_the_web_v2.md` (the rumor board / investigation layer). Not yet
implemented. This document is the agreed design; author it into inline TODOs (project
`todo-staging` skill) before building.

---

## Goal

Today, cracking a case pays out whatever its success event's `on_complete` happens to list —
and that payout is invisible and inconsistent. Several cases grant nothing but a lone
`{:knowledge, flag}`; only `supplier_conspiracy` pays a rich, multi-category reward.

v3 makes **completing every case impactful and legible.** Every `RumorConnection` a player
cracks should offer one or more of six reward categories, and the moment of cracking should
surface those rewards in a reveal that makes the impact *felt*:

1. A new NPC
2. A new map location
3. Equipment or a blueprint for Chrome & Meat or Street Alchemy
4. A new program for Ghostwork
5. A scrip payload
6. A new, cross-area rumor connection (a thread opening in another district)

This is **not** a new subsystem. It reuses the existing event → `on_complete` → `Effects.apply`
reward pipeline throughout. The only genuinely new engine surface is a pure formatter that turns
already-applied effects into player-facing reward descriptors, plus the reveal panel that renders
them.

---

## Design Philosophy

```text
RumorConnection cracked (Web.pursue/3, :crack)
      ↓
success_event.on_complete  (unchanged — the single source of truth for what you get)
      ↓
Effects.apply              (unchanged — grants scrip, location, blueprint, program, rumor…)
      ↓
Web.Rewards.describe/1     (NEW — pure: effects → typed reward descriptors)
      ↓
"SIGNAL CRACKED" reveal panel in WebLive  (NEW — renders the descriptors)
```

The reward stays authored in one place: the success event's `on_complete`. Nothing is
duplicated into a separate manifest. The reveal is *derived* from the effects that were applied,
so preview and payout can never drift.

### Reveal, not preview

The payoff lands **after** the crack, not before it.

- **Pre-crack:** the board is unchanged. A case shows only its cost (`[ CRACK · +N HEAT ]`). The
  rewards are hidden — the case stays a mystery, and committing to it is a leap.
- **Post-crack:** a reveal panel enumerates what you just unlocked, itemized by type. The
  surprise is already spent, so the reveal names the actual unlocks (the contact, the district,
  the blueprint) rather than teasing them.

This is a deliberate inversion of a "shop preview" model. Investigation should feel like pulling
a thread and *discovering* where it leads, not shopping from a menu of known payouts.

---

## What Already Exists (No Changes Needed)

The reward rail is fully built. Every category already maps to a working effect tuple applied
through `Shunt.Effects.apply/2`:

| # | Reward | Existing effect(s) |
|---|---|---|
| 1 | New NPC | Grant a `{:knowledge, flag}` / `{:rumor, id}`; gate the target `world_npc`'s location entry on it via `World.available_npcs/2`'s `%{id:, requirements:}` form. (The v1 `{:contact, key}` ledger is a separate, lighter "you know this person" record.) |
| 2 | New map location | `{:discover_location, key}` |
| 3 | Chrome/Meat or Street Alchemy gear/blueprint | `{:install_implant, key}`, `{:inventory, item_or_raw, n}`, `{:knowledge, "schematic_x"}` (blueprints are `{:knows, ...}` recipe/fabrication gates) |
| 4 | Ghostwork program | `{:inventory, program_key, 1}` — programs are inventory items |
| 5 | Scrip payload | `{:scrip, n}` |
| 6 | Cross-area rumor connection | `{:rumor, seed_id}` — granting a seed rumor makes that district's case appear in `Web.network/1` (a connection surfaces once the player holds ≥ 1 of its rumors) |

`supplier_conspiracy_success` already demonstrates the ideal: `{:discover_location, ...}` +
`{:contact, ...}` + `{:rumor, ...}` + `{:scrip, 200}` in one `on_complete`.

So the mechanical claim "a crack can grant any of the six" is **already true**. v3 adds only
*visibility* and *consistent coverage* on top of it — no new effect types, no migration.

---

## The Gaps v3 Closes

**Gap A — the payoff is invisible.** `WebLive` renders the crack *cost* but has no way to read or
show the *reward*; the `on_complete` list is opaque, buried in an event `.exs` file. Cracking a
case produces a flash and the event's prose, but never a clear "here is what you unlocked."

**Gap B — coverage is inconsistent.** Auditing the seven current success events:

| Connection | Current `on_complete` payout | Categories hit |
|---|---|---|
| `supplier_conspiracy` | location + contact + rumor + 200 scrip | 1, 2, 5, 6 ✅ |
| `market_squeeze` | 60 scrip + knowledge + 2× loyalty | 5 (+ soft) |
| `windlass_sabotage` | knowledge + 40 scrip + 5 cred + loyalty | 5 (+ soft) |
| `grayline_court` | 2× knowledge + 120 scrip | 5 |
| `liftworks_clean_names` | contact + knowledge + 150 scrip | 1, 5 |
| `winnow_tier_above` | **1× knowledge flag only** | none of the six |
| `bloom_ascent` | **1× knowledge flag only** | none of the six |

`winnow` and `bloom_ascent` are the weakest — a lone gating flag with no felt reward. Every case
needs a deliberate reward pass so each offers ≥ 1 category worth revealing.

**Gap C — two categories read poorly without help:**

- A bare `{:knowledge, flag}` that merely *gates* an NPC or location is invisible to the player —
  it needs to be tagged so the formatter can render it as "intel" / "blueprint" / a named unlock.
- The cross-area reward (#6) is implicit: `{:rumor, seed}` surfaces a new case, but nothing marks
  it as "a thread opening in another district," so the reveal can't distinguish it from an
  ordinary lead.

---

## New Engine Surface (small, localized)

### `Shunt.Web.Rewards` — pure formatter

```elixir
Shunt.Web.Rewards.describe(on_complete_effects) :: [reward_descriptor]
```

A pure function. Given a success event's `on_complete` list, it returns typed, display-ready
reward descriptors, dropping bookkeeping effects (`{:npc_progression, ...}`,
`{:set, ...}`, loyalty, cred, heat side-effects) that aren't part of the six categories.

```elixir
%{type: :scrip,      amount: 200}
%{type: :location,   id: "shunt9_freight_tunnel", name: "Freight Tunnel"}
%{type: :npc,        id: "dex_broker",             name: "Dex"}
%{type: :blueprint,  id: "schematic_lineman_graft", name: "Lineman's Graft", skill: :chrome_meat}
%{type: :program,    id: "decrypt_program",        name: "Decrypt"}
%{type: :connection, id: "liftworks_clean_names",  district: "Liftworks"}
```

Effect → descriptor mapping:

| Effect | Descriptor |
|---|---|
| `{:scrip, n}` | `:scrip` |
| `{:discover_location, id}` | `:location` (name via `World.get_location/1`) |
| `{:contact, id}` **or** an NPC-reveal flag (see below) | `:npc` |
| `{:knowledge, "schematic_*"}` / tagged blueprint | `:blueprint` |
| `{:inventory, id, n}` where `id` is a `:programs` entry | `:program` |
| `{:inventory, id, n}` where `id` is an implant/chrome raw | `:blueprint`/`gear` (category 3) |
| `{:rumor, id}` seeding a cross-area connection | `:connection` |
| everything else | dropped from the reveal |

### The reward-tag lookup (keeps "derive from effects" honest)

Two effects are ambiguous on their own:

- **NPC reveal:** a `{:knowledge, flag}` used only to gate a `world_npc`. The formatter can't know
  that from the effect alone.
- **Cross-area connection:** a `{:rumor, seed}` that opens a case in another district vs. an
  ordinary lead.

Resolve this **in content, not with special-case code**, via lightweight conventions the
formatter reads:

- Blueprints already follow the `schematic_*` naming convention (per `SHUNT_chrome_and_meat_v1.md`)
  — the formatter keys off the prefix.
- Programs are resolved by membership in the `:programs` content table (an existing lookup).
- For NPC-reveal flags and cross-area seed rumors, add a small, data-driven **reward hint** the
  authoring already implies: the descriptor's display name is looked up from the target content
  (the `world_npc`'s `name`, the connection's home district). If a case wants to reveal an NPC,
  it grants the flag *and* the reveal is named by the `world_npc` whose `requirements` reference
  that flag. (Implementation detail to settle during staging: either a reverse index from
  gating-flag → `world_npc`, or an explicit `reveals:` hint list on the success event read only by
  the formatter. Prefer the reverse index so there's still one source of truth.)

No new effect types. No player-schema change. No migration.

### `WebLive` — the reveal panel

`Web.pursue/3` already returns `{:ok, effects, %{event_id: id}}` and dispatches through
`Players.dispatch/2`. After a successful `:crack`:

1. Fetch the success event, run `Web.Rewards.describe(event.on_complete)`.
2. Assign the descriptors to a transient `:reveal` socket assign.
3. Render a "SIGNAL CRACKED" panel — one row per descriptor, typed icon + name — dismissible.

Presentation boundary holds: `WebLive` renders descriptors the context handed it and does no
domain reasoning (no diffing before/after player state). The formatter is a context function; the
LiveView only displays its output.

---

## Content Work

### 1. Reward pass over the seven existing success events

Bring each `on_complete` up to offer ≥ 1 of the six categories, honoring district canon. The two
priorities are `winnow_case_success` and `bloom_ascent_success` (currently a lone flag). Author
per the relevant district docs and `SHUNT_STORY_CANON.md` — a reward must not contradict the
Spire continuity contract or the Bloom/Winnow forward hooks. All pure content edits.

### 2. Cross-area connections (reward #6, reference pattern)

Author 1–2 new `RumorConnection`s whose success seeds a rumor for a case in **another** district
(e.g. cracking a Shunt 9 thread opens a Liftworks thread). This is the canonical way to deliver
category 6 and is what wires the districts' investigation layers together.

### 3. NPC reveals

Where a case rewards a new NPC, grant a gating flag and add the `%{id:, requirements: [...]}`
form to the target `world_npc`'s location `:npcs` entry (existing `World.available_npcs/2`
support). No new effect.

---

## What This Deliberately Does *Not* Add

- **No pre-crack preview.** Rewards stay hidden until the crack (see *Reveal, not preview*).
- **No authored `rewards:` manifest** on connections/events — the reveal derives from
  `on_complete`, so there is nothing to keep in sync.
- **No new effect tuple** and **no migration.** NPC reveals reuse knowledge-gating; every other
  category already has an effect.
- **No changes to the resolver, `Effects`, or `Requirements`.**

---

## Build Order (for staging)

1. `Shunt.Web.Rewards.describe/1` + the reward-tag/reverse-index lookup. Unit tests: each effect
   shape → expected descriptor; bookkeeping effects dropped.
2. `WebLive` reveal panel, wired against `supplier_conspiracy` (already pays richly) so the
   mechanic is visible end-to-end first. LiveView test against the panel's element id.
3. Reward pass over the remaining six success events (content), `winnow` and `bloom_ascent`
   first. Read `SHUNT_STORY_CANON.md` before authoring the Bloom/Winnow rewards.
4. 1–2 cross-area connections as the category-6 reference pattern.
5. `mix precommit` green; the existing content-integrity test (every `{:knows}` gate has a
   matching grant) still passes for any new schematic/knowledge rewards.

---

## Open Questions / Follow-ups

- **Reveal fidelity:** current design names unlocks in the reveal (the surprise is spent by then).
  If reveals should stay type-only (icons, not names), that's a one-line change in the panel.
- **NPC-reveal resolution:** reverse index (gating-flag → `world_npc`) vs. an explicit
  formatter-only `reveals:` hint — settle during staging; reverse index preferred to keep a single
  source of truth.
- **Lexicon:** register any new recurring terms (new NPCs, blueprints, the "SIGNAL CRACKED"
  reveal label) in `SHUNT_LEXICON.md` per Constitution Rule 5.
