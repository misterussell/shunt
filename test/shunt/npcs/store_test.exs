defmodule Shunt.Npcs.StoreTest do
  use ExUnit.Case, async: true

  alias Shunt.Npcs.Store

  # TODO: describe "all/0" — assert it returns 5 NPCs, that every npc has the keys
  # :key, :name, :faction, :loyalty, :trade_actions, and that the 5 :key values are
  # exactly ["rook", "splice", "nine_iron", "mother_graft", "tally"] (order-independent,
  # use MapSet or sort both sides).

  # TODO: describe "fetch!/1" — assert Store.fetch!("rook") returns the rook map
  # (spot-check :name == "Rook" and :faction == :syndicate_of_closed_hands), and assert
  # Store.fetch!("unknown") raises a RuntimeError.

  # TODO: test "repeated calls don't error" — call Store.all/0 twice in the same test and
  # assert both calls return the same 5 npcs (covers the lazy ensure_loaded/0 path being
  # safe to call when the table already exists).
end
