defmodule Shunt.Web.RumorTest do
  use ExUnit.Case, async: true

  alias Shunt.Web.Rumor

  setup do
    rumor = %Rumor{
      id: "test_rumor",
      title: "Juno's Supplier",
      description: "Someone has been supplying Juno with corporate hardware.",
      source: "npc",
      tags: ["corporate", "smuggling"]
    }

    :ets.insert(:rumors, {rumor.id, rumor})
    on_exit(fn -> :ets.delete(:rumors, rumor.id) end)
    %{rumor: rumor}
  end

  describe "fetch!/1" do
    test "returns the %Rumor{} for a known id", %{rumor: rumor} do
      assert Rumor.fetch!("test_rumor") == rumor
    end

    test "raises for an unknown id" do
      assert_raise RuntimeError, fn -> Rumor.fetch!("no_such_rumor") end
    end
  end

  describe "all/0" do
    test "includes loaded rumors", %{rumor: rumor} do
      assert rumor in Rumor.all()
    end
  end
end
