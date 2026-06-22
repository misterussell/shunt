defmodule Shunt.Content.StoreTest do
  use ExUnit.Case, async: true

  # TODO: once Shunt.Content.Store (lib/shunt/content/store.ex) is implemented and wired
  # into lib/shunt/application.ex, write tests covering every entry in its @sources list -
  # this supersedes test/shunt/npcs/store_test.exs (see the TODO already left there), so
  # delete that file once this one is in place. For each {table, _dir} in @sources except
  # :skill_trees, assert Shunt.Content.all(table) returns a non-empty list whose items all
  # have a :key field, and that Shunt.Content.fetch!(table, some_known_key) returns the
  # matching item. For :skill_trees specifically, assert Shunt.Content.all(:skill_trees)
  # returns the same 4-tree list currently hardcoded in
  # lib/shunt/skills/catalog.ex's @trees. Also assert repeated calls return identical
  # results (mirrors the existing "repeated calls don't error" test in the file being
  # replaced).
  describe "all sources load at boot" do
  end
end
