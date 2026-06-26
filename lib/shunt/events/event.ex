defmodule Shunt.Events.Event do
  @moduledoc false

  # TODO: Add `requirements: []` to defstruct. Used to hide-entirely POI events
  # (a location's :events) whose requirements aren't met, via
  # World.points_of_interest/2. NPC story-arc events ignore this field — their
  # ordering is the linear npc_progression index.
  @enforce_keys [:id, :title, :steps]
  defstruct [:id, :title, :description, :steps, on_complete: []]
end
