defmodule Shunt.World do
  @moduledoc false

  alias Shunt.Content

  def get_location(id), do: Content.fetch!(:locations, id)

  def exits(location_id), do: get_location(location_id).exits

  def connected?(from, to), do: to in Enum.map(exits(from), & &1.to)

  def all_locations, do: Content.all(:locations)
end
