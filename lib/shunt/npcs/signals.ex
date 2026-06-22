defmodule Shunt.Npcs.Signals do
  @moduledoc false

  # TODO: Define @topic "npc_signals" — single shared topic. The app is single-player today
  # (Shunt.Players.get_player!/0 does Repo.one!(Player)), so no per-player scoping is needed
  # yet; revisit if/when multiple players exist.

  # TODO: def subscribe, do: Phoenix.PubSub.subscribe(Shunt.PubSub, @topic)
  # Called once from ShuntWeb.DashboardLive.mount/3, only when connected?(socket) (mirror how
  # other LiveViews in this app gate subscriptions on connected?/1, if any do; otherwise it's
  # safe to call unconditionally since subscribe/0 is idempotent per-process).

  # TODO: def npc_met(npc_key) do
  #   Phoenix.PubSub.broadcast(Shunt.PubSub, @topic, {:npc_met, npc_key})
  # end
  # Called by Shunt.Npcs trade-action functions the first time a player interacts with
  # npc_key (i.e. Shunt.Npcs.Loyalty.record_interaction/2 returned met_for_first_time: true).

  # TODO: def loyalty_band_changed(npc_key, old_band, new_band) do
  #   Phoenix.PubSub.broadcast(Shunt.PubSub, @topic, {:loyalty_band_changed, npc_key, old_band, new_band})
  # end
  # Called by Shunt.Npcs trade-action functions only when old_band != new_band, per
  # Shunt.Npcs.Loyalty.record_interaction/2's returned :old_band/:new_band.
end
