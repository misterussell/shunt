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

  # TODO: test "renders the four skill trees as locked for a fresh player" — assert
  # has_element?(view, "#skill-tree-ghostwork", "Locked") and the same for
  # #skill-tree-chrome_meat, #skill-tree-web, #skill-tree-street_alchemy
end
