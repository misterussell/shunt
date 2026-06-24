defmodule ShuntWeb.MovementLive do
  use ShuntWeb, :live_view

  alias Shunt.Movement
  alias Shunt.Players
  alias Shunt.World
  alias ShuntWeb.Chrome
  alias ShuntWeb.Components.MapGraph

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    {:ok,
     socket
     |> assign(player_id: player_id)
     |> assign(:status, nil)
     # TODO: assign(:active_event_id, nil) — ephemeral UI state for which event's step is
     # currently expanded in the location panel; not persisted (see Shunt.Events.choose/3 TODO).
     |> stream(:narrative, [], limit: -20)
     |> assign_location(player)}
  end

  # TODO: handle_event("start_event", %{"id" => event_id}, socket) — dispatch
  # Events.start/2 via Players.dispatch/2 (same shape as "move_to" below), then
  # assign(:active_event_id, event_id) so the template renders that event's current step.

  # TODO: handle_event("event_choice", %{"event_id" => id, "choice" => choice}, socket) —
  # dispatch Events.choose/3 via Players.dispatch/2. On {:ok, player, _meta}, re-assign the
  # player and, if the event is now in player.completed_events, clear :active_event_id (back
  # to the description + POI list); otherwise keep it set so the next step renders. On
  # {:error, :invalid_choice} or {:error, :already_completed}, no-op the socket (same style as
  # the {:error, :not_connected} clause below).

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
      <div class="map-page-grid">
        <div>
          <Chrome.section_header>MAP</Chrome.section_header>
          <Chrome.panel id="current-location">
            <p class="location-name">{@location.name}</p>
            <%!-- TODO: when @active_event_id is set, render that event's current step
            (via Shunt.Events.current_step/2) — step text + a button per choice, each
            phx-click="event_choice" with phx-value-event_id and phx-value-choice — instead
            of the description below. When nil, render the description as today plus a
            "Points of Interest" list sourced from @location.events (title via
            Shunt.Events.get!/1), each clickable with phx-click="start_event"
            phx-value-id={event_id}, marked "(completed)" when the id is in
            @player.completed_events. --%>
            <p class="location-description">{@location.description}</p>
          </Chrome.panel>
          <MapGraph.map_legend />
          <MapGraph.map_graph player={@player} locations={@locations} />
        </div>
        <div>
          <Chrome.section_header>NARRATIVE_FEED</Chrome.section_header>
          <Chrome.panel id="narrative-feed">
            <div id="narrative-entries" phx-update="stream">
              <p id="narrative-empty" class="hidden only:block">No movement yet.</p>
              <p :for={{id, entry} <- @streams.narrative} id={id}>{entry.text}</p>
            </div>
          </Chrome.panel>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp assign_location(socket, player) do
    socket
    |> assign(:player, player)
    |> assign(:location, World.get_location(player.location_id))
    |> assign(:locations, World.all_locations())
  end
end
