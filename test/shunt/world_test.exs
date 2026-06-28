defmodule Shunt.WorldTest do
  use ExUnit.Case, async: true

  alias Shunt.Players.Player
  alias Shunt.World

  # TODO: integration test for a district-gated point of interest (pure content, no new code —
  # points_of_interest/2 already filters by requirements). Author a new POI event at a Shunt 9
  # location with requirements [{:district, "shunt9", :power, :>=, :online}], following the SHUNT
  # content docs (steps/choices/on_complete). Test: World.points_of_interest(player, location_id)
  # excludes the event id while power is offline and includes it once the generator is repaired
  # (set player.infrastructure). Assert the specific event id's presence/absence, not counts.

  describe "get_location/1" do
    test "returns the location for a known key" do
      assert World.get_location("shunt9_bazaar").name == "Shunt 9 Bazaar"
    end

    test "raises for an unknown key" do
      assert_raise RuntimeError, fn -> World.get_location("unknown") end
    end
  end

  describe "exits/1" do
    test "returns Shunt.World.Exit structs" do
      assert [%World.Exit{} | _] = World.exits("shunt9_bazaar")
    end

    test "returns the exit destinations for a known location key" do
      destinations = Enum.map(World.exits("shunt9_bazaar"), & &1.to)

      assert "shunt9_scrap_yard" in destinations
      assert "shunt9_food_stalls" in destinations
    end
  end

  describe "all_locations/0" do
    test "returns the seeded locations" do
      assert "shunt9_bazaar" in Enum.map(World.all_locations(), & &1.id)
    end

    test "every returned location has a graph_position tuple" do
      assert Enum.all?(World.all_locations(), &match?({_, _}, &1.graph_position))
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

  describe "location_accessible?/2" do
    test "is true for a location with no requirements" do
      assert World.location_accessible?(%Player{}, "shunt9_bazaar")
    end

    test "is false for a requirement-gated location the player has not unlocked" do
      refute World.location_accessible?(%Player{knowledge: []}, "shunt9_rooks_desk")
    end

    test "is true once the gating knowledge is held" do
      assert World.location_accessible?(%Player{knowledge: ["rook"]}, "shunt9_rooks_desk")
    end
  end

  describe "available_exits/2" do
    test "omits an exit whose own requirements are unmet" do
      destinations =
        %Player{knowledge: []}
        |> World.available_exits("shunt9_bazaar")
        |> Enum.map(& &1.to)

      assert "shunt9_scrap_yard" in destinations
      refute "shunt9_power_relay" in destinations
    end

    test "includes a gated exit once its requirement is met" do
      destinations =
        %Player{knowledge: ["power_relay_entrance"]}
        |> World.available_exits("shunt9_bazaar")
        |> Enum.map(& &1.to)

      assert "shunt9_power_relay" in destinations
    end

    test "omits an exit to a location gated at the location level" do
      without =
        %Player{knowledge: []}
        |> World.available_exits("shunt9_bazaar")
        |> Enum.map(& &1.to)

      with_knowledge =
        %Player{knowledge: ["rook"]}
        |> World.available_exits("shunt9_bazaar")
        |> Enum.map(& &1.to)

      refute "shunt9_rooks_desk" in without
      assert "shunt9_rooks_desk" in with_knowledge
    end
  end

  describe "accessible_locations/1" do
    test "includes the player's current location and ungated reachable locations" do
      ids =
        %Player{location_id: "shunt9_bazaar"}
        |> World.accessible_locations()
        |> Enum.map(& &1.id)

      assert "shunt9_bazaar" in ids
      assert "shunt9_scrap_yard" in ids
    end

    test "hides locations only reachable through unmet requirements" do
      ids =
        %Player{location_id: "shunt9_bazaar", knowledge: []}
        |> World.accessible_locations()
        |> Enum.map(& &1.id)

      refute "shunt9_power_relay" in ids
      refute "shunt9_rooks_desk" in ids
    end

    test "reveals a gated location once its requirement is met" do
      ids =
        %Player{location_id: "shunt9_bazaar", knowledge: ["power_relay_entrance"]}
        |> World.accessible_locations()
        |> Enum.map(& &1.id)

      assert "shunt9_power_relay" in ids
    end

    test "filtered locations carry no exits pointing to hidden locations" do
      bazaar =
        %Player{location_id: "shunt9_bazaar", knowledge: []}
        |> World.accessible_locations()
        |> Enum.find(&(&1.id == "shunt9_bazaar"))

      destinations = Enum.map(bazaar.exits, & &1.to)

      refute "shunt9_power_relay" in destinations
      refute "shunt9_rooks_desk" in destinations
    end
  end

  describe "points_of_interest/2" do
    test "returns the location's event ids when ungated" do
      ids = World.points_of_interest(%Player{}, "shunt9_player_squat")

      assert "shunt9_player_squat_deck" in ids
    end
  end
end
