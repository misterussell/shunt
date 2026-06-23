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
  slot :inner_block, required: true

  # TODO: add `attr :secondary, :string, default: nil` for the right-aligned secondary
  # label (e.g. "0x1A · FENCE_PROTOCOL", "5 DOSSIERS · USE WISELY", "⚠ DRAWS HEAT",
  # "DECRYPTED BY TIER", "BENCH OUTPUT" — each call site passes its own value, see
  # docs/design-comp.html lines 106-110, 191-195, 255-259, 280-284, 314-318). Re-render
  # the markup as: a cyan bracket-open span "┌─[ LABEL ]", a dashed rule (flex:1,
  # border-top:1px dashed var(--border-c), not the current solid `.section-header::after`
  # rule), the secondary label span (muted, or amber when the call site needs amber e.g.
  # "⚠ DRAWS HEAT"), and a cyan bracket-close span "─┐". Replace the current
  # `.section-header`/`::before`/`::after` CSS in app.css with rules for this new
  # 4-part flex layout (drop the `// ` pseudo-element prefix, it's superseded by the
  # bracket glyphs).
  def section_header(assigns) do
    ~H"""
    <div class="section-header">
      {render_slot(@inner_block)}
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

  # TODO: wrap this whole component in a bordered/padded panel div (see
  # docs/design-comp.html lines 233-250: `position:relative; margin-bottom:26px;
  # background:linear-gradient(180deg, var(--p1), var(--p2)); border:1px solid
  # var(--border); padding:18px 20px;`) and prefix the tree name/description row with a
  # "PROGRESSION_LADDER //" label (muted, letter-spacing:0.18em) before {@tree.name} on
  # the same line. Add a `.ladder-panel` class in app.css for the wrapper.
  #
  # TODO: change each `.ladder-segment` from a bordered box containing the tier name text
  # to a thin bar (height:11px, no border, just background color per state) with a label
  # row below it showing the tier code ("T0", "T1", ...) plus the tier name beside it (see
  # docs/design-comp.html lines 239-249). Reached segments: solid cyan-tinted background.
  # Current segment: solid cyan + glow. Unreached: keep the existing hatch background but
  # move it onto the bar element instead of the text box. Update `.ladder-track`,
  # `.ladder-segment`, `.ladder-segment--reached`, `.ladder-segment--current`,
  # `.ladder-segment--unreached` in app.css accordingly — this changes the segment's
  # internal structure (bar div + label row div) so the HEEx markup below needs restructuring,
  # not just new CSS.
  def ladder_track(assigns) do
    ~H"""
    <div>
      <div>
        <span>{@tree.name}</span>
        <span>{@tree.description}</span>
      </div>
      <div class="ladder-track">
        <div
          :for={tier <- @tree.tiers}
          class={[
            "ladder-segment",
            tier.tier <= @current_tier && "ladder-segment--reached",
            tier.tier == @current_tier && "ladder-segment--current",
            tier.tier > @current_tier && "ladder-segment--unreached"
          ]}
        >
          {tier.name}
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

  # TODO: restyle as bordered "gauge" boxes per docs/design-comp.html lines 60-79.
  # Cred/Scrip gauges: a bordered box (border:1px solid var(--border-c); background:
  # var(--sunk); padding) containing a small muted label ("CRED"/"SCRIP", font-size:8px,
  # letter-spacing:0.18em) stacked above a larger glowing colored number (font-size:15px,
  # cyan for Cred, amber for Scrip, text-shadow glow) — replace the flat `.wallet-chip`
  # span with this two-line box (`.gauge`/`.gauge-label`/`.gauge-value` classes in
  # app.css). Heat gauge: same bordered box (min-width:152px) but three stacked rows —
  # label+numeric readout on one line (justify-content:space-between), the existing
  # `.heat-bar` below it, then the existing heat label text below that — keep the
  # ramping cyan→amber→red color and the >=75 pulse, just nest them inside the new
  # bordered box instead of the current bare `<div>`.
  def wallet_hud(assigns) do
    ~H"""
    <div>
      <span id="resource-cred" class="wallet-chip">CRED {@player.cred}</span>
      <span id="resource-scrip" class="wallet-chip">SCRIP {@player.scrip}</span>
      <div>
        <span id="resource-heat">HEAT {@player.heat}/100</span>
        <div class={["heat-bar", @player.heat >= 75 && "heat-bar--danger"]}>
          <div class="heat-bar-fill" style={"--heat: #{@player.heat}"} />
        </div>
        <span>{heat_label(@player.heat)}</span>
      </div>
    </div>
    """
  end
end
