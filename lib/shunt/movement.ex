defmodule Shunt.Movement do
  @moduledoc false

  # TODO: implement following the exact shape of Shunt.Players.lay_low/1
  # (lib/shunt/players.ex:46-52) and Shunt.Npcs.flesh_tithe/1 (lib/shunt/npcs.ex:25-45):
  #
  #   def can_move?(%Player{} = player, destination) do
  #     World.connected?(player.location_id, destination)
  #   end
  #
  #   def move(%Player{} = player, destination) do
  #     if can_move?(player, destination) do
  #       {:ok,
  #        [
  #          {:set, :location_id, destination},
  #          {:discover_location, destination}
  #        ],
  #        %{narrative: narrative_for(player.location_id, destination)}}
  #     else
  #       {:error, :not_connected}
  #     end
  #   end
  #
  # `requirements` checks are a no-op through Phase 4 (every exit ships with
  # requirements: [] — see priv/docs/SHUNT_location_and_movement.md). Narrative
  # text can be a simple "You leave {from.name}. {to.short_description}" built
  # from Shunt.World.get_location/1 on both ends — exact wording is not
  # load-bearing for tests, just non-empty and sourced from real location data.
  #
  # Dispatched from LiveView exactly like every other action (Phase 2, not here):
  #   Players.dispatch(player_id, &Movement.move(&1, destination))
end
