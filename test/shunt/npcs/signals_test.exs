defmodule Shunt.Npcs.SignalsTest do
  use ExUnit.Case, async: true

  # TODO: add `alias Shunt.Npcs.Signals` once the describe block below is implemented.

  # TODO: describe "subscribe/0 and broadcasts" do
  #   setup: Signals.subscribe()
  #   test "npc_met/1 broadcasts {:npc_met, npc_key} to subscribers":
  #     Signals.npc_met("mother_graft")
  #     assert_receive {:npc_met, "mother_graft"}
  #   test "loyalty_band_changed/3 broadcasts {:loyalty_band_changed, npc_key, old_band, new_band}":
  #     Signals.loyalty_band_changed("mother_graft", :neutral, :favored)
  #     assert_receive {:loyalty_band_changed, "mother_graft", :neutral, :favored}
end
