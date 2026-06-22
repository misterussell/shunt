# Shunt — UI Design Brief

> Hand-off brief for styling/visual design work. This is a design brief, not an
> implementation plan — it describes what should exist and how it should look/feel.
> It does not prescribe Elixir/HEEx code structure.

## 1. Context

Shunt ("Shunt 9") is a single-player black-market fixer simulation: scavenge and
craft, fence stolen goods, manage Heat (police/syndicate attention), and build
loyalty with five NPC contacts across four factions. The UI is currently the stock
Phoenix/daisyUI scaffold with zero game-specific styling — one unstyled page with
everything on it. This brief defines a cyberpunk visual identity ("corporate-dystopia
chrome": cold, sterile corp-tech surfaces with grime at the edges — think Deus Ex /
Ghost in the Shell, not neon synthwave) and the page/navigation structure to build it
into.

**Tone reference points already in the game's own content:** faction names like
"Syndicate of Closed Hands," "Kaspav Authority," "Latticework Collective," and
"Fleshless"; NPC flavor lines like *"Sealed casing, corp serials filed off. Whoever
lost this is already looking for it."* The UI should read as understated and
technical, not loud — the writing already carries the noir/grime tone.

## 2. What's implemented today (don't invent functionality beyond this)

- **Wallet**: `Cred` and `Scrip` (plain integer counters), `Heat` (0–100 risk meter).
- **Fencing**: find a lead → get a buy/sell offer (tiered clean/warm/hot) → take or
  pass → sell held item.
- **Street Alchemy** (the only fully functional skill tree): scavenge for raw
  materials, assemble recipes (tier-gated), sell assembled goods.
- **NPC trading**: 5 NPCs (Mother Graft, Rook, Nine-Iron, Splice, Tally), each with
  one trade action and a loyalty value (0–100).
- **Skill trees / progression ladders**: four trees — **Ghostwork**, **Chrome &
  Meat**, **The Web**, **Street Alchemy** — each with 5 named tiers. Only tier 0/1 is
  reachable today (binary: own the tree's tool item or don't); tiers 2–5 have no
  unlock mechanic yet. Ghostwork, Chrome & Meat, and The Web have **no gameplay
  attached** — they exist only as progression trackers right now.

Everything below should accommodate this state honestly: stub pages should look
intentionally dormant, not broken or "coming soon" in a jokey way.

## 3. Visual identity

### Palette

| Role | Color | Use |
|---|---|---|
| Base background | `#0B0E14` | page background |
| Panel surface | `#161B24` | cards/panels |
| Panel border | `#2A3340` | 1px hairline borders — no drop shadows |
| Primary accent | `#4FC3E0` (cold cyan) | active states, links, primary buttons, ladder glow |
| Warning accent | `#E0A458` (amber) | Heat mid-range, caution states |
| Danger accent | `#E0566B` (cold red) | Heat near-max, hostile loyalty, errors |
| Text primary | `#D8E1E8` | body/headings |
| Text muted | `#7C8896` | secondary/flavor text |

### Typography

Self-host all fonts via `assets/fonts` + `@font-face` in `app.css`. Per this
project's house rules (`AGENTS.md`), templates may **never** reference an external
`<link>`/`<script>` — only the bundled `app.css`/`app.js`.

- **Display/UI labels** (headers, nav, button labels): *Chakra Petch* — geometric,
  technical. Uppercase with letter-spacing for labels/buttons/nav.
- **Data/numeric readouts** (Cred/Scrip/Heat values, tier counters): *IBM Plex Mono*
  — reinforces a terminal-readout feel for anything that's a number.
- **Body/flavor text** (descriptions, offer text, NPC dialogue): *Inter*, system sans
  fallback. Kept plain for readability — the writing carries the tone, not the font.

### Component motifs

- Sharp corners — no `rounded-lg`. Thin 1px borders instead of shadows.
- Small L-bracket corner accents on focused/active panels (HUD-reticle feel).
- Glow is reserved for active/interactive elements only — restraint is the point;
  this is "corp," not synthwave neon-everywhere.
