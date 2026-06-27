defmodule Shunt.RequirementsTest do
  use ExUnit.Case, async: true

  alias Shunt.Players.Player
  alias Shunt.Requirements

  describe "met?/2 with an empty list" do
    test "is always met" do
      assert Requirements.met?(%Player{}, [])
    end
  end

  describe "met?/2 with {:knows, key}" do
    test "met when the key is in player.knowledge" do
      player = %Player{knowledge: ["rook"]}

      assert Requirements.met?(player, [{:knows, "rook"}])
    end

    test "unmet when the key is absent" do
      refute Requirements.met?(%Player{knowledge: []}, [{:knows, "rook"}])
    end
  end

  describe "met?/2 with {:infra_state, id, state}" do
    test "met when the repairable is in the given state" do
      player = %Player{infrastructure: %{"gen" => "repaired"}}

      assert Requirements.met?(player, [{:infra_state, "gen", "repaired"}])
    end

    test "unmet when the repairable is in a different state" do
      player = %Player{infrastructure: %{"gen" => "broken"}}

      refute Requirements.met?(player, [{:infra_state, "gen", "repaired"}])
    end
  end

  describe "met?/2 with {:contact_known, key}" do
    test "met when the key is in player.contacts" do
      player = %Player{contacts: ["rose_broker"]}

      assert Requirements.met?(player, [{:contact_known, "rose_broker"}])
    end

    test "unmet when the key is absent" do
      refute Requirements.met?(%Player{contacts: []}, [{:contact_known, "rose_broker"}])
    end
  end

  describe "met?/2 with {:rep_at_least, npc, dim, n}" do
    test "met when reputation for the npc/dim is at or above the threshold" do
      player = %Player{reputation: %{"juno" => %{trust: 20}}}

      assert Requirements.met?(player, [{:rep_at_least, "juno", :trust, 20}])
    end

    test "unmet when reputation is below the threshold" do
      player = %Player{reputation: %{"juno" => %{trust: 5}}}

      refute Requirements.met?(player, [{:rep_at_least, "juno", :trust, 20}])
    end

    test "treats a missing npc as 0" do
      refute Requirements.met?(%Player{reputation: %{}}, [{:rep_at_least, "juno", :trust, 1}])
    end

    test "treats a missing dimension as 0" do
      player = %Player{reputation: %{"juno" => %{trust: 50}}}

      refute Requirements.met?(player, [{:rep_at_least, "juno", :favors, 1}])
    end
  end

  describe "met?/2 with {:has_item, key}" do
    test "met when the inventory holds the key at count >= 1" do
      player = %Player{inventory: %{"juno_parcel" => 1}}

      assert Requirements.met?(player, [{:has_item, "juno_parcel"}])
    end

    test "unmet when the inventory count is 0" do
      player = %Player{inventory: %{"juno_parcel" => 0}}

      refute Requirements.met?(player, [{:has_item, "juno_parcel"}])
    end

    test "unmet when the key is absent" do
      refute Requirements.met?(%Player{inventory: %{}}, [{:has_item, "juno_parcel"}])
    end
  end

  describe "met?/2 with {:ghostwork_mastery_at_least, family, n}" do
    test "met when family mastery is at or above the threshold" do
      player = %Player{ghostwork_state: %{"mastery" => %{"ice_corp" => 2}}}

      assert Requirements.met?(player, [{:ghostwork_mastery_at_least, "ice_corp", 2}])
    end

    test "unmet when family mastery is below the threshold" do
      player = %Player{ghostwork_state: %{"mastery" => %{"ice_corp" => 1}}}

      refute Requirements.met?(player, [{:ghostwork_mastery_at_least, "ice_corp", 2}])
    end

    test "treats a missing family as 0" do
      player = %Player{ghostwork_state: %{"mastery" => %{}}}

      refute Requirements.met?(player, [{:ghostwork_mastery_at_least, "ice_corp", 1}])
    end

    test "treats absent ghostwork state as 0" do
      refute Requirements.met?(%Player{ghostwork_state: %{}}, [
               {:ghostwork_mastery_at_least, "ice_corp", 1}
             ])
    end
  end

  describe "met?/2 with {:has_program, action}" do
    setup do
      prog = %{
        id: "test_decryptor",
        name: "Decryptor",
        action: :decrypt,
        progress: 4,
        trace: 3,
        on_weakness: %{progress: 8, trace: 1},
        text: "x"
      }

      :ets.insert(:programs, {prog.id, prog})
      on_exit(fn -> :ets.delete(:programs, prog.id) end)
      :ok
    end

    test "met when the player owns a program of that action type" do
      player = %Player{inventory: %{"test_decryptor" => 1}}

      assert Requirements.met?(player, [{:has_program, :decrypt}])
    end

    test "unmet when the player owns no program of that action type" do
      player = %Player{inventory: %{"test_decryptor" => 1}}

      refute Requirements.met?(player, [{:has_program, :spoof}])
    end

    test "unmet when the player owns no programs at all" do
      refute Requirements.met?(%Player{inventory: %{}}, [{:has_program, :decrypt}])
    end
  end

  describe "met?/2 with {:has_rumor, key}" do
    test "met when the key is in player.rumors" do
      player = %Player{rumors: ["juno_supplier"]}

      assert Requirements.met?(player, [{:has_rumor, "juno_supplier"}])
    end

    test "unmet when the key is absent from player.rumors" do
      refute Requirements.met?(%Player{rumors: []}, [{:has_rumor, "juno_supplier"}])
    end
  end

  describe "met?/2 with multiple requirements" do
    test "requires every requirement to pass" do
      player = %Player{knowledge: ["rook"], reputation: %{"juno" => %{trust: 20}}}

      assert Requirements.met?(player, [{:knows, "rook"}, {:rep_at_least, "juno", :trust, 20}])
    end

    test "fails when any single requirement is unmet" do
      player = %Player{knowledge: ["rook"], reputation: %{"juno" => %{trust: 5}}}

      refute Requirements.met?(player, [{:knows, "rook"}, {:rep_at_least, "juno", :trust, 20}])
    end
  end
end
