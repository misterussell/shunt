defmodule ShuntWeb.WebLive do
  use ShuntWeb, :live_view

  alias Shunt.Events
  alias Shunt.Players
  alias Shunt.Web
  alias Shunt.Web.Rumor
  alias ShuntWeb.Chrome

  @dev_routes Application.compile_env(:shunt, :dev_routes)

  # Dev-only: the shunt9 rumor set seeded by the [ SEED RUMORS ] control so the board can be
  # exercised without replaying the events that normally award these rumors.
  @dev_seed_rumors ~w(juno_supplier missing_shipments vex_debts authority_involvement freight_tunnel_shipments)

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    # TODO: replace the tap-to-select model with board-derived assigns:
    #   :intake -> Web.intake(player) mapped to Rumor structs (unsorted rail)
    #   :placed -> positioned rumor structs carrying their fractional x/y from web_board
    #   :wires -> player.web_board wires
    #   :resonant -> Web.resonant_clusters(player) (drives cluster glow + inline CONNECT)
    # Drop :selected entirely. Add a board_assigns(socket) helper that recomputes intake/placed/
    # wires/resonant from the current player so every handle_event can refresh in one call.
    {:ok,
     socket
     |> assign(:player_id, player_id)
     |> assign(:player, player)
     |> assign(:rumors, player_rumors(player))
     |> assign(:selected, MapSet.new())
     |> assign(:active_event_id, nil)
     |> assign(:dev?, @dev_routes)
     |> assign(:status, nil)}
  end

  # TODO: replace "toggle_rumor"/"investigate"/"clear" below with the board interaction events.
  # The WebBoard hook pushes these; each dispatches the matching Shunt.Web op via Players.dispatch
  # and then refreshes board assigns:
  #   "place_rumor"  %{"id" => id, "x" => x, "y" => y}  -> Web.place_rumor/4 (intake -> board)
  #   "move_rumor"   %{"id" => id, "x" => x, "y" => y}  -> Web.move_rumor/4 (debounced on drag-end)
  #   "connect"      %{"a" => a, "b" => b}              -> Web.connect/3
  #   "disconnect"   %{"a" => a, "b" => b}              -> Web.disconnect/3
  #   "return_to_intake" %{"id" => id}                  -> Web.return_to_intake/2
  # x/y arrive as strings from JS — parse to floats and clamp to 0.0..1.0 before dispatching.

  # TODO: "connect_theory" %{"connection_id" => id} — fired by the inline [ CONNECT ] that appears on
  # a resonant cluster. Look up the connection in @resonant, dispatch &Events.start(&1, conn.success_
  # event_id), and set :active_event_id, mirroring the success branch of the old "investigate" handler.
  # Resonance already guarantees an exact match, so there is no NO-MATCH path here.

  def handle_event("seed_rumors", _params, socket) do
    {:ok, player, _meta} =
      Players.dispatch(socket.assigns.player_id, fn _p ->
        {:ok, Enum.map(@dev_seed_rumors, &{:rumor, &1})}
      end)

    {:noreply, socket |> assign(:player, player) |> assign(:rumors, player_rumors(player))}
  end

  # TODO: dev-only "wipe_board" — when @dev?, dispatch a Web op (or {:web_board, empty board}) that
  # resets web_board to %{"positions" => %{}, "wires" => []} so the UI can be re-tested from scratch.
  # Does not touch player.rumors — cards return to intake.

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

  # TODO: rework render for the board. Replace the .rumor-grid + theory-controls block with:
  #   - an INTAKE rail listing @intake cards (draggable onto the board)
  #   - a board container `<div id="web-board" phx-hook="WebBoard">` whose children are the @placed
  #     cards, each with id={"rumor-#{id}"}, data-rumor-id, data-x/data-y (fractional), and state
  #     attrs data-resonant / data-solved. The hook creates the SVG wire layer itself (do NOT render
  #     wires in HEEx) and reads @wires from a data attribute / pushed payload.
  #   - per-resonant-cluster inline [ CONNECT ] (phx-click="connect_theory", phx-value-connection_id),
  #     rendered only for clusters in @resonant
  #   - keep the empty-state panel for when @rumors == [] (NO RUMORS COLLECTED)
  #   - a `:if={@dev?}` control strip with [ SEED RUMORS ] (phx-click="seed_rumors") and
  #     [ WIPE BOARD ] (phx-click="wipe_board")
  # The active-event panel block stays as-is. No phx-update="ignore" on #web-board — the hook
  # re-applies layout in mounted()/updated() so server-added cards and state classes reconcile.
  # TODO: frontend-design styling pass is deferred until the mechanics above work — cyberpunk
  # case-graph surface, glowing fiber wires with a traveling pulse, resonance surge, SOLVED stamp.
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:web} status={@status}>
      <Chrome.section_header>INVESTIGATION BOARD</Chrome.section_header>

      <div :if={@dev?} id="dev-controls" class="dev-controls">
        <Chrome.btn id="seed-rumors-button" variant={:ghost} phx-click="seed_rumors">
          [ SEED RUMORS ]
        </Chrome.btn>
      </div>

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
