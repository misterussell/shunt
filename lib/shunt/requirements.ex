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

  # NOTE: {:has_program, action} from the doc is intentionally deferred to Phase 2 — it
  # depends on the Shunt.Ghostwork.Programs catalog, which doesn't exist until then.
end
