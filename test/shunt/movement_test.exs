defmodule Shunt.MovementTest do
  use ExUnit.Case, async: true

  alias Shunt.Movement
  alias Shunt.Players.Player

  describe "can_move?/2" do
    test "returns true when there is a real exit to the destination" do
      player = %Player{location_id: "shunt9_bazaar"}

      assert Movement.can_move?(player, "shunt9_scrap_yard")
    end

    test "returns false when there is no exit between the locations" do
      player = %Player{location_id: "shunt9_scrap_yard"}

      refute Movement.can_move?(player, "shunt9_food_stalls")
    end

    test "returns false when the exit's requirement is unmet" do
      player = %Player{location_id: "shunt9_bazaar", knowledge: []}

      refute Movement.can_move?(player, "shunt9_power_relay")
    end

    test "returns true once the gating knowledge is held" do
      player = %Player{location_id: "shunt9_bazaar", knowledge: ["power_relay_entrance"]}

      assert Movement.can_move?(player, "shunt9_power_relay")
    end

    test "returns false for a destination gated at the location level despite an open exit" do
      player = %Player{location_id: "shunt9_bazaar", knowledge: []}

      refute Movement.can_move?(player, "shunt9_rooks_desk")
    end
  end

  describe "move/2" do
    test "returns effects and a narrative for a connected destination" do
      player = %Player{location_id: "shunt9_bazaar"}

      assert {:ok,
              [
                {:set, :location_id, "shunt9_scrap_yard"},
                {:discover_location, "shunt9_scrap_yard"}
              ], %{narrative: narrative}} = Movement.move(player, "shunt9_scrap_yard")

      assert is_binary(narrative)
      assert narrative != ""
    end

    test "returns an error for an unconnected destination" do
      player = %Player{location_id: "shunt9_scrap_yard"}

      assert Movement.move(player, "shunt9_food_stalls") == {:error, :not_connected}
    end
  end
end
