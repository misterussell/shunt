defmodule ShuntWeb.ChromeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  use Phoenix.Component

  alias ShuntWeb.Chrome

  defp render_panel(assigns) do
    assigns = Map.put_new(assigns, :active, false)
    render_component(&panel_wrapper/1, assigns)
  end

  defp panel_wrapper(assigns) do
    ~H"""
    <Chrome.panel active={@active}>
      <p>hello</p>
    </Chrome.panel>
    """
  end

  test "renders inner content inside a .panel div" do
    html = render_panel(%{})

    assert html =~ ~r/class="panel\s*"/
    refute html =~ "panel--active"
    assert html =~ "<p>hello</p>"
  end

  test "active panel gets the panel--active modifier class" do
    html = render_panel(%{active: true})

    assert html =~ "panel--active"
  end

  defp btn_wrapper(assigns) do
    ~H"""
    <Chrome.btn variant={@variant}>[ GO ]</Chrome.btn>
    """
  end

  test "renders a button with the variant's class and slot content" do
    html = render_component(&btn_wrapper/1, %{variant: :primary})

    assert html =~ ~r/class="btn-primary"/
    assert html =~ "[ GO ]"
  end

  test ":dead variant is always disabled" do
    html = render_component(&btn_wrapper/1, %{variant: :dead})

    assert html =~ "disabled"
    assert html =~ ~r/class="btn-dead"/
  end

  defp section_header_wrapper(assigns) do
    ~H"""
    <Chrome.section_header secondary={@secondary} secondary_amber={@secondary_amber}>
      BLACK_MARKET
    </Chrome.section_header>
    """
  end

  test "renders the label inside a .section-header element" do
    html = render_component(&section_header_wrapper/1, %{secondary: nil, secondary_amber: false})

    assert html =~ ~r/class="section-header"/
    assert html =~ "BLACK_MARKET"
  end

  test "renders the bracket motif around the label" do
    html = render_component(&section_header_wrapper/1, %{secondary: nil, secondary_amber: false})

    assert html =~ ~r/┌─\[\s*BLACK_MARKET\s*\]/
    assert html =~ "─┐"
  end

  test "renders a secondary label when given, without amber styling by default" do
    html =
      render_component(&section_header_wrapper/1, %{
        secondary: "0x1A · FENCE_PROTOCOL",
        secondary_amber: false
      })

    assert html =~ "0x1A · FENCE_PROTOCOL"
    refute html =~ "section-header-secondary--amber"
  end

  test "omits the secondary label entirely when not given" do
    html = render_component(&section_header_wrapper/1, %{secondary: nil, secondary_amber: false})

    refute html =~ "section-header-secondary"
  end

  test "secondary_amber adds the amber modifier class to the secondary label" do
    html =
      render_component(&section_header_wrapper/1, %{
        secondary: "⚠ DRAWS HEAT",
        secondary_amber: true
      })

    assert html =~ "section-header-secondary--amber"
  end

  @tree %{
    key: "street_alchemy",
    name: "Street Alchemy",
    description: "Breaking down scavenged tech.",
    tiers: [
      %{tier: 1, name: "Scrap Picker"},
      %{tier: 2, name: "Bench Tinkerer"},
      %{tier: 3, name: "Salvage Artisan"},
      %{tier: 4, name: "Patchworker's Peer"},
      %{tier: 5, name: "Old-World Machinist"}
    ]
  }

  defp ladder_track_wrapper(assigns) do
    ~H"""
    <Chrome.ladder_track tree={@tree} current_tier={@current_tier} />
    """
  end

  test "renders the tree name and every tier's name" do
    html = render_component(&ladder_track_wrapper/1, %{tree: @tree, current_tier: 0})

    assert html =~ "Street Alchemy"
    assert html =~ "Scrap Picker"
    assert html =~ "Old-World Machinist"
  end

  test "tier 0: no segment is reached or current, all five are unreached" do
    html = render_component(&ladder_track_wrapper/1, %{tree: @tree, current_tier: 0})

    refute html =~ "ladder-segment--reached"
    refute html =~ "ladder-segment--current"
    assert Regex.scan(~r/ladder-segment--unreached/, html) |> length() == 5
  end

  test "tier 1: tier 1's segment is both reached and current, the rest are unreached" do
    html = render_component(&ladder_track_wrapper/1, %{tree: @tree, current_tier: 1})

    assert Regex.scan(~r/ladder-segment--reached/, html) |> length() == 1
    assert Regex.scan(~r/ladder-segment--current/, html) |> length() == 1
    assert Regex.scan(~r/ladder-segment--unreached/, html) |> length() == 4
  end

  defp wallet_hud_wrapper(assigns) do
    ~H"""
    <Chrome.wallet_hud player={@player} />
    """
  end

  test "exposes #resource-cred/#resource-scrip/#resource-heat ids for tests to target" do
    html = render_component(&wallet_hud_wrapper/1, %{player: %{cred: 42, scrip: 7, heat: 10}})

    assert html =~ ~s(id="resource-cred")
    assert html =~ ~s(id="resource-scrip")
    assert html =~ ~s(id="resource-heat")
  end

  test "renders cred, scrip, and the numeric heat readout" do
    html = render_component(&wallet_hud_wrapper/1, %{player: %{cred: 42, scrip: 7, heat: 10}})

    assert html =~ "42"
    assert html =~ "7"
    assert html =~ "HEAT"
    assert html =~ "10/100"
  end

  test "low heat shows the GHOST status label and no danger styling" do
    html = render_component(&wallet_hud_wrapper/1, %{player: %{cred: 0, scrip: 0, heat: 10}})

    assert html =~ "GHOST"
    refute html =~ "heat-bar--danger"
  end

  test "mid heat shows the EYES ON YOU status label" do
    html = render_component(&wallet_hud_wrapper/1, %{player: %{cred: 0, scrip: 0, heat: 50}})

    assert html =~ "EYES ON YOU"
    refute html =~ "heat-bar--danger"
  end

  test "heat at or above 75 shows the AUTHORITY INBOUND label and danger styling" do
    html = render_component(&wallet_hud_wrapper/1, %{player: %{cred: 0, scrip: 0, heat: 75}})

    assert html =~ "AUTHORITY INBOUND"
    assert html =~ "heat-bar--danger"
  end

  test "cred, scrip, and heat each render as a bordered gauge box with label and value" do
    html = render_component(&wallet_hud_wrapper/1, %{player: %{cred: 42, scrip: 7, heat: 10}})

    assert Regex.scan(~r/class="gauge[" ]/, html) |> length() == 3
    assert html =~ ~r/class="gauge-label">\s*CRED\s*</
    assert html =~ ~r/class="gauge-label">\s*SCRIP\s*</
    assert html =~ ~r/class="gauge-value[^"]*">\s*42\s*</
  end
end
