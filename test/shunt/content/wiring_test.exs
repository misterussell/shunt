defmodule Shunt.Content.WiringTest do
  use ExUnit.Case, async: true

  alias Shunt.Content

  test "Nickel vouches the player to Rook, granting the knowledge that unlocks Rook's Desk" do
    nickel = Content.fetch!(:world_npcs, "shunt9_bazaar_nickel")
    assert "shunt9_bazaar_nickel_rook" in nickel.story_arcs

    event = Content.fetch!(:events, "shunt9_bazaar_nickel_rook")
    assert {:knowledge, "rook"} in event.on_complete

    desk = Content.fetch!(:locations, "shunt9_rooks_desk")
    assert {:knows, "rook"} in desk.requirements
  end

  test "the freight tunnel exposes its leverage and skim events" do
    tunnel = Content.fetch!(:locations, "shunt9_freight_tunnel")
    events = Map.get(tunnel, :events, [])

    assert "shunt9_freight_tunnel_ghost_route" in events
    assert "shunt9_freight_tunnel_skim" in events
  end

  test "skimming the freight route is gated behind the one-shot leverage payoff" do
    ghost_route = Content.fetch!(:events, "shunt9_freight_tunnel_ghost_route")
    assert {:knowledge, "freight_route_worked"} in ghost_route.on_complete
    refute ghost_route.repeatable

    skim = Content.fetch!(:events, "shunt9_freight_tunnel_skim")
    assert {:knows, "freight_route_worked"} in skim.requirements
    assert skim.repeatable
  end
end
