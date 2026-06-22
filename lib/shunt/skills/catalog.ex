defmodule Shunt.Skills.Catalog do
  @moduledoc false

  alias Shunt.Content

  def trees, do: Content.fetch!(:skill_trees, :skill_trees)

  def fetch!(key) do
    Enum.find(trees(), &(&1.key == key)) ||
      raise "unknown skill tree key: #{inspect(key)}"
  end

  # Capped at 0/1 for now — tiers 2-5's advancement mechanic is undesigned until a future
  # sprint item.
  def current_tier(player, tree) do
    if Map.get(player.inventory, tree.tool_key, 0) > 0, do: 1, else: 0
  end
end
