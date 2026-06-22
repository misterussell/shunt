defmodule ShuntWeb.DashboardLive do
  use ShuntWeb, :live_view

  alias Shunt.Crafting
  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Fencing
  alias Shunt.Fencing.Catalog
  alias Shunt.Npcs
  alias Shunt.Npcs.Loyalty
  alias Shunt.Players
  alias Shunt.Skills.Catalog, as: SkillsCatalog

  # TODO: Add `alias Shunt.Npcs.Loyalty` and `alias Shunt.Npcs.Signals` near the other
  # aliases above, and subscribe to NPC signals on mount:
  #   def mount(_params, _session, socket) do
  #     if connected?(socket), do: Signals.subscribe()
  #     {:ok, assign_player(socket, Players.get_player!())}
  #   end
  def mount(_params, _session, socket) do
    {:ok, assign_player(socket, Players.get_player!())}
  end

  # TODO: Add handle_info/2 clauses for the two NPC signals, flashing them like
  # flash_heat_event/2 does below (put_flash(socket, :info, ...) — these are good news/bad
  # news for the player, not Heat's penalty-flavored :error flashes):
  #   def handle_info({:npc_met, npc_key}, socket) do
  #     {:noreply, put_flash(socket, :info, "You've met #{Npcs.get!(npc_key).name}.")}
  #   end
  #
  #   def handle_info({:loyalty_band_changed, npc_key, _old_band, new_band}, socket) do
  #     name = Npcs.get!(npc_key).name
  #
  #     message =
  #       case new_band do
  #         :favored -> "#{name} has come to trust you."
  #         :hostile -> "#{name} no longer trusts you."
  #         :neutral -> "#{name}'s trust in you has steadied."
  #       end
  #
  #     {:noreply, put_flash(socket, :info, message)}
  #   end

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

  def handle_event("take_offer", _params, socket) do
    case Fencing.take_offer(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("pass_offer", _params, socket) do
    {:ok, player} = Fencing.pass_offer(socket.assigns.player)
    {:noreply, assign_player(socket, player)}
  end

  def handle_event("sell_item", _params, socket) do
    case Fencing.sell_held_item(socket.assigns.player) do
      {:ok, player, event} -> {:noreply, flash_heat_event(socket, event) |> assign_player(player)}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("scavenge", _params, socket) do
    {:ok, player, event} = Crafting.scavenge(socket.assigns.player)
    {:noreply, flash_heat_event(socket, event) |> assign_player(player)}
  end

  def handle_event("assemble", %{"key" => recipe_key}, socket) do
    case Crafting.assemble(socket.assigns.player, recipe_key) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("sell_assembled", %{"key" => item_key}, socket) do
    case Crafting.sell_assembled(socket.assigns.player, item_key) do
      {:ok, player, event} -> {:noreply, flash_heat_event(socket, event) |> assign_player(player)}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("flesh_tithe", _params, socket) do
    case Npcs.flesh_tithe(socket.assigns.player) do
      {:ok, player, event} -> {:noreply, flash_heat_event(socket, event) |> assign_player(player)}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("move_goods", _params, socket) do
    case Npcs.move_goods(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("look_the_other_way", _params, socket) do
    case Npcs.look_the_other_way(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("data_drop", _params, socket) do
    case Npcs.data_drop(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("settle_the_books", _params, socket) do
    case Npcs.settle_the_books(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, _reason} -> {:noreply, socket}
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
                <div class="flex gap-4">
                  <button
                    id="take-offer-button"
                    phx-click="take_offer"
                    class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                    disabled={@player.scrip < @offer.buy_cost}
                  >
                    Take It
                  </button>
                  <button
                    id="pass-offer-button"
                    phx-click="pass_offer"
                    class="px-4 py-2 rounded bg-gray-600 text-white hover:bg-gray-700"
                  >
                    Pass
                  </button>
                </div>
              </div>
            <% true -> %>
              <div id="held-item" class="space-y-2">
                <p class="font-semibold">{@held.name}</p>
                <p>{@held.sell_text}</p>
                <p>Sell: {@held.sell_value} Scrip · +{@held.heat_cost} Heat</p>
                <button
                  id="sell-item-button"
                  phx-click="sell_item"
                  class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
                >
                  Move It
                </button>
              </div>
          <% end %>
        </div>

        <div class="border border-gray-300 rounded-lg p-4 space-y-4">
          <div :for={tree <- @skill_trees} id={"skill-tree-#{tree.key}"} class="space-y-1">
            <p class="font-semibold">{tree.name}</p>
            <p class="text-sm text-gray-500">{tree.description}</p>
            <div class="flex gap-1">
              <div
                :for={tier <- tree.tiers}
                class={[
                  "w-6 h-2 rounded",
                  if(tier.tier <= SkillsCatalog.current_tier(@player, tree),
                    do: "bg-blue-600",
                    else: "bg-gray-200"
                  )
                ]}
              />
            </div>
            <p class="text-sm">{skill_tree_status(@player, tree)}</p>
          </div>
        </div>

        <div class="border border-gray-300 rounded-lg p-4 space-y-4">
          <div :for={npc <- @npcs} id={"npc-#{npc.key}"} class="space-y-1">
            <p class="font-semibold">{npc.name}</p>
            <p class="text-sm text-gray-500">{humanize_faction(npc.faction)}</p>
            <div>
              <p class="text-sm">Loyalty: {npc.loyalty}/100</p>
              <div class="w-full h-2 bg-gray-200 rounded">
                <div class="h-2 bg-blue-600 rounded" style={"width: #{npc.loyalty}%"}></div>
              </div>
            </div>
            <div :for={action <- npc.trade_actions}>
              <p class="text-sm">
                <span class="font-semibold">{action.name}</span> — {action.description}
              </p>
            </div>
            <%= cond do %>
              <% npc.key == "mother_graft" -> %>
                <button
                  id="trade-flesh-tithe-button"
                  phx-click="flesh_tithe"
                  class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  disabled={Map.get(@player.inventory, "cracked_bone_plate", 0) < 1}
                >
                  Flesh Tithe
                </button>
              <% npc.key == "rook" -> %>
                <button
                  id="trade-move-goods-button"
                  phx-click="move_goods"
                  class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  disabled={is_nil(@player.held_item_key)}
                >
                  Move Goods
                </button>
              <% npc.key == "nine_iron" -> %>
                <button
                  id="trade-look-the-other-way-button"
                  phx-click="look_the_other_way"
                  class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  disabled={@player.scrip < 20}
                >
                  Look the Other Way
                </button>
              <% npc.key == "splice" -> %>
                <button
                  id="trade-data-drop-button"
                  phx-click="data_drop"
                  class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  disabled={@player.scrip < 20}
                >
                  Data Drop
                </button>
              <% npc.key == "tally" -> %>
                <button
                  id="trade-settle-the-books-button"
                  phx-click="settle_the_books"
                  class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  disabled={@player.cred < 1}
                >
                  Settle the Books
                </button>
              <% true -> %>
            <% end %>
          </div>
        </div>

        <div class="border border-gray-300 rounded-lg p-4 space-y-4">
          <button
            id="scavenge-button"
            phx-click="scavenge"
            class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
          >
            Scavenge
          </button>

          <div class="space-y-1">
            <p class="font-semibold">Raw materials</p>
            <div :for={raw <- @raws}>
              <p
                :if={Map.get(@player.inventory, raw.key, 0) > 0}
                id={"raw-#{raw.key}"}
                class="text-sm"
              >
                {raw.name} ({Map.get(@player.inventory, raw.key, 0)})
              </p>
            </div>
          </div>

          <div class="space-y-2">
            <p class="font-semibold">Recipes</p>
            <div :for={recipe <- @recipes} id={"recipe-#{recipe.key}"} class="space-y-1">
              <p>
                <span class="font-semibold">{recipe.name}</span>
                <%= if @street_alchemy_tier < recipe.tier_required do %>
                  Locked
                <% else %>
                  Unlocked
                <% end %>
              </p>
              <p :for={{raw_key, qty} <- recipe.inputs} class="text-sm text-gray-500">
                {qty} x {RawCatalog.fetch!(raw_key).name} (owned: {Map.get(
                  @player.inventory,
                  raw_key,
                  0
                )})
              </p>
              <button
                id={"assemble-#{recipe.key}-button"}
                phx-click="assemble"
                phx-value-key={recipe.key}
                class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                disabled={
                  @street_alchemy_tier < recipe.tier_required or
                    Enum.any?(recipe.inputs, fn {raw_key, qty} ->
                      qty > Map.get(@player.inventory, raw_key, 0)
                    end)
                }
              >
                Assemble
              </button>
            </div>
          </div>

          <div class="space-y-1">
            <p class="font-semibold">Assembled goods</p>
            <div :for={recipe <- @recipes}>
              <div
                :if={Map.get(@player.inventory, recipe.key, 0) > 0}
                id={"assembled-#{recipe.key}"}
                class="text-sm flex items-center gap-2"
              >
                <p>
                  {recipe.name} ({Map.get(@player.inventory, recipe.key, 0)}) — {recipe.sell_value} Scrip
                </p>
                <button
                  id={"sell-assembled-#{recipe.key}-button"}
                  phx-click="sell_assembled"
                  phx-value-key={recipe.key}
                  class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
                >
                  Sell
                </button>
              </div>
            </div>
          </div>
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
    |> assign(:skill_trees, SkillsCatalog.trees())
    |> assign(
      :street_alchemy_tier,
      SkillsCatalog.current_tier(player, SkillsCatalog.fetch!("street_alchemy"))
    )
    |> assign(:npcs, Enum.map(Npcs.list(), &Map.put(&1, :loyalty, Loyalty.value(player, &1.key))))
    |> assign(:raws, RawCatalog.items())
    |> assign(:recipes, RecipeCatalog.recipes())
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

  defp humanize_faction(faction) do
    faction
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp skill_tree_status(player, tree) do
    case SkillsCatalog.current_tier(player, tree) do
      0 -> "Locked"
      tier -> Enum.find(tree.tiers, &(&1.tier == tier)).name
    end
  end
end
