defmodule ShuntWeb.Components.SignalWeb do
  @moduledoc false

  use Phoenix.Component

  # TODO: render the entity-to-entity signal web as a deterministic SVG node-link graph, modeled
  #   on ShuntWeb.Components.MapGraph (an SVG with a viewBox and a <g> world, an edge partial and
  #   a node partial, MapGraph-style framing). Input: the %{nodes, edges} map from
  #   Shunt.Web.entity_graph/1 plus the selected_entity tag (or nil).
  #   - Edges drawn first as <line> using each edge's a/b node positions: stroke-width scaled by
  #     edge weight, data-status={status} so CSS colors them by the case status accents
  #     (crackable/lead/forming/solved; :unaffiliated renders dim/muted).
  #   - Nodes drawn on top: <circle> with r scaled by node weight plus a <text> label. Each node
  #     is clickable via phx-click="select_entity" phx-value-entity={tag} (reuses WebLive's
  #     existing handler) and carries a stable id={"web-node-#{tag}"}.
  #   - When selected_entity is set, stamp --active / --dim classes computed HERE from the edge
  #     list: the selected node + its incident edges + immediate-neighbor nodes get --active,
  #     everything else --dim. This is pure presentation off already-derived edges, not a domain
  #     recompute (stays within the LiveView presentation boundary).
  #   - Guard: render an empty placeholder when nodes == [].
  attr :graph, :map, required: true
  attr :selected_entity, :string, default: nil

  def signal_web(assigns) do
    ~H"""
    <div id="entity-web" class="entity-web"></div>
    """
  end
end
