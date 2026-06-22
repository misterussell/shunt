defmodule Shunt.Heat.CatalogTest do
  use ExUnit.Case, async: true

  # TODO: test Shunt.Heat.Catalog.events_for_band/1 returns exactly 3 events for each of
  # :low, :medium, :high, and that every returned event's :band field matches the
  # requested band.

  # TODO: test Shunt.Heat.Catalog.fetch!/1 returns the matching event for a known key and
  # raises for an unknown key.
end
