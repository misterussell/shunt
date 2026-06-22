defmodule Shunt.Crafting.RawCatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Crafting.RawCatalog

  describe "items/0" do
    # TODO: once the 12 new raws are staged (see TODO in
    # lib/shunt/crafting/raw_catalog.ex), update this test's name and assertions to expect
    # 16 items total, with 16 unique keys.
    test "returns 4 items, each with a unique key and non-empty scavenge_text" do
      items = RawCatalog.items()

      assert length(items) == 4
      assert items |> Enum.map(& &1.key) |> Enum.uniq() |> length() == 4
      assert Enum.all?(items, &(&1.scavenge_text != ""))
    end
  end

  describe "fetch!/1" do
    test "returns the matching raw material" do
      assert RawCatalog.fetch!("stripped_copper_coil").name == "Stripped Copper Coil"
    end

    test "raises on an unknown key" do
      assert_raise RuntimeError, ~r/unknown raw material key/, fn ->
        RawCatalog.fetch!("not_a_real_key")
      end
    end
  end
end
