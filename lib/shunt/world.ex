defmodule Shunt.World do
  @moduledoc false

  alias Shunt.Content
  alias Shunt.Events
  alias Shunt.Requirements

  def get_location(id), do: Content.fetch!(:locations, id)

  @doc """
  The description text shown for `location`: if a repairable here is in a state with a
  matching `state_descriptions` override (first match, declared order), that text;
  otherwise the location's base description. Lets repairs visibly change the world.
  """
  def effective_description(player, location) do
    player
    |> Shunt.Repair.at_location(location.id)
    |> Enum.find_value(fn repairable ->
      Map.get(repairable.state_descriptions, Shunt.Repair.state(player, repairable.id))
    end)
    |> Kernel.||(location.description)
  end

  def exits(location_id), do: get_location(location_id).exits

  def connected?(from, to), do: to in Enum.map(exits(from), & &1.to)

  def all_locations, do: Content.all(:locations)

  @doc "Whether a location's own requirements are met by the player."
  def location_accessible?(player, location_id) do
    Requirements.met?(player, Map.get(get_location(location_id), :requirements, []))
  end

  @doc """
  Exits leaving `location_id` that the player may take: the exit's own
  requirements are met and the destination location is itself accessible.
  """
  def available_exits(player, location_id) do
    location_id
    |> exits()
    |> Enum.filter(fn exit ->
      Requirements.met?(player, exit.requirements) and location_accessible?(player, exit.to)
    end)
  end

  @doc """
  The player's view of the world for the map: locations reachable from the
  current location through available exits, each with its :exits narrowed to the
  available ones. Requirement-gated locations and exits never appear.
  """
  def accessible_locations(player) do
    reachable = reachable_ids(player)

    reachable
    |> Enum.map(&get_location/1)
    |> Enum.map(fn location ->
      Map.put(location, :exits, available_exits(player, location.id))
    end)
  end

  @doc """
  Event ids attached to `location_id` whose event requirements are met — the
  points of interest to surface for the player.
  """
  def points_of_interest(player, location_id) do
    location_id
    |> get_location()
    |> Map.get(:events, [])
    |> Enum.filter(fn event_id ->
      Requirements.met?(player, Events.get!(event_id).requirements)
    end)
  end

  defp reachable_ids(player) do
    start = player.location_id
    bfs([start], MapSet.new([start]), player)
  end

  defp bfs([], visited, _player), do: MapSet.to_list(visited)

  defp bfs([id | queue], visited, player) do
    neighbors =
      player
      |> available_exits(id)
      |> Enum.map(& &1.to)
      |> Enum.reject(&MapSet.member?(visited, &1))

    visited = Enum.reduce(neighbors, visited, &MapSet.put(&2, &1))
    bfs(queue ++ neighbors, visited, player)
  end
end
