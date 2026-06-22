defmodule Shunt.Npcs.Signals do
  @moduledoc false

  @topic "npc_signals"

  def subscribe, do: Phoenix.PubSub.subscribe(Shunt.PubSub, @topic)

  def npc_met(npc_key) do
    Phoenix.PubSub.broadcast(Shunt.PubSub, @topic, {:npc_met, npc_key})
  end

  def loyalty_band_changed(npc_key, old_band, new_band) do
    Phoenix.PubSub.broadcast(Shunt.PubSub, @topic, {:loyalty_band_changed, npc_key, old_band, new_band})
  end
end
