defmodule ShuntWeb.MovementLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
  end

  test "renders the current location's name and description", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    location = Shunt.World.get_location("shunt9_player_squat")

    assert has_element?(view, "#current-location", location.name)
    assert has_element?(view, "#current-location", location.description)
  end

  test "clicking a move button moves the player to that location", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()

    destination = Shunt.World.get_location("shunt9_maintenance_tunnel")
    assert has_element?(view, "#current-location", destination.name)
    assert Shunt.Players.get_player!().location_id == "shunt9_maintenance_tunnel"
  end

  test "clicking a move button appends a narrative entry to the feed", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()

    from = Shunt.World.get_location("shunt9_player_squat")
    to = Shunt.World.get_location("shunt9_maintenance_tunnel")
    expected = "You leave #{from.name}. #{to.short_description}"

    assert has_element?(view, "#narrative-entries", expected)
  end

  test "moving twice keeps both narrative entries in the feed", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()
    view |> element("#move-to-shunt9_player_squat") |> render_click()

    player_squat = Shunt.World.get_location("shunt9_player_squat")
    maintenance_tunnel = Shunt.World.get_location("shunt9_maintenance_tunnel")

    first_entry = "You leave #{player_squat.name}. #{maintenance_tunnel.short_description}"
    second_entry = "You leave #{maintenance_tunnel.name}. #{player_squat.short_description}"

    assert has_element?(view, "#narrative-entries", first_entry)
    assert has_element?(view, "#narrative-entries", second_entry)
  end

  # TODO: replace this test (the #exit-badge-* ids it asserts on go away once the exit-list
  # <ul> in MovementLive is replaced by MapGraph.map_graph/1 — see the TODO in
  # lib/shunt_web/live/movement_live.ex). Rewrite as two assertions on rendered map-node
  # markup instead: (1) before any move, "shunt9_maintenance_tunnel" is the player's only
  # exit and has never been visited — assert the view contains `id="move-to-shunt9_maintenance_tunnel"`
  # (still clickable, since :connected wins over discovery) and is rendered with whatever
  # CSS class/data-attribute map_graph/1 uses to distinguish a :connected node that's NOT yet
  # in player.discovered_locations from one that is, once that attribute is decided during
  # implementation; (2) after moving there and back (`move-to-shunt9_maintenance_tunnel` then
  # `move-to-shunt9_player_squat`), Player Squat's node should now read as :discovered or
  # :connected (it's still the only exit from Maintenance Tunnel) rather than :undiscovered —
  # pick a location further from the start (e.g. assert on "shunt9_bazaar" or
  # "shunt9_power_relay"'s ✕ → real-name transition isn't reachable in 2 moves from
  # shunt9_player_squat, so this test may need a 3rd move added to actually exercise the
  # :undiscovered → :discovered/:connected transition on a node that was never a direct exit).
  test "undiscovered exits are marked as new and discovered ones as visited", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    assert has_element?(view, "#exit-badge-shunt9_maintenance_tunnel", "NEW")

    view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()
    view |> element("#move-to-shunt9_player_squat") |> render_click()

    assert has_element?(view, "#exit-badge-shunt9_maintenance_tunnel", "VISITED")
  end
end
