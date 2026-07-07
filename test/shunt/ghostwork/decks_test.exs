defmodule Shunt.Ghostwork.DecksTest do
  # async: false — inserts/deletes in the global :decks ETS table; must not run concurrently
  # with tests that read it (e.g. decks_content_test), or reads race with the temp rows.
  use ExUnit.Case, async: false

  alias Shunt.Ghostwork.Decks
  alias Shunt.Players.Player

  setup do
    deck = %{id: "test_bigrig", name: "Big Rig", slots: 5, text: "A fat deck."}

    :ets.insert(:decks, {deck.id, deck})
    on_exit(fn -> :ets.delete(:decks, deck.id) end)
    %{deck: deck}
  end

  describe "all/0" do
    test "includes loaded decks", %{deck: deck} do
      assert deck in Decks.all()
    end
  end

  describe "fetch!/1" do
    test "returns the deck map for a known id", %{deck: deck} do
      assert Decks.fetch!("test_bigrig") == deck
    end

    test "raises for an unknown id" do
      assert_raise RuntimeError, fn -> Decks.fetch!("no_such_deck") end
    end
  end

  describe "owned/1" do
    test "returns the decks the player holds", %{deck: deck} do
      player = %Player{inventory: %{"test_bigrig" => 1}}

      assert Decks.owned(player) == [deck]
    end

    test "excludes decks absent from inventory" do
      player = %Player{inventory: %{}}

      refute Enum.any?(Decks.owned(player), &(&1.id == "test_bigrig"))
    end
  end
end
