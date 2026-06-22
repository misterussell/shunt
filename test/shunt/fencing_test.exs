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
    # TODO: once Fencing.sell_held_item/1 returns {:ok, player, event}, update this test to
    # assert {:ok, updated, nil} = Fencing.sell_held_item(player) for a starting heat low
    # enough that player.heat + item.heat_cost stays within the same Shunt.Heat band (no
    # event fires), keeping the existing scrip/cred/heat/held_item_key assertions.
    test "adds sell_value, cred_gain, and heat_cost, then clears held_item_key" do
      player = Players.create_player!()
      item = Catalog.fetch!("cracked_latticework_relay_key")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{held_item_key: item.key})
        |> Repo.update()

      assert {:ok, updated} = Fencing.sell_held_item(player)

      assert updated.scrip == player.scrip + item.sell_value
      assert updated.cred == player.cred + item.cred_gain
      assert updated.heat == player.heat + item.heat_cost
      assert updated.held_item_key == nil
    end

    # TODO: replace this test (heat no longer clamps to 100 once a Shunt.Heat band is
    # crossed). Rewrite as two tests:
    #   1. starting heat at 90 + an item whose heat_cost pushes past 85 (:high threshold)
    #      asserts {:ok, updated, event} = Fencing.sell_held_item(player), event != nil,
    #      event.band == :high, updated.heat == 80 (85 - 5), and that updated.scrip/cred
    #      reflect item.sell_value/cred_gain minus event.scrip_loss/cred_loss (clamped at 0).
    #   2. starting heat at 100 already (no band left above) with a heat_cost that can't
    #      cross further asserts heat still clamps at 100 with event == nil.
    test "clamps heat at 100" do
      player = Players.create_player!()
      item = Catalog.fetch!("burned_netrunners_memory_core")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{held_item_key: item.key, heat: 90})
        |> Repo.update()

      assert {:ok, updated} = Fencing.sell_held_item(player)

      assert updated.heat == 100
    end

    test "returns an error when there is no held item" do
      player = Players.create_player!()

      assert Fencing.sell_held_item(player) == {:error, :no_held_item}
    end
  end
end
