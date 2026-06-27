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
