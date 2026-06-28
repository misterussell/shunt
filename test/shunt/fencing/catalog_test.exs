defmodule Shunt.Fencing.CatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Fencing.Catalog

  describe "items/0" do
    test "spans clean, warm, and hot tiers" do
      items = Catalog.items()

      assert length(items) >= 6
      assert Enum.count(items, &(&1.tier == :clean)) >= 2
      assert Enum.count(items, &(&1.tier == :warm)) >= 2
      assert Enum.count(items, &(&1.tier == :hot)) >= 2
    end

    test "every item has a unique key and a positive margin" do
      items = Catalog.items()
      keys = Enum.map(items, & &1.id)

      assert length(Enum.uniq(keys)) == length(keys)
      assert Enum.all?(items, &(&1.sell_value > &1.buy_cost))
    end
  end

  describe "fetch!/1" do
    test "returns the item matching the given key" do
      item = Catalog.fetch!("scrap_dermal_plating")

      assert item.name == "Scrap Dermal Plating"
    end

    test "raises when the key is not in the catalog" do
      assert_raise RuntimeError, ~r/unknown fencing_items key/, fn ->
        Catalog.fetch!("not_a_real_key")
      end
    end
  end
end
