defmodule Shunt.WebNetworkTest do
  # Not async: seeds the shared global :rumor_connections ETS table.
  use ExUnit.Case

  alias Shunt.Events.Event
  alias Shunt.Players.Player
  alias Shunt.Web
  alias Shunt.Web.Rumor
  alias Shunt.Web.RumorConnection

  setup do
    connections = [
      # Status-transition + pursue target.
      conn("net_trio", ["n_a", "n_b", "n_c"], 2),
      # Ordering targets: one reachable to each status by a single player's holdings.
      conn("net_alpha", ["x1"], 1),
      conn("net_beta", ["y1", "y2", "y3"], 2),
      conn("net_gamma", ["z1", "z2", "z3"], 2)
    ]

    events = [
      event("net_trio_success"),
      event("net_trio_partial")
    ]

    Enum.each(connections, &:ets.insert(:rumor_connections, {&1.id, &1}))
    :ets.insert(:events, Enum.map(events, &{&1.id, &1}))

    on_exit(fn ->
      Enum.each(connections, &:ets.delete(:rumor_connections, &1.id))
      Enum.each(events, &:ets.delete(:events, &1.id))
    end)

    :ok
  end

  defp event(id) do
    %Event{
      id: id,
      title: id,
      steps: [%{id: "step", text: "…", choices: [%{label: "Continue", complete: true}]}]
    }
  end

  defp conn(id, rumors, threshold) do
    %RumorConnection{
      id: id,
      rumors: rumors,
      partial_threshold: threshold,
      success_event_id: "#{id}_success",
      partial_event_id: "#{id}_partial",
      failure_event_id: "#{id}_failure",
      lead_heat: 2,
      crack_heat: 5
    }
  end

  defp player(rumors, completed \\ []), do: %Player{rumors: rumors, completed_events: completed}

  defp entry(player, id), do: player |> Web.network() |> Enum.find(&(&1.connection.id == id))

  describe "network/1 status" do
    test "a case the player holds no rumors of is absent from the network" do
      refute entry(player([]), "net_trio")
      refute entry(player(["unrelated"]), "net_trio")
    end

    test "holding some rumors but below the threshold is :forming" do
      e = entry(player(["n_a"]), "net_trio")
      assert e.status == :forming
      assert e.held == ["n_a"]
      assert e.missing == ["n_b", "n_c"]
      assert e.total == 3
    end

    test "reaching partial_threshold is :lead" do
      e = entry(player(["n_a", "n_b"]), "net_trio")
      assert e.status == :lead
      assert e.missing == ["n_c"]
    end

    test "holding every rumor in the set is :crackable" do
      e = entry(player(["n_a", "n_b", "n_c"]), "net_trio")
      assert e.status == :crackable
      assert e.missing == []
    end

    test "a cracked case is :solved (success takes precedence over crackable)" do
      e = entry(player(["n_a", "n_b", "n_c"], ["net_trio_success"]), "net_trio")
      assert e.status == :solved
    end

    test "held and missing preserve the connection's authored rumor order" do
      e = entry(player(["n_c", "n_a"]), "net_trio")
      assert e.held == ["n_a", "n_c"]
      assert e.missing == ["n_b"]
    end
  end

  describe "network/1 ordering" do
    test "sorts crackable before lead before forming" do
      ids =
        player(["x1", "y1", "y2", "z1"])
        |> Web.network()
        |> Enum.map(& &1.connection.id)

      assert ids == ["net_alpha", "net_beta", "net_gamma"]
    end

    test "solved cases sort to the end" do
      ids =
        player(["x1", "z1"], ["net_alpha_success"])
        |> Web.network()
        |> Enum.map(& &1.connection.id)

      assert ids == ["net_gamma", "net_alpha"]
    end
  end

  describe "pursue/3" do
    test ":crack on a full holding applies crack_heat and starts the success event" do
      assert {:ok, effects, meta} = Web.pursue(player(["n_a", "n_b", "n_c"]), "net_trio", :crack)
      assert {:heat, 5} in effects
      assert meta.event_id == "net_trio_success"
      assert Enum.any?(effects, &match?({:set, :event_state, _}, &1))
    end

    test ":lead at the threshold applies lead_heat and starts the partial event" do
      assert {:ok, effects, meta} = Web.pursue(player(["n_a", "n_b"]), "net_trio", :lead)
      assert {:heat, 2} in effects
      assert meta.event_id == "net_trio_partial"
      assert Enum.any?(effects, &match?({:set, :event_state, _}, &1))
    end

    test ":crack is rejected when the player does not hold every rumor" do
      assert {:error, _} = Web.pursue(player(["n_a", "n_b"]), "net_trio", :crack)
    end

    test ":lead is rejected below the partial threshold" do
      assert {:error, _} = Web.pursue(player(["n_a"]), "net_trio", :lead)
    end

    test ":crack is rejected once the case is solved" do
      p = player(["n_a", "n_b", "n_c"], ["net_trio_success"])
      assert {:error, _} = Web.pursue(p, "net_trio", :crack)
    end

    test ":lead is rejected once its partial event has already been followed" do
      p = player(["n_a", "n_b"], ["net_trio_partial"])
      assert {:error, _} = Web.pursue(p, "net_trio", :lead)
    end

    test "an unknown connection id is rejected, not raised" do
      assert {:error, :not_found} = Web.pursue(player(["n_a"]), "no_such_connection", :crack)
    end
  end

  describe "entity_graph, entity_view, and default_focus (real entities)" do
    setup do
      # Real content the rumors' entity refs resolve against; npc_ghost is deliberately absent so
      # a dangling ref can be exercised.
      npcs = [%{id: "npc_juno", name: "Juno"}]

      locations = [
        %{id: "loc_tunnel", name: "Freight Tunnel"},
        %{id: "loc_bazaar", name: "Bazaar"}
      ]

      ice = [%{id: "ice_grid", name: "Salvage Grid"}]

      rumors = [
        rumor("er_a", [{:npc, "npc_juno"}, {:location, "loc_tunnel"}]),
        rumor("er_b", [{:location, "loc_tunnel"}, {:ice, "ice_grid"}]),
        rumor("er_c", [{:npc, "npc_juno"}, {:location, "loc_bazaar"}, {:npc, "npc_ghost"}])
      ]

      ecase = conn("ecase", ["er_a", "er_b"], 1)

      :ets.insert(:world_npcs, Enum.map(npcs, &{&1.id, &1}))
      :ets.insert(:locations, Enum.map(locations, &{&1.id, &1}))
      :ets.insert(:ice_nodes, Enum.map(ice, &{&1.id, &1}))
      :ets.insert(:rumors, Enum.map(rumors, &{&1.id, &1}))
      :ets.insert(:rumor_connections, {ecase.id, ecase})

      on_exit(fn ->
        Enum.each(npcs, &:ets.delete(:world_npcs, &1.id))
        Enum.each(locations, &:ets.delete(:locations, &1.id))
        Enum.each(ice, &:ets.delete(:ice_nodes, &1.id))
        Enum.each(rumors, &:ets.delete(:rumors, &1.id))
        :ets.delete(:rumor_connections, ecase.id)
      end)

      :ok
    end

    defp keyed(nodes), do: Map.new(nodes, &{&1.key, &1})
    defp epair(edge), do: Enum.sort([edge.a, edge.b])
    defp efind(edges, a, b), do: Enum.find(edges, &(epair(&1) == Enum.sort([a, b])))

    test "nodes resolve to real entities with kind, name, and weight" do
      nodes = Web.entity_graph(player(["er_a", "er_b"])).nodes |> keyed()

      assert %{kind: :location, name: "Freight Tunnel", weight: 2} = nodes["location-loc_tunnel"]
      assert %{kind: :npc, name: "Juno", weight: 1} = nodes["npc-npc_juno"]
      assert %{kind: :ice, name: "Salvage Grid"} = nodes["ice-ice_grid"]
    end

    test "a dangling entity ref is dropped, not surfaced" do
      keys = Web.entity_graph(player(["er_c"])).nodes |> Enum.map(& &1.key)

      refute "npc-npc_ghost" in keys
      assert "npc-npc_juno" in keys
      assert "location-loc_bazaar" in keys
    end

    test "edges connect entities co-named in a held rumor, colored by case status" do
      edges = Web.entity_graph(player(["er_a", "er_b"])).edges

      assert efind(edges, "npc-npc_juno", "location-loc_tunnel").status == :crackable
      assert efind(edges, "ice-ice_grid", "location-loc_tunnel")
      # Juno and the grid are never named in the same rumor.
      refute efind(edges, "npc-npc_juno", "ice-ice_grid")
    end

    test "edge status follows the case: a partial holding reads as a lead" do
      edges = Web.entity_graph(player(["er_a"])).edges
      assert efind(edges, "npc-npc_juno", "location-loc_tunnel").status == :lead
    end

    test "a co-occurrence in no case is :unaffiliated" do
      edges = Web.entity_graph(player(["er_c"])).edges
      assert efind(edges, "npc-npc_juno", "location-loc_bazaar").status == :unaffiliated
    end

    test "default_focus is the highest-signal entity key" do
      graph = Web.entity_graph(player(["er_a", "er_b"]))
      assert Web.default_focus(graph) == "location-loc_tunnel"
    end

    test "default_focus of an empty graph is nil" do
      assert Web.default_focus(Web.entity_graph(player([]))) == nil
    end

    test "entities lists the distinct held entities as descriptors, sorted by name" do
      names = player(["er_a", "er_b"]) |> Web.entities() |> Enum.map(& &1.name)
      assert names == ["Freight Tunnel", "Juno", "Salvage Grid"]
    end

    test "entity_view returns the held rumors naming the entity and the cases they touch" do
      view = Web.entity_view(player(["er_a", "er_b"]), "npc-npc_juno")

      assert Enum.map(view.rumors, & &1.id) == ["er_a"]
      assert [%{connection: %{id: "ecase"}}] = view.cases
    end

    test "no held rumors yields an empty graph" do
      assert Web.entity_graph(player([])) == %{nodes: [], edges: []}
    end
  end

  defp rumor(id, entities), do: %Rumor{id: id, title: id, description: "…", entities: entities}
end
