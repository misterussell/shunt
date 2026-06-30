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

  The frontend pass renders these five sections as a physical space: a rack of installed
  equipment (`#installed-modules`, one rack unit per owned module — a standard list that scales
  as modules grow), a wall-mounted Bleed meter with a vertical reservoir gauge (`#bleed`), and an
  off-site acquisitions rail (`#module-catalog` + `#relocate`). All visual rules live in
  assets/css/app.css (`.hideout-*`); the section ids and phx-click/phx-value contracts above are
  the stable surface the tests rely on.
  """
  use ShuntWeb, :live_view

  alias Shunt.Players
  alias Shunt.Territory

  # The reservoir accrues with real time, so a page left open goes stale. Re-derive on this cadence
  # to keep the pooled scrip — and the Heat a collect will cost — truthful, so a collect never
  # spikes more Heat than the page last showed.
  @refresh_interval :timer.seconds(30)

  @impl true
  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)

    if player.location_id == player.premises_id do
      if connected?(socket), do: :timer.send_interval(@refresh_interval, self(), :refresh)

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
    bleed = Territory.bleed(player, now)

    socket
    |> assign(:player, player)
    |> assign(:premises_name, premises_name(player))
    |> assign(:tier_n, tier_n)
    |> assign(:tier_name, tier_name)
    |> assign(:premises_class, Territory.premises_class(player))
    |> assign(:income_rate, bleed.rate)
    |> assign(:reservoir, bleed.reservoir)
    |> assign(:reservoir_cap, bleed.cap)
    |> assign(:reservoir_pct, Territory.reservoir_pct(bleed.reservoir, bleed.cap))
    |> assign(:projected_heat, bleed.heat)
    |> assign(:available_modules, Territory.available_modules(player))
    |> assign(:available_relocations, Territory.available_relocations(player))
  end

  defp premises_name(player) do
    case Territory.premises(player) do
      {:ok, location} -> location.name
      :error -> "Unknown"
    end
  end

  @impl true
  def handle_info(:refresh, socket) do
    # Nothing about the player changed — only elapsed accrual — so re-derive from the held player at
    # the current time (no DB read) to advance the reservoir/Heat readout.
    {:noreply, assign_hideout(socket, socket.assigns.player)}
  end

  @impl true
  def handle_event("collect", _params, socket) do
    now = now()

    case Players.dispatch(socket.assigns.player_id, &Territory.collect(&1, now)) do
      {:ok, player, meta} ->
        {:noreply, socket |> assign_hideout(player) |> put_flash(:info, collect_flash(meta))}

      {:error, :nothing_to_collect} ->
        {:noreply, put_flash(socket, :info, "Nothing pooled yet.")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, error_message(reason))}
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
        <div class="hideout-topbar">
          <.link navigate={~p"/map"} id="hideout-exit" class="hideout-exit">
            ← Back to the street
          </.link>
        </div>

        <div class="hideout-layout">
          <%!-- LEFT: the room you stand in. --%>
          <div class="hideout-stage">
            <%!-- 1. IDENTITY: who you are now. The premises placard. --%>
            <section id="hideout-identity" class="hideout-placard">
              <span class="hideout-placard-eyebrow">Premises</span>
              <p class="hideout-premises-name">{@premises_name}</p>
              <p class="hideout-placard-line">
                Tier {@tier_n}: <span id="hideout-tier">{@tier_name}</span>
                <span class="hideout-class">· class {@premises_class} premises</span>
              </p>
            </section>

            <div class="hideout-room-wrap">
              <%!-- 3. INSTALLED: the "guts" you've added, as a rack of equipment. A standard,
                scalable list — one rack unit per owned module; grows downward, no fixed slots. --%>
              <section id="installed-modules" class="hideout-rack">
                <span class="hideout-rack-label">Installed // Rack</span>
                <p :if={@player.modules == []} class="hideout-rack-empty">
                  Bare walls. Nothing installed yet.
                </p>
                <div :if={@player.modules != []} class="hideout-rack-list">
                  <div :for={key <- @player.modules} id={"installed-#{key}"} class="hideout-rack-unit">
                    <span class="hideout-unit-glyph">{fixture_glyph(key)}</span>
                    <span class="hideout-unit-name">{fixture_label(key)}</span>
                    <span class="hideout-unit-tag">installed</span>
                  </div>
                </div>
              </section>

              <%!-- 2. THE BLEED: income reservoir + collect — a meter on the wall. The vertical
                reservoir gauge fills to @reservoir_pct; @projected_heat warns of the cost of
                collecting before the click. The collect button only exists when something is pooled. --%>
              <section id="bleed" class="hideout-bleed">
                <span class="hideout-bleed-eyebrow">The Bleed</span>
                <%= if @income_rate > 0 do %>
                  <div class="hideout-reservoir">
                    <div class="hideout-reservoir-fill" style={"--fill: #{@reservoir_pct}"}></div>
                    <span class="hideout-reservoir-pct">{@reservoir_pct}%</span>
                  </div>
                  <p id="bleed-reservoir" class="hideout-bleed-readout">
                    {@reservoir} <span class="hideout-bleed-sep">/</span> {@reservoir_cap}
                    <span class="hideout-bleed-unit">scrip pooled</span>
                  </p>
                  <p class="hideout-bleed-rate">+{@income_rate} scrip/hr</p>
                  <%= if @reservoir > 0 do %>
                    <p class="hideout-bleed-warn">
                      Collecting now spikes Heat by <span
                        id="bleed-projected-heat"
                        class="hideout-bleed-heat"
                      >{@projected_heat}</span>.
                    </p>
                    <button id="bleed-collect" phx-click="collect" class="btn-primary hideout-collect">
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
            </div>
          </div>

          <%!-- RIGHT: the off-site acquisitions rail. --%>
          <div class="hideout-rail">
            <%!-- 4. CATALOG: buyable vs locked modules. :buyable+affordable gets the buy button;
              the other states render as desaturated, un-actionable rows. Each keeps id="module-<key>". --%>
            <section id="module-catalog" class="hideout-acq">
              <span class="hideout-acq-title">Upgrades // Installable</span>
              <p :if={@available_modules == []} class="hideout-muted">
                Nothing left to bolt in. You're running the full kit.
              </p>
              <div
                :for={entry <- @available_modules}
                id={"module-#{entry.module.id}"}
                class="hideout-acq-item"
                data-state={state_css(catalog_state(entry))}
              >
                <p class="hideout-acq-name">{entry.module.name}</p>
                <p class="hideout-acq-desc">{entry.module.description}</p>
                <div class="hideout-acq-foot">
                  <span class="hideout-cost">{cost_label(entry.module.cost)}</span>
                  <%= case catalog_state(entry) do %>
                    <% :ready -> %>
                      <button
                        id={"buy-module-#{entry.module.id}"}
                        phx-click="buy_module"
                        phx-value-key={entry.module.id}
                        class="btn-ghost"
                      >
                        [ Install ]
                      </button>
                    <% :short -> %>
                      <span class="hideout-locked">Can't afford it.</span>
                    <% :locked_class -> %>
                      <span class="hideout-locked">Needs a bigger place — relocate first.</span>
                    <% _ -> %>
                      <span class="hideout-locked">Locked.</span>
                  <% end %>
                </div>
              </div>
            </section>

            <%!-- 5. RELOCATE: premises you can move up into. Shows cost + the class it unlocks;
              higher rungs you can't reach yet read as dim, aspirational rows. Each keeps
              id="relocation-<location_id>"; the move button is id="relocate-<location_id>". --%>
            <section id="relocate" class="hideout-acq">
              <span class="hideout-acq-title">Relocate // Move Up</span>
              <p :if={@available_relocations == []} class="hideout-muted">
                Nothing bigger within reach. Build out what you've got.
              </p>
              <div
                :for={entry <- @available_relocations}
                id={"relocation-#{entry.location.id}"}
                class="hideout-acq-item"
                data-state={state_css(relocate_state(entry))}
              >
                <p class="hideout-acq-name">{entry.location.name}</p>
                <p class="hideout-acq-desc">Unlocks class {entry.unlocks_class}.</p>
                <div class="hideout-acq-foot">
                  <span class="hideout-cost">{cost_label(entry.cost)}</span>
                  <%= case relocate_state(entry) do %>
                    <% :ready -> %>
                      <button
                        id={"relocate-#{entry.location.id}"}
                        phx-click="relocate"
                        phx-value-to={entry.location.id}
                        class="btn-ghost"
                      >
                        [ Relocate Here ]
                      </button>
                    <% :short -> %>
                      <span class="hideout-locked">Can't afford the move.</span>
                    <% _ -> %>
                      <span class="hideout-locked">Locked.</span>
                  <% end %>
                </div>
              </div>
            </section>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  # Presentation-only helpers for the floorplan fixtures: a readable name and a glyph from the
  # raw module key (player.modules holds only keys). Unmapped keys degrade to the humanized key.
  defp fixture_label(key),
    do: key |> String.split("_") |> Enum.map_join(" ", &String.capitalize/1)

  defp fixture_glyph("stash"), do: "▣"
  defp fixture_glyph("latticework_bleed"), do: "◈"
  defp fixture_glyph("drop_point"), do: "▤"
  defp fixture_glyph(_key), do: "▪"

  # Presentation state for an acquisitions-rail card, derived once from (status, affordable?). Both
  # the data-state CSS hook and the template's button/message branch read these, so the ready/short/
  # locked rule lives in one place.
  defp catalog_state(%{status: :buyable, affordable?: true}), do: :ready
  defp catalog_state(%{status: :buyable}), do: :short
  defp catalog_state(%{status: :locked_class}), do: :locked_class
  defp catalog_state(_entry), do: :locked

  defp relocate_state(%{status: :available, affordable?: true}), do: :ready
  defp relocate_state(%{status: :available}), do: :short
  defp relocate_state(_entry), do: :locked

  # The cyan/dim CSS treatment only distinguishes ready/short from everything locked.
  defp state_css(:ready), do: "ready"
  defp state_css(:short), do: "short"
  defp state_css(_state), do: "locked"

  # Human-readable cost (e.g. "40 scrip", "150 scrip · 20 cred"). Pure formatting helper.
  defp cost_label(cost) do
    [{:scrip, "scrip"}, {:cred, "cred"}]
    |> Enum.map(fn {key, label} -> {Map.get(cost, key, 0), label} end)
    |> Enum.filter(fn {amount, _label} -> amount > 0 end)
    |> Enum.map_join(" · ", fn {amount, label} -> "#{amount} #{label}" end)
  end
end
