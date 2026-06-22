defmodule Shunt.Heat.Catalog do
  @moduledoc false

  alias Shunt.Content

  def events_for_band(band), do: Enum.filter(Content.all(:heat_events), &(&1.band == band))

  def fetch!(key), do: Content.fetch!(:heat_events, key)
end
