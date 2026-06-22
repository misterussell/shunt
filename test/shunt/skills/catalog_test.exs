defmodule Shunt.Skills.CatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Players.Player
  alias Shunt.Skills.Catalog

  describe "trees/0" do
    test "returns four trees with unique keys, tier fields, and five ordered tiers each" do
      trees = Catalog.trees()

      assert length(trees) == 4
      assert length(Enum.uniq(Enum.map(trees, & &1.key))) == 4
      assert length(Enum.uniq(Enum.map(trees, & &1.tier_field))) == 4

      for tree <- trees do
        assert Enum.map(tree.tiers, & &1.tier) == [1, 2, 3, 4, 5]
      end
    end
  end

  describe "current_tier/2" do
    test "reads the tree's tier_field off the given player" do
      tree = Enum.find(Catalog.trees(), &(&1.key == "ghostwork"))
      player = %Player{ghostwork_tier: 2}

      assert Catalog.current_tier(player, tree) == 2
    end
  end
end
