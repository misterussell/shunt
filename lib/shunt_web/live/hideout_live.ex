defmodule ShuntWeb.HideoutLive do
  @moduledoc """
  The Hideout — the interior of the player's premises (Territory ladder). A dedicated page so it
  can grow into a real interior (floorplan, inventory manager, visual module slots) later.
  See priv/docs/SHUNT_territory_ladder_v1.md §5.

  Access-gated in mount: only usable when the player is physically home
  (location_id == premises_id); otherwise it redirects to /map. Reached from the map's
  "Enter the Hideout" link.

  ## Structure (for the frontend pass)

  This module is intentionally a thin presentation shell over `Shunt.Territory`. ALL domain
  values are computed in the context and assigned in `assign_hideout/2` — the template never does
  game math (LiveView presentation boundary). The render is organised into five sections, each a
  top-level `<section>` with a stable DOM id the tests rely on. A frontend agent doing a UI pass
  should keep these ids and the phx-click/phx-value contracts, and is free to restyle freely:

    1. `#hideout-identity` — who you are now (tier, premises, class).
    2. `#bleed`            — the income reservoir + collect action (the flagship beat).
    3. `#installed-modules`— what you've installed.
    4. `#module-catalog`   — buyable vs locked modules.
    5. `#relocate`         — premises you can move up into.

  Markup here is deliberately minimal/functional (plain classes, no visual polish) — the styling,
  the reservoir gauge visualisation, locked-state treatment, and layout are the frontend pass's job.
  """
  use ShuntWeb, :live_view

  alias Shunt.Players
  alias Shunt.Territory

  @impl true
  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    if player.location_id == player.premises_id do
      {:ok,
       socket |> assign(:player_id, player_id) |> assign(:status, nil) |> assign_hideout(player)}
    else
      # Access gate: you must be standing at your premises to go inside.
      {:ok,
       socket
       |> put_flash(:error, "You need to be at your hideout to go inside.")
       |> redirect(to: ~p"/map")}
    end
  end

  # Second-precision UTC now. The :last_collected column is :utc_datetime (no microseconds), so
  # every `now` that can be persisted must be truncated to seconds. Captured at the edge and passed
  # into the pure context reads/resolvers.
  defp now, do: DateTime.truncate(DateTime.utc_now(), :second)

  # Recompute every derived value the page shows from the (freshly persisted) player. Called on
  # mount and after every successful command so the page always reflects current state.
  defp assign_hideout(socket, player) do
    now = now()
    {tier_n, tier_name} = Territory.tier(player)
    reservoir = Territory.reservoir(player, now)
    cap = Territory.reservoir_cap(player)

    socket
    |> assign(:player, player)
    |> assign(:premises_name, premises_name(player))
    |> assign(:tier_n, tier_n)
    |> assign(:tier_name, tier_name)
    |> assign(:premises_class, Territory.premises_class(player))
    |> assign(:income_rate, Territory.income_rate(player))
    |> assign(:reservoir, reservoir)
    |> assign(:reservoir_cap, cap)
    |> assign(:reservoir_pct, percent(reservoir, cap))
    |> assign(:projected_heat, Territory.projected_heat(player, now))
    |> assign(:available_modules, Territory.available_modules(player))
    |> assign(:available_relocations, Territory.available_relocations(player))
  end

  defp premises_name(player) do
    case Territory.premises(player) do
      {:ok, location} -> location.name
      :error -> "Unknown"
    end
  end

  defp percent(_value, 0), do: 0
  defp percent(value, cap), do: round(value / cap * 100)

  @impl true
  def handle_event("collect", _params, socket) do
    now = now()

    case Players.dispatch(socket.assigns.player_id, &Territory.collect(&1, now)) do
      {:ok, player, meta} ->
        {:noreply, socket |> assign_hideout(player) |> put_flash(:info, collect_flash(meta))}

      {:error, :nothing_to_collect} ->
        {:noreply, put_flash(socket, :info, "Nothing pooled yet.")}
    end
  end

  @impl true
  def handle_event("buy_module", %{"key" => key}, socket) do
    now = now()

    case Players.dispatch(socket.assigns.player_id, &Territory.install_module(&1, key, now)) do
      {:ok, player, _meta} ->
        {:noreply, socket |> assign_hideout(player) |> put_flash(:info, "Installed.")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, error_message(reason))}
    end
  end

  @impl true
  def handle_event("relocate", %{"to" => target_id}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Territory.relocate(&1, target_id)) do
      {:ok, player, _meta} ->
        {:noreply,
         socket |> assign_hideout(player) |> put_flash(:info, "You move your operation.")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, error_message(reason))}
    end
  end

  # Flash copy from command metadata — the context tells us what happened (meta.deltas /
  # meta.heat_event); the LiveView never reconstructs it from before/after state.
  defp collect_flash(%{heat_event: event}) when not is_nil(event),
    do: "You cash out — and #{event.name} lands on you."

  defp collect_flash(%{deltas: deltas}),
    do: "Skimmed #{Map.get(deltas, :scrip, 0)} scrip from the Latticework."

  defp error_message(:insufficient_scrip), do: "Not enough scrip."
  defp error_message(:insufficient_cred), do: "Not enough cred."
  defp error_message(:premises_class_too_low), do: "Your place isn't big enough — relocate first."
  defp error_message(:already_owned), do: "You already run that."
  defp error_message(:requirements_unmet), do: "You can't run that here yet."
  defp error_message(_reason), do: "That didn't work."

  @impl true
  def render(assigns) do
    # FRONTEND NOTE: keep the section ids and the phx-click / phx-value-* attributes; everything
    # else (classes, layout, copy, the reservoir gauge) is yours to redesign. See @moduledoc.
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:hideout} status={@status}>
      <div id="hideout" class="hideout">
        <.link navigate={~p"/map"} id="hideout-exit" class="hideout-exit">← Back to the street</.link>

        <%!-- 1. IDENTITY: who you are now. FRONTEND: this is the page's headline. --%>
        <section id="hideout-identity" class="hideout-identity">
          <p class="hideout-premises-name">{@premises_name}</p>
          <p>
            Tier {@tier_n}: <span id="hideout-tier">{@tier_name}</span>
            <span class="hideout-class">· class {@premises_class} premises</span>
          </p>
        </section>

        <%!-- 2. THE BLEED: income reservoir + collect. FRONTEND: the reservoir gauge (@reservoir /
          @reservoir_cap, @reservoir_pct) is the marquee visual; show @projected_heat as the cost
          of collecting BEFORE the click. The collect button only exists when something is pooled. --%>
        <section id="bleed" class="hideout-bleed">
          <h2>The Bleed</h2>
          <%= if @income_rate > 0 do %>
            <p id="bleed-reservoir">
              {@reservoir} / {@reservoir_cap} scrip pooled ({@reservoir_pct}%)
            </p>
            <p class="hideout-muted">+{@income_rate} scrip/hr</p>
            <%= if @reservoir > 0 do %>
              <p>
                Collecting now spikes Heat by <span id="bleed-projected-heat">{@projected_heat}</span>.
              </p>
              <button id="bleed-collect" phx-click="collect" class="btn-ghost">
                [ Collect Takings ]
              </button>
            <% else %>
              <p class="hideout-muted">Nothing pooled yet — give it time.</p>
            <% end %>
          <% else %>
            <p id="bleed-empty" class="hideout-muted">
              No income running. Install a bleed to start skimming the Latticework.
            </p>
          <% end %>
        </section>

        <%!-- 3. INSTALLED: the "guts" you've added. FRONTEND: this is where a visual floorplan /
          module slots could live later. Empty-state when nothing is installed. --%>
        <section id="installed-modules" class="hideout-installed">
          <h2>Installed</h2>
          <p :if={@player.modules == []} class="hideout-muted">Bare walls. Nothing installed yet.</p>
          <ul>
            <li :for={key <- @player.modules} id={"installed-#{key}"}>{key}</li>
          </ul>
        </section>

        <%!-- 4. CATALOG: buyable vs locked modules. FRONTEND: :buyable+affordable gets the buy
          button; :buyable-but-unaffordable, :locked_class ("relocate to unlock"), and :locked each
          want a distinct visual treatment. Every entry keeps id="module-<key>". --%>
        <section id="module-catalog" class="hideout-catalog">
          <h2>Upgrades</h2>
          <div
            :for={entry <- @available_modules}
            id={"module-#{entry.module.id}"}
            class="hideout-catalog-item"
          >
            <p class="hideout-catalog-name">{entry.module.name}</p>
            <p class="hideout-muted">{entry.module.description}</p>
            <p class="hideout-cost">{cost_label(entry.module.cost)}</p>
            <%= cond do %>
              <% entry.status == :buyable and entry.affordable? -> %>
                <button
                  id={"buy-module-#{entry.module.id}"}
                  phx-click="buy_module"
                  phx-value-key={entry.module.id}
                  class="btn-ghost"
                >
                  [ Install ]
                </button>
              <% entry.status == :buyable -> %>
                <p class="hideout-locked">Can't afford it.</p>
              <% entry.status == :locked_class -> %>
                <p class="hideout-locked">Needs a bigger place — relocate first.</p>
              <% true -> %>
                <p class="hideout-locked">Locked.</p>
            <% end %>
          </div>
        </section>

        <%!-- 5. RELOCATE: premises you can move up into. FRONTEND: show cost + the class it unlocks;
          higher rungs you can't reach yet are good "aspirational goal" UI. Each keeps
          id="relocation-<location_id>"; the move button is id="relocate-<location_id>". --%>
        <section id="relocate" class="hideout-relocate">
          <h2>Move Up</h2>
          <p :if={@available_relocations == []} class="hideout-muted">
            Nothing bigger within reach. Build out what you've got.
          </p>
          <div
            :for={entry <- @available_relocations}
            id={"relocation-#{entry.location.id}"}
            class="hideout-relocate-item"
          >
            <p class="hideout-catalog-name">{entry.location.name}</p>
            <p class="hideout-muted">Unlocks class {entry.unlocks_class}.</p>
            <p class="hideout-cost">{cost_label(entry.cost)}</p>
            <%= cond do %>
              <% entry.status == :available and entry.affordable? -> %>
                <button
                  id={"relocate-#{entry.location.id}"}
                  phx-click="relocate"
                  phx-value-to={entry.location.id}
                  class="btn-ghost"
                >
                  [ Relocate Here ]
                </button>
              <% entry.status == :available -> %>
                <p class="hideout-locked">Can't afford the move.</p>
              <% true -> %>
                <p class="hideout-locked">Locked.</p>
            <% end %>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  # Human-readable cost (e.g. "40 scrip", "150 scrip · 20 cred"). Pure formatting helper.
  defp cost_label(cost) do
    [{:scrip, "scrip"}, {:cred, "cred"}]
    |> Enum.map(fn {key, label} -> {Map.get(cost, key, 0), label} end)
    |> Enum.filter(fn {amount, _label} -> amount > 0 end)
    |> Enum.map_join(" · ", fn {amount, label} -> "#{amount} #{label}" end)
  end
end
