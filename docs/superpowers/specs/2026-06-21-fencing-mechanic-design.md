# Shunt — Fencing Mechanic Design

Date: 2026-06-21

## Context

This is the second game-feature sprint, per `priv/docs/gdd.md` Initial
Development Priority #2: "The player's initial action: receive a goods
offer, decide whether to take it, move it to a buyer. Establishes the
buy-low/sell-high loop and introduces Heat as a consequence of activity
volume."

The Core Resource Loop sprint (see
`docs/superpowers/specs/2026-06-21-core-resource-loop-design.md`) wired up
Cred/Scrip/Heat with one placeholder generation action, "Do a Job," and
explicitly called it out as a stand-in for this mechanic. This sprint
replaces it with the real thing.

## Goals

- Replace "Do a Job" with a real buy-low/sell-high loop: receive an offer,
  decide to take it or pass, and — if taken — sell it to a buyer.
- Give the take/pass decision real stakes by varying margin and Heat cost
  across a small catalog of goods, instead of one flat action.
- Ground every offer and sale in Kaspav's setting (factions, strata,
  underworld figures from the GDD) so the very first session reads like
  the world, not a placeholder.
- Keep Cred usable: selling nets a small Cred trickle (reputation for
  being a reliable fence), so Lay Low isn't a one-shot button once "Do a
  Job" is gone.

## Non-goals

- Multiple held items / inventory. One item at a time — the player must
  resolve (sell) a held item before a new offer can surface. No inventory
  schema this sprint.
