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

    <%!-- TODO: add a sticky (top:0) utility strip here: a "root@shunt-9:~/<cwd>$" prompt with
    a blinking cursor span, "NET: DARKLINE" text, a blinking REC dot, and a live clock. `cwd`
    is a case/cond on @active: :hub -> "blackmarket", :ghostwork -> "ghostwork", :chrome_meat
    -> "chrome-meat", :web -> "the-web", :street_alchemy -> "street-alchemy" (matches each
    tab's route slug except :hub, which keeps the thematic "blackmarket"). The clock is a
    client-side JS hook (phx-hook="Clock", phx-update="ignore" on its element) whose hook
    calls setInterval and writes the time into its own textContent — no server round-trips.
    Move the <.theme_toggle /> call out of <header> below and into this strip, under a
    "LIGHTING" label, when this lands. --%>
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

    <%!-- TODO: restyle this into the brief's footer ticker (fixed bottom:0): a cyan ">"
    caret before @status, status text truncated with ellipsis, a blinking cursor span after
    it, a flex-1 spacer, then "SHUNT_9 · NIGHT_CYCLE · ALL SYSTEMS NOMINAL" right-aligned
    (static text — no live data source for the ticker segment yet). --%>
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
end
