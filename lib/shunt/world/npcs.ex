defmodule Shunt.World.Npcs do
  @moduledoc false

  alias Shunt.Content

  def get!(id), do: Content.fetch!(:world_npcs, id)

  # TODO: add current_event(player, npc_key), per
  # priv/docs/SHUNT_npc_architecture.md "Event Resolution" + "Repeatable Content" sections:
  #
  #   def current_event(player, npc_key) do
  #     npc = get!(npc_key)
  #     progression = Map.get(player.npc_progression, npc_key, 0)
  #
  #     if progression < length(npc.story_arcs) do
  #       Enum.at(npc.story_arcs, progression)
  #     else
  #       Enum.random(npc.repeatable_events)
  #     end
  #   end
  #
  # Known edge: raises via Enum.random([]) if repeatable_events is empty and progression
  # has exceeded story_arcs — acceptable for the pilot since no repeatable content is
  # authored yet for the Tunnel Junkie. Requires player.npc_progression to exist first.
end
