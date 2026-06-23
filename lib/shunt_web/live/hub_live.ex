defmodule ShuntWeb.HubLive do
  use ShuntWeb, :live_view

  alias Shunt.Fencing
  alias Shunt.Fencing.Catalog
  alias Shunt.Npcs
  alias Shunt.Npcs.Loyalty
  alias Shunt.Npcs.Signals
  alias Shunt.Players

  # TODO: port mount/3 verbatim from ShuntWeb.DashboardLive (lib/shunt_web/live/dashboard_live.ex
  # lines 15-20): subscribe to Signals when connected, load the player, assign :player_id and
  # call assign_player/2.
  def mount(_params, _session, socket) do
    raise "not implemented"
  end

  # TODO: port handle_info/2 for {:npc_met, npc_key} and {:loyalty_band_changed, ...} verbatim
  # from DashboardLive lines 22-37 (put_flash narrative beats — these stay on @flash, they are
  # NOT the footer-ticker @status mechanism added below).

  # TODO: port handle_event("lay_low", ...) from DashboardLive lines 39-44, dispatching
  # Players.lay_low/1. On success, before calling assign_player/2, compute the status line
  # from the cred/heat deltas between socket.assigns.player (before) and the new player
  # (after): e.g. "LAY LOW // -10 CRED // HEAT -20". Render this on the Hub page in a new
  # small panel next to Black Market (brief gap noted in design discussion — Lay Low has no
  # home in the written brief's page map, agreed placement is here).

  # TODO: port handle_event("find_lead", ...) from DashboardLive lines 46-51, dispatching
  # Fencing.find_lead/1. Status line on success: "LEAD ACQUIRED // <new offer item's
  # .name>" (look up via Catalog.fetch!(player.current_offer_key) on the *new* player).

  # TODO: port handle_event("take_offer", ...) from DashboardLive lines 53-58, dispatching
  # Fencing.take_offer/1. Status line on success: "STASHED // <item.name> // -<scrip delta>
  # SCRIP" — item is Catalog.fetch!(key) using the *new* player's held_item_key; scrip delta
  # is socket.assigns.player.scrip - new_player.scrip (take_offer only spends scrip, it does
  # not change heat — confirm against Shunt.Fencing.take_offer/1's effects list before
  # assuming otherwise).

  # TODO: port handle_event("pass_offer", ...) from DashboardLive lines 60-65, dispatching
  # Fencing.pass_offer/1. Status line on success is static: "LEAD BURNED // nothing changes
  # hands".

  # TODO: port handle_event("sell_item", ...) from DashboardLive lines 67-75, dispatching
  # Fencing.sell_held_item/1. Capture the held item's name from socket.assigns.player (the
  # *before* player, since held_item_key becomes nil after) via
  # Catalog.fetch!(socket.assigns.player.held_item_key) before dispatching. Status line:
  # "FENCED // <name> // +<scrip delta> SCRIP // HEAT +<heat delta>". Keep the existing
  # flash_heat_event/2 call for heat-threshold-crossing flashes — that's a separate, already-
  # correct mechanism layered on top of the new status line, not a replacement for it.

  # TODO: port handle_event("flesh_tithe", ...) from DashboardLive lines 99-107, dispatching
  # Npcs.flesh_tithe/1. Status line: "MOTHER GRAFT // stitched a deal // +<scrip delta>
  # SCRIP // HEAT +<heat delta>".

  # TODO: port handle_event("move_goods", ...) from DashboardLive lines 109-114, dispatching
  # Npcs.move_goods/1. Capture the held item's name from socket.assigns.player *before*
  # dispatch (same reasoning as sell_item above). Status line: "ROOK // moved <name> //
  # +<scrip delta> SCRIP".

  # TODO: port handle_event("look_the_other_way", ...) from DashboardLive lines 116-121,
  # dispatching Npcs.look_the_other_way/1. Status line: "NINE-IRON // sensor wiped // HEAT
  # <heat delta, signed>".

  # TODO: port handle_event("data_drop", ...) from DashboardLive lines 123-128, dispatching
  # Npcs.data_drop/1. Status line: "SPLICE // data dropped // +<cred delta> CRED".

  # TODO: port handle_event("settle_the_books", ...) from DashboardLive lines 130-135,
  # dispatching Npcs.settle_the_books/1. Status line: "TALLY // books settled // +<scrip
  # delta> SCRIP".

  # TODO: build render/1 for the brief's §6 Hub page, using <Layouts.app flash={@flash}
  # player={@player} active={:hub} status={@status}>:
  #   - <Chrome.section_header>BLACK_MARKET</Chrome.section_header> then a two-column grid
  #     (brief's "OFFER / intercepted transmission" + "HELD / stash") panel pair, porting the
  #     cond branches from DashboardLive's render (lines 152-207) but using <Chrome.panel>,
  #     <Chrome.btn variant={:primary|:ghost|:dead}> instead of raw Tailwind divs/buttons with
  #     inline classes — keep the existing element ids (#find-lead-button, #current-offer,
  #     #take-offer-button, #pass-offer-button, #held-item, #sell-item-button) since tests key
  #     off them.
  #   - A small Lay Low panel next to/below Black Market: a single <.btn> with id
  #     "lay-low-button", disabled={@player.cred < 10} (mirrors DashboardLive line 381's
  #     disabled condition), showing the lay-low cost/effect as static flavor text (10 Cred /
  #     -20 Heat — these constants are private to Shunt.Players, so hardcode the copy here
  #     rather than reaching into the module's @attributes).
  #   - <Chrome.section_header>CONTACTS</Chrome.section_header> then the NPC panel grid,
  #     porting DashboardLive's render lines 229-293 (one <Chrome.panel> per NPC with name,
  #     faction chip, loyalty bar, trade_actions description, and the per-npc.key cond for
  #     which trade button to show) — keep existing ids (#npc-#{npc.key},
  #     #trade-flesh-tithe-button, #trade-move-goods-button, #trade-look-the-other-way-button,
  #     #trade-data-drop-button, #trade-settle-the-books-button).
  def render(assigns) do
    raise "not implemented"
  end

  # TODO: port assign_player/2, catalog_item/1, flash_heat_event/2, humanize_faction/1 from
  # DashboardLive lines 391-425 verbatim (Hub only needs the offer/held/npcs slice of what
  # DashboardLive assigned — drop skill_trees/street_alchemy_tier/raws/recipes, those move to
  # SkillsLive). Add a small private helper for building the @status string from a
  # before/after Player diff, since every handle_event above needs the same
  # cred/scrip/heat-delta pattern — e.g. `defp delta(before, after_, field) do
  # Map.get(after_, field) - Map.get(before, field) end`.
end
