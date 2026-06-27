defmodule Shunt.HeatTest do
  use ExUnit.Case, async: true

  alias Shunt.Heat

  describe "clamp/1" do
    test "clamps negative values to 0" do
      assert Heat.clamp(-5) == 0
    end

    test "clamps values above 100 to 100" do
      assert Heat.clamp(150) == 100
    end

    test "passes in-range values through unchanged" do
      assert Heat.clamp(42) == 42
    end
  end

  describe "band_for/1" do
    test "returns :none below 30" do
      assert Heat.band_for(0) == :none
      assert Heat.band_for(29) == :none
    end

    test "returns :low for 30..59" do
      assert Heat.band_for(30) == :low
      assert Heat.band_for(59) == :low
    end

    test "returns :medium for 60..84" do
      assert Heat.band_for(60) == :medium
      assert Heat.band_for(84) == :medium
    end

    test "returns :high for 85..100" do
      assert Heat.band_for(85) == :high
      assert Heat.band_for(100) == :high
    end
  end

  describe "resolve/2" do
    test "returns {new_heat, nil} when staying within the same band" do
      assert Heat.resolve(10, 20) == {20, nil}
    end

    test "returns {new_heat, nil} when heat decreases across a band boundary" do
      assert Heat.resolve(65, 50) == {50, nil}
    end

    test "fires a :low event and pins heat to the low threshold when crossing upward into :low" do
      assert {30, event} = Heat.resolve(10, 35)
      assert event.band == :low
    end

    test "fires a :medium event and pins heat to the medium threshold when crossing upward into :medium" do
      assert {60, event} = Heat.resolve(40, 65)
      assert event.band == :medium
    end

    test "fires a :high event and pins heat to the high threshold when crossing upward into :high" do
      assert {85, event} = Heat.resolve(70, 90)
      assert event.band == :high
    end
  end
end
