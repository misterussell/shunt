defmodule Shunt.Ghostwork.IceNode do
  @moduledoc """
  A breakable ICE node on the Latticework: an ordered stack of layers reached
  through the player's deck at a specific location.

  Each layer is an open board of subroutines (no single Progress bar):

      %{
        id: "ledger_access",
        name: "Ledger Access",
        trace_multiplier: 1.5,          # scales Trace for the whole layer
        reward: [ ... ],                # fires when EVERY subroutine on the layer is down
        subroutines: [
          %{id: "auth_gate", key: :spoof,   threat: :barrier, progress_required: 8},
          %{id: "watchdog",  key: :decrypt, threat: :sentry,  progress_required: 6},
          %{id: "canary",    key: :backdoor, threat: :trap,   progress_required: 5}
        ]
      }

  A subroutine's `key` is the action type (:spoof/:decrypt/:backdoor) that cracks it
  efficiently; `threat` is `:barrier` (inert) | `:sentry` (bleeds Trace each turn it stays
  alive) | `:trap` (amplifies a mismatched non-Probe hit's Trace). See
  priv/docs/SHUNT_ghostwork_v1.md ("The ICE Encounter").
  """

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

  alias Shunt.Content

  def all, do: Content.all(:ice_nodes)

  def fetch!(id), do: Content.fetch!(:ice_nodes, id)
end
