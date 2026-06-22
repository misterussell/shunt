defmodule Shunt.Crafting.RawCatalog do
  @moduledoc false

  # TODO: define @raws, a list of 4 maps, one per Raw material, each shaped as:
  #   %{key: "...", name: "...", scavenge_text: "..."}
  # (scavenge_text is flavor shown when this Raw is found via Crafting.scavenge/1)
  # Entries, salvage/scrap-flavored (distinct from Fencing.Catalog's "hot contraband" framing):
  #   key: "stripped_copper_coil", name: "Stripped Copper Coil"
  #   key: "cracked_chassis_plating", name: "Cracked Chassis Plating"
  #   key: "junked_servo_motor", name: "Junked Servo Motor"
  #   key: "frayed_optic_cable", name: "Frayed Optic Cable"
  # Write a one-sentence scavenge_text for each, in the same terse, cyberpunk-underbelly
  # voice as Fencing.Catalog's offer_text/sell_text entries.

  # TODO: def items, do: @raws

  # TODO: def fetch!(key) — Enum.find(@raws, &(&1.key == key)), or raise
  # "unknown raw material key: #{inspect(key)}" on no match (mirrors Fencing.Catalog.fetch!/1)
end
