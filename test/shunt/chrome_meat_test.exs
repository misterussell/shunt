defmodule Shunt.ChromeMeatTest do
  use ExUnit.Case, async: true

  alias Shunt.ChromeMeat

  describe "clamp/1" do
    test "leaves an in-range value unchanged" do
      assert ChromeMeat.clamp(47) == 47
    end

    test "floors at 0" do
      assert ChromeMeat.clamp(-5) == 0
    end

    test "caps at 100" do
      assert ChromeMeat.clamp(140) == 100
    end
  end
end
