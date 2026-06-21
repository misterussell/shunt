defmodule Shunt.Fencing do
  alias Shunt.Repo
  alias Shunt.Players.Player
  alias Shunt.Fencing.Catalog

  def find_lead(%Player{current_offer_key: nil, held_item_key: nil} = player) do
    item = Enum.random(Catalog.items())

    player
    |> Ecto.Changeset.change(%{current_offer_key: item.key})
    |> Repo.update()
  end

  def find_lead(%Player{}), do: {:error, :offer_in_progress}

  def take_offer(%Player{current_offer_key: nil}), do: {:error, :no_offer}

  def take_offer(%Player{current_offer_key: key, scrip: scrip} = player) do
    item = Catalog.fetch!(key)

    if scrip < item.buy_cost do
      {:error, :insufficient_scrip}
    else
      player
      |> Ecto.Changeset.change(%{
        scrip: scrip - item.buy_cost,
        current_offer_key: nil,
        held_item_key: key
      })
      |> Repo.update()
    end
  end
end
