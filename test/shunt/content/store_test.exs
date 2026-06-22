defmodule Shunt.Content.StoreTest do
  use ExUnit.Case, async: true

  # TODO: once Crafting.RawCatalog, Crafting.RecipeCatalog, Heat.Catalog, and Skills.Catalog
  # migrate their data into priv/content/<type>/*.exs (see each module's own staged TODO),
  # add equivalent coverage here for the :raws, :recipes, :heat_events, and :skill_trees
  # sources. For now only :npcs and :fencing_items have migrated content.

  alias Shunt.Content

  describe "all sources load at boot" do
    test "npcs: returns 5 npcs with the expected keys and shape" do
      npcs = Content.all(:npcs)

      assert length(npcs) == 5

      for npc <- npcs do
        assert Map.has_key?(npc, :key)
        assert Map.has_key?(npc, :name)
        assert Map.has_key?(npc, :faction)
        assert Map.has_key?(npc, :trade_actions)
      end

      assert MapSet.new(Enum.map(npcs, & &1.key)) ==
               MapSet.new(["rook", "splice", "nine_iron", "mother_graft", "tally"])
    end

    test "npcs: fetch!/2 returns the npc map for a known key" do
      npc = Content.fetch!(:npcs, "rook")

      assert npc.name == "Rook"
      assert npc.faction == :syndicate_of_closed_hands
    end

    test "npcs: fetch!/2 raises for an unknown key" do
      assert_raise RuntimeError, fn -> Content.fetch!(:npcs, "unknown") end
    end

    test "fencing_items: returns six items spanning clean, warm, and hot tiers" do
      items = Content.all(:fencing_items)

      assert length(items) == 6
      assert Enum.count(items, &(&1.tier == :clean)) == 2
      assert Enum.count(items, &(&1.tier == :warm)) == 2
      assert Enum.count(items, &(&1.tier == :hot)) == 2
    end

    test "fencing_items: fetch!/2 returns the item for a known key" do
      item = Content.fetch!(:fencing_items, "scrap_dermal_plating")

      assert item.name == "Scrap Dermal Plating"
    end

    test "repeated calls don't error" do
      assert Content.all(:npcs) == Content.all(:npcs)
    end
  end
end
