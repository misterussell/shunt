defmodule Shunt.Crafting.RecipeCatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog

  # TODO: describe "recipes/0" — assert it returns 3 recipes, each with a unique :key,
  # :tier_required >= 1, a non-empty :inputs map, and assert every raw key referenced in
  # every recipe's :inputs exists in RawCatalog.items() (cross-catalog integrity check)

  # TODO: describe "fetch!/1" — assert RecipeCatalog.fetch!("patchwork_courier_drone")
  # returns the matching map (spot-check :name and :sell_value), and assert
  # RecipeCatalog.fetch!("not_a_real_key") raises a RuntimeError matching
  # ~r/unknown recipe key/
end
