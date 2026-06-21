defmodule Shunt.PlayersTest do
  use Shunt.DataCase

  alias Shunt.Players

  describe "get_or_create_player/0" do
    test "creates a default player when none exists" do
      player = Players.get_or_create_player()

      assert player.cred == 0
      assert player.scrip == 0
      assert player.heat == 0
    end

    test "returns the existing player on subsequent calls" do
      player = Players.get_or_create_player()

      assert Players.get_or_create_player().id == player.id
    end
  end

  describe "do_job/1" do
    test "increases cred, scrip, and heat" do
      player = Players.get_or_create_player()

      assert {:ok, updated} = Players.do_job(player)

      assert updated.scrip == player.scrip + 15
      assert updated.cred == player.cred + 5
      assert updated.heat == player.heat + 10
    end
  end
end
