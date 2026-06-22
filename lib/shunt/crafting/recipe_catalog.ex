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
    },
    %{
      key: "jury_rigged_terminal",
      name: "Jury-Rigged Terminal",
      tier_required: 0,
      inputs: %{"cracked_datachip" => 1, "salvaged_fiber_spool" => 1},
      sell_value: 45,
      cred_gain: 1,
      heat_cost: 5,
      craft_text:
        "The datachip's firmware boots just long enough to pair with a spliced fiber uplink.",
      sell_text: "A Midgrid pawnshop pays for anything that still boots."
    },
    %{
      key: "patchwork_scalpel",
      name: "Patchwork Scalpel",
      tier_required: 0,
      inputs: %{"sterile_suture_kit" => 1, "subdermal_wiring_bundle" => 1},
      sell_value: 45,
      cred_gain: 1,
      heat_cost: 5,
      craft_text:
        "Suture-kit steel, honed to an edge, wired to a subdermal grip that hums faintly.",
      sell_text: "Even unlicensed, a working scalpel finds a buyer fast."
    },
    %{
      key: "burner_ledger",
      name: "Burner Ledger",
      tier_required: 0,
      inputs: %{"burner_sim_stack" => 1, "forged_credential_stub" => 1},
      sell_value: 40,
      cred_gain: 1,
      heat_cost: 5,
      craft_text:
        "A burner SIM paired to a half-forged credential — enough to open a ledger no one can trace.",
      sell_text: "Burner hardware moves fast and cheap in the Underbelly."
    },
    %{
      key: "scrap_forged_soldering_iron",
      name: "Scrap-Forged Soldering Iron",
      tier_required: 0,
      inputs: %{"flux_paste_tin" => 1, "scrap_heating_coil" => 1},
      sell_value: 40,
      cred_gain: 1,
      heat_cost: 5,
      craft_text:
        "Flux paste smeared over a scavenged heating coil, and the tip glows cherry-red.",
      sell_text: "A pawnbroker tests the tip against a thumbnail before naming a price."
    }
  ]

  def recipes, do: @recipes

  def fetch!(key) do
    Enum.find(@recipes, &(&1.key == key)) ||
      raise "unknown recipe key: #{inspect(key)}"
  end
end
