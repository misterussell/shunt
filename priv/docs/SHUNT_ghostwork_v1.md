# Shunt Feature: Ghostwork (Latticework Hacking) — v1

## Goal

Ghostwork is one of Shunt's primary player skills: interfacing with the
**Latticework** through the player's **Ghostdeck**, from skimming stray feeds to
cracking the ICE around valuable digital assets.

Like The Web, Ghostwork is a **data-driven layer over the existing Event, NPC,
World, and Effects systems** — *plus one genuinely new mechanic*: the ICE-breaking
push-your-luck encounter. It introduces no separate quest engine.

The player fantasy:

> Jack your deck into the Latticework from wherever you're standing, scan for
> signals, crack the ICE protecting hidden data, and learn the shape of every
> system you breach — so the next break is sharper than the last.

---

# Design Philosophy

## One new mechanic, everything else reused

Ghostwork is **three loops, but only one new system.** Two of the three loops are
existing systems wearing a Latticework skin:

| Loop | What it actually is |
|------|---------------------|
| **Signal Hunting** | A `Scan` action — structurally `Crafting.scavenge/1`, but it emits *effects* (reveal a node/location/NPC, grant knowledge, drop scrip) instead of a raw. |
| **ICE Breaking** | **The one new mechanic.** A layered, press-your-luck encounter. No existing primitive does risk-accumulation, so this is where the real new code lives. |
| **AI Encounters** | A **world NPC** (`%Shunt.World.NPC{}`) revealed by a cracked node. `story_arcs` + `npc_loyalty` + Event choices already give Bargain / Lie / Threaten / Destroy with persistent consequences. **Zero new code.** |

This mirrors how The Web was built — new effect types, new requirement *reuse*, a
small player ledger — without a new engine. Resist building three frameworks.

## The deck is the interaction surface (physical vs digital)

The game has two worlds: the **physical** city the player's body moves through
(the map / `MovementLive`) and the **digital Latticework** they reach through the
deck. Ghostwork must keep these distinct:

* **The physical map stays clean.** Scans, nodes, and AI contacts are **never**
  listed as map Points of Interest. The only Ghostwork presence on the map is a
  single ambient cue on the current-location panel — `⌁ LATTICE` — shown when the
  location carries lattice traffic *and* the player holds a deck. One glyph, not a
  growing list.
* **The GHOSTWORK tab *is* the deck.** Switching to `/skills/ghostwork` is
  "jacking in." The page renders all ghostwork interactions **filtered by the
  player's current `location_id`**: what your deck can see depends on where your
  body is. Move on the map, and the deck sees a different slice of the Lattice.
* **The ICE encounter is its own panel.** Breaking ICE opens a focused terminal
  modal (the `EventTerminal` "hacking panel" pattern, extended with Progress /
  Trace meters) over the deck page. Finishing or retreating closes it — you put
  the deck away.

The route, the `GHOSTWORK` tab, the skill tree (`priv/content/skills/trees.exs`),
and the deck item (`jury_rigged_terminal`) **already exist and are empty.** This
feature fills them in.

---

# Progression: Gear × Mastery

Ghostwork's progression is **deliberately distinct** from the other skills (each
skill should feel different). It has two axes, and neither is an arbitrary
percentage bonus:

### Axis 1 — Gear (the loot pull)

Your **deck** and the **programs** loaded into it are *inventory items*. Each
program *is* an action you can run in an encounter (`Decrypt`, `Spoof`,
`Backdoor`…). Better/rarer programs push harder or generate less Trace, and a
tougher node simply cannot be cracked without the right tools. Programs come from
the economy that already exists — crafted via Street Alchemy, dropped by scavenge
/ fencing / event rewards, looted from nodes. This is the "always hunting better
gear to crack harder ICE" engine.

### Axis 2 — Mastery (learned by doing)

