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

  # TODO: test "scavenging adds a raw material to the displayed inventory", %{conn: conn} —
  # {:ok, view, _html} = live(conn, ~p"/"), render_click(view, "scavenge"), then assert at
  # least one #raw-<key> element is present (use Shunt.Crafting.RawCatalog.items/0 to check
  # has_element?(view, "#raw-\#{raw.key}") for any raw — the random pick means you can't
  # assert a specific key, so assert Enum.any?(RawCatalog.items(), &has_element?(view, "#raw-#{&1.key}")))

  # TODO: test "renders recipes as locked for a fresh player", %{conn: conn} —
  # {:ok, view, _html} = live(conn, ~p"/"), assert
  # has_element?(view, "#recipe-patchwork_courier_drone", "Locked") (street_alchemy_tier is
  # 0 for a fresh player, every recipe requires tier_required: 1)
end
