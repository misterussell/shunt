defmodule Shunt.Crafting.RecipeCatalog do
  @moduledoc false

  # TODO: define @recipes, a list of 3 maps, one per recipe, each shaped as:
  #   %{
  #     key: "...",
  #     name: "...",
  #     tier_required: 1,
  #     inputs: %{"<raw_key>" => qty, ...},
  #     sell_value: ...,
  #     cred_gain: ...,
  #     heat_cost: ...,
  #     craft_text: "...",
  #     sell_text: "..."
  #   }
  # The assembled item produced by a recipe shares that recipe's :key — there is no
  # separate assembled-item catalog; Crafting.assemble/2 stores the output under
  # inventory[recipe.key], and Crafting.sell_assembled/2 looks the key back up here.
  # Inputs reference Shunt.Crafting.RawCatalog keys.
  # Entries (all tier_required: 1, per the agreed design — see note below):
  #   key: "patchwork_courier_drone", name: "Patchwork Courier Drone"
  #     inputs: %{"junked_servo_motor" => 1, "cracked_chassis_plating" => 1}
  #     sell_value: 70, cred_gain: 3, heat_cost: 10
  #   key: "splice_tap_relay", name: "Splice-Tap Relay"
  #     inputs: %{"frayed_optic_cable" => 2, "stripped_copper_coil" => 1}
  #     sell_value: 55, cred_gain: 2, heat_cost: 8
  #   key: "jury_rigged_stim_rig", name: "Jury-Rigged Stim Rig"
  #     inputs: %{"junked_servo_motor" => 1, "stripped_copper_coil" => 2}
  #     sell_value: 65, cred_gain: 3, heat_cost: 9
  # Write a one-sentence craft_text and sell_text for each, in the same terse,
  # cyberpunk-underbelly voice as Fencing.Catalog's offer_text/sell_text entries.
  #
  # Note: tier_required: 1 means every recipe is unreachable until a future skill
  # investment feature can raise street_alchemy_tier above 0 — that's intentional and
  # matches how the Skill Trees section already always renders "Locked" today.

  # TODO: def recipes, do: @recipes

  # TODO: def fetch!(key) — Enum.find(@recipes, &(&1.key == key)), or raise
  # "unknown recipe key: #{inspect(key)}" on no match (mirrors Fencing.Catalog.fetch!/1)
end
