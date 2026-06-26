defmodule Shunt.RequirementsTest do
  use ExUnit.Case, async: true

  # TODO: Test Shunt.Requirements.met?/2 per requirement type, building plain
  # %Shunt.Players.Player{} structs as input (no DB needed):
  #   - an empty requirements list is always met
  #   - {:knows, key}: met only when key is in player.knowledge
  #   - {:contact_known, key}: met only when key is in player.contacts
  #   - {:rep_at_least, npc, :trust, n}: met when reputation trust >= n; unmet
  #     when below n or when the npc/dim entry is absent (defaults to 0)
  #   - a multi-requirement list requires ALL requirements to pass
end
