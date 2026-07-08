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
  web" of real game objects: the focus at center, the entities one hop away (NPCs, locations, ICE)
  on a ring around it, threads colored by the status of the case that links them. Each kind gets a
  distinct silhouette (NPC circle / location square / ICE diamond) so the graph reads as a social
  web, not a taxonomy. Only the local neighborhood is drawn, so it stays legible at any scale —
  clicking a node re-centers the web on it.
  """
  attr :graph, :map, required: true
  attr :focus, :string, default: nil

  def signal_web(assigns) do
    {nodes, edges} = neighborhood(assigns.graph, assigns.focus)
    positions = positions(nodes, edges, assigns.focus)

    assigns =
      assigns
      |> assign(:placed_nodes, place_nodes(nodes, positions, assigns.focus))
      |> assign(:placed_edges, place_edges(edges, positions))
      |> assign(:view_box, "0 0 #{@size} #{@size}")

    ~H"""
    <svg id="entity-web" class="entity-web" viewBox={@view_box} role="presentation">
      <g class="entity-web-threads">
        <line
          :for={edge <- @placed_edges}
          class="entity-web-thread"
          data-status={edge.status}
          x1={edge.x1}
          y1={edge.y1}
          x2={edge.x2}
          y2={edge.y2}
          stroke-width={edge.width}
        />
      </g>
      <g class="entity-web-nodes">
        <g :for={node <- @placed_nodes} class={node.class}>
          <circle
            :if={node.kind == :npc}
            class="entity-web-mark"
            cx={node.cx}
            cy={node.cy}
            r={node.r}
          />
          <rect
            :if={node.kind == :location}
            class="entity-web-mark"
            x={node.cx - node.r}
            y={node.cy - node.r}
            width={2 * node.r}
            height={2 * node.r}
          />
          <rect
            :if={node.kind == :ice}
            class="entity-web-mark"
            x={node.cx - node.r}
            y={node.cy - node.r}
            width={2 * node.r}
            height={2 * node.r}
            transform={"rotate(45 #{node.cx} #{node.cy})"}
          />
          <text class="entity-web-label" x={node.cx} y={node.cy + node.r + 13} text-anchor="middle">
            {node.name}
          </text>
          <circle
            id={"web-node-#{node.key}"}
            class="entity-web-hit"
            data-kind={node.kind}
            cx={node.cx}
            cy={node.cy}
            r={node.r + 6}
            phx-click="select_entity"
            phx-value-entity={node.key}
          />
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

    nodes = Enum.filter(graph.nodes, &MapSet.member?(visible, &1.key))
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
      |> Enum.reject(&(&1.key == focus))
      |> Enum.sort_by(&{Map.get(ranked, &1.key, map_size(@status_order)), -&1.weight, &1.key})

    count = length(ordered)

    ordered
    |> Enum.with_index()
    |> Enum.reduce(%{focus => {@center, @center}}, fn {node, i}, acc ->
      theta = 2 * :math.pi() * i / count

      Map.put(
        acc,
        node.key,
        {@center + @ring * :math.cos(theta), @center + @ring * :math.sin(theta)}
      )
    end)
  end

  defp focus_thread_ranks(edges, focus) do
    for edge <- edges, tag <- linked(edge, focus), into: %{} do
      {tag, Map.fetch!(@status_order, edge.status)}
    end
  end

  defp place_nodes(nodes, positions, focus) do
    Enum.map(nodes, fn node ->
      {cx, cy} = positions[node.key]

      %{
        key: node.key,
        kind: node.kind,
        name: node.name,
        cx: cx,
        cy: cy,
        r: node_radius(node.weight, node.key == focus),
        class: node_class(node.key, focus)
      }
    end)
  end

  defp place_edges(edges, positions) do
    Enum.map(edges, fn edge ->
      {x1, y1} = positions[edge.a]
      {x2, y2} = positions[edge.b]
      %{status: edge.status, width: thread_width(edge.weight), x1: x1, y1: y1, x2: x2, y2: y2}
    end)
  end

  defp node_class(focus, focus), do: "entity-web-node entity-web-node--focus"
  defp node_class(_key, _focus), do: "entity-web-node"

  defp node_radius(_weight, true), do: 12
  defp node_radius(weight, false), do: min(6 + 2 * weight, 11)
  defp thread_width(weight), do: 1 + weight
end
