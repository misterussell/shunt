defmodule Shunt.FencingTest do
  use ExUnit.Case, async: true

  alias Shunt.Fencing
  alias Shunt.Fencing.Catalog
  alias Shunt.Players.Player

  describe "find_lead/1" do
    test "sets current_offer_key to a valid catalog key when idle" do
      player = %Player{current_offer_key: nil, held_item_key: nil}

      assert {:ok, [{:set, :current_offer_key, key}]} = Fencing.find_lead(player)

      valid_keys = Enum.map(Catalog.items(), & &1.key)
      assert key in valid_keys
    end

    test "returns an error when an offer is already pending" do
      player = %Player{current_offer_key: "scrap_dermal_plating", held_item_key: nil}

      assert Fencing.find_lead(player) == {:error, :offer_in_progress}
    end
  end

  describe "can_take_offer?/1" do
    test "returns true when scrip covers the offer's buy_cost" do
      item = Catalog.fetch!("cracked_latticework_relay_key")
      player = %Player{current_offer_key: item.key, scrip: item.buy_cost}

      assert Fencing.can_take_offer?(player)
    end

    test "returns false when scrip is below the offer's buy_cost" do
      item = Catalog.fetch!("cracked_latticework_relay_key")
      player = %Player{current_offer_key: item.key, scrip: item.buy_cost - 1}

      refute Fencing.can_take_offer?(player)
    end

    test "returns false when there is no pending offer" do
      player = %Player{current_offer_key: nil, scrip: 1_000}

      refute Fencing.can_take_offer?(player)
    end
  end

  describe "take_offer/1" do
    test "deducts buy_cost from scrip and moves the offer to held_item_key" do
      item = Catalog.fetch!("cracked_latticework_relay_key")
      player = %Player{current_offer_key: item.key, scrip: 100}

      assert Fencing.take_offer(player) ==
               {:ok,
                [
                  {:scrip, -item.buy_cost},
                  {:set, :current_offer_key, nil},
                  {:set, :held_item_key, item.key}
                ]}
    end

    test "returns an error when there is no pending offer" do
      player = %Player{current_offer_key: nil}

      assert Fencing.take_offer(player) == {:error, :no_offer}
    end

    test "returns an error when scrip is insufficient" do
      item = Catalog.fetch!("cracked_latticework_relay_key")
      player = %Player{current_offer_key: item.key, scrip: 0}

      assert Fencing.take_offer(player) == {:error, :insufficient_scrip}
    end
  end

  describe "pass_offer/1" do
    test "clears the pending offer" do
      player = %Player{current_offer_key: "scrap_dermal_plating"}

      assert Fencing.pass_offer(player) == {:ok, [{:set, :current_offer_key, nil}]}
    end

    test "returns an error when there is no pending offer" do
      player = %Player{current_offer_key: nil}

      assert Fencing.pass_offer(player) == {:error, :no_offer}
    end
  end

  describe "sell_held_item/1" do
    test "returns effects for heat, scrip, cred, and clearing held_item_key" do
      item = Catalog.fetch!("cracked_latticework_relay_key")
      player = %Player{held_item_key: item.key}

      assert Fencing.sell_held_item(player) ==
               {:ok,
                [
                  {:heat, item.heat_cost},
                  {:scrip, item.sell_value},
                  {:cred, item.cred_gain},
                  {:set, :held_item_key, nil}
                ]}
    end

    test "returns an error when there is no held item" do
      player = %Player{held_item_key: nil}

      assert Fencing.sell_held_item(player) == {:error, :no_held_item}
    end
  end
end
