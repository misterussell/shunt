defmodule Shunt.WebBoardTest do
  use ExUnit.Case, async: true

  alias Shunt.Players.Player
  alias Shunt.Web

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
