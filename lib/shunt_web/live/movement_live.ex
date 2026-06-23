defmodule ShuntWeb.MovementLive do
  use ShuntWeb, :live_view

  alias Shunt.Movement
  alias Shunt.Players
  alias Shunt.World
  alias ShuntWeb.Chrome

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    {:ok,
     socket
     |> assign(player_id: player_id)
     |> assign(:status, nil)
     |> stream(:narrative, [], limit: -20)
     |> assign_location(player)}
  end

  def handle_event("move_to", %{"destination" => destination}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Movement.move(&1, destination)) do
      {:ok, player, meta} ->
        entry = %{id: System.unique_integer([:monotonic, :positive]), text: meta.narrative}

        {:noreply,
         socket
         |> assign(:status, meta.narrative)
         |> stream_insert(:narrative, entry, limit: -20)
         |> assign_location(player)}

      {:error, :not_connected} ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:map} status={@status}>
      <Chrome.section_header>MAP</Chrome.section_header>
      <Chrome.panel id="current-location">
        <p class="location-name">{@location.name}</p>
        <p class="location-description">{@location.description}</p>
      </Chrome.panel>
      <ul class="exit-list">
        <li :for={exit <- @exits}>
          <Chrome.btn
            id={"move-to-#{exit.to}"}
            variant={:ghost}
            phx-click="move_to"
            phx-value-destination={exit.to}
          >
            {World.get_location(exit.to).name}
          </Chrome.btn>
          <% {badge_class, badge_label} = discovered_badge(exit.to, @player) %>
          <span id={"exit-badge-#{exit.to}"} class={["exit-badge", badge_class]}>
            {badge_label}
          </span>
        </li>
      </ul>

      <Chrome.section_header>NARRATIVE_FEED</Chrome.section_header>
      <Chrome.panel id="narrative-feed">
        <div id="narrative-entries" phx-update="stream">
          <p id="narrative-empty" class="hidden only:block">No movement yet.</p>
          <p :for={{id, entry} <- @streams.narrative} id={id}>{entry.text}</p>
        </div>
      </Chrome.panel>
    </Layouts.app>
    """
  end

  defp assign_location(socket, player) do
    socket
    |> assign(:player, player)
    |> assign(:location, World.get_location(player.location_id))
    |> assign(:exits, World.exits(player.location_id))
  end

  defp discovered_badge(location_key, player) do
    if location_key in player.discovered_locations do
      {"exit-badge--visited", "VISITED"}
    else
      {"exit-badge--new", "NEW"}
    end
  end
end
