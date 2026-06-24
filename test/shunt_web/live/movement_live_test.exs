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

  describe "events at shunt9_player_squat" do
    @event_id "shunt9_player_squat_deck"

    test "the location panel lists each of @location.events by title", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      assert has_element?(view, "#location-events", "Broken Deck")
      assert has_element?(view, "#location-events", "Burnt-Out Neural Port")
      assert has_element?(view, "#location-events", "Stolen Kaspav Authority Knowledge-Chits")
    end

    test "clicking a start_event button renders that event's first step text + choice buttons",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#start-event-#{@event_id}") |> render_click()

      [first_step | _] = Shunt.Events.get!(@event_id).steps
      first_line = first_step.text |> String.trim() |> String.split("\n") |> hd()

      assert has_element?(view, "#event-step-text", first_line)

      for choice <- first_step.choices do
        assert has_element?(view, "##{choice_dom_id(choice.label)}", choice.label)
      end
    end

    test "clicking a choice that has :next renders the next step", %{conn: conn} do
      branching_event_id = "test_movement_live_branching_event"

      :ets.insert(
        :events,
        {branching_event_id,
         %Shunt.Events.Event{
           id: branching_event_id,
           title: "Test Branching Event",
           steps: [
             %{
               id: "start",
               text: "start step text",
               choices: [%{label: "Go onward", next: "middle"}]
             },
             %{
               id: "middle",
               text: "middle step text",
               choices: [%{label: "Finish up", complete: true}]
             }
           ]
         }}
      )

      on_exit(fn -> :ets.delete(:events, branching_event_id) end)

      {:ok, view, _html} = live(conn, ~p"/map")

      render_click(view, "start_event", %{"id" => branching_event_id})

      render_click(view, "event_choice", %{
        "event_id" => branching_event_id,
        "choice" => "Go onward"
      })

      assert has_element?(view, "#event-step-text", "middle step text")
    end

    test "clicking a choice that completes the event reverts the panel to the description + POI list",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#start-event-#{@event_id}") |> render_click()
      view |> element("##{choice_dom_id("Leave it alone")}") |> render_click()

      location = Shunt.World.get_location("shunt9_player_squat")

      refute has_element?(view, "#active-event")
      assert has_element?(view, "#current-location", location.description)
      assert has_element?(view, "#location-events", "Broken Deck (completed)")
    end

    test "Shunt.Players.get_player!().completed_events includes the event id afterward",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#start-event-#{@event_id}") |> render_click()
      view |> element("##{choice_dom_id("Leave it alone")}") |> render_click()

      assert @event_id in Shunt.Players.get_player!().completed_events
    end
  end

  defp choice_dom_id(label), do: "event-choice-" <> String.replace(label, " ", "-")
end
