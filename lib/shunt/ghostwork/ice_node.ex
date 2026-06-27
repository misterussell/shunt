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

  # TODO: all/0 returns every %IceNode{} from the :ice_nodes content table via
  # Shunt.Content.all(:ice_nodes), mirroring Shunt.Crafting.RawCatalog.items/0. Content
  # files in priv/content/ice_nodes build %IceNode{} structs directly, so this is a thin
  # wrapper with no conversion.

  # TODO: fetch!(id) returns the %IceNode{} for id via Shunt.Content.fetch!(:ice_nodes, id),
  # mirroring Shunt.Crafting.RawCatalog.fetch!/1; raises on unknown id.
end
