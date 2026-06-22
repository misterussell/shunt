defmodule Shunt.EffectsTest do
  use ExUnit.Case, async: true

  # TODO: per priv/docs/architecture.md Section 2, write pure unit tests for
  # Shunt.Effects.apply/2 (lib/shunt/effects.ex) once implemented, covering:
  #   - {:scrip, delta}, {:cred, delta} - clamp at 0, never negative
  #   - {:heat, delta} - clamps via Shunt.Heat.clamp/1; when the resulting band crosses
  #     upward into a new Shunt.Heat band, prepends the band's fired event's
  #     {:scrip, -event.scrip_loss} and {:cred, -event.cred_loss} effects to the remaining
  #     worklist and records the event in the returned meta (e.g. under :heat_event); no band
  #     crossing -> meta's heat_event is nil
  #   - {:inventory, key, delta} - Map.update(inventory, key, delta, &(&1 + delta)), never
  #     goes negative for delta < 0 (only reachable today with sufficient stock, per each
  #     resolver's own precondition checks)
  #   - {:npc_loyalty, npc_key, delta} - clamps via Shunt.Npcs.Loyalty.clamp/1; detects a
  #     band transition (Shunt.Npcs.Loyalty.band_for/1 old vs new) and a first-meeting
  #     transition (old value was the unmet sentinel), recording both in meta, and calls
  #     Shunt.Npcs.Signals.npc_met/1 / loyalty_band_changed/3 - this is the only Effects
  #     case allowed to reach outside the player struct, since those are fire-and-forget
  #     PubSub broadcasts, not persistence
  #   - {:set, field, value} - Map.put(player, field, value)
  #   - apply/2 takes a plain %Shunt.Players.Player{} struct (no Repo) and a list of effects,
  #     returns {updated_player, meta}; folding behavior - effects apply in list order, and
  #     a {:heat, _} effect's prepended event-loss effects must also fold against the same
  #     accumulator before any effects originally after the {:heat, _} effect
  describe "apply/2" do
  end
end