The **first** time you face a family of ICE, the encounter is fog-of-war: the
Trace bar is visible, but you don't know each action's cost *on this ICE*, or
where the layer's weak point is. As you crack nodes of that family, per-family
**mastery** accrues and the fog lifts in stages: first action numbers are
revealed, then the weak point surfaces. Diegetically — *"you've cracked Sentinels
before; you know Spoof barely dents them."* You literally play better because you
*understand* the ICE, not because a hidden multiplier changed.

The two interact: a fully-geared novice can brute-force but flies blind (busts
more); a master on weak gear reads the board perfectly but lacks firepower for
top-tier nodes. The game wants you to pursue both.

The named skill-tree tiers (Feed Skimmer → Latticework Phantom) become **earned
titles** displayed at gear + mastery milestones — a progress *readout*, not an XP
gate. (This intentionally leaves the generic 0/1 `ghostwork_tier` gate in
`Skills.Catalog` untouched for v1.)

---

# Player State

One new field on `Shunt.Players.Player` (`AddGhostworkStateToPlayers` migration):

```elixir
field :ghostwork_state, :map, default: %{}
# %{
#   "mastery" => %{"ice_maintenance" => 3},   # per-family crack count → fog-of-war level
#   "nodes"   => %{
#     "shunt9_abandoned_relay" => %{"banked_layer" => 1, "hardened" => false}
#   }
# }
```

Everything else rides existing ledgers — **no other new state**:

