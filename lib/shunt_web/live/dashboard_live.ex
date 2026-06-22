defmodule ShuntWeb.DashboardLive do
  use ShuntWeb, :live_view

  alias Shunt.Fencing
  alias Shunt.Fencing.Catalog
  alias Shunt.Players

  def mount(_params, _session, socket) do
    {:ok, assign_player(socket, Players.get_player!())}
  end

  def handle_event("lay_low", _params, socket) do
    case Players.lay_low(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, :insufficient_cred} -> {:noreply, socket}
    end
  end

  def handle_event("find_lead", _params, socket) do
    case Fencing.find_lead(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, :offer_in_progress} -> {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-6">
        <div class="border border-gray-300 rounded-lg p-4 space-y-2">
          <p id="resource-cred">Cred: {@player.cred}</p>
          <p id="resource-scrip">Scrip: {@player.scrip}</p>
          <div id="resource-heat">
            <p>Heat: {@player.heat}/100</p>
            <div class="w-full h-2 bg-gray-200 rounded">
              <div class="h-2 bg-red-500 rounded" style={"width: #{@player.heat}%"}></div>
            </div>
          </div>
        </div>

        <div class="border border-gray-300 rounded-lg p-4 space-y-3">
          <%= cond do %>
            <% @offer == nil and @held == nil -> %>
              <button
                id="find-lead-button"
                phx-click="find_lead"
                class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
              >
                Find a Lead
              </button>
            <% @offer != nil -> %>
              <div id="current-offer" class="space-y-2">
                <p class="font-semibold">{@offer.name}</p>
                <span class={[
                  "inline-block px-2 py-0.5 rounded text-xs",
                  @offer.tier == :clean && "bg-green-100",
                  @offer.tier == :warm && "bg-yellow-100",
                  @offer.tier == :hot && "bg-red-100"
                ]}>
                  {@offer.tier}
                </span>
                <p>{@offer.offer_text}</p>
                <p>Buy: {@offer.buy_cost} Scrip</p>
              </div>
            <% true -> %>
              <div id="held-item" class="space-y-2">
                <p class="font-semibold">{@held.name}</p>
                <p>{@held.sell_text}</p>
                <p>Sell: {@held.sell_value} Scrip · +{@held.heat_cost} Heat</p>
              </div>
          <% end %>
        </div>

        <div class="flex gap-4">
          <button
            id="lay-low-button"
            phx-click="lay_low"
            class="px-4 py-2 rounded bg-gray-600 text-white hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={@player.cred < 10}
          >
            Lay Low
          </button>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp assign_player(socket, player) do
    socket
    |> assign(:player, player)
    |> assign(:offer, catalog_item(player.current_offer_key))
    |> assign(:held, catalog_item(player.held_item_key))
  end

  defp catalog_item(nil), do: nil
  defp catalog_item(key), do: Catalog.fetch!(key)
end
