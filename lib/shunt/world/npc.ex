defmodule Shunt.World.NPC do
  @moduledoc false

  @enforce_keys [:id, :name]
  defstruct [
    :id,
    :name,
    :description,
    :location_id,
    story_arcs: [],
    conditional_events: [],
    repeatable_events: [],
    services: []
  ]
end
