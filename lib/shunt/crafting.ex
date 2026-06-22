defmodule Shunt.Crafting do
  @moduledoc false
  alias Shunt.Players.Player
  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Repo

  # TODO: implement scavenge(%Player{} = player) — always succeeds (no "in progress" gate;
  # inventory has no slot limit, unlike Fencing's single held_item_key). Pick
  # raw = Enum.random(RawCatalog.items()), then update the player via
  # Ecto.Changeset.change/2 + Repo.update/1 to:
  #   - set inventory: Map.update(player.inventory, raw.key, 1, &(&1 + 1))
  #   - set heat: clamp_heat(player.heat + 4)
  # Return {:ok, updated_player}.
  def scavenge(%Player{} = player) do
  end

  # TODO: implement assemble(%Player{} = player, recipe_key) — fetch
  # recipe = RecipeCatalog.fetch!(recipe_key), then:
  #   - return {:error, :insufficient_tier} if player.street_alchemy_tier < recipe.tier_required
  #   - return {:error, :insufficient_materials} if, for any {raw_key, qty} in recipe.inputs,
  #     Map.get(player.inventory, raw_key, 0) < qty
  #   - otherwise update the player via Ecto.Changeset.change/2 + Repo.update/1: subtract every
  #     recipe.inputs quantity from the matching inventory key (Map.update!/3 with subtraction),
  #     then increment inventory[recipe.key] by 1 (Map.update/4 default 1, else +1).
  #     No Scrip/Heat cost — return {:ok, updated_player}.
  def assemble(%Player{} = player, recipe_key) do
  end

  # TODO: implement sell_assembled(%Player{} = player, item_key) — fetch
  # recipe = RecipeCatalog.fetch!(item_key) (the assembled item's key is always a recipe key),
  # then:
  #   - return {:error, :no_item} if Map.get(player.inventory, item_key, 0) < 1
  #   - otherwise update the player via Ecto.Changeset.change/2 + Repo.update/1:
  #     decrement inventory[item_key] by 1, scrip: player.scrip + recipe.sell_value,
  #     cred: player.cred + recipe.cred_gain, heat: clamp_heat(player.heat + recipe.heat_cost).
  #     Return {:ok, updated_player}.
  def sell_assembled(%Player{} = player, item_key) do
  end

  # TODO: implement clamp_heat(heat), do: heat |> max(0) |> min(100)
  # (duplicated locally rather than shared, matching the existing duplication in
  # Shunt.Fencing and Shunt.Players)
end
