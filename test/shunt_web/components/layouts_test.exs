defmodule ShuntWeb.LayoutsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  use Phoenix.Component

  alias ShuntWeb.Layouts

  describe "theme_toggle/1" do
    test "renders exactly two buttons" do
      html = render_component(&Layouts.theme_toggle/1, %{})

      assert Regex.scan(~r/<button/, html) |> length() == 2
    end

    test "renders a STREET button that dispatches phx:set-theme with data-phx-theme=street" do
      html = render_component(&Layouts.theme_toggle/1, %{})

      assert html =~ ~r/<button[^>]*data-phx-theme="street"[^>]*>\s*STREET/
      assert Regex.scan(~r/phx:set-theme/, html) |> length() == 2
    end

    test "renders a CORP button that dispatches phx:set-theme with data-phx-theme=corp" do
      html = render_component(&Layouts.theme_toggle/1, %{})

      assert html =~ ~r/<button[^>]*data-phx-theme="corp"[^>]*>\s*CORP/
    end

    test "does not render icon-only buttons" do
      html = render_component(&Layouts.theme_toggle/1, %{})

      refute html =~ "hero-computer-desktop-micro"
      refute html =~ "hero-sun-micro"
      refute html =~ "hero-moon-micro"
    end
  end

  describe "app/1" do
    defp app_wrapper(assigns) do
      ~H"""
      <Layouts.app flash={@flash} player={@player} active={@active} status={@status}>
        <p>content</p>
      </Layouts.app>
      """
    end

    defp render_app(overrides \\ %{}) do
      assigns =
        Map.merge(
          %{flash: %{}, player: %{cred: 0, scrip: 0, heat: 0}, active: :hub, status: nil},
          overrides
        )

      render_component(&app_wrapper/1, assigns)
    end

    test "renders fixed decorative overlay divs for the atmosphere pass" do
      html = render_app()

      assert html =~ ~s(class="noise-overlay")
      assert html =~ ~s(class="scanline")
      assert html =~ ~s(class="scanline-sweep")
      assert html =~ ~s(class="vignette")
    end
  end
end
