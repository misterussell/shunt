defmodule ShuntWeb.GhostworkLive do
  @moduledoc """
  The deck: the GHOSTWORK tab is the player's Ghostdeck. Switching here is "jacking
  in". Everything renders filtered by the player's current location_id — what the
  deck can see depends on where the body is (doc "The deck is the interaction
  surface"). Two-column cockpit: main = SCAN feed + NODES; rail = LOADOUT + CODEX.
  The ICE break opens the IceTerminal modal over the page.

  Presentation boundary: this view renders state and dispatches commands. Scan /
  begin_encounter / act / retreat all live in Shunt.Ghostwork and return the
  effects to dispatch (plus, for the encounter, the updated %Encounter{}); this
  view never computes Progress / Trace / outcomes itself.
  """
  use ShuntWeb, :live_view

  alias Shunt.Ghostwork
  alias Shunt.Players
  alias Shunt.Skills.Catalog, as: SkillsCatalog
  alias Shunt.World
  alias ShuntWeb.Chrome
  alias ShuntWeb.Components.IceTerminal

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    {:ok,
     socket
     |> assign(player_id: player_id)
     |> assign(:tree, SkillsCatalog.fetch!("ghostwork"))
     |> assign(:status, nil)
     |> assign(:encounter, nil)
     |> assign(:lattice_live?, true)
     |> stream(:signal_feed, [])
     |> assign_deck(player)}
  end

  def handle_event("scan", _params, socket) do
    location = World.get_location(socket.assigns.player.location_id)

    case Players.dispatch(socket.assigns.player_id, &Ghostwork.scan(&1, location)) do
      {:ok, player, meta} ->
        socket =
          if meta.kind == :empty,
            do: socket,
            else: stream_insert(socket, :signal_feed, signal_entry(meta), at: 0)

        {:noreply,
         socket
         |> flash_heat_event(Map.get(meta, :heat_event))
         |> assign(:status, "SCAN // #{String.upcase(to_string(meta.kind))}")
         |> assign(:lattice_live?, true)
         |> assign_deck(player)
         |> push_event("lattice:pulse", %{})}

      {:error, :no_deck} ->
        {:noreply,
         socket
         |> assign(:status, "NO DECK · acquire a ghostdeck to scan")
         |> assign(:lattice_live?, false)}

      {:error, :no_lattice} ->
        {:noreply,
         socket
         |> assign(:status, "NO LATTICE TRAFFIC HERE")
         |> assign(:lattice_live?, false)}
    end
  end

  def handle_event("break", %{"key" => node_id}, socket) do
    node = Ghostwork.IceNode.fetch!(node_id)

    resolver = fn player ->
      case Ghostwork.begin_encounter(player, node) do
        {:ok, encounter, effects} -> {:ok, effects, %{encounter: encounter}}
        {:error, reason} -> {:error, reason}
      end
    end

    case Players.dispatch(socket.assigns.player_id, resolver) do
      {:ok, player, meta} ->
        {:noreply, socket |> assign(:encounter, meta.encounter) |> assign_deck(player)}

      {:error, :hardened} ->
        {:noreply, assign(socket, :status, "#{node.name} HARDENED — cool off")}

      {:error, :already_cracked} ->
        {:noreply, assign(socket, :status, "#{node.name} already cracked")}
    end
  end

  def handle_event("act", %{"action" => action}, socket) do
    case socket.assigns.encounter do
      nil -> {:noreply, socket}
      encounter -> dispatch_act(socket, encounter, decode_action(action))
    end
  end

  def handle_event("retreat", _params, socket) do
    case socket.assigns.encounter do
      nil ->
        {:noreply, socket}

      encounter ->
        {:ok, updated, _effects} = Ghostwork.retreat(encounter)
        {:noreply, assign(socket, :encounter, updated)}
    end
  end

  def handle_event("close_encounter", _params, socket) do
    {:noreply, assign(socket, :encounter, nil)}
  end

  defp dispatch_act(socket, encounter, decoded) do
    resolver = fn player ->
      case Ghostwork.act(encounter, player, decoded) do
        {:ok, updated, effects} -> {:ok, effects, %{encounter: updated}}
        {:error, reason} -> {:error, reason}
      end
    end

    case Players.dispatch(socket.assigns.player_id, resolver) do
      {:ok, player, meta} ->
        {:noreply, socket |> assign(:encounter, meta.encounter) |> assign_deck(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:ghostwork} status={@status}>
      <Chrome.ladder_track tree={@tree} current_tier={@current_tier} />

      <IceTerminal.ice_modal
        :if={@encounter}
        id="ice-modal"
        encounter={@encounter}
        programs={@programs}
      />

      <div id="deck-tether" class="deck-tether">
        <span class="deck-tether-dot" aria-hidden="true">◉</span>
        <span class="deck-tether-state">JACKED IN</span>
        <span class="deck-tether-at">@ {@location.name}</span>
        <span class="deck-tether-rule"></span>
        <span class="deck-tether-exposed">{node_count_label(@nodes)}</span>
      </div>

      <div id="ghostwork-deck" class="ghostwork-page-grid">
        <div class="ghostwork-main">
          <Chrome.section_header secondary="⚠ DRAWS HEAT" secondary_amber>
            SCAN
          </Chrome.section_header>
          <Chrome.panel id="scan-panel">
            <div
              id="lattice-carrier"
              class={["lattice-carrier", !@lattice_live? && "lattice-carrier--flat"]}
              phx-hook="LatticeCarrier"
              role="img"
              aria-label={
                if @lattice_live?,
                  do: "local lattice carrier: live",
                  else: "local lattice carrier: no traffic"
              }
            >
              <svg
                class="lattice-carrier-trace"
                viewBox="0 0 240 24"
                preserveAspectRatio="none"
                aria-hidden="true"
              >
                <path
                  class="lattice-carrier-wave"
                  d="M0 12 q15 -4 30 0 q15 4 30 0 q15 -4 30 0 q15 4 30 0 q15 -4 30 0 q15 4 30 0 q15 -4 30 0 q15 4 30 0 q15 -4 30 0 q15 4 30 0 q15 -4 30 0 q15 4 30 0 q15 -4 30 0 q15 4 30 0 q15 -4 30 0 q15 4 30 0"
                />
                <path class="lattice-carrier-flatline" d="M0 12 H110 M118 12 H122 M130 12 H240" />
              </svg>
            </div>
            <p class="ghostwork-scan-line">
              Jack a probe into the local lattice and skim for stray signals.
            </p>
            <Chrome.btn id="scan-button" variant={:primary} phx-click="scan">[ SCAN ]</Chrome.btn>
            <div id="signal-feed" class="ghostwork-signal-feed" phx-update="stream">
              <p id="signal-feed-empty" class="ghostwork-signal-empty hidden only:block">
                &gt; no signal intercepted
              </p>
              <p :for={{id, entry} <- @streams.signal_feed} id={id} class="ghostwork-signal-line">
                &gt; {entry.text}
              </p>
            </div>
          </Chrome.panel>

          <Chrome.section_header secondary="LOCATION-FILTERED">NODES</Chrome.section_header>
          <Chrome.panel id="nodes-panel">
            <p :if={@nodes == []} id="nodes-empty" class="ghostwork-empty">
              NO NODES IN RANGE · scan for signals
            </p>
            <div
              :for={%{node: node, status: status, read: read} <- @nodes}
              id={"node-#{node.id}"}
              class="ghostwork-node-row"
            >
              <div class="ghostwork-node-info">
                <span class="ghostwork-node-name">{node.name}</span>
                <span class="ghostwork-node-family">{node.family}</span>
                <span
                  id={"node-read-#{node.id}"}
                  class={["ghostwork-node-read", "ghostwork-node-read--#{read}"]}
                >
                  read · {fog_label(read)}
                </span>
              </div>
              <%= if status == :breakable do %>
                <Chrome.btn
                  id={"break-#{node.id}"}
                  variant={:primary}
                  phx-click="break"
                  phx-value-key={node.id}
                >
                  [ BREAK ]
                </Chrome.btn>
              <% else %>
                <span class="ghostwork-node-hardened">HARDENED — cool off</span>
              <% end %>
            </div>
          </Chrome.panel>
        </div>

        <div class="ghostwork-rail">
          <Chrome.section_header>LOADOUT</Chrome.section_header>
          <Chrome.panel id="loadout-panel">
            <p :if={@programs == []} id="loadout-empty" class="ghostwork-empty">
              NO PROGRAMS LOADED
            </p>
            <div :for={prog <- @programs} id={"program-#{prog.id}"} class="ghostwork-program-row">
              <span class="ghostwork-program-name">{prog.name}</span>
              <span class="ghostwork-program-action">{prog.action}</span>
              <span class="ghostwork-program-stats">P{prog.progress} / T{prog.trace}</span>
            </div>
          </Chrome.panel>

          <Chrome.section_header>CODEX</Chrome.section_header>
          <Chrome.panel id="codex-panel">
            <div class="ghostwork-codex-mastery">
              <p :if={@mastery == []} class="ghostwork-empty">NO ICE READ YET</p>
              <div :for={m <- @mastery} id={"mastery-#{m.family}"} class="ghostwork-mastery-row">
                <span class="ghostwork-mastery-family">{m.family}</span>
                <span class="ghostwork-mastery-cracks">cracked ×{m.cracks}</span>
                <span class="ghostwork-mastery-fog">fog: {fog_label(m.fog_stage)}</span>
              </div>
            </div>
          </Chrome.panel>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp decode_action("probe"), do: :probe
  defp decode_action("program:" <> id), do: {:program, id}
  defp decode_action(_), do: :unknown

  defp node_count_label([]), do: "no nodes exposed"
  defp node_count_label([_]), do: "1 node exposed"
  defp node_count_label(nodes), do: "#{length(nodes)} nodes exposed"

  defp fog_label(:dark), do: "dark"
  defp fog_label(:numbers), do: "P/T mapped"
  defp fog_label(:weakness), do: "weakness"

  defp signal_entry(meta) do
    %{id: System.unique_integer([:monotonic, :positive]), text: meta.text, kind: meta.kind}
  end

  defp assign_deck(socket, player) do
    socket
    |> assign(:player, player)
    |> assign(:location, World.get_location(player.location_id))
    |> assign(:current_tier, SkillsCatalog.current_tier(player, socket.assigns.tree))
    |> assign(:nodes, Ghostwork.nodes_at(player, player.location_id))
    |> assign(:programs, Ghostwork.Programs.owned(player))
    |> assign(:mastery, Ghostwork.mastery_summary(player))
  end

  defp flash_heat_event(socket, nil), do: socket

  defp flash_heat_event(socket, event) do
    put_flash(
      socket,
      :error,
      "#{event.name} — #{event.flavor_text} (-#{event.scrip_loss} Scrip, -#{event.cred_loss} Cred)"
    )
  end
end
