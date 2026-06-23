defmodule Shunt.World.ExitTest do
  use ExUnit.Case, async: true

  alias Shunt.World.Exit

  test "raises when :to is omitted" do
    assert_raise ArgumentError, fn -> struct!(Exit, []) end
  end

  test "defaults requirements, tags, and travel_text when only :to is given" do
    exit = struct!(Exit, to: "shunt9_scrap_yard")

    assert exit.to == "shunt9_scrap_yard"
    assert exit.requirements == []
    assert exit.tags == []
    assert exit.travel_text == nil
  end
end
