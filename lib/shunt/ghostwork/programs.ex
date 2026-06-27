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

  # TODO: all/0 returns every program map from the :programs content table via
  # Shunt.Content.all(:programs), mirroring Shunt.Crafting.RawCatalog.items/0.

  # TODO: fetch!(id) returns the program map for id via Shunt.Content.fetch!(:programs, id),
  # mirroring Shunt.Crafting.RawCatalog.fetch!/1; raises on unknown id.

  # TODO: owned(player) returns the program maps the player holds — every program from all/0
  # whose :id has a count >= 1 in player.inventory (program ids are inventory keys).
end
