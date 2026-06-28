defmodule Shunt.DistrictTest do
  use ExUnit.Case, async: true

  alias Shunt.District
  alias Shunt.Players.Player

  describe "fact/3 with the :power ordinal fact" do
    test "is :offline when the generator has not been repaired" do
      assert District.fact(%Player{}, "shunt9", :power) == :offline
    end

    test "is :partial when the generator is patched" do
      player = %Player{infrastructure: %{"shunt9_power_relay_generator" => "patched"}}

      assert District.fact(player, "shunt9", :power) == :partial
    end

    test "is :online when the generator is repaired" do
      player = %Player{infrastructure: %{"shunt9_power_relay_generator" => "repaired"}}

      assert District.fact(player, "shunt9", :power) == :online
    end
  end

  describe "fact_meets?/5 with op :>=" do
    test "met when the derived level is above the target" do
      player = %Player{infrastructure: %{"shunt9_power_relay_generator" => "repaired"}}

      assert District.fact_meets?(player, "shunt9", :power, :>=, :partial)
    end

    test "met when the derived level equals the target" do
      player = %Player{infrastructure: %{"shunt9_power_relay_generator" => "repaired"}}

      assert District.fact_meets?(player, "shunt9", :power, :>=, :online)
    end

    test "unmet when the derived level is below the target" do
      refute District.fact_meets?(%Player{}, "shunt9", :power, :>=, :online)
    end
  end

  describe "fact_meets?/5 with op :<" do
    test "met when the derived level is below the target" do
      assert District.fact_meets?(%Player{}, "shunt9", :power, :<, :online)
    end

    test "unmet when the derived level equals the target" do
      player = %Player{infrastructure: %{"shunt9_power_relay_generator" => "repaired"}}

      refute District.fact_meets?(player, "shunt9", :power, :<, :online)
    end
  end
end
