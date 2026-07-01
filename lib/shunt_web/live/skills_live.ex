defmodule ShuntWeb.SkillsLive do
  use ShuntWeb, :live_view

  alias Shunt.ChromeMeat
  alias Shunt.Crafting
  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Implants
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
    {:ok, player, meta} = Players.dispatch(socket.assigns.player_id, &Crafting.scavenge/1)

    raw_name = RawCatalog.fetch!(meta.gained_raw).name
    status = "SCAVENGED // 1x #{raw_name} // HEAT +#{meta.deltas.heat}"

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
        status =
          "FENCED // #{recipe.name} // +#{meta.deltas.scrip} SCRIP // HEAT +#{meta.deltas.heat}"

        {:noreply,
         socket
         |> assign(:status, status)
         |> flash_heat_event(meta.heat_event)
         |> assign_player(player)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("fabricate", %{"key" => key}, socket) do
    case Players.dispatch(socket.assigns.player_id, &ChromeMeat.fabricate(&1, key)) do
      {:ok, player, _meta} ->
        status = "FABRICATED // #{Implants.fetch!(key).name} // ready to install"
        {:noreply, socket |> assign(:status, status) |> assign_player(player)}

      {:error, reason} ->
        status = "FABRICATION HALTED // #{reason |> to_string() |> String.upcase()}"
        {:noreply, assign(socket, :status, status)}
    end
  end

  def handle_event("install", %{"key" => key}, socket) do
    case Players.dispatch(socket.assigns.player_id, &ChromeMeat.install(&1, key)) do
      {:ok, player, meta} ->
        status =
          "GRAFTED // #{Implants.fetch!(key).name} // CHROME LOAD #{player.chrome_load}/100"

        {:noreply,
         socket
         |> assign(:status, status)
         |> flash_heat_event(meta.heat_event)
         |> assign_player(player)}

      {:error, reason} ->
        status = "INSTALL HALTED // #{reason |> to_string() |> String.upcase()}"
        {:noreply, assign(socket, :status, status)}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      player={@player}
      active={String.to_existing_atom(@tree.id)}
      status={@status}
    >
      <Chrome.ladder_track tree={@tree} current_tier={@current_tier} />

      <%= cond do %>
        <% @tree.id == "street_alchemy" -> %>
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
                <div :for={raw <- @raws} id={"raw-#{raw.id}"} class="raw-material-chip">
                  <span class="raw-material-name">{raw.name}</span>
                  <span class={[
                    "raw-material-count",
                    Map.get(@player.inventory, raw.id, 0) > 0 && "raw-material-count--owned"
                  ]}>
                    ×{Map.get(@player.inventory, raw.id, 0)}
                  </span>
                </div>
              </div>
            </div>
          </Chrome.panel>

          <Chrome.section_header secondary="DECRYPTED BY TIER">RECIPES</Chrome.section_header>
          <div class="recipes-list">
            <div :for={recipe <- @recipes} id={"recipe-#{recipe.id}"}>
              <%= if @current_tier < recipe.tier_required do %>
                <div class="recipe-row recipe-row--locked">
                  <span class="recipe-tier-chip recipe-tier-chip--locked">
                    T{recipe.tier_required}
                  </span>
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
                    id={"assemble-#{recipe.id}-button"}
                    variant={if(recipe.craftable?, do: :primary, else: :dead)}
                    phx-click="assemble"
                    phx-value-key={recipe.id}
                  >
                    [ ASSEMBLE ]
                  </Chrome.btn>
                </div>
              <% end %>
            </div>
          </div>

          <Chrome.section_header secondary="BENCH OUTPUT">ASSEMBLED</Chrome.section_header>
          <%= if Enum.any?(@recipes, &(Map.get(@player.inventory, &1.id, 0) > 0)) do %>
            <div class="assembled-grid">
              <div
                :for={recipe <- @recipes}
                :if={Map.get(@player.inventory, recipe.id, 0) > 0}
                id={"assembled-#{recipe.id}"}
                class="assembled-row"
              >
                <div>
                  <div class="assembled-name">{recipe.name}</div>
                  <div class="assembled-value">+{recipe.sell_value} cr</div>
                </div>
                <Chrome.btn
                  id={"sell-assembled-#{recipe.id}-button"}
                  variant={:ghost}
                  phx-click="sell_assembled"
                  phx-value-key={recipe.id}
                >
                  [ SELL ]
                </Chrome.btn>
              </div>
            </div>
          <% else %>
            <div id="assembled-empty-state">
              <span>BENCH CLEAN · no product assembled</span>
            </div>
          <% end %>
        <% @tree.id == "chrome_meat" -> %>
          <Chrome.section_header secondary="⚠ DRIFT TOWARD THE WIRE">
            CHROME LOAD
          </Chrome.section_header>
          <Chrome.panel>
            <div id="chrome-load" class={["chrome-load", "chrome-load--#{@chrome_band}"]}>
              <div class="chrome-load-value">
                {@player.chrome_load}<span class="chrome-load-max">/100</span>
              </div>
              <div class="chrome-load-bar">
                <div class="chrome-load-fill" style={"width: #{@player.chrome_load}%"}></div>
              </div>
              <div class="chrome-load-band">
                BAND · {@chrome_band |> to_string() |> String.upcase()}
              </div>
            </div>
          </Chrome.panel>

          <Chrome.section_header secondary="MEAT MADE MACHINE">AUGMENTS</Chrome.section_header>
          <div id="chrome-implants" class="implants-list">
            <div
              :for={entry <- @implants}
              id={"implant-#{entry.def.id}"}
              class={["implant-row", "implant-row--#{entry.state}"]}
            >
              <div class="implant-info">
                <div class="implant-name">{entry.def.name}</div>
                <div class="implant-load">◇ +{entry.def.chrome_load} load</div>
                <div :if={entry.state in [:fabricable, :needs_materials]} class="implant-req">
                  <span class="implant-req-label">FAB:</span>
                  <span
                    :for={inp <- entry.inputs}
                    class={[
                      "implant-req-item",
                      inp.owned < inp.needed && "implant-req-item--short"
                    ]}
                  >
                    ◇ {inp.name} {inp.owned}/{inp.needed}<span
                      :if={inp.owned < inp.needed and inp.source}
                      class="implant-req-source"
                    >· {inp.source}</span>
                  </span>
                </div>
              </div>
              <%= cond do %>
                <% entry.state == :installed -> %>
                  <span class="implant-status implant-status--installed">✓ GRAFTED</span>
                <% entry.state == :owned -> %>
                  <Chrome.btn
                    id={"install-#{entry.def.id}-button"}
                    variant={:primary}
                    phx-click="install"
                    phx-value-key={entry.def.id}
                  >
                    [ INSTALL ]
                  </Chrome.btn>
                <% entry.state == :fabricable -> %>
                  <Chrome.btn
                    id={"fabricate-#{entry.def.id}-button"}
                    variant={:ghost}
                    phx-click="fabricate"
                    phx-value-key={entry.def.id}
                  >
                    [ FABRICATE ]
                  </Chrome.btn>
                <% entry.state == :needs_materials -> %>
                  <span class="implant-status implant-status--needs">◇ NEED PARTS</span>
                <% true -> %>
                  <span class="implant-status implant-status--locked">🔒 NO SCHEMATIC</span>
              <% end %>
            </div>
          </div>
        <% true -> %>
          <div id="skill-tree-stub">
            <Chrome.panel class="hatch stub-panel">
              <span class="stub-accent-bar stub-accent-bar--top"></span>
              <span class="stub-accent-bar stub-accent-bar--bottom"></span>
              <span class="stub-badge">⚠ DORMANT MODULE</span>
              <p class="stub-tree-text">{@tree.stub}</p>
              <p class="stub-generic-line">
                This subsystem only tracks progression. No gameplay is wired to the tree yet — the deck's still missing parts. Crack the first tier and check back.
              </p>
              <span class="stub-footer">// SIGNAL LOST · 0x00 · NO HANDSHAKE //</span>
            </Chrome.panel>
          </div>
      <% end %>
    </Layouts.app>
    """
  end

  defp assign_player(socket, player) do
    tree = socket.assigns.tree

    recipes =
      Enum.map(
        RecipeCatalog.recipes(),
        &Map.put(&1, :craftable?, Crafting.craftable?(player, &1))
      )

    socket
    |> assign(:player, player)
    |> assign(:current_tier, SkillsCatalog.current_tier(player, tree))
    |> assign(:raws, RawCatalog.items())
    |> assign(:recipes, recipes)
    |> assign(:implants, ChromeMeat.catalog(player))
    |> assign(:chrome_band, ChromeMeat.band_for(player.chrome_load))
  end

  defp flash_heat_event(socket, nil), do: socket

  defp flash_heat_event(socket, event) do
    put_flash(
      socket,
      :error,
      "#{event.name} — #{event.flavor_text} (-#{event.scrip_loss} Scrip, -#{event.cred_loss} Cred)"
    )
  end
end
