defmodule ShuntWeb.Components.MapGraphTest do
  use ExUnit.Case, async: true

  # TODO: import Phoenix.LiveViewTest and `use Phoenix.Component`, then alias
  # ShuntWeb.Components.MapGraph — mirror test/shunt_web/components/chrome_test.exs's
  # render_component/wrapper-component pattern (e.g. `render_component(&map_graph_wrapper/1,
  # %{player: player, locations: locations})` where the wrapper does
  # `<MapGraph.map_graph player={@player} locations={@locations} />`). Private
  # node_state/edge_style logic is tested indirectly through the rendered markup, the same way
  # ChromeTest covers Chrome's private heat_label/1 only through wallet_hud's output — don't
  # make node_state/edge_style public just to unit test them directly.

  # TODO: build one small fixture: a player map with `location_id: "a"` and
  # `discovered_locations: ["a", "b"]`, plus 4 plain location maps shaped like
  # Shunt.World.get_location/1's return value (%{key:, name:, graph_position:, exits: [...]})
  # — "a" (current), "b" (direct exit from "a", also already discovered — exercises the
  # :connected-wins-over-:discovered rule), "c" (direct exit from "a", never visited), "d"
  # (no exit from "a", not in discovered_locations). Reuse this fixture across the tests below.

  # TODO: test "the current location renders as a filled node with no move handler" — assert
  # the rendered html contains location "a"'s real name and does NOT contain
  # `id="move-to-a"`.

  # TODO: test "a directly-connected, never-visited location renders bright and clickable" —
  # assert the html contains `id="move-to-c"`, `phx-click="move_to"`, and location "c"'s real
  # name (not "???").

  # TODO: test "a directly-connected, already-discovered location is still clickable" — assert
  # the html contains `id="move-to-b"` (connectivity wins over discovery for clickability).

  # TODO: test "a location with no exit from current renders its real name but is not
  # clickable" — using a 5th fixture location "e" that's in discovered_locations but not a
  # direct exit from "a", assert its real name appears and no `id="move-to-e"` is present.

  # TODO: test "an undiscovered, unreachable location renders redacted and is not clickable" —
  # assert the html contains "???" instead of location "d"'s real name, and no
  # `id="move-to-d"`.

  # TODO: test "map_legend/1 renders all four legend rows" — render `<MapGraph.map_legend />`
  # via the same wrapper pattern and assert the html contains the four legend labels (match the
  # exact copy once map_legend/1 ships).
end
