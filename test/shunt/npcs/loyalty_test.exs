defmodule Shunt.Npcs.LoyaltyTest do
  use Shunt.DataCase

  alias Shunt.Npcs.Loyalty
  alias Shunt.Players

  describe "value/2" do
    test "defaults to 50 for an NPC the player has never met" do
      player = Players.create_player!()
      assert Loyalty.value(player, "mother_graft") == 50
    end

    test "reads the stored value once the player has met the NPC" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 80})
        |> Repo.update!()

      assert Loyalty.value(player, "mother_graft") == 80
    end
  end

  describe "met?/2" do
    test "false when the player has no entry for the npc_key" do
      player = Players.create_player!()
      refute Loyalty.met?(player, "mother_graft")
    end

    test "true once npc_loyalty has an entry for the npc_key" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 80})
        |> Repo.update!()

      assert Loyalty.met?(player, "mother_graft")
    end
  end

  describe "band_for/1" do
    test "0-24 is :hostile" do
      assert Loyalty.band_for(0) == :hostile
      assert Loyalty.band_for(24) == :hostile
    end

    test "25-74 is :neutral" do
      assert Loyalty.band_for(25) == :neutral
      assert Loyalty.band_for(74) == :neutral
    end

    test "75-100 is :favored" do
      assert Loyalty.band_for(75) == :favored
      assert Loyalty.band_for(100) == :favored
    end
  end

  describe "clamp/1" do
    test "clamps below 0 up to 0" do
      assert Loyalty.clamp(-5) == 0
    end

    test "clamps above 100 down to 100" do
      assert Loyalty.clamp(105) == 100
    end
  end

  describe "roll_reliable?/2" do
    test "always true in the neutral band" do
      player = Players.create_player!()

      assert Enum.all?(1..200, fn _ -> Loyalty.roll_reliable?(player, "mother_graft") end)
    end

    test "always true in the favored band" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 80})
        |> Repo.update!()

      assert Enum.all?(1..200, fn _ -> Loyalty.roll_reliable?(player, "mother_graft") end)
    end

    test "can return false in the hostile band" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 0})
        |> Repo.update!()

      results = Enum.map(1..200, fn _ -> Loyalty.roll_reliable?(player, "mother_graft") end)

      assert Enum.any?(results, &(&1 == false))
    end
  end

  describe "price_multiplier/2" do
    test "0.8 in hostile, 1.0 in neutral, 1.2 in favored" do
      hostile_player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 0})
        |> Repo.update!()

      neutral_player = Players.create_player!()

      favored_player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 80})
        |> Repo.update!()

      assert Loyalty.price_multiplier(hostile_player, "mother_graft") == 0.8
      assert Loyalty.price_multiplier(neutral_player, "mother_graft") == 1.0
      assert Loyalty.price_multiplier(favored_player, "mother_graft") == 1.2
    end
  end

  describe "cost_multiplier/2" do
    test "1.25 in hostile, 1.0 in neutral, 0.8 in favored" do
      hostile_player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 0})
        |> Repo.update!()

      neutral_player = Players.create_player!()

      favored_player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 80})
        |> Repo.update!()

      assert Loyalty.cost_multiplier(hostile_player, "mother_graft") == 1.25
      assert Loyalty.cost_multiplier(neutral_player, "mother_graft") == 1.0
      assert Loyalty.cost_multiplier(favored_player, "mother_graft") == 0.8
    end
  end

  describe "record_interaction/2" do
    test "seeds at 50 and adds @gain (5) for a first-time interaction, met_for_first_time: true" do
      player = Players.create_player!()
      interaction = Loyalty.record_interaction(player, "mother_graft")

      assert interaction.npc_loyalty["mother_graft"] == 55
      assert interaction.met_for_first_time == true
      assert interaction.old_band == :neutral
      assert interaction.new_band == :neutral
    end

    test "adds @gain (5) to an existing value, met_for_first_time: false" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 60})
        |> Repo.update!()

      interaction = Loyalty.record_interaction(player, "mother_graft")

      assert interaction.npc_loyalty["mother_graft"] == 65
      assert interaction.met_for_first_time == false
    end

    test "old_band/new_band differ when the gain crosses a band threshold" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 73})
        |> Repo.update!()

      interaction = Loyalty.record_interaction(player, "mother_graft")

      assert interaction.npc_loyalty["mother_graft"] == 78
      assert interaction.old_band == :neutral
      assert interaction.new_band == :favored
    end

    test "clamps at 100 (gain doesn't overshoot)" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(npc_loyalty: %{"mother_graft" => 98})
        |> Repo.update!()

      interaction = Loyalty.record_interaction(player, "mother_graft")

      assert interaction.npc_loyalty["mother_graft"] == 100
    end
  end
end
