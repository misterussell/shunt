defmodule Shunt.Ghostwork.IceNodeTest do
  use ExUnit.Case, async: true

  alias Shunt.Ghostwork.IceNode

  setup do
    node = %IceNode{
      id: "test_relay",
      name: "Abandoned Relay",
      family: "ice_maintenance",
      location_id: "shunt9_maintenance_tunnel",
      layers: [
        %{
          id: "handshake",
          name: "Handshake",
          trace_multiplier: 1.0,
          reward: [],
          subroutines: [
            %{id: "handshake_core", key: :spoof, threat: :barrier, progress_required: 10}
          ]
        }
      ]
    }

    :ets.insert(:ice_nodes, {node.id, node})
    on_exit(fn -> :ets.delete(:ice_nodes, node.id) end)
    %{node: node}
  end

  describe "all/0" do
    test "includes loaded nodes", %{node: node} do
      assert node in IceNode.all()
    end
  end

  describe "fetch!/1" do
    test "returns the %IceNode{} for a known id", %{node: node} do
      assert IceNode.fetch!("test_relay") == node
    end

    test "raises for an unknown id" do
      assert_raise RuntimeError, fn -> IceNode.fetch!("no_such_node") end
    end
  end
end
