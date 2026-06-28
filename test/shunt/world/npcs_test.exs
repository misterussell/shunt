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

  describe "current_event/2 story arc progression" do
    @npc_key "test_current_event_npc"

    setup do
      npc = %NPC{
        id: @npc_key,
        name: "Test NPC",
        story_arcs: ["arc_one", "arc_two"],
        conditional_events: [],
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

    test "skips a story arc the player has already completed" do
      player = %Player{
        npc_progression: %{},
        completed_events: ["arc_one"]
      }

      assert Npcs.current_event(player, @npc_key) == "repeatable_one"
    end

    test "falls back to a repeatable event once progression exceeds the story arcs" do
      player = %Player{npc_progression: %{@npc_key => 2}}

      assert Npcs.current_event(player, @npc_key) == "repeatable_one"
    end
  end

  describe "current_event/2 conditional events" do
    @npc_key "test_conditional_npc"

    setup do
      npc = %NPC{
        id: @npc_key,
        name: "Test NPC",
        story_arcs: [],
        conditional_events: [
          "shunt9_bazaar_juno_deliver_parcel",
          "shunt9_bazaar_juno_collect_pickup"
        ],
        repeatable_events: []
      }

      :ets.insert(:world_npcs, {@npc_key, npc})
      on_exit(fn -> :ets.delete(:world_npcs, @npc_key) end)

      :ok
    end

    test "returns the first conditional event whose requirements are met" do
      player = %Player{inventory: %{"juno_parcel" => 1}}

      assert Npcs.current_event(player, @npc_key) == "shunt9_bazaar_juno_deliver_parcel"
    end

    test "skips unmet conditional events and returns the first matching one" do
      player = %Player{inventory: %{"juno_pickup_chit" => 1}}

      assert Npcs.current_event(player, @npc_key) == "shunt9_bazaar_juno_collect_pickup"
    end

    test "returns nil when no conditional event requirements are met and no repeatables" do
      player = %Player{inventory: %{}}

      assert Npcs.current_event(player, @npc_key) == nil
    end

    test "skips a completed non-repeatable conditional event even while its requirements still hold" do
      player = %Player{
        inventory: %{"juno_parcel" => 1},
        completed_events: ["shunt9_bazaar_juno_deliver_parcel"]
      }

      assert Npcs.current_event(player, @npc_key) == nil
    end
  end
end
