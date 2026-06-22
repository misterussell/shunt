defmodule Shunt.Content.StoreTest do
  use ExUnit.Case, async: true

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

    test "raws: returns 16 raws with the expected keys and shape" do
      raws = Content.all(:raws)

      assert length(raws) == 16

      for raw <- raws do
        assert Map.has_key?(raw, :key)
        assert Map.has_key?(raw, :name)
        assert Map.has_key?(raw, :scavenge_text)
      end
    end

    test "raws: fetch!/2 returns the raw map for a known key" do
      raw = Content.fetch!(:raws, "stripped_copper_coil")

      assert raw.name == "Stripped Copper Coil"
    end

    test "recipes: returns 7 recipes with the expected keys and shape" do
      recipes = Content.all(:recipes)

      assert length(recipes) == 7

      for recipe <- recipes do
        assert Map.has_key?(recipe, :key)
        assert Map.has_key?(recipe, :inputs)
        assert Map.has_key?(recipe, :tier_required)
      end
    end

    test "recipes: fetch!/2 returns the recipe map for a known key" do
      recipe = Content.fetch!(:recipes, "patchwork_courier_drone")

      assert recipe.name == "Patchwork Courier Drone"
      assert recipe.sell_value == 70
    end

    test "heat_events: returns 9 events with the expected keys and shape" do
      events = Content.all(:heat_events)

      assert length(events) == 9

      for event <- events do
        assert Map.has_key?(event, :key)
        assert Map.has_key?(event, :band)
        assert Map.has_key?(event, :scrip_loss)
        assert Map.has_key?(event, :cred_loss)
      end
    end

    test "heat_events: fetch!/2 returns the event map for a known key" do
      event = Content.fetch!(:heat_events, "rival_undercuts_prices")

      assert event.name == "Rival Undercuts Prices"
      assert event.band == :low
    end

    test "skill_trees: fetch!/2 with the :skill_trees key returns the full trees list" do
      trees = Content.fetch!(:skill_trees, :skill_trees)

      assert length(trees) == 4

      assert MapSet.new(Enum.map(trees, & &1.key)) ==
               MapSet.new(["ghostwork", "chrome_meat", "web", "street_alchemy"])
    end

    test "repeated calls don't error" do
      assert Content.all(:npcs) == Content.all(:npcs)
    end
  end

  describe "load_source/2 for :skill_trees" do
    test "raises a clear error instead of a CaseClauseError when more than one file is found" do
      dir = "priv/content/skills"
      extra_file = Path.join(Application.app_dir(:shunt, dir), "extra.exs")
      File.write!(extra_file, "%{}")
      on_exit(fn -> File.rm!(extra_file) end)

      assert_raise RuntimeError, ~r/expected exactly one skill_trees content file/, fn ->
        Shunt.Content.Store.load_source(:skill_trees, dir)
      end
    end
  end
end
