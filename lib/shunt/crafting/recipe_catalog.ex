defmodule Shunt.Crafting.RecipeCatalog do
  @moduledoc false

  @recipes [
    %{
      key: "patchwork_courier_drone",
      name: "Patchwork Courier Drone",
      tier_required: 1,
      inputs: %{"junked_servo_motor" => 1, "cracked_chassis_plating" => 1},
      sell_value: 70,
      cred_gain: 3,
      heat_cost: 10,
      craft_text:
        "Bolt the servo into the cracked chassis and it twitches awake, rotors whining.",
      sell_text: "A courier broker doesn't care that it's held together with tape."
    },
    %{
      key: "splice_tap_relay",
      name: "Splice-Tap Relay",
      tier_required: 1,
      inputs: %{"frayed_optic_cable" => 2, "stripped_copper_coil" => 1},
      sell_value: 55,
      cred_gain: 2,
      heat_cost: 8,
      craft_text: "Splice the optic strands into the coil and the relay hums to a faint signal.",
      sell_text: "A line-tapper pays cash for anything that still carries a signal."
    },
    %{
      key: "jury_rigged_stim_rig",
      name: "Jury-Rigged Stim Rig",
      tier_required: 1,
      inputs: %{"junked_servo_motor" => 1, "stripped_copper_coil" => 2},
      sell_value: 65,
      cred_gain: 3,
      heat_cost: 9,
      craft_text: "The servo's pump action drives the coils into a rough injector cycle.",
      sell_text: "A back-alley medic takes it without asking who it was built for."
    }
  ]

  def recipes, do: @recipes

  def fetch!(key) do
    Enum.find(@recipes, &(&1.key == key)) ||
      raise "unknown recipe key: #{inspect(key)}"
  end
end
