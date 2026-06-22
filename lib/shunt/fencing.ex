defmodule Shunt.Fencing do
  @moduledoc false
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

    # TODO: route the heat change through Shunt.Heat:
    #   new_heat = Shunt.Heat.clamp(player.heat + item.heat_cost)
    #   {final_heat, event} = Shunt.Heat.resolve(player.heat, new_heat)
    # Then apply scrip/cred event penalties on top of the existing scrip/cred gains
    # (clamped at 0, e.g. max(player.scrip + item.sell_value - (event && event.scrip_loss || 0), 0)),
    # set heat: final_heat instead of clamp_heat(...), delete the private clamp_heat/1
    # function below, and change this function's return to {:ok, player, event} /
    # {:error, reason} so DashboardLive can flash the fired event.
    player
    |> Ecto.Changeset.change(%{
      scrip: player.scrip + item.sell_value,
      cred: player.cred + item.cred_gain,
      heat: clamp_heat(player.heat + item.heat_cost),
      held_item_key: nil
    })
    |> Repo.update()
  end

  defp clamp_heat(heat), do: heat |> max(0) |> min(100)
end
