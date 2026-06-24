defmodule Shunt.World.NPC do
  @moduledoc false

  @enforce_keys [:id, :name]
  defstruct [
    :id,
    :name,
    :description,
    :location_id,
    story_arcs: [],
    repeatable_events: [],
    services: []
  ]
end
