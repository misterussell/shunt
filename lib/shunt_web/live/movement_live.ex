defmodule ShuntWeb.MovementLive do
  use ShuntWeb, :live_view

  alias Shunt.Movement
  alias Shunt.Players
  alias Shunt.World
  alias ShuntWeb.Chrome

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    {:ok,
     socket |> assign(player_id: player_id) |> assign(:status, nil) |> assign_location(player)}
  end

  def handle_event("move_to", %{"destination" => destination}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Movement.move(&1, destination)) do
      {:ok, player, meta} ->
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