* **Programs / decks** → `inventory` (they're items).
* **Node, location, and lead reveals** → `knowledge` + `Requirements` (the Web's
  exact trick; see below).
* **Bust consequence** → `heat`.
* **Rewards** → existing effects (`:scrip`, `:inventory`, `:knowledge`,
  `:discover_location`, `:modify_rep`, …).

`ghostwork_state` holds only the two things no existing ledger expresses: a
**graded** per-family mastery count (more than the boolean a `knowledge` key
gives) and per-node resumable progress + hardened status.

---

# New Effect Types

Applied through `Shunt.Effects.apply/2`, listed in a layer's `reward` or emitted
by the encounter resolver.

```elixir
{:ghostwork_mastery, "ice_maintenance", 1}        # bump family mastery count
{:ghostwork_node, "shunt9_abandoned_relay", {:bank_layer, 1}}  # record layer 1 banked (resume point)
{:ghostwork_node, "shunt9_abandoned_relay", :harden}           # set hardened on bust
```

Hardened is **cleared lazily, not stored as a timer**: a node is attemptable when
it is not hardened **or** the player's Heat has fallen to/below the node's
`cool_threshold` (default: Heat band `:low` or better, i.e. `heat < 60`). When a
hardened node is re-entered under that condition, the resolver clears the flag.
No wall-clock state ever enters the game.

---

# Requirement Reuse — reveals cost no new machinery

A scan lead grants a `{:knowledge, key}`, and the node / location / contact it
unlocks is requirement-gated on that key — identical to how Juno's secret supplier
works in The Web. Two small additions to `Shunt.Requirements.met?/2` let leads and
nodes gate on gear and mastery:

```elixir
{:knows, "shunt9_abandoned_relay_found"}            # existing — node reveal
{:has_item, "jury_rigged_terminal"}                  # existing — "you hold a deck"
{:has_program, :decrypt}                              # NEW — you have a program of this action type
{:ghostwork_mastery_at_least, "ice_corp", 2}         # NEW — deeper signals need a sharper read
```

A lead stops surfacing once its knowledge key is held → "swept" needs no separate
bookkeeping. `{:has_program, action}` is met when the player's inventory contains
any program item whose `:action` matches; it gates deep leads and high-class nodes
behind owning the right tools.

---

# The ICE Encounter (the new mechanic)

## Data model

```elixir
defmodule Shunt.Ghostwork.IceNode do
  @enforce_keys [:id, :name, :family, :location_id, :layers]
  defstruct [
    :id,
    :name,
    :family,             # "ice_maintenance" — drives per-family mastery
    :location_id,        # the deck must be jacked in here to reach it
    description: nil,
    requirements: [],    # when the node becomes visible (usually a scan-lead {:knows, ...})
    cool_threshold: 60,  # hardened clears when heat is below this
    layers: []           # ordered %{...}
  ]
end
```

A **layer**:

```elixir
%{
  id: "handshake",
  name: "Access Handshake",
  progress_required: 10,
  trace_multiplier: 1.0,        # deeper layers > 1.0 — same action costs more Trace
  weakness: :spoof,             # super-effective action; hidden until mastery reveals it
  reward: [{:inventory, "maintenance_log", 1}]
}
```

A program (content category `:programs`; `id` matches an inventory key):

```elixir
%{
  id: "mimic_daemon",
  name: "Mimic Daemon",
  action: :spoof,
  progress: 4,
  trace: 3,
  on_weakness: %{progress: 8, trace: 1},   # when used against a layer it's weak to
  text: "Wraps your handshake in a forged corp signature."
}
```

## Actions

* **Probe** *(innate, always available)* — small Progress, small Trace. The safe
  grind; lets even a player with **no programs** crack weak ICE slowly.
* **Retreat** *(innate)* — end now, walk clean, keep everything banked.
* **Programs** *(gear)* — each loaded program is one action, with its own
  Progress / Trace and a bonus profile when used against a layer's weakness.

## Loop

State machine, one layer at a time. Trace (`0–100`) **persists across all layers**
and never resets until the encounter ends.

```text
                 ┌─────────────────────────────────────┐
   Jack in  ──▶  │  LAYER n: choose an action          │
                 │   Probe / Program / Retreat          │
                 └───────────────┬─────────────────────┘
        Progress fills           │            Trace hits 100
   ┌─────────────────────────────┤            (bust)
   ▼                             ▼                     ▼
 bank layer reward         keep pushing          lose current layer only,
 (dispatch effects)        same layer            keep banked, +Heat,
 + mastery tick            (Trace climbs)        node HARDENED
 Progress→0, next layer
   │
   ▼
 last layer cracked → node fully owned
```

* **Layer cracked** (Progress ≥ `progress_required`) → reward dispatched
  immediately through `Players.dispatch` / `Effects` + `{:ghostwork_mastery,
  family, 1}` + `{:ghostwork_node, id, {:bank_layer, n}}`. Progress resets, Trace
  carries, next layer's `trace_multiplier` applies.
* **Retreat** → encounter ends, banked layers already applied, no Heat.
* **Bust** (Trace ≥ 100) → `{:heat, scaled}` + `{:ghostwork_node, id, :harden}`.
  Banked layers are already applied; only the current layer's progress is lost.
  Resumable later from `banked_layer + 1` once cooled off.

## Mastery fog-of-war

The encounter view is rendered from `mastery = ghostwork_state["mastery"][family]`:

| Mastery | What the player sees |
|---------|----------------------|
| `0` | Action Progress/Trace shown as `?`; weakness hidden. Feeling around in the dark — wasted Trace finding what works. |
| `≥ 1` | Action numbers revealed. |
| `≥ 3` | The layer's `weakness` is revealed (the tell). |

Thresholds are constants in `Shunt.Ghostwork`, tunable in one place.

## Where the logic lives (presentation boundary)

Transient encounter state — current layer, Progress, Trace, which numbers are
known — lives in the **LiveView assigns** and is advanced by **pure
`Shunt.Ghostwork` functions** (`begin_encounter/2`, `act/3`, `retreat/1`). Each
call returns an updated encounter struct **and** any effects to dispatch (a banked
reward, a bust). The LiveView dispatches those through `Players.dispatch` and never
computes Progress/Trace/outcomes itself. Only *outcomes* touch the player record;
the in-progress encounter is never persisted (a dropped connection mid-break = you
lose the unbanked layer, which is thematically perfect).

---

# Signal Hunting (Scan)

A location carries an optional `:lattice` field (no new content category — it sits
on existing location content):

```elixir
lattice: %{
  leads: [
    %{
      id: "abandoned_relay_signal",
      requirements: [],                                  # standard gate to surface
      text: "A maintenance relay still broadcasting on a dead frequency.",
      on_intercept: [{:knowledge, "shunt9_abandoned_relay_found"}]
    },
    %{
      id: "distress_beacon_signal",
      requirements: [{:has_program, :decrypt}],          # deeper signal needs a tool
      text: "An encrypted distress loop, barely audible under the static.",
      on_intercept: [{:knowledge, "shunt9_distress_beacon_found"}]
    }
  ],
  filler: [
    %{weight: 3, text: "Stray feed fragments resolve into a few loose credits.",
      on_intercept: [{:scrip, 3}]},
    %{weight: 2, text: "Corp chatter — a name worth remembering.",
      on_intercept: [{:knowledge, "midgrid_rumor_01"}]}
  ]
}
```

`Shunt.Ghostwork.scan/2` resolves a scan at the player's location:

1. The first **lead** whose `requirements` are met **and** whose granted knowledge
   key the player doesn't yet hold is surfaced (authored, deterministic, swept
   once taken).
