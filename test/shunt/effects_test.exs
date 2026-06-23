defmodule Shunt.EffectsTest do
  use ExUnit.Case, async: true

  alias Shunt.Effects
  alias Shunt.Players.Player

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
      assert changes.heat == 80
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
      assert changes.heat == 80
      assert changes.scrip == max(100 + 15 - meta.heat_event.scrip_loss, 0)
      assert changes.cred == max(20 + 3 - meta.heat_event.cred_loss, 0)
      assert changes.held_item_key == nil
    end
  end
end
