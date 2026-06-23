defmodule Shunt.Movement do
  @moduledoc false

  alias Shunt.Players.Player
  alias Shunt.World

  def can_move?(%Player{} = player, destination) do
    World.connected?(player.location_id, destination)
  end

  def move(%Player{} = player, destination) do
    if can_move?(player, destination) do
      {:ok,
       [
         {:set, :location_id, destination},
         {:discover_location, destination}
       ], %{narrative: narrative_for(player.location_id, destination)}}
    else
      {:error, :not_connected}
    end
  end

  defp narrative_for(from, to) do
    from_location = World.get_location(from)
    to_location = World.get_location(to)

    "You leave #{from_location.name}. #{to_location.short_description}"
  end
end
