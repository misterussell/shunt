defmodule Shunt.Content.StoreTest do
  use ExUnit.Case, async: true

  alias Shunt.Content

  describe "all sources load at boot" do
    test "npcs: returns 5 npcs with the expected keys and shape" do
      npcs = Content.all(:npcs)

      assert length(npcs) == 5

      for npc <- npcs do
        assert Map.has_key?(npc, :id)
        assert Map.has_key?(npc, :name)
        assert Map.has_key?(npc, :faction)
        assert Map.has_key?(npc, :trade_actions)
      end

      assert MapSet.new(Enum.map(npcs, & &1.id)) ==
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

    test "raws: returns raws with the expected keys and shape" do
      raws = Content.all(:raws)

      for raw <- raws do
        assert Map.has_key?(raw, :id)
        assert Map.has_key?(raw, :name)
        assert Map.has_key?(raw, :scavenge_text)
      end
    end

    test "raws: fetch!/2 returns the raw map for a known key" do
      raw = Content.fetch!(:raws, "stripped_copper_coil")

      assert raw.name == "Stripped Copper Coil"
    end

    test "recipes: returns recipes with the expected keys and shape" do
      recipes = Content.all(:recipes)

      assert recipes != []

      for recipe <- recipes do
        assert Map.has_key?(recipe, :id)
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
        assert Map.has_key?(event, :id)
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

      assert MapSet.new(Enum.map(trees, & &1.id)) ==
               MapSet.new(["ghostwork", "chrome_meat", "web", "street_alchemy"])
    end

    test "repeated calls don't error" do
      assert Content.all(:npcs) == Content.all(:npcs)
    end

    test "events: fetch!/2 returns the event for a known key" do
      event = Content.fetch!(:events, "shunt9_player_squat_deck")

      assert event.title == "Broken Deck"
    end

    test "locations: loads them from the nested shunt9/ dir" do
      ids = Enum.map(Content.all(:locations), & &1.id)
      assert "shunt9_bazaar" in ids
    end
  end

  describe "all sources load at boot (web v2)" do
    test "rumors: loads the example juno_supplier rumor from priv/content/rumors/" do
      rumors = Content.all(:rumors)

      assert Enum.any?(rumors, &(&1.id == "juno_supplier"))
    end

    test "rumor_connections: loads the example supplier_conspiracy connection" do
      connections = Content.all(:rumor_connections)

      assert Enum.any?(connections, &(&1.id == "supplier_conspiracy"))
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
