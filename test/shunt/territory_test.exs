defmodule Shunt.TerritoryTest do
  # Reads global content (:locations, :territory) tables; kept sync per the content-ETS house rule.
  use ExUnit.Case, async: false

  alias Shunt.Players.Player
  alias Shunt.Territory

  # Find a catalog entry by its module id (available_modules) or location id (available_relocations).
  defp entry(entries, id) do
    Enum.find(entries, fn
      %{module: %{id: ^id}} -> true
      %{location: %{id: ^id}} -> true
      _ -> false
    end)
  end

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

  describe "install_module/3" do
    test "errors on an unknown module" do
      assert Territory.install_module(%Player{}, "no_such_module", @start) ==
               {:error, :unknown_module}
    end

    test "errors when the module is already owned" do
      player = %Player{modules: ["stash"]}

      assert Territory.install_module(player, "stash", @start) == {:error, :already_owned}
    end

    test "errors when the premises class is too low for the module" do
      # drop_point needs class 2; the squat is class 1.
      player = %Player{premises_id: "shunt9_player_squat", scrip: 1000, cred: 1000}

      assert Territory.install_module(player, "drop_point", @start) ==
               {:error, :premises_class_too_low}
    end

    test "errors when scrip is insufficient" do
      player = %Player{premises_id: "shunt9_player_squat", scrip: 10}

      assert Territory.install_module(player, "stash", @start) == {:error, :insufficient_scrip}
    end

    test "errors when cred is insufficient" do
      # drop_point at the class-2 cold store: scrip ok, cred short.
      player = %Player{premises_id: "shunt9_cold_store", scrip: 1000, cred: 0}

      assert Territory.install_module(player, "drop_point", @start) ==
               {:error, :insufficient_cred}
    end

    test "spends cost and installs a gate module (zero costs omitted)" do
      player = %Player{premises_id: "shunt9_player_squat", scrip: 100}

      assert Territory.install_module(player, "stash", @start) ==
               {:ok, [{:scrip, -40}, {:install_module, "stash"}]}
    end

    test "starts income accrual when installing an income module with no last_collected" do
      player = %Player{
        premises_id: "shunt9_cold_store",
        scrip: 200,
        cred: 50,
        last_collected: nil
      }

      assert Territory.install_module(player, "latticework_bleed", @start) ==
               {:ok,
                [
                  {:scrip, -150},
                  {:cred, -20},
                  {:install_module, "latticework_bleed"},
                  {:set, :last_collected, @start}
                ]}
    end
  end

  describe "relocate/2" do
    test "errors when the target is not a premises (no :premises_class)" do
      player = %Player{premises_id: "shunt9_player_squat", scrip: 1000, cred: 1000}

      assert Territory.relocate(player, "shunt9_maintenance_tunnel") == {:error, :not_a_premises}
    end

    test "errors when the target location is unknown" do
      assert Territory.relocate(%Player{}, "no_such_location") == {:error, :not_a_premises}
    end

    test "errors when the target is not an upgrade (class not greater than current)" do
      # Already at the class-2 cold store; the squat (class 1) is a downgrade.
      player = %Player{premises_id: "shunt9_cold_store", scrip: 1000, cred: 1000}

      assert Territory.relocate(player, "shunt9_player_squat") == {:error, :not_an_upgrade}
    end

    test "errors when scrip is insufficient" do
      player = %Player{premises_id: "shunt9_player_squat", scrip: 10, cred: 1000}

      assert Territory.relocate(player, "shunt9_cold_store") == {:error, :insufficient_scrip}
    end

    test "errors when cred is insufficient" do
      player = %Player{premises_id: "shunt9_player_squat", scrip: 1000, cred: 0}

      assert Territory.relocate(player, "shunt9_cold_store") == {:error, :insufficient_cred}
    end

    test "spends cost and sets the new premises on success" do
      player = %Player{premises_id: "shunt9_player_squat", scrip: 1000, cred: 100}

      assert Territory.relocate(player, "shunt9_cold_store") ==
               {:ok, [{:scrip, -400}, {:cred, -30}, {:set, :premises_id, "shunt9_cold_store"}]}
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

  describe "available_modules/1" do
    test "excludes owned modules" do
      player = %Player{premises_id: "shunt9_player_squat", modules: ["stash"]}

      refute Enum.any?(Territory.available_modules(player), &(&1.module.id == "stash"))
    end

    test "marks a class-met, requirement-met module buyable, with affordability" do
      poor = %Player{premises_id: "shunt9_player_squat", scrip: 0}
      flush = %Player{premises_id: "shunt9_player_squat", scrip: 100}

      assert entry(Territory.available_modules(poor), "stash").status == :buyable
      refute entry(Territory.available_modules(poor), "stash").affordable?
      assert entry(Territory.available_modules(flush), "stash").affordable?
    end

    test "marks a module above the premises class :locked_class" do
      player = %Player{premises_id: "shunt9_player_squat", scrip: 1000, cred: 1000}

      assert entry(Territory.available_modules(player), "drop_point").status == :locked_class
    end
  end

  describe "available_relocations/1" do
    test "offers a higher-class premises with its cost and unlocked class" do
      player = %Player{premises_id: "shunt9_player_squat", scrip: 1000, cred: 100}

      entry = entry(Territory.available_relocations(player), "shunt9_cold_store")
      assert entry.unlocks_class == 2
      assert entry.cost == %{scrip: 400, cred: 30}
      assert entry.status == :available
      assert entry.affordable?
    end

    test "reflects affordability" do
      broke = %Player{premises_id: "shunt9_player_squat", scrip: 0, cred: 0}

      refute entry(Territory.available_relocations(broke), "shunt9_cold_store").affordable?
    end

    test "offers nothing once at the top available class" do
      player = %Player{premises_id: "shunt9_cold_store", scrip: 1000, cred: 1000}

      assert Territory.available_relocations(player) == []
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