2. If no lead is available, draw weighted-random from **filler** (repeatable
   texture — scrip, rumors).
3. Always apply `{:heat, +4}` (scanning is mildly loud, like `scavenge`).

A revealed node then appears on the **deck page** when `node.location_id ==
player.location_id`, its `requirements` are met (the scan-lead `{:knows, …}`), and
it isn't fully cracked. Hardened nodes render as `HARDENED — cool off` instead of
breakable.

---

# AI Encounters (reused NPC system)

A node layer's `reward` can reveal an AI as an ordinary `%Shunt.World.NPC{}` —
e.g. `{:knowledge, "warden_ai_contact"}`, with a world NPC whose interaction is
gated on it and whose `location_id` is the node's location (so it appears as a
"contact" on the deck page at that location). Bargain / Trade / Help / Lie /
Threaten / Destroy are **Event choices** with effects; `npc_loyalty` bands give
the AI memory. **No new system** — an AI is an NPC with a digital skin. Out of
scope for the v1 vertical slice; the hook is the node reward.

---

# Content & Code Organization

```
lib/shunt/ghostwork.ex              # context: scan/2, begin_encounter/2, act/3, retreat/1
lib/shunt/ghostwork/ice_node.ex     # %IceNode{} struct + catalog lookup
lib/shunt/ghostwork/programs.ex     # program action-profile lookup (inventory key → profile)
lib/shunt_web/live/ghostwork_live.ex        # the deck: location-aware page + encounter modal
lib/shunt_web/components/ice_terminal.ex     # encounter panel (EventTerminal-style + meters)

priv/content/ice_nodes/**/*.exs     # NEW content category
priv/content/programs/**/*.exs      # NEW content category (program items)
priv/content/locations/**/*.exs     # existing — gains optional :lattice field
```

Wire the two new categories into `Shunt.Content.Store` `@sources` (the generic
`load_source/2` handles their `%{id: ...}` map shape). Repoint
`live "/skills/ghostwork"` from `SkillsLive` to the new `GhostworkLive`; the other
three skills keep `SkillsLive`.

---

# Worked Example / Minimum Vertical Slice

End-to-end, using content **already seeded** — the maintenance-tunnel security
panel event already says *"if you had a working ghostdeck you could try and catch a
fragment of Lattice traffic."* No programs and no AI required.

