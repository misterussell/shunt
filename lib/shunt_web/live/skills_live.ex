defmodule ShuntWeb.SkillsLive do
  use ShuntWeb, :live_view

  alias Shunt.Crafting
  alias Shunt.Crafting.RawCatalog
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Players
  alias Shunt.Skills.Catalog, as: SkillsCatalog

  # TODO: mount/3 — same player-loading shape as HubLive (Players.get_player!().id,
  # Players.current/1), but this LiveView is routed four ways with a shared live_action
  # (:ghostwork | :chrome_meat | :web | :street_alchemy — see router.ex TODO). Resolve the
  # active tree once via `SkillsCatalog.fetch!(Atom.to_string(socket.assigns.live_action))`
  # (the live_action atoms match the tree `key` strings in priv/content/skills/trees.exs
  # exactly, e.g. :chrome_meat -> "chrome_meat" -> Content.fetch!(:skill_trees, "chrome_meat")
  # — confirm Atom.to_string/1 round-trips correctly for all four before relying on it).
  # Assign :player_id, :tree, and call assign_player/2. No Npcs.Signals subscription needed
  # here — NPC narrative flashes only matter on the Hub page.
  def mount(_params, _session, socket) do
    raise "not implemented"
  end

  # TODO: handle_event("scavenge", ...) — port Crafting.scavenge/1 dispatch from
  # DashboardLive lines 77-80 (only reachable when @tree.key == "street_alchemy"; the route
  # itself already guarantees this since scavenge/assemble/sell_assembled only render on the
  # street-alchemy body, but don't skip a guard — pattern-match or guard on
  # socket.assigns.live_action == :street_alchemy defensively). Status line: "SCAVENGED //
  # 1x <RAW NAME> // HEAT +<heat delta>". Crafting.scavenge/1 picks a random raw internally
  # and doesn't return which one in `meta`, so determine it by diffing
  # socket.assigns.player.inventory (before) against the new player's inventory (after) —
  # find the one raw key whose count increased by 1. Keep the existing flash_heat_event/2
  # call for heat-threshold flashes.

  # TODO: handle_event("assemble", %{"key" => recipe_key}, ...) — port from DashboardLive
  # lines 82-87, dispatching Crafting.assemble(player, recipe_key). Status line: "ASSEMBLED
  # // <RecipeCatalog.fetch!(recipe_key).name> // bench output +1". Crafting.assemble/2 does
  # not change heat (only inventory), so no heat delta belongs in this status line — confirm
  # against Shunt.Crafting.assemble/2's effects list before adding one.

  # TODO: handle_event("sell_assembled", %{"key" => item_key}, ...) — port from DashboardLive
  # lines 89-97, dispatching Crafting.sell_assembled(player, item_key). Look up
  # `recipe = RecipeCatalog.fetch!(item_key)` before dispatch for the display name. Status
  # line: "FENCED // <recipe.name> // +<scrip delta> SCRIP // HEAT +<heat delta>". Keep the
  # existing flash_heat_event/2 call.

  # TODO: build render/1 for the brief's §6 craft pages, using <Layouts.app flash={@flash}
  # player={@player} active={socket.assigns.live_action} status={@status}>:
  #   - <Chrome.ladder_track tree={@tree} current_tier={@current_tier} /> at the top on every
  #     page (brief §4 "sub-header below the top bar" / §5 "Progression ladder track" —
  #     ported from DashboardLive's per-tree rendering at lines 209-227, but using the shared
  #     component instead of inline divs).
  #   - When @tree.key == "street_alchemy": the full crafting body, porting DashboardLive
  #     lines 295-374 (Scavenge action button id="scavenge-button", raw materials list ids
  #     "raw-#{raw.key}", recipe list ids "recipe-#{recipe.key}"/"assemble-#{recipe.key}-button"
  #     with Locked/Unlocked text and tier-gating exactly as today, assembled-goods list ids
  #     "assembled-#{recipe.key}"/"sell-assembled-#{recipe.key}-button") rebuilt with
  #     <Chrome.panel>/<Chrome.btn>/<Chrome.section_header> ("// SCAVENGE", "// RECIPES",
  #     "// ASSEMBLED" per brief §6) instead of raw Tailwind markup.
  #   - Otherwise (ghostwork/chrome_meat/web): a single dormant <Chrome.panel> with the
  #     "⚠ DORMANT MODULE" label and @tree.stub flavor text (the field staged in
  #     priv/content/skills/trees.exs) — no controls, per brief §6 ("a short flavor line and
  #     no controls").
  def render(assigns) do
    raise "not implemented"
  end

  # TODO: assign_player/2 — narrower than HubLive's: assign :player, :tree (already resolved
  # in mount/3), :current_tier (SkillsCatalog.current_tier(player, tree)), and, only relevant
  # for street_alchemy, :raws (RawCatalog.items()) and :recipes (RecipeCatalog.recipes()).
  # Port flash_heat_event/2 from DashboardLive lines 409-417 (identical to HubLive's copy —
  # both LiveViews need their own private copy, this is small enough not to warrant a shared
  # module). Add the same before/after Player-diff helper described in hub_live.ex's TODO for
  # building @status lines.
end
