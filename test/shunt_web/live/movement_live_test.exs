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
end
