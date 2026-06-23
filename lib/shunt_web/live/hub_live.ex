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
      <Chrome.section_header secondary="0x1A · FENCE_PROTOCOL">BLACK_MARKET</Chrome.section_header>
      <div class="black-market-grid">
        <Chrome.panel id="offer-panel">
          <span class="offer-accent-strip"></span>
          <div class="offer-header">
            <span class="offer-header-dot"></span>
            <span class="offer-header-label">&gt;&gt; INTERCEPTED LEAD</span>
            <div class="flex-1"></div>
            <span class="offer-header-signal">||||·|||·||||·|·|||</span>
          </div>

          <%= if @offer == nil do %>
            <p class="offer-flavor-empty">
              The wire's dead air. Tap the darkline and see what's moving through Shunt 9 tonight.
            </p>
            <div class="offer-handshake">
              &gt; awaiting handshake<span class="offer-handshake-cursor">_</span>
            </div>
            <Chrome.btn id="find-lead-button" variant={:primary} phx-click="find_lead">
              [ FIND A LEAD ]
            </Chrome.btn>
          <% else %>
            <div id="current-offer">
              <div class="offer-header-row">
                <div>
                  <p class="offer-name">{@offer.name}</p>
                  <p class="offer-sku">SKU://{offer_sku(@offer.key)}</p>
                </div>
                <span class={["offer-tier-badge", "offer-tier-badge--#{@offer.tier}"]}>
                  {tier_label(@offer.tier)}
                </span>
              </div>
              <p class="offer-flavor">{@offer.offer_text}</p>
              <div class="offer-stat-strip">
                <div class="offer-stat">
                  <span class="offer-stat-label">BUY @</span>
                  <span class="offer-stat-value">{@offer.buy_cost}</span>
                </div>
                <div class="offer-stat">
                  <span class="offer-stat-label">FENCE @</span>
                  <span class="offer-stat-value offer-stat-value--cyan">{@offer.sell_value}</span>
                </div>
                <div class="offer-stat">
                  <span class="offer-stat-label">HEAT +</span>
                  <span class={["offer-stat-value", "offer-stat-value--#{@offer.tier}"]}>
                    {@offer.heat_cost}
                  </span>
                </div>
              </div>
              <% can_afford_offer = @player.scrip >= @offer.buy_cost %>
              <Chrome.btn
                id="take-offer-button"
                variant={if(can_afford_offer, do: :primary, else: :dead)}
                phx-click="take_offer"
              >
                {action_label(can_afford_offer, "TAKE IT", "CRED SHORT")}
              </Chrome.btn>
              <Chrome.btn id="pass-offer-button" variant={:ghost} phx-click="pass_offer">
                [ PASS ]
              </Chrome.btn>
            </div>
          <% end %>
        </Chrome.panel>

        <Chrome.panel id="stash-panel">
          <div class="stash-header">▓ STASH // 1 SLOT</div>
          <%= if @held == nil do %>
            <div class="stash-empty">
              <span class="stash-empty-glyph">[ ]</span>
              <span class="stash-empty-label">EMPTY · take a lead to hold stock</span>
            </div>
          <% else %>
            <div id="held-item">
              <div class="held-header-row">
                <p class="held-name">{@held.name}</p>
                <span class={["held-tier-badge", "held-tier-badge--#{@held.tier}"]}>
                  {tier_label(@held.tier)}
                </span>
              </div>
              <p class="held-flavor">{@held.sell_text}</p>
              <div class="held-value-row">
                <span class="held-value-label">STREET VALUE</span>
                <span class="held-value">
                  +{@held.sell_value} <span class="held-value-suffix">cr</span>
                </span>
                <span class="held-heat-note">+{@held.heat_cost} Heat</span>
              </div>
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

      <Chrome.section_header secondary="5 DOSSIERS · USE WISELY">CONTACTS</Chrome.section_header>
      <div class="contacts-grid">
        <Chrome.panel :for={npc <- @npcs} id={"npc-#{npc.key}"}>
          <span class={["npc-accent-bar", "npc-accent-bar--#{loyalty_band(npc.loyalty)}"]}></span>
          <p class="npc-name">{npc.name}</p>
          <span class={["npc-faction-pill", "npc-faction-pill--#{faction_color(npc.faction)}"]}>
            {humanize_faction(npc.faction)}
          </span>
          <div class="npc-trust-row">
            <span>TRUST</span>
            <span class={"npc-trust-value--#{loyalty_band(npc.loyalty)}"}>
              {npc.loyalty}/100 · {loyalty_word(npc.loyalty)}
            </span>
          </div>
          <div class="npc-trust-bar">
            <div
              class={["npc-trust-fill", "npc-trust-fill--#{loyalty_band(npc.loyalty)}"]}
              style={"width: #{npc.loyalty}%"}
            />
          </div>
          <div :for={action <- npc.trade_actions}>
            <p class="npc-action-text"><span>{action.name}</span> — {action.description}</p>
          </div>
          <%= cond do %>
            <% npc.key == "mother_graft" -> %>
              <% can_do = Map.get(@player.inventory, "cracked_bone_plate", 0) >= 1 %>
              <Chrome.btn
                id="trade-flesh-tithe-button"
                variant={if(can_do, do: :primary, else: :dead)}
                phx-click="flesh_tithe"
              >
                {action_label(can_do, "FLESH TITHE", "CAN'T PAY")}
              </Chrome.btn>
            <% npc.key == "rook" -> %>
              <% can_do = not is_nil(@player.held_item_key) %>
              <Chrome.btn
                id="trade-move-goods-button"
                variant={if(can_do, do: :primary, else: :dead)}
                phx-click="move_goods"
              >
                {action_label(can_do, "MOVE GOODS", "CAN'T PAY")}
              </Chrome.btn>
            <% npc.key == "nine_iron" -> %>
              <% can_do = @player.scrip >= 20 %>
              <Chrome.btn
                id="trade-look-the-other-way-button"
                variant={if(can_do, do: :primary, else: :dead)}
                phx-click="look_the_other_way"
              >
                {action_label(can_do, "LOOK THE OTHER WAY", "CAN'T PAY")}
              </Chrome.btn>
            <% npc.key == "splice" -> %>
              <% can_do = @player.scrip >= 20 %>
              <Chrome.btn
                id="trade-data-drop-button"
                variant={if(can_do, do: :primary, else: :dead)}
                phx-click="data_drop"
              >
                {action_label(can_do, "DATA DROP", "CAN'T PAY")}
              </Chrome.btn>
            <% npc.key == "tally" -> %>
              <% can_do = @player.cred >= 1 %>
              <Chrome.btn
                id="trade-settle-the-books-button"
                variant={if(can_do, do: :primary, else: :dead)}
                phx-click="settle_the_books"
              >
                {action_label(can_do, "SETTLE THE BOOKS", "CAN'T PAY")}
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

  defp action_label(true, label, _disabled_label), do: "[ #{label} ]"
  defp action_label(false, _label, disabled_label), do: "[ #{disabled_label} ]"

  defp tier_label(:hot), do: "HOT // HIGH RISK"
  defp tier_label(:warm), do: "WARM"
  defp tier_label(:clean), do: "CLEAN"

  defp offer_sku(key), do: key |> String.upcase() |> String.replace("_", "-")

  defp loyalty_band(loyalty), do: Loyalty.band_for(loyalty) |> band_color()

  defp band_color(:favored), do: "cyan"
  defp band_color(:neutral), do: "amber"
  defp band_color(:hostile), do: "red"

  defp faction_color(:fleshless), do: "red"
  defp faction_color(:latticework_collective), do: "green"
  defp faction_color(:syndicate_of_closed_hands), do: "amber"
  defp faction_color(:kaspav_authority), do: "cyan"

  defp loyalty_word(loyalty), do: Loyalty.band_for(loyalty) |> band_word()

  defp band_word(:favored), do: "SOLID"
  defp band_word(:neutral), do: "WARY"
  defp band_word(:hostile), do: "BURNED"
end
