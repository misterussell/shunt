defmodule ShuntWeb.MovementLive do
  use ShuntWeb, :live_view

  alias Shunt.Events
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
     |> assign(:active_event_id, nil)
     |> stream(:narrative, [], limit: -20)
     |> assign_location(player)}
  end

  def handle_event("start_event", %{"id" => event_id}, socket) do
    {:ok, player, _meta} =
      Players.dispatch(socket.assigns.player_id, &Events.start(&1, event_id))

    {:noreply,
     socket
     |> assign(:player, player)
     |> assign(:active_event_id, event_id)}
  end

  def handle_event("event_choice", %{"event_id" => event_id, "choice" => choice}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Events.choose(&1, event_id, choice)) do
      {:ok, player, _meta} ->
        active_event_id = if event_id in player.completed_events, do: nil, else: event_id

        {:noreply,
         socket
         |> assign(:player, player)
         |> assign(:active_event_id, active_event_id)}

      {:error, reason} when reason in [:invalid_choice, :already_completed] ->
        {:noreply, socket}
    end
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
      <div class="map-page-grid">
        <div>
          <Chrome.section_header>MAP</Chrome.section_header>
          <Chrome.panel id="current-location">
            <p class="location-name">{@location.name}</p>
            <%= if @active_event_id do %>
              <% step = Events.current_step(@player, @active_event_id) %>
              <div id="active-event">
                <p id="event-step-text" class="location-description">{step.text}</p>
                <button
                  :for={choice <- step.choices}
                  id={choice_dom_id(choice.label)}
                  class="btn-ghost location-event-button"
                  phx-click="event_choice"
                  phx-value-event_id={@active_event_id}
                  phx-value-choice={choice.label}
                >
                  [ {choice.label} ]
                </button>
              </div>
            <% else %>
              <p class="location-description">{@location.description}</p>
              <div :if={Map.get(@location, :events, []) != []} id="location-events">
                <p class="location-events-label">Points of Interest</p>
                <button
                  :for={event_id <- @location.events}
                  id={"start-event-#{event_id}"}
                  class="btn-ghost location-event-button"
                  phx-click="start_event"
                  phx-value-id={event_id}
                >
                  [ {Events.get!(event_id).title}{if event_id in @player.completed_events,
                    do: " (completed)"} ]
                </button>
              </div>
            <% end %>
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

  defp choice_dom_id(label), do: "event-choice-" <> String.replace(label, " ", "-")

  defp assign_location(socket, player) do
    socket
    |> assign(:player, player)
    |> assign(:location, World.get_location(player.location_id))
    |> assign(:locations, World.all_locations())
  end
end
