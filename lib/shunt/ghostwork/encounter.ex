defmodule Shunt.Ghostwork.Encounter do
  @moduledoc """
  Transient state of one in-progress ICE break. Lives in the LiveView assigns and
  is advanced only by pure `Shunt.Ghostwork` functions — it is never persisted, so
  a dropped connection mid-break loses the unbanked layer (by design).

  See priv/docs/SHUNT_ghostwork_v1.md ("Where the logic lives").

  Fields:
    * node        — the %Shunt.Ghostwork.IceNode{} being broken
    * layer_index — 0-based index of the current layer (resumes at banked_layer + 1)
    * progress    — accumulated progress on the current layer (resets to 0 per layer)
    * trace       — 0..100, persists across all layers until the encounter ends
    * mastery     — snapshot of the family's mastery count at begin (drives fog-of-war)
    * status      — :active | :cracked | :busted | :retreated
  """

  # TODO: Replace the single `progress` field with `subroutine_progress` — a
  # %{subroutine_id => accumulated_progress} map for the CURRENT layer only. A
  # subroutine is "down" when its accumulated progress >= its progress_required; a
  # subroutine is "alive" otherwise. The layer is cleared when every subroutine on it
  # is down. `subroutine_progress` resets to a fresh zeroed map each time the layer
  # advances (mirrors how `progress` reset to 0 per layer). Keep `layer_index`,
  # `trace`, `mastery`, `status` exactly as they are. Update this moduledoc field list
  # to describe `subroutine_progress` instead of `progress`.
  @enforce_keys [:node, :layer_index, :mastery]
  defstruct [
    :node,
    :layer_index,
    :mastery,
    progress: 0,
    trace: 0,
    status: :active
  ]
end
