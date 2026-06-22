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
    # TODO: replace this test (current_tier/2 no longer reads tree.tier_field off the
    # player — see TODO in lib/shunt/skills/catalog.ex). Rewrite as two tests, both using
    # the ghostwork tree (tool_key: "jury_rigged_terminal" once staged):
    #   1. a player with `inventory: %{"jury_rigged_terminal" => 1}` asserts
    #      Catalog.current_tier(player, tree) == 1.
    #   2. a player with an empty inventory AND ghostwork_tier: 2 set (to prove the stored
    #      field is now ignored) asserts Catalog.current_tier(player, tree) == 0.
    test "reads the tree's tier_field off the given player" do
      tree = Enum.find(Catalog.trees(), &(&1.key == "ghostwork"))
      player = %Player{ghostwork_tier: 2}

      assert Catalog.current_tier(player, tree) == 2
    end
  end
end
