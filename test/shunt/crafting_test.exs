defmodule Shunt.CraftingTest do
  use Shunt.DataCase

  alias Shunt.Crafting
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Players
  alias Shunt.Repo

  # TODO: describe "scavenge/1" —
  #   test "adds one of a valid Raw to inventory and raises heat by 4": create a player via
  #   Players.create_player!(), call {:ok, updated} = Crafting.scavenge(player), assert
  #   updated.heat == player.heat + 4, assert the inventory gained exactly 1 across all keys
  #   (Enum.sum(Map.values(updated.inventory)) == Enum.sum(Map.values(player.inventory)) + 1),
  #   and assert every key present in updated.inventory is a valid RawCatalog key.
  #
  #   test "clamps heat at 100": seed heat: 99 via Ecto.Changeset.change/2 + Repo.update/1,
  #   call Crafting.scavenge/1, assert updated.heat == 100.

  # TODO: describe "assemble/2" —
  #   test "consumes inputs and adds the output when tier and materials are sufficient":
  #   seed a player with street_alchemy_tier: 1 and inventory matching/exceeding
  #   RecipeCatalog.fetch!("patchwork_courier_drone").inputs via Ecto.Changeset.change/2 +
  #   Repo.update/1, call {:ok, updated} = Crafting.assemble(player, "patchwork_courier_drone"),
  #   assert each input key decremented by its recipe quantity, and assert
  #   updated.inventory["patchwork_courier_drone"] == 1.
  #
  #   test "returns :insufficient_tier when street_alchemy_tier is below the requirement":
  #   create a fresh player (tier 0 by default), assert
  #   Crafting.assemble(player, "patchwork_courier_drone") == {:error, :insufficient_tier}.
  #
  #   test "returns :insufficient_materials when an input quantity is missing": seed
  #   street_alchemy_tier: 1 with an empty inventory, assert
  #   Crafting.assemble(player, "patchwork_courier_drone") == {:error, :insufficient_materials}.

  # TODO: describe "sell_assembled/2" —
  #   test "pays scrip, cred, and heat, and decrements inventory": seed a player with
  #   inventory: %{"patchwork_courier_drone" => 1}, scrip: 0, cred: 0, heat: 0 via
  #   Ecto.Changeset.change/2 + Repo.update/1, call
  #   {:ok, updated} = Crafting.sell_assembled(player, "patchwork_courier_drone"), assert
  #   updated.scrip == recipe.sell_value, updated.cred == recipe.cred_gain,
  #   updated.heat == recipe.heat_cost, and updated.inventory["patchwork_courier_drone"] == 0.
  #
  #   test "returns :no_item when the player doesn't own one": create a fresh player, assert
  #   Crafting.sell_assembled(player, "patchwork_courier_drone") == {:error, :no_item}.
end
