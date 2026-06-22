defmodule Shunt.Effects do
  @moduledoc false

  # TODO: implement apply(player, effects) :: {changes, meta} per priv/docs/architecture.md
  # Section 2. `effects` is a list of:
  #   {:scrip, delta} - clamp the resulting scrip to >= 0
  #   {:cred, delta} - clamp the resulting cred to >= 0
  #   {:heat, delta} - clamp player.heat + delta to 0..100 via Shunt.Heat.clamp/1, then call
  #     Shunt.Heat.resolve(player.heat, clamped_heat). If it returns {final_heat, event} with
  #     a non-nil event, use final_heat as the heat result and prepend
  #     {:scrip, -event.scrip_loss} and {:cred, -event.cred_loss} onto the remaining worklist
  #     before continuing the reduce. Record event in meta.heat_event (nil if no event fired).
  #   {:inventory, key, delta} - Map.update(player.inventory, key, delta, &(&1 + delta)),
  #     never let the result go below 0
  #   {:npc_loyalty, npc_key, delta} - read the current value via
  #     Shunt.Npcs.Loyalty.value(player, npc_key) (defaults to 50 when unset), compute
  #     old_band = Shunt.Npcs.Loyalty.band_for(old_value), apply delta and
  #     Shunt.Npcs.Loyalty.clamp/1, compute new_band the same way. Record
  #     {:npc_met, npc_key} in meta.loyalty_signals when player.npc_loyalty had no entry for
  #     npc_key before this effect, and {:loyalty_band_changed, npc_key, old_band, new_band}
  #     when old_band != new_band.
  #   {:set, field, value} - Map.put(changes, field, value)
  # Return {changes :: map(), meta :: %{heat_event: map() | nil, loyalty_signals: list()}}.
  # `changes` accumulates into one map suitable for Ecto.Changeset.change(player, changes).
  # This function must stay pure - no Repo, no PubSub, no GenServer calls. Shunt.Players.Server
  # is the only caller, and it owns persistence + signal emission after Effects.apply/2 returns.
end
