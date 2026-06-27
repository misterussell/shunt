defmodule Shunt.Ghostwork.IceNode do
  @moduledoc """
  A breakable ICE node on the Latticework: an ordered stack of layers reached
  through the player's deck at a specific location.

  See priv/docs/SHUNT_ghostwork_v1.md ("The ICE Encounter").
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
