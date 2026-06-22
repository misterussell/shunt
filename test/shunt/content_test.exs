defmodule Shunt.ContentTest do
  use ExUnit.Case, async: true

  # TODO: once Shunt.Content.all/1 and Shunt.Content.fetch!/2 are implemented
  # (lib/shunt/content.ex), write pure unit tests against an ETS table set up directly in
  # this test (e.g. :ets.new(:test_table, [:set, :public, :named_table]) then
  # :ets.insert(:test_table, {"a", %{key: "a"}})) covering:
  #   - all/1 returns every inserted item, regardless of insertion order
  #   - fetch!/2 returns the item for a known key
  #   - fetch!/2 raises "unknown :test_table key: ..." for an unknown key, mirroring
  #     Shunt.Npcs.Store.fetch!/1's existing error message shape
  describe "all/1 and fetch!/2" do
  end
end
