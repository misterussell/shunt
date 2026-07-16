defmodule ShuntWeb.HubLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
  end

  # Grant fields on the singleton player (knowledge flags unlock a contact's services).
  defp update_player(attrs) do
    Shunt.Players.get_player!()
    |> Ecto.Changeset.change(attrs)
    |> Shunt.Repo.update!()
  end

  test "renders initial resource values", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#resource-cred", "CRED 0")
    assert has_element?(view, "#resource-scrip", "SCRIP 0")
    assert has_element?(view, "#resource-heat", "HEAT 0/100")
  end

  test "section headers show their secondary labels", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert render(view) =~ "0x1A · FENCE_PROTOCOL"
    assert render(view) =~ "COMMS NETWORK"
  end

  defp put_heat(heat) do
    Shunt.Players.get_player!()
    |> Ecto.Changeset.change(heat: heat)
    |> Shunt.Repo.update!()
  end

  test "the Hub offers a Go To Ground control when not laying low", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#enter-laying-low-button")
    refute has_element?(view, "#laying-low-panel")
  end

  test "the Go To Ground control is disabled while Heat is below the entry band", %{conn: conn} do
    put_heat(0)
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#enter-laying-low-button.btn-dead")
  end

  test "entering Laying Low at high Heat reveals the activity panel", %{conn: conn} do
    put_heat(70)
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#enter-laying-low-button") |> render_click()

    assert has_element?(view, "#laying-low-panel")
    refute has_element?(view, "#enter-laying-low-button")
  end

  test "resting while laid low lowers Heat and sets the status line", %{conn: conn} do
    put_heat(70)
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#enter-laying-low-button") |> render_click()

    view |> element("#rest-button") |> render_click()

    assert has_element?(view, "#resource-heat", "HEAT 65/100")
    assert has_element?(view, ".footer-ticker-status", "HEAT -5")
  end

  test "Burn Evidence is disabled while laid low without enough scrip", %{conn: conn} do
    put_heat(70)
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#enter-laying-low-button") |> render_click()

    assert has_element?(view, "#burn-evidence-button.btn-dead")
  end

  test "Burn Evidence with enough scrip drops Heat and spends scrip", %{conn: conn} do
    Shunt.Players.get_player!()
    |> Ecto.Changeset.change(heat: 70, scrip: 50)
    |> Shunt.Repo.update!()

    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#enter-laying-low-button") |> render_click()

    view |> element("#burn-evidence-button") |> render_click()

    assert has_element?(view, "#resource-heat", "HEAT 55/100")
    assert has_element?(view, "#resource-scrip", "SCRIP 25")
  end

  test "resurfacing returns the Hub to the open", %{conn: conn} do
    put_heat(70)
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#enter-laying-low-button") |> render_click()

    view |> element("#resurface-button") |> render_click()

    assert has_element?(view, "#enter-laying-low-button")
    refute has_element?(view, "#laying-low-panel")
  end

  test "clicking Find a Lead reveals an offer", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute has_element?(view, "#current-offer")

    view |> element("#find-lead-button") |> render_click()

    assert has_element?(view, "#current-offer")
    refute has_element?(view, "#find-lead-button")
  end

  test "offer panel shows the intercepted-lead header chrome", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#offer-panel .offer-accent-strip")
    assert has_element?(view, "#offer-panel .offer-header", ">> INTERCEPTED LEAD")
  end

  test "the empty offer state shows an awaiting-handshake cursor line", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#offer-panel", "awaiting handshake")
  end

  test "a revealed offer shows a tier badge and a buy/fence/heat stat strip", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#find-lead-button") |> render_click()

    assert has_element?(view, "#current-offer .offer-tier-badge")
    assert has_element?(view, "#current-offer .offer-stat", "BUY @")
    assert has_element?(view, "#current-offer .offer-stat", "FENCE @")
    assert has_element?(view, "#current-offer .offer-stat", "HEAT +")
  end

  test "a revealed offer shows the item name, SKU line, and flavor text with styled classes", %{
    conn: conn
  } do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, current_offer_key: "bootleg_credchip_stack"))

    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#current-offer .offer-name", "Bootleg Credchip Stack")
    assert has_element?(view, "#current-offer .offer-sku", "SKU://")

    assert has_element?(
             view,
             "#current-offer .offer-flavor",
             "Counterfeit chips"
           )
  end

  test "a clean-tier offer shows a formatted CLEAN tier label and a cyan-glowing heat stat", %{
    conn: conn
  } do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, current_offer_key: "bootleg_credchip_stack"))

    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#current-offer .offer-tier-badge", "CLEAN")
    assert has_element?(view, "#current-offer .offer-stat-value--clean")
  end

  test "a hot-tier offer shows the HOT // HIGH RISK tier label", %{conn: conn} do
    player = Shunt.Players.get_player!()

    Shunt.Repo.update!(
      Ecto.Changeset.change(player, current_offer_key: "burned_netrunners_memory_core")
    )

    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#current-offer .offer-tier-badge", "HOT // HIGH RISK")
  end

  test "the empty offer state shows a flavor line above the awaiting-handshake cursor", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#offer-panel .offer-flavor-empty", "The wire's dead air")
  end

  test "stash panel shows a STASH // 1 SLOT header", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#stash-panel .stash-header", "STASH // 1 SLOT")
  end

  test "the empty stash shows a dashed empty-state box", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#stash-panel .stash-empty", "EMPTY")
    assert has_element?(view, "#stash-panel .stash-empty", "take a lead to hold stock")
  end

  test "a held item shows its name, tier badge, flavor text, and a STREET VALUE readout", %{
    conn: conn
  } do
    item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, held_item_key: item.id))

    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#held-item .held-name", item.name)
    assert has_element?(view, "#held-item .held-tier-badge", "CLEAN")
    assert has_element?(view, "#held-item .held-flavor", item.sell_text)
    assert has_element?(view, "#held-item .held-value-label", "STREET VALUE")
    assert has_element?(view, "#held-item .held-value", "+#{item.sell_value}")
  end

  test "an unmet contact does not render on the comms network", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute has_element?(view, "#npc-mother_graft")
    refute has_element?(view, "#service-mother_graft-flesh_tithe")
  end

  test "the comms network shows an empty state when no contacts are known", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, ".comms-empty", "No contacts yet")
  end

  test "a known contact's panel shows a loyalty accent bar, a faction pill, and a trust bar", %{
    conn: conn
  } do
    update_player(knowledge: ["mother_graft_intro"])
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, ".contacts-grid #npc-mother_graft")
    assert has_element?(view, "#npc-mother_graft .npc-accent-bar")
    assert has_element?(view, "#npc-mother_graft .npc-faction-pill")
    assert has_element?(view, "#npc-mother_graft .npc-trust-row", "TRUST")
    assert has_element?(view, "#npc-mother_graft .npc-trust-row", "50/100 · WARY")
    assert has_element?(view, "#npc-mother_graft .npc-trust-fill")
  end

  test "taking an offer deducts scrip and shows the held item", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 100))

    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#find-lead-button") |> render_click()
    view |> element("#take-offer-button") |> render_click()

    assert has_element?(view, "#held-item")
    refute has_element?(view, "#current-offer")
  end

  test "the offer and stash panels render side by side in a grid, independent of each other",
       %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 100))

    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, ".black-market-grid #offer-panel")
    assert has_element?(view, ".black-market-grid #stash-panel")
    assert has_element?(view, "#offer-panel #find-lead-button")

    view |> element("#find-lead-button") |> render_click()
    view |> element("#take-offer-button") |> render_click()

    # taking an offer clears @offer (back to the empty state) but fills @held —
    # the two panels must update independently of one another
    assert has_element?(view, "#offer-panel #find-lead-button")
    assert has_element?(view, "#stash-panel #held-item")
  end

  test "the Go To Ground control stays in the stash panel regardless of held-item state", %{
    conn: conn
  } do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 100, cred: 30))

    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#stash-panel #enter-laying-low-button")

    view |> element("#find-lead-button") |> render_click()
    view |> element("#take-offer-button") |> render_click()

    assert has_element?(view, "#stash-panel #held-item")
    assert has_element?(view, "#stash-panel #enter-laying-low-button")
  end

  test "passing an offer returns to idle", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#find-lead-button") |> render_click()
    view |> element("#pass-offer-button") |> render_click()

    assert has_element?(view, "#find-lead-button")
    refute has_element?(view, "#current-offer")
  end

  test "passing an offer when there is no pending offer doesn't crash the view", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    refute has_element?(view, "#current-offer")

    render_click(view, "pass_offer")

    assert has_element?(view, "#find-lead-button")
  end

  test "find a lead, take it, and sell it updates resources and returns to idle", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 100))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#find-lead-button") |> render_click()
    view |> element("#take-offer-button") |> render_click()
    view |> element("#sell-item-button") |> render_click()

    assert has_element?(view, "#find-lead-button")
    refute has_element?(view, "#held-item")

    player = Shunt.Players.get_player!()
    assert player.scrip > 0
    assert player.cred > 0
    assert player.heat > 0
  end

  test "renders a known contact and its service button", %{conn: conn} do
    item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")
    update_player(knowledge: ["rook", "tally_intro"], held_item_key: item.id)

    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#npc-rook", "Rook")
    assert has_element?(view, "#service-rook-move_goods", "Move Goods")
    assert has_element?(view, "#npc-tally", "Tally")
  end

  test "a service description has a styled action-text class", %{conn: conn} do
    update_player(knowledge: ["rook"])
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#npc-rook .npc-action-text", "fences whatever")
  end

  test "an unaffordable service button is styled dead", %{conn: conn} do
    update_player(knowledge: ["mother_graft_intro"])
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#service-mother_graft-flesh_tithe.btn-dead")
  end

  test "a hostile-loyalty player's service is dead even when scrip covers the base cost", %{
    conn: conn
  } do
    update_player(knowledge: ["nine_iron_intro"], scrip: 20, npc_loyalty: %{"nine_iron" => 0})
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#service-nine_iron-look_the_other_way.btn-dead")
  end

  test "an affordable service button is styled primary", %{conn: conn} do
    update_player(knowledge: ["mother_graft_intro"], inventory: %{"cracked_bone_plate" => 1})
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#service-mother_graft-flesh_tithe.btn-primary")
    refute has_element?(view, "#service-mother_graft-flesh_tithe.btn-dead")
  end

  test "a disabled take-offer button shows CRED SHORT instead of TAKE IT", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 0))

    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#find-lead-button") |> render_click()

    assert has_element?(view, "#take-offer-button", "CRED SHORT")
    refute has_element?(view, "#take-offer-button", "TAKE IT")
  end

  test "loyalty bar reflects Player.npc_loyalty, not a static NPC value", %{conn: conn} do
    update_player(knowledge: ["mother_graft_intro"], npc_loyalty: %{"mother_graft" => 80})
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#npc-mother_graft", "80/100 · SOLID")
  end

  test "a hostile-band (<=24) contact shows BURNED and the red accent/fill classes", %{conn: conn} do
    update_player(knowledge: ["mother_graft_intro"], npc_loyalty: %{"mother_graft" => 24})
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#npc-mother_graft .npc-trust-row", "24/100 · BURNED")
    assert has_element?(view, "#npc-mother_graft .npc-accent-bar--red")
    assert has_element?(view, "#npc-mother_graft .npc-trust-fill--red")
  end

  test "a favored-band (>=75) contact shows SOLID and the cyan accent/fill classes", %{conn: conn} do
    update_player(knowledge: ["mother_graft_intro"], npc_loyalty: %{"mother_graft" => 75})
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#npc-mother_graft .npc-trust-row", "75/100 · SOLID")
    assert has_element?(view, "#npc-mother_graft .npc-accent-bar--cyan")
    assert has_element?(view, "#npc-mother_graft .npc-trust-fill--cyan")
  end

  test "a mid-band (25..74) contact shows WARY and the amber accent/fill classes", %{conn: conn} do
    update_player(knowledge: ["mother_graft_intro"], npc_loyalty: %{"mother_graft" => 25})
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#npc-mother_graft .npc-trust-row", "25/100 · WARY")
    assert has_element?(view, "#npc-mother_graft .npc-accent-bar--amber")
    assert has_element?(view, "#npc-mother_graft .npc-trust-fill--amber")
  end

  test "invoking Flesh Tithe consumes a cracked_bone_plate and grants scrip", %{conn: conn} do
    update_player(
      knowledge: ["mother_graft_intro"],
      inventory: %{"cracked_bone_plate" => 1},
      scrip: 0
    )

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#service-mother_graft-flesh_tithe") |> render_click()

    assert has_element?(view, "#resource-scrip", "SCRIP 15")
    assert render(view) =~ "MOTHER GRAFT"
  end

  test "invoking Move Goods pays out for the held item and clears it", %{conn: conn} do
    item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")
    update_player(knowledge: ["rook"], held_item_key: item.id, scrip: 0)
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#service-rook-move_goods") |> render_click()

    assert has_element?(view, "#resource-scrip", "SCRIP #{floor(item.sell_value * 0.5)}")
    refute has_element?(view, "#held-item")
  end

  test "invoking Look the Other Way spends scrip and reduces heat", %{conn: conn} do
    update_player(knowledge: ["nine_iron_intro"], scrip: 20, heat: 20)
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#service-nine_iron-look_the_other_way") |> render_click()

    assert has_element?(view, "#resource-scrip", "SCRIP 0")
    assert has_element?(view, "#resource-heat", "HEAT 5/100")
  end

  test "invoking Data Drop converts scrip into cred", %{conn: conn} do
    update_player(knowledge: ["splice_intro"], scrip: 20, cred: 0)
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#service-splice-data_drop") |> render_click()

    assert has_element?(view, "#resource-scrip", "SCRIP 0")
    assert has_element?(view, "#resource-cred", "CRED 1")
  end

  test "invoking Settle the Books converts cred into scrip", %{conn: conn} do
    update_player(knowledge: ["tally_intro"], cred: 1, scrip: 0)
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#service-tally-settle_the_books") |> render_click()

    assert has_element?(view, "#resource-cred", "CRED 0")
    assert has_element?(view, "#resource-scrip", "SCRIP 10")
  end

  test "the best-unlocked tier's label and payout win once tasks are done", %{conn: conn} do
    update_player(knowledge: ["tally_intro", "tally_task1", "tally_task2"], cred: 1, scrip: 0)
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#service-tally-settle_the_books", "Cook the Ledger")
    view |> element("#service-tally-settle_the_books") |> render_click()

    assert has_element?(view, "#resource-scrip", "SCRIP 24")
  end

  test "meeting a contact for the first time flashes a met message", %{conn: conn} do
    update_player(knowledge: ["mother_graft_intro"], inventory: %{"cracked_bone_plate" => 1})
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#service-mother_graft-flesh_tithe") |> render_click()
    assert render(view) =~ "met Mother Graft"
  end

  test "crossing a loyalty band flashes a band-changed message", %{conn: conn} do
    update_player(
      knowledge: ["mother_graft_intro"],
      inventory: %{"cracked_bone_plate" => 1},
      npc_loyalty: %{"mother_graft" => 73}
    )

    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#service-mother_graft-flesh_tithe") |> render_click()
    assert render(view) =~ "trust you"
  end
end
