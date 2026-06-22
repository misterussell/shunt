defmodule Shunt.Crafting.RawCatalog do
  @moduledoc false

  @raws [
    %{
      key: "stripped_copper_coil",
      name: "Stripped Copper Coil",
      scavenge_text: "Pried loose from a gutted junction box, still smelling of ozone."
    },
    %{
      key: "cracked_chassis_plating",
      name: "Cracked Chassis Plating",
      scavenge_text: "A drone's shell, dented and split, dragged out of a storm drain."
    },
    %{
      key: "junked_servo_motor",
      name: "Junked Servo Motor",
      scavenge_text: "Seized up and rust-streaked, but the windings might still be good."
    },
    %{
      key: "frayed_optic_cable",
      name: "Frayed Optic Cable",
      scavenge_text: "Snipped from a dead relay line, fibers exposed and milky with age."
    },
    %{
      key: "cracked_datachip",
      name: "Cracked Datachip",
      scavenge_text: "Pulled from a dead courier's wrist unit, firmware still flickering."
    },
    %{
      key: "salvaged_fiber_spool",
      name: "Salvaged Fiber Spool",
      scavenge_text:
        "Looped fiber-optic line, scavenged from a junction box nobody's checked in years."
    },
    %{
      key: "burnt_out_relay_board",
      name: "Burnt-Out Relay Board",
      scavenge_text: "Fried by a surge, but the traces are still legible under a scope."
    },
    %{
      key: "sterile_suture_kit",
      name: "Sterile Suture Kit",
      scavenge_text: "Black-market medical stock, still sealed, expiration date scratched off."
    },
    %{
      key: "subdermal_wiring_bundle",
      name: "Subdermal Wiring Bundle",
      scavenge_text:
        "Fine-gauge wire meant for under the skin, coiled tight in a biohazard pouch."
    },
    %{
      key: "cracked_bone_plate",
      name: "Cracked Bone Plate",
      scavenge_text:
        "A salvaged augmentation plate, hairline-fractured but the alloy's still good."
    },
    %{
      key: "burner_sim_stack",
      name: "Burner SIM Stack",
      scavenge_text: "A brick of unregistered SIMs, still shrink-wrapped from a Midgrid smuggler."
    },
    %{
      key: "forged_credential_stub",
      name: "Forged Credential Stub",
      scavenge_text: "Half a fake ID, the hologram seal almost convincing."
    },
    %{
      key: "encrypted_drive_shard",
      name: "Encrypted Drive Shard",
      scavenge_text: "A shattered drive fragment; whatever's on it, someone wants it back."
    },
    %{
      key: "flux_paste_tin",
      name: "Flux Paste Tin",
      scavenge_text: "Scavenged soldering flux, half-dried but still workable."
    },
    %{
      key: "scrap_heating_coil",
      name: "Scrap Heating Coil",
      scavenge_text: "Pulled from a dead heater, still holds a charge of resistance wire."
    },
    %{
      key: "bent_pry_bar",
      name: "Bent Pry Bar",
      scavenge_text: "A tool stripped from a long-dead repair kit, edge worn smooth."
    }
  ]

  def items, do: @raws

  def fetch!(key) do
    Enum.find(@raws, &(&1.key == key)) ||
      raise "unknown raw material key: #{inspect(key)}"
  end
end
