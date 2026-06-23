defmodule Shunt.WorldTest do
  use ExUnit.Case, async: true

  # TODO: write tests for Shunt.World against the real location content files
  # under priv/content/locations/*.exs (loaded by Shunt.Content.Store at app
  # boot, same as Shunt.Npcs's tests rely on priv/content/npcs/*.exs):
  #
  #   describe "get_location/1" — returns the location for a known key
  #     (e.g. "shunt9_bazaar"); raises for an unknown key (mirror
  #     Shunt.NpcsTest's get!/1 describe block in test/shunt/npcs_test.exs:17-25).
  #
  #   describe "exits/1" — returns the list of exit maps for a known location key
  #     (assert the destination keys you wrote into that location's exits list).
  #
  #   describe "connected?/2" — true for a real exit pair you wrote (e.g.
  #     shunt9_bazaar -> shunt9_scrap_yard); false for two locations with no
  #     direct exit between them; false in the reverse direction if you only
  #     wrote the exit one way (catches a missing back-exit bug).
end
