defmodule ShuntWeb.WebLive do
  use ShuntWeb, :live_view

  alias Shunt.Events
  alias Shunt.Players
  alias Shunt.Web
  alias Shunt.Web.Rumor
  alias ShuntWeb.Chrome

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    {:ok,
     socket
     |> assign(:player_id, player_id)
     |> assign(:player, player)
     |> assign(:rumors, player_rumors(player))
     |> assign(:selected, MapSet.new())
     |> assign(:active_event_id, nil)
     |> assign(:status, nil)}
  end

  def handle_event("toggle_rumor", %{"id" => id}, socket) do
    selected = socket.assigns.selected

    new_selected =
      if MapSet.member?(selected, id),
        do: MapSet.delete(selected, id),
        else: MapSet.put(selected, id)

    {:noreply, assign(socket, :selected, new_selected)}
  end

  def handle_event("investigate", _params, socket) do
    player = socket.assigns.player
    selected_ids = MapSet.to_list(socket.assigns.selected)

    case Web.resolve_theory(player, selected_ids) do
      {:no_match, nil} ->
        {:noreply, assign(socket, :status, "NO MATCHING INVESTIGATION · keep looking")}

      {_outcome, event_id} ->
        {:ok, player, _meta} =
          Players.dispatch(socket.assigns.player_id, &Events.start(&1, event_id))

        {:noreply,
         socket
         |> assign(:player, player)
         |> assign(:active_event_id, event_id)
         |> assign(:status, nil)}
    end
  end

  def handle_event("event_choice", %{"event_id" => event_id, "choice" => choice}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Events.choose(&1, event_id, choice)) do
      {:ok, player, _meta} ->
        completed? = not Map.has_key?(player.event_state, event_id)

        socket =
          socket
          |> assign(:player, player)
          |> assign(:rumors, player_rumors(player))

        socket =
          if completed?,
            do: socket |> assign(:active_event_id, nil) |> assign(:selected, MapSet.new()),
            else: socket

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("clear", _params, socket) do
    {:noreply, socket |> assign(:selected, MapSet.new()) |> assign(:status, nil)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:web} status={@status}>
      <Chrome.section_header>INVESTIGATION BOARD</Chrome.section_header>

      <%= if @active_event_id do %>
        <% step = Events.current_step(@player, @active_event_id) %>
        <Chrome.panel id="active-event">
          <p class="event-step-text">{String.trim(step.text)}</p>
          <div class="event-choices">
            <button
              :for={choice <- step.choices}
              id={"active-event-choice-#{String.replace(choice.label, " ", "-")}"}
              class="btn-ghost event-choice-button"
              phx-click="event_choice"
              phx-value-event_id={@active_event_id}
              phx-value-choice={choice.label}
            >
              [ {choice.label} ]
            </button>
          </div>
        </Chrome.panel>
      <% end %>

      <%= if @rumors == [] do %>
        <Chrome.panel id="board-empty">
          <p class="board-empty-text">
            NO RUMORS COLLECTED · explore, talk, and hack to gather intelligence
          </p>
        </Chrome.panel>
      <% else %>
        <div id="rumor-collection">
          <div class="rumor-grid">
            <div
              :for={rumor <- @rumors}
              id={"rumor-#{rumor.id}"}
              class={["rumor-card", MapSet.member?(@selected, rumor.id) && "selected"]}
              phx-click="toggle_rumor"
              phx-value-id={rumor.id}
            >
              <p class="rumor-title">{rumor.title}</p>
              <p class="rumor-source">{rumor.source}</p>
              <div :if={rumor.tags != []} class="rumor-tags">
                <span :for={tag <- rumor.tags} class="rumor-tag">{tag}</span>
              </div>
            </div>
          </div>
        </div>

        <div id="theory-controls" class="theory-controls">
          <Chrome.btn
            id="investigate-button"
            variant={if(MapSet.size(@selected) >= 2, do: :primary, else: :dead)}
            phx-click="investigate"
          >
            [ INVESTIGATE ]
          </Chrome.btn>
          <Chrome.btn id="clear-button" variant={:ghost} phx-click="clear">
            [ CLEAR ]
          </Chrome.btn>
        </div>

        <%= if @status do %>
          <div id="status-bar" class="status-bar">{@status}</div>
        <% end %>
      <% end %>
    </Layouts.app>
    """
  end

  defp player_rumors(player) do
    Enum.map(player.rumors, &Rumor.fetch!/1)
  end
end
