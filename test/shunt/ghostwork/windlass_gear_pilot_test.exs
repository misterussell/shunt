defmodule Shunt.Ghostwork.WindlassGearPilotTest do
  @moduledoc """
  Windlass Ghostwork gear pilot — behavioral spec.

  Turns on the loadout choice (5 keys > 3 slots), the tier deck (Axis 1), and the
  crack->loot->crack economy, entirely as ice_authority content — no engine code.

  SLICE 1 (this file, implemented): the gear + the High Anchor vault gate/structure.
  Remaining TODOs at the bottom cover Nodes 1 & 2 and the lattice wiring (next slice).
  """
  use ExUnit.Case, async: true

  alias Shunt.Ghostwork
  alias Shunt.Ghostwork.{Decks, IceNode, Programs}
  alias Shunt.Players.Player
  alias Shunt.World

  # --- The gear itself -----------------------------------------------------------------------

  test "the four new programs load with the new-key action profiles" do
    for {id, action} <- [
          {"powerspike", :overload},
          {"arc_driver", :overload},
          {"dampener", :cloak},
          {"nullsleeve", :cloak}
        ] do
      program = Programs.fetch!(id)
      assert program.action == action
      assert is_integer(program.progress) and program.progress > 0
      assert is_integer(program.on_weakness.progress) and is_integer(program.on_weakness.trace)
    end
  end

  test "the tier deck loads at four slots and sizes a holder's loadout" do
    assert Decks.fetch!("fitworks_deck").slots == 4

    holder = %Player{inventory: %{"fitworks_deck" => 1}}
    assert Ghostwork.active_deck(holder).id == "fitworks_deck"
    assert Ghostwork.deck_slots(holder) == 4
  end

  test "the tier deck lets a fourth program equip" do
    player = %Player{
      inventory: %{
        "fitworks_deck" => 1,
        "maskchip" => 1,
        "shard_reader" => 1,
        "ghostkey" => 1,
        "dampener" => 1
      },
      ghostwork_state: %{"loadout" => ["maskchip", "shard_reader", "ghostkey"]}
    }

    assert Ghostwork.equip(player, "dampener") ==
             ["maskchip", "shard_reader", "ghostkey", "dampener"]
  end

  test "four slots is the cap even on the tier deck" do
    loadout = ["maskchip", "shard_reader", "ghostkey", "dampener"]

    player = %Player{
      inventory: Map.new(["fitworks_deck", "nullsleeve" | loadout], &{&1, 1}),
      ghostwork_state: %{"loadout" => loadout}
    }

    assert Ghostwork.equip(player, "nullsleeve") == loadout
  end

  test "the starter deck still caps the loadout at three" do
    loadout = ["maskchip", "shard_reader", "ghostkey"]

    player = %Player{
      inventory: Map.new(["jury_rigged_terminal", "dampener" | loadout], &{&1, 1}),
      ghostwork_state: %{"loadout" => loadout}
    }

    assert Ghostwork.equip(player, "dampener") == loadout
  end

  # --- The structural fix: key-space > slots -------------------------------------------------

  test "ice_authority ICE now demands the two new keys" do
    keys = Ghostwork.family_coverage(%Player{}, "ice_authority") |> Enum.map(& &1.key)

    assert :overload in keys
    assert :cloak in keys
  end

  test "ice_authority demands more keys than a starter loadout can carry" do
    key_count = Ghostwork.family_coverage(%Player{}, "ice_authority") |> length()
    starter = %Player{inventory: %{"jury_rigged_terminal" => 1}}

    assert key_count > Ghostwork.deck_slots(starter)
  end

  test "family coverage names an owned program against its key" do
    owner = %Player{inventory: %{"dampener" => 1}}
    cloak = Ghostwork.family_coverage(owner, "ice_authority") |> Enum.find(&(&1.key == :cloak))
    assert cloak.program == "Dampener"

    unowned =
      Ghostwork.family_coverage(%Player{}, "ice_authority") |> Enum.find(&(&1.key == :cloak))

    assert unowned.program == nil
  end

  # --- The mastery long-tail (Node 3 gate) ---------------------------------------------------

  test "the High Anchor vault stays hidden until ice_authority is read cold" do
    base = %Player{
      knowledge: ["windlass_anchor_vault_found"],
      location_id: "windlass_high_anchor"
    }

    below = %{base | ghostwork_state: %{"mastery" => %{"ice_authority" => 5}}}
    at = %{base | ghostwork_state: %{"mastery" => %{"ice_authority" => 6}}}

    refute vault_visible?(below)
    assert vault_visible?(at)
  end

  defp vault_visible?(player) do
    player
    |> Ghostwork.nodes_at("windlass_high_anchor")
    |> Enum.any?(&(&1.node.id == "windlass_anchor_vault"))
  end

  # --- The capstone (Node 3 structure) -------------------------------------------------------

  test "the High Anchor vault's warden layer forces both new keys on one board" do
    node = IceNode.fetch!("windlass_anchor_vault")

    both? =
      Enum.any?(node.layers, fn layer ->
        keys = Enum.map(layer.subroutines, & &1.key)
        :cloak in keys and :overload in keys
      end)

    assert both?
  end

  test "the High Anchor vault subroutine loots the tier deck" do
    vault =
      IceNode.fetch!("windlass_anchor_vault").layers
      |> Enum.flat_map(& &1.subroutines)
      |> Enum.find(&(&1.threat == :vault))

    assert vault
    assert {:inventory, "fitworks_deck", 1} in vault.reward
  end

  # --- Node 1: the :overload teacher ---------------------------------------------------------

  test "the Slagfoot relay teaches :overload with a crackable barrier core" do
    overload =
      IceNode.fetch!("windlass_slagfoot_relay").layers
      |> Enum.flat_map(& &1.subroutines)
      |> Enum.find(&(&1.key == :overload))

    assert overload

    # A :barrier (crackable slow with base programs), never a :vault — it teaches, it can't lock out.
    assert overload.threat == :barrier
  end

  # --- Node 2: the :cloak bleed race ---------------------------------------------------------

  test "the Skim registry stacks a cloak-keyed sentry ring" do
    assert skim_watch_ring()
  end

  test "the Skim registry's watch ring loots the cloak upgrade" do
    assert {:inventory, "nullsleeve", 1} in skim_watch_ring().reward
  end

  defp skim_watch_ring do
    IceNode.fetch!("windlass_skim_registry").layers
    |> Enum.find(fn layer ->
      Enum.count(layer.subroutines, &(&1.threat == :sentry and &1.key == :cloak)) >= 3
    end)
  end

  # --- Lattice wiring: reveals + the Collective skim -----------------------------------------

  test "scanning the new lattice locations reveals their nodes" do
    deck = %{"jury_rigged_terminal" => 1}
    read_cold = %{"mastery" => %{"ice_authority" => 6}}

    reveals = [
      {"windlass_slagworks", %Player{inventory: deck}, "windlass_slagfoot_relay_found"},
      {"windlass_the_skim", %Player{inventory: deck}, "windlass_skim_registry_found"},
      {"windlass_high_anchor", %Player{inventory: deck, ghostwork_state: read_cold},
       "windlass_anchor_vault_found"}
    ]

    for {loc_id, player, knowledge} <- reveals do
      {:ok, effects, meta} = Ghostwork.scan(player, World.get_location(loc_id))
      assert meta.kind == :lead
      assert {:knowledge, knowledge} in effects
    end
  end

  test "the Fitworks skims the cloak starter to a returning runner" do
    # holding the relay's knowledge sweeps the existing ICE lead, so the next skim surfaces
    player = %Player{
      inventory: %{"jury_rigged_terminal" => 1},
      knowledge: ["windlass_fitworks_ice_found"]
    }

    {:ok, effects, meta} = Ghostwork.scan(player, World.get_location("windlass_fitters_floor"))

    assert meta.kind == :lead
    assert {:inventory, "dampener", 1} in effects
  end

  test "the overload starter is gated behind turning the grid war" do
    inventory = %{"jury_rigged_terminal" => 1}
    # relay + dampener leads already swept, so powerspike is the next candidate
    swept = ["windlass_fitworks_ice_found", "windlass_dampener_taken"]

    clamped = %Player{inventory: inventory, knowledge: swept}

    {:ok, clamped_effects, _} =
      Ghostwork.scan(clamped, World.get_location("windlass_fitters_floor"))

    refute Enum.any?(clamped_effects, &match?({:inventory, "powerspike", _}, &1))

    # {:knows, windlass_fitworks_ice_cracked} derives grid >= :contested (see districts/windlass.exs)
    contested = %Player{
      inventory: inventory,
      knowledge: ["windlass_fitworks_ice_cracked" | swept]
    }

    {:ok, contested_effects, meta} =
      Ghostwork.scan(contested, World.get_location("windlass_fitters_floor"))

    assert meta.kind == :lead
    assert {:inventory, "powerspike", 1} in contested_effects
  end
end
