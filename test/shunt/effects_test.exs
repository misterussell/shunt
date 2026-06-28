defmodule Shunt.EffectsTest do
  use ExUnit.Case, async: true

  alias Shunt.Effects
  alias Shunt.Players.Player

  describe "apply/2 - :infrastructure" do
    test "sets a repairable's state on an empty infrastructure map" do
      player = %Player{infrastructure: %{}}

      {changes, _meta} = Effects.apply(player, [{:infrastructure, "gen", "patched"}])

      assert changes.infrastructure == %{"gen" => "patched"}
    end

    test "updates one repairable's state while preserving others" do
      player = %Player{infrastructure: %{"gen" => "patched", "lift" => "broken"}}

      {changes, _meta} = Effects.apply(player, [{:infrastructure, "gen", "repaired"}])

      assert changes.infrastructure == %{"gen" => "repaired", "lift" => "broken"}
    end
  end

  describe "apply/2 - :web_board" do
    test "sets the web_board to the given map" do
      board = %{"positions" => %{"a" => %{"x" => 0.1, "y" => 0.2}}, "wires" => [["a", "b"]]}
      player = %Player{}

      {changes, _meta} = Effects.apply(player, [{:web_board, board}])

      assert changes.web_board == board
    end
  end

  describe "apply/2 - :scrip and :cred" do
    test "adds a positive scrip delta" do
      player = %Player{scrip: 10}

      {changes, _meta} = Effects.apply(player, [{:scrip, 5}])

      assert changes.scrip == 15
    end

    test "clamps scrip at 0 when a delta would take it negative" do
      player = %Player{scrip: 5}

      {changes, _meta} = Effects.apply(player, [{:scrip, -20}])

      assert changes.scrip == 0
    end

    test "adds a positive cred delta" do
      player = %Player{cred: 2}

      {changes, _meta} = Effects.apply(player, [{:cred, 3}])

      assert changes.cred == 5
    end

    test "clamps cred at 0 when a delta would take it negative" do
      player = %Player{cred: 1}

      {changes, _meta} = Effects.apply(player, [{:cred, -10}])

      assert changes.cred == 0
    end
  end

  describe "apply/2 - :heat" do
    test "raises heat with no event when staying within the current band" do
      player = %Player{heat: 0}

      {changes, meta} = Effects.apply(player, [{:heat, 10}])

      assert changes.heat == 10
      assert meta.heat_event == nil
    end

    test "fires a heat event and discharges heat when crossing a band, then applies the event's losses" do
      player = %Player{heat: 60, scrip: 100, cred: 20}

      {changes, meta} = Effects.apply(player, [{:heat, 30}, {:scrip, 15}, {:cred, 3}])

      assert meta.heat_event.band == :high
      assert changes.heat == 85
      assert changes.scrip == max(100 + 15 - meta.heat_event.scrip_loss, 0)
      assert changes.cred == max(20 + 3 - meta.heat_event.cred_loss, 0)
    end
  end

  describe "apply/2 - :inventory" do
    test "increments an existing inventory key" do
      player = %Player{inventory: %{"raw_key" => 2}}

      {changes, _meta} = Effects.apply(player, [{:inventory, "raw_key", 1}])

      assert changes.inventory == %{"raw_key" => 3}
    end

    test "adds a new inventory key starting from zero" do
      player = %Player{inventory: %{}}

      {changes, _meta} = Effects.apply(player, [{:inventory, "raw_key", 1}])

      assert changes.inventory == %{"raw_key" => 1}
    end

    test "decrements an inventory key, clamped at 0" do
      player = %Player{inventory: %{"raw_key" => 1}}

      {changes, _meta} = Effects.apply(player, [{:inventory, "raw_key", -5}])

      assert changes.inventory == %{"raw_key" => 0}
    end

    test "accumulates multiple inventory effects across different keys" do
      player = %Player{inventory: %{"raw_a" => 2, "raw_b" => 1, "output" => 0}}

      {changes, _meta} =
        Effects.apply(player, [
          {:inventory, "raw_a", -1},
          {:inventory, "raw_b", -1},
          {:inventory, "output", 1}
        ])

      assert changes.inventory == %{"raw_a" => 1, "raw_b" => 0, "output" => 1}
    end
  end

  describe "apply/2 - :npc_loyalty" do
    test "raises loyalty for an already-met npc, clamped at 100" do
      player = %Player{npc_loyalty: %{"tally" => 98}}

      {changes, meta} = Effects.apply(player, [{:npc_loyalty, "tally", 5}])

      assert changes.npc_loyalty == %{"tally" => 100}
      assert meta.loyalty_signals == []
    end

    test "records an :npc_met signal the first time an npc is interacted with" do
      player = %Player{npc_loyalty: %{}}

      {changes, meta} = Effects.apply(player, [{:npc_loyalty, "tally", 5}])

      assert changes.npc_loyalty == %{"tally" => 55}
      assert {:npc_met, "tally"} in meta.loyalty_signals
    end

    test "records a :loyalty_band_changed signal when crossing into :favored" do
      player = %Player{npc_loyalty: %{"tally" => 74}}

      {changes, meta} = Effects.apply(player, [{:npc_loyalty, "tally", 5}])

      assert changes.npc_loyalty == %{"tally" => 79}
      assert {:loyalty_band_changed, "tally", :neutral, :favored} in meta.loyalty_signals
    end

    test "records no band-change signal when staying within the same band" do
      player = %Player{npc_loyalty: %{"tally" => 50}}

      {_changes, meta} = Effects.apply(player, [{:npc_loyalty, "tally", 5}])

      assert meta.loyalty_signals == []
    end
  end

  describe "apply/2 - :npc_progression" do
    test "adds a new npc_progression key starting from zero" do
      player = %Player{npc_progression: %{}}

      {changes, _meta} = Effects.apply(player, [{:npc_progression, "tunnel_junkie", 1}])

      assert changes.npc_progression == %{"tunnel_junkie" => 1}
    end

    test "increments an existing npc_progression key" do
      player = %Player{npc_progression: %{"tunnel_junkie" => 1}}

      {changes, _meta} = Effects.apply(player, [{:npc_progression, "tunnel_junkie", 1}])

      assert changes.npc_progression == %{"tunnel_junkie" => 2}
    end

    test "clamps npc_progression at a minimum of 0 when a delta would take it negative" do
      player = %Player{npc_progression: %{"tunnel_junkie" => 1}}

      {changes, _meta} = Effects.apply(player, [{:npc_progression, "tunnel_junkie", -5}])

      assert changes.npc_progression == %{"tunnel_junkie" => 0}
    end
  end

  describe "apply/2 - :ghostwork_loadout" do
    test "sets the equipped loadout list" do
      player = %Player{ghostwork_state: %{}}

      {changes, _meta} = Effects.apply(player, [{:ghostwork_loadout, ["maskchip", "ghostkey"]}])

      assert changes.ghostwork_state == %{"loadout" => ["maskchip", "ghostkey"]}
    end

    test "replaces an existing loadout without disturbing other ghostwork_state" do
      player = %Player{
        ghostwork_state: %{"loadout" => ["old"], "mastery" => %{"ice_corp" => 2}}
      }

      {changes, _meta} = Effects.apply(player, [{:ghostwork_loadout, ["maskchip"]}])

      assert changes.ghostwork_state == %{
               "loadout" => ["maskchip"],
               "mastery" => %{"ice_corp" => 2}
             }
    end
  end

  describe "apply/2 - :ghostwork_mastery" do
    test "adds a new family mastery starting from zero" do
      player = %Player{ghostwork_state: %{}}

      {changes, _meta} = Effects.apply(player, [{:ghostwork_mastery, "ice_maintenance", 1}])

      assert changes.ghostwork_state == %{"mastery" => %{"ice_maintenance" => 1}}
    end

    test "increments an existing family mastery" do
      player = %Player{ghostwork_state: %{"mastery" => %{"ice_maintenance" => 3}}}

      {changes, _meta} = Effects.apply(player, [{:ghostwork_mastery, "ice_maintenance", 1}])

      assert changes.ghostwork_state == %{"mastery" => %{"ice_maintenance" => 4}}
    end

    test "clamps family mastery at a minimum of 0 when a delta would take it negative" do
      player = %Player{ghostwork_state: %{"mastery" => %{"ice_maintenance" => 1}}}

      {changes, _meta} = Effects.apply(player, [{:ghostwork_mastery, "ice_maintenance", -5}])

      assert changes.ghostwork_state == %{"mastery" => %{"ice_maintenance" => 0}}
    end

    test "leaves the nodes map untouched when bumping mastery" do
      player = %Player{
        ghostwork_state: %{"nodes" => %{"relay" => %{"banked_layer" => 1, "hardened" => false}}}
      }

      {changes, _meta} = Effects.apply(player, [{:ghostwork_mastery, "ice_corp", 1}])

      assert changes.ghostwork_state == %{
               "mastery" => %{"ice_corp" => 1},
               "nodes" => %{"relay" => %{"banked_layer" => 1, "hardened" => false}}
             }
    end
  end

  describe "apply/2 - :ghostwork_node" do
    test "banks a layer on a missing node, defaulting hardened to false" do
      player = %Player{ghostwork_state: %{}}

      {changes, _meta} = Effects.apply(player, [{:ghostwork_node, "relay", {:bank_layer, 2}}])

      assert changes.ghostwork_state == %{
               "nodes" => %{"relay" => %{"banked_layer" => 2, "hardened" => false}}
             }
    end

    test "hardens a missing node, defaulting banked_layer to -1" do
      player = %Player{ghostwork_state: %{}}

      {changes, _meta} = Effects.apply(player, [{:ghostwork_node, "relay", :harden}])

      assert changes.ghostwork_state == %{
               "nodes" => %{"relay" => %{"banked_layer" => -1, "hardened" => true}}
             }
    end

    test "banking a layer preserves an existing hardened flag" do
      player = %Player{
        ghostwork_state: %{"nodes" => %{"relay" => %{"banked_layer" => 0, "hardened" => true}}}
      }

      {changes, _meta} = Effects.apply(player, [{:ghostwork_node, "relay", {:bank_layer, 1}}])

      assert changes.ghostwork_state == %{
               "nodes" => %{"relay" => %{"banked_layer" => 1, "hardened" => true}}
             }
    end

    test "clears a hardened flag while preserving the banked layer" do
      player = %Player{
        ghostwork_state: %{"nodes" => %{"relay" => %{"banked_layer" => 1, "hardened" => true}}}
      }

      {changes, _meta} = Effects.apply(player, [{:ghostwork_node, "relay", :clear_hardened}])

      assert changes.ghostwork_state == %{
               "nodes" => %{"relay" => %{"banked_layer" => 1, "hardened" => false}}
             }
    end

    test "mastery and node effects accumulate without clobbering each other" do
      player = %Player{ghostwork_state: %{}}

      {changes, _meta} =
        Effects.apply(player, [
          {:ghostwork_mastery, "ice_maintenance", 1},
          {:ghostwork_node, "relay", {:bank_layer, 0}}
        ])

      assert changes.ghostwork_state == %{
               "mastery" => %{"ice_maintenance" => 1},
               "nodes" => %{"relay" => %{"banked_layer" => 0, "hardened" => false}}
             }
    end
  end

  describe "apply/2 - :set" do
    test "sets a field to a literal value" do
      player = %Player{current_offer_key: "old_key"}

      {changes, _meta} = Effects.apply(player, [{:set, :current_offer_key, nil}])

      assert changes.current_offer_key == nil
    end
  end

  describe "apply/2 - :deltas" do
    test "reports the requested delta when no clamping occurs" do
      player = %Player{scrip: 10, cred: 2, heat: 0}

      {_changes, meta} = Effects.apply(player, [{:scrip, 5}, {:cred, 3}, {:heat, 10}])

      assert meta.deltas == %{scrip: 5, cred: 3, heat: 10}
    end

    test "reports the clamped delta, not the requested one, when scrip would go negative" do
      player = %Player{scrip: 5}

      {_changes, meta} = Effects.apply(player, [{:scrip, -20}])

      assert meta.deltas == %{scrip: -5}
    end

    test "reports the post-discharge heat delta when a heat event fires" do
      player = %Player{heat: 60, scrip: 100, cred: 20}

      {changes, meta} = Effects.apply(player, [{:heat, 30}])

      assert meta.deltas.heat == changes.heat - 60
      assert meta.deltas.scrip == changes.scrip - 100
      assert meta.deltas.cred == changes.cred - 20
    end

    test "omits fields that weren't touched by any effect" do
      player = %Player{scrip: 10}

      {_changes, meta} = Effects.apply(player, [{:scrip, 5}])

      assert meta.deltas == %{scrip: 5}
    end
  end

  describe "apply/2 - ordering and folding" do
    test "an empty effect list returns no changes and default meta" do
      player = %Player{scrip: 10}

      assert Effects.apply(player, []) ==
               {%{}, %{heat_event: nil, loyalty_signals: [], deltas: %{}}}
    end

    test "applies effects in list order, folding prepended heat-event effects ahead of later ones" do
      player = %Player{heat: 60, scrip: 100, cred: 20, held_item_key: "some_item"}

      {changes, meta} =
        Effects.apply(player, [
          {:heat, 30},
          {:scrip, 15},
          {:cred, 3},
          {:set, :held_item_key, nil}
        ])

      assert meta.heat_event.band == :high
      assert changes.heat == 85
      assert changes.scrip == max(100 + 15 - meta.heat_event.scrip_loss, 0)
      assert changes.cred == max(20 + 3 - meta.heat_event.cred_loss, 0)
      assert changes.held_item_key == nil
    end
  end

  describe "apply/2 - :discover_location" do
    test "appends a new key to a player's discovered_locations" do
      player = %Player{discovered_locations: []}

      {changes, _meta} = Effects.apply(player, [{:discover_location, "shunt9_bazaar"}])

      assert changes.discovered_locations == ["shunt9_bazaar"]
    end

    test "does not duplicate a key already present in discovered_locations" do
      player = %Player{discovered_locations: ["shunt9_bazaar"]}

      {changes, _meta} = Effects.apply(player, [{:discover_location, "shunt9_bazaar"}])

      assert changes.discovered_locations == ["shunt9_bazaar"]
    end
  end

  describe "apply/2 - :modify_rep" do
    test "creates the npc and dimension entries when absent" do
      player = %Player{reputation: %{}}

      {changes, _meta} = Effects.apply(player, [{:modify_rep, "juno", :trust, 10}])

      assert changes.reputation == %{"juno" => %{trust: 10}}
    end

    test "increments an existing dimension without touching others" do
      player = %Player{reputation: %{"juno" => %{trust: 10, favors: 2}}}

      {changes, _meta} = Effects.apply(player, [{:modify_rep, "juno", :trust, 5}])

      assert changes.reputation == %{"juno" => %{trust: 15, favors: 2}}
    end

    test "clamps a dimension at 0 when a delta would take it negative" do
      player = %Player{reputation: %{"juno" => %{favors: 1}}}

      {changes, _meta} = Effects.apply(player, [{:modify_rep, "juno", :favors, -5}])

      assert changes.reputation == %{"juno" => %{favors: 0}}
    end

    test "accumulates multiple modify_rep effects across npcs and dimensions" do
      player = %Player{reputation: %{}}

      {changes, _meta} =
        Effects.apply(player, [
          {:modify_rep, "juno", :trust, 10},
          {:modify_rep, "juno", :favors, 1},
          {:modify_rep, "rose", :trust, 5}
        ])

      assert changes.reputation == %{
               "juno" => %{trust: 10, favors: 1},
               "rose" => %{trust: 5}
             }
    end
  end

  describe "apply/2 - :knowledge" do
    test "appends a new key to a player's knowledge" do
      player = %Player{knowledge: []}

      {changes, _meta} = Effects.apply(player, [{:knowledge, "juno_secret_supplier"}])

      assert changes.knowledge == ["juno_secret_supplier"]
    end

    test "does not duplicate a key already present in knowledge" do
      player = %Player{knowledge: ["juno_secret_supplier"]}

      {changes, _meta} = Effects.apply(player, [{:knowledge, "juno_secret_supplier"}])

      assert changes.knowledge == ["juno_secret_supplier"]
    end
  end

  describe "apply/2 - :contact" do
    test "appends a new key to a player's contacts" do
      player = %Player{contacts: []}

      {changes, _meta} = Effects.apply(player, [{:contact, "rose_broker"}])

      assert changes.contacts == ["rose_broker"]
    end

    test "does not duplicate a key already present in contacts" do
      player = %Player{contacts: ["rose_broker"]}

      {changes, _meta} = Effects.apply(player, [{:contact, "rose_broker"}])

      assert changes.contacts == ["rose_broker"]
    end
  end

  describe "apply/2 - :rumor" do
    test "appends a new key to a player's rumors" do
      player = %Player{rumors: []}

      {changes, _meta} = Effects.apply(player, [{:rumor, "juno_supplier"}])

      assert changes.rumors == ["juno_supplier"]
    end

    test "does not duplicate a key already present in rumors" do
      player = %Player{rumors: ["juno_supplier"]}

      {changes, _meta} = Effects.apply(player, [{:rumor, "juno_supplier"}])

      assert changes.rumors == ["juno_supplier"]
    end
  end
end
