defmodule Shunt.RequirementsTest do
  # async: false — the {:has_program} test inserts/deletes in the global :programs ETS table; must
  # not run concurrently with tests that read it (e.g. programs_content_test).
  use ExUnit.Case, async: false

  alias Shunt.Players.Player
  alias Shunt.Requirements

  describe "met?/2 with an empty list" do
    test "is always met" do
      assert Requirements.met?(%Player{}, [])
    end
  end

  describe "deepest_met_tier/2" do
    @tiers [
      %{requirements: [], text: "base"},
      %{requirements: [{:knows, "x"}], text: "deeper"}
    ]

    test "returns the deepest tier whose requirements are met, scanning top-down" do
      assert Requirements.deepest_met_tier(%Player{}, @tiers).text == "base"
      assert Requirements.deepest_met_tier(%Player{knowledge: ["x"]}, @tiers).text == "deeper"
    end

    test "stops at the first unmet tier (tiers are treated as cumulative)" do
      tiers = [
        %{requirements: [], text: "base"},
        %{requirements: [{:knows, "x"}], text: "gated"},
        %{requirements: [], text: "ungated_but_unreachable"}
      ]

      assert Requirements.deepest_met_tier(%Player{}, tiers).text == "base"
    end

    test "returns nil when no tier matches" do
      assert Requirements.deepest_met_tier(%Player{}, [
               %{requirements: [{:knows, "x"}], text: "a"}
             ]) ==
               nil
    end

    test "returns nil for an empty tier list" do
      assert Requirements.deepest_met_tier(%Player{}, []) == nil
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

  describe "met?/2 with {:has_module, key}" do
    test "met when the key is in player.modules" do
      player = %Player{modules: ["stash"]}

      assert Requirements.met?(player, [{:has_module, "stash"}])
    end

    test "unmet when the key is absent" do
      refute Requirements.met?(%Player{modules: []}, [{:has_module, "stash"}])
    end
  end

  describe "met?/2 with {:premises_at_least, class}" do
    test "met when the premises class is at or above the threshold" do
      player = %Player{premises_id: "shunt9_player_squat"}

      assert Requirements.met?(player, [{:premises_at_least, 1}])
    end

    test "unmet when the premises class is below the threshold" do
      player = %Player{premises_id: "shunt9_player_squat"}

      refute Requirements.met?(player, [{:premises_at_least, 2}])
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

    test "unmet (degrades, no crash) when the repairable id is unknown" do
      player = %Player{infrastructure: %{}}

      refute Requirements.met?(player, [{:infra_state, "no_such_repairable", "repaired"}])
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

  describe "met?/2 with {:district, district_id, fact, op, target}" do
    test "met when the derived district fact satisfies :>=" do
      player = %Player{infrastructure: %{"shunt9_power_relay_generator" => "repaired"}}

      assert Requirements.met?(player, [{:district, "shunt9", :power, :>=, :online}])
    end

    test "unmet when the derived district fact is below the :>= target" do
      refute Requirements.met?(%Player{}, [{:district, "shunt9", :power, :>=, :online}])
    end

    test "met when the derived district fact satisfies :<" do
      assert Requirements.met?(%Player{}, [{:district, "shunt9", :power, :<, :online}])
    end

    test "unmet when the derived district fact does not satisfy :<" do
      player = %Player{infrastructure: %{"shunt9_power_relay_generator" => "repaired"}}

      refute Requirements.met?(player, [{:district, "shunt9", :power, :<, :online}])
    end

    test "degrades to unmet (no crash) on an unknown district fact, like {:infra_state, ...}" do
      refute Requirements.met?(%Player{}, [{:district, "shunt9", :no_such_fact, :>=, :online}])
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

  describe "met?/2 with {:has_implant, key}" do
    test "met when the implant is installed (present in player.implants)" do
      player = %Player{implants: %{"lineman_graft" => %{}}}

      assert Requirements.met?(player, [{:has_implant, "lineman_graft"}])
    end

    test "unmet when the implant is not installed" do
      refute Requirements.met?(%Player{implants: %{}}, [{:has_implant, "lineman_graft"}])
    end
  end

  describe "met?/2 with {:chrome_load_at_least, n}" do
    test "met when chrome_load is at or above the threshold" do
      assert Requirements.met?(%Player{chrome_load: 30}, [{:chrome_load_at_least, 30}])
    end

    test "unmet when chrome_load is below the threshold" do
      refute Requirements.met?(%Player{chrome_load: 29}, [{:chrome_load_at_least, 30}])
    end
  end

  describe "met?/2 with {:chrome_load_below, n}" do
    test "met when chrome_load is under the threshold" do
      assert Requirements.met?(%Player{chrome_load: 29}, [{:chrome_load_below, 30}])
    end

    test "unmet when chrome_load is at or above the threshold" do
      refute Requirements.met?(%Player{chrome_load: 30}, [{:chrome_load_below, 30}])
    end
  end
end
