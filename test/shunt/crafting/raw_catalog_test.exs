defmodule Shunt.Crafting.RawCatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Crafting.RawCatalog

  # TODO: describe "items/0" — assert it returns 4 items, each with a unique :key, and
  # assert every item has a non-empty :scavenge_text

  # TODO: describe "fetch!/1" — assert RawCatalog.fetch!("stripped_copper_coil") returns
  # the matching map (spot-check :name), and assert RawCatalog.fetch!("not_a_real_key")
  # raises a RuntimeError matching ~r/unknown raw material key/
end
