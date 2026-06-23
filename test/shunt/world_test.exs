defmodule Shunt.WorldTest do
  use ExUnit.Case, async: true

  alias Shunt.World

  describe "get_location/1" do
    test "returns the location for a known key" do
      assert World.get_location("shunt9_bazaar").name == "Shunt 9 Bazaar"
    end

    test "raises for an unknown key" do
      assert_raise RuntimeError, fn -> World.get_location("unknown") end
    end
  end

  describe "exits/1" do
    test "returns the exit destinations for a known location key" do
      destinations = Enum.map(World.exits("shunt9_bazaar"), & &1.to)

      assert Enum.sort(destinations) ==
               Enum.sort([
                 "shunt9_scrap_yard",
                 "shunt9_food_stalls",
                 "shunt9_power_relay",
                 "shunt9_burned_platform"
               ])
    end
  end

  describe "connected?/2" do
    test "returns true for a real exit pair" do
      assert World.connected?("shunt9_bazaar", "shunt9_scrap_yard")
    end

    test "returns true in the reverse direction since exits are written both ways" do
      assert World.connected?("shunt9_scrap_yard", "shunt9_bazaar")
    end

    test "returns false for two locations with no direct exit between them" do
      refute World.connected?("shunt9_scrap_yard", "shunt9_food_stalls")
    end
  end
end
