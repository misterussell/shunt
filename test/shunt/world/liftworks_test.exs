defmodule Shunt.World.LiftworksTest do
  use ExUnit.Case, async: true

  alias Shunt.Ghostwork.IceNode
  alias Shunt.Players.Player
  alias Shunt.World

  defp accessible_ids(player) do
    player |> World.accessible_locations() |> Enum.map(& &1.id)
  end

  defp ascent_destinations(player) do
    player
    |> World.available_exits("liftworks_the_risers")
    |> Enum.map(& &1.to)
  end

  describe "locations load" do
    test "every Liftworks location resolves" do
      for id <- [
            "liftworks_intake_hall",
            "liftworks_transfer_row",
            "liftworks_the_pen",
            "liftworks_watch_office",
            "liftworks_cold_stair",
            "liftworks_the_risers",
            "liftworks_upper_landing"
          ] do
        assert World.get_location(id).id == id
      end
    end
  end

  describe "discovery gate off the Concourse" do
    test "Intake Hall is hidden until the player knows the route" do
      player = %Player{location_id: "crossgate_concourse"}
      refute "liftworks_intake_hall" in accessible_ids(player)
    end

    test "knowing the route opens the way into the Liftworks" do
      player = %Player{location_id: "crossgate_concourse", knowledge: ["liftworks_route"]}
      assert "liftworks_intake_hall" in accessible_ids(player)
    end
  end

  describe "Cold Stair back-route gate" do
    test "hidden without Proxy as a contact" do
      player = %Player{location_id: "liftworks_intake_hall"}
      refute "liftworks_cold_stair" in accessible_ids(player)
    end

    test "visible once Proxy vouches" do
      player = %Player{location_id: "liftworks_intake_hall", contacts: ["liftworks_proxy"]}
      assert "liftworks_cold_stair" in accessible_ids(player)
    end
  end

  describe "the three-key ascent to the Midgrid" do
    test "the lift stays locked with no key" do
      player = %Player{location_id: "liftworks_the_risers"}
      refute "liftworks_upper_landing" in ascent_destinations(player)
    end

    test "a transit permit opens the lift" do
      player = %Player{location_id: "liftworks_the_risers", inventory: %{"transit_permit" => 1}}
      assert "liftworks_upper_landing" in ascent_destinations(player)
    end

    test "a spoofed scan tag opens the lift" do
      player = %Player{location_id: "liftworks_the_risers", knowledge: ["scan_arch_spoofed"]}
      assert "liftworks_upper_landing" in ascent_destinations(player)
    end

    test "the Cold Stair back route opens the lift" do
      player = %Player{location_id: "liftworks_the_risers", knowledge: ["liftworks_back_route"]}
      assert "liftworks_upper_landing" in ascent_destinations(player)
    end

    test "Upper Landing carries no requirements of its own" do
      assert World.location_accessible?(%Player{}, "liftworks_upper_landing")
    end
  end

  describe "Scan Arch ICE node (the spoof route)" do
    test "is gated until the player has found it" do
      node = IceNode.fetch!("liftworks_scan_arch")
      assert {:knows, "scan_arch_found"} in node.requirements
    end

    test "its final layer grants the spoofed-tag knowledge that opens the lift" do
      node = IceNode.fetch!("liftworks_scan_arch")
      final_rewards = node.layers |> List.last() |> Map.fetch!(:reward)
      assert {:knowledge, "scan_arch_spoofed"} in final_rewards
    end
  end
end
