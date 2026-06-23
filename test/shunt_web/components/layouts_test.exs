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

    test "footer ticker renders a caret, the status, a blinking cursor, and the right-aligned system line" do
      html = render_app(%{status: "FENCED: 3x SCRAP CHIP"})

      assert html =~ ~s(class="footer-ticker-caret")
      assert html =~ "FENCED: 3x SCRAP CHIP"
      assert html =~ ~s(class="footer-ticker-cursor")
      assert html =~ ~s(class="flex-1")
      assert html =~ "SHUNT_9 · NIGHT_CYCLE · ALL SYSTEMS NOMINAL"
    end

    test "footer ticker status falls back to the default line when @status is nil" do
      html = render_app(%{status: nil})

      assert html =~ "SYSTEM ONLINE // DECK WARM"
    end

    test "utility strip prompt's cwd matches each active tab's route slug" do
      for {active, cwd} <- [
            hub: "blackmarket",
            ghostwork: "ghostwork",
            chrome_meat: "chrome-meat",
            web: "the-web",
            street_alchemy: "street-alchemy"
          ] do
        html = render_app(%{active: active})

        assert html =~ "root@shunt-9:~/#{cwd}$"
      end
    end

    test "utility strip shows NET: DARKLINE and a REC dot" do
      html = render_app()

      assert html =~ "NET: DARKLINE"
      assert html =~ ~s(class="utility-strip-rec")
    end

    test "utility strip includes a client-side clock hook that LiveView won't manage the DOM of" do
      html = render_app()

      assert html =~ ~s(phx-hook="Clock")
      assert html =~ ~s(phx-update="ignore")
    end

    test "wordmark shows a subtitle line under SHUNT" do
      html = render_app()

      assert html =~ ~s(class="wordmark-sub")
      assert html =~ "NODE_9 · MAKESHIFT DECK · v0.9.4"
    end

    test "a divider sits between the wordmark and the wallet HUD" do
      html = render_app()

      assert html =~ ~s(class="main-bar-divider")
    end

    test "a spacer pushes the nav tabs to the right edge of the main bar" do
      html = render_app()
      [_, header_section] = String.split(html, "<header", parts: 2)
      [header_only, _] = String.split(header_section, "</header>", parts: 2)
      [before_nav, _] = String.split(header_only, ~s(class="nav-tabs"), parts: 2)

      assert before_nav =~ ~s(class="flex-1")
    end

    test "theme toggle moves out of <header> and into the utility strip under a LIGHTING label" do
      html = render_app()
      [before_header, _rest] = String.split(html, "<header", parts: 2)
      [_, header_section] = String.split(html, "<header", parts: 2)
      [header_only, _] = String.split(header_section, "</header>", parts: 2)

      assert before_header =~ "theme-toggle"
      assert before_header =~ "LIGHTING"
      refute header_only =~ "theme-toggle"
    end
  end
end
