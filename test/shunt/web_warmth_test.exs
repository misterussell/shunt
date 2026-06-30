defmodule Shunt.WebWarmthTest do
  # Seeds synthetic connections into the global :rumor_connections ETS table, so this runs sync.
  use ExUnit.Case, async: false

  alias Shunt.Players.Player
  alias Shunt.Web
  alias Shunt.Web.RumorConnection

  setup do
    trio = %RumorConnection{
      id: "ww_trio",
      rumors: ["ww_a", "ww_b", "ww_c"],
      partial_threshold: 2,
      success_event_id: "ww_trio_success",
      partial_event_id: "ww_trio_partial",
      failure_event_id: "ww_trio_failure"
    }

    quint = %RumorConnection{
      id: "ww_quint",
      rumors: ["ww_m", "ww_n", "ww_o", "ww_p", "ww_q"],
      partial_threshold: 3,
      success_event_id: "ww_quint_success",
      partial_event_id: "ww_quint_partial",
      failure_event_id: "ww_quint_failure"
    }

    :ets.insert(:rumor_connections, [{trio.id, trio}, {quint.id, quint}])

    on_exit(fn ->
      :ets.delete(:rumor_connections, trio.id)
      :ets.delete(:rumor_connections, quint.id)
    end)

    %{trio: trio, quint: quint}
  end

  describe "warm_clusters/1" do
    test "a wired pair that is a proper subset of a connection is warm with a meter" do
      player = board_player(["ww_a", "ww_b"], [["ww_a", "ww_b"]])

      assert [warm] = Web.warm_clusters(player)
      assert warm.connection.id == "ww_trio"
      assert warm.cluster == MapSet.new(["ww_a", "ww_b"])
      assert warm.matched == 2
      assert warm.total == 3
      assert warm.short == 1
      assert warm.lead_ready? == true
    end

    test "a lone placed card is not warm" do
      player = board_player(["ww_a"], [])

      assert Web.warm_clusters(player) == []
    end

    test "an exact match is resonant, not warm" do
      player = board_player(["ww_a", "ww_b", "ww_c"], [["ww_a", "ww_b"], ["ww_b", "ww_c"]])

      assert Web.warm_clusters(player) == []
    end

    test "a cluster carrying a rumor foreign to the connection is not warm" do
      player = board_player(["ww_a", "ww_b", "ww_z"], [["ww_a", "ww_b"], ["ww_b", "ww_z"]])

      assert Web.warm_clusters(player) == []
    end

    test "a subset below the connection's partial_threshold is warm but not lead-ready" do
      player = board_player(["ww_m", "ww_n"], [["ww_m", "ww_n"]])

      assert [warm] = Web.warm_clusters(player)
      assert warm.connection.id == "ww_quint"
      assert warm.matched == 2
      assert warm.total == 5
      assert warm.short == 3
      assert warm.lead_ready? == false
    end

    test "a partial subset of an already-solved connection is not warm" do
      player =
        board_player(["ww_a", "ww_b"], [["ww_a", "ww_b"]], completed_events: ["ww_trio_success"])

      assert Web.warm_clusters(player) == []
    end

    test "a lead-ready cluster stops being lead-ready once its partial event is completed" do
      # Following a non-repeatable partial lands its id in completed_events; the cluster stays warm
      # (the connection's success event is still open) but can no longer be re-followed — otherwise
      # re-clicking [ FOLLOW LEAD ] would reopen the finished event and soft-lock the panel.
      player =
        board_player(["ww_a", "ww_b"], [["ww_a", "ww_b"]], completed_events: ["ww_trio_partial"])

      assert [warm] = Web.warm_clusters(player)
      assert warm.matched == 2
      assert warm.total == 3
      assert warm.lead_ready? == false
    end
  end

  describe "rumor_status/2" do
    test "a held rumor not on the board is :not_placed" do
      player = %Player{rumors: ["ww_a"], web_board: %{"positions" => %{}, "wires" => []}}

      assert Web.rumor_status(player, "ww_a") == :not_placed
    end

    test "a placed lone card is :on_board" do
      player = board_player(["ww_a"], [])

      assert Web.rumor_status(player, "ww_a") == :on_board
    end

    test "a placed rumor in a warm cluster is {:forming, matched, total}" do
      player = board_player(["ww_a", "ww_b"], [["ww_a", "ww_b"]])

      assert Web.rumor_status(player, "ww_a") == {:forming, 2, 3}
    end

    test "a placed rumor in an exact unsolved cluster is :resonant" do
      player = board_player(["ww_a", "ww_b", "ww_c"], [["ww_a", "ww_b"], ["ww_b", "ww_c"]])

      assert Web.rumor_status(player, "ww_a") == :resonant
    end

    test "a placed rumor in a solved cluster is :solved" do
      player =
        board_player(
          ["ww_a", "ww_b", "ww_c"],
          [["ww_a", "ww_b"], ["ww_b", "ww_c"]],
          completed_events: ["ww_trio_success"]
        )

      assert Web.rumor_status(player, "ww_a") == :solved
    end
  end

  # Builds a player whose board holds the given placed ids (at arbitrary coords) and wires,
  # bypassing place_rumor/connect since we're exercising the read-side cluster functions directly.
  defp board_player(placed_ids, wires, opts \\ []) do
    positions = Map.new(placed_ids, fn id -> {id, %{"x" => 0.5, "y" => 0.5}} end)

    %Player{
      rumors: placed_ids,
      web_board: %{"positions" => positions, "wires" => wires},
      completed_events: Keyword.get(opts, :completed_events, [])
    }
  end
end
