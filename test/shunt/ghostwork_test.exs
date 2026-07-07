defmodule Shunt.GhostworkTest do
  # async: false — inserts/deletes in the global :programs ETS table; must not run concurrently
  # with tests that read it (e.g. programs_content_test), or reads race with the temp rows.
  use ExUnit.Case, async: false

  alias Shunt.Ghostwork
  alias Shunt.Ghostwork.Encounter
  alias Shunt.Ghostwork.IceNode
  alias Shunt.Players.Player

  # A single-subroutine node (the mechanically-migrated shape): each layer is one
  # :barrier subroutine, mirroring the old single-bar nodes.
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
          trace_multiplier: 1.0,
          reward: [{:inventory, "maintenance_log", 1}],
          subroutines: [
            %{id: "l1_core", key: :spoof, threat: :barrier, progress_required: 10}
          ]
        },
        %{
          id: "l2",
          name: "Archive",
          trace_multiplier: 2.0,
          reward: [{:knowledge, "maintenance_log_decoded"}],
          subroutines: [
            %{id: "l2_core", key: nil, threat: :barrier, progress_required: 10}
          ]
        }
      ]
    }

    struct(base, overrides)
  end

  # A layer whose subroutines mix threats/keys, for the open-board behaviours.
  defp board_node(subroutines) do
    %IceNode{
      id: "board",
      name: "Board",
      family: "ice_corp",
      location_id: "loc",
      cool_threshold: 60,
      layers: [
        %{
          id: "b1",
          name: "B1",
          trace_multiplier: 1.0,
          reward: [{:scrip, 5}],
          subroutines: subroutines
        }
      ]
    }
  end

  defp node_state(%Player{} = player, fields) do
    %{player | ghostwork_state: %{"nodes" => %{"relay" => fields}}}
  end

  describe "begin_encounter/2" do
    test "a fresh node starts at layer 0 with a zeroed subroutine board and no effects" do
      assert {:ok, enc, []} = Ghostwork.begin_encounter(%Player{}, ice_node())
      assert %Encounter{layer_index: 0, trace: 0, status: :active} = enc
      assert enc.subroutine_progress == %{"l1_core" => 0}
      assert enc.node == ice_node()
    end

    test "snapshots the family mastery count" do
      player = %Player{ghostwork_state: %{"mastery" => %{"ice_maintenance" => 3}}}

      assert {:ok, %Encounter{mastery: 3}, []} = Ghostwork.begin_encounter(player, ice_node())
    end

    test "treats absent mastery as 0" do
      assert {:ok, %Encounter{mastery: 0}, []} = Ghostwork.begin_encounter(%Player{}, ice_node())
    end

    test "resumes from banked_layer + 1 with that layer's board zeroed" do
      player = node_state(%Player{}, %{"banked_layer" => 0, "hardened" => false})

      assert {:ok, %Encounter{layer_index: 1} = enc, []} =
               Ghostwork.begin_encounter(player, ice_node())

      assert enc.subroutine_progress == %{"l2_core" => 0}
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

  defp on_board(node, overrides \\ %{}) do
    layer = Enum.at(node.layers, Map.get(overrides, :layer_index, 0))
    zeroed = Map.new(layer.subroutines, &{&1.id, 0})

    struct(
      %Encounter{node: node, layer_index: 0, mastery: 1, subroutine_progress: zeroed},
      overrides
    )
  end

  describe "act/4 with :probe (single-subroutine layer)" do
    test "auto-targets the sole subroutine, adding exact progress and jittered trace" do
      enc = on_board(ice_node())

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :active
      assert enc2.layer_index == 0
      assert enc2.subroutine_progress == %{"l1_core" => 3}
      assert enc2.trace in 2..6
      assert effects == []
    end

    test "a deeper layer's trace_multiplier raises the trace band" do
      enc = on_board(ice_node(), %{layer_index: 1})

      traces =
        for _ <- 1..200 do
          {:ok, e, _} = Ghostwork.act(enc, %Player{}, :probe)
          e.trace
        end

      assert Enum.all?(traces, &(&1 in 4..12))
      assert Enum.any?(traces, &(&1 > 6))
    end

    test "downing every subroutine banks the layer reward and advances, re-zeroing the board" do
      enc = on_board(ice_node(), %{subroutine_progress: %{"l1_core" => 8}, trace: 5})

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :active
      assert enc2.layer_index == 1
      assert enc2.subroutine_progress == %{"l2_core" => 0}
      assert enc2.trace in 7..11
      assert {:inventory, "maintenance_log", 1} in effects
      assert {:ghostwork_mastery, "ice_maintenance", 1} in effects
      assert {:ghostwork_node, "relay", {:bank_layer, 0}} in effects
    end

    test "downing the final layer marks the node fully cracked" do
      enc =
        on_board(ice_node(), %{layer_index: 1, subroutine_progress: %{"l2_core" => 8}, trace: 5})

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :cracked
      assert {:knowledge, "maintenance_log_decoded"} in effects
      assert {:ghostwork_mastery, "ice_maintenance", 1} in effects
      assert {:ghostwork_node, "relay", {:bank_layer, 1}} in effects
    end

    test "busting hardens the node and emits scaled heat, capping trace at 100" do
      enc = on_board(ice_node(), %{subroutine_progress: %{"l1_core" => 5}, trace: 98})

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :busted
      assert enc2.trace == 100
      assert {:heat, 8} in effects
      assert {:ghostwork_node, "relay", :harden} in effects
    end

    test "bust scales heat by layer depth" do
      enc =
        on_board(ice_node(), %{layer_index: 1, subroutine_progress: %{"l2_core" => 5}, trace: 98})

      {:ok, _enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert {:heat, 11} in effects
    end

    test "a bust takes priority over a layer crack" do
      enc = on_board(ice_node(), %{subroutine_progress: %{"l1_core" => 8}, trace: 98})

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.status == :busted
      refute {:ghostwork_node, "relay", {:bank_layer, 0}} in effects
    end
  end

  describe "act/4 open board" do
    defp barrier(id, key, req \\ 10),
      do: %{id: id, key: key, threat: :barrier, progress_required: req}

    test "hits the explicitly targeted subroutine, not the first one" do
      node = board_node([barrier("a", :spoof), barrier("b", :decrypt)])
      enc = on_board(node)

      {:ok, enc2, _} = Ghostwork.act(enc, %Player{}, :probe, "b")

      assert enc2.subroutine_progress == %{"a" => 0, "b" => 3}
    end

    test "a layer is not cleared until every subroutine is down" do
      node = board_node([barrier("a", :spoof, 3), barrier("b", :decrypt, 3)])
      enc = on_board(node)

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe, "a")
      assert enc2.status == :active
      assert enc2.layer_index == 0
      assert effects == []

      {:ok, enc3, effects2} = Ghostwork.act(enc2, %Player{}, :probe, "b")
      assert enc3.status == :cracked
      assert {:scrip, 5} in effects2
    end

    test "auto-target skips an already-downed subroutine" do
      node = board_node([barrier("a", :spoof, 3), barrier("b", :decrypt)])
      enc = on_board(node, %{subroutine_progress: %{"a" => 3, "b" => 0}})

      {:ok, enc2, _} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.subroutine_progress == %{"a" => 3, "b" => 3}
    end

    test "errors on a target that is not on the layer" do
      enc = on_board(board_node([barrier("a", :spoof)]))

      assert {:error, :invalid_target} = Ghostwork.act(enc, %Player{}, :probe, "ghost")
    end

    test "errors on a target that is already down" do
      node = board_node([barrier("a", :spoof, 3), barrier("b", :decrypt)])
      enc = on_board(node, %{subroutine_progress: %{"a" => 3, "b" => 0}})

      assert {:error, :invalid_target} = Ghostwork.act(enc, %Player{}, :probe, "a")
    end

    test "a still-alive sentry bleeds extra trace each turn beyond the action's own trace" do
      sentry = %{id: "s", key: :decrypt, threat: :sentry, progress_required: 99}
      node = board_node([barrier("a", :spoof, 99), sentry])
      enc = on_board(node, %{mastery: 5})

      # Probe the barrier; the sentry stays alive and bleeds @sentry_bleed (4) on top of
      # probe's own jittered 2..6.
      traces =
        for _ <- 1..200 do
          {:ok, e, _} = Ghostwork.act(enc, %Player{}, :probe, "a")
          e.trace
        end

      assert Enum.all?(traces, &(&1 in 6..10))
    end

    test "a sentry downed this turn stops bleeding (no extra trace once dead)" do
      sentry = %{id: "s", key: :decrypt, threat: :sentry, progress_required: 3}
      node = board_node([barrier("a", :spoof, 99), sentry])
      enc = on_board(node, %{mastery: 5})

      traces =
        for _ <- 1..200 do
          {:ok, e, _} = Ghostwork.act(enc, %Player{}, :probe, "s")
          e.trace
        end

      # Probe (+3) downs the 3-req sentry the same turn, so only probe's own 2..6 lands.
      assert Enum.all?(traces, &(&1 in 2..6))
    end
  end

  describe "loadout/1, equip/2, unequip/2" do
    defp owner(loadout, owned \\ ["maskchip", "shard_reader", "ghostkey", "signal_knife"]) do
      %Player{
        inventory: Map.new(owned, &{&1, 1}),
        ghostwork_state: %{"loadout" => loadout}
      }
    end

    test "loadout/1 reads the equipped ids, defaulting to empty" do
      assert Ghostwork.loadout(%Player{}) == []
      assert Ghostwork.loadout(owner(["maskchip"])) == ["maskchip"]
    end

    test "equip/2 appends an owned program" do
      assert Ghostwork.equip(owner([]), "maskchip") == ["maskchip"]
    end

    test "equip/2 is a no-op for a program the player does not own" do
      assert Ghostwork.equip(owner([], ["maskchip"]), "ghostkey") == []
    end

    test "equip/2 dedupes an already-equipped program" do
      assert Ghostwork.equip(owner(["maskchip"]), "maskchip") == ["maskchip"]
    end

    test "equip/2 is a no-op once all three slots are full" do
      full = ["maskchip", "shard_reader", "ghostkey"]
      assert Ghostwork.equip(owner(full), "signal_knife") == full
    end

    test "unequip/2 removes an equipped program and leaves others" do
      assert Ghostwork.unequip(owner(["maskchip", "ghostkey"]), "maskchip") == ["ghostkey"]
    end

    test "unequip/2 is a no-op for a program that is not equipped" do
      assert Ghostwork.unequip(owner(["maskchip"]), "ghostkey") == ["maskchip"]
    end
  end

  describe "active_deck/1, deck_slots/1 (deck as gear)" do
    setup do
      small = %{id: "test_small_deck", name: "Small Deck", slots: 3, text: "."}
      big = %{id: "test_big_deck", name: "Big Deck", slots: 5, text: "."}
      :ets.insert(:decks, {small.id, small})
      :ets.insert(:decks, {big.id, big})

      on_exit(fn ->
        :ets.delete(:decks, small.id)
        :ets.delete(:decks, big.id)
      end)

      %{small: small, big: big}
    end

    test "active_deck/1 returns nil when the player owns no deck" do
      assert Ghostwork.active_deck(%Player{}) == nil
    end

    test "active_deck/1 returns the owned deck", %{small: small} do
      player = %Player{inventory: %{"test_small_deck" => 1}}
      assert Ghostwork.active_deck(player) == small
    end

    test "active_deck/1 picks the highest-slots deck when several are owned", %{big: big} do
      player = %Player{inventory: %{"test_small_deck" => 1, "test_big_deck" => 1}}
      assert Ghostwork.active_deck(player) == big
    end

    test "deck_slots/1 falls back to 3 when the player owns no deck" do
      assert Ghostwork.deck_slots(%Player{}) == 3
    end

    test "deck_slots/1 reads the active deck's slots", %{big: _big} do
      player = %Player{inventory: %{"test_big_deck" => 1}}
      assert Ghostwork.deck_slots(player) == 5
    end

    test "equip/2 fills up to the active deck's slot count, not a hardcoded 3", %{big: _big} do
      player = %Player{
        inventory: %{
          "test_big_deck" => 1,
          "maskchip" => 1,
          "shard_reader" => 1,
          "ghostkey" => 1,
          "signal_knife" => 1
        },
        ghostwork_state: %{"loadout" => ["maskchip", "shard_reader", "ghostkey"]}
      }

      # A 5-slot deck must accept a 4th program where the old constant-3 cap refused it.
      assert Ghostwork.equip(player, "signal_knife") ==
               ["maskchip", "shard_reader", "ghostkey", "signal_knife"]
    end
  end

  describe "resolve_target/2" do
    test "keeps the preferred subroutine while it is still alive" do
      node = board_node([barrier("a", :spoof, 10), barrier("b", :decrypt, 10)])

      assert Ghostwork.resolve_target(on_board(node), "b") == "b"
    end

    test "falls back to the first alive subroutine when the preferred is down" do
      node = board_node([barrier("a", :spoof, 10), barrier("b", :decrypt, 3)])
      enc = on_board(node, %{subroutine_progress: %{"a" => 0, "b" => 3}})

      assert Ghostwork.resolve_target(enc, "b") == "a"
    end

    test "defaults to the first alive subroutine when no preference is given" do
      node = board_node([barrier("a", :spoof, 10), barrier("b", :decrypt, 10)])

      assert Ghostwork.resolve_target(on_board(node), nil) == "a"
    end

    test "is nil once the encounter has ended" do
      enc = %Encounter{
        node: ice_node(),
        layer_index: 0,
        mastery: 1,
        status: :cracked,
        subroutine_progress: %{}
      }

      assert Ghostwork.resolve_target(enc, "l1_core") == nil
    end
  end

  describe "program_target/2" do
    test "keeps the preferred subroutine while it is an alive non-vault" do
      node = board_node([barrier("a", :spoof), barrier("b", :decrypt)])

      assert Ghostwork.program_target(on_board(node), "b") == "b"
    end

    test "never targets a vault: a highlighted vault falls back to the first breakable" do
      node = board_node([barrier("a", :spoof), vault("v", :decrypt, 10, [])])

      assert Ghostwork.program_target(on_board(node), "v") == "a"
    end

    test "defaults to the first alive non-vault when no preference is given" do
      node = board_node([barrier("a", :spoof), barrier("b", :decrypt)])

      assert Ghostwork.program_target(on_board(node), nil) == "a"
    end

    test "is nil when only a vault is alive (nothing breakable to hit)" do
      node = board_node([barrier("a", :spoof, 3), vault("v", :decrypt, 10, [])])
      enc = on_board(node, %{subroutine_progress: %{"a" => 3, "v" => 0}})

      assert Ghostwork.program_target(enc, "v") == nil
    end

    test "is nil once the encounter has ended" do
      node = board_node([barrier("a", :spoof)])
      enc = on_board(node, %{status: :locked_out})

      assert Ghostwork.program_target(enc, "a") == nil
    end
  end

  describe "drill_target/2" do
    test "returns the highlighted vault id when it is an alive vault" do
      node = board_node([barrier("a", :spoof), vault("v", :decrypt, 10, [])])

      assert Ghostwork.drill_target(on_board(node), "v") == "v"
    end

    test "is nil when the highlighted subroutine is a non-vault" do
      node = board_node([barrier("a", :spoof), vault("v", :decrypt, 10, [])])

      assert Ghostwork.drill_target(on_board(node), "a") == nil
    end

    test "is nil when nothing is highlighted" do
      node = board_node([vault("v", :decrypt, 10, [])])

      assert Ghostwork.drill_target(on_board(node), nil) == nil
    end

    test "is nil once the vault is already down" do
      node = board_node([vault("v", :decrypt, 6, [])])
      enc = on_board(node, %{subroutine_progress: %{"v" => 6}})

      assert Ghostwork.drill_target(enc, "v") == nil
    end

    test "is nil once the encounter has ended" do
      node = board_node([vault("v", :decrypt, 10, [])])
      enc = on_board(node, %{status: :locked_out})

      assert Ghostwork.drill_target(enc, "v") == nil
    end
  end

  describe "act/4 with {:program, id}" do
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

    test "uses the on_weakness profile when its action matches the target's key", %{
      player: player
    } do
      enc = on_board(ice_node())

      {:ok, enc2, _} = Ghostwork.act(enc, player, {:program, "test_spoof_prog"})

      assert enc2.subroutine_progress == %{"l1_core" => 8}
    end

    test "uses the base profile against a mismatched target", %{player: player} do
      enc = on_board(ice_node(), %{layer_index: 1})

      {:ok, enc2, _} = Ghostwork.act(enc, player, {:program, "test_spoof_prog"})

      assert enc2.subroutine_progress == %{"l2_core" => 4}
    end

    test "a mismatched non-probe hit on a :trap amplifies trace; a match does not", %{
      player: player
    } do
      trap = %{id: "t", key: :decrypt, threat: :trap, progress_required: 99}
      node = board_node([trap])
      enc = on_board(node, %{mastery: 5})

      mismatched =
        for _ <- 1..200 do
          {:ok, e, _} = Ghostwork.act(enc, player, {:program, "test_spoof_prog"}, "t")
          e.trace
        end

      # base trace 3, doubled by the trap -> 6, jittered (spread 3) -> band 3..9.
      # Un-amplified that base would jitter to 2..4, so exceeding 4 proves the penalty.
      assert Enum.all?(mismatched, &(&1 in 3..9))
      assert Enum.any?(mismatched, &(&1 > 4))
    end

    test "probe is exempt from the trap penalty" do
      trap = %{id: "t", key: :decrypt, threat: :trap, progress_required: 99}
      enc = on_board(board_node([trap]), %{mastery: 5})

      traces =
        for _ <- 1..200 do
          {:ok, e, _} = Ghostwork.act(enc, %Player{}, :probe, "t")
          e.trace
        end

      assert Enum.all?(traces, &(&1 in 2..6))
    end

    test "errors when the player does not own the program" do
      enc = on_board(ice_node())

      assert {:error, :program_not_owned} =
               Ghostwork.act(enc, %Player{inventory: %{}}, {:program, "test_spoof_prog"})
    end

    test "errors without crashing when the program id does not exist in the catalog" do
      enc = on_board(ice_node())

      assert {:error, :program_not_owned} =
               Ghostwork.act(enc, %Player{inventory: %{}}, {:program, "totally_bogus_id"})
    end
  end

  describe "act/4 with unknown action" do
    test "returns :unknown_action error for an unrecognized action atom" do
      enc = on_board(ice_node())

      assert {:error, :unknown_action} = Ghostwork.act(enc, %Player{}, :unknown)
    end
  end

  describe "retreat/1" do
    test "ends the encounter as :retreated with no effects" do
      {:ok, enc, _} = Ghostwork.begin_encounter(%Player{}, ice_node())

      assert {:ok, %Encounter{status: :retreated}, []} = Ghostwork.retreat(enc)
    end
  end

  describe "act/4 vault mechanic" do
    setup do
      # A :decrypt program, to match (or, against a :spoof vault, mismatch) a vault key.
      prog = %{
        id: "test_vault_key",
        name: "Ghostkey",
        action: :decrypt,
        progress: 5,
        trace: 2,
        on_weakness: %{progress: 6, trace: 2},
        text: "x"
      }

      :ets.insert(:programs, {prog.id, prog})
      on_exit(fn -> :ets.delete(:programs, prog.id) end)
      %{player: %Player{inventory: %{prog.id => 1}}}
    end

    defp vault(id, key, req, reward),
      do: %{id: id, key: key, threat: :vault, progress_required: req, reward: reward}

    test "a mismatched program hit on a vault trips the lockout: terminal, hardens, denies loot",
         %{player: player} do
      # program action :decrypt vs vault key :spoof -> mismatch
      node = board_node([vault("v", :spoof, 6, [{:scrip, 40}])])
      enc = on_board(node, %{mastery: 5})

      {:ok, enc2, effects} = Ghostwork.act(enc, player, {:program, "test_vault_key"}, "v")

      assert enc2.status == :locked_out
      assert enc2.subroutine_progress["v"] == 0
      assert {:ghostwork_node, "board", :harden} in effects
      assert Enum.any?(effects, &match?({:heat, _}, &1))
      refute {:scrip, 40} in effects
    end

    test "a probe on a vault trips the lockout (only the matching key is safe)" do
      node = board_node([vault("v", :decrypt, 6, [{:scrip, 40}])])
      enc = on_board(node, %{mastery: 5})

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe, "v")

      assert enc2.status == :locked_out
      assert {:ghostwork_node, "board", :harden} in effects
    end

    test "lockout heat exceeds a comparable trace-bust and scales by layer depth" do
      layer = fn id ->
        %{
          id: id,
          name: id,
          trace_multiplier: 1.0,
          reward: [],
          subroutines: [vault("v", :spoof, 6, [])]
        }
      end

      deep = %IceNode{
        id: "deep",
        name: "Deep",
        family: "ice_corp",
        location_id: "loc",
        cool_threshold: 60,
        layers: [layer.("l0"), layer.("l1")]
      }

      {:ok, e0, fx0} = Ghostwork.act(on_board(deep, %{mastery: 5}), %Player{}, :probe, "v")

      {:ok, e1, fx1} =
        Ghostwork.act(on_board(deep, %{layer_index: 1, mastery: 5}), %Player{}, :probe, "v")

      [heat0] = for {:heat, h} <- fx0, do: h
      [heat1] = for {:heat, h} <- fx1, do: h

      assert e0.status == :locked_out and e1.status == :locked_out
      # deeper than the layer-0 trace-bust heat (8), and deeper layers hurt more
      assert heat0 > 8
      assert heat1 > heat0
    end

    test "a matching-key hit advances a vault instead of tripping it", %{player: player} do
      node = board_node([vault("v", :decrypt, 12, [{:scrip, 40}])])
      enc = on_board(node, %{mastery: 5})

      {:ok, enc2, effects} = Ghostwork.act(enc, player, {:program, "test_vault_key"}, "v")

      assert enc2.status == :active
      assert enc2.subroutine_progress["v"] == 6
      refute {:scrip, 40} in effects
    end

    test "cracking a vault dispatches its reward without banking the layer", %{player: player} do
      # required barrier stays up (99 req) so the layer does not bank/advance
      node = board_node([barrier("a", :spoof, 99), vault("v", :decrypt, 6, [{:scrip, 40}])])
      enc = on_board(node, %{mastery: 5})

      {:ok, enc2, effects} = Ghostwork.act(enc, player, {:program, "test_vault_key"}, "v")

      assert enc2.status == :active
      assert enc2.subroutine_progress["v"] == 6
      assert {:scrip, 40} in effects
      refute {:scrip, 5} in effects
    end

    test "clearing the required set banks the safe reward but holds the layer open for the vault" do
      node = board_node([barrier("a", :spoof, 3), vault("v", :decrypt, 12, [{:scrip, 40}])])
      enc = on_board(node, %{mastery: 5})

      {:ok, enc2, effects} = Ghostwork.act(enc, %Player{}, :probe, "a")

      assert enc2.status == :active
      assert enc2.layer_banked == true
      assert enc2.layer_index == 0
      assert {:scrip, 5} in effects
      assert {:ghostwork_mastery, "ice_corp", 1} in effects
      assert {:ghostwork_node, "board", {:bank_layer, 0}} in effects
    end

    test "drilling the vault after the safe reward banked does not re-dispatch it", %{
      player: player
    } do
      node = board_node([barrier("a", :spoof, 3), vault("v", :decrypt, 12, [{:scrip, 40}])])

      enc =
        on_board(node, %{
          mastery: 5,
          subroutine_progress: %{"a" => 3, "v" => 0},
          layer_banked: true
        })

      {:ok, enc2, effects} = Ghostwork.act(enc, player, {:program, "test_vault_key"}, "v")

      assert enc2.subroutine_progress["v"] == 6
      refute {:scrip, 5} in effects
      refute {:ghostwork_mastery, "ice_corp", 1} in effects
    end

    test "cracking the vault on a banked-open final layer finishes the node, loot only", %{
      player: player
    } do
      node = board_node([barrier("a", :spoof, 3), vault("v", :decrypt, 6, [{:scrip, 40}])])

      enc =
        on_board(node, %{
          mastery: 5,
          subroutine_progress: %{"a" => 3, "v" => 0},
          layer_banked: true
        })

      {:ok, enc2, effects} = Ghostwork.act(enc, player, {:program, "test_vault_key"}, "v")

      assert enc2.status == :cracked
      assert {:scrip, 40} in effects
      refute {:scrip, 5} in effects
    end

    test "auto-target never picks a vault" do
      node = board_node([barrier("a", :spoof, 10), vault("v", :decrypt, 10, [])])
      enc = on_board(node, %{mastery: 5})

      {:ok, enc2, _} = Ghostwork.act(enc, %Player{}, :probe)

      assert enc2.subroutine_progress["a"] == 3
      assert enc2.subroutine_progress["v"] == 0
    end

    test "auto-target errors when only a vault remains alive" do
      node = board_node([barrier("a", :spoof, 3), vault("v", :decrypt, 10, [])])

      enc =
        on_board(node, %{
          mastery: 5,
          subroutine_progress: %{"a" => 3, "v" => 0},
          layer_banked: true
        })

      assert {:error, :invalid_target} = Ghostwork.act(enc, %Player{}, :probe)
    end
  end

  describe "descend/1" do
    test "advances to the next layer, re-zeroing the board and carrying trace, with no effects" do
      two = %IceNode{
        id: "two",
        name: "Two",
        family: "ice_corp",
        location_id: "loc",
        cool_threshold: 60,
        layers: [
          %{
            id: "l0",
            name: "L0",
            trace_multiplier: 1.0,
            reward: [{:scrip, 5}],
            subroutines: [
              barrier("a", :spoof, 3),
              vault("v", :decrypt, 10, [{:scrip, 40}])
            ]
          },
          %{
            id: "l1",
            name: "L1",
            trace_multiplier: 1.0,
            reward: [{:scrip, 9}],
            subroutines: [barrier("b", :decrypt, 5)]
          }
        ]
      }

      enc =
        on_board(two, %{
          layer_index: 0,
          mastery: 5,
          subroutine_progress: %{"a" => 3, "v" => 0},
          layer_banked: true,
          trace: 12
        })

      {:ok, enc2, effects} = Ghostwork.descend(enc)

      assert enc2.status == :active
      assert enc2.layer_index == 1
      assert enc2.subroutine_progress == %{"b" => 0}
      assert enc2.layer_banked == false
      assert enc2.trace == 12
      assert effects == []
    end

    test "on the final layer, skipping the vault finishes the node with no further effects" do
      node = board_node([barrier("a", :spoof, 3), vault("v", :decrypt, 10, [{:scrip, 40}])])

      enc =
        on_board(node, %{
          mastery: 5,
          subroutine_progress: %{"a" => 3, "v" => 0},
          layer_banked: true
        })

      {:ok, enc2, effects} = Ghostwork.descend(enc)

      assert enc2.status == :cracked
      assert effects == []
    end

    test "errors when the required set is not yet cleared (nothing banked to descend from)" do
      node = board_node([barrier("a", :spoof, 10), vault("v", :decrypt, 10, [])])
      enc = on_board(node, %{mastery: 5})

      assert {:error, :not_banked} = Ghostwork.descend(enc)
    end
  end

  describe "resolve_target/2 with vaults" do
    test "keeps an explicitly-selected alive vault highlighted" do
      node = board_node([barrier("a", :spoof, 10), vault("v", :decrypt, 10, [])])
      enc = on_board(node, %{mastery: 5})

      assert Ghostwork.resolve_target(enc, "v") == "v"
    end

    test "never falls back to a vault when the preferred target is gone" do
      node = board_node([barrier("a", :spoof, 3), vault("v", :decrypt, 10, [])])
      enc = on_board(node, %{mastery: 5, subroutine_progress: %{"a" => 3, "v" => 0}})

      assert Ghostwork.resolve_target(enc, "a") == nil
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

  describe "fog_stage/1" do
    test "maps mastery count to a fog stage" do
      assert Ghostwork.fog_stage(0) == :dark
      assert Ghostwork.fog_stage(1) == :numbers
      assert Ghostwork.fog_stage(2) == :numbers
      assert Ghostwork.fog_stage(3) == :weakness
      assert Ghostwork.fog_stage(9) == :weakness
    end
  end

  describe "nodes_at/2 read status" do
    defp relay_seeker(mastery) do
      %Player{
        knowledge: ["shunt9_abandoned_relay_found"],
        location_id: "shunt9_maintenance_tunnel",
        ghostwork_state: %{"mastery" => %{"ice_maintenance" => mastery}}
      }
    end

    test "tags each node with the fog stage of its family's mastery" do
      [entry] = Ghostwork.nodes_at(relay_seeker(1), "shunt9_maintenance_tunnel")
      assert entry.read == :numbers

      [weak] = Ghostwork.nodes_at(relay_seeker(3), "shunt9_maintenance_tunnel")
      assert weak.read == :weakness
    end

    test "an unread family reads as :dark" do
      player = %Player{
        knowledge: ["shunt9_abandoned_relay_found"],
        location_id: "shunt9_maintenance_tunnel"
      }

      [entry] = Ghostwork.nodes_at(player, "shunt9_maintenance_tunnel")
      assert entry.read == :dark
    end
  end

  describe "read_meter/1" do
    test "SEEN below the first crack" do
      assert Ghostwork.read_meter(0) == %{stage: :seen, filled: 1, label: "SEEN", to_keys: 3}
    end

    test "COSTS from the first crack, counting down to KEYS" do
      assert Ghostwork.read_meter(1) == %{stage: :costs, filled: 2, label: "COSTS", to_keys: 2}
      assert Ghostwork.read_meter(2) == %{stage: :costs, filled: 2, label: "COSTS", to_keys: 1}
    end

    test "KEYS once the weakness threshold is reached, fully read" do
      assert Ghostwork.read_meter(3) == %{stage: :keys, filled: 3, label: "KEYS", to_keys: 0}
      assert Ghostwork.read_meter(9) == %{stage: :keys, filled: 3, label: "KEYS", to_keys: 0}
    end
  end

  describe "mastery_summary/1" do
    test "summarizes each family sorted by name with its read meter" do
      player = %Player{
        ghostwork_state: %{"mastery" => %{"ice_maintenance" => 2, "ice_corp" => 4}}
      }

      assert Ghostwork.mastery_summary(player) == [
               %{family: "ice_corp", cracks: 4, read: Ghostwork.read_meter(4)},
               %{family: "ice_maintenance", cracks: 2, read: Ghostwork.read_meter(2)}
             ]
    end

    test "is empty when the player has no mastery" do
      assert Ghostwork.mastery_summary(%Player{}) == []
    end
  end

  describe "family_coverage/2 and codex/1" do
    setup do
      node = %IceNode{
        id: "cov_node",
        name: "Cov",
        family: "ice_testfam",
        location_id: "cov_loc",
        cool_threshold: 60,
        layers: [
          %{
            id: "l",
            name: "l",
            trace_multiplier: 1.0,
            reward: [],
            subroutines: [
              %{id: "a", key: :spoof, threat: :barrier, progress_required: 5},
              %{id: "b", key: :decrypt, threat: :sentry, progress_required: 5},
              %{id: "v", key: :backdoor, threat: :vault, progress_required: 5, reward: []}
            ]
          }
        ]
      }

      prog = %{
        id: "cov_spoof",
        name: "Cov Spoof",
        action: :spoof,
        progress: 4,
        trace: 3,
        on_weakness: %{progress: 8, trace: 1},
        text: "x"
      }

      :ets.insert(:ice_nodes, {node.id, node})
      :ets.insert(:programs, {prog.id, prog})

      on_exit(fn ->
        :ets.delete(:ice_nodes, "cov_node")
        :ets.delete(:programs, "cov_spoof")
      end)

      %{player: %Player{inventory: %{"cov_spoof" => 1}}}
    end

    test "family_coverage lists the distinct subroutine keys (incl vault), sorted, with owned matches",
         %{player: player} do
      assert Ghostwork.family_coverage(player, "ice_testfam") == [
               %{key: :backdoor, program: nil},
               %{key: :decrypt, program: nil},
               %{key: :spoof, program: "Cov Spoof"}
             ]
    end

    test "codex attaches key coverage once a family is read to KEYS", %{player: player} do
      keys_player = %{player | ghostwork_state: %{"mastery" => %{"ice_testfam" => 3}}}

      assert [entry] = Ghostwork.codex(keys_player)
      assert entry.read.stage == :keys
      assert entry.coverage == Ghostwork.family_coverage(keys_player, "ice_testfam")
    end

    test "codex leaves coverage nil below KEYS read-level", %{player: player} do
      costs_player = %{player | ghostwork_state: %{"mastery" => %{"ice_testfam" => 2}}}

      assert [entry] = Ghostwork.codex(costs_player)
      assert entry.read.stage == :costs
      assert entry.coverage == nil
    end
  end

  describe "titles/1" do
    defp with_deck(player),
      do: %{player | inventory: Map.put(player.inventory, "jury_rigged_terminal", 1)}

    defp earned_tiers(player) do
      player |> Ghostwork.titles() |> Enum.filter(& &1.earned?) |> Enum.map(& &1.tier)
    end

    test "earns only tier 1 when holding the deck with no cracks" do
      assert earned_tiers(with_deck(%Player{})) == [1]
    end

    test "earns higher tiers as total cracks cross thresholds" do
      player = with_deck(%Player{ghostwork_state: %{"mastery" => %{"a" => 2, "b" => 1}}})

      assert earned_tiers(player) == [1, 2, 3]
    end

    test "earns nothing without the deck, even with cracks" do
      player = %Player{ghostwork_state: %{"mastery" => %{"a" => 20}}}

      assert earned_tiers(player) == []
    end

    test "returns every ghostwork tree tier with a name" do
      titles = Ghostwork.titles(with_deck(%Player{}))

      assert Enum.map(titles, & &1.tier) == [1, 2, 3, 4, 5]
      assert Enum.all?(titles, &is_binary(&1.name))
    end
  end

  describe "lattice_active?/2" do
    test "true when the location has lattice and the player holds the deck" do
      player = %Player{inventory: %{"jury_rigged_terminal" => 1}}

      assert Ghostwork.lattice_active?(player, %{id: "loc", lattice: %{}})
    end

    test "false without the deck" do
      refute Ghostwork.lattice_active?(%Player{}, %{id: "loc", lattice: %{}})
    end

    test "false when the location carries no lattice" do
      player = %Player{inventory: %{"jury_rigged_terminal" => 1}}

      refute Ghostwork.lattice_active?(player, %{id: "loc"})
    end
  end

  describe "nodes_at/2" do
    setup do
      base = %IceNode{
        id: "nat_node",
        name: "Node",
        family: "ice_maintenance",
        location_id: "deck_loc",
        cool_threshold: 60,
        layers: [
          %{
            id: "l1",
            name: "L1",
            progress_required: 10,
            trace_multiplier: 1.0,
            weakness: nil,
            reward: []
          }
        ]
      }

      :ets.insert(:ice_nodes, {base.id, base})
      on_exit(fn -> :ets.delete(:ice_nodes, base.id) end)
      %{base: base}
    end

    test "lists a breakable node at the location", %{base: base} do
      assert [%{node: ^base, status: :breakable}] = Ghostwork.nodes_at(%Player{}, "deck_loc")
    end

    test "excludes nodes at other locations" do
      assert Ghostwork.nodes_at(%Player{}, "elsewhere") == []
    end

    test "excludes nodes whose requirements are unmet", %{base: base} do
      :ets.insert(:ice_nodes, {base.id, %{base | requirements: [{:knows, "gate"}]}})

      assert Ghostwork.nodes_at(%Player{}, "deck_loc") == []
    end

    test "excludes a fully cracked node" do
      player = %Player{
        ghostwork_state: %{
          "nodes" => %{"nat_node" => %{"banked_layer" => 0, "hardened" => false}}
        }
      }

      assert Ghostwork.nodes_at(player, "deck_loc") == []
    end

    test "marks a hardened node hot as :hardened" do
      player = %Player{
        heat: 70,
        ghostwork_state: %{
          "nodes" => %{"nat_node" => %{"banked_layer" => -1, "hardened" => true}}
        }
      }

      assert [%{status: :hardened}] = Ghostwork.nodes_at(player, "deck_loc")
    end

    test "marks a hardened node that has cooled off as :breakable" do
      player = %Player{
        heat: 30,
        ghostwork_state: %{
          "nodes" => %{"nat_node" => %{"banked_layer" => -1, "hardened" => true}}
        }
      }

      assert [%{status: :breakable}] = Ghostwork.nodes_at(player, "deck_loc")
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
    test "errors without a deck" do
      assert {:error, :no_deck} = Ghostwork.scan(%Player{}, lattice_location(%{}))
    end

    test "errors when the location carries no lattice" do
      assert {:error, :no_lattice} = Ghostwork.scan(with_deck(%Player{}), %{id: "loc"})
    end

    test "surfaces an eligible lead with its on_intercept and heat" do
      location = lattice_location(%{leads: [lead([])], filler: []})

      {:ok, effects, meta} = Ghostwork.scan(with_deck(%Player{}), location)

      assert {:knowledge, "relay_found"} in effects
      assert {:heat, 2} in effects
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

      {:ok, _effects, meta} = Ghostwork.scan(with_deck(%Player{}), location)

      assert meta.signal_id == "first"
    end

    test "skips a lead whose granted knowledge the player already holds (swept)" do
      location =
        lattice_location(%{
          leads: [lead([])],
          filler: [%{weight: 1, text: "filler", on_intercept: [{:scrip, 3}]}]
        })

      {:ok, effects, meta} =
        Ghostwork.scan(with_deck(%Player{knowledge: ["relay_found"]}), location)

      assert meta.kind == :filler
      assert {:scrip, 3} in effects
    end

    test "skips a lead whose requirements are unmet" do
      location =
        lattice_location(%{
          leads: [lead(requirements: [{:knows, "gate"}])],
          filler: [%{weight: 1, text: "filler", on_intercept: [{:scrip, 3}]}]
        })

      {:ok, _effects, meta} = Ghostwork.scan(with_deck(%Player{}), location)

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
          {:ok, _effects, meta} = Ghostwork.scan(with_deck(%Player{}), location)
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

      {:ok, effects, _meta} = Ghostwork.scan(with_deck(%Player{}), location)

      assert {:heat, 2} in effects
    end

    test "returns an empty scan (heat only) when no lead and no filler are available" do
      location = lattice_location(%{leads: [], filler: []})

      {:ok, effects, meta} = Ghostwork.scan(with_deck(%Player{}), location)

      assert effects == [{:heat, 2}]
      assert meta == %{kind: :empty, text: nil}
    end

    test "treats missing :leads/:filler keys as empty" do
      {:ok, effects, meta} = Ghostwork.scan(with_deck(%Player{}), lattice_location(%{}))

      assert effects == [{:heat, 2}]
      assert meta.kind == :empty
    end

    test "surfaces a lead whose on_intercept contains only non-knowledge effects" do
      scrip_lead = lead(on_intercept: [{:scrip, 10}])
      location = lattice_location(%{leads: [scrip_lead], filler: []})

      {:ok, effects, meta} = Ghostwork.scan(with_deck(%Player{}), location)

      assert meta.kind == :lead
      assert {:scrip, 10} in effects
    end

    test "filler with all zero weights falls back to empty scan without crashing" do
      location =
        lattice_location(%{
          leads: [],
          filler: [%{weight: 0, text: "ghost", on_intercept: [{:scrip, 1}]}]
        })

      {:ok, effects, meta} = Ghostwork.scan(with_deck(%Player{}), location)

      assert meta.kind == :empty
      assert effects == [{:heat, 2}]
    end
  end

  describe "verb_identity/1 and verb_legend/0" do
    test "each verb has a label and a tell" do
      for verb <- [:spoof, :cloak, :backdoor, :decrypt, :overload] do
        id = Ghostwork.verb_identity(verb)
        assert id.label == verb |> to_string() |> String.upcase()
        assert is_binary(id.tell) and id.tell != ""
      end
    end

    test "verb_legend/0 lists every verb, in order, tagged with its verb atom" do
      legend = Ghostwork.verb_legend()

      assert Enum.map(legend, & &1.verb) == [:spoof, :cloak, :backdoor, :decrypt, :overload]
      assert Enum.all?(legend, &match?(%{verb: _, label: _, tell: _}, &1))
    end
  end

  describe "threat_affinity/1 and threat_affinities/0" do
    test "the three keyed threats map to their canon verb" do
      assert Ghostwork.threat_affinity(:barrier) == :spoof
      assert Ghostwork.threat_affinity(:sentry) == :cloak
      assert Ghostwork.threat_affinity(:trap) == :backdoor
    end

    test "vault (and anything else) has no affinity — it is a blind gamble" do
      assert Ghostwork.threat_affinity(:vault) == nil
      assert Ghostwork.threat_affinity(:whatever) == nil
    end

    test "affinity verbs are real verbs that counter their own key (the rule of thumb is honest)" do
      for %{threat: _threat, verb: verb} <- Ghostwork.threat_affinities() do
        assert Ghostwork.counters?(%{action: verb}, verb)
      end
    end

    test "threat_affinities/0 lists the keyed threats in legend order" do
      assert Ghostwork.threat_affinities() == [
               %{threat: :barrier, verb: :spoof},
               %{threat: :sentry, verb: :cloak},
               %{threat: :trap, verb: :backdoor}
             ]
    end
  end
end
