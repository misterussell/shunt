defmodule Shunt.EventsTest do
  # async: false — setup mutates the shared, global :events ETS table with a synthetic
  # fixture event, which would otherwise race with other test modules' reads of :events.
  use ExUnit.Case, async: false

  alias Shunt.Events
  alias Shunt.Events.Event
  alias Shunt.Players.Player

  @event_id "test_branching_event"

  setup do
    event = %Event{
      id: @event_id,
      title: "Test Branching Event",
      on_complete: [
        {:npc_progression, "test_npc", 1},
        {:inventory, "test_item", 2},
        {:inventory, "junk_item", -1}
      ],
      steps: [
        %{
          id: "start",
          text: "start text",
          choices: [
            %{label: "Branch onward", next: "middle"},
            %{label: "Bail immediately", complete: true},
            %{label: "Take the bad path", next: "dead_end"},
            %{label: "Leave it alone"}
          ]
        },
        %{
          id: "middle",
          text: "middle text",
          choices: [
            %{label: "Finish up", complete: true}
          ]
        },
        %{
          id: "dead_end",
          text: "dead end text",
          rewards: [{:knowledge, :test}],
          choices: [
            %{label: "Close it out", complete: true}
          ]
        }
      ]
    }

    :ets.insert(:events, {@event_id, event})
    on_exit(fn -> :ets.delete(:events, @event_id) end)

    :ok
  end

  describe "get!/1" do
    test "returns the event for a known id" do
      assert Events.get!("shunt9_player_squat_deck").title == "Broken Deck"
    end

    test "raises for an unknown id" do
      assert_raise RuntimeError, fn -> Events.get!("unknown") end
    end
  end

  describe "current_step/2" do
    test "returns the first step for a player with no event_state entry" do
      player = %Player{event_state: %{}}

      assert Events.current_step(player, @event_id).id == "start"
    end

    test "returns the recorded step when event_state has a current_step" do
      player = %Player{event_state: %{@event_id => %{"current_step" => "middle"}}}

      assert Events.current_step(player, @event_id).id == "middle"
    end
  end

  describe "start/2" do
    test "returns effects pointing at the event's first step" do
      player = %Player{event_state: %{}}

      assert {:ok, [{:set, :event_state, new_state}], _meta} = Events.start(player, @event_id)
      assert new_state[@event_id]["current_step"] == "start"
    end
  end

  describe "choose/3" do
    test "a valid non-terminal choice advances event_state's current_step" do
      player = %Player{event_state: %{}, completed_events: []}

      assert {:ok, [{:set, :event_state, new_state}], _meta} =
               Events.choose(player, @event_id, "Branch onward")

      assert new_state[@event_id]["current_step"] == "middle"
    end

    test "a valid terminal choice sets completed_events and clears event_state for that event_id" do
      player = %Player{
        event_state: %{
          @event_id => %{"current_step" => "start"},
          "other_event" => %{"current_step" => "x"}
        },
        completed_events: ["another_event"]
      }

      assert {:ok, effects, _meta} = Events.choose(player, @event_id, "Bail immediately")

      assert {:set, :completed_events, [@event_id, "another_event"]} in effects
      assert {:set, :event_state, %{"other_event" => %{"current_step" => "x"}}} in effects
    end

    test "completing an event prepends the event's on_complete effects" do
      player = %Player{event_state: %{}, completed_events: []}

      assert {:ok, effects, _meta} = Events.choose(player, @event_id, "Bail immediately")

      assert {:npc_progression, "test_npc", 1} in effects
    end

    test "completing an event returns positive :inventory grants from on_complete as granted_items in meta" do
      player = %Player{event_state: %{}, completed_events: []}

      assert {:ok, _effects, meta} = Events.choose(player, @event_id, "Bail immediately")

      assert meta.granted_items == [{"test_item", 2}]
    end

    test "a choice that leads to a terminal step transitions current_step without completing" do
      player = %Player{
        event_state: %{@event_id => %{"current_step" => "start"}},
        completed_events: []
      }

      assert {:ok, effects, _meta} = Events.choose(player, @event_id, "Take the bad path")

      assert {:set, :event_state, %{@event_id => %{"current_step" => "dead_end"}}} in effects
      refute Enum.any?(effects, &match?({:set, :completed_events, _}, &1))
    end

    test "choosing a terminal step's own closing choice completes the event" do
      player = %Player{
        event_state: %{
          @event_id => %{"current_step" => "dead_end"},
          "other_event" => %{"current_step" => "x"}
        },
        completed_events: ["another_event"]
      }

      assert {:ok, effects, _meta} = Events.choose(player, @event_id, "Close it out")

      assert {:set, :completed_events, [@event_id, "another_event"]} in effects
      assert {:set, :event_state, %{"other_event" => %{"current_step" => "x"}}} in effects
    end

    test "a choice with neither :next nor :complete closes the event without completing it" do
      player = %Player{
        event_state: %{
          @event_id => %{"current_step" => "start"},
          "other_event" => %{"current_step" => "x"}
        },
        completed_events: ["another_event"]
      }

      assert {:ok, effects, _meta} = Events.choose(player, @event_id, "Leave it alone")

      assert {:set, :event_state, %{"other_event" => %{"current_step" => "x"}}} in effects
      refute Enum.any?(effects, &match?({:set, :completed_events, _}, &1))
    end

    test "a choice label not on the current step returns {:error, :invalid_choice}" do
      player = %Player{event_state: %{}, completed_events: []}

      assert Events.choose(player, @event_id, "Not a real choice") == {:error, :invalid_choice}
    end

    test "an event already in completed_events returns {:error, :already_completed}" do
      player = %Player{event_state: %{}, completed_events: [@event_id]}

      assert Events.choose(player, @event_id, "Branch onward") == {:error, :already_completed}
    end
  end
end
