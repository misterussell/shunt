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

    {:ok,
     socket
     |> assign(:player_id, player_id)
     |> assign(:player, player)
     |> assign(:active_event_id, nil)
     |> assign(:dev?, @dev_routes)
     |> board_assigns()}
  end

  # Board interactions pushed by the WebBoard hook. x/y arrive as strings from JS; clamp_unit/1
  # parses them to floats in 0.0..1.0. place_rumor (intake -> board) and move_rumor (reposition)
  # are the same op — both just set positions[id].
  def handle_event(event, %{"id" => id, "x" => x, "y" => y}, socket)
      when event in ["place_rumor", "move_rumor"] do
    dispatch_board(socket, &Web.place_rumor(&1, id, clamp_unit(x), clamp_unit(y)))
  end

  def handle_event("connect", %{"a" => a, "b" => b}, socket) do
    dispatch_board(socket, &Web.connect(&1, a, b))
  end

  def handle_event("disconnect", %{"a" => a, "b" => b}, socket) do
    dispatch_board(socket, &Web.disconnect(&1, a, b))
  end

  def handle_event("return_to_intake", %{"id" => id}, socket) do
    dispatch_board(socket, &Web.return_to_intake(&1, id))
  end

  # Fired by the inline [ CONNECT ] on a resonant cluster. Resonance already guarantees an exact
  # match, so this always opens the connection's success event — there is no no-match path.
  def handle_event("connect_theory", %{"connection_id" => connection_id}, socket) do
    {_cluster, conn} =
      Enum.find(socket.assigns.resonant, fn {_cluster, conn} -> conn.id == connection_id end)

    {:ok, player, _meta} =
      Players.dispatch(socket.assigns.player_id, &Events.start(&1, conn.success_event_id))

    {:noreply,
     socket
     |> assign(:player, player)
     |> assign(:active_event_id, conn.success_event_id)
     |> board_assigns()}
  end

  def handle_event("event_choice", %{"event_id" => event_id, "choice" => choice}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Events.choose(&1, event_id, choice)) do
      {:ok, player, _meta} ->
        completed? = not Map.has_key?(player.event_state, event_id)

        socket = socket |> assign(:player, player) |> board_assigns()
        socket = if(completed?, do: assign(socket, :active_event_id, nil), else: socket)

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("seed_rumors", _params, socket) do
    dispatch_board(socket, fn _p -> {:ok, Enum.map(@dev_seed_rumors, &{:rumor, &1})} end)
  end

  def handle_event("wipe_board", _params, socket) do
    dispatch_board(socket, &Web.wipe_board/1)
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:web}>
      <Chrome.section_header>INVESTIGATION BOARD</Chrome.section_header>

      <div :if={@dev?} id="dev-controls" class="dev-controls">
        <Chrome.btn id="seed-rumors-button" variant={:ghost} phx-click="seed_rumors">
          [ SEED RUMORS ]
        </Chrome.btn>
        <Chrome.btn id="wipe-board-button" variant={:ghost} phx-click="wipe_board">
          [ WIPE BOARD ]
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
        <div id="intake-rail" class="intake-rail">
          <div
            :for={rumor <- @intake}
            id={"intake-#{rumor.id}"}
            class="rumor-card intake-card"
            data-rumor-id={rumor.id}
          >
            <p class="rumor-title">{rumor.title}</p>
            <p class="rumor-source">{rumor.source}</p>
          </div>
        </div>

        <div :if={@resonant != []} id="resonance-controls" class="resonance-controls">
          <span class="resonance-eyebrow">Resonance</span>
          <Chrome.btn
            :for={{_cluster, conn} <- @resonant}
            id={"connect-#{conn.id}"}
            variant={:primary}
            phx-click="connect_theory"
            phx-value-connection_id={conn.id}
          >
            [ CONNECT ]
          </Chrome.btn>
        </div>

        <div
          id="web-board"
          class="web-board"
          phx-hook="WebBoard"
          data-wires={Jason.encode!(@wires)}
        >
          <%!-- JS-owned wire layer: ignored so morphdom leaves the hook's drawn paths alone. --%>
          <svg id="wire-layer" class="wire-layer" phx-update="ignore"></svg>
          <p :if={@placed == []} class="board-hint">
            DRAG RUMORS HERE TO INVESTIGATE
          </p>
          <div
            :for={card <- @placed}
            id={"rumor-#{card.rumor.id}"}
            class="rumor-card board-card"
            data-rumor-id={card.rumor.id}
            data-x={card.x}
            data-y={card.y}
            data-resonant={to_string(card.resonant)}
            data-solved={to_string(card.solved)}
          >
            <p class="rumor-title">{card.rumor.title}</p>
            <p class="rumor-source">{card.rumor.source}</p>
            <div :if={card.rumor.tags != []} class="rumor-tags">
              <span :for={tag <- card.rumor.tags} class="rumor-tag">{tag}</span>
            </div>
            <span :if={card.solved} class="rumor-stamp">SOLVED</span>
          </div>
        </div>
      <% end %>
    </Layouts.app>
    """
  end

  # Recomputes every board-derived assign from the current player so each handle_event refreshes
  # in one call.
  defp board_assigns(socket) do
    player = socket.assigns.player
    resonant = Web.resonant_clusters(player)
    resonant_ids = cluster_ids(Enum.map(resonant, fn {cluster, _conn} -> cluster end))
    solved_ids = cluster_ids(Web.solved_clusters(player))

    placed =
      Enum.map(Web.placed(player), fn {id, x, y} ->
        %{
          rumor: Rumor.fetch!(id),
          x: x,
          y: y,
          resonant: MapSet.member?(resonant_ids, id),
          solved: MapSet.member?(solved_ids, id)
        }
      end)

    socket
    |> assign(:rumors, player.rumors)
    |> assign(:intake, Enum.map(Web.intake(player), &Rumor.fetch!/1))
    |> assign(:placed, placed)
    |> assign(:wires, Web.wires(player))
    |> assign(:resonant, resonant)
  end

  defp dispatch_board(socket, fun) do
    {:ok, player, _meta} = Players.dispatch(socket.assigns.player_id, fun)
    {:noreply, socket |> assign(:player, player) |> board_assigns()}
  end

  defp cluster_ids(clusters), do: Enum.reduce(clusters, MapSet.new(), &MapSet.union(&2, &1))

  defp clamp_unit(value), do: value |> parse_float() |> max(0.0) |> min(1.0)

  defp parse_float(value) when is_float(value), do: value

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _rest} -> float
      :error -> 0.0
    end
  end
end
