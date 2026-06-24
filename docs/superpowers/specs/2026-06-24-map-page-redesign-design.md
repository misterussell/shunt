# Map Page Redesign

## Problem

The map page (`ShuntWeb.MovementLive`) currently lays out the current-location
panel and the map graph stacked in a left column, with the narrative feed in
a right column. Both columns are top-aligned (`align-items: start`), so as
the narrative feed grows (stream of movement entries) or the current-location
panel's content changes (different locations have different amounts of
Points-of-Interest/NPC content), the two columns drift to different heights
and the page feels unstable.

Separately, the map graph itself renders the *entire* world by computing an
SVG `viewBox` from the bounding box of every location's `graph_position`. As
the world grows, this means more and more of the map is visible at once,
making it harder to read and less focused on where the player actually is.

## Goals

1. Make the map graph the static, top-of-page focal element.
2. Stop the location and narrative panels from visibly resizing as their
   content changes — fixed-height panels with no scrollbars.
3. Turn the map into a fixed-size "camera" window that follows the player:
   only a handful of nearby zones are visible at once, centered on the
   player's current location, panning smoothly as they move.

## Layout

```
+--------------------------+------------------+
|   MAP VIEWPORT (fixed)   |                  |
|                          |  CURRENT LOCATION|
+--------------------------+  (full column     |
|  legend                  |   height)         |
+--------------------------+                  |
| NARRATIVE_FEED (small,   |                  |
| fixed height, fade)      |                  |
+--------------------------+------------------+
```

- Left column: map viewport (top, fixed height) → legend → narrative feed
  (smaller fixed-height box, below).
- Right column: current-location panel, stretched to the full height of the
  left column — it becomes the dominant panel.

### Equal-height mechanism

`.map-page-grid` switches from `align-items: start` to `align-items: stretch`
(the grid default). With two single-row grid items, this makes the right
column automatically match the left column's total natural height — no JS
measurement, no fixed pixel height shared between columns. The
current-location panel then uses `flex: 1` within its column to fill the
available height below its section header.

## Map camera (windowed, player-centered)

Replace the current "fit the whole world" viewBox computation
(`bounds/1` in `map_graph.ex`) with a fixed-size window centered on the
player:

- The `<svg>` keeps a **constant viewBox**, e.g. `0 0 640 440` (world units —
  a tunable module attribute, sized so a handful of adjacent zones are
  visible given current location spacing of ~150-170 units between
  neighbors).
- All world content (edges, nodes) is wrapped in a single `<g>` whose
  `transform="translate(W/2 - player_x, H/2 - player_y)"` re-centers the
  player's location at the middle of the fixed window.
- Anything outside the window is clipped automatically by the SVG's own
  viewport (default `overflow: hidden` on `<svg>`) — no manual `clip-path`
  needed. This gives hard-edge clipping of out-of-range locations/edges for
  free.
- Panning is animated via a CSS rule on the world group:
  `.map-world { transition: transform 400ms ease-in-out; }`. Browsers
  animate changes to the SVG `transform` attribute the same way they animate
  any CSS transform, so LiveView re-renders with a new center glide rather
  than snap, with no JS hook required.
- The background dot-texture rect and the current-location glow no longer
  need to track world bounds: since the player is always centered, the glow
  is drawn once at the fixed center of the viewport `(W/2, H/2)`, and the
  texture tiles the static viewBox. `bounds/1` is deleted (dead code once
  nothing references full-world bounds).
- Node state logic (`:current`/`:connected`/`:discovered`/`:undiscovered`)
  is unchanged — only the camera/clipping changes, not which locations are
  considered known.

## Panel overflow (fixed heights, no scrollbars)

- **Narrative feed** (left column, small box): fixed height,
  `display: flex; flex-direction: column; justify-content: flex-end;
  overflow: hidden`. Entries are appended to the bottom of the stream as
  today. With `justify-content: flex-end`, once content overflows the fixed
  height, the *oldest* entries clip off the top while the newest stays
  pinned at the bottom visible — no JS auto-scroll needed. A subtle
  gradient-fade pseudo-element softens the top clip edge.
- **Current-location panel** (right column, full height): `overflow:
  hidden` with a bottom-edge fade as a safety net. Since this panel now
  stretches to the full left-column height, overflow is expected to be rare
  in practice, but the fade guard stays in case a location ever has an
  unusually long list of Points of Interest/NPCs. Known tradeoff: if that
  guard ever triggers, the lowest buttons become unreachable (no scrollbar);
  accepted as a deliberate simplicity choice over adding scroll affordances.

## Visual chrome

No palette or font changes. The map viewport keeps the same panel treatment
as the other panels (gradient fill, hairline border, corner brackets on
focus). Section headers (`MAP`, `NARRATIVE_FEED`, and a new header for the
current-location rail) follow the existing `Chrome.section_header` pattern.

## Out of scope

- No changes to event/NPC interaction flow, movement logic, or narrative
  content generation.
- No new accent colors, typefaces, or signature visual elements — this is a
  structural/spacing pass on the existing terminal aesthetic.
- No server-side culling of off-window locations/edges — the world is small
  enough that rendering everything and letting the SVG viewport clip
  visually is sufficient.
