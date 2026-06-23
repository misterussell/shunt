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
  attr :active, :boolean, default: false
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def panel(assigns) do
    # TODO: render a <div class={["panel", @active && "panel--active", @class]}> wrapping
    # @inner_block. "panel" supplies the var(--p1)->var(--p2) gradient surface, 1px
    # var(--border), and the inset top highlight; "panel--active" adds the small L-bracket
    # corner accents via ::before/::after (see app.css TODO). Do not inline any style=.
    raise "not implemented"
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
    # TODO: render <button class={["btn-#{@variant}"]} {@rest}>{render_slot(@inner_block)}</button>.
    # :dead should also force disabled="disabled" regardless of @rest, since a "dead" button
    # is never clickable. Hover/active fill behavior lives entirely in the .btn-primary /
    # .btn-ghost / .btn-dead CSS classes (app.css TODO) — no style-hover inline attrs like
    # the prototype used.
    raise "not implemented"
  end

  @doc """
  HUD-module section label with a thin horizontal rule, e.g. `// WALLET`, `// FENCING`,
  `// CONTACTS` (brief §5 "Section header").

  ## Examples

      <.section_header>BLACK_MARKET</.section_header>
  """
  slot :inner_block, required: true

  def section_header(assigns) do
    # TODO: render the "// LABEL ──────" small-caps HUD module header (see Shunt.dc.html's
    # "┌─[ BLACK_MARKET ]" rows for the exact visual: label, flex-1 dashed rule, optional
    # right-aligned subtext). Use a class like "section-header" — no inline styles.
    raise "not implemented"
  end

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
    # TODO: render the tree label + description header row, then a flex row of 5
    # `.ladder-segment` divs (one per @tree.tiers entry plus an implicit tier-0 segment —
    # confirm against Shunt.dc.html's segments mapping which iterates t.tiers directly with
    # `reached = i < t.tier, current = i === t.tier`). Apply
    # "ladder-segment--current"/"ladder-segment--reached"/"ladder-segment--unreached" per
    # segment based on @current_tier, with each tier's name shown beneath it.
    raise "not implemented"
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
    # TODO: render the CRED chip (`@player.cred`), SCRIP chip (`@player.scrip`), and the
    # HEAT module: numeric "HEAT NN/100" readout, a thin bar whose fill width is
    # `@player.heat`% and color/animation depend on the threshold, and the small status
    # label under the bar (e.g. "GHOST · LOW PROFILE" / "EYES ON YOU" / "⚠ AUTHORITY
    # INBOUND" — reuse Shunt.dc.html's heatLabel logic, thresholds heat>=75 / heat>=40 /
    # else). All via "wallet-chip"/"heat-bar"/"heat-bar-fill"/"heat-bar--danger" classes.
    raise "not implemented"
  end
end
