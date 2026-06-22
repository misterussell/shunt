defmodule Shunt.HeatTest do
  use ExUnit.Case, async: true

  # TODO: test Shunt.Heat.clamp/1 clamps to the 0..100 range (negative -> 0, >100 -> 100,
  # in-range value passes through unchanged).

  # TODO: test Shunt.Heat.band_for/1 returns :none below 30, :low for 30..59, :medium for
  # 60..84, :high for 85..100.

  # TODO: test Shunt.Heat.resolve/2 returns {new_heat, nil} when band_for(old_heat) ==
  # band_for(new_heat) (no crossing) and when new_heat's band is lower-or-equal rank than
  # old_heat's band (e.g. a decrease via lay_low).

  # TODO: test Shunt.Heat.resolve/2 returns {threshold - 5, event} when crossing upward into
  # :low (old_heat 10, new_heat 35 -> {25, event} with event.band == :low), into :medium
  # (old_heat 40, new_heat 65 -> {55, event} with event.band == :medium), and into :high
  # (old_heat 70, new_heat 90 -> {80, event} with event.band == :high).
end
