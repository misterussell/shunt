defmodule Shunt.Ghostwork.DecksContentTest do
  @moduledoc """
  Asserts the shipped deck catalog (priv/content/decks). Reads real seeded content;
  assertions stay tolerant (no exact counts) so they don't break as the catalog grows.
  """
  use ExUnit.Case, async: true

  alias Shunt.Ghostwork.Decks

  test "ships the baseline jury-rigged terminal at 3 slots" do
    deck = Decks.fetch!("jury_rigged_terminal")

    assert deck.slots == 3
    assert is_binary(deck.name) and deck.name != ""
  end

  test "every shipped deck is well-formed" do
    for deck <- Decks.all() do
      assert is_binary(deck.id) and deck.id != ""
      assert is_binary(deck.name) and deck.name != ""
      assert is_integer(deck.slots) and deck.slots > 0
    end
  end
end
