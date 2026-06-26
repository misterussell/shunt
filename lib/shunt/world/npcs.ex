defmodule Shunt.World.Npcs do
  @moduledoc false

  alias Shunt.Content
  alias Shunt.Events
  alias Shunt.Requirements

  def get!(id), do: Content.fetch!(:world_npcs, id)

  def current_event(player, npc_key) do
    npc = get!(npc_key)
    progression = Map.get(player.npc_progression, npc_key, 0)

    if progression < length(npc.story_arcs) do
      Enum.at(npc.story_arcs, progression)
    else
      Enum.find(npc.repeatable_events, fn event_id ->
        Requirements.met?(player, Events.get!(event_id).requirements)
      end)
    end
  end
end
