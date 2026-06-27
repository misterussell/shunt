defmodule ShuntWeb.GhostworkSliceTest do
  @moduledoc """
  End-to-end vertical slice (doc "Worked Example") against real seeded content —
  no ETS stubs. Walks the maintenance-relay loop: jack in at the tunnel, scan to
  reveal the abandoned relay, break both ICE layers with Probe only, and confirm
  the decoded log reveals the crew-stash POI back on the physical map.
  """
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shunt.Players

  setup do
    Players.create_player!()
    player_id = Players.get_player!().id

    # Hold a deck and stand in the maintenance tunnel (the "jack in" precondition).
    Players.dispatch(player_id, fn _player ->
      {:ok,
       [
         {:inventory, "jury_rigged_terminal", 1},
         {:set, :location_id, "shunt9_maintenance_tunnel"}
       ], %{}}
    end)

    %{player_id: player_id}
  end

  test "scan reveals the relay, breaking both layers grants the log and decodes it, revealing the stash POI",
       %{conn: conn} do
    {:ok, deck, _html} = live(conn, ~p"/skills/ghostwork")

    # The node is hidden until a scan surfaces its lead.
    refute has_element?(deck, "#break-shunt9_abandoned_relay")

    deck |> element("#scan-button") |> render_click()

    assert has_element?(deck, "#signal-feed", "broadcasting on a frequency")
    assert has_element?(deck, "#break-shunt9_abandoned_relay")

    # Break the ICE.
    deck |> element("#break-shunt9_abandoned_relay") |> render_click()
    assert has_element?(deck, "#ice-modal")

    # Probe-only path: L1 handshake (6 / +3) = 2 probes, L2 archive (9 / +3) = 3 probes.
    for _ <- 1..5, do: deck |> element("#ice-probe") |> render_click()

    assert has_element?(deck, "#ice-modal", "CRACKED")
    deck |> element("#ice-close") |> render_click()

    # Node fully cracked: no longer breakable, both layer rewards applied, mastery ticked.
    refute has_element?(deck, "#break-shunt9_abandoned_relay")
    assert has_element?(deck, "#mastery-ice_maintenance")

    player = Players.get_player!()
    assert Map.get(player.inventory, "maintenance_log", 0) >= 1
    assert "maintenance_log_decoded" in player.knowledge

    # The decoded log reveals a hidden POI back on the physical map.
    {:ok, map, _html} = live(conn, ~p"/map")
    assert has_element?(map, "#start-event-shunt9_maintenance_tunnel_relay_stash")
  end
end
