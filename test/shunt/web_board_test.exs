defmodule Shunt.WebBoardTest do
  use ExUnit.Case, async: true

  alias Shunt.Players.Player
  alias Shunt.Web
  alias Shunt.Web.RumorConnection

  describe "place_rumor/4" do
    test "adds a fractional position for the rumor" do
      player = %Player{rumors: ["a"], web_board: %{"positions" => %{}, "wires" => []}}

      {:ok, [{:web_board, board}]} = Web.place_rumor(player, "a", 0.25, 0.5)

      assert board["positions"]["a"] == %{"x" => 0.25, "y" => 0.5}
    end

    test "is a no-op for a rumor the player does not hold" do
      player = %Player{rumors: [], web_board: %{"positions" => %{}, "wires" => []}}

      assert Web.place_rumor(player, "a", 0.25, 0.5) == {:ok, []}
    end

    test "overwrites the position when the rumor is already placed (reposition)" do
      player = %Player{
        rumors: ["a"],
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

  describe "placed/1" do
    test "returns {id, x, y} tuples for placed rumors, sorted by id" do
      player = %Player{
        web_board: %{
          "positions" => %{
            "b" => %{"x" => 0.2, "y" => 0.3},
            "a" => %{"x" => 0.8, "y" => 0.9}
          },
          "wires" => []
        }
      }

      assert Web.placed(player) == [{"a", 0.8, 0.9}, {"b", 0.2, 0.3}]
    end

    test "is empty for an unset board" do
      assert Web.placed(%Player{web_board: nil}) == []
    end
  end

  describe "wires/1" do
    test "returns the board's wire pairs" do
      player = %Player{web_board: %{"positions" => %{}, "wires" => [["a", "b"]]}}

      assert Web.wires(player) == [["a", "b"]]
    end

    test "is empty for an unset board" do
      assert Web.wires(%Player{web_board: nil}) == []
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

  describe "solved_clusters/1" do
    @supplier_rumors ~w(juno_supplier missing_shipments vex_debts)

    defp solved_board(rumors) do
      %Player{
        rumors: rumors,
        web_board: %{
          "positions" => Map.new(rumors, &{&1, %{"x" => 0.1, "y" => 0.1}}),
          "wires" => rumors |> Enum.chunk_every(2, 1, :discard) |> Enum.map(&Enum.sort/1)
        }
      }
    end

    test "returns clusters whose connection success event is completed" do
      player = %{
        solved_board(@supplier_rumors)
        | completed_events: ["supplier_conspiracy_success"]
      }

      assert Web.solved_clusters(player) == [MapSet.new(@supplier_rumors)]
    end

    test "returns nothing for an exact-but-unsolved cluster" do
      assert Web.solved_clusters(solved_board(@supplier_rumors)) == []
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

  describe "solved-cluster locking" do
    @supplier_rumors ~w(juno_supplier missing_shipments vex_debts)

    defp locked_player do
      %Player{
        rumors: @supplier_rumors,
        completed_events: ["supplier_conspiracy_success"],
        web_board: %{
          "positions" => Map.new(@supplier_rumors, &{&1, %{"x" => 0.1, "y" => 0.1}}),
          "wires" =>
            @supplier_rumors |> Enum.chunk_every(2, 1, :discard) |> Enum.map(&Enum.sort/1)
        }
      }
    end

    test "locked_rumor_ids returns the ids of every solved cluster" do
      assert Web.locked_rumor_ids(locked_player()) == MapSet.new(@supplier_rumors)
    end

    test "place_rumor (move) is a no-op for a rumor in a solved cluster" do
      assert Web.place_rumor(locked_player(), "juno_supplier", 0.9, 0.9) == {:ok, []}
    end

    test "return_to_intake is a no-op for a rumor in a solved cluster" do
      assert Web.return_to_intake(locked_player(), "juno_supplier") == {:ok, []}
    end

    test "disconnect is a no-op when an endpoint is in a solved cluster" do
      assert Web.disconnect(locked_player(), "juno_supplier", "missing_shipments") == {:ok, []}
    end

    test "connect is a no-op when an endpoint is in a solved cluster" do
      assert Web.connect(locked_player(), "juno_supplier", "vex_debts") == {:ok, []}
    end
  end
end
