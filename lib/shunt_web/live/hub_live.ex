defmodule ShuntWeb.HubLive do
  use ShuntWeb, :live_view

  alias Shunt.Fencing
  alias Shunt.Fencing.Catalog
  alias Shunt.Npcs
  alias Shunt.Npcs.Loyalty
  alias Shunt.Npcs.Signals
  alias Shunt.Players
  alias ShuntWeb.Chrome

  def mount(_params, _session, socket) do
    if connected?(socket), do: Signals.subscribe()
    player_id = Players.get_player!().id
    player = Players.current(player_id)
    {:ok, socket |> assign(player_id: player_id) |> assign(:status, nil) |> assign_player(player)}
  end

  def handle_info({:npc_met, npc_key}, socket) do
    {:noreply, put_flash(socket, :info, "You've met #{Npcs.get!(npc_key).name}.")}
  end

  def handle_info({:loyalty_band_changed, npc_key, _old_band, new_band}, socket) do
    name = Npcs.get!(npc_key).name

    message =
      case new_band do
        :favored -> "#{name} has come to trust you."
        :hostile -> "#{name} no longer trusts you."
        :neutral -> "#{name}'s trust in you has steadied."
      end

    {:noreply, put_flash(socket, :info, message)}
  end

  def handle_event("lay_low", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Players.lay_low/1) do
      {:ok, player, _meta} ->
        status =
          "LAY LOW // #{delta(socket.assigns.player, player, :cred)} CRED // HEAT #{delta(socket.assigns.player, player, :heat)}"

        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, :insufficient_cred} ->
        {:noreply, socket}
    end
  end

  def handle_event("find_lead", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Fencing.find_lead/1) do
      {:ok, player, _meta} ->
        status = "LEAD ACQUIRED // #{Catalog.fetch!(player.current_offer_key).name}"
        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, :offer_in_progress} ->
        {:noreply, socket}
    end
  end

  def handle_event("take_offer", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Fencing.take_offer/1) do
      {:ok, player, _meta} ->
        item = Catalog.fetch!(player.held_item_key)
        scrip_delta = delta(socket.assigns.player, player, :scrip)
        status = "STASHED // #{item.name} // #{scrip_delta} SCRIP"
        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("pass_offer", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Fencing.pass_offer/1) do
      {:ok, player, _meta} ->
        status = "LEAD BURNED // nothing changes hands"
        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("sell_item", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Fencing.sell_held_item/1) do
      {:ok, player, meta} ->
        name = Catalog.fetch!(socket.assigns.player.held_item_key).name
        scrip_delta = delta(socket.assigns.player, player, :scrip)
        heat_delta = delta(socket.assigns.player, player, :heat)
        status = "FENCED // #{name} // +#{scrip_delta} SCRIP // HEAT +#{heat_delta}"

        {:noreply,
         socket
         |> assign(:status, status)
         |> flash_heat_event(meta.heat_event)
         |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("flesh_tithe", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Npcs.flesh_tithe/1) do
      {:ok, player, meta} ->
        scrip_delta = delta(socket.assigns.player, player, :scrip)
        heat_delta = delta(socket.assigns.player, player, :heat)
        status = "MOTHER GRAFT // stitched a deal // +#{scrip_delta} SCRIP // HEAT +#{heat_delta}"

        {:noreply,
         socket
         |> assign(:status, status)
         |> flash_heat_event(meta.heat_event)
         |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("move_goods", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Npcs.move_goods/1) do
      {:ok, player, _meta} ->
        name = Catalog.fetch!(socket.assigns.player.held_item_key).name
        scrip_delta = delta(socket.assigns.player, player, :scrip)
        status = "ROOK // moved #{name} // +#{scrip_delta} SCRIP"
        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("look_the_other_way", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Npcs.look_the_other_way/1) do
      {:ok, player, _meta} ->
        heat_delta = delta(socket.assigns.player, player, :heat)
        status = "NINE-IRON // sensor wiped // HEAT #{heat_delta}"
        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("data_drop", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Npcs.data_drop/1) do
      {:ok, player, _meta} ->
        cred_delta = delta(socket.assigns.player, player, :cred)
        status = "SPLICE // data dropped // +#{cred_delta} CRED"
        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("settle_the_books", _params, socket) do
    case Players.dispatch(socket.assigns.player_id, &Npcs.settle_the_books/1) do
      {:ok, player, _meta} ->
        scrip_delta = delta(socket.assigns.player, player, :scrip)
        status = "TALLY // books settled // +#{scrip_delta} SCRIP"
        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:hub} status={@status}>
      <%!-- TODO: once Chrome.section_header gets its `secondary` attr (staged in
        chrome.ex), pass secondary="0x1A · FENCE_PROTOCOL" here (docs/design-comp.html
        line 108). --%>
      <Chrome.section_header>BLACK_MARKET</Chrome.section_header>
      <div class="black-market-grid">
        <%!-- TODO: offer panel chrome (docs/design-comp.html lines 115-164): a top amber
          dashed accent strip (absolute-positioned span, background:repeating-linear-
          gradient(90deg, var(--amber) 0 9px, ... 9px 18px)), a ">> INTERCEPTED LEAD"
          header row with a blinking red dot (reuse the `.utility-strip-rec`-style blink
          animation) + a muted signal-strength glyph ("||||·|||·||||·|·|||"), and in the
          `@offer != nil` branch a colored tier badge (cyan/amber/red border+text by
          @offer.tier — CLEAN/WARM/HOT) plus a 3-up buy/fence/heat stat strip (each stat:
          muted label above a value, divided by 1px gaps, background var(--sunk))
          replacing the current bare `<p>Buy: {@offer.buy_cost} Scrip</p>`. In the
          `@offer == nil` empty state, add the "awaiting handshake" line with a blinking
          `_` cursor before the button (docs/design-comp.html line 161; the comp's button
          reads "[ PULL LEAD ]" vs. this code's "[ FIND A LEAD ]" — confirm the copy
          change with the user before renaming it, since hub_live_test.exs asserts on the
          current label). --%>
        <Chrome.panel id="offer-panel">
          <%= if @offer == nil do %>
            <Chrome.btn id="find-lead-button" variant={:primary} phx-click="find_lead">
              [ FIND A LEAD ]
            </Chrome.btn>
          <% else %>
            <div id="current-offer">
              <p>{@offer.name}</p>
              <span>{@offer.tier}</span>
              <p>{@offer.offer_text}</p>
              <p>Buy: {@offer.buy_cost} Scrip</p>
              <Chrome.btn
                id="take-offer-button"
                variant={if(@player.scrip < @offer.buy_cost, do: :dead, else: :primary)}
                phx-click="take_offer"
              >
                [ TAKE IT ]
              </Chrome.btn>
              <Chrome.btn id="pass-offer-button" variant={:ghost} phx-click="pass_offer">
                [ PASS ]
              </Chrome.btn>
            </div>
          <% end %>
        </Chrome.panel>

        <%!-- TODO: stash panel chrome (docs/design-comp.html lines 166-187): a
          "▓ STASH // 1 SLOT" header above the cond, and when `@held == nil` a
          dashed/hatched empty-state box (border:1px dashed var(--border-c);
          background:repeating-linear-gradient(45deg, ...)) containing "[ ]" and "EMPTY ·
          take a lead to hold stock" (replacing having no empty-state markup at all today).
          When `@held != nil`, keep the existing held-item content unchanged. --%>
        <Chrome.panel id="stash-panel">
          <%= if @held == nil do %>
            <p>Stash empty.</p>
          <% else %>
            <div id="held-item">
              <p>{@held.name}</p>
              <p>{@held.sell_text}</p>
              <p>Sell: {@held.sell_value} Scrip · +{@held.heat_cost} Heat</p>
              <Chrome.btn id="sell-item-button" variant={:primary} phx-click="sell_item">
                [ MOVE IT ]
              </Chrome.btn>
            </div>
          <% end %>

          <p>Lay Low — 10 Cred, -20 Heat</p>
          <Chrome.btn
            id="lay-low-button"
            variant={if(@player.cred < 10, do: :dead, else: :ghost)}
            phx-click="lay_low"
          >
            [ LAY LOW ]
          </Chrome.btn>
        </Chrome.panel>
      </div>

      <%!-- TODO: once Chrome.section_header gets its `secondary` attr, pass
        secondary="5 DOSSIERS · USE WISELY" here (docs/design-comp.html line 193). --%>
      <Chrome.section_header>CONTACTS</Chrome.section_header>
      <%!-- TODO: wrap this `:for` div in a grid container — change the outer element to
        `<div class="contacts-grid">` with CSS `display:grid;
        grid-template-columns:repeat(auto-fill, minmax(290px,1fr)); gap:12px;` in app.css
        (docs/design-comp.html line 197 — this is the second instance of the
        originally-reported bug: NPC panels currently stack full-width). The `:for` can
        move onto this same div (Phoenix allows `:for` directly on the grid container) or
        stay on a child — keep whichever keeps `id={"npc-\#{npc.key}"}` on each panel. --%>
      <div :for={npc <- @npcs} id={"npc-#{npc.key}"}>
        <%!-- TODO: add NPC panel chrome (docs/design-comp.html lines 199-217): a
          left-edge accent bar (absolute-positioned 3px-wide span, height:100%, colored by
          loyalty band — cyan >=60, amber >=35, red below) replacing the plain `<p>` name;
          the faction text rendered as a small colored pill (background = the loyalty
          color, dark text) instead of plain text; and a trust bar — a label row
          ("TRUST" / "{loyalty}/100 · {word}") above a thin colored fill bar (height:5px,
          border, background var(--sunk)) — replacing the bare
          `<p>Loyalty: {npc.loyalty}/100</p>`. Reuse the heat-bar's color-ramp pattern
          (cyan/amber/red) for both the accent bar and the trust-bar fill. --%>
        <Chrome.panel>
          <p>{npc.name}</p>
          <p>{humanize_faction(npc.faction)}</p>
          <p>Loyalty: {npc.loyalty}/100</p>
          <div :for={action <- npc.trade_actions}>
            <p><span>{action.name}</span> — {action.description}</p>
          </div>
          <%= cond do %>
            <% npc.key == "mother_graft" -> %>
              <Chrome.btn
                id="trade-flesh-tithe-button"
                variant={
                  if(Map.get(@player.inventory, "cracked_bone_plate", 0) < 1,
                    do: :dead,
                    else: :primary
                  )
                }
                phx-click="flesh_tithe"
              >
                [ FLESH TITHE ]
              </Chrome.btn>
            <% npc.key == "rook" -> %>
              <Chrome.btn
                id="trade-move-goods-button"
                variant={if(is_nil(@player.held_item_key), do: :dead, else: :primary)}
                phx-click="move_goods"
              >
                [ MOVE GOODS ]
              </Chrome.btn>
            <% npc.key == "nine_iron" -> %>
              <Chrome.btn
                id="trade-look-the-other-way-button"
                variant={if(@player.scrip < 20, do: :dead, else: :primary)}
                phx-click="look_the_other_way"
              >
                [ LOOK THE OTHER WAY ]
              </Chrome.btn>
            <% npc.key == "splice" -> %>
              <Chrome.btn
                id="trade-data-drop-button"
                variant={if(@player.scrip < 20, do: :dead, else: :primary)}
                phx-click="data_drop"
              >
                [ DATA DROP ]
              </Chrome.btn>
            <% npc.key == "tally" -> %>
              <Chrome.btn
                id="trade-settle-the-books-button"
                variant={if(@player.cred < 1, do: :dead, else: :primary)}
                phx-click="settle_the_books"
              >
                [ SETTLE THE BOOKS ]
              </Chrome.btn>
            <% true -> %>
          <% end %>
        </Chrome.panel>
      </div>
    </Layouts.app>
    """
  end

  defp assign_player(socket, player) do
    socket
    |> assign(:player, player)
    |> assign(:offer, catalog_item(player.current_offer_key))
    |> assign(:held, catalog_item(player.held_item_key))
    |> assign(:npcs, Enum.map(Npcs.list(), &Map.put(&1, :loyalty, Loyalty.value(player, &1.key))))
  end

  defp catalog_item(nil), do: nil
  defp catalog_item(key), do: Catalog.fetch!(key)

  defp flash_heat_event(socket, nil), do: socket

  defp flash_heat_event(socket, event) do
    put_flash(
      socket,
      :error,
      "#{event.name} — #{event.flavor_text} (-#{event.scrip_loss} Scrip, -#{event.cred_loss} Cred)"
    )
  end

  defp delta(before, after_, field), do: Map.get(after_, field) - Map.get(before, field)

  defp humanize_faction(faction) do
    faction
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
