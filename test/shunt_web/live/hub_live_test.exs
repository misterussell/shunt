defmodule ShuntWeb.HubLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
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
    assert render(view) =~ "5 DOSSIERS · USE WISELY"
  end

  test "clicking Lay Low decreases displayed resources and sets the status line", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, cred: 30, heat: 40))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#lay-low-button") |> render_click()

    assert has_element?(view, "#resource-cred", "CRED 20")
    assert has_element?(view, "#resource-heat", "HEAT 20/100")
    assert render(view) =~ "LAY LOW"
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

  test "Lay Low stays available in the stash panel regardless of held-item state", %{
    conn: conn
  } do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 100, cred: 30))

    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#stash-panel #lay-low-button")

    view |> element("#find-lead-button") |> render_click()
    view |> element("#take-offer-button") |> render_click()

    assert has_element?(view, "#stash-panel #held-item")
    assert has_element?(view, "#stash-panel #lay-low-button")
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

  test "renders the NPC roster", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#npc-rook", "Rook")
    assert has_element?(view, "#npc-rook", "MOVE GOODS")
    assert has_element?(view, "#npc-tally", "Tally")
  end

  test "loyalty bar reflects Player.npc_loyalty, not a static NPC value", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, npc_loyalty: %{"mother_graft" => 80}))
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#npc-mother_graft", "Loyalty: 80/100")
  end

  test "Flesh Tithe consumes a cracked_bone_plate and grants scrip", %{conn: conn} do
    player = Shunt.Players.get_player!()

    Shunt.Repo.update!(
      Ecto.Changeset.change(player, inventory: %{"cracked_bone_plate" => 1}, scrip: 0)
    )

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-flesh-tithe-button") |> render_click()

    assert has_element?(view, "#resource-scrip", "SCRIP 15")
    assert render(view) =~ "MOTHER GRAFT"
  end

  test "Move Goods pays out for the held item and clears it", %{conn: conn} do
    item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, held_item_key: item.key, scrip: 0))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-move-goods-button") |> render_click()

    assert has_element?(view, "#resource-scrip", "SCRIP #{floor(item.sell_value * 0.5)}")
    refute has_element?(view, "#held-item")
  end

  test "Look the Other Way spends scrip and reduces heat", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 20, heat: 20))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-look-the-other-way-button") |> render_click()

    assert has_element?(view, "#resource-scrip", "SCRIP 0")
    assert has_element?(view, "#resource-heat", "HEAT 5/100")
  end

  test "Data Drop converts scrip into cred", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 20, cred: 0))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-data-drop-button") |> render_click()

    assert has_element?(view, "#resource-scrip", "SCRIP 0")
    assert has_element?(view, "#resource-cred", "CRED 1")
  end

  test "Settle the Books converts cred into scrip", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, cred: 1, scrip: 0))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-settle-the-books-button") |> render_click()

    assert has_element?(view, "#resource-cred", "CRED 0")
    assert has_element?(view, "#resource-scrip", "SCRIP 10")
  end

  test "meeting an NPC for the first time flashes a met message", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, inventory: %{"cracked_bone_plate" => 1}))
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#trade-flesh-tithe-button") |> render_click()
    # render(view) again to let the LiveView's own self-broadcast (sent via Phoenix.PubSub
    # in the same handle_event) land and get processed by handle_info before asserting:
    assert render(view) =~ "met Mother Graft"
  end

  test "crossing a loyalty band flashes a band-changed message", %{conn: conn} do
    player = Shunt.Players.get_player!()

    Shunt.Repo.update!(
      Ecto.Changeset.change(player,
        inventory: %{"cracked_bone_plate" => 1},
        npc_loyalty: %{"mother_graft" => 73}
      )
    )

    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#trade-flesh-tithe-button") |> render_click()
    assert render(view) =~ "trust you"
  end
end
