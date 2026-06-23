defmodule ShuntWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ShuntWeb, :html

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

  # TODO: add the assigns the cyberpunk shell needs from every caller:
  #   attr :player, :map, required: true  — for the WalletHud (Cred/Scrip/Heat)
  #   attr :active, :atom, required: true — :hub | :ghostwork | :chrome_meat | :web |
  #     :street_alchemy, used to highlight the current nav tab
  #   attr :status, :string, default: nil — last action's status line for the footer ticker
  #     (e.g. "STASHED // REFURB DECK // HEAT +8"); HubLive/SkillsLive set this in their
  #     handle_events, distinct from @flash which stays for narrative beats (NPC met/loyalty
  #     band changes, heat-event warnings)
  slot :inner_block, required: true

  def app(assigns) do
    # TODO: replace this stock Phoenix navbar/main/flash shell with the brief's §4 layout —
    # everything below is staged from Shunt.dc.html's structure (the UTILITY STRIP, MAIN BAR,
    # and FOOTER TICKER blocks), translated from inline styles to CSS classes in app.css:
    #
    #   1. Atmosphere stack (full pass, per agreed scope): a fixed noise-overlay div, a
    #      scanline div, a drifting scanline-sweep div, and a vignette div — all
    #      pointer-events:none, stacked via z-index, ported from Shunt.dc.html lines 30-35.
    #
    #   2. Utility strip (sticky top:0): "root@shunt-9:~/<cwd>$" prompt with a blinking
    #      cursor span, flex-1 spacer, "NET: DARKLINE", a blinking REC dot, and a live clock
    #      (HH:MM:SS-ish — Shunt.dc.html only ticks seconds via a 1s setInterval-equivalent;
    #      decide whether to drive this from a LiveView `:timer.send_interval/2` tick in each
    #      LiveView's mount/2, or a client JS hook, and use that consistently). `cwd` should
    #      derive from @active (e.g. :hub -> "blackmarket", :ghostwork -> "ghostwork").
    #
    #   3. Main bar (sticky top, below the strip): wordmark "SHUNT" + "NODE_9 · MAKESHIFT
    #      DECK · v0.9.4" tag on the left, a vertical hairline divider, then
    #      <Chrome.wallet_hud player={@player} />, a flex-1 spacer, the nav tabs (HUB,
    #      GHOSTWORK, CHROME//MEAT, THE_WEB, ST_ALCHEMY — five <.link navigate={...}> styled
    #      as tabs, highlighting whichever matches @active via a "tab--active" class instead
    #      of inline style), and the LIGHTING toggle (replaces .theme_toggle/1 below).
    #
    #   4. <main> wrapping {render_slot(@inner_block)} at the brief's max-w-1240px.
    #
    #   5. <.flash_group flash={@flash} /> (keep — restyle its rendered markup via CSS, not
    #      structure, since core_components.ex's flash/1 already handles client/server error
    #      states this game still needs).
    #
    #   6. Footer ticker (fixed bottom:0): "&gt;" cyan caret, @status (or a sensible default
    #      like "SYSTEM ONLINE // DECK WARM" when nil) truncated with ellipsis, a blinking
    #      cursor span, flex-1 spacer, "SHUNT_9 · NIGHT_CYCLE · <ticker>" on the right (ticker
    #      can be a static placeholder or derived from the clock tick from #2 — keep it
    #      simple, it's pure flavor with no real data backing it).
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
          <li>
            <a href="https://hexdocs.pm/phoenix/overview.html" class="btn btn-primary">
              Get Started <span aria-hidden="true">&rarr;</span>
            </a>
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
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
