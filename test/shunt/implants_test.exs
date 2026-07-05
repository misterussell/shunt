defmodule Shunt.ImplantsTest do
  use ExUnit.Case, async: true

  alias Shunt.Implants

  describe "items/0" do
    test "returns implant defs, each with a unique id" do
      items = Implants.items()

      assert items != []
      assert items |> Enum.map(& &1.id) |> Enum.uniq() |> length() == length(items)
    end
  end

  describe "fetch!/1" do
    test "returns the matching implant def" do
      assert Implants.fetch!("lineman_graft").id == "lineman_graft"
    end

    test "raises on an unknown key" do
      assert_raise RuntimeError, ~r/unknown implants key/, fn ->
        Implants.fetch!("not_a_real_key")
      end
    end
  end
end
