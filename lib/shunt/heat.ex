defmodule Shunt.Heat do
  @moduledoc false

  alias Shunt.Heat.Catalog

  @low_threshold 30
  @medium_threshold 60
  @high_threshold 85

  # TODO: def clamp(heat), do: heat |> max(0) |> min(100)
  # Consolidates the clamp_heat/1 private helper currently duplicated in
  # Shunt.Players, Shunt.Fencing, and Shunt.Crafting. Remove those three copies
  # and call Shunt.Heat.clamp/1 from each call site instead.

  # TODO: def band_for(heat) returning :none | :low | :medium | :high based on
  # @low_threshold/@medium_threshold/@high_threshold (heat >= @high_threshold -> :high,
  # >= @medium_threshold -> :medium, >= @low_threshold -> :low, else :none).

  # TODO: def resolve(old_heat, new_heat) :: {final_heat :: integer, event :: map | nil}
  # 1. new_heat must already be clamp/1'd by the caller before calling resolve/2.
  # 2. Compare band_for(old_heat) to band_for(new_heat) using rank order
  #    :none < :low < :medium < :high.
  # 3. If band_for(new_heat) did NOT increase in rank over band_for(old_heat), return
  #    {new_heat, nil} (covers decreases via Players.lay_low and same-band increases).
  # 4. If it did increase, pick `event = Enum.random(Catalog.events_for_band(band_for(new_heat)))`
  #    and return {threshold_for_band - 5, event}, where threshold_for_band is
  #    @low_threshold/@medium_threshold/@high_threshold matching the new band (e.g. crossing
  #    into :medium at heat 60+ returns final_heat 55).
end
