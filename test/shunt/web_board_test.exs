defmodule Shunt.WebBoardTest do
  use ExUnit.Case, async: true

  alias Shunt.Players.Player
  alias Shunt.Web
  alias Shunt.Web.RumorConnection

  describe "place_rumor/4" do
    test "adds a fractional position for the rumor" do
      player = %Player{web_board: %{"positions" => %{}, "wires" => []}}

      {:ok, [{:web_board, board}]} = Web.place_rumor(player, "a", 0.25, 0.5)

      assert board["positions"]["a"] == %{"x" => 0.25, "y" => 0.5}
    end

    test "overwrites the position when the rumor is already placed (reposition)" do
      player = %Player{
        web_board: %{"positions" => %{"a" => %{"x" => 0.1, "y" => 0.1}}, "wires" => []}
      }

      {:ok, [{:web_board, board}]} = Web.place_rumor(player, "a", 0.8, 0.9)

      assert board["positions"]["a"] == %{"x" => 0.8, "y" => 0.9}
    end
  end

  describe "connect/3" do
    test "adds a wire as a sorted id pair" do
      player = %Player{web_board: %{"positions" => %{}, "wires" => []}}

      {:ok, [{:web_board, board}]} = Web.connect(player, "b", "a")

      assert board["wires"] == [["a", "b"]]
    end

    test "is idempotent regardless of argument order" do
      player = %Player{web_board: %{"positions" => %{}, "wires" => [["a", "b"]]}}

      {:ok, [{:web_board, board}]} = Web.connect(player, "b", "a")

      assert board["wires"] == [["a", "b"]]
    end
  end

  describe "disconnect/3" do
    test "removes the wire regardless of argument order" do
      player =
        %Player{web_board: %{"positions" => %{}, "wires" => [["a", "b"], ["a", "c"]]}}

      {:ok, [{:web_board, board}]} = Web.disconnect(player, "b", "a")

      assert board["wires"] == [["a", "c"]]
    end
  end

  describe "intake/1" do
    test "returns rumors the player holds that are not yet placed on the board" do
      player = %Player{
        rumors: ["a", "b", "c"],
        web_board: %{"positions" => %{"a" => %{"x" => 0.1, "y" => 0.1}}, "wires" => []}
      }

      assert Web.intake(player) == ["b", "c"]
    end
  end

  describe "clusters/1" do
    test "groups wired placed rumors into connected components, singletons included" do
      player = %Player{
        web_board: %{
          "positions" => Map.new(~w(a b c d), &{&1, %{"x" => 0.1, "y" => 0.1}}),
          "wires" => [["a", "b"], ["b", "c"]]
        }
      }

      clusters = Web.clusters(player)

      assert MapSet.new(["a", "b", "c"]) in clusters
      assert MapSet.new(["d"]) in clusters
      assert length(clusters) == 2
    end

    test "ignores wires whose endpoint is not placed on the board" do
      player = %Player{
        web_board: %{
          "positions" => Map.new(~w(a b), &{&1, %{"x" => 0.1, "y" => 0.1}}),
          "wires" => [["a", "c"]]
        }
      }

      clusters = Web.clusters(player)

      assert MapSet.new(["a"]) in clusters
      assert MapSet.new(["b"]) in clusters
      assert length(clusters) == 2
    end
  end

  describe "solved?/2" do
    test "true when the connection's success event is completed" do
      conn = %RumorConnection{
        id: "c",
        rumors: ["a"],
        partial_threshold: 1,
        success_event_id: "win",
        partial_event_id: "p",
        failure_event_id: "f"
      }

      assert Web.solved?(%Player{completed_events: ["win"]}, conn)
      refute Web.solved?(%Player{completed_events: []}, conn)
    end
  end

  describe "resonant_clusters/1" do
    @supplier_rumors ~w(juno_supplier missing_shipments vex_debts)

    defp board_with(rumors) do
      %Player{
        rumors: rumors,
        web_board: %{
          "positions" => Map.new(rumors, &{&1, %{"x" => 0.1, "y" => 0.1}}),
          "wires" => rumors |> Enum.chunk_every(2, 1, :discard) |> Enum.map(&Enum.sort/1)
        }
      }
    end

    test "an exact cluster match resonates with its connection" do
      [{cluster, conn}] = Web.resonant_clusters(board_with(@supplier_rumors))

      assert cluster == MapSet.new(@supplier_rumors)
      assert conn.id == "supplier_conspiracy"
    end

    test "a cluster with an extra rumor does not resonate (silent on non-exact)" do
      player = board_with(@supplier_rumors ++ ["authority_involvement"])

      assert Web.resonant_clusters(player) == []
    end

    test "an already-solved connection does not resonate" do
      player = %{board_with(@supplier_rumors) | completed_events: ["supplier_conspiracy_success"]}

      assert Web.resonant_clusters(player) == []
    end
  end

  describe "wipe_board/1" do
    test "resets positions and wires to empty" do
      player = %Player{
        web_board: %{"positions" => %{"a" => %{"x" => 0.1, "y" => 0.1}}, "wires" => [["a", "b"]]}
      }

      {:ok, [{:web_board, board}]} = Web.wipe_board(player)

      assert board == %{"positions" => %{}, "wires" => []}
    end
  end

  describe "return_to_intake/2" do
    test "removes the position and every wire touching the rumor" do
      player = %Player{
        web_board: %{
          "positions" => %{"a" => %{"x" => 0.1, "y" => 0.1}, "b" => %{"x" => 0.2, "y" => 0.2}},
          "wires" => [["a", "b"], ["b", "c"]]
        }
      }

      {:ok, [{:web_board, board}]} = Web.return_to_intake(player, "b")

      refute Map.has_key?(board["positions"], "b")
      assert board["wires"] == []
    end
  end
end
