defmodule Shunt.District do
  @moduledoc """
  Derived district world-state. A pure read-side over existing player state: facts are
  computed on demand from priv/content/districts defs via Shunt.Requirements, never
  persisted. Repairs (and other facts) are the single source of truth; district facts
  cannot drift from them.

  Authoring constraint: a fact's derivation rule requirements must NOT contain a
  `{:district, ...}` requirement. Doing so would recurse (Requirements.met? -> fact_meets?/5
  -> derive -> Requirements.met?) with no cycle guard. Derive facts from primitive
  requirements ({:infra_state, ...}, {:knows, ...}, etc.) only.
  """

  alias Shunt.Content
  alias Shunt.Requirements

  def get!(id), do: Content.fetch!(:districts, id)

  @doc """
  The derived value of `fact_name` for `player` in district `district_id`. For an `:ordinal`
  fact, returns the level of the first rule (top-down) whose requirements are met, else the
  rule's `default`. Raises on an unknown district/fact — this is the direct read API, not the
  gating path; `fact_meets?/5` is what content requirements use and it degrades instead.
  """
  def fact(player, district_id, fact_name) do
    case fetch_rule(district_id, fact_name) do
      {:ok, rule} -> derive(player, rule)
      :error -> raise "unknown district fact: #{district_id}/#{fact_name}"
    end
  end

  @doc """
  Whether the derived ordinal `fact_name` satisfies `op` against `target`, comparing by
  position in the fact's `:levels` list (ascending). `op` is `:>=` or `:<`. This is what the
  `{:district, district_id, fact, op, target}` requirement delegates to.

  Degrades to `false` (unmet) on any unknown content — unknown district, fact, level, or op —
  rather than crashing the render, mirroring how `{:infra_state, ...}` degrades on an unknown
  repairable. A content typo silently fails the gate instead of taking down the page.
  """
  def fact_meets?(player, district_id, fact_name, op, target) do
    case fetch_rule(district_id, fact_name) do
      {:ok, rule} ->
        current_index = Enum.find_index(rule.levels, &(&1 == derive(player, rule)))
        target_index = Enum.find_index(rule.levels, &(&1 == target))
        compare(op, current_index, target_index)

      :error ->
        false
    end
  end

  defp fetch_rule(district_id, fact_name) do
    with {:ok, def} <- Content.fetch(:districts, district_id),
         {:ok, rule} <- Map.fetch(def.facts, fact_name) do
      {:ok, rule}
    else
      _ -> :error
    end
  end

  defp derive(player, %{kind: :ordinal, rules: rules, default: default}) do
    Enum.find_value(rules, default, fn {level, requirements} ->
      if Requirements.met?(player, requirements), do: level
    end)
  end

  # nil index = a level/target not present in :levels; unknown op = an unsupported comparison.
  # Both are content errors that degrade to unmet rather than crash.
  defp compare(_op, nil, _target), do: false
  defp compare(_op, _current, nil), do: false
  defp compare(:>=, current, target), do: current >= target
  defp compare(:<, current, target), do: current < target
  defp compare(_op, _current, _target), do: false
end
