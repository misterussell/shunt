defmodule Shunt.World do
  @moduledoc false

  alias Shunt.Content

  def get_location(key), do: Content.fetch!(:locations, key)

  def exits(location_key), do: get_location(location_key).exits

  def connected?(from, to), do: to in Enum.map(exits(from), & &1.to)
end
