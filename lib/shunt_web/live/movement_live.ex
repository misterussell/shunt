defmodule ShuntWeb.MovementLive do
  use ShuntWeb, :live_view

  alias Shunt.Events
  alias Shunt.Movement
  alias Shunt.Players
  alias Shunt.World
  alias Shunt.World.Npcs
  alias ShuntWeb.Chrome
  alias ShuntWeb.Components.EventTerminal
  alias ShuntWeb.Components.MapGraph

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)
    ghostwork_tool_key = Shunt.Skills.Catalog.fetch!("ghostwork").tool_key

    {:ok,
     socket
     |> assign(player_id: player_id)
     |> assign(:status, nil)
     |> assign(:active_event_id, nil)
     |> assign(:active_repairable_id, nil)
     |> assign(:ghostwork_tool_key, ghostwork_tool_key)
     |> stream(:narrative, [], limit: -20)
     |> stream(:event_log, [], limit: -50)
     |> assign_location(player)}
  end

  def handle_event("start_event", %{"id" => event_id}, socket) do
    {:ok, player, _meta} =
      Players.dispatch(socket.assigns.player_id, &Events.start(&1, event_id))

    step = Events.current_step(player, event_id)

    {:noreply,
     socket
     |> assign(:player, player)
     |> assign(:active_event_id, event_id)
     |> stream(:event_log, [step_entry(step)], reset: true)}
  end

  def handle_event("event_choice", %{"event_id" => event_id, "choice" => choice}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Events.choose(&1, event_id, choice)) do
      {:ok, player, meta} ->
        completed? = not Map.has_key?(player.event_state, event_id)
        granted_items = Map.get(meta, :granted_items, [])
        socket = assign_location(socket, player)

        socket =
          cond do
            not completed? ->
              step = Events.current_step(player, event_id)

              socket
              |> assign(:active_event_id, event_id)
              |> stream_insert(:event_log, echo_entry(choice))
              |> stream_insert(:event_log, step_entry(step))

            granted_items != [] ->
              socket
              |> assign(:active_event_id, event_id)
              |> stream_insert(:event_log, echo_entry(choice))
              |> stream_insert(:event_log, reward_entry(event_id, granted_items))

            true ->
              assign(socket, :active_event_id, nil)
          end

        {:noreply, socket}

      {:error, reason} when reason in [:invalid_choice, :already_completed] ->
        {:noreply, socket}
    end
  end

  def handle_event("close_event", %{"event_id" => _event_id}, socket) do
    {:noreply, assign(socket, :active_event_id, nil)}
  end

  def handle_event("start_npc_event", %{"npc_key" => npc_key}, socket) do
    player = socket.assigns.player

    case Npcs.current_event(player, npc_key) do
      nil -> {:noreply, socket}
      event_id -> handle_event("start_event", %{"id" => event_id}, socket)
    end
  end

  def handle_event("inspect_repairable", %{"id" => id}, socket) do
    if Enum.any?(socket.assigns.repairables, &(&1.id == id)) do
      {:noreply, assign(socket, :active_repairable_id, id)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("close_repair", _params, socket) do
    {:noreply, assign(socket, :active_repairable_id, nil)}
  end

  def handle_event("apply_repair", %{"id" => id, "solution" => solution_id}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Shunt.Repair.repair(&1, id, solution_id)) do
      {:ok, player, meta} ->
        entry = %{id: System.unique_integer([:monotonic, :positive]), text: meta.outcome_text}

        {:noreply,
         socket
         |> assign(:active_repairable_id, nil)
         |> assign(:status, meta.outcome_text)
         |> stream_insert(:narrative, entry, limit: -20)
         |> assign_location(player)}

      {:error, _reason} ->
        {:noreply,
         assign(socket, :status, "The repair won't take — you're missing the tools or parts.")}
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
      <EventTerminal.event_modal
        :if={@active_event_id}
        id="event-modal"
        event_id={@active_event_id}
        title={Events.get!(@active_event_id).title}
        streams={@streams}
      />
      <.repair_modal
        :if={@active_repairable_id}
        player={@player}
        repairable_id={@active_repairable_id}
      />
      <div class="map-page-grid">
        <div class="map-page-main">
          <Chrome.section_header>MAP</Chrome.section_header>
          <Chrome.panel id="map-viewport">
            <MapGraph.map_graph player={@player} locations={@locations} />
          </Chrome.panel>
          <MapGraph.map_legend />
          <Chrome.section_header>NARRATIVE_FEED</Chrome.section_header>
          <Chrome.panel id="narrative-feed">
            <div id="narrative-entries" phx-update="stream">
              <p id="narrative-empty" class="hidden only:block">No movement yet.</p>
              <p :for={{id, entry} <- @streams.narrative} id={id}>{entry.text}</p>
            </div>
          </Chrome.panel>
        </div>
        <div class="map-page-rail">
          <Chrome.section_header>LOCATION</Chrome.section_header>
          <Chrome.panel id="current-location">
            <p class="location-name">{@location.name}</p>
            <span
              :if={Shunt.Ghostwork.lattice_active?(@player, @location, @ghostwork_tool_key)}
              id="lattice-cue"
              class="lattice-cue"
            >
              ⌁ lattice detected
            </span>
            <p class="location-description">
              {World.effective_description(@player, @location, @repairables)}
            </p>
            <div :if={@repairables != []} id="location-repairables">
              <p class="location-events-label">Infrastructure</p>
              <button
                :for={repairable <- @repairables}
                id={"inspect-repairable-#{repairable.id}"}
                class="btn-ghost location-event-button"
                phx-click="inspect_repairable"
                phx-value-id={repairable.id}
              >
                [ {repairable.name} ({Shunt.Repair.state(@player, repairable.id)}) ]
              </button>
            </div>
            <div :if={@points_of_interest != []} id="location-events">
              <p class="location-events-label">Points of Interest</p>
              <button
                :for={event_id <- @points_of_interest}
                id={"start-event-#{event_id}"}
                class="btn-ghost location-event-button"
                phx-click="start_event"
                phx-value-id={event_id}
              >
                [ {Events.get!(event_id).title}{if event_id in @player.completed_events,
                  do: " (completed)"} ]
              </button>
            </div>
            <div :if={Map.get(@location, :npcs, []) != []} id="location-npcs">
              <p class="location-events-label">People Here</p>
              <button
                :for={npc_key <- @location.npcs}
                id={"start-npc-#{npc_key}"}
                class="btn-ghost location-event-button"
                phx-click="start_npc_event"
                phx-value-npc_key={npc_key}
              >
                [ {Npcs.get!(npc_key).name} ]
              </button>
            </div>
          </Chrome.panel>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :player, :map, required: true
  attr :repairable_id, :string, required: true

  defp repair_modal(assigns) do
    repairable = Shunt.Repair.get!(assigns.repairable_id)
    current = Shunt.Repair.state(assigns.player, repairable.id)

    assigns =
      assigns
      |> assign(:repairable, repairable)
      |> assign(:diagnosis, Shunt.Repair.inspect(assigns.player, repairable))
      |> assign(:solutions, Shunt.Repair.available_solutions(assigns.player, repairable))
      |> assign(:fixable?, Enum.any?(repairable.solutions, &(current in &1.from)))

    ~H"""
    <div id="repair-modal" class="event-modal-backdrop" phx-click="close_repair">
      <div class="event-modal-panel" phx-click-away="close_repair">
        <div class="event-modal-header">
          <span class="section-header-bracket">┌─[ {@repairable.name} ]</span>
          <span class="section-header-rule"></span>
          <span class="section-header-secondary">
            [ {Shunt.Repair.state(@player, @repairable.id)} ]
          </span>
          <span class="section-header-bracket">─┐</span>
        </div>
        <div class="event-log">
          <p id="repair-diagnosis" class="event-step-text">{@diagnosis}</p>
          <div class="event-choices">
            <button
              :for={solution <- @solutions}
              id={"apply-repair-#{@repairable.id}-#{solution.id}"}
              class="btn-ghost event-choice-button"
              phx-click="apply_repair"
              phx-value-id={@repairable.id}
              phx-value-solution={solution.id}
            >
              [ {solution.label} ]
            </button>
            <p :if={@solutions == [] and @fixable?} id="repair-no-solutions" class="event-step-text">
              You're short on parts — the kind you have to make, not find whole. Scavenge what you need and come back.
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp step_entry(step) do
    %{
      id: System.unique_integer([:monotonic, :positive]),
      kind: :step,
      text: String.trim(step.text),
      choices: step.choices
    }
  end

  defp echo_entry(choice_label) do
    %{
      id: System.unique_integer([:monotonic, :positive]),
      kind: :echo,
      text: choice_label,
      choices: []
    }
  end

  defp reward_entry(event_id, granted_items) do
    text =
      Enum.map_join(granted_items, "\n", fn {key, qty} ->
        "+#{qty} #{Shunt.Items.display_name(key)}"
      end)

    %{
      id: System.unique_integer([:monotonic, :positive]),
      kind: :reward,
      text: text,
      event_id: event_id
    }
  end

  defp assign_location(socket, player) do
    socket
    |> assign(:player, player)
    |> assign(:location, World.get_location(player.location_id))
    |> assign(:locations, World.accessible_locations(player))
    |> assign(:points_of_interest, World.points_of_interest(player, player.location_id))
    |> assign(:repairables, Shunt.Repair.at_location(player, player.location_id))
  end
end
