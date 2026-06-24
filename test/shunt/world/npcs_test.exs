defmodule Shunt.World.NpcsTest do
  use ExUnit.Case, async: true

  alias Shunt.World.Npcs

  describe "get!/1" do
    test "returns the Shunt.World.NPC struct for a known id" do
      npc = Npcs.get!("shunt9_maintenance_tunnel_junkie")

      assert %Shunt.World.NPC{} = npc
      assert npc.name == "Tunnel Junkie"
      assert npc.location_id == "shunt9_maintenance_tunnel"
    end

    test "raises for an unknown id" do
      assert_raise RuntimeError, fn -> Npcs.get!("unknown") end
    end
  end
end
