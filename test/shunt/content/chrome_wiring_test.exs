defmodule Shunt.Content.ChromeWiringTest do
  use ExUnit.Case, async: true

  alias Shunt.Content

  test "Mira the grafter is gated in the Maintenance Tunnel behind partial power" do
    tunnel = Content.fetch!(:locations, "shunt9_maintenance_tunnel")

    entry =
      Enum.find(tunnel.npcs, fn
        %{id: "shunt9_maintenance_tunnel_grafter"} -> true
        _ -> false
      end)

    assert entry.requirements == [{:district, "shunt9", :power, :>=, :partial}]

    npc = Content.fetch!(:world_npcs, "shunt9_maintenance_tunnel_grafter")
    assert "shunt9_maintenance_tunnel_grafter_intro" in npc.story_arcs
  end

  test "the grafter intro teaches the lineman_graft schematic" do
    intro = Content.fetch!(:events, "shunt9_maintenance_tunnel_grafter_intro")
    assert {:knowledge, "schematic_lineman_graft"} in intro.on_complete
  end

  test "each salvage event is gated behind the schematic and grants its chrome raw" do
    servo = Content.fetch!(:events, "shunt9_scrap_yard_strip_servo")
    assert {:knows, "schematic_lineman_graft"} in servo.requirements
    assert {:inventory, "salvaged_servo", 1} in servo.on_complete
    assert servo.repeatable

    sheath = Content.fetch!(:events, "shunt9_burned_platform_strip_sheath")
    assert {:knows, "schematic_lineman_graft"} in sheath.requirements
    assert {:inventory, "nerve_sheath", 1} in sheath.on_complete
    assert sheath.repeatable
  end

  test "chrome raws live in their own isolated category, never in the scavenge :raws pool" do
    for key <- ["salvaged_servo", "nerve_sheath"] do
      assert {:ok, raw} = Content.fetch(:chrome_raws, key)
      assert raw.source != nil
      refute Enum.any?(Content.all(:raws), &(&1.id == key))
    end
  end

  test "the lineman_graft fabricates only from salvage-recovered chrome raws (not Street Alchemy)" do
    def = Content.fetch!(:implants, "lineman_graft")
    assert def.fabrication.schematic == "schematic_lineman_graft"
    assert Map.keys(def.fabrication.inputs) |> Enum.sort() == ["nerve_sheath", "salvaged_servo"]
    # Every input is a chrome_raw (salvage-only), so nothing routes through Street Alchemy forage.
    assert Enum.all?(Map.keys(def.fabrication.inputs), fn key ->
             match?({:ok, _}, Content.fetch(:chrome_raws, key))
           end)

    assert def.chrome_load > 0
  end

  test "an installed lineman_graft opens an additive live-bus repair path that blocks no one" do
    generator = Content.fetch!(:repairables, "shunt9_power_relay_generator")
    solutions = generator.solutions

    graft = Enum.find(solutions, &(&1.id == "live_bus_graft"))
    assert graft.requirements == [{:has_implant, "lineman_graft"}]
    assert graft.result_state == "repaired"

    # The base solutions remain reachable without any chrome — the power arc never depends on it.
    base = Enum.filter(solutions, &(&1.id in ["improvised", "standard", "military"]))
    assert length(base) == 3
    assert Enum.all?(base, fn s -> Enum.all?(s.requirements, &(elem(&1, 0) != :has_implant)) end)
  end

  test "the Chrome Load foreshadowing beat is gated on carrying chrome" do
    event = Content.fetch!(:events, "shunt9_player_squat_chrome_settling")
    assert [{:chrome_load_at_least, n}] = event.requirements
    assert n > 0
    refute event.repeatable
  end
end
