defmodule Shunt.WebTest do
  use ExUnit.Case, async: true

  alias Shunt.Events
  alias Shunt.Movement
  alias Shunt.Players.Player
  alias Shunt.World

  @knowledge "juno_secret_supplier"
  @trust_reveal_threshold 20

  describe "knowledge reveal (gated location)" do
    test "the supplier drop is hidden and unreachable without the knowledge" do
      player = %Player{location_id: "shunt9_bazaar", knowledge: []}

      refute "shunt9_supplier_drop" in location_ids(player)
      refute Movement.can_move?(player, "shunt9_supplier_drop")
    end

    test "the supplier drop appears and is reachable once the knowledge is held" do
      player = %Player{location_id: "shunt9_bazaar", knowledge: [@knowledge]}

      assert "shunt9_supplier_drop" in location_ids(player)
      assert Movement.can_move?(player, "shunt9_supplier_drop")
    end
  end

  describe "trust reveal (gated exit)" do
    test "the cargo chute is hidden and unreachable below the trust threshold" do
      player = %Player{location_id: "shunt9_bazaar", reputation: %{"juno" => %{trust: 5}}}

      refute "shunt9_cargo_chute" in location_ids(player)
      refute Movement.can_move?(player, "shunt9_cargo_chute")
    end

    test "the cargo chute appears once trust reaches the threshold" do
      player = %Player{
        location_id: "shunt9_bazaar",
        reputation: %{"juno" => %{trust: @trust_reveal_threshold}}
      }

      assert "shunt9_cargo_chute" in location_ids(player)
      assert Movement.can_move?(player, "shunt9_cargo_chute")
    end
  end

  describe "gated point of interest" do
    test "the supplier investigation is hidden at the bazaar without the knowledge" do
      player = %Player{knowledge: []}

      refute "shunt9_bazaar_juno_supplier_investigation" in World.points_of_interest(
               player,
               "shunt9_bazaar"
             )
    end

    test "the supplier investigation appears once the knowledge is held" do
      player = %Player{knowledge: [@knowledge]}

      assert "shunt9_bazaar_juno_supplier_investigation" in World.points_of_interest(
               player,
               "shunt9_bazaar"
             )
    end
  end

  describe "juno arc content wiring" do
    test "the opening job grants trust with juno" do
      effects = Events.get!("shunt9_bazaar_juno_move_package").on_complete

      assert {:modify_rep, "juno", :trust, delta} =
               Enum.find(effects, &match?({:modify_rep, _, :trust, _}, &1))

      assert delta > 0
    end

    test "the quiet pickup grants the supplier knowledge" do
      effects = Events.get!("shunt9_bazaar_juno_quiet_pickup").on_complete

      assert {:knowledge, @knowledge} in effects
    end
  end

  defp location_ids(player) do
    player |> World.accessible_locations() |> Enum.map(& &1.id)
  end
end
