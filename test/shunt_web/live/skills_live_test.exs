defmodule ShuntWeb.SkillsLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
  end

  test "chrome_meat renders the dormant stub panel with its stub text", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/chrome-meat")

    assert has_element?(view, "#skill-tree-stub", "No table prepped. No hands steady enough yet.")
  end

  test "stub page shows a DORMANT MODULE badge, the generic subsystem line, and the signal-lost footer",
       %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/chrome-meat")

    assert has_element?(view, "#skill-tree-stub .stub-badge", "DORMANT MODULE")

    assert has_element?(
             view,
             "#skill-tree-stub .stub-generic-line",
             "This subsystem only tracks progression"
           )

    assert has_element?(
             view,
             "#skill-tree-stub .stub-footer",
             "SIGNAL LOST · 0x00 · NO HANDSHAKE"
           )
  end

  test "street_alchemy does not render the dormant stub, renders the crafting body", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    refute has_element?(view, "#skill-tree-stub")
    assert has_element?(view, "#scavenge-button")
  end

  test "street_alchemy section headers show their secondary labels", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    html = render(view)
    assert html =~ "⚠ DRAWS HEAT"
    assert html =~ "DECRYPTED BY TIER"
    assert html =~ "BENCH OUTPUT"
  end

  test "renders recipes as locked for a fresh player", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    assert has_element?(view, "#recipe-patchwork_courier_drone", "ENCRYPTED")
    refute has_element?(view, "#recipe-patchwork_courier_drone", "Patchwork Courier Drone")
    refute has_element?(view, "#assemble-patchwork_courier_drone-button")
  end

  test "crafting the Scrap-Forged Soldering Iron unlocks street_alchemy tier 1", %{conn: conn} do
    player = Shunt.Players.get_player!()
    inputs = Shunt.Crafting.RecipeCatalog.fetch!("scrap_forged_soldering_iron").inputs
    Shunt.Repo.update!(Ecto.Changeset.change(player, inventory: inputs))

    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    view |> element("#assemble-scrap_forged_soldering_iron-button") |> render_click()

    assert has_element?(view, "#recipe-patchwork_courier_drone", "Patchwork Courier Drone")
    refute has_element?(view, "#recipe-patchwork_courier_drone", "ENCRYPTED")
  end

  test "an unlocked recipe shows a tier chip, requirement text, and the sell value", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    recipe = Shunt.Crafting.RecipeCatalog.fetch!("scrap_forged_soldering_iron")
    assert has_element?(view, "#recipe-scrap_forged_soldering_iron .recipe-tier-chip", "T0")
    assert has_element?(view, "#recipe-scrap_forged_soldering_iron .recipe-req", "×")

    assert has_element?(
             view,
             "#recipe-scrap_forged_soldering_iron .recipe-value",
             "+#{recipe.sell_value}cr"
           )
  end

  test "the scavenge panel lays out the description/button column beside the raw materials bin",
       %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    assert has_element?(view, ".scavenge-grid #scavenge-button")
    assert has_element?(view, ".scavenge-grid .scavenge-output", "output: 1 unit / run")
    assert has_element?(view, ".scavenge-grid .raw-materials-label", "RAW MATERIALS · BIN")
  end

  test "every raw material always shows its count, even at zero, for a fresh player", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    assert Enum.all?(
             Shunt.Crafting.RawCatalog.items(),
             &has_element?(view, "#raw-#{&1.id}", "×0")
           )
  end

  test "scavenging adds a raw material to the displayed inventory", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    view |> element("#scavenge-button") |> render_click()

    assert Enum.any?(
             Shunt.Crafting.RawCatalog.items(),
             &has_element?(view, "#raw-#{&1.id}")
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
    assert Shunt.Players.get_player!().heat == 85
  end

  test "the assembled section shows a BENCH CLEAN empty state when nothing is assembled", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    assert has_element?(view, "#assembled-empty-state", "BENCH CLEAN")
    assert has_element?(view, "#assembled-empty-state", "no product assembled")
  end

  test "assembled goods sit in a grid and the empty state disappears once something is assembled",
       %{conn: conn} do
    player = Shunt.Players.get_player!()

    Shunt.Repo.update!(
      Ecto.Changeset.change(player, inventory: %{"scrap_forged_soldering_iron" => 1})
    )

    {:ok, view, _html} = live(conn, ~p"/skills/street-alchemy")

    refute has_element?(view, "#assembled-empty-state")
    assert has_element?(view, ".assembled-grid #assembled-scrap_forged_soldering_iron")
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
