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

  # TODO: add a check/2 clause for {:has_item, key} that is met when
  # Map.get(player.inventory, key, 0) >= 1 (the carried-item gate for The Web errands).
  # Document it in priv/docs/SHUNT_the_web_v1.md beside the other requirement types, and add
  # unit tests in test/shunt/requirements_test.exs (met at count >= 1; unmet at 0/absent).
end
