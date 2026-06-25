defmodule Shunt.Fencing do
  @moduledoc false
  alias Shunt.Players.Player
  alias Shunt.Fencing.Catalog

  def find_lead(%Player{current_offer_key: nil, held_item_key: nil}) do
    item = Enum.random(Catalog.items())
    {:ok, [{:set, :current_offer_key, item.id}]}
  end

  def find_lead(%Player{}), do: {:error, :offer_in_progress}

  def can_take_offer?(%Player{current_offer_key: nil}), do: false

  def can_take_offer?(%Player{current_offer_key: key, scrip: scrip}) do
    scrip >= Catalog.fetch!(key).buy_cost
  end

  def take_offer(%Player{current_offer_key: nil}), do: {:error, :no_offer}

  def take_offer(%Player{current_offer_key: key, scrip: scrip}) do
    item = Catalog.fetch!(key)

    if scrip < item.buy_cost do
      {:error, :insufficient_scrip}
    else
      {:ok,
       [
         {:scrip, -item.buy_cost},
         {:set, :current_offer_key, nil},
         {:set, :held_item_key, key}
       ]}
    end
  end

  def pass_offer(%Player{current_offer_key: nil}), do: {:error, :no_offer}

  def pass_offer(%Player{}) do
    {:ok, [{:set, :current_offer_key, nil}]}
  end

  def sell_held_item(%Player{held_item_key: nil}), do: {:error, :no_held_item}

  def sell_held_item(%Player{held_item_key: key}) do
    item = Catalog.fetch!(key)

    {:ok,
     [
       {:heat, item.heat_cost},
       {:scrip, item.sell_value},
       {:cred, item.cred_gain},
       {:set, :held_item_key, nil}
     ]}
  end
end
