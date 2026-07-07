defmodule Shunt.Crafting.RecipeCatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog

  describe "recipes/0" do
    test "returns recipes with valid tiers, unique ids, inputs, and raw key references" do
      recipes = RecipeCatalog.recipes()
      raw_keys = Enum.map(RawCatalog.items(), & &1.id)

      assert recipes != []
      assert recipes |> Enum.map(& &1.id) |> Enum.uniq() |> length() == length(recipes)
      assert Enum.all?(recipes, &(&1.tier_required >= 0))
      assert Enum.all?(recipes, &(map_size(&1.inputs) > 0))

      assert Enum.all?(recipes, fn recipe ->
               Enum.all?(recipe.inputs, fn {raw_key, _qty} -> raw_key in raw_keys end)
             end)
    end
  end

  describe "routes" do
    test "every recipe carries a non-empty routes list of known route keys" do
      valid_keys = MapSet.new(Shunt.Crafting.Routes.keys())

      for recipe <- RecipeCatalog.recipes() do
        assert is_list(recipe.routes) and recipe.routes != [],
               "recipe #{recipe.id} is missing a non-empty routes list"

        assert MapSet.subset?(MapSet.new(recipe.routes), valid_keys),
               "recipe #{recipe.id} has unknown route(s): " <>
                 inspect(recipe.routes -- Shunt.Crafting.Routes.keys())
      end
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
