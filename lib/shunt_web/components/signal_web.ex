defmodule ShuntWeb.Components.SignalWeb do
  @moduledoc false

  use Phoenix.Component

  @size 440
  @center @size / 2
  @ring 150

  # Actionable threads sort to the top of the ring; unaffiliated trails.
  @status_order %{crackable: 0, lead: 1, forming: 2, solved: 3, unaffiliated: 4}

  @doc """
  Renders one focal entity's neighborhood of `Shunt.Web.entity_graph/1` as an SVG node-link "signal
  web": the focus at center, the entities one hop away on a ring around it, threads colored by the
  status of the case that links them. Only the local neighborhood is ever drawn, so the picture
  stays legible no matter how large the network grows — clicking a node re-centers the web on it.
  """
  attr :graph, :map, required: true
  attr :focus, :string, default: nil

  def signal_web(assigns) do
    {nodes, edges} = neighborhood(assigns.graph, assigns.focus)

    assigns =
      assigns
      |> assign(:nodes, nodes)
      |> assign(:edges, edges)
      |> assign(:positions, positions(nodes, edges, assigns.focus))
      |> assign(:view_box, "0 0 #{@size} #{@size}")

    ~H"""
    <svg id="entity-web" class="entity-web" viewBox={@view_box} role="presentation">
      <g class="entity-web-threads">
        <line
          :for={edge <- @edges}
          class="entity-web-thread"
          data-status={edge.status}
          x1={x(@positions[edge.a])}
          y1={y(@positions[edge.a])}
          x2={x(@positions[edge.b])}
          y2={y(@positions[edge.b])}
          stroke-width={thread_width(edge.weight)}
        />
      </g>
      <g class="entity-web-nodes">
        <g :for={node <- @nodes} class={node_class(node.tag, @focus)}>
          <circle
            id={"web-node-#{node.tag}"}
            class="entity-web-node-hit"
            cx={x(@positions[node.tag])}
            cy={y(@positions[node.tag])}
            r={node_radius(node.weight, node.tag == @focus)}
            phx-click="select_entity"
            phx-value-entity={node.tag}
          />
          <text
            class="entity-web-label"
            x={x(@positions[node.tag])}
            y={y(@positions[node.tag]) + node_radius(node.weight, node.tag == @focus) + 13}
            text-anchor="middle"
          >
            {node.tag}
          </text>
        </g>
      </g>
    </svg>
    """
  end

  # The focus plus every entity one hop away, and the threads among just that visible set.
  defp neighborhood(%{nodes: []}, _focus), do: {[], []}

  defp neighborhood(graph, focus) do
    neighbors = for edge <- graph.edges, tag <- linked(edge, focus), into: MapSet.new(), do: tag
    visible = MapSet.put(neighbors, focus)

    nodes = Enum.filter(graph.nodes, &MapSet.member?(visible, &1.tag))
    edges = Enum.filter(graph.edges, &(&1.a in visible and &1.b in visible))
    {nodes, edges}
  end

  defp linked(%{a: focus, b: b}, focus), do: [b]
  defp linked(%{a: a, b: focus}, focus), do: [a]
  defp linked(_edge, _focus), do: []

  # Focus at the center; neighbors swept around a ring, actionable threads first.
  defp positions(nodes, edges, focus) do
    ranked = focus_thread_ranks(edges, focus)

    ordered =
      nodes
      |> Enum.reject(&(&1.tag == focus))
      |> Enum.sort_by(&{Map.get(ranked, &1.tag, map_size(@status_order)), -&1.weight, &1.tag})

    count = length(ordered)

    ordered
    |> Enum.with_index()
    |> Enum.reduce(%{focus => {@center, @center}}, fn {node, i}, acc ->
      theta = 2 * :math.pi() * i / count

      Map.put(
        acc,
        node.tag,
        {@center + @ring * :math.cos(theta), @center + @ring * :math.sin(theta)}
      )
    end)
  end

  defp focus_thread_ranks(edges, focus) do
    for edge <- edges, tag <- linked(edge, focus), into: %{} do
      {tag, Map.fetch!(@status_order, edge.status)}
    end
  end

  defp x({x, _y}), do: x
  defp y({_x, y}), do: y

  defp node_class(focus, focus), do: "entity-web-node entity-web-node--focus"
  defp node_class(_tag, _focus), do: "entity-web-node"

  defp node_radius(_weight, true), do: 13
  defp node_radius(weight, false), do: min(6 + 2 * weight, 12)
  defp thread_width(weight), do: 1 + weight
end
