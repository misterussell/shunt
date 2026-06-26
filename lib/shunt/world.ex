defmodule Shunt.World do
  @moduledoc false

  alias Shunt.Content

  def get_location(id), do: Content.fetch!(:locations, id)

  def exits(location_id), do: get_location(location_id).exits

  def connected?(from, to), do: to in Enum.map(exits(from), & &1.to)

  def all_locations, do: Content.all(:locations)

  # TODO: Add accessible_locations/1 (player) returning the player's view of the
  # world for the map: only locations whose own requirements are met
  # (Shunt.Requirements.met?/2 on Map.get(loc, :requirements, [])), and with each
  # location's :exits filtered to exits whose requirements are met. This keeps
  # gated nodes/exits from rendering at all (not even as "???"). MapGraph and
  # MovementLive consume this instead of all_locations/0; the map component needs
  # no change because it derives everything from the locations + exits passed in.

  # TODO: Add available_exits/2 (player, location_id) returning the location's
  # exits whose requirements are met. Movement.can_move?/2 uses this.

  # TODO: Add points_of_interest/2 (player, location_id) returning the location's
  # event ids (Map.get(loc, :events, [])) whose event requirements are met, via
  # Shunt.Requirements.met?/2 + Shunt.Events.get!/1. MovementLive renders these
  # instead of the raw @location.events list.
end
