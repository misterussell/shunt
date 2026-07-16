defmodule ShuntWeb.WebLive do
  use ShuntWeb, :live_view

  alias Shunt.Events
  alias Shunt.Players
  alias Shunt.Web
  alias Shunt.Web.Rumor
  alias ShuntWeb.Chrome

  @dev_routes Application.compile_env(:shunt, :dev_routes)

  # Dev-only: the shunt9 rumor set seeded by [ SEED RUMORS ] so the network can be exercised
  # without replaying the events that normally award these rumors.
  @dev_seed_rumors ~w(juno_supplier missing_shipments vex_debts authority_involvement freight_tunnel_shipments vendor_squeeze protection_chits cook_supply_short)

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    {:ok,
     socket
     |> assign(:player_id, player_id)
     |> assign(:player, player)
     |> assign(:active_event_id, nil)
     |> assign(:dev?, @dev_routes)
     |> view_assigns()}
  end

  # Follows a lead (:lead -> partial_event) or cracks a case (:crack -> success_event). Web.pursue/3
  # is server-authoritative and prices the action in heat; we just dispatch it and open the event it
  # started. Ignored when an event is already open, the mode is unrecognized, or the player doesn't
  # qualify (a stale/duplicate click, or a forming case whose button isn't even rendered).
  def handle_event("pursue", %{"connection_id" => id, "mode" => mode}, socket) do
    with nil <- socket.assigns.active_event_id,
         {:ok, mode_atom} <- parse_mode(mode),
         {:ok, player, %{event_id: event_id}} <-
           Players.dispatch(socket.assigns.player_id, &Web.pursue(&1, id, mode_atom)) do
      {:noreply,
       socket
       |> assign(:player, player)
       |> assign(:active_event_id, event_id)
       |> view_assigns()}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("event_choice", %{"event_id" => event_id, "choice" => choice}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Events.choose(&1, event_id, choice)) do
      {:ok, player, _meta} ->
        completed? = not Map.has_key?(player.event_state, event_id)

        socket = socket |> assign(:player, player) |> view_assigns()
        socket = if(completed?, do: assign(socket, :active_event_id, nil), else: socket)

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "That choice is no longer available.")}
    end
  end

  def handle_event("seed_rumors", _params, %{assigns: %{dev?: true}} = socket) do
    {:ok, player, _meta} =
      Players.dispatch(socket.assigns.player_id, fn _p ->
        {:ok, Enum.map(@dev_seed_rumors, &{:rumor, &1})}
      end)

    {:noreply, socket |> assign(:player, player) |> view_assigns()}
  end

  # Hidden outside dev, but the channel still accepts the event; ignore it server-side.
  def handle_event("seed_rumors", _params, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:web}>
      <Chrome.section_header>THE WEB</Chrome.section_header>

      <div :if={@dev?} id="dev-controls" class="dev-controls">
        <Chrome.btn id="seed-rumors-button" variant={:ghost} phx-click="seed_rumors">
          [ SEED RUMORS ]
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

      <%= if @network == [] do %>
        <Chrome.panel id="web-empty">
          <p class="web-empty-text">
            NO SIGNAL YET · gather intel out in the world and the network surfaces its cases
          </p>
        </Chrome.panel>
      <% else %>
        <div id="signal-network" class="signal-network">
          <.case_card
            :for={entry <- @network}
            entry={entry}
            event_open?={not is_nil(@active_event_id)}
          />
        </div>
      <% end %>
    </Layouts.app>
    """
  end

  # One case in the network: progress, the intel you hold, redacted slots for what's missing, and
  # the heat-priced action (or a SOLVED stamp).
  attr :entry, :map, required: true
  attr :event_open?, :boolean, required: true

  defp case_card(assigns) do
    ~H"""
    <div id={"case-#{@entry.connection.id}"} class="case-card" data-status={@entry.status}>
      <div class="case-head">
        <span class="case-title">{humanize_id(@entry.connection.id)}</span>
        <span class="case-progress">{length(@entry.held)}/{@entry.total}</span>
        <span :if={@entry.status == :solved} class="case-stamp">SOLVED</span>
      </div>

      <ul :if={@entry.held_rumors != []} class="case-held">
        <li :for={rumor <- @entry.held_rumors} class="case-held-item">{rumor.title}</li>
      </ul>

      <ul :if={@entry.missing_hints != []} class="case-missing">
        <li :for={hint <- @entry.missing_hints} class="case-missing-item">
          <span class="case-redacted">▓▓▓▓</span>
          <span class="case-hint">{hint}</span>
        </li>
      </ul>

      <div :if={not @event_open?} class="case-actions">
        <Chrome.btn
          :if={@entry.status == :lead}
          id={"lead-#{@entry.connection.id}"}
          variant={:ghost}
          phx-click="pursue"
          phx-value-connection_id={@entry.connection.id}
          phx-value-mode="lead"
        >
          [ FOLLOW LEAD · +{@entry.connection.lead_heat} HEAT ]
        </Chrome.btn>
        <Chrome.btn
          :if={@entry.status == :crackable}
          id={"crack-#{@entry.connection.id}"}
          variant={:primary}
          phx-click="pursue"
          phx-value-connection_id={@entry.connection.id}
          phx-value-mode="crack"
        >
          [ CRACK · +{@entry.connection.crack_heat} HEAT ]
        </Chrome.btn>
      </div>
    </div>
    """
  end

  # Rebuilds the cases list from the current player.
  defp view_assigns(socket) do
    player = socket.assigns.player
    assign(socket, :network, player |> Web.network() |> Enum.map(&enrich/1))
  end

  # Decorates a network entry with the display data the case card needs: the held rumors as structs
  # (for titles) and an origin hint per missing rumor (where to go looking), skipping any id whose
  # content no longer resolves.
  defp enrich(entry) do
    entry
    |> Map.put(:held_rumors, Enum.flat_map(entry.held, &fetch_rumor/1))
    |> Map.put(:missing_hints, Enum.flat_map(entry.missing, &missing_hint/1))
  end

  defp fetch_rumor(id) do
    case Rumor.fetch(id) do
      {:ok, rumor} -> [rumor]
      :error -> []
    end
  end

  # The "where to look" line for a rumor you don't hold yet — its authored origin, or a humanized
  # source. Skipped entirely if the content is gone, so a stale id leaves no empty slot.
  defp missing_hint(id) do
    case Rumor.fetch(id) do
      {:ok, rumor} -> [rumor.origin || humanize_source(rumor.source)]
      :error -> []
    end
  end

  defp humanize_id(id), do: id |> String.split("_") |> Enum.map_join(" ", &String.capitalize/1)

  defp humanize_source("npc"), do: "From a contact"
  defp humanize_source("latticework"), do: "Off the latticework"
  defp humanize_source("street"), do: "Word on the street"
  defp humanize_source(source) when is_binary(source), do: source
  defp humanize_source(_), do: "Source unknown"

  defp parse_mode("crack"), do: {:ok, :crack}
  defp parse_mode("lead"), do: {:ok, :lead}
  defp parse_mode(_), do: :error
end
