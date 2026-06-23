defmodule Shunt.World do
  @moduledoc false

  alias Shunt.Content

  def get_location(key), do: Content.fetch!(:locations, key)

  def exits(location_key), do: get_location(location_key).exits

  def connected?(from, to), do: to in Enum.map(exits(from), & &1.to)

  # TODO: add `all_locations/0` returning `Content.all(:locations)` (mirrors get_location/1's
  # Content.fetch!/2 call). Needed by ShuntWeb.Components.MapGraph to render every location on
  # the map, not just the current one's exits.
end
