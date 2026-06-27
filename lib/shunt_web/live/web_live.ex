defmodule ShuntWeb.WebLive do
  use ShuntWeb, :live_view

  alias Shunt.Events
  alias Shunt.Players
  alias Shunt.Web
  alias Shunt.Web.Rumor
  alias ShuntWeb.Chrome

  # TODO: implement mount/3 — load player via Players.get_player!().id and Players.current/1.
  # Resolve player.rumors to %Rumor{} structs via Enum.map(player.rumors, &Rumor.fetch!/1).
  # Assign: :player_id, :player, :rumors (list of %Rumor{}), :selected (MapSet.new()),
  # :active_event_id (nil), :status (nil).

  # TODO: implement handle_event("toggle_rumor", %{"id" => id}, socket) —
  # if id in :selected, remove it; otherwise add it. No player dispatch. Update :selected assign.

  # TODO: implement handle_event("investigate", _params, socket) —
  # call Web.resolve_theory(socket.assigns.player, MapSet.to_list(socket.assigns.selected)).
  # On {:success | :partial | :failure, event_id}: dispatch Events.start via Players.dispatch/2,
  # derive the first step via Events.current_step/2, and assign :active_event_id to event_id.
  # On {:no_match, nil}: assign :status to "NO MATCHING INVESTIGATION · keep looking".
  # Reload player after dispatch via Players.current/1 and re-derive :rumors from player.rumors.

  # TODO: implement handle_event("event_choice", %{"event_id" => event_id, "choice" => choice}, socket) —
  # dispatch Events.choose via Players.dispatch/2. If the event is complete (event_id absent from
  # player.event_state), set :active_event_id to nil, reload player, re-derive :rumors, and
  # reset :selected to MapSet.new(). If incomplete, keep :active_event_id set.
  # Mirror the pattern in MovementLive.handle_event("event_choice", ...).

  # TODO: implement handle_event("clear", _params, socket) —
  # reset :selected to MapSet.new() and :status to nil. No player dispatch.

  # TODO: implement render/1 — wrap in <Layouts.app flash={@flash} player={@player} active={:web}>.
  # Board layout:
  #   - Section header: "INVESTIGATION BOARD"
  #   - Empty state panel (id="board-empty") when @rumors is []:
  #     "NO RUMORS COLLECTED · explore, talk, and hack to gather intelligence"
  #   - Rumor collection (id="rumor-collection") when @rumors is non-empty:
  #     One card per %Rumor{} (id="rumor-{rumor.id}"), showing title, source label, tags.
  #     phx-click="toggle_rumor" phx-value-id={rumor.id}.
  #     Selected state: add a neon accent border class when rumor.id in @selected.
  #   - Theory controls: "[ INVESTIGATE ]" button (id="investigate-button"),
  #     disabled when MapSet.size(@selected) < 2, phx-click="investigate".
  #     "[ CLEAR ]" button (id="clear-button"), phx-click="clear".
  #   - Active event panel (id="active-event") when @active_event_id is set:
  #     render the current event step and choices using the EventTerminal component
  #     or inline, mirroring MovementLive's event rendering pattern.
  #   - Status bar: show @status when set (same pattern as GhostworkLive).
end
