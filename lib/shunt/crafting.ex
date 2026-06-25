defmodule Shunt.Crafting do
  @moduledoc false
  alias Shunt.Players.Player
  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Skills.Catalog, as: SkillsCatalog

  def scavenge(%Player{}) do
    raw = Enum.random(RawCatalog.items())
    {:ok, [{:inventory, raw.id, 1}, {:heat, 4}], %{gained_raw: raw.id}}
  end

  def craftable?(%Player{} = player, recipe) do
    Enum.all?(recipe.inputs, fn {raw_key, qty} -> Map.get(player.inventory, raw_key, 0) >= qty end)
  end

  def assemble(%Player{} = player, recipe_key) do
    recipe = RecipeCatalog.fetch!(recipe_key)

    cond do
      SkillsCatalog.current_tier(player, SkillsCatalog.fetch!("street_alchemy")) <
          recipe.tier_required ->
        {:error, :insufficient_tier}

      not craftable?(player, recipe) ->
        {:error, :insufficient_materials}

      true ->
        input_effects =
          Enum.map(recipe.inputs, fn {raw_key, qty} -> {:inventory, raw_key, -qty} end)

        {:ok, input_effects ++ [{:inventory, recipe.id, 1}]}
    end
  end

  def sell_assembled(%Player{} = player, item_key) do
    recipe = RecipeCatalog.fetch!(item_key)

    if Map.get(player.inventory, item_key, 0) < 1 do
      {:error, :no_item}
    else
      {:ok,
       [
         {:inventory, item_key, -1},
         {:heat, recipe.heat_cost},
         {:scrip, recipe.sell_value},
         {:cred, recipe.cred_gain}
       ]}
    end
  end
end
