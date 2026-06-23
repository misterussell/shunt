defmodule Shunt.World do
  @moduledoc false

  # TODO: implement this module mirroring Shunt.Npcs (lib/shunt/npcs.ex:13-19),
  # which is just thin wrappers over Shunt.Content:
  #
  #   def get_location(key), do: Content.fetch!(:locations, key)
  #   def exits(location_key), do: get_location(location_key).exits
  #   def connected?(from, to), do: to in Enum.map(exits(from), & &1.to)
  #
  # Requires {:locations, "priv/content/locations"} to be added to
  # Shunt.Content.Store.@sources (see TODO in lib/shunt/content/store.ex) and at
  # least 5-8 location content files to exist under priv/content/locations/*.exs.
  #
  # Create those location files now as part of this TODO, following the shape in
  # priv/docs/SHUNT_location_and_movement.md ("Content Definitions" section):
  # %{key, name, short_description, description, tags, graph_position, exits: [%{to, requirements: []}]}.
  # Use this starter graph (every line is two one-directional exits, written into
  # both locations' files):
  #
  #   shunt9_power_relay
  #          |
  #   shunt9_scrap_yard -- shunt9_bazaar -- shunt9_food_stalls
  #                              |
  #                     shunt9_burned_platform
  #                              |
  #                  shunt9_maintenance_tunnel
  #                              |
  #                     shunt9_player_squat
  #
  # `shunt9_player_squat` is the starting location_id set on Shunt.Players.Player.
end
