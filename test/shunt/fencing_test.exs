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

  describe "pass_offer/1" do
    test "clears the pending offer" do
      player = Players.create_player!()
      {:ok, player} = Fencing.find_lead(player)

      assert {:ok, updated} = Fencing.pass_offer(player)

      assert updated.current_offer_key == nil
    end

    test "returns an error when there is no pending offer" do
      player = Players.create_player!()

      assert Fencing.pass_offer(player) == {:error, :no_offer}
    end
  end

  describe "sell_held_item/1" do
    test "adds sell_value, cred_gain, and heat_cost, then clears held_item_key, with no heat event" do
      player = Players.create_player!()
      item = Catalog.fetch!("cracked_latticework_relay_key")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{held_item_key: item.key})
        |> Repo.update()

      assert {:ok, updated, nil} = Fencing.sell_held_item(player)

      assert updated.scrip == player.scrip + item.sell_value
      assert updated.cred == player.cred + item.cred_gain
      assert updated.heat == player.heat + item.heat_cost
      assert updated.held_item_key == nil
    end

    test "fires a heat event and discharges heat when crossing a Shunt.Heat band" do
      player = Players.create_player!()
      item = Catalog.fetch!("burned_netrunners_memory_core")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{held_item_key: item.key, heat: 60})
        |> Repo.update()

      assert {:ok, updated, event} = Fencing.sell_held_item(player)

      assert event.band == :high
      assert updated.heat == 80
      assert updated.scrip == max(player.scrip + item.sell_value - event.scrip_loss, 0)
      assert updated.cred == max(player.cred + item.cred_gain - event.cred_loss, 0)
    end

    test "clamps heat at 100 with no event when already at the top of the :high band" do
      player = Players.create_player!()
      item = Catalog.fetch!("burned_netrunners_memory_core")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{held_item_key: item.key, heat: 100})
        |> Repo.update()

      assert {:ok, updated, nil} = Fencing.sell_held_item(player)

      assert updated.heat == 100
    end

    test "returns an error when there is no held item" do
      player = Players.create_player!()

      assert Fencing.sell_held_item(player) == {:error, :no_held_item}
    end
  end
end
