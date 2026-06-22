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
    }
  ]

  def items, do: @raws

  def fetch!(key) do
    Enum.find(@raws, &(&1.key == key)) ||
      raise "unknown raw material key: #{inspect(key)}"
  end
end
