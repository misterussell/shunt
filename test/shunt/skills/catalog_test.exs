defmodule Shunt.Skills.CatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Skills.Catalog

  # TODO: describe "trees/0" — assert it returns 4 trees, each with a unique :key,
  # a :tier_field atom, and exactly 5 :tiers (tier numbers 1..5 in order)

  # TODO: describe "current_tier/2" — given a %Shunt.Players.Player{} struct with
  # e.g. ghostwork_tier: 2, assert Catalog.current_tier(player, ghostwork_tree) == 2
  # (look up the ghostwork tree via Enum.find(Catalog.trees(), &(&1.key == "ghostwork")))
end
