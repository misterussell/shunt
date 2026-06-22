# TODO: per priv/docs/architecture.md Section 4, once Shunt.Content.Store
# (lib/shunt/content/store.ex) is implemented and wired into lib/shunt/application.ex with
# an :npcs source pointed at priv/content/npcs, delete this entire file - its coverage is
# superseded by a generic test/shunt/content/store_test.exs exercising Shunt.Content.all/1
# and Shunt.Content.fetch!/2 across all 6 sources (see the @sources TODO in
# lib/shunt/content/store.ex). Also delete lib/shunt/npcs/store.ex itself at that point (see
# the TODO already at the top of that file).
defmodule Shunt.Npcs.StoreTest do
  use ExUnit.Case, async: true

  alias Shunt.Npcs.Store

  describe "all/0" do
    test "returns 5 npcs with the expected keys and shape" do
      npcs = Store.all()

      assert length(npcs) == 5

      for npc <- npcs do
        assert Map.has_key?(npc, :key)
        assert Map.has_key?(npc, :name)
        assert Map.has_key?(npc, :faction)
        assert Map.has_key?(npc, :trade_actions)
      end

      assert MapSet.new(Enum.map(npcs, & &1.key)) ==
               MapSet.new(["rook", "splice", "nine_iron", "mother_graft", "tally"])
    end
  end

  describe "fetch!/1" do
    test "returns the npc map for a known key" do
      npc = Store.fetch!("rook")

      assert npc.name == "Rook"
      assert npc.faction == :syndicate_of_closed_hands
    end

    test "raises for an unknown key" do
      assert_raise RuntimeError, fn -> Store.fetch!("unknown") end
    end
  end

  test "repeated calls don't error" do
    assert Store.all() == Store.all()
  end
end
