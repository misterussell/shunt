defmodule Shunt.TerritoryTest do
  # Reads global content (:locations, :territory) tables; kept sync per the content-ETS house rule.
  use ExUnit.Case, async: false

  alias Shunt.Players.Player
  alias Shunt.Territory

  describe "tier/1" do
    test "no modules -> Squatter (tier 1, the default)" do
      assert Territory.tier(%Player{modules: []}) == {1, "Squatter"}
    end

    test "the stash keystone -> Tenant (tier 2)" do
      assert Territory.tier(%Player{modules: ["stash"]}) == {2, "Tenant"}
    end

    test "the latticework_bleed keystone -> Operator (tier 3)" do
      assert Territory.tier(%Player{modules: ["stash", "latticework_bleed"]}) == {3, "Operator"}
    end

    test "the drop_point keystone -> Fixture (tier 4), the deepest v1 rung" do
      player = %Player{modules: ["stash", "latticework_bleed", "drop_point"]}

      assert Territory.tier(player) == {4, "Fixture"}
    end

    test "returns the deepest satisfied tier regardless of module order" do
      assert Territory.tier(%Player{modules: ["drop_point"]}) == {4, "Fixture"}
    end
  end

  describe "premises_class/1" do
    test "reads :premises_class from the player's premises location" do
      assert Territory.premises_class(%Player{premises_id: "shunt9_player_squat"}) == 1
    end

    test "defaults to class 1 for a location without a :premises_class" do
      # The maintenance tunnel is a normal (non-premises) location.
      assert Territory.premises_class(%Player{premises_id: "shunt9_maintenance_tunnel"}) == 1
    end

    test "degrades to class 1 for an unknown premises id (no crash)" do
      assert Territory.premises_class(%Player{premises_id: "no_such_location"}) == 1
    end
  end
end
