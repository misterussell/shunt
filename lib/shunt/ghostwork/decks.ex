defmodule Shunt.Ghostwork.Decks do
  @moduledoc """
  Catalog of decks (deck hardware). A deck is an inventory item that gates Ghostwork AND
  defines the player's program loadout size. Mirrors `Shunt.Ghostwork.Programs`.

  A deck is a plain content map (no struct), shaped:

      %{
        id: "jury_rigged_terminal",   # matches the inventory key AND the skill tree tool_key
        name: "Jury-Rigged Terminal",
        slots: 3,                      # how many programs fit in the loadout
        text: "..."
      }

  See priv/docs/SHUNT_ghostwork_v1.md ("Axis 1 — Gear"): the deck is the other half of gear
  (deck + programs). Better decks grant more slots.
  """

  alias Shunt.Content

  def all, do: Content.all(:decks)

  def fetch!(id), do: Content.fetch!(:decks, id)

  def owned(player) do
    Enum.filter(all(), fn deck -> Map.get(player.inventory, deck.id, 0) >= 1 end)
  end
end
