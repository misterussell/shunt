defmodule Shunt.QuestItemsTest do
  use ExUnit.Case, async: true

  alias Shunt.Content
  alias Shunt.Crafting.RawCatalog

  test "quest items load as their own content category, fetchable by id" do
    item = Content.fetch!(:quest_items, "juno_parcel")

    assert item.name
  end

  test "quest items are isolated from the raws / scavenge pool" do
    raw_ids = Enum.map(RawCatalog.items(), & &1.id)

    refute "juno_parcel" in raw_ids
  end
end
