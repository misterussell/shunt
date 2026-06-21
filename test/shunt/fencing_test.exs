defmodule Shunt.FencingTest do
  use Shunt.DataCase

  alias Shunt.Fencing
  alias Shunt.Fencing.Catalog
  alias Shunt.Players
  alias Shunt.Repo

  describe "find_lead/1" do
    test "sets current_offer_key to a valid catalog key when idle" do
      player = Players.create_player!()

      assert {:ok, updated} = Fencing.find_lead(player)

      valid_keys = Enum.map(Catalog.items(), & &1.key)
      assert updated.current_offer_key in valid_keys
    end

    test "returns an error when an offer is already pending" do
      player = Players.create_player!()
      {:ok, player} = Fencing.find_lead(player)

      assert Fencing.find_lead(player) == {:error, :offer_in_progress}
    end
  end

  describe "take_offer/1" do
    test "deducts buy_cost from scrip and moves the offer to held_item_key" do
      player = Players.create_player!()
      item = Catalog.fetch!("cracked_latticework_relay_key")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{scrip: 100, current_offer_key: item.key})
        |> Repo.update()

      assert {:ok, updated} = Fencing.take_offer(player)

      assert updated.scrip == 100 - item.buy_cost
      assert updated.held_item_key == item.key
      assert updated.current_offer_key == nil
    end

    test "returns an error when there is no pending offer" do
      player = Players.create_player!()

      assert Fencing.take_offer(player) == {:error, :no_offer}
    end

    test "returns an error when scrip is insufficient" do
      player = Players.create_player!()
      item = Catalog.fetch!("cracked_latticework_relay_key")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{scrip: 0, current_offer_key: item.key})
        |> Repo.update()

      assert Fencing.take_offer(player) == {:error, :insufficient_scrip}
    end
  end
end
