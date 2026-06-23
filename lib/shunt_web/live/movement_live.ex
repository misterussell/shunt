defmodule ShuntWeb.MovementLive do
  use ShuntWeb, :live_view

  alias Shunt.Movement
  alias Shunt.Players
  alias Shunt.World
  alias ShuntWeb.Chrome

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    # TODO: initialize an empty `:narrative` stream so the feed starts fresh on every
    # mount/reconnect (ephemeral, never loaded from storage): stream(socket, :narrative, [], limit: -20)
    {:ok,
     socket |> assign(player_id: player_id) |> assign(:status, nil) |> assign_location(player)}
  end

  def handle_event("move_to", %{"destination" => destination}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Movement.move(&1, destination)) do
      {:ok, player, meta} ->
        # TODO: stream_insert a new entry into the :narrative stream so the move's
        # narrative line appears in the feed, capped to the last 20 entries:
        # stream_insert(socket, :narrative, %{id: System.unique_integer([:monotonic, :positive]), text: meta.narrative}, limit: -20)
        {:noreply, socket |> assign(:status, meta.narrative) |> assign_location(player)}

      {:error, :not_connected} ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:map} status={@status}>
      <Chrome.section_header>MAP</Chrome.section_header>
      <Chrome.panel id="current-location">
        <p>{@location.name}</p>
        <p>{@location.description}</p>
      </Chrome.panel>
      <ul>
        <li :for={exit <- @exits}>
          <%!-- TODO: render a discovered-locations indicator next to each exit, e.g. a
          badge span showing "● VISITED" when `exit.to in @player.discovered_locations` and
          "○ NEW" otherwise (mirrors the ● current / ○ available legend planned for the
          Phase 4 graph). Style as a Chrome-style badge, similar to .offer-tier-badge in
          assets/css/app.css. --%>
          <Chrome.btn
            id={"move-to-#{exit.to}"}
            variant={:ghost}
            phx-click="move_to"
            phx-value-destination={exit.to}
          >
            {World.get_location(exit.to).name}
          </Chrome.btn>
        </li>
      </ul>

      <%!-- TODO: add a narrative feed panel below the exits list:
      1. Chrome.section_header (e.g. "NARRATIVE_FEED")
      2. A Chrome.panel with DOM id "narrative-feed", containing a child div with
         id="narrative-entries" and phx-update="stream", consuming @streams.narrative and
         rendering each {id, entry} pair's `entry.text` (one line per entry, newest last).
      3. Use the hidden only:block empty-state pattern from AGENTS.md's streams section for
         when the feed is empty (e.g. "No movement yet.").
      Style the panel/text to match the existing simple panel + paragraph treatment already
      used for #current-location above (Chrome.panel wrapping <p> tags), not the heavier
      hub_live.ex offer/stash panel chrome. --%>
    </Layouts.app>
    """
  end

  defp assign_location(socket, player) do
    socket
    |> assign(:player, player)
    |> assign(:location, World.get_location(player.location_id))
    |> assign(:exits, World.exits(player.location_id))
  end
end
