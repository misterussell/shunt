defmodule ShuntWeb.DashboardLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders initial resource values", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#resource-cred", "Cred: 0")
    assert has_element?(view, "#resource-scrip", "Scrip: 0")
    assert has_element?(view, "#resource-heat", "Heat: 0/100")
  end

  test "clicking Do a Job increases displayed resources", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#do-job-button") |> render_click()

    assert has_element?(view, "#resource-cred", "Cred: 5")
    assert has_element?(view, "#resource-scrip", "Scrip: 15")
    assert has_element?(view, "#resource-heat", "Heat: 10/100")
  end

  test "clicking Lay Low decreases displayed resources", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#do-job-button") |> render_click()
    view |> element("#do-job-button") |> render_click()
    view |> element("#lay-low-button") |> render_click()

    assert has_element?(view, "#resource-cred", "Cred: 0")
    assert has_element?(view, "#resource-heat", "Heat: 0/100")
  end
end
