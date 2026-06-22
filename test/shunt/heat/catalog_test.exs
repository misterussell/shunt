defmodule Shunt.Heat.CatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Heat.Catalog

  describe "events_for_band/1" do
    test "returns exactly 3 events for each band, all tagged with that band" do
      for band <- [:low, :medium, :high] do
        events = Catalog.events_for_band(band)
        assert length(events) == 3
        assert Enum.all?(events, &(&1.band == band))
      end
    end
  end

  describe "fetch!/1" do
    test "returns the matching event for a known key" do
      [event | _] = Catalog.events_for_band(:low)

      assert Catalog.fetch!(event.key) == event
    end

    test "raises for an unknown key" do
      assert_raise RuntimeError, ~r/unknown heat_events key/, fn ->
        Catalog.fetch!("not-a-real-key")
      end
    end
  end
end
