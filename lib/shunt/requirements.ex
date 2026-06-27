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

  defp check(player, {:knows, key}), do: key in player.knowledge

  # TODO: add `defp check(player, {:has_rumor, key}), do: key in player.rumors`
  # Gates content behind rumor possession, mirroring {:knows, key} but reading player.rumors.

  defp check(player, {:contact_known, key}), do: key in player.contacts

  defp check(player, {:rep_at_least, npc, dim, threshold}) do
    player.reputation
    |> Map.get(npc, %{})
    |> Map.get(dim, 0)
    |> Kernel.>=(threshold)
  end

  defp check(player, {:has_item, key}), do: Map.get(player.inventory, key, 0) >= 1

  defp check(player, {:ghostwork_mastery_at_least, family, threshold}) do
    player.ghostwork_state
    |> Map.get("mastery", %{})
    |> Map.get(family, 0)
    |> Kernel.>=(threshold)
  end

  defp check(player, {:has_program, action}) do
    player
    |> Shunt.Ghostwork.Programs.owned()
    |> Enum.any?(&(&1.action == action))
  end
end
