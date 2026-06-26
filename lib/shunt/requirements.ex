defmodule Shunt.Requirements do
  @moduledoc """
  Evaluates content-gating requirements against player state for The Web.

  Used to hide-entirely any location, exit, or POI event whose requirements are
  not met. See priv/docs/SHUNT_the_web_v1.md.
  """

  # TODO: Implement met?/2 returning true only when EVERY requirement in the list
  # passes for the given player. An empty list is always met.
  #   met?(_player, [])   => true
  #   met?(player, reqs)  => Enum.all?(reqs, &check(player, &1))

  # TODO: Implement check/2 (private) for each requirement type:
  #   {:knows, key}                -> key in player.knowledge
  #   {:contact_known, key}        -> key in player.contacts
  #   {:rep_at_least, npc, dim, n} -> reputation for npc/dim >= n, reading
  #       player.reputation[npc][dim] and defaulting a missing npc or dim to 0.
  #       dim is :trust or :favors.
end
