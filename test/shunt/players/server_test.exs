defmodule Shunt.Players.ServerTest do
  use Shunt.DataCase

  alias Shunt.Npcs.Signals
  alias Shunt.Players
  alias Shunt.Players.Player

  describe "lookup_or_start/1" do
    test "starts a server for a player_id and returns the same pid on a repeated call" do
      player = Players.create_player!()

      assert {:ok, pid} = Players.lookup_or_start(player.id)
      assert {:ok, ^pid} = Players.lookup_or_start(player.id)
      assert Process.alive?(pid)
      assert [{^pid, nil}] = Registry.lookup(Shunt.Players.Registry, player.id)
    end
  end

  describe "current/1" do
    test "returns the player loaded from Postgres" do
      player = Players.create_player!()

      assert Players.current(player.id).id == player.id
    end
  end

  describe "dispatch/2" do
    test "applies the resolver's effects and persists the result" do
      player = Players.create_player!()

      assert {:ok, updated, _meta} =
               Players.dispatch(player.id, fn _p -> {:ok, [{:scrip, 50}]} end)

      assert updated.scrip == 50
      assert Players.current(player.id).scrip == 50
      assert Repo.get!(Player, player.id).scrip == 50
    end

    test "returns the resolver's error without persisting or mutating in-memory state" do
      player = Players.create_player!()

      assert Players.dispatch(player.id, fn _p -> {:error, :no_offer} end) == {:error, :no_offer}

      assert Players.current(player.id).scrip == 0
      assert Repo.get!(Player, player.id).scrip == 0
    end

    test "merges a resolver's extra meta with the effect meta" do
      player = Players.create_player!()

      assert {:ok, _updated, meta} =
               Players.dispatch(player.id, fn _p -> {:ok, [{:scrip, 10}], %{flash: :sold}} end)

      assert meta.flash == :sold
      assert meta.heat_event == nil
    end

    test "broadcasts npc signals via Shunt.Npcs.Signals after a successful loyalty band transition" do
      player = Players.create_player!()
      Signals.subscribe()

      assert {:ok, _updated, _meta} =
               Players.dispatch(player.id, fn _p -> {:ok, [{:npc_loyalty, "tally", 5}]} end)

      assert_receive {:npc_met, "tally"}
    end
  end
end
