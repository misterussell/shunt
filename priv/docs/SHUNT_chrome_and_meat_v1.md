# Chrome & Meat — v1 Spec (Shunt 9 Intro)

## Status

**Implemented** on `feature/chrome-meat-shunt9-v1` (Milestones 1–4). This replaces the original
aspirational "10 pillars" pass-off. The v1 target is an **early, basic introduction to the skill in
the starting district, Shunt 9** — not the late-game Bloom addition. The Bloom/Spire wiring is
explicitly **v2** (see the Forward-Compatibility Contract).

Two structural additions surfaced during implementation and are now part of v1:
- **`:chrome_raws` content category** — chrome-fabrication raws live in their own ETS table
  (isolated from `:raws`, exactly like `:quest_items`), so the random scavenge pool never yields
  them; they drop only from salvage events.
- **`catalog/1` state `:needs_materials`** — distinguishes "has the schematic + tool but lacks
  parts" from "no schematic," so the UI points the player at salvage instead of lying "NO SCHEMATIC."

The guiding constraint: **build a clean, forward-compatible foundation** and a small, on-theme
first loop that reuses Shunt 9's existing fabric. Favor reuse over new systems; favor data-driven
content; keep Chrome & Meat a self-contained skill.

---

## What already exists (inherit, do not reinvent)

Chrome & Meat is a **reserved, dormant slot** — much of the on-ramp is already built:

