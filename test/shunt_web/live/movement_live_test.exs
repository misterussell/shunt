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

  test "locations with no path from the current one are redacted as ???", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    assert Regex.scan(~r/\?\?\?/, render(view)) |> length() == 5
  end

  test "traveling to a redacted location reveals it on the map", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()
    view |> element("#move-to-shunt9_burned_platform") |> render_click()
    view |> element("#move-to-shunt9_bazaar") |> render_click()

    assert Regex.scan(~r/\?\?\?/, render(view)) |> length() == 1
  end

  # TODO: once MovementLive's "start_event"/"event_choice" handlers and template are
  # implemented (see the TODOs in lib/shunt_web/live/movement_live.ex), add tests at
  # shunt9_player_squat covering:
  #   - the location panel lists each of @location.events by title
  #   - clicking a "start_event" button renders that event's first step text + choice buttons
  #   - clicking a choice that has :next renders the next step
  #   - clicking a choice that completes the event reverts the panel to the description + POI
  #     list, and the event now shows "(completed)"
  #   - Shunt.Players.get_player!().completed_events includes the event id afterward
end
