defmodule Shunt.Fencing do
  @moduledoc false
  alias Shunt.Heat
  alias Shunt.Repo
  alias Shunt.Players.Player
  alias Shunt.Fencing.Catalog

  # TODO: per priv/docs/architecture.md Section 3, rewrite find_lead/1, take_offer/1,
  # pass_offer/1, and sell_held_item/1 below to return {:ok, effects} / {:ok, effects, meta} /
  # {:error, reason} effect lists (see Shunt.Effects' effect vocabulary) instead of calling
  # Ecto.Changeset.change/Repo.update directly. Preconditions and error returns stay the same -
  # only the success branch of each function changes. Remove the `alias Shunt.Repo` and
  # `alias Shunt.Heat` lines once every function below is converted.

  def find_lead(%Player{current_offer_key: nil, held_item_key: nil} = player) do
    item = Enum.random(Catalog.items())
    # TODO: return {:ok, [{:set, :current_offer_key, item.key}]}

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
      # TODO: return {:ok, [{:scrip, -item.buy_cost}, {:set, :current_offer_key, nil},
      # {:set, :held_item_key, key}]}
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
    # TODO: return {:ok, [{:set, :current_offer_key, nil}]}
    player
    |> Ecto.Changeset.change(%{current_offer_key: nil})
    |> Repo.update()
  end

  def sell_held_item(%Player{held_item_key: nil}), do: {:error, :no_held_item}

  def sell_held_item(%Player{held_item_key: key} = player) do
    item = Catalog.fetch!(key)
    # TODO: return {:ok, [{:heat, item.heat_cost}, {:scrip, item.sell_value},
    # {:cred, item.cred_gain}, {:set, :held_item_key, nil}]} - the {:heat, _} effect now owns
    # the Shunt.Heat.resolve/2 + event-loss logic that the lines below currently duplicate
    # (event_loss/2 and the `final_heat` calc); delete that usage here once Shunt.Effects
    # handles it.
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
