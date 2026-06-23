defmodule ShuntWeb.SkillsLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
  end

  test "ghostwork renders the dormant stub panel with its stub text", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

    assert has_element?(view, "#skill-tree-stub", "No backdoor cracked yet.")
  end

  test "chrome_meat renders the dormant stub panel with its stub text", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/chrome-meat")

    assert has_element?(view, "#skill-tree-stub", "No table prepped. No hands steady enough yet.")
  end

  test "web renders the dormant stub panel with its stub text", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/the-web")

    assert has_element?(
             view,
             "#skill-tree-stub",
             "No threads pulled. The Web is listening, not talking."
           )
  end

  test "street_alchemy does not render the dormant stub, renders the crafting body", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    refute has_element?(view, "#skill-tree-stub")
    assert has_element?(view, "#scavenge-button")
  end

  test "renders recipes as locked for a fresh player", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    assert has_element?(view, "#recipe-patchwork_courier_drone", "Locked")
  end

  test "crafting the Scrap-Forged Soldering Iron unlocks street_alchemy tier 1", %{conn: conn} do
    player = Shunt.Players.get_player!()
    inputs = Shunt.Crafting.RecipeCatalog.fetch!("scrap_forged_soldering_iron").inputs
    Shunt.Repo.update!(Ecto.Changeset.change(player, inventory: inputs))

    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    view |> element("#assemble-scrap_forged_soldering_iron-button") |> render_click()

    assert has_element?(view, "#recipe-patchwork_courier_drone", "Unlocked")
  end

  test "scavenging adds a raw material to the displayed inventory", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    view |> element("#scavenge-button") |> render_click()

    assert Enum.any?(
             Shunt.Crafting.RawCatalog.items(),
             &has_element?(view, "#raw-#{&1.key}")
           )
  end

  test "scavenging sets a status line naming the raw material gained", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    html = view |> element("#scavenge-button") |> render_click()

    assert html =~ "SCAVENGED"
  end

  test "scavenging across a heat threshold flashes the fired event and drops heat", %{
    conn: conn
  } do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, heat: 84))

    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    html = view |> element("#scavenge-button") |> render_click()

    assert html =~ "Scrip"
    assert has_element?(view, "#flash-error")
    assert Shunt.Players.get_player!().heat == 80
  end

  test "assembling a recipe shows the assembled good with a sell button", %{conn: conn} do
    player = Shunt.Players.get_player!()
    inputs = Shunt.Crafting.RecipeCatalog.fetch!("scrap_forged_soldering_iron").inputs
    Shunt.Repo.update!(Ecto.Changeset.change(player, inventory: inputs))

    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    view |> element("#assemble-scrap_forged_soldering_iron-button") |> render_click()

    assert has_element?(view, "#assembled-scrap_forged_soldering_iron")
  end

  test "selling an assembled good pays out scrip and clears the assembled listing", %{
    conn: conn
  } do
    player = Shunt.Players.get_player!()

    Shunt.Repo.update!(
      Ecto.Changeset.change(player, inventory: %{"scrap_forged_soldering_iron" => 1})
    )

    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    view |> element("#sell-assembled-scrap_forged_soldering_iron-button") |> render_click()

    refute has_element?(view, "#assembled-scrap_forged_soldering_iron")
    assert Shunt.Players.get_player!().scrip > 0
  end
end