- Locked/disabled states are desaturated and subtly "redacted" (e.g. a diagonal
  hatch texture) rather than just faded to gray.
- Per `AGENTS.md`: do not rely on daisyUI's prebuilt component classes (`btn`,
  `card`, etc.) for the game-specific look — write custom Tailwind-based components.
  The daisyUI theme-variable plumbing (`data-theme` switching) can stay as the
  mechanism for the Corp/Street toggle below; the visual values it drives change.

## 4. Layout & navigation

A fixed top bar, present on every page:

- **Left**: wordmark "SHUNT" + district tag "// SHUNT 9".
- **Center/right**: wallet HUD (see §5).
- **Right**: nav tabs — `HUB`, `GHOSTWORK`, `CHROME & MEAT`, `THE WEB`,
  `STREET ALCHEMY`.
- **Far right**: theme toggle, replacing the current light/dark daisyUI toggle with
  two cyberpunk-themed modes:
  - **CORP** — brighter/cleaner chrome variant.
  - **STREET** — darker, grimier variant.
  Both stay dark-cyberpunk; only the lighting mood changes. No light mode.

Each craft page has a sub-header below the top bar: craft name, one-line
description, and its progression ladder track (§5) before any page content.

## 5. Core components

### Wallet HUD (lives in the top bar, persistent)

- `Cred` and `Scrip`: small monospace chips, hairline border, no fill —
  `[CRED 142]` `[SCRIP 38]` style. These are plain counters, no risk implied.
- `Heat`: a compact horizontal bar, not a chip, since it's a risk meter — numeric
  readout (`HEAT 64/100`) plus a thin bar that ramps color cyan → amber → red by
  fill percentage. Add a subtle pulse/glow once it crosses ~75% to signal real
  danger; no animation below that.

### Progression ladder track (top of every craft page)

- Horizontal 5-segment track, one segment per tier.
- Reached tiers: solid accent fill. Current tier: glowing. Unreached tiers: dim with
  a diagonal hatch texture (reads as "not yet decrypted," not just "off").
- Current tier's name shown under its segment (e.g. "Feed Skimmer"); the tree's
  one-line description as muted subtext below the track.
- One component, reused on all four craft pages — only the data (tier list, current
  tier, description) changes per tree.

### Shared atoms (reused everywhere)

- **Panel**: surface color + hairline border + optional corner brackets when
  focused/active.
- **Button**: rectangular, uppercase tracked-out label, thin border; fills with
  accent color on hover/active; disabled state is desaturated + hatched, not just
  `opacity-50`.
- **Section header**: small-caps label with a thin horizontal rule, HUD-module
  style — e.g. `// WALLET`, `// FENCING`, `// CONTACTS`.

## 6. Page map

- **Hub** (`/`) — landing page. Two sections:
  - **`// BLACK MARKET`** — Fencing flow (current offer / held item), unchanged
    mechanics.
  - **`// CONTACTS`** — the 5 NPC panels with their trade actions and loyalty bars.
- **Street Alchemy** (`/crafts/street-alchemy`) — the one fully functional craft
  page: ladder track, then Scavenge action, raw materials inventory, recipe list
  (locked/unlocked by tier), assembled goods + sell actions. This is today's
  crafting section, relocated here.
- **Ghostwork**, **Chrome & Meat**, **The Web** (`/crafts/ghostwork`,
  `/crafts/chrome-meat`, `/crafts/the-web`) — stub pages: ladder track at top, then
  a single dormant panel with a short flavor line and no controls (e.g. Ghostwork:
  *"No backdoor cracked yet."*). Styled consistently with the rest so they read as
  dormant, not broken.

## 7. Explicit non-goals (basic first, add later)

- No tier 2–5 unlock mechanics or UI for them yet — ladders only need to render
  tier 0/1 correctly today; design the track to scale to 5 tiers, but don't build
  unlock flows that don't exist.
- No faction-specific color theming (e.g. tinting NPC panels by faction) in this
  pass — flat panel style for all NPCs for now.
- No mobile-specific layout pass — responsive enough not to break, not optimized.
- No animation beyond the Heat-bar pulse and standard hover/active transitions.
