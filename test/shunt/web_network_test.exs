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

  describe "entities/1 and entity_view/2" do
    setup do
      rumors = [
        rumor("r_juno", ["juno", "corporate"]),
        rumor("r_ship", ["smuggling", "juno"]),
        rumor("r_debt", ["debt"])
      ]

      ent_case = conn("ent_case", ["r_juno", "r_ship", "r_debt"], 2)

      :ets.insert(:rumors, Enum.map(rumors, &{&1.id, &1}))
      :ets.insert(:rumor_connections, {ent_case.id, ent_case})

      on_exit(fn ->
        Enum.each(rumors, &:ets.delete(:rumors, &1.id))
        :ets.delete(:rumor_connections, ent_case.id)
      end)

      :ok
    end

    test "entities lists the distinct tags across the player's held rumors, sorted" do
      assert Web.entities(player(["r_juno", "r_ship"])) == ["corporate", "juno", "smuggling"]
    end

    test "entities ignores tags from rumors the player does not hold" do
      refute "debt" in Web.entities(player(["r_juno", "r_ship"]))
    end

    test "entity_view returns the held rumors carrying the tag, in held order" do
      view = Web.entity_view(player(["r_juno", "r_ship"]), "juno")
      assert Enum.map(view.rumors, & &1.id) == ["r_juno", "r_ship"]
    end

    test "entity_view returns the cases those rumors touch" do
      view = Web.entity_view(player(["r_juno", "r_ship"]), "juno")
      assert [%{status: :lead, connection: %{id: "ent_case"}}] = view.cases
    end

    test "entity_view of a tag with no held rumor is empty" do
      view = Web.entity_view(player(["r_juno"]), "debt")
      assert view.rumors == []
      assert view.cases == []
    end
  end

  defp rumor(id, tags), do: %Rumor{id: id, title: id, description: "…", tags: tags}
end
