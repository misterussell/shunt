defmodule Shunt.TerritoryTest do
  # Reads global content (:locations, :territory) tables; kept sync per the content-ETS house rule.
  use ExUnit.Case, async: false

  alias Shunt.Players.Player
  alias Shunt.Territory

  # The Latticework Bleed is the v1 income module: rate 5 scrip/hr, cap_hours 12 (cap 60), trace 1
  # Heat per 30 scrip. These assertions track those authored starter values.
  @start ~U[2026-06-30 00:00:00Z]

  describe "income_rate/1 and reservoir_cap/1" do
    test "are 0 with no income modules (gate-only or empty)" do
      assert Territory.income_rate(%Player{modules: []}) == 0
      assert Territory.reservoir_cap(%Player{modules: []}) == 0
      # an unauthored / gate module contributes nothing
      assert Territory.income_rate(%Player{modules: ["stash"]}) == 0
    end

    test "sum the rate and capacity of installed income modules" do
      player = %Player{modules: ["latticework_bleed"]}

      assert Territory.income_rate(player) == 5
      assert Territory.reservoir_cap(player) == 60
    end
  end

  describe "reservoir/2" do
    test "is 0 when last_collected is nil (no accrual started)" do
      player = %Player{modules: ["latticework_bleed"], last_collected: nil}

      assert Territory.reservoir(player, @start) == 0
    end

    test "accrues rate * elapsed hours before the cap" do
      player = %Player{modules: ["latticework_bleed"], last_collected: @start}
      now = DateTime.add(@start, 3 * 3600, :second)

      assert Territory.reservoir(player, now) == 15
    end

    test "caps at the reservoir cap" do
      player = %Player{modules: ["latticework_bleed"], last_collected: @start}
      now = DateTime.add(@start, 100 * 3600, :second)

      assert Territory.reservoir(player, now) == 60
    end

    test "clamps negative elapsed (clock skew) to 0" do
      player = %Player{modules: ["latticework_bleed"], last_collected: @start}
      now = DateTime.add(@start, -5 * 3600, :second)

      assert Territory.reservoir(player, now) == 0
    end
  end

  describe "collect/2" do
    test "errors with :nothing_to_collect when the reservoir is empty" do
      player = %Player{modules: ["latticework_bleed"], last_collected: nil}

      assert Territory.collect(player, @start) == {:error, :nothing_to_collect}
    end

    test "banks the reservoir, charges trace Heat scaled to the take, and resets the clock" do
      player = %Player{modules: ["latticework_bleed"], last_collected: @start}
      now = DateTime.add(@start, 12 * 3600, :second)

      # full 60-scrip reservoir; trace 1 Heat / 30 scrip -> +2 Heat
      assert Territory.collect(player, now) ==
               {:ok, [{:scrip, 60}, {:heat, 2}, {:set, :last_collected, now}]}
    end
  end

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