- Randomness in outcomes. Margins and Heat costs are fixed per item;
  there's no chance of a deal going bad. That risk/randomness layer
  belongs to the Heat Event Table (GDD priority #6), not here.
- Real NPCs. Buyers in sell flavor text are archetypal ("a Graftsman's
  apprentice," "a Latticework Collective courier"), not named individuals
  with loyalty tracking — that's the NPC System (GDD priority #4).
- Skill-gated items or crafting. All catalog items are Raw goods sourced
  externally; Street Alchemy / crafting integration is priority #5.
- Visual theming beyond what the dashboard already uses (plain Tailwind
  utilities, consistent with the existing wireframe).

## Goods catalog

A static, hardcoded catalog — not Ecto-backed, since nothing here needs
runtime CRUD. Three tiers create real stakes for the take/pass decision:
thin, safe margins at the low end; fat, hot margins at the high end.

| Tier | Item | Buy (Scrip) | Sell (Scrip) | Heat | Cred |
|------|------|------|------|------|------|
| Clean | Scrap Dermal Plating | 10 | 18 | 5 | 1 |
| Clean | Bootleg Credchip Stack | 15 | 25 | 6 | 1 |
| Warm | Grey-Market Neural Patch | 25 | 45 | 12 | 2 |
| Warm | Cracked Latticework Relay Key | 30 | 55 | 15 | 3 |
| Hot | Stolen Corp Biomod Prototype | 55 | 110 | 28 | 4 |
| Hot | Burned Netrunner's Memory Core | 65 | 130 | 32 | 5 |

Flavor text, shown on offer and again on sale:

- **Scrap Dermal Plating** — *Offer:* "A ganger's leftovers — dented
  plating still tacky with someone else's blood." *Sale:* "A patcher in a
  stall off the main concourse barely looks up before paying."
- **Bootleg Credchip Stack** — *Offer:* "Counterfeit chips, good enough
  to fool a distracted register — for a while." *Sale:* "A till-runner
  takes the stack without counting it twice."
- **Grey-Market Neural Patch** — *Offer:* "An unlicensed reflex patch,
  still warm from whoever wore it last." *Sale:* "A Graftsman's
  apprentice pays cash, no questions, no receipt."
- **Cracked Latticework Relay Key** — *Offer:* "A stolen access token.
  Somewhere uptown, it's still pinging for a body that isn't yours."
  *Sale:* "A Latticework Collective courier pays fast and leaves faster."
- **Stolen Corp Biomod Prototype** — *Offer:* "Sealed casing, corp
  serials filed off. Whoever lost this is already looking for it."
  *Sale:* "A Chrome & Meat broker doesn't ask where it came from — just
  whether it's clean."
- **Burned Netrunner's Memory Core** — *Offer:* "Salvaged off a netrunner
  who flatlined mid-run. Still humming with whatever fried them." *Sale:*
  "A Fleshless acolyte trades scrip for it like it's a relic."

`Shunt.Fencing.Catalog`:

```elixir
items/0       # -> list of item maps, each with:
              #    :key, :name, :tier, :buy_cost, :sell_value,
              #    :heat_cost, :cred_gain, :offer_text, :sell_text
fetch!/1      # -> item map by :key, raises on miss (internal invariant —
              #    keys only ever come from this module's own data or
              #    values it previously wrote to the player row, never
              #    from user input)
```

Keys are plain strings (e.g. `"scrap_dermal_plating"`), not atoms — there
is no need to convert user-facing data to atoms, and storing/comparing
strings end-to-end avoids that question entirely.

## Data model

Two new nullable columns on `players`:

| Field | Type | Notes |
|-------|------|-------|
| `current_offer_key` | `:string` | catalog item key, or `nil` |
| `held_item_key` | `:string` | catalog item key, or `nil` |

These two fields are mutually exclusive in practice and define the loop's
three states:

| State | `current_offer_key` | `held_item_key` | Valid action |
|-------|---|---|---|
| Idle | `nil` | `nil` | Find a Lead |
| Offer pending | item key | `nil` | Take It / Pass |
| Holding | `nil` | item key | Move It |

Persisting both fields on the player row (rather than holding them only
in LiveView assigns) matters once money has changed hands: after `take_offer/1`
spends Scrip, that commitment must survive a page refresh/reconnect, the
same way Cred/Scrip/Heat already do.

## Context API

`Shunt.Fencing`, alongside `Shunt.Players` (same pattern: plain functions
taking and returning a `%Player{}`, each enforcing its own precondition as
defense-in-depth even though the UI only ever exposes the one valid
action per state):

```elixir
find_lead(%Player{})
# idle -> offer pending. Picks a random catalog item, sets current_offer_key.
# {:ok, %Player{}} | {:error, :offer_in_progress}

take_offer(%Player{})
# offer pending -> holding. Deducts buy_cost from scrip, moves the key
# from current_offer_key to held_item_key.
# {:ok, %Player{}} | {:error, :insufficient_scrip} | {:error, :no_offer}

pass_offer(%Player{})
# offer pending -> idle. Clears current_offer_key, no cost.
# {:ok, %Player{}} | {:error, :no_offer}

sell_held_item(%Player{})
# holding -> idle. Adds sell_value to scrip, cred_gain to cred, clamps
# heat_cost into heat. Clears held_item_key.
# {:ok, %Player{}} | {:error, :no_held_item}
```

`do_job/1` and its `@job_*` module attributes are deleted from
`Shunt.Players` entirely — "Do a Job" no longer exists in any form.
`lay_low/1` is untouched.

## LiveView / UI

`ShuntWeb.DashboardLive` drops the "Do a Job" button and handler, and adds
a fencing panel with three mutually-exclusive states:

**Idle:**
```
+----------------------------------+
|  [ Find a Lead ]                 |
+----------------------------------+
```

**Offer pending:**
```
+----------------------------------+
|  Cracked Latticework Relay Key   |
|  [Warm]                          |
|  "A stolen access token..."      |
|  Buy: 30 Scrip                   |
|  [ Take It ]      [ Pass ]       |
+----------------------------------+
```

**Holding:**
```
+----------------------------------+
|  Cracked Latticework Relay Key   |
|  "A Latticework Collective..."   |
|  Sell: 55 Scrip · +15 Heat       |
|  [ Move It ]                     |
+----------------------------------+
```

`Take It` is disabled client-side when `scrip < buy_cost` (mirrors the
existing `lay_low` disabled-button pattern — the context guard is the
real enforcement). Tier badges use the same plain-Tailwind-utility
approach already established (e.g. `bg-green-100`/`bg-yellow-100`/
`bg-red-100` for Clean/Warm/Hot) — no new design system.

DOM ids: `#find-lead-button`, `#current-offer`, `#take-offer-button`,
`#pass-offer-button`, `#held-item`, `#sell-item-button`.

`handle_event/3` clauses: `"find_lead"`, `"take_offer"`, `"pass_offer"`,
`"sell_item"` — each calls the matching `Shunt.Fencing` function and
re-assigns the updated player, mirroring the existing `do_job`/`lay_low`
handler style.

## Testing

- `Shunt.FencingTest`: exercises the context functions directly.
  `find_lead/1` is asserted only to set `current_offer_key` to a key
  present in `Catalog.items/0` (its choice is random, so no stronger
  claim is made). `take_offer/1`, `pass_offer/1`, and `sell_held_item/1`
  are tested by first setting a known catalog key as fixture state
  (rather than depending on `find_lead`'s randomness), so exact
  scrip/cred/heat arithmetic can be asserted precisely. Error branches
  (`:insufficient_scrip`, `:no_offer`, `:no_held_item`, `:offer_in_progress`)
  each get a case.
- `ShuntWeb.DashboardLiveTest`: extends the existing dashboard test to
  cover state transitions structurally — `#find-lead-button` triggers
  `#current-offer` to appear with `#take-offer-button`/`#pass-offer-button`;
  taking replaces it with `#held-item`/`#sell-item-button`; selling
  returns to the idle state. One full find → take → sell happy path
  confirms the resource displays update. Kept light, matching the prior
  sprint's testing scope — not exhaustive edge cases.

## Out of scope (future sprints)

- Heat Event Table (priority #6) layers consequences on top of the Heat
  this loop generates.
- NPC System (priority #4) replaces archetypal buyer flavor text with
  real named NPCs with loyalty tracking.
- Crafting (priority #5) introduces Assembled goods, which may eventually
  feed into or replace parts of this catalog.
- Multi-item holding/inventory, if ever needed, is a deliberate expansion
  of the one-item-at-a-time model chosen here.
