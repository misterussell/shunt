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

  # TODO: test "clicking a move button appends a narrative entry to the feed" — live(conn,
  # ~p"/map"), click "#move-to-shunt9_maintenance_tunnel", then assert
  # has_element?(view, "#narrative-entries", <expected narrative text>) where the expected
  # text matches Shunt.Movement.move/2's narrative_for/2 output for the Player
  # Squat -> Maintenance Tunnel move (leaving-location name + destination's short_description)

  # TODO: test "moving twice keeps both narrative entries in the feed" — move from Player
  # Squat to Maintenance Tunnel, then back to Player Squat (Maintenance Tunnel's exits
  # include "shunt9_player_squat" — verify via Shunt.World.exits/1), and assert
  # has_element?(view, "#narrative-entries") still shows both narrative lines (the feed
  # accumulates rather than resets each move)

  # TODO: test "undiscovered exits are marked as new and discovered ones as visited" — on
  # initial mount from Player Squat, assert the exit badge for
  # "shunt9_maintenance_tunnel" (not yet in player.discovered_locations) renders the "NEW"
  # badge; after moving there and back to Player Squat, assert that same exit's badge now
  # renders "VISITED" (Shunt.Players.get_player!().discovered_locations now includes
  # "shunt9_maintenance_tunnel")
end
