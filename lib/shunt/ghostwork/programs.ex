defmodule Shunt.Ghostwork.Programs do
  @moduledoc """
  Catalog of programs (deck software). Each program is an inventory item AND an
  action the player can run in an ICE encounter.

  A program is a plain content map (no struct), shaped:

      %{
        id: "mimic_daemon",          # matches the inventory key
        name: "Mimic Daemon",
        action: :spoof,              # action type; matched against a layer's :weakness
        progress: 4,
        trace: 3,
        on_weakness: %{progress: 8, trace: 1},
        text: "Wraps your handshake in a forged corp signature."
      }

  See priv/docs/SHUNT_ghostwork_v1.md ("A program").
  """

  alias Shunt.Content

  def all, do: Content.all(:programs)

  def fetch!(id), do: Content.fetch!(:programs, id)

  def owned(player) do
    Enum.filter(all(), fn program -> Map.get(player.inventory, program.id, 0) >= 1 end)
  end

  # TODO: Add loadout/1 — the programs runnable in an encounter: owned(player) filtered to
  # those whose id is in the player's equipped loadout (Ghostwork.loadout/1). The encounter
  # action bar shows Probe + these (<= 3). owned/1 stays as the full library the rail
  # LOADOUT panel offers to equip from.
end
