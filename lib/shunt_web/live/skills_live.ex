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
        <Chrome.section_header secondary="⚠ DRAWS HEAT" secondary_amber>
          SCAVENGE
        </Chrome.section_header>
        <Chrome.panel class="scavenge-grid">
          <div class="scavenge-left">
            <p class="scavenge-description">
              Comb the district gutters for raw stock. Every run trips a sensor — Heat climbs.
            </p>
            <Chrome.btn id="scavenge-button" variant={:primary} phx-click="scavenge">
              [ SCAVENGE ]
            </Chrome.btn>
            <div class="scavenge-output">
              &gt; output: 1 unit / run<span class="scavenge-output-cursor">_</span>
            </div>
          </div>
          <div class="scavenge-right">
            <div class="raw-materials-label">RAW MATERIALS · BIN</div>
            <div class="raw-materials-grid">
              <div :for={raw <- @raws} id={"raw-#{raw.key}"} class="raw-material-chip">
                <span class="raw-material-name">{raw.name}</span>
                <span class={[
                  "raw-material-count",
                  Map.get(@player.inventory, raw.key, 0) > 0 && "raw-material-count--owned"
                ]}>
                  ×{Map.get(@player.inventory, raw.key, 0)}
                </span>
              </div>
            </div>
          </div>
        </Chrome.panel>

        <Chrome.section_header secondary="DECRYPTED BY TIER">RECIPES</Chrome.section_header>
        <div class="recipes-list">
          <div :for={recipe <- @recipes} id={"recipe-#{recipe.key}"}>
            <%= if @current_tier < recipe.tier_required do %>
              <div class="recipe-row recipe-row--locked">
                <span class="recipe-tier-chip recipe-tier-chip--locked">T{recipe.tier_required}</span>
                <span class="recipe-redacted-name">█████ ███</span>
                <span class="recipe-encrypted-label">🔒 ENCRYPTED</span>
              </div>
            <% else %>
              <div class="recipe-row">
                <span class="recipe-tier-chip">T{recipe.tier_required}</span>
                <div class="recipe-info">
                  <div class="recipe-name">{recipe.name}</div>
                  <div class="recipe-req">
                    {recipe.inputs
                    |> Enum.map_join("   +   ", fn {raw_key, qty} ->
                      "◇ #{qty}× #{RawCatalog.fetch!(raw_key).name}"
                    end)}
                  </div>
                </div>
                <span class="recipe-value">+{recipe.sell_value}cr</span>
                <Chrome.btn
                  id={"assemble-#{recipe.key}-button"}
                  variant={
                    if(
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
              </div>
            <% end %>
          </div>
        </div>

        <Chrome.section_header secondary="BENCH OUTPUT">ASSEMBLED</Chrome.section_header>
        <%!-- TODO: restructure assembled goods (docs/design-comp.html lines 319-336).
          When at least one recipe has `Map.get(@player.inventory, recipe.key, 0) > 0`:
          wrap the `:for` in a `<div class="assembled-grid">` (CSS: display:grid;
          grid-template-columns:repeat(auto-fill, minmax(228px,1fr)); gap:9px;) and
          replace the per-item `Chrome.panel` with a compact row (flex,
          justify-content:space-between, padding:13px 15px, bordered) — name + "+{value}
          cr" on the left, the existing `[ SELL ]` ghost button on the right. When NONE
          of the recipes have inventory > 0, render the "BENCH CLEAN · no product
          assembled" empty state (dashed border, hatched background) instead of nothing
          — today this section just renders an empty area with no empty-state markup. --%>
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
        <%!-- TODO: add stub-page chrome (docs/design-comp.html lines 340-349): amber
          dashed accent bars along the top and bottom edges of the panel (absolute-
          positioned spans, background:repeating-linear-gradient(90deg, var(--amber) 0
          12px, ... 12px 24px)), restyle "⚠ DORMANT MODULE" as an amber bordered badge
          (letter-spacing:0.32em, padding:5px 13px, box-shadow glow) instead of plain
          text, center the content column with generous padding (54px 40px) and the
          existing hatched background, and append a closing line
          "// SIGNAL LOST · 0x00 · NO HANDSHAKE //" (muted/dim) after {@tree.stub} — plus
          the comp's fixed second line "This subsystem only tracks progression..." which
          isn't currently rendered at all (confirm with the user whether that generic
          line should be added verbatim or is superseded by each tree's own `@tree.stub`
          text). --%>
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
