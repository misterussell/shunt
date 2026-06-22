defmodule Shunt.Fencing do
  @moduledoc false
  alias Shunt.Heat
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

  def pass_offer(%Player{current_offer_key: nil}), do: {:error, :no_offer}

  def pass_offer(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{current_offer_key: nil})
    |> Repo.update()
  end

  def sell_held_item(%Player{held_item_key: nil}), do: {:error, :no_held_item}

  def sell_held_item(%Player{held_item_key: key} = player) do
    item = Catalog.fetch!(key)
    {final_heat, event} = Heat.resolve(player.heat, Heat.clamp(player.heat + item.heat_cost))

    player
    |> Ecto.Changeset.change(%{
      scrip: max(player.scrip + item.sell_value - event_loss(event, :scrip_loss), 0),
      cred: max(player.cred + item.cred_gain - event_loss(event, :cred_loss), 0),
      heat: final_heat,
      held_item_key: nil
    })
    |> Repo.update()
    |> case do
      {:ok, player} -> {:ok, player, event}
      {:error, reason} -> {:error, reason}
    end
  end

  defp event_loss(nil, _field), do: 0
  defp event_loss(event, field), do: Map.fetch!(event, field)
end
