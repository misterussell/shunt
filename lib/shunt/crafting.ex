defmodule Shunt.Crafting do
  @moduledoc false
  alias Shunt.Heat
  alias Shunt.Players.Player
  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Repo
  alias Shunt.Skills.Catalog, as: SkillsCatalog

  # TODO: per priv/docs/architecture.md Section 3, rewrite scavenge/1, assemble/2, and
  # sell_assembled/2 below to return effect lists instead of calling
  # Ecto.Changeset.change/Repo.update directly, same pattern as Shunt.Fencing. Remove the
  # `alias Shunt.Repo` and `alias Shunt.Heat` lines once every function below is converted.

  def scavenge(%Player{} = player) do
    raw = Enum.random(RawCatalog.items())
    # TODO: return {:ok, [{:inventory, raw.key, 1}, {:heat, 4}]} - the {:heat, _} effect now
    # owns the Shunt.Heat.resolve/2 + event-loss logic that the lines below currently
    # duplicate; delete that usage here once Shunt.Effects handles it.
    {final_heat, event} = Heat.resolve(player.heat, Heat.clamp(player.heat + 4))

    player
    |> Ecto.Changeset.change(%{
      inventory: Map.update(player.inventory, raw.key, 1, &(&1 + 1)),
      scrip: max(player.scrip - event_loss(event, :scrip_loss), 0),
      cred: max(player.cred - event_loss(event, :cred_loss), 0),
      heat: final_heat
    })
    |> Repo.update()
    |> with_event(event)
  end

  def assemble(%Player{} = player, recipe_key) do
    recipe = RecipeCatalog.fetch!(recipe_key)

    cond do
      SkillsCatalog.current_tier(player, SkillsCatalog.fetch!("street_alchemy")) <
          recipe.tier_required ->
        {:error, :insufficient_tier}

      Enum.any?(recipe.inputs, fn {raw_key, qty} ->
        Map.get(player.inventory, raw_key, 0) < qty
      end) ->
        {:error, :insufficient_materials}

      true ->
        # TODO: return {:ok, effects} where effects is one {:inventory, raw_key, -qty} per
        # {raw_key, qty} in recipe.inputs, plus a trailing {:inventory, recipe.key, 1}
        inventory =
          recipe.inputs
          |> Enum.reduce(player.inventory, fn {raw_key, qty}, inventory ->
            Map.update!(inventory, raw_key, &(&1 - qty))
          end)
          |> Map.update(recipe.key, 1, &(&1 + 1))

        player
        |> Ecto.Changeset.change(%{inventory: inventory})
        |> Repo.update()
    end
  end

  def sell_assembled(%Player{} = player, item_key) do
    recipe = RecipeCatalog.fetch!(item_key)

    if Map.get(player.inventory, item_key, 0) < 1 do
      {:error, :no_item}
    else
      # TODO: return {:ok, [{:inventory, item_key, -1}, {:heat, recipe.heat_cost},
      # {:scrip, recipe.sell_value}, {:cred, recipe.cred_gain}]} - same {:heat, _}
      # consolidation as scavenge/1 above and Shunt.Fencing.sell_held_item/1.
      {final_heat, event} = Heat.resolve(player.heat, Heat.clamp(player.heat + recipe.heat_cost))

      player
      |> Ecto.Changeset.change(%{
        inventory: Map.update!(player.inventory, item_key, &(&1 - 1)),
        scrip: max(player.scrip + recipe.sell_value - event_loss(event, :scrip_loss), 0),
        cred: max(player.cred + recipe.cred_gain - event_loss(event, :cred_loss), 0),
        heat: final_heat
      })
      |> Repo.update()
      |> with_event(event)
    end
  end

  defp with_event({:ok, player}, event), do: {:ok, player, event}
  defp with_event({:error, reason}, _event), do: {:error, reason}

  defp event_loss(nil, _field), do: 0
  defp event_loss(event, field), do: Map.fetch!(event, field)
end
