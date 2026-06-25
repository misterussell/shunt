defmodule Shunt.Crafting.RawCatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Crafting.RawCatalog

  describe "items/0" do
    test "returns items, each with a unique key and non-empty scavenge_text" do
      items = RawCatalog.items()

      assert items |> Enum.map(& &1.id) |> Enum.uniq() |> length() == length(items)
      assert Enum.all?(items, &(&1.scavenge_text != ""))
    end
  end

  describe "fetch!/1" do
    test "returns the matching raw material" do
      assert RawCatalog.fetch!("stripped_copper_coil").name == "Stripped Copper Coil"
    end

    test "raises on an unknown key" do
      assert_raise RuntimeError, ~r/unknown raws key/, fn ->
        RawCatalog.fetch!("not_a_real_key")
      end
    end
  end
end
