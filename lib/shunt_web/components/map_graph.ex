defmodule ShuntWeb.Components.MapGraph do
  @moduledoc false

  use Phoenix.Component

  @window_width 640
  @window_height 440

  attr :player, :map, required: true
  attr :locations, :list, required: true

  def map_graph(assigns) do
    current = Enum.find(assigns.locations, &(&1.id == assigns.player.location_id))
    connected_keys = MapSet.new(current.exits, & &1.to)
    states = Map.new(assigns.locations, &{&1.id, node_state(&1, assigns.player, connected_keys)})
    edges = edges(assigns.locations)

    {cx, cy} = current.graph_position
    translate_x = @window_width / 2 - cx
    translate_y = @window_height / 2 - cy

    assigns =
      assigns
      |> assign(:states, states)
      |> assign(:edges, edges)
      |> assign(:current, current)
      |> assign(:window_width, @window_width)
      |> assign(:window_height, @window_height)
      |> assign(:view_box, "0 0 #{@window_width} #{@window_height}")
      |> assign(:world_transform, "translate(#{trunc(translate_x)}, #{trunc(translate_y)})")

    ~H"""
    <svg viewBox={@view_box} class="map-graph">
      <defs>
        <filter id="map-glow" x="-60%" y="-60%" width="220%" height="220%">
          <feGaussianBlur stdDeviation="6" result="b" />
          <feMerge>
            <feMergeNode in="b" /><feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
        <filter id="map-rough" x="-20%" y="-20%" width="140%" height="140%">
          <feTurbulence
            type="fractalNoise"
            baseFrequency="0.06"
            numOctaves="2"
            seed="7"
            result="turb"
          />
          <feDisplacementMap
            in="SourceGraphic"
            in2="turb"
            scale="4"
            xChannelSelector="R"
            yChannelSelector="G"
          />
        </filter>
        <filter id="map-grain">
          <feTurbulence
            type="fractalNoise"
            baseFrequency="0.85"
            numOctaves="2"
            stitchTiles="stitch"
            result="n"
          />
          <feColorMatrix in="n" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0.55 0" />
        </filter>
        <pattern id="map-dots" width="40" height="40" patternUnits="userSpaceOnUse">
          <circle cx="20" cy="20" r="1.4" fill="var(--border-c)" opacity="0.55" />
          <circle cx="6" cy="33" r="0.8" fill="var(--border-c)" opacity="0.3" />
          <circle cx="33" cy="9" r="0.6" fill="var(--border-c)" opacity="0.25" />
        </pattern>
        <pattern
          id="map-hatch-amber"
          width="6"
          height="6"
          patternUnits="userSpaceOnUse"
          patternTransform="rotate(45)"
        >
          <line x1="0" y1="0" x2="0" y2="6" stroke="var(--amber)" stroke-width="1.4" />
        </pattern>
        <pattern
          id="map-hatch-undiscovered"
          width="8"
          height="8"
          patternUnits="userSpaceOnUse"
          patternTransform="rotate(45)"
        >
          <line x1="0" y1="0" x2="0" y2="8" stroke="var(--border-c)" stroke-width="2" />
        </pattern>
        <radialGradient id="map-burn" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="var(--amber)" stop-opacity="0.35" />
          <stop offset="55%" stop-color="#1a1108" stop-opacity="0.35" />
          <stop offset="100%" stop-color="#000000" stop-opacity="0" />
        </radialGradient>
      </defs>

      <rect x="0" y="0" width={@window_width} height={@window_height} fill="url(#map-dots)" />
      <rect
        x="0"
        y="0"
        width={@window_width}
        height={@window_height}
        filter="url(#map-grain)"
        opacity="0.18"
      />

      <rect
        x={@window_width / 2 - 120}
        y={@window_height / 2 - 120}
        width="240"
        height="240"
        fill="url(#map-burn)"
      />

      <g class="map-world" transform={@world_transform}>
        <.edge
          :for={{loc_a, loc_b} <- @edges}
          state_a={@states[loc_a.id]}
          state_b={@states[loc_b.id]}
          point_a={loc_a.graph_position}
          point_b={loc_b.graph_position}
        />

        <.map_node
          :for={location <- @locations}
          location={location}
          state={@states[location.id]}
        />
      </g>
    </svg>
    """
  end

  attr :state_a, :atom, required: true
  attr :state_b, :atom, required: true
  attr :point_a, :any, required: true
  attr :point_b, :any, required: true

  defp edge(assigns) do
    style = edge_style(assigns.state_a, assigns.state_b)
    grates = if style == :unknown, do: [0.5], else: [0.35, 0.65]

    points =
      [assigns.point_a | break_points(grates, assigns.point_a, assigns.point_b)] ++
        [assigns.point_b]

    segments = Enum.chunk_every(points, 2, 1, :discard)
    break_xy = break_points(grates, assigns.point_a, assigns.point_b)

    {stroke, width, dash, filter} =
      case style do
        :active -> {"var(--cyan)", "3", nil, "url(#map-glow)"}
        :known -> {"var(--muted)", "2", nil, nil}
        :unknown -> {"var(--border-c)", "2", "3 6", nil}
      end

    hatch =
      if style == :unknown, do: "url(#map-hatch-undiscovered)", else: "url(#map-hatch-amber)"

    assigns =
      assigns
      |> assign(:segments, segments)
      |> assign(:break_xy, break_xy)
      |> assign(:stroke, stroke)
      |> assign(:width, width)
      |> assign(:dash, dash)
      |> assign(:filter, filter)
      |> assign(:hatch, hatch)

    ~H"""
    <g filter="url(#map-rough)">
      <line
        :for={[{x1, y1}, {x2, y2}] <- @segments}
        x1={x1}
        y1={y1}
        x2={x2}
        y2={y2}
        stroke={@stroke}
        stroke-width={@width}
        stroke-dasharray={@dash}
        filter={@filter}
      />
    </g>
    <g :for={{x, y} <- @break_xy} filter={@filter}>
      <rect
        x={x - 4.5}
        y={y - 4.5}
        width="9"
        height="9"
        fill={@hatch}
        stroke={@stroke}
        stroke-width="1"
      />
    </g>
    """
  end

  attr :location, :map, required: true
  attr :state, :atom, required: true

  defp map_node(assigns) do
    {x, y} = assigns.location.graph_position

    {fill, stroke, opacity, filter} =
      case assigns.state do
        :current -> {"var(--cyan)", "var(--cyan)", "1", "url(#map-glow)"}
        :connected -> {"none", "var(--cyan)", "1", "url(#map-rough)"}
        :discovered -> {"none", "var(--muted)", "0.7", "url(#map-rough)"}
        :undiscovered -> {"url(#map-hatch-undiscovered)", "var(--border-c)", "1", nil}
      end

    name = if assigns.state == :undiscovered, do: "???", else: assigns.location.name

    assigns =
      assigns
      |> assign(:x, x)
      |> assign(:y, y)
      |> assign(:fill, fill)
      |> assign(:stroke, stroke)
      |> assign(:opacity, opacity)
      |> assign(:filter, filter)
      |> assign(:name, name)

    ~H"""
    <g filter={@filter}>
      <rect
        x={@x - 14}
        y={@y - 14}
        width="28"
        height="28"
        fill={@fill}
        stroke={@stroke}
        stroke-width="2.5"
        opacity={@opacity}
        transform={"rotate(45 #{@x} #{@y})"}
      />
    </g>
    <path
      :if={@state == :undiscovered}
      d={"M#{@x - 6} #{@y - 6} L#{@x + 6} #{@y + 6} M#{@x + 6} #{@y - 6} L#{@x - 6} #{@y + 6}"}
      stroke="var(--muted)"
      stroke-width="2.5"
      filter="url(#map-rough)"
    />
    <path
      :if={@state == :current}
      d={"M#{@x - 23} #{@y - 14} L#{@x - 23} #{@y - 23} M#{@x - 23} #{@y - 14} L#{@x - 14} #{@y - 14}
          M#{@x + 23} #{@y - 14} L#{@x + 23} #{@y - 23} M#{@x + 23} #{@y - 14} L#{@x + 14} #{@y - 14}
          M#{@x - 23} #{@y + 14} L#{@x - 23} #{@y + 23} M#{@x - 23} #{@y + 14} L#{@x - 14} #{@y + 14}
          M#{@x + 23} #{@y + 14} L#{@x + 23} #{@y + 23} M#{@x + 23} #{@y + 14} L#{@x + 14} #{@y + 14}"}
      stroke="var(--cyan)"
      stroke-width="2"
      filter="url(#map-rough)"
    />
    <ellipse
      :if={@state in [:current, :connected]}
      cx={@x}
      cy={@y}
      rx="5.5"
      ry="4.5"
      fill="#1c2422"
      stroke="var(--cyan)"
      stroke-width="1"
      opacity="0.9"
    />
    <text
      x={@x}
      y={@y + 45}
      text-anchor="middle"
      fill={@stroke}
      font-size="11"
      letter-spacing="1"
    >
      {@name}
    </text>
    <circle
      :if={@state == :connected}
      id={"move-to-#{@location.id}"}
      class="map-node--connected"
      cx={@x}
      cy={@y}
      r="20"
      fill="transparent"
      phx-click="move_to"
      phx-value-destination={@location.id}
    />
    """
  end

  def map_legend(assigns) do
    ~H"""
    <ul class="map-legend">
      <li class="map-legend-row map-legend-row--current">● CURRENT LOCATION</li>
      <li class="map-legend-row map-legend-row--connected">○ CONNECTED</li>
      <li class="map-legend-row map-legend-row--discovered">○ DISCOVERED</li>
      <li class="map-legend-row map-legend-row--undiscovered">✕ UNDISCOVERED</li>
    </ul>
    """
  end

  defp node_state(location, player, connected_keys) do
    cond do
      location.id == player.location_id -> :current
      location.id in connected_keys -> :connected
      location.id in player.discovered_locations -> :discovered
      true -> :undiscovered
    end
  end

  defp edges(locations) do
    by_key = Map.new(locations, &{&1.id, &1})

    locations
    |> Enum.flat_map(fn loc -> Enum.map(loc.exits, &{loc.id, &1.to}) end)
    |> Enum.uniq_by(fn {a, b} -> Enum.sort([a, b]) end)
    |> Enum.map(fn {a, b} -> {by_key[a], by_key[b]} end)
  end

  defp edge_style(state_a, state_b) do
    cond do
      :current in [state_a, state_b] -> :active
      :undiscovered in [state_a, state_b] -> :unknown
      true -> :known
    end
  end

  defp break_points(t_fractions, {x1, y1}, {x2, y2}) do
    Enum.map(t_fractions, fn t -> {x1 + (x2 - x1) * t, y1 + (y2 - y1) * t} end)
  end
end
