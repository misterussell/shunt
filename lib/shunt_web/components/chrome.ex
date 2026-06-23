defmodule ShuntWeb.Chrome do
  @moduledoc """
  Shared "atoms" for Shunt's cyberpunk UI (the brief's §5 Core components): Panel, Button,
  SectionHeader, the per-tree progression Ladder track, and the persistent Wallet HUD.
  Reused across HubLive, SkillsLive, and the page shell in Layouts.app/1. All visual rules
  live in assets/css/app.css as classes — no inline `style="..."` attributes here.
  """
  use Phoenix.Component

  @doc """
  Surface panel: panel surface color + hairline border, optional corner-bracket accents
  when active/focused (HUD-reticle feel — brief §5 "Panel").

  ## Examples

      <.panel><p>content</p></.panel>
      <.panel active><p>focused content</p></.panel>
  """
  attr :id, :string, default: nil
  attr :active, :boolean, default: false
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def panel(assigns) do
    ~H"""
    <div id={@id} class={["panel", @active && "panel--active", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Rectangular button atom with three variants matching brief §5 "Button":
  `:primary` (fills with accent on hover/active), `:ghost` (muted border, used for secondary
  actions like "burn lead"/"fence"), and `:dead` (disabled — desaturated + hatched, not
  `opacity-50`). Label text should be the caller's literal uppercase bracketed text
  (e.g. "[ TAKE OFFER ]") to match the brief's terminal-button style.

  ## Examples

      <.btn variant={:primary} phx-click="take_offer">[ TAKE OFFER ]</.btn>
      <.btn variant={:dead} disabled>[ CRED SHORT ]</.btn>
  """
  attr :variant, :atom, values: [:primary, :ghost, :dead], default: :primary
  attr :rest, :global, include: ~w(phx-click phx-value-key disabled type)
  slot :inner_block, required: true

  def btn(assigns) do
    ~H"""
    <button class={"btn-#{@variant}"} disabled={@variant == :dead || nil} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  HUD-module section label with a thin horizontal rule, e.g. `// WALLET`, `// FENCING`,
  `// CONTACTS` (brief §5 "Section header").

  ## Examples

      <.section_header>BLACK_MARKET</.section_header>
  """
  attr :secondary, :string, default: nil
  attr :secondary_amber, :boolean, default: false
  slot :inner_block, required: true

  def section_header(assigns) do
    ~H"""
    <div class="section-header">
      <span class="section-header-bracket">┌─[ {render_slot(@inner_block)} ]</span>
      <span class="section-header-rule"></span>
      <span
        :if={@secondary}
        class={["section-header-secondary", @secondary_amber && "section-header-secondary--amber"]}
      >
        {@secondary}
      </span>
      <span class="section-header-bracket">─┐</span>
    </div>
    """
  end

  defp heat_label(heat) when heat >= 75, do: "⚠ AUTHORITY INBOUND"
  defp heat_label(heat) when heat >= 40, do: "EYES ON YOU"
  defp heat_label(_heat), do: "GHOST · LOW PROFILE"

  @doc """
  Horizontal 5-segment progression ladder track, reused on every skill page (brief §5
  "Progression ladder track"). `tree` is one row from `Shunt.Skills.Catalog.trees/0`
  (`%{label/name, description, tiers: [%{tier, name}, ...]}`); `current_tier` is the
  player's tier for that tree from `Shunt.Skills.Catalog.current_tier/2` (0 today — only
  tier 0/1 is reachable, see brief §7 non-goals). Reached tiers (tier <= current_tier) get
  solid accent fill, the current tier glows, unreached tiers get the dim diagonal-hatch
  texture ("not yet decrypted").

  ## Examples

      <.ladder_track tree={@tree} current_tier={@current_tier} />
  """
  attr :tree, :map, required: true
  attr :current_tier, :integer, required: true

  def ladder_track(assigns) do
    ~H"""
    <div class="ladder-panel">
      <div class="ladder-panel-heading">
        <span class="ladder-panel-prefix">PROGRESSION_LADDER //</span>
        <span class="ladder-panel-name">{@tree.name}</span>
        <span class="ladder-panel-description">{@tree.description}</span>
      </div>
      <div class="ladder-track">
        <div :for={tier <- @tree.tiers} class="ladder-segment-wrap">
          <div class={[
            "ladder-segment",
            tier.tier <= @current_tier && "ladder-segment--reached",
            tier.tier == @current_tier && "ladder-segment--current",
            tier.tier > @current_tier && "ladder-segment--unreached"
          ]} />
          <div class="ladder-segment-label">
            <span class="ladder-segment-code">T{tier.tier}</span>
            <span class="ladder-segment-name">{tier.name}</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Persistent wallet readout for the top bar (brief §5 "Wallet HUD"): Cred and Scrip as
  hairline-border monospace chips, Heat as a compact bar with numeric readout that ramps
  cyan -> amber -> red by fill % and pulses once heat crosses 75 (`Shunt.Heat.band_for/1`
  thresholds: low 30, medium 60, high 85 — use heat >= 75 specifically for the pulse, per
  brief §5, not the `:high` band's 85 threshold).

  ## Examples

      <.wallet_hud player={@player} />
  """
  attr :player, :map, required: true

  def wallet_hud(assigns) do
    ~H"""
    <div class="wallet-hud">
      <div id="resource-cred" class="gauge">
        <span class="gauge-label">CRED</span>
        <span class="gauge-value gauge-value--cyan">{@player.cred}</span>
      </div>
      <div id="resource-scrip" class="gauge">
        <span class="gauge-label">SCRIP</span>
        <span class="gauge-value gauge-value--amber">{@player.scrip}</span>
      </div>
      <div id="resource-heat" class="gauge gauge--heat">
        <div class="gauge-heat-row">
          <span class="gauge-label">HEAT</span>
          <span class="gauge-heat-readout">{@player.heat}/100</span>
        </div>
        <div class={["heat-bar", @player.heat >= 75 && "heat-bar--danger"]}>
          <div class="heat-bar-fill" style={"--heat: #{@player.heat}"} />
        </div>
        <span class="gauge-heat-status">{heat_label(@player.heat)}</span>
      </div>
    </div>
    """
  end
end
