defmodule ShuntWeb.Components.SignalWeb do
  @moduledoc false

  use Phoenix.Component

  @size 440
  @radius 170

  @doc """
  Renders `Shunt.Web.entity_graph/1` as an SVG node-link "signal web": entity nodes sized by
  signal, threads between co-occurring entities colored by the status of the case that produces
  them. Selecting an entity lights its neighborhood and dims the rest. Positions come pre-computed
  and normalized from the domain; this component only projects them into the viewport and draws.
  """
  attr :graph, :map, required: true
  attr :selected_entity, :string, default: nil

  def signal_web(assigns) do
    positions = Map.new(assigns.graph.nodes, &{&1.tag, project(&1)})

    assigns =
      assigns
      |> assign(:positions, positions)
      |> assign(:neighbors, neighbors(assigns.graph.edges, assigns.selected_entity))
      |> assign(:view_box, "0 0 #{@size} #{@size}")

    ~H"""
    <svg id="entity-web" class="entity-web" viewBox={@view_box} role="presentation">
      <g class="entity-web-threads">
        <line
          :for={edge <- @graph.edges}
          class={thread_class(edge, @selected_entity)}
          data-status={edge.status}
          x1={x(@positions[edge.a])}
          y1={y(@positions[edge.a])}
          x2={x(@positions[edge.b])}
          y2={y(@positions[edge.b])}
          stroke-width={thread_width(edge.weight)}
        />
      </g>
      <g class="entity-web-nodes">
        <g :for={node <- @graph.nodes} class={node_class(node, @selected_entity, @neighbors)}>
          <circle
            id={"web-node-#{node.tag}"}
            class="entity-web-node-hit"
            cx={x(@positions[node.tag])}
            cy={y(@positions[node.tag])}
            r={node_radius(node.weight)}
            phx-click="select_entity"
            phx-value-entity={node.tag}
          />
          <text
            class="entity-web-label"
            x={x(@positions[node.tag])}
            y={y(@positions[node.tag]) + node_radius(node.weight) + 12}
            text-anchor="middle"
          >
            {node.tag}
          </text>
        </g>
      </g>
    </svg>
    """
  end

  # Normalized unit-circle coords -> viewport pixels, centered.
  defp project(node), do: {@size / 2 + node.x * @radius, @size / 2 + node.y * @radius}
  defp x({x, _y}), do: x
  defp y({_x, y}), do: y

  # The selected entity plus every entity directly threaded to it.
  defp neighbors(_edges, nil), do: MapSet.new()

  defp neighbors(edges, selected) do
    edges
    |> Enum.flat_map(fn
      %{a: ^selected, b: b} -> [b]
      %{a: a, b: ^selected} -> [a]
      _ -> []
    end)
    |> MapSet.new()
    |> MapSet.put(selected)
  end

  defp node_class(_node, nil, _neighbors), do: "entity-web-node"

  defp node_class(node, selected, neighbors) do
    cond do
      node.tag == selected -> "entity-web-node entity-web-node--selected"
      MapSet.member?(neighbors, node.tag) -> "entity-web-node entity-web-node--active"
      true -> "entity-web-node entity-web-node--dim"
    end
  end

  defp thread_class(_edge, nil), do: "entity-web-thread"

  defp thread_class(edge, selected) do
    if edge.a == selected or edge.b == selected,
      do: "entity-web-thread entity-web-thread--active",
      else: "entity-web-thread entity-web-thread--dim"
  end

  defp node_radius(weight), do: 5 + 2 * weight
  defp thread_width(weight), do: 1 + weight
end
