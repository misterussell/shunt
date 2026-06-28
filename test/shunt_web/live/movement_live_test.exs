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

    assert render(view) =~ "???"
  end

  test "requirement-gated locations are not shown on the map", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()
    view |> element("#move-to-shunt9_burned_platform") |> render_click()
    view |> element("#move-to-shunt9_bazaar") |> render_click()

    refute has_element?(view, "#move-to-shunt9_power_relay")
    refute has_element?(view, "#move-to-shunt9_rooks_desk")
  end

  test "a gated location appears once the player holds the gating knowledge", %{conn: conn} do
    player_id = Shunt.Players.get_player!().id

    Shunt.Players.dispatch(player_id, fn _player ->
      {:ok, [{:knowledge, "power_relay_entrance"}], %{}}
    end)

    {:ok, view, _html} = live(conn, ~p"/map")

    view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()
    view |> element("#move-to-shunt9_burned_platform") |> render_click()
    view |> element("#move-to-shunt9_bazaar") |> render_click()

    assert has_element?(view, "#move-to-shunt9_power_relay")
  end

  test "traveling to a redacted location reveals it on the map", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()
    view |> element("#move-to-shunt9_burned_platform") |> render_click()
    view |> element("#move-to-shunt9_bazaar") |> render_click()

    assert Regex.scan(~r/\?\?\?/, render(view)) |> length() == 1
  end

  test "the map graph renders inside a fixed map-viewport panel", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    assert has_element?(view, "#map-viewport svg.map-graph")
  end

  test "the current-location panel has its own LOCATION section header", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/map")

    assert has_element?(view, ".section-header", "LOCATION")
  end

  describe "events at shunt9_player_squat" do
    @event_id "shunt9_player_squat_deck"

    test "the location panel lists each of @location.events by title", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      assert has_element?(view, "#location-events", "Broken Deck")
      assert has_element?(view, "#location-events", "Burnt-Out Neural Port")
      assert has_element?(view, "#location-events", "Stolen Kaspav Authority Knowledge-Chits")
    end

    test "clicking a start_event button opens the event modal with the title, first step's text, and choices",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#start-event-#{@event_id}") |> render_click()

      [first_step | _] = Shunt.Events.get!(@event_id).steps

      assert has_element?(view, "#event-modal", "Broken Deck")
      assert render(view) =~ first_line(first_step.text)

      for choice <- first_step.choices do
        assert has_element?(view, "#event-log", choice.label)
      end
    end

    test "the event modal is not present when no event is active", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      refute has_element?(view, "#event-modal")
    end

    test "the location panel still shows the description and Points of Interest while the event modal is open",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#start-event-#{@event_id}") |> render_click()

      location = Shunt.World.get_location("shunt9_player_squat")

      assert has_element?(view, "#current-location", location.description)
      assert has_element?(view, "#location-events", "Broken Deck")
    end

    test "clicking 'Examine circuitry' on the Broken Deck event renders the circuitry step's text",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#start-event-#{@event_id}") |> render_click()
      view |> element("#event-log button", "Examine circuitry") |> render_click()

      circuitry_step = Shunt.Events.get!(@event_id).steps |> Enum.find(&(&1.id == "circuitry"))

      assert has_element?(view, "#event-modal")
      assert render(view) =~ first_line(circuitry_step.text)
    end

    test "clicking a choice that has :next echoes the choice and renders the next step's text",
         %{conn: conn} do
      {_branching_event_id, view} = start_branching_event(conn)

      view |> element("#event-log button", "Go onward") |> render_click()

      assert has_element?(view, "#event-log", "Go onward")
      assert render(view) =~ "middle step text"
    end

    test "starting an event again after it completes resets the transcript to just the first step",
         %{conn: conn} do
      {branching_event_id, view} = start_branching_event(conn)

      view |> element("#event-log button", "Go onward") |> render_click()
      view |> element("#event-log button", "Finish up") |> render_click()

      refute has_element?(view, "#event-modal")

      render_click(view, "start_event", %{"id" => branching_event_id})

      assert render(view) =~ "start step text"
      refute render(view) =~ "middle step text"
    end

    test "clicking a choice with no :next or :complete closes the event modal and reverts the panel to the description + POI list",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#start-event-#{@event_id}") |> render_click()
      view |> element("#event-log button", "Leave it alone") |> render_click()

      location = Shunt.World.get_location("shunt9_player_squat")

      refute has_element?(view, "#event-modal")
      assert has_element?(view, "#current-location", location.description)
      assert has_element?(view, "#location-events", "Broken Deck")
      refute has_element?(view, "#location-events", "Broken Deck (completed)")
    end

    test "Shunt.Players.get_player!().completed_events does not include the event id afterward",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#start-event-#{@event_id}") |> render_click()
      view |> element("#event-log button", "Leave it alone") |> render_click()

      refute @event_id in Shunt.Players.get_player!().completed_events
    end

    test "the event can be started again after leaving it alone", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#start-event-#{@event_id}") |> render_click()
      view |> element("#event-log button", "Leave it alone") |> render_click()
      view |> element("#start-event-#{@event_id}") |> render_click()

      [first_step | _] = Shunt.Events.get!(@event_id).steps

      assert has_element?(view, "#event-modal")
      assert render(view) =~ first_line(first_step.text)
    end

    defp first_line(text), do: text |> String.trim() |> String.split("\n") |> hd()
  end

  describe "npcs at shunt9_maintenance_tunnel" do
    @npc_key "shunt9_maintenance_tunnel_junkie"

    test "the location panel lists the npc present at the location", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()

      assert has_element?(view, "#location-npcs", "Tunnel Junkie")
    end

    test "clicking a start_npc_event button opens the event modal with the npc's current event",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()
      view |> element("#start-npc-#{@npc_key}") |> render_click()

      intro = Shunt.Events.get!("shunt9_maintenance_tunnel_junkie_intro")
      [first_step | _] = intro.steps

      assert has_element?(view, "#event-modal", intro.title)
      assert render(view) =~ first_line(first_step.text)
    end

    test "completing the npc's current event advances progression so the next interaction shows the next story arc",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()
      view |> element("#start-npc-#{@npc_key}") |> render_click()

      view |> element("#event-log button", "Talk to them") |> render_click()

      view
      |> element(
        "#event-log button",
        "Nothing yet, just looking for parts. Trying to make some scrip."
      )
      |> render_click()

      view |> element("#event-log button", "Thanks.") |> render_click()

      view |> element("#start-npc-#{@npc_key}") |> render_click()

      parts_request = Shunt.Events.get!("shunt9_maintenance_tunnel_junkie_parts_request")
      [first_step | _] = parts_request.steps

      assert has_element?(view, "#event-modal", parts_request.title)
      assert render(view) =~ first_line(first_step.text)
    end

    test "completing the parts_request event shows the granted Battered Relay Coil reward",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      view |> element("#move-to-shunt9_maintenance_tunnel") |> render_click()
      view |> element("#start-npc-#{@npc_key}") |> render_click()
      view |> element("#event-log button", "Talk to them") |> render_click()

      view
      |> element(
        "#event-log button",
        "Nothing yet, just looking for parts. Trying to make some scrip."
      )
      |> render_click()

      view |> element("#event-log button", "Thanks.") |> render_click()
      view |> element("#start-npc-#{@npc_key}") |> render_click()
      view |> element("#event-log button", "Did you find anything?") |> render_click()
      view |> element("#event-log button", "Take the coil.") |> render_click()

      assert has_element?(view, "#event-modal")
      assert render(view) =~ "+1 Battered Relay Coil"

      view |> element("#event-log button", "Close") |> render_click()

      refute has_element?(view, "#event-modal")
    end

    test "completing a choice that grants an item keeps the modal open and shows the reward",
         %{conn: conn} do
      {:ok, view} = start_reward_event(conn)

      view |> element("#event-log button", "Take it") |> render_click()

      assert has_element?(view, "#event-modal")
      assert render(view) =~ "+1 Stripped Copper Coil"
      assert has_element?(view, "#event-log button", "Close")
      assert has_element?(view, "#event-log .event-choices--revealed button", "Close")
    end

    test "clicking Close after a reward dismisses the event modal", %{conn: conn} do
      {:ok, view} = start_reward_event(conn)

      view |> element("#event-log button", "Take it") |> render_click()
      view |> element("#event-log button", "Close") |> render_click()

      refute has_element?(view, "#event-modal")
    end

    defp start_reward_event(conn) do
      reward_event_id = "test_movement_live_reward_event"

      :ets.insert(
        :events,
        {reward_event_id,
         %Shunt.Events.Event{
           id: reward_event_id,
           title: "Test Reward Event",
           on_complete: [{:inventory, "stripped_copper_coil", 1}],
           steps: [
             %{
               id: "start",
               text: "start step text",
               choices: [%{label: "Take it", complete: true}]
             }
           ]
         }}
      )

      on_exit(fn -> :ets.delete(:events, reward_event_id) end)

      {:ok, view, _html} = live(conn, ~p"/map")
      render_click(view, "start_event", %{"id" => reward_event_id})

      {:ok, view}
    end

    defp start_branching_event(conn) do
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

      {branching_event_id, view}
    end
  end

  describe "⌁ LATTICE cue" do
    test "is absent by default (no deck, no lattice)", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/map")

      refute has_element?(view, "#lattice-cue")
    end

    test "appears when the player holds a deck at a lattice location", %{conn: conn} do
      squat = Shunt.World.get_location("shunt9_player_squat")
      :ets.insert(:locations, {squat.id, Map.put(squat, :lattice, %{leads: [], filler: []})})
      on_exit(fn -> :ets.insert(:locations, {squat.id, squat}) end)

      Shunt.Players.dispatch(Shunt.Players.get_player!().id, fn _player ->
        {:ok, [{:inventory, "jury_rigged_terminal", 1}], %{}}
      end)

      {:ok, view, _html} = live(conn, ~p"/map")

      assert has_element?(view, "#lattice-cue")
    end
  end

  describe "repair economy" do
    @generator "shunt9_power_relay_generator"

    defp at_power_relay(effects \\ []) do
      Shunt.Players.dispatch(Shunt.Players.get_player!().id, fn _player ->
        {:ok, [{:set, :location_id, "shunt9_power_relay"} | effects], %{}}
      end)
    end

    test "lists a repairable at the current location with its state", %{conn: conn} do
      at_power_relay()

      {:ok, view, _html} = live(conn, ~p"/map")

      assert has_element?(view, "#inspect-repairable-#{@generator}")
      assert has_element?(view, "#inspect-repairable-#{@generator}", "broken")
    end

    test "inspecting a repairable shows the diagnosis", %{conn: conn} do
      at_power_relay()

      {:ok, view, _html} = live(conn, ~p"/map")
      view |> element("#inspect-repairable-#{@generator}") |> render_click()

      assert has_element?(view, "#repair-modal")
      assert has_element?(view, "#repair-diagnosis", "It's dead.")
    end

    test "the diagnosis deepens when the player holds the right tool", %{conn: conn} do
      at_power_relay([{:inventory, "scrap_forged_soldering_iron", 1}])

      {:ok, view, _html} = live(conn, ~p"/map")
      view |> element("#inspect-repairable-#{@generator}") |> render_click()

      assert has_element?(view, "#repair-diagnosis", "electrical fault")
    end

    test "applying a repair changes the state and swaps the location description", %{conn: conn} do
      at_power_relay([
        {:inventory, "scrap_forged_soldering_iron", 1},
        {:inventory, "improvised_relay", 1}
      ])

      {:ok, view, _html} = live(conn, ~p"/map")
      view |> element("#inspect-repairable-#{@generator}") |> render_click()
      view |> element("#apply-repair-#{@generator}-improvised") |> render_click()

      assert Shunt.Players.get_player!().infrastructure[@generator] == "patched"
      assert has_element?(view, "#current-location", "no longer sits half in shadow")
      assert has_element?(view, "#inspect-repairable-#{@generator}", "patched")
    end

    test "a full repair unlocks the powered-on point of interest", %{conn: conn} do
      at_power_relay([
        {:inventory, "scrap_forged_soldering_iron", 1},
        {:inventory, "standard_relay", 1}
      ])

      {:ok, view, _html} = live(conn, ~p"/map")
      refute has_element?(view, "#start-event-shunt9_power_relay_backup_online")

      view |> element("#inspect-repairable-#{@generator}") |> render_click()
      view |> element("#apply-repair-#{@generator}-standard") |> render_click()

      assert Shunt.Players.get_player!().infrastructure[@generator] == "repaired"
      assert has_element?(view, "#start-event-shunt9_power_relay_backup_online")
    end

    test "inspecting an id that is not a repairable at the location does not open the modal",
         %{conn: conn} do
      at_power_relay()

      {:ok, view, _html} = live(conn, ~p"/map")
      render_click(view, "inspect_repairable", %{"id" => "not_a_repairable_here"})

      refute has_element?(view, "#repair-modal")
    end

    test "a repair that can't be applied reports why instead of doing nothing", %{conn: conn} do
      # At the relay with the tool but no relay parts: applying still fails and must surface feedback.
      at_power_relay([{:inventory, "scrap_forged_soldering_iron", 1}])

      {:ok, view, _html} = live(conn, ~p"/map")
      render_click(view, "apply_repair", %{"id" => @generator, "solution" => "improvised"})

      assert Shunt.Players.get_player!().infrastructure[@generator] == nil
      assert has_element?(view, ".footer-ticker-status", "won't take")
    end
  end
end
