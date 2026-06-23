defmodule Shunt.PlayersTest do
  use Shunt.DataCase

  alias Shunt.Players
  alias Shunt.Players.Player

  describe "create_player!/0" do
    test "creates a player with default resource values" do
      player = Players.create_player!()

      assert player.cred == 0
      assert player.scrip == 0
      assert player.heat == 0
    end

    test "creates a player with no offer or held item" do
      player = Players.create_player!()

      assert player.current_offer_key == nil
      assert player.held_item_key == nil
    end

    test "creates a player with all skill trees locked at tier 0" do
      player = Players.create_player!()

      assert player.ghostwork_tier == 0
      assert player.chrome_meat_tier == 0
      assert player.web_tier == 0
      assert player.street_alchemy_tier == 0
    end

    # TODO: add a test asserting Players.create_player!() starts with
    # location_id == "shunt9_player_squat" and discovered_locations == [] —
    # this is the migration round-trip test called for in Phase 1 (proves the
    # new players.location_id/discovered_locations columns and their defaults
    # actually persist through Repo.insert!/1 + the new migration).
  end

  describe "get_player!/0" do
    test "returns the existing player" do
      player = Players.create_player!()

      assert Players.get_player!().id == player.id
    end
  end

  describe "can_lay_low?/1" do
    test "returns true when cred covers the cost" do
      player = %Player{cred: 10}

      assert Players.can_lay_low?(player)
    end

    test "returns false when cred is below the cost" do
      player = %Player{cred: 9}

      refute Players.can_lay_low?(player)
    end
  end

  describe "lay_low/1" do
    test "returns an effect list reducing cred and heat" do
      player = %Player{cred: 30, heat: 40}

      assert Players.lay_low(player) == {:ok, [{:cred, -10}, {:heat, -20}]}
    end

    test "returns an error when cred is below the cost" do
      player = %Player{cred: 5, heat: 40}

      assert Players.lay_low(player) == {:error, :insufficient_cred}
    end
  end
end
