defmodule Shunt.Npcs.SignalsTest do
  use ExUnit.Case, async: true

  alias Shunt.Npcs.Signals

  describe "subscribe/0 and broadcasts" do
    setup do
      Signals.subscribe()
      :ok
    end

    test "npc_met/1 broadcasts {:npc_met, npc_key} to subscribers" do
      Signals.npc_met("mother_graft")
      assert_receive {:npc_met, "mother_graft"}
    end

    test "loyalty_band_changed/3 broadcasts {:loyalty_band_changed, npc_key, old_band, new_band}" do
      Signals.loyalty_band_changed("mother_graft", :neutral, :favored)
      assert_receive {:loyalty_band_changed, "mother_graft", :neutral, :favored}
    end
  end
end
