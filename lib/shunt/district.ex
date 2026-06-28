defmodule Shunt.District do
  @moduledoc """
  Derived district world-state. A pure read-side over existing player state: facts are
  computed on demand from priv/content/districts defs via Shunt.Requirements, never
  persisted. Repairs (and other facts) are the single source of truth; district facts
  cannot drift from them.
  """

  alias Shunt.Content
  alias Shunt.Requirements

  def get!(id), do: Content.fetch!(:districts, id)

  @doc """
  The derived value of `fact_name` for `player` in district `district_id`. For an `:ordinal`
  fact, returns the level of the first rule (top-down) whose requirements are met, else the
  rule's `default`.
  """
  def fact(player, district_id, fact_name) do
    derive(player, rule(district_id, fact_name))
  end

  defp rule(district_id, fact_name) do
    district_id |> get!() |> Map.fetch!(:facts) |> Map.fetch!(fact_name)
  end

  defp derive(player, %{kind: :ordinal, rules: rules, default: default}) do
    Enum.find_value(rules, default, fn {level, requirements} ->
      if Requirements.met?(player, requirements), do: level
    end)
  end

  @doc """
  Whether the derived ordinal `fact_name` satisfies `op` against `target`, comparing by
  position in the fact's `:levels` list (ascending). `op` is `:>=` or `:<`. This is what the
  `{:district, district_id, fact, op, target}` requirement delegates to.
  """
  def fact_meets?(player, district_id, fact_name, op, target) do
    rule = rule(district_id, fact_name)
    levels = rule.levels
    current_index = Enum.find_index(levels, &(&1 == derive(player, rule)))
    target_index = Enum.find_index(levels, &(&1 == target))
    compare(op, current_index, target_index)
  end

  defp compare(:>=, current, target), do: current >= target
  defp compare(:<, current, target), do: current < target
end
