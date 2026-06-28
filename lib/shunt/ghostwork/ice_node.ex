defmodule Shunt.Ghostwork.IceNode do
  @moduledoc """
  A breakable ICE node on the Latticework: an ordered stack of layers reached
  through the player's deck at a specific location.

  See priv/docs/SHUNT_ghostwork_v1.md ("The ICE Encounter").
  """

  # TODO: New layer schema — a layer is an open board of subroutines instead of a single
  # Progress bar + hidden weakness. Each layer map becomes:
  #     %{
  #       id: "...",
  #       name: "...",
  #       trace_multiplier: 1.5,          # kept — scales Trace for the whole layer
  #       reward: [ ... ],                # kept — fires when ALL subroutines are down
  #       subroutines: [
  #         %{id: "auth_gate", key: :spoof, threat: :barrier, progress_required: 8},
  #         %{id: "watchdog",  key: :decrypt, threat: :sentry, progress_required: 6},
  #         %{id: "canary",    key: :backdoor, threat: :trap,  progress_required: 5}
  #       ]
  #     }
  # `key` is an action type (:spoof/:decrypt/:backdoor) — the program that cracks it
  # efficiently. `threat` is one of :barrier (inert) | :sentry (bleeds Trace each turn it
  # stays alive) | :trap (amplifies a mismatched non-Probe hit's Trace). The layer-level
  # `weakness` and `progress_required` fields are REMOVED. Document the subroutine shape in
  # this moduledoc.
  @enforce_keys [:id, :name, :family, :location_id, :layers]
  defstruct [
    :id,
    :name,
    :family,
    :location_id,
    description: nil,
    requirements: [],
    cool_threshold: 60,
    layers: []
  ]

  # TODO: Migrate all existing nodes in priv/content/ice_nodes/**/*.exs to the new layer
  # schema with a mechanical 1:1 conversion that preserves current difficulty: each old
  # layer becomes a layer whose single subroutine is
  #     %{id: "#{old_layer.id}_core", key: old_layer.weakness, threat: :barrier,
  #       progress_required: old_layer.progress_required}
  # carrying over the old layer's id/name/trace_multiplier/reward. Remove the old
  # `weakness` and layer-level `progress_required` keys. content_integrity_test must pass.

  # TODO: Author 1-2 NEW showcase nodes (e.g. priv/content/ice_nodes/<area>/<id>.exs) whose
  # layers use the full Barrier/Sentry/Trap mix across the three keys, so the open-board
  # "which subroutine first" loop is exercised end to end. Gate them behind a scan lead like
  # the existing nodes, and add a LiveView integration test that breaks one (targeting
  # subroutines in a non-trivial order) to its reward.

  alias Shunt.Content

  def all, do: Content.all(:ice_nodes)

  def fetch!(id), do: Content.fetch!(:ice_nodes, id)
end
