defmodule Shunt.Ghostwork.ProgramsTest do
  use ExUnit.Case, async: true

  alias Shunt.Ghostwork.Programs
  alias Shunt.Players.Player

  setup do
    prog = %{
      id: "test_mimic_daemon",
      name: "Mimic Daemon",
      action: :spoof,
      progress: 4,
      trace: 3,
      on_weakness: %{progress: 8, trace: 1},
      text: "Wraps your handshake in a forged corp signature."
    }

    :ets.insert(:programs, {prog.id, prog})
    on_exit(fn -> :ets.delete(:programs, prog.id) end)
    %{prog: prog}
  end

  describe "all/0" do
    test "includes loaded programs", %{prog: prog} do
      assert prog in Programs.all()
    end
  end

  describe "fetch!/1" do
    test "returns the program map for a known id", %{prog: prog} do
      assert Programs.fetch!("test_mimic_daemon") == prog
    end

    test "raises for an unknown id" do
      assert_raise RuntimeError, fn -> Programs.fetch!("no_such_program") end
    end
  end

  describe "owned/1" do
    test "returns the programs the player holds", %{prog: prog} do
      player = %Player{inventory: %{"test_mimic_daemon" => 1}}

      assert Programs.owned(player) == [prog]
    end

    test "excludes programs absent from inventory" do
      player = %Player{inventory: %{}}

      refute Enum.any?(Programs.owned(player), &(&1.id == "test_mimic_daemon"))
    end
  end

  describe "loadout/1" do
    test "returns only owned programs that are equipped", %{prog: prog} do
      player = %Player{
        inventory: %{"test_mimic_daemon" => 1},
        ghostwork_state: %{"loadout" => ["test_mimic_daemon"]}
      }

      assert Programs.loadout(player) == [prog]
    end

    test "excludes an equipped program the player no longer owns" do
      player = %Player{inventory: %{}, ghostwork_state: %{"loadout" => ["test_mimic_daemon"]}}

      refute Enum.any?(Programs.loadout(player), &(&1.id == "test_mimic_daemon"))
    end

    test "excludes an owned program that is not equipped" do
      player = %Player{inventory: %{"test_mimic_daemon" => 1}, ghostwork_state: %{}}

      refute Enum.any?(Programs.loadout(player), &(&1.id == "test_mimic_daemon"))
    end
  end
end
