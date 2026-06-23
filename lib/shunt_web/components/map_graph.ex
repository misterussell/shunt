defmodule ShuntWeb.Components.MapGraph do
  @moduledoc false

  use Phoenix.Component

  # TODO: implement `node_state(location, player)` returning one of
  # `:current | :connected | :discovered | :undiscovered`:
  #   - :current      when location.key == player.location_id
  #   - :connected    when Shunt.World.connected?(player.location_id, location.key) — this
  #                   wins over :discovered regardless of whether location.key is already in
  #                   player.discovered_locations, because a reachable neighbor is always
  #                   shown bright/clickable even before the player has ever been there
  #   - :discovered   when location.key in player.discovered_locations (and neither of the
  #                   above matched)
  #   - :undiscovered otherwise
  # Add `alias Shunt.World` at the top of this module when implementing.

  # TODO: implement `edges(locations)` returning a deduped list of `{location_a, location_b}`
  # tuples (full location structs, not just keys) covering every connection in the graph
  # exactly once, even though each connection is stored as two one-directional
  # `Shunt.World.Exit` structs (one in each location's `exits` list). Dedupe by sorting each
  # pair's keys before uniq-ing:
  #   by_key = Map.new(locations, &{&1.key, &1})
  #   locations
  #   |> Enum.flat_map(fn loc -> Enum.map(loc.exits, &{loc.key, &1.to}) end)
  #   |> Enum.uniq_by(fn {a, b} -> Enum.sort([a, b]) end)
  #   |> Enum.map(fn {a, b} -> {by_key[a], by_key[b]} end)

  # TODO: implement `edge_style(state_a, state_b)` returning `:active | :known | :unknown`:
  #   - :active  when :current is one of the two states (this edge is a literal move option
  #              from where the player is standing right now)
  #   - :unknown when :undiscovered is one of the two states and :current is not
  #   - :known   otherwise (both ends at least discovered, neither end is current)

  # TODO: implement `break_points(t_fractions, {x1, y1}, {x2, y2})` — given a list of
  # fractions along the edge (e.g. `[0.35, 0.65]` for a 2-grate edge, `[0.5]` for a 1-grate
  # edge) and the two endpoint graph_position tuples, return the lerped `{x, y}` center point
  # for each fraction: `{x1 + (x2 - x1) * t, y1 + (y2 - y1) * t}`. This places the
  # broken-hatch grate icons generically along any edge angle, not just the axis-aligned ones
  # in the current 7-location graph.

  # TODO: implement the `map_graph/1` function component.
  # Attrs: `:player` (required, the current %Shunt.Players.Player{}), `:locations` (required,
  # list of all locations from `Shunt.World.all_locations/0`).
  #
  # Renders, porting the visual treatment 1:1 from the approved mockup at
  # .superpowers/brainstorm/162690-1782257871/content/visual-style-a-gritty-v2.html:
  #   - an outer <svg viewBox="..."> sized to bound every location's graph_position with a
  #     ~50px margin on each side — compute min/max x/y across `@locations` rather than
  #     hardcoding the current 7-location bounding box, so new locations don't get clipped
  #   - <defs>: PCB dot-grid pattern, grain filter (feTurbulence + feColorMatrix), the "rough"
  #     hand-etched wobble filter (feTurbulence + feDisplacementMap), a radial burn-smudge
  #     gradient, and hatch patterns (amber-stroked for grates on :active/:known edges and the
  #     pad fill on :undiscovered nodes' "blank" look needs its own dimmer muted hatch)
  #   - background: dot-grid rect, grain overlay rect, 2 grime-streak lines
  #   - one burn-smudge rect centered on the current location's graph_position
  #   - for each `{loc_a, loc_b}` in `edges(locations)`: split into 2 segments (1 grate, via
  #     `break_points([0.5], ...)`) or 3 segments (2 grates, via `break_points([0.35, 0.65],
  #     ...)`) depending on `edge_style(node_state(loc_a, player), node_state(loc_b, player))`
  #     — :active/:known edges get 2 grates, :unknown edges get 1 — with a small hatch-filled
  #     square centered on each break point; stroke color/width/glow driven by edge style
  #     (:active = bright cyan + glow filter, :known = muted solid, :unknown = dim dashed)
  #   - for each location: a rotated-45° diamond pad styled per `node_state/2`:
  #       :current      — filled cyan + glow filter + corner-bracket reticle (4 corner ticks)
  #       :connected    — hollow cyan outline, "rough" wobble filter applied
  #       :discovered   — hollow muted outline, opacity 0.7, "rough" wobble filter applied
  #       :undiscovered — hatch-filled outline (dimmer muted hatch) + a bold ✕ path overlay
  #     plus a small solder-blob ellipse at the node center for :current/:connected only
  #   - a name label below each node: the real `location.name` for :current/:connected/
  #     :discovered, the literal string "???" for :undiscovered
  #   - for `:connected` nodes only: a transparent oversized hit-circle (r ~20) layered on top
  #     with `id={"move-to-#{location.key}"}` and `phx-click="move_to"
  #     phx-value-destination={location.key}` — reuses MovementLive's existing
  #     `handle_event("move_to", ...)` unchanged
  #
  # Keep all colors as the existing CSS custom properties (var(--cyan), var(--amber),
  # var(--muted), var(--border-c)) via inline SVG style/stroke/fill attribute values, not
  # literal hex, so theme switching (street/corp) still recolors the map.
  #
  # attr :player, :map, required: true
  # attr :locations, :list, required: true
  #
  # def map_graph(assigns)

  # TODO: implement `map_legend/1` (no attrs) — a static 4-row key, one row per node state:
  # "●  CURRENT LOCATION" (cyan), "○  CONNECTED" (bright cyan), "○  DISCOVERED" (dim muted),
  # "✕  UNDISCOVERED" (dim muted). Rendered alongside `map_graph/1` in MovementLive.
  #
  # def map_legend(assigns)
end
