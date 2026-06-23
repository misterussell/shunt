defmodule ShuntWeb.MovementLive do
  use ShuntWeb, :live_view

  alias Shunt.Movement
  alias Shunt.Players
  alias Shunt.World
  alias ShuntWeb.Chrome

  # TODO: mount/3 — mirror HubLive.mount/3 (Players.get_player!().id, Players.current/1,
  # assign :player_id and :status), then call assign_location/2 (defined below) instead of
  # assign_player/2 to also populate :location and :exits

  # TODO: handle_event("move_to", %{"destination" => destination}, socket) —
  # Players.dispatch(socket.assigns.player_id, &Movement.move(&1, destination)):
  #   {:ok, player, meta} -> set :status to meta.narrative, re-run assign_location/2 with
  #     the new player
  #   {:error, :not_connected} -> {:noreply, socket} (defensive no-op, same pattern as every
  #     other handle_event in HubLive — the UI only ever offers connected destinations)

  # TODO: render/1 — <Layouts.app flash={@flash} player={@player} active={:map} status={@status}>
  # wrapping:
  #   - Chrome.section_header (e.g. "MAP")
  #   - Chrome.panel showing @location.name and @location.description
  #   - a plain list of @exits, one Chrome.btn per exit
  #     (phx-click="move_to" phx-value-destination={exit.to}, labeled with the destination
  #     location's name resolved via World.get_location(exit.to).name) — no custom CSS, no
  #     SVG graph (that's Phase 4)

  # TODO: private assign_location(socket, player) — assign(:player, player),
  # assign(:location, World.get_location(player.location_id)),
  # assign(:exits, World.exits(player.location_id))
end
