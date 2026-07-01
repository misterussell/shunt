defmodule Shunt.Requirements do
  @moduledoc """
  Evaluates content-gating requirements against player state for The Web.

  Used to hide-entirely any location, exit, or POI event whose requirements are
  not met. See priv/docs/SHUNT_the_web_v1.md.
  """

  alias Shunt.Players.Player

  def met?(%Player{} = player, requirements) do
    Enum.all?(requirements, &check(player, &1))
  end

  @doc """
  The deepest tier whose requirements are met, scanning a list of `%{requirements: [...]}` maps
  top-down and stopping at the first unmet tier (tiers are treated as cumulative). Returns the
  tier map, or nil if the first tier is already unmet or the list is empty. Shared selector for
  `Shunt.Repair.inspect/2` (gear-gated diagnosis tiers) and `Shunt.World.atmosphere/2` (district
  ambient lines); each caller handles the nil case itself.
  """
  def deepest_met_tier(%Player{} = player, tiers) do
    tiers
    |> Enum.take_while(&met?(player, &1.requirements))
    |> List.last()
  end

  defp check(player, {:knows, key}), do: key in player.knowledge

  defp check(player, {:has_rumor, key}), do: key in player.rumors

  defp check(player, {:contact_known, key}), do: key in player.contacts

  defp check(player, {:rep_at_least, npc, dim, threshold}) do
    player.reputation
    |> Map.get(npc, %{})
    |> Map.get(dim, 0)
    |> Kernel.>=(threshold)
  end

  defp check(player, {:has_item, key}), do: Map.get(player.inventory, key, 0) >= 1

  defp check(player, {:has_module, key}), do: key in player.modules

  defp check(player, {:premises_at_least, class}) do
    Shunt.Territory.premises_class(player) >= class
  end

  defp check(player, {:ghostwork_mastery_at_least, family, threshold}) do
    player.ghostwork_state
    |> Map.get("mastery", %{})
    |> Map.get(family, 0)
    |> Kernel.>=(threshold)
  end

  defp check(player, {:infra_state, id, state}), do: Shunt.Repair.state(player, id) == state

  defp check(player, {:has_program, action}) do
    player
    |> Shunt.Ghostwork.Programs.owned()
    |> Enum.any?(&(&1.action == action))
  end

  defp check(player, {:district, district_id, fact, op, target}) do
    Shunt.District.fact_meets?(player, district_id, fact, op, target)
  end

  # TODO: [Chrome & Meat v1 — Milestone 1] Add check/2 clauses:
  #   {:has_implant, key}         -> Map.has_key?(player.implants, key)  (capability-key gate; how
  #                                  events/choices/POIs/repair solutions gate on an installed implant)
  #   {:chrome_load_at_least, n}  -> player.chrome_load >= n
  #   {:chrome_load_below, n}     -> player.chrome_load < n
  # The Chrome Load foreshadowing event gates on {:chrome_load_at_least, <low>}; the additive live-bus
  # repair solution gates on {:has_implant, "lineman_graft"}. See priv/docs/SHUNT_chrome_and_meat_v1.md.
end
