defmodule ShuntWeb.SkillsLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
  end

  # TODO: replace dashboard_live_test.exs's single "renders the four skill trees as locked
  # for a fresh player" test (lines 91-98, which checked one page for all four trees at once)
  # with one test per route now that each tree is its own LiveView:
  #   - visiting ~p"/skills/ghostwork" renders the dormant stub panel with the
  #     priv/content/skills/trees.exs "ghostwork" stub text ("No backdoor cracked yet.")
  #   - same for ~p"/skills/chrome-meat" and ~p"/skills/the-web" with their respective stubs
  #   - visiting ~p"/skills/street-alchemy" does NOT render a stub — it renders the live
  #     crafting body instead (assert refute has_element?(view, ...stub marker...) and assert
  #     the scavenge button/recipe list are present)
  # Keep an id like "#skill-tree-stub" (or similar, matching whatever id chrome.ex's dormant
  # panel ends up using) so these assertions don't depend on exact stub copy.

  # TODO: port "renders recipes as locked for a fresh player" (dashboard_live_test.exs lines
  # 229-233) and "crafting the Scrap-Forged Soldering Iron unlocks street_alchemy tier 1"
  # (lines 235-245) against `live(conn, ~p"/skills/street-alchemy")` — same
  # #recipe-patchwork_courier_drone / #assemble-scrap_forged_soldering_iron-button ids.

  # TODO: port "scavenging adds a raw material to the displayed inventory" and "scavenging
  # across a heat threshold flashes the fired event and drops heat" (dashboard_live_test.exs
  # lines 171-195) against `live(conn, ~p"/skills/street-alchemy")` — same #scavenge-button /
  # #raw-#{key} ids and #flash-error assertion. Additionally assert the new @status line
  # mentions "SCAVENGED" for the non-threshold-crossing case, since that's new behavior.
end
