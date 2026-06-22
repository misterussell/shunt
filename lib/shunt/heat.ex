defmodule Shunt.Heat do
  @moduledoc false

  alias Shunt.Heat.Catalog

  @low_threshold 30
  @medium_threshold 60
  @high_threshold 85

  @band_rank %{none: 0, low: 1, medium: 2, high: 3}

  def clamp(heat), do: heat |> max(0) |> min(100)

  def band_for(heat) when heat >= @high_threshold, do: :high
  def band_for(heat) when heat >= @medium_threshold, do: :medium
  def band_for(heat) when heat >= @low_threshold, do: :low
  def band_for(_heat), do: :none

  def resolve(old_heat, new_heat) do
    old_band = band_for(old_heat)
    new_band = band_for(new_heat)

    if @band_rank[new_band] > @band_rank[old_band] do
      event = Enum.random(Catalog.events_for_band(new_band))
      {threshold_for(new_band) - 5, event}
    else
      {new_heat, nil}
    end
  end

  defp threshold_for(:low), do: @low_threshold
  defp threshold_for(:medium), do: @medium_threshold
  defp threshold_for(:high), do: @high_threshold
end
