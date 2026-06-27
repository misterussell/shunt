defmodule Shunt.GhostworkTest do
  use ExUnit.Case, async: true

  alias Shunt.Ghostwork
  alias Shunt.Ghostwork.Encounter
  alias Shunt.Ghostwork.IceNode
  alias Shunt.Players.Player

  defp ice_node(overrides \\ %{}) do
    base = %IceNode{
      id: "relay",
      name: "Abandoned Relay",
      family: "ice_maintenance",
      location_id: "shunt9_maintenance_tunnel",
      cool_threshold: 60,
      layers: [
        %{
          id: "l1",
          name: "Handshake",
          progress_required: 10,
          trace_multiplier: 1.0,
          weakness: :spoof,
          reward: [{:inventory, "maintenance_log", 1}]
        },
        %{
          id: "l2",
          name: "Archive",
          progress_required: 10,
          trace_multiplier: 2.0,
          weakness: nil,
          reward: [{:knowledge, "maintenance_log_decoded"}]
        }
      ]
    }

    struct(base, overrides)
  end

  defp node_state(%Player{} = player, fields) do
    %{player | ghostwork_state: %{"nodes" => %{"relay" => fields}}}
  end

  describe "begin_encounter/2" do
    test "a fresh node starts at layer 0 with zeroed meters and no effects" do
      assert {:ok, enc, []} = Ghostwork.begin_encounter(%Player{}, ice_node())
      assert %Encounter{layer_index: 0, progress: 0, trace: 0, status: :active} = enc
      assert enc.node == ice_node()
    end

    test "snapshots the family mastery count" do
      player = %Player{ghostwork_state: %{"mastery" => %{"ice_maintenance" => 3}}}

      assert {:ok, %Encounter{mastery: 3}, []} = Ghostwork.begin_encounter(player, ice_node())
    end

    test "treats absent mastery as 0" do
      assert {:ok, %Encounter{mastery: 0}, []} = Ghostwork.begin_encounter(%Player{}, ice_node())
    end

    test "resumes from banked_layer + 1" do
      player = node_state(%Player{}, %{"banked_layer" => 0, "hardened" => false})

      assert {:ok, %Encounter{layer_index: 1}, []} = Ghostwork.begin_encounter(player, ice_node())
    end

    test "errors when the last layer is already banked" do
      player = node_state(%Player{}, %{"banked_layer" => 1, "hardened" => false})

      assert {:error, :already_cracked} = Ghostwork.begin_encounter(player, ice_node())
    end

    test "blocks a hardened node while heat is at/above the cool threshold" do
      player =
        %Player{heat: 60}
        |> node_state(%{"banked_layer" => -1, "hardened" => true})

      assert {:error, :hardened} = Ghostwork.begin_encounter(player, ice_node())
    end

    test "clears a hardened node once heat is below the cool threshold" do
      player =
        %Player{heat: 59}
        |> node_state(%{"banked_layer" => -1, "hardened" => true})

      assert {:ok, %Encounter{status: :active}, effects} =
               Ghostwork.begin_encounter(player, ice_node())

      assert {:ghostwork_node, "relay", :clear_hardened} in effects
    end
  end

  describe "act/3 with :probe" do
    test "continues on the same layer, adding exact progress and jittered trace" do
      enc = %Encounter{node: ice_node(), layer_index: 0, mastery: 1}

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :active
      assert enc2.layer_index == 0
      assert enc2.progress == 3
      assert enc2.trace in 2..6
      assert effects == []
    end

    test "probe trace stays within its jitter band over many rolls" do
      enc = %Encounter{node: ice_node(), layer_index: 0, mastery: 1}

      traces =
        for _ <- 1..200 do
          {:ok, e, _} = Ghostwork.act(enc, %Player{}, :probe)
          e.trace
        end

      assert Enum.all?(traces, &(&1 in 2..6))
    end

    test "a deeper layer's trace_multiplier raises the trace band" do
      enc = %Encounter{node: ice_node(), layer_index: 1, mastery: 1}

      traces =
        for _ <- 1..200 do
          {:ok, e, _} = Ghostwork.act(enc, %Player{}, :probe)
          e.trace
        end

      assert Enum.all?(traces, &(&1 in 4..12))
      assert Enum.any?(traces, &(&1 > 6))
    end

    test "cracking a non-final layer banks its reward and advances" do
      enc = %Encounter{node: ice_node(), layer_index: 0, mastery: 1, progress: 8, trace: 5}

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :active
      assert enc2.layer_index == 1
      assert enc2.progress == 0
      assert enc2.trace in 7..11
      assert {:inventory, "maintenance_log", 1} in effects
      assert {:ghostwork_mastery, "ice_maintenance", 1} in effects
      assert {:ghostwork_node, "relay", {:bank_layer, 0}} in effects
    end

    test "cracking the final layer marks the node fully cracked" do
      enc = %Encounter{node: ice_node(), layer_index: 1, mastery: 1, progress: 8, trace: 5}

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :cracked
      assert {:knowledge, "maintenance_log_decoded"} in effects
      assert {:ghostwork_mastery, "ice_maintenance", 1} in effects
      assert {:ghostwork_node, "relay", {:bank_layer, 1}} in effects
    end

    test "busting hardens the node and emits scaled heat, capping trace at 100" do
      enc = %Encounter{node: ice_node(), layer_index: 0, mastery: 1, progress: 5, trace: 98}

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :busted
      assert enc2.trace == 100
      assert {:heat, 12} in effects
      assert {:ghostwork_node, "relay", :harden} in effects
    end

    test "bust scales heat by layer depth" do
      enc = %Encounter{node: ice_node(), layer_index: 1, mastery: 1, progress: 5, trace: 98}

      {:ok, _enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert {:heat, 16} in effects
    end

    test "a bust takes priority over a same-action crack" do
      enc = %Encounter{node: ice_node(), layer_index: 0, mastery: 1, progress: 8, trace: 98}

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :busted
      refute {:ghostwork_node, "relay", {:bank_layer, 0}} in effects
    end
  end

  describe "act/3 with {:program, id}" do
    setup do
      prog = %{
        id: "test_spoof_prog",
        name: "Mimic Daemon",
        action: :spoof,
        progress: 4,
        trace: 3,
        on_weakness: %{progress: 8, trace: 1},
        text: "x"
      }

      :ets.insert(:programs, {prog.id, prog})
      on_exit(fn -> :ets.delete(:programs, prog.id) end)
      %{player: %Player{inventory: %{prog.id => 1}}}
    end

    test "uses the on_weakness profile against a matching layer weakness", %{player: player} do
      enc = %Encounter{node: ice_node(), layer_index: 0, mastery: 1}

      {:ok, enc2, _} = Ghostwork.act(enc, player, {:program, "test_spoof_prog"})

      assert enc2.progress == 8
    end

    test "uses the base profile against a non-weak layer", %{player: player} do
      enc = %Encounter{node: ice_node(), layer_index: 1, mastery: 1}

      {:ok, enc2, _} = Ghostwork.act(enc, player, {:program, "test_spoof_prog"})

      assert enc2.progress == 4
    end

    test "errors when the player does not own the program" do
      enc = %Encounter{node: ice_node(), layer_index: 0, mastery: 1}

      assert {:error, :program_not_owned} =
               Ghostwork.act(enc, %Player{inventory: %{}}, {:program, "test_spoof_prog"})
    end
  end

  describe "retreat/1" do
    test "ends the encounter as :retreated with no effects" do
      {:ok, enc, _} = Ghostwork.begin_encounter(%Player{}, ice_node())

      assert {:ok, %Encounter{status: :retreated}, []} = Ghostwork.retreat(enc)
    end
  end

  describe "fog-of-war helpers" do
    test "numbers are hidden at mastery 0 and known from mastery 1" do
      refute Ghostwork.numbers_known?(%Encounter{node: ice_node(), layer_index: 0, mastery: 0})
      assert Ghostwork.numbers_known?(%Encounter{node: ice_node(), layer_index: 0, mastery: 1})
    end

    test "weakness is hidden below mastery 3 and known from mastery 3" do
      refute Ghostwork.weakness_known?(%Encounter{node: ice_node(), layer_index: 0, mastery: 2})
      assert Ghostwork.weakness_known?(%Encounter{node: ice_node(), layer_index: 0, mastery: 3})
    end
  end

  defp lattice_location(lattice), do: %{id: "loc", lattice: lattice}

  defp lead(overrides) do
    Map.merge(
      %{
        id: "relay_signal",
        requirements: [],
        text: "relay text",
        on_intercept: [{:knowledge, "relay_found"}]
      },
      Map.new(overrides)
    )
  end

  describe "scan/2" do
    test "errors when the location carries no lattice" do
      assert {:error, :no_lattice} = Ghostwork.scan(%Player{}, %{id: "loc"})
    end

    test "surfaces an eligible lead with its on_intercept and heat" do
      location = lattice_location(%{leads: [lead([])], filler: []})

      {:ok, effects, meta} = Ghostwork.scan(%Player{}, location)

      assert {:knowledge, "relay_found"} in effects
      assert {:heat, 4} in effects
      assert meta == %{kind: :lead, signal_id: "relay_signal", text: "relay text"}
    end

    test "picks the first eligible lead in order" do
      location =
        lattice_location(%{
          leads: [
            lead(id: "first", on_intercept: [{:knowledge, "first_key"}]),
            lead(id: "second", on_intercept: [{:knowledge, "second_key"}])
          ],
          filler: []
        })

      {:ok, _effects, meta} = Ghostwork.scan(%Player{}, location)

      assert meta.signal_id == "first"
    end

    test "skips a lead whose granted knowledge the player already holds (swept)" do
      location =
        lattice_location(%{
          leads: [lead([])],
          filler: [%{weight: 1, text: "filler", on_intercept: [{:scrip, 3}]}]
        })

      {:ok, effects, meta} = Ghostwork.scan(%Player{knowledge: ["relay_found"]}, location)

      assert meta.kind == :filler
      assert {:scrip, 3} in effects
    end

    test "skips a lead whose requirements are unmet" do
      location =
        lattice_location(%{
          leads: [lead(requirements: [{:knows, "gate"}])],
          filler: [%{weight: 1, text: "filler", on_intercept: [{:scrip, 3}]}]
        })

      {:ok, _effects, meta} = Ghostwork.scan(%Player{}, location)

      assert meta.kind == :filler
    end

    test "falls back to weighted-random filler when no lead is available" do
      location =
        lattice_location(%{
          leads: [],
          filler: [
            %{weight: 3, text: "common", on_intercept: [{:scrip, 3}]},
            %{weight: 1, text: "rare", on_intercept: [{:knowledge, "rumor"}]}
          ]
        })

      texts =
        for _ <- 1..400 do
          {:ok, _effects, meta} = Ghostwork.scan(%Player{}, location)
          meta.text
        end

      assert "common" in texts
      assert "rare" in texts
      assert Enum.all?(texts, &(&1 in ["common", "rare"]))
    end

    test "always applies scan heat even on filler" do
      location =
        lattice_location(%{
          leads: [],
          filler: [%{weight: 1, text: "filler", on_intercept: [{:scrip, 3}]}]
        })

      {:ok, effects, _meta} = Ghostwork.scan(%Player{}, location)

      assert {:heat, 4} in effects
    end

    test "returns an empty scan (heat only) when no lead and no filler are available" do
      location = lattice_location(%{leads: [], filler: []})

      {:ok, effects, meta} = Ghostwork.scan(%Player{}, location)

      assert effects == [{:heat, 4}]
      assert meta == %{kind: :empty, text: nil}
    end

    test "treats missing :leads/:filler keys as empty" do
      {:ok, effects, meta} = Ghostwork.scan(%Player{}, lattice_location(%{}))

      assert effects == [{:heat, 4}]
      assert meta.kind == :empty
    end
  end
end
