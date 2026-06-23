defmodule ShuntWeb.SkillsLive do
  use ShuntWeb, :live_view

  alias Shunt.Crafting
  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Players
  alias Shunt.Skills.Catalog, as: SkillsCatalog
  alias ShuntWeb.Chrome

  def mount(_params, _session, socket) do
    player_id = Players.get_player!().id
    player = Players.current(player_id)
    tree = SkillsCatalog.fetch!(Atom.to_string(socket.assigns.live_action))

    {:ok,
     socket
     |> assign(player_id: player_id)
     |> assign(:status, nil)
     |> assign(:tree, tree)
     |> assign_player(player)}
  end

  def handle_event("scavenge", _params, socket) do
    before_inventory = socket.assigns.player.inventory
    {:ok, player, meta} = Players.dispatch(socket.assigns.player_id, &Crafting.scavenge/1)

    {raw_key, _qty} =
      Enum.find(player.inventory, fn {key, qty} ->
        qty > Map.get(before_inventory, key, 0)
      end)

    heat_delta = delta(socket.assigns.player, player, :heat)
    raw_name = RawCatalog.fetch!(raw_key).name
    status = "SCAVENGED // 1x #{raw_name} // HEAT +#{heat_delta}"

    {:noreply,
     socket
     |> assign(:status, status)
     |> flash_heat_event(meta.heat_event)
     |> assign_player(player)}
  end

  def handle_event("assemble", %{"key" => recipe_key}, socket) do
    case Players.dispatch(socket.assigns.player_id, &Crafting.assemble(&1, recipe_key)) do
      {:ok, player, _meta} ->
        status = "ASSEMBLED // #{RecipeCatalog.fetch!(recipe_key).name} // bench output +1"
        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("sell_assembled", %{"key" => item_key}, socket) do
    recipe = RecipeCatalog.fetch!(item_key)

    case Players.dispatch(socket.assigns.player_id, &Crafting.sell_assembled(&1, item_key)) do
      {:ok, player, meta} ->
        scrip_delta = delta(socket.assigns.player, player, :scrip)
        heat_delta = delta(socket.assigns.player, player, :heat)
        status = "FENCED // #{recipe.name} // +#{scrip_delta} SCRIP // HEAT +#{heat_delta}"

        {:noreply,
         socket
         |> assign(:status, status)
         |> flash_heat_event(meta.heat_event)
         |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      player={@player}
      active={String.to_existing_atom(@tree.key)}
      status={@status}
    >
      <Chrome.ladder_track tree={@tree} current_tier={@current_tier} />

      <%= if @tree.key == "street_alchemy" do %>
        <Chrome.section_header>// SCAVENGE</Chrome.section_header>
        <Chrome.panel>
          <Chrome.btn id="scavenge-button" variant={:primary} phx-click="scavenge">
            [ SCAVENGE ]
          </Chrome.btn>
          <div :for={raw <- @raws}>
            <p :if={Map.get(@player.inventory, raw.key, 0) > 0} id={"raw-#{raw.key}"}>
              {raw.name} ({Map.get(@player.inventory, raw.key, 0)})
            </p>
          </div>
        </Chrome.panel>

        <Chrome.section_header>// RECIPES</Chrome.section_header>
        <div :for={recipe <- @recipes} id={"recipe-#{recipe.key}"}>
          <Chrome.panel>
            <p>
              <span>{recipe.name}</span>
              <%= if @current_tier < recipe.tier_required do %>
                Locked
              <% else %>
                Unlocked
              <% end %>
            </p>
            <p :for={{raw_key, qty} <- recipe.inputs}>
              {qty} x {RawCatalog.fetch!(raw_key).name} (owned: {Map.get(
                @player.inventory,
                raw_key,
                0
              )})
            </p>
            <Chrome.btn
              id={"assemble-#{recipe.key}-button"}
              variant={
                if(
                  @current_tier < recipe.tier_required or
                    Enum.any?(recipe.inputs, fn {raw_key, qty} ->
                      qty > Map.get(@player.inventory, raw_key, 0)
                    end),
                  do: :dead,
                  else: :primary
                )
              }
              phx-click="assemble"
              phx-value-key={recipe.key}
            >
              [ ASSEMBLE ]
            </Chrome.btn>
          </Chrome.panel>
        </div>

        <Chrome.section_header>// ASSEMBLED</Chrome.section_header>
        <div :for={recipe <- @recipes}>
          <div :if={Map.get(@player.inventory, recipe.key, 0) > 0} id={"assembled-#{recipe.key}"}>
            <Chrome.panel>
              <p>
                {recipe.name} ({Map.get(@player.inventory, recipe.key, 0)}) — {recipe.sell_value} Scrip
              </p>
              <Chrome.btn
                id={"sell-assembled-#{recipe.key}-button"}
                variant={:primary}
                phx-click="sell_assembled"
                phx-value-key={recipe.key}
              >
                [ SELL ]
              </Chrome.btn>
            </Chrome.panel>
          </div>
        </div>
      <% else %>
        <div id="skill-tree-stub">
          <Chrome.panel>
            <p>⚠ DORMANT MODULE</p>
            <p>{@tree.stub}</p>
          </Chrome.panel>
        </div>
      <% end %>
    </Layouts.app>
    """
  end

  defp assign_player(socket, player) do
    tree = socket.assigns.tree

    socket
    |> assign(:player, player)
    |> assign(:current_tier, SkillsCatalog.current_tier(player, tree))
    |> assign(:raws, RawCatalog.items())
    |> assign(:recipes, RecipeCatalog.recipes())
  end

  defp flash_heat_event(socket, nil), do: socket

  defp flash_heat_event(socket, event) do
    put_flash(
      socket,
      :error,
      "#{event.name} — #{event.flavor_text} (-#{event.scrip_loss} Scrip, -#{event.cred_loss} Cred)"
    )
  end

  defp delta(before, after_, field), do: Map.get(after_, field) - Map.get(before, field)
end
