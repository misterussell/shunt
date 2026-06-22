defmodule Shunt.Players.ServerTest do
  use Shunt.DataCase

  # TODO: per priv/docs/architecture.md Section 1, write integration tests for
  # Shunt.Players.Server (lib/shunt/players/server.ex) and Shunt.Players.lookup_or_start/1,
  # dispatch/2, current/1 (lib/shunt/players.ex) once implemented, covering:
  #   - lookup_or_start/1 starts exactly one Shunt.Players.Server per player_id under
  #     Shunt.Players.Supervisor, registered via Shunt.Players.Registry; calling it twice
  #     with the same player_id returns the same pid (use Registry.lookup/2 to assert)
  #   - current/1 returns {:ok, %Player{}} matching the row in Postgres
  #   - dispatch/2 with a resolver returning {:ok, effects}: applies the effects via
  #     Shunt.Effects.apply/2, persists the result via Repo.update, and returns
  #     {:ok, updated_player, meta}; a subsequent current/1 call reflects the persisted state
  #   - dispatch/2 with a resolver returning {:error, reason}: returns {:error, reason}
  #     unchanged, performs no Repo.update, and leaves the server's in-memory player
  #     untouched (assert via a follow-up current/1)
  #   - dispatch/2 against a resolver that fires a Shunt.Heat band-crossing event or an
  #     :npc_loyalty band transition: asserts Shunt.Npcs.Signals broadcasts land (subscribe
  #     via Shunt.Npcs.Signals.subscribe/0 in the test process before dispatching)
  #   - a Repo.update failure during dispatch/2 does not crash the server process and leaves
  #     it usable for a subsequent dispatch/2 call (exact recovery behavior to be decided
  #     when lib/shunt/players/server.ex's handle_call TODO is implemented)
  describe "lookup_or_start/1 and dispatch/2" do
  end
end
