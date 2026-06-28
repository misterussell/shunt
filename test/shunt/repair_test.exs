defmodule Shunt.RepairTest do
  # async: false — these tests insert a fixture into the global :repairables content table.
  use ExUnit.Case, async: false

  alias Shunt.Players.Player
  alias Shunt.Repair
  alias Shunt.Repair.Repairable

  @repairable %Repairable{
    id: "test_gen",
    name: "Test Generator",
    location_id: "test_loc",
    initial_state: "broken",
    inspect_tiers: [
      %{requirements: [], text: "It's broken."},
      %{requirements: [{:has_item, "soldering_iron"}], text: "Electrical failure."},
      %{requirements: [{:has_item, "probe"}], text: "The starter relay has burned out."}
    ],
    solutions: [
      %{
        id: "improvised",
        label: "Improvised Relay",
        from: ["broken"],
        requirements: [{:has_item, "soldering_iron"}],
        consumes: %{"improvised_relay" => 1},
        result_state: "patched",
        effects: [],
        outcome_text: "You patch it. The lights flicker but hold."
      },
      %{
        id: "standard",
        label: "Standard Relay",
        from: ["broken", "patched"],
        requirements: [{:has_item, "soldering_iron"}],
        consumes: %{"standard_relay" => 1},
        result_state: "repaired",
        effects: [{:modify_rep, "coil", :trust, 1}],
        outcome_text: "It runs clean and steady."
      }
    ],
    state_descriptions: %{"repaired" => "The generator hums."}
  }

  setup do
    :ets.insert(:repairables, {@repairable.id, @repairable})
    on_exit(fn -> :ets.delete(:repairables, @repairable.id) end)
    :ok
  end

  describe "state/2" do
    test "returns the repairable's initial_state when the player has no entry" do
      assert Repair.state(%Player{infrastructure: %{}}, "test_gen") == "broken"
    end

    test "returns the stored state when present" do
      player = %Player{infrastructure: %{"test_gen" => "repaired"}}
      assert Repair.state(player, "test_gen") == "repaired"
    end
  end

  describe "at_location/2" do
    test "returns repairables whose location_id matches" do
      assert Repair.at_location(%Player{}, "test_loc") == [@repairable]
    end

    test "returns [] when no repairable is at the location" do
      assert Repair.at_location(%Player{}, "elsewhere") == []
    end
  end

  describe "inspect/2" do
    test "returns the base diagnosis with no tools" do
      assert Repair.inspect(%Player{inventory: %{}}, @repairable) == "It's broken."
    end

    test "advances to the next tier when its requirements are met" do
      player = %Player{inventory: %{"soldering_iron" => 1}}
      assert Repair.inspect(player, @repairable) == "Electrical failure."
    end

    test "returns the deepest tier when all cumulative requirements are met" do
      player = %Player{inventory: %{"soldering_iron" => 1, "probe" => 1}}
      assert Repair.inspect(player, @repairable) == "The starter relay has burned out."
    end

    test "stops at the last met tier when a shallower tier is unmet" do
      player = %Player{inventory: %{"probe" => 1}}
      assert Repair.inspect(player, @repairable) == "It's broken."
    end
  end

  describe "available_solutions/2" do
    test "returns solutions valid from the current state with reqs and materials met" do
      player = %Player{
        inventory: %{"soldering_iron" => 1, "improvised_relay" => 1, "standard_relay" => 1}
      }

      ids = Enum.map(Repair.available_solutions(player, @repairable), & &1.id)
      assert ids == ["improvised", "standard"]
    end

    test "excludes solutions whose consumed materials are missing" do
      player = %Player{inventory: %{"soldering_iron" => 1, "improvised_relay" => 1}}

      ids = Enum.map(Repair.available_solutions(player, @repairable), & &1.id)
      assert ids == ["improvised"]
    end

    test "excludes solutions whose from-state does not include the current state" do
      player = %Player{
        infrastructure: %{"test_gen" => "patched"},
        inventory: %{"soldering_iron" => 1, "improvised_relay" => 1, "standard_relay" => 1}
      }

      ids = Enum.map(Repair.available_solutions(player, @repairable), & &1.id)
      assert ids == ["standard"]
    end
  end

  describe "repair/3" do
    test "consumes materials, sets the new state, and appends solution effects" do
      player = %Player{inventory: %{"soldering_iron" => 1, "improvised_relay" => 1}}

      {:ok, effects, meta} = Repair.repair(player, "test_gen", "improvised")

      assert effects == [
               {:inventory, "improvised_relay", -1},
               {:infrastructure, "test_gen", "patched"}
             ]

      assert meta == %{
               from: "broken",
               to: "patched",
               outcome_text: @repairable.solutions |> hd() |> Map.fetch!(:outcome_text)
             }
    end

    test "includes the solution's own effects" do
      player = %Player{inventory: %{"soldering_iron" => 1, "standard_relay" => 1}}

      {:ok, effects, _meta} = Repair.repair(player, "test_gen", "standard")

      assert {:modify_rep, "coil", :trust, 1} in effects
      assert {:infrastructure, "test_gen", "repaired"} in effects
    end

    test "upgrades from patched to repaired" do
      player = %Player{
        infrastructure: %{"test_gen" => "patched"},
        inventory: %{"soldering_iron" => 1, "standard_relay" => 1}
      }

      {:ok, _effects, meta} = Repair.repair(player, "test_gen", "standard")
      assert meta.from == "patched"
      assert meta.to == "repaired"
    end

    test "returns {:error, :invalid_solution} for an unknown solution id" do
      assert Repair.repair(%Player{}, "test_gen", "nope") == {:error, :invalid_solution}
    end

    test "returns {:error, :wrong_state} when the solution is not valid from the current state" do
      player = %Player{
        infrastructure: %{"test_gen" => "patched"},
        inventory: %{"soldering_iron" => 1, "improvised_relay" => 1}
      }

      assert Repair.repair(player, "test_gen", "improvised") == {:error, :wrong_state}
    end

    test "returns {:error, :insufficient_materials} when reqs or consumes are unmet" do
      player = %Player{inventory: %{"soldering_iron" => 1}}

      assert Repair.repair(player, "test_gen", "improvised") == {:error, :insufficient_materials}
    end
  end
end
