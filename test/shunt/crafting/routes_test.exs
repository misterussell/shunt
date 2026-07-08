defmodule Shunt.Crafting.RoutesTest do
  use ExUnit.Case, async: true

  alias Shunt.Crafting.Routes

  describe "all/0" do
    test "returns the six routes as %{key, label} in display order" do
      assert Routes.all() == [
               %{key: :repair, label: "Repair"},
               %{key: :tools, label: "Tools"},
               %{key: :ghostwork, label: "Ghostwork"},
               %{key: :chrome_meat, label: "Chrome & Meat"},
               %{key: :web, label: "Web"},
               %{key: :fence, label: "Fence"}
             ]
    end
  end

  describe "keys/0" do
    test "returns the six route atoms in display order" do
      assert Routes.keys() == [:repair, :tools, :ghostwork, :chrome_meat, :web, :fence]
    end
  end

  describe "label/1" do
    test "returns the display label for a route key" do
      assert Routes.label(:chrome_meat) == "Chrome & Meat"
      assert Routes.label(:fence) == "Fence"
    end

    test "raises for an unknown route key" do
      assert_raise KeyError, fn -> Routes.label(:not_a_route) end
    end
  end
end
