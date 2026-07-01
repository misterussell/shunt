# Authoring a District (or Location)

A start-here playbook for building new districts and locations in Shunt, distilled from the
Windlass build. It covers **what to decide**, **what to author**, **how it wires together**,
and **how to verify it**. It does not restate the voice rules — those live in the five content
docs and always win:

- `docs/SHUNT_CONTENT_CONSTITUTION.md` (the five non-negotiable rules)
- `docs/SHUNT_TERMINOLOGY.md`, `docs/SHUNT_STYLE_GUIDE.md`,
  `docs/SHUNT_NAMING_PATTERNS.md`, `docs/SHUNT_LEXICON.md`

**Golden rule (Constitution #1): infrastructure first.** Decide what the place *is for* and
*who survives there* before naming anything. Then pull words from the Lexicon before coining
new ones, and register any new recurring term back into `SHUNT_LEXICON.md` (Constitution #5).

---

## 1. Decisions to make first

A district is not a single object — it's a set of `.exs` content files sharing an id prefix
(`grayline_`, `windlass_`), wired by exits and gated by requirements. Before authoring, pin
these down (this is the lightweight version of the brainstorming pass):

1. **Core infrastructure & concept** — what machine/place is it built on? What's its shape on
   the map (the Windlass is a spiral coil; graph_position coordinates are hand-authored)?
2. **Id prefix** — e.g. `windlass_`. Every file's `id` starts with it.
3. **Zones & locations** — the sub-areas and how many locations each gets. Pick a scope and
   stick to it (the Windlass = 13 locations across 4 zones + 1 connective hub).
4. **Factions** — which existing factions have presence, and what's the conflict axis. Faction
   presence is expressed through the NPCs/events/rumors you place + reputation gates; there is
   **no** "faction field" on a district.
5. **District Evolution facts** (optional but recommended) — 1–2 derived world-state facts
   (like Windlass `grid`/`haul`) that shift as the player acts and rewrite atmosphere/gates.
6. **Through-line** — the central case/goal that ties the zones together (the Web investigation).
7. **Territory premise** (optional) — a new hideout the player can move into, and whether it
   advances the ladder.
8. **Entry & exit** — which existing location connects in, and how the player leaves onward.
9. **Skill coverage** — make sure each skill has a real reason to exist here (Ghostwork,
   Street Alchemy, Chrome & Meat, The Web).

---

## 2. Content types & where they live

All content is `.exs` files under `priv/content/<type>/`, loaded at boot by
`lib/shunt/content/store.ex` (the `@sources` list is the authoritative type→dir map). Each file
`Code.eval_file`s to a struct/map exposing `.id`; subdirectories are purely organizational.
Read `Shunt.Content.fetch!/2` / `all/1` to consume.

| Type | Dir | Shape | Example to copy |
|---|---|---|---|
| Location | `locations/<district>/` | bare map (no struct) | `locations/windlass/windlass_fitters_floor.exs` |
| World NPC | `world_npcs/<district>/**` | `%Shunt.World.NPC{}` | `world_npcs/windlass/fitworks/windlass_drift.exs` |
| Event | `events/<district>/**` | `%Shunt.Events.Event{}` | `events/windlass/fitworks/windlass_drift_intro.exs` |
| District Def | `districts/` | `%Shunt.District.Def{}` | `districts/windlass.exs` |
| Repairable | `repairables/` | `%Shunt.Repair.Repairable{}` | `repairables/windlass_engine.exs` |
| ICE node | `ice_nodes/<district>/` | `%Shunt.Ghostwork.IceNode{}` | `ice_nodes/windlass/windlass_grid_core.exs` |
| Program | `programs/` | plain map `%{id, action, ...}` | `programs/tracebreaker.exs` |
| Rumor | `rumors/<district>/` | `%Shunt.Web.Rumor{}` | `rumors/windlass/windlass_authority_order.exs` |
| Rumor connection | `rumor_connections/` | `%Shunt.Web.RumorConnection{}` | `rumor_connections/windlass_sabotage.exs` |
| Hideout module | `modules/` | plain map `%{id, cost, effect, ...}` | `modules/signal_tap.exs` |
| Ladder | `territory/ladder.exs` | single def keyed `"ladder"` | (edit in place) |
| Fencing item | `fencing/` | plain map | `fencing/windlass_skimmed_signal_shard.exs` |
| Heat event | `heat_events/` | plain map `%{id, band, ...}` | `heat_events/windlass_authority_sweep.exs` |
| Quest item | `quest_items/` | `%{id, name, flavor}` | (needed only for `{:has_item}` errand gates) |
| Raws / recipes | `raws/`, `recipes/` | plain maps | reuse existing before adding new |

### Location map — the fields that matter

```elixir
alias Shunt.World.Exit
%{
  id: "district_place",            # required, ETS key; prefix with your district
  name: "The Place",
  short_description: "...",        # shown in listings
  description: "...",              # base body text
  tags: [:midgrid, :market, ...],  # atoms
  graph_position: {x, y},          # hand-authored map coords (more negative y = higher strata)
  premises_class: 3,               # ONLY on hideouts (Territory); omit otherwise
  relocation: %{cost: %{scrip: _, cred: _}, requirements: [...]},  # ONLY on hideouts
  atmosphere: [                    # District-Evolution ambient tiers, base->deepest, cumulative
    %{requirements: [], text: "..."},
    %{requirements: [{:district, "district", :fact, :>=, :level}], text: "..."}
  ],
  lattice: %{                      # makes the location hackable (Ghostwork scan layer)
    leads: [%{id: "...", requirements: [...], text: "...", on_intercept: [<effects>]}],
    filler: [%{weight: 3, text: "...", on_intercept: []}]
  },
  npcs: [
    "district_npc",                                        # always visible
    %{id: "district_npc2", requirements: [...]}            # conditionally revealed (see §5)
  ],
  events: ["district_some_event"],  # POI events surfaced at this location
  requirements: [...],              # OPTIONAL: hide the whole location until met
  exits: [
    %Exit{id: "here_to_there", to: "district_there",
          requirements: [...],       # OPTIONAL gate (see §5)
          travel_text: "..."}        # OPTIONAL flavor on move
  ]
}
```

**Exits are one-directional.** For two-way travel, author the return exit on the destination
too. (We shipped a bug where the Grayline→Windlass entry had no return — don't repeat it.)

---

## 3. The requirements DSL (gating)

Every `requirements: [...]` list (on locations, exits, npc entries, atmosphere tiers, lattice
leads, events, modules, relocations) is checked by `lib/shunt/requirements.ex`. All predicates:

- `{:knows, key}` — player has knowledge flag
- `{:has_rumor, key}` — player holds a rumor
- `{:contact_known, key}` — player knows a contact
- `{:rep_at_least, npc, dim, n}` — reputation threshold
- `{:has_item, key}` — inventory has ≥1
- `{:has_module, key}` — hideout module installed
- `{:premises_at_least, class}` — premises class ≥ n
- `{:ghostwork_mastery_at_least, family, n}` — ICE mastery threshold
- `{:infra_state, id, state}` — a repairable is in `"broken"|"patched"|"repaired"`
- `{:has_program, action}` — owns a deck program of that action
- `{:district, district_id, fact, op, target}` — `op` is `:>=` or `:<`, compared by position
  in the fact's `:levels`

All lists are **AND** (every predicate must hold). For OR, use multiple gated entries or
multiple district rules (see §4).

## 3b. The effects vocabulary (grants)

Event `on_complete`, ICE layer `reward`, lattice `on_intercept`, and repairable `effects` are
lists of effect tuples applied by `lib/shunt/effects.ex`. Common ones:

`{:scrip, n}` · `{:cred, n}` · `{:heat, n}` · `{:inventory, key, n}` · `{:knowledge, key}` ·
`{:contact, key}` · `{:rumor, key}` · `{:npc_loyalty, key, n}` · `{:infrastructure, id, state}` ·
`{:install_module, key}` · `{:discover_location, key}` · `{:set, field, value}`.

---

## 4. District Evolution facts

Author `districts/<district>.exs` as `%Shunt.District.Def{id, name, facts}`. Each fact is an
`:ordinal` rule: ascending `levels`, a `default`, and top-down `rules` (first match wins).
`Shunt.District.fact/2` derives the current level; `{:district, ...}` requirements read it.

```elixir
grid: %{
  kind: :ordinal,
  levels: [:clamped, :contested, :open],
  default: :clamped,
  rules: [
    {:open,      [{:knows, "windlass_grid_open"}]},
    {:contested, [{:knows, "windlass_fitworks_ice_cracked"}]},  # multiple :contested rules
    {:contested, [{:infra_state, "windlass_fitworks_relay", "repaired"}]}  # = OR semantics
  ]
}
```

**Hard constraint:** a fact's rule requirements must **not** contain `{:district, ...}` — it
would recurse with no cycle guard. Derive facts only from primitives (`{:infra_state, ...}`,
`{:knows, ...}`, etc.). Facts are derived, **never stored** — you cannot "set" a fact directly;
you grant the knowledge/repair the rule keys on.

Facts pay off in: `atmosphere` tiers, `{:district, ...}` gates on exits/npcs/events, hacking
difficulty, and district-scaled income (below).

---

## 5. Web-v1 conditional reveals (make the world open up)

This is what makes a district feel alive as the player progresses. Use all of it:

- **Hidden/locked locations** — either a location-level `requirements`, or (more common) gate
  the *exit* into it. Windlass: the Coldroom exit needs `{:knows, "windlass_fuse_vouched"}`.
- **Conditionally-revealed NPCs** — in a location's `npcs` list, use
  `%{id: "npc", requirements: [...]}` instead of a bare id. The NPC appears only when met.
  Windlass: Crane appears at Slagfoot Landing once `haul >= :running`; Hex once
  `grid >= :contested`; Wick once the purge rumor is held. (Shunt 9's Volt is the original.)
- **Conditional events** — put late-unlock events in the NPC's `conditional_events` (vs
  `story_arcs`) and/or gate the event's own `requirements`.
- **Gated lattice leads** — a lead with `requirements` only surfaces its hack when met.

Rule of thumb: at least one NPC and one location should reveal off each District fact, and the
finale should reveal off the case being cracked.

## 5b. Ghostwork (hacking)

Two pieces: a location's `lattice` block (the scan layer whose `leads` grant "found" knowledge)
and `ice_nodes/` files (`%Shunt.Ghostwork.IceNode{}`) whose `requirements` gate on that
knowledge. A node has `layers`, each an open board of `subroutines` with a `key`
(`:spoof|:decrypt|:backdoor`), a `threat` (`:barrier` inert | `:sentry` bleeds trace |
`:trap` amplifies mismatch), and `progress_required`. Layer `reward` fires like an `on_complete`
— use it to grant knowledge that promotes a District fact or drops an investigation rumor.
Escalate `cool_threshold` / `trace_multiplier` / `progress_required` for harder nodes.

## 5c. The Web investigation

Seed rumors (`{:rumor, key}` effects from events, ICE rewards, lattice intercepts), then author
one `%Shunt.Web.RumorConnection{}` listing the exact resonant set, a `partial_threshold`, and
`success_event_id` / `partial_event_id` / `failure_event_id`. The success event's `on_complete`
grants the flag that opens the finale. Tip: sourcing one required rumor from an ICE reward forces
the player to hack for a full-case crack.

## 5d. Territory premise & ladder

A premise is just a location carrying `:premises_class` (2+) and a `:relocation` block. To add
an income module, author `modules/<key>.exs` with `effect: %{kind: :income, ...}`; to advance
the ladder, add a rung to `territory/ladder.exs` keyed on `{:has_module, key}`. Income can be
static (`rate:`) or district-scaled — see `signal_tap`, whose `scales_with` a district fact is
resolved per player in `Shunt.Territory` (`normalize_income/2`). Class floors are enforced at
install via `premises_class_min`.

---

## 6. Integrity constraints (or the app soft-locks)

- **Event gate grants** (`test/shunt/content_integrity_test.exs`, enforced): every
  `{:knows}`/`{:has_item}`/`{:contact_known}` in an **event's** `requirements` must have a
  matching grant somewhere — an event `on_complete` or an ICE layer `reward`. Location/exit
  gates are exempt (world-building gates may precede their granting events). `{:has_item}` keys
  must also exist in the `quest_items` catalog.
- **Choices carry no effects.** Event choices only do `%{next: id}` or `%{complete: true}`; any
  other choice abandons the event. All effects live in one `on_complete`, fired on complete.
  Branching *outcomes* = separate events, each with its own `requirements` + `on_complete`.
- **Cross-references are NOT test-enforced** (exits→locations, npc/event ids, repairable/ICE
  `location_id`, connection rumors). Self-check with the script in §7.

---

## 7. Build & verify workflow

1. **Branch** — never author on `master` (`git checkout -b feature/<district>`).
2. **Code changes first, TDD** — any engine change (e.g. district-scaled income) gets a failing
   test before implementation. Content-only additions don't need new tests.
3. **Author in committed stages** — spine (district def + modules) → locations + entry seam →
   repairables + ICE → NPCs + events + rumors → fencing + heat → Lexicon. One stage per commit.
4. **Register new terms** in `SHUNT_LEXICON.md` (Constitution #5).
5. **`mix precommit`** must be green (Credo + format + full test suite) before finishing.
6. **Cross-ref + reachability check** (no test covers this) — run a throwaway script:

```elixir
# mix run check.exs   (set `pfx` to your district prefix)
alias Shunt.{Content, World}
alias Shunt.Players.Player
pfx = "windlass_"
loc_ids = MapSet.new(Content.all(:locations), & &1.id)
npc_ids = MapSet.new(Content.all(:world_npcs), & &1.id)
evt_ids = MapSet.new(Content.all(:events), & &1.id)
locs = Enum.filter(Content.all(:locations), &String.starts_with?(&1.id, pfx))
errs =
  (for l <- locs, e <- Map.get(l, :exits, []), not MapSet.member?(loc_ids, e.to), do: "#{l.id}: exit -> #{e.to}") ++
  (for l <- locs, n <- Map.get(l, :npcs, []), id = (is_binary(n) && n) || n[:id], not MapSet.member?(npc_ids, id), do: "#{l.id}: npc #{id}") ++
  (for l <- locs, ev <- Map.get(l, :events, []), not MapSet.member?(evt_ids, ev), do: "#{l.id}: event #{ev}")
IO.puts("#{length(locs)} locations, #{length(errs)} cross-ref errors")
Enum.each(errs, &IO.puts("  - " <> &1))
# reachability from the entry (grant the gate flags):
p = %Player{location_id: "#{pfx}entry", inventory: %{"jury_rigged_terminal" => 1}, knowledge: [<gate flags>]}
reach = World.accessible_locations(p) |> Enum.map(& &1.id) |> Enum.filter(&String.starts_with?(&1, pfx))
IO.puts("reachable: #{length(reach)}/#{length(locs)}")
```

Also confirm **every exit is bidirectional** unless a one-way drop is intended, and that each
District fact derives across its levels (call `Shunt.District.fact/2` with sample player state).

7. **Finish the branch** — merge locally / open a PR (the last two districts shipped as PRs).

---

## Naming test (apply to every new name)

1. Could a worker plausibly say this? 2. Does it sound useful, not impressive? 3. Does it fit a
salvaged future? 4. Would it still make sense in twenty years? See `SHUNT_NAMING_PATTERNS.md`.
Check new NPC display names against existing ones (`grep -rh "name:" priv/content/world_npcs/`)
— repeated names read as the same person unless they actually are.

**NPCs specifically:** default to plain real given names (Mara, Eli, Silas, Yara…); reserve
nicknames/occupational handles (Coil, Bevel, Soot…) for the one or two per district who've
genuinely earned one. A cast that's all Ratchet/Cinder/Rusk is over-themed — see
`SHUNT_NAMING_PATTERNS.md` § NPC Names.
