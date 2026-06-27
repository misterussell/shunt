defmodule Shunt.Repair do
  @moduledoc """
  Repair economy context for Street Alchemy. Pure functions over player state +
  :repairables content. Returns effect lists for Players.dispatch and explicit
  result metadata (never requires the caller to diff before/after state).
  """

  alias Shunt.Content
  alias Shunt.Players.Player
  alias Shunt.Requirements

  def get!(id), do: Content.fetch!(:repairables, id)

  @doc "The repairable's current state for this player, falling back to its initial_state."
  def state(%Player{} = player, repairable_id) do
    Map.get(player.infrastructure, repairable_id) || get!(repairable_id).initial_state
  end

  @doc "Repairables anchored at `location_id`, for surfacing as points of interest."
  def at_location(%Player{}, location_id) do
    Enum.filter(Content.all(:repairables), &(&1.location_id == location_id))
  end

  @doc """
  The diagnosis text the player can read: the deepest inspect tier reachable while each
  successive tier's requirements are met (cumulative). Tier 0 has no requirements.
  """
  def inspect(%Player{} = player, repairable) do
    repairable.inspect_tiers
    |> Enum.take_while(&Requirements.met?(player, &1.requirements))
    |> List.last()
    |> Map.fetch!(:text)
  end

  @doc """
  Solutions the player may currently apply: valid from the current state, with their
  requirements met and every consumed material on hand.
  """
  def available_solutions(%Player{} = player, repairable) do
    current = state(player, repairable.id)
    Enum.filter(repairable.solutions, &applicable?(player, current, &1))
  end

  @doc """
  Applies `solution_id` to the repairable. Returns `{:ok, effects, meta}` where effects
  spend the consumed materials, set the new state, and append the solution's own effects;
  meta reports `%{from:, to:, outcome_text:}`. Errors: `:invalid_solution`, `:wrong_state`,
  `:insufficient_materials`.
  """
  def repair(%Player{} = player, repairable_id, solution_id) do
    repairable = get!(repairable_id)
    current = state(player, repairable_id)

    case Enum.find(repairable.solutions, &(&1.id == solution_id)) do
      nil ->
        {:error, :invalid_solution}

      solution ->
        cond do
          current not in solution.from ->
            {:error, :wrong_state}

          not (Requirements.met?(player, solution.requirements) and
                   materials?(player, solution.consumes)) ->
            {:error, :insufficient_materials}

          true ->
            consume_effects = for {key, qty} <- solution.consumes, do: {:inventory, key, -qty}

            effects =
              consume_effects ++
                [{:infrastructure, repairable_id, solution.result_state}] ++ solution.effects

            {:ok, effects,
             %{from: current, to: solution.result_state, outcome_text: solution.outcome_text}}
        end
    end
  end

  defp applicable?(player, current, solution) do
    current in solution.from and Requirements.met?(player, solution.requirements) and
      materials?(player, solution.consumes)
  end

  defp materials?(player, consumes) do
    Enum.all?(consumes, fn {key, qty} -> Map.get(player.inventory, key, 0) >= qty end)
  end
end
