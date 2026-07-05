defmodule Shunt.Ghostwork.Encounter do
  @moduledoc """
  Transient state of one in-progress ICE break. Lives in the LiveView assigns and
  is advanced only by pure `Shunt.Ghostwork` functions — it is never persisted, so
  a dropped connection mid-break loses the unbanked layer (by design).

  See priv/docs/SHUNT_ghostwork_v1.md ("Where the logic lives").

  Fields:
    * node                — the %Shunt.Ghostwork.IceNode{} being broken
    * layer_index         — 0-based index of the current layer (resumes at banked_layer + 1)
    * subroutine_progress — %{subroutine_id => accumulated_progress} for the CURRENT layer
                            only. A subroutine is "down" when its progress >= its
                            progress_required, "alive" otherwise. The layer is cleared when
                            every subroutine is down. Re-zeroed to the next layer's
                            subroutines each time the layer advances.
    * trace               — 0..100, persists across all layers until the encounter ends
    * mastery             — snapshot of the family's mastery count at begin (drives fog-of-war)
    * status              — :active | :cracked | :busted | :retreated | :locked_out
                            (:locked_out = a vault defender tripped; see Shunt.Ghostwork act/4)

  TODO (vault mechanic, model ii): add a `layer_banked: false` field. It records that the CURRENT
  layer's required subroutines are down and its safe reward has already been dispatched, so the
  encounter can stay :active with the layer "cleared but open" — letting the player drill a still-
  alive vault or call Shunt.Ghostwork.descend/1 — without the resolver re-banking the safe reward.
  Reset to false each time the layer advances. See the resolve/descend TODOs in ghostwork.ex.
  """

  @enforce_keys [:node, :layer_index, :mastery]
  defstruct [
    :node,
    :layer_index,
    :mastery,
    subroutine_progress: %{},
    trace: 0,
    status: :active
  ]
end
