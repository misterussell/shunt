defmodule Shunt.Crafting.RecipeCatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog

  describe "recipes/0" do
    test "returns 7 recipes with valid tiers, inputs, and raw key references" do
      recipes = RecipeCatalog.recipes()
      raw_keys = Enum.map(RawCatalog.items(), & &1.id)

      assert length(recipes) == 7
      assert recipes |> Enum.map(& &1.id) |> Enum.uniq() |> length() == 7
      assert Enum.all?(recipes, &(&1.tier_required >= 0))
      assert Enum.all?(recipes, &(map_size(&1.inputs) > 0))

      assert Enum.all?(recipes, fn recipe ->
               Enum.all?(recipe.inputs, fn {raw_key, _qty} -> raw_key in raw_keys end)
             end)
    end
  end

  describe "fetch!/1" do
    test "returns the matching recipe" do
      recipe = RecipeCatalog.fetch!("patchwork_courier_drone")

      assert recipe.name == "Patchwork Courier Drone"
      assert recipe.sell_value == 70
    end

    test "raises on an unknown key" do
      assert_raise RuntimeError, ~r/unknown recipes key/, fn ->
        RecipeCatalog.fetch!("not_a_real_key")
      end
    end
  end
end
