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
  @dev_seed_rumors ~w(juno_supplier missing_shipments vex_debts authority_involvement freight_tunnel_shipments scrubbed_watchlist proxy_pipeline off_hours_passage cargo_discrepancy checkpoint_pressure)

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    {:ok,
     socket
     |> assign(:player_id, player_id)
     |> assign(:player, player)
     |> assign(:active_event_id, nil)
     # Ephemeral id of the rumor whose dossier is open in #board-dossier (nil = none). Resets on
     # navigate-away, like the working theory; board_assigns/1 derives the rumor + status from it.
     |> assign(:inspected_rumor_id, nil)
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

  # Fired by the inline [ CONNECT ] on a resonant cluster. Ignored when an event is already open
  # (re-clicking must not restart an in-progress event via Events.start) or when the cluster is no
  # longer resonant for this connection_id (a stale/duplicate client click — Enum.find would
  # otherwise return nil and crash the match).
  def handle_event("connect_theory", %{"connection_id" => connection_id}, socket) do
    resonant_conn =
      Enum.find(socket.assigns.resonant, fn {_cluster, conn} -> conn.id == connection_id end)

    case {socket.assigns.active_event_id, resonant_conn} do
      {nil, {_cluster, conn}} ->
        {:ok, player, _meta} =
          Players.dispatch(socket.assigns.player_id, &Events.start(&1, conn.success_event_id))

        {:noreply,
         socket
         |> assign(:player, player)
         |> assign(:active_event_id, conn.success_event_id)
         |> board_assigns()}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("event_choice", %{"event_id" => event_id, "choice" => choice}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Events.choose(&1, event_id, choice)) do
      {:ok, player, _meta} ->
        completed? = not Map.has_key?(player.event_state, event_id)

        socket = socket |> assign(:player, player) |> board_assigns()
        socket = if(completed?, do: assign(socket, :active_event_id, nil), else: socket)

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "That choice is no longer available.")}
    end
  end

  def handle_event("seed_rumors", _params, %{assigns: %{dev?: true}} = socket) do
    dispatch_board(socket, fn _p -> {:ok, Enum.map(@dev_seed_rumors, &{:rumor, &1})} end)
  end

  def handle_event("wipe_board", _params, %{assigns: %{dev?: true}} = socket) do
    dispatch_board(socket, &Web.wipe_board/1)
  end

  # The dev seed/wipe controls are hidden outside dev, but the channel still accepts the event;
  # ignore it server-side so it can't run in production.
  def handle_event(event, _params, socket) when event in ["seed_rumors", "wipe_board"] do
    {:noreply, socket}
  end

  # Opens the dossier for a held rumor. Ids the player doesn't hold are ignored (the client could
  # push any id; the board only recalls intel actually collected).
  def handle_event("inspect_rumor", %{"id" => id}, socket) do
    if id in socket.assigns.player.rumors do
      {:noreply, socket |> assign(:inspected_rumor_id, id) |> assign_inspected()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("close_dossier", _params, socket) do
    {:noreply, socket |> assign(:inspected_rumor_id, nil) |> assign_inspected()}
  end

  # Fired by [ FOLLOW LEAD ] on a lead-ready warm cluster. The lead is keyed on its cluster, not
  # the connection, since two warm sub-clusters can point at the same connection. Like
  # connect_theory/2 it ignores the click when an event is already open or when the named cluster
  # is no longer a lead-ready lead (stale/duplicate click, or a non-repeatable partial already
  # followed — warm_clusters drops lead_ready? once that partial is completed, so a re-click can't
  # reopen the finished event into a soft-lock).
  def handle_event("follow_lead", %{"lead_id" => lead_id}, socket) do
    lead = Enum.find(socket.assigns.warm, &(&1.key == lead_id))

    case {socket.assigns.active_event_id, lead} do
      {nil, %{lead_ready?: true, connection: conn}} ->
        {:ok, player, _meta} =
          Players.dispatch(socket.assigns.player_id, &Events.start(&1, conn.partial_event_id))

        {:noreply,
         socket
         |> assign(:player, player)
         |> assign(:active_event_id, conn.partial_event_id)
         |> board_assigns()}

      _ ->
        {:noreply, socket}
    end
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
        <% event = Events.get!(@active_event_id) %>
        <% step = Events.current_step(@player, @active_event_id) %>
        <Chrome.panel id="active-event" active>
          <div class="active-event-header">
            <span class="section-header-bracket">┌─[ {event.title} ]</span>
            <span class="section-header-rule"></span>
            <span class="section-header-secondary">[ ACTIVE ]</span>
            <span class="section-header-bracket">─┐</span>
          </div>
          <p class="active-event-text">{String.trim(step.text)}</p>
          <div class="active-event-choices">
            <button
              :for={choice <- step.choices}
              id={"active-event-choice-#{String.replace(choice.label, " ", "-")}"}
              class="btn-ghost active-event-choice"
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
        <div id="web-grid" class="web-grid">
          <div id="intake-rail" class="intake-rail">
            <div
              :for={rumor <- @intake}
              id={"intake-#{rumor.id}"}
              class="rumor-card intake-card"
              data-rumor-id={rumor.id}
            >
              <button
                type="button"
                class="inspect-glyph"
                data-inspect="true"
                phx-click="inspect_rumor"
                phx-value-id={rumor.id}
                aria-label="Inspect rumor"
              >
                ⓘ
              </button>
              <p class="rumor-title">{rumor.title}</p>
              <p class="rumor-source">{rumor.source}</p>
            </div>
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
              data-warm={to_string(card.warm)}
              data-solved={to_string(card.solved)}
            >
              <button
                type="button"
                class="inspect-glyph"
                data-inspect="true"
                phx-click="inspect_rumor"
                phx-value-id={card.rumor.id}
                aria-label="Inspect rumor"
              >
                ⓘ
              </button>
              <p class="rumor-title">{card.rumor.title}</p>
              <p class="rumor-source">{card.rumor.source}</p>
              <div :if={card.rumor.tags != []} class="rumor-tags">
                <span :for={tag <- card.rumor.tags} class="rumor-tag">{tag}</span>
              </div>
              <span :if={card.solved} class="rumor-stamp">SOLVED</span>
              <div :if={not card.solved} class="wire-port" data-port="true"></div>
            </div>
          </div>

          <div id="board-rail" class="board-rail">
            <div id="board-signals" class="board-signals">
              <div
                :if={@resonant != [] and is_nil(@active_event_id)}
                id="resonance-controls"
                class="resonance-controls"
              >
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
                :if={@warm != [] and is_nil(@active_event_id)}
                id="leads-controls"
                class="leads-controls"
              >
                <span class="leads-eyebrow">Leads</span>
                <div :for={lead <- @warm} id={"lead-#{lead.key}"} class="lead">
                  <div class="leads-meter">
                    <span
                      :for={i <- 1..lead.total}
                      class={["leads-dot", i <= lead.matched && "leads-dot--on"]}
                    >
                    </span>
                    <span class="leads-count">{lead.matched}/{lead.total}</span>
                    <span class="leads-short">{lead.short} short</span>
                  </div>
                  <Chrome.btn
                    :if={lead.lead_ready?}
                    id={"follow-lead-#{lead.key}"}
                    variant={:ghost}
                    phx-click="follow_lead"
                    phx-value-lead_id={lead.key}
                  >
                    [ FOLLOW LEAD ]
                  </Chrome.btn>
                </div>
              </div>
            </div>

            <div id="board-dossier" class="board-dossier">
              <%= if @inspected do %>
                <div class="dossier">
                  <div class="dossier-head">
                    <p class="dossier-title">{@inspected.title}</p>
                    <button
                      type="button"
                      class="dossier-close"
                      phx-click="close_dossier"
                      aria-label="Close dossier"
                    >
                      [ × ]
                    </button>
                  </div>
                  <div class="dossier-row">
                    <span class="dossier-eyebrow">Where</span>
                    <p class="dossier-text">
                      {@inspected.origin || humanize_source(@inspected.source)}
                    </p>
                  </div>
                  <div class="dossier-row">
                    <span class="dossier-eyebrow">What</span>
                    <p class="dossier-text">{@inspected.description}</p>
                  </div>
                  <div :if={@inspected.tags != []} class="dossier-row">
                    <span class="dossier-eyebrow">Tags</span>
                    <div class="rumor-tags">
                      <span :for={tag <- @inspected.tags} class="rumor-tag">{tag}</span>
                    </div>
                  </div>
                  <div class="dossier-row">
                    <span class="dossier-eyebrow">In play</span>
                    <p class="dossier-text">{status_label(@inspected_status)}</p>
                  </div>
                </div>
              <% else %>
                <p class="dossier-empty">SELECT ⓘ ON A RUMOR TO RECALL IT</p>
              <% end %>
            </div>
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

    {solved, resonant} =
      player
      |> Web.matched_clusters()
      |> Enum.split_with(fn {_cluster, conn} -> Web.solved?(player, conn) end)

    resonant_ids = cluster_ids(Enum.map(resonant, fn {cluster, _conn} -> cluster end))
    solved_ids = cluster_ids(Enum.map(solved, fn {cluster, _conn} -> cluster end))

    # Each warm lead is keyed on its cluster (sorted rumor ids), not the connection: two warm
    # sub-clusters can point at the same connection, so connection.id is not unique among leads.
    warm =
      player
      |> Web.warm_clusters()
      |> Enum.map(&Map.put(&1, :key, lead_key(&1.cluster)))

    warm_ids = cluster_ids(Enum.map(warm, & &1.cluster))

    placed =
      Enum.flat_map(Web.placed(player), fn {id, x, y} ->
        case Rumor.fetch(id) do
          {:ok, rumor} ->
            [
              %{
                rumor: rumor,
                x: x,
                y: y,
                resonant: MapSet.member?(resonant_ids, id),
                warm: MapSet.member?(warm_ids, id),
                solved: MapSet.member?(solved_ids, id)
              }
            ]

          :error ->
            []
        end
      end)

    socket
    |> assign(:rumors, player.rumors)
    |> assign(:intake, Enum.flat_map(Web.intake(player), &fetch_rumor/1))
    |> assign(:placed, placed)
    |> assign(:wires, Web.wires(player))
    |> assign(:resonant, resonant)
    |> assign(:warm, warm)
    |> assign(:solved_ids, solved_ids)
    |> assign(:resonant_ids, resonant_ids)
    |> assign_inspected()
  end

  # The dossier rumor + its live status, derived from the open id so the IN PLAY line tracks the
  # board while a dossier stays open. nil id (or removed content) falls back to the empty state.
  # Reads the board breakdown board_assigns already stored in assigns, so a dossier-only toggle
  # (inspect/close) refreshes the status without re-walking the board graph.
  defp assign_inspected(socket) do
    player = socket.assigns.player

    inspected =
      case socket.assigns[:inspected_rumor_id] do
        nil -> nil
        id -> fetch_rumor(id) |> List.first()
      end

    inspected_status =
      inspected &&
        Web.rumor_status(
          player,
          inspected.id,
          socket.assigns.solved_ids,
          socket.assigns.resonant_ids,
          socket.assigns.warm
        )

    socket
    |> assign(:inspected, inspected)
    |> assign(:inspected_status, inspected_status)
  end

  defp status_label(:not_placed), do: "Not placed"
  defp status_label(:on_board), do: "On the board"
  defp status_label({:forming, matched, total}), do: "Forming · #{matched}/#{total}"
  defp status_label(:resonant), do: "Resonant"
  defp status_label(:solved), do: "Solved"
  defp status_label(nil), do: ""

  defp humanize_source("npc"), do: "From a contact"
  defp humanize_source("latticework"), do: "Off the latticework"
  defp humanize_source("street"), do: "Word on the street"
  defp humanize_source(source) when is_binary(source), do: source
  defp humanize_source(_), do: "Source unknown"

  defp dispatch_board(socket, fun) do
    {:ok, player, _meta} = Players.dispatch(socket.assigns.player_id, fun)
    {:noreply, socket |> assign(:player, player) |> board_assigns()}
  end

  defp cluster_ids(clusters), do: Enum.reduce(clusters, MapSet.new(), &MapSet.union(&2, &1))

  # Disjoint clusters → the sorted member ids uniquely and stably identify each warm lead, so the
  # leads strip's DOM id (and follow_lead's handle) stay distinct even when two warm sub-clusters
  # target the same connection.
  defp lead_key(cluster), do: cluster |> Enum.sort() |> Enum.join("--")

  # Skips ids that no longer resolve to a rumor (renamed/removed content) instead of crashing.
  defp fetch_rumor(id) do
    case Rumor.fetch(id) do
      {:ok, rumor} -> [rumor]
      :error -> []
    end
  end

  defp clamp_unit(value), do: value |> parse_float() |> max(0.0) |> min(1.0)

  defp parse_float(value) when is_float(value), do: value

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _rest} -> float
      :error -> 0.0
    end
  end
end
