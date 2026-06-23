defmodule ShuntWeb.MovementLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
  end

  # TODO: test "renders the current location's name and description" — live(conn, ~p"/map"),
  # assert the rendered HTML includes the starting location's name ("Player Squat") and
  # description text (Shunt.World.get_location("shunt9_player_squat"))

  # TODO: test "clicking a move button moves the player to that location" — live(conn,
  # ~p"/map"), click the move button for "shunt9_maintenance_tunnel" (the starting
  # location's only exit), then assert the rendered location updates to "Maintenance Tunnel"
  # and that Shunt.Players.get_player!().location_id == "shunt9_maintenance_tunnel"
end
