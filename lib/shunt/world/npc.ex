defmodule Shunt.World.NPC do
  @moduledoc false

  @enforce_keys [:id, :name]
  # `contact_key` is the bare loyalty/identity key for a world NPC that is also a Hub contact
  # (e.g. "splice", "mother_graft"), decoupled from the district-prefixed struct `id`
  # (e.g. "liftworks_splice"). nil for ordinary world NPCs. The Hub reads loyalty via
  # Loyalty.value(player, npc.contact_key) and service resolvers grant {:npc_loyalty, contact_key, n},
  # so existing loyalty keys are preserved even though the world-NPC id is prefixed. A world NPC is
  # a Hub contact iff `services` is non-empty (contact_key must be set in that case).
  defstruct [
    :id,
    :name,
    :description,
    :location_id,
    :contact_key,
    story_arcs: [],
    conditional_events: [],
    repeatable_events: [],
    services: []
  ]
end
