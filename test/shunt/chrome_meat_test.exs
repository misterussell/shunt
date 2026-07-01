defmodule Shunt.ChromeMeatTest do
  use ExUnit.Case, async: true

  alias Shunt.ChromeMeat
  alias Shunt.Implants
  alias Shunt.Players.Player

  # A player who can fabricate the lineman_graft: chrome tier 1 (owns the scalpel), knows the
  # schematic, and holds the fabrication inputs.
  defp ready_to_fabricate(def) do
    inputs = Map.new(def.fabrication.inputs, fn {k, qty} -> {k, qty} end)
    inventory = Map.put(inputs, "patchwork_scalpel", 1)
    %Player{inventory: inventory, knowledge: [def.fabrication.schematic]}
  end

  describe "clamp/1" do
    test "leaves an in-range value unchanged" do
      assert ChromeMeat.clamp(47) == 47
    end

    test "floors at 0" do
      assert ChromeMeat.clamp(-5) == 0
    end

    test "caps at 100" do
      assert ChromeMeat.clamp(140) == 100
    end
  end

  describe "band_for/1" do
    test "maps load values to bands by threshold" do
      assert ChromeMeat.band_for(0) == :none
      assert ChromeMeat.band_for(29) == :none
      assert ChromeMeat.band_for(30) == :low
      assert ChromeMeat.band_for(60) == :medium
      assert ChromeMeat.band_for(85) == :high
    end
  end

  describe "catalog/1" do
    test "marks an implant :fabricable when the player can build it" do
      def = Implants.fetch!("lineman_graft")
      player = ready_to_fabricate(def)

      entry = Enum.find(ChromeMeat.catalog(player), &(&1.def.id == "lineman_graft"))
      assert entry.state == :fabricable
    end

    test "marks an implant :locked when the player lacks the tool or schematic" do
      entry = Enum.find(ChromeMeat.catalog(%Player{}), &(&1.def.id == "lineman_graft"))
      assert entry.state == :locked
    end

    test "marks :needs_materials when the schematic and tool are held but inputs are missing" do
      def = Implants.fetch!("lineman_graft")
      # tool + schematic, but no fabrication inputs.
      player = %Player{
        inventory: %{"patchwork_scalpel" => 1},
        knowledge: [def.fabrication.schematic]
      }

      entry = Enum.find(ChromeMeat.catalog(player), &(&1.def.id == "lineman_graft"))
      assert entry.state == :needs_materials
    end

    test "marks an owned but uninstalled implant :owned" do
      player = %Player{inventory: %{"lineman_graft" => 1}}

      entry = Enum.find(ChromeMeat.catalog(player), &(&1.def.id == "lineman_graft"))
      assert entry.state == :owned
    end

    test "marks an installed implant :installed" do
      player = %Player{implants: %{"lineman_graft" => %{}}}

      entry = Enum.find(ChromeMeat.catalog(player), &(&1.def.id == "lineman_graft"))
      assert entry.state == :installed
    end
  end

  describe "fabricate/2" do
    test "consumes the inputs and grants the uninstalled implant item" do
      def = Implants.fetch!("lineman_graft")
      player = ready_to_fabricate(def)

      {:ok, effects} = ChromeMeat.fabricate(player, "lineman_graft")

      for {input_key, qty} <- def.fabrication.inputs do
        assert {:inventory, input_key, -qty} in effects
      end

      assert {:inventory, "lineman_graft", 1} in effects
      assert length(effects) == map_size(def.fabrication.inputs) + 1
    end

    test "errors with :insufficient_tier without the chrome tool" do
      def = Implants.fetch!("lineman_graft")

      player = %{
        ready_to_fabricate(def)
        | inventory: Map.delete(ready_to_fabricate(def).inventory, "patchwork_scalpel")
      }

      assert ChromeMeat.fabricate(player, "lineman_graft") == {:error, :insufficient_tier}
    end

    test "errors with :unknown_schematic when the schematic is not learned" do
      def = Implants.fetch!("lineman_graft")
      player = %{ready_to_fabricate(def) | knowledge: []}

      assert ChromeMeat.fabricate(player, "lineman_graft") == {:error, :unknown_schematic}
    end

    test "errors with :insufficient_materials when an input is missing" do
      def = Implants.fetch!("lineman_graft")
      [input_key | _] = Map.keys(def.fabrication.inputs)

      player = %{
        ready_to_fabricate(def)
        | inventory: Map.delete(ready_to_fabricate(def).inventory, input_key)
      }

      assert ChromeMeat.fabricate(player, "lineman_graft") == {:error, :insufficient_materials}
    end
  end

  describe "install/2" do
    test "consumes the owned implant item and applies install effects deterministically" do
      def = Implants.fetch!("lineman_graft")
      player = %Player{inventory: %{"lineman_graft" => 1}, implants: %{}}

      {:ok, effects} = ChromeMeat.install(player, "lineman_graft")

      assert effects == [
               {:inventory, "lineman_graft", -1},
               {:install_implant, "lineman_graft"},
               {:chrome_load, def.chrome_load},
               {:heat, def.heat_on_install}
             ]
    end

    test "errors with :not_owned when the implant item is not held" do
      player = %Player{inventory: %{}, implants: %{}}

      assert ChromeMeat.install(player, "lineman_graft") == {:error, :not_owned}
    end

    test "errors with :already_installed when it is already installed" do
      player = %Player{inventory: %{"lineman_graft" => 1}, implants: %{"lineman_graft" => %{}}}

      assert ChromeMeat.install(player, "lineman_graft") == {:error, :already_installed}
    end
  end
end
