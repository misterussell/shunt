defmodule Shunt.Crafting do
  @moduledoc false
  alias Shunt.Players.Player
  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Repo

  def scavenge(%Player{} = player) do
    raw = Enum.random(RawCatalog.items())

    player
    |> Ecto.Changeset.change(%{
      inventory: Map.update(player.inventory, raw.key, 1, &(&1 + 1)),
      heat: clamp_heat(player.heat + 4)
    })
    |> Repo.update()
  end

  def assemble(%Player{} = player, recipe_key) do
    recipe = RecipeCatalog.fetch!(recipe_key)

    cond do
      player.street_alchemy_tier < recipe.tier_required ->
        {:error, :insufficient_tier}

      Enum.any?(recipe.inputs, fn {raw_key, qty} ->
        Map.get(player.inventory, raw_key, 0) < qty
      end) ->
        {:error, :insufficient_materials}

      true ->
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
      player
      |> Ecto.Changeset.change(%{
        inventory: Map.update!(player.inventory, item_key, &(&1 - 1)),
        scrip: player.scrip + recipe.sell_value,
        cred: player.cred + recipe.cred_gain,
        heat: clamp_heat(player.heat + recipe.heat_cost)
      })
      |> Repo.update()
    end
  end

  defp clamp_heat(heat), do: heat |> max(0) |> min(100)
end
