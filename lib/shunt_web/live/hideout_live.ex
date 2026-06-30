defmodule ShuntWeb.HideoutLive do
  @moduledoc """
  The Hideout — the interior of the player's premises. A dedicated page (not a map POI) so
  it can grow into a real interior (floorplan, inventory manager, visual module slots) later.
  See priv/docs/SHUNT_territory_ladder_v1.md §5.

  Access-gated: only usable when the player is physically home (location_id == premises_id);
  reached via the "Enter the Hideout" link on the map. All commerce, collection, and module
  interaction live here; the map only shows the entrance.
  """
  use ShuntWeb, :live_view

  # TODO: [Territory] mount/3 — mirror MovementLive.mount: resolve player_id via
  # Players.get_player!().id, lookup_or_start, subscribe to Signals when connected?, load the
  # player. ACCESS GATE: if player.location_id != player.premises_id, push_navigate to ~p"/map"
  # (you must be home to enter). Otherwise assign the player and the derived view (tier,
  # reservoir computed with DateTime.utc_now(), available_modules/available_relocations).

  # TODO: [Territory] handle_event("collect", ...) — capture now = DateTime.utc_now() at the
  # edge, Players.dispatch(player_id, &Shunt.Territory.collect(&1, now)), re-assign on {:ok, ...}.
  # Surface the trace Heat (and any heat_event from meta) to the player. No-op the
  # {:error, :nothing_to_collect} case.

  # TODO: [Territory] handle_event("buy_module", %{"key" => key}, ...) — dispatch
  # Shunt.Territory.install_module/2 (pass now for income-module accrual start); re-assign and
  # re-derive the catalog on success.

  # TODO: [Territory] handle_event("relocate", %{"to" => premises_id}, ...) — dispatch
  # Shunt.Territory.relocate/2; on success re-assign (premises/class/tier change).

  # TODO: [Territory] render/1 — five sections per §5, each with stable DOM ids for tests:
  #   1. Identity header (#hideout-tier): premises name, derived status/tier, class, stratum.
  #   2. The Bleed (#bleed): reservoir gauge (% full / FULL), rate, and a #bleed-collect button
  #      showing the projected Heat cost BEFORE clicking.
  #   3. Installed (#installed-modules): modules held (simple list/grid in v1).
  #   4. Catalog (#module-catalog): buyable modules (#buy-module-<key>) vs locked/aspirational
  #      ones ("Requires a bigger space — relocate").
  #   5. Relocate (#relocate): available premises (#relocate-<id>) with cost + unlocked ceiling.
  # Wrap everything in <Layouts.app flash={@flash} current_scope={...}> and include an "Exit"
  # <.link navigate={~p"/map"}>. Use plain assigns (re-derived each action), NOT streams — the
  # catalog is a small fully-recomputed collection.
  @impl true
  def render(assigns) do
    # Placeholder — replaced by the §5 render (wrapped in Layouts.app with player/active) during
    # implementation. Bare stub here so the unrouted skeleton compiles without required-attr warnings.
    ~H"""
    <p>TODO: [Territory] Hideout page — see module TODOs.</p>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # TODO: [Territory] Replace this placeholder mount with the access-gated mount described above.
    {:ok, socket}
  end
end
