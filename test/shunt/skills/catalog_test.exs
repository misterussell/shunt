defmodule Shunt.Skills.CatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Players.Player
  alias Shunt.Skills.Catalog

  describe "trees/0" do
    test "returns four trees with unique keys, tier fields, and five ordered tiers each" do
      trees = Catalog.trees()

      assert length(trees) == 4
      assert length(Enum.uniq(Enum.map(trees, & &1.id))) == 4
      assert length(Enum.uniq(Enum.map(trees, & &1.tier_field))) == 4

      for tree <- trees do
        assert Enum.map(tree.tiers, & &1.tier) == [1, 2, 3, 4, 5]
      end
    end
  end

  describe "current_tier/2" do
    test "returns 1 when the player holds the tree's tool in inventory" do
      tree = Enum.find(Catalog.trees(), &(&1.id == "ghostwork"))
      player = %Player{inventory: %{"jury_rigged_terminal" => 1}}

      assert Catalog.current_tier(player, tree) == 1
    end

    test "returns 0 when the player doesn't hold the tool, ignoring the stored tier field" do
      tree = Enum.find(Catalog.trees(), &(&1.id == "ghostwork"))
      player = %Player{inventory: %{}, ghostwork_tier: 2}

      assert Catalog.current_tier(player, tree) == 0
    end
  end

  describe "fetch!/1" do
    test "returns the matching tree" do
      assert Catalog.fetch!("ghostwork").name == "Ghostwork"
    end

    test "raises on an unknown key" do
      assert_raise RuntimeError, ~r/unknown skill tree id/, fn ->
        Catalog.fetch!("not_a_real_key")
      end
    end
  end
end
