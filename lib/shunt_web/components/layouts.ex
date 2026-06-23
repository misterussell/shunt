defmodule ShuntWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ShuntWeb, :html

  alias ShuntWeb.Chrome

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :player, :map, required: true, doc: "for the WalletHud (Cred/Scrip/Heat)"

  attr :active, :atom,
    required: true,
    values: [:hub, :ghostwork, :chrome_meat, :web, :street_alchemy],
    doc: "which nav tab to highlight"

  # TODO: restyle the plain .footer-ticker div below into the brief's §4 footer ticker (fixed
  # bottom:0): "&gt;" cyan caret before @status, truncated with ellipsis, a blinking cursor
  # span, flex-1 spacer, "SHUNT_9 · NIGHT_CYCLE · <ticker>" on the right. Also still pending
  # here (full atmosphere pass, per agreed scope — see Shunt.dc.html lines 30-35 for the
  # reference markup):
  #   - fixed noise-overlay / scanline / scanline-sweep / vignette divs (pointer-events:none)
  #   - utility strip (sticky top:0): "root@shunt-9:~/<cwd>$" prompt with a blinking cursor,
  #     "NET: DARKLINE", a blinking REC dot, and a live clock — `cwd` derives from @active
  #     (e.g. :hub -> "blackmarket", :ghostwork -> "ghostwork")
  #   - the LIGHTING toggle replacing .theme_toggle/1 below (street/corp, see that function's
  #     own TODO)
  attr :status, :string, default: nil, doc: "footer-ticker status line set by handle_events"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="main-bar">
      <span class="wordmark">SHUNT</span>
      <Chrome.wallet_hud player={@player} />
      <nav class="nav-tabs">
        <.link navigate={~p"/"} class={["tab", @active == :hub && "tab--active"]}>HUB</.link>
        <.link
          navigate={~p"/skills/ghostwork"}
          class={["tab", @active == :ghostwork && "tab--active"]}
        >
          GHOSTWORK
        </.link>
        <.link
          navigate={~p"/skills/chrome-meat"}
          class={["tab", @active == :chrome_meat && "tab--active"]}
        >
          CHROME//MEAT
        </.link>
        <.link navigate={~p"/skills/the-web"} class={["tab", @active == :web && "tab--active"]}>
          THE_WEB
        </.link>
        <.link
          navigate={~p"/skills/street-alchemy"}
          class={["tab", @active == :street_alchemy && "tab--active"]}
        >
          ST_ALCHEMY
        </.link>
      </nav>
      <.theme_toggle />
    </header>

    <main class="main-content">
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />

    <div class="footer-ticker">{@status || "SYSTEM ONLINE // DECK WARM"}</div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides the STREET vs CORP lighting-mood toggle (brief §4: "two cyberpunk-themed modes
  ... both stay dark-cyberpunk; only the lighting mood changes. No light mode.").

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    # TODO: replace this 3-button system/light/dark toggle with a 2-button STREET/CORP one,
    # matching Shunt.dc.html's "LIGHTING" power-switch control (label above, two adjacent
    # buttons in a bordered strip, the active one filled with var(--cyan) background +
    # #03100C text, the inactive one transparent/var(--muted)). Each button keeps the same
    # phx-click={JS.dispatch("phx:set-theme")} + data-phx-theme="street"/"corp" mechanism —
    # only the values and button count change, not the dispatch approach. Drop the icon-only
    # hero-* buttons in favor of the brief's text labels ("STREET"/"CORP"), since this is a
    # mood toggle, not a system/light/dark icon picker. Active state should read from
    # `assigns[:theme]` if threaded in as an attr, or stay purely CSS-driven via the
    # [data-theme=street]/[data-theme=corp] attribute selectors like the rest of the chrome.
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
