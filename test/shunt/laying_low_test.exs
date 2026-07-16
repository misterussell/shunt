defmodule Shunt.LayingLowTest do
  use ExUnit.Case, async: true

  alias Shunt.LayingLow
  alias Shunt.Players.Player

  describe "laying_low?/1" do
    test "true when the player is in the mode" do
      assert LayingLow.laying_low?(%Player{mode: "laying_low"})
    end

    test "false otherwise" do
      refute LayingLow.laying_low?(%Player{mode: nil})
      refute LayingLow.laying_low?(%Player{mode: "on_the_run"})
    end
  end

  describe "can_enter?/1" do
    test "true at the medium Heat band and above" do
      assert LayingLow.can_enter?(%Player{heat: 60})
      assert LayingLow.can_enter?(%Player{heat: 90})
    end

    test "false below the medium band" do
      refute LayingLow.can_enter?(%Player{heat: 59})
      refute LayingLow.can_enter?(%Player{heat: 0})
    end
  end

  describe "enter/1" do
    test "sets the mode when Heat is high enough" do
      assert LayingLow.enter(%Player{heat: 70}) == {:ok, [{:set, :mode, "laying_low"}]}
    end

    test "errors when Heat is too low" do
      assert LayingLow.enter(%Player{heat: 20}) == {:error, :heat_too_low}
    end
  end

  describe "leave/1" do
    test "clears the mode when laying low" do
      assert LayingLow.leave(%Player{mode: "laying_low"}) == {:ok, [{:set, :mode, nil}]}
    end

    test "errors when not laying low" do
      assert LayingLow.leave(%Player{mode: nil}) == {:error, :not_laying_low}
    end
  end

  describe "activities while laying low" do
    setup do
      %{player: %Player{mode: "laying_low", scrip: 100}}
    end

    test "rest advances time and reduces Heat", %{player: player} do
      assert {:ok, [{:advance_time, 6}, {:heat, -5}], %{narrative: _}} = LayingLow.rest(player)
    end

    test "gather_rumors advances time and reduces Heat", %{player: player} do
      assert {:ok, [{:advance_time, 4}, {:heat, -3}], %{narrative: _}} =
               LayingLow.gather_rumors(player)
    end

    test "visit_contact advances time and reduces Heat", %{player: player} do
      assert {:ok, [{:advance_time, 6}, {:heat, -5}], %{narrative: _}} =
               LayingLow.visit_contact(player)
    end

    test "train advances time and reduces Heat", %{player: player} do
      assert {:ok, [{:advance_time, 8}, {:heat, -2}], %{narrative: _}} = LayingLow.train(player)
    end

    test "burn_evidence advances time, reduces Heat, and spends scrip", %{player: player} do
      assert {:ok, [{:advance_time, 4}, {:heat, -15}, {:scrip, -25}], %{narrative: _}} =
               LayingLow.burn_evidence(player)
    end
  end

  describe "activities when not laying low" do
    test "every activity errors :not_laying_low" do
      player = %Player{mode: nil, scrip: 100}

      assert LayingLow.rest(player) == {:error, :not_laying_low}
      assert LayingLow.gather_rumors(player) == {:error, :not_laying_low}
      assert LayingLow.visit_contact(player) == {:error, :not_laying_low}
      assert LayingLow.train(player) == {:error, :not_laying_low}
      assert LayingLow.burn_evidence(player) == {:error, :not_laying_low}
    end
  end

  describe "burn_evidence affordability" do
    test "errors when scrip is below the cost" do
      player = %Player{mode: "laying_low", scrip: 24}

      assert LayingLow.burn_evidence(player) == {:error, :insufficient_scrip}
    end
  end
end
