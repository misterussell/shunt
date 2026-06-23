defmodule ShuntWeb.HubLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
  end

  # TODO: port "renders initial resource values" from
  # test/shunt_web/live/dashboard_live_test.exs lines 11-17, against `live(conn, ~p"/")` —
  # same #resource-cred/#resource-scrip/#resource-heat ids, HubLive keeps them via
  # <Chrome.wallet_hud>.

  # TODO: port "clicking Lay Low decreases displayed resources" (dashboard_live_test.exs
  # lines 19-29) — same #lay-low-button id, now rendered on the Hub page next to Black
  # Market per the agreed placement.

  # TODO: port the Black Market offer flow as 4 tests (dashboard_live_test.exs lines 31-89):
  # "clicking Find a Lead reveals an offer", "taking an offer deducts scrip and shows the
  # held item", "passing an offer returns to idle", "passing an offer when there is no
  # pending offer doesn't crash the view", "find a lead, take it, and sell it updates
  # resources and returns to idle" — same #find-lead-button/#current-offer/#take-offer-button
  # /#pass-offer-button/#held-item/#sell-item-button ids.

  # TODO: port "renders the NPC roster" (dashboard_live_test.exs lines 100-106) and "loyalty
  # bar reflects Player.npc_loyalty, not a static NPC value" (lines 197-202) — same
  # #npc-#{key} ids.

  # TODO: port the 5 NPC trade-action tests (dashboard_live_test.exs lines 108-169): "Flesh
  # Tithe consumes a cracked_bone_plate and grants scrip", "Move Goods pays out for the held
  # item and clears it", "Look the Other Way spends scrip and reduces heat", "Data Drop
  # converts scrip into cred", "Settle the Books converts cred into scrip" — same
  # #trade-flesh-tithe-button/#trade-move-goods-button/#trade-look-the-other-way-button/
  # #trade-data-drop-button/#trade-settle-the-books-button ids. Additionally assert the new
  # @status footer-ticker line renders the expected text for at least one of these (e.g.
  # flesh tithe -> assert render(view) =~ "MOTHER GRAFT"), since that's new behavior not
  # covered by the ported assertions alone.

  # TODO: port "meeting an NPC for the first time flashes a met message" and "crossing a
  # loyalty band flashes a band-changed message" (dashboard_live_test.exs lines 204-227)
  # verbatim — these narrative flashes are unchanged by the redesign.
end
