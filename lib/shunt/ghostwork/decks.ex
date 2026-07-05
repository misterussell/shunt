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

  # TODO: `alias Shunt.Content` and implement `all/0` and `fetch!/1` delegating to
  # Content.all(:decks) / Content.fetch!(:decks, id), exactly like Shunt.Ghostwork.Programs.
  #
  # TODO: implement `owned(player)` -> the decks whose id is in player.inventory (>= 1),
  # mirroring Programs.owned/1.
  #
  # TODO: seed priv/content/decks/jury_rigged_terminal.exs as %{id: "jury_rigged_terminal",
  # name: "Jury-Rigged Terminal", slots: 3, text: ...}. slots: 3 preserves today's hardcoded
  # @loadout_slots so behavior is unchanged until better decks drop.
end
