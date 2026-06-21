defmodule Shunt.FencingTest do
  use Shunt.DataCase

  alias Shunt.Fencing
  alias Shunt.Fencing.Catalog
  alias Shunt.Players

  describe "find_lead/1" do
    test "sets current_offer_key to a valid catalog key when idle" do
      player = Players.create_player!()

      assert {:ok, updated} = Fencing.find_lead(player)

      valid_keys = Enum.map(Catalog.items(), & &1.key)
      assert updated.current_offer_key in valid_keys
    end

    test "returns an error when an offer is already pending" do
      player = Players.create_player!()
      {:ok, player} = Fencing.find_lead(player)

      assert Fencing.find_lead(player) == {:error, :offer_in_progress}
    end
  end
end
