defmodule Shunt.CraftingTest do
  use ExUnit.Case, async: true

  alias Shunt.Crafting
  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Players.Player

  describe "scavenge/1" do
    test "returns effects for a random raw and a heat increase of 2, naming the raw gained" do
      player = %Player{}

      assert {:ok, [{:inventory, key, 1}, {:heat, 2}], %{gained_raw: key}} =
               Crafting.scavenge(player)

      raw_keys = Enum.map(RawCatalog.items(), & &1.id)
      assert key in raw_keys
    end
  end

  describe "craftable?/2" do
    test "returns true when the player has at least the required quantity of every input" do
      recipe = RecipeCatalog.fetch!("patchwork_courier_drone")
      player = %Player{inventory: Map.put(recipe.inputs, "scrap_forged_soldering_iron", 1)}

      assert Crafting.craftable?(player, recipe)
    end

    test "returns false when an input quantity is missing" do
      recipe = RecipeCatalog.fetch!("patchwork_courier_drone")
      player = %Player{inventory: %{"scrap_forged_soldering_iron" => 1}}

      refute Crafting.craftable?(player, recipe)
    end
  end

  describe "assemble/2" do
    test "returns input-decrement and output-increment effects when tier and materials are sufficient" do
      recipe = RecipeCatalog.fetch!("patchwork_courier_drone")
      player = %Player{inventory: Map.put(recipe.inputs, "scrap_forged_soldering_iron", 1)}

      expected_effects =
        Enum.map(recipe.inputs, fn {raw_key, qty} -> {:inventory, raw_key, -qty} end) ++
          [{:inventory, recipe.id, 1}]

      assert Crafting.assemble(player, "patchwork_courier_drone") == {:ok, expected_effects}
    end

    test "returns :insufficient_tier when street_alchemy_tier is below the requirement" do
      player = %Player{}

      assert Crafting.assemble(player, "patchwork_courier_drone") == {:error, :insufficient_tier}
    end

    test "returns :insufficient_materials when an input quantity is missing" do
      player = %Player{inventory: %{"scrap_forged_soldering_iron" => 1}}

      assert Crafting.assemble(player, "patchwork_courier_drone") ==
               {:error, :insufficient_materials}
    end

    test "tier_required: 0 recipes need no tool or tier" do
      recipe = RecipeCatalog.fetch!("scrap_forged_soldering_iron")
      player = %Player{inventory: recipe.inputs}

      expected_effects =
        Enum.map(recipe.inputs, fn {raw_key, qty} -> {:inventory, raw_key, -qty} end) ++
          [{:inventory, recipe.id, 1}]

      assert Crafting.assemble(player, "scrap_forged_soldering_iron") == {:ok, expected_effects}
    end
  end

  describe "sell_assembled/2" do
    test "returns effects for inventory, heat, scrip, and cred" do
      recipe = RecipeCatalog.fetch!("patchwork_courier_drone")
      player = %Player{inventory: %{"patchwork_courier_drone" => 1}}

      assert Crafting.sell_assembled(player, "patchwork_courier_drone") ==
               {:ok,
                [
                  {:inventory, "patchwork_courier_drone", -1},
                  {:heat, recipe.heat_cost},
                  {:scrip, recipe.sell_value},
                  {:cred, recipe.cred_gain}
                ]}
    end

    test "returns :no_item when the player doesn't own one" do
      player = %Player{}

      assert Crafting.sell_assembled(player, "patchwork_courier_drone") == {:error, :no_item}
    end
  end
end
