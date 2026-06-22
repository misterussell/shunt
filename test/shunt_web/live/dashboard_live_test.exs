defmodule ShuntWeb.DashboardLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
  end

  test "renders initial resource values", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#resource-cred", "Cred: 0")
    assert has_element?(view, "#resource-scrip", "Scrip: 0")
    assert has_element?(view, "#resource-heat", "Heat: 0/100")
  end

  test "clicking Lay Low decreases displayed resources", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, cred: 30, heat: 40))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#lay-low-button") |> render_click()

    assert has_element?(view, "#resource-cred", "Cred: 20")
    assert has_element?(view, "#resource-heat", "Heat: 20/100")
  end

  test "clicking Find a Lead reveals an offer", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute has_element?(view, "#current-offer")

    view |> element("#find-lead-button") |> render_click()

    assert has_element?(view, "#current-offer")
    refute has_element?(view, "#find-lead-button")
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

  test "renders the four skill trees as locked for a fresh player", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#skill-tree-ghostwork", "Locked")
    assert has_element?(view, "#skill-tree-chrome_meat", "Locked")
    assert has_element?(view, "#skill-tree-web", "Locked")
    assert has_element?(view, "#skill-tree-street_alchemy", "Locked")
  end

  test "renders the NPC roster", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#npc-rook", "Rook")
    assert has_element?(view, "#npc-rook", "Move Goods")
    assert has_element?(view, "#npc-tally", "Tally")
  end

  test "Flesh Tithe consumes a cracked_bone_plate and grants scrip", %{conn: conn} do
    player = Shunt.Players.get_player!()

    Shunt.Repo.update!(
      Ecto.Changeset.change(player, inventory: %{"cracked_bone_plate" => 1}, scrip: 0)
    )

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-flesh-tithe-button") |> render_click()

    assert has_element?(view, "#resource-scrip", "Scrip: 15")
  end

  test "Move Goods pays out for the held item and clears it", %{conn: conn} do
    item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, held_item_key: item.key, scrip: 0))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-move-goods-button") |> render_click()

    assert has_element?(view, "#resource-scrip", "Scrip: #{floor(item.sell_value * 0.5)}")
    refute has_element?(view, "#held-item")
  end

  test "Look the Other Way spends scrip and reduces heat", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 20, heat: 20))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-look-the-other-way-button") |> render_click()

    assert has_element?(view, "#resource-scrip", "Scrip: 0")
    assert has_element?(view, "#resource-heat", "Heat: 5/100")
  end

  test "Data Drop converts scrip into cred", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 20, cred: 0))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-data-drop-button") |> render_click()

    assert has_element?(view, "#resource-scrip", "Scrip: 0")
    assert has_element?(view, "#resource-cred", "Cred: 1")
  end

  test "Settle the Books converts cred into scrip", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, cred: 1, scrip: 0))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#trade-settle-the-books-button") |> render_click()

    assert has_element?(view, "#resource-cred", "Cred: 0")
    assert has_element?(view, "#resource-scrip", "Scrip: 10")
  end

  test "scavenging adds a raw material to the displayed inventory", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#scavenge-button") |> render_click()

    assert Enum.any?(
             Shunt.Crafting.RawCatalog.items(),
             &has_element?(view, "#raw-#{&1.key}")
           )
  end

  test "scavenging across a heat threshold flashes the fired event and drops heat", %{
    conn: conn
  } do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, heat: 84))

    {:ok, view, _html} = live(conn, ~p"/")

    html = view |> element("#scavenge-button") |> render_click()

    assert html =~ "Scrip"
    assert has_element?(view, "#flash-error")
    assert Shunt.Players.get_player!().heat == 80
  end

  test "loyalty bar reflects Player.npc_loyalty, not a static NPC value", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, npc_loyalty: %{"mother_graft" => 80}))
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#npc-mother_graft", "Loyalty: 80/100")
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

  test "renders recipes as locked for a fresh player", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#recipe-patchwork_courier_drone", "Locked")
  end

  test "crafting the Scrap-Forged Soldering Iron unlocks street_alchemy tier 1", %{conn: conn} do
    player = Shunt.Players.get_player!()
    inputs = Shunt.Crafting.RecipeCatalog.fetch!("scrap_forged_soldering_iron").inputs
    Shunt.Repo.update!(Ecto.Changeset.change(player, inventory: inputs))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#assemble-scrap_forged_soldering_iron-button") |> render_click()

    assert has_element?(view, "#recipe-patchwork_courier_drone", "Unlocked")
  end
end
