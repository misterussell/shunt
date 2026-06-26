defmodule Shunt.World.NpcsTest do
  # async: false — setup mutates the shared, global :world_npcs ETS table with a synthetic
  # fixture NPC, which would otherwise race with other test modules' reads of :world_npcs.
  use ExUnit.Case, async: false

  alias Shunt.Events.Event
  alias Shunt.Players.Player
  alias Shunt.World.NPC
  alias Shunt.World.Npcs

  describe "get!/1" do
    test "returns the Shunt.World.NPC struct for a known id" do
      npc = Npcs.get!("shunt9_maintenance_tunnel_junkie")

      assert %Shunt.World.NPC{} = npc
      assert npc.name == "Tunnel Junkie"
      assert npc.location_id == "shunt9_maintenance_tunnel"
    end

    test "raises for an unknown id" do
      assert_raise RuntimeError, fn -> Npcs.get!("unknown") end
    end
  end

  describe "current_event/2" do
    @npc_key "test_current_event_npc"

    setup do
      npc = %NPC{
        id: @npc_key,
        name: "Test NPC",
        story_arcs: ["arc_one", "arc_two"],
        repeatable_events: ["repeatable_one"]
      }

      event = %Event{id: "repeatable_one", title: "Repeatable One", requirements: [], steps: []}

      :ets.insert(:world_npcs, {@npc_key, npc})
      :ets.insert(:events, {"repeatable_one", event})

      on_exit(fn ->
        :ets.delete(:world_npcs, @npc_key)
        :ets.delete(:events, "repeatable_one")
      end)

      :ok
    end

    test "returns the first story arc for a player who has never met the npc" do
      player = %Player{npc_progression: %{}}

      assert Npcs.current_event(player, @npc_key) == "arc_one"
    end

    test "returns the next story arc once progression has advanced" do
      player = %Player{npc_progression: %{@npc_key => 1}}

      assert Npcs.current_event(player, @npc_key) == "arc_two"
    end

    test "falls back to a repeatable event once progression exceeds the story arcs" do
      player = %Player{npc_progression: %{@npc_key => 2}}

      assert Npcs.current_event(player, @npc_key) == "repeatable_one"
    end
  end

  describe "current_event/2 with requirement-gated repeatables" do
    @npc_key "test_requirement_npc"

    setup do
      npc = %NPC{
        id: @npc_key,
        name: "Test NPC",
        story_arcs: [],
        repeatable_events: [
          "shunt9_bazaar_juno_deliver_parcel",
          "shunt9_bazaar_juno_collect_pickup"
        ]
      }

      :ets.insert(:world_npcs, {@npc_key, npc})
      on_exit(fn -> :ets.delete(:world_npcs, @npc_key) end)

      :ok
    end

    test "returns the first matching repeatable event based on player inventory" do
      player = %Player{inventory: %{"juno_parcel" => 1}}

      assert Npcs.current_event(player, @npc_key) == "shunt9_bazaar_juno_deliver_parcel"
    end

    test "skips non-matching repeatables and returns the first one the player qualifies for" do
      player = %Player{inventory: %{"juno_pickup_chit" => 1}}

      assert Npcs.current_event(player, @npc_key) == "shunt9_bazaar_juno_collect_pickup"
    end

    test "returns nil when no repeatable event requirements are met" do
      player = %Player{inventory: %{}}

      assert Npcs.current_event(player, @npc_key) == nil
    end
  end
end
