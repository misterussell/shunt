defmodule Shunt.PlayersTest do
  use Shunt.DataCase

  alias Shunt.Players

  describe "create_player!/0" do
    test "creates a player with default resource values" do
      player = Players.create_player!()

      assert player.cred == 0
      assert player.scrip == 0
      assert player.heat == 0
    end

    test "creates a player with no offer or held item" do
      player = Players.create_player!()

      assert player.current_offer_key == nil
      assert player.held_item_key == nil
    end
  end

  describe "get_player!/0" do
    test "returns the existing player" do
      player = Players.create_player!()

      assert Players.get_player!().id == player.id
    end
  end

  describe "do_job/1" do
    test "increases cred, scrip, and heat" do
      player = Players.create_player!()

      assert {:ok, updated} = Players.do_job(player)

      assert updated.scrip == player.scrip + 15
      assert updated.cred == player.cred + 5
      assert updated.heat == player.heat + 10
    end
  end

  describe "lay_low/1" do
    test "decreases cred and heat" do
      player = Players.create_player!()
      {:ok, player} = Players.do_job(player)
      {:ok, player} = Players.do_job(player)

      assert {:ok, updated} = Players.lay_low(player)

      assert updated.cred == player.cred - 10
      assert updated.heat == player.heat - 20
    end
  end
end
