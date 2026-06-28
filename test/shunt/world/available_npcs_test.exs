defmodule Shunt.World.AvailableNpcsTest do
  # async: false — inserts a fixture location into the global :locations content table.
  use ExUnit.Case, async: false

  alias Shunt.Players.Player
  alias Shunt.World

  @loc_id "test_available_npcs_loc"

  setup do
    location = %{
      id: @loc_id,
      name: "Fixture",
      npcs: [
        "always_here",
        %{id: "gated_here", requirements: [{:knows, "the_password"}]}
      ]
    }

    :ets.insert(:locations, {@loc_id, location})
    on_exit(fn -> :ets.delete(:locations, @loc_id) end)
    :ok
  end

  test "a bare-string npc entry is always returned" do
    assert "always_here" in World.available_npcs(%Player{}, @loc_id)
  end

  test "a gated map npc entry is omitted when its requirements are unmet" do
    refute "gated_here" in World.available_npcs(%Player{knowledge: []}, @loc_id)
  end

  test "a gated map npc entry is returned when its requirements are met" do
    player = %Player{knowledge: ["the_password"]}

    assert "gated_here" in World.available_npcs(player, @loc_id)
  end
end
