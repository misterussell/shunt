defmodule Shunt.World.Npcs do
  @moduledoc false

  alias Shunt.Content
  alias Shunt.Events
  alias Shunt.Requirements

  def get!(id), do: Content.fetch!(:world_npcs, id)

  def current_event(player, npc_key) do
    npc = get!(npc_key)
    progression = Map.get(player.npc_progression, npc_key, 0)
    current_arc = Enum.at(npc.story_arcs, progression)

    if current_arc != nil and current_arc not in player.completed_events do
      current_arc
    else
      conditional =
        Enum.find(npc.conditional_events, fn event_id ->
          Requirements.met?(player, Events.get!(event_id).requirements)
        end)

      conditional || if npc.repeatable_events != [], do: Enum.random(npc.repeatable_events)
    end
  end
end
