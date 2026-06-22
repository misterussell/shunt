defmodule Shunt.ContentTest do
  use ExUnit.Case, async: true

  alias Shunt.Content

  describe "all/1 and fetch!/2" do
    test "all/1 returns every inserted item, regardless of insertion order" do
      table = :content_test_all
      :ets.new(table, [:set, :public, :named_table])
      :ets.insert(table, {"b", %{key: "b"}})
      :ets.insert(table, {"a", %{key: "a"}})

      assert MapSet.new(Content.all(table)) == MapSet.new([%{key: "a"}, %{key: "b"}])
    end

    test "fetch!/2 returns the item for a known key" do
      table = :content_test_fetch_known
      :ets.new(table, [:set, :public, :named_table])
      :ets.insert(table, {"a", %{key: "a"}})

      assert Content.fetch!(table, "a") == %{key: "a"}
    end

    test "fetch!/2 raises for an unknown key" do
      table = :content_test_fetch_unknown
      :ets.new(table, [:set, :public, :named_table])

      assert_raise RuntimeError, ~r/unknown content_test_fetch_unknown key/, fn ->
        Content.fetch!(table, "missing")
      end
    end
  end
end
