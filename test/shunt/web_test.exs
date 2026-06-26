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
    test "the supplier investigation is hidden at supplier_drop without the knowledge" do
      player = %Player{knowledge: []}

      refute "shunt9_bazaar_juno_supplier_investigation" in World.points_of_interest(
               player,
               "shunt9_supplier_drop"
             )
    end

    test "the supplier investigation appears at supplier_drop once the knowledge is held" do
      player = %Player{knowledge: [@knowledge]}

      assert "shunt9_bazaar_juno_supplier_investigation" in World.points_of_interest(
               player,
               "shunt9_supplier_drop"
             )
    end
  end

  describe "juno arc content wiring" do
    test "the opening job grants the parcel as the outbound carry item" do
      effects = Events.get!("shunt9_bazaar_juno_move_package").on_complete

      assert {:inventory, "juno_parcel", 1} in effects
    end

    test "the move package report grants trust with juno" do
      effects = Events.get!("shunt9_bazaar_juno_move_package_report").on_complete

      assert {:modify_rep, "juno", :trust, delta} =
               Enum.find(effects, &match?({:modify_rep, _, :trust, _}, &1))

      assert delta > 0
    end

    test "the quiet pickup report grants the supplier knowledge" do
      effects = Events.get!("shunt9_bazaar_juno_quiet_pickup_report").on_complete

      assert {:knowledge, @knowledge} in effects
    end
  end

  describe "move a package round trip" do
    test "completing move_package leaves the player carrying juno_parcel" do
      effects = Events.get!("shunt9_bazaar_juno_move_package").on_complete

      assert {:inventory, "juno_parcel", 1} in effects
    end

    test "the deliver POI appears at food_stalls only while carrying juno_parcel" do
      player_without = %Player{}
      player_with = %Player{inventory: %{"juno_parcel" => 1}}

      refute "shunt9_bazaar_juno_deliver_parcel" in World.points_of_interest(
               player_without,
               "shunt9_food_stalls"
             )

      assert "shunt9_bazaar_juno_deliver_parcel" in World.points_of_interest(
               player_with,
               "shunt9_food_stalls"
             )
    end

    test "completing the deliver POI removes the parcel and grants juno_delivery_receipt" do
      effects = Events.get!("shunt9_bazaar_juno_deliver_parcel").on_complete

      assert {:inventory, "juno_parcel", -1} in effects
      assert {:inventory, "juno_delivery_receipt", 1} in effects
    end

    test "the report POI appears at bazaar only while carrying juno_delivery_receipt" do
      player_without = %Player{}
      player_with = %Player{inventory: %{"juno_delivery_receipt" => 1}}

      refute "shunt9_bazaar_juno_move_package_report" in World.points_of_interest(
               player_without,
               "shunt9_bazaar"
             )

      assert "shunt9_bazaar_juno_move_package_report" in World.points_of_interest(
               player_with,
               "shunt9_bazaar"
             )
    end

    test "completing the report POI applies scrip/trust payout and consumes the receipt" do
      effects = Events.get!("shunt9_bazaar_juno_move_package_report").on_complete

      assert {:inventory, "juno_delivery_receipt", -1} in effects
      assert {:scrip, scrip} = Enum.find(effects, &match?({:scrip, _}, &1))
      assert scrip > 0
      assert {:modify_rep, "juno", :trust, trust} =
               Enum.find(effects, &match?({:modify_rep, "juno", :trust, _}, &1))

      assert trust > 0
    end

    test "supplier_investigation is a POI at supplier_drop gated by knowledge, not at bazaar" do
      player_without = %Player{knowledge: []}
      player_with = %Player{knowledge: [@knowledge]}

      refute "shunt9_bazaar_juno_supplier_investigation" in World.points_of_interest(
               player_without,
               "shunt9_supplier_drop"
             )

      assert "shunt9_bazaar_juno_supplier_investigation" in World.points_of_interest(
               player_with,
               "shunt9_supplier_drop"
             )

      refute "shunt9_bazaar_juno_supplier_investigation" in World.points_of_interest(
               player_with,
               "shunt9_bazaar"
             )
    end
  end

  defp location_ids(player) do
    player |> World.accessible_locations() |> Enum.map(& &1.id)
  end
end