- **Skill tree** `chrome_meat` in `priv/content/skills/trees.exs` (5 tiers, tier 1 = "Back-Alley
  Tinkerer"), `tool_key: "patchwork_scalpel"`. `Shunt.Players.Player` already has
  `chrome_meat_tier`. Route `/skills/chrome-meat` and the nav tab exist; today it renders a
  "DORMANT MODULE" stub.
- **The skill-unlock loop is already mechanically complete.** `player_squat_neural_port` (one of
  three parallel starter-kit events in the spawn squat) grants `{:knowledge, :augmentations}` and
  points the player at the scalpel. Crafting `patchwork_scalpel` (recipe exists; `tier_required: 0`;
  inputs `sterile_suture_kit` + `subdermal_wiring_bundle`, both scavengeable) flips
  `chrome_meat_tier` 0→1 via `Shunt.Skills.Catalog.current_tier/2`.
- **The graduation graftsman exists:** `crossgate_graft_den_stitch` ("Stitch") at
  `crossgate_graft_den` — *"installation, removal, calibration, and diagnosis."* Crossgate is
  reachable only after unlocking the transit door off the Burned Platform, so Stitch is the **tier-up
  graftsman for later**, not the Shunt 9 intro.
- **The faction exists:** `mother_graft`, `faction: :fleshless`, "Flesh Tithe." Reserved for the v2
  Fleshless path.
- **Chrome-flavored fencing items exist** (`stolen_corp_biomod_prototype`, `winnow_stripped_augment`,
  `grey_market_neural_patch`, `scrap_dermal_plating`). **These stay as fencing goods** — the fencing
  loop is "move it for someone else," not ownership. Chrome you actually own lives in a new registry.
- **A supply thread is pre-seeded:** Stitch's `supply_shortage` arc already ties augment material to
  "the Fleshless" and specifically to **subdermal wiring** — the same raw as the scalpel input.

---

## Design identity

**Chrome & Meat is the body-side of the harvest.** In canon, ascent = harvest and the ascended become
Latticework substrate; the Fleshless say "flesh is obsolete"; the Bloom "gloss" is the neural shunt
that makes a body harvest-ready (`SHUNT_STORY_CANON.md` hook #4). Chrome & Meat is the player-driven
mirror of that: the more chrome you carry, the more legible you are to the machine and the closer you
drift to substrate.

- **In Shunt 9 the theme is *seeded, not revealed.*** Chrome Load reads as a simple power-vs-instability
  risk axis. Its true meaning is foreshadowed here (ominous low-threshold beats) and paid off near the
  Spire in v2.
- **Two separate meters — never merged.** *Authority Heat* (`player.heat`) is surveillance/pursuit
  pressure with the Kaspav Authority. *Chrome Load* is a **new, separate** meter. They share only a code
  *shape* (capped integer + threshold bands + event-on-crossing, à la `Shunt.Heat`).
- **Intentional cross-link (v1):** *bad/heavy chrome raises Authority Heat.* Tracked/counterfeit/
  military-surplus chrome (later) and high Chrome Load through a checkpoint feed `{:heat, +n}` — chrome
  makes you legible the way a forged name does.
- **Implants are capability keys** (+ a few bespoke hooks). Shunt has **no passive-modifier layer**;
  installing an implant sets a flag gated by a new `{:has_implant, key}` requirement (exactly how
  knowledge/contacts/modules already gate content). A small number of signature implants may get
  hand-coded hooks. No generic "+X% while equipped" system.
- **Install outcomes are deterministic by inputs** (graftsman quality + your tier + suppressants/
  materials on hand), not RNG. True randomness isn't expressible in Shunt content and is reserved for
  emergency/field surgery (deferred).
- **No combat.** Shunt has no combat system. The original "harvest from defeated enemies" and "escape
  combat" pillars are reframed (harvesting → salvage events; emergency → heat/time pressure) and
  deferred.

---

## v1 scope — the Shunt 9 loop

| Stage | What happens | Reuses |
|---|---|---|
| **0 — Unlock** (mostly exists) | Read `player_squat_neural_port` → `{:knowledge, :augmentations}` → scavenge two raws → craft `patchwork_scalpel` → `chrome_meat_tier` 1, module lights up. | Existing event + recipe + tier logic. Enrich text only. |
| **1 — The fitter** | A **new back-alley grafter NPC** (Maintenance Tunnel or Burned Platform — both one hop from spawn), gated on `power >= :partial` (bench needs juice), mirroring how Volt appears at `:online`. Introduces the fitter, offers the first install, seeds the Fleshless supply thread. | New `world_npc`; existing `power` fact. |
| **2 — Acquire first implant** | The **lineman's graft** (crude protective/motor chrome). Fitter-provided or cheaply fabricated to avoid craft→craft→install fatigue; fabrication is the repeatable path for *later* implants. | New `:implants` content. |
| **3 — Install** | At the fitter. Deterministic by inputs (tier 1 + optional suppressant raw improves outcome text / trims heat). Adds Chrome Load and a small Authority Heat bump. | New effects. |
| **4 — Chrome Load debut** | Ticks from 0; one **low** threshold fires a mild, ominous foreshadowing beat (the seam itches; a reader's eye lingers). No reveal. | Heat-pattern meter + a threshold event. |
| **5 — The graft does something** | `{:has_implant, "lineman_graft"}` opens an **additive** option on the generator's full repair (`:partial → :online`): a safer/cheaper/bonus path. **Never required** — a chrome-less player can still finish the power arc. *Useful before cool* (Constitution Rule 4). | New requirement + an added repair solution / POI. |

**Timing is self-consistent:** the fitter needs `power >= :partial` to run their bench, so the player
reaches chrome right as they finish the district's core "get the power back on" arc, and the first graft
pays off on the arc's back half.

### Deferred to v2+ (explicitly out of v1)

Maintenance/upkeep; tuning (per-implant modes); black-market authentication (per-copy
counterfeit/tracked — needs item instancing); the Fleshless faction path; deep harvesting; emergency
surgery + the RNG install verb; cross-skill firmware/repair/Web integrations; and the Bloom `shunt`
wiring + Winnow `winnow_shunt_complete` payoff.

---

## Data model

The only genuinely new persistent state (one additive migration in `priv/repo/migrations/` +
fields on `Shunt.Players.Player`):

- **`chrome_load :integer, default: 0`** — the capped 0–100 meter, distinct from `heat`.
  `Shunt.ChromeMeat.clamp/1` enforces the cap. Unlike `Shunt.Heat`, Chrome Load does **not** fire
  events mid-effect; the foreshadowing beat is a narrative conditional event gated on
  `{:chrome_load_at_least, n}`. `band_for/1` (UI styling only) arrives with the Milestone 3 UI.
- **`implants :map, default: %{}`** — **def-keyed** like `player.infrastructure`:
  `%{implant_key => %{"installed_at" => datetime, ...}}`. Def-keyed (not instanced) because per-copy
  provenance (authentication) and tuning are deferred; instancing becomes a v2 migration when
  authentication lands. `condition`/`last_serviced` sub-keys are **reserved** for v2 maintenance.
- **New content type `:implants`** — add `{:implants, "priv/content/implants"}` to
  `Shunt.Content.Store` `@sources`; author a thin `Shunt.Implants` accessor over `Content.all/1` /
  `Content.fetch!/2`. Each implant `.exs` is self-describing:

  ```elixir
  %{
    id: "lineman_graft",
    name: "Lineman's Graft",
    chrome_load: 15,               # added to Chrome Load on install
    heat_on_install: 2,            # Authority-Heat cross-link
    grants: ["lineman_graft"],     # capability key(s) for {:has_implant, ...}
    fabrication: %{                # optional; absent for NPC-only implants
      schematic: "schematic_lineman_graft",   # {:knows, ...} gate
      inputs: %{"subdermal_wiring_bundle" => 1, "salvaged_servo" => 1}
    },
    install_text: "...", flavor: "..."
  }
  ```

- **`chrome_meat_tier`:** leave the column, but **derive** the effective tier (Ghostwork-style) from
  chrome state rather than writing it — keeps a single source of truth. (v1 stays tier 0/1 on tool
  possession, matching the existing catalog behavior.)

---

## New engine surface (small, localized)

- **Effects** (`lib/shunt/effects.ex`, one `do_apply/4` clause each):
  - `{:chrome_load, delta}` — clamps via `ChromeMeat.clamp/1` (no mid-effect event; see above).
  - `{:install_implant, key}` — writes the `implants` map; emits the implant's `chrome_load` and
    `heat_on_install` as follow-on effects.
  - `{:remove_implant, key}` — inverse (for completeness; UI use is minimal in v1).
- **Requirements** (`lib/shunt/requirements.ex`, one `check/2` clause each):
  - `{:has_implant, key}` — capability-key gate.
  - `{:chrome_load_at_least, n}` / `{:chrome_load_below, n}` — threshold gating for events.
- **Fabrication (self-contained, no `Shunt.Crafting` change):** chrome fabrication is a Chrome-owned
  `Shunt.ChromeMeat.fabricate/2` that reads the implant def's `fabrication` block and reuses the
  *mechanism* of `assemble/` (consume inputs → grant output). The **schematic-lock and tool gate live
  in `fabricate/2`** — it requires the chrome tool (`patchwork_scalpel`) + the learned schematic
  (`{:knows, "schematic_x"}`) + materials, and does **not** gate on `street_alchemy` tier or touch
  `Shunt.Crafting`. (Implants are not `:recipes` entries; their fabrication data lives on the implant
  def, so `assemble/` never needs a `requirements` field.)
- **`Shunt.ChromeMeat`** — new pure domain module (returns effect lists, never touches Repo):
  clamp/band logic, `fabricate/2`, `install/2` (deterministic outcome from inputs), derived tier.
- **UI:** replace the dormant stub branch in `ShuntWeb.SkillsLive` for `:chrome_meat` — show Chrome
  Load, owned/installed implants, and the fabricate action. Dispatch via `Players.dispatch/2`.

**Content-integrity note:** the existing test forces every `{:knows}` gate to have a matching grant,
so schematic-locked recipes *require* a real in-world source to exist — the wiring can't be forgotten.

---

## Acquisition (v1)

Two ways to own an (uninstalled) implant; installation is a separate step (see below).

- **Fabricate (primary, repeatable).** Chrome tool + learned schematic + salvaged raws → an
  **uninstalled implant item in inventory**. Location-agnostic (a Chrome & Meat screen action, like
  alchemy assembling).
- **NPC grant (secondary).** A few implants handed over directly by NPCs (the Shunt 9 fitter in v1) as
  story/loyalty rewards.
- **Not fencing.** Fenced chrome stays a laundering loop.

**Supply chain:**

- **Chrome raws** (salvaged servos, neural fiber, harvested tissue, …) are new raw types that drop
  **only from dedicated salvage/"recover" events** — the reframed harvesting fantasy — kept **out of
  the global random-scavenge pool** so Street Alchemy scavenging isn't diluted.
- **Schematics** are `{:knows, "schematic_x"}` flags, learnable in v1 from any of four channels
  (author at least one in Shunt 9): **NPC teaching, Ghostwork ICE-node cracks, Web rumor resolutions,
  salvage/cache finds.**

---

## Installation (v1)

- Performed by the **new Shunt 9 fitter** (Stitch in Crossgate is the later graduation option).
- **Deterministic by inputs:** outcome branches are separate requirement-gated events keyed on your
  tier, the fitter's standing, and whether you brought a suppressant/material. Existing systems cover
  the "relationships matter" fantasy for free: **Loyalty** (`player.npc_loyalty`) scales
  discount/reliability; **Reputation** (`player.reputation`) gates prototype access later.
- Installing emits `{:chrome_load, +n}` and `{:heat, +small}`, and may cross Chrome Load's first
  threshold → foreshadowing event.

---

## Backward / forward-compatibility contract

**This is the first skill that must be built for long-range compatibility. Behaviors to hold:**

Backward (don't break the starting experience):
- The power-restoration arc **must remain completable without any chrome.** The graft only opens an
  *additive* option on the `:partial → :online` repair; it is never a required gate.
- Existing chrome fencing items are unchanged (still fence-only).
- `chrome_meat_tier` behavior is unchanged for existing saves (0/1 on tool possession); we derive, not
  rewrite.
- The three parallel squat starter events stay parallel; only the chrome one gets light enrichment.

Forward (so v2 attaches without rework):
- **Bloom `bloom_glossed` → `shunt` implant (v2).** Build the `implants` model and `{:install_implant}`
  now so the Bloom gloss can retroactively grant the `shunt` implant (derive-on-read) without a schema
  change. `bloom_bevel_gloss.exs` is the anchor.
- **Winnow `winnow_shunt_complete` (v2)** — the Chrome system should read this flag when the shunt
  "completes" at the Spire; don't contradict it.
- **Stitch (Crossgate)** is the tier-up graftsman; the Shunt 9 fitter is a deliberate down-scale of
  Stitch's model (converted bench, "installation/removal," writes you a parts list).
- **Fleshless supply thread** (subdermal wiring, already in Stitch's arc) is the seam the v2 faction
  path grows from.
- Reserve `condition`/`last_serviced` in the `implants` map and the `{:has_implant}`/`{:chrome_load_*}`
  requirements so v2 maintenance, authentication (instancing), and tuning layer on cleanly.

---

## Implementation milestones (each independently testable)

1. **Foundation:** migration (`chrome_load`, `implants`) + `{:chrome_load}`/`{:install_implant}`/
   `{:remove_implant}` effects + `{:has_implant}`/`{:chrome_load_*}` requirements + `:implants` registry
   + `Shunt.Implants` accessor. Unit tests on effects/requirements/clamp/bands. *(Content-mutating
   ETS tests run sync.)*
2. **Domain:** `Shunt.ChromeMeat` (`fabricate/2` with the tool + schematic + materials gate,
   `install/2` deterministic outcome, clamp/band) + `Shunt.Implants` accessor. Unit tests. (No
   `Shunt.Crafting` change — fabrication reads the implant def's `fabrication` block.)
3. **Meter + UI:** Chrome Load display and the fabricate/install actions replace the dormant stub in
   `ShuntWeb.SkillsLive`. LiveView tests against element IDs.
4. **Shunt 9 content:** new fitter NPC (power-gated); the `lineman_graft` implant + its schematic +
   salvage event(s) granting chrome raws; the additive power-relay repair option; the low Chrome Load
   foreshadowing event; light enrichment of `player_squat_neural_port`.
5. **Integration/verify:** full loop playable in Shunt 9; **assert the power arc still completes with
   zero chrome**; `mix precommit` green.

---

## Open questions / follow-ups

- **`player_squat_neural_port` text:** it names a "neural port" as the example install; the v1 first
  implant is the `lineman_graft`. Light-touch the text so it seeds the skill without over-promising a
  port (the port becomes a natural later/Ghostwork-facing implant).
- **Additive power-relay option shape:** a new `solution` on `shunt9_power_relay_generator` vs. a gated
  POI event at the Power Relay — decide during content authoring.
- **Lexicon additions:** register new recurring terms (the fitter, "Chrome Load," the graft, chrome raw
  names) in `SHUNT_LEXICON.md` per Constitution Rule 5.
- **Fitter placement:** Maintenance Tunnel vs Burned Platform — pick during authoring (both one hop
  from spawn, both `:underbelly`).
