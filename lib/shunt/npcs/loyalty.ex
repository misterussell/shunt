defmodule Shunt.Npcs.Loyalty do
  @moduledoc false

  @start_value 50
  @hostile_max 24
  @favored_min 75
  @hostile_failure_chance 0.30

  def clamp(loyalty), do: loyalty |> max(0) |> min(100)

  def band_for(loyalty) when loyalty >= @favored_min, do: :favored
  def band_for(loyalty) when loyalty <= @hostile_max, do: :hostile
  def band_for(_loyalty), do: :neutral

  def value(player, npc_key), do: Map.get(player.npc_loyalty, npc_key, @start_value)

  def met?(player, npc_key), do: Map.has_key?(player.npc_loyalty, npc_key)

  def roll_reliable?(player, npc_key) do
    case band_for(value(player, npc_key)) do
      :hostile -> :rand.uniform() > @hostile_failure_chance
      _ -> true
    end
  end

  def price_multiplier(player, npc_key) do
    case band_for(value(player, npc_key)) do
      :hostile -> 0.8
      :neutral -> 1.0
      :favored -> 1.2
    end
  end

  def cost_multiplier(player, npc_key) do
    case band_for(value(player, npc_key)) do
      :hostile -> 1.25
      :neutral -> 1.0
      :favored -> 0.8
    end
  end
end
