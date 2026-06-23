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

  attr :status, :string, default: nil, doc: "footer-ticker status line set by handle_events"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="noise-overlay"></div>
    <div class="scanline"></div>
    <div class="scanline-sweep"></div>
    <div class="vignette"></div>

    <div class="utility-strip">
      <span class="utility-strip-prompt">root@shunt-9:~/{cwd(@active)}$</span>
      <span class="utility-strip-cursor"></span>
      <span class="utility-strip-net">NET: DARKLINE</span>
      <span class="utility-strip-rec"></span>
      <span id="utility-strip-clock" phx-hook="Clock" phx-update="ignore"></span>
      <div class="flex-1"></div>
      <span class="utility-strip-lighting-label">LIGHTING</span>
      <.theme_toggle />
    </div>

    <header class="main-bar">
      <%!-- TODO: wrap "SHUNT" in a flex-column div with a second span below it reading
        "NODE_9 · MAKESHIFT DECK · v0.9.4" (docs/design-comp.html lines 52-55: wordmark
        block is `display:flex; flex-direction:column; line-height:1;` with the subtitle
        span at font-size:8.5px, letter-spacing:0.18em, color:var(--muted),
        margin-top:4px). Add a `.wordmark-sub` class in app.css for the subtitle span. --%>
      <span class="wordmark">SHUNT</span>
      <%!-- TODO: insert a vertical divider div between the wordmark and the wallet HUD,
        matching docs/design-comp.html line 57: width:1px; height:34px;
        background:repeating-linear-gradient(180deg, var(--border-c) 0 3px, transparent
        3px 6px). Add a `.main-bar-divider` class in app.css. --%>
      <Chrome.wallet_hud player={@player} />
      <%!-- TODO: add `<div class="flex-1"></div>` here (matching the utility-strip's
        existing spacer pattern above) so `<nav class="nav-tabs">` is pushed to the right
        edge of the bar instead of sitting immediately after the wallet HUD — see
        docs/design-comp.html line 81 `<span style="flex:1;"></span>` between the gauges
        and `<nav>`. --%>
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
    </header>

    <main class="main-content">
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />

    <div class="footer-ticker">
      <span class="footer-ticker-caret">&gt;</span>
      <span class="footer-ticker-status truncate">{@status || "SYSTEM ONLINE // DECK WARM"}</span>
      <span class="footer-ticker-cursor"></span>
      <div class="flex-1"></div>
      <span class="footer-ticker-sysid">SHUNT_9 · NIGHT_CYCLE · ALL SYSTEMS NOMINAL</span>
    </div>
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
    ~H"""
    <div class="theme-toggle">
      <button
        class="theme-toggle-btn"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="street"
      >
        STREET
      </button>

      <button
        class="theme-toggle-btn"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="corp"
      >
        CORP
      </button>
    </div>
    """
  end

  defp cwd(:hub), do: "blackmarket"
  defp cwd(:ghostwork), do: "ghostwork"
  defp cwd(:chrome_meat), do: "chrome-meat"
  defp cwd(:web), do: "the-web"
  defp cwd(:street_alchemy), do: "street-alchemy"
end
