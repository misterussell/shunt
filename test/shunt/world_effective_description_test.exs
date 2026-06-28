defmodule Shunt.WorldEffectiveDescriptionTest do
  # async: false — inserts a fixture into the global :repairables content table.
  use ExUnit.Case, async: false

  alias Shunt.Players.Player
  alias Shunt.Repair.Repairable
  alias Shunt.World

  @location %{id: "test_loc", description: "Base description."}

  @repairable %Repairable{
    id: "test_gen",
    name: "Test Generator",
    location_id: "test_loc",
    initial_state: "broken",
    inspect_tiers: [%{requirements: [], text: "It's broken."}],
    solutions: [],
    state_descriptions: %{"repaired" => "Worklights flood the bay."}
  }

  setup do
    :ets.insert(:repairables, {@repairable.id, @repairable})
    on_exit(fn -> :ets.delete(:repairables, @repairable.id) end)
    :ok
  end

  describe "effective_description/2" do
    test "returns the base description when no repairable overrides the current state" do
      # broken has no entry in state_descriptions
      assert World.effective_description(%Player{}, @location) == "Base description."
    end

    test "returns the state override when the repairable is in an overridden state" do
      player = %Player{infrastructure: %{"test_gen" => "repaired"}}

      assert World.effective_description(player, @location) == "Worklights flood the bay."
    end

    test "returns the base description for a location with no repairables" do
      location = %{id: "empty_loc", description: "Nothing here."}

      assert World.effective_description(%Player{}, location) == "Nothing here."
    end
  end
end
