defmodule Shunt.ContactsTest do
  # Reads the real loaded world_npcs content; tests build their own Player state and never mutate
  # the shared content :ets tables, so async is safe.
  use ExUnit.Case, async: true

  alias Shunt.Contacts
  alias Shunt.Effects
  alias Shunt.Events
  alias Shunt.Fencing.Catalog
  alias Shunt.Players.Player
  alias Shunt.World

  # Faithfully apply an event's completion (its on_complete + the completed_events tracking effect,
  # exactly as Shunt.Events.complete_event does) to a plain Player struct.
  defp complete(player, event_id) do
    event = Events.get!(event_id)
    tracking = [{:set, :completed_events, Enum.uniq([event_id | player.completed_events])}]
    {changes, _meta} = Effects.apply(player, event.on_complete ++ tracking)
    struct(player, changes)
  end

  # Knowledge flags that unlock each contact's basic (intro) tier.
  defp met, do: ["mother_graft_intro", "nine_iron_intro", "splice_intro", "tally_intro", "rook"]

  describe "resolve_service/3 — data_drop (Splice)" do
    test "basic tier returns the retired deal's exact effects, keyed by contact_key" do
      player = %Player{scrip: 20, knowledge: ["splice_intro"]}

      assert Contacts.resolve_service(player, "splice", "data_drop") ==
               {:ok, [{:scrip, -20}, {:cred, 1}, {:npc_loyalty, "splice", 5}]}
    end

    test "a locked service (no unlock flag) returns {:error, :service_locked}" do
      player = %Player{scrip: 20, knowledge: []}

      assert Contacts.resolve_service(player, "splice", "data_drop") ==
               {:error, :service_locked}
    end

    test "returns {:error, :insufficient_scrip} when scrip is below cost" do
      player = %Player{scrip: 19, knowledge: ["splice_intro"]}

      assert Contacts.resolve_service(player, "splice", "data_drop") ==
               {:error, :insufficient_scrip}
    end

    test "the best unlocked tier's params win (task2 -> Blind-Spot Feed)" do
      player = %Player{scrip: 20, knowledge: ["splice_intro", "splice_task1", "splice_task2"]}

      assert Contacts.resolve_service(player, "splice", "data_drop") ==
               {:ok, [{:scrip, -15}, {:cred, 3}, {:npc_loyalty, "splice", 5}]}
    end

    test "a favored-loyalty player gets a scaled (cheaper) scrip cost" do
      player = %Player{scrip: 20, knowledge: ["splice_intro"], npc_loyalty: %{"splice" => 80}}

      assert {:ok, effects} = Contacts.resolve_service(player, "splice", "data_drop")
      assert {:scrip, -ceil(20 * 0.8)} in effects
    end

    test "a hostile-loyalty player can be unreliable" do
      player = %Player{scrip: 25, knowledge: ["splice_intro"], npc_loyalty: %{"splice" => 0}}

      results =
        Enum.map(1..200, fn _ -> Contacts.resolve_service(player, "splice", "data_drop") end)

      assert Enum.any?(results, &(&1 == {:error, :npc_unreliable}))
    end
  end

  describe "resolve_service/3 — the other four basic deals" do
    test "flesh_tithe (Mother Graft)" do
      player = %Player{inventory: %{"cracked_bone_plate" => 1}, knowledge: ["mother_graft_intro"]}

      assert Contacts.resolve_service(player, "mother_graft", "flesh_tithe") ==
               {:ok,
                [
                  {:inventory, "cracked_bone_plate", -1},
                  {:heat, 3},
                  {:scrip, 15},
                  {:npc_loyalty, "mother_graft", 5}
                ]}
    end

    test "flesh_tithe returns {:error, :insufficient_materials} without the input" do
      player = %Player{inventory: %{}, knowledge: ["mother_graft_intro"]}

      assert Contacts.resolve_service(player, "mother_graft", "flesh_tithe") ==
               {:error, :insufficient_materials}
    end

    test "move_goods (Rook) pays 50% of the held item's sell_value at the basic tier" do
      item = Catalog.fetch!("scrap_dermal_plating")
      player = %Player{held_item_key: item.id, knowledge: ["rook"]}

      assert Contacts.resolve_service(player, "rook", "move_goods") ==
               {:ok,
                [
                  {:scrip, floor(item.sell_value * 0.5)},
                  {:set, :held_item_key, nil},
                  {:npc_loyalty, "rook", 5}
                ]}
    end

    test "move_goods returns {:error, :no_held_item} when holding nothing" do
      player = %Player{held_item_key: nil, knowledge: ["rook"]}

      assert Contacts.resolve_service(player, "rook", "move_goods") == {:error, :no_held_item}
    end

    test "look_the_other_way (Nine-Iron)" do
      player = %Player{scrip: 20, knowledge: ["nine_iron_intro"]}

      assert Contacts.resolve_service(player, "nine_iron", "look_the_other_way") ==
               {:ok, [{:scrip, -20}, {:heat, -15}, {:npc_loyalty, "nine_iron", 5}]}
    end

    test "settle_the_books (Tally)" do
      player = %Player{cred: 1, knowledge: ["tally_intro"]}

      assert Contacts.resolve_service(player, "tally", "settle_the_books") ==
               {:ok, [{:cred, -1}, {:scrip, 10}, {:npc_loyalty, "tally", 5}]}
    end

    test "a favored-loyalty player gets a scaled (better) gain on the price side" do
      player = %Player{cred: 1, knowledge: ["tally_intro"], npc_loyalty: %{"tally" => 80}}

      assert {:ok, effects} = Contacts.resolve_service(player, "tally", "settle_the_books")
      assert {:scrip, floor(10 * 1.2)} in effects
    end

    test "settle_the_books returns {:error, :insufficient_cred} when cred is 0" do
      player = %Player{cred: 0, knowledge: ["tally_intro"]}

      assert Contacts.resolve_service(player, "tally", "settle_the_books") ==
               {:error, :insufficient_cred}
    end
  end

  describe "list_for_player/1" do
    test "omits a contact with no unlocked service (known-only)" do
      player = %Player{knowledge: []}

      refute Enum.any?(Contacts.list_for_player(player), &(&1.npc.contact_key == "splice"))
    end

    test "includes a contact once its intro flag is granted, with only its basic service" do
      player = %Player{knowledge: ["splice_intro"]}

      entry = Enum.find(Contacts.list_for_player(player), &(&1.npc.contact_key == "splice"))
      assert [%{key: :data_drop, name: "Data Drop"}] = entry.services
    end

    test "reveals the best-unlocked tier as the single service (collapse, hide locked)" do
      player = %Player{knowledge: ["splice_intro", "splice_task1"]}

      entry = Enum.find(Contacts.list_for_player(player), &(&1.npc.contact_key == "splice"))

      assert [%{key: :data_drop, name: "Deep Cache", params: %{cost: 15, gain_cred: 2}}] =
               entry.services
    end

    test "carries the contact's loyalty value" do
      player = %Player{knowledge: ["tally_intro"], npc_loyalty: %{"tally" => 73}}

      entry = Enum.find(Contacts.list_for_player(player), &(&1.npc.contact_key == "tally"))
      assert entry.loyalty == 73
    end

    test "is sorted by contact name" do
      player = %Player{knowledge: met()}

      names = Enum.map(Contacts.list_for_player(player), & &1.npc.name)
      assert names == Enum.sort(names)
    end
  end

  describe "can_afford?/3" do
    test "true when the player can pay the best-unlocked tier" do
      player = %Player{scrip: 20, knowledge: ["nine_iron_intro"]}

      assert Contacts.can_afford?(player, "nine_iron", "look_the_other_way")
    end

    test "false when the player cannot pay" do
      player = %Player{scrip: 19, knowledge: ["nine_iron_intro"]}

      refute Contacts.can_afford?(player, "nine_iron", "look_the_other_way")
    end
  end

  describe "name/1" do
    test "returns the contact's display name for its contact_key" do
      assert Contacts.name("mother_graft") == "Mother Graft"
    end

    test "falls back to the raw key for an unknown contact" do
      assert Contacts.name("nobody") == "nobody"
    end
  end

  describe "story-arc -> Hub integration (drives the real runtime)" do
    test "completing Mother Graft's arc reveals her on the Hub and upgrades her tier by tier" do
      npc = "crossgate_mother_graft"

      p0 = %Player{}
      assert World.Npcs.current_event(p0, npc) == "crossgate_mother_graft_intro"
      refute Enum.any?(Contacts.list_for_player(p0), &(&1.npc.contact_key == "mother_graft"))

      p1 = complete(p0, "crossgate_mother_graft_intro")
      assert World.Npcs.current_event(p1, npc) == "crossgate_mother_graft_task1"
      assert [%{name: "Flesh Tithe"}] = services_for(p1, "mother_graft")

      p2 = complete(p1, "crossgate_mother_graft_task1")
      assert World.Npcs.current_event(p2, npc) == "crossgate_mother_graft_task2"
      assert [%{name: "Clean Cut"}] = services_for(p2, "mother_graft")

      p3 = complete(p2, "crossgate_mother_graft_task2")
      assert World.Npcs.current_event(p3, npc) == nil
      assert [%{name: "Fleshless Favor"}] = services_for(p3, "mother_graft")
    end
  end

  defp services_for(player, contact_key) do
    player
    |> Contacts.list_for_player()
    |> Enum.find(&(&1.npc.contact_key == contact_key))
    |> Map.fetch!(:services)
  end
end