```text
Player Squat ──(walk map)──▶ Maintenance Tunnel        [physical]
        │ panel: ⌁ LATTICE cue (holds jury_rigged_terminal)
        ▼ switch to GHOSTWORK tab — "jack in"            [digital]
   Deck page (location = maintenance tunnel):
        ▼ SCAN
   Lead: "abandoned relay" → {:knowledge, "shunt9_abandoned_relay_found"}
        ▼ node now listed on deck page → [ Break ]
   IceNode "shunt9_abandoned_relay" (family "ice_maintenance", 2 layers):
        L1 handshake → Probe ×N → bank {:inventory, "maintenance_log", 1} + mastery+1
        L2 archive   → Probe ×N (Trace climbing) → bank {:knowledge, "maintenance_log_decoded"}
        ▼ node cracked
   {:knows, "maintenance_log_decoded"} gates a hidden POI event back in the tunnel
```

Exercises: the `⌁ LATTICE` cue, jacking in, location-filtered deck page, scan +
lead reveal, the layered encounter (Probe-only path), immediate banking, a mastery
tick, Trace pressure, and a knowledge-gated reveal — the whole spine with one node
and zero gear.

---

# Implementation Phases

1. **State + effects + requirements.** `ghostwork_state` migration;
   `:ghostwork_mastery` and `:ghostwork_node` effects; `:has_program` and
   `:ghostwork_mastery_at_least` requirements. *Verify: `Effects` / `Requirements`
   unit tests.*
2. **Encounter engine.** `Shunt.Ghostwork` pure functions + `IceNode` / program
   structs + content categories. Layers, Trace, bank, retreat, bust, harden,
   mastery reveal. *Verify: encounter unit tests, no UI.*
3. **Scan + lattice.** `scan/2`, lead/filler resolution, the `:lattice` location
   field. *Verify: scan unit tests.*
4. **Deck UI.** `GhostworkLive` (location-filtered scan / nodes / loadout / codex)
   + `IceTerminal` encounter modal; `⌁ LATTICE` cue on `MovementLive`. *Verify:
   LiveView tests against element IDs.*
5. **Vertical slice content.** The maintenance relay end-to-end. *Verify: a
   LiveView integration test that scans, breaks both layers, and asserts the
   revealed POI.*
6. **(Later — out of v1 scope.)** AI-NPC node reward; programs as Street-Alchemy
   recipes; Chrome & Meat deck-slot synergy; deeper corp/military families.

---

# Risks / Architectural Concerns

* **New mechanic, real RNG.** ICE breaking is the first risk-accumulation system
  and the first place RNG drives outcomes (`Loyalty` already uses `:rand`, so it's
  not unprecedented). Keep all randomness inside `Shunt.Ghostwork` so it's unit
  testable with an injectable seed; the LiveView stays deterministic.
* **Tuning is content, not code.** Layer `progress_required` / `trace_multiplier`,
  program numbers, mastery thresholds, and bust Heat are all data/constants. Build
  the slice, then tune for feel — don't pre-balance on paper.
* **Encounter state in the LiveView.** Acceptable (a dropped break loses only the
  unbanked layer), but it means the encounter resolver must be pure and the
  LiveView must never recompute domain outcomes — enforce the presentation
  boundary in review.
* **Two new content categories + a location field.** Modest surface growth. The
  generic loader absorbs the categories; the `:lattice` field is optional and
  ignored where absent.

---

# Future Phase (Not In Scope)

Deferred until the core loop proves fun:

* AI entities as full NPC arcs with their own questlines
* Programs as a Street Alchemy crafting branch; Chrome & Meat deck-slot upgrades
* Corp / military / rogue-AI ICE families with distinct weaknesses
* Traces that persist into the physical world (NPC reactions, security encounters)
* Multi-node "runs" and Latticework-only locations reachable only via the deck

The v1 focus is the loop:

```text
Scan → reveal node → break layered ICE (push your luck) → bank data + learn the family → better reads + better gear → harder ICE
```

If that loop is engaging, every richer Ghostwork system layers on top without
replacing this architecture.
