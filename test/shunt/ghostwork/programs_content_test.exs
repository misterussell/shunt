defmodule Shunt.Ghostwork.ProgramsContentTest do
  @moduledoc """
  Asserts the shipped program catalog (priv/content/programs) covers every subroutine
  key and is obtainable in-world, so the key-matching loop can actually be exercised.
  Reads real seeded content; assertions stay tolerant (no exact counts) so they don't
  break as the catalog grows.
  """
  use ExUnit.Case, async: true

  alias Shunt.Ghostwork
  alias Shunt.Ghostwork.Encounter
  alias Shunt.Ghostwork.IceNode
  alias Shunt.Ghostwork.Programs
  alias Shunt.Players.Player
  alias Shunt.World

  test "ships at least one program for each subroutine key" do
    actions = Programs.all() |> Enum.map(& &1.action) |> Enum.uniq()

    assert :spoof in actions
    assert :decrypt in actions
    assert :backdoor in actions
  end

  test "every shipped program has a well-formed action profile" do
    for program <- Programs.all() do
      assert is_binary(program.id) and program.id != ""
      assert is_binary(program.name) and program.name != ""
      assert is_binary(program.text) and program.text != ""
      assert program.action in [:spoof, :decrypt, :backdoor]
      assert is_integer(program.progress) and program.progress > 0
      assert is_integer(program.trace) and program.trace >= 0
      assert is_integer(program.on_weakness.progress) and is_integer(program.on_weakness.trace)
    end
  end

  test "ships at least one quiet/loud pair on the same key (so the loadout choice bites)" do
    by_key = Enum.group_by(Programs.all(), & &1.action)

    assert Enum.any?(by_key, fn {_key, programs} ->
             traces = Enum.map(programs, & &1.trace)
             length(programs) >= 2 and Enum.max(traces) > Enum.min(traces)
           end)
  end

  test "the bazaar lattice hands a player with a deck their first program" do
    player = %Player{inventory: %{"jury_rigged_terminal" => 1}}
    location = World.get_location("shunt9_bazaar")

    {:ok, effects, meta} = Ghostwork.scan(player, location)

    assert meta.kind == :lead
    assert Enum.any?(effects, &match?({:inventory, _id, 1}, &1))
  end

  describe "salvage grid showcase node" do
    test "its board layer mixes barrier/sentry/trap across all three keys" do
      node = IceNode.fetch!("shunt9_salvage_grid")
      board = Enum.find(node.layers, &(length(&1.subroutines) >= 3))

      threats = board.subroutines |> Enum.map(& &1.threat) |> Enum.uniq() |> Enum.sort()
      keys = board.subroutines |> Enum.map(& &1.key) |> Enum.uniq() |> Enum.sort()

      assert threats == [:barrier, :sentry, :trap]
      assert keys == [:backdoor, :decrypt, :spoof]
    end

    test "it is revealed by a scrap-yard scan lead it gates on" do
      lead =
        World.get_location("shunt9_scrap_yard").lattice.leads
        |> Enum.find(&(&1.id == "salvage_grid_signal"))

      assert {:knowledge, "shunt9_salvage_grid_found"} in lead.on_intercept

      assert {:knows, "shunt9_salvage_grid_found"} in IceNode.fetch!("shunt9_salvage_grid").requirements
    end

    test "is winnable with matching keys without busting" do
      :rand.seed(:exsss, {7, 7, 7})
      node = IceNode.fetch!("shunt9_salvage_grid")
      player = %Player{inventory: Map.new(Programs.all(), &{&1.id, 1})}

      {:ok, enc, _} = Ghostwork.begin_encounter(player, node)
      {status, trace} = play_to_end(enc, player)

      assert status == :cracked
      assert trace < 100
    end
  end

  # Greedily clear the board: target the lowest-progress still-alive subroutine (sentries
  # bleed, so finishing fast matters) with a program whose key matches it.
  defp play_to_end(enc, player, turns \\ 0)

  defp play_to_end(%Encounter{status: :active} = enc, player, turns) when turns < 50 do
    layer = Enum.at(enc.node.layers, enc.layer_index)

    target =
      layer.subroutines
      |> Enum.filter(&(Map.get(enc.subroutine_progress, &1.id, 0) < &1.progress_required))
      |> Enum.min_by(&(&1.progress_required - Map.get(enc.subroutine_progress, &1.id, 0)))

    action =
      case Enum.find(Programs.all(), &(&1.action == target.key)) do
        nil -> :probe
        program -> {:program, program.id}
      end

    {:ok, next, _} = Ghostwork.act(enc, player, action, target.id)
    play_to_end(next, player, turns + 1)
  end

  defp play_to_end(enc, _player, _turns), do: {enc.status, enc.trace}
end
