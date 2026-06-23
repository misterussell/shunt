defmodule ShuntWeb.LayoutsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

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
end
