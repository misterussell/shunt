defmodule Shunt.World.Npcs do
  @moduledoc false

  alias Shunt.Content

  def get!(id), do: Content.fetch!(:world_npcs, id)

  def current_event(player, npc_key) do
    npc = get!(npc_key)
    progression = Map.get(player.npc_progression, npc_key, 0)

    if progression < length(npc.story_arcs) do
      Enum.at(npc.story_arcs, progression)
    else
      Enum.random(npc.repeatable_events)
    end
  end
end
